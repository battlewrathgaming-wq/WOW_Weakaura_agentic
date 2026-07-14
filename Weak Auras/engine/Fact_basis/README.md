# Fact_basis

The engine's **fact basis** — the proven, sourced truths the engine builds on. It answers the engine's first
question, **"is it true?"** (the gears that answer **"can we work it?"** — extractors, gate, pipeline — consolidate
in beside it later). Everything here is **extracted from WA source** or **live-proven**; nothing is invented (the ADR
`adr-inventiveness-confined-to-contained-spaces`).

## The rule

A fact enters only when **sourced** (from WA source) or **proven** (a live export decoded). An unproven claim is
marked **proof-pending**, never asserted as fact — an agent reads the fact basis as truth and feeds it to WA, so an
unproven "fact" collapses silently (the whole reason for the gate + this discipline).

## The three kinds of truth

- **`sheets/`** — *does this lever exist, and what can it take?* WA's complete option surface, per trigger type /
  region / load, sourced statically. See `sheets/README.md`.
- **`contract/`** — *is this docket valid and complete?* The compiled acceptance rules (`contract.json`) — required
  fields, domains, the condition join, coupling — JOINed from the sheets. The class-inventory pre-flight + the gate
  read this.
- **`maps/`** — *given X, what's the forced Y?* The deterministic lookups / derivations: class token → class
  (`class_table.json`), and (consolidating here later) ability → granted buff (the effect chain) and
  `(grow, align)` → selfPoint (the coupling table).

The emitters/compiler that PRODUCE `sheets/` + `contract/` live in `wa_index/` for now (they move into the engine's
"can we work it?" side in a later pass); they write across into here.

## maps/class_table.json — class name ↔ API token ↔ classId (21 COA classes)

Regenerable: `py build_class_table.py`.
- `class_name` — user-facing, ours (e.g. "Bloodmage").
- `api_name` — **FACT**: the game class API token, sourced from the trainer scrape. COA classes ride base-class
  shells, so the token is an **opaque codename you can't guess**: `SONOFARUGAL`=Bloodmage, `MONK`=Templar,
  `DEMONHUNTER`=Felsworn, `WILDWALKER`=Primalist, `PROPHET`=Venomancer, `SPIRITMAGE`=Runemaster. Never guessed.
- `wa_load_verified` — the **separate claim** (the token is fact; *WA using it* is the corpus evidence): `true` iff
  the token was seen in a real aura's `load.class` in the corpus (3: Necromancer, Reaper, Bloodmage). **Classed
  SOLVED** — WA's `load.class` reads the game class token uniformly; the corpus proves 3 *including the most opaque*
  (`SONOFARUGAL`), so the mechanism generalizes to all 21. The other 18 aren't a backlog — if a token ever bounces on
  a real `load.class`, it's a one-line fix.
