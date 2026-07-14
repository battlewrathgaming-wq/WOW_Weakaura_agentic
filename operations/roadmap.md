# roadmap — forward-looking (the slower notes)

_Where we're headed, at a slower cadence than STATE. The moving present is `STATE.md`; the granular, fast creator
decisions are `creator/decisions.md`; the fixed touchstones are `WHAT.md` / `HOW.md`. This is the direction between them._

## Near

- ✅ **Heal the merge (done 2026-07-14)** — `filter_coa_spells.py` now carries `effectClassMask`; `coa_spells.json`
  regenerated, verified purely additive (graph + gate unaffected). Family-based cross-links unblocked.
- **The DBC resolver** — interpret the effect slots into typed edges (trigger · modify-cooldown · apply-aura/buff ·
  resource-gen) → the full web + the proc→cooldown cross-links. Right-sized to edge-and-attribute effects.
- **Enrich** the class:spec tables + taxonomy with the resolved edges; sharpen the shape-hint triage; name-map the DBC
  enum codes (powerType/mechanic/effect → names).
- **Graduate** the classification tool from `creator/planning/` into `creator/` once the design firms up.

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
