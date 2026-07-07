# Bloodmage spell index (Resources tier)

A pointer index, not a copy - same principle as `Necromancer/
spell_index.md` and `Reaper/spell_index.md`. Scope: only the Resources-tier
content actually built so far (Health-as-resource, Rage) - NOT a full class
ability dump. The real full sources remain
`Outputs/skill_indices/bloodmage_skill_index.json` (123 skills),
`Outputs/readouts/bloodmage_readout.md` (4 specs), and
`Input/bloodmage_talents.json`.

## Health-as-resource ("HP Reserve", top 50%-100% of max HP)

The class's defining mechanic and its primary-resource-slot content. Not a
spell ID - a native `Health` unit trigger, no ability to reference.

- **What it tracks:** the player's own health, displayed as a bar clamped
  to the **top half** of max HP (`adjustedMin: "50%"`, `adjustedMax:
  "100%"`) - full at 100% HP, empty at 50% HP. Reads as "the life you can
  afford to spend," matching the class fantasy where strong spells cost
  health (see `Bloodmage_fantasy_playstyle.md` for the source talents:
  `Pooled Vitality`, `Gore Barrage`, `Nightmare`, `One Man's Curse...`,
  etc., all of which reference "spells that cost health").
- **Mechanism (no spell ID, no custom Lua):** native WeakAuras `Health`
  unit-event trigger (`type: "unit"`, `event: "Health"`, `unit: "player"`)
  + the aurabar region's own `adjustedMin`/`adjustedMax` percent clamp.
  Confirmed two ways in `BUILD_METHOD.md` ("FORMALIZED as a core
  capability"): direct source read of `Prototypes.lua`/
  `RegionPrototype.lua`, AND a real live-tested Battlewrath export (`id:
  Bloodmage_hp_resouece_50-100%`, `uid: d4mA)3j847u`).
- **Built via** `Tiers/resources_base.py`'s `health_slot("HP Reserve", 50,
  100, rb.CLASS_RESOURCE_POS, bar_color=ACCENT_COLOR)` - passed PLAIN
  NUMBERS (50, 100); the builder appends the `%` itself, structurally
  preventing the real `%`-missing bug the original hand-built capture had
  (documented in `BUILD_METHOD.md`'s "Upgraded to REAL-CAPTURE confirmed").
  `opportunity_type`: `health_range` / template `health_range_aurabar`
  (REGISTRY-confirmed present this session).
- **Bar color:** theme accent `#c66161` (`ACCENT_COLOR`), sanctioned by
  `BUILD_METHOD.md`'s worked example - a blood-red, on-theme for a health
  meter. No competing captured barColor exists to prefer over the accent
  (unlike Reaper's Soul Fragment, which had one).

## Rage (secondary resource)

- **Power type:** Rage = standard WoW `PowerType` 1
  (`rb.POWERTYPE_RAGE`). Confirmed as the class's second resource - NOT
  Mana - by Battlewrath directly ("the other energy is rage, not mana") and
  by the skill index: 33 talent references to Rage cost/generation, and
  zero real Mana references (the only two "Mana" substrings in the index
  are both the word "ema**na**te"). `Pooled Vitality`/`Unchained` on
  `Mortal Form` explicitly gate on "spells that cost **Rage**."
- **How it behaves (context, not needed for a plain Power bar):** generated
  by auto-attacks and damage dealt (`Bloody Claws`: "generate 20% increased
  Rage from damage dealt and critical strikes with auto attacks"; `Raging
  Hunger`: "generates 3 Rage"; `Wretched`: "generates 10 Rage... every
  1 sec"), spent by abilities. Per-ability Rage costs are NOT indexed here -
  not needed for a plain Power-status bar, same scoping call made for
  Necromancer/Reaper Resources tiers.
- **Built via** `Tiers/resources_base.py`'s `resource_slot("Rage",
  POWERTYPE_RAGE, rb.CLASS_ENERGY_POS, bar_color=RAGE_BAR_COLOR)`.
  `opportunity_type`: `resource_threshold` / template
  `resource_threshold_aurabar`.
- **Bar color - FLAGGED, not a Bloodmage capture:** no real in-game
  Bloodmage Rage bar has been captured, so its true barColor is unknown.
  `resource_threshold_aurabar`'s own template default is Mana's captured
  blue, which is visibly wrong for a Rage bar. Rather than ship a blue Rage
  bar OR invent a value, `inventory.py` sets `RAGE_BAR_COLOR` to Blizzard's
  own canonical `PowerBarColor["RAGE"]` = `{0.77, 0.25, 0.25}` - a real,
  documented reference constant, not a fabricated one. This is the same
  "documented default, flag before assuming permanent" posture Reaper used
  for its Runic Power recolor (`Reaper/inventory.py`). **Flag:** replace
  with a real capture if one is ever taken; also note it sits close to the
  accent-red HP bar directly above it (thematically coherent for a blood
  class, but confirm the two reds read as distinct in-game).

## Not tracked in the Resources tier (deferred to future tiers)

The spec-defining stacking sub-resources are NOT Resources-tier content -
they are talent/spec-gated, not universal, and belong to later
Rotation/Buffs tiers (same call Reaper made - only Soul Fragment, an
always-relevant resource, went in its Resources tier). Named here only so a
future agent knows where they live, not built:
- **Blood Shard** (Accursed) - `Battleweaver` generation, stacks to 8.
- **Pooled Vitality** (Fleshweaver) - stacks to 10, empowers at 10.
- **Thirst** (Sanguine) - `Vampiric Fang` expends it.
- **Eternal Curse form / summon presence** (Eternal).

See `Bloodmage_fantasy_playstyle.md`'s per-spec "UI priority" notes and its
closing escalation reminder before building any of these.
