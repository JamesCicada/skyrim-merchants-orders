# Implementation plan

Current implementation: 0.2.0 adds six materials and eleven merchants. See STATUS.md and INSTALL.md for the shipped prototype behavior; the sections below retain the original milestone plan.

## 1. Establish the build environment

Record the installed Skyrim runtime, Creation Kit/compiler locations, available Papyrus sources, and mod-manager test profile. Inspect installed dependencies before choosing APIs. Build generated PEX files outside the tracked source tree.

The 0.1.0 prototype now has generated ESP/SEQ and compiled PEX output. Compilation and binary checks pass; in-game validation remains pending. See STATUS.md and BUILD.md. The plugin uses a standard ESP; ESL flagging remains deferred.

## 2. Build the smallest complete slice

Proposed records (names may change):
- MO_OrderQuest: persistent quest owning the order manager and stored order data.
- MO_MerchantOrdersBranch: merchant dialogue with eligibility limited to Belethor initially.
- MO_ChooseIronQuantity and MO_ConfirmOrder: Message records for quantity and confirmation.
- MO_IronCatalog: catalog data configured through quest/script properties.
- Dialogue fragments that call the manager for quote, purchase, status, and collection.

Proposed source responsibilities:
- MO_OrderManager.psc: validation, gold charge, stored order, readiness, and collection.
- MO_MerchantCatalog.psc: item/quantity/price/lead-time data and validation.
- Small dialogue fragments: delegate to the manager, without duplicating transaction logic.

Use editor-linked gold/item/merchant properties. Reject missing properties, invalid quantities, nonpositive prices or lead times, and occupied order slots before charging. Revalidate the quote at confirmation. Avoid latent calls while charging or delivering.

Do not remove gold until an order slot is reserved and all inputs are valid. The purchase path must leave either a paid pending order or an unchanged player balance. Verify the actual engine behavior during implementation.

Track due time as an absolute in-game day. Use one pending-order scheduler, with interaction-time checks as the correctness fallback. Do not poll every real-time frame.

## 3. Manual acceptance checks for the slice

Use a disposable test save and record observed results:

| Scenario | Required result |
| --- | --- |
| Decline confirmation | No gold removed; no order created |
| Insufficient gold, including a balance change before confirmation | No order and no charge |
| Missing catalog property or invalid quantity | Clear rejection before payment |
| Confirm with exact funds | Exact charge and one pending order |
| Attempt a second purchase | Rejected without charge |
| Collect before due time | No items granted |
| Wait/sleep past due time | Order becomes ready |
| Fast travel across due time | Order is ready on interaction |
| Save and reload pending/ready order | State and price remain intact |
| Collect a ready order | Exact quantity, once |
| Repeat/rapidly activate collection | No duplicate items |
| Speak to a different merchant | Cannot collect the order |
| Spend gold after placing order | Paid order remains collectible |
| Change catalog after payment | Existing order keeps its stored terms |

Also check vanilla trading and normal merchant dialogue still function. Test timer boundary cases immediately before and after the due time. Do not mark the milestone complete until compiled scripts and a plugin pass these checks in game.

## 4. Expand only after the slice passes

Add merchant selection, fixed-size order storage, catalog specialties, per-merchant limits, and a global status interface. Resolve merchant death/unavailability recovery before this expansion ships.

Keep existing-save migrations explicit. Do not rename/remove persistent properties or change storage layout without testing a migration from a prior release.

## 5. Package

Include the plugin, compiled scripts, source scripts where appropriate, README/install instructions, license selected by the owner, and changelog. Confirm dependencies, clean installation, upgrade behavior, and rollback on the test profile. Removing a scripted mod from an active save requires separate guidance based on testing; do not promise safe uninstall.
