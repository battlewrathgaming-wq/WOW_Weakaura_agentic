# Reaper spell index (Resources tier)

A pointer index, not a copy - same principle as Necromancer's own
`spell_index.md`. Scope: only the Resources-tier content actually built so
far (Soul Fragment, Runic Power) - not a full class ability index.
`Outputs/skill_indices/reaper_skill_index.json` and
`Outputs/readout_html/reaper_readout.html` remain the actual full sources.

## Soul Fragment (805077)

The gap this project's Resources-tier tracker actually fills: Reaper
already has a native in-game UI element for **Reaped Souls** (the capped,
visible stack resource itself - per Battlewrath, "there already is a UI
element that shows us the resource"), but nothing shows the underlying
**Soul Fragment** mechanic feeding it - a fragment stacks to 3, each with
its own time-to-live, and reaching 3 converts into 1 Reaped Soul. Per
Battlewrath: "it is; (seconds) to get 3 soul fragments = 1 reaped soul. We
could display that there. Time remaining on soul fragment + stack count."

- **Spell ID**: 805077 (confirmed directly by Battlewrath, correcting an
  earlier typo of 605077: "805077 is actual.")
- **Stacks to 3**, sub-3 time-to-live per fragment (Battlewrath, live
  observation - not yet independently found as an explicit duration value
  in `reaper_skill_index.json`, which describes the mechanic's talent
  interactions but not a raw TTL number).
- **Generation is talent-gated, not baseline** - confirmed via
  `Outputs/skill_indices/reaper_skill_index.json`'s "Soul Fragment" entry:
  `isBaseAbilityInTree: false`, `baseDescription: null` - the earliest
  source found is the Domination tree's **Soulsight** talent ("dealing
  direct damage now has a 15% chance to generate a Soul Fragment"), with
  further talents (**Shudder Scythe**, replacing Murder: "granting you a
  Soul Fragment with each strike") adding more generation. This is WHY the
  tracker needs `show_when_missing` (see `slot_assignment.md`) - the
  underlying mechanic may not even be active yet for a given talent build,
  and the element should still hold its Resources-tier footprint rather
  than vanish from the layout.
- **Prototype built and live-tested directly by Battlewrath** (not
  authored from this project's templates first) - see
  `Necromancer/_soulfrag_prototype_raw.txt` (kept in the Necromancer
  folder as the historical capture location; Soul Fragment itself is a
  Reaper element). Decoded real values: `barColor` `[0.0902, 0.580,
  0.431, 1]` (a muted teal-green, close to but not identical to Reaper's
  own theme accent `#0a876b` - kept as the real evidenced value rather
  than swapped for the theme color), trigger `aura2` /
  `auraspellids: ["805077"]`, position matching the OLD pre-divider-strip
  Resources geometry (superseded - this build uses
  `Tiers/resources_base.py`'s current `CLASS_RESOURCE_POS`).
- **Residual "0" bug (diagnosed 2026-07-09, Necromancer/slot_assignment.md
  has the full trail)**: NOT a Soul Fragment defect - was the OLD Mana bar
  aura still present at the identical screen coordinates. Not relevant to
  this class's own build (Reaper's Resources tier has no Mana slot at
  all - Soul Fragment occupies that vacated address instead).
- **Footprint-when-idle fix**: Battlewrath's own live-tested "anti
  statement" second-trigger fix ("Yes that fixed it") - formalized as
  `buff_uptime_aurabar`'s `show_when_missing` param
  (`Templates/build_templates.py`). Does NOT restore the permanent
  end-cap tick (a separate, since-abandoned mechanism, replaced by
  `Tiers/resources_base.py`'s `divider_strip_slot` instead - see that
  file's own docstring).
- **Stack count subtext**: requested by Battlewrath ("Time remaining on
  soul fragment + stack count") but absent from the real captured
  prototype at the time it was built - formalized as `buff_uptime_
  aurabar`'s `show_stacks` param, not yet independently live-tested (the
  underlying `state.stacks` mechanism IS already proven elsewhere, on
  `minion_presence_icon`).

## Tormented Souls (500483) / its granted buff (500481)

Tank defensive, built into the Tier 1 Rotation slot despite the "defensive"
framing - Battlewrath: "Tormented soul, is a tank defensive, but fits in
the rotation." Consumes Reaped Souls (per Reaped Souls' own real
description, `Outputs/skill_indices/reaper_skill_index.json`: "Consumes
Reaped Souls and Soul Infusion... Reduces all direct damage you take by
-10% and heals you for 35 + 5.8% AP + 24% Stamina, removing 1 stack.
Lasts 20 seconds"), granting a stacking self-buff on use.

- **Ability spell ID**: 500483 (the thing you press - resource+cooldown
  gated, not cooldown-only). **Granted buff spell ID**: 500481 (applied to
  self when used, carries the stack count and 20s duration). Both
  confirmed directly by decoding Battlewrath's real, hand-built and
  live-tested "Tormented Souls" WeakAuras export (v3) via
  `weakaura_codec.py` - see `Templates/build_templates.py`'s
  `RESOURCE_SPENDER_ICON_SCHEMA` for the full field-level trail. No prior
  entry existed for either ID in this file or in
  `reaper_skill_index.json` (both abilities have `isBaseAbilityInTree:
  false`, no `spellId` field in the index itself - these numbers came
  from the live in-game export, not the skill index).
- **Formalized as `resource_spender_icon`** (Templates/build_templates.py,
  2026-07-10) - the first Class IV capability in `Templates/
  CAPABILITY_COMPLEXITY.md`'s taxonomy: a self-contained "spender + its
  own resulting buff timer," combining an Action Usable ready/cooldown
  pair (the spend gate) with the existing `glow_source` (`buff_uptime`)
  mechanism (the granted buff's own tracked lifecycle) in one aura, no
  companion aura needed. Not yet re-built through the formal template
  pipeline in Reaper's own `inventory.py`/Tier 1 Rotation slot - the
  live-tested hand-built version is what's actually equipped in-game
  today; the template exists so the NEXT similar ability (any other
  reagent-gated spender with its own resulting effect) doesn't have to be
  hand-built and reverse-engineered the same way.

## Soul Infusion (803031) - empowerment buff on Tormented Souls

A self-contained resource-threshold empowerment: reaching 3 Reaped Souls
grants Soul Infusion, which gives spenders (including Tormented Souls
itself) an additional effect. Battlewrath: "I've found a way to self
contain a threshold resource amount on the same item. When reaper hits 3
reaped souls, they get soul enfusion, that makes spenders have an
additional effect. So now the icon has a subtle texture that shows it's
empowered."

- **Spell ID**: 803031 - confirmed directly by decoding Battlewrath's real,
  hand-built and live-tested "Tormented Souls" v4 WeakAuras export via
  `weakaura_codec.py`. No prior entry existed for this ID in this file or
  in `reaper_skill_index.json`.
- **Formalized as `glow_source`'s third `opportunity_type`,
  `external_empower`** (`Templates/build_templates.py`, 2026-07-10, second
  pass same day) - an aura2 presence check on the empowering buff, paired
  with a declarative `subtexture` visibility toggle (both true/false states
  explicit, since this subRegion's own baseline is visible). Deliberately
  distinct from `buff_uptime`'s `glowexternal` border glow: Battlewrath's
  own framing - "rather than being flashy for attention... less dramatics,
  but gives you reference to wait for that state." The visual signal is a
  quiet ambient texture overlay (PowerAurasMedia Aura1, ADD blend, bright
  cyan `[0.012, 1, 0.847, 1]` - the empowering buff's own visual identity,
  not Reaper's theme accent), not an attention-grabbing effect.
- **Proves `glow_source`'s multi-entry case is real, not theoretical**: the
  real v4 build stacks this `external_empower` entry ALONGSIDE the existing
  `buff_uptime` entry (Tormented Souls' own granted buff) on the SAME
  `resource_spender_icon` - two independent signals, one icon. Fixed a
  real, previously-latent limitation in `template_filler.py` (was
  hardcoded to `glow_source[0]` only) - now loops over every entry. See
  `Templates/CAPABILITY_COMPLEXITY.md`'s "Stacking within a class" section
  and `glow_source.schema.json`'s "verified" field for the full trail.
- **`useStacks`/`stacksOperator`/`stacks` fields deliberately NOT
  reproduced** in the formalized trigger - Battlewrath's own words,
  "canceling out conditions," describing these as a neutralized
  WeakAuras-UI artifact (trivially true for a non-stacking buff, not real
  filtering). A plain aura2 presence check achieves the identical result
  here and avoids a latent bug for any future empowering buff that
  genuinely stacks past 1.
- **Broader design note (not yet acted on)**: Battlewrath's own framing
  after seeing this work end to end - "it gives me some framing to
  consider some of Necro's current slots. Basically - we can do more with
  them. And limit the overall UI space we need to try to display. As
  opposed to layering signals." Worth revisiting for Necromancer slots
  that currently use separate icons/auras for related state, if a future
  session is asked to consolidate them.

## Murder (502679) / target debuff check (560421)

Rotation-tier icon, color-coded purple as an "offensive tracker." Per
Battlewrath: "This checks if my target has my debuff on it. This is not a
DOT tracker in the broad sense. More a condition checker." A boolean
presence check, not a duration/countdown display.

- **Ability spell ID**: 502679 (Cooldown Progress trigger, standard
  Rotation-tier ready/cooldown icon). **Debuff checked**: 560421 - a debuff
  the player applies to the target, checked via `unit: "target"` (the
  first aura2 trigger in this project to use `unit: "target"` rather than
  `unit: "player"` - every prior aura2 trigger tracked the player's own
  aura list; here the presence check reads the TARGET's aura list instead,
  even though `ownOnly: true` still scopes it to a debuff the player
  personally applied).
- **Formalized as `glow_source`'s fourth `opportunity_type`,
  `target_debuff_presence`** (`Templates/build_templates.py`, 2026-07-10,
  third pass same day) - decoded directly from Battlewrath's real,
  live-built and live-tested Murder export via `weakaura_codec.py`.
- **Purple color-coding convention**: `glowColor` `[0.4, 0.0235, 0.7686,
  1]` - Battlewrath's own stated color for an "offensive tracker" signal,
  distinct from Soul Infusion's cyan (the empowering buff's own visual
  identity) and from any class's own theme accent. Establishes purple as
  this project's convention for "target has my debuff" checks generally,
  not just for Murder specifically.
- **Mechanism simplification, applies project-wide going forward**:
  Battlewrath's own framing - "I didn't know I can declare an internal
  glow effect, so I used the external and pointed it on it's self. I've
  since learned about making a glow, internal, but turned off. And then a
  condition turning it onto visible." The real Murder capture proves an
  ordinary INTERNAL subglow subRegion (glowType 'Pixel', useGlowColor
  true, a custom glowColor) can be toggled via the same declarative
  `sub.N.glow` Condition `proc_alert` already uses - a SINGLE Condition,
  no paired hide needed (auto-revert, confirmed by the real capture having
  only one condition for this signal). This is simpler than `buff_uptime`'s
  `glowexternal` mechanism (no frame-selector self-targeting, no imperative
  glow_action pair) - kept as a documented alternative rather than
  retroactively rewriting Tormented Souls' own already-shipped
  `glowexternal` build; future border-glow confirmation signals should
  default to this simpler internal-subglow approach unless a real reason
  favors `glowexternal` specifically. See `glow_source.schema.json`'s
  "verified" field for the full trail.

## Runic Power (spender resource)

Shares `Tiers/resources_base.py`'s generic `resource_slot()` builder and
the confirmed real WoW `PowerType` enum value (6) - same mechanism
already live-tested for Necromancer's own Runic Power bar. Reaper's own
per-ability Runic Power spend/generation list (Dirge, Murder, Slaughter,
etc.) has not been indexed here - not needed for a plain Power-status bar,
same scoping call already made for Necromancer's Resources tier.

## Reaped Soul - deliberately NOT tracked here

Per this file's own opening note: Reaped Souls already have a native
in-game UI element. Same "don't compete with an existing native display"
principle already established for Necromancer's Life Force
(`Necromancer/BUILD_METHOD.md`'s "Open items" section) - noted here so a
future agent doesn't accidentally rebuild a duplicate tracker.
