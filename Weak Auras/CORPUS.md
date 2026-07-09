# B · The corpus (read the intent)

**What it is:** the mechanism for reading Battlewrath's live auras as **design
intent** — the channel that closed the project-vs-live lag. Live captures are
NOT authority (hand-placed in ~0.5px mouse increments); they show *trends* the
geometry pipeline then formalizes precisely.

**The chain:**
- `WeakAuras.lua` (account SavedVariables — see memory `game-client-install-path`)
- → [lua_table.py](lua_table.py) — dependency-free parser for the SavedVariables
  Lua subset (plain data, no code). Matches the codec's dict shape.
- → [aura_scrape.py](aura_scrape.py) — normalize every display into the codec's
  shape + **self-validate**: (A) codec round-trip 59/59, (B) shared-field cross-
  check against committed import strings. Writes `Outputs/aura_corpus/battlewrath_displays.json`.
- → [mask_trends.py](mask_trends.py) — cluster leaf positions into **gravity
  wells** (a slot's magnetic centre + the drag-error spread). Writes `gravity_wells.json`.

**What it feeds:** the wells **validate** the mask's computed anchors (strand A) —
resources confirm as 3-class wells; rotation/power show small group-drift, flagged
not overridden. The corpus also feeds the block system (strand E) and is the
**training source** for BOM mining (with wago.io as the far larger future set).

**Key facts confirmed while proving the parser:** WA stores `auraspellids` as a
STRING (sometimes trailing-space `"800034 "`); empty Lua tables are `[]`≡`{}`;
SavedVariables numbers round to ~14 sig-figs (slightly less precise than import
strings). Read-only — never writes the game files.

See [CHAIN.md](CHAIN.md).
