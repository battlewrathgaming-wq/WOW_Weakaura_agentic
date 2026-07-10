# 1 · Mask — the spatial authority (WHERE)

**Role.** Defines every slot as a **family**: a spatial budget with a computed
anchor and a composition rule. Class-agnostic. Answers "where can things go, and
how much room." The single source of truth for position — live captures only
validate it, never define it.

**In:** geometry primitives + declared relationships (column grid, bands ±125/
±185, plateau).
**Out:** `masks/Central_hud.mask.json` — families: `anchor`, `budget {w,h}`,
`composition (single | subdivide)`, `provenance (live | design)`.

**Owned by:** computed geometry (`geometry.py` → `mask_build.py`), human-tunable
by editing the relational primitives (change one, the matrix recomputes).

**Consumed by:** the class inventory (slots to fill) and `mask_validate.py`.

**Status:** BUILT. See `../MASK.md`, `../mask_build.py`.
