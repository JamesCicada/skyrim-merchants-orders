using System.Text;
using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;

internal sealed record Material(string EditorId, string Name, int UnitPrice, int CapacityPerDay);
internal sealed record MerchantSpec(string EditorId, string Name, string City, string Catalog);
internal sealed record CatalogSpec(string Version, int[] QuantityChoices, Material[] Items,
    Dictionary<string, string[]> Catalogs, MerchantSpec[] Merchants);
internal sealed record ResolvedMerchant(MerchantSpec Spec, FormKey Npc, FormKey Reference,
    FormKey Chest, string Voice);
internal sealed record Expansion(CatalogSpec Spec, ResolvedMerchant[] Merchants, FormKey[] Items,
    int AddedMessages, int AddedResponses);

internal static class CatalogExpansion {
    static string Q(string value) => JsonSerializer.Serialize(value);
    static string Hex(uint id) => $"0x{id:X8}";
    static string Form(FormKey key, string type) => $"(Game.GetForm({Hex(key.ID)}) as {type})";
    static string Own(FormKey key, string type) =>
        $"(Game.GetFormFromFile({Hex(key.ID)}, \"MerchantOrders.esp\") as {type})";

    internal static Expansion Add(SkyrimMod mod, ISkyrimModGetter master, Quest quest,
        DialogTopic topic, string sourceDirectory, string configPath) {
        var spec = JsonSerializer.Deserialize<CatalogSpec>(File.ReadAllText(configPath),
            new JsonSerializerOptions { PropertyNameCaseInsensitive = true })
            ?? throw new InvalidDataException("Empty materials catalog");
        var commonOnly = new HashSet<string> {
            "IngotIron", "IngotSteel", "OreIron", "Leather01", "LeatherStrips", "Firewood01"
        };
        if (!spec.Items.Select(i => i.EditorId).ToHashSet().SetEquals(commonOnly) ||
            spec.Items.Length != commonOnly.Count)
            throw new InvalidDataException("Catalog must contain exactly the approved common materials.");
        if (!spec.QuantityChoices.SequenceEqual(new[] { 10, 25, 50 }) ||
            spec.Items.Any(i => i.UnitPrice <= 0 || i.UnitPrice > 100 || i.CapacityPerDay <= 0 || i.CapacityPerDay > 100))
            throw new InvalidDataException("Invalid material pricing, capacity, or quantity choices.");
        if (spec.Catalogs.Count != 2 || !spec.Catalogs.ContainsKey("general") || !spec.Catalogs.ContainsKey("blacksmith") ||
            spec.Catalogs.Values.Any(items => items.Length is < 1 or > 8 ||
                items.Distinct().Count() != items.Length || items.Any(i => !commonOnly.Contains(i))) ||
            spec.Catalogs["general"].Contains("IngotSteel") || spec.Catalogs["blacksmith"].Contains("Firewood01"))
            throw new InvalidDataException("Invalid merchant specialties.");
        if (spec.Merchants.Length != 11 || spec.Merchants.Select(m => m.EditorId).Distinct().Count() != 11 ||
            spec.Merchants.Any(m => !spec.Catalogs.ContainsKey(m.Catalog)) ||
            spec.Merchants.Select(m => m.City).Distinct().Count() != 5)
            throw new InvalidDataException("Expected eleven supported merchants in five cities.");

        var materialForms = spec.Items.Select(i =>
            master.MiscItems.Single(m => m.EditorID == i.EditorId).FormKey).ToArray();
        // Include exterior placements as well as interior shops.
        var placements = master.EnumerateMajorRecords()
            .Where(r => r is IPlacedNpcGetter or IPlacedObjectGetter).ToList();
        var resolved = spec.Merchants.Select(m => {
            var npc = master.Npcs.Single(n => n.EditorID == m.EditorId);
            var reference = placements.OfType<IPlacedNpcGetter>().Single(r => r.Base.FormKey == npc.FormKey);
            var chests = npc.Factions.Select(f => master.Factions.Single(x => x.FormKey == f.Faction.FormKey))
                .Where(f => !f.MerchantContainer.IsNull).Select(f => f.MerchantContainer.FormKey).Distinct().ToArray();
            if (chests.Length != 1) throw new InvalidDataException($"Ambiguous vendor chest: {m.EditorId}");
            var chest = placements.OfType<IPlacedObjectGetter>().Single(r => r.FormKey == chests[0]);
            if (!master.Containers.Any(c => c.FormKey == chest.Base.FormKey))
                throw new InvalidDataException($"Vendor destination is not a container: {m.EditorId}");
            var voice = master.VoiceTypes.Single(v => v.FormKey == npc.Voice.FormKey).EditorID
                ?? throw new InvalidDataException($"Missing voice type: {m.EditorId}");
            return new ResolvedMerchant(m, npc.FormKey, reference.FormKey, chests[0], voice);
        }).ToArray();

        Message Menu(string id, string text, params string[] buttons) {
            var menu = new Message(mod, id) {
                Name = "Merchant Orders", Description = text, Flags = Mutagen.Bethesda.Skyrim.Message.Flag.MessageBox
            };
            foreach (var button in buttons) menu.MenuButtons.Add(new MessageButton { Text = button });
            mod.Messages.Add(menu);
            return menu;
        }
        int Days(Material item, int quantity) => (quantity + item.CapacityPerDay - 1) / item.CapacityPerDay;
        var quantityMenus = spec.Items.Select(i => Menu("MO_Quantity_" + i.EditorId,
            $"{i.Name}\n\n" + string.Join("\n", spec.QuantityChoices.Select(q =>
                $"{q}: {q * i.UnitPrice} gold / {Days(i, q)} game day(s)")) +
            "\n\nPay upfront. Pickup from the merchant who took your order.",
            spec.QuantityChoices.Select(q => q.ToString()).Append("Cancel").ToArray())).ToArray();
        var confirmMenus = spec.Items.Select(i => Menu("MO_Confirm_" + i.EditorId,
            $"Order %.0f {i.Name} for %.0f gold?\n\nPickup in %.0f game day(s) from this merchant. No delivery fee. No cancellation or refund.",
            "Pay and confirm", "Cancel")).ToArray();
        var mainMenus = resolved.Select(m => Menu("MO_Main_" + m.Spec.EditorId,
            $"{m.Spec.Name} - {m.Spec.City}\nMaterial orders\n\nCommon supplies only. Larger orders take longer. One outstanding order across all merchants.",
            "Place an order", "Order status", "Collect order", "Leave")).ToArray();
        var itemMenus = resolved.Select(m => Menu("MO_Items_" + m.Spec.EditorId,
            $"{m.Spec.Name} - {m.Spec.City}\nChoose a common material.",
            spec.Catalogs[m.Spec.Catalog].Select(id => spec.Items.Single(i => i.EditorId == id).Name)
                .Append("Cancel").ToArray())).ToArray();

        // New INFOs are appended only after all existing 0.1.2 records.
        var takeLook = master.DialogTopics.Single(t => t.EditorID == "OfferServicesTopic")
            .Responses.Single(r => r.FormKey.ID == 0x07F6BC);
        foreach (var m in resolved.Where(m => m.Spec.EditorId != "Belethor")) {
            var response = new DialogResponses(mod, "MO_Response_" + m.Spec.EditorId) {
                Flags = new DialogResponseFlags {
                    Flags = DialogResponses.Flag.Goodbye | DialogResponses.Flag.ForceSubtitle
                },
                VirtualMachineAdapter = new DialogResponsesAdapter {
                    Version = 5, ObjectFormat = 2,
                    ScriptFragments = new ScriptFragments {
                        ExtraBindDataVersion = 2, FileName = "MO_OrderDialogue",
                        OnBegin = new ScriptFragment {
                            ExtraBindDataVersion = 1, ScriptName = "MO_OrderDialogue", FragmentName = "Fragment_0"
                        }
                    }
                }
            };
            response.ResponseData.SetTo(takeLook.FormKey);
            response.Topic.SetTo(topic.FormKey);
            response.PreviousDialog.SetTo(topic.Responses.Last().FormKey);
            var condition = new GetIsIDConditionData();
            condition.Object.Link.SetTo(m.Npc);
            response.Conditions.Add(new ConditionFloat {
                CompareOperator = CompareOperator.EqualTo, ComparisonValue = 1, Data = condition
            });
            var script = new ScriptEntry { Name = "MO_OrderDialogue" };
            var property = new ScriptObjectProperty {
                Name = "OrderManager", Flags = ScriptProperty.Flag.Edited, Alias = -1
            };
            property.Object.SetTo(quest.FormKey);
            script.Properties.Add(property);
            response.VirtualMachineAdapter.Scripts.Add(script);
            topic.Responses.Add(response);
        }

        var code = new StringBuilder("Scriptname MO_Catalog Hidden\n; Generated from catalogs/materials.json and Skyrim.esm. Do not edit.\n\n");
        void Lookup(string type, string name, string argument, IEnumerable<(string condition, string result)> entries, string fallback) {
            code.AppendLine($"{type} Function {name}({argument}) Global");
            foreach (var entry in entries) {
                code.AppendLine($"    If {entry.condition}");
                code.AppendLine($"        Return {entry.result}");
                code.AppendLine("    EndIf");
            }
            code.AppendLine($"    Return {fallback}");
            code.AppendLine("EndFunction\n");
        }
        Lookup("Int", "MerchantIndex", "Actor akMerchant", resolved.Select((m, i) =>
            ($"akMerchant == {Form(m.Reference, "Actor")}", i.ToString())), "-1");
        Lookup("String", "MerchantName", "Actor akMerchant", resolved.Select((m, i) =>
            ($"MerchantIndex(akMerchant) == {i}", Q(m.Spec.Name + " in " + m.Spec.City))), Q("the original merchant"));
        Lookup("ObjectReference", "MerchantFunds", "Actor akMerchant", resolved.Select((m, i) =>
            ($"MerchantIndex(akMerchant) == {i}", Form(m.Chest, "ObjectReference"))), "None");
        Lookup("Message", "MainMenu", "Actor akMerchant", resolved.Select((m, i) =>
            ($"MerchantIndex(akMerchant) == {i}", Own(mainMenus[i].FormKey, "Message"))), "None");
        Lookup("Message", "ItemMenu", "Actor akMerchant", resolved.Select((m, i) =>
            ($"MerchantIndex(akMerchant) == {i}", Own(itemMenus[i].FormKey, "Message"))), "None");
        Lookup("Int", "ItemIndex", "MiscObject akItem", materialForms.Select((f, i) =>
            ($"akItem == {Form(f, "MiscObject")}", i.ToString())), "-1");
        Lookup("MiscObject", "ItemForm", "Int aiItem", materialForms.Select((f, i) =>
            ($"aiItem == {i}", Form(f, "MiscObject"))), "None");
        Lookup("String", "ItemName", "Int aiItem", spec.Items.Select((m, i) =>
            ($"aiItem == {i}", Q(m.Name))), Q("materials"));
        Lookup("Int", "UnitPrice", "Int aiItem", spec.Items.Select((m, i) =>
            ($"aiItem == {i}", m.UnitPrice.ToString())), "0");
        Lookup("Int", "Capacity", "Int aiItem", spec.Items.Select((m, i) =>
            ($"aiItem == {i}", m.CapacityPerDay.ToString())), "0");
        Lookup("Message", "QuantityMenu", "Int aiItem", quantityMenus.Select((m, i) =>
            ($"aiItem == {i}", Own(m.FormKey, "Message"))), "None");
        Lookup("Message", "Confirmation", "Int aiItem", confirmMenus.Select((m, i) =>
            ($"aiItem == {i}", Own(m.FormKey, "Message"))), "None");
        var choices = resolved.SelectMany((m, merchantIndex) => spec.Catalogs[m.Spec.Catalog].Select((id, choice) =>
            ($"MerchantIndex(akMerchant) == {merchantIndex} && aiChoice == {choice}",
             Array.FindIndex(spec.Items, i => i.EditorId == id).ToString())));
        Lookup("Int", "ItemForChoice", "Actor akMerchant, Int aiChoice", choices, "-1");
        Lookup("Bool", "CanOrder", "Actor akMerchant, Int aiItem", resolved.Select((m, merchantIndex) =>
            ($"MerchantIndex(akMerchant) == {merchantIndex} && (" + string.Join(" || ",
                spec.Catalogs[m.Spec.Catalog].Select(id => "aiItem == " + Array.FindIndex(spec.Items, i => i.EditorId == id))) + ")", "True")), "False");
        code.AppendLine("""
Float Function LeadDays(Int aiItem, Int aiQuantity) Global
    Int dailyCapacity = Capacity(aiItem)
    If dailyCapacity <= 0 || aiQuantity <= 0 || aiQuantity > 500
        Return 0.0
    EndIf
    Int days = (aiQuantity + dailyCapacity - 1) / dailyCapacity
    Return days as Float
EndFunction
""");
        Directory.CreateDirectory(sourceDirectory);
        File.WriteAllText(Path.Combine(sourceDirectory, "MO_Catalog.psc"), code.ToString());
        return new Expansion(spec, resolved, materialForms, quantityMenus.Length + confirmMenus.Length +
            mainMenus.Length + itemMenus.Length, resolved.Length - 1);
    }

    internal static void Validate(ISkyrimModGetter read, Expansion expansion) {
        void Check(bool value, string message) {
            if (!value) throw new InvalidDataException(message);
            Console.WriteLine("PASS " + message);
        }
        Check(read.Messages.Count == 10 + expansion.AddedMessages, "Every item and merchant menu serialized");
        var responses = read.DialogTopics.Single().Responses;
        Check(responses.Count == 3 + expansion.AddedResponses, "All eleven merchants have order dialogue");
        var expected = expansion.Merchants.Select(m => m.Npc).ToHashSet();
        var actual = responses.Where(r => r.EditorID != "MO_DynamicResponse").Select(r => ((IGetIsIDConditionDataGetter)r.Conditions.Single().Data).Object.Link.FormKey).ToHashSet();
        Check(actual.SetEquals(expected), "Dialogue eligibility matches the explicit merchant allowlist");
        Check(responses.All(r => r.VirtualMachineAdapter!.ScriptFragments!.OnBegin?.FragmentName == "Fragment_0" &&
            r.VirtualMachineAdapter.Scripts.Single().Properties.OfType<IScriptObjectPropertyGetter>().Single().Object.FormKey ==
            read.Quests.Single().FormKey), "Every merchant routes to the same persistent order manager");
        Check(expansion.Spec.Items.Length == 6 && expansion.Items.Distinct().Count() == 6,
            "Only six distinct common material forms are orderable");
        foreach (var item in expansion.Spec.Items) {
            var menu = read.Messages.Single(m => m.EditorID == "MO_Quantity_" + item.EditorId);
            var text = menu.Description?.ToString() ?? "";
            Check(expansion.Spec.QuantityChoices.All(q =>
                text.Contains($"{q}: {q * item.UnitPrice} gold / {(q + item.CapacityPerDay - 1) / item.CapacityPerDay} game day(s)")),
                item.Name + " prices and quantity lead times agree");
        }
    }
}
