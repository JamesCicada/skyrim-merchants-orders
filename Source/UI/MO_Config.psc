Scriptname MO_Config extends SKI_ConfigBase
MO_OrderManager Property Manager Auto
Int _quantityOption
Int _waitOption

Event OnConfigInit()
    ModName = "Merchant Orders"
EndEvent

Event OnPageReset(String asPage)
    AddHeaderOption("New-order defaults")
    _quantityOption = AddSliderOption("Default quantity", Manager.GetDefaultQuantity(), "{0}")
    _waitOption = AddSliderOption("Lead-time multiplier", Manager.GetWaitMultiplier(), "{2}x")
    AddTextOption("Courier delivery fee", "5% (rounded up)", 1)
    AddTextOption("Quantity range", "1-500 units", 1)
    AddTextOption("Paid orders", "Keep their original terms", 1)
EndEvent

Event OnOptionSliderOpen(Int aiOption)
    If aiOption == _quantityOption
        SetSliderDialogStartValue(Manager.GetDefaultQuantity())
        SetSliderDialogDefaultValue(25.0)
        SetSliderDialogRange(1.0, 500.0)
        SetSliderDialogInterval(1.0)
    ElseIf aiOption == _waitOption
        SetSliderDialogStartValue(Manager.GetWaitMultiplier())
        SetSliderDialogDefaultValue(1.0)
        SetSliderDialogRange(0.25, 4.0)
        SetSliderDialogInterval(0.25)
    EndIf
EndEvent

Event OnOptionSliderAccept(Int aiOption, Float afValue)
    If aiOption == _quantityOption
        Manager.SetDefaultQuantity(afValue as Int)
        SetSliderOptionValue(aiOption, Manager.GetDefaultQuantity(), "{0}")
    ElseIf aiOption == _waitOption
        Manager.SetWaitMultiplier(afValue)
        SetSliderOptionValue(aiOption, Manager.GetWaitMultiplier(), "{2}x")
    EndIf
EndEvent

Event OnOptionHighlight(Int aiOption)
    If aiOption == _quantityOption
        SetInfoText("Starting quantity for new orders. Change it again before paying. Common materials only.")
    ElseIf aiOption == _waitOption
        SetInfoText("Scales quantity-based sourcing time for new orders: 0.25x to 4x. Paid orders keep their quoted deadline.")
    EndIf
EndEvent
