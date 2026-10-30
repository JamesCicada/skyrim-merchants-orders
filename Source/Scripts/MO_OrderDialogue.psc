Scriptname MO_OrderDialogue extends TopicInfo Hidden

MO_OrderManager Property OrderManager Auto

; OnBegin queues the request; the quest opens the menu after dialogue closes.
Function Fragment_0(ObjectReference akSpeakerRef)
    If OrderManager != None
        OrderManager.QueueMenu(akSpeakerRef as Actor)
    Else
        Debug.Notification("Merchant Orders: order manager binding is missing.")
    EndIf
EndFunction
