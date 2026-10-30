# Vanilla trade voice integration

The order topic shares response data from Skyrim.esm, retaining its native subtitles, voice, and lip-sync lookup. No audio is extracted or bundled.

Belethor has three random variants:
- 000A963D: Trinkets, odds and ends, that sort of thing.
- 000A963E: Some may call this junk. Me, I call them treasures.
- 0007F6BC: Take a look.

The ten added merchants use 0007F6BC in their own voices. The installed English archive contains this recording for MaleSlyCynical, FemaleCommander, MaleBrute, FemaleEvenToned, MaleNord, MaleCondescending, FemaleNord, and FemaleOrc.

## UI handoff in 0.2.1

Each INFO's OnBegin fragment calls MO_OrderManager.QueueMenu and returns immediately. OnUpdate checks ObjectReference.IsInDialogueWithPlayer as well as Utility.IsInMenuMode before opening the UI. Dialogue does not itself count as Utility menu mode.

Do not run a latent order menu directly inside the dialogue fragment. Do not depend on OnEnd for the only menu request: 0.2.0 had a user report of voice playing without the menu reopening.

The request waits in bounded 0.5-second updates and cancels with a notification after 60 occupied checks. The guard recovery never changes the stored order or unlocks collection-in-progress.

Only response data is shared. Original service fragments are not copied, and the original OfferServicesTopic is not called through Say. This prevents the native barter fragment from opening inventory.

The first three INFOs retain their IDs. Each added merchant is explicitly conditioned on its NPC and sits outside Belethor's random group. Random selection can repeat lines. This remains opening chatter, not spoken order-specific prices or deadlines.
