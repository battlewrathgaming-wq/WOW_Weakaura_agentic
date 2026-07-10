# 6 · WA engine — Modernize (the canonicalizer)

**Role.** Takes the assembler's *reasonable* table and brings it to **WA-valid
canonical form**. This is WeakAuras' own authoritative normalization / version-
migration — we do **not** reimplement it. It's why the assembler can be sloppy:
build something plausible, let WA's engine finish it.

**In:** the assembled data table.
**Out:** a canonical, WA-valid table → `encode_import_string` → the import string.

**Owned by:** WeakAuras (`Modernize`), harnessed **headless** under our Lua 5.1.

**Status:** HARNESSABLE — proven (a real aura forced to `v10` migrated to `v86`
clean, three trivial stubs). Full fidelity for *arbitrary* input still needs
stubbing the few real WA deps some migrations touch. `WeakAuras.Add` (live-load,
creates frames) stays in-game — only the data-normalization half is harnessable.
See `../WA_VALIDATION.md`.
