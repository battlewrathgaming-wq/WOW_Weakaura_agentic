# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_5 file(s) · 62 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `e01aaf304350`._

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `GetMapInfo`, `UnitIsGhost`, `UnitName`

- `recapAttackers` *(:66, local)*
- `engagedBosses` *(:105, local)*
- `inInstance` *(:117, local)*
- `onUpdate` *(:140, function)*
- `Capture.Stop` *(:189, function)*
- `Capture.RunId` *(:204, function)*
- `Capture.Pulls` *(:206, function)*
- `onCombatStart` *(:210, local)*
- `onCombatEnd` *(:219, local)*
- `onPlayerDead` *(:236, local)*
- `onEncounterEngage` *(:243, local)*
- `captureOrigin` *(:257, function)*
- `onEnteringWorld` *(:316, local)*
- `Capture.Init` *(:320, function)*
- `Capture.Arm` *(:345, function)*

## `core.lua`  —  events: ADDON_LOADED

- `NS.Say` *(:4, function)*
- `status` *(:8, local)*
- `list` *(:23, local)*
- `slash` *(:36, local)*

## `map.lua`

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ArtSize` *(:78, function)*
- `Map.TileGrid` *(:80, function)*
- `Map.RunsFor` *(:109, function)*
- `Map.ArtFor` *(:129, function)*
- `Map.PointsOn` *(:145, function)*
- `Map.ArtKey` *(:164, function)*
- `Map.ArtForPoint` *(:175, function)*
- `Map.Offset` *(:187, function)*
- `Map.TilePath` *(:193, function)*
- `ensureDots` *(:203, local)*
- `styleDot` *(:221, local)*
- `clearDots` *(:228, local)*
- `paint` *(:232, local)*
- `context` *(:265, local)*
- `Map.Show` *(:271, function)*
- `Map.Toggle` *(:291, function)*
- `step` *(:296, local)*
- `Map.Init` *(:303, function)*
- `Map.MapIDOf` *(:356, function)*

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
