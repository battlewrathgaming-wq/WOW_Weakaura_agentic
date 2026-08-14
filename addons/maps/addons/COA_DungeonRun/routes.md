# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_9 file(s) · 202 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `b02be4ca0c60`._

## `calibrate.lua`

- `Calibrate.Init` *(:54, function)*
- `Calibrate.Clear` *(:60, function)*
- `spread` *(:115, local)*
- `Calibrate.Fit` *(:138, function)*
- `Calibrate.Apply` *(:173, function)*
- `Calibrate.For` *(:232, function)*
- `Calibrate.Floor` *(:243, function)*
- `Calibrate.ToWorld` *(:258, function)*
- `Calibrate.Report` *(:265, function)*
- `solve3` *(:280, local)*
- `build` *(:280, local)*

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`, `UnitIsGhost`, `UnitName`
**pushes:** `SetMapToCurrentZone`

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
- `mapIsShowingUs` *(:352, local)*
- `onEnteringWorld` *(:405, local)*
- `Capture.Init` *(:409, function)*
- `Capture.Arm` *(:434, function)*

## `core.lua`  —  events: ADDON_LOADED

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `NS.Say` *(:4, function)*
- `status` *(:8, local)*
- `probe` *(:38, local)*
- `list` *(:52, local)*
- `slash` *(:65, local)*

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
- `Editor.SyncPeek` *(:578, function)*
- `tick` *(:592, local)*
- `Editor.StopPlay` *(:604, function)*
- `Editor.TogglePlay` *(:611, function)*
- `Editor.Toggle` *(:619, function)*

## `map.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ArtSize` *(:169, function)*
- `Map.TileGrid` *(:171, function)*
- `layerDef` *(:217, local)*
- `resolve` *(:227, local)*
- `currentRun` *(:241, local)*
- `authoringMapID` *(:272, local)*
- `Map.AuthoringMapID` *(:279, function)*
- `stillLoaded` *(:285, local)*
- `Map.RunsFor` *(:351, function)*
- `Map.ArtFor` *(:371, function)*
- `Map.PointsOn` *(:391, function)*
- `Map.ClampWindow` *(:444, function)*
- `Map.SkipStep` *(:456, function)*
- `Map.Envelope` *(:460, function)*
- `Map.Window` *(:462, function)*
- `Map.Peeking` *(:463, function)*
- `repaintIfShown` *(:464, local)*
- `Map.ResetTime` *(:470, function)*
- `Map.Span` *(:481, function)*
- `Map.SetEnvelope` *(:483, function)*
- `Map.FloorAt` *(:506, function)*
- `Map.SeparateHandles` *(:525, function)*
- `Map.ResetView` *(:538, function)*
- `Map.TrackingFloor` *(:544, function)*
- `Map.SetTrackFloor` *(:546, function)*
- `Map.SetWindow` *(:552, function)*
- `Map.SetPeek` *(:570, function)*
- `Map.InWindow` *(:578, function)*
- `Map.VisibleOn` *(:603, function)*
- `Map.Painted` *(:617, function)*
- `Map.LayerShown` *(:635, function)*
- `Map.SetLayerShown` *(:637, function)*
- `Map.Layers` *(:643, function)*
- `Map.Hidden` *(:660, function)*
- `Map.SetHidden` *(:663, function)*
- `Map.ArtKey` *(:675, function)*
- `Map.Rank` *(:699, function)*
- `Map.ArtForPoint` *(:703, function)*
- `Map.SetMoveArmed` *(:740, function)*
- `Map.MoveArmed` *(:747, function)*
- `Map.AddOnEdit` *(:753, function)*
- `Map.ClearOnEdit` *(:758, function)*
- `Map.OpenEditor` *(:760, function)*
- `Map.AddOnSelect` *(:767, function)*
- `Map.ClearOnSelect` *(:775, function)*
- `fireSelect` *(:777, local)*
- `Map.Selected` *(:781, function)*
- `Map.Select` *(:783, function)*
- `Map.Describe` *(:800, function)*
- `add` *(:810, local)*
- `Map.FillTooltip` *(:855, function)*
- `Map.Offset` *(:877, function)*
- `Map.FractionAt` *(:897, function)*
- `Map.Draggable` *(:911, function)*
- `Map.TilePath` *(:932, function)*
- `Map.TileRect` *(:955, function)*
- `byName` *(:988, local)*
- `Map.SeedFloor` *(:1001, function)*
- `Map.Caption` *(:1023, function)*
- `ensureDots` *(:1046, local)*
- `styleDot` *(:1084, local)*
- `clearDots` *(:1097, local)*
- `paint` *(:1103, function)*
- `context` *(:1159, local)*
- `Map.LoadedId` *(:1167, function)*
- `Map.ReadoutAnchor` *(:1200, function)*
- `fillReadout` *(:1213, function)*
- `Map.Readout` *(:1244, function)*
- `Map.ShownArt` *(:1259, function)*
- `Map.Load` *(:1266, function)*
- `Map.Show` *(:1351, function)*
- `dragTo` *(:1384, local)*
- `Map.BeginDrag` *(:1395, function)*
- `Map.EndDrag` *(:1409, function)*
- `Map.Dragging` *(:1433, function)*
- `Map.Toggle` *(:1435, function)*
- `step` *(:1444, local)*
- `Map.Floor` *(:1453, function)*
- `Map.Init` *(:1466, function)*
- `Map.MapIDOf` *(:1574, function)*
- `Map.TimeSpan` *(:1574, function)*
- `Map.RunList` *(:1574, function)*

## `promoter.lua`

**pushes:** `StaticPopup_Show`

- `isPromoted` *(:63, local)*
- `selectedNode` *(:65, local)*
- `rawSelected` *(:72, local)*
- `authoringMapID` *(:78, local)*
- `refresh` *(:83, local)*
- `initDropdown` *(:178, local)*
- `info.func` *(:183, assigned)*
- `none.func` *(:194, assigned)*
- `b.func` *(:215, assigned)*
- `installPopups` *(:221, local)*
- `mintRoute` *(:247, local)*
- `mintBeacon` *(:262, local)*
- `mintNote` *(:278, local)*
- `Promoter.Init` *(:290, function)*
- `Promoter.Toggle` *(:442, function)*
- `Promoter.IsShown` *(:447, function)*

## `routes.lua`

**pulls:** `UnitName`

- `Routes.Init` *(:45, function)*
- `Routes.Inherit` *(:53, function)*
- `Routes.InheritSummary` *(:63, function)*
- `tbl` *(:81, local)*
- `composeId` *(:84, local)*
- `Routes.Create` *(:92, function)*
- `Routes.Get` *(:107, function)*
- `Routes.Rename` *(:112, function)*
- `Routes.Delete` *(:119, function)*
- `Routes.Ids` *(:124, function)*
- `Routes.List` *(:144, function)*
- `Routes.AddBeacon` *(:173, function)*
- `Routes.Unplace` *(:239, function)*
- `Routes.PositionOf` *(:248, function)*
- `Routes.WorldOf` *(:254, function)*
- `Routes.DeleteBeacon` *(:260, function)*
- `Routes.Count` *(:271, function)*
- `notes` *(:288, local)*
- `Routes.NotePlane` *(:290, function)*
- `Routes.GetNotes` *(:300, function)*
- `Routes.AddNote` *(:305, function)*
- `Routes.NoteCount` *(:316, function)*
- `Routes.Place` *(:320, function)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.Load` *(:47, function)*
- `db` *(:68, local)*
- `Store.Point` *(:117, function)*
- `Store.Open` *(:148, function)*
- `Store.Get` *(:167, function)*
- `Store.Close` *(:172, function)*
- `Store.Rename` *(:186, function)*
- `Store.SetComment` *(:198, function)*
- `Store.Delete` *(:207, function)*
- `Store.Ids` *(:212, function)*
- `Store.AddLeg` *(:253, function)*
- `Store.SetOutside` *(:262, function)*
- `Store.SetArrival` *(:268, function)*
- `Store.SetInstance` *(:281, function)*
- `Store.SetMapArt` *(:299, function)*
- `Store.AddBoss` *(:315, function)*
- `Store.RouteTable` *(:353, function)*
- `Store.NoteTable` *(:361, function)*
- `Store.NextRouteId` *(:371, function)*
- `Store.GetUI` *(:379, function)*
- `Store.SetUI` *(:388, function)*
- `Store.AddMarker` *(:392, function)*
- `Store.Counts` *(:392, function)*
- `mapFraction` *(:392, local)*
- `composeId` *(:392, local)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:46, local)*
- `Widget.Init` *(:61, function)*
- `Widget.Pin` *(:142, function)*
- `Widget.Toggle` *(:150, function)*
