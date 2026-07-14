# conditions — the reaction layer

_Read state the triggers provide, change what the region shows. This is where most invention lives: the same aura gets
its states (ready / active / warning / payoff) without extra triggers. Fact sources: each trigger's `provides` (the
readable vars), each region's `condition_change_targets` (the writable props), `sheets/display/_shared.json` (the
shared layer + the four condition ACTIONS). Docket form proven through fill: `conditions: [{check, changes}]`._

## The shape

```json
"conditions": [
  { "check": { "trigger": 1, "variable": "stacks", "op": ">=", "value": "5" },
    "changes": { "color": [1, 0.8, 0, 1], "desaturate": false } }
]
```
- **check** reads a variable the numbered trigger PROVIDES (see the trigger file's READ table).
- **changes** writes properties from the REGION's reactive surface (see the region file's list) — fill turns the
  map into WA's `[{property, value}]` form.

## Don't conflate the three reactive surfaces (banked law)

| surface | lives in | question it answers |
|---|---|---|
| **EXISTENCE** | the trigger's filter (CATCH/SHOW) | does the aura show at all? |
| **MAPPING** | the region's progress range (`adjustedMin/Max`) | how does the value paint? |
| **REACTION** | here — conditions | how does the look CHANGE on state? |

The same variable can gate existence OR drive a reaction — where you put it is a design choice, and the values are taste.

## Composition rules (all banked, all live-earned)

- **A trigger has ONE active/show state; its condition-vars read wider.** A second *show* = a second trigger;
  a second *reaction* = a condition. (Confirmed in-game.)
- **Read LOCAL state** — dim THIS icon on THIS ability's not-ready. Compound/global state (everything-unusable)
  as a condition darkens the whole HUD: make ONE indicator instead.
- **Prefer conditions over extra triggers** — cheaper, and they keep the aura user-editable in WA's UI.
- **Cross-aura effects pull, not push** — a proc's listener is a 2nd trigger IN the affected aura reading the native
  buff-window; conditions then flip that aura's look. Never a central aura reaching out by UID.

## The shared layer (every region inherits)

- Writable everywhere: `xOffsetRelative` / `yOffsetRelative` — nudge-on-state (the "step forward" moment).
- **Condition ACTIONS** (one-shots, fire on state-enter): `sound` · `glowexternal` · `chat` · `customcode`.
  - `sound` — the proc *ping*; the strongest attention lever, use once per pack at most.
  - `glowexternal` — the glow without a glow subregion; the payoff/proc highlight.
  - `chat` — debugging/announce; not pack material.
  - `customcode` — exists, but **locks the everyman out** (design-for-everyman law): structured first, always.

## Idioms (from the corpus + the bucket work)

- `stacks >= N` → color flip = the payoff wake-up (trigger 2 flip pattern).
- `expirationTime`-family checks (`rem <`) → urgent color = the refresh window.
- `onCooldown == true` → `desaturate` = the standard dim (when the cooldown trigger arrives).
