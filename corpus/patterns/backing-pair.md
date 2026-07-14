# pattern: backing-pair

_status: **WORKAROUND-LEAD — not adopted** (Battlewrath: "a workaround... better persistence options haven't been
explored") · provenance: the Necromancer capture 2026-07-14, 4 instances (Razorice · Foul Mandate · Ward active ·
Undead Stance), all closed._

## What it is

Two auras layered per tracked state: a styled **backing** icon that persists (the slot's permanent presence) + the
**state** icon on top that comes and goes. The backing keeps the slot visually occupied when the state is absent.

## Why it's a LEAD, not a primitive

It solves "the slot shouldn't vanish" — but the native persistence surface may solve it in ONE aura:
`matchesShowOn: showAlways` + conditions styling the inactive state (desaturate/alpha/color on show==false). If that
works live, the pair is superseded and this entry gets PRUNED (not precious). The bench question to answer someday:

> Does one icon with showAlways + an inactive-state condition reproduce the backing-pair feel?

## Prune criteria

- Native option proven live → prune this entry, note the native form in the ingredients palette instead.
- Native option proven insufficient (e.g., the backing carries different art than the state icon's desaturate can
  express) → promote to primitive with that boundary documented.
