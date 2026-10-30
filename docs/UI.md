# Enhanced UI and dynamic catalogs - 0.4.1 development build

Install the matching 0.4.1 core plus this addon. Dependencies:
- SKSE matching your runtime: https://skse.silverlock.org/
- SkyUI SE: https://www.nexusmods.com/skyrimspecialedition/mods/12604
- UIExtensions SE: https://www.nexusmods.com/skyrimspecialedition/mods/17561

Enable MerchantOrders.esp before MerchantOrders-UI.esp and launch through SKSE.

The addon now includes three scripts: MO_UiExtensionsBridge, MO_Config, and MO_DynamicStock. Deploy all three with the matching ESP/SEQ.

Features:
- Stock-driven common-material and food catalogs.
- More merchants/innkeepers discovered through standard vendor factions and chests.
- Scrollable item/action menus, direct quantity entry, and itemized dynamic quotes.
- MCM sliders for quantity and waiting defaults.

The initial stock quest enables dynamic dialogue after startup. The original UI quest stays at local ID 800; the new stock quest is 801 and both are included in the SEQ.

The top list row returns Back, and Escape cancels. In a dynamic quote, informational rows cannot charge gold; only Pay and confirm accepts the order.

Core-only mode keeps the previous fixed catalogs and basic menus. Extra materials need an explicit MO_CommonMaterials patch to avoid introducing rare goods. Mod-added ordinary food can qualify by its food flag, subject to the stock and exclusion rules.

Stock changes after restocking. Sold-out food can disappear, and uninitialized chests may need one normal trade interaction before ordering. A scan is limited to 120 eligible entries from up to 2,048 forms.

No dependencies or game assets are bundled. All nine authored scripts compile; dynamic-mode gameplay is not yet tested. See docs/DYNAMIC_CATALOGS.md in the repository for full policy and upgrade details.
