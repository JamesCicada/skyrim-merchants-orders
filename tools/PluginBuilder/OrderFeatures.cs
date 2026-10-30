using System.Buffers.Binary;
using System.Text;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;

internal sealed record FeatureOutput(FormKey Parcel, int AddedMessages);

internal static class OrderFeatures {
    internal static FeatureOutput Add(SkyrimMod mod, ISkyrimModGetter master, Quest quest,
        string sourceDirectory, Expansion expansion) {
        var courier = master.Quests.Single(q => q.EditorID == "WICourier");
        if (courier.FormKey.ID != 0x039F82 ||
            !courier.VirtualMachineAdapter!.Scripts.Any(s => s.Name.Equals("WICourierScript", StringComparison.OrdinalIgnoreCase)))
            throw new InvalidDataException("Unexpected vanilla courier API binding.");

        Message Menu(string id, string text, params string[] buttons) {
            var menu = new Message(mod, id) {
                Name = "Merchant Orders", Description = text,
                Flags = Mutagen.Bethesda.Skyrim.Message.Flag.MessageBox
            };
            foreach (var button in buttons) menu.MenuButtons.Add(new MessageButton { Text = button });
            mod.Messages.Add(menu);
            return menu;
        }
        var extras = new[] {
            Menu("MO_EditQuantity", "Order quantity: %.0f units\nUnit price: %.0f gold\nMaterials: %.0f gold\nSourcing: %.2f game days\n\nChoose 1-500 units. Delivery is chosen next.",
                "Use this quantity", "-1", "+1", "-10", "+10", "-50", "+50", "Cancel"),
            Menu("MO_DeliveryMethod", "Materials: %.0f gold\nCourier fee (5%%, rounded up): %.0f gold\nCourier total: %.0f gold\n\nPickup is free. Courier delivery starts when sourcing finishes; the courier still needs to reach you.",
                "Merchant pickup - Free", "Courier - Add 5%", "Cancel"),
            Menu("MO_OrderSettings", "New-order defaults\nQuantity: %.0f units\nLead time: %.2fx normal\n\nSettings never alter a paid order.",
                "Default quantity", "Lead-time multiplier", "Back"),
            Menu("MO_WaitSettings", "Lead-time multiplier for NEW orders\n\n0.25x is four times faster; 4x is four times longer. Quantity and material capacity still affect the quote.",
                "0.25x", "0.5x", "1x - Normal", "2x", "4x", "Cancel"),
            Menu("MO_ConvertPickup", "Your courier shipment is pending.\n\nCollect here instead and refund the %.0f gold delivery fee? The receipt will no longer grant materials.",
                "Switch to pickup and refund fee", "Keep courier delivery"),
            Menu("MO_DefaultQuantity", "Default quantity: %.0f units\nChoose the starting quantity for NEW orders (1-500).",
                "Use this quantity", "-1", "+1", "-10", "+10", "-50", "+50", "Cancel")
        };
        foreach (var menu in mod.Messages.Where(m => m.EditorID?.StartsWith("MO_Main_") == true)) {
            menu.MenuButtons.Clear();
            foreach (var label in new[] { "Place an order", "Order status", "Collect / resolve delivery", "Settings", "Leave" })
                menu.MenuButtons.Add(new MessageButton { Text = label });
        }
        var courierMenus = expansion.Spec.Items.Select(item => {
            string quote = $"%.0f {item.Name}\nMaterials: %.0f gold\nDelivery fee: %.0f gold\nTotal: %.0f gold\nSourcing time: %.2f game days\n\n";
            mod.Messages.Single(m => m.EditorID == "MO_Confirm_" + item.EditorId).Description =
                quote + "Collect from this merchant. No cancellation or refund of materials.";
            return Menu("MO_CourierConfirm_" + item.EditorId, quote +
                "Courier will find you after sourcing finishes. Actual arrival depends on the vanilla courier. No cancellation of materials.",
                "Pay and confirm", "Cancel");
        }).ToArray();

        var parcel = new Book(mod, "MO_ShipmentReceipt") {
            Name = "Merchant Shipment Receipt", Weight = 0, Value = 0,
            Model = new Model { File = @"Clutter\Books\Note01.nif" },
            BookText = "<font face='$HandwrittenFont'>Merchant Orders<br><br>Your paid materials have arrived. This receipt is exchanged for the shipment when handed to you.</font>",
            VirtualMachineAdapter = new VirtualMachineAdapter { Version = 5, ObjectFormat = 2 }
        };
        var receiptScript = new ScriptEntry { Name = "MO_ShipmentReceipt" };
        var manager = new ScriptObjectProperty { Name = "OrderManager", Alias = -1, Flags = ScriptProperty.Flag.Edited };
        manager.Object.SetTo(quest.FormKey);
        receiptScript.Properties.Add(manager);
        parcel.VirtualMachineAdapter.Scripts.Add(receiptScript);
        mod.Books.Add(parcel);

        string Own(FormKey key, string type) =>
            $"(Game.GetFormFromFile(0x{key.ID:X8}, \"MerchantOrders.esp\") as {type})";
        var code = new StringBuilder("\n; Delivery and settings records appended after the released catalog layout.\n");
        code.AppendLine("Message Function ExtraMenu(Int aiMenu) Global");
        for (int i = 0; i < extras.Length; i++)
            code.AppendLine($"    If aiMenu == {i}\n        Return {Own(extras[i].FormKey, "Message")}\n    EndIf");
        code.AppendLine("    Return None\nEndFunction\n");
        code.AppendLine("Message Function CourierConfirmation(Int aiItem) Global");
        for (int i = 0; i < courierMenus.Length; i++)
            code.AppendLine($"    If aiItem == {i}\n        Return {Own(courierMenus[i].FormKey, "Message")}\n    EndIf");
        code.AppendLine("    Return None\nEndFunction\n");
        code.AppendLine($"Book Function ShipmentReceipt() Global\n    Return {Own(parcel.FormKey, "Book")}\nEndFunction\n");
        code.AppendLine($"WICourierScript Function Courier() Global\n    Return Game.GetForm(0x{courier.FormKey.ID:X8}) as WICourierScript\nEndFunction\n");
        code.AppendLine("""
Int Function CourierFee(Int aiSubtotal) Global
    If aiSubtotal <= 0
        Return 0
    EndIf
    Return (aiSubtotal + 19) / 20
EndFunction
""");
        File.AppendAllText(Path.Combine(sourceDirectory, "MO_Catalog.psc"), code.ToString());
        return new FeatureOutput(parcel.FormKey, extras.Length + courierMenus.Length);
    }

    internal static void Validate(ISkyrimModGetter read, FeatureOutput output) {
        void Check(bool value, string name) {
            if (!value) throw new InvalidDataException(name);
            Console.WriteLine("PASS " + name);
        }
        var receipt = read.Books.Single(b => b.FormKey == output.Parcel);
        Check(receipt.VirtualMachineAdapter!.Scripts.Single().Name == "MO_ShipmentReceipt" &&
            receipt.VirtualMachineAdapter.Scripts.Single().Properties.OfType<IScriptObjectPropertyGetter>()
                .Single().Object.FormKey == read.Quests.Single().FormKey,
            "Shipment receipt routes to the existing order manager");
        Check(read.Messages.Count(m => m.EditorID?.StartsWith("MO_CourierConfirm_") == true) == 6 &&
            read.Messages.Where(m => m.EditorID?.StartsWith("MO_CourierConfirm_") == true)
                .All(m => (m.Description?.ToString() ?? "").Count(c => c == '%') == 5),
            "Every courier quote shows quantity, materials, fee, total, and sourcing time");
        Check(read.Messages.Where(m => m.EditorID?.StartsWith("MO_Main_") == true).All(m =>
            m.MenuButtons.Count == 5 && m.MenuButtons[3].Text?.ToString() == "Settings"),
            "All merchants expose settings and delivery recovery");
        int Fee(int subtotal) => subtotal <= 0 ? 0 : (subtotal + 19) / 20;
        Check(Fee(0) == 0 && Fee(1) == 1 && Fee(19) == 1 && Fee(20) == 1 &&
            Fee(21) == 2 && Fee(600) == 30 && Fee(12500) == 625,
            "5% courier fees round up correctly at whole-gold boundaries");
        Check(Enumerable.Range(1, 12500).All(n => Fee(n) * 20 >= n && (Fee(n) - 1) * 20 < n),
            "Courier fee rounding holds across every supported subtotal");
    }
    internal static void BuildUiAddon(string output, FormKey managerQuest) {
        var addon = new SkyrimMod(ModKey.FromNameAndExtension("MerchantOrders-UI.esp"), SkyrimRelease.SkyrimSE);
        addon.ModHeader.Author = "Merchant Orders";
        addon.ModHeader.Description = "Optional UIExtensions order menus and SkyUI MCM. Requires SKSE, SkyUI, UIExtensions, and MerchantOrders.";
        var quest = new Quest(addon, "MO_EnhancedUI") {
            Name = "Merchant Orders UI", Flags = Quest.Flag.StartGameEnabled,
            Priority = 10, QuestFormVersion = 65, NextAliasID = 0,
            VirtualMachineAdapter = new QuestAdapter { Version = 5, ObjectFormat = 2, ExtraBindDataVersion = 2 }
        };
        addon.Quests.Add(quest);
        if (quest.FormKey.ID != 0x800) throw new InvalidDataException("UI bridge quest must keep local ID 800");
        quest.VirtualMachineAdapter.Scripts.Add(new ScriptEntry { Name = "MO_UiExtensionsBridge" });
        var config = new ScriptEntry { Name = "MO_Config" };
        var manager = new ScriptObjectProperty { Name = "Manager", Alias = -1, Flags = ScriptProperty.Flag.Edited };
        manager.Object.SetTo(managerQuest);
        config.Properties.Add(manager);
        quest.VirtualMachineAdapter.Scripts.Add(config);
        string path = Path.Combine(output, "MerchantOrders-UI.esp");
        addon.WriteToBinary(path);
        using var read = SkyrimMod.CreateFromBinaryOverlay(new ModPath(addon.ModKey, path), SkyrimRelease.SkyrimSE);
        if (read.Quests.Count != 1 || read.Quests.Single().VirtualMachineAdapter!.Scripts.Count != 2 ||
            !read.ModHeader.MasterReferences.Any(m => m.Master == managerQuest.ModKey))
            throw new InvalidDataException("UI addon failed binary validation.");
        byte[] seq = new byte[4];
        BinaryPrimitives.WriteUInt32LittleEndian(seq, ((uint)read.ModHeader.MasterReferences.Count << 24) | quest.FormKey.ID);
        Directory.CreateDirectory(Path.Combine(output, "Seq"));
        File.WriteAllBytes(Path.Combine(output, "Seq", "MerchantOrders-UI.seq"), seq);
        Console.WriteLine("PASS Optional UI addon links to core manager and starts its MCM/bridge quest");
    }
}
