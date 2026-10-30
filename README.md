# Merchant Orders

A Skyrim Anniversary Edition mod for bulk orders from merchants, with optional courier delivery.

## Current release: 0.4.1

The enhanced addon now builds catalogs from a merchant's current trade inventory:
- Six approved common materials plus ordinary food/drink.
- Innkeepers such as Orgnar and other standard vendors can be discovered through their vendor factions/chests.
- Rare materials, equipment, potions/poisons, and known special consumables are filtered out.
- Mod-added normal food can qualify by its food flag; additional materials need an allowlist patch.
- Quantities 1-500, configurable sourcing times, 5% courier delivery, and pickup recovery remain.
- Itemized dynamic quotes revalidate stock and price before payment.

Dynamic catalogs need the enhanced addon with SKSE, SkyUI SE, and UIExtensions SE. Core-only mode retains the previous eleven-merchant/six-material catalogs.

[Dynamic behavior and limits](docs/DYNAMIC_CATALOGS.md) | [Installation](docs/INSTALL.md) | [Enhanced addon](docs/UI.md)

Nine scripts compile and plugin/package regression checks pass. Existing record IDs and saved order fields are preserved. The 0.4.1 merchant detection repair awaits in-game confirmation. Horker Stew passes the food test; rare ingots, equipment, and Skooma do not.

The catalog follows current trade stock: sold-out food may be absent until restocking. It does not give every innkeeper every cooking recipe. Existing paid orders keep their stored terms.

0.4.1 fixes the wrong vendor-flag check that rejected Anoriath, Carlotta Valentia, and Belethor. Regression checks now resolve their vendor chests; both matching packages are required. Existing orders need no reset.

## Published version

[GitHub 0.4.1 release and prebuilt files](https://github.com/JamesCicada/skyrim-merchants-orders/releases/tag/v0.4.1)
[Nexus page](https://www.nexusmods.com/skyrimspecialedition/mods/197340)

The author reported 0.3.0 working in game on 30 October 2026, with occasional courier delays. The sourcing estimate excludes courier travel/encounter time.

## Development

- [Build instructions](docs/BUILD.md)
- [Fallback catalog configuration](catalogs/materials.json)
- [Order manager](Source/Scripts/MO_OrderManager.psc)
- [Dynamic stock provider](Source/UI/MO_DynamicStock.psc)
- [Stock policy/dialogue generator](tools/PluginBuilder/StockFeatures.cs)
- [Development status](docs/STATUS.md)

Do not commit game assets, saves, external tools, or generated archives. Choose a project license before public distribution.

## Support development

Made by James Cicada, a solo developer. Optional support is welcome on [Ko-fi](https://ko-fi.com/jcicada).
