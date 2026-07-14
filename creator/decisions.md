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
- **Store the AXES (fact), derive the LABELS (view).** The `citizenship` enum (controlled/empowering/offensive/…) was
  never an axis — it was a hand-drawn region in coordinate space, so it kept needing re-cutting and lost the info the
  pairing needed. The data varies on five real fields: **invocation · persistence · target · verb · centrality(hub)**
  (grounded — the cross-tab proved `passive` ≡ `permanent`, and `hub` is a 2.3% *flag* not a partition). Decision:
  resolver Pass 1 stores the axes as coordinates; Pass 2 (`citizenship.py`) derives the native **signal**
  (mechanic·cooldown·buff-window·debuff·resource·none) as a view, `first-class = earns a tracker`. Taste layers on fact.
- **The signal view self-validates.** Derived cold from the axes, buff-window + cooldown = ~76% of the 3,729 first-class
  spells — the corpus's own "two readers carry 2/3 of authorship". The debuff→source pairing dissolved (walk the applier
  edge); per-spec now reads as a play profile (the generator's fingerprint).
- **Custom-effect gaps: isolate from data in hand, don't scrape first.** The 19 `CUSTOM_effect_<n>` codes are opaque to
  our TC enum (Ascension's server-side handlers). But the game's already-scraped descriptions + each code's slot-local
  fields isolate most of them (`name_gaps.py`: slot target/trigger = fact, distinctive phrase, SOLO-effect spells). A
  sweep for a carried `effectAura` **trisected** them: **190 = `apply_area_aura`** (100% carry an aura + a radius — the
  biggest win: folded into the apply-aura path, **+113** recovered aura edges); six **trigger-variants** (175/183/178/…)
  already captured by the `triggers` edge; and **structural ops** — named **195 `reset_cooldown` · 177 `extend_duration`
  · 192 `reduce_remaining_cooldown` · 112 `weapon_augment`**. Sourced from the game's own render, same bar as 165. Gaps
  502→270 spells, 19→14 codes. Residue: ~8 small structural codes (`168` biggest), **probed on the DB and ACCEPTED as
  bounded-opaque** — no dev channel to resolve them ([[dev-channel-unavailable-for-gaps]]), and the structure is enough:
  173/171 target a spell (`misc` — the target-edge pass captures them), 168 links an out-of-scope pet spell, 166/181/174
  are bare flags, 187 a value-param. None block classification (it runs on the axes + the spell's other slots). Target-edge
  wiring (what a reset/extend points at — often a *family*, cf. Rearmament "all Traps") still held for a follow-up.
  Battlewrath cracked 190 from the DB (radius the invariant); our carried `effectAura` completed it.
- **Target-edge wiring — done.** The spell-targeting custom ops (`165/177/192/195` + structural `173/171`) emit a unified
  **`targets_spell`** edge (`op` + `dst` = the `misc` spell). 351 cross-links, **329 to in-scope COA abilities** — "this
  spell resets/reduces/extends *that tracked ability*". `modify_cooldown` folded in. "All Traps"-style fan-out is
  server-side (not in the DBC — Rearmament resolves to one `misc` target); we capture what the data holds, accept the rest.
