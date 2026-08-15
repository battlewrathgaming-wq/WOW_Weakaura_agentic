# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_15 file(s) · 368 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `d3ca30c697bf`._

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

- `NS.Say` *(:31, function)*
- `status` *(:35, local)*
- `probe` *(:72, local)*
- `list` *(:86, local)*
- `slash` *(:99, local)*

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

## `layout.lua`

**pulls:** `AtlasInfo`

- `Layout.SkinDivider` *(:93, function)*
- `Layout.NewZone` *(:114, function)*
- `Layout.AddRow` *(:156, function)*
- `hide` *(:176, local)*
- `show` *(:180, local)*
- `Layout.Apply` *(:190, function)*
- `Layout.Height` *(:242, function)*

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
- `Map.ClickSelect` *(:1045, function)*
- `Map.Select` *(:1054, function)*
- `Map.Describe` *(:1073, function)*
- `add` *(:1085, local)*
- `Map.ArtKeys` *(:1141, function)*
- `Map.KeyFacts` *(:1150, function)*
- `Map.FillTooltip` *(:1158, function)*
- `Map.Offset` *(:1183, function)*
- `Map.FractionAt` *(:1204, function)*
- `Map.Draggable` *(:1224, function)*
- `Map.TilePath` *(:1252, function)*
- `Map.TileRect` *(:1275, function)*
- `byName` *(:1308, local)*
- `Map.SeedFloor` *(:1321, function)*
- `Map.Caption` *(:1343, function)*
- `ensureDots` *(:1366, local)*
- `styleDot` *(:1423, local)*
- `clearDots` *(:1436, local)*
- `paint` *(:1442, function)*
- `context` *(:1505, local)*
- `Map.LoadedId` *(:1513, function)*
- `Map.ReadoutAnchor` *(:1548, function)*
- `fillReadout` *(:1561, function)*
- `Map.Readout` *(:1597, function)*
- `Map.ShownArt` *(:1612, function)*
- `Map.Load` *(:1619, function)*
- `Map.Show` *(:1713, function)*
- `dragTo` *(:1746, local)*
- `Map.BeginDrag` *(:1757, function)*
- `Map.EndDrag` *(:1789, function)*
- `Map.Dragging` *(:1815, function)*
- `refreshControls` *(:1837, local)*
- `buildControls` *(:1846, function)*
- `btn` *(:1872, local)*
- `Map.ToggleControls` *(:1925, function)*
- `Map.ControlsShown` *(:1931, function)*
- `Map.Toggle` *(:1933, function)*
- `step` *(:1942, local)*
- `applyView` *(:1970, local)*
- `Map.Zoom` *(:1985, function)*
- `Map.Pan` *(:1987, function)*
- `Map.SetZoom` *(:1988, function)*
- `Map.StepZoom` *(:2001, function)*
- `Map.NextStage` *(:2011, function)*
- `Map.CycleZoomStage` *(:2020, function)*
- `Map.ZoomStages` *(:2024, function)*
- `Map.ResetZoom` *(:2028, function)*
- `Map.PanStep` *(:2036, function)*
- `Map.Recenter` *(:2043, function)*
- `Map.WheelZoom` *(:2059, function)*
- `Map.RightPan` *(:2061, function)*
- `Map.SetWheelZoom` *(:2062, function)*
- `Map.SetRightPan` *(:2068, function)*
- `Map.SetPan` *(:2077, function)*
- `panTo` *(:2087, local)*
- `Map.BeginPan` *(:2093, function)*
- `Map.EndPan` *(:2101, function)*
- `Map.Panning` *(:2108, function)*
- `Map.Repaint` *(:2110, function)*
- `Map.Floor` *(:2114, function)*
- `Map.Init` *(:2129, function)*
- `Map.MapIDOf` *(:2278, function)*
- `Map.TimeSpan` *(:2278, function)*
- `Map.RunList` *(:2278, function)*

## `object.lua`  —  hookscript: OnClick

**pushes:** `StaticPopup_Show`

- `NS.Tests.Register` *(:88, function)*
- `NS.Tests.Run` *(:95, function)*
- `parentOf` *(:145, local)*
- `subject` *(:150, local)*
- `answersFor` *(:165, local)*
- `nameOf` *(:170, local)*
- `refresh` *(:185, local)*
- `commitName` *(:354, local)*
- `installPopups` *(:361, local)*
- `Object.Init` *(:392, function)*
- `b.func` *(:535, assigned)*
- `b.func` *(:535, assigned)*
- `b.func` *(:535, assigned)*
- `b.func` *(:535, assigned)*
- `numBox` *(:697, local)*
- `none.func` *(:780, assigned)*
- `e.func` *(:793, assigned)*
- `zText` *(:914, local)*
- `Object.Toggle` *(:968, function)*
- `Object.IsShown` *(:973, function)*

## `panespec.lua`

- `only` *(:44, local)*
- `Spec.Build` *(:161, function)*

## `promoter.lua`

**pushes:** `StaticPopup_Show`

- `isPromoted` *(:70, local)*
- `selectedNode` *(:72, local)*
- `rawSelected` *(:79, local)*
- `authoringMapID` *(:85, local)*
- `refresh` *(:90, local)*
- `initDropdown` *(:224, local)*
- `info.func` *(:229, assigned)*
- `none.func` *(:240, assigned)*
- `b.func` *(:261, assigned)*
- `installPopups` *(:267, local)*
- `mintRoute` *(:293, local)*
- `mintBeacon` *(:308, local)*
- `mintNote` *(:329, local)*
- `Promoter.Init` *(:341, function)*
- `Promoter.Toggle` *(:577, function)*
- `Promoter.IsShown` *(:582, function)*

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
- `nextChildId` *(:391, local)*
- `mint` *(:398, local)*
- `Routes.AddChildFromNode` *(:411, function)*
- `Routes.AddChildHere` *(:425, function)*
- `Routes.DeleteChild` *(:437, function)*
- `Routes.ParentOf` *(:451, function)*
- `has` *(:547, local)*
- `Routes.SetChildRole` *(:576, function)*
- `Routes.SetChildStage` *(:594, function)*
- `Routes.SetChildIfUnseen` *(:606, function)*
- `Routes.ChildIfUnseen` *(:620, function)*
- `Routes.SetChildShape` *(:626, function)*
- `Routes.SetChildReach` *(:636, function)*
- `Routes.SetChildAction` *(:668, function)*
- `Routes.GoToTarget` *(:731, function)*
- `Routes.SetChildFireOn` *(:741, function)*
- `Routes.OnRampOf` *(:810, function)*
- `Routes.AcceptanceOf` *(:841, function)*
- `Routes.Heads` *(:860, function)*
- `Routes.BrokenLinks` *(:874, function)*
- `Routes.Cycles` *(:885, function)*
- `Routes.RoleMatches` *(:904, function)*
- `Routes.ChildrenWithRole` *(:912, function)*
- `Routes.SetOutcome` *(:948, function)*
- `Routes.OutcomeOf` *(:956, function)*
- `Routes.SetStage` *(:971, function)*
- `Routes.StageMatches` *(:981, function)*
- `Routes.Gaps` *(:995, function)*
- `Routes.Outcome` *(:1015, function)*
- `Routes.StageOrder` *(:1024, function)*
- `Routes.BeaconAt` *(:1036, function)*
- `notes` *(:1055, local)*
- `Routes.NotePlane` *(:1057, function)*
- `Routes.GetNotes` *(:1067, function)*
- `Routes.AddNote` *(:1072, function)*
- `Routes.NoteCount` *(:1083, function)*
- `Routes.Place` *(:1087, function)*
- `Routes.ChildrenOf` *(:1087, function)*
- `Routes.SetChildGoTo` *(:1087, function)*
- `Routes.SetChildOnRamp` *(:1087, function)*

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
- `Store.SetUIRun` *(:415, function)*
- `Store.UIRun` *(:420, function)*
- `Store.AddMarker` *(:423, function)*
- `Store.Counts` *(:423, function)*
- `mapFraction` *(:423, local)*
- `composeId` *(:423, local)*

## `ui.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetTime`

- `UI.Init` *(:63, function)*
- `UI.Register` *(:81, function)*
- `UI.Get` *(:94, function)*
- `UI.Keys` *(:99, function)*
- `UI.Misses` *(:105, function)*
- `UI.List` *(:107, function)*
- `UI.Click` *(:123, function)*
- `UI.Set` *(:131, function)*
- `UI.Read` *(:141, function)*
- `UI.PlanClear` *(:169, function)*
- `UI.PlanAdd` *(:174, function)*
- `UI.PlanSize` *(:184, function)*
- `UI.Plan` *(:186, function)*
- `UI.RunId` *(:187, function)*
- `UI.Step` *(:191, function)*
- `UI.RunPlan` *(:247, function)*
- `UI.Tick` *(:262, function)*
- `UI.Finish` *(:279, function)*
- `UI.Running` *(:291, function)*
- `UI.Summary` *(:296, function)*

## `walk.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCurrentPlayerPosition`
**pushes:** `SuperTrackerUtil.SetSuperTrackedPosition`

- `Walk.Init` *(:49, function)*
- `Walk.Hits` *(:55, function)*
- `Walk.Apply` *(:73, function)*
- `Walk.LastTarget` *(:134, function)*
- `Walk.Act` *(:136, function)*
- `Walk.OnRamp` *(:160, function)*
- `Walk.PointAtOnRamp` *(:173, function)*
- `Walk.Detectors` *(:188, function)*
- `Walk.State` *(:208, function)*
- `Walk.SeenCount` *(:220, function)*
- `Walk.Unrunnable` *(:233, function)*
- `Walk.MultipleAcceptance` *(:245, function)*
- `Walk.Waiting` *(:256, function)*
- `Walk.StartLines` *(:274, function)*
- `Walk.Start` *(:302, function)*
- `Walk.Stop` *(:314, function)*
- `Walk.IsRunning` *(:323, function)*
- `Walk.Index` *(:325, function)*
- `Walk.Seen` *(:326, function)*
- `Walk.Scan` *(:334, function)*
- `Walk.Tick` *(:372, function)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:46, local)*
- `Widget.Init` *(:61, function)*
- `Widget.Pin` *(:142, function)*
- `Widget.Toggle` *(:150, function)*
