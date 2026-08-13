# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_6 file(s) · 70 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `b2031147db18`._

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

## `editor.lua`

- `refresh` *(:35, local)*
- `Editor.Init` *(:64, function)*
- `Editor.Toggle` *(:125, function)*

## `map.lua`

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ArtSize` *(:78, function)*
- `Map.TileGrid` *(:80, function)*
- `Map.RunsFor` *(:110, function)*
- `Map.ArtFor` *(:130, function)*
- `Map.PointsOn` *(:146, function)*
- `Map.ArtKey` *(:165, function)*
- `Map.ArtForPoint` *(:176, function)*
- `Map.SetOnSelect` *(:193, function)*
- `Map.Selected` *(:196, function)*
- `Map.Select` *(:197, function)*
- `Map.Describe` *(:207, function)*
- `add` *(:216, local)*
- `Map.Offset` *(:233, function)*
- `Map.TilePath` *(:239, function)*
- `ensureDots` *(:249, local)*
- `styleDot` *(:269, local)*
- `clearDots` *(:280, local)*
- `paint` *(:284, local)*
- `context` *(:318, local)*
- `Map.Show` *(:324, function)*
- `Map.Toggle` *(:344, function)*
- `step` *(:349, local)*
- `Map.Init` *(:356, function)*
- `Map.MapIDOf` *(:416, function)*

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
