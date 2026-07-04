# Necromancer slot assignment (Resources tier)

The real-content counterpart to `ELEMENT_INVENTORY.md` - that file
describes what each `Template_shadow.py` slot is *for*, in the abstract,
across every class; this file records what's actually assigned to
Necromancer's slots, traceably, updated as real content gets built and
live-tested. Positions below are copied from `ELEMENT_INVENTORY.md`'s Row
C/D (v0.14) exactly - this file mirrors the mask, per `BUILD_METHOD.md`,
it doesn't re-derive geometry.

Scope: Resources tier only for now, per Battlewrath's explicit request.
Other tiers get their own rows here once they're built out the same way.

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
