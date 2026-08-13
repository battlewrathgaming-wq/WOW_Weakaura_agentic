# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_6 file(s) · 82 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `39e639b8f929`._

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

**pulls:** `GetCurrentPlayerPosition`

- `refresh` *(:57, local)*
- `initDropdown` *(:81, local)*
- `info.func` *(:89, assigned)*
- `b.func` *(:113, assigned)*
- `Editor.Init` *(:117, function)*
- `Editor.Toggle` *(:177, function)*

## `map.lua`

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ArtSize` *(:103, function)*
- `Map.TileGrid` *(:105, function)*
- `Map.RunsFor` *(:145, function)*
- `Map.ArtFor` *(:165, function)*
- `Map.PointsOn` *(:181, function)*
- `Map.ArtKey` *(:200, function)*
- `Map.Rank` *(:211, function)*
- `Map.ArtForPoint` *(:215, function)*
- `Map.SetOnSelect` *(:232, function)*
- `Map.Selected` *(:235, function)*
- `Map.Select` *(:236, function)*
- `Map.Describe` *(:246, function)*
- `add` *(:255, local)*
- `Map.FillTooltip` *(:297, function)*
- `Map.Offset` *(:312, function)*
- `Map.TilePath` *(:318, function)*
- `Map.TileRect` *(:339, function)*
- `byName` *(:372, local)*
- `Map.SeedFloor` *(:385, function)*
- `Map.Caption` *(:407, function)*
- `ensureDots` *(:422, local)*
- `styleDot` *(:449, local)*
- `clearDots` *(:462, local)*
- `paint` *(:468, function)*
- `context` *(:514, local)*
- `Map.LoadedId` *(:520, function)*
- `Map.ShownArt` *(:525, function)*
- `Map.Show` *(:532, function)*
- `Map.Toggle` *(:555, function)*
- `step` *(:561, local)*
- `Map.Init` *(:577, function)*
- `Map.MapIDOf` *(:654, function)*
- `Map.RunList` *(:654, function)*

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
