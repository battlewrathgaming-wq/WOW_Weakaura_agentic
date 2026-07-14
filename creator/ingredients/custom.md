# custom — the scripting surface

_Lua slots across the whole aura anatomy. Light on the menu by design: packs default STRUCTURED (custom locks users out
of editing in WA's UI — the everyman law), but scripting is a legitimate LANE — the state-carrying scaffolds
(builder→spender counters, cross-event logic, anything structure can't reach) live here. Fact sources:
`sheets/trigger/custom.json` (17 inputs) · the fork's `AuraEnvironment.lua` (the sandbox) · `_shared.json` (customcode action)._

## Where custom slots exist

| slot | where | good for |
|---|---|---|
| **custom trigger** | `type: "custom"` / event `Custom` | the big one — see below |
| `customcode` condition action | conditions | one-shot Lua on state-enter (last resort — sound/glow cover most) |
| custom actions | actions.init / start / finish | setup code (`aura_env` state init lives in init) |
| custom text | a text subregion `%c` + customText func | computed numbers structure can't derive |
| custom anchor / grow / sort | display/dynamicgroup funcs | bespoke layout logic |

## The custom trigger (the main event)

| ingredient | what it does | good for |
|---|---|---|
| `custom_type` | event / status / **stateupdate (TSU)** (domain `custom_trigger_types`) | event = fire on WoW events; status = polled state; TSU = full state-table control (clones, per-unit states) — the scaffold workhorse |
| `events` | which WoW events wake it | the listen list — combat log, unit events, Ascension custom events (e.g. `ASCENSION_CA_SPECIALIZATION_ACTIVE_ID_CHANGED`) |
| `custom` | the function itself | the logic |
| `check` + `onUpdateThrottle` | event-driven vs every-update (+ throttle) | throttle anything on update — untamed OnUpdate is the classic perf sin |
| `custom_hide` + `custom_hide2` | how it unshows (timed / custom) | matching the show's lifecycle |
| `duration` / `dynamicDuration` / `customDuration` | hand the timer to the region | lets a script drive a bar/sweep like a native trigger |
| `customName` / `customIcon` | name/icon funcs | keep drive-from-ID spirit: derive from a spellId, don't hardcode strings |

`provides` is empty on the sheet — a custom trigger provides **whatever its states set** (TSU states expose fields to
conditions/text exactly like native provides). That's the power and the responsibility.

## The environment (the real constraints)

- Scripts run sandboxed — `AuraEnvironment.lua` maintains `blockedFunctions` / `blockedTables` (blocked WoW API).
  **The sandbox is the mechanical constraint** — same architecture as everywhere: invent freely, the env refuses.
- `aura_env` is the per-aura state home (persists across calls; init it in the init action).
- Server note: `debug.*` is stripped on Ascension (confirmed live) — no reflection tricks in scripts.
- WA-env facts (what IS available, event payloads, TSU state shape) = **an unharvested wall**: when the scripting
  work starts, harvest the environment surface first (allowed API + TSU contract), same as live_keys — then this
  file grows the tables.

## When to reach for it

Structure first, always — a second trigger + a condition covers most "custom" instincts. Reach here when the ask is
genuinely **stateful** (count things across events, remember between procs, per-unit clone states) or **cross-event**
(combat-log patterns no native trigger flattens). That's the scaffold lane — the packs' flat bulk never needs it.
