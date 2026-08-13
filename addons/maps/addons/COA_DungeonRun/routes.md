# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_5 file(s) · 55 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `cf52e28a7318`._

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `GetMapInfo`, `UnitIsGhost`, `UnitName`

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
- `onEnteringWorld` *(:305, local)*
- `Capture.Init` *(:309, function)*
- `Capture.Arm` *(:334, function)*

## `core.lua`  —  events: ADDON_LOADED

- `NS.Say` *(:4, function)*
- `status` *(:8, local)*
- `list` *(:23, local)*
- `slash` *(:36, local)*

## `map.lua`

**pulls:** `GetCurrentPlayerPosition`

- `Map.PointsOn` *(:81, function)*
- `Map.Offset` *(:98, function)*
- `Map.TilePath` *(:104, function)*
- `ensureDots` *(:114, local)*
- `clearDots` *(:131, local)*
- `paint` *(:135, local)*
- `context` *(:161, local)*
- `Map.Show` *(:167, function)*
- `Map.Toggle` *(:187, function)*
- `step` *(:192, local)*
- `Map.Init` *(:199, function)*
- `Map.RunsFor` *(:248, function)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.Load` *(:46, function)*
- `db` *(:67, local)*
- `Store.Point` *(:112, function)*
- `Store.Open` *(:143, function)*
- `Store.Get` *(:162, function)*
- `Store.Close` *(:167, function)*
- `Store.Delete` *(:173, function)*
- `Store.Ids` *(:178, function)*
- `Store.AddLeg` *(:213, function)*
- `Store.SetOutside` *(:221, function)*
- `Store.SetArrival` *(:227, function)*
- `Store.SetInstance` *(:240, function)*
- `Store.SetMapArt` *(:249, function)*
- `Store.AddBoss` *(:264, function)*
- `Store.Counts` *(:276, function)*
- `Store.GetUI` *(:288, function)*
- `Store.SetUI` *(:297, function)*
- `Store.AddMarker` *(:301, function)*
- `mapFraction` *(:301, local)*
- `composeId` *(:301, local)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:39, local)*
- `Widget.Init` *(:54, function)*
- `Widget.Toggle` *(:117, function)*
