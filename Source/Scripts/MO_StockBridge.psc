Scriptname MO_StockBridge extends Quest Hidden
; Vanilla-only interface. The enhanced addon implements SKSE inventory scanning.
Bool Function IsReady()
    Return False
EndFunction
ObjectReference Function MerchantFunds(Actor akMerchant)
    Return None
EndFunction
String Function MerchantName(Actor akMerchant)
    Return "the original merchant"
EndFunction
Form[] Function GetItems(Actor akMerchant)
    Return None
EndFunction
Bool Function CanOrder(Actor akMerchant, Form akItem)
    Return False
EndFunction
String Function ItemName(Form akItem)
    Return ""
EndFunction
Int Function UnitPrice(Form akItem)
    Return 0
EndFunction
Int Function Capacity(Form akItem)
    Return 0
EndFunction
