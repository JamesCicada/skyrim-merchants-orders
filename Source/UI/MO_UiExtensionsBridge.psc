Scriptname MO_UiExtensionsBridge extends MO_UIBridge

Int Function ShowList(String asTitle, String[] asEntries)
    UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
    If menu == None
        Return -2
    EndIf
    menu.SetPropertyBool("sort", False)
    menu.AddEntryItem(asTitle + " - Back", -1, -1)
    Int i = 0
    While i < asEntries.Length
        If asEntries[i] != ""
            menu.AddEntryItem(asEntries[i], -1, i)
        EndIf
        i += 1
    EndWhile
    If menu.OpenMenu() != 1
        Return -1
    EndIf
    ; UIExtensions returns the callback in the float channel, not the row ID.
    Return menu.GetResultFloat() as Int
EndFunction

Int Function EditQuantity(Int aiValue, Int aiMinimum, Int aiMaximum)
    UITextEntryMenu menu = UIExtensions.GetMenu("UITextEntryMenu") as UITextEntryMenu
    If menu == None
        Return -2
    EndIf
    menu.SetPropertyString("text", aiValue as String)
    If menu.OpenMenu() != 1
        Return -1
    EndIf
    String value = menu.GetResultString()
    Int charCount = StringUtil.GetLength(value)
    If charCount < 1 || charCount > 3
        Debug.Notification("Enter a whole number from 1 to 500.")
        Return -1
    EndIf
    Int i = 0
    While i < charCount
        String digit = StringUtil.GetNthChar(value, i)
        If StringUtil.Find("0123456789", digit) < 0
            Debug.Notification("Enter a whole number from 1 to 500.")
            Return -1
        EndIf
        i += 1
    EndWhile
    Int result = value as Int
    If result < aiMinimum || result > aiMaximum
        Debug.Notification("Quantity must be between 1 and 500.")
        Return -1
    EndIf
    Return result
EndFunction

Bool Function ConfirmOrder(String asTitle, String[] asDetails)
    Int attempts = 0
    While attempts < 20
        UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
        If menu == None
            Return False
        EndIf
        menu.SetPropertyBool("sort", False)
        menu.AddEntryItem(asTitle, -1, -2)
        Int i = 0
        While i < asDetails.Length
            menu.AddEntryItem(asDetails[i], -1, -2)
            i += 1
        EndWhile
        menu.AddEntryItem("Pay and confirm", -1, 0)
        menu.AddEntryItem("Cancel", -1, 1)
        If menu.OpenMenu() != 1
            Return False
        EndIf
        Int selection = menu.GetResultFloat() as Int
        If selection == 0
            Return True
        ElseIf selection != -2
            Return False
        EndIf
        ; Selecting an informational row cannot charge the player.
        attempts += 1
    EndWhile
    Return False
EndFunction
