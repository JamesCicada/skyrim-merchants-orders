# Merchant Orders 0.3.0

Material orders from eleven merchants in the five major cities. Six common materials only: iron ingots, steel ingots, iron ore, leather, leather strips, and firewood.

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

Exit dialogue, save, and quit Skyrim. Install MerchantOrders-0.3.0-prototype.zip through MO2/Vortex, replacing the prior core package. Keep MerchantOrders.esp enabled.

Deploy all FIVE core PEX scripts together:
- MO_OrderManager
- MO_OrderDialogue
- MO_Catalog
- MO_UIBridge
- MO_ShipmentReceipt

Existing pickup orders keep their original terms. All released 0.2.1 form IDs and old persistent fields are preserved. No quest reset is needed.

The core only requires Skyrim.esm and installed vanilla game scripts. It does not require SKSE, SkyUI, or UIExtensions.

## Optional enhanced UI

Install the matching MerchantOrders-UI-0.3.0.zip after the core, with:
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

Author-tested in game on 30 October 2026. The author reports the current version working and notes that couriers can sometimes arrive late. All seven scripts compile; both plugins, prior record IDs, and fee rounding pass build checks. This does not establish every edge case or load-order combination.

For your next periodic test, cover pickup and courier checkout, a non-default quantity/multiplier, save/load, the courier handoff, and pickup recovery followed by an old receipt arriving. Verify one grant and one fee refund at most. The current version has a general author smoke-test report; no exhaustive per-feature matrix is claimed.

There is no merchant-death recovery. Courier overhauls that preserve WICourierScript.AddRefToContainer should remain callable, but compatibility has not been tested. The builder uses vanilla vendor chests; overhauls replacing them need integration.
