# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_12 file(s) · 312 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `82e2ed4ce5f9`._

## `calibrate.lua`

- `Calibrate.Init` *(:55, function)*
- `Calibrate.Clear` *(:61, function)*
- `spread` *(:119, local)*
- `Calibrate.Fit` *(:142, function)*
- `Calibrate.Apply` *(:177, function)*
- `Calibrate.For` *(:236, function)*
- `Calibrate.Floor` *(:247, function)*
- `Calibrate.ToWorld` *(:262, function)*
- `Calibrate.Report` *(:269, function)*
- `solve3` *(:284, local)*
- `build` *(:284, local)*

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `GetMapInfo`, `UnitIsGhost`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `recapAttackers` *(:73, local)*
- `engagedBosses` *(:122, local)*
- `inInstance` *(:134, local)*
- `onUpdate` *(:210, function)*
- `Capture.Stop` *(:263, function)*
- `Capture.RunId` *(:278, function)*
- `Capture.Pulls` *(:280, function)*
- `Capture.Pin` *(:308, function)*
- `onCombatStart` *(:318, local)*
- `onCombatEnd` *(:327, local)*
- `onPlayerDead` *(:349, local)*
- `onEncounterEngage` *(:356, local)*
- `captureOrigin` *(:370, function)*
- `onEnteringWorld` *(:444, local)*
- `Capture.Init` *(:448, function)*
- `captureMapArt` *(:473, function)*
- `Capture.Arm` *(:473, function)*

## `core.lua`  —  events: ADDON_LOADED

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `NS.Say` *(:4, function)*
- `status` *(:8, local)*
- `probe` *(:45, local)*
- `list` *(:59, local)*
- `slash` *(:72, local)*

## `driver.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCurrentPlayerPosition`

- `Driver.Promote` *(:62, function)*
- `Driver.Cost` *(:72, function)*
- `here` *(:79, local)*
- `inInstance` *(:84, local)*
- `Driver.Reached` *(:117, function)*
- `beaconAt` *(:138, local)*
- `say` *(:144, local)*
- `label` *(:147, local)*
- `report` *(:149, local)*
- `scan` *(:170, local)*
- `Driver.Arm` *(:204, function)*
- `Driver.Stop` *(:229, function)*
- `Driver.Armed` *(:243, function)*
- `Driver.Stage` *(:245, function)*
- `Driver.Route` *(:246, function)*
- `initDropdown` *(:248, local)*
- `b.func` *(:263, assigned)*
- `Driver.Init` *(:267, function)*
- `Driver.Toggle` *(:323, function)*

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
- `installPopups` *(:217, local)*
- `Editor.Init` *(:248, function)*
- `handle` *(:399, local)*
- `drag` *(:417, local)*
- `widthBtn` *(:453, local)*
- `stepBtn` *(:469, local)*
- `Editor.SyncPeek` *(:590, function)*
- `tick` *(:604, local)*
- `Editor.StopPlay` *(:616, function)*
- `Editor.TogglePlay` *(:623, function)*
- `Editor.Toggle` *(:631, function)*

## `map.lua`  —  **OnUpdate ×2** (0 persistent)

**pulls:** `AtlasInfo`, `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ResolveBorrowedArt` *(:250, function)*
- `Map.ArtSize` *(:265, function)*
- `Map.TileGrid` *(:267, function)*
- `Map.ZoomAnchor` *(:329, function)*
- `Map.PanClamp` *(:338, function)*
- `layerDef` *(:390, local)*
- `resolve` *(:402, local)*
- `currentRun` *(:416, local)*
- `authoringMapID` *(:447, local)*
- `Map.AuthoringMapID` *(:454, function)*
- `stillLoaded` *(:460, local)*
- `Map.RunsFor` *(:532, function)*
- `Map.ArtFor` *(:553, function)*
- `Map.PointsOn` *(:574, function)*
- `Map.ClampWindow` *(:646, function)*
- `Map.SkipStep` *(:660, function)*
- `Map.Envelope` *(:664, function)*
- `Map.Window` *(:666, function)*
- `Map.Peeking` *(:667, function)*
- `repaintIfShown` *(:668, local)*
- `Map.ResetTime` *(:674, function)*
- `Map.Span` *(:685, function)*
- `Map.SetEnvelope` *(:687, function)*
- `Map.FloorAt` *(:714, function)*
- `Map.SeparateHandles` *(:733, function)*
- `Map.ResetView` *(:746, function)*
- `Map.TrackingFloor` *(:752, function)*
- `Map.SetTrackFloor` *(:754, function)*
- `Map.SetWindow` *(:760, function)*
- `Map.SetPeek` *(:778, function)*
- `Map.InWindow` *(:786, function)*
- `Map.VisibleOn` *(:812, function)*
- `Map.Painted` *(:827, function)*
- `Map.LayerShown` *(:845, function)*
- `Map.SetLayerShown` *(:847, function)*
- `Map.Layers` *(:853, function)*
- `Map.Hidden` *(:870, function)*
- `Map.SetHidden` *(:873, function)*
- `Map.ArtKey` *(:887, function)*
- `Map.Rank` *(:916, function)*
- `Map.ArtForPoint` *(:920, function)*
- `Map.SetMoveArmed` *(:972, function)*
- `Map.MoveArmed` *(:979, function)*
- `Map.SetPickArmed` *(:986, function)*
- `Map.PickArmed` *(:991, function)*
- `Map.ArmedFor` *(:995, function)*
- `Map.Disarm` *(:997, function)*
- `Map.AddOnEdit` *(:1003, function)*
- `Map.ClearOnEdit` *(:1008, function)*
- `Map.OpenEditor` *(:1010, function)*
- `Map.AddOnSelect` *(:1017, function)*
- `Map.ClearOnSelect` *(:1025, function)*
- `fireSelect` *(:1027, local)*
- `Map.Selected` *(:1031, function)*
- `Map.Select` *(:1033, function)*
- `Map.Describe` *(:1052, function)*
- `add` *(:1064, local)*
- `Map.ArtKeys` *(:1120, function)*
- `Map.KeyFacts` *(:1129, function)*
- `Map.FillTooltip` *(:1137, function)*
- `Map.Offset` *(:1162, function)*
- `Map.FractionAt` *(:1183, function)*
- `Map.Draggable` *(:1203, function)*
- `Map.TilePath` *(:1231, function)*
- `Map.TileRect` *(:1254, function)*
- `byName` *(:1287, local)*
- `Map.SeedFloor` *(:1300, function)*
- `Map.Caption` *(:1322, function)*
- `ensureDots` *(:1345, local)*
- `styleDot` *(:1402, local)*
- `clearDots` *(:1415, local)*
- `paint` *(:1421, function)*
- `context` *(:1484, local)*
- `Map.LoadedId` *(:1492, function)*
- `Map.ReadoutAnchor` *(:1527, function)*
- `fillReadout` *(:1540, function)*
- `Map.Readout` *(:1576, function)*
- `Map.ShownArt` *(:1591, function)*
- `Map.Load` *(:1598, function)*
- `Map.Show` *(:1692, function)*
- `dragTo` *(:1725, local)*
- `Map.BeginDrag` *(:1736, function)*
- `Map.EndDrag` *(:1768, function)*
- `Map.Dragging` *(:1794, function)*
- `refreshControls` *(:1816, local)*
- `buildControls` *(:1825, function)*
- `btn` *(:1851, local)*
- `Map.ToggleControls` *(:1904, function)*
- `Map.ControlsShown` *(:1910, function)*
- `Map.Toggle` *(:1912, function)*
- `step` *(:1921, local)*
- `applyView` *(:1949, local)*
- `Map.Zoom` *(:1964, function)*
- `Map.Pan` *(:1966, function)*
- `Map.SetZoom` *(:1967, function)*
- `Map.StepZoom` *(:1980, function)*
- `Map.NextStage` *(:1990, function)*
- `Map.CycleZoomStage` *(:1999, function)*
- `Map.ZoomStages` *(:2003, function)*
- `Map.ResetZoom` *(:2007, function)*
- `Map.PanStep` *(:2015, function)*
- `Map.Recenter` *(:2022, function)*
- `Map.WheelZoom` *(:2038, function)*
- `Map.RightPan` *(:2040, function)*
- `Map.SetWheelZoom` *(:2041, function)*
- `Map.SetRightPan` *(:2047, function)*
- `Map.SetPan` *(:2056, function)*
- `panTo` *(:2066, local)*
- `Map.BeginPan` *(:2072, function)*
- `Map.EndPan` *(:2080, function)*
- `Map.Panning` *(:2087, function)*
- `Map.Repaint` *(:2089, function)*
- `Map.Floor` *(:2093, function)*
- `Map.Init` *(:2108, function)*
- `Map.MapIDOf` *(:2257, function)*
- `Map.TimeSpan` *(:2257, function)*
- `Map.RunList` *(:2257, function)*

## `object.lua`

**pushes:** `StaticPopup_Show`

- `subject` *(:65, local)*
- `refresh` *(:73, local)*
- `commitName` *(:173, local)*
- `installPopups` *(:180, local)*
- `Object.Init` *(:211, function)*
- `b.func` *(:349, assigned)*
- `Object.Toggle` *(:464, function)*
- `Object.IsShown` *(:469, function)*

## `promoter.lua`

**pushes:** `StaticPopup_Show`

- `isPromoted` *(:69, local)*
- `selectedNode` *(:71, local)*
- `rawSelected` *(:78, local)*
- `authoringMapID` *(:84, local)*
- `refresh` *(:89, local)*
- `initDropdown` *(:223, local)*
- `info.func` *(:228, assigned)*
- `none.func` *(:239, assigned)*
- `b.func` *(:260, assigned)*
- `installPopups` *(:266, local)*
- `mintRoute` *(:292, local)*
- `mintBeacon` *(:307, local)*
- `mintNote` *(:328, local)*
- `Promoter.Init` *(:340, function)*
- `Promoter.Toggle` *(:538, function)*
- `Promoter.IsShown` *(:543, function)*

## `routes.lua`

**pulls:** `UnitName`

- `Routes.Init` *(:45, function)*
- `Routes.Inherit` *(:54, function)*
- `Routes.InheritSummary` *(:64, function)*
- `tbl` *(:82, local)*
- `composeId` *(:85, local)*
- `Routes.Create` *(:93, function)*
- `Routes.Get` *(:108, function)*
- `Routes.Rename` *(:113, function)*
- `Routes.Delete` *(:120, function)*
- `Routes.Ids` *(:125, function)*
- `Routes.List` *(:145, function)*
- `Routes.NextStage` *(:184, function)*
- `Routes.AddBeacon` *(:202, function)*
- `Routes.Unplace` *(:268, function)*
- `Routes.PositionOf` *(:277, function)*
- `Routes.WorldOf` *(:283, function)*
- `Routes.SetName` *(:293, function)*
- `Routes.NameOf` *(:300, function)*
- `Routes.DeleteNote` *(:307, function)*
- `Routes.DeleteBeacon` *(:315, function)*
- `Routes.Count` *(:326, function)*
- `Routes.ChildCount` *(:379, function)*
- `mint` *(:385, local)*
- `Routes.AddChildFromNode` *(:397, function)*
- `Routes.AddChildHere` *(:410, function)*
- `Routes.DeleteChild` *(:421, function)*
- `Routes.ParentOf` *(:435, function)*
- `has` *(:481, local)*
- `Routes.SetChildRole` *(:489, function)*
- `Routes.SetChildStage` *(:507, function)*
- `Routes.SetChildIfUnseen` *(:519, function)*
- `Routes.ChildIfUnseen` *(:533, function)*
- `Routes.SetChildShape` *(:539, function)*
- `Routes.SetChildReach` *(:549, function)*
- `Routes.SetChildAction` *(:561, function)*
- `Routes.SetChildFireOn` *(:577, function)*
- `Routes.SetChildNote` *(:594, function)*
- `Routes.SetChildNoteClear` *(:601, function)*
- `Routes.AcceptanceOf` *(:615, function)*
- `Routes.WaypointOf` *(:621, function)*
- `Routes.ChildrenWithRole` *(:627, function)*
- `Routes.SetOutcome` *(:663, function)*
- `Routes.OutcomeOf` *(:671, function)*
- `Routes.SetStage` *(:686, function)*
- `Routes.StageMatches` *(:696, function)*
- `Routes.Gaps` *(:710, function)*
- `Routes.Outcome` *(:730, function)*
- `Routes.StageOrder` *(:739, function)*
- `Routes.BeaconAt` *(:751, function)*
- `notes` *(:770, local)*
- `Routes.NotePlane` *(:772, function)*
- `Routes.GetNotes` *(:782, function)*
- `Routes.AddNote` *(:787, function)*
- `Routes.NoteCount` *(:798, function)*
- `Routes.Place` *(:802, function)*
- `Routes.ChildrenOf` *(:802, function)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.Load` *(:51, function)*
- `db` *(:72, local)*
- `Store.Point` *(:127, function)*
- `Store.Open` *(:158, function)*
- `Store.Get` *(:177, function)*
- `Store.Close` *(:182, function)*
- `Store.Rename` *(:196, function)*
- `Store.SetComment` *(:208, function)*
- `Store.Delete` *(:217, function)*
- `Store.Ids` *(:222, function)*
- `Store.AddLeg` *(:263, function)*
- `Store.SetOutside` *(:272, function)*
- `Store.SetArrival` *(:278, function)*
- `Store.SetInstance` *(:291, function)*
- `Store.SetMapArt` *(:309, function)*
- `Store.AddBoss` *(:325, function)*
- `Store.RouteTable` *(:363, function)*
- `Store.NoteTable` *(:371, function)*
- `Store.NextRouteId` *(:381, function)*
- `Store.GetUI` *(:389, function)*
- `Store.SetUI` *(:398, function)*
- `Store.AddMarker` *(:402, function)*
- `Store.Counts` *(:402, function)*
- `mapFraction` *(:402, local)*
- `composeId` *(:402, local)*

## `walk.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCurrentPlayerPosition`

- `Walk.Init` *(:49, function)*
- `Walk.Hits` *(:55, function)*
- `Walk.Apply` *(:73, function)*
- `Walk.Detectors` *(:110, function)*
- `Walk.State` *(:127, function)*
- `Walk.SeenCount` *(:139, function)*
- `Walk.Unrunnable` *(:149, function)*
- `Walk.Waiting` *(:159, function)*
- `Walk.Start` *(:179, function)*
- `Walk.Stop` *(:191, function)*
- `Walk.IsRunning` *(:200, function)*
- `Walk.Index` *(:202, function)*
- `Walk.Seen` *(:203, function)*
- `Walk.Scan` *(:211, function)*
- `Walk.Tick` *(:239, function)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:46, local)*
- `Widget.Init` *(:61, function)*
- `Widget.Pin` *(:142, function)*
- `Widget.Toggle` *(:150, function)*
