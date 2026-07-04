# Capability inventory - research packet (phase 1)

Scoping doc for phase 1 of the `reference_library.py` expansion initiative
settled 2026-07-04 (see `USE_CASE.md`'s "Open items" section for the
three-phase plan this belongs to): **capability inventory first, then a
prior-art survey across more packs, then a reusable template code repo.**
This doc is phase 1's packet - what to look at, in what order, and what
"done" looks like - written before starting the actual read-through, same
"evidenced, not invented" discipline as the rest of this project.

## Why this phase exists

Every region/trigger/animation this project has used so far
(`weakaura_codec.py`'s icon/aurabar examples, `Template_shadow.py`'s
scaffold, the Cast trigger, `showOnMissing`, translate animations) was
found the same way: discovered one at a time, exactly when a specific
build needed it, by grepping for a guess and reading whatever turned up.
That's worked, but it means the project doesn't yet know what it doesn't
know - there's no answer to "what are all the ways to show state" or "what
triggers exist besides the ones we've already needed." Phase 1 closes that
gap once, systematically, so phase 3's template repo is built from a full
picture instead of growing ad hoc per-use the way `weakaura_codec.py` has
so far.

## Where to look (real paths, confirmed present)

Addon root: `F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\WeakAuras\`
(a sibling folder, `WeakAurasOptions\`, holds the *options-panel* code -
relevant only if a capability's options-UI shape matters, not for what's
possible to encode).

| Category | Files | What it defines |
|---|---|---|
| Region types | `RegionTypes\AuraBar.lua`, `DynamicGroup.lua`, `Empty.lua`, `Group.lua`, `Icon.lua`, `Model.lua`, `ProgressTexture.lua`, `RegionPrototype.lua`, `SmoothStatusBarMixin.lua`, `StopMotion.lua`, `Text.lua`, `Texture.lua` | The actual visual shapes an aura can take. Icon and aurabar are the only two this project has used; Texture, Text, ProgressTexture, Model, StopMotion, Group, DynamicGroup, Empty are all unopened so far. |
| Sub-region types | `SubRegionTypes\Background.lua`, `Border.lua`, `Glow.lua`, `Model.lua`, `StopMotion.lua`, `SubText.lua`, `Texture.lua`, `Tick.lua` | Decorative layers addable on top of a base region (this project has used the icon+subglow pattern once; Border was live-tested once for the "central island" backdrop idea - see HUD_DESIGN.md - the other six are unopened). |
| Trigger types | `Prototypes.lua`, `GenericTrigger.lua`, `BuffTrigger2.lua` | What can drive an aura's visibility/state. Confirmed so far: Cooldown Progress (Spell), Aura (buff/debuff, including `showOnMissing`), Cast (player/target/focus). Not yet checked: Combat Log, Unit Health/Power thresholds, Item Count, Combination triggers, Spell Activation Overlay, and whatever else `Prototypes.lua` actually enumerates. |
| Animations | `Animations.lua`, `WeakAurasOptions\AnimationOptions.lua` | Confirmed: translate/slide. Not yet checked: alpha, scale, rotate, and whether start/main/finish phases behave differently per type. |
| Conditions | `Conditions.lua` | The mechanism actually driving "full brightness when ready, dimmed on cooldown" today - confirmed working by use, but the full set of properties a Condition can key off of or modify hasn't been enumerated. |
| Built-in templates | `Templates.lua` | WeakAuras' own quick-start templates, shipped with the addon - worth checking before phase 2's external-pack survey, since this is a reference source that's already local and hasn't been looked at at all yet. |

Out of scope for this pass: `WeakAuras.lua`'s control flow, the options-UI
code in `WeakAurasOptions\` (except `AnimationOptions.lua` above), saved-
variables migration/versioning code, and anything not reachable from
authoring an aura via an import string - this is a capability inventory
for *building content*, not a full codebase audit.

## What "done" looks like per category

For each region type / trigger type / animation type actually opened, capture:

1. What it's for, one line (e.g. "ProgressTexture: a fill/progress
   indicator using an arbitrary texture instead of a StatusBar - an
   alternative to aurabar's fill style").
2. Required fields vs. optional fields, at the level `weakaura_codec.py`'s
   debugging checklist already treats as load-bearing (regionType
   determines the field set - this is the same exercise, done ahead of
   time instead of by trial and error).
3. Whether this project already has a real, live-tested use of it (most
   won't - that's the point) or whether it's inventoried but unused so far.
4. One line on why it might or might not be relevant to the HUD_DESIGN.md
   five-tier model - not a decision to use it, just enough context that
   phase 3 knows what's available when a real need shows up.

Not required: full field-by-field documentation reproducing the Lua
source - that's what the source is for. This inventory is a map (what
exists, roughly what it needs, whether we've proven it works), not a
manual.

## Output

Findings get appended to this same file, one section per category above,
as each is actually read - same living-document pattern as
`ELEMENT_INVENTORY.md`. Once all six categories have at least a first
pass, phase 1 is done and phase 2 (prior-art survey, expanding
`reference_library.py` past the single Fojji source) can use this as its
checklist of "what to look for" in each new pack sampled, per
`USE_CASE.md`'s phase order.

---

# Findings (first pass, 2026-07-04)

All six categories below have had a first pass - phase 1 is complete as a
first-pass map. Depth varies by category on purpose (per this doc's own
"what done looks like" section: a map, not a manual) - region types got a
full default-table read each since they're the most immediately reusable
for phase 3's template repo; trigger types got the full 43-entry catalog
but not a field-by-field read of each (43 x that depth wasn't worth it for
a first pass - flagged individually below where something stood out).

## Region types (11 confirmed, via `Private.RegisterRegionType(...)` in each file)

| Type | File | Proven here? | One-line purpose |
|---|---|---|---|
| `icon` | Icon.lua | **Yes** - the scaffold's main region type | Spell/item icon with cooldown sweep, zoom, desaturate-when-unavailable, optional edge highlight. Fields: `width`/`height`, `color`, `desaturate`, `cooldown`/`cooldownEdge`, `zoom`, `iconSource`/`displayIcon`, plus shared position fields (`selfPoint`/`anchorPoint`/`xOffset`/`yOffset`). |
| `aurabar` | AuraBar.lua | **Yes** - resource/cast/swing bars | Fill/progress bar. Fields: `texture`/`textureSource` (LSM or manual picker), `orientation` (H/V), `barColor`/`barColor2` + `enableGradient`, `spark*` (a moving highlight at the fill edge - width/height/color/texture/blend/rotation), `backgroundColor`. **New finding:** aurabar can also show an attached icon (`icon`, `icon_side`, `icon_color` fields) - a bar with a built-in icon badge, not something we've used (we pair separate icon+bar elements instead). |
| `group` | Group.lua | **Yes** - `Template_shadow`'s envelope | Static container, no visual by itself besides optional `border`/`backdropColor` (confirmed live via the "central island" backdrop test). Holds `controlledChildren`. |
| `dynamicgroup` | DynamicGroup.lua | Designed, not yet built | Auto-arranging container. **Key finding relevant to the Buffs/Utility overflow design:** has native `useLimit`/`limit` fields (caps visible children) and `gridType`/`gridWidth`/`rowSpace`/`columnSpace` (grid layout mode - this is exactly the field set Luxthos Mage's real pack used, per `HUD_DESIGN.md`'s spacing evidence). Also has an undocumented-by-us circular layout mode (`radius`/`rotation`/`stepAngle`/`fullCircle`/`arcLength`) - a radial arrangement option we haven't considered. `grow` (UP/DOWN/etc.), `align`, `space`, `stagger`, `sort`, `animate` round out the linear-grow fields. Worth a second look before hand-building the buff/utility dynamic slots - a real `dynamicgroup` with `useLimit=6` might do natively what we're currently planning as 2 static + a hand-managed overflow. |
| `text` | Text.lua | Not yet used | Standalone text display, no icon/bar attached. `displayText` supports the dynamic-text codes below (`%p`/`%t`/`%n`/`%i`/`%s`). Has its own shadow/outline/wrap/fixed-width fields. |
| `texture` | Texture.lua | Not yet used | A single static or simple texture image (rotation/mirror, blend mode, desaturate) - simpler than `progresstexture`, no fill/progress behavior. Plausible fit for the Class Accent blocks currently built as plain icons. |
| `progresstexture` | ProgressTexture.lua | Not yet used | A **radial/pie or custom-crop progress fill** using foreground+background textures - `startAngle`/`endAngle` fields confirm genuine pie-timer support (not just rectangular bars). A real alternative shape for cooldown/cast display if a bar or icon-cooldown-sweep ever feels wrong for something. |
| `model` | Model.lua | Not yet used | Renders a real 3D model (M2 path or unit token), with `sequence`/`advance` (animation), `rotation`/`scale`, and its own `border`/`backdropColor`. Novelty/flavor register - no obvious HUD_DESIGN.md fit today, noted for completeness. |
| `stopmotion` | StopMotion.lua | Not yet used | Sprite-sheet flipbook animation (frame rate, rows/columns, loop vs. play-once). Niche - a hand-authored animated icon effect, not something this project has needed. |
| `empty` | Empty.lua | Not yet used | An invisible, resizable placeholder - just `width`/`height`/position. A legitimate "reserve this exact space, show nothing" element - could replace ad hoc invisible-icon placeholders if one is ever needed for pure layout spacing. |
| `fallback` | Text.lua (shares the file) | N/A | Internal - what WeakAuras substitutes when a real region type fails to load. Not a usable content type. |

## Sub-region types (9 confirmed - Background.lua registers two)

Sub-regions are decorative layers attached on top of a base region (already
used: `subglow` on Rotation/Power icons, `subborder`/backdrop on the
central-island test).

| Type | Attaches to | One-line purpose |
|---|---|---|
| `subbackground` / `subforeground` | anything except group/dynamicgroup; `subforeground` is `aurabar`-only | Structural layering hooks - no visuals of their own, just an anchor point for stacking other sub-regions behind/in front. |
| `subborder` | any | A lightweight border overlay, independent of Group's own built-in border - useful for outlining a single icon without wrapping it in a Group. |
| `subglow` | any (icon-style `buttonOverlay`/`ACShine`/`Proc` glow; `Pixel` glow for aurabar) | **Confirmed the exact 4 glow styles available: Autocast Shine, Pixel Glow, Action Button Glow, Proc Glow** (`Types.lua` line 3497) - directly answers what "glow/brighten in place" (HUD_DESIGN.md's Proc/Condition mechanism) can actually look like. `buttonOverlay` matches the standard action-bar proc look; worth trying `Proc` glow specifically since it's purpose-named for this. |
| `subtick` | any bar-capable region | **New finding, relevant to a known open gap:** places a marker line at a fixed value on a bar (`tick_placement_mode = "AtValue"`, e.g. "50"). This is a real, if partial, answer to `USE_CASE.md`'s "no resource-threshold opportunity type yet" - a tick can mark a fixed threshold visually on the resource bar even without a full alert/trigger built around it. |
| `subtext` | any | Text overlay with a different sensible default per parent: `%p` (progress) centered on an `icon`, `%n` (name) on a bar/other, anchored inner-right on aurabar or bottom-left elsewhere. This is the real mechanism for stack-count/name/timer text on top of Rotation/Power/Buff icons if that's ever wanted. |
| `submodel` / `substopmotion` / `subtexture` | matching base type | Sub-region equivalents of the Model/StopMotion/Texture region types above, for layering rather than as the base region. Not opened in depth - same niche/decorative status as their base-region counterparts. |

**Dynamic text codes, confirmed (`Prototypes.lua`'s `Private.dynamic_texts`,
~line 8875):** `%p` = progress (remaining time, formatted M:SS, or a static
value), `%t` = total/duration, `%n` = name, `%i` = icon (inline icon
texture code), `%s` = stack count. This is what any `text`/`subtext`
field's `%`-codes actually resolve to - not guessed, read directly from
the formatter functions.

## Trigger types (43 confirmed in `Prototypes.lua`'s `event_prototypes`, plus `aura2` in `BuffTrigger2.lua`)

Full catalog (line numbers in `Prototypes.lua`, for a future deeper pass):
Unit Characteristics (1622), Faction Reputation (1962), Experience (2132),
Health (2273), Power (2674), Combat Log (3157), Cooldown Progress/Spell
(3742), Cooldown Ready/Spell (4164), Charges Changed (4231), Cooldown
Progress/Item (4320), Cooldown Progress/Equipment Slot (4507), Cooldown
Ready/Item (4734), Cooldown Ready/Equipment Slot (4799), **GTFO** (4871),
Global Cooldown (4892), Swing Timer (4969), Action Usable (5079), Talent
Known (5286), Class/Spec (5386), Totem (5428), Item Count (5621),
Stance/Form/Aura (5757), Weapon Enchant (5866), Chat Message (6032), Spell
Cast Succeeded (6172), Ready Check (6248), Combat Events (6260), Encounter
Events (6285), Death Knight Rune (6364), Item Equipped (6580), Item Type
Equipped (6673), Equipment Set (6700), Threat Situation (6801), Crowd
Controlled (6991), **Cast** (7010, already confirmed live-relevant),
Character Stats (7528), Conditions (8059), Spell Known (8253), Pet
Behavior (8340), **Queued Action** (8415), Range Check (8459), Money
(8544), Currency (8612), Location (8745) - plus `aura2` (`BuffTrigger2.lua`,
the buff/debuff trigger already in active use via `showOnMissing`).

Confirmed already in use: Cooldown Progress (Spell), Cast, `aura2`.
Individually verified this pass (not just name-inferred): **GTFO Alert**
depends on the separate GTFO addon being installed (`GTFO_DISPLAY` event) -
a real third-party dependency, not a core-client capability, so it's
unusable unless that addon exists on the client. **Queued Action** detects
a spell staged via right-click-drag onto an action bar slot
(`IsCurrentSpell`) - niche, not obviously relevant to any tier. The
remaining ~38 are catalogued by name/line only this pass - accurate enough
to know they exist and roughly what they cover (Health/Power are unit
resource thresholds - directly relevant to the still-open "no
resource-threshold opportunity type yet" gap in `USE_CASE.md` and worth a
follow-up read before that gap gets tackled; Totem, Death Knight Rune,
Weapon Enchant are class/mechanic-specific state trackers relevant to
custom-class work later) - not individually field-verified.

**Swing Timer (4969) - individually verified (2026-07-06), and the
finding reverses an earlier assumption.** Read `Prototypes.lua` lines
4969-5030 directly against this project's real installed client
(`Interface/AddOns/WeakAuras` under `Ascension_wow`): it's a fully
**native, self-contained trigger type** - `type = "unit"`, internal event
`SWING_TIMER_UPDATE`, driven entirely by `WeakAuras.InitSwingTimer()` and
`WeakAuras.GetSwingTimerInfo(hand)`, both internal to the WeakAuras addon
itself. No external library referenced anywhere in the code. `hand` is a
`swing_types` dropdown (`Types.lua` line 2350) with three real values:
`main` (MAINHANDSLOT), `off` (SECONDARYHANDSLOT), `ranged` (RANGEDSLOT) -
full dual-wield support out of the box. WeakAuras' own UI even ships a
built-in honesty caveat as part of this trigger's options: *"Note: Due to
how complicated the swing timer behavior is and the lack of APIs from
Blizzard, results are inaccurate in edge cases."* This directly
contradicts the working assumption from checking a live Wago "[WotLK]
Swing Timer" pack (which stated a dependency on a separate SwingTimerAPI
addon by Ralgathor) - that pack's dependency is a legacy/author-preference
choice, not a technical requirement of this WeakAuras version. **No addon
beyond WeakAuras itself is needed to build a real swing timer** - see
`HUD_DESIGN.md`'s Resources-tier section and `IMPLEMENTATION_PLAN.md`,
both corrected accordingly.

## Animations (`Animations.lua` + `WeakAurasOptions\AnimationOptions.lua`)

Confirmed 5 independently animatable tracks, each with a start/main/finish
phase (per the settle-delay discussion) and a `*Type` (preset easing
function) or `custom` (hand-written function): **translate** (position -
already used for the buff/utility slide), **alpha** (fade), **scale**
(grow/shrink), **rotate**, **color** (tween between colors). Scale and
rotate are new findings - not yet used anywhere in this project, but both
are plausible extra tools for the Proc/Condition tier's "state change"
language if brightness/glow alone ever needs a second channel.

## Conditions (`Conditions.lua`)

Not a separate universal property catalog - confirmed it operates on
whatever a Region Type's own `properties`/`GetProperties()` table exposes
(the field lists inventoried above are exactly what a Condition can drive:
Icon's `color`/`desaturate`/`zoom`, etc.) plus any trigger `arg` explicitly
flagged `conditionType = ...` (e.g. GTFO's `alertType`). This confirms the
existing brightness/desaturate mechanism is the standard path, not a
special case.

**Update (2026-07-04) - the actual `conditions` field shape, confirmed
against a real captured example** (Battlewrath pasted a real single-icon
import string, "Multi-condition example"; decoded via `weakaura_codec.py`
- preserved as `REAL_MULTI_CONDITION_EXAMPLE_STRING` in that file). This
corrected a wrong guess `template_filler.py`'s glow-source mechanism had
been built on:

- `conditions` is a **list** of `{"changes": [...], "check": {...}}`
  objects - not a dict keyed by numbered condition-index strings the way
  `triggers` is keyed by trigger-index. Multiple conditions can coexist
  and target the same property (the real example had 4, all targeting the
  same glow property - "multiple glow conditions, of different types," per
  Battlewrath).
- A `changes` entry's `"property"` is `"sub.N.<field>"`, where N is the
  target subRegion's **1-based position in that aura's own `subRegions`
  array at build time** - not a fixed/assumed index. The real example's
  subRegions were `[subbackground, subtext, subglow]`, so its glow
  property was `sub.3.glow`; `template_filler.py` now computes this
  position dynamically per-template instead of hardcoding a number.
- A `"check"` can reference `trigger: -1` for a global/pseudo-check not
  tied to any of the aura's own numbered triggers (confirmed variables:
  `alwaystrue`, `attackabletarget`), or `trigger: N` for a real numbered
  trigger's own derived state (confirmed variables: `show`, `duration`,
  the latter paired with an explicit `"op"` key for the comparison).
- **Still not confirmed:** the real example only had ONE trigger, glowing
  off *that same trigger's* own `show`/`duration` state - it does not
  prove whether a genuinely second, independent trigger (`triggers[2]`,
  the actual glow-source use case - an unrelated ability's own proc/buff
  brightening a Rotation icon) drives a `show` check the identical way.
  `template_filler.py` builds that case by analogy from the now-confirmed
  syntax, flagged explicitly as inferred, not independently verified,
  until either a real two-trigger capture or a live test settles it.

**Update (2026-07-06) - the global-condition gap closed, via direct
source read, not the harness.** `Conditions.lua` itself (~1080 lines) is
a runtime condition-evaluation engine (builds/tests functions
dynamically against live region state) - genuinely out of scope for
`wa_lua_verify`'s execute-and-extract approach, same reason full game
API emulation was declared out of scope from the start. But one part of
it *is* a plain static table, no execution needed: `globalConditions`
(line 688), which `Private.GetGlobalConditions()` just returns as-is.
Full real list, six entries, not the four previously observed:
`incombat`, `hastarget`, `rangecheck`, `attackabletarget`,
`customcheck`, `alwaystrue`. This is now the exhaustive list of
*global* (not tied to any specific trigger) condition checks available
- closing this gap completely, not just narrowing it. Beyond these six,
a condition's `check` can also reference `trigger: N` and key off
whatever derived state fields that trigger's own prototype exposes
(e.g. Cast's `show`/`duration` from `Prototypes.lua`) - that part is
still per-trigger and not exhaustively catalogued, since it varies by
trigger type rather than being one fixed list.

## Built-in templates (`Templates.lua`) - corrected finding

**This file is not aura-content templates.** Despite the name, it turned
out to be generic UI-widget scaffolding for WeakAuras' own options panel
(nine-slice border frames, search-box behavior, input-box focus states) -
the original packet's assumption that this was a "quick-start template
library" was wrong, caught by actually opening the file rather than
trusting the filename. WeakAuras' real new-aura template/wizard UI (if
one exists in this build) would live in `WeakAurasOptions\`, which is out
of this inventory's declared scope. Not pursued further this pass - if
built-in templates matter later, that's a `WeakAurasOptions` question, not
a `WeakAuras` core one.

## What this changes for phase 2 / phase 3

Two findings are worth acting on before phase 2 starts, not just filing away:
- **`dynamicgroup`'s native `useLimit`/`limit` field** may let the
  Buffs/Utility dynamic overflow be built as one real dynamic group capped
  at 4, instead of hand-managing "which of N missing items currently
  shows" - worth checking against `BuffTrigger2.lua`'s actual behavior
  before the overflow gets built for real.
- **`subtick`** gives a partial, already-available answer to the
  resource-threshold alert gap - a visual marker at a fixed bar value,
  buildable today without waiting on a new opportunity-type classification.
