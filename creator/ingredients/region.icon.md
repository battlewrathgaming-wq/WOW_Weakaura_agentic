# region: icon — the static square

_The workhorse display: one ability, one square, state shown by styling. Fact source: `sheets/display/icon.json`
(20 options + the reactive surface). Law: **ICON wants timed/boolean content** (a cooldown sweep, an aura window) —
feeding it raw progress values is the bar's job (live-confirmed crash: Icon.lua:642)._

## Ingredients

| ingredient | default | what it does | good for |
|---|---|---|---|
| `displayIcon` / `iconSource` | auto | which texture; source = trigger's `icon` by default | leave on auto — drive-from-ID hands you the right icon free |
| `cooldown` | true | the sweep overlay driven by the trigger's timer | the aura/CD timer read at a glance; **turning it OFF is a designer seat** (see-the-skill vs see-the-timer) |
| `cooldownEdge` | — | the edge line on the sweep | declare positively when intent-bearing |
| `desaturate` | false | grayscale the icon | THE dim-state: not-ready / not-up. Corpus did this ~35 hand-rolled ways — use a condition, one way |
| `color` | [1,1,1,1] | tint | payoff/warning states via conditions; keep resting state untinted |
| `inverse` | — | invert the sweep direction | "filling toward ready" vs "draining while active" taste |
| `zoom` / `keepAspectRatio` | 0 / false | texture crop | cosmetic tightening |
| `width` / `height` / `alpha` | — | size + opacity | size = hierarchy (bigger = more important); alpha for ambient-vs-active |
| `anchorPoint` / `anchorFrameType` / `xOffset` / `yOffset` / `selfPoint` | CENTER/SCREEN | placement | inside a dynamicgroup, the GROUP owns placement — don't fight it |

## The reactive surface (what conditions may change)

From the sheet's `condition_change_targets` — the properties a condition is allowed to flip on this region:

`color · cooldownEdge · desaturate · displayIcon · height · iconSource · inverse · progressSource · width · zoom`

Good-fors:
- **`desaturate` on a local state** (this ability's own not-ready) — the standard dim. Keep it LOCAL: compound/global
  states (spellUsable everywhere) darken the whole HUD — one indicator instead.
- **`color` flip at a threshold** — the payoff wake-up (stacks ≥ N → gold).
- **`width`/`height` bump** — the "look at me now" moment; use sparingly.

## Composition notes

- Text on an icon (stacks count, %p timer) lives in **subRegions** — declared as `{type, ...props}`, canon completes.
- The icon + a stack-counter text + a threshold color-flip = the payoff pair's static half, all on one region.
