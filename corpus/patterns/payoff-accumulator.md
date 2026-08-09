# pattern: payoff-accumulator (what did that burst actually do?)

_status: **primitive — LIVE-PROVEN 2026-08-09** on Corpse Explosion (Battlewrath, in play: 39,236 total /
912 per hit, cross-checked against the banked kill count)._

## What it is

A **reward readout**, not an instrument: a cast fires, damage lands across many events, and one aura tells
you what the burst was worth. Resets on the next cast, lingers a few seconds so it can be read.

## The shape

- **Trigger 1 (lifetime):** Combat Log · `SPELL_CAST_SUCCESS` · Source Mine · **Spell ID** field ·
  Duration ~8s timed — this is what makes the number outlive the cast so you can actually read it.
  (A payoff drawn inside the ability's own window dies at the moment you most want it.)
- **Trigger 2 (the tally):** custom TSU, events `CLEU:SPELL_CAST_SUCCESS, CLEU:SPELL_DAMAGE`:

```lua
function(allstates, event, ...)
    if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return false end
    local sub, src, spellId = select(2, ...), select(3, ...), select(9, ...)
    if src ~= UnitGUID("player") then return false end

    if sub == "SPELL_CAST_SUCCESS" and spellId == CAST_ID then
        aura_env.total, aura_env.hits = 0, 0
    elseif sub == "SPELL_DAMAGE" and spellId == DAMAGE_ID then
        aura_env.total = (aura_env.total or 0) + (select(12, ...) or 0)
        aura_env.hits  = (aura_env.hits or 0) + 1
    else
        return false
    end

    local state = allstates[""]
    if not state then state = {}; allstates[""] = state end
    state.show, state.changed, state.progressType = true, true, "static"
    state.total = aura_env.total
    state.hits  = aura_env.hits
    state.avg   = state.hits > 0 and math.floor(state.total / state.hits + 0.5) or 0
    return true
end
```

(Substitute the two ids: the cast that starts a round, and the damage spell it produces. For Corpse
Explosion those are 533239 and 533240 — often different ids, since a cast's damage frequently rides a
separate effect spell.)

- Required for Activation **All Triggers** · dynamic info from Trigger 1 · text `%2.total` and `%2.avg`
  in **separate subregions** (independent size/colour; big total, small dim average).

## The facts it rests on

- **CLEU `amount` is arg 12** (SPELL prefix; crit flag at 18) — layout confirmed empirically by the
  addons bench, `creator/verification/findings.md` #17.
- **Arbitrary TSU state fields ARE addressable in text** as `%<trigger>.<field>` — the resolver checks the
  state table first and only falls back to the four-name whitelist (`p`/`t`/`n`/`i`) if absent
  (`WeakAuras.lua:5030`). But the state must carry `show = true` or the substitution renders empty.
- Use the **Spell ID** field, never Spell Name — see the rider on
  [summon-count-tracker](summon-count-tracker.md).

## The design law it encodes (Battlewrath, 2026-08-09)

**A number earns its place by having a knob behind it.**

- **Total** — the jackpot; the feedback that makes the loop a loop. Keep.
- **Per-HIT average** — benchmarks SP/crit, which *gear can move*. Keep, and leave it **unformatted**:
  raw `912` is comparable across gear changes in a way `0.9k` is not. Precision beats punch when the
  number is a benchmark.
- **Dispersal / hits-per-corpse ratio** — a real insight (see
  `Class_design/Necromancer/tests/graveyard-observe.md`) but **no control knob** → CUT. "That makes more
  mental load and very few control knobs." Diagnostics belong in the knowledge base, not the display.
