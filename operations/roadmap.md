# roadmap — forward-looking (the slower notes)

_Where we're headed, at a slower cadence than STATE. The moving present is `STATE.md`; the granular, fast creator
decisions are `creator/decisions.md`; the fixed touchstones are `WHAT.md` / `HOW.md`. This is the direction between them._

## Near

- **★ HEADING (restore point 2026-07-14): the derived-gears rewrite.** Kill hand-written stored-form shapes everywhere:
  harvest `ConstructFunction` → `maps/arg_shapes.json` (per arg.type: stored form + `use_` gate, source-cited) · fill
  drops its load translation (fully dumb: containers + verbatim) · populate shapes load via load-sheet type × template ·
  expand's filter shaping goes type-aware · regression = re-press everything, diff byte-identical except load's live
  form. Principle: **leverage what is known and proven true — derive handling, never hand-write it** (three instances
  of the same disease found: fill's load, expand's type-blind `use_`, expand's hand multiEntry shape).
- ✅ **Heal the merge (done 2026-07-14)** — `filter_coa_spells.py` now carries `effectClassMask`; `coa_spells.json`
  regenerated, verified purely additive (graph + gate unaffected). Family-based cross-links unblocked.
- ✅ **The DBC resolver (done 2026-07-14)** — Pass 1 axes + typed edges (triggers · applies_aura incl. area-190 ·
  family_effect · targets_spell); Pass 2 signal view; the bucket map; custom-effect gaps named or accepted.
- ✅ **First product through the machine (2026-07-14)** — Target tracker contract → populate → gate → stage → pickup →
  the Necro/Death 7-icon pack; two live catches fixed at the right layers (live-key gate tier; load-shape finding).
- **Enrich** the class:spec tables + taxonomy with the resolved signal + edges; name-map the remaining DBC enum codes.
- **Graduate** the classification tool + contracts from `creator/planning/` into `creator/` once the design firms up.
- **Next contracts** — Ready tracker (cooldown progress; needs its live-key harvest) · Self tracker · resource bars.
- **Pending in-game:** the corrected pack's live re-import; the specialization list's names (20 index entries) →
  wire `load.specialization`.

## Further

- **Generation side** — type-configured tracker packs from the classified data: the flat bulk auto-generated through the
  engine, the custom scaffolds reasoned. Then bespoke aura products.
- **WoW addons** beyond auras (the capability, applied wider).
- **Consolidation** — the engine folds into creator's neighbourhood over time; the weakauras corpus decomposes into the
  graph / feature-store / slice storage instead of scattered json.
- **Live-client confirms** — headless-green is not live-proven; the game is the ground-truth authority.

## Standing

- The product scope is per-class TRACKER packs + resource bars, **not a HUD** (HUD is a later data-driven phase, deferred
  not excluded). See `WHAT.md`.
