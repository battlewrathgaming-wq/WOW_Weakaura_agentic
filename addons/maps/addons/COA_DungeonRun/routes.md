# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_6 file(s) · 128 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `5924f86eaf4b`._

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
- `layerDef` *(:174, local)*
- `resolve` *(:184, local)*
- `currentRun` *(:194, local)*
- `Map.RunsFor` *(:246, function)*
- `Map.ArtFor` *(:266, function)*
- `Map.PointsOn` *(:286, function)*
- `Map.ClampWindow` *(:339, function)*
- `Map.SkipStep` *(:351, function)*
- `Map.Envelope` *(:355, function)*
- `Map.Window` *(:357, function)*
- `Map.Peeking` *(:358, function)*
- `repaintIfShown` *(:359, local)*
- `Map.ResetTime` *(:365, function)*
- `Map.Span` *(:376, function)*
- `Map.SetEnvelope` *(:378, function)*
- `Map.FloorAt` *(:401, function)*
- `Map.SeparateHandles` *(:420, function)*
- `Map.ResetView` *(:433, function)*
- `Map.TrackingFloor` *(:439, function)*
- `Map.SetTrackFloor` *(:441, function)*
- `Map.SetWindow` *(:447, function)*
- `Map.SetPeek` *(:465, function)*
- `Map.InWindow` *(:473, function)*
- `Map.VisibleOn` *(:498, function)*
- `Map.Painted` *(:512, function)*
- `Map.LayerShown` *(:530, function)*
- `Map.SetLayerShown` *(:532, function)*
- `Map.Layers` *(:538, function)*
- `Map.Hidden` *(:555, function)*
- `Map.SetHidden` *(:558, function)*
- `Map.ArtKey` *(:570, function)*
- `Map.Rank` *(:585, function)*
- `Map.ArtForPoint` *(:589, function)*
- `Map.SetOnSelect` *(:606, function)*
- `Map.Selected` *(:609, function)*
- `Map.Select` *(:610, function)*
- `Map.Describe` *(:620, function)*
- `add` *(:630, local)*
- `Map.FillTooltip` *(:675, function)*
- `Map.Offset` *(:690, function)*
- `Map.TilePath` *(:696, function)*
- `Map.TileRect` *(:717, function)*
- `byName` *(:750, local)*
- `Map.SeedFloor` *(:763, function)*
- `Map.Caption` *(:785, function)*
- `ensureDots` *(:808, local)*
- `styleDot` *(:835, local)*
- `clearDots` *(:848, local)*
- `paint` *(:854, function)*
- `context` *(:902, local)*
- `Map.LoadedId` *(:910, function)*
- `Map.ShownArt` *(:915, function)*
- `Map.Load` *(:922, function)*
- `Map.Show` *(:966, function)*
- `Map.Toggle` *(:970, function)*
- `step` *(:979, local)*
- `Map.Floor` *(:988, function)*
- `Map.Init` *(:1001, function)*
- `Map.MapIDOf` *(:1078, function)*
- `Map.TimeSpan` *(:1078, function)*
- `Map.RunList` *(:1078, function)*

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
