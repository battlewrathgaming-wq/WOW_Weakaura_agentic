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

- **Necromancer (Animation — Battlewrath's main): seeded, two haste questions
  closed.** Stat priority + the pet-scaling loop (Stamina a confirmed damage
  stat, ~0.5 SP/pt, multiplicative on Life Force) → `Class_design/Necromancer/
  FINDINGS.md`. Haste adds no output to Harvest Plague or Crypt Swarm (both
  combat-log tested) → the weakest secondary (pet-inheritance value only).

## Open / forecast

- **Crypt Swarm haste discriminator** (posted to the class Discord as a possible
  bug): Crypt-Swarm-specific vs archer-haste-global? Test = a hard-cast under
  0 vs 5 archers (`SPELL_CAST_START→SUCCESS` gap). Or benign tick-rounding. The
  robust claim regardless: total output unchanged.
- Necromancer small: exact Life-Force slope (Banshee LF2 / Gargoyle); Hit-cap
  weight under pet-heavy play.
- **20 more classes** — same spine (talents JSON + coa_spells + live tests).
