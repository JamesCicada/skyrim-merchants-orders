# Building Merchant Orders

Requires .NET SDK 8+, Caprica 0.3.0, and a local Skyrim.esm. Mutagen.Bethesda.Skyrim 0.53.1 is pinned.

    .\build.ps1 -SkyrimData 'D:\Games\Skyrim Anniversary Edition\Data'

Caprica upstream: https://github.com/Orvid/Caprica/releases/tag/v0.3.0
Extract it to .tools/caprica/ or pass -Compiler.

## Outputs

- dist/MerchantOrders-0.3.0-prototype.zip: dependency-free core, 13 files.
- dist/MerchantOrders-UI-0.3.0.zip: optional UI addon, 7 files.

The build does not deploy files, change plugins lists, or edit saves.

## Pipeline

Read catalogs/materials.json and resolve six materials, eleven merchants, their references, voices, and vendor chests from Skyrim.esm. Reject rare-form substitutions or invalid configuration.

Generate the core ESP/SEQ and MO_Catalog.psc. Original record allocations happen first; all released 0.2.1 IDs are checked against tests/record-layout.json. Add feature records only afterward.

OrderFeatures adds settings/delivery messages and a scripted receipt Book. Its receipt property points to the existing order manager. WICourier is verified from the master; its AddRefToContainer(ObjectReference) API was verified by inspecting the installed vanilla bytecode locally. No decompiled vanilla script or game asset is distributed.

Generate a separate MerchantOrders-UI.esp with a start-game-enabled quest holding the UI bridge and MCM scripts. It links to the core manager; core records are not overridden. Both plugins are reopened and checked.

Compile five core scripts using only tools/api and Source/Scripts. Compile two addon scripts separately with tools/ui-api and Source/UI. Only the addon sees UIExtensions, SkyUI, and SKSE interfaces. Core's MO_UIBridge is an authored vanilla-only contract.

Package exact file allowlists. Dependency implementations, interfaces, tools, game assets, and external audio are excluded. Core PEX headers/game IDs and package entry counts are checked.

## Configuration

materials.json defines allowed material prices/capacity and merchant specialties. Its quantityChoices array retains the legacy 10/25/50 quote menus for record compatibility; current quantity entry accepts 1-500 and runtime settings are saved on the quest.

New orders use the saved lead-time multiplier. Accepted orders store the due day; changing settings does not change that deadline. Fee calculation is ceil(subtotal / 20), equivalent to 5% rounded up.

MO_Catalog.psc is generated on every build. Do not edit it by hand.

## Compile-only APIs

tools/api contains authored vanilla interfaces. WICourierScript is an interface only, never a replacement to install. tools/ui-api contains authored subsets of author-maintained dependency APIs. Nothing in either folder is compiled as shipped output.

For a second compile against complete CK sources:

    .\build.ps1 -SkyrimData 'PATH_TO_DATA' -VanillaSources 'PATH_TO_COMPLETE_CK_SOURCES' -FlagsFile 'PATH_TO_TESV_FLAGS'

The compiler option expects Caprica CLI syntax.

## Validation limits

Build checks verify form links, menus, amount/fee fields, merchant restrictions, record-ID compatibility, and fee rounding across every supported subtotal. They do not run Skyrim's courier, inventory, MCM, or UI events.

The author reported the current 0.3.0 version working in game on 30 October 2026, with occasional courier delays. This is a general smoke-test report rather than an exhaustive per-feature or cross-runtime test matrix.

Mutagen is GPL-3.0-only; Caprica is MIT. Tool binaries are not bundled. Choose a project license before public distribution.
