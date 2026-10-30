Scriptname MO_OrderManager extends Quest

; One-slot prototype. Persistent fields are deliberately kept on this quest.
Actor Property SupportedMerchant Auto
MiscObject Property IronIngot Auto
MiscObject Property Gold Auto
Message Property MainMenu Auto
Message Property QuantityMenu Auto
Message Property ConfirmOrder Auto
Message Property PendingStatus Auto
Message Property ReadyStatus Auto
Message Property NoOrderStatus Auto
Message Property InsufficientGold Auto
Message Property AcceptedOrder Auto
Message Property CollectedOrder Auto
Message Property Unavailable Auto

; 0 empty, 1 pending, 2 ready, 3 collecting, 4 completed, 5 courier dispatched
Int _orderState = 0
Bool _menuOpen = False
Actor _orderMerchant
MiscObject _orderItem
Int _quantity = 0
Int _unitPrice = 0
Int _paidGold = 0
Float _placedDay = 0.0
Float _dueDay = 0.0

; UI request data is separate from the persisted paid-order record.
Actor _requestedSpeaker
Int _requestAttempts = 0

; New settings and delivery fields. Existing paid orders default to pickup.
Int _defaultQuantity = 25
Float _waitMultiplier = 1.0
Int _deliveryMethod = 0
Int _deliveryFee = 0
ObjectReference _deliveryParcel

; Generalized order data: do not change/remove the legacy MiscObject field.
Form _orderedForm
String _orderLabel = ""
String _orderVendorName = ""
ObjectReference _orderFunds

MO_StockBridge Function StockProvider()
    MO_StockBridge provider = Game.GetFormFromFile(0x00000801, "MerchantOrders-UI.esp") as MO_StockBridge
    If provider != None && provider.IsReady()
        Return provider
    EndIf
    Return None
EndFunction

Bool Function IsSupportedMerchant(Actor akMerchant)
    If akMerchant == None
        Return False
    EndIf
    MO_StockBridge provider = StockProvider()
    If provider != None
        Return provider.MerchantFunds(akMerchant) != None
    EndIf
    Return MO_Catalog.MerchantIndex(akMerchant) >= 0
EndFunction

String Function MerchantLabel(Actor akMerchant)
    MO_StockBridge provider = StockProvider()
    If provider != None
        Return provider.MerchantName(akMerchant)
    EndIf
    Return MO_Catalog.MerchantName(akMerchant)
EndFunction

Form Function OrderedItem()
    If _orderedForm != None
        Return _orderedForm
    EndIf
    Return _orderItem
EndFunction

String Function OrderedLabel()
    If _orderLabel != ""
        Return _orderLabel
    EndIf
    Return MO_Catalog.ItemName(MO_Catalog.ItemIndex(_orderItem))
EndFunction

String Function OrderedMerchantLabel()
    If _orderVendorName != ""
        Return _orderVendorName
    EndIf
    Return MO_Catalog.MerchantName(_orderMerchant)
EndFunction

ObjectReference Function OrderedFunds()
    If _orderFunds != None
        Return _orderFunds
    EndIf
    Return MO_Catalog.MerchantFunds(_orderMerchant)
EndFunction

Float Function QuoteLeadDays(Int aiQuantity, Int aiCapacity)
    If aiQuantity < 1 || aiQuantity > 500 || aiCapacity <= 0
        Return 0.0
    EndIf
    Int days = (aiQuantity + aiCapacity - 1) / aiCapacity
    Return days * GetWaitMultiplier()
EndFunction

Function QueueMenu(Actor akSpeaker)
    If akSpeaker == None || !IsSupportedMerchant(akSpeaker)
        Debug.Notification("This character cannot take material or food orders.")
        Return
    EndIf
    If _requestedSpeaker != None
        Return
    EndIf
    _requestedSpeaker = akSpeaker
    _requestAttempts = 0
    RegisterForSingleUpdate(0.5)
EndFunction

Event OnUpdate()
    Actor speaker = _requestedSpeaker
    If speaker == None
        Return
    EndIf
    If speaker.IsDead()
        _requestedSpeaker = None
        Return
    EndIf
    ; Dialogue does not count as Utility menu mode, so check it explicitly.
    If speaker.IsInDialogueWithPlayer() || Utility.IsInMenuMode()
        _requestAttempts += 1
        If _requestAttempts < 60
            RegisterForSingleUpdate(0.5)
        Else
            _requestedSpeaker = None
            Debug.Notification("Merchant Orders: finish the conversation, then try again.")
        EndIf
        Return
    EndIf
    _requestedSpeaker = None

    ; A fresh dialogue request after menus have closed can recover the old
    ; post-payment guard. Never clear the guard during item delivery.
    If _menuOpen
        If _orderState == 1 || _orderState == 2 || _orderState == 4 || _orderState == 5
            _menuOpen = False
        Else
            Debug.Notification("Merchant Orders: an order interaction is still active.")
            Return
        EndIf
    EndIf
    OpenMenu(speaker)
EndEvent

Int Function GetDefaultQuantity()
    If _defaultQuantity < 1 || _defaultQuantity > 500
        Return 25
    EndIf
    Return _defaultQuantity
EndFunction

Function SetDefaultQuantity(Int aiQuantity)
    If aiQuantity >= 1 && aiQuantity <= 500
        _defaultQuantity = aiQuantity
    EndIf
EndFunction

Float Function GetWaitMultiplier()
    If _waitMultiplier < 0.25 || _waitMultiplier > 4.0
        Return 1.0
    EndIf
    Return _waitMultiplier
EndFunction

Function SetWaitMultiplier(Float afMultiplier)
    If afMultiplier >= 0.25 && afMultiplier <= 4.0
        _waitMultiplier = afMultiplier
    EndIf
EndFunction

MO_UIBridge Function EnhancedUI()
    ; Core never imports UIExtensions, SkyUI, or SKSE types.
    If Game.GetFormFromFile(0x00000E05, "UIExtensions.esp") == None
        Return None
    EndIf
    Return Game.GetFormFromFile(0x00000800, "MerchantOrders-UI.esp") as MO_UIBridge
EndFunction

Int Function ChooseList(String asTitle, String[] asEntries)
    MO_UIBridge bridge = EnhancedUI()
    If bridge == None
        Return -2
    EndIf
    Return bridge.ShowList(asTitle, asEntries)
EndFunction

Int Function EditQuantity(Int aiStart, Int aiItem)
    Return EditOrderQuantity(aiStart, MO_Catalog.UnitPrice(aiItem), MO_Catalog.Capacity(aiItem), aiItem < 0)
EndFunction

Int Function EditOrderQuantity(Int aiStart, Int aiPrice, Int aiCapacity, Bool abDefaults = False)
    MO_UIBridge bridge = EnhancedUI()
    If bridge != None
        Int advanced = bridge.EditQuantity(aiStart, 1, 500)
        If advanced != -2
            Return advanced
        EndIf
    EndIf
    Int quantity = aiStart
    Message editor = MO_Catalog.ExtraMenu(0)
    If abDefaults
        editor = MO_Catalog.ExtraMenu(5)
    EndIf
    Int attempts = 0
    While attempts < 200
        Float days = QuoteLeadDays(quantity, aiCapacity)
        Int choice = editor.Show(quantity, aiPrice, quantity * aiPrice, days)
        If choice == 0
            Return quantity
        ElseIf choice == 1
            quantity -= 1
        ElseIf choice == 2
            quantity += 1
        ElseIf choice == 3
            quantity -= 10
        ElseIf choice == 4
            quantity += 10
        ElseIf choice == 5
            quantity -= 50
        ElseIf choice == 6
            quantity += 50
        Else
            Return -1
        EndIf
        If quantity < 1
            quantity = 1
        ElseIf quantity > 500
            quantity = 500
        EndIf
        attempts += 1
    EndWhile
    Return -1
EndFunction
Function ShowSettings()
    String[] choices = new String[3]
    choices[0] = "Default quantity: " + GetDefaultQuantity()
    choices[1] = "Lead-time multiplier: " + GetWaitMultiplier() + "x"
    choices[2] = "Back"
    Int choice = ChooseList("New-order settings", choices)
    If choice == -2
        choice = MO_Catalog.ExtraMenu(2).Show(GetDefaultQuantity(), GetWaitMultiplier())
    EndIf
    If choice == 0
        Int quantity = EditQuantity(GetDefaultQuantity(), -1)
        If quantity >= 1 && quantity <= 500
            SetDefaultQuantity(quantity)
        EndIf
    ElseIf choice == 1
        String[] speeds = new String[6]
        speeds[0] = "0.25x - Four times faster"
        speeds[1] = "0.5x - Twice as fast"
        speeds[2] = "1x - Normal"
        speeds[3] = "2x - Twice as long"
        speeds[4] = "4x - Four times as long"
        speeds[5] = "Cancel"
        Int speed = ChooseList("Lead times for new orders", speeds)
        If speed == -2
            speed = MO_Catalog.ExtraMenu(3).Show()
        EndIf
        If speed == 0
            SetWaitMultiplier(0.25)
        ElseIf speed == 1
            SetWaitMultiplier(0.5)
        ElseIf speed == 2
            SetWaitMultiplier(1.0)
        ElseIf speed == 3
            SetWaitMultiplier(2.0)
        ElseIf speed == 4
            SetWaitMultiplier(4.0)
        EndIf
    EndIf
EndFunction

Function OpenMenu(Actor akSpeaker)
    If _menuOpen
        Return
    EndIf
    _menuOpen = True
    If !IsConfigured() || !IsSupportedMerchant(akSpeaker)
        Debug.Notification("Merchant Orders: this merchant is unavailable.")
        _menuOpen = False
        Return
    EndIf
    If akSpeaker.IsDead()
        Unavailable.Show()
        _menuOpen = False
        Return
    EndIf

    Message menu = MO_Catalog.MainMenu(akSpeaker)
    If menu == None && StockProvider() != None
        menu = MO_Catalog.DynamicMainMenu()
    EndIf
    If menu == None
        Debug.Notification("Merchant Orders: catalog missing. Update all mod scripts and the plugin together.")
        _menuOpen = False
        Return
    EndIf
    RefreshReadiness()
    String[] choices = new String[5]
    choices[0] = "Place an order"
    choices[1] = "Order status"
    choices[2] = "Collect / resolve delivery"
    choices[3] = "Settings"
    choices[4] = "Leave"
    Int choice = ChooseList(MerchantLabel(akSpeaker), choices)
    If choice == -2
        choice = menu.Show()
    EndIf
    If choice == 0
        PlaceOrder(akSpeaker)
    ElseIf choice == 1
        ShowStatus()
    ElseIf choice == 2
        CollectOrder(akSpeaker)
    ElseIf choice == 3
        ShowSettings()
    EndIf
    _menuOpen = False
EndFunction

Bool Function IsConfigured()
    ; Keep all original properties and persistent fields for existing saves.
    Return Gold != None && Unavailable != None && InsufficientGold != None
EndFunction

Function PlaceOrder(Actor akSpeaker)
    If !_menuOpen
        Return
    EndIf
    RefreshReadiness()
    If _orderState != 0 && _orderState != 4
        ShowStatus()
        Return
    EndIf
    MO_StockBridge provider = StockProvider()
    Form item = None
    String itemName = ""
    Int itemIndex = -1
    Int unitPrice = 0
    Int capacity = 0
    ObjectReference funds = None

    If provider != None
        Form[] products = provider.GetItems(akSpeaker)
        If products == None
            Debug.Notification("Merchant Orders: no trade inventory is available.")
            Return
        EndIf
        String[] labels = new String[120]
        Int i = 0
        Int eligible = 0
        While i < products.Length && i < 120
            If products[i] != None
                labels[i] = provider.ItemName(products[i]) + " - " + provider.UnitPrice(products[i]) + " gold each"
                eligible += 1
            EndIf
            i += 1
        EndWhile
        If eligible == 0
            _menuOpen = False
            Debug.MessageBox("This merchant currently has no eligible common materials or food. Try normal trading once if the inventory has not initialized, or return after a restock.")
            Return
        EndIf
        Int selected = ChooseList(MerchantLabel(akSpeaker) + " - Materials and food", labels)
        If selected < 0 || selected >= products.Length
            Return
        EndIf
        item = products[selected]
        If item == None || !provider.CanOrder(akSpeaker, item)
            Return
        EndIf
        itemName = provider.ItemName(item)
        unitPrice = provider.UnitPrice(item)
        capacity = provider.Capacity(item)
        funds = provider.MerchantFunds(akSpeaker)
    Else
        Message itemsMenu = MO_Catalog.ItemMenu(akSpeaker)
        If itemsMenu == None
            Return
        EndIf
        String[] items = new String[5]
        Int i = 0
        While i < items.Length
            Int index = MO_Catalog.ItemForChoice(akSpeaker, i)
            items[i] = MO_Catalog.ItemName(index) + " - " + MO_Catalog.UnitPrice(index) + " gold each"
            i += 1
        EndWhile
        Int itemChoice = ChooseList("Common materials", items)
        If itemChoice == -2
            itemChoice = itemsMenu.Show()
        EndIf
        itemIndex = MO_Catalog.ItemForChoice(akSpeaker, itemChoice)
        If !MO_Catalog.CanOrder(akSpeaker, itemIndex)
            Return
        EndIf
        item = MO_Catalog.ItemForm(itemIndex)
        itemName = MO_Catalog.ItemName(itemIndex)
        unitPrice = MO_Catalog.UnitPrice(itemIndex)
        capacity = MO_Catalog.Capacity(itemIndex)
        funds = MO_Catalog.MerchantFunds(akSpeaker)
    EndIf
    If item == None || itemName == "" || unitPrice < 1 || unitPrice > 200 || capacity <= 0 || funds == None
        Unavailable.Show()
        Return
    EndIf
    Int quantity = EditOrderQuantity(GetDefaultQuantity(), unitPrice, capacity)
    If quantity < 1 || quantity > 500
        Return
    EndIf
    Int subtotal = quantity * unitPrice
    Int courierFee = MO_Catalog.CourierFee(subtotal)
    String[] methods = new String[3]
    methods[0] = "Merchant pickup - Free"
    methods[1] = "Courier - " + courierFee + " gold (5%)"
    methods[2] = "Cancel"
    Int delivery = ChooseList("Delivery method", methods)
    If delivery == -2
        delivery = MO_Catalog.ExtraMenu(1).Show(subtotal, courierFee, subtotal + courierFee)
    EndIf
    If delivery != 0 && delivery != 1
        Return
    EndIf
    Int fee = 0
    If delivery == 1
        fee = courierFee
        If MO_Catalog.Courier() == None || MO_Catalog.ShipmentReceipt() == None
            Unavailable.Show()
            Return
        EndIf
    EndIf
    Int total = subtotal + fee
    Float multiplier = GetWaitMultiplier()
    Float leadDays = QuoteLeadDays(quantity, capacity)
    If leadDays <= 0.0
        Return
    EndIf

    If provider != None
        MO_UIBridge bridge = EnhancedUI()
        If bridge == None
            Return
        EndIf
        String[] details = new String[5]
        details[0] = "Materials / food: " + subtotal + " gold"
        details[1] = "Delivery fee: " + fee + " gold"
        details[2] = "TOTAL: " + total + " gold"
        details[3] = "Sourcing: " + leadDays + " game day(s)"
        details[4] = "Merchant pickup"
        If delivery == 1
            details[4] = "Courier after sourcing; travel time varies"
        EndIf
        If !bridge.ConfirmOrder(quantity + " x " + itemName, details)
            Return
        EndIf
    Else
        Message confirmation = MO_Catalog.Confirmation(itemIndex)
        If delivery == 1
            confirmation = MO_Catalog.CourierConfirmation(itemIndex)
        EndIf
        If confirmation == None || confirmation.Show(quantity, subtotal, fee, total, leadDays) != 0
            Return
        EndIf
    EndIf

    ; Revalidate live stock and its exact quote after every interactive menu.
    If !IsConfigured() || akSpeaker.IsDead() || multiplier != GetWaitMultiplier()
        Return
    EndIf
    If provider != None
        If !provider.CanOrder(akSpeaker, item) || provider.MerchantFunds(akSpeaker) != funds || provider.UnitPrice(item) != unitPrice || provider.Capacity(item) != capacity
            Debug.Notification("Merchant Orders: stock or pricing changed. No payment taken.")
            Return
        EndIf
    ElseIf !MO_Catalog.CanOrder(akSpeaker, itemIndex) || item != MO_Catalog.ItemForm(itemIndex) || unitPrice != MO_Catalog.UnitPrice(itemIndex)
        Return
    EndIf
    Actor player = Game.GetPlayer()
    If player.GetItemCount(Gold) < total
        InsufficientGold.Show(total)
        Return
    EndIf
    If _orderState != 0 && _orderState != 4
        Return
    EndIf
    _orderMerchant = akSpeaker
    _orderedForm = item
    _orderItem = item as MiscObject
    _orderLabel = itemName
    _orderVendorName = MerchantLabel(akSpeaker)
    _orderFunds = funds
    _quantity = quantity
    _unitPrice = unitPrice
    _paidGold = total
    _deliveryMethod = delivery
    _deliveryFee = fee
    _deliveryParcel = None
    _placedDay = Utility.GetCurrentGameTime()
    _dueDay = _placedDay + leadDays
    player.RemoveItem(Gold, total, True, funds)
    _orderState = 1
    ScheduleReadiness()
    _menuOpen = False
    String method = "Collect from " + OrderedMerchantLabel() + "."
    If delivery == 1
        method = "Courier delivery after sourcing. The courier still needs to reach you."
    EndIf
    Debug.MessageBox("Order accepted: " + quantity + " " + itemName + ".\nGoods: " + subtotal + " gold\nDelivery: " + fee + " gold\nPaid: " + total + " gold\nSourcing: " + leadDays + " game day(s).\n" + method)
EndFunction
; Legacy helper signatures retained for earlier saved script instances.
Float Function GetLeadTimeDays(Int aiQuantity)
    If aiQuantity <= 0
        Return 0.0
    EndIf
    Int days = (aiQuantity + 14) / 15
    Return days as Float
EndFunction

ObjectReference Function GetMerchantFunds()
    Return Game.GetForm(0x0009CAF9) as ObjectReference
EndFunction

Function ShowStatus()
    _menuOpen = False
    RefreshReadiness()
    If _orderState != 1 && _orderState != 2 && _orderState != 5
        Debug.MessageBox("You have no outstanding order.")
        Return
    EndIf
    String details = _quantity + " " + OrderedLabel() + "\nMerchant: " + OrderedMerchantLabel() + "\nPaid: " + _paidGold + " gold. Unit price: " + _unitPrice + " gold."
    If _deliveryMethod == 1
        details += "\nCourier fee included: " + _deliveryFee + " gold."
    Else
        details += "\nDelivery method: merchant pickup."
    EndIf
    If _orderState == 1
        Float remaining = (_dueDay - Utility.GetCurrentGameTime()) * 24.0
        If remaining < 0.0
            remaining = 0.0
        EndIf
        Int hours = (remaining + 0.999) as Int
        Debug.MessageBox(details + "\nSourcing: about " + hours + " game hour(s) remaining.")
    ElseIf _orderState == 5
        Debug.MessageBox(details + "\nSourcing complete. Courier dispatched. Visit a settlement and let the courier approach.\nIf needed, use Collect / resolve at the original merchant to switch to pickup and refund the delivery fee.")
    ElseIf _deliveryMethod == 1
        Debug.MessageBox(details + "\nSourcing complete; courier dispatch unavailable. Collect / resolve at the original merchant can refund the fee and release the goods.")
    Else
        Debug.MessageBox(details + "\nReady to collect from the original merchant.")
    EndIf
EndFunction

Function CollectOrder(Actor akSpeaker)
    If !_menuOpen
        Return
    EndIf
    RefreshReadiness()
    If _orderState != 2 && _orderState != 5
        ShowStatus()
        Return
    EndIf
    If akSpeaker != _orderMerchant
        _menuOpen = False
        Debug.MessageBox("Please resolve this order with " + OrderedMerchantLabel() + ".")
        Return
    EndIf
    If _deliveryMethod == 1
        If MO_Catalog.ExtraMenu(4).Show(_deliveryFee) != 0
            Return
        EndIf
        ; Courier delivery may have occurred during the confirmation.
        If _deliveryMethod != 1 || (_orderState != 2 && _orderState != 5)
            ShowStatus()
            Return
        EndIf
        Int refund = _deliveryFee
        _deliveryMethod = 0
        _deliveryFee = 0
        _deliveryParcel = None
        _paidGold -= refund
        _orderState = 2
        ; Invalidate the receipt before any native inventory calls.
        ObjectReference funds = OrderedFunds()
        Int available = 0
        If funds != None
            available = funds.GetItemCount(Gold)
            If available > refund
                available = refund
            EndIf
            If available > 0
                funds.RemoveItem(Gold, available, True, Game.GetPlayer())
            EndIf
        EndIf
        If refund > available
            Game.GetPlayer().AddItem(Gold, refund - available, True)
        EndIf
    EndIf
    If _orderState != 2
        Return
    EndIf
    _orderState = 3
    Game.GetPlayer().AddItem(OrderedItem(), _quantity, True)
    _orderState = 4
    UnregisterForUpdateGameTime()
    _menuOpen = False
    Debug.MessageBox("Collected " + _quantity + " " + OrderedLabel() + ". Thank you for your business.")
EndFunction

Function DispatchCourier()
    If _orderState != 2 || _deliveryMethod != 1
        Return
    EndIf
    ; Reserve dispatch before resolving any native forms.
    _orderState = 5
    WICourierScript courier = MO_Catalog.Courier()
    Book receipt = MO_Catalog.ShipmentReceipt()
    If courier == None || receipt == None
        _orderState = 2
        Return
    EndIf
    ; Create only one uniquely tracked receipt.
    _deliveryParcel = Game.GetPlayer().PlaceAtMe(receipt, 1, True, False)
    If _deliveryParcel == None
        _orderState = 2
        Return
    EndIf
    courier.AddRefToContainer(_deliveryParcel)
    Debug.Notification("Merchant Orders: your shipment has been dispatched.")
EndFunction

Function ReceiveShipment(ObjectReference akReceipt)
    If _orderState != 5 || _deliveryMethod != 1 || akReceipt == None || akReceipt != _deliveryParcel
        Return
    EndIf
    ; Consume entitlement before the inventory grant, rejecting old/replayed receipts.
    _orderState = 3
    _deliveryParcel = None
    Game.GetPlayer().AddItem(OrderedItem(), _quantity, True)
    _orderState = 4
    UnregisterForUpdateGameTime()
    Debug.Notification("Courier delivered " + _quantity + " " + OrderedLabel() + ".")
EndFunction

Function RefreshReadiness()
    Float now = Utility.GetCurrentGameTime()
    If _orderState == 1 && now >= _dueDay
        _orderState = 2
        UnregisterForUpdateGameTime()
    EndIf
    If _orderState == 2 && _deliveryMethod == 1
        DispatchCourier()
    EndIf
EndFunction
Function ScheduleReadiness()
    UnregisterForUpdateGameTime()
    If _orderState == 1
        Float hours = (_dueDay - Utility.GetCurrentGameTime()) * 24.0
        If hours < 0.1
            hours = 0.1
        EndIf
        RegisterForSingleUpdateGameTime(hours)
    EndIf
EndFunction

Event OnUpdateGameTime()
    RefreshReadiness()
    If _orderState == 1
        ScheduleReadiness()
    EndIf
EndEvent
