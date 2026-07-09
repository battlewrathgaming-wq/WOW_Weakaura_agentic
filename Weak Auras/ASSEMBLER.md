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
not **generation**. Building a *new* aura from a mined BOM still needs the
generative joining layer to *allocate* indices and *wire* conditions itself —
that surfaces when strand C's inventory→manifest (open thread #3) feeds a pattern
rather than a decomposed real aura.

See [BLOCK_SYSTEM.md](BLOCK_SYSTEM.md) for the library it stands on, [CHAIN.md](CHAIN.md).
