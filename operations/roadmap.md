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

- **★ THE HTML WA PICKER — DESIGN DONE, SILOED (2026-07-15).** The full decision-tree walk-through with
  Battlewrath converged the design; authority now lives in **`creator/picker/`** (the public packaging silo):
  `picker_tree.md` = THE SPEC (8 laws · the wizard script "what class→spec→lane→scope→which→behaviour→closer→string"
  · one-time minting, emit-never-ingest · the library face with the "not provided by CoA" gap rule · text-only
  data-flattening, WA owns the come-alive · pool assessed READY · JS-export feasibility confirmed against the
  codec) and `picker_build.md` = THE RUNWAY (6 phases: library emit ∥ JS codec port → template press → shell →
  live stamp → doors light up post-V1). V1 lanes = DoTs (target + catch-all) + pets; Ready/Self contracts light
  their doors later by data regeneration, shell untouched. LATER still: the hosted variant + picks-as-votes
  (needs a hosting partner, bisbeard precedent). This roadmap entry is a POINTER now — don't re-derive here.

- **Generation side** — type-configured tracker packs from the classified data: the flat bulk auto-generated through the
  engine, the custom scaffolds reasoned. **Sequencing (Battlewrath, 2026-07-15): the picker ships FIRST (packaging
  what exists for the public), THEN the bench turns to bespoke UIs through the existing engine pipeline** — the
  picker is the wide product for everyone; bespoke is the deep product the machine was always for.
- **WoW addons** beyond auras — **the `addons/` bench ESTABLISHED (2026-07-15)**: root sibling, own charter/invariants/bench/backlog (the agent-handoff kit); three banked missions (spec-name capture · tooltip gap-fill · WA-env harvest) each unblock the aura bench. Same ecosystem, separate focus - no goal-flipping.
- **Consolidation** — the engine folds into creator's neighbourhood over time; the weakauras corpus decomposes into the
  graph / feature-store / slice storage instead of scattered json.
- **Live-client confirms** — headless-green is not live-proven; the game is the ground-truth authority.

## Standing

- The product scope is per-class TRACKER packs + resource bars, **not a HUD** (HUD is a later data-driven phase, deferred
  not excluded). See `WHAT.md`.
