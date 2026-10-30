Scriptname MO_DynamicStock extends MO_StockBridge
; Runs on the new addon bootstrap quest, avoiding new filled properties on old saves.

Event OnInit()
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
    GlobalVariable enabled = MO_Catalog.DynamicOrdersEnabled()
    If enabled != None
        If IsReady()
            enabled.SetValue(1.0)
        Else
            enabled.SetValue(0.0)
            Debug.Notification("Merchant Orders: dynamic catalogs require SKSE and UIExtensions.")
        EndIf
    EndIf
EndEvent

Bool Function IsReady()
    Return SKSE.GetVersion() > 0 && Game.GetFormFromFile(0x00000E05, "UIExtensions.esp") != None
EndFunction

ObjectReference Function MerchantFunds(Actor akMerchant)
    If akMerchant == None || akMerchant.IsDead()
        Return None
    EndIf
    Faction[] factions = akMerchant.GetFactions(0, 127)
    If factions == None
        Return None
    EndIf
    ObjectReference found = None
    Int i = 0
    While i < factions.Length
        Faction vendor = factions[i]
        If vendor != None && akMerchant.IsInFaction(vendor) && vendor.IsFactionFlagSet(MO_Catalog.VendorFactionFlag())
            ObjectReference chest = vendor.GetMerchantContainer()
            If chest != None
                If found != None && found != chest
                    ; Never guess which of two shops should receive payment.
                    Return None
                EndIf
                found = chest
            EndIf
        EndIf
        i += 1
    EndWhile
    Return found
EndFunction

String Function MerchantName(Actor akMerchant)
    If akMerchant == None
        Return "the original merchant"
    EndIf
    Return akMerchant.GetActorBase().GetName()
EndFunction

Bool Function IsAllowed(Form akItem)
    If akItem == None
        Return False
    EndIf
    FormList common = MO_Catalog.CommonMaterials()
    If common != None && common.HasForm(akItem)
        Return True
    EndIf
    Potion food = akItem as Potion
    If food == None || !food.IsFood() || food.IsPoison() || food.IsHostile()
        Return False
    EndIf
    FormList excluded = MO_Catalog.ExcludedFood()
    If excluded != None && excluded.HasForm(akItem)
        Return False
    EndIf
    ; Fail closed on high-value/special consumables.
    Return akItem.GetGoldValue() <= 100 && akItem.GetName() != ""
EndFunction

Form[] Function GetItems(Actor akMerchant)
    ObjectReference chest = MerchantFunds(akMerchant)
    If chest == None
        Return None
    EndIf
    Form[] products = new Form[120]
    Int count = chest.GetNumItems()
    If count > 2048
        count = 2048
    EndIf
    Int i = 0
    Int filled = 0
    While i < count && filled < 120
        Form item = chest.GetNthForm(i)
        If IsAllowed(item) && chest.GetItemCount(item) > 0
            If products.Find(item) < 0
                products[filled] = item
                filled += 1
            EndIf
        EndIf
        i += 1
    EndWhile
    Return products
EndFunction

Bool Function CanOrder(Actor akMerchant, Form akItem)
    If !IsAllowed(akItem)
        Return False
    EndIf
    ObjectReference chest = MerchantFunds(akMerchant)
    Return chest != None && chest.GetItemCount(akItem) > 0
EndFunction

String Function ItemName(Form akItem)
    If akItem == None
        Return "goods"
    EndIf
    Return akItem.GetName()
EndFunction

Int Function UnitPrice(Form akItem)
    Int legacy = MO_Catalog.ItemIndex(akItem as MiscObject)
    If legacy >= 0
        Return MO_Catalog.UnitPrice(legacy)
    EndIf
    If !IsAllowed(akItem)
        Return 0
    EndIf
    ; Common food orders: 150% of base value, rounded up, minimum one gold.
    Int value = akItem.GetGoldValue()
    Int price = (value * 3 + 1) / 2
    If price < 1
        price = 1
    EndIf
    Return price
EndFunction

Int Function Capacity(Form akItem)
    Int legacy = MO_Catalog.ItemIndex(akItem as MiscObject)
    If legacy >= 0
        Return MO_Catalog.Capacity(legacy)
    EndIf
    If IsAllowed(akItem)
        Return 25
    EndIf
    Return 0
EndFunction
