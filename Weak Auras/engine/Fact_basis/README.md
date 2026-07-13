# Fact_basis

The engine's **fact basis** — the proven, sourced truths the engine builds on. Everything here is either
**extracted from WA source** or **live-proven**; nothing is invented (the ADR: sheets are source-authored only,
`adr-inventiveness-confined-to-contained-spaces`).

Eventually the whole fact basis consolidates here — the **contract** (WA field/domain truth, currently in
`../../wa_index/`), the **class:spec** data, the **effect chain**, the **coupling table**. One home for *what is
true*, cleanly separate from the gears that consume it.

## The rule

A fact enters here only when **sourced** (from WA source) or **proven** (a live export decoded). An unproven claim
is marked **proof-pending** and never asserted as fact — because an agent reads the fact basis as truth and feeds it
to WA; an unproven "fact" collapses silently (that's the whole reason for the gate + this discipline).

## What's here

- **class_table.json** — the class **user-facing name ↔ API token ↔ classId** fact basis (21 COA classes).
  Regenerable: `py build_class_table.py`.
  - `class_name` — user-facing, ours (e.g. "Bloodmage").
  - `api_name` — **FACT**: the game class API token (GetClassInfo), sourced from the trainer scrape. COA classes ride
    base-class shells, so the token is an **opaque codename you can't guess**: `SONOFARUGAL`=Bloodmage, `MONK`=Templar,
    `DEMONHUNTER`=Felsworn, `WILDWALKER`=Primalist, `PROPHET`=Venomancer, `SPIRITMAGE`=Runemaster. Never guessed — sourced.
  - `wa_load_verified` — the **separate claim** (Battlewrath's distinction: the token is fact; *WA using it* is not):
    `true` iff the token was seen in a real aura's `load.class` in the corpus (WA-usage proven live). Currently 3
    (Necromancer, Reaper, Bloodmage — the classes with corpus auras); the other 18 are fact-but-not-yet-corpus-confirmed
    (they *are* the game class token, so expected to work — a live class-loaded export flips them to `true`).
