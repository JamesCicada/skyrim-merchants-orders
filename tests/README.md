# Compatibility and feature checks

record-layout.json contains every editor ID/local FormID in the released 0.2.1 ESP. It is embedded in PluginBuilder; new builds must preserve those mappings.

Build checks cover:
- Six common-material forms, eleven merchants, vendor chests, voice and manager links.
- Existing record IDs and all original manager properties.
- Quantity/pricing/lead-time message records.
- Receipt-to-manager binding and UI-addon-to-manager binding.
- Itemized delivery quotes and a settings option at each merchant.
- Exact 5%-rounded-up boundaries and all supported subtotals 1-12500.
- PEX compilation plus explicit core/addon archive contents.

Earlier negative checks rejected an IngotGold substitution and a zero sourcing capacity before output.

The UIExtensions author code shows row ID in GetResultInt and callback in GetResultFloat; the addon uses the latter to avoid the header-row offset.

These checks do not execute Skyrim. During periodic tests include courier handoff, receipt replay after pickup recovery, changed settings with an already paid order, and core-only operation without UI dependencies.
