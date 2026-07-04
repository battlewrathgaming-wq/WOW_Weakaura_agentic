# Necromancer slot assignment

The real-content counterpart to `ELEMENT_INVENTORY.md` - that file
describes what each `Template_shadow.py` slot is *for*, in the abstract,
across every class; this file records what's actually assigned to
Necromancer's slots, traceably, updated as real content gets built and
live-tested. Positions below are copied from `ELEMENT_INVENTORY.md`'s Row
C/D (v0.14) exactly - this file mirrors the mask, per `BUILD_METHOD.md`,
it doesn't re-derive geometry.

Scope: covers every tier built so far - Resources (built 2026-07-05/06)
and Tier 1 Rotation (built 2026-07-06). Other tiers get their own section
here once they're built out the same way, per `BUILD_METHOD.md`'s
per-tier authoring process.

## Tier 1 Rotation (layer 2 in `inventory.py`)

**CURRENT STATE, 2026-07-06 (v6, most recent revision - read this first,
the walkthrough below is the in-order history that got here, kept for
traceability but NOT the current picture on its own):** just **Command:
Undead** (504868). Lichfrost and Crypt Swarm were both built, live-tested,
and then deliberately DROPPED the same day - both turned out to be pure
Runic Power builders (no cooldown, no decision point), not opportunities
worth a HUD slot; see the "SCOPE RULE" walkthrough below for the full
reasoning trail. Command: Undead currently has: `cooldown_tracker_icon` +
`power_threshold` (desaturate-on-insufficient-power + afford-glow at 30
Runic Power). It does NOT currently have `press_wash` - that fragment is
real, live-confirmed working (on Lichfrost, before Lichfrost itself was
dropped), but never fired reliably for Command: Undead specifically and
was pulled from this build rather than ship a visibly-broken feature.
`press_wash` itself is NOT deprecated - it's a proven mechanism, just not
currently applied here; the next ability that's both real and has no
cooldown of its own is the next real candidate for it.

**Real import string, current: `Necromancer/Tier1_Rotation_v6_import.txt`**
(single child, round-trip verified: 2 triggers - Cooldown Progress + Power
- and 2 conditions - desaturate, afford-glow via `sub.3.glow`; no
combatlog trigger). **Not yet live-tested in-game.** `_v1` through `_v5`
in this same folder are superseded build history, not live artifacts -
kept on disk per this project's existing convention (see the Resources
section below for the same pattern), not cleaned up.

Necromancer's first three real rotation abilities were originally built
via `layer_builder.py` from `Necromancer/inventory.py`'s "Tier 1 Rotation"
layer (not hand-assembled like Resources was) - see that file's own
inline comments for the full sourcing trail. All used
`cooldown_tracker_icon` + the `power_threshold` fragment
(`Templates/ROTATION_ICON_PATTERN.md`), no `glow_source` (no confirmed
"proc that empowers" buff exists among these three - see below).

| Template_shadow slot | x | y | Assigned to | Spell ID | Cost | Opportunity type | Status (as of v1, since superseded - see CURRENT STATE above) |
|---|---|---|---|---|---|---|---|
| Tier 1 slot Rotation | -107.5 | -130 | ~~Lichfrost~~ | 501969 | 10% base mana (`percentpower`) | `cooldown_tracker` + desaturate-on-insufficient-mana | Built, live-tested, confirmed working - then DROPPED (pure Runic Power builder, no decision point) |
| Tier 1 slot 2 | -64.5 | -130 | ~~Crypt Swarm~~ | 500965 | 10% base mana (`percentpower`) | `cooldown_tracker` + desaturate-on-insufficient-mana | Built, live-tested, confirmed working - then DROPPED (channeled Runic Power builder, same reasoning as Lichfrost) |
| Tier 1 slot 3 | -21.5 | -130 | **Command: Undead** | 504868 | 30 flat Runic Power (`power`) | `cooldown_tracker` + desaturate-on-insufficient-power + afford-glow (`include_afford_glow`) | **Kept - this is the current, only slot in the layer** |

**No proc/empower relationship built yet.** Research this session (spell
data pulled from `db.ascension.gg`, since none of these 3 IDs existed in
this project's own indexed data yet) found Lichfrost triggers **Ice
Barrage** (804112 - instant, no cost, "Give Power: (Runic Power) Value:
20") and Command: Undead triggers **Grave March** (500991 - a minor
damage tick) as side effects, but neither is a buff that empowers a
*different* rotation ability the way `glow_source`/`ROTATION_ICON_PATTERN.md`
expects - Lichfrost is a Runic Power *generator*, Command: Undead a
Runic Power *spender*, not a proc chain. So `power_threshold` (desaturate
+ afford-glow) is the only effect wired in for this tier; revisit
`glow_source` once a real empowering proc exists in this character's kit
(low level, per Battlewrath - "a lot of the kit is missing").

**Original v1 import string:** `Necromancer/Tier1_Rotation_v1_import.txt`,
built via `python3 layer_builder.py Necromancer Necromancer/inventory.py
"Tier 1 Rotation"`. Round-trip verified (correct trigger/condition counts:
Lichfrost 1 condition, Crypt Swarm 1 condition, Command: Undead 2
conditions) and pasted into WeakAuras in-game - confirmed working. This is
now superseded - see CURRENT STATE above for what's actually live.

**Revision, 2026-07-06 - press-wash feedback added ("I pressed this and it
actioned").** Battlewrath, running Resources + Tier 1 Rotation live in-game:
"Currently they just look at you without response... I liken it to playing
a piano. Press a key and get a response." Explicitly NOT wanted: all three
icons flashing together off one shared GCD animation - "What I don't want
is every ability to all go through the same GCD animation, because I
pressed one key." Diagnosed why: none of these 3 abilities have a real
ability cooldown (only GCD) - `power_threshold`'s desaturate/afford-glow
covers the "can I afford this" question, but nothing signals "I just
pressed it." Reference point Battlewrath gave: the native Blizzard action-
button press highlight (a faint, neutral wash, not a golden proc-glow) -
"maybe a very faint class hex based wash on the button when YOUR spell
triggers on the event log." Scope clarified: "those with cooldowns don't
need it, as their response is going on cooldown / desaturation" - so this
only applies to abilities without a real cooldown sweep (all 3 here,
currently; future Power-button abilities with real 15s+ cooldowns won't
need it). Command: Undead keeps its existing afford-glow untouched -
"Glow is opportunity. Wash is response" - the two are independent,
non-conflicting Conditions on separate triggers.

**Mechanism, confirmed via direct source read before building (`CLAUDE.md`'s
"discuss before acting"):** a new optional `press_wash` fragment
(`Templates/schemas/press_wash_effect.schema.json`,
`template_filler.py`'s press-wash block) adds a third trigger - Combat Log,
`SPELL_CAST_SUCCESS`, filtered to the icon's own spell ID, with
`duration: "0.3"`. Combat Log is a `timedrequired` trigger category
(`GenericTrigger.lua` line 3739) - WeakAuras auto-reverts this trigger's
`show` back to false 0.3s after it fires, natively, no custom Lua. A single
Condition (matching the existing `power_threshold`/`glow_source` pattern -
one direction only, WeakAuras reverts automatically) mixes the icon's base
`color` 30% toward its class accent while that trigger is showing, then
reverts. **A real risk was caught before shipping, not after:**
`WeakAuras.lua` line 3109 defaults a multi-trigger aura's `disjunctive`
combination to `"all"` (AND) unless set otherwise. `power_threshold`'s own
second trigger (Power, a continuous status - always active) never needed
to touch this; this new trigger is genuinely momentary (0.3s per cast), so
leaving `disjunctive` at its default would have required BOTH trigger 1
(showAlways) AND this one active simultaneously for the icon to show at
all - hiding it except during the 0.3s flash. This is plausibly the same
bug class that broke the Cast Bar/Swing Timer idle-shadow experiment
(above). Fixed: `template_filler.py` explicitly sets
`disjunctive: "any"` whenever `press_wash` is applied.

Applied to all 3 built abilities (`inventory.py`): `press_wash: {wash_alpha:
0.3, duration: 0.3}` - 30%/0.3s, Battlewrath's confirmed starting values.
Rebuilt as **`Necromancer/Tier1_Rotation_v2_import.txt`**. Round-trip
verified: each icon now carries 3 triggers (Cooldown Progress, Power,
Combat Log wash) with `disjunctive: "any"`; Lichfrost/Crypt Swarm each
carry 2 conditions (desaturate + wash-color), Command: Undead carries 3
(desaturate + afford-glow + wash-color, all independent); the wash color
resolves to `[0.781, 0.958, 0.884, 1]` (30% mix of white toward the
Necromancer accent `#45db9c`), region alpha untouched throughout (a tint
mix, never a fade/flicker). **Not yet live-tested in-game.**

## Resources tier (Row C/D, `Template_shadow.py` v0.14)

| Template_shadow slot | x | y | w | h | Assigned to | Opportunity type | Status |
|---|---|---|---|---|---|---|---|
| Class resource | -63.75 | -152.5 | 127.5 | 15 | **Mana** (primary/budget resource, per Battlewrath) - `powertype: 0`, confirmed live 2026-07-06 | `resource_threshold` (Power status trigger) | **Rebuilt, 2026-07-06 (third revision)** - added left-side value readout (see below), real import string regenerated, round-trip verified |
| Cast bar | 63.75 | -152.5 | 127.5 | 15 | **Player Cast Bar** (own cast time, joins Resources per Luxthos convention) | `player_cast` (Cast trigger, unit=player) | **Rebuilt, 2026-07-06 (later same day)** - added idle-shadow + right-side timer text (see below), real import string regenerated, round-trip verified |
| Class energy | -63.75 | -167.5 | 127.5 | 15 | **Runic Power** (spender resource, per Battlewrath) - `powertype: 6`, confirmed live 2026-07-06 | `resource_threshold` (Power status trigger) | **Rebuilt, 2026-07-06 (third revision)** - added left-side value readout (see below), real import string regenerated, round-trip verified |
| Swing Timer | 63.75 | -167.5 | 127.5 | 15 | **Swing Timer** (native `WeakAuras.InitSwingTimer()` trigger, hand=main, no addon dependency) | `swing_timer` (Swing Timer trigger, **aurabar** region - see revision below) | **Rebuilt, 2026-07-06 (later same day)** - converted icon->aurabar, added idle-shadow + right-side timer text, real import string regenerated, round-trip verified |

Mana/Runic Power use `resource_threshold_aurabar`. Cast Bar and Swing
Timer use `player_cast_aurabar` and `swing_timer_aurabar` respectively
(see `Templates/schemas/` + `Templates/templates/`), per `BUILD_METHOD.md`'s
per-ability build steps. Mana/Runic Power ship as plain bars for now - a
`subtick` threshold marker only gets added once a specific "alert at N"
value is actually wanted, not required to ship a working bar.

**Revision, 2026-07-06 (later same day) - Cast Bar and Swing Timer both
converted to a shared "always-shown bar" treatment**, per Battlewrath:
"I think the cast / swing should both be bars. Both have a timer on the
right side, static. Both have a shadow presence when not in use to
declare their footprint." This replaces Swing Timer's earlier `icon`
region choice (Template_shadow.py v0.12's changelog, ELEMENT_INVENTORY.md's
Row D note) and adds new behavior to both:

- **Both are now `aurabar`** (not icon) - `swing_timer_icon.schema.json`/
  `.template.json` are superseded and no longer in `Templates/build_
  templates.py`'s `REGISTRY` (left on disk as inert history - never live-
  tested, so nothing real is lost by superseding them).
- **Idle-shadow footprint:** each bar carries a SECOND trigger - "Unit
  Characteristics" (unit=player, no optional checks enabled) - which is
  unconditionally true whenever the player exists (confirmed directly in
  Prototypes.lua: every base field on that trigger has `test="true"` with
  nothing else ticked). Combined with the real trigger (Cast / Swing
  Timer) via `activeTriggerMode: -10` ("first_active", confirmed in
  Types.lua's `trigger_modes` table), the bar is now ALWAYS shown - empty
  and dim (`alpha: 0.35`) when idle, since AuraBar.lua's own fill logic
  reads 0% whenever duration is 0/absent. A Condition (`{"check":
  {"trigger":1,"variable":"show","value":1}, "changes":[{"property":
  "alpha","value":1}]}`) brightens it to full alpha only while the real
  trigger is actually active (casting / mid-swing). The condition's
  `{trigger, variable:"show", value:1}` check shape is a REAL confirmed
  pattern (`weakaura_codec.REAL_MULTI_CONDITION_CONDITIONS`, captured
  2026-07-04); the exact `"value"` key for a number-type property change
  is inferred by analogy, not independently captured - flag this first if
  the dimming doesn't take live.
- **Static right-side timer:** a `subtext` subregion, text `"%p"`,
  anchored `INNER_RIGHT` - matches WeakAuras' own real default position
  for an aurabar's right-side subtext (SubText.lua's `addDefaultsForNewAura`),
  just swapped from its default `"%n"` (name) to `"%p"` (remaining time,
  confirmed via `Private.dynamic_texts["p"]` in Prototypes.lua). Reads
  blank while the idle/shadow trigger is the active one (it has no
  `progressType`), and shows a live countdown once actually casting/
  swinging - no extra logic needed for that split.

**Revision, 2026-07-06 (third pass, same day) - Mana/Runic Power get a
left-side value readout**, per Battlewrath: "Can we have the resource
bars on the left most side show a static read out of their current
value?" A `subtext` subregion, text `"%p"`, anchored `INNER_LEFT`, added
to `resource_threshold_aurabar`. The Power trigger has `progressType:
'static'` (Prototypes.lua line 2676), with `state.value`/`state.total`
populated from the trigger's own `power`/`total` locals (current/max) -
`Private.dynamic_texts["p"]` (WeakAuras.lua) returns `state.value`
unformatted whenever `progressType` isn't `'timed'`, so `"%p"` resolves
to the plain current power number here (not a percentage, not a
countdown - those only apply on the Cast/Swing Timer triggers' `'timed'`
path). No idle-shadow mechanism needed here - the Power trigger is always
showing (you always have some current mana/RP value), unlike Cast/Swing
Timer which are naturally hidden between casts/swings.

**Bug caught and fixed while making this change:** the `subtick`
(threshold-marker) subRegion used to be baked unconditionally into the
static template with a `"{{threshold_value}}"` placeholder. Neither Mana
nor Runic Power was ever given a threshold, so both v1 and v2 shipped
with that placeholder string LITERALLY unresolved inside `tick_placements`
- a real defect that would have rendered a broken tick marker in-game.
Fixed properly: `template_filler.py` now only appends the subtick when
`threshold_value` is actually supplied (same optional-append pattern as
`stack_counter`/`glow_source`), so omitting it now correctly ships a
plain bar with no subtick at all, instead of a broken one.

**Real import string:** all four were assembled into a single "Resources"
group (regionType `group`, plain container - children keep their own
absolute x/y, matching `BUILD_METHOD.md`'s per-tier authoring convention)
via `weakaura_codec.py`'s `encode_group_import_string`. **v1**
(`Necromancer/Resources_v1_import.txt`) had all four built to mask
position but without the idle-shadow/timer-text treatment, and carried
the unresolved-placeholder bug above. **v2**
(`Necromancer/Resources_v2_import.txt`) added Cast Bar/Swing Timer's
idle-shadow + right-side timer text. **v3** (`Necromancer/
Resources_v3_import.txt`, current) adds Mana/Runic Power's left-side
value readout and fixes the subtick bug; Cast Bar/Swing Timer are
unchanged from v2. Round-trip decode confirms all 4 children's ids, uids
(unique), positions, region types, subRegions, and (for Cast Bar/Swing
Timer) alpha/conditions match spec. **Not yet live-tested in-game** -
next step is pasting v3 into WeakAuras' Import dialog.

**Revision, 2026-07-06 (fourth pass, same day) - colors synced from
Battlewrath's own in-game edits.** Battlewrath pasted a real group export
of their edited bars; decoded and applied:

| Aura | Field | Old (default) | New (synced) |
|---|---|---|---|
| Mana | barColor | `#0066FF` | unchanged - Battlewrath left it at default |
| Runic Power | barColor | `#0066FF` (shared default) | **`#21E8FF`** (cyan) |
| Cast Bar | barColor | `#3399FF` | **`#9ED9FF`** (pale sky blue) |
| Cast Bar | backgroundColor alpha | 0.5 | **0.73** |

Since Mana and Runic Power share one template (`resource_threshold_
aurabar`) but now need different colors, added an optional `bar_color`
fill-time override (same non-placeholder pattern as `threshold_value` -
`template_filler.py` applies it directly to `result["barColor"]` post-
fill, so omitting it just keeps the template default, no risk of a
stranded `"{{...}}"` string). Cast Bar's color is a single-instance
template, so its default was updated directly in `player_cast_aurabar`.
All 4 rebuilt, reassembled as **v4** (`Necromancer/Resources_v4_import.txt`,
current), round-trip verified.

**Timeline correction, same day (second pass) - the previous correction
above was itself wrong; restoring the real sequence.** Battlewrath
clarified: **v1** (`Resources_v1_import.txt`, the version where Swing
Timer was still built as an `icon`) WAS actually pasted into WeakAuras'
Import dialog in-game - that's the real, live import this project's
pipeline has been validated against, and it's exactly how the color
feedback (Runic Power/Cast Bar recolored, "Swing Timer 2") was generated:
Battlewrath imported v1, edited colors on the real in-game auras via
WeakAuras' own options UI, then exported and pasted that state back here
to decode. ("Swing Timer 2" is most likely WeakAuras' own auto-renamed
copy of the imported "Swing Timer," not a separate unrelated aura -
consistent with it still being the plain default icon color at that
point.) **v2 through v5 (the aurabar conversion, idle-shadow, timer text,
value readout, and this color sync) have NOT been imported into the game
since** - per Battlewrath: "it has not been updated to the game since.
Which is the act we're going to do soon." So: v1's import/round-trip
pipeline is confirmed working live, in-game, for this Resources group;
v2-v5 exist only as round-trip-verified strings so far, pending that next
import.

**Revision, 2026-07-06 (fifth pass) - Swing Timer color confirmed.**
Battlewrath confirmed "Swing Timer 2" does correspond to Swing Timer's
intended look - its icon `color` field was `[1,1,1,1]` (white/untinted),
not this project's earlier default orange (`#FF8C1A`). Updated
`swing_timer_aurabar`'s default `barColor` to white. Rebuilt all 4,
reassembled as **v5** (`Necromancer/Resources_v5_import.txt`, current).
Full color state now: Mana `#0066FF` (default, unchanged), Runic Power
`#21E8FF`, Cast Bar `#9ED9FF` (background alpha 0.73), Swing Timer
`#FFFFFF` (untinted).

**Revision, 2026-07-06 (sixth pass) - idle-shadow mechanism WITHDRAWN
after live-testing found it backwards; replaced with a separate backing
plate.** Battlewrath imported the idle-shadow version (Cast Bar/Swing
Timer's second "Unit Characteristics" trigger + `activeTriggerMode=-10` +
alpha Condition) into the game and reported: "They still disappear when
not triggered. And they leave a gap due to the icon spacing." Then
refined further: "Actually, I think pre-being triggered, they was
present. Then once they trigger they default to hiding again." So the
mechanism did the OPPOSITE of what it was designed for - visible at rest,
hidden once actually casting/swinging - meaning WeakAuras' `activeTriggerMode
= -10` ("first_active") does not combine two triggers into a genuinely
always-shown region the way this project's reading of `Types.lua`'s
`trigger_modes` table assumed. Rather than debug that combination logic
further, Battlewrath's call: "I think the fix is just a backing plate
that maintains their footprint, and sits behind the bars as far as the
layers go... rather than over complicate the auras."

**Fix implemented:** `player_cast_aurabar` and `swing_timer_aurabar` are
reverted to a single trigger each (Cast / Swing Timer only), full alpha,
no Conditions - normal show/hide, no different from before this whole
idle-shadow detour. A new template, `backing_plate_aurabar`, is a
separate, structurally simple always-shown aura (sole trigger = "Unit
Characteristics," no combination, no Condition) positioned at the EXACT
same x/y/w/h as the bar it backs, at `frameStrata: 2` ("BACKGROUND",
confirmed in `Types.lua`'s `frame_strata_types`) so it renders behind the
real bar (which stays at the project's usual `frameStrata: 1`/"Inherited").
Dim (`alpha: 0.35`), no fill (its trigger never sets duration, so
AuraBar.lua's own progress fallback reads 0%), no subtext - purely a
static plate showing the backgroundColor/border footprint.

**v6** (`Necromancer/Resources_v6_import.txt`, current) has all 6
children: Mana, Runic Power, Cast Bar Backing, Cast Bar, Swing Timer
Backing, Swing Timer. Round-trip verified - each backing plate's
position/size matches its bar exactly, frameStrata/alpha differ as
designed.

**Revision, 2026-07-06 (seventh pass) - icon-spacing gap "fixed"
(misdiagnosis, see eighth pass below).** Battlewrath's other complaint,
"they leave a gap due to the icon spacing," was initially traced to
`icon: true` reserving layout space, and both `player_cast_aurabar` and
`swing_timer_aurabar` were flipped to `icon: false`. Rebuilt all 6,
reassembled as v7 (`Necromancer/Resources_v7_import.txt`).

**Revision, 2026-07-06 (eighth pass) - the seventh-pass diagnosis was
wrong; icon restored, with the real mechanics understood this time.**
Battlewrath: "I'll flip it to true. They consume the space outlined by
the bar total. If you had already set it to correct dimensions, it
seems." Confirmed directly in `RegionTypes/AuraBar.lua`'s HORIZONTAL
width function (`return self.totalWidth - self.iconWidth, self.
totalHeight`) - the icon slot is carved OUT OF the bar's own configured
width/height (127.5x15, unchanged throughout), not added as overflow
beyond it. Since width/height were already set correctly, `icon: true`
never actually cost any extra footprint - the seventh-pass "fix" solved a
problem that didn't exist the way it was described. Battlewrath also
explained why the icon is wanted at all: "the work they do is feedback,
as they use the icon of what triggered them. So what spell + what
weapon." With `iconSource: -1` (already set on both templates),
`AuraBar.lua`'s `UpdateIcon()` reads `self.state.icon` directly - and
both triggers already populate their own `icon` state field: the Cast
trigger's comes from `UnitCastingInfo`/`UnitChannelInfo` (the spell's
icon, Prototypes.lua line ~7190), the Swing Timer trigger's comes from
`GetSwingTimerInfo(hand)` (the swinging weapon's icon, Prototypes.lua
line ~5047). So the icon slot automatically shows which spell is being
cast / which weapon is swinging, with zero extra configuration - real
information, not decoration. Restored `icon: true` on both templates.
Rebuilt all 6, reassembled as **v8** (`Necromancer/Resources_v8_import.txt`,
current) - this supersedes v7.

**Status:** v1 (icon Swing Timer) and the idle-shadow version were both
live-tested in-game; the idle-shadow mechanism is confirmed broken and
withdrawn (backing plate added instead). The icon-spacing complaint
turned out not to be a real footprint problem - v8 keeps the icon,
correctly understood as useful spell/weapon feedback.

**Revision, 2026-07-06 (ninth pass) - backing plate's idle darkness
corrected to match the real bars.** v8 was live-tested; Battlewrath's
report: "the backing plate doesn't match the darkness of the runic bar
colour (currently empty as the runic power is low. When I have lower
mana, the same darkness is seen. So it is cohesive between both bars as
a background colour). It should be one cohesive footprint." A follow-up
screenshot of Mana/Runic Power and Cast Bar/Swing Timer actively in use
confirmed all four already read as visually cohesive with each other -
so the mismatch was isolated to the backing plate's idle look, not a
broader color problem. Root cause: `backing_plate_aurabar`'s alpha=0.35
was compounding with its own `backgroundColor`'s 0.5 alpha (~0.175
effective darkness), while Mana/Runic Power sit at alpha=1 (their
`backgroundColor`'s 0.5 alpha IS the effective darkness, unmultiplied) -
two different dimming mechanisms producing two different results.
**Fixed, confirmed aligned with Battlewrath before implementing:** backing
plate's alpha set to 1, relying solely on its existing `backgroundColor`
for the dim look - the same single mechanism the real bars already use.
Rebuilt all 6, reassembled as **v9** (`Necromancer/Resources_v9_import.txt`,
current) - supersedes v8.

**Status:** v1 and the idle-shadow version were both live-tested in-game;
idle-shadow withdrawn. v8 (backing plate + icon) was live-tested; its
alpha mismatch is now fixed in v9. v9 is round-trip-verified server-side
only - importing it and confirming the footprint now reads as cohesive
is the next step.

**Revision, 2026-07-06 (tenth pass) - permanent end-cap marker added to
Mana/Runic Power.** After v9's footprint fix was confirmed live ("The
footprint now looks great and locked in"), Battlewrath raised a new,
explicitly discussion-gated question (per `CLAUDE.md`): fixing the
backing plate's darkness to match the real bars also erased the only
visual seam that showed where the resource bar's own max extent was -
so at rest, with e.g. 50% mana, there was no reference point to gauge
the fill against, since Mana's bar and Cast Bar's backing plate now read
as one continuous strip. Discussed two framings ("an end line ... so it
sits right in the middle of both bars" vs. "an end-cap to that specific
bar ... indicate its range of travel") before building anything;
Battlewrath confirmed both describe the same thing - a permanent marker
at the seam where the resource bar meets its backing plate/timer
counterpart, i.e. the resource bar's own 100% edge - and confirmed no
equivalent marker is needed on Cast Bar/Swing Timer, since those already
end cleanly against their backing plate and then the game background
(built-in contrast already).

**Fix, confirmed aligned before implementing:** read `SubRegionTypes/
Tick.lua` directly this pass. `tick_placement_mode = "AtPercent"` is a
distinct code path from `threshold_value`'s `"AtValue"` -
`UpdateTickPlacementOne` resolves `minValue + placements[i]*valueRange/100`
against the bar's live `GetMinMaxProgress()` every update, so a
placement of 100 always lands at the bar's CURRENT true max regardless
of level/gear - no hardcoded value needed. Added a new optional
`end_cap_color` param to `resource_threshold_aurabar` (schema +
`template_filler.py`, same append-only-if-present pattern as
`threshold_value`/`bar_color`): appends a `subtick` with
`tick_placement_mode: "AtPercent"`, `tick_placements: [100]`, colored
with the Necromancer's own accent (`theme.json`'s `accent_rgba`,
`#45db9c`). Applied to both Mana and Runic Power only. Rebuilt by
decoding v9's real group export and appending the subtick directly to
Mana's and Runic Power's `subRegions` (preserving every other field/uid
exactly), reassembled as **v10** (`Necromancer/Resources_v10_import.txt`,
current) - supersedes v9. Round-trip verified: 6 children, unique uids,
`controlledChildren` matches, Mana/Runic Power each carry exactly one
`subtick` (`AtPercent`, `[100]`, `[0.2706, 0.8588, 0.6118, 1.0]`); Cast
Bar/Swing Timer/both backing plates unchanged from v9.

**Revision, 2026-07-06 (eleventh pass) - real live-test bug found and
fixed: subtick was missing 3 fields, causing it to ship at the wrong
placement.** Battlewrath imported v10 (after first deleting the old
aura, ruling out an update-merge explanation), and reported: "I had to
update the tick position to 100... The tick position, listed as tick 1,
was set to 50 for both mana / rune bars." Diagnosed by decoding
Battlewrath's own real re-exported aura (after their manual fix) and
diffing it field-by-field against what v10 actually shipped. The diff
showed two real gaps in our subtick fragment versus `SubRegionTypes/
Tick.lua`'s own `default()` table: we were missing `progressSources`,
`automatic_length`, and `tick_texture` entirely, and we stored
`tick_placements` as a JSON number (`100`) where real WeakAuras stores
it as a string (`"100"`) once committed through its own options UI.
Root cause theory: WeakAuras' load-time defaults-merge treated the
incompletely-specified subRegion as needing stock defaults for the
parts it didn't recognize as fully authored - which is exactly
`Tick.lua`'s own stock placement of `50` - until Battlewrath's manual
edit forced a full commit/normalize of the subregion. Confirmed NOT a
percent-vs-combined-length math issue (that was Battlewrath's own first
theory) - the exported string's `AtPercent`/`100` data was byte-correct
before the fix; the gap was purely missing fields.

**Fix, and new reusable element, per Battlewrath: "make that tick a
known element ... a subtle design language through all the UI's."**
Promoted the end-cap tick out of an inline dict into a named, shared
FRAGMENT - `class_accent_tick_end` (`Templates/schemas/
class_accent_tick_end.schema.json`, `Templates/templates/
class_accent_tick_end.template.json`, registered in `build_templates.py`'s
`FRAGMENTS`/`FRAGMENT_TEMPLATES`, same pattern as `stack_counter_overlay`)
- intended for reuse on any aurabar, any class, going forward, not just
Mana/Runic Power. The fragment now matches `Tick.lua`'s `default()`
table completely (17 fields including `type`). The older, still-unused
`threshold_value` subtick (same underlying shape, never live-tested)
was proactively fixed the same way in `template_filler.py`, since it
shared the identical defect. Rebuilt by swapping Mana's/Runic Power's
subtick for the corrected fragment, reassembled as **v11**
(`Necromancer/Resources_v11_import.txt`, current) - supersedes v10.
Round-trip verified: unique uids, `controlledChildren` matches, both
subticks carry the full 17-field shape with `tick_placements: ["100"]`.
**Not yet live-tested in-game.**

**Revision, 2026-07-06 (thirteenth pass) - Cast Bar gets a center ability-
name text.** Battlewrath: "the cast bar (actual) will show the ability
name... Do the name in the middle position." Confirmed directly:
Prototypes.lua's Cast trigger stores a hidden `name` state field
(`init='spell'`, the real spell name), and `Private.dynamic_texts['n']`
resolves `%n` to `state.name` - the same mechanism already used for the
existing `%p` timer text, not a new one. `anchor_point: 'CENTER'`
confirmed valid for an aurabar-parented subtext directly in
`SubText.lua`'s `modify()` - a bare `CENTER` value resolves straight
through without needing `INNER_`/`OUTER_` prefixing, anchoring the
text's own center to the bar's center. Added a third subRegion (subtext,
`%n`, `CENTER`) to `player_cast_aurabar`; reads blank while idle (backing
plate/idle state has no `name`), matches whenever actually casting.
Rebuilt by appending directly to Cast Bar's subRegions in the real v11
export, reassembled as **v12** (`Necromancer/Resources_v12_import.txt`,
current) - supersedes v11. Round-trip verified: unique uids,
`controlledChildren` matches, Cast Bar carries exactly 3 subRegions
(`subbackground`, `%p`/`INNER_RIGHT`, `%n`/`CENTER`); all 5 other
children unchanged from v11. **Not yet live-tested in-game.**

Battlewrath also raised, as considerations only (not built): an
interrupted-cast flash, and a silence/stun overlay. Checked directly -
the Cast trigger has no distinct "was interrupted" state (it just
reverts to idle same as a normal cast finishing), so a real flash would
need a second Combat Log (`SPELL_INTERRUPT`) trigger combined with this
one - untested combination, not attempted yet. Silence/stun would need
its own curated debuff spell-ID list, scoped as a separate future
feature. Neither built this pass. A separate discussion (also this pass)
on whether the real cast-fail *reason* is natively surfaceable led to a
dedicated write-up: `CAST_ERROR_OVERLAY.md` (flagged future feature, not
a blocker - a native Custom trigger reading `UI_ERROR_MESSAGE` is the
real path to the actual reason text, since Combat Log's own
`_CAST_FAILED` subevent has its reason argument explicitly discarded by
this WeakAuras version).

**Revision, 2026-07-06 (fourteenth pass) - real in-game edit synced: name
text made deliberately subtle.** Battlewrath pasted a real export of the
Cast Bar after editing it in-game, with the intent stated directly: "It's
there as visual confirmation than explicit confirmation. Enough to
register it's the right skill." Decoded and synced: the `%n` name text's
font changed to `Arial Narrow`, size shrunk from 12 to 6, and nudged with
`text_anchorXOffset: -10` (distinct from `anchorXOffset`, which
positions the subRegion frame against the bar rather than the text
within its own point). Also picked up, for byte-fidelity (not a
deliberate user change): a `subforeground` subRegion that
`RegionTypes/AuraBar.lua`'s `EnforceSubregionExists` auto-inserts into
every real aurabar, and auto-added text-format metadata fields WeakAuras'
own options UI appends once a subtext is edited through it. Rebuilt by
replacing Cast Bar's subRegions with the real captured set exactly,
reassembled as **v13** (`Necromancer/Resources_v13_import.txt`, current)
- supersedes v12. Round-trip verified: unique uids, `controlledChildren`
matches; all 5 other children unchanged. Battlewrath also floated
showing the Cast trigger's own `castType` field ("cast" vs "channel")
instead of the name text - noted as "we'll see," not decided, nothing
built for it yet.

## Stance loader (Undead Stance)

**Built 2026-07-08.** A single icon showing whichever of the Necromancer's
3 mutually-exclusive Undead Stances (Pacify/Protect/Assault) is currently
active - `stance_loader_icon`, a new generalized (N-of-N) template added
this pass to `Templates/build_templates.py`/`template_filler.py`. See that
template's own schema for the full mechanism writeup (N `aura2` triggers,
name-matched, `disjunctive: "any"`, `activeTriggerMode: -10` - no
Conditions block or manual icon-swap needed, confirmed via direct source
read of `RegionTypes/Icon.lua`'s `UpdateIcon` and `WeakAuras.lua`'s
`activeTriggerMode` handling).

Sourced from `Outputs/live_reference/necromancer_live_reference.json`
(trainer capture, `verifiedLive: true`) - mutual exclusivity confirmed
directly from the live tooltip text: "Only 1 Undead Stance can be active
at a time." All three are single-rank (no rank-multiplicity risk - see
`Templates/build_templates.py`'s stance_loader_icon comment block).
Matched by exact in-game name (`useName`/`auranames`), not spell ID - none
of the three has a resolved spellId in the live reference (trainer-window
data doesn't expose one).

**Position: PLACEHOLDER, not final.** Asked Battlewrath directly where
this should sit on the mask; answer: "Undefined. This will live around
the UI for the necro" - i.e. genuinely not decided yet, not a case of
picking the wrong existing slot. Built at `x: -107.5, y: -130` - the
vacated Tier 1 Rotation slot 1 (Lichfrost's old position, left empty since
Lichfrost was dropped, see the v5 change-log entry below) - a real,
already-known-empty coordinate in the Necromancer's own action area,
chosen only so the mechanism could be verified end-to-end rather than
left unbuilt. **Reposition once Battlewrath settles where stance display
actually belongs** - this is not a considered placement decision, just an
available parking spot.

**Real import string:** `Necromancer/UndeadStance_v1_import.txt` (single
aura, not a group). Round-trip verified via `weakaura_codec.py`'s
`encode_import_string`/`decode_import_string`
(`_normalize_for_comparison`-equal, per this codec's own empty-table
convention - see `weakaura_codec.py`'s docstring). **Not yet live-tested
in-game.**

## Necro_animation_spec_UI_element (Battlewrath's live dev/test group)

**Indexed 2026-07-08.** Battlewrath imported Undead Stance in-game
("General placement. Some feedback. But conceptually works great."),
moved it (along with the existing Life Force delta text) into a new
personal dev/test group named `Necro_animation_spec_UI_element`, re-styled
the Life Force text, and - notably - **built a second real element
themselves**, by hand, reusing the exact `stance_loader_icon` mechanism
for an unrelated mutually-exclusive pair. Per Battlewrath's explicit
request ("I'd index it so it gets picked up in future builds for export.
On both the font change and the ward addition."), all of this is now
indexed as a real layer in `Necromancer/inventory.py` (`"Necro_
animation_spec_UI_element"`), not left as a one-off in-game edit -
`layer_builder.py` reproduces it byte-for-byte (round-trip verified,
decoded output matches Battlewrath's real pasted export field-for-field:
group id, `controlledChildren` order, all 3 children's positions,
`LF Delta Test`'s font/fontSize/color, and both stance-loader icons'
option names/`disjunctive`/`activeTriggerMode`).

**1. Life Force delta text - font/size/color synced.** Battlewrath's
in-game edit changed `stack_delta_flash_text`'s font from the template
default (`Friz Quadrata TT`) to `MoK`, font_size from 20 to 13, and color
to a teal (`[0, 0.6745, 0.5451, 1]`). The font change required a real
compiler fix, not just a data update: `font` was previously **hardcoded**
inside `STACK_DELTA_FLASH_TEXT_TEMPLATE` (`"font": "Friz Quadrata TT"`,
no placeholder), so there was no way to override it at all. Added a new
optional `font` property to `stack_delta_flash_text`'s schema (default
`"Friz Quadrata TT"`, preserving existing behavior for anyone who doesn't
override it), templated as `"font": "{{font}}"`, and added a matching
`fill_params.setdefault(...)` block in `template_filler.py` for
`font`/`font_size`/`color` together - these are plain `{{}}`-substituted
leaves, not schema-required, so omitting any of them without a default
would have silently stranded the literal `"{{font}}"` string in a built
aura (same failure class as the `threshold_value` bug from 2026-07-06,
just never caught until now because `font` had no placeholder at all to
strand). Verified via test-fill: both the no-override case (`Friz
Quadrata TT` / 20) and the real override case (`MoK` / 13 / teal) resolve
cleanly with no unresolved `{{...}}` left in either.

**2. Ward active - a second real element, built by Battlewrath directly,
now indexed.** Not something this project built - Battlewrath constructed
it themselves in-game, by hand, copying `stance_loader_icon`'s exact
mechanism (2 `aura2` triggers, `useName`/`auranames`, `disjunctive: "any"`,
`activeTriggerMode: -10`) for **Fetid Ward vs. Bone Ward**. Checked the
live reference to confirm this is a real, independently-verified
mutually-exclusive pair, not a guess: **Bone Ward**'s own live trainer
tooltip text reads *"Only 1 |cffffffffWard|r can be active at a time"* -
the identical mutual-exclusivity language as the Undead Stances, from a
completely separate ability family. This is a strong validation of the
`stance_loader_icon` design generalizing beyond its original 3-option case
without any changes needed - Battlewrath reused it directly, unassisted.
Indexed into `inventory.py` as a second `stance_loader_icon` slot
(`option_names: ["Fetid Ward", "Bone Ward"]`) so it's tracked the same way
as every other real element here, not left as an untracked hand-built
aura.

**Position - explicitly a dev/test area, not the final mask, same caveat
as Undead Stance's own placeholder above.** All 3 children's x/y are
Battlewrath's own current in-game coordinates (decoded straight off their
real pasted export), reflecting where they're actively testing right now,
not a settled design decision - Battlewrath: "General placement... I'll
develop a mask for around the UI." Revisit once that mask exists.

**Real import string:** `Necromancer/Necro_animation_spec_UI_element_v1_
import.txt` (group, 3 children: `LF Delta Test`, `Undead Stance`, `Ward
active`). Round-trip verified via `layer_builder.py`/`weakaura_codec.py`.
**Not yet re-tested in-game since this indexing pass** - the next useful
check is re-importing this generated string and confirming it matches
what's already running, byte-for-byte in practice, not just in the codec's
own decode.

## Open items before either slot can be built for real

- **Power-type value - CONFIRMED LIVE (2026-07-06).** Battlewrath captured
  and pasted two real in-game auras ("Mana", "Runic power" - default
  WeakAuras Progress Bar quick-auras, decoded via `weakaura_codec.py`).
  Decoded trigger data: Mana's real Power trigger carries `powertype: 0`;
  Runic Power's carries `powertype: 6`. Both are the plain, standard WoW
  `PowerType` enum values (0 = Mana, 6 = Runic Power) - **not a custom or
  remapped enum**. This directly confirms Battlewrath's own hypothesis
  ("Runic Power is just the DK's version, re-used") with real client data,
  not just corroborating display-name evidence from `db.ascension.gg`.
  Also caught and fixed a real bug this surfaced: `resource_threshold_
  aurabar.schema.json`'s `power_type` field was documented as a STRING
  enum name (`"MANA"`/`"RUNIC_POWER"`) - wrong. The real field is
  `powertype` (no underscore) and takes the raw numeric enum value. Schema
  corrected; `template_filler.py` itself needed no code change (it
  substitutes the raw Python value regardless of type - passing an int
  param now just works).
- **Runic Power's spend-side abilities - CONFIRMED (2026-07-05).** Per
  Battlewrath, spent mainly by **Command** (a client-to-server call making
  all summoned minions cast their own version of Command) - and this is
  now directly confirmed, not just asserted: cross-checking all three
  Command spell IDs against `db.ascension.gg`'s live pages shows they
  really do cost Runic Power (30/20/30). This project's own indexed data
  (`manaCost` 400/300/300) was wrong - a confirmed extraction-pipeline bug,
  not a real discrepancy in the game. See `spell_index.md` for the full
  corrected table (also two wrong ability names, since fixed).
- **Mana bar's threshold, if any** - no specific "alert at N mana" value
  has been requested yet. Ship as a plain bar first; add a `subtick` only
  if a concrete threshold gets specified.
- **Subtext field-parity gap, found by `wa_lua_verify` (2026-07-06),
  NOT yet fixed - flagged, pending a decision.** Mana/Runic Power's own
  `%p` value readout (`resource_threshold_aurabar`) and Swing Timer's
  `%p` timer (`swing_timer_aurabar`) are both missing `text_automaticWidth`,
  `text_fixedWidth`, `text_wordWrap` - the same three fields Cast Bar's
  subtext entries already picked up when Battlewrath's real edit was
  synced (fourteenth pass). That sync only touched Cast Bar's own
  template; these two siblings still have the smaller, pre-fix field
  set. Confirmed via `wa_lua_verify/verify.py` diffing against
  `SubText.lua`'s real `default()` table, not yet confirmed via a live
  in-game re-export (per `CLAUDE.md`'s guardrail - this is exactly the
  kind of finding worth that extra step before treating as settled,
  since it's new territory, not a re-confirmation of the already-proven
  subtick pattern).

## Not in this tier (deliberately)

**Life Force** does not get a Resources-tier slot - it has its own native
in-game UI element already, and its WeakAuras treatment is a transient
DynamicGroup budget-fit alert (redesigned 2026-07-06, see `USE_CASE.md`'s
pet-tracking section), not a third bar. See `spell_index.md`'s own
section and `BUILD_METHOD.md`'s open items for the real per-minion cost
data.

## Change log

- 2026-07-05: Initial assignment - Mana to "Class resource," Runic Power
  to "Class energy," per Battlewrath's direct confirmation of the class's
  actual resource pair (superseding the earlier open question in
  `HUD_DESIGN.md` about what fills these two generic slots). Neither slot
  built yet - positions and opportunity type assigned, template selected,
  power-type string and thresholds still open pending live confirmation.
- 2026-07-05: "Life Essence" renamed to "Life Force" throughout (Battlewrath's
  own correction). Added Runic Power's Command-ability spend mechanism and
  the DK-power-type-reuse hypothesis as the leading candidate for the
  still-unconfirmed power-type string; flagged the manaCost-vs-Runic-Power
  discrepancy on Command abilities for live verification.
- 2026-07-06: Power-type values CONFIRMED via two real pasted captures -
  Mana `powertype: 0`, Runic Power `powertype: 6` (the native enum, DK
  hypothesis directly confirmed). Both slots' status upgraded from
  "assigned, not yet built" to "live-probed" - the captures are default
  WeakAuras Progress Bar auras (200x30, unpositioned), not yet built to
  the mask's real x/y/w/h spec via `template_filler.py`. Also fixed
  `resource_threshold_aurabar.schema.json`'s `power_type` field (was
  wrongly documented as a string enum, actually a raw integer).
- 2026-07-06 (later same day): Added Cast Bar and Swing Timer to this
  table - both settled in `HUD_DESIGN.md` this session as joining the
  Resources tier (Cast Bar) / getting their own Row D slot (Swing Timer),
  using two brand-new templates (`player_cast_aurabar`,
  `swing_timer_icon`). All four Resources-tier elements (Mana, Runic
  Power, Cast Bar, Swing Timer) built to mask spec via `template_filler.py`,
  assembled into one "Resources" group import via `weakaura_codec.py`'s
  `encode_group_import_string`, round-trip verified, and saved to
  `Necromancer/Resources_v1_import.txt`. Status upgraded from
  "live-probed" to "built, not yet live-tested" for all four.
- 2026-07-06 (later same day, second revision): Per Battlewrath's direct
  request, converted Swing Timer from `icon` to `aurabar` and gave both
  Cast Bar and Swing Timer an idle-shadow footprint (always shown, dim/
  empty when inactive, brightens and fills when active) plus a static
  right-side `"%p"` timer text. `swing_timer_icon` retired in favor of
  `swing_timer_aurabar`. Rebuilt both auras, reassembled the Resources
  group as v2 (`Necromancer/Resources_v2_import.txt`), round-trip
  verified. Mana/Runic Power untouched. Updated `ELEMENT_INVENTORY.md`'s
  Row D region-type column to match.
- 2026-07-06 (later same day, third revision): Per Battlewrath's request,
  added a left-side `"%p"` value readout to Mana/Runic Power
  (`resource_threshold_aurabar`). Caught and fixed a real pre-existing
  bug in the process: the subtick threshold marker was unconditionally
  baked into the template as an unresolved `"{{threshold_value}}"`
  placeholder in both v1 and v2, since neither bar was ever given a
  threshold - moved to an optional fill-time append (`template_filler.py`,
  same pattern as stack_counter/glow_source). Rebuilt Mana/Runic Power,
  reassembled as v3 (`Necromancer/Resources_v3_import.txt`); Cast Bar/
  Swing Timer unchanged from v2. Battlewrath separately reported having
  changed the bars' color hexes in-game - awaiting the export string to
  sync those into the source templates.
- 2026-07-06 (tenth pass): Added a permanent end-cap `subtick` (AtPercent,
  100, class accent color) to Mana and Runic Power, marking each bar's
  own 100% edge now that the backing-plate fix made it visually blend
  into the adjacent Cast Bar/Swing Timer backing plate. Discussed before
  building, per `CLAUDE.md`. New optional `end_cap_color` param on
  `resource_threshold_aurabar`. Rebuilt as v10, round-trip verified, not
  yet live-tested.
- 2026-07-06 (eleventh pass): Live-test of v10 found the subtick shipped
  at the wrong placement (50, not 100) due to a real field-parity bug -
  our fragment omitted 3 fields from Tick.lua's own default() table and
  stored tick_placements as a number instead of a string. Fixed both this
  fragment and the older unused threshold_value one the same way, and
  promoted the end-cap tick into a new named, reusable FRAGMENT
  (`class_accent_tick_end`) per Battlewrath's request. Rebuilt as v11,
  round-trip verified, not yet live-tested.
- 2026-07-06: Added Tier 1 Rotation section (Lichfrost, Crypt Swarm,
  Command: Undead), built via the new `layer_builder.py` +
  `Necromancer/inventory.py` pipeline, pasted into WeakAuras in-game and
  confirmed working. This closed a real doc gap: the layer had already
  been built and live-tested before this ledger recorded it at all,
  found during a documentation audit for new-agent handoff.
- 2026-07-06: Added press-wash feedback (new `press_wash` fragment) to
  all 3 Tier 1 Rotation abilities - a faint (30%, 0.3s) class-accent tint
  on the icon's base `color`, driven by a third Combat Log
  SPELL_CAST_SUCCESS trigger (own spell ID, `duration: "0.3"` for native
  auto-revert), independent per ability and independent of Command:
  Undead's existing afford-glow. Caught and fixed a real risk before
  building: WeakAuras defaults multi-trigger `disjunctive` to `"all"`
  (AND), which would have hidden the icon except during the 0.3s flash -
  fixed by explicitly setting `disjunctive: "any"`. Rebuilt as
  `Tier1_Rotation_v2_import.txt`, round-trip verified. Not yet
  live-tested in-game.
- 2026-07-06 (v3 correction, same day): Battlewrath live-tested v2 in-game
  and pasted back the manually-edited export as reference material,
  reporting two real gaps: "they all landed with no spell config. So they
  was firing to any combat event" and a fix of "set source = player,"
  plus "set spell ID to named" (switched the filter from spell ID to
  spell name). Decoded the pasted export and confirmed both:
  1. MISSING SOURCE FILTER - v2's combatlog trigger had no `sourceUnit`/
     `use_sourceUnit` at all, so it matched Combat Log events from ANY
     unit. Fixed: `use_sourceUnit: true, sourceUnit: "player"`.
  2. NAME-BASED SPELL MATCH - v2 used `spellIds`/`use_spellId: true`
     (copied from `proc_alert_icon`'s own not-independently-verified
     pattern). Battlewrath's fix uses `use_spellName: true` +
     `spellName: [<name>]` instead. Confirmed directly with Battlewrath
     this is a DELIBERATE rank-safety choice, not a workaround for a
     broken ID filter: "Spell ID can be a source. But I made it generic
     incase the ranks effect things. So targetted the spell name" -
     different ranks of the same spell carry different spell IDs but the
     same display name, so name-based matching catches all ranks where
     ID-based would only catch one specific rank.
  Both fixes applied in `template_filler.py`; `press_wash_effect.schema.json`'s
  "verified" field rewritten to document the correction, the source-filter
  bug, and the deliberate-choice framing precisely (not as a bug).
  OPEN QUESTION, not resolved: Battlewrath's real test also flipped
  `subeventSuffix` to `_CAST_START` and reported Lichfrost then repeated
  correctly, but Crypt Swarm and Command: Undead did not fire at all under
  that suffix. Hypothesis (unconfirmed): `_CAST_START` may only fire for
  casts with a visible windup, while purely instant abilities may only
  ever emit `_CAST_SUCCESS`. Kept the corrected build at `_CAST_SUCCESS`
  (universal for instant and windup casts) rather than `_CAST_START`,
  pending a live re-test of this specific hypothesis - flag if any ability
  still doesn't fire once this v3 is tested in-game.
  Rebuilt as `Tier1_Rotation_v3_import.txt`; round-trip verified (decoded
  and confirmed, per icon: `sourceUnit=player`, `use_spellName=True`,
  `spellName=[<name>]`, `use_spellId=False`, `subeventSuffix=_CAST_SUCCESS`,
  `disjunctive=any`; Command: Undead's afford-glow condition (trigger 2,
  `sub.3.glow`) confirmed still independent of the wash condition
  (trigger 3, `color`)). Not yet live-tested in-game.
- 2026-07-06 (v4, same day): Battlewrath live-tested v3 and resolved the
  open `_CAST_START`/`_CAST_SUCCESS` question - swapped Crypt Swarm to
  `_CAST_SUCCESS` and it started firing correctly, then stated the rule:
  "true cast start = spells with a cast time. Cast success = spells with
  instant." Cross-checked against real db.ascension.gg spell pages to
  sharpen this into the precise combat-log rule: **Lichfrost** (501969)
  has a real 1.5s windup cast time -> `_CAST_START`; **Crypt Swarm**
  (500965) is "Channeled" (not a windup) -> `_CAST_SUCCESS`; **Command:
  Undead** (504868) is "Instant cast" -> `_CAST_SUCCESS`. Channeled spells
  fire `SPELL_CAST_SUCCESS` the instant the channel begins - there's no
  separate `CAST_START` event for them the way there is for a true
  windup, despite showing a nonzero "cast time" on their tooltip.
  Implemented as a new per-ability `trigger_event` param on `press_wash`
  (`"cast_start"` or `"cast_success"`, default `"cast_success"`) -
  Lichfrost is the only ability currently set to `"cast_start"`. Rebuilt
  as `Tier1_Rotation_v4_import.txt`; round-trip verified per icon:
  Lichfrost=`_CAST_START`, Crypt Swarm/Command: Undead=`_CAST_SUCCESS`,
  `disjunctive=any` still present on all three.
  Command: Undead's wash is still not observed firing in-game even at the
  now-correct `_CAST_SUCCESS` suffix - left unresolved and NOT further
  debugged, per Battlewrath's call: it's non-blocking since Command:
  Undead already gets its own per-press feedback for free via its
  existing afford-glow (Runic Power >= 30) cycling on/off as its 30 RP
  cost is spent and regenerated - "that has feed back in the glow once
  you press it enough times."
  **Also surfaced, same pass, not yet acted on:** the real db.ascension.gg
  check done for this fix showed Crypt Swarm actually has a genuine
  15-second cooldown - this project's own prior assumption ("all 3 Tier 1
  Rotation abilities lack a real cooldown, only GCD") was wrong for Crypt
  Swarm specifically. This matters against Battlewrath's newly-stated
  scoping rule ("if it has a cooldown worth tracking, or a condition to
  launch on it, track it - if it's pure builder, don't"): Crypt Swarm's
  own Cooldown Progress trigger (trigger 1) already sweeps on that real
  15s cooldown, which per the earlier press-wash scoping rule ("those
  with cooldowns don't need it") likely makes its press_wash redundant.
  Flagged for Battlewrath's direct call - not removed yet.
- 2026-07-06 (v5, same day) - Tier 1 Rotation scope reduced from 3
  abilities to 2, per Battlewrath's direct rulings on the two open items
  above:
  1. **Lichfrost DROPPED entirely.** Real data confirmed it's a pure
     builder: no cooldown, and its own Effect #2 triggers Ice Barrage
     (804112), which itself just gives 20 Runic Power - i.e. Lichfrost's
     whole job is generating Runic Power for Command: Undead to spend,
     with no cooldown or condition making it worth tracking. Battlewrath
     confirmed: "Drop it entirely." Its slot (was slot 1, x=-107.5) is
     left as a vacated gap in `Necromancer/inventory.py` - the remaining
     two abilities were NOT shifted left to fill it; reflowing slot
     positions is a separate, not-yet-made decision.
  2. **Crypt Swarm's press_wash KEPT, db.ascension.gg's cooldown claim
     corrected.** Asked whether to drop Crypt Swarm's press_wash as
     redundant (given the apparent 15s cooldown above) - Battlewrath
     corrected the premise directly: "It does not have a 15 sec cool
     down." Battlewrath's direct in-game experience is being treated as
     authoritative over db.ascension.gg's scraped page for this specific
     field (this project has already caught a real db.ascension.gg data
     error once before - the manaCost/Runic-Power mislabeling documented
     in `spell_index.md`). Crypt Swarm is treated as having no real
     cooldown; its press_wash stays as originally built.
  Rebuilt as `Tier1_Rotation_v5_import.txt` (2 children: Crypt Swarm,
  Command: Undead); round-trip verified both are present with their
  press_wash triggers intact (`_CAST_SUCCESS`, `sourceUnit=player`).
  Not yet live-tested in-game.
  **Open follow-up, not yet decided:** whether to reflow Crypt Swarm/
  Command: Undead into the vacated slot-1 position now that Lichfrost is
  gone, or leave the gap - and whether this "opportunities only, not a
  full hotbar" philosophy should be applied retroactively to any other
  layer/ability going forward.
- 2026-0