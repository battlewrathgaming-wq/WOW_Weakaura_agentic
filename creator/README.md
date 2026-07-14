# creator

The **CREATOR** half of the machine — the *invent* side, the **author lane** that feeds the mechanical engine. Where the
class inventories, the classification / web tooling, and the design work live. This is the lab.

## The two halves (see `operations/HOW.md`)

`creator (invent) → gate → engine (wrap) → WA`. Generation lives HERE, in the contained spaces (the ADR: invention is
confined, never leaks past the gate). `operations/` *tracks* the work; `creator/` is where the work *happens*.

## What lives here (migrating in over time)

- **class inventories** — where an agent authors dockets per slot (the mechanical proof a slot can function). The
  biggest current target; not the only axis (complex scaffolds are their own track).
- **the classification / web tooling** — the "signal platform": spell *nodes* + the `coa.triggeredBy` *edge graph* +
  *traffic* (centrality) + lane *buckets* + the clear-vs-hard *triage*. It turns 9,152 spells into "auto-generate these ·
  reason about those." Grounded 2026-07-14: the web is **already materialized** in `coa_spells.json` (`coa.triggeredBy`),
  and traffic = in-degree centrality **finds the class mechanics** (Reaper's souls surfaced by connectivity alone).
- **design materials** — the bespoke-scaffold reasoning, the complex compositions, the experiments.

## The consolidation direction (Battlewrath)

This is the keeper-home the sprawl migrates INTO — reduce the bloat, name and home the keepers. In time:
- the **engine** (`Weak Auras/engine/`) consolidates here too — the whole machine under one roof;
- a lot of the **weakauras corpus** decomposes into **better storage** (the graph + feature-store + slice model),
  not scattered json.

## Not built yet — established, not filled

Empty by design. The home exists; the materials **settle in via staged passes**, and the **research** (adtech /
graph-centrality prior art) + the **settlement** (what migrates, in what order) are their own steps, not a dive.
Current front: `operations/STATE.md`.
