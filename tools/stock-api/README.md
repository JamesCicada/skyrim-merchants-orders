# Compile-only stock interfaces

Authored subsets of the SKSE APIs, verified against the installed SKSE source declarations and the SKSE team's public repository. These files are never shipped as replacement game scripts.

The build copies the existing authored core interfaces into an ignored merged import folder, appends each .additions file to its corresponding class, and adds these SKSE-only classes. Only addon scripts compile against the merged folder. Core scripts never call these SKSE methods.
