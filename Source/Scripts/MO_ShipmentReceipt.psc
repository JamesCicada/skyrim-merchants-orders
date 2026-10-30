Scriptname MO_ShipmentReceipt extends ObjectReference
MO_OrderManager Property OrderManager Auto

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    If akNewContainer == Game.GetPlayer() && OrderManager != None
        OrderManager.ReceiveShipment(Self)
        ; Consume this unique receipt even if it was superseded by pickup.
        Game.GetPlayer().RemoveItem(Self, 1, True)
    EndIf
EndEvent
