# Block system — Layer-0 primitives → BOM patterns → assembly

The fix for the chaotic template catalog (18 tangled Layer-1 monoliths + 6 ad-hoc
fragments). An aura is a **stack of ID'd native blocks**; meaning is the stack's
shape (a **BOM**); the assembler addresses blocks by ID and allocates WA's own
indices (`triggers[1/2]`, condition order) — that allocation is the joining
layer, so no block hardcodes an index.

## Two layers
- **Layer 0 — native blocks.** WeakAuras' OWN ontology, not our meaning.
  `region · trigger · condition · subregion · load`. Each block = stable ID +
  known code (parameterized field-set).
- **Layer 1 — meaning = a BOM.** "dot tracker", "backing plate", "proc alert"
  are NAMED, ordered compositions of Layer-0 blocks. NOT primitives.
  ("backing plate is our meaning, not how WeakAuras functions.")

## Sources of truth
- **WA wiki** — https://github.com/WeakAuras/WeakAuras2/wiki — the Layer-0 SPEC
  (what's possible). Pages: *Aura Types* (regions), *Trigger Types* +
  *Triggers/Untriggers* + *TSU*, *Conditions*, *Editing Aura Regions*
  (subregions), *Load*, and *Custom Triggers/Options/Actions/Animation/Anchor*
  + *aura_env* + *Useful Variables and Functions* (the Lua API).
- **The corpus** — `../Outputs/aura_corpus/native_blocks.json` — Layer-0 USAGE
  (what's actually built). 59 personal auras → ~34 blocks (5 region · 12 trigger
  · 6 subregion · 8 condition · 3 load).
- **wago.io** — a potential **training library**: the community's shared auras,
  a far larger corpus to mine BOM patterns from than the personal 59. Not yet
  ingested; `aura_scrape.py`/`lua_table.py`/`weakaura_codec.py` can decode any
  exported string.

## BOM pattern notation (Battlewrath's conjecture, to formalize)
A meaning is an ordered block stack with two operators:

```
base:       dot tracker = [1,2,3,4]        ordered Layer-0 blocks
extension:  + proc       = [1,2,3,4,+5]     APPEND a block/feature -> changes the STACK
variant:    persistent   = 1(a)             a block in a modified mode -> changes a block's FILL
```

Extension = more blocks (a second trigger, a glow condition). Variant = a block's
mode (persistence = keep-open/backing footprint; threshold; exact-spell-id; …).

## Long-term job of the corpus section
MINE BOM patterns: cluster real auras' block-stacks → recurring BOMs = named
Layer-1 meanings, empirically (not invented). Bigger training set (wago.io) →
richer BOM library. Goal: **flatten the reasoning** — ship complicated WAs by
composing known, indexed BOMs, because the primitives are understood, patterned,
and indexed.

## Pipeline (this section)
```
aura_blocks.py  — Layer-0 block inventory (ID + field-shape + usage)          [done]
blocks_db.py    — parts catalog SQLite: block-ID -> code_template + holes,     [done]
                  derived by diffing every instance (invariant = "always the
                  same" code; holes = options/IDs). bom/bom_block ready-empty.
assembler.py    — manifest -> resolve by ID -> mint uid -> fill holes ->       [done, proven]
                  allocate WA indices -> import string. See ASSEMBLER.md.
wa_validate.py  — blocks vs WA's real default() schemas (expected vs other).   [done]
                  See WA_VALIDATION.md.
BOM miner       — cluster corpus/wago stacks -> named patterns.                [next]
```
The library is corpus-agnostic (code snippets + constant IDs only); aura instances
stay in the corpus JSON. See [ASSEMBLER.md](ASSEMBLER.md), [WA_VALIDATION.md](WA_VALIDATION.md),
and [CHAIN.md](CHAIN.md) for the wider pipeline; this is the Layer-0/meaning spine under it.
