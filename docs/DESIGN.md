# Design

These are proposed implementation defaults, not claims about existing game behavior.

## Player loop

Ask a supported merchant to place an order, choose an item and quantity, review the total and lead time, confirm payment, then return to that merchant to collect. Show the quoted total before removing gold. Recheck funds, catalog limits, and capacity at confirmation.

Version 1 uses merchant pickup only. The order record is authoritative; a receipt is an optional reminder, never an entitlement to goods.

## Scope and progression

First milestone: Belethor, Iron Ingots, quantities of 10/25/50, one outstanding order, quantity-dependent lead time (10/25/50 ingots take 1/2/4 game days), fixed illustrative price of 12 gold per ingot. Use an explicit confirmation step.

Full v1 target: curated common materials from blacksmiths and general merchants in the five major cities. Begin with no filled soul gems, enchanted equipment, unique items, or rare crafting materials. Add those only after a separate balance decision.

Suggested full-v1 defaults:
- Three outstanding orders across all merchants; no more than one per merchant.
- One item type per order, with fixed quantity choices.
- One to four in-game days of lead time, configured per catalog entry.
- Fixed per-unit catalog prices, with no Speech discounts initially.
- A per-merchant reorder delay after collection, so splitting orders cannot bypass supply limits.
- No cancellation or refunds in the initial slice; make this clear before confirmation.

Limits, timing, and prices need playtesting. Convenience should cost gold and time, and should not grant early access to progression-gated materials.

## Order lifecycle

Empty -> Pending -> Ready -> Collecting -> Completed

Persist merchant identity, item form, quantity, unit price, total paid, placement game day, due game day, and state. Snapshot the quote so later catalog edits cannot change a paid order.

Pending becomes Ready when the current game day is at least the due game day. Recheck on interaction as well as a scheduled game-time update. Waiting, sleeping, fast travel, and loading a save must all produce the same outcome.

Ready orders remain available until collected. Check the speaking merchant against the stored merchant before offering collection.

Collection must reject repeated activation. Set a transaction guard before adding items, complete synchronously without waits or menus between the grant and final state update, and then release the guard. Test this in game; the state model alone does not prove duplication safety.

Do not silently discard pending orders when a merchant is unavailable. Define a recovery path before expanding to merchants that can die; a future recovery menu may refund the stored amount exactly once.

## UI

Use vanilla dialogue and confirmation Message records for the first slice. Offer quantity buttons, a quote/confirmation, and a status response showing merchant, item, quantity, and remaining time. Never accept an order if the player cannot inspect the exact charge.

A multi-item cart, custom Scaleform menu, MCM tracking, receipts with dynamic text, and translated/voiced dialogue are later decisions. MCM configuration should not be required to use the core loop.

## Compatibility and distribution

Prefer additive records. Keep merchant eligibility explicit and avoid editing merchant inventory containers or replacing existing merchant scripts. Verify dialogue conflicts in the eventual plugin.

Catalogs must reference actual item forms through editor properties. Do not embed guessed numeric FormIDs. The prototype vendor-chest lookup uses a verified vanilla reference, checked against the master at build time, to avoid adding an unfilled property to existing saves. Modded items will need explicit integration later; the example JSON is not an SKSE feature.

Record tested game runtime, Creation Kit, masters, and optional dependencies with each release. Do not claim general AE compatibility until tested on the selected runtime.
