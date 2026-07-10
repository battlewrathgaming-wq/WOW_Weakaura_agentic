# 5 · Assembler — distribute + pair (the dumb picker)

**Role.** Turns an inventory into a data table. For each slot's slice: resolve
**slice → blocks**, drop each block into **its lane** (`triggers[]` /
`conditions[]` / `subRegions[]`) at the **next free index**, fill the holes from
the slot's fills, and **pair** them — emit the condition
`{ check.trigger = N, changes = sub.M.<prop> }` (or a bare region property).
Anchors come from the mask. **Zero reasoning** — a part picker.

**In:** inventory + `blocks.db` + slice definitions + mask anchors.
**Out:** a **reasonable** WA data table — need not be perfectly canonical (WA's
engine finishes it).

**Owned by:** the machine (mechanical, index-allocating).

**Status:** RECONSTRUCTION built and proven (238/238 blocks, 59/59 round-trip,
ships real strings). **GENERATIVE** (distribute + pair from intent) is **spec'd,
not built** — join spec established n=1 from `Full stack strip test`. See
`../ASSEMBLER.md`.
