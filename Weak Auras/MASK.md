# A · The mask (+ C · its validator)

**What it is:** the precise, geometry-aware source of truth for *where every slot
lives*. Not derived from anything upstream — it **is** the authority. Live
captures validate it; they never define it.

**The model — a relational matrix, not frozen numbers.** The whole layout is
computed by [mask_build.py](mask_build.py) from a few declared relationships, so
changing one propagates and shared edges hold *by construction* (asserted in
`_verify()`):
- **column grid** — 6 icons, 40 wide, 2px gap → `±21/±63/±105` (scheme A, all integers).
- **inner band ±125** — the icon rows' outer edge; the resource bars share it.
- **outer band ±185** — accents + buffs/utility share it.
- **plateau `P`** — the central divider's width; widening it pushes the resource
  columns out `P/2` each (whole-number `P`, so `P/2` stays on the 0.5 grid) —
  the non-rectangular "central plateau." `P=2` = flush.
- **size-by-throughput** — rotation 40×30 (tall, constant attention), power/proc
  40×20, buffs/utility 30×20 (tucked). Resource bars 124×15.

**Families = budget + composition.** Each family is a spatial **budget** with a
computed anchor. `composition ∈ single | subdivide` says how a class may fill it
(Reaper tiles the 124-wide primary budget where Necro/Bloodmage use one bar).
The **backing-plate** footprint mechanism is an inventory/strata concern, NOT a
composition. `provenance ∈ live` (a gravity well confirms it) `| design` (computed,
unbuilt).

**Files:** [geometry.py](geometry.py) (row/mirror/stack primitives) →
[mask_build.py](mask_build.py) (the matrix) → [masks/Central_hud.mask.json](masks/Central_hud.mask.json).

**C · validator:** [mask_validate.py](mask_validate.py) checks a class's
`inventory.py` against `mask.json` + the capability REGISTRY — region/budget/
position/spell-id — as HARD/WARN/INFO. (It currently flags the live resources as
"pending re-import to scheme A" — expected until open-thread #1 lands.)

See [CHAIN.md](CHAIN.md). Related: `Template_shadow.py` is the discarded v1 draft
this replaced; `ELEMENT_INVENTORY.md` is the stale prose mask, to be regenerated
*from* `mask.json`.
