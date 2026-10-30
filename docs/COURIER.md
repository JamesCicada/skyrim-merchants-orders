# Courier delivery design

A paid order snapshots item, quantity, unit price, total paid, due time, delivery method, and fee. Existing orders default to pickup when the new delivery fields are introduced.

States:
- 1: sourcing pending
- 2: ready at merchant / dispatch retry available
- 5: courier dispatched
- 3: entitlement reserved for inventory grant
- 4: completed

At maturity, courier dispatch changes 2 to 5 before native calls. A single persistent receipt reference is created and stored, then passed to the vanilla WICourierScript.AddRefToContainer. The source game API was verified locally; the script implementation is never packaged.

The receipt's OnContainerChanged passes Self to the manager when its new container is the player. The manager checks state 5, courier method, and exact reference identity before reserving state 3 and granting goods. It then completes the order. The receipt consumes itself whether accepted or superseded.

An old receipt cannot grant a new order. A copied base receipt has different reference identity. Pickup recovery revalidates after its confirmation, invalidates the stored receipt before refund calls, zeros the fee, and completes ordinary pickup once.

Sourcing time is not courier travel time. The vanilla quest decides when to find the player. No vanilla courier/dialogue records are overridden.

If the merchant has spent/restocked away the delivery fee, recovery still honors the promised refund; available shop gold is transferred first and the missing amount is supplied by the service. The fee is invalidated before inventory calls so the refund is one-time.

These guards reduce duplicate/replay paths but do not make Papyrus inventory calls engine-atomic. In-game handoff, save/load, and late-receipt-after-recovery tests remain necessary during periodic testing.
