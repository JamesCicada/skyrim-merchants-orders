Scriptname MO_UIBridge extends Quest Hidden
; Dependency-free contract. The optional UI addon implements this class.
Int Function ShowList(String asTitle, String[] asEntries)
    Return -2
EndFunction
Int Function EditQuantity(Int aiValue, Int aiMinimum, Int aiMaximum)
    Return -2
EndFunction

Bool Function ConfirmOrder(String asTitle, String[] asDetails)
    Return False
EndFunction
