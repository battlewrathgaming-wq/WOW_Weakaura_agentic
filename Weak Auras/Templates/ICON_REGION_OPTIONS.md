# Icon region: the full option catalogue

Built 2026-07-06, in response to Battlewrath's ask: to be able to say
"let's do a Tier 1 (Rotation) spell icon" and have the reasoning about
*what that icon can be configured to do* come from the real emulation
data, not be improvised per element - so building a new HUD element
becomes a choice from known options, not a fresh design exercise each
time.

**Everything below is read directly from the real, installed addon
source** (`RegionTypes/Icon.lua`, `RegionTypes/RegionPrototype.lua`,
and `SubRegionTypes/*.lua` via `wa_lua_verify`'s Lua 5.1 harness - see
`wa_lua_verify/README.md`) - not hand-recalled or assumed. Where a field
comes from real live-tested/exported WeakAuras data rather than the
emulation alone, it's marked **(live-confirmed)**.

## 1. Base region - every `type: icon` aura has these

From `RegionTypes/Icon.lua`'s own `default` table, plus what
`RegionPrototype.lua`'s `AddAlphaToDefault`/`AddProgressSourceToDefault`
mix in (shared by every region type, not icon-specific):

| Field | Default | What it is |
|---|---|---|
| `icon` | `true` | Whether the icon texture itself renders (used `false` briefly in this project's own Cast Bar/Swing Timer work, then reverted - see `slot_assignment.md` change log) |
| `desaturate` | `false` | Grayscale the icon |
| `iconSource` | `-1` | Where the icon texture comes from (trigger-provided vs manual) |
| `displayIcon` | - | Manual icon override (only meaningful if `iconSource` picks manual) |
| `progressSource` | `{-1, ""}` | Which trigger value drives cooldown/progress display |
| `adjustedMin` / `adjustedMax` | `""` | Manual override of progress min/max |
| `useAdjustededMin` / `useAdjustededMax` | `false` | Whether the override above is active |
| `inverse` | `false` | Flip progress direction |
| `width` / `height` | `64` / `64` | Icon size |
| `color` | `[1,1,1,1]` | Tint |
| `selfPoint` / `anchorPoint` | `"CENTER"` | Anchoring |
| `anchorFrameType` | `"SCREEN"` | What the anchor point is relative to |
| `xOffset` / `yOffset` | `0` | Position offset |
| `zoom` | `0` | Crop-in on the icon texture (0-1) |
| `keepAspectRatio` | `false` | - |
| `frameStrata` | `1` | - |
| `cooldown` | `true` | Whether the stock cooldown swipe renders |
| `cooldownEdge` | `false` | Whether the cooldown swipe shows a bright edge line |
| `alpha` | `1.0` | Region opacity |

## 2. Configurable properties (the actual "knobs")

These are the fields a person (or a template) can actually set/expose,
per `Icon.lua`'s own `properties` table plus the shared ones
`RegionPrototype.AddProperties` adds to every region type:

**Icon-specific:**

| Property | Type | Range / values |
|---|---|---|
| `desaturate` | bool | - |
| `width` / `height` | number | 1 to screen size |
| `color` | color | - |
| `inverse` | bool | - |
| `cooldown` | bool | - |
| `cooldownEdge` | bool | - |
| `zoom` | number (percent) | 0-1 |
| `iconSource` | list | populated per-trigger at runtime |
| `displayIcon` | icon picker | - |

**Shared across all region types (icon included):**

| Property | Type | Notes |
|---|---|---|
| `sound` | sound | Plays a sound on trigger state change |
| `chat` | chat | Sends a chat message |
| `customcode` | customcode | Runs arbitrary Lua - escape hatch, not a fixed option |
| `xOffsetRelative` / `yOffsetRelative` | number | Position offset relative to anchor |
| `glowexternal` | glowexternal | Makes this aura glow a *different*, external UI element (e.g. an action bar button) - notably different from the `subglow` subRegion below, which glows this element itself |
| `alpha` | number (percent) | Region opacity (only added because `Icon.lua` sets `default.alpha`) |
| `progressSource` / `adjustedMin` / `adjustedMax` | progressSource / string | Only added because `Icon.lua` sets `default.progressSource` - ties back to section 1 |

## 3. SubRegion attachment menu - the "decorations" you can add

An icon region's `subRegions` list can include zero or more of these.
Each is validated against the real `default()` table for the `"icon"`
parentType specifically (several of these types render differently, or
omit fields entirely, when attached to an `aurabar` instead - see each
type's own note).

### `subbackground` / `subforeground`
- **Fields:** none (`{}` - purely a rendering-order slot, all visuals come from the base icon texture/color).
- **Use for a rotation icon:** not typically needed - Cast Bar/Swing Timer use these because they're aurabars with a literal bar texture to layer; an icon doesn't have that same texture-layering need.

### `subborder` - a decorative border around the icon
- **Fields (icon variant):** `border_size` (default `2`), `border_color` (`[1,1,1,1]`), `border_visible` (`true`), `border_edge` (`"Square Full White"`), `border_offset` (`0`). No `anchor_area` (that's aurabar-only).
- **(live-confirmed)** via `Test_Board_validation` export - real field set matches exactly.
- **Use for a rotation icon:** yes - this is the natural way to mark an ability as "ready now" vs "on cooldown," or to give it a class-accent-colored frame consistent with `class_accent_tick_end`'s design language elsewhere in the HUD.

### `subglow` - a glow effect on the icon itself
- **Fields (icon variant):** `glowType` defaults to `"buttonOverlay"` (vs `"Pixel"` for aurabar), `glowColor` (`[1,1,1,1]`), `glowLines`, `glowFrequency`, `glowLength`, `glowThickness`, `glowScale`, `glowDuration`, `useGlowColor`, `glow`/`glowBorder` (both `false` until enabled). No `anchor_area`.
- **Use for a rotation icon:** yes - the standard "this is ready to use / procced" pulse. This is the type `cooldown_tracker_icon.template.json` already uses; its previously-flagged "missing `anchor_area`" gap is resolved by this data (icon variant doesn't have that field - not a bug).

### `subtexture` - an arbitrary extra texture layered on the icon
- **Fields (icon variant):** `anchor_area: "ALL"` (vs `"bar"` for aurabar), `textureTexture` (defaults to a stock Power Auras aura texture), `textureColor`, `textureBlendMode`, scale/rotation/mirror flags, `width`/`height` (`32`/`32`).
- **Use for a rotation icon:** situational - useful for a custom overlay icon/symbol (e.g. a small "interrupt" glyph), not needed for a plain rotation-priority icon.

### `subtext` - a text label on the icon
- **Fields (icon variant):** `anchor_point: "CENTER"`, `text_text` defaulting to `"%p"`, `text_fontType: "OUTLINE"`, `text_justify: "CENTER"`, `text_automaticWidth`/`text_fixedWidth`/`text_wordWrap` (all confirmed real fields, per the Cast Bar sync), plus shadow/color fields. (`text_font`/`text_fontSize` are resolved via LibSharedMedia at runtime - the harness can't reach that, so treat those two as "pick a real font/size," not a literal default to copy.)
- **Use for a rotation icon:** yes - most commonly a cooldown-remaining number (`%c`/`%d`-style dynamic text) or a stack count.
- **Note:** `subtext:aurabar` defaults to `%n` (name) instead - a reminder that copying a subtext fragment between an aurabar template and an icon template needs its `text_text` reconsidered, not just carried over.

### `submodel` - a 3D model overlay
- **Fields:** `model_path` (defaults to a stock Arthas Lich King model - a placeholder, not meaningful), `model_x`/`model_y`/`model_z`, `rotation`, `model_alpha`, `model_visible`, `bar_model_clip`. No parentType branching.
- **Use for a rotation icon:** not validated live yet, and not an obvious fit for this project's flat, readable HUD style (this project's own `HUD_DESIGN.md` favors clean icon+glow+border over 3D ornamentation) - flagging as available, not recommending it.

### `substopmotion` - a frame-by-frame sprite-sheet animation overlay
- **Fields (icon variant):** the largest field set of any subRegion type - `customColumns`/`customRows`/`customFrames`, `customFrameWidth`/`customFrameHeight`, `frameRate`, `animationType`, `startPercent`/`endPercent`, `progressSource`, `stopmotionTexture` (defaults to a stock "ArcReactor" sprite sheet), blend/color/desaturate flags, `anchor_area: "ALL"` (vs `"bar"` for aurabar).
- **Use for a rotation icon:** not validated live, and a heavier visual effect than this project's HUD style calls for so far - available if a specific ability ever wants an animated proc effect, not a default choice.

## 4. How this gets used

For any new `type: icon` element, building it is now a matter of:

1. Pick the base fields that differ from default (size, position, `cooldown`/`cooldownEdge` on or off, `zoom` if cropping the icon).
2. Pick zero or more subRegion attachments from section 3 - each is a
   known-good, real-field-verified fragment, the same pattern
   `class_accent_tick_end` already established for subtick.
3. Only reach for `customcode`/`submodel`/`substopmotion` when a
   specific, concrete need calls for it - these are the "escape hatch"
   / heavier-weight options, not defaults.

This replaces re-deriving an icon element's options from scratch each
time with choosing from a fixed, real menu - the procedural approach
Battlewrath asked for.

## 5. Worked example - "let's do a Tier 1 (Rotation) spell icon"

Demonstrating the choice process end to end, using this catalogue - not
a real build yet (Rotation tier positions/geometry are still open per
`slot_assignment.md`'s Not-in-this-tier / change-log notes). This is
what reasoning "from the emulation" looks like in practice:

**Base region choices:**
- `cooldown: true` - keep the stock cooldown swipe. A rotation-priority
  icon still benefits from the native "time left" sweep, the same
  reasoning that kept Swing Timer/Cast Bar's built-in timer text instead
  of reinventing it.
- `cooldownEdge: false` - matches every other built element so far; no
  precedent yet for turning this on.
- `desaturate` - left at its static default (`false`) here, but this is
  the natural field to drive with a **Condition** (WeakAuras' separate
  state-reactive system, not a subRegion) - e.g. desaturate when the
  ability is on cooldown, full color when ready. Worth flagging clearly:
  this option catalogue covers static default fields; anything that
  needs to *change* with game state layers a Condition on top of one of
  these fields, it doesn't get a different field.
- `width`/`height` - would follow whatever Tier 1's actual slot geometry
  ends up being (not yet fixed), not a new decision this catalogue makes.

**SubRegion attachments chosen:**
- `subborder` - yes. A class-accent-colored border (`theme.json`'s
  `#45db9c` / `[0.2706, 0.8588, 0.6118, 1.0]`) reuses the same design
  language as `class_accent_tick_end` elsewhere in the HUD, giving the
  whole UI a consistent visual vocabulary rather than a one-off look for
  this element.
- `subglow` - yes, `glowType: "buttonOverlay"` (the real icon default -
  no reason to override it), `glowColor` set to the same class accent,
  driven by a Condition to pulse when the ability comes off cooldown or
  becomes the priority pick.
- `subtext` - yes, but with `text_text` changed from the real default
  `"%p"` to a cooldown-remaining or stack-count format string - the
  point flagged in section 3 that a subtext fragment's `text_text`
  always needs reconsidering per use, not blindly copied.
- `subtexture`, `submodel`, `substopmotion` - not chosen, per section 3's
  own notes: heavier-weight effects this project's flat HUD style hasn't
  called for anywhere else yet.

**What's still a real decision, not a catalogue lookup:** which spell(s)
occupy this slot, the exact Condition logic (what "ready"/"priority"
means for this ability), and the slot's actual screen position - none of
that is something the option catalogue can answer; it only answers *what
the icon element is capable of being configured to do*.

## Cross-references

- `wa_lua_verify/README.md` - the tool this data comes from, and its
  known limitations (official Lua 5.1 vs Blizzard's patched client Lua;
  LibSharedMedia-resolved fields like `text_font` aren't reachable).
- `CLAUDE.md` - the guardrail on treating emulation output as a fast
  pre-check, not ground truth, for genuinely novel findings.
- `Necromancer/slot_assignment.md` - the `cooldown_tracker_icon`
  `subglow`/`anchor_area` open item, now resolved by section 3 above.
