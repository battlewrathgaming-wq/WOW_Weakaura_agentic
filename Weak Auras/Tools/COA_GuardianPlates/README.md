# COA_GuardianPlates ("COA State Plates")

A small custom addon (folder/SavedVariables name `COA_GuardianPlates`,
outward brand/Title `COA State Plates` as of v3.1) that suppresses friendly
PLAYER nameplates while leaving friendly guardian/pet/NPC nameplates
untouched, whenever the game's native "Friendly Nameplates" option shows
them - fills a real gap, since there is no stock
`nameplateShowFriendlyPlayers` CVar. Built 2026-07 as a low-risk
theorycraft companion addon, currently v3.5.42 (see `COA_GuardianPlates.toc`'s
`## Notes:` field for the full per-version changelog from v3.1 onward - this
README's own prose below stops narrating individual versions somewhere
around v3.5.2 and is kept for the earlier architectural history instead).

**Native aggroHighlight investigation (v3.5.16-v3.5.42):** a long, mostly-
resolved side investigation into recoloring/suppressing Ascension_NamePlates'
built-in red "you have aggro" nameplate indicator - fully written up in
`AggroHighlight_Saga/` (README/CHANGELOG/CODE_MAP/FINDINGS), not narrated
here. Short version: the hand-rolled glow texture (see below) is the addon's
real, reliable, production threat signal regardless of the outcome; the
native-highlight work is a nice-to-have, currently paused (not dead-ended)
pending further live testing.

**v3.0 (module split)** broke the addon into three files sharing one
namespace: `Core.lua` (the sole executor of plate visuals + shared
plate-driver plumbing), `FriendlyPlates.lua` (`ns.Friendly`, `/coagp` -
suppression + healer mode + NPC/pet color, all friendly-facing), and what
was originally `ThreatPlates.lua` (`ns.Threat`, hostile-facing). **v3.1
(brand pivot)** renamed the addon's outward brand from "COA Guardian
Plates" to "COA State Plates," and renamed `ThreatPlates.lua`/`ns.Threat`
to `EnemyPlates.lua`/`ns.Enemy` (`/coaep`) - threat coloring is now framed
as Enemy Plates' first sub-mode (paralleling healer mode as Friendly
Plates' sub-mode), leaving room for future enemy-facing sub-modes (needs-
action highlight, DPS threat-cue) without another rename. Both renames are
cosmetic/structural only - the AddOns folder name and
`COA_GuardianPlatesDB` SavedVariables key were deliberately left unchanged
so existing saved settings and the deploy path keep working.

v2.0 (2026-07-08) adds an optional, independent threat-coloring capability
for ENEMY nameplates - the first of three "light capability" additions
picked from a code review of TurboPlates/Kui_Nameplates/Kui_Nameplates_Auras/
PlateBuffs plus role research on what tanks/healers/DPS actually rely on
(see `CAPABILITY_INVENTORY.md` and `ROLE_RESEARCH.md` in this folder). Two
more capabilities (a curated "needs action" debuff/cast highlight, and a
DPS-facing threat cue) are planned as later, equally independent additions -
this addon is deliberately not adopting any reference addon's full option
surface, just small on/off pieces shaped like their best ideas.

v2.1 (2026-07-08) adds healer mode - not a fourth independent capability,
but a sub-option of the existing suppression switch itself (Battlewrath's
own correction: "Maybe this is a healer option to the suppression?"). For
friendly players in your group/raid, suppression behaves as normal until
their health drops below a threshold, at which point their plate's health
bar is revealed and held open via a TTL to avoid flicker. See the "Healer
mode" bullet below for the full mechanism.

v2.2 (2026-07-08) is an internal-only refactor, no user-facing behavior
change: a single `unitIndex` table (plate reference + `UnitGUID` + last-seen
timestamp) replaces the old plate-only cache, and every plate's sibling
region list (health bar, portrait, cast bar, level text, etc.) is now cached
on the plate's container and refreshed on the existing 0.5s reclassify
cadence instead of being re-queried via `GetChildren()`/`GetRegions()` every
single rendered frame for every suppressed unit. Prompted by a design
discussion about whether the addon's per-frame "hide, then reapply"
suppression loop was doing more work than necessary - it was, specifically
in that re-query - see the "Sibling cache" and "Unit index" bullets below.
Kept deliberately internal (no WeakAuras-facing API yet, per Battlewrath:
"Weak aura need first... DOT/HOT tracking... that'll be internal to the
addon") - the GUID field exists now so a future internal HoT/DoT tracker
has a stable per-entity identity to key off, since a pooled nameplate frame
can get reassigned to a different occupant mid-fight.

v2.2.1 (2026-07-08) removes the custom %HP `FontString` that v2.1.1-v2.2
drew on top of the revealed health bar. Live-testing surfaced a real bug
where its alpha got zeroed by the sibling-hide sweep and never restored
("I haven't been able to see the HP text"), but rather than ship that fix,
Battlewrath's call was to drop the custom text entirely: "Bar only. Then
let upstream handle how it is presented." The reveal now shows only the
plate's real native health bar - no addon-drawn text sits on top of it.

Also caught before this commit: the `.toc` file's file-list line had lost
its trailing "a" (`COA_GuardianPlates.lu` instead of `...lua`) during this
same session's editing - confirmed via byte-level hex dump, not visible
from a plain `cat`/`diff` check, since both showed the project and
deployed copies matching each other (just matching each other's wrong
content). That class of bug - the addon still "registers" enough to
appear enabled, but the real `.lua` never loads at all, so nothing it
does actually happens - is exactly why file changes on this project get
verified byte-for-byte, not just diffed for consistency between copies.

v2.2.2 (2026-07-08), built directly from a full logical-coherence code
review (function call graph, per-unit table lifecycle, event flow,
sibling-cache/unit-index invalidation, healer-mode state machine, DB field
spelling): fixes a real bug the review found - toggling `healerModeEnabled`
off (checkbox or `/coagp healermode off`) never cleared already-armed
`healAlerted`/`healAlertExpire` state, since `SweepHealAlertExpirations`
(the only code that clears it) refuses to run at all once the feature is
off. A revealed plate could stay revealed indefinitely until its nameplate
happened to despawn. Fixed with a new shared `SetHealerModeEnabled`
function (mirroring `SetEnabled`/`SetThreatMode`'s shape, same internal-
utility tier as `unitIndex`) that both the checkbox and slash command now
route through, actively collapsing back to normal suppression on disable
instead of waiting on a TTL or despawn - per Battlewrath's framing:
"Turning something off shouldn't lead to more work because it was on.
Instead letting the base line behaviour take over." Same commit also
normalizes a smaller asymmetry the review flagged: `ApplyGuardianColorForUnit`
now nils `originalColors`/`originalNameColors` after restoring a unit's
native color (mirroring how `ApplyThreatColorForUnit` already did), so a
future re-override always starts from a fresh capture.

CONFIRMED LIVE (Battlewrath, 2026-07-08): switching Healer Mode off while a
unit is currently revealed collapses that plate back to normal suppression
immediately - no stuck-open plates observed. Same session also confirmed
the v2.2.1 "bar only, let upstream handle presentation" design directly:
toggling the HP-value display in Ascension's own nameplate settings on/off
was reflected correctly in GuardianPlates' reveal, confirming the addon
really does draw nothing of its own on top of the native bar - whatever
Ascension is configured to show is what shows.

FLAGGED, not settled: this confirms the CURRENT mechanism (per-toggle
shared setters - `SetEnabled`/`SetThreatMode`/`SetHealerModeEnabled` - each
forcing an immediate collapse to baseline on disable) works as tested. It
is not being treated as finished/final architecture - `SetHealerModeEnabled`
in particular was built from a code-review finding without first agreeing
on its shape as a shared utility with Battlewrath, and remains open to
reconsideration/rewrite once that design conversation actually happens,
rather than locked in just because it passed this test.

v2.3.0 (2026-07-08) makes the three threat colors user-configurable.
Battlewrath: "make 3 color pickers for each state... so a DPS and Tank can
define what each state means to them." The previous hardcoded
`THREAT_COLOR_SECURE`/`_WARNING`/`_DANGER` constants (which already carried
a code comment anticipating exactly this: "A color picker could be added
later the same way npcColor/petColor already work") are now only the seed/
reset defaults - live reads come from
`COA_GuardianPlatesDB.threatColor{Secure,Warning,Danger}`, seeded non-nil at
load so `GetThreatColorForUnit` never has to special-case an unset value.
Naming stays state-based (secure/warning/danger), not tank/non-tank, since
the tank-view/non-tank-view branch in `GetThreatColorForUnit` already flips
which literal situation maps to which state - one stable color per state,
not per role. A parallel `CreateThreatColorRow` factory (deliberately not a
generalized reuse of the existing `CreateGuardianColorRow`, since a threat
state has no meaningful "native/unset" fallback the way a guardian/NPC
color override does) adds the 3 swatches to the options panel, right below
the existing threat-mode dropdown. Right-click resets a swatch to that
state's default color (not clear-to-nil, since threat coloring is always
either on-scheme or not shown at all). Guardrail confirmed via source read
before building: `DisarmThreatColors()` (the revert-on-disable path) only
ever reads from `originalThreatColors` - the captured native color - never
from the state constants, so making those colors configurable doesn't touch
the "return to normal values when turned off" behavior at all.

v2.4.0 (2026-07-08) closes a real design gap Battlewrath raised after the
color pickers shipped: "Health in WoW has meaning. Red = enemy, Green =
friendly, grey = enemy who is tagged... Currently we're over riding health
bar meaning." The v2.0-v2.3 threat coloring unconditionally overwrote the
health bar's own fill color, silently hiding the native tag-grey signal
(you can't loot a tagged creature) the moment a unit entered a threat
state. Restructured into two channels sharing the same 3 configured
colors:
- **Border/glow (always on)** - a `Backdrop`-templated frame around the
  health bar (`GetOrCreateThreatBorder`), mirroring TurboPlates' own
  live-proven target-glow technique (confirmed via its `Nameplates.lua`
  source) rather than inventing a new mechanism. Shows/hides/recolors with
  the same threat state as before, everywhere (open world, dungeon/raid,
  arena/pvp) - but never touches the bar's own native fill, so tag-grey/
  enemy-red/friendly-green stays readable underneath at all times.
- **Instance Fill (opt-in, off by default)** - the old fill-override
  behavior from v2.0-v2.3 still exists, now behind a checkbox
  (`COA_GuardianPlatesDB.threatInstanceFillEnabled`) in the options panel
  and `/coagp instancefill on|off`. Off by default - Battlewrath: "Instance
  fill should be off by default, as it's more intrusive than a new boarder
  element." Even when the checkbox is on, fill only actually applies while
  `IsInstanceFillZone()` reports eligible content (`party` or `raid` via
  `IsInInstance()`) - deliberately excludes arena/battleground, per
  Battlewrath: "Threat isn't really a mechanic as it's player driven" in
  PvP. Tag-loot competition is real in open world and irrelevant inside a
  dungeon/raid, which is the actual reasoning behind the split.

`IsInstanceFillZone()` is deliberately a single, named, documented
extension point rather than an inline check scattered across the file -
per Battlewrath's explicit request to "leave the door open for that party
(dungeon) and raid. Incase CoA has unique responses," since CoA may have
its own custom instance-like content (a possible "Mana Storm" zone was
mentioned - not independently verified to report a matching `instanceType`
here; the only "Mana Storm" reference actually found in this project is an
unrelated, coincidental native WeakAuras Load-condition field name). If
that's ever confirmed live, this is the one function to extend.

Both channels reuse the exact same 3 color pickers from v2.3 - no new
color configuration was needed, since the border and fill are just two
different places to paint the same threat-state color.

v2.5.0 (2026-07-08) - two related fixes found by walking through the
design out loud with Battlewrath. First: "Smart" auto-detection (the
`threatMode` tri-state's mode 1) is gone. It worked by checking
`UnitClass("player")` against the 4 stock Wrath classes
(Warrior/Paladin/Druid/DeathKnight) and reading talent points off their
tank trees - Battlewrath confirmed CoA's classes are entirely custom
(Necromancer, Reaper, Bloodmage, etc.), so `UnitClass("player")` never
matched any of those 4 strings and `IsTank()` always returned `false`.
"Smart" had been silently non-functional since the day it shipped - it
always resolved to permanent DPS-view, for every class, regardless of
what was actually being played. Rather than build detection against CoA's
own custom talent trees, `threatMode` is now a plain Off/On toggle, and a
new manual **Tanking** checkbox (`COA_GuardianPlatesDB.threatTanking`,
also `/coagp threat tanking on|off`) replaces the detection outright - the
player just states which lens to view threat through. `GetTalentPointsSpent`/
`IsDeathKnightTank`/`IsDruidTank`/`IsTank` are removed entirely, not just
disabled - they were checking classes that don't exist here, so there was
no reason to keep them around as dead code.

Second: the threat border/glow (v2.4) used to show for all three states,
including "secure." Battlewrath's observation: whichever role reaches
"secure" is already in its boring, expected, default state (a tank holding
aggro correctly spends most of a fight there) - a constant glow there
"doesn't drive behaviour," only the transition to warning/danger does. The
DPS-safe state was already silent by construction (no color assigned at
all); this update gives the tank side that same treatment instead of
tank-secure being the one loud, ever-present exception. The border is now
suppressed specifically for the "secure" state - matched by name, not by
comparing the color's live RGB value (which would break the moment
someone recolors a swatch to coincidentally match another state). The fill
channel (Instance Fill) is deliberately untouched - it still paints all 3
states including secure, so a tank glancing across a dense instance pull
still gets a steady "everything's fine" color read at a glance, while the
glow itself is reserved for the actual outliers. Battlewrath: "being able
to see stable colors and then the single outliers is important in high
density... but that's more boring than glows everywhere. Boring is good
here."

v2.6.0 (2026-07-08) adds a group gate: threat coloring (both the border and
Instance Fill) now only ever engages while `IsInGroup()` is true. Solo,
you're always the only possible threat generator on whatever you're
fighting - every pull would read as "you have aggro," which isn't
information, it's noise. Checked TurboPlates' own source first
(Battlewrath: "shall we inspect how turbo plate handles it?") - it turns
out TurboPlates has no equivalent gate at all; it colors a solo pull
exactly like a group threat situation, so this isn't prior art being
copied, it's a genuine improvement over it. One incidental finding worth
noting for later: TurboPlates' tank-role detection (`UpdatePlayerTankStatus`)
checks a manual MAINTANK raid assignment and LFG-assigned role before
falling back to talent points - both of those are class-agnostic party-role
signals, unlike the class-name check `IsTank()` used before v2.5 removed
it, so they'd actually work fine against CoA's custom classes if
auto-detection is ever worth revisiting. Not pursued now - Battlewrath was
explicit: "Don't touch the tank selector yet."

The gate is deliberately keyed on actual group membership (`IsInGroup()`),
not zone/instance type - Battlewrath: "where it matters is all in the
group content... when aggro is someone's responsibility, we give the
option to gate around that." This is separate from, and narrower than,
`IsInstanceFillZone()`, which still only ever governs the Instance Fill
channel specifically. Known open edge case, not solved here: a solo
player's own pet/guardian could in theory hold aggro independently even
while solo - whether that's a real, common scenario on CoA (and whether
CoA's custom classes even have pets/guardians generating independent
threat) is unconfirmed. The `/coagp status` readout now also reports
"grouped" vs "solo - inactive" so it's obvious at a glance why threat
coloring may be silently doing nothing.

Brought into this project folder 2026-07-08 as its source of truth - it
previously only existed in the deployed game install with no project-folder
copy at all (unlike `Tools/COA_DevDump/`, which already followed this
convention), meaning it had no version history and would have been lost if
that install folder was ever wiped or reinstalled. This README and the
`.lua`/`.toc` files here are now the source of truth; the game-install copy
is just a deployment target, same convention as COA_DevDump.

## Deploying it

Copy both files into
`<GameInstall>/Interface/AddOns/COA_GuardianPlates/`, then enable it at
character select (or `/reload` if already logged in). Always overwrite the
game-install copy wholesale from this folder rather than hand-editing it in
place.

## What it actually does

- Uses Ascension's real backported modern nameplate API
  (`C_NamePlate.GetNamePlateForUnit`, `NAME_PLATE_UNIT_ADDED`/`_REMOVED`,
  each plate carrying a real unit token) rather than the stock pre-Legion
  no-unit-token assumption that seemed like the safe default for a 3.3.5
  client - confirmed via TurboPlates' own live, working source, after an
  earlier combat-log/name-matching version of this addon crashed live on a
  wrong CLEU argument-layout assumption. See the file's own header comment
  for the full story.
- Suppression only ever fires for a unit that is both `UnitIsPlayer` and
  `UnitIsFriend("player", unit)` - selectively hides the health bar/
  portrait/etc. while explicitly keeping the floating name visible
  (`SetPlateBarsHidden`), since `SetAlpha(0)` on the whole plate cascades
  to every child region including the name.
- Optional cosmetic color override for friendly guardian/pet/NPC nameplates
  (health bar + name text), split into two independently-configurable
  buckets (NPC vs Pet/Guardian/Totem, via `UnitPlayerControlled`) - gated
  entirely behind the addon's own on/off switch (the "armed gate":
  Battlewrath, "We shouldn't hijack the user's UI. We only apply anything
  when we're armed.") so nothing is ever touched while disabled.
- Nameplate frames on this client are pooled and reused across unrelated
  units - `RestorePlateOnRemoved()` explicitly restores a plate's true
  native state before bookkeeping is wiped, using a cached plate reference
  (`unitIndex`) as a fallback since `GetNamePlateForUnit(unit)` was
  confirmed (20/20 live events) to never resolve directly by the time
  `NAME_PLATE_UNIT_REMOVED` actually fires on this client.
- **Threat coloring (v2.0)**, its own independent capability
  (`/coagp threat off|on` or the "Enable threat coloring" checkbox) -
  colors an ENEMY unit's health bar using
  `UnitDetailedThreatSituation("player", unit)`, a genuine WotLK-era API
  (patch 3.0.2), not a client backport like the nameplate system itself.
  **Role is a manual choice (v2.5), not auto-detected** - a "Tanking"
  checkbox (`threatTanking`, also `/coagp threat tanking on|off`) picks
  tank view vs DPS view. An earlier "Smart" auto-detect mode existed
  (v2.0-v2.4) but was removed after Battlewrath confirmed it checked
  `UnitClass("player")` against the 4 stock Wrath classes - classes that
  don't exist on CoA's custom class roster - so it had silently never
  worked. Tank view and non-tank view read the same isTanking/status pair
  differently (a tank without aggro is bad for a tank, but the safe default
  for everyone else). **The 3 colors are user-configurable (v2.3.0)** via
  color pickers in the options panel
  (`COA_GuardianPlatesDB.threatColorSecure`/`Warning`/`Danger`, seeded from
  `THREAT_COLOR_DEFAULT_SECURE`/`_WARNING`/`_DANGER` in the file) - right-
  click a swatch to reset it to that state's default. Deliberately not
  gated behind the main on/off switch - its own capability, its own toggle.
- **Threat border + Instance Fill (v2.4, glow refined v2.5)** - the threat
  color above drives a border/glow around the health bar
  (`GetOrCreateThreatBorder`, mirroring TurboPlates' own target-glow
  technique) that never touches the bar's native fill, so tag-grey/enemy-
  red/friendly-green stays readable underneath. The glow shows for
  "warning"/"danger" but is **deliberately suppressed for "secure"** (v2.5)
  - that's the boring, expected default for whichever role reaches it, so a
  constant glow there added no information; only the transition to
  warning/danger should draw the eye. The old fill-override behavior is a
  separate, opt-in "Instance Fill" checkbox (`threatInstanceFillEnabled`,
  off by default, `/coagp instancefill on|off`), which only actually fills
  the bar while `IsInstanceFillZone()` reports eligible content
  (`party`/`raid`, excludes arena/pvp) - and unlike the glow, fill still
  paints all 3 states including secure, so a tank glancing across a dense
  instance pull gets a steady "everything's fine" color read at a glance
  while the glow is reserved for actual outliers. Both channels share the
  same 3 threat-color pickers - no new color config.
- **Healer mode (v2.1, reveal simplified in v2.2.1)**, a sub-option of
  suppression itself rather than an independent capability - only ever does
  anything while the main on/off switch is enabled. For a friendly player
  also in your party/raid (`IsGroupOrRaidFriendlyPlayer` - everyone else
  stays untouched, to avoid noise from players outside your group),
  suppression reveals just the real native health bar the moment health
  drops below `healerModeThreshold` (default 80%) -
  `ApplyHealAlertRevealState` is a PARTIAL reveal, not a full unsuppress:
  level text, portrait, cast bar, and everything else stays hidden
  (live-test feedback, Battlewrath: "The only thing I would omit from the
  healer display is the target's level element. It's just the health bar
  we want."). Held open via `healerModeTTL` (default 4s) that only ever
  refreshes forward while still below threshold - once healed above it,
  the existing TTL timestamp is left alone rather than cleared, so the
  reveal keeps holding until it genuinely expires
  (`SweepHealAlertExpirations`, piggybacked on the existing 0.5s reclassify
  throttle) - this is what prevents a HoT tick bouncing HP across the line
  from turning into a flicker show. Event-driven off `UNIT_HEALTH`/
  `UNIT_MAXHEALTH`, not polled - no meaningful processing cost.
- **Unit index (v2.2)**, internal only - a single `unitIndex` table
  (`IndexUnit`/`GetIndexedPlate`/`GetUnitGUID`) replacing the old
  plate-only cache, populated on every `UpdatePlateForUnit` pass (ADDED +
  0.5s reclassify). Adds a real `UnitGUID(unit)` field alongside the plate
  reference - GUID is stable per-entity even when a pooled nameplate frame
  gets reassigned to a different occupant, unlike the unit token itself,
  which matters for any future internal consumer (a HoT/DoT tracker) that
  needs to keep tracking the same entity across a frame reassignment. No
  WeakAuras-facing API yet - kept internal per Battlewrath's call.
- **Sibling cache (v2.2)** - the plate's non-name sibling regions (health
  bar, portrait, cast bar, level text, etc.) used to be re-queried via
  `GetChildren()`/`GetRegions()` from scratch on every single rendered
  frame, for every currently suppressed unit, just to hide the same set of
  regions over and over. Since a pooled frame's structural children are
  fixed by its XML template, the sibling list is now cached on the
  container itself (`RefreshSiblingsCache`/`GetSiblings`) and only
  recomputed on the 0.5s reclassify cadence rather than every frame - the
  every-frame suppression loop just reads the cached list. Bounded
  staleness window (0.5s), not unbounded: see known open item below.

## Commands

As of v3.0's module split, Friendly Plates and Enemy Plates each own their
own slash command - `threat`/`instancefill` are no longer subcommands of
`/coagp`, they moved to `/coaep`. Historical mentions of `/coagp threat...`
elsewhere in this doc reflect the pre-split (v2.0-v2.5) command surface.

**`/coagp` - Friendly Plates** (`ns.Friendly`, suppression + healer mode +
NPC/pet color):
- **`/coagp on|off|toggle`** - persistent (SavedVariables, per-character)
  enable switch.
- **`/coagp status`** - prints current state + active plate count.
- **`/coagp scan`** - one-shot dump of every active nameplate (unit token,
  name, isPlayer, isFriend, plateName) to `COA_GuardianPlatesDB.lastScan`.
  `/reload` after running to flush to disk.
- **`/coagp probe`** - one-shot frame-structure dump of the first
  suppressed friendly-player plate, to `COA_GuardianPlatesDB.lastProbe`.
  Only needed if the floating name still disappears despite the selective-
  suppression path.
- **`/coagp diag`** - prints how many REMOVED-restore events needed the
  cached-plate fallback vs resolved directly. `/reload` then check
  `COA_GuardianPlatesDB.removedLog` for full per-event detail.
- **`/coagp healermode on|off`** (v2.1) - toggles the healer-mode sub-
  option; also a checkbox in the options panel, directly under the main
  enable checkbox. **`/coagp healermode threshold <n>`** and
  **`/coagp healermode ttl <secs>`** tune the reveal threshold (default 80)
  and hold time (default 4s) - slash-only, matching the addon's existing
  split between GUI (everyday on/off) and slash-only (tuning/debugging).
- **`/coagp options`** / **`/coagp config`** - opens the Interface Options
  panel directly (on/off switch, healer-mode checkbox, the two guardian/NPC
  color swatches). `scan`/`probe`/`diag` are debugging aids and deliberately
  stay slash-only.

**`/coasp` - Core** (shared infrastructure, not either sub-module):
- **`/coasp log on|off|status|dump [n]|copy [n]|clear`** (v3.4.3, `copy`
  added v3.4.4) - unified debug log + perf monitor. `dump` prints a recent
  slice straight to chat; `copy` opens a selectable popup with the full
  buffer (or last `n`) since the default chat frame can't be copied from
  at all. See the v3.4.3/v3.4.4 changelog entries above for the full
  design notes.

**`/coaep` - Enemy Plates** (`ns.Enemy`, threat coloring is its current
sub-mode; was `/coatp` before the v3.1 brand pivot):
- **`/coaep on|off`** (v2.0) - toggles threat coloring.
- **`/coaep tanking on|off`** (v2.5, auto-detect added v3.2) - manually
  picks tank view (aggro = secure/boring) vs DPS view (no aggro = safe/
  boring); replaces the old "Smart" auto-detect, which never worked against
  CoA's custom classes. As of v3.2, this checkbox is only actually
  consulted when the game has no role for the player - Core.lua's shared
  `ns.GetPlayerRole()` (backed by `UnitGroupRolesAssigned`) auto-supplies
  TANK/HEALER/DAMAGER for a Dungeon/Raid Finder-formed group, and this
  manual setting is the fallback for everything else (manually-formed
  groups, world content). `/coaep status` shows which source is active.
  Also a checkbox in the options panel, directly under "Enable threat
  coloring."
- **`/coaep instancefill on|off`** (v2.4) - toggles whether the threat
  color also fills the health bar while inside eligible instance content
  (`party`/`raid`). Off by default; also a checkbox in the options panel,
  directly under the 3 threat-color swatches.
- **`/coaep caution <pct>`** (v3.3, "Mob Aggro Cue") - tunes the early-
  warning threshold (default 80). `UnitDetailedThreatSituation`'s raw
  threat percentage is checked against this, on both sides symmetrically:
  a DPS's own rawPercentage crossing it warns before Blizzard's native
  status would (which stays flat at 0 all the way to 100% raw threat); a
  tank sees the same warning color if any OTHER party/raid member's
  rawPercentage crosses it (since the tank's own rawPercentage freezes the
  moment they become the primary target - confirmed via Blizzard's own
  documented API behavior, not assumed). Reuses the existing "warning"
  color - no new color swatch. Known scope limit: only scans party/raid
  member units, not their pets.
- **`/coaep status`** - prints current threat-coloring state, including
  the aggro-cue caution threshold.
- **`/coaep options`** / **`/coaep config`** - opens the "Enemy Plates"
  options sub-panel directly (threat-coloring dropdown, the 3 threat-color
  swatches, instance-fill checkbox), nested under "COA State Plates" in
  Interface Options.

v3.3.1 (2026-07-08) fixed a real polling inefficiency in the Mob Aggro Cue's
tank-side other-member scan, found by Battlewrath asking directly "What is
their polling on that collection? And what triggers it?" rather than
assuming it was fine. Two changes: the roster it scans moved into a Core-
owned cache (`ns.GetGroupUnits()`, refreshed only on `GROUP_ROSTER_UPDATE`)
instead of rebuilding via `GetNumRaidMembers`/`GetNumPartyMembers` from
scratch on every single call; and the scan itself now only runs from the
0.5s reclassify tick (and the one-off unit-added event), not from the
higher-frequency threat-update events - Battlewrath: "we already have the
tighter probing on damage events... those are a great stack of limiting
traffic against CoA."

v3.4 (2026-07-08) is a research-driven pass against a folder of downloaded
threat-plate/threat-meter addons Battlewrath collected specifically for this
(`Addon refs_threat/` - NamePlatesThreat, TidyPlates_ThreatPlates, bdThreat,
QoL_ClassicThreat-TBC, ThreatMeter), covering both cadence ("politeness")
and visual design:
- **Debounce on change.** `ApplyThreatColorForUnit` now caches the last
  state actually applied per unit (state name, color, whether fill was
  engaged) and skips Core's executor calls entirely when nothing has
  changed - mirroring the confirmed-real pattern in TidyPlates'
  `Modules/Threat.lua` (`UpdateThreatLevel` only restyles on an actual
  transition). Previously every dispatch - including the high-frequency
  `OnThreatEvent` path - re-ran `SetGlow`/`SetHealthBarColor` even when the
  result was identical to last time. Cache is wiped on unit removal (pooled
  frame reuse) and on `DisarmThreatColors` (so re-enabling threatMode always
  reapplies rather than trusting stale state).
- **Glow technique redesign.** Battlewrath's direct feedback: "the dash
  lines are very.. technical, for a fantasy game" - the animated `PixelGlow`
  border (rotating dashed segments, in place since v2.7) reads fine at the
  small 40x30px icon scale used elsewhere in this project (the WeakAuras
  rotation-icon work) but not at nameplate scale. Replaced with three
  distinct tiers, hand-specified by Battlewrath ("Secure: Only the health
  fill... Cue/threat change: A immidiate glow around the plate. Danger
  state: A wider glow area, stronger saturation. Motion if we find
  something that looks nice"), mapped to three different techniques already
  present in the embedded LibCustomGlow-1.0 library:
  - **Secure** - unchanged: no glow/border at all, health-bar fill only
    (still gated behind Instance Fill + `IsInstanceFillZone()`).
  - **Cue** (the "warning" state, including both the native status-based
    warning and the Mob Aggro Cue's early percentage warning) -
    `ButtonGlow_Start`, the classic soft "ability ready" bloom (inner/outer
    glow plus a fading spark ring). No discrete motion, appears immediately
    - matches "an immediate glow around the plate."
  - **Danger** - `AutoCastGlow_Start`, small shimmering particles orbiting a
    ring pushed further out from the plate than the Cue bloom, with the
    configured color's HSV saturation boosted 1.6x via a small helper
    (`BoostSaturation`) - matches "a wider glow area, stronger saturation.
    Motion."
  - The original `PixelGlow` technique is kept in Core.lua only as the
    default fallback style for any future glow caller that doesn't specify
    one - Enemy Plates itself no longer uses it.
  `ns.SetGlow`/`ns.ClearGlow` gained a `style` parameter and now track which
  technique is active per (health bar, key) pair, since `ButtonGlow_Start`
  has no `key` concept of its own (one glow per frame) and a unit can
  switch tiers (e.g. warning -> danger) across calls - the old technique is
  explicitly stopped before the new one starts, rather than risking two
  glows animating on the same frame at once.

v3.4.1 (2026-07-08) is two live-feedback fixes on top of v3.4, both from
watching it in practice:
- **Danger glow calmed down.** Battlewrath: "still a big aggressive. It's
  lots of dotted points tracing around super fast. We want something that
  says 'you should act' not 'panic panic panic'." `AutoCastGlow` draws 4
  concentric rings of `N` particles each; the original `N=6`, `frequency=0.7`
  meant 24 particles completing a lap in ~1.4s on a nameplate-sized frame -
  read as a swarm, not a cue. Cut to `N=2` (8 particles total) and
  `frequency=0.18` (~5.6s/lap) - still visibly in motion, but a slow drift
  instead of a frantic blur. The "wider glow area, stronger saturation"
  part (scale/offset/saturation boost) is unchanged - that wasn't the
  complaint, only the speed/density was.
- **Real combat gate, closing a previously-deferred gap.** Battlewrath: "The
  rendering also applies to all mobs. Not those where a threat table has
  been established. (Party members, self, threat)" `ns.IsPotentialThreatUnit`
  (Core.lua) used to only check hostile/attackable, explicitly deferring a
  combat check - documented at the time as "a gap is real but deliberately
  deferred to after this split." That gap was the actual bug: for the
  tank-view branch, `isTanking` is simply `false` for a mob nobody has any
  threat on at all (never pulled, wandering in the open world), same value
  as a mob someone else is actively tanking - both fell into the same
  "danger" branch. Added `UnitAffectingCombat(unit)` to the gate, which is
  only true once a mob is actually engaged by someone (that's what puts an
  entry on its threat table in the first place) - threat coloring now only
  ever renders on a mob with a real, live threat table, never on an
  untouched one.

v3.4.2 (2026-07-08) tightens the v3.4.1 combat gate into the real thing,
prompted by Battlewrath asking exactly how strict the "threat table
established" check actually was: "A group is the basis for the threat
table. We can: safe when it is attacking me. Safe when I am in a group, and
it is attacking me. We can not: assess our threat relationship from the
mob, to every creature around me and then player (not in group), until I
get all the aggro." Confirmed that framing is structurally correct -
`UnitDetailedThreatSituation` requires a real Blizzard unit token as its
first argument (self/pet/party/raid/target/focus/mouseover), and there's no
token for an arbitrary nearby non-grouped player, so their relationship to
a mob is simply unaddressable from here. Group is the only multi-entity
boundary this addon has tokens for at all.

That confirmed `UnitAffectingCombat` (added v3.4.1) was the wrong tool for
the actual gate - it only proves a mob is fighting *someone*, not that
*we* have any entry on its threat table, so a mob being tanked by an
unrelated bystander nearby could still pass it. `GetThreatColorForUnit`
used to immediately collapse that with `isTanking = isTanking and true or
false` - `UnitDetailedThreatSituation("player", unit)` returns nil across
the board when player has no entry on this specific mob's threat table at
all, and that line silently treated "no relationship exists" the same as
"on the table, not currently tanking," which is how an untouched mob could
still land in the tank-view "not tanking -> danger" branch. Replaced with
an explicit `if isTanking == nil then return nil end` before any
defaulting happens - confirmed via reading TidyPlates_ThreatPlates'
`Modules/Threat.lua` that this is exactly their own pattern too
(`if UnitThreatSituation("player", unit.unitid) then ... end`, tracking
`UnitAffectingCombat` as a separate, non-gating attribute rather than the
source of truth). `UnitAffectingCombat` stays in `ns.IsPotentialThreatUnit`
as a cheap pre-filter only, to skip fully idle world mobs before the real
per-relationship check runs.

v3.4.3 (2026-07-08) adds `/coasp log` - a unified debug log + perf monitor,
built directly in response to the v3.4.2 fix not producing the expected
color live: "Would a logger and performance monitor help here? /coatp log,
it can be a unified log for anything loaded. lives in the call time to
/reload." Battlewrath's own follow-up settled it into `/coasp` (matching
the addon's actual "COA State Plates" brand) and confirmed it belongs in
Core, not either sub-module - same reasoning as the unit index/role/roster
caches: shared infrastructure, one buffer, not three private logs.

Lives in `Core.lua` since it's genuinely cross-module: `ns.Log(source, fmt,
...)` appends a timestamped entry to a capped ring buffer (300 entries,
`COA_GuardianPlatesDB.log`) only when logging is toggled on
(`COA_GuardianPlatesDB.logEnabled`) - every call site checks
`ns.IsLogging()` first and bails before doing any `string.format`/table
work, so leaving it off (the default) costs one boolean read, not a hidden
tax on the paths this whole session has been trying to keep light.
`ns.PerfStart()`/`ns.PerfEnd(source, label, start)` bracket timed sections
using `debugprofilestop()` (confirmed genuine WotLK 3.3.5 API, not
combat-restricted) and log the elapsed milliseconds through the same
`ns.Log` path.

- **`/coasp log on|off`** - toggles the monitor.
- **`/coasp log status`** - prints on/off + current buffered entry count.
- **`/coasp log dump [n]`** - prints the most recent `n` entries (default
  20) straight to chat - unlike `scan`/`probe`, a log line is short enough
  to read live rather than needing a `/reload` + SavedVariables inspection,
  though the full buffer is still there in `COA_GuardianPlatesDB.log` too
  (`/reload` to flush to disk, same convention as `removedLog`/`lastScan`/
  `lastProbe`).
- **`/coasp log clear`** - wipes the buffer.

Instrumented so far: `ns.IsPotentialThreatUnit` logs its can't-attack/
combat-state outcome per unit; `GetThreatColorForUnit` (restructured to a
single return point so every exit - including "nothing to show" - gets one
line) logs the unit name, the raw `isTanking`/`status`/`rawPct`
`UnitDetailedThreatSituation` actually returned, which lens (tanking/non-
tanking) it read through, and what state it resolved to; and both the 0.5s
reclassify tick (total duration + unit count) and
`IsAnotherMemberApproachingAggro` (the Mob Aggro Cue's group scan) are
perf-timed. This is the direct tool for the still-open "not performing the
expected response" report - watch `/coasp log dump` during a real pull
instead of reasoning about it from documentation/reference-addon behavior
that may not carry over 1:1 to Ascension's backported client.

v3.4.4 (2026-07-08) adds a copyable export popup, prompted directly by
Battlewrath hitting the log's actual usability limit: "There is a copy
function that can appear in the chat / the debugger. Can we feed responses
to them? I can't copy raw from chat." Confirmed real - WotLK's default
chat frame has no text-selection/copy support at all, a genuine client
limitation, not something an addon can patch from inside the chat frame
itself. Built the standard WoW addon workaround instead (the same trick
WeakAuras' own Import/Export window uses): `ns.ShowCopyableText(title,
text)` in Core.lua pops a small movable frame with a single multi-line
EditBox, pre-filled and pre-selected (`SetFocus` + `HighlightText`) the
moment it opens, so Ctrl+A/Ctrl+C works immediately - no "BackdropTemplate"
mixin needed on the frame, since that's a Retail (8.0+) requirement and
this is a 3.3.5 client where `SetBackdrop` already works directly on a
plain Frame (matching `GetOrCreateFallbackBorder`'s own existing use of
it). Deliberately generic (title + text in, nothing log-specific) so any
future export need can reuse the same box.

**`/coasp log copy [n]`** wires this to the log: builds the same
`[time][source] msg` lines `dump` prints to chat, joined with real
newlines, and opens the popup instead. Unlike `dump`'s chat-friendly
default (a short recent slice), `copy` defaults to the *entire* buffer
when no count is given - the point of copying out is usually getting the
whole session's trace, not a quick glance.

v3.4.5 (2026-07-08) fixes an over-correction that the v3.4.3 logger caught
red-handed on the very first real capture. Live in a group, watching two
Kobold Miners/Tunnelers that were genuinely in combat the whole time
(`UnitAffectingCombat=1` steady across many ticks), the log showed
`GetThreatColorForUnit(...) -> nil (isTanking=nil, no threat-table entry
for player)` on every single pass - and Battlewrath's own read of the
result nailed the actual gap: "I was in a group, so when I was watching
the player, the addon never said 'get aggro from them'." The v3.4.2 nil
check correctly excludes a mob NOBODY in the group has any relationship to
(an unrelated bystander's fight elsewhere) - but it over-corrected: it also
went silent on a mob the GROUP has genuinely engaged (a party/raid member
has a real entry on its threat table) while the player personally hadn't
landed a hit on it. That second case is exactly "Safe when I am in a
group, and it is attacking me [my group]" from Battlewrath's own earlier
framing - and for a tank, it's the single most useful case to flag: an add
the group is already fighting that the tank hasn't picked up at all is a
real "go get it" moment, not silence.

Added `HasAnyGroupThreatEntry(mob)` - same roster-scan shape as the Mob
Aggro Cue's own `IsAnotherMemberApproachingAggro` (Core's cached
`ns.GetGroupUnits()`), but asking a different question: not "is someone
else close to pulling it," just "does ANYONE else have a real entry on
this mob's table at all." When player's own `isTanking` comes back nil,
`GetThreatColorForUnit` now checks this before giving up - if the group
has a genuine entry, player's missing one is substituted with zero
personal threat (`isTanking, status, rawPct = false, 0, 0`) rather than
bailing to "nothing to show," letting the existing tank-view "not
tanking -> danger" branch fire exactly as it already does for a real
lost-aggro case.

Cost-disciplined the same way as the Mob Aggro Cue scan it mirrors: this
only actually runs from the `allowAggroCueScan`-gated cadence (0.5s
reclassify tick / unit-added), not the high-frequency threat-event path.
The hot event path reads a small cache (`groupThreatEntryCache`, keyed by
unit, refreshed only on the gated cadence) instead of either re-scanning
or blindly returning nil - the latter would have flickered the color off
between the 0.5s tick (which knows the group has this mob) and every
threat event in between. Cache is cleared alongside the existing debounce
cache (`ClearAppliedState`, on unit removal and on Disarm) so a
reused/pooled unit token never inherits a stale answer for a different
occupant.

v3.4.6 (2026-07-08) adds roster visibility to `HasAnyGroupThreatEntry`
after the very next capture with v3.4.5 live showed the scan genuinely
running (0.00ms - cheap, confirmed working) and still finding nothing, for
the same two Kobolds staying in combat the entire time. That's not
necessarily wrong - it's the correct, silent result if nobody in the
scanned roster (self + `ns.GetGroupUnits()`) actually has any relationship
to that specific mob (someone outside the party/raid could be the one
fighting it, which is exactly the case this design is supposed to stay
silent for) - but there was no way to tell that apart from "the roster
itself is wrong/empty" using only the previous log line. Now logs the
roster it actually scanned (unit token + name) and each member's own raw
`isTanking` read, every time the scan runs, so a "found nothing" result
can be confirmed rather than assumed.

v3.4.7 (2026-07-08) fixes the real bug the v3.4.6 roster visibility was
built to catch - and it caught it on the very next capture. Every single
`HasAnyGroupThreatEntry` scan logged `scanning roster: <empty>`, for a
full session, despite `IsInGroup()` already having passed (the log lines
only appear after that gate). A general threat-mechanics research pass
(Wowpedia/Warcraft Wiki) confirmed a real party member being actively
attacked should already have a genuine threat-table entry - "Every unit is
added to the threat table upon beginning combat" - so an empty roster scan
wasn't an engagement-timing nuance, it was Core's own roster cache being
wrong.

Battlewrath's own instinct to step back and check TurboPlates directly
("Turbo plates has known working agro mechanics?") found the actual root
cause: TurboPlates' `Nameplates.lua` (installed and presumably working on
this exact server) builds its party roster with `for i = 1,
GetNumGroupMembers() - 1 do -- -1 because player not in party array` - the
*modern* (Cataclysm 4.1.0+ on a stock client) group-size API, not
`GetNumPartyMembers()`/`GetNumRaidMembers()`, the classic-era pair this
addon deliberately chose earlier after confirming `GetNumGroupMembers()`
was Cata-only *on a stock client*. TurboPlates using it live on Ascension
is strong evidence the server backported it as a convenience global - and
that `GetNumPartyMembers()` was the one quietly failing here, not
`UnitDetailedThreatSituation` or anything else in the resolution chain
(confirmed separately: the moment the player actually held aggro
personally, `GetThreatColorForUnit` resolved `isTanking=1 status=3
rawPct=255 -> secure` correctly on the first try - the core logic was
never the problem).

Core's `RefreshGroupRoster` now prefers `GetNumGroupMembers()` (falling
back to the old pair only if that global is ever somehow absent), with the
same `-1` party adjustment TurboPlates uses - `GetNumGroupMembers()`
counts the player, `GetNumPartyMembers()` didn't. Raid numbering is
unaffected (both APIs already counted the player there).

v3.4.8 (2026-07-09): v3.4.7 alone didn't fix it. Battlewrath redeployed
and re-tested, and the very next capture showed the exact same
`HasAnyGroupThreatEntry(...) scanning roster: <empty>` line, still while
grouped. First step was ruling out the obvious alternate explanation:
re-read TurboPlates' `Nameplates.lua`/`Core.lua` directly and confirmed
`local GetNumGroupMembers = GetNumGroupMembers` is just caching the real
client global into an upvalue, not a TurboPlates-provided shim/polyfill -
so the API choice in v3.4.7 was correct, and the bug had to be somewhere
else in the call path.

The real problem: `RefreshGroupRoster` (and `RefreshPlayerRole`) were
always invoked through a bare `pcall(...)` on `GROUP_ROSTER_UPDATE` with
the error result thrown away - if either function ever raised an error,
it would fail silently forever with zero trace in the log, and we'd have
no way to tell "it ran and found nothing" apart from "it never
successfully ran at all." Added a log line inside `RefreshGroupRoster`
itself on every run (which branch - raid/party, which API it called,
the raw pre-adjustment return, and the final roster it built), and error
surfacing on both `pcall`s in the `GROUP_ROSTER_UPDATE` handler so a
thrown error is now visible instead of swallowed. Also added `/coasp
roster` to force a refresh and print the result immediately, without
needing to leave and rejoin a group just to get one more data point.

Separately, while checking the code path: solo combat producing zero
`GetThreatColorForUnit` log lines at all is not a new bug - `EnemyPlates.lua`
has carried a "GROUP GATE (v2.6)" comment since that version, and the
function returns immediately via `if not okGroup or not inGroup then
return nil end` before ever touching `UnitDetailedThreatSituation`. Threat
coloring has only ever been a group-context feature by original design;
this session's captures didn't introduce that behavior, they just made it
visible for the first time.

Next step is the same loop as before: redeploy, `/coasp log clear` +
`/coasp log on`, re-run the same grouped scenario, and share a fresh
capture - this time the `RefreshGroupRoster:` log line itself should say
exactly what the API call returned and whether an error was thrown, so
the next fix (if still needed) will be evidence-based rather than another
guess.

v3.4.9 (2026-07-09): the v3.4.8 diagnostics paid off immediately. A fresh
capture confirmed `GetNumGroupMembers()` and the roster-build logic were
correct the whole time - after roughly 13 minutes of the same session
still showing `scanning roster: <empty>` while grouped, the very next
`RefreshGroupRoster` log line showed `party1=Hemoroiid`, and the
tank-view substitution fired exactly as designed: `isTanking=nil but
group has an entry - substituting zero personal threat` ->
`tanking=true isTanking=false status=0 rawPct=0 -> danger` - the "go get
aggro from them" cue, live, for the first time. Battlewrath separately
confirmed via `/coasp roster` that the roster read back 1 unit once
things settled.

So the fix was never wrong, but the roster sat empty for a stretch
despite being genuinely grouped the entire time - a classic WotLK
timing race: `GROUP_ROSTER_UPDATE` fires once at `PLAYER_ENTERING_WORLD`
(e.g. on `/reload`), but the client's own group-roster data isn't always
settled at that exact instant, so the very first refresh can legitimately
read a 0 that isn't a bug, just a call made one tick too early. It then
self-corrected only because something else happened to fire
`GROUP_ROSTER_UPDATE` again later in the session.

Rather than rely on that happening (or on remembering to run the new
`/coasp roster` command by hand), added a one-shot ~2 second delayed
re-check specifically after `PLAYER_ENTERING_WORLD` - WotLK 3.3.5 has no
`C_Timer`, so a tiny `OnUpdate`-driven frame accumulates elapsed time and
fires once, then hides itself. By 2 seconds in, the client's group data
is reliably settled, so this closes the race automatically instead of
depending on luck.

v3.5.0 (2026-07-09): investigating a report of an enemy nameplate
disappearing when Battlewrath personally engaged a mob a party member was
already fighting turned up a more fundamental logging gap. Several live
captures showed a single displayed mob name (e.g. "Rot Hide Mongrel")
swinging between totally different states within a couple of seconds -
`secure` to `danger` to dropping out of tracking entirely - which read
like a single mob's threat table flickering. But every log line only
ever printed `UnitName(unit)`, never the underlying nameplate token or
the creature's actual GUID, so there was no way to distinguish "one real
mob's state is genuinely swinging fast" from "the client recycled this
pooled nameplate slot onto a different physical mob that happens to
share the same generic name" - a real possibility when several of the
same low-level mob are up in the same area.

Added `ns.DescribeUnit(unit)` to Core.lua (name + the raw unit token,
stable per plate slot, + a short GUID suffix, unique per physical
creature) and wired it into every relevant log line in `IsPotentialThreatUnit`,
`HasAnyGroupThreatEntry`, and `GetThreatColorForUnit`. The next capture
will show directly whether the GUID changes mid-swing (plate recycling,
not a bug) or stays constant (a genuine single-mob issue worth chasing
further).

Separately, Battlewrath confirmed one of the specific swings in the
captured log (`secure` -> `danger` on Rot Hide Mongrel around 00:50:15-45)
was simply real taunt usage - "I was playing a tank. So I taunted a few
times." Taunt forces top-of-table instantly (`secure`), and if it isn't
backed by enough real threat generation, decays back to "not tanking"
(`danger`, tank branch's own comment: "a tank without aggro needs to
taunt back") once the effect wears off. That's expected, correctly-read
behavior, not a bug - a useful reminder that not every wild-looking swing
in these logs needs a code fix; some of them are just combat happening
as designed.

v3.5.1 (2026-07-09): the v3.5.0 GUID tagging paid off on the very next
capture. It showed `Rot Hide Mongrel[nameplate1|02BD93]` and
`Rot Hide Mongrel[target|02BD93]` - identical GUID - both being
independently tracked and colored within the same reclassify tick.
`NAME_PLATE_UNIT_ADDED` had fired for both `nameplate1` and `target` for
what `C_NamePlate.GetNamePlateForUnit` resolves to the exact same plate
Frame - almost certainly this Ascension client's nameplate-unit-ID
backport re-announcing a mob's plate under the `target` token once it's
targeted, layered on top of its regular `nameplateN` token. Without a
guard, both tokens got processed independently every tick, each with its
own state cache (`lastAppliedState[unit]`, `groupThreatEntryCache[unit]`,
etc.), both writing to the same underlying health bar/glow frame - a very
plausible root cause for both the rapid state swings and the originally
reported disappearing-plate bug (two uncoordinated code paths fighting
over one frame).

Added `ns.plateOwner` (plate Frame -> the unit token that's the
canonical owner) to Core.lua. `NAME_PLATE_UNIT_ADDED` now checks whether
the resolved plate already belongs to a different, still-active unit
token before adding the new one to `ns.activeUnits` - if so, it's
recognized as a duplicate alias and skipped entirely (nothing indexed,
no Friendly/Enemy `OnUnitAdded` call). `NAME_PLATE_UNIT_REMOVED` mirrors
this: a removal for a token that was never actually tracked (i.e. it was
skipped as a duplicate at ADD time) now no-ops immediately instead of
running restore/cleanup logic for something that was never applied, and
only clears `plateOwner` when the *canonical* owner is the one being
removed. The reclassify tick carries the same guard as defense-in-depth,
in case a duplicate ever slips in before the ADD-time check runs.

This is the strongest lead yet on the disappearing-plate report. Next
step: redeploy v3.5.1, reproduce the same scenario (party member already
engaged with a mob, then personally engage/target it), and confirm via
`/coasp log` that only one unit token now gets processed per plate.

v3.5.2 (2026-07-09): v3.5.1 alone didn't fix it. Battlewrath redeployed
and the very next capture still showed both `Rot Hide Gnoll[nameplate3|02D83C]`
and `Rot Hide Gnoll[target|02D83C]` processed independently every tick,
same GUID, same as before - though this time in close agreement with each
other (danger -> warning -> secure in lockstep), rather than fighting.

Root cause: `UNIT_THREAT_SITUATION_UPDATE`/`UNIT_THREAT_LIST_UPDATE` fire
with whatever unit token Blizzard's own event system provides directly -
including `target` itself, whenever the current target's threat situation
changes - completely bypassing `ns.activeUnits`/`ns.plateOwner` entirely.
Core.lua's handler for these two events resolves a plate fresh via
`C_NamePlate.GetNamePlateForUnit(unit)` and calls `ns.Enemy.OnThreatEvent(unit, plate)`
unconditionally, with no awareness of the v3.5.1 guard, which only ever
covered the ADD/REMOVE/reclassify code paths. Since threat events fire
far more often than plate add/remove or the 0.5s reclassify tick, this
was almost certainly the dominant source of the double processing all
along, not the smaller paths fixed first.

Added the same `ns.plateOwner` check to the `UNIT_THREAT_SITUATION_UPDATE`/
`UNIT_THREAT_LIST_UPDATE` handler: if the resolved plate's canonical
owner is a different, still-active unit token, the event is skipped as a
duplicate alias instead of calling `ns.Enemy.OnThreatEvent`. All three
ways a unit can enter Enemy Plates - add/remove, the reclassify tick, and
threat events - now share one consistent dedup guard.

Next: redeploy v3.5.2, reproduce the same scenario, and confirm via
`/coasp log` that `target` no longer appears in the log at all once its
matching `nameplateN` token is already tracked.

**Confirmed working** - the very next capture showed repeated
`UNIT_THREAT_LIST_UPDATE(...[target|...]) -> skipped, duplicate alias for
already-tracked plate owned by nameplateN` lines, with no further
duplicate processing for that plate afterward. Battlewrath separately
confirmed the plate stayed visible the whole session - the original
disappearing-plate report is resolved. Also noted: yellow "warning" isn't
showing up much, but that's expected - the test fights were short enough
that there wasn't real aggro competition to trigger it; and taunt still
produces a sharp, immediate glow-state jump, which is correct (taunt
really is an instant state change, not something that should ease in).

v3.5.3 (2026-07-09): while confirming the above, Battlewrath noticed a
separate, smaller gap - "roster doesn't update on player join. I had to
manually run it once when someone joined." That's the same class of race
as the v3.4.9 login/reload fix, just triggered by `GROUP_ROSTER_UPDATE`
firing for a mid-session join/leave instead of `PLAYER_ENTERING_WORLD` on
reload - the event can fire before the client's own roster data is fully
settled, so the immediate refresh reads a stale count with nothing to
correct it afterward (v3.4.9's delayed re-check was only ever wired to
`PLAYER_ENTERING_WORLD`, not the other three group-roster events).
Generalized it: every event in `groupEventFrame` (`PLAYER_ROLES_ASSIGNED`,
`ROLE_CHANGED_INFORM`, `GROUP_ROSTER_UPDATE`, `PLAYER_ENTERING_WORLD`) now
schedules the same ~2s delayed re-check, not just the login/reload case.

**Confirmed live (2026-07-09), real dungeon pull as DPS:** the v3.5.2
dedup fix held across a full pull with 4+ mobs simultaneously in combat -
`/coasp log` showed clean "skipped, duplicate alias" lines for every
`target`/`nameplateN` pair, perf staying sub-1ms per reclassify tick even
with multiple mobs tracked, threat lead changing hands between party
members mid-fight with no double-processing or state fighting. Also
surfaced, consistently across every mob in the pull: `GetThreatColorForUnit`
correctly substitutes zero personal threat when the group has an entry the
player doesn't (`isTanking=nil but group has an entry - substituting zero
personal threat` -> `tanking=false isTanking=false status=0 rawPct=0 ->
nil`), but the DPS branch has no catch-all the way the tank branch does
(`elseif not isTanking then danger`) - so a mob the team already has
secured renders no color at all for a DPS who hasn't personally engaged
it. Raised as an explicit design fork rather than assumed: should DPS view
get a neutral "team is engaged with this, no action needed" indicator to
support sweeping the pull and pinpointing which nameplate matches a party
frame's HP dip?

Battlewrath's answer, closing the fork: "Keep the DPS view narrow. They
need to know am I in immediate danger. Not what the full combat state is.
Tank owns agro. Healer owns stability. DPS owns damage." Current behavior
(no color = no personal action needed) is correct as designed, not a gap -
no code change. The role-scoped read applies generally: each view should
only surface what that role is responsible for acting on, not the full
group threat picture.

Two smaller items flagged during the same test, both still open: the
mid-session join delayed re-check (v3.5.3) wasn't exercised (no join event
occurred in this pull), and every capture with a real (non-substituted)
personal threat entry shows `rawPct=255` rather than an actual 0-100
percentage - not yet investigated in code, worth checking specifically
since it feeds the DPS-side Mob Aggro Cue's `rawPct >= cautionPct` check.

**Both items above resolved (2026-07-09):** a follow-up capture of
Battlewrath joining/leaving group 4 times over confirmed the v3.5.3 delayed
re-check works - three separate cycles showed a stale immediate read
(`rawNum=1 -> 0 unit(s): <empty>`) followed ~2s later by the re-check
correctly catching up (`rawNum=2 -> 1 unit(s): party1`). The `rawPct=255`
anomaly turned out to already be documented in the Mob Aggro Cue's own doc
comment above `GetThreatColorForUnit`: `UnitDetailedThreatSituation`'s raw
threat percentage "stops updating when you become the primary target" -
every 255 reading occurred exactly when `isTanking=true` (secure, or a
taunt-driven warning), i.e. the frozen case the code already anticipated.
Confirmed inert either way: the tank branch never reads `rawPct` (only
`isTanking`/`status`), and the Mob Aggro Cue's `rawPct >= cautionPct` check
only runs in the non-tanking branch, where the value is still live.
Battlewrath's own framing of the frozen value doubles as a sanity check on
the design itself: "You are the primary target. So that is evidence of the
danger state for DPS/Healer" - correct, and already fully captured by the
DPS/else branch's own `if isTanking then color = danger` check, which reads
the real `isTanking` boolean directly rather than needing `rawPct` at all.

v3.5.5 (2026-07-09) replaces the v3.4.9/v3.5.3 delayed re-check's manual
`OnUpdate` elapsed-time accumulator with `C_Timer.After`, prompted directly
by Battlewrath: "go for it. It gives us basis to use that for other similar
event handling. So we don't engrain custom internal clocks when we can have
the game do it for us." `C_Timer.After`/`C_Timer.NewTimer` are confirmed
genuine Ascension client globals (TurboPlates' own `Nameplates.lua`/
`Auras.lua`/`Core.lua` use them directly throughout - `ScheduleThreatUpdate`/
`ScheduleHealthUpdate`/`ScheduleAbsorbUpdate` in particular use the exact
same "pending flag guards against scheduling more than one timer" pattern
this addon already had), not a WotLK-3.3.5-lacks-this workaround as
originally assumed when the OnUpdate frame was first built (v3.4.9). Same
behavior exactly: `recheckPending` is still a plain boolean, a second event
arriving while one is already scheduled does not restart the wait, and the
callback still re-runs `DoRefresh` ~2s after the triggering event. The only
change is who does the waiting - the client's own timer, not this addon
polling every rendered frame for up to 2 seconds after every group event.
No functional behavior change; removes `recheckFrame`/`recheckElapsed`
entirely.

v3.5.6 (2026-07-09) adds a deliberately loose overload safety valve,
prompted by Battlewrath thinking ahead to raid-scale content: "Should we
build in a suspend when that hangs too much? Raids can have 40 units in the
play space, if not more for those not engaged yet." The math from already-
measured numbers didn't show a real problem - the reclassify tick's own
marginal cost (~0.03ms/unit from the PERF lines) puts a 40-unit raid pull
around ~1ms every 0.5s, and the actual scaling risk isn't nameplate count
at all but engaged-mobs x raid-roster-size in EnemyPlates' own group scans
(`HasAnyGroupThreatEntry`, `IsAnotherMemberApproachingAggro`, which loop the
full roster per engaged mob) - a rough worst case (10 simultaneous adds x a
40-man roster) still only landed around 5-6ms/tick. Nothing observed or
extrapolated justified throttling on its own, but Battlewrath's framing
settled it as forward-looking insurance rather than a fix: "add that
insurance now at the very open end (so a long wait), just so we have some
catchment when that system balloons/spider-webs."

Core.lua now measures the reclassify tick's own duration unconditionally
(`debugprofilestop()` bracketing the per-unit loop, stored in
`ns.lastReclassifyMs`) instead of only when `/coasp log` is on - unlike
`ns.PerfStart`/`ns.PerfEnd`, this is a genuine functional signal that has
to work live regardless of debug logging, not a debug-only instrument, so
it can't be gated the same zero-cost-when-off way. `ns.IsReclassifyOverloaded()`
trips only above `RECLASSIFY_OVERLOAD_MS = 15` - well beyond anything
measured or extrapolated above, so it should never fire under any normal
raid load, only a genuine runaway. EnemyPlates.lua's `OnReclassify` checks
this before allowing the Mob Aggro Cue's expensive group scans for that
tick; the cheap `isTanking`/`status` check that drives all core threat
coloring is untouched by this and keeps running every tick regardless.
Re-evaluated fresh every tick against the previous tick's duration - not
sticky/latched - so it self-recovers the instant load drops back down,
the same auto-correcting shape as the roster delayed re-check rather than
needing a manual reset. Logs once per overloaded tick (only when `/coasp
log` is on) so a real trip is visible if it ever happens. Not yet
live-tested at raid scale - dungeon-scale testing so far has never come
close to tripping it.

v3.5.7 (2026-07-09) shifts the diagnostic focus from the decision layer to
the render layer, prompted directly by Battlewrath: "I think we should
shift onto the render side. As whilst we've seen bits. I don't have strong
confidence it's working as we desire." Everything logged up to this point -
`GetThreatColorForUnit`, `HasAnyGroupThreatEntry`, the roster/dedup work -
only ever confirmed what state got *decided*. The debounce check
(`StatesMatch`) and the actual executor calls
(`SetGlow`/`ClearGlow`/`SetHealthBarColor`/`ClearHealthBarColor`) were
completely silent before this - a debounce misfire (e.g. a pooled-plate
reuse wrongly read as "no change") or a failed glow/fill application (a
`GetHealthBar` resolution failure, a LibCustomGlow call erroring against an
unexpected argument) would have been invisible to `/coasp log`, only
catchable by watching the screen directly.

EnemyPlates.lua's `ApplyThreatColorForUnit` now logs the debounce outcome
(applied vs. skipped, with the resolved state) and exactly what it
dispatches to Core (`SetGlow` with which style, `ClearGlow`,
`SetHealthBarColor`/`ClearHealthBarColor` for Instance Fill), tagged with
`ns.DescribeUnit` like every other Enemy Plates log line. Core.lua's
`SetGlow`/`ClearGlow`/`SetHealthBarColor`/`ClearHealthBarColor` now log
whether a health bar frame actually resolved, which LibCustomGlow technique
started or stopped (or switched, e.g. warning -> danger on the same
frame), whether a call fell back to the static border (LCG unavailable),
and surface any error a LibCustomGlow call itself throws (previously
swallowed silently by a bare `pcall`). Together this closes the loop the
whole session's testing hasn't touched yet - decision, debounce, and actual
screen output are now all visible in one log, so the next live test can
confirm (or catch) the render side the same way the roster/dedup work was
confirmed earlier this session. Not yet live-tested - this is the
instrumentation pass, the actual render-side verification pass is next.

v3.5.8 (2026-07-09) adds a render test rig, prompted directly by
Battlewrath asking: "Are we able to feed dummy input into it? Like I have
a target, then it builds a data stream off them?" Real threat states are
hard to summon on demand - they depend on real combat, real group
membership, real timing - which made the render side slow to iterate on.
`/coaep rendertest secure|warning|danger|clear [fill]` forces a state onto
your CURRENT TARGET's plate by calling the exact same Core executor
primitives `ApplyThreatColorForUnit` itself dispatches to
(`SetGlow`/`ClearGlow`/`SetHealthBarColor`/`ClearHealthBarColor`),
bypassing `GetThreatColorForUnit`'s real `UnitDetailedThreatSituation` read
entirely. This means the actual render pipeline - the same code path, same
LibCustomGlow techniques, same fill logic - can be exercised on demand on
anything with a nameplate (a training dummy works fine, matching the
earlier "training dummy" discussion), in or out of combat, solo or
grouped, with each of the three states and the fill channel toggled
independently and repeatably, instead of waiting for real conditions to
line up. Deliberately debug/test-only: doesn't touch `threatMode`, the
group gate, or the debounce cache (`lastAppliedState`), so a forced test
state can't leave the addon in some different real-mode state afterward,
and a subsequent genuine `ApplyThreatColorForUnit` call on the same unit
won't be fooled by a stale debounce entry from the test. Combined with the
v3.5.7 render-side logging, this is the concrete plan for closing out the
long-standing "not yet live-tested" items on the border/glow/Instance Fill
channels (see known open items 8-10 below) - cycle through all 4
`rendertest` states with `/coasp log on`, confirm each dispatch line has
its matching Core confirmation line, and watch the actual nameplate.

v3.5.9 (2026-07-09) is two corrections from Battlewrath after trying the
v3.5.8 render test rig live. First, an architecture correction: "How come
coaep? I'd stated core should carry everything." The rig lived under
EnemyPlates.lua's own `/coaep` in v3.5.8, which broke the project's own
established principle - already on record for the player-role index (see
its doc note above): "have core as the executor... everything pulls
requirements from what we attach to it." Moved the whole command surface to
Core's shared `/coasp`. Core now owns a small registry
(`ns.RegisterRenderTest(name, applyFn, steps)`) - a module registers what
states it can render-test and how to apply one; Core's dispatcher calls the
registered `applyFn` directly for a one-off state, with no idea what
"secure"/"warning"/"danger" even mean. `EnemyPlates.lua`'s render logic
itself didn't change - `TestRenderState` was simply renamed to
`ns.Enemy.RenderTestApply` and registered with Core at load time instead of
being wired into its own slash command. This also sets up cleanly for the
still-deferred "needs action highlight" capability (open item, task list) -
whenever that's built, it registers its own states the same way, no new
command needed.

Second, a usability request: "Can we not just run a test cycle that I kick
off? Moving through every testable state with a c-time delay?" Manually
typing each `rendertest` state one at a time (and the backtick copy-paste
mishap that happened trying it) made for a clunky test loop. Added
`/coasp rendertest cycle [delaySeconds]` (default 3s) - chains
`C_Timer.After` calls (one step, wait, next step - same pattern as the
v3.5.5 delayed re-check, the client's timer does the waiting) to
automatically step through every registered module's states in order:
secure, warning, warning+fill, danger, danger+fill, clear. A generation
token guards against overlapping runs - any new `/coasp rendertest`
invocation (another cycle, or a manual one-off state) supersedes whatever
chain was already in flight, so starting a fresh test never fights an old
one for the same plate. Not yet live-tested - this is the fix for the
architecture/usability issues found while trying to live-test v3.5.8, not
itself confirmed working yet.

v3.5.10 (2026-07-09) fixes two things found live-testing v3.5.9's cycle
command. First, a UX gap: Battlewrath tried `/coasp rendertest 5` (no
"cycle"), which doesn't match the `cycle` branch - it fell through to the
one-off state-test branch with a literal state named `"5"`, printing
"unknown state '5'". No actual cycle ran from that command; a bare number
is now accepted directly as shorthand for `cycle` with that delay, since no
real state name is ever numeric.

Second, and more real: `/coasp rendertest cycle 5`, typed correctly, ran
all 6 registered steps in the right order (confirming the cycle engine
itself works) but every color-based step reported "unknown state" -
Battlewrath: "It can't run the cycle if it's not the correct command. It
ran through 6 steps and self reported each time of unknown state." That's
the signature of a real bug in `RenderTestApply`'s color lookup, not a
dispatch problem: it used the classic Lua `condition and A or B` idiom -
```lua
local color = (stateName == "secure" and COA_GuardianPlatesDB.threatColorSecure)
    or (stateName == "warning" and COA_GuardianPlatesDB.threatColorWarning)
    or (stateName == "danger" and COA_GuardianPlatesDB.threatColorDanger)
```
which silently breaks whenever the "true" branch's own value is itself
falsy - if `threatColorSecure` (etc.) were ever nil, `stateName == "secure"
and nil` evaluates to nil regardless of whether the name actually matched,
so the whole chain falls through and reports "unknown state" for a
perfectly valid, correctly-typed name. This only ever affected the test
rig - production `GetThreatColorForUnit` assigns colors via direct
`color, stateName = COA_GuardianPlatesDB.threatColorX, "x"` pairs, not this
idiom, so real threat coloring was never at risk. Rewritten as explicit
if/elseif with nothing to trip over, and split into two distinct messages:
an actually-unrecognized state name vs. a recognized name whose color
config happens to be missing/nil - so the print tells you which one it
really is instead of conflating them.

## Known open items (not yet resolved, flagged in the code itself)

1. **Color-tint reclassify cadence not yet stress-tested.** Alpha
   suppression needed full per-frame cadence to beat the native driver's
   own per-frame recalculation (confirmed live). The guardian/NPC color
   override rides the slower 0.5s reclassify sweep instead, on the
   (untested) assumption that bar/name *color* doesn't need to win the same
   per-frame race alpha does. If a custom color visibly flickers/reverts in
   testing, move `ApplyGuardianColorForUnit` into `ReapplySuppressed`'s
   every-frame loop instead (needs its own tracked-unit set mirroring
   `suppressed`).
2. **Spec-aware auto-toggling deliberately deferred.** E.g. auto-disable
   suppression on a healer spec (so friendly health bars are always visible
   without needing to remember to toggle manually) - needs its own research
   pass to confirm the right spec-change event on this client before wiring
   it up. Not started.
3. **Pet/guardian/totem stays a two-way split, not three-way.** No single
   reliable Lua call cleanly distinguishes pet vs guardian vs totem for a
   unit you don't own - would need heuristics (creature type/family) that
   risk misclassifying edge cases, so this stays `UnitPlayerControlled`'s
   clean two-way split (pet/guardian/totem combined vs plain NPC) per
   Battlewrath's call. Not a bug, just a known scope limit.
4. **Threat coloring (v2.0) not yet live-tested.** The
   `UnitDetailedThreatSituation` status-value semantics (0=safe,
   1=approaching threat cap, 2=tanking-but-insecure, 3=tanking-securely)
   are the standard documented behavior for this API era, but haven't been
   confirmed against a real pull on this specific server yet. Watch a pull
   with `/coaep on` (and `/coaep tanking on` if tanking) and
   confirm the color actually tracks aggro state as expected; also not yet
   stress-tested against the same "wins the per-frame race" concern flagged
   in item 1 above - threat coloring rides `UNIT_THREAT_SITUATION_UPDATE`/
   `UNIT_THREAT_LIST_UPDATE` events (near-real-time) plus the 0.5s
   reclassify sweep as a safety net, not a per-frame loop, on the
   (untested) assumption that's fast enough for this use case.
5. **Healer mode (v2.1) reveal/collapse timing partially live-tested.**
   Threshold detection, the level-omission fix (v2.1.1), and the v2.2.1
   bar-only reveal (custom %HP text removed) are all confirmed working
   live. The default 80%/4s values themselves are still a first guess, not
   watched against a real heal/damage exchange yet - re-test with a
   deliberately easy-to-trigger threshold (`/coagp healermode threshold
   95`) to confirm the hold/collapse cadence feels right before trusting
   the defaults blind.
6. **Sibling cache (v2.2) staleness window not yet live-tested.** If this
   client ever lazily creates a new child region on a plate after the last
   0.5s refresh (e.g. a raid-icon texture that only appears once actually
   assigned), it would go unhidden on a suppressed plate until the next
   refresh window - bounded, not silent-forever, but worth watching for if
   anything unexpected shows up on an otherwise-suppressed plate. Not
   observed yet; flagged proactively based on how the cache is built.
7. **`SetHealerModeEnabled` (v2.2.2) confirmed live, but not settled
   design.** Live-tested: switching Healer Mode off while a unit is
   currently revealed collapses that plate back to normal suppression
   immediately, no stuck-open plates observed. That said, this function
   was built from a code-review finding without first agreeing its shape
   as a shared utility with Battlewrath - it works, but stays open to
   reconsideration/rewrite once that design conversation actually happens,
   rather than being treated as finished just because it passed this test.
8. **Threat border + Instance Fill (v2.4-v2.5) not yet live-tested.** The
   border/glow technique is confirmed-real prior art (TurboPlates' own
   target-glow), but this addon's own use of it hasn't been watched in a
   real pull yet - confirm the border shows/hides/recolors correctly
   alongside tag-grey and native red/green, that it stays silent for
   "secure" (v2.5) while still showing for warning/danger, and that
   Instance Fill actually engages only inside a real dungeon/raid and stays
   off in open world and arena/pvp. Also unconfirmed: whether any
   CoA-specific instance-like zone (the "Mana Storm" mention) reports
   `party`/`raid` under `IsInInstance()` or needs `IsInstanceFillZone()`
   extended - watch for this if that content turns out to be real and
   Instance Fill doesn't engage there as expected.
9. **Manual Tanking toggle (v2.5) not yet live-tested.** Removing "Smart"
   auto-detection was a code-level fix for a confirmed-broken assumption
   (CoA's classes aren't the 4 stock classes `IsTank()` checked), but the
   replacement checkbox itself hasn't been watched in a real tank pull yet
   - confirm toggling "Tanking" actually flips which literal aggro state
   reads as "secure" vs "danger," and that the secure-state glow suppression
   behaves correctly for both checkbox positions.
10. **Group gate (v2.6) not yet live-tested.** Confirm threat coloring
    actually goes silent solo and lights back up the moment a group forms
    (`GROUP_ROSTER_UPDATE` isn't separately hooked - the gate is just read
    live inside `GetThreatColorForUnit` on the existing reclassify/event
    cadence, so it should pick up a group forming without any extra
    wiring, but that's an assumption, not yet watched). Also unconfirmed:
    whether a solo player's own pet/guardian holding independent aggro is
    a real scenario on CoA at all - see the GROUP GATE doc note in the
    `.lua` file for the full reasoning.
