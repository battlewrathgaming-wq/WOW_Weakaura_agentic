# Rotation ability icon: a parameterized, procedural pattern

Built 2026-07-06, in direct response to Battlewrath's use case: build a
system where "this spell is in the rotation," "this spell is a proc
that empowers it," and "desaturate when out of mana for it" become
choices filled into a known pattern, not something reasoned through
fresh for every ability. Every mechanism below is confirmed directly
against real source (`Prototypes.lua`, `Conditions.lua`,
`BuffTrigger2.lua`) this session - not assumed.

**Refined 2026-07-06, per Battlewrath's correction:** the trigger/
condition system here is deliberately NOT used to show or hide the icon
itself - a rotation slot is a fixed, always-visible element. Every
trigger and condition in this pattern exists purely to drive *effects
on the button* (desaturate, glow, border emphasis, icon swap) - the
button's presence is not itself an input.

## The inputs this pattern takes

1. **`base_spell`** (required) - the rotation ability this icon represents.
2. **`proc_spell(s)`** (optional, zero or more) - a buff on the player that,
   while active, means "use `base_spell` now" - drives attention-calling
   effects (glow, and optionally an icon swap - see below), never
   visibility.
3. **`mana_cost`** (optional) - if set, the icon desaturates when the
   player doesn't have enough of the relevant power type to cast
   `base_spell`.
4. **`powertype`** (required only if `mana_cost` is set) - which power
   bar to check (Mana = 0, Runic Power = 6, per this project's own
   confirmed Necromancer values in `slot_assignment.md`).

## How each input becomes real WeakAuras structure

### `base_spell` -> trigger 1: `Cooldown Progress (Spell)`

Real internal name `Cooldown/Charges/Count` (`Prototypes.lua` line
3742). Exposes `state.duration`, `state.expirationTime`, `state.paused`,
`state.icon` (the spell's own icon texture) - the same timing fields
already relied on for Cast Bar/Swing Timer.

Has a native `genericShowOn` option (`showOnReady` / `showOnCooldown` /
`showAlways`) that *can* control visibility - **fixed to `showAlways`
for this pattern, not exposed as a per-ability input**, per Battlewrath's
correction: these are fixed rotation slots, always present. Readiness
is communicated entirely through the effects below, never by the icon
appearing/disappearing.

### `proc_spell` -> trigger N: `aura2` (Buff Active, unit `player`)

Confirmed via `BuffTrigger2.lua`: exposes `state.show` (true while the
buff is present), `state.duration`, `state.expirationTime`, `state.stacks`.

**Condition:** `{"trigger": N, "variable": "show", "value": true}` targeting
`sub.M.glow` (M = the subglow subRegion's 1-based position in this
icon's own `subRegions` array - computed per-instance, never hardcoded,
per the existing rule in `CAPABILITY_INVENTORY.md`'s Conditions section).

Confirmed generated code shape, straight from `Conditions.lua`
(`CreateTestForCondition`, `cType == "bool"` branch):
```
state[N] and state[N].show and state[N]["show"] ~= nil and state[N]["show"] == true
```

Multiple `proc_spell`s (if more than one buff should trigger the same
glow) become multiple trigger slots, each with its own condition
targeting the same `sub.M.glow` property - conditions are a list, not a
single value, so this composes cleanly without new mechanism.

### `proc_spell` -> optional icon swap (conceptual, now confirmed feasible)

Battlewrath's idea: when a proc alters the ability itself (not just
"use it now" but "it's now a different/upgraded version"), swap the
icon's own texture while the proc is active. Checked directly against
`RegionTypes/Icon.lua`'s `UpdateIcon()` (lines 549-563) - this is a
real, already-existing mechanism, not something needing new code:

- `iconSource` is itself a Condition-changeable property (`type: "list"`,
  `setter: "SetIconSource"` - satisfies the same `type`+`setter`
  requirement `Conditions.lua` checks before allowing a property in a
  `changes` list).
- `UpdateIcon()`'s own logic: `iconSource == -1` shows trigger 1's icon
  (the default); `iconSource == <trigger number>` shows *that trigger's*
  own `state.icon` instead. Confirmed `BuffTrigger2.lua` does write a
  real `state.icon` for the matched buff (line 637) - so the proc
  trigger's icon is genuinely available to swap to, not empty.
- **Condition:** same `check` as the glow one above (`trigger: N,
  variable: "show", value: true`), but with `changes: [{"property":
  "iconSource", "value": N}]` instead of/alongside the glow change.
  Deactivating reverts `iconSource` back to `-1` automatically (per
  `CreateDeactivateCondition`'s captured-default-value behavior).

Still conceptual in the sense that no real ability has asked for this
yet, but the mechanism itself is now confirmed real, not speculative -
ready to use the moment a specific proc-that-changes-the-ability case
comes up.

### `mana_cost` + `powertype` -> trigger N: `Power` (unit `player`)

Confirmed via `Prototypes.lua` (`["Power"]`, line 2674): exposes
`state.power` (current amount), `state.total`/`state.maxpower`,
`state.percentpower`, `state.deficit` - all four marked
`conditionType = "number"` in the trigger's own `args`, meaning
WeakAuras' Condition UI treats these as first-class numeric checks, not
a workaround.

**Condition:** `{"trigger": N, "variable": "power", "op": "<", "value":
"<mana_cost>"}` targeting the base region's `desaturate` property.

Confirmed generated code shape (`cType == "number"` branch):
```
state[N] and state[N].show and state[N]["power"] ~= nil and state[N]["power"] < <mana_cost>
```

### Both together

Nothing special - `conditions` is a flat list; a glow-on-proc entry and
a desaturate-on-insufficient-mana entry coexist independently, each
with its own `check`/`changes` pair, each referencing a different
trigger slot and targeting a different property. This directly answers
"or both" - no combination logic needed beyond having both entries
present.

## SubRegion choices (from `ICON_REGION_OPTIONS.md`)

- `subborder` - class-accent-colored, consistent with the rest of the
  HUD's design language.
- `subglow` - the proc-driven glow target above.
- `subtext` - cooldown-remaining display (`text_text` set to a
  cooldown-format string, not the icon-variant's raw `%p` default - see
  `ICON_REGION_OPTIONS.md` section 3's own note on this).

## What building a real ability still requires beyond this pattern

- The actual `base_spell`/`proc_spell` IDs and `mana_cost` value -
  ability-specific data, not something the pattern derives.
- The slot's real position/size - now settled per the latest mask
  (Battlewrath, 2026-07-06), pending being read out of it for the
  specific slot in question.
- Whether a specific proc should drive glow, icon swap, or both - the
  mechanism supports either/both, but which effect(s) apply is a
  per-ability creative decision, not something this pattern presumes.

## Status

**WIRED IN 2026-07-06.** Promoted from a documented-but-unwired design
into an actual reusable capability: `cooldown_tracker_icon`'s schema/
template gained a permanent `subborder` (class-accent, icon-variant
fields live-confirmed via `Test_Board_validation`) and an optional
`power_threshold` fragment (`Templates/schemas/power_threshold_effect.
schema.json`, `template_filler.py`'s `power_threshold` handling block) -
desaturate-on-insufficient-power always applied when present, an
optional inverse `include_afford_glow` for the "enough banked" signal.
First real consumers: Necromancer's Lichfrost/Crypt Swarm/Command:
Undead, built into `Necromancer/Tier1_Rotation_v1_import.txt`
(`Tier 1 Rotation` group, 3 children). Round-trip verified (encode then
decode, correct trigger/condition counts per aura) - not yet
live-tested in-game.

## Cross-references

- `Templates/ICON_REGION_OPTIONS.md` - the base region + subRegion
  option catalogue this pattern draws from.
- `CAPABILITY_INVENTORY.md`'s Conditions section - the `sub.N.<field>`
  addressing rule and the now-closed global-conditions gap.
- `Necromancer/slot_assignment.md` - Runic Power/Mana powertype values
  (6/0) already confirmed for this class.
