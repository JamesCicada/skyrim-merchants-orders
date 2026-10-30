# Dynamic material and food catalogs - 0.4.1 development build

Install the matching 0.4.1 core and enhanced addon, plus SKSE matching your game, SkyUI SE, and UIExtensions SE. Dynamic mode lives in the enhanced addon; the core alone retains the existing eleven-merchant/six-material catalogs.

## What changes

The addon discovers a merchant's active vendor faction and its trade container. Orders are built from eligible items actually present in that container. It does not scan an NPC's personal pockets or add every recipe to every shop.

Eligible goods:
- The six approved common materials: Iron Ingots, Steel Ingots, Iron Ore, Leather, Leather Strips, and Firewood.
- Ordinary food/drink represented by food-flagged ingestibles, excluding poison/hostile effects, known special/drug items, and base values over 100 gold.

Food is recognized by its actual food flag, not just VendorItemFood. Horker Stew has the food flag but no keyword list; Skooma can have VendorItemFood without being food. The checks deliberately handle these cases differently.

Common materials remain an explicit global allowlist to avoid accidentally offering gold, ebony, daedric materials, gems, or equipment. A compatibility patch can add approved mod materials to MO_CommonMaterials or exclude mod food through MO_ExcludedFood. Mod-added ordinary food can qualify automatically when properly flagged and stocked.

## Merchants

Dynamic dialogue is enabled when the addon's new startup quest runs. It is offered while service conditions allow. The stock provider then requires one unambiguous vendor chest.

This can include innkeepers such as Orgnar and other/mod-added merchants using standard vendor factions and containers. It is not a hardcoded claim that every custom merchant implementation is supported.

The original eleven merchant responses and their IDs remain unchanged. Other merchants use the shared vanilla trade response; unique custom voices may be silent.

## Availability and pricing

The catalog follows current trade stock. Food not rolled into this restock, sold out, or removed from the chest may be absent. An approved item sold to the vendor can also appear; the scanner does not reconstruct the historical origin of every stack. This is a stock-driven catalog, not a list of every product a merchant could ever source.

If an uninitialized inventory appears empty, use normal trading once, then try ordering again. No dummy items are inserted into stock to force initialization.

The current stock proves eligibility; it does not cap bulk order quantity or consume those existing units. Quantities remain 1-500.

The original common materials keep their configured prices/capacities. Food orders use 150% of base item value, rounded up, minimum one gold, and source 25 units per game day before applying the waiting multiplier. This is fixed order pricing, not an exact reproduction of Speech/barter discounts.

A visit scans at most 2,048 distinct forms and lists at most 120 eligible products. Item, price, capacity, vendor chest, and availability are rechecked before payment.

## Orders and upgrades

New orders snapshot the actual Form, item name, merchant name, destination chest, quantity, payment, and deadline. Food and mod-added forms can be delivered through the existing pickup/courier paths.

The legacy _orderItem MiscObject field remains unchanged. New generalized fields are appended, and old orders use their legacy values if no new snapshot exists. All 0.3.0 core record IDs and all 29 original saved fields/properties are checked at build time.

The addon keeps its original UI quest at local ID 800 and adds a new startup stock quest at 801. Its SEQ contains both quests, so existing saves can start the new feature without resetting the main order quest.

Do not remove the addon or an item's source mod while an order depends on it.

## Validation

All nine authored scripts compile and plugin/package checks pass. Tests confirm Horker Stew qualifies; Skooma, gold/ebony ingots, and equipment do not; Orgnar has a discoverable vendor container; and old saved fields/types are preserved.

This 0.4.0 dynamic feature has not been observed in game. The author-tested report applies to released 0.3.0, not this new development build.
