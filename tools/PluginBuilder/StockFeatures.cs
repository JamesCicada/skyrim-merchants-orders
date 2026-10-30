using System.Text;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;

internal sealed record StockOutput(FormKey Enabled, FormKey Common, FormKey Excluded, int AddedMessages, int AddedResponses);

internal static class StockFeatures {
    internal static StockOutput AddCore(SkyrimMod mod, ISkyrimModGetter master, Quest quest,
        DialogTopic topic, Expansion expansion, string sourceDirectory) {
        using var fieldStream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("OrderFields.json")
            ?? throw new InvalidDataException("Missing saved-field baseline");
        var oldFields = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, string>>(fieldStream)!;
        var source = File.ReadAllText(Path.Combine(sourceDirectory, "MO_OrderManager.psc"));
        var header = new System.Text.RegularExpressions.Regex(@"(?m)^(?:\w+(?:\[\])?\s+)?Function\s").Split(source, 2)[0];
        var fields = System.Text.RegularExpressions.Regex.Matches(header, @"(?m)^(\w+(?:\[\])?)\s+(?:Property\s+)?(\w+)(?:\s|$)")
            .ToDictionary(m => m.Groups[2].Value, m => m.Groups[1].Value.ToLowerInvariant());
        if (oldFields.Any(entry => !fields.TryGetValue(entry.Key, out var kind) || kind != entry.Value))
            throw new InvalidDataException("An existing order field/property was removed or changed type");
        Console.WriteLine($"PASS All {oldFields.Count} existing order fields/properties retain their types");
        uint vendorMask = Convert.ToUInt32(Enum.Parse(master.Factions.First().Flags.GetType(), "Vendor"));
        var enabled = new GlobalFloat(mod, "MO_DynamicOrdersEnabled") { Data = 0 };
        mod.Globals.Add(enabled);
        var common = new FormList(mod, "MO_CommonMaterials");
        foreach (var key in expansion.Items)
            common.Items.Add(new FormLink<ISkyrimMajorRecordGetter>(key));
        mod.FormLists.Add(common);
        var excluded = new FormList(mod, "MO_ExcludedFood");
        foreach (var item in master.Ingestibles.Where(p =>
            new[] { "skooma", "homecooked", "sleepingtree", "balmorablue" }
                .Any(text => (p.EditorID ?? "").Contains(text, StringComparison.OrdinalIgnoreCase) ||
                    (p.Name?.ToString() ?? "").Replace(" ", "").Contains(text, StringComparison.OrdinalIgnoreCase))))
            excluded.Items.Add(new FormLink<ISkyrimMajorRecordGetter>(item.FormKey));
        mod.FormLists.Add(excluded);

        var menu = new Message(mod, "MO_DynamicMainMenu") {
            Name = "Merchant Orders", Description = "Orders from this merchant's trade stock\n\nCommon materials and ordinary food/drink only. One outstanding order globally.",
            Flags = Mutagen.Bethesda.Skyrim.Message.Flag.MessageBox
        };
        foreach (var label in new[] { "Place an order", "Order status", "Collect / resolve delivery", "Settings", "Leave" })
            menu.MenuButtons.Add(new MessageButton { Text = label });
        mod.Messages.Add(menu);

        var response = new DialogResponses(mod, "MO_DynamicResponse") {
            Flags = new DialogResponseFlags { Flags = DialogResponses.Flag.Goodbye | DialogResponses.Flag.ForceSubtitle },
            VirtualMachineAdapter = new DialogResponsesAdapter {
                Version = 5, ObjectFormat = 2,
                ScriptFragments = new ScriptFragments {
                    ExtraBindDataVersion = 2, FileName = "MO_OrderDialogue",
                    OnBegin = new ScriptFragment { ExtraBindDataVersion = 1, ScriptName = "MO_OrderDialogue", FragmentName = "Fragment_0" }
                }
            }
        };
        response.Topic.SetTo(topic.FormKey);
        response.PreviousDialog.SetTo(topic.Responses.Last().FormKey);
        response.ResponseData.SetTo(master.DialogTopics.Single(t => t.EditorID == "OfferServicesTopic")
            .Responses.Single(r => r.FormKey.ID == 0x07F6BC).FormKey);
        var flag = new GetGlobalValueConditionData();
        flag.Global.Link.SetTo(enabled.FormKey);
        response.Conditions.Add(new ConditionFloat { Data = flag, CompareOperator = CompareOperator.EqualTo, ComparisonValue = 1 });
        response.Conditions.Add(new ConditionFloat {
            Data = new GetOffersServicesNowConditionData(), CompareOperator = CompareOperator.EqualTo, ComparisonValue = 1
        });
        // Keep the original merchant INFOs and Belethor's random group authoritative.
        foreach (var merchant in expansion.Merchants) {
            var condition = new GetIsIDConditionData();
            condition.Object.Link.SetTo(merchant.Npc);
            response.Conditions.Add(new ConditionFloat { Data = condition, CompareOperator = CompareOperator.NotEqualTo, ComparisonValue = 1 });
        }
        var script = new ScriptEntry { Name = "MO_OrderDialogue" };
        var manager = new ScriptObjectProperty { Name = "OrderManager", Alias = -1, Flags = ScriptProperty.Flag.Edited };
        manager.Object.SetTo(quest.FormKey);
        script.Properties.Add(manager);
        response.VirtualMachineAdapter.Scripts.Add(script);
        topic.Responses.Add(response);

        string Own(FormKey key, string type) =>
            $"(Game.GetFormFromFile(0x{key.ID:X8}, \"MerchantOrders.esp\") as {type})";
        var code = new StringBuilder("\n; Dynamic-mode records are appended after all 0.3.0 forms.\n");
        code.AppendLine($"GlobalVariable Function DynamicOrdersEnabled() Global\n    Return {Own(enabled.FormKey, "GlobalVariable")}\nEndFunction\n");
        code.AppendLine($"FormList Function CommonMaterials() Global\n    Return {Own(common.FormKey, "FormList")}\nEndFunction\n");
        code.AppendLine($"FormList Function ExcludedFood() Global\n    Return {Own(excluded.FormKey, "FormList")}\nEndFunction\n");
        code.AppendLine($"Message Function DynamicMainMenu() Global\n    Return {Own(menu.FormKey, "Message")}\nEndFunction\n");
        code.AppendLine($"Int Function VendorFactionFlag() Global\n    Return {vendorMask}\nEndFunction\n");
        File.AppendAllText(Path.Combine(sourceDirectory, "MO_Catalog.psc"), code.ToString());
        return new StockOutput(enabled.FormKey, common.FormKey, excluded.FormKey, 1, 1);
    }

    internal static void Validate(ISkyrimModGetter read, ISkyrimModGetter master, StockOutput output, Expansion expansion) {
        void Check(bool condition, string name) {
            if (!condition) throw new InvalidDataException(name);
            Console.WriteLine("PASS " + name);
        }
        Check(read.Globals.Single(g => g.FormKey == output.Enabled) is IGlobalFloatGetter global && global.Data == 0, "Dynamic dialogue remains disabled without the addon bootstrap");
        var common = read.FormLists.Single(f => f.FormKey == output.Common);
        var excluded = read.FormLists.Single(f => f.FormKey == output.Excluded);
        Check(common.Items.Select(x => x.FormKey).ToHashSet().SetEquals(expansion.Items),
            "Dynamic materials are limited to the common-material allowlist");
        var response = read.DialogTopics.Single().Responses.Single(r => r.EditorID == "MO_DynamicResponse");
        Check(response.Conditions[0].Data is IGetGlobalValueConditionDataGetter g && g.Global.Link.FormKey == output.Enabled &&
            response.Conditions[1].Data is IGetOffersServicesNowConditionDataGetter &&
            response.Conditions.Skip(2).All(c => c.CompareOperator == CompareOperator.NotEqualTo),
            "Dynamic dialogue is addon-gated, service-gated, and excludes legacy duplicates");

        bool Allowed(ISkyrimMajorRecordGetter record) => common.Items.Any(f => f.FormKey == record.FormKey) ||
            record is IIngestibleGetter food && food.Flags.HasFlag(Ingestible.Flag.FoodItem) &&
            food.Value <= 100 && !excluded.Items.Any(f => f.FormKey == record.FormKey);
        Check(Allowed(master.Ingestibles.Single(f => f.EditorID == "FoodHorkerStew")),
            "Horker Stew qualifies by its food flag even without keywords");
        Check(!Allowed(master.MiscItems.Single(f => f.EditorID == "IngotGold")) &&
            !Allowed(master.MiscItems.Single(f => f.EditorID == "IngotEbony")) &&
            !Allowed(master.Weapons.First()),
            "Rare ingots and equipment stay outside the dynamic filter");
        Check(!Allowed(master.Ingestibles.Single(f => f.EditorID == "Skooma")),
            "Skooma is excluded despite its misleading VendorItemFood keyword");
        uint vendorMask = Convert.ToUInt32(Enum.Parse(master.Factions.First().Flags.GetType(), "Vendor"));
        Check(vendorMask == 0x4000, "Vendor bit is 0x4000, not the obsolete 0x1000 mask");
        foreach (string name in new[] { "Anoriath", "CarlottaValentia", "Belethor", "Orgnar" }) {
            var npc = master.Npcs.Single(n => n.EditorID == name);
            var activeFactions = npc.Factions.Where(r => r.Rank >= 0)
                .Select(r => master.Factions.Single(f => f.FormKey == r.Faction.FormKey)).ToArray();
            var correctChests = activeFactions.Where(f => ((uint)f.Flags & vendorMask) == vendorMask &&
                !f.MerchantContainer.IsNull).Select(f => f.MerchantContainer.FormKey).Distinct().ToArray();
            Check(correctChests.Length == 1, name + " resolves to exactly one active vendor chest");
            Check(!activeFactions.Any(f => ((uint)f.Flags & 0x1000) != 0 && !f.MerchantContainer.IsNull),
                name + " reproduces the old wrong-mask rejection");
        }
        var orgnar = master.Npcs.Single(n => n.EditorID == "Orgnar");
        Check(orgnar.Factions.Select(f => master.Factions.Single(x => x.FormKey == f.Faction.FormKey))
            .Any(f => !f.MerchantContainer.IsNull), "Orgnar has a discoverable vanilla merchant container");
    }
}
