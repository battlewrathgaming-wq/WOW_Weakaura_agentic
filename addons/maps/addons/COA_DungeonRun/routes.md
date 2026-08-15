# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_11 file(s) · 271 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `8f959c03ee54`._

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
- `Driver.Reached` *(:100, function)*
- `beaconAt` *(:116, local)*
- `say` *(:122, local)*
- `label` *(:125, local)*
- `report` *(:127, local)*
- `scan` *(:148, local)*
- `Driver.Arm` *(:182, function)*
- `Driver.Stop` *(:207, function)*
- `Driver.Armed` *(:221, function)*
- `Driver.Stage` *(:223, function)*
- `Driver.Route` *(:224, function)*
- `initDropdown` *(:226, local)*
- `b.func` *(:241, assigned)*
- `Driver.Init` *(:245, function)*
- `Driver.Toggle` *(:301, function)*

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

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ArtSize` *(:188, function)*
- `Map.TileGrid` *(:190, function)*
- `Map.ZoomAnchor` *(:250, function)*
- `Map.PanClamp` *(:259, function)*
- `layerDef` *(:307, local)*
- `resolve` *(:317, local)*
- `currentRun` *(:331, local)*
- `authoringMapID` *(:362, local)*
- `Map.AuthoringMapID` *(:369, function)*
- `stillLoaded` *(:375, local)*
- `Map.RunsFor` *(:445, function)*
- `Map.ArtFor` *(:465, function)*
- `Map.PointsOn` *(:485, function)*
- `Map.ClampWindow` *(:538, function)*
- `Map.SkipStep` *(:550, function)*
- `Map.Envelope` *(:554, function)*
- `Map.Window` *(:556, function)*
- `Map.Peeking` *(:557, function)*
- `repaintIfShown` *(:558, local)*
- `Map.ResetTime` *(:564, function)*
- `Map.Span` *(:575, function)*
- `Map.SetEnvelope` *(:577, function)*
- `Map.FloorAt` *(:604, function)*
- `Map.SeparateHandles` *(:623, function)*
- `Map.ResetView` *(:636, function)*
- `Map.TrackingFloor` *(:642, function)*
- `Map.SetTrackFloor` *(:644, function)*
- `Map.SetWindow` *(:650, function)*
- `Map.SetPeek` *(:668, function)*
- `Map.InWindow` *(:676, function)*
- `Map.VisibleOn` *(:701, function)*
- `Map.Painted` *(:715, function)*
- `Map.LayerShown` *(:733, function)*
- `Map.SetLayerShown` *(:735, function)*
- `Map.Layers` *(:741, function)*
- `Map.Hidden` *(:758, function)*
- `Map.SetHidden` *(:761, function)*
- `Map.ArtKey` *(:773, function)*
- `Map.Rank` *(:797, function)*
- `Map.ArtForPoint` *(:801, function)*
- `Map.SetMoveArmed` *(:838, function)*
- `Map.MoveArmed` *(:845, function)*
- `Map.AddOnEdit` *(:851, function)*
- `Map.ClearOnEdit` *(:856, function)*
- `Map.OpenEditor` *(:858, function)*
- `Map.AddOnSelect` *(:865, function)*
- `Map.ClearOnSelect` *(:873, function)*
- `fireSelect` *(:875, local)*
- `Map.Selected` *(:879, function)*
- `Map.Select` *(:881, function)*
- `Map.Describe` *(:898, function)*
- `add` *(:910, local)*
- `Map.ArtKeys` *(:962, function)*
- `Map.KeyFacts` *(:971, function)*
- `Map.FillTooltip` *(:979, function)*
- `Map.Offset` *(:1004, function)*
- `Map.FractionAt` *(:1024, function)*
- `Map.Draggable` *(:1038, function)*
- `Map.TilePath` *(:1065, function)*
- `Map.TileRect` *(:1088, function)*
- `byName` *(:1121, local)*
- `Map.SeedFloor` *(:1134, function)*
- `Map.Caption` *(:1156, function)*
- `ensureDots` *(:1179, local)*
- `styleDot` *(:1219, local)*
- `clearDots` *(:1232, local)*
- `paint` *(:1238, function)*
- `context` *(:1297, local)*
- `Map.LoadedId` *(:1305, function)*
- `Map.ReadoutAnchor` *(:1338, function)*
- `fillReadout` *(:1351, function)*
- `Map.Readout` *(:1385, function)*
- `Map.ShownArt` *(:1400, function)*
- `Map.Load` *(:1407, function)*
- `Map.Show` *(:1492, function)*
- `dragTo` *(:1525, local)*
- `Map.BeginDrag` *(:1536, function)*
- `Map.EndDrag` *(:1564, function)*
- `Map.Dragging` *(:1590, function)*
- `refreshControls` *(:1610, local)*
- `buildControls` *(:1619, function)*
- `btn` *(:1645, local)*
- `Map.ToggleControls` *(:1698, function)*
- `Map.ControlsShown` *(:1704, function)*
- `Map.Toggle` *(:1706, function)*
- `step` *(:1715, local)*
- `applyView` *(:1741, local)*
- `Map.Zoom` *(:1756, function)*
- `Map.Pan` *(:1758, function)*
- `Map.SetZoom` *(:1759, function)*
- `Map.StepZoom` *(:1772, function)*
- `Map.NextStage` *(:1780, function)*
- `Map.CycleZoomStage` *(:1789, function)*
- `Map.ZoomStages` *(:1793, function)*
- `Map.ResetZoom` *(:1797, function)*
- `Map.PanStep` *(:1805, function)*
- `Map.Recenter` *(:1812, function)*
- `Map.WheelZoom` *(:1828, function)*
- `Map.RightPan` *(:1830, function)*
- `Map.SetWheelZoom` *(:1831, function)*
- `Map.SetRightPan` *(:1837, function)*
- `Map.SetPan` *(:1846, function)*
- `panTo` *(:1856, local)*
- `Map.BeginPan` *(:1862, function)*
- `Map.EndPan` *(:1870, function)*
- `Map.Panning` *(:1877, function)*
- `Map.Repaint` *(:1879, function)*
- `Map.Floor` *(:1883, function)*
- `Map.Init` *(:1896, function)*
- `Map.MapIDOf` *(:2040, function)*
- `Map.TimeSpan` *(:2040, function)*
- `Map.RunList` *(:2040, function)*

## `object.lua`

**pushes:** `StaticPopup_Show`

- `subject` *(:64, local)*
- `refresh` *(:70, local)*
- `commitName` *(:151, local)*
- `installPopups` *(:158, local)*
- `Object.Init` *(:182, function)*
- `b.func` *(:315, assigned)*
- `Object.Toggle` *(:368, function)*
- `Object.IsShown` *(:373, function)*

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
- `Routes.SetOutcome` *(:359, function)*
- `Routes.OutcomeOf` *(:367, function)*
- `Routes.SetStage` *(:382, function)*
- `Routes.StageMatches` *(:392, function)*
- `Routes.Gaps` *(:406, function)*
- `Routes.Outcome` *(:426, function)*
- `Routes.StageOrder` *(:435, function)*
- `Routes.BeaconAt` *(:447, function)*
- `notes` *(:466, local)*
- `Routes.NotePlane` *(:468, function)*
- `Routes.GetNotes` *(:478, function)*
- `Routes.AddNote` *(:483, function)*
- `Routes.NoteCount` *(:494, function)*
- `Routes.Place` *(:498, function)*

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

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:46, local)*
- `Widget.Init` *(:61, function)*
- `Widget.Pin` *(:142, function)*
- `Widget.Toggle` *(:150, function)*
