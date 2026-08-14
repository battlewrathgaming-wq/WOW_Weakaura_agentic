# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_11 file(s) · 271 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `8fb0e77ad5d3`._

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

**pulls:** `GetMapInfo`, `UnitIsGhost`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `recapAttackers` *(:67, local)*
- `engagedBosses` *(:114, local)*
- `inInstance` *(:126, local)*
- `onUpdate` *(:202, function)*
- `Capture.Stop` *(:255, function)*
- `Capture.RunId` *(:270, function)*
- `Capture.Pulls` *(:272, function)*
- `Capture.Pin` *(:300, function)*
- `onCombatStart` *(:310, local)*
- `onCombatEnd` *(:319, local)*
- `onPlayerDead` *(:336, local)*
- `onEncounterEngage` *(:343, local)*
- `captureOrigin` *(:357, function)*
- `onEnteringWorld` *(:427, local)*
- `Capture.Init` *(:431, function)*
- `captureMapArt` *(:456, function)*
- `Capture.Arm` *(:456, function)*

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
- `Driver.Reached` *(:98, function)*
- `beaconAt` *(:114, local)*
- `say` *(:120, local)*
- `label` *(:123, local)*
- `report` *(:125, local)*
- `scan` *(:146, local)*
- `Driver.Arm` *(:180, function)*
- `Driver.Stop` *(:205, function)*
- `Driver.Armed` *(:219, function)*
- `Driver.Stage` *(:221, function)*
- `Driver.Route` *(:222, function)*
- `initDropdown` *(:224, local)*
- `b.func` *(:239, assigned)*
- `Driver.Init` *(:243, function)*
- `Driver.Toggle` *(:299, function)*

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
- `Map.Offset` *(:989, function)*
- `Map.FractionAt` *(:1009, function)*
- `Map.Draggable` *(:1023, function)*
- `Map.TilePath` *(:1044, function)*
- `Map.TileRect` *(:1067, function)*
- `byName` *(:1100, local)*
- `Map.SeedFloor` *(:1113, function)*
- `Map.Caption` *(:1135, function)*
- `ensureDots` *(:1158, local)*
- `styleDot` *(:1198, local)*
- `clearDots` *(:1211, local)*
- `paint` *(:1217, function)*
- `context` *(:1276, local)*
- `Map.LoadedId` *(:1284, function)*
- `Map.ReadoutAnchor` *(:1317, function)*
- `fillReadout` *(:1330, function)*
- `Map.Readout` *(:1364, function)*
- `Map.ShownArt` *(:1379, function)*
- `Map.Load` *(:1386, function)*
- `Map.Show` *(:1471, function)*
- `dragTo` *(:1504, local)*
- `Map.BeginDrag` *(:1515, function)*
- `Map.EndDrag` *(:1543, function)*
- `Map.Dragging` *(:1569, function)*
- `refreshControls` *(:1589, local)*
- `buildControls` *(:1598, function)*
- `btn` *(:1624, local)*
- `Map.ToggleControls` *(:1674, function)*
- `Map.ControlsShown` *(:1680, function)*
- `Map.Toggle` *(:1682, function)*
- `step` *(:1691, local)*
- `applyView` *(:1717, local)*
- `Map.Zoom` *(:1732, function)*
- `Map.Pan` *(:1734, function)*
- `Map.SetZoom` *(:1735, function)*
- `Map.StepZoom` *(:1748, function)*
- `Map.NextStage` *(:1756, function)*
- `Map.CycleZoomStage` *(:1765, function)*
- `Map.ZoomStages` *(:1769, function)*
- `Map.ResetZoom` *(:1773, function)*
- `Map.PanStep` *(:1781, function)*
- `Map.Recenter` *(:1788, function)*
- `Map.WheelZoom` *(:1804, function)*
- `Map.RightPan` *(:1806, function)*
- `Map.SetWheelZoom` *(:1807, function)*
- `Map.SetRightPan` *(:1813, function)*
- `Map.SetPan` *(:1822, function)*
- `panTo` *(:1832, local)*
- `Map.BeginPan` *(:1838, function)*
- `Map.EndPan` *(:1846, function)*
- `Map.Panning` *(:1853, function)*
- `Map.Repaint` *(:1855, function)*
- `Map.Floor` *(:1859, function)*
- `Map.Init` *(:1872, function)*
- `Map.MapIDOf` *(:2016, function)*
- `Map.TimeSpan` *(:2016, function)*
- `Map.RunList` *(:2016, function)*

## `object.lua`

**pushes:** `StaticPopup_Show`

- `subject` *(:63, local)*
- `refresh` *(:69, local)*
- `commitName` *(:150, local)*
- `installPopups` *(:157, local)*
- `Object.Init` *(:181, function)*
- `b.func` *(:310, assigned)*
- `Object.Toggle` *(:363, function)*
- `Object.IsShown` *(:368, function)*

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
- `Routes.NextStage` *(:182, function)*
- `Routes.AddBeacon` *(:200, function)*
- `Routes.Unplace` *(:266, function)*
- `Routes.PositionOf` *(:275, function)*
- `Routes.WorldOf` *(:281, function)*
- `Routes.SetName` *(:291, function)*
- `Routes.NameOf` *(:298, function)*
- `Routes.DeleteNote` *(:305, function)*
- `Routes.DeleteBeacon` *(:313, function)*
- `Routes.Count` *(:324, function)*
- `Routes.SetOutcome` *(:357, function)*
- `Routes.OutcomeOf` *(:365, function)*
- `Routes.SetStage` *(:376, function)*
- `Routes.StageMatches` *(:386, function)*
- `Routes.Gaps` *(:400, function)*
- `Routes.Outcome` *(:420, function)*
- `Routes.StageOrder` *(:429, function)*
- `Routes.BeaconAt` *(:441, function)*
- `notes` *(:460, local)*
- `Routes.NotePlane` *(:462, function)*
- `Routes.GetNotes` *(:472, function)*
- `Routes.AddNote` *(:477, function)*
- `Routes.NoteCount` *(:488, function)*
- `Routes.Place` *(:492, function)*

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
