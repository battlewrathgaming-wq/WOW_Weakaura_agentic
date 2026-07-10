# D · The assembler (reconstruct & ship)

**What it is:** the recompose half of the block system. We could always
decompose an aura into blocks; [assembler.py](assembler.py) is the first time we
rebuild one and emit a real import string. An aura is **derived, not stored**.

**The model — header + blocks + joins:**
- **manifest** = a `header` (envelope: id, minted uid, regionType, position,
  config) + ordered **blocks** (`{block-ID, fills}` for region/triggers/subregions)
  + **joins** (conditions, trigger meta).
- **resolve**: each block-ID → its `code_template` from `blocks.db` (strand E),
  then `invariant | fills` reconstructs the block. Type in the library, instance
  in the fills, bound here.
- **mint**: each pulled block gets a run-unique `uid` (WA's mechanism); the stable
  block-ID is *our* addressing, the uid is WA's per-instance identity.
- **joins / index allocation**: `triggers[1..n]` indices, `disjunctive`,
  `activeTriggerMode`, and condition→subregion index wiring — this is the joining
  layer that replaces the old hand-glued "fragments hardcode trigger 2."
- → `weakaura_codec.encode_import_string` → the string.

**Proven** (over all 59 live auras):
- **A · block losslessness 238/238** — `invariant | fills == original`, exactly.
- **B · whole-aura round-trip 59/59** — decompose → assemble → identical.
- **C · ship** — assemble → encode → decode round-trips.

**Honest caveat:** the round-trip *carries* joins (conditions, trigger-meta) from
the source aura, so it proves **reconstruction** (lossless blocks + valid output),
not **generation**. Building a *new* aura from a pattern still needs the generative
joining layer to *allocate* indices and *wire* conditions itself.

## Generative joining — the spec

Established from a single hand-built reference aura (`Full stack strip test`, a
4-level ablation that peels one *slice* at a time). **Not yet implemented** in
`assembler.py` (which still only reconstructs); this is the spec for the
generative half.

A **slice** = a trigger + an optional subRegion + the condition that wires them
(the dependency unit — pull one and you pull all three). To add a slice:

1. **append the trigger** at the next free index `N` (`triggers[N]`);
2. **append the subRegion** (if any) at the next free index `M`;
3. **emit the condition** `{ check.trigger = N, changes.property = P }`, where
   `P` is `"sub.M.<prop>"` for a subRegion-targeting effect (e.g. `sub.3.glow`,
   `sub.4.textureVisible`) or a **bare region-level** property (e.g. `desaturate`)
   when it targets no subRegion.

Indices are allocated **sequentially** (next free), so generation only ever
appends — no renumbering. `disjunctive: any` and `activeTriggerMode: -10` were
constant across all four levels, single-trigger included.

**Evidence base — n = 1.** One clean ablation established this; it's surgical and
consistent, but single-source. Not yet exercised against: a condition with
multiple `changes`, other trigger→subRegion coupling forms, or mid-stack
renumbering (the top-down peel avoided it, and append-only generation never needs
it). Treat as *established by reference, extend as more references are built*.

**Method:** the reference aura **is** the authored spec — we establish joins (and
later, pattern templates) by hand-built ablation, not inference. Reusable move.

## The division of labour — lanes, and what WA does for us

An aura is a set of **parallel lanes**: `triggers[]`, `conditions[]`,
`subRegions[]`. A **slice is a vertical cut across them** — one logical feature
whose trigger, condition, and subregion live in *different lanes* and *point at
each other by index*. So the assembler's real job is **distribute + pair**: drop
each of a slice's blocks into *its* lane at the next free index, then emit the
condition that pins them together (`check.trigger=N`, `changes=sub.M.<prop>`).

Three parts, cleanly split:
- **Author** (human): define slices as *logical display operators* — "flash on
  proc", "dim when unaffordable". The always-task. A slice = which blocks, in
  which lanes, pointed which way, + its fills.
- **Assemble** (this file, dumb): distribute + pair + allocate indices.
- **Canonicalize** (WA's own engine, harnessed): `Modernize` runs **headless**
  under our Lua 5.1 (`WA_VALIDATION.md` — probe migrated a real aura v10→86
  clean). So the assembler need only emit a *reasonable* table; WA's authoritative
  logic brings it to canonical current-version form. We do **not** reimplement
  WA's canonical shape. (`WeakAuras.Add`, which creates live frames, stays
  in-game; only the data-normalization half is harnessable.)

See [BLOCK_SYSTEM.md](BLOCK_SYSTEM.md) for the library it stands on,
[WA_VALIDATION.md](WA_VALIDATION.md) for the harness, [CHAIN.md](CHAIN.md).
