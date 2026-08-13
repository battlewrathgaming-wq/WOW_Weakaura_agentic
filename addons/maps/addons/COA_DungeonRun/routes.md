# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_4 file(s) · 42 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `638379bc9b9a`._

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `UnitIsGhost`, `UnitName`

- `recapAttackers` *(:66, local)*
- `engagedBosses` *(:94, local)*
- `inInstance` *(:106, local)*
- `onUpdate` *(:129, function)*
- `Capture.Stop` *(:178, function)*
- `Capture.RunId` *(:193, function)*
- `Capture.Pulls` *(:195, function)*
- `onCombatStart` *(:199, local)*
- `onCombatEnd` *(:208, local)*
- `onPlayerDead` *(:225, local)*
- `onEncounterEngage` *(:232, local)*
- `captureOrigin` *(:246, function)*
- `onEnteringWorld` *(:263, local)*
- `Capture.Init` *(:267, function)*
- `Capture.Arm` *(:292, function)*

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
