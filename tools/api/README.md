# Compile-only vanilla API interfaces

These small declarations are authored for this project's build. They describe only the vanilla native API used by our scripts. They are not Bethesda implementations, are never compiled as output, and must never be installed in the game.

The installed SKSE source folder is incomplete (for example Message.psc is missing). To keep builds reproducible, the compiler imports these minimal interfaces. Runtime implementations come from Skyrim. A successful compile checks syntax/types against these declarations; it does not validate runtime behavior.

Optional full CK source validation is available through build.ps1 -VanillaSources. That mode also needs the CK flags file and all transitive vanilla sources. No SKSE functions are used.

API references: https://ck.uesp.net/wiki/Category:Papyrus and installed vanilla/SKSE declaration signatures. Keep method signatures compatible with the vanilla Skyrim API.
