# Merchant Orders enhanced UI 0.3.0

Requires the matching Merchant Orders core, SKSE matching your game runtime, SkyUI SE, and UIExtensions SE.

Dependency pages:
- https://skse.silverlock.org/
- https://www.nexusmods.com/skyrimspecialedition/mods/12604
- https://www.nexusmods.com/skyrimspecialedition/mods/17561

Install dependencies through MO2/Vortex, then the core ZIP and MerchantOrders-UI-0.3.0.zip. Enable MerchantOrders.esp before MerchantOrders-UI.esp and launch through SKSE. The addon ESP depends on the core. No third-party files are bundled.

Adds:
- Scrollable order-action, material, delivery, and settings lists.
- Direct quantity entry, validated as a whole number from 1 to 500.
- A Merchant Orders MCM with default-quantity and lead-time sliders.

The first list row is Back; Escape cancels. The quantity input starts with your default quantity. The final quote remains a native confirmation box showing materials, 5% delivery fee if chosen, total, and sourcing time.

MCM appears through SkyUI's normal registration process. Its lead-time slider ranges from 0.25x to 4x in quarter steps. Paid orders are never recalculated.

Without this addon, core quantity/settings menus work using vanilla message boxes. Core scripts import no UIExtensions/SkyUI/SKSE API; integration scripts are isolated in this addon. Do not install it without dependencies.

Implementation follows the author-maintained UIExtensions and SkyUI scripting APIs. UIExtensions list selection uses the callback result, rather than its header-offset row ID, to avoid selecting the wrong action.

The author reports the current version working in game as of 30 October 2026. All addon scripts compile and plugin/package checks pass. A separate exhaustive UI/runtime compatibility matrix has not been established.
