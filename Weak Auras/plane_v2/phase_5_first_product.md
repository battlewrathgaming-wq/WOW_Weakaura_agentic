# Phase 5 — first product: the type-configured pack, mechanically docketed

**Goal:** the pack (`[[type-configured-pack-first-product]]`) as a BATCH RUN of
the finished machine — and the structural point that makes it cheap:
**it does not need the story→BOM agent.** Principles: P1, P10.

## The docket generator (mechanical, not agentic)

`plane/generate_docket.py`: coa_spells.json → docket.json, one row per ability,
by data-driven mapping — no LLM in the loop:

- **active/passive split** (the DBC attr bit, classify_lanes) scopes the run:
  actives → button-auras; aura-granting passives/procs → track-auras.
- **base primitive per ability** from categorisation signals:
  - ~cooldownless + rotational → `cooldown_button` (Tier 1 contract)
  - cooldown tiers 30/60/120/300s → major-button variants
  - grants-aura (effectTriggerSpell / aura effects) → `buff_track` (aura2,
    drive-from-ID in auranames, family match)
  - external-input abilities → blank-basis SCAFFOLD rows (emitted as
    copy-and-fill, marked, not guessed)
- mechanical whys ("cooldown 120s → major"; "applies 533240 → buff_track").
- slot assignment from the mask's tier rows (Tier 1 rotation / Tier 2 below);
  the pack ships type-configured, users arrange their own UI — layout
  reasoning stays deferred by design.

Generator rules are DATA (a mapping table in the script header), so the
mapping is reviewable and diffable — intent lives in a table, not in prose.

## Why generator-before-agent (P10)

The generator exercises the ENTIRE chain — fill → assemble → canon → encode →
verify, receipts and all — at scale on deterministic input. Every defect found
is a machine defect, not confounded with agent judgment. The agent/resolver
(story → docket) slots in LATER writing the SAME schema; it inherits a proven
machine. Same machine, swapped front-end.

## The green gate (the pipeline has legs)

One class — Necromancer (Battlewrath plays it; the HUD is the proof-bed):

- every active ability → an import string,
- all receipts green (V1–V4),
- ZERO hand edits anywhere in the chain,
- a sampled subset imported live on the sandbox account and eyeballed.

Then scale is a loop over 21 classes, not a new build.

## Deferred, explicitly (unchanged)

Custom/proc scaffold REASONING (the proc-basis talent→ability tracer), layout
reasoning, script-insertion (custom code contract), the story→docket agent.
Each becomes its own workstream ON TOP of the machine this phase proves.
