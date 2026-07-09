# F · Validate against WeakAuras itself

**What it is:** the strongest "expected vs other" check — not "does the string
decode" (the codec proves that) but "are these the fields **WeakAuras actually
defines**." Done by running the *real* WA 5.21.2 source under a version-matched
Lua interpreter and diffing our blocks against WA's own `default()` schemas.

**Setup (native):**
- **Lua 5.1.5** at `.tools/lua51/lua5.1.exe` (LuaBinaries, gitignored) —
  version-matched to the 3.3.5 client, because WA's source uses 5.1-isms
  (`setfenv`, `unpack`) that break under newer Lua. This replaces the
  Cowork-sandbox `lua5.1` that `wa_lua_verify` originally used.
- **[wa_lua_verify/](wa_lua_verify/)** harnesses stub the WA environment
  (permissive autoviv metatables; `LibStub("Masque", true)` → absent so its block
  skips) and capture `RegisterRegionType` / `RegisterSubRegionType`'s `default`
  table. `harness_regiontype.lua` (regions) + `harness.lua` (subregions).
- **[wa_validate.py](wa_validate.py)** runs both harnesses over every WA region/
  subregion file, collects the `default()` field sets, and diffs our `blocks.db`
  blocks against them: a field WE have that WA doesn't = suspect; a WA field we
  never use = coverage.

**What it found:** the library is WA-conformant. 66 of 67 initial "unknowns" were
legitimate WA layers (RegionPrototype base props, WA-added storage fields like
`preferToUpdate`/`displayIcon`, dynamic `text_text_format_*`) — allowlisted,
leaving **1** to inspect (`subtext.text_anchorXOffset`, a real WA offset field
not in the static default — benign). Bonus: WA's source independently confirms
`subbackground`/`subforeground` have **empty** defaults, matching the corpus.

**Scope / next:** validates **region + subregion** fields. **Triggers** register
via a different path (`Prototypes.lua`) — a harness for those is open thread #6.
Beyond field-conformance sits **import acceptance** (driving WA's real `Import`),
a deeper level not yet built.

See [CHAIN.md](CHAIN.md). Needs the game client (memory `game-client-install-path`).
