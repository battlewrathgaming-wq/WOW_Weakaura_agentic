# triggers — the overview (what a trigger IS, before picking one)

_The authors' own pedagogy ([Trigger Types](https://github.com/WeakAuras/WeakAuras2/wiki/Trigger-Types)), folded onto
our fork facts. Per-type detail lives in `trigger.<type>.md`; this is the frame those files sit in._

## The information handshake (the authors' four channels)

A trigger is judged by what it can FEED the display: **Duration · Icon · Name · Stacks** — and types provide different
subsets. This is the trigger↔display contract in miniature: the region can only show what the trigger hands it
(our per-type `provides`/READ tables are the full fork-fact version — `maps/condition_vars.json` the catalog).
Region-appropriate content is this law from the display side.

## The behavioral taxonomy (choose by BEHAVIOR, not by prototype family)

- **Aura** — reads a buff/debuff window on a unit. The most-used trigger (66% of corpus authorship). Ours: `trigger.aura2.md`.
- **Status** — state that **can always be checked** (pollable): cooldown progress, power, health, usability, stance,
  item counts. Continuous truth → natural for always-shown/dim styles.
- **Event** — fires on a **one-time occurrence** and stays visible only temporarily: Cooldown READY (the flash),
  chat message, combat-log lines. Momentary truth → natural for appear-at-the-moment styles.
  _This split is load-bearing: it's why Cooldown Ready exists separately from Cooldown Progress, why `custom_type`
  offers event vs status, and it maps straight onto the picker's show-logic presets._
- **Custom** — the scripting lane (`custom.md`): event / status / TSU, whatever the sandbox allows.

## Traps and rules (wiki-claimed where noted — fork-confirm per invariant 7)

- **Inverse / show-on-missing loses ALL dynamic info** *(wiki-claimed)*: no aura present = no duration/name/icon/stacks
  to read — the display needs static fallbacks (why drive-from-ID's auto icon matters; our show-on-missing members
  should carry their own `displayIcon` when the look depends on it).
- **Multi-target tracking rides the combat log** *(wiki-claimed; matches our 3.3.5 reasoning)* — the mechanism behind
  the unit=target flattening decision.
- **Up to ten triggers per display, three activation modes** — the `activation` block (`disjunctive` any/all/custom,
  `activeTriggerMode`); one trigger = one show state, conditions read across all of them.

## The choosing flow

What's the native signal? (the bucket map decides) → is its truth **continuous** (status/aura) or **momentary**
(event)? → does the display need its info channels filled (duration on a bar, stacks on a counter)? → then the
per-type file for the levers.
