Scriptname ObjectReference extends Form Hidden
Int Function GetItemCount(Form akItem) Native
Function RemoveItem(Form akItemToRemove, Int aiCount = 1, Bool abSilent = False, ObjectReference akOtherContainer = None) Native
Function AddItem(Form akItemToAdd, Int aiCount = 1, Bool abSilent = False) Native
Bool Function IsInDialogueWithPlayer() Native
ObjectReference Function PlaceAtMe(Form akFormToPlace, Int aiCount = 1, Bool abForcePersist = False, Bool abInitiallyDisabled = False) Native
Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
EndEvent
