# Frame cost — the whole bench

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._
_Source fingerprint `24f580307730` — run `py addons/tools/emit_addon_census.py --check` to find out if this has gone stale._

**Read the OnUpdate table first.** It is the only kind of entry that runs *every frame*; everything below it fires when something happens.

**Lifetime is arithmetic: `installs − clears`.** **transient** = every handler is torn down again, so it runs only while something is happening (a drag, a running session task). **PERSISTENT** = none are, so they run for as long as the addon is loaded — that is where a cost would live. **MIXED** = both in one file, which a boolean hid on the first pass.

**★ `hot?` marks a COMBAT-FREQUENCY event.** Only events we have MEASURED go on that list - currently the two combat-log events, at 57-82 lines/second in a dungeon here (`addons/planning/cleu_on_this_fork.md`). It is where to look first when something is blamed on cost, and it is deliberately NOT a list of events someone guessed were expensive.

**`throttle?` is a LEAD, not a verdict.** It reports whether the file contains an accumulator pattern at all. **`no` means go and look** — it does not mean the handler is unthrottled. The parent `README.md` records what the first run flagged and why every one of it was correct-by-design.

## ★ OnUpdate — runs every frame

| Addon | File | Installs | Clears | Lifetime | throttle? |
|---|---|---|---|---|---|
| COA_DevDump | `core.lua` | 1 | 1 | transient | **no — look** |
| COA_DevDump | `task_callwitness.lua` | 1 | 1 | transient | yes |
| COA_DevDump | `task_cleu.lua` | 1 | 1 | transient | yes |
| COA_DevDump | `task_cvarlog.lua` | 1 | 1 | transient | yes |
| COA_DevDump | `task_perf.lua` | 1 | 1 | transient | yes |
| COA_DevDump | `task_petlog.lua` | 1 | 1 | transient | yes |
| COA_DevDump | `task_satnav.lua` | 1 | 1 | transient | yes |
| COA_GuardianPlates | `Core.lua` | 1 | 0 | **PERSISTENT** | yes |
| COA_GuardianPlates | `FriendlyPlates.lua` | 1 | 0 | **PERSISTENT** | yes |
| COA_PetGrid | `core.lua` | 2 | 0 | **PERSISTENT** | yes |
| COA_DungeonRun | `capture.lua` | 1 | 1 | transient | yes |
| COA_DungeonRun | `editor.lua` | 2 | 3 | transient | yes |
| COA_Landmarks | `beacon.lua` | 1 | 2 | transient | yes |
| COA_Landmarks | `minimap.lua` | 1 | 1 | transient | **no — look** |
| MancerLedger | `core.lua` | 1 | 0 | **PERSISTENT** | yes |
| MancerLedger | `minimap.lua` | 3 | 1 | **MIXED** — 2 persistent | yes |

**20 handler(s) installed; 7 PERSISTENT.** The persistent ones are the whole point of this page.

## Timers

| Addon | File | Detail |
|---|---|---|
| COA_GuardianPlates | `Core.lua` | C_Timer.After |

## ★ HOT events — combat frequency

_The first place to look when anything is blamed on cost. Measured at 57-82 lines/second in a dungeon on this fork — `addons/planning/cleu_on_this_fork.md`. Whatever ships must be no heavier than the handler that number was measured on._

| Addon | File | Detail |
|---|---|---|
| COA_DevDump | `task_cleu.lua` | `COMBAT_LOG_EVENT_UNFILTERED` |
| COA_DevDump | `task_petlog.lua` | `COMBAT_LOG_EVENT_UNFILTERED` |
| COA_PetGrid | `feed_live.lua` | `COMBAT_LOG_EVENT_UNFILTERED` |

## Events we listen for

| Addon | File | Detail |
|---|---|---|
| COA_DevDump | `task_cleu.lua` | COMBAT_LOG_EVENT_UNFILTERED, PLAYER_REGEN_DISABLED |
| COA_DevDump | `task_petlog.lua` | COMBAT_LOG_EVENT_UNFILTERED |
| COA_GuardianPlates | `Core.lua` | GROUP_ROSTER_UPDATE, NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED, PLAYER_ENTERING_WORLD, PLAYER_ROLES_ASSIGNED, ROLE_CHANGED_INFORM, UNIT_HEALTH, UNIT_MAXHEALTH, UNIT_THREAT_LIST_UPDATE, UNIT_THREAT_SITUATION_UPDATE |
| COA_StatePlates_Aggro | `Options.lua` | ADDON_LOADED |
| COA_StatePlates_Friendly | `Options.lua` | ADDON_LOADED |
| COA_StatePlates_Enemy | `Options.lua` | ADDON_LOADED |
| COA_PetGrid | `core.lua` | ADDON_LOADED |
| COA_PetGrid | `feed_live.lua` | COMBAT_LOG_EVENT_UNFILTERED, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED |
| COA_DungeonRun | `capture.lua` | INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA |
| COA_DungeonRun | `core.lua` | ADDON_LOADED |
| COA_Landmarks | `core.lua` | ADDON_LOADED, PLAYER_ENTERING_WORLD |
| COA_Landmarks | `pins.lua` | WORLD_MAP_UPDATE |
| MancerLedger | `core.lua` | ADDON_LOADED, PLAYER_ENTERING_WORLD, PLAYER_REGEN_ENABLED |

## ★ Hooks — hooksecurefunc

_The highest-risk column: a hook runs inside someone else's flow._

| Addon | File | Detail |
|---|---|---|
| COA_GuardianPlates | `Core.lua` | `frame`, `texture` |
| COA_Landmarks | `beacon.lua` | `SelectQuestLogEntry` |

## ★ Hooks — HookScript on frames we do not own

_Anyone else doing the same can clobber ours, and silently._

| Addon | File | Detail |
|---|---|---|
| COA_Landmarks | `pins.lua` | `OnShow` |
