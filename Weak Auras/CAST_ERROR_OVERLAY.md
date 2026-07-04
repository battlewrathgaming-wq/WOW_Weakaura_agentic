# Feature: cast-fail-reason overlay

Status: **flagged, not built, not a blocker.** Raised 2026-07-06 during the
Necromancer Cast Bar work (name text / v12), as a "great add value, not
urgent" idea. Captured here so the reasoning and feasibility research
aren't lost, per this project's usual practice of recording real findings
rather than re-deriving them next time it comes up.

## The idea

Real Blizzard's own cast bar flashes red and shows text ("Interrupted",
"Failed") when a cast attempt doesn't go through. Our `player_cast_aurabar`
currently has no equivalent - a failed cast just silently returns to the
idle/backing-plate state, same as a cast finishing normally or being
self-cancelled. The proposal: a small element that spawns in the same
screen space as the Cast Bar (anchored to it, not a separate console
position), showing the actual reason a cast couldn't fire - out of mana,
silenced, interrupted, out of range, etc. - not just "something failed."

## Feasibility, researched 2026-07-06 (real source reads, not assumption)

**The built-in trigger options can detect failure, but not why:**
- The Cast trigger itself (`Prototypes.lua` ~line 7010) has no distinct
  "was interrupted"/"failed" state - `UNIT_SPELLCAST_INTERRUPTED` just
  makes it re-check `UnitCastingInfo`/`UnitChannelInfo`, both nil after a
  failure, so it looks identical to a normal cast finishing.
- Combat Log's `_CAST_FAILED` subevent (a real, selectable Combat Log
  trigger option, confirmed at `Prototypes.lua` line 3714) DOES receive a
  `failedType` argument from the underlying game event - but WeakAuras
  explicitly discards it (line 3716's own comment: `"failedType ignored
  with _ argument... added here for completeness"`). So this build can
  detect *that* a cast failed via combat log, but not *why* - the reason
  string that exists at the game-event level is thrown away before it
  reaches anything an aura can read.
- `_INTERRUPT` is a separate, real Combat Log subevent option (confirmed
  alongside `_CAST_FAILED`/`_DISPEL`/`_STOLEN` at lines 3524/3540/3547) -
  usable for detecting a genuine interrupt specifically, but still no
  human-readable reason text, and combining it with the existing Cast
  trigger as a second trigger is an untested combination in this project.

**The one native event that actually carries the real reason text:**
`UI_ERROR_MESSAGE` - the same event that drives Blizzard's own red error
text ("Not enough mana", "You are silenced", "Interrupted", etc.). This is
a core Blizzard client event, not a combat log subevent or unit event, and
no built-in WeakAuras trigger currently listens to it.

**Getting the real reason requires a Custom trigger - still fully native,
no dependency.** WeakAuras' Custom trigger type (`type = "custom"`) is a
first-class, built-in trigger type (confirmed directly:
`GenericTrigger.lua` lines 1090/1626/4102/4179/4189/4505/4726,
`Prototypes.lua` registers several `type = "custom"` entries already).
Confirmed separately that the Combat Log trigger's native event
(`COMBAT_LOG_EVENT_UNFILTERED`) requires no external library - the same is
true here: a Custom trigger can register `UI_ERROR_MESSAGE` directly and
expose its message string as trigger state, with zero addon dependencies.
The real cost is authoring effort, not capability - this would be the
first hand-written Lua trigger in this project (everything built so far
has been declarative field-filling via `template_filler.py`), so it's a
step up in complexity and deserves its own build/live-test pass rather
than folding into the existing Cast Bar template.

## Scope, if/when this gets built

- A new schema/template pair (not a modification to `player_cast_aurabar`)
  - a small text/icon element anchored to the Cast Bar's own position,
  shown briefly on a real failure event.
- A Custom trigger registering `UI_ERROR_MESSAGE`, storing the message
  string as trigger state, `show`/`hide` timed briefly (a few seconds,
  matching how Blizzard's own error text behaves) rather than persistent.
- Live-test needed specifically for: does `UI_ERROR_MESSAGE` fire
  reliably for the cases we care about (silence, stun, interrupt, out of
  mana/range) in this WotLK 3.3.5a client build; does the message text
  come through clean/localized or need any parsing.
- Fallback if `UI_ERROR_MESSAGE` proves unreliable: Combat Log
  `_INTERRUPT` can at least flag "you were interrupted" as a boolean,
  without the specific human-readable reason - a lesser version of the
  same idea.

## Why not built now

Not a blocker for anything currently in progress - the Resources tier
(Mana, Runic Power, Cast Bar, Swing Timer, backing plates, end-cap ticks)
is complete and live-tested through v12. This is a genuinely separate,
higher-effort feature (first Custom trigger in the project) worth its own
dedicated pass, not a quick add-on to the current build.
