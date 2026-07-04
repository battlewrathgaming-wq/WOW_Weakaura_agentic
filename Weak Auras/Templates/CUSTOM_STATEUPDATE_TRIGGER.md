# Custom (stateupdate) triggers - researched, built, live-tested, formalized

Written 2026-07-06/07, after three live-test failures trying to get a
"stack gain flash" for Necromancer's Life Force debuff (525004) working
via a plain wizard Combat Log trigger (`stack_gain_flash_text`, see
`Templates/build_templates.py`). This doc is the source-grounded research
pass that came out of that failure chain. As of 2026-07-07 the mechanism
is fully proven end to end: built, live-tested (v1 then a fixed v2,
confirmed working), and formalized into a reusable `build_templates.py`
capability (`stack_delta_flash_text`) - see the "Status" section below
for the full trail.

## Why the wizard Combat Log approach was abandoned for Life Force

Three attempts, in order, all failed to fire:

1. Name-based filter (`use_spellName`, `spellName: ["Life Force: Visual"]`),
   `sourceUnit` filter set to `"player"`.
2. Battlewrath's own live edit: switched to ID-based filter
   (`use_spellId`, `spellId: [525004]` - the real singular Combat Log
   field, confirmed in `Prototypes.lua` line 3443; NOT the plural
   `spellIds`, which is actually the Cast trigger's field, line 7129).
   Kept `sourceUnit: "player"`.
3. Battlewrath re-tested with no source/destination unit filter at all,
   purely on subevent + spell ID. Still nothing.

That rules out both filter-shape hypotheses this project tried along the
way (source-vs-destination unit confusion, and a stale/wrong display-name
string from `spell_index.md`, itself traced to db.ascension.gg - the
mechanism was mechanically confirmed real via `WeakAuras.lua`'s
`CreateSpellChecker`, but ID-based matching sidesteps name resolution
entirely and *still* didn't fire). With all three filter dimensions
eliminated, the remaining honest conclusion is that this custom server's
Life Force mechanic likely does not emit a reliably-matching
`SPELL_AURA_APPLIED_DOSE` (or the combat log event it does emit isn't
what any of these three attempts filtered for) - not something to keep
guessing at one subevent name at a time.

Real, independently useful things surfaced along the way, from
Battlewrath's own combat log screenshots:

- Life Force's debuff application/removal is self-contained on the player
  - both sourced and lost by the player themself, not the pet (an earlier
    hypothesis of mine, directly retracted after Battlewrath pushed back
    with two contradicting screenshots).
- The pet relationship runs the *other* direction: "Abom takes passives
  from me. And gives me a buff to say I have an abom." This is the
  already-documented **Guardian count buff** mechanism in
  `Necromancer/spell_index.md` (`Effect #1 - Apply Area Aura: Pet Owner`,
  confirmed for Lesser Skeletal Warrior 805016, shelved 2026-07-06) -
  today's live combat log ("Gravekeeper gains Abomination's Abomination" /
  "...fades from Gravekeeper") directly reconfirms that exact pattern for
  Abomination too, independently of the DB data.

## The alternative: poll-and-diff via a `stateupdate` Custom trigger

Rather than waiting for a specific combat-log event, this approach
re-reads Life Force's *current* stack count every time the player's auras
change (`UNIT_AURA` for `player`), and computes the gain itself in Lua -
building directly on the aura2 stack-count read this project already
live-confirmed works (`TEST_text_region_lifeforce_import.txt`, confirmed
2026-07-06: renders, tracks the live count, shows/hides correctly).

### Confirmed trigger shape (source-read, not assumed)

- `trigger.type = "custom"`
- `trigger.custom_type = "stateupdate"`
- `trigger.events = "UNIT_AURA:player"` - registers a per-unit event
  (confirmed: `GenericTrigger.lua` line ~1813, `trueEvent:match("^UNIT_")`
  branch splits `"EVENT:unit"` into a unit-scoped registration).
- `trigger.custom` - a literal Lua **function expression** as a string
  (confirmed: `GenericTrigger.lua` line 1746,
  `WeakAuras.LoadFunction("return "..(trigger.custom or ""), data.id)` -
  the stored string must itself be valid Lua that evaluates to a function
  when prefixed with `return `, i.e. `"function(allstates, event, ...) ... end"`).
- Calling convention confirmed via `RunTriggerFunc`
  (`GenericTrigger.lua` lines 645-674, the `statesParameter == "full"`
  branch, which `custom_type == "stateupdate"` sets at line 1860):
  `pcall(data.triggerFunc, allStates, event, arg1, arg2, ...)` - so the
  function signature is `function(allstates, event, ...)`.
- The function's return value directly controls whether WeakAuras treats
  this invocation as "fired" - explicitly `return true`/`return false`,
  don't rely on falling through to `allStates:IsChanged()` (that path is
  only consulted when the return value is `nil`, not `false`).

### Safe state manipulation - `TSUHelpers.lua`'s `allstates` API

Read directly from `TSUHelpers.lua` (confirmed, not community folklore -
this project's own installed addon source defines it):

- `allstates:Update(key, newState)` - create-or-merge a state table at
  `key`, defaults `show = true` if not explicitly set (via
  `fixMissingFields`), marks it changed. **Use this instead of hand-writing
  `allstates[key] = {...}` directly** - `RunTriggerFunc` requires every
  top-level value in `allStates` to be a table (it wipes the whole thing
  and errors otherwise), so any bookkeeping value (like a running "last
  seen count") must live *inside* a state table, never as a bare sibling
  key.
- `allstates:Get(key, field)` - read a single field back out.
- `allstates:IsChanged()` / `:SetChanged()` - internal changed-tracking;
  not needed directly if the custom function always returns an explicit
  boolean.

### Reading the real stack count

`UnitAura(unit, index, filter)` - the actual classic 3.3.5a API this
addon's own `BuffTrigger2.lua` uses internally (confirmed, not modern
`AuraUtil` - this is a WotLK-era client). Field order confirmed via real
usage: `name, rank, icon, stacks, debuffClass, duration, expirationTime,
unitCaster, isStealable, _, spellId = UnitAura(unit, index, filter)`.
Loop `index` until `name` is nil, matching on `spellId == 525004`.

### Auto-revert - confirmed generic, not trigger-type-specific

Setting `show = true`, `autoHide = true`, `expirationTime = GetTime() +
duration`, `duration = duration`, `progressType = "timed"` on the state is
honored by `WeakAuras.lua`'s own `startStopTimers` (~line 4520) - this
scheduler is generic to any state with these fields set, **not** limited
to prototype-based `timedrequired` triggers (confirmed by reading it
directly, since `Private.ActivateEvent` - which normally sets these
fields automatically - is never called for `statesParameter == "full"`
triggers; a `stateupdate` custom trigger has to set them itself, but once
set, the same auto-hide plumbing everything else in this project relies
on takes over).

### Corrected implementation (built, round-trip verified, awaiting live test)

**Correction made before building, 2026-07-07:** the first draft (below,
kept for the record in the change history, not reproduced here) set
`state.displayText = "+N LF"` - but `displayText` is not a real
dynamic-text source. Read `Prototypes.lua`'s `Private.dynamic_texts`
table directly (line 8875) to get the complete, exact set - there are
only five tokens: `p` (progress), `t` (duration), `n` (name -
`state.name or state.id`), `i` (icon), `s` (stacks - `state.stacks`
directly). No generic/custom passthrough token exists. Fixed: the region
displayText is the fixed template `"%n"`, and the custom trigger sets
`state.name` to the fully-composed string instead:

```lua
function(allstates, event, ...)
  local count, icon = 0, nil
  for i = 1, 40 do
    local name, _, ic, stacks, _, _, _, _, _, _, spellId = UnitAura("player", i, "HARMFUL")
    if not name then break end
    if spellId == 525004 then
      count, icon = stacks or 1, ic
      break
    end
  end
  local lastCount = allstates:Get("", "lastCount") or 0
  if count > lastCount then
    allstates:Update("", {
      show = true, name = "+" .. (count - lastCount) .. " LF",
      icon = icon, progressType = "timed",
      expirationTime = GetTime() + 1.5, duration = 1.5, autoHide = true,
      lastCount = count,
    })
    return true
  else
    allstates:Update("", { lastCount = count, show = false })
    return false
  end
end
```

Matches Battlewrath's exact spec: last value to current, only a positive
delta is reported (1→3 = 2, 2→5 = 3; decreases produce nothing).

**Known, accepted quirk, not chased further:** on first load/reload, there
is no memory of the prior count, so if Life Force is already above 0 it
will flash once for the full amount as a one-time false "gain." Cosmetic,
non-blocking.

## Status

**v1 live-tested 2026-07-07 - fired correctly first time** ("That works as
expected first time. :D"). One real bug surfaced by the live test,
diagnosed and fixed in v2 (below) - not yet re-tested.

**Bug found, v1: flash sticks on screen instead of fading, except at the
count's extremes.** Battlewrath's report: "When the delta is at 0 or 3,
it fades. When it is at say in the middle. so +1/+2, it holds open/
stays on screen." (Also asked whether `3` was hardcoded anywhere - it
isn't; the delta is purely `count - lastCount`, computed live off
`UnitAura`'s real `stacks` value, so it scales correctly as the cap
grows from talents.)

Traced the actual cause through `GenericTrigger.lua`/`WeakAuras.lua`
rather than guess again: v1's "no new gain" branch explicitly wrote
`show = false` into the state every time (`allstates:Update("", {
lastCount = count, show = false })`), while also `return false`-ing to
tell WeakAuras not to refresh anything that tick. `RunTriggerFunc`
(`GenericTrigger.lua` ~line 662) only calls `Private.UpdatedTriggerState`
- which is what actually invokes `startStopTimers` (`WeakAuras.lua`
~line 4728, gated on `state.changed`) - when the trigger function
returns a truthy value (or `IsChanged()` when the return isn't
explicitly `false`). Returning `false` explicitly skips that path
entirely per the exact condition in `RunTriggerFunc`
(`returnValue or (returnValue ~= false and allStates:IsChanged())`).
`UNIT_AURA` fires constantly for reasons unrelated to Life Force (any
aura changing during combat) - so almost immediately after a real gain,
another `UNIT_AURA` event hits the "else" branch and silently stamps
`state.show = false` into memory, without ever signaling a redraw. When
the legitimate 1.5s auto-hide timer (scheduled on the original gain
tick) eventually fires, it finds `state.show` already `false` and
no-ops (`startStopTimers`'s own guard: `if not state.show or not
state.autoHide then stopAutoHideTimer(...); return end`) instead of
actively hiding - so the last rendered frame never gets told to update,
and the text appears stuck. At the count's extremes (0 or the cap),
there's typically a quiet moment with no unrelated `UNIT_AURA` churn
before the legitimate timer fires, so the correct path runs
uninterrupted there - consistent with what was reported.

**Fix, v2:** the "else" branch no longer touches `show` at all - it only
persists `lastCount` bookkeeping when it actually changes, and never
writes to `show`/`autoHide`/`expirationTime` itself. The auto-hide timer
is left as the sole owner of visibility:

```lua
else
  if count ~= lastCount then
    allstates:Update("", { lastCount = count })
  end
  return false
end
```

Rebuilt as v2, round-trip verified (confirmed the else branch no longer
contains `show = false`) - `Necromancer/TEST_custom_trigger_lifeforce_
delta_import.txt`. **Not yet live-tested.** This diagnosis is
source-traced, not just inferred from symptoms, but it's still a
hypothesis until Battlewrath confirms the flash now fades consistently
regardless of how much `UNIT_AURA` churn happens mid-window.

**v2 CONFIRMED WORKING, 2026-07-07** ("It works fully as expected on our
end"). The sticking bug is fixed; fades correctly regardless of
`UNIT_AURA` churn. This closes out the mechanism research/build/live-test
cycle for this capability.

**Separately noted, not a bug - a real game-mechanic quirk to be aware
of:** Battlewrath observed "weird behaviour" that traces to how the
server recalculates Life Force on a summon, not to the aura. A summon
costing 1 LF, with 3 currently available, drains ALL 3 to 0 first, then
refunds what's owed (2) - net effect is the intended -1, but the raw
data the aura reads goes 3 -> 0 -> 2. Since the aura only ever reports
positive deltas (by design - see the schema's own scope), this shows up
as no flash on the 3->0 drain (correctly suppressed, not a loss to
report) followed by a "+2 LF" flash on the 0->2 refund - accurately
reflecting the real underlying data the server produces, even though a
player might semantically expect "-1" for that summon. Not something to
fix in the aura - it's correctly reporting real values; the drain-then-
refund pattern is the server's own implementation detail.

**Formalized 2026-07-07** into `build_templates.py` as its own reusable,
class-agnostic capability (`stack_delta_flash_text`, a new
`opportunity_type` in `REGISTRY`), per Battlewrath's "Go. We're in
perfect alignment." A dedicated Lua `.format()` fill block was added to
`template_filler.py` (the generic `{{}}` mechanism can't reach
placeholders embedded mid-string in the Lua). Test-filled and round-trip
verified against the hand-built v2 scratch aura: field-for-field
identical, including a byte-for-byte match on the generated Lua. A fresh
instance for Life Force (525004) was rebuilt through the formalized
template and dropped into
`Necromancer/TEST_custom_trigger_lifeforce_delta_import.txt` for
Battlewrath to give it one final in-game confirmation pass. This closes
out the mechanism's research/build/formalize cycle - see
`Necromancer/slot_assignment.md`'s 2026-07-07 entry for the changelog.

## Separately flagged, not fixed (out of scope for this doc)

`proc_alert_icon` and `pet_summon_countdown_icon` (`Templates/build_templates.py`)
both use `spellIds` (plural) on a Combat Log trigger - that's actually the
Cast trigger's field name (`Prototypes.lua` line 7129), not Combat Log's
(which is the singular `spellId`, line 3443). Neither template has been
built or live-tested yet, so this is flagged for whenever either is
actually used, not corrected now.
