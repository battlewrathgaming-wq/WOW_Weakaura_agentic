# Class_design

Root-level, per-class **mechanics & theorycraft knowledge** for Conquest of
Azeroth classes — what a class *is*, how its mechanics actually work, and the
stat/rotation action-points that fall out of them. One subfolder per class.

This is deliberately **separate from `Weak Auras/`**: that folder is the
tooling that *builds* auras; this folder is the *understanding* the tooling
(and the player) reasons from. A finding here can inform a WA later, but it
stands on its own as class knowledge.

## Discipline (same as the rest of the repo)

Evidence-first. Every claim traces to an observable source:

- **`Input/<class>_talents.json`** — dev-authored ability/talent DB (spell IDs,
  descriptions, trees, costs).
- **`dependencies/coa_spells.json`** — spell DBC dump (durations, schools,
  effects, attributes).
- **In-game** — tooltips, character-sheet numbers, `/combatlog` captures, live
  A/B tests.
- **Community / dev** — named, and weighted honestly (a dev statement outranks
  "feels-craft without a sim").

Where data stops, the gap is **named**, not guessed — and classified as "go
gather" (a test we can run) or "accept as bounded-opaque."

## Layout

```
Class_design/            # the FLOOR = what translates across every class
  METHOD.md          # the reasoning method — the EXPRESSION × INTENT × MECHANICS triangle
  README.md          # this file — purpose + evidence-first discipline
  tools/             # class-agnostic extraction tooling (decode_build.py + CAPTURE.md)
  <Class>/           # per-class application of the method
    FINDINGS.md      # living, sourced summary — the shareable artifact
    tests/           # test protocols + captured data + verdicts
```

## Classes

- [Necromancer](Necromancer/FINDINGS.md) — Battlewrath's main (Animation spec).
