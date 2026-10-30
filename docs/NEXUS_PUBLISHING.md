# Nexus listing details

## Page fields

- **Mod name:** Merchant Orders and Deliveries
- **Version:** 0.3.0
- **Author:** James Cicada
- **Game:** Skyrim Special Edition (developed for Anniversary Edition)
- **Suggested category:** Immersion
- **Release status:** Early release / alpha, author-tested in game
- **Language:** English
- **Source:** https://github.com/JamesCicada/skyrim-merchants-orders
- **Support:** https://ko-fi.com/jcicada

### Short description

Order common crafting materials from 11 city merchants. Choose your quantity and wait time, pay upfront, then collect your goods or pay 5% extra for courier delivery. Optional enhanced menus and SkyUI MCM.

### Full description

Paste NEXUS_DESCRIPTION.bbcode into the page's BBCode/source editor. Preview the result before publishing. It includes the merchant list, material limits, fees, settings, installation, current limitations, credits, and Ko-fi link.

## Files to upload

| Nexus file group | Display name | Local archive |
| --- | --- | --- |
| Main file | Merchant Orders and Deliveries - Core 0.3.0 | dist/MerchantOrders-0.3.0-prototype.zip |
| Optional file | Enhanced UI and MCM - 0.3.0 | dist/MerchantOrders-UI-0.3.0.zip |

**Core file description:** Required main mod. Eleven merchants, six common materials, quantities of 1-500, adjustable sourcing times, free pickup, and 5% courier delivery. Includes basic menus; no SKSE/SkyUI/UIExtensions requirement.

**UI addon file description:** Optional scrollable menus, direct quantity entry, and SkyUI MCM. Requires matching core 0.3.0, SKSE for your runtime, SkyUI SE, and UIExtensions SE. Load MerchantOrders-UI.esp after MerchantOrders.esp.

Do not upload the source repository ZIP, .tools, or build directories as the installable mod.

## Requirement notes

List the external dependencies specifically as **UI addon only**:
- SKSE: https://skse.silverlock.org/
- SkyUI SE: https://www.nexusmods.com/skyrimspecialedition/mods/12604
- UIExtensions SE: https://www.nexusmods.com/skyrimspecialedition/mods/17561

The core only uses Skyrim.esm and vanilla scripts. Do not describe the optional UI requirements as mandatory for the core.

## Changelog text

Initial public 0.3.0 release:
- Order six common materials from eleven city merchants.
- Separate blacksmith and general-merchant catalogs.
- Editable quantities of 1-500 and 0.25x-4x sourcing-time settings.
- Free merchant pickup or 5% courier delivery.
- Order status and courier-to-pickup recovery with delivery-fee refund.
- Vanilla voiced trade responses.
- Optional UIExtensions menus and SkyUI MCM.
- Preserves previous prototype record IDs and stored pickup-order terms.

## Testing statement

On 30 October 2026, the author reported that the current mod works in game and that couriers can sometimes arrive late. Use "author-tested" rather than "fully tested." Do not claim every merchant, runtime, load order, refund edge case, or UI path was separately validated.

The sourcing estimate excludes courier encounter/travel delay. This distinction belongs in the description and FAQ.

## Suggested screenshots

Use real in-game screenshots of:
1. The merchant order dialogue.
2. Material selection and quantity entry.
3. The quote showing the 5% courier fee.
4. The MCM quantity and lead-time settings.
5. An order-status screen naming the merchant.
6. A courier handoff.

No in-game screenshots have been created as part of this publishing preparation.

## Permissions

No project license or Nexus reuse/translation/reupload permissions have been selected yet. Set these according to your preferences during publication; this document does not grant third-party permissions. The repository contains authored source and compile-only interfaces, not Bethesda assets or dependency binaries.

The Ko-fi support paragraph is adapted from the author's BB Tools support information. Donations are optional and are not a requirement to use the mod.

## Publication scope

The source push is authorized. This preparation does not create or publish a Nexus listing, upload archives to Nexus, or publish the Nexus page. Prebuilt archives are also published separately through GitHub Releases at the author's request. The same two mod-manager archives are ready for manual Nexus upload.
