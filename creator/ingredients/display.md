# display — the shared look layer (what every region has)

_The Display tab splits in two: the region's OWN surface (its `region.<type>.md` file) and this — the layer every
region inherits (`regionPrototype.AddProperties`, `sheets/display/_shared.json`) plus the fields WA gives every aura.
Pick the region by the content law: **icon = boolean/timed · aurabar = progress · dynamicgroup = the container**._

## Position family (on every aura; the group overrides members)

| ingredient | what it does | good for |
|---|---|---|
| `anchorPoint` / `selfPoint` | where it hangs / which corner of itself | inside a dynamicgroup: the GROUP owns these — don't author on members |
| `anchorFrameType` | what it anchors to (SCREEN/...) | SCREEN default; advanced anchoring is user territory |
| `xOffset` / `yOffset` | pixel position | the user's seat — packs ship sane defaults, users drag |
| `frameStrata` | draw layer | leave default; raising it is a fight with the rest of the UI |
| `width` / `height` / `alpha` | size + opacity | hierarchy (size) and ambience (alpha) — the two honest emphasis levers |

## The shared reactive bits

- `xOffsetRelative` / `yOffsetRelative` — the only condition-writable position props (every region): the
  nudge-on-state. Subtle; prefer color/desaturate first.
- The four condition ACTIONS (`sound/glowexternal/chat/customcode`) also live at this layer — see `conditions.md`.

## subRegions — the decoration stack

Declared on the docket as `{type, ...props}`; canon completes the rest. The ones that matter for trackers:

| subregion | good for |
|---|---|
| **text** | the numbers: stacks count on an icon, `%p` remaining on a bar, `%n` name. Text sources read the trigger's provides — never hardcode what the trigger already provides |
| **glow** | the proc/payoff moment — show-it's-live. One glow at a time per screen region, or nothing reads as special |
| **border** | state framing (rare; color does it cheaper) |

_Surfaces for these live in `sheets/display/` (text.json etc.) — spotlight them here as asks reach for them; the sheet settles disputes._

## Identity fields (never styled)

`id` (the human name) · `uid` (stable identity — inventory-provided, minted only when absent) · `regionType` — these
are the docket's spine, not display taste.

## The choosing rule

Ask what the information IS before picking the frame: a yes/no ("is my dot up?") wants an **icon**; a duration you
watch drain wants a **bar**; several of either want a **dynamicgroup**; a number alone can be a **text** subregion on
any of them. The region carries the meaning — styling only decorates it.
