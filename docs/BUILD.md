# Building Merchant Orders 0.4.1

Requires .NET SDK 8+, Caprica 0.3.0, and a local Skyrim.esm. Mutagen.Bethesda.Skyrim 0.53.1 is pinned.

    .\build.ps1 -SkyrimData 'D:\Games\Skyrim Anniversary Edition\Data'

Caprica: https://github.com/Orvid/Caprica/releases/tag/v0.3.0
Extract to .tools/caprica/ or pass -Compiler.

Outputs:
- dist/MerchantOrders-0.4.1-prototype.zip: core, 15 files.
- dist/MerchantOrders-UI-0.4.1.zip: dynamic/enhanced addon, 9 files.

No game installation, plugins list, saves, or public release is modified by the build.

## Records and sources

CatalogExpansion retains the six-material/eleven-merchant fallback and all original record allocations. OrderFeatures appends delivery/settings records. StockFeatures appends the dynamic enable global (default zero), material/food policy FormLists, a generic menu, and the generic merchant INFO.

StockFeatures verifies the 0.3.0 saved-field fixture before output. The binary validator preserves every released 0.3.0 core form ID. New fields are appended rather than changing the saved MiscObject item type.

The addon keeps its existing UI/MCM quest at ID 800 and adds the stock bootstrap at 801. Both are start-game enabled and included in its SEQ. No vanilla NPC, merchant, or courier record is overridden.

MO_Catalog.psc is generated; do not edit it manually. materials.json now describes the core-only fallback and the dynamic common-material allowlist. It is not a runtime JSON loader.

## API separation

Core compiles six scripts against authored vanilla interfaces in tools/api.

For the addon, the build copies those interfaces into .tools/stock-api, appends authored SKSE signatures from tools/stock-api/*.additions, and adds its SKSE-only class interfaces. Existing declarations are not appended twice when using fuller source sets. The addon compiles three scripts using that merged folder plus tools/ui-api.

No imported interface, dependency implementation, game asset, or extracted audio is packaged. Runtime dependencies are required only by the enhanced/dynamic addon.

## Dynamic policies

The addon reads current vendor-container inventory with SKSE. It does not inspect actor pockets or reconstruct all historical/restock possibilities.

Common materials are allowlisted. Food uses the engine food flag, poison/hostile exclusion, explicit special-item exclusions, and a 100-gold base-value cap. Mod-added ordinary food can qualify; extra materials require an explicit patch.

Existing common-material prices/capacities stay configured. Food uses ceil(1.5 * base value), minimum one gold, with capacity 25/day. Quantity and waiting settings are applied to the quote, then stored with the accepted order.

The scan limits are 2,048 forms and 120 eligible products. UI lists skip empty array slots. Only the explicit Pay and confirm callback charges; informational quote rows do not.

## Validation scope

Build checks cover compilation, form/script/voice links, addon startup, prior record IDs, saved field types, material restrictions, Horker Stew qualification, misleading food keywords, vendor-container discovery, fee rounding through 100,000 gold, and archive entry allowlists.

These checks do not execute Skyrim inventory, food delivery, menu, or save-upgrade behavior. The new dynamic paths are untested in game. The author-tested release remains 0.3.0.

For a second compile against complete CK sources, -VanillaSources and -FlagsFile remain available. Compiler CLI syntax is Caprica's.

Mutagen is GPL-3.0-only and Caprica is MIT; their tool binaries are not bundled. Choose a project license before public distribution.

0.4.1 derives the Vendor bit from the record schema (0x4000) and checks the three reported Whiterun vendors plus Orgnar against the obsolete 0x1000 failure. The baseline fixtures now preserve all 0.4.0 core records and 33 saved fields/properties.
