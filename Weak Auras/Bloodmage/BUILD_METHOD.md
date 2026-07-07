# Build method - Bloodmage

Mirrors `Necromancer/BUILD_METHOD.md` and `Reaper/BUILD_METHOD.md` exactly
- same seven-step `AURA_BLUEPRINT.md` method, same `theme.json` /
`Bloodmage_fantasy_playstyle.md` / `spell_index.md` / `slot_assignment.md` /
`inventory.py` file set, same `layer_builder.py` + `Templates/` pipeline.
Not re-explained in full here; see `Necromancer/BUILD_METHOD.md` for the
complete rationale and `../AGENT_ROLES.md` for the class-implementer
workflow this folder is scaffolded for. This file only records what's
specific to Bloodmage.

## Why this folder exists now (2026-07-07)

Battlewrath: "I'm going to play blood mage for a while... Do you want to
seed the file... we can do the fantasy exploring with that agent. I just
need the folder structure, instructions and files setting up."

Explicit two-phase split for this class:
1. **This pass (scaffolding only)** - create the folder, populate anything
   that's just plumbing/already-confirmed fact (accent color, file
   pointers, spec names), and stop. No fantasy synthesis, no spell_index
   content, no slot_assignment content, no inventory.py slots - those all
   require actually reading and reasoning about the real source data, which
   Battlewrath explicitly deferred.
2. **A later class-implementer agent pass** - follows `../AGENT_ROLES.md`'s
   "class implementer" role exactly, starting with
   `Bloodmage_fantasy_playstyle.md` (per that doc's step 1: write the
   fantasy/playstyle doc BEFORE spell_index.md/slot_assignment.md, so
   slot-priority decisions have something to reason against).

**Do not skip step 1's ordering.** `theme.json`'s `fantasy_mechanic` field
is deliberately left as an unverified placeholder (Battlewrath's verbal
steer only: "uses their own life as a resource as well as mana and such")
- that is a hint for where to start reading, not a confirmed mechanic to
build against.

## Real source data already available (found, not yet read in full)

Unlike Necromancer/Reaper's first sessions, Bloodmage already has scraped
source data sitting in this project from earlier work, same convention as
every other class:
- `Input/bloodmage_talents.json` - raw talent export.
- `Outputs/readouts/bloodmage_readout.md` - the skill-investment readout
  (confirmed: 4 specs - **Accursed**, **Eternal**, **Fleshweaver**,
  **Sanguine** - each folded together with the class tree, same format as
  every other `*_readout.md`).
- `Outputs/skill_indices/bloodmage_skill_index.json` - the full per-skill
  index (123 skills indexed, `class: "Bloodmage"`, same schema as
  `reaper_skill_index.json`/`necromancer_skill_index.json`). Skimmed only
  far enough to confirm structure and spot two recurring RESOURCE-tagged
  skills (`Mortal Form`, `Pooled Vitality`) that look like candidates for
  Battlewrath's "own life as a resource" steer - NOT read in depth, NOT
  confirmed as the actual mechanism.
- `Outputs/readout_html/bloodmage_readout.html` - source of the confirmed
  accent color (`--accent: #c66161`).
- `Outputs/Archive/bloodmage_reference.html` and
  `Outputs/Archive/bloodmage_tree_display.md` - older archived scrapes:
  flagged as existing but NOT used as the source for anything in this
  folder - `Outputs/readouts/`/`Outputs/skill_indices/` are the current,
  actively-maintained data shape every other class folder points at.

## Escalation flag - RESOLVED (health-as-a-resource is just a bar)

Battlewrath pushed back on an earlier over-complicated framing of this:
"Well. It is just a bar, no? That tracks HP." That pushback was correct,
confirmed by direct source read (not assumption) of the real installed
client addon at
`Interface/AddOns/WeakAuras/Prototypes.lua`/`RegionTypes/RegionPrototype.lua`:

- **A native "Health" unit-event trigger already exists** in
  `Prototypes.lua` (`~line 2273`), parallel to the already-proven "Power"
  trigger `resource_threshold_aurabar` uses: `type = "unit"`,
  `progressType = "static"`, watches `UNIT_HEALTH`/`UNIT_MAXHEALTH`, exposes
  `value`/`total`/`percenthealth`/`deficit`/`maxhealth`. Same shape, just
  `event = "Health"` instead of `event = "Power"` and no `powertype` field.
- **The "top 50%" clamp is also already native**, no custom trigger or Lua
  needed. `RegionTypes/RegionPrototype.lua` (`~line 368-796`) shows
  `adjustedMin`/`useAdjustededMin` (already present, currently unused, in
  `RESOURCE_THRESHOLD_AURABAR_TEMPLATE`) accept a percent string like
  `"50%"`, stored as `adjustedMinRelPercent = 50/100` and applied at render
  as `adjustMin = adjustedMinRelPercent * total`. Setting
  `adjustedMin = "50%"`, `useAdjustededMin = true` on a Health-trigger bar
  makes it empty at 50% HP and full at 100% HP - exactly "HP we can afford
  to lose/use" - with zero new mechanism.

**Conclusion: this is a small, low-risk sibling of `resource_threshold_aurabar`
(new `event`/no `powertype`, existing `adjustedMin` field turned on), not a
new escalation-worthy primitive.** Not a "Fragment" either (fragments are
attachable annotations, not primary bar values) - it's bespoke content built
from an already-proven template shape, same as every other class's
Resources tier. Still core-maintainer territory to add the sibling
schema/template to `Templates/build_templates.py` if `resources_base.py`
gets a matching `health_slot()`-style builder, but it does not require new
source investigation, a Custom/stateupdate trigger, or a gap report.

### Upgraded to REAL-CAPTURE confirmed (2026-07-07, same day)

Battlewrath pasted a real `!WA:2!...` export string, decoded here with this
project's own `weakaura_codec.py`. It is a real, hand-built aurabar, `id:
"Bloodmage_hp_resouece_50-100%"`, `uid: "d4mA)3j847u"` - and it matches the
source-read conclusion above field-for-field: `regionType: "aurabar"`,
trigger `type: "unit"`, `event: "Health"`, `unit: "player"`,
`useAdjustededMin: true`, `useAdjustededMax: true`, subtext showing
`%1.percenthealth`. This is no longer just a source-code inference - it is
now a live-confirmed build, same evidentiary bar as Reaper's Soul Fragment
capture.

**One real bug worth flagging back**: the captured `adjustedMin`/
`adjustedMax` values are the plain strings `"50"`/`"100"`, with no `%`
suffix. Per `RegionPrototype.lua`'s `SetAdjustedMin`/`SetAdjustedMax`
(`~line 368-387`), a trailing `%` is what makes WeakAuras treat the value
as *relative to max* (`adjustedMinRelPercent = 50/100`, applied as
`adjustedMinRelPercent * total`); without it, WeakAuras stores a literal
absolute value (`adjustedMin = 50`, i.e. "clamp range starts at 50 raw
hit points"). For a real character with a max health in the thousands,
that reads as "always full" or "always empty" depending on current HP, not
"top 50% of max health." The id (`50-100%`) suggests `"50%"`/`"100%"` was
the intent - the fields just need the `%` added (`adjustedMin: "50%"`,
`adjustedMax: "100%"`) to get the relative-to-max behavior this doc
describes above.

### FORMALIZED as a core capability (2026-07-09) - no longer just a finding

Battlewrath: "I'd formalize the health side as a capability. Then the
class agent can work from there. We already stated they shouldn't be
injecting class needs up stream. It comes between us as a primitive
capability first." Done at the core layer, same treatment every other
proven mechanism in this project gets before a class consumes it:

- `Templates/build_templates.py` now has `HEALTH_RANGE_AURABAR_SCHEMA`/
  `_TEMPLATE` (opportunity_type `health_range`), registered in `REGISTRY`
  right after `resource_threshold_aurabar`. Trigger is the minimal,
  functionally-necessary `{type: "unit", event: "Health", unit: "player"}`
  (the real capture's inert leftover fields trimmed, same treatment
  `resource_threshold_aurabar`'s own Power trigger already got).
- `Tiers/resources_base.py` now has `health_slot(name, min_percent,
  max_percent, position, bar_color=None)` - takes PLAIN NUMBERS (50, 100),
  not pre-suffixed strings, and appends the `%` itself, making the exact
  bug found above structurally impossible for any class using it rather
  than relying on each class remembering to type `%` by hand.
- No `template_filler.py` changes were needed - the existing generic
  `bar_color` override (not gated by template name) and placeholder
  substitution already cover this template fully.
- Regenerated via `write_all()` (18 template pairs now, up from 17),
  test-filled with `health_slot("Bloodmage_hp_resouece_50-100%", 50, 100,
  CLASS_RESOURCE_POS, bar_color=<accent>)`, and round-trip verified
  through `weakaura_codec.py` (encode -> decode matches, modulo the
  codec's own already-documented empty-dict-vs-list normalization quirk
  shared by every template, not something new here). Output correctly
  shows `adjustedMin: "50%"`, `adjustedMax: "100%"` - the `%`-suffix bug
  fixed structurally, not just noted.

This is now listed in `../AGENT_ROLES.md`'s "What's already proven and
safe to reuse without any escalation" - a class-implementer agent building
Bloodmage's real Resources tier can call `rb.health_slot(...)` directly,
same as `rb.resource_slot(...)`, with no further core-layer work or
escalation needed for this specific mechanism. Nothing in Bloodmage's own
`inventory.py` LAYERS has been filled in yet, though - that's still
deferred to the class-implementer pass per this file's own two-phase
split above.

## Rage confirmed present (not Mana)

Battlewrath corrected the initial assumption directly: "the other energy is
rage, not mana." Confirmed against `bloodmage_skill_index.json`'s "Pooled
Vitality" skill entry: "Mortal Form spells that cost **Rage** consume 10
stacks of Pooled Vitality to become empowered" (via the "Unchained"/
Fleshweaver-tree talent text). So Bloodmage's `CLASS_ENERGY_POS` slot is a
standard `resource_slot(..., POWERTYPE_RAGE, ...)`, same mechanism already
proven elsewhere in this project - not Mana.

## Mask is still the sole source of truth for position

Same reaffirmation as Necromancer's and Reaper's own files:
`Tiers/resources_base.py`'s `CLASS_RESOURCE_POS`/etc. are what
`inventory.py` always reads from - never a live in-game capture, and never
invented per-class geometry.
