# decisions — the creator work's trail

_Fast, local decisions as the creative work happens — the call + a one-line why. Append over time._
_Neighbours: forward-looking direction → `operations/roadmap.md` · solidified fact → `creator/provenance.md` ·
fixed touchstones → `operations/WHAT.md` / `HOW.md` · moving present → `operations/STATE.md`._

## 2026-07-14 — the classification tool

- **It's a signal platform, not ML.** Multi-signal → entity → graph → centrality → route. Research showed our
  sub-problems are already solved (graph centrality, link analysis); the ML / feature-store path is overkill. Stack:
  `networkx` + `pyvis`, **no graph DB** (9,152 nodes is small). → `creator/planning/research.md`
- **Traffic = graph centrality** (in-degree / pagerank). Validated on our data: the high-centrality hubs ARE the class
  mechanics (Reaper's souls surfaced from raw connectivity). PageRank refines — it down-weights busy-but-peripheral nodes.
- **Slice per CLASS:SPEC, not the total pool.** A class plays differently per spec; auras load per class:spec; the
  mechanic is really a *spec's* hub. Slicing revealed what the pool hid — Necromancer's minions in the Animation spec.
- **The web's SHAPE triages.** A dense proc hub (high in-degree) = flat/drivable; a summon hub (low in-degree, fans out)
  = custom/state. Bucket + triage from geometry, no per-class insight required.
- **Data local to creator, per class:spec tables** (`build_tables.py`) + a **keyword taxonomy** (`taxonomy.py`) — the
  vocabulary mounted for visibility. The creator works from these, not the global pool.
- **Provenance: `coa_spells.json` is a MERGE, not an authority.** Verified audit: effect slots faithful, but
  `effectClassMask` (+ `desc`, conditions) flattened. Decision: **heal at the source** — extend `filter_coa_spells.py`
  to carry `effectClassMask` [pending the go, since everything reads `coa_spells.json`]. → `creator/provenance.md`
- **The DBC resolver, right-sized:** edge-and-attribute effects (trigger · modify-cooldown `165` · apply-aura/buff ·
  resource-gen), **not** full spell simulation. Sourced from the authority; honest gaps (`custom_<n>`) — same discipline
  as the sheets.
