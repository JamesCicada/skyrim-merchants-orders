using System.Buffers.Binary;
using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;

if (args.Length != 4) {
    Console.Error.WriteLine("Usage: PluginBuilder <Skyrim.esm> <output Data directory> <source directory> <catalog JSON>");
    return 2;
}
string masterPath = Path.GetFullPath(args[0]);
string output = Path.GetFullPath(args[1]);
using var master = SkyrimMod.CreateFromBinaryOverlay(
    new ModPath(ModKey.FromNameAndExtension("Skyrim.esm"), masterPath), SkyrimRelease.SkyrimSE);
var merchant = master.Npcs.Single(n => n.EditorID == "Belethor");
var iron = master.MiscItems.Single(n => n.EditorID == "IngotIron");
var gold = master.MiscItems.Single(n => n.EditorID == "Gold001");
var merchantRefs = master.Cells.SelectMany(b => b.SubBlocks).SelectMany(b => b.Cells)
    .SelectMany(c => c.Persistent).OfType<IPlacedNpcGetter>()
    .Where(n => n.Base.FormKey == merchant.FormKey).ToList();
if (merchantRefs.Count != 1) throw new InvalidDataException("Expected exactly one persistent Belethor reference.");
var merchantRef = merchantRefs.Single();
// Keep the script's upgrade-safe vanilla lookup tied to actual master records.
var vendorChests = merchant.Factions
    .Select(f => master.Factions.Single(x => x.FormKey == f.Faction.FormKey))
    .Where(f => !f.MerchantContainer.IsNull)
    .Select(f => f.MerchantContainer.FormKey).Distinct().ToList();
var expectedVendorChest = new FormKey(master.ModKey, 0x09CAF9);
if (vendorChests.Count != 1 || vendorChests.Single() != expectedVendorChest)
    throw new InvalidDataException("Belethor vendor chest differs from the script binding; review payment destination.");
var vendorChest = master.Cells.SelectMany(b => b.SubBlocks).SelectMany(b => b.Cells)
    .SelectMany(c => c.Persistent.Concat(c.Temporary)).OfType<IPlacedObjectGetter>()
    .Single(r => r.FormKey == expectedVendorChest);
if (!master.Containers.Any(c => c.FormKey == vendorChest.Base.FormKey))
    throw new InvalidDataException("Payment destination must resolve to a container.");

int LeadDays(int quantity) => (quantity + 14) / 15;

var mod = new SkyrimMod(ModKey.FromNameAndExtension("MerchantOrders.esp"), SkyrimRelease.SkyrimSE);
mod.ModHeader.Author = "Merchant Orders";
mod.ModHeader.Description = "Merchant Orders 0.4.1 prototype: common material orders from city merchants.";
var quest = new Quest(mod, "MO_OrderQuest") {
    Name = "Merchant Orders", Priority = 30, QuestFormVersion = 65,
    Flags = Quest.Flag.StartGameEnabled,
    NextAliasID = 0,
    VirtualMachineAdapter = new QuestAdapter { Version = 5, ObjectFormat = 2, ExtraBindDataVersion = 2 }
};
mod.Quests.Add(quest);
var manager = new ScriptEntry { Name = "MO_OrderManager" };
quest.VirtualMachineAdapter.Scripts.Add(manager);

ScriptObjectProperty Bind(string name, FormKey key) {
    var property = new ScriptObjectProperty { Name = name, Flags = ScriptProperty.Flag.Edited, Alias = -1 };
    property.Object.SetTo(key);
    return property;
}
manager.Properties.Add(Bind("SupportedMerchant", merchantRef.FormKey));
manager.Properties.Add(Bind("IronIngot", iron.FormKey));
manager.Properties.Add(Bind("Gold", gold.FormKey));

void Message(string property, string text, params string[] buttons) {
    var msg = new Message(mod, "MO_" + property) {
        Name = "Merchant Orders", Description = text, Flags = Mutagen.Bethesda.Skyrim.Message.Flag.MessageBox
    };
    foreach (string button in buttons) msg.MenuButtons.Add(new MessageButton { Text = button });
    mod.Messages.Add(msg);
    manager.Properties.Add(Bind(property, msg.FormKey));
}
Message("MainMenu", "Belethor's General Goods\nBulk Iron Ingot orders\n\n12 gold per ingot. Sourcing capacity: 15 ingots per game day. One outstanding order. No refunds.",
    "Place an order", "Order status", "Collect order", "Leave");
Message("QuantityMenu", "Choose Iron Ingots\n\n10 ingots: 120 gold / 1 day\n25 ingots: 300 gold / 2 days\n50 ingots: 600 gold / 4 days\n\nLarger orders take longer. Pickup at Belethor's shop.",
    "10 ingots", "25 ingots", "50 ingots", "Cancel");
Message("ConfirmOrder", "Order %.0f Iron Ingots for %.0f gold?\n\nPay now; collect from Belethor in %.0f game day(s). No delivery fee. Orders cannot be cancelled or refunded.",
    "Pay and confirm", "Cancel");
Message("PendingStatus", "%.0f Iron Ingots ordered from Belethor.\nApproximately %.1f game hours remaining.\nPaid: %.0f gold (%.0f per ingot).\nQuoted lead time: %.0f game day(s).", "OK");
Message("ReadyStatus", "Your %.0f Iron Ingots are ready at Belethor's shop.\nAlready paid: %.0f gold. Select Collect order to receive them.", "OK");
Message("NoOrderStatus", "You have no outstanding order.", "OK");
Message("InsufficientGold", "This order costs %.0f gold. You do not have enough. No order was placed.", "OK");
Message("AcceptedOrder", "Order accepted: %.0f Iron Ingots.\nPaid: %.0f gold.\nReturn to Belethor in %.0f game day(s) to collect.", "OK");
Message("CollectedOrder", "Collected %.0f Iron Ingots. Thank you for your business.", "OK");
Message("Unavailable", "This merchant is unavailable. No new order can be placed.", "OK");

var branch = new DialogBranch(mod, "MO_MerchantOrdersBranch") {
    Category = DialogBranch.CategoryType.Player, Flags = DialogBranch.Flag.TopLevel
};
branch.Quest.SetTo(quest.FormKey);
mod.DialogBranches.Add(branch);
var topic = new DialogTopic(mod, "MO_MerchantOrdersTopic") {
    Name = "I'd like to place or collect an order.",
    Priority = 50, Category = DialogTopic.CategoryEnum.Topic,
    Subtype = DialogTopic.SubtypeEnum.Custom,
    SubtypeName = new("CUST")
};
topic.Quest.SetTo(quest.FormKey);
topic.Branch.SetTo(branch.FormKey);
branch.StartingTopic.SetTo(topic.FormKey);
mod.DialogTopics.Add(topic);
var offers = master.DialogTopics.Single(t => t.EditorID == "OfferServicesTopic");
string[] tradeTexts = {
    "Trinkets, odds and ends, that sort of thing.",
    "Some may call this junk. Me, I call them treasures.",
    "Take a look."
};
var tradeResponses = tradeTexts.Select(text => offers.Responses.Single(r =>
    r.Responses.Count == 1 && r.Responses[0].Text?.ToString() == text)).ToArray();

// Allocate the original INFO first, preserving every 0.1.0 form ID.
var info = new DialogResponses(mod, "MO_MerchantOrdersResponse");
var orderResponses = new[] {
    info,
    new DialogResponses(mod, "MO_MerchantOrdersResponseTreasures"),
    new DialogResponses(mod, "MO_MerchantOrdersResponseTakeALook")
};
for (int index = 0; index < orderResponses.Length; index++) {
    var responseInfo = orderResponses[index];
    responseInfo.Flags = new DialogResponseFlags {
        Flags = DialogResponses.Flag.Goodbye | DialogResponses.Flag.ForceSubtitle |
            DialogResponses.Flag.Random |
            (index == orderResponses.Length - 1 ? DialogResponses.Flag.RandomEnd : 0)
    };
    // Reuse only vanilla response data (including native voice/lip lookup).
    // Do not copy or invoke the vanilla barter fragment that opens inventory.
    responseInfo.ResponseData.SetTo(tradeResponses[index].FormKey);
    responseInfo.VirtualMachineAdapter = new DialogResponsesAdapter {
        Version = 5, ObjectFormat = 2,
        ScriptFragments = new ScriptFragments {
            ExtraBindDataVersion = 2, FileName = "MO_OrderDialogue",
            OnBegin = new ScriptFragment {
                ExtraBindDataVersion = 1, ScriptName = "MO_OrderDialogue", FragmentName = "Fragment_0"
            }
        }
    };
    var merchantCondition = new GetIsIDConditionData();
    merchantCondition.Object.Link.SetTo(merchant.FormKey);
    responseInfo.Conditions.Add(new ConditionFloat {
        CompareOperator = CompareOperator.EqualTo, ComparisonValue = 1, Data = merchantCondition
    });
    var fragment = new ScriptEntry { Name = "MO_OrderDialogue" };
    fragment.Properties.Add(Bind("OrderManager", quest.FormKey));
    responseInfo.VirtualMachineAdapter.Scripts.Add(fragment);
    responseInfo.Topic.SetTo(topic.FormKey);
    if (index > 0) responseInfo.PreviousDialog.SetTo(orderResponses[index - 1].FormKey);
    topic.Responses.Add(responseInfo);
}
var expansion = CatalogExpansion.Add(mod, master, quest, topic, args[2], args[3]);
var features = OrderFeatures.Add(mod, master, quest, args[2], expansion);
var stock = StockFeatures.AddCore(mod, master, quest, topic, expansion, args[2]);
expansion = expansion with {
    AddedMessages = expansion.AddedMessages + features.AddedMessages + stock.AddedMessages,
    AddedResponses = expansion.AddedResponses + stock.AddedResponses
};
Directory.CreateDirectory(output);
string pluginPath = Path.Combine(output, mod.ModKey.FileName);
mod.WriteToBinary(pluginPath);

// Read back the produced binary, not just the in-memory records.
using var read = SkyrimMod.CreateFromBinaryOverlay(new ModPath(mod.ModKey, pluginPath), SkyrimRelease.SkyrimSE);
void Require(bool ok, string description) {
    if (!ok) throw new InvalidDataException(description);
    Console.WriteLine("PASS " + description);
}
Require(read.ModHeader.MasterReferences.Count == 1 &&
    read.ModHeader.MasterReferences[0].Master.FileName == "Skyrim.esm", "Only Skyrim.esm is required");
Require(read.Quests.Count == 1 && read.Messages.Count == 10 + expansion.AddedMessages && read.DialogBranches.Count == 1 &&
    read.DialogTopics.Count == 1 && read.DialogTopics.Single().Responses.Count == 3 + expansion.AddedResponses, "Expected record counts");
Require(read.EnumerateMajorRecords().All(r => r.FormKey.ModKey == mod.ModKey), "All records are additive; no vanilla overrides");
Require(read.Quests.Single().Flags.HasFlag(Quest.Flag.StartGameEnabled), "Quest starts with game");
using var layoutStream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("RecordLayout.json")
        ?? throw new InvalidDataException("Missing 0.4.0 record baseline");
var oldLayout = JsonSerializer.Deserialize<Dictionary<string, uint>>(layoutStream)!;
var newLayout = read.EnumerateMajorRecords().ToDictionary(r => r.EditorID!, r => r.FormKey.ID);
Require(oldLayout.All(entry => newLayout.TryGetValue(entry.Key, out var id) && id == entry.Value),
    "All 0.4.0 record IDs preserved for existing-save references");
var bound = read.Quests.Single().VirtualMachineAdapter!.Scripts.Single();
Require(bound.Name == "MO_OrderManager" && bound.Properties.Count == 13, "All manager properties serialized");
Require(bound.Properties.OfType<IScriptObjectPropertyGetter>().All(p => p.Alias == -1 && !p.Object.IsNull), "Object bindings are explicit forms");
Require(bound.Properties.OfType<IScriptObjectPropertyGetter>().Single(p => p.Name == "SupportedMerchant").Object.FormKey == merchantRef.FormKey,
    "Supported merchant is persistent Belethor reference");
Require(vendorChest.FormKey == expectedVendorChest, "Payment destination resolves to Belethor vendor chest");
Require(LeadDays(10) == 1 && LeadDays(25) == 2 && LeadDays(50) == 4,
    "Quantity lead times are 1, 2, and 4 days");
string quantityText = read.Messages.Single(m => m.EditorID == "MO_QuantityMenu").Description?.ToString() ?? "";
Require(new[] { 10, 25, 50 }.All(q => quantityText.Contains($"{q} ingots: {q * 12} gold / {LeadDays(q)} day")),
    "Serialized quantity menu matches prices and lead times");
Require((read.Messages.Single(m => m.EditorID == "MO_ConfirmOrder").Description?.ToString() ?? "").Count(ch => ch == '%') == 3 &&
    (read.Messages.Single(m => m.EditorID == "MO_AcceptedOrder").Description?.ToString() ?? "").Count(ch => ch == '%') == 3,
    "Confirmation and receipt accept quantity, price, and quoted lead time");
var voiced = read.DialogTopics.Single().Responses.Take(3).ToArray();
Require(voiced.All(r => r.Conditions.Single().Data is IGetIsIDConditionDataGetter c &&
    c.Object.Link.FormKey == merchant.FormKey), "Every voiced variant is restricted to Belethor");
Require(voiced.All(r => r.VirtualMachineAdapter!.ScriptFragments!.OnEnd == null &&
    r.VirtualMachineAdapter.ScriptFragments.OnBegin!.FragmentName == "Fragment_0" &&
    r.VirtualMachineAdapter.Scripts.Single().Name == "MO_OrderDialogue" &&
    r.VirtualMachineAdapter.Scripts.Single().Properties.OfType<IScriptObjectPropertyGetter>()
        .Single().Object.FormKey == quest.FormKey),
    "Voice begins by queuing a menu request; no vanilla barter scripts copied");
Require(voiced.Select(r => r.ResponseData.FormKey).SequenceEqual(tradeResponses.Select(r => r.FormKey)) &&
    voiced.All(r => r.Responses.Count == 0), "All variants share the original vanilla voiced response data");
Require(voiced.All(r => r.Flags!.Flags.HasFlag(DialogResponses.Flag.Random) &&
    !r.Flags.Flags.HasFlag(DialogResponses.Flag.NoLipFile)) &&
    voiced.Last().Flags!.Flags.HasFlag(DialogResponses.Flag.RandomEnd) &&
    voiced.Take(2).All(r => !r.Flags!.Flags.HasFlag(DialogResponses.Flag.RandomEnd)),
    "Three-response random group retains vanilla lip sync");
CatalogExpansion.Validate(read, expansion);
OrderFeatures.Validate(read, features);
StockFeatures.Validate(read, master, stock, expansion);
Require(read.DialogBranches.Single().StartingTopic.FormKey == read.DialogTopics.Single().FormKey,
    "Top-level branch points to order topic");
Require(read.Messages.All(m => m.Flags.HasFlag(Mutagen.Bethesda.Skyrim.Message.Flag.MessageBox) && m.MenuButtons.Count > 0),
    "Every menu is an interactive message box");
Require(read.Messages.Single(m => m.EditorID == "MO_ConfirmOrder").MenuButtons.Count == 2,
    "Payment has an explicit cancel choice");

// SEQ supports discovery of start-game-enabled dialogue quests on existing saves.
// FormID is encoded in this file's master order, NOT the user's current load order.
Directory.CreateDirectory(Path.Combine(output, "Seq"));
uint rawQuestId = ((uint)read.ModHeader.MasterReferences.Count << 24) | quest.FormKey.ID;
byte[] seq = new byte[4];
BinaryPrimitives.WriteUInt32LittleEndian(seq, rawQuestId);
File.WriteAllBytes(Path.Combine(output, "Seq", "MerchantOrders.seq"), seq);
Require(BinaryPrimitives.ReadUInt32LittleEndian(File.ReadAllBytes(Path.Combine(output, "Seq", "MerchantOrders.seq"))) == rawQuestId,
    "Start-game quest SEQ matches plugin-local FormID");

File.WriteAllText(Path.Combine(output, "..", "build-report.json"), JsonSerializer.Serialize(new {
    version = "0.4.1-prototype", master = masterPath,
    bindings = new { merchant = merchant.FormKey.ToString(), merchantReference = merchantRef.FormKey.ToString(),
        iron = iron.FormKey.ToString(), gold = gold.FormKey.ToString(), quest = quest.FormKey.ToString(), vendorChest = vendorChest.FormKey.ToString() },
    merchantCatalogs = expansion.Merchants, materials = expansion.Spec.Items,
    voiceResponseSources = tradeResponses.Select(r => r.FormKey.ToString()).ToArray(),
    validation = "Binary readback passed. Refer to docs/STATUS.md for author testing reports."
}, new JsonSerializerOptions { WriteIndented = true }));
OrderFeatures.BuildUiAddon(output, quest.FormKey);
Console.WriteLine("Built " + pluginPath);
return 0;
