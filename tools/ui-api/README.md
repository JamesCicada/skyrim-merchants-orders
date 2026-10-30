# Compile-only dependency interfaces

These authored declarations describe the subset of UIExtensions, SkyUI, and SKSE used by the optional UI addon. They are never compiled as output or distributed in either ZIP.

Verified against author-maintained sources:
- https://github.com/expired6978/skyui/tree/master/uiextensions_dist/Data/Scripts/Source
- https://github.com/schlangster/skyui/blob/master/dist/Data/Scripts/Source/SKI_ConfigBase.psc
- Local SKSE StringUtil source declarations

The core package imports no UIExtensions/SkyUI/SKSE interface. UI dependency references exist only in the addon scripts and plugin.
