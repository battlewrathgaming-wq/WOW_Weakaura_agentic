# roadmap — forward-looking (the slower notes)

_Where we're headed, at a slower cadence than STATE. The moving present is `STATE.md`; the granular, fast creator
decisions are `creator/decisions.md`; the fixed touchstones are `WHAT.md` / `HOW.md`. This is the direction between them._

## Near

- ✅ **The derived-gears rewrite (DONE 2026-07-14, same evening).** `maps/arg_shapes.json` harvested from
  ConstructFunction (per arg.type: stored form + `use_` gate, source-cited) · fill fully dumb (load verbatim) · populate
  shapes load via load-sheet type × template applier · expand map-cited + gear-to-map assert · tome/venomancer refit ·
  regression: re-press diff = triggers byte-identical, load gained its live form (the predicted delta exactly) ·
  class_table: all 18 unverified tokens flipped verified off the live capture (zero mismatches). Principle landed:
  **derive handling from harvested maps; nothing hand-writes a stored form.** Restore tag `restore-pre-derived-gears`
  stays as the fallback.
- ✅ **Heal the merge (done 2026-07-14)** — `filter_coa_spells.py` now carries `effectClassMask`; `coa_spells.json`
  regenerated, verified purely additive (graph + gate unaffected). Family-based cross-links unblocked.
- ✅ **The DBC resolver (done 2026-07-14)** — Pass 1 axes + typed edges (triggers · applies_aura incl. area-190 ·
  family_effect · targets_spell); Pass 2 signal view; the bucket map; custom-effect gaps named or accepted.
- ✅ **First product through the machine (2026-07-14)** — Target tracker contract → populate → gate → stage → pickup →
  the Necro/Death 7-icon pack; two live catches fixed at the right layers (live-key gate tier; load-shape finding).
- **★ HEADING: contracts as repeatable mechanisms of code construct.** The creation pipeline's core primitive, proven
  in three species on 2026-07-14 (bucket contract pressed per class:spec · micro-contract for one-offs · the coverage
  matrix as a verification contract): **select + emit, written once, pressed forever** — populate the compiler, gate +
  canon the type-checker and linker. The remaining creation-pipeline work rides this: **the per-class MULTIDOT
  contract (PRESS-READY 2026-07-15 — `corpus/patterns/multidot-tracker.md` is the live-discovered template; the dot
  lists already computed; operator flip owed in Battlewrath's live copy)**, the **Ready tracker** contract
  (spell-trigger palette file + its liveness first — `trigger_args`/`condition_vars` already harvested), the **Self
  tracker** (boons · proc-on-consumer · payoff pairs), **resource bars**, `spellknown` per-member gates, and the batch
  press (all classes × specs unattended — the defined-I/O end-state).
- **Enrich** the class:spec tables + taxonomy with the resolved signal + edges; name-map the remaining DBC enum codes.
- **Graduate** the classification tool + contracts from `creator/planning/` into `creator/` once the design firms up.
- **Pending in-game:** the specialization list's names (20 index entries) → wire `load.specialization`; re-import the
  re-pressed packs at convenience (subRegions fix).
- **Pending external (never blocked on):** dev reply re class design docs / a DOT-HOT register — if it lands, it's the
  THIRD witness in the validation triangle (designer intent × words × mechanics). **Distribution channel emerging:**
  devs discussed pinning the packs in the Discord → when close, a packaging pass (per-class strings + a public
  import/what-loads-when readme).

## Further

- **★ THE HTML WA PICKER (Battlewrath, 2026-07-14 close — the distribution layer, heading candidate).** Every class ×
  spec × spell × **4 styles**. **V1 SETTLED (2026-07-15): ONE PORTABLE self-contained .html carrying the RUNTIME
  EXPORTER** — pre-bounced member tables (canon runs at BUILD time on the real bench; never reimplemented) + a
  pre-bounced group shell + a small JS codec (serialize→deflate→WA-b64, pako inlined). **Part-pick → ONE group
  string**: tick spells, pick each one's show-logic style, one button → one paste (WA rebuilds child wiring from the
  `c` array — the round-trip finding). **Conformance harness:** at build, the JS encoder must byte-match the python
  codec on a test set or the build fails. V1 virtues BY DESIGN: **sidesteps the organization/mask piece** (flat group,
  users arrange in-game) · **DUMB type-to-type** (no composition intelligence; each pick independent). **The shelves (backing already exists):** SINGLES = the class:spec slicing (the batch press's own select, proven at
  110 pairs) · **SCAFFOLDS = the proven pattern compositions as pickable UNITS** (the proc pair, the stack-band alarm,
  the minion counters — corpus/patterns graduating to primitives by becoming shelf items). **Assembly stays IN-GAME**
  (no layout intelligence — static groups + dragging; the mask/grammar work stays unblocked). Pinned in the Discord as
  the file itself. LATER (needs a hosting partner, bisbeard precedent): the hosted variant + picks-as-votes = the
  grammar's training data. **The 4 STYLES = SHOW-LOGIC presets (Battlewrath's correction — basic logic, not looks):**
  1) always-on dim-when-unavailable · 2) appear-when-ready · 3) appear-while-running · 4) appear-at-the-moment
  (proc/usable). Pure lever presets on proven surfaces (`genericShowOn` / `matchesShowOn` + a desat/alpha condition) —
  the bucket map's check-vs-react laws handed to the PLAYER as a choice. Four tiny emit templates shared by every
  contract; the spell's signal still picks the trigger (fact), the style picks the visibility behavior (the player's).
  This is the "users arrange their own UI" MVP vision's final face.

- **Generation side** — type-configured tracker packs from the classified data: the flat bulk auto-generated through the
  engine, the custom scaffolds reasoned. Then bespoke aura products.
- **WoW addons** beyond auras — **the `addons/` bench ESTABLISHED (2026-07-15)**: root sibling, own charter/invariants/bench/backlog (the agent-handoff kit); three banked missions (spec-name capture · tooltip gap-fill · WA-env harvest) each unblock the aura bench. Same ecosystem, separate focus - no goal-flipping.
- **Consolidation** — the engine folds into creator's neighbourhood over time; the weakauras corpus decomposes into the
  graph / feature-store / slice storage instead of scattered json.
- **Live-client confirms** — headless-green is not live-proven; the game is the ground-truth authority.

## Standing

- The product scope is per-class TRACKER packs + resource bars, **not a HUD** (HUD is a later data-driven phase, deferred
  not excluded). See `WHAT.md`.
