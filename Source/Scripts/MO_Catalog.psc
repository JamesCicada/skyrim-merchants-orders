Scriptname MO_Catalog Hidden
; Generated from catalogs/materials.json and Skyrim.esm. Do not edit.

Int Function MerchantIndex(Actor akMerchant) Global
    If akMerchant == (Game.GetForm(0x0001A672) as Actor)
        Return 0
    EndIf
    If akMerchant == (Game.GetForm(0x0001A67C) as Actor)
        Return 1
    EndIf
    If akMerchant == (Game.GetForm(0x000D15B0) as Actor)
        Return 2
    EndIf
    If akMerchant == (Game.GetForm(0x000198C9) as Actor)
        Return 3
    EndIf
    If akMerchant == (Game.GetForm(0x000198D8) as Actor)
        Return 4
    EndIf
    If akMerchant == (Game.GetForm(0x0001B123) as Actor)
        Return 5
    EndIf
    If akMerchant == (Game.GetForm(0x0001B135) as Actor)
        Return 6
    EndIf
    If akMerchant == (Game.GetForm(0x000198EA) as Actor)
        Return 7
    EndIf
    If akMerchant == (Game.GetForm(0x00019906) as Actor)
        Return 8
    EndIf
    If akMerchant == (Game.GetForm(0x00019DD0) as Actor)
        Return 9
    EndIf
    If akMerchant == (Game.GetForm(0x00019DF1) as Actor)
        Return 10
    EndIf
    Return -1
EndFunction

String Function MerchantName(Actor akMerchant) Global
    If MerchantIndex(akMerchant) == 0
        Return "Belethor in Whiterun"
    EndIf
    If MerchantIndex(akMerchant) == 1
        Return "Adrianne Avenicci in Whiterun"
    EndIf
    If MerchantIndex(akMerchant) == 2
        Return "Ulfberth War-Bear in Whiterun"
    EndIf
    If MerchantIndex(akMerchant) == 3
        Return "Sayma in Solitude"
    EndIf
    If MerchantIndex(akMerchant) == 4
        Return "Beirand in Solitude"
    EndIf
    If MerchantIndex(akMerchant) == 5
        Return "Revyn Sadri in Windhelm"
    EndIf
    If MerchantIndex(akMerchant) == 6
        Return "Oengul War-Anvil in Windhelm"
    EndIf
    If MerchantIndex(akMerchant) == 7
        Return "Lisbet in Markarth"
    EndIf
    If MerchantIndex(akMerchant) == 8
        Return "Ghorza gra-Bagol in Markarth"
    EndIf
    If MerchantIndex(akMerchant) == 9
        Return "Bersi Honey-Hand in Riften"
    EndIf
    If MerchantIndex(akMerchant) == 10
        Return "Balimund in Riften"
    EndIf
    Return "the original merchant"
EndFunction

ObjectReference Function MerchantFunds(Actor akMerchant) Global
    If MerchantIndex(akMerchant) == 0
        Return (Game.GetForm(0x0009CAF9) as ObjectReference)
    EndIf
    If MerchantIndex(akMerchant) == 1
        Return (Game.GetForm(0x0009CAFE) as ObjectReference)
    EndIf
    If MerchantIndex(akMerchant) == 2
        Return (Game.GetForm(0x0009CAFE) as ObjectReference)
    EndIf
    If MerchantIndex(akMerchant) == 3
        Return (Game.GetForm(0x000A6C0A) as ObjectReference)
    EndIf
    If MerchantIndex(akMerchant) == 4
        Return (Game.GetForm(0x000A6C0B) as ObjectReference)
    EndIf
    If MerchantIndex(akMerchant) == 5
        Return (Game.GetForm(0x000A3F11) as ObjectReference)
    EndIf
    If MerchantIndex(akMerchant) == 6
        Return (Game.GetForm(0x000A3F18) as ObjectReference)
    EndIf
    If MerchantIndex(akMerchant) == 7
        Return (Game.GetForm(0x00094377) as ObjectReference)
    EndIf
    If MerchantIndex(akMerchant) == 8
        Return (Game.GetForm(0x0009438F) as ObjectReference)
    EndIf
    If MerchantIndex(akMerchant) == 9
        Return (Game.GetForm(0x000A31BF) as ObjectReference)
    EndIf
    If MerchantIndex(akMerchant) == 10
        Return (Game.GetForm(0x000A31BD) as ObjectReference)
    EndIf
    Return None
EndFunction

Message Function MainMenu(Actor akMerchant) Global
    If MerchantIndex(akMerchant) == 0
        Return (Game.GetFormFromFile(0x0000081C, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 1
        Return (Game.GetFormFromFile(0x0000081D, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 2
        Return (Game.GetFormFromFile(0x0000081E, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 3
        Return (Game.GetFormFromFile(0x0000081F, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 4
        Return (Game.GetFormFromFile(0x00000820, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 5
        Return (Game.GetFormFromFile(0x00000821, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 6
        Return (Game.GetFormFromFile(0x00000822, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 7
        Return (Game.GetFormFromFile(0x00000823, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 8
        Return (Game.GetFormFromFile(0x00000824, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 9
        Return (Game.GetFormFromFile(0x00000825, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 10
        Return (Game.GetFormFromFile(0x00000826, "MerchantOrders.esp") as Message)
    EndIf
    Return None
EndFunction

Message Function ItemMenu(Actor akMerchant) Global
    If MerchantIndex(akMerchant) == 0
        Return (Game.GetFormFromFile(0x00000827, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 1
        Return (Game.GetFormFromFile(0x00000828, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 2
        Return (Game.GetFormFromFile(0x00000829, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 3
        Return (Game.GetFormFromFile(0x0000082A, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 4
        Return (Game.GetFormFromFile(0x0000082B, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 5
        Return (Game.GetFormFromFile(0x0000082C, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 6
        Return (Game.GetFormFromFile(0x0000082D, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 7
        Return (Game.GetFormFromFile(0x0000082E, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 8
        Return (Game.GetFormFromFile(0x0000082F, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 9
        Return (Game.GetFormFromFile(0x00000830, "MerchantOrders.esp") as Message)
    EndIf
    If MerchantIndex(akMerchant) == 10
        Return (Game.GetFormFromFile(0x00000831, "MerchantOrders.esp") as Message)
    EndIf
    Return None
EndFunction

Int Function ItemIndex(MiscObject akItem) Global
    If akItem == (Game.GetForm(0x0005ACE4) as MiscObject)
        Return 0
    EndIf
    If akItem == (Game.GetForm(0x0005ACE5) as MiscObject)
        Return 1
    EndIf
    If akItem == (Game.GetForm(0x00071CF3) as MiscObject)
        Return 2
    EndIf
    If akItem == (Game.GetForm(0x000DB5D2) as MiscObject)
        Return 3
    EndIf
    If akItem == (Game.GetForm(0x000800E4) as MiscObject)
        Return 4
    EndIf
    If akItem == (Game.GetForm(0x0006F993) as MiscObject)
        Return 5
    EndIf
    Return -1
EndFunction

MiscObject Function ItemForm(Int aiItem) Global
    If aiItem == 0
        Return (Game.GetForm(0x0005ACE4) as MiscObject)
    EndIf
    If aiItem == 1
        Return (Game.GetForm(0x0005ACE5) as MiscObject)
    EndIf
    If aiItem == 2
        Return (Game.GetForm(0x00071CF3) as MiscObject)
    EndIf
    If aiItem == 3
        Return (Game.GetForm(0x000DB5D2) as MiscObject)
    EndIf
    If aiItem == 4
        Return (Game.GetForm(0x000800E4) as MiscObject)
    EndIf
    If aiItem == 5
        Return (Game.GetForm(0x0006F993) as MiscObject)
    EndIf
    Return None
EndFunction

String Function ItemName(Int aiItem) Global
    If aiItem == 0
        Return "Iron Ingots"
    EndIf
    If aiItem == 1
        Return "Steel Ingots"
    EndIf
    If aiItem == 2
        Return "Iron Ore"
    EndIf
    If aiItem == 3
        Return "Leather"
    EndIf
    If aiItem == 4
        Return "Leather Strips"
    EndIf
    If aiItem == 5
        Return "Firewood"
    EndIf
    Return "materials"
EndFunction

Int Function UnitPrice(Int aiItem) Global
    If aiItem == 0
        Return 12
    EndIf
    If aiItem == 1
        Return 25
    EndIf
    If aiItem == 2
        Return 8
    EndIf
    If aiItem == 3
        Return 10
    EndIf
    If aiItem == 4
        Return 3
    EndIf
    If aiItem == 5
        Return 5
    EndIf
    Return 0
EndFunction

Int Function Capacity(Int aiItem) Global
    If aiItem == 0
        Return 15
    EndIf
    If aiItem == 1
        Return 10
    EndIf
    If aiItem == 2
        Return 25
    EndIf
    If aiItem == 3
        Return 20
    EndIf
    If aiItem == 4
        Return 40
    EndIf
    If aiItem == 5
        Return 25
    EndIf
    Return 0
EndFunction

Message Function QuantityMenu(Int aiItem) Global
    If aiItem == 0
        Return (Game.GetFormFromFile(0x00000810, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 1
        Return (Game.GetFormFromFile(0x00000811, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 2
        Return (Game.GetFormFromFile(0x00000812, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 3
        Return (Game.GetFormFromFile(0x00000813, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 4
        Return (Game.GetFormFromFile(0x00000814, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 5
        Return (Game.GetFormFromFile(0x00000815, "MerchantOrders.esp") as Message)
    EndIf
    Return None
EndFunction

Message Function Confirmation(Int aiItem) Global
    If aiItem == 0
        Return (Game.GetFormFromFile(0x00000816, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 1
        Return (Game.GetFormFromFile(0x00000817, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 2
        Return (Game.GetFormFromFile(0x00000818, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 3
        Return (Game.GetFormFromFile(0x00000819, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 4
        Return (Game.GetFormFromFile(0x0000081A, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 5
        Return (Game.GetFormFromFile(0x0000081B, "MerchantOrders.esp") as Message)
    EndIf
    Return None
EndFunction

Int Function ItemForChoice(Actor akMerchant, Int aiChoice) Global
    If MerchantIndex(akMerchant) == 0 && aiChoice == 0
        Return 0
    EndIf
    If MerchantIndex(akMerchant) == 0 && aiChoice == 1
        Return 2
    EndIf
    If MerchantIndex(akMerchant) == 0 && aiChoice == 2
        Return 3
    EndIf
    If MerchantIndex(akMerchant) == 0 && aiChoice == 3
        Return 4
    EndIf
    If MerchantIndex(akMerchant) == 0 && aiChoice == 4
        Return 5
    EndIf
    If MerchantIndex(akMerchant) == 1 && aiChoice == 0
        Return 0
    EndIf
    If MerchantIndex(akMerchant) == 1 && aiChoice == 1
        Return 1
    EndIf
    If MerchantIndex(akMerchant) == 1 && aiChoice == 2
        Return 2
    EndIf
    If MerchantIndex(akMerchant) == 1 && aiChoice == 3
        Return 3
    EndIf
    If MerchantIndex(akMerchant) == 1 && aiChoice == 4
        Return 4
    EndIf
    If MerchantIndex(akMerchant) == 2 && aiChoice == 0
        Return 0
    EndIf
    If MerchantIndex(akMerchant) == 2 && aiChoice == 1
        Return 1
    EndIf
    If MerchantIndex(akMerchant) == 2 && aiChoice == 2
        Return 2
    EndIf
    If MerchantIndex(akMerchant) == 2 && aiChoice == 3
        Return 3
    EndIf
    If MerchantIndex(akMerchant) == 2 && aiChoice == 4
        Return 4
    EndIf
    If MerchantIndex(akMerchant) == 3 && aiChoice == 0
        Return 0
    EndIf
    If MerchantIndex(akMerchant) == 3 && aiChoice == 1
        Return 2
    EndIf
    If MerchantIndex(akMerchant) == 3 && aiChoice == 2
        Return 3
    EndIf
    If MerchantIndex(akMerchant) == 3 && aiChoice == 3
        Return 4
    EndIf
    If MerchantIndex(akMerchant) == 3 && aiChoice == 4
        Return 5
    EndIf
    If MerchantIndex(akMerchant) == 4 && aiChoice == 0
        Return 0
    EndIf
    If MerchantIndex(akMerchant) == 4 && aiChoice == 1
        Return 1
    EndIf
    If MerchantIndex(akMerchant) == 4 && aiChoice == 2
        Return 2
    EndIf
    If MerchantIndex(akMerchant) == 4 && aiChoice == 3
        Return 3
    EndIf
    If MerchantIndex(akMerchant) == 4 && aiChoice == 4
        Return 4
    EndIf
    If MerchantIndex(akMerchant) == 5 && aiChoice == 0
        Return 0
    EndIf
    If MerchantIndex(akMerchant) == 5 && aiChoice == 1
        Return 2
    EndIf
    If MerchantIndex(akMerchant) == 5 && aiChoice == 2
        Return 3
    EndIf
    If MerchantIndex(akMerchant) == 5 && aiChoice == 3
        Return 4
    EndIf
    If MerchantIndex(akMerchant) == 5 && aiChoice == 4
        Return 5
    EndIf
    If MerchantIndex(akMerchant) == 6 && aiChoice == 0
        Return 0
    EndIf
    If MerchantIndex(akMerchant) == 6 && aiChoice == 1
        Return 1
    EndIf
    If MerchantIndex(akMerchant) == 6 && aiChoice == 2
        Return 2
    EndIf
    If MerchantIndex(akMerchant) == 6 && aiChoice == 3
        Return 3
    EndIf
    If MerchantIndex(akMerchant) == 6 && aiChoice == 4
        Return 4
    EndIf
    If MerchantIndex(akMerchant) == 7 && aiChoice == 0
        Return 0
    EndIf
    If MerchantIndex(akMerchant) == 7 && aiChoice == 1
        Return 2
    EndIf
    If MerchantIndex(akMerchant) == 7 && aiChoice == 2
        Return 3
    EndIf
    If MerchantIndex(akMerchant) == 7 && aiChoice == 3
        Return 4
    EndIf
    If MerchantIndex(akMerchant) == 7 && aiChoice == 4
        Return 5
    EndIf
    If MerchantIndex(akMerchant) == 8 && aiChoice == 0
        Return 0
    EndIf
    If MerchantIndex(akMerchant) == 8 && aiChoice == 1
        Return 1
    EndIf
    If MerchantIndex(akMerchant) == 8 && aiChoice == 2
        Return 2
    EndIf
    If MerchantIndex(akMerchant) == 8 && aiChoice == 3
        Return 3
    EndIf
    If MerchantIndex(akMerchant) == 8 && aiChoice == 4
        Return 4
    EndIf
    If MerchantIndex(akMerchant) == 9 && aiChoice == 0
        Return 0
    EndIf
    If MerchantIndex(akMerchant) == 9 && aiChoice == 1
        Return 2
    EndIf
    If MerchantIndex(akMerchant) == 9 && aiChoice == 2
        Return 3
    EndIf
    If MerchantIndex(akMerchant) == 9 && aiChoice == 3
        Return 4
    EndIf
    If MerchantIndex(akMerchant) == 9 && aiChoice == 4
        Return 5
    EndIf
    If MerchantIndex(akMerchant) == 10 && aiChoice == 0
        Return 0
    EndIf
    If MerchantIndex(akMerchant) == 10 && aiChoice == 1
        Return 1
    EndIf
    If MerchantIndex(akMerchant) == 10 && aiChoice == 2
        Return 2
    EndIf
    If MerchantIndex(akMerchant) == 10 && aiChoice == 3
        Return 3
    EndIf
    If MerchantIndex(akMerchant) == 10 && aiChoice == 4
        Return 4
    EndIf
    Return -1
EndFunction

Bool Function CanOrder(Actor akMerchant, Int aiItem) Global
    If MerchantIndex(akMerchant) == 0 && (aiItem == 0 || aiItem == 2 || aiItem == 3 || aiItem == 4 || aiItem == 5)
        Return True
    EndIf
    If MerchantIndex(akMerchant) == 1 && (aiItem == 0 || aiItem == 1 || aiItem == 2 || aiItem == 3 || aiItem == 4)
        Return True
    EndIf
    If MerchantIndex(akMerchant) == 2 && (aiItem == 0 || aiItem == 1 || aiItem == 2 || aiItem == 3 || aiItem == 4)
        Return True
    EndIf
    If MerchantIndex(akMerchant) == 3 && (aiItem == 0 || aiItem == 2 || aiItem == 3 || aiItem == 4 || aiItem == 5)
        Return True
    EndIf
    If MerchantIndex(akMerchant) == 4 && (aiItem == 0 || aiItem == 1 || aiItem == 2 || aiItem == 3 || aiItem == 4)
        Return True
    EndIf
    If MerchantIndex(akMerchant) == 5 && (aiItem == 0 || aiItem == 2 || aiItem == 3 || aiItem == 4 || aiItem == 5)
        Return True
    EndIf
    If MerchantIndex(akMerchant) == 6 && (aiItem == 0 || aiItem == 1 || aiItem == 2 || aiItem == 3 || aiItem == 4)
        Return True
    EndIf
    If MerchantIndex(akMerchant) == 7 && (aiItem == 0 || aiItem == 2 || aiItem == 3 || aiItem == 4 || aiItem == 5)
        Return True
    EndIf
    If MerchantIndex(akMerchant) == 8 && (aiItem == 0 || aiItem == 1 || aiItem == 2 || aiItem == 3 || aiItem == 4)
        Return True
    EndIf
    If MerchantIndex(akMerchant) == 9 && (aiItem == 0 || aiItem == 2 || aiItem == 3 || aiItem == 4 || aiItem == 5)
        Return True
    EndIf
    If MerchantIndex(akMerchant) == 10 && (aiItem == 0 || aiItem == 1 || aiItem == 2 || aiItem == 3 || aiItem == 4)
        Return True
    EndIf
    Return False
EndFunction

Float Function LeadDays(Int aiItem, Int aiQuantity) Global
    Int dailyCapacity = Capacity(aiItem)
    If dailyCapacity <= 0 || aiQuantity <= 0 || aiQuantity > 500
        Return 0.0
    EndIf
    Int days = (aiQuantity + dailyCapacity - 1) / dailyCapacity
    Return days as Float
EndFunction

; Delivery and settings records appended after the released catalog layout.
Message Function ExtraMenu(Int aiMenu) Global
    If aiMenu == 0
        Return (Game.GetFormFromFile(0x0000083C, "MerchantOrders.esp") as Message)
    EndIf
    If aiMenu == 1
        Return (Game.GetFormFromFile(0x0000083D, "MerchantOrders.esp") as Message)
    EndIf
    If aiMenu == 2
        Return (Game.GetFormFromFile(0x0000083E, "MerchantOrders.esp") as Message)
    EndIf
    If aiMenu == 3
        Return (Game.GetFormFromFile(0x0000083F, "MerchantOrders.esp") as Message)
    EndIf
    If aiMenu == 4
        Return (Game.GetFormFromFile(0x00000840, "MerchantOrders.esp") as Message)
    EndIf
    If aiMenu == 5
        Return (Game.GetFormFromFile(0x00000841, "MerchantOrders.esp") as Message)
    EndIf
    Return None
EndFunction

Message Function CourierConfirmation(Int aiItem) Global
    If aiItem == 0
        Return (Game.GetFormFromFile(0x00000842, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 1
        Return (Game.GetFormFromFile(0x00000843, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 2
        Return (Game.GetFormFromFile(0x00000844, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 3
        Return (Game.GetFormFromFile(0x00000845, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 4
        Return (Game.GetFormFromFile(0x00000846, "MerchantOrders.esp") as Message)
    EndIf
    If aiItem == 5
        Return (Game.GetFormFromFile(0x00000847, "MerchantOrders.esp") as Message)
    EndIf
    Return None
EndFunction

Book Function ShipmentReceipt() Global
    Return (Game.GetFormFromFile(0x00000848, "MerchantOrders.esp") as Book)
EndFunction

WICourierScript Function Courier() Global
    Return Game.GetForm(0x00039F82) as WICourierScript
EndFunction

Int Function CourierFee(Int aiSubtotal) Global
    If aiSubtotal <= 0
        Return 0
    EndIf
    Return (aiSubtotal + 19) / 20
EndFunction
