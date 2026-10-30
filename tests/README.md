# Compatibility and feature checks

record-layout.json captures all core editor IDs/local FormIDs from the 0.4.0 test-build ESP.
order-field-layout.json captures the names/types of its 33 saved fields/properties.

Both fixtures are embedded in PluginBuilder and checked on each build. The legacy MiscObject item field is preserved while a new Form snapshot supports food and mod-added goods.

StockFeatures also checks:
- A disabled-by-default dynamic global and service/addon-gated generic dialogue.
- No duplicate legacy merchant INFO matches.
- Only the approved common material forms.
- Horker Stew's food flag without keywords.
- Rejection of rare ingots, equipment, and Skooma's misleading VendorItemFood tag.
- Orgnar's vanilla vendor-container availability.

Other checks cover quotes, manager/receipt links, UI addon records, two startup quests in its SEQ, compilation, fee rounding through 100,000 gold, and 15/9 packaged files.

These checks do not run the game. During periodic testing, include Orgnar food selection, restock changes, vendor payments, food pickup/courier grants, an existing paid 0.3.0 order, and cancel/detail rows in dynamic confirmation.

Vendor regression: Anoriath, Carlotta Valentia, Belethor, and Orgnar each have one active vendor chest under mask 0x4000, and none under the erroneous 0x1000 check. The runtime flag is generated from the schema rather than hardcoded in Papyrus.
