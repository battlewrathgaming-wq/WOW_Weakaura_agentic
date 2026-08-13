# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_6 file(s) · 120 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `c563bf4ffd38`._

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `GetMapInfo`, `UnitIsGhost`, `UnitName`

- `recapAttackers` *(:66, local)*
- `engagedBosses` *(:113, local)*
- `inInstance` *(:125, local)*
- `onUpdate` *(:164, function)*
- `Capture.Stop` *(:215, function)*
- `Capture.RunId` *(:230, function)*
- `Capture.Pulls` *(:232, function)*
- `Capture.Pin` *(:260, function)*
- `onCombatStart` *(:270, local)*
- `onCombatEnd` *(:279, local)*
- `onPlayerDead` *(:296, local)*
- `onEncounterEngage` *(:303, local)*
- `captureOrigin` *(:317, function)*
- `onEnteringWorld` *(:376, local)*
- `Capture.Init` *(:380, function)*
- `Capture.Arm` *(:405, function)*

## `core.lua`  —  events: ADDON_LOADED

- `NS.Say` *(:4, function)*
- `status` *(:8, local)*
- `list` *(:24, local)*
- `slash` *(:37, local)*

## `editor.lua`  —  **OnUpdate ×2** (0 persistent)

**pulls:** `GetCurrentPlayerPosition`
**pushes:** `StaticPopup_Show`

- `clock` *(:66, local)*
- `toPx` *(:73, local)*
- `toSec` *(:78, local)*
- `refresh` *(:94, local)*
- `initDropdown` *(:172, local)*
- `info.func` *(:180, assigned)*
- `b.func` *(:204, assigned)*
- `installPopups` *(:214, local)*
- `Editor.Init` *(:245, function)*
- `handle` *(:393, local)*
- `drag` *(:411, local)*
- `widthBtn` *(:441, local)*
- `stepBtn` *(:457, local)*
- `Editor.SyncPeek` *(:556, function)*
- `tick` *(:570, local)*
- `Editor.StopPlay` *(:582, function)*
- `Editor.TogglePlay` *(:589, function)*
- `Editor.Toggle` *(:597, function)*

## `map.lua`

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ArtSize` *(:137, function)*
- `Map.TileGrid` *(:139, function)*
- `Map.RunsFor` *(:193, function)*
- `Map.ArtFor` *(:213, function)*
- `Map.PointsOn` *(:229, function)*
- `Map.ClampWindow` *(:281, function)*
- `Map.SkipStep` *(:293, function)*
- `Map.Envelope` *(:297, function)*
- `Map.Window` *(:299, function)*
- `Map.Peeking` *(:300, function)*
- `repaintIfShown` *(:301, local)*
- `Map.ResetTime` *(:307, function)*
- `Map.Span` *(:318, function)*
- `Map.SetEnvelope` *(:320, function)*
- `Map.FloorAt` *(:343, function)*
- `Map.SeparateHandles` *(:362, function)*
- `Map.ResetView` *(:375, function)*
- `Map.TrackingFloor` *(:381, function)*
- `Map.SetTrackFloor` *(:383, function)*
- `Map.SetWindow` *(:389, function)*
- `Map.SetPeek` *(:407, function)*
- `Map.InWindow` *(:415, function)*
- `Map.VisibleOn` *(:435, function)*
- `Map.Hidden` *(:455, function)*
- `Map.SetHidden` *(:458, function)*
- `Map.ArtKey` *(:470, function)*
- `Map.Rank` *(:485, function)*
- `Map.ArtForPoint` *(:489, function)*
- `Map.SetOnSelect` *(:506, function)*
- `Map.Selected` *(:509, function)*
- `Map.Select` *(:510, function)*
- `Map.Describe` *(:520, function)*
- `add` *(:530, local)*
- `Map.FillTooltip` *(:575, function)*
- `Map.Offset` *(:590, function)*
- `Map.TilePath` *(:596, function)*
- `Map.TileRect` *(:617, function)*
- `byName` *(:650, local)*
- `Map.SeedFloor` *(:663, function)*
- `Map.Caption` *(:685, function)*
- `ensureDots` *(:700, local)*
- `styleDot` *(:727, local)*
- `clearDots` *(:740, local)*
- `paint` *(:746, function)*
- `context` *(:792, local)*
- `Map.LoadedId` *(:798, function)*
- `Map.ShownArt` *(:803, function)*
- `Map.Show` *(:810, function)*
- `Map.Toggle` *(:837, function)*
- `step` *(:846, local)*
- `Map.Floor` *(:855, function)*
- `Map.Init` *(:868, function)*
- `Map.MapIDOf` *(:945, function)*
- `Map.TimeSpan` *(:945, function)*
- `Map.RunList` *(:945, function)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.Load` *(:47, function)*
- `db` *(:68, local)*
- `Store.Point` *(:113, function)*
- `Store.Open` *(:144, function)*
- `Store.Get` *(:163, function)*
- `Store.Close` *(:168, function)*
- `Store.Rename` *(:182, function)*
- `Store.SetComment` *(:194, function)*
- `Store.Delete` *(:203, function)*
- `Store.Ids` *(:208, function)*
- `Store.AddLeg` *(:249, function)*
- `Store.SetOutside` *(:258, function)*
- `Store.SetArrival` *(:264, function)*
- `Store.SetInstance` *(:277, function)*
- `Store.SetMapArt` *(:286, function)*
- `Store.AddBoss` *(:301, function)*
- `Store.GetUI` *(:328, function)*
- `Store.SetUI` *(:337, function)*
- `Store.AddMarker` *(:341, function)*
- `Store.Counts` *(:341, function)*
- `mapFraction` *(:341, local)*
- `composeId` *(:341, local)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:46, local)*
- `Widget.Init` *(:61, function)*
- `Widget.Pin` *(:142, function)*
- `Widget.Toggle` *(:150, function)*
