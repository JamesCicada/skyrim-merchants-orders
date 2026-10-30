# Development status

## Author smoke test - 30 October 2026

The author reports that the current 0.3.0 version works in game. Couriers can sometimes arrive late; this is accepted behavior and is documented as delay beyond the sourcing estimate.

This supersedes earlier "not observed" status for the release as a whole. It is not a claim that every merchant, setting, UI path, refund/replay case, save migration, or runtime was separately tested.


## 0.3.0 delivery, settings, and optional UI

Implemented:
- Quantities 1-500 and saved defaults.
- Lead-time multiplier 0.25x-4x for new orders.
- Free pickup or courier for ceil(subtotal / 20) gold extra.
- Unique receipt dispatched through WICourierScript.AddRefToContainer.
- Materials released only when the stored receipt reaches the player.
- Dispatch reserves state 5 before native form lookups; delivery consumes entitlement before AddItem.
- Pickup recovery invalidates an outstanding receipt and refunds the delivery fee once.
- Core settings menus; optional UIExtensions lists/numeric entry and SkyUI MCM in a separate addon.
- Complete core/UI dependency separation.

Verified:
- Seven authored scripts compile (five core, two addon).
- Both plugins reopen successfully and link to the existing order manager.
- All 0.2.1 record IDs are preserved.
- Fee rounding passes 0/1/19/20/21/600/12500 boundary cases and all subtotals 1-12500.
- Core quote records show materials, fee, total, and sourcing time.
- UIExtensions' callback channel was verified against the author's ActionScript.
- Vanilla courier API and generic handoff were inspected from local game data.
- Core/UI archive allowlists contain 13/7 intended nonempty files.

Initial build-time status was untested in game. See the subsequent author smoke-test report above for the current release status; detailed feature-by-feature coverage remains unspecified.

No new game files or dependencies have been installed automatically.
## 0.2.1 menu reopening hotfix

Reported: after placing an order, selecting the order topic plays voice but no longer opens the menu.

Investigation found two possible failure paths: reliance on OnEnd for the UI handoff and a persistent menu guard that silently drops subsequent requests. No Papyrus log was available to identify the exact runtime path.

Changed:
- OnBegin queues the request and returns; OnUpdate waits for dialogue and paused menus to close.
- Queue polling is bounded to 60 checks, with notifications on timeout or missing bindings.
- Informational messages release the interaction guard.
- A fresh dialogue can recover an old post-payment guard only after dialogue/menus close and only in pending/ready/completed states. Collection-in-progress is not unlocked.
- Existing paid-order fields remain unchanged; all released 0.2.0 record IDs are preserved.

Verified: three script compiles, binary fragment wiring, complete record-ID baseline, material/vendor bindings, and package checks. The original runtime report has not yet been retested.
## 0.2.0 material catalogs

Implemented:
- Six approved common materials and eleven merchants in the five major cities.
- Separate blacksmith/general catalogs, item-specific prices and sourcing capacities.
- Merchant and item selection menus generated from catalogs/materials.json.
- Generated vanilla-only MO_Catalog runtime tables; no new persistent quest properties.
- Status names the item and pickup merchant; wrong-merchant collection is rejected.
- Vendor payment destinations resolved per shop; Adrianne and Ulfberth share a chest.
- Added merchants reuse a vanilla trade line recorded for their voice types.

Verified outside the game:
- All three scripts compile.
- ESP readback checks all merchant eligibility and script links, catalog menu counts, exact prices/times, and only six approved forms.
- Every released 0.1.2 record ID is preserved.
- Rare-material substitution (IngotGold) and zero sourcing capacity are rejected without output.
- The local English archive contains the shared trade line for every selected voice type.
- ZIP contains only nine intended nonempty files.

Expanded gameplay and upgrade behavior remain for periodic in-game testing. Do not require the user to test every small iteration.
## 0.1.2 prototype

Implemented:
- Three random voiced trade responses before opening the order menu.
- ResponseData links reuse original Skyrim.esm INFO records 000A963D, 000A963E, and 0007F6BC.
- The order menu runs from OnEnd, after the response completes.
- Vanilla voice/lip-sync lookup stays intact; no source audio is bundled and no original barter scripts are copied.

Build verification passed for compilation, shared response links, random group flags, end-fragment wiring, preserved original form IDs, gameplay/menu bindings, and ZIP packaging. The local English voice archive contains all three responses for MaleSlyCynical. Playback has not yet been observed in game.

Per the user's preference, continue development and leave in-game checks for periodic testing rather than requiring a test after every small update.
## 0.1.1 prototype

Implemented:
- Quantity-dependent sourcing: 15 ingots per game day, rounded up.
- 10/25/50 ingots take 1/2/4 game days.
- Selected timing appears in quantity, confirmation, acceptance, and pending-status menus.
- Player gold is transferred in one RemoveItem call to Belethor's vendor chest rather than destroyed.
- The vanilla chest reference is verified against the installed master by the builder.
- Existing stored due dates and script field/property layout remain intact.

Verified outside the game:
- Both scripts compile for Skyrim with Caprica 0.3.0 using minimal vanilla native interfaces.
- ESP binary readback validates dependencies, record counts, property bindings, dialogue, menus, quoted times, and SEQ.
- Every record ID from the released 0.1.0 ESP is preserved.
- ZIP packaging checks the seven intended nonempty files.

Still pending in game:
- 1/2/4-day boundaries and save/load behavior for new orders.
- Matching player debit/vendor balance credit.
- Cancellation, insufficient funds, duplicate collection, and old-save upgrade checks.

## 0.1.0 user smoke test

The user reported placing an order, waiting two in-game days, and collecting the correct Iron Ingots. This confirms that basic flow on their setup. It does not establish duplicate-collection safety or full compatibility.

No update files have been automatically installed into the game.
