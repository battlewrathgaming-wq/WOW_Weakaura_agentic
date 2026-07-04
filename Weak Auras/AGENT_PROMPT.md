# Baseline prompt - WeakAuras agent

Paste this as the opening message when starting a fresh session to work on
WeakAuras for this project. No specific ability/task is assumed - fill
that in after this context is established.

---

You're helping design WeakAuras for **Conquest of Azeroth**, a heavily
custom WotLK 3.3.5a private server (Ascension) with 21 custom classes on
top of the base 10 WoW classes. Talent trees and abilities are custom -
don't assume generic WoW/Classic knowledge about what a named ability does
without checking the real data first, and don't assume race/class or
class-identity mechanics follow retail rules (they don't - see
`Docs/PIPELINE.md` for confirmed specifics, e.g. these 21 classes aren't
even real `ChrClasses.dbc` entries).

## Reference materials - read before proposing anything

1. **`Weak Auras/README.md`** - index of what's available and how it
   connects to the rest of the project.
2. **`Docs/WEAKAURA_INDEX.md`** - the methodology: four opportunity types,
   how each maps to a real WeakAuras trigger type, and a known limitation
   worth internalizing before trusting the data blindly (see below).
3. **`Outputs/weakaura_index/necromancer_weakaura_index.json`** - the
   actual per-ability data (Necromancer only so far). Every entry has a
   real `spellId` pulled from the client's Spell.dbc - use it directly in
   trigger config, don't guess or re-derive from a tooltip name.
4. **`Display/README.md`** - points to the fuller ability-relationship
   data (what modifies/compounds on what, real cooldowns/durations/procs)
   if you need more context than the WeakAuras index alone gives you.

## What's already resolved for you, per ability

- `spellId` - verified against the real client, use directly.
- `isFirstClass` - true if the player actually presses this (WotLK's own
  `PASSIVE` attribute bit, not a guess); false means it's a passive/proc
  modifier with no independent press.
- `cooldown`, `duration`, `procChance`, `maxStacks` - real DBC values,
  already unit-formatted.
- `opportunities` - which of the four types apply, each with a plain-
  language trigger description already written out.

## The four opportunity types -> WeakAuras trigger types

- **`cooldown_tracker`** (first-class ability, real CD) -> **Cooldown
  Progress (Spell)** trigger, spell ID direct.
- **`proc_alert`** (passive/talent, `procChance < 100`) -> **Combat Log:
  Spell Cast Success / Aura Applied**, filtered to the spell ID - these
  fire automatically and are easy to miss without a visual cue.
- **`buff_uptime`** (has a real duration) -> **Aura** trigger, spell ID
  direct. Split further: negative duration ("Until cancelled") means a
  permanent on/off icon, not a countdown; positive duration means a
  countdown bar.
- **`stack_counter`** (`maxStacks > 1`) -> not its own trigger, a stack
  count sub-display layered on whichever trigger above already applies.

## Known limitations - don't overtrust the data past these points

- **Stack counts can under-report.** The index doesn't apply the
  wrapper/same-name-trigger merge the main pipeline uses - confirmed on
  `Diabolical` (spell 704723), whose real 15-stack cap lives on a
  *different* spell ID only referenced in its description text. If a
  stack-based aura doesn't behave as expected, check the ability's raw
  description in `Outputs/dbc_preview/necromancer_abilities_reference.html`
  for a `$<id>u` token pointing elsewhere before assuming the data's wrong.
- **No resource-threshold category yet.** "Alert me at 80 Runic Power"
  isn't classified - that needs a "Class Resource" primitive that hasn't
  been built (see PIPELINE.md's still-open synthesized-family work).
- **Some mechanics are genuinely invisible to any addon**, WeakAuras
  included - not a data gap, a game-engine one. Confirmed case: `Army of
  the Dead`'s crit/haste buff scales with live Abomination count via
  server-side scripting with zero client-side footprint (no
  SpellClassMask, no exposed variable). A WeakAura can only react to what
  the client can actually observe (auras present, combat log events,
  cooldowns, unit stats) - if the underlying condition check happens
  server-side with no client-visible signal, the best a WeakAura can do is
  approximate via a visible proxy, not replicate the real condition.
- **Necromancer only.** No other class has this data built yet.

## How to work

- Ground every suggestion in the JSON/spellId data, not general WoW
  instinct - these are custom spells with custom numbers.
- If a task calls for stacking/duration precision and the ability is
  flagged as a possible under-report case, check the raw description
  before committing to a number.
- If asked to build something outside what the four categories cover
  (resource thresholds, positioning, anything server-only), say so
  explicitly rather than forcing it into an existing category.
- WeakAuras syntax/version specifics (export string format, trigger UI
  labels) should be confirmed against whatever WeakAuras version Ascension
  players actually run, if an actual import string is being produced -
  this project's data tells you *what* to track, not the addon's exact
  current UI wording.
