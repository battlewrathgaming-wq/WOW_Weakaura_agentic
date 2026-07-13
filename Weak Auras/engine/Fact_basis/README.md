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

- **class_table.json** — the class **API-token ↔ user-facing name** pairing.
  - `class_name` (user-facing, e.g. "Bloodmage") is **ours** — translated/scraped, proven.
  - `api_name` (what WA's `load.class` actually accepts internally) is **proof-PENDING** for the COA custom classes.
    WA may use a codename that differs entirely from the display name. We do NOT guess it.
  - **To prove one:** on that COA class, make an aura with *Load → Class = <that class>*, export it, decode
    `load.class.single` → that's the real `api_name`. Fill it in, set `proven: true`. (Same "live export is ground
    truth" move that proved the Tome tracker.)
