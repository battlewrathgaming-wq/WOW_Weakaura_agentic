# 3 · Blocks — the parts bin

**Role.** Layer-0 native WeakAuras primitives: known-good **code snippets +
holes**. The atoms slices are assembled from. WA's own ontology — `region` /
`trigger` / `condition` / `subregion` / `load` — not our meaning ("backing plate"
is a slice, i.e. Layer-1, not a block).

**In:** decomposed from real auras (invariant vs holes derived by diffing every
instance) and validated against WA's own `default()` schema.
**Out:** `blocks.db` — `block(block_id, kind, code_template, holes)`.

**Owned by:** WeakAuras (its native structure); we *index* it, we don't invent it.

**Consumed by:** the assembler (resolves slice → blocks → snippets to fill).

**Status:** BUILT. See `../BLOCK_SYSTEM.md`, `../blocks_db.py`, `../wa_validate.py`.
