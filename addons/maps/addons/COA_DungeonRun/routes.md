# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_11 file(s) · 271 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `4f0aba40162c`._

## `calibrate.lua`

- `Calibrate.Init` *(:55, function)*
- `Calibrate.Clear` *(:61, function)*
- `spread` *(:116, local)*
- `Calibrate.Fit` *(:139, function)*
- `Calibrate.Apply` *(:174, function)*
- `Calibrate.For` *(:233, function)*
- `Calibrate.Floor` *(:244, function)*
- `Calibrate.ToWorld` *(:259, function)*
- `Calibrate.Report` *(:266, function)*
- `solve3` *(:281, local)*
- `build` *(:281, local)*

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `GetMapInfo`, `UnitIsGhost`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `recapAttackers` *(:69, local)*
- `engagedBosses` *(:116, local)*
- `inInstance` *(:128, local)*
- `onUpdate` *(:204, function)*
- `Capture.Stop` *(:257, function)*
- `Capture.RunId` *(:272, function)*
- `Capture.Pulls` *(:274, function)*
- `Capture.Pin` *(:302, function)*
- `onCombatStart` *(:312, local)*
- `onCombatEnd` *(:321, local)*
- `onPlayerDead` *(:338, local)*
- `onEncounterEngage` *(:345, local)*
- `captureOrigin` *(:359, function)*
- `onEnteringWorld` *(:430, local)*
- `Capture.Init` *(:434, function)*
- `captureMapArt` *(:459, function)*
- `Capture.Arm` *(:459, function)*

## `core.lua`  —  events: ADDON_LOADED

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `NS.Say` *(:4, function)*
- `status` *(:8, local)*
- `probe` *(:38, local)*
- `list` *(:52, local)*
- `slash` *(:65, local)*

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

## `map.lua`  —  **OnUpdate ×2** (0 persistent)

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ArtSize` *(:184, function)*
- `Map.TileGrid` *(:186, function)*
- `Map.ZoomAnchor` *(:244, function)*
- `Map.PanClamp` *(:253, function)*
- `layerDef` *(:301, local)*
- `resolve` *(:311, local)*
- `currentRun` *(:325, local)*
- `authoringMapID` *(:356, local)*
- `Map.AuthoringMapID` *(:363, function)*
- `stillLoaded` *(:369, local)*
- `Map.RunsFor` *(:435, function)*
- `Map.ArtFor` *(:455, function)*
- `Map.PointsOn` *(:475, function)*
- `Map.ClampWindow` *(:528, function)*
- `Map.SkipStep` *(:540, function)*
- `Map.Envelope` *(:544, function)*
- `Map.Window` *(:546, function)*
- `Map.Peeking` *(:547, function)*
- `repaintIfShown` *(:548, local)*
- `Map.ResetTime` *(:554, function)*
- `Map.Span` *(:565, function)*
- `Map.SetEnvelope` *(:567, function)*
- `Map.FloorAt` *(:590, function)*
- `Map.SeparateHandles` *(:609, function)*
- `Map.ResetView` *(:622, function)*
- `Map.TrackingFloor` *(:628, function)*
- `Map.SetTrackFloor` *(:630, function)*
- `Map.SetWindow` *(:636, function)*
- `Map.SetPeek` *(:654, function)*
- `Map.InWindow` *(:662, function)*
- `Map.VisibleOn` *(:687, function)*
- `Map.Painted` *(:701, function)*
- `Map.LayerShown` *(:719, function)*
- `Map.SetLayerShown` *(:721, function)*
- `Map.Layers` *(:727, function)*
- `Map.Hidden` *(:744, function)*
- `Map.SetHidden` *(:747, function)*
- `Map.ArtKey` *(:759, function)*
- `Map.Rank` *(:783, function)*
- `Map.ArtForPoint` *(:787, function)*
- `Map.SetMoveArmed` *(:824, function)*
- `Map.MoveArmed` *(:831, function)*
- `Map.AddOnEdit` *(:837, function)*
- `Map.ClearOnEdit` *(:842, function)*
- `Map.OpenEditor` *(:844, function)*
- `Map.AddOnSelect` *(:851, function)*
- `Map.ClearOnSelect` *(:859, function)*
- `fireSelect` *(:861, local)*
- `Map.Selected` *(:865, function)*
- `Map.Select` *(:867, function)*
- `Map.Describe` *(:884, function)*
- `add` *(:896, local)*
- `Map.ArtKeys` *(:948, function)*
- `Map.KeyFacts` *(:957, function)*
- `Map.FillTooltip` *(:965, function)*
- `Map.Offset` *(:990, function)*
- `Map.FractionAt` *(:1010, function)*
- `Map.Draggable` *(:1024, function)*
- `Map.TilePath` *(:1045, function)*
- `Map.TileRect` *(:1068, function)*
- `byName` *(:1101, local)*
- `Map.SeedFloor` *(:1114, function)*
- `Map.Caption` *(:1136, function)*
- `ensureDots` *(:1159, local)*
- `styleDot` *(:1199, local)*
- `clearDots` *(:1212, local)*
- `paint` *(:1218, function)*
- `context` *(:1277, local)*
- `Map.LoadedId` *(:1285, function)*
- `Map.ReadoutAnchor` *(:1318, function)*
- `fillReadout` *(:1331, function)*
- `Map.Readout` *(:1365, function)*
- `Map.ShownArt` *(:1380, function)*
- `Map.Load` *(:1387, function)*
- `Map.Show` *(:1472, function)*
- `dragTo` *(:1505, local)*
- `Map.BeginDrag` *(:1516, function)*
- `Map.EndDrag` *(:1544, function)*
- `Map.Dragging` *(:1570, function)*
- `refreshControls` *(:1590, local)*
- `buildControls` *(:1599, function)*
- `btn` *(:1625, local)*
- `Map.ToggleControls` *(:1675, function)*
- `Map.ControlsShown` *(:1681, function)*
- `Map.Toggle` *(:1683, function)*
- `step` *(:1692, local)*
- `applyView` *(:1718, local)*
- `Map.Zoom` *(:1733, function)*
- `Map.Pan` *(:1735, function)*
- `Map.SetZoom` *(:1736, function)*
- `Map.StepZoom` *(:1749, function)*
- `Map.NextStage` *(:1757, function)*
- `Map.CycleZoomStage` *(:1766, function)*
- `Map.ZoomStages` *(:1770, function)*
- `Map.ResetZoom` *(:1774, function)*
- `Map.PanStep` *(:1782, function)*
- `Map.Recenter` *(:1789, function)*
- `Map.WheelZoom` *(:1805, function)*
- `Map.RightPan` *(:1807, function)*
- `Map.SetWheelZoom` *(:1808, function)*
- `Map.SetRightPan` *(:1814, function)*
- `Map.SetPan` *(:1823, function)*
- `panTo` *(:1833, local)*
- `Map.BeginPan` *(:1839, function)*
- `Map.EndPan` *(:1847, function)*
- `Map.Panning` *(:1854, function)*
- `Map.Repaint` *(:1856, function)*
- `Map.Floor` *(:1860, function)*
- `Map.Init` *(:1873, function)*
- `Map.MapIDOf` *(:2017, function)*
- `Map.TimeSpan` *(:2017, function)*
- `Map.RunList` *(:2017, function)*

## `object.lua`

**pushes:** `StaticPopup_Show`

- `subject` *(:64, local)*
- `refresh` *(:70, local)*
- `commitName` *(:151, local)*
- `installPopups` *(:158, local)*
- `Object.Init` *(:182, function)*
- `b.func` *(:311, assigned)*
- `Object.Toggle` *(:364, function)*
- `Object.IsShown` *(:369, function)*

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
- `Routes.SetStage` *(:378, function)*
- `Routes.StageMatches` *(:388, function)*
- `Routes.Gaps` *(:402, function)*
- `Routes.Outcome` *(:422, function)*
- `Routes.StageOrder` *(:431, function)*
- `Routes.BeaconAt` *(:443, function)*
- `notes` *(:462, local)*
- `Routes.NotePlane` *(:464, function)*
- `Routes.GetNotes` *(:474, function)*
- `Routes.AddNote` *(:479, function)*
- `Routes.NoteCount` *(:490, function)*
- `Routes.Place` *(:494, function)*

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
