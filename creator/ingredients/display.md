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

**First split (the authors' own framing, [Aura Types](https://github.com/WeakAuras/WeakAuras2/wiki/Aura-Types)):
normal types SHOW information; group types ORGANIZE and show nothing themselves.**

Then ask what the information IS before picking the frame: a yes/no ("is my dot up?") wants an **icon**; a duration you
watch drain wants a **bar**; several of either want a **dynamicgroup**; a number alone can be a **text** subregion on
any of them. The region carries the meaning — styling only decorates it.

**The information-density ladder** (the authors' reasoned ordering — each region carries this much):
`texture` (pure graphic, zero data) → `progresstexture` (graphic + progress) → `icon` (compact; cooldown-native) →
`aurabar` ("a maximal amount of information": texture + name + timer + icon) → `text` (pure message). Pick by the
player's reading budget: the proc swirl needs zero words; the tank's stack alarm earns the bar's full row.

**Capability constraints (wiki-claimed — fork-confirm before relying, invariant 7):** progresstexture scales but
can't rotate · text can't scale or rotate · groups take no width/height. The per-region animation-capability harvest
is a named wall (the Animations tab is unharvested).

**The static `group`** (one anchor, children move together, no auto-arrangement) is the players' own nesting tool —
how packs get hand-combined in-game (our bundle is flat-only by design; the static group is the user-side answer).
