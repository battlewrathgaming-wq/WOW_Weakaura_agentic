# COA_GuardianPlates

A small custom addon (`COA_GuardianPlates.lua` / `.toc`) that suppresses
friendly PLAYER nameplates while leaving friendly guardian/pet/NPC
nameplates untouched, whenever the game's native "Friendly Nameplates"
option shows them - fills a real gap, since there is no stock
`nameplateShowFriendlyPlayers` CVar. Built 2026-07 as a low-risk
theorycraft companion addon, currently v2.0.

v2.0 (2026-07-08) adds an optional, independent threat-coloring capability
for ENEMY nameplates - the first of three "light capability" additions
picked from a code review of TurboPlates/Kui_Nameplates/Kui_Nameplates_Auras/
PlateBuffs plus role research on what tanks/healers/DPS actually rely on
(see `CAPABILITY_INVENTORY.md` and `ROLE_RESEARCH.md` in this folder). Two
more capabilities (a curated "needs action" debuff/cast highlight, and a
DPS-facing threat cue) are planned as later, equally independent additions -
this addon is deliberately not adopting any reference addon's full option
surface, just small on/off pieces shaped like their best ideas.

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
  (`platesByUnit`) as a fallback since `GetNamePlateForUnit(unit)` was
  confirmed (20/20 live events) to never resolve directly by the time
  `NAME_PLATE_UNIT_REMOVED` actually fires on this client.
- **Threat coloring (v2.0)**, its own independent tri-state capability
  (Off/Smart/Always On, `/coagp threat off|smart|always` or the options
  dropdown) - colors an ENEMY unit's health bar using
  `UnitDetailedThreatSituation("player", unit)`, a genuine WotLK-era API
  (patch 3.0.2), not a client backport like the nameplate system itself.
  "Smart" auto-detects a tank spec via real talent-point introspection
  (`IsTank()`, ported from Kui_Nameplates' `TankMode.lua`) rather than
  "whichever tab has the most points." Tank view and non-tank view read the
  same isTanking/status pair differently (a tank without aggro is bad for a
  tank, but the safe default for everyone else) - see
  `THREAT_COLOR_SECURE`/`_WARNING`/`_DANGER` in the file. Deliberately not
  gated behind the main on/off switch - its own capability, its own toggle.

## Commands

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
- **`/coagp threat off|smart|always`** (v2.0) - sets the threat-coloring
  tri-state. Independent of the on/off switch above.
- **`/coagp options`** / **`/coagp config`** - opens the Interface Options
  panel directly (on/off switch, the two color swatches, and the threat-
  coloring dropdown). `scan`/`probe`/`diag` are debugging aids and
  deliberately stay slash-only.

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
   with `/coagp threat smart` (or `always`) on and confirm the color
   actually tracks aggro state as expected; also not yet stress-tested
   against the same "wins the per-frame race" concern flagged in item 1
   above - threat coloring rides `UNIT_THREAT_SITUATION_UPDATE`/
   `UNIT_THREAT_LIST_UPDATE` events (near-real-time) plus the 0.5s
   reclassify sweep as a safety net, not a per-frame loop, on the
   (untested) assumption that's fast enough for this use case.
