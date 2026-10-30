# Merchant Orders 0.4.1 - development build

Material orders from eleven merchants in the five major cities. Six common materials only: iron ingots, steel ingots, iron ore, leather, leather strips, and firewood.

## 0.4.1 vendor-detection hotfix

Fixed the rejection of Anoriath, Carlotta Valentia, Belethor, and other valid vendors. The 0.4.0 script tested 0x1000; the actual vendor bit in the game records is 0x4000. The generator now derives this flag from the record schema. Discovery also ignores negative-rank/removed factions.

Install BOTH matching 0.4.1 core and enhanced addon packages after quitting Skyrim, then reload the same save. No order/quest reset is needed. Existing order fields and 0.4.0 record IDs are preserved. Do not update only the addon: its corrected resolver calls a new generated core helper.

Regression checks reproduce the old rejection and resolve one vendor chest each for Anoriath, Carlotta, Belethor, and Orgnar. All nine scripts compile. The hotfix has not yet been confirmed in game.
## New in 0.4.0: stock-driven materials and food

With the enhanced addon, eligible orders now come from the merchant's current trade inventory. Innkeepers such as Orgnar can offer food they actually stock. Ordinary food/drink is admitted by its food flag; poisons, hostile consumables, known special/drug items, and high-value consumables are excluded. Materials remain limited to the six approved common forms.

Stock changes after restocking or normal trading can change the catalog. Horker Stew qualifies when stocked; it is not forcibly added to every innkeeper. Mod-added normal food can qualify, while extra materials need an allowlist patch.

Food prices are 150% of base value, rounded up (minimum one gold); food sources at 25 units/day before your multiplier. Existing material prices stay the same. The courier fee remains 5%.

Dynamic mode requires the enhanced addon and its SKSE/SkyUI/UIExtensions dependencies. Install both matching 0.4.1 packages. The addon now includes MO_DynamicStock.pex in addition to its prior two scripts. A new startup quest enables the mode without resetting paid orders.

Core-only mode still uses the eleven merchants and six material catalogs below. The new dynamic feature is not yet tested in game; the author's successful test report applies to 0.3.0.

See DYNAMIC_CATALOGS.md in the source repository for stock limits, compatibility, and save preservation.
## Delivery choice

After selecting an item and quantity, choose:
- Merchant pickup: no delivery fee.
- Courier: add 5% of the materials subtotal, rounded up to whole gold.

The final quote separates materials, delivery, total, and sourcing time. For 50 Iron Ingots: 600 gold materials + 30 gold courier fee = 630 gold. Payment goes into the accepting shop's vendor chest.

Sourcing remains quantity/material based. Once it finishes, courier orders dispatch a unique shipment receipt through Skyrim's vanilla WICourier quest. The courier hands it to you; that transfer grants the materials and consumes the receipt. Other quest mail is not changed.

The sourcing deadline is not a guaranteed courier arrival time. The courier follows normal encounter/location behavior; visiting a settlement and changing location can allow the courier to approach.

If delivery is delayed, return to the original merchant and choose Collect / resolve delivery. After sourcing is complete, you can switch to pickup, refund the delivery fee, and collect. The old receipt is invalidated first, so it cannot later grant a second shipment. Materials cannot be cancelled/refunded.

## Adjustable quantities and waiting

Every order accepts 1-500 whole units. Without the UI addon, use the +/- buttons before confirming. With the addon, type the quantity directly.

Each merchant's Settings menu has:
- Default quantity for new orders.
- Lead-time multiplier: 0.25x, 0.5x, 1x, 2x, or 4x.

The optional SkyUI MCM provides sliders, including quarter-step multipliers between 0.25x and 4x. Quantity and per-material capacity still determine the base sourcing time. A 0.25x multiplier is four times faster; 4x is four times longer.

Settings only affect new orders. An accepted order keeps its item, quantity, total, delivery choice, and due time.

## Core installation/update

Exit dialogue, save, and quit Skyrim. Install MerchantOrders-0.4.1-prototype.zip through MO2/Vortex, replacing the prior core package. Keep MerchantOrders.esp enabled.

Deploy all SIX core PEX scripts together:
- MO_OrderManager
- MO_OrderDialogue
- MO_Catalog
- MO_UIBridge
- MO_ShipmentReceipt
- MO_StockBridge

Existing pickup orders keep their original terms. All released 0.3.0 form IDs and old persistent fields are preserved. No quest reset is needed.

The core only requires Skyrim.esm and installed vanilla game scripts. It does not require SKSE, SkyUI, or UIExtensions.

## Optional enhanced UI

Install the matching MerchantOrders-UI-0.4.1.zip after the core, with:
- SKSE matching your Skyrim runtime: https://skse.silverlock.org/
- SkyUI SE: https://www.nexusmods.com/skyrimspecialedition/mods/12604
- UIExtensions SE: https://www.nexusmods.com/skyrimspecialedition/mods/17561

Enable MerchantOrders-UI.esp after MerchantOrders.esp and launch through SKSE. This adds scrollable action/material/delivery menus, direct quantity entry, and the Merchant Orders MCM. See UI.md in the source repository or the addon README for details. Dependency files are not bundled.

The final payment confirmation stays a native message box. The list's top row returns Back; Escape cancels. Default quantity and speed can still be changed from merchants when using the core alone.

## Merchants and specialties

| City | General merchant | Blacksmith |
| --- | --- | --- |
| Whiterun | Belethor | Adrianne Avenicci; Ulfberth War-Bear |
| Solitude | Sayma | Beirand |
| Windhelm | Revyn Sadri | Oengul War-Anvil |
| Markarth | Lisbet | Ghorza gra-Bagol |
| Riften | Bersi Honey-Hand | Balimund |

General merchants offer iron ingots, iron ore, leather, leather strips, and firewood. Blacksmiths replace firewood with steel ingots. No rare metals, gems, soul gems, weapons, armor, or enchanted items.

One outstanding order is allowed globally, including dispatched courier shipments. Adrianne and Ulfberth share shop funds, but pickup/recovery stays with the actor who accepted the order.

## Validation and periodic tests

Released 0.3.0 was author-tested on 30 October 2026, with occasional courier delays. This 0.4.0 stock-driven development build is not yet tested in game. Nine scripts compile, both plugins and prior saved-field/record compatibility checks pass, and food/rare-item rules are checked.

For your next periodic test, cover pickup and courier checkout, a non-default quantity/multiplier, save/load, the courier handoff, and pickup recovery followed by an old receipt arriving. Verify one grant and one fee refund at most. The earlier author report is not a validation of the new dynamic feature.

There is no merchant-death recovery. Courier overhauls that preserve WICourierScript.AddRefToContainer should remain callable, but compatibility has not been tested. The builder uses vanilla vendor chests; overhauls replacing them need integration.
