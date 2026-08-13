# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_4 file(s) · 41 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `3faca18b3bdf`._

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `UnitIsGhost`, `UnitName`

- `recapAttackers` *(:61, local)*
- `engagedBosses` *(:89, local)*
- `inInstance` *(:101, local)*
- `onUpdate` *(:124, function)*
- `Capture.Stop` *(:168, function)*
- `Capture.RunId` *(:183, function)*
- `Capture.Pulls` *(:185, function)*
- `onCombatStart` *(:189, local)*
- `onCombatEnd` *(:198, local)*
- `onPlayerDead` *(:215, local)*
- `onEncounterEngage` *(:222, local)*
- `onEnteringWorld` *(:230, local)*
- `Capture.Init` *(:246, function)*
- `Capture.Arm` *(:271, function)*

## `core.lua`  —  events: ADDON_LOADED

- `NS.Say` *(:4, function)*
- `status` *(:8, local)*
- `list` *(:23, local)*
- `slash` *(:36, local)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.Load` *(:45, function)*
- `db` *(:66, local)*
- `Store.Point` *(:95, function)*
- `Store.Open` *(:122, function)*
- `Store.Get` *(:141, function)*
- `Store.Close` *(:146, function)*
- `Store.Delete` *(:152, function)*
- `Store.Ids` *(:157, function)*
- `Store.AddLeg` *(:192, function)*
- `Store.SetOutside` *(:200, function)*
- `Store.SetArrival` *(:206, function)*
- `Store.SetInstance` *(:219, function)*
- `Store.AddBoss` *(:233, function)*
- `Store.Counts` *(:245, function)*
- `Store.GetUI` *(:257, function)*
- `Store.SetUI` *(:266, function)*
- `Store.AddMarker` *(:270, function)*
- `mapFraction` *(:270, local)*
- `composeId` *(:270, local)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:39, local)*
- `Widget.Init` *(:54, function)*
- `Widget.Toggle` *(:110, function)*
