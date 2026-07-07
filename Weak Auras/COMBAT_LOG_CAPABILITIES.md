# Combat Log trigger - capability inventory (problem -> use case -> formation)

Companion to `CAPABILITY_INVENTORY.md`'s phase-1 pass, which catalogued
"Combat Log (3157)" by name/line only. This is the deferred deep read of
that one trigger type, done now because the Witch Doctor totem/ward
investigation (2026-07-06) surfaced a real design question: several
things this project has been tracking as buffs (`aura2`/BuffTrigger2)
don't actually grant a real buff aura at all - a Combat Log trigger keyed
on "did something happen to me" is the only way to see them.

Source: `Prototypes.lua` lines 3157-3741 (`["Combat Log"]` trigger
definition), `Types.lua` lines 1466-1485 (the three flag dropdowns'
values), `Prototypes.lua` lines 801-838 (`CheckCombatLogFlags*` - the
actual bitmask logic behind those dropdowns), all read directly from
this project's installed client, not inferred from general WotLK
knowledge - though the underlying flag *semantics* (affiliation/
reaction/object-type bits) are stock Blizzard combat log design, not
WeakAuras- or Ascension-specific.

Format per entry: the real problem that prompted looking this up, what
capability actually answers it, and the concrete trigger fields to set.
This is meant to be read problem-first, not as a field-by-field manual -
see `Prototypes.lua` itself for that.

---

## Problem: "Did something happen to ME/MINE, regardless of which specific thing"

**This is the mechanism behind last session's observation** ("the ward
dying is reported as a self event, even though it makes no ownership
claim"). Every combat log event carries a `sourceFlags`/`destFlags`
bitmask - real WotLK combat log design, not inferred. `CheckCombatLogFlags`
(`Prototypes.lua:801`) tests it directly:

```lua
if(flagToCheck == "Mine") then
  return bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
```

**Formation:** Combat Log trigger, `sourceFlags` (or `destFlags`,
depending on direction - see next entry) = **"Mine"** (`Source/Destination
Affiliation` dropdown, `Types.lua:1466`). Nothing in the event payload
itself asserts ownership in plain terms - it's this one bit, set by the
server the moment the totem/ward/pet is summoned, checked independently
of the event's own source name/GUID. This is *why* "Self" catches your
ward dying without any explicit ownership field in the message - confirms
last session's read of the mechanism.

Other values in the same dropdown, for completeness: `InGroup`, `InParty`,
`NotInGroup` - group-relative affiliation, not needed for "is this mine"
specifically but available if a future aura needs to react to a *party
member's* summon dying, not just your own.

---

## Problem: "Which direction - did I do something, or did something happen to me"

Easy to conflate. `sourceFlags`/`sourceUnit`/`sourceGUID` describe **who
caused** the event; `destFlags`/`destUnit`/`destGUID` describe **who it
happened to**. For a ward's own death: the ward is the thing dying, so
whichever side of the event names the ward is where "Mine" needs to be
checked - not automatically "source." A cast event (you casting the
totem) has you as source; a death event has the totem as whichever side
the log names it. **Not yet independently confirmed on this server** which
side (source or dest) a totem/ward's own death event actually populates -
flagged as a live-test item before building a real trigger around it,
same "verify before assuming" discipline as the `GetNumTalentTabs`
lesson - this server has a track record of custom systems not matching
stock assumptions.

---

## Problem: "Is this a totem/ward, or an actual controlled pet"

**Real, useful distinction available and previously unused.**
`sourceFlags3`/`destFlags3` ("Source/Destination Object Type",
`Types.lua:1479`) exposes a second, independent bitmask
(`CheckCombatLogFlagsObjectType`, `Prototypes.lua:833`) with five real
values and their bit weights (`Prototypes.lua:825-829`):

| Value | Bit |
|---|---|
| Object | 16384 |
| Guardian | 8192 |
| Pet | 4096 |
| NPC | 2048 |
| Player | (next bit down, not read this pass) |

`Object` is stock WotLK's classification for passive/summoned-but-not-
independently-AI'd things - totems fall in this bucket in vanilla/stock
Shaman play. `Guardian` is a true semi-autonomous pet-class summon.
**Not yet independently confirmed against a real captured Witch Doctor
ward event on this server** whether it actually carries the `Object` bit
as expected - flagged as the same category of "verify, don't assume" item
as the direction question above, given this server's history of custom
systems diverging from stock (talent API being the clearest precedent).
If confirmed, this is a clean way to filter "totem/ward-type things I
own" apart from "my actual pets" apart from "NPCs/players" in one field,
without needing to name-match specific ward text.

---

## Problem: "Two wards of the SAME type are up at once - which one is which"

**This is the real gap flagged last session** ("it doesn't show uniqueness
of same type"), and the honest answer is: the plain point-and-click
Combat Log trigger UI doesn't solve this on its own. `sourceFlags`
Affiliation/Object-Type filters only tell you "something of mine, of this
kind, did X" - they collapse multiple simultaneous instances into the
same true/false check.

**What actually WOULD solve it, confirmed as a real field:** `sourceGUID`/
`destGUID` (`Prototypes.lua:3179-3188`, `3288-3297`) are real, per-instance
Blizzard GUIDs, `store = true` (so they land in the aura's tracked state,
not thrown away), with a `formatter = "guid"` for display. A GUID is
unique per summoned instance - two Snake Totems cast seconds apart get
two different GUIDs, even with identical name/spellId. **Formation:**
capture `sourceGUID` off the summon event, then a second trigger (or the
matching untrigger) that requires exact GUID equality against the stored
value to close out that *specific* instance. The plain declarative
Combat Log trigger UI has no built-in "remember a GUID from an earlier
event and compare against it later" mechanism by itself (its own
`sourceUnit`/`destUnit` test only compares against a *live* unit token via
`UnitGUID`, not a value stored from a prior event) - this specific need
is a **Custom trigger** (hand-written Lua), not a stock dropdown
configuration. Flagging as the concrete next research item if per-instance
ward tracking becomes a real requirement, not a dead end - the data
needed (`sourceGUID`) is confirmed present and already flagged `store=true`
by WeakAuras itself.

**Adjacent, different mechanism - `cloneId` ("Clone per Event" toggle,
`Prototypes.lua:3722-3728`):** generates a fresh incrementing id
(`WeakAuras.GetUniqueCloneId()`, `GenericTrigger.lua:4045`) per *matching
event occurrence*, giving one visual clone per event rather than
collapsing repeats into one aura state. Confirmed this is keyed on event
count, not on GUID - good fit for "show one instance per damage tick/proc
occurrence," not for "track this one specific ward's whole lifetime,"
since a fresh cloneId is assigned every time the trigger fires, with no
persistence tying it back to a specific source GUID across separate
start/end events. Don't reach for this when the actual need is per-object
identity over time - that's the GUID approach above.

---

## Problem: "Should this be a buff/debuff trigger or a combat log trigger"

**The actual design question behind "we've been tracking buffs when we
could use the self events more."** Two genuinely different mechanisms,
each with a real cost:

- **`aura2` (BuffTrigger2)** - polls whether a real buff/debuff aura is
  currently active on a unit. Clean, automatic expiration (the aura
  itself has a duration WeakAuras reads natively), no manual start/end
  pairing needed - but only works if the effect actually grants an
  inspectable buff. Per this project's own totem investigation: several
  Witch Doctor totems/wards grant **no buff on the caster at all**
  (confirmed live by Battlewrath) - for those, `aura2` has nothing to
  poll, full stop, regardless of clever trigger configuration.
- **Combat Log trigger** - fires off real server events (summon/cast/
  death/damage/etc.) regardless of whether a buff exists. Catches things
  `aura2` structurally can't see. Cost: no automatic "is this still true
  right now" polling - you're pairing a start event with an end event (or
  a known duration) yourself, and (per the two problems above) real
  per-instance uniqueness needs the GUID-capture approach, not something
  free out of the box.

**Practical rule of thumb going forward:** check for a real buff first
(cheapest, auto-expiring); if none exists - which is common for
totem/ward-type effects per this project's own findings - Combat Log
with `sourceFlags`/`destFlags` = Mine (+ Object Type filter where it
matters) is the correct fallback, not a workaround.

---

## Field reference - what's actually available, by subevent shape

Every field below is real (read from `Prototypes.lua`'s own `args` table,
not guessed), each with an `enable()` function gating it to specific
`subeventPrefix`/`subeventSuffix` combinations - i.e. the trigger UI only
shows a field when it's actually meaningful for the subevent you picked:

- **Always available:** `sourceGUID`/`sourceUnit`/`sourceName`/
  `sourceNpcId`/`sourceFlags`/`sourceFlags2`/`sourceFlags3`, and the same
  five for `dest*` (dest fields disabled specifically for
  `SPELL_CAST_START`, which has no real destination yet).
- **SPELL/RANGE/DAMAGE-prefixed events:** `spellId`, `spellName`,
  `spellSchool`.
- **`_DAMAGE` / `DAMAGE_SHIELD` / `DAMAGE_SPLIT`:** `amount`, `overkill`,
  `resisted`, `blocked`, `absorbed`, `critical`, `glancing`, `crushing`.
- **`_HEAL`:** `amount`, `overhealing`, `absorbed`, `critical`.
- **`_ENERGIZE` / `_DRAIN` / `_LEECH`:** `overEnergize`/`extraAmount`,
  `powerType`.
- **`_MISSED` / `DAMAGE_SHIELD_MISSED`:** `missType`.
- **`_INTERRUPT` / `_DISPEL` / `_DISPEL_FAILED` / `_STOLEN` /
  `_AURA_BROKEN_SPELL`:** `extraSpellId`, `extraSpellName`.
- **Any `AURA`-suffixed event, plus `_DISPEL`/`_STOLEN`:** `auraType`
  (buff/debuff).
- **`_EXTRA_ATTACKS` / any `DOSE`-suffixed event:** `number`.
- **`ENVIRONMENTAL` prefix only:** `environmentalType`.

This is the real subevent taxonomy to check against before assuming a
field exists for a given event - e.g. don't expect `critical` on an
`_ENERGIZE` event, or `missType` on anything that isn't a miss.

---

## Writing a Custom trigger against Combat Log - hard requirements and useful mechanisms

Everything above covers the plain, point-and-click Combat Log trigger.
This section is what changes once the need outgrows that UI and requires
a hand-written **Custom** trigger (own Lua function) - found while
designing a generic "is this summoned thing still doing anything"
staleness check, and independently corroborated by a real, live-tested
script shared by Pitho (the "Tinker - Restorative Beacon" author) using
the same pattern.

### Hard requirement: subevents MUST be filtered, or the trigger never fires at all

**This is not a performance suggestion - it's enforced by WeakAuras' own
code.** Confirmed directly in `GenericTrigger.lua`: registering
`COMBAT_LOG_EVENT_UNFILTERED` with no subevent filter is refused outright
("we don't register CLEU events without parameters anymore" - the
comment in the source itself), and the aura additionally gets flagged
with an error-severity warning icon ("Support for unfiltered
COMBAT_LOG_EVENT_UNFILTERED is deprecated... disabled as it's very
performance costly"). A trigger written this way isn't throttled or
slow - **it simply never runs**, silently.

The fix is a colon-separated Events string naming every subevent the
trigger cares about:

```
COMBAT_LOG_EVENT_UNFILTERED:SPELL_SUMMON:SPELL_HEAL:SPELL_PERIODIC_HEAL
```

**Important distinction, since this looks like it defeats the point of a
generic/ID-agnostic trigger - it doesn't:** what's mandatory is filtering
by **subevent type** (`SPELL_HEAL`, `SPELL_SUMMON`, etc.) - a small,
fixed list, maybe two dozen possible values total, that never needs
touching again regardless of which ability it's pointed at. What a
generic staleness/heartbeat check is actually trying to avoid is a
**spell ID** list (one entry per ability, growing every time new content
is added) - and that's still entirely avoidable; the trigger's own Lua
body can match "any spellId from this source," it's only the outer event
registration that needs the subevent names spelled out. A reasonably
broad, reusable subevent set for "did this summoned actor do a
recognizable thing" - covers damage, healing, buff apply/refresh,
resource generation, casting, and the initial summon, without naming a
single ability:

```
COMBAT_LOG_EVENT_UNFILTERED:SPELL_DAMAGE:SPELL_PERIODIC_DAMAGE:SPELL_HEAL:SPELL_PERIODIC_HEAL:SPELL_AURA_APPLIED:SPELL_AURA_REFRESH:SPELL_ENERGIZE:SPELL_PERIODIC_ENERGIZE:SPELL_CAST_SUCCESS:SPELL_SUMMON
```

### `custom_hide = "timed"` - a native "stay alive while X keeps happening" mechanism

Found in Pitho's real, live-tested script (decoded via
`weakaura_codec.py`, 2026-07-06): a Custom trigger with `custom_type =
"event"`, `custom_hide = "timed"`, and a `duration` field gets a **built-
in auto-hide timer that resets every time the trigger function returns
true.** Concretely: their trigger returns `true` on the beacon's own
summon event, *and again* every time the player receives one of its heal
ticks - each `true` restarts the `duration`-second countdown. The result
is "stays visible as long as qualifying events keep landing at least
every N seconds, auto-hides the moment they stop" - exactly the
heartbeat/staleness behavior this project had been about to hand-roll
with `GetTime()` differencing and manual `aura_env` bookkeeping. Prefer
`custom_hide: timed` over manual polling wherever the same "still alive
because it keeps happening" shape applies - simpler, and now proven
working on this client by someone else's real script, not just our own
reasoning.

### `TRIGGER:N` - one trigger watching another trigger's own state

Confirmed directly in `GenericTrigger.lua`
(`WeakAuras.GetTriggerStateForTrigger`, the `"TRIGGER"` event dispatch
that passes a watched trigger's number and live state table to an
observing trigger): a Custom trigger's Events field can include
`TRIGGER:1` (or whichever trigger number) to react whenever *that*
trigger's own state changes, receiving its state table directly -
`function(event, watchedTriggerNum, watchedStates) ... end`, with
`watchedStates[""]` for a normal (non-cloneId) trigger's single state.
This is the real mechanism for "a condition/second trigger that rides
entirely on an existing aura's lifecycle" - no independent event-
matching or lifecycle management needed in the observing trigger at all;
when the watched trigger hides, the observer's own supply of `show`
naturally follows. Confirmed the state key is `[""]` (not a per-clone
numeric key) specifically for triggers that don't set `use_cloneId` -
check the watched trigger's own config before assuming this key, since a
`use_cloneId`-enabled trigger would need per-clone indexing instead.

### Real, live-confirmed combat log arg order (independent second source)

Pitho's script's own function signature -
`function(event, timestamp, subEvent, sourceGUID, sourceName,
sourceFlags, destGUID, destName, destFlags, spellId, ...)` - matches the
field order this project already derived by reading `Prototypes.lua`
directly (see the field reference section above). Two independent
sources (our own source read, and someone else's real working script)
landing on the same order is good corroboration, not just a repeat of
one assumption.

---

## Open verification items (flagged, not resolved this pass)

1. Which side (source or dest) a Witch Doctor ward/totem's own summon
   and death events actually populate - needed before writing a real
   trigger, not assumable from stock WotLK Shaman-totem knowledge given
   this server's track record of custom-class divergence.
2. Whether a ward/totem's death event actually carries Object Type =
   `Object` on this server, as stock semantics would predict.
3. The exact subevent name(s) fired on totem/ward death - Battlewrath's
   earlier in-game check found the combat log shows a summon and "a
   generic death" without naming the ward - needs a live capture (e.g.
   via `/etrace` from `/devconsole`, or a temporary Combat Log trigger set
   to log everything) to pin down the literal subevent string, rather
   than guessing `UNIT_DESTROYED` vs `PARTY_KILL` vs something else from
   memory.

All three are "go check live" items in the same spirit as this project's
existing verification discipline (`CLAUDE.md`'s Lua-emulation caveat,
`DEV_TOOLS.md`'s dev-console entries) - not blocking, but worth doing
before a real aura gets built around any of them.
