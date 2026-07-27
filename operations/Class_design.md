# Class_design — lane

_Per-class mechanics & theorycraft. Root `Class_design/` (sibling to operations/,
separate from `Weak Auras/` = aura-building tooling). Stood up 2026-07-27. This
file TRACKS the lane and points into the detail; the knowledge itself lives in
`Class_design/<Class>/FINDINGS.md` + `tests/`._

## Method (proven on Necromancer)

Answer "does stat/mechanic X do Y" by MEASUREMENT, not tooltip guesswork:
**capture (`/combatlog`) → parse (a gear) → reason on the landing.** Inventiveness
is in building the gear + interpreting output, never hand-reading raw lines.
Tools + format gotchas: `Class_design/Necromancer/tests/README.md`
(`parse_combatlog.py` for DoTs, `crypt_analyze.py` for channels; reusable across
classes, promote to a shared home when a 2nd class needs them). Standing rule:
**match by spell NAME, not id** (live cast ids ≠ DBC ranks; effects fire under
triggered ids).

## Status

- **Necromancer (Animation — Battlewrath's main): seeded.** Stat priority + the
  pet-scaling loop (Stamina a confirmed damage stat, ~0.5 SP/pt, multiplicative
  on Life Force) → `Class_design/Necromancer/FINDINGS.md`. Harvest Plague ticks
  are haste-immune (tested). Crypt Swarm "haste" test was **invalidated by a
  community-confirmed bug** (Scourge Disciple applies NEGATIVE haste — a trap
  talent), so Crypt Swarm × *positive* haste is **reopened**.

- **Reaper (Domination — tank): seeded** (`Class_design/Reaper/FINDINGS.md`).
  Thesis = a soul-economy tank (RP/Reap → fragments → Reaped Souls → Soul
  Infusion, feeding active mitigation). First grounded find: **Stamina scales
  the self-heal** (Tormented Souls heals 24% Stamina/stack) → Stam premier, AP
  co-scaler (same "Stamina is throughput" shape as Necro). Talents-not-yet-read
  + Deathwind-in-build + the Dreadknight r2/r1 drift are the open next pass.

## Open / forecast

- **Crypt Swarm × positive haste (reopened)** — the archer test used bugged
  −haste (Scourge Disciple; community-confirmed known bug = the archer-haste-
  global answer to the old discriminator). Clean re-test = **potion, NO archers**,
  baseline vs potion → does positive haste shorten the channel / add ticks/RP?
- Necromancer small: exact Life-Force slope (Banshee LF2 / Gargoyle); Hit-cap
  weight under pet-heavy play.
- **20 more classes** — same spine (talents JSON + coa_spells + live tests).
- **Build extraction** — the CoA builder export/share string decodes cleanly
  offline (`Class_design/tools/decode_build.py`; presence = selected, no
  is-selected ambiguity). Second witness = a live addon talent-tree walk, scoped
  for the addon bench at `addons/backlog.md #5`; acceptance = a decode-vs-walk
  diff on the Reaper build (also backfills unnamed gaps like id `561337`).
