# region: aurabar — the progress bar

_The duration/progress display: a bar that drains (or fills) with the trigger's timer. Fact source:
`sheets/display/aurabar.json` (37 options + the reactive surface). Law: **BAR wants progress** — a timed aura window,
a cast, a channel. It's the region the icon must NOT imitate (progress on an icon = the live crash); here progress is
native. The banked tracker archetype (dynamic-group duration-bars) is this region inside a dynamicgroup._

## The proven pairing

aura2 provides `duration`/`expirationTime` → the bar reads them as its progress automatically (`progressSource` default
= the trigger). A DoT/HoT bar is: aura2 catch + this region + a dynamicgroup around the members. Nothing to wire by hand.

## Ingredients — the bar itself

| ingredient | default | what it does | good for |
|---|---|---|---|
| `barColor` / `barColor2` | red / yellow | fill color (+ second color for gradient) | the identity color per tracker; barColor2 only matters with gradient on |
| `enableGradient` + `gradientOrientation` | off | two-color fill | taste; off is calmer |
| `backgroundColor` | black 50% | the empty track | contrast control; leave default unless the ask names it |
| `texture` + `textureSource` | Blizzard / LSM | the fill texture | taste; LSM names must exist client-side — default is safe |
| `orientation` | HORIZONTAL | bar direction | vertical bars for side stacks |
| `inverse` | false | drain vs fill | **the maintain-vs-build read**: drain = time running out (DoT/HoT), fill = building toward ready |
| `width` / `height` | 200 / 15 | size | rows of 15–20px read well in a group; size = hierarchy |
| `zoom` | 0 | texture crop | cosmetic |
| `adjustedMin` / `adjustedMax` | "" | clamp the progress range | comparing bars on one scale (e.g., all DoTs vs a fixed 20s window) — the MAPPING surface |
| `progressSource` | trigger | what drives the fill | leave on the trigger; cross-wiring progress is invention territory — gate/canon judge |

## Ingredients — the icon slot

| ingredient | default | what it does | good for |
|---|---|---|---|
| `icon` | false | show the ability icon beside the bar | ON for trackers — the bar names itself (drive-from-ID hands the texture) |
| `icon_side` | RIGHT | which end | LEFT reads better for left-anchored rows |
| `icon_color` / `iconSource` | white / auto | tint + source | leave auto |

## Ingredients — the spark

| ingredient | default | what it does | good for |
|---|---|---|---|
| `spark` | false | the bright line at the fill edge | the classic cast-bar look; nice on long timers |
| `sparkColor/Height/Width/Texture/BlendMode` | — | spark styling | taste |
| `sparkHidden` | NEVER | when the spark hides | FULL/EMPTY to stop edge flicker at the ends |
| `sparkOffsetX/Y` / `sparkRotation(Mode)` | 0 / AUTO | fine placement | rarely needed |

## The reactive surface (what conditions may change)

`backgroundColor · barColor · barColor2 · desaturate · displayIcon · enableGradient · gradientOrientation · height ·
icon · iconSource · icon_color · inverse · orientation · progressSource · sparkColor · sparkHeight · sparkWidth ·
texture · textureInput · textureSource · width`

Good-fors:
- **`barColor` flip on a remaining-time check** — the refresh warning (aura2 `rem <` → bar goes urgent). The bar's
  version of the icon's desaturate.
- **`desaturate`/`backgroundColor`** for the inactive state when a bar shows-always.
- `height` bump at a threshold — emphasis without layout churn (the group re-flows around it).

## Composition notes

- Text (%p remaining, %n name, stacks) lives in **subRegions**, same as the icon.
- Inside a dynamicgroup the GROUP owns placement; `grow: DOWN` + these bars = the classic tracker column.
- Region-appropriate: if the ask is boolean ("is it up") with no timer to read, the ICON is the cheaper region —
  reach for the bar when the *time itself* is the information.
