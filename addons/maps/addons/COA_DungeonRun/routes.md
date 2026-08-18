# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_15 file(s) · 384 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `974d4e7876de`._

## `adaptor.lua`

- `Adaptor.Has` *(:104, function)*
- `Adaptor.Codes` *(:109, function)*
- `Adaptor.Word` *(:115, function)*

## `calibrate.lua`

- `Calibrate.Init` *(:61, function)*
- `Calibrate.Clear` *(:67, function)*
- `spread` *(:125, local)*
- `Calibrate.Fit` *(:148, function)*
- `Calibrate.Apply` *(:183, function)*
- `Calibrate.For` *(:242, function)*
- `Calibrate.Floor` *(:253, function)*
- `Calibrate.ToWorld` *(:268, function)*
- `Calibrate.Report` *(:275, function)*
- `solve3` *(:290, local)*
- `build` *(:290, local)*

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`, `UnitIsGhost`, `UnitName`
**pushes:** `C_SuperTrack.GetSuperTrackedPosition`, `C_SuperTrack.GetTargetState`, `SetMapToCurrentZone`, `SuperTrackerUtil.ClearSuperTrackedPosition`, `SuperTrackerUtil.SetSuperTrackedPosition`

- `Capture.PendingPin` *(:97, function)*
- `dumpTrackedGlobal` *(:117, local)*
- `trackerProbe` *(:134, local)*
- `recapAttackers` *(:201, local)*
- `engagedBosses` *(:250, local)*
- `inInstance` *(:262, local)*
- `onUpdate` *(:338, function)*
- `Capture.Arm` *(:393, function)*
- `Capture.Stop` *(:454, function)*
- `Capture.RunId` *(:479, function)*
- `Capture.TestPin` *(:488, function)*
- `Capture.ClearTestPin` *(:507, function)*
- `Capture.Profile` *(:512, function)*
- `Capture.SampleEvery` *(:514, function)*
- `Capture.Pulls` *(:515, function)*
- `Capture.Pin` *(:543, function)*
- `onCombatStart` *(:553, local)*
- `onCombatEnd` *(:562, local)*
- `onPlayerDead` *(:584, local)*
- `onEncounterEngage` *(:591, local)*
- `captureOrigin` *(:605, function)*
- `onEnteringWorld` *(:679, local)*
- `Capture.Init` *(:683, function)*
- `captureMapArt` *(:708, function)*
- `Capture.ArmDev` *(:708, function)*

## `core.lua`  —  events: ADDON_LOADED

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `NS.Say` *(:34, function)*
- `status` *(:38, local)*
- `probe` *(:75, local)*
- `list` *(:89, local)*
- `slash` *(:102, local)*

## `editor.lua`  —  **OnUpdate ×2** (0 persistent)

**pulls:** `GetCurrentPlayerPosition`
**pushes:** `StaticPopup_Show`

- `clock` *(:76, local)*
- `toPx` *(:83, local)*
- `toSec` *(:88, local)*
- `refresh` *(:129, local)*
- `initDropdown` *(:210, local)*
- `info.func` *(:218, assigned)*
- `b.func` *(:242, assigned)*
- `installPopups` *(:255, local)*
- `Editor.Init` *(:286, function)*
- `handle` *(:467, local)*
- `drag` *(:485, local)*
- `widthBtn` *(:521, local)*
- `stepBtn` *(:540, local)*
- `Editor.SyncAll` *(:744, function)*
- `Editor.SyncPeek` *(:752, function)*
- `tick` *(:782, local)*
- `Editor.StopPlay` *(:794, function)*
- `Editor.TogglePlay` *(:801, function)*
- `Editor.Toggle` *(:809, function)*

## `layout.lua`

**pulls:** `AtlasInfo`

- `Layout.DROPDOWN_FIELD` *(:119, assigned)*
- `Layout.DROPDOWN_TEXT` *(:121, assigned)*
- `Layout.DROPDOWN_ART` *(:122, assigned)*
- `Layout.SkinDivider` *(:139, function)*
- `Layout.NewZone` *(:160, function)*
- `Layout.AddRow` *(:202, function)*
- `hide` *(:222, local)*
- `show` *(:226, local)*
- `Layout.Apply` *(:236, function)*
- `Layout.Height` *(:288, function)*

## `map.lua`  —  **OnUpdate ×2** (0 persistent)

**pulls:** `AtlasInfo`, `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ResolveBorrowedArt` *(:254, function)*
- `Map.ArtSize` *(:269, function)*
- `Map.TileGrid` *(:271, function)*
- `Map.ZoomAnchor` *(:333, function)*
- `Map.PanClamp` *(:342, function)*
- `layerDef` *(:394, local)*
- `resolve` *(:406, local)*
- `currentRun` *(:420, local)*
- `authoringMapID` *(:451, local)*
- `Map.AuthoringMapID` *(:458, function)*
- `stillLoaded` *(:464, local)*
- `Map.RunsFor` *(:536, function)*
- `Map.ArtFor` *(:557, function)*
- `Map.PointsOn` *(:578, function)*
- `Map.ClampWindow` *(:650, function)*
- `Map.SkipStep` *(:664, function)*
- `Map.Envelope` *(:668, function)*
- `Map.Window` *(:670, function)*
- `Map.Peeking` *(:671, function)*
- `repaintIfShown` *(:672, local)*
- `Map.ResetTime` *(:678, function)*
- `Map.Span` *(:689, function)*
- `Map.SetEnvelope` *(:691, function)*
- `Map.FloorAt` *(:718, function)*
- `Map.SeparateHandles` *(:737, function)*
- `Map.ResetView` *(:750, function)*
- `Map.TrackingFloor` *(:756, function)*
- `Map.SetTrackFloor` *(:758, function)*
- `Map.SetWindow` *(:764, function)*
- `Map.SetPeek` *(:782, function)*
- `Map.InWindow` *(:790, function)*
- `Map.VisibleOn` *(:816, function)*
- `Map.Painted` *(:831, function)*
- `Map.LayerShown` *(:849, function)*
- `Map.SetLayerShown` *(:851, function)*
- `Map.Layers` *(:857, function)*
- `Map.Hidden` *(:874, function)*
- `Map.SetHidden` *(:877, function)*
- `Map.KindKey` *(:901, function)*
- `Map.ArtKey` *(:927, function)*
- `Map.Rank` *(:935, function)*
- `Map.ArtForPoint` *(:939, function)*
- `Map.SetMoveArmed` *(:991, function)*
- `Map.MoveArmed` *(:998, function)*
- `Map.SetPickArmed` *(:1005, function)*
- `Map.PickArmed` *(:1010, function)*
- `Map.ArmedFor` *(:1014, function)*
- `Map.Disarm` *(:1016, function)*
- `Map.AddOnEdit` *(:1022, function)*
- `Map.ClearOnEdit` *(:1027, function)*
- `Map.OpenEditor` *(:1029, function)*
- `Map.AddOnSelect` *(:1036, function)*
- `Map.ClearOnSelect` *(:1044, function)*
- `fireSelect` *(:1046, local)*
- `Map.Selected` *(:1050, function)*
- `Map.ClickSelect` *(:1064, function)*
- `Map.Select` *(:1073, function)*
- `Map.Describe` *(:1092, function)*
- `add` *(:1104, local)*
- `Map.Palette` *(:1175, function)*
- `Map.ArtKeys` *(:1181, function)*
- `Map.KeyFacts` *(:1190, function)*
- `Map.FillTooltip` *(:1198, function)*
- `Map.Offset` *(:1223, function)*
- `Map.FractionAt` *(:1244, function)*
- `Map.Draggable` *(:1264, function)*
- `Map.TilePath` *(:1292, function)*
- `Map.TileRect` *(:1315, function)*
- `byName` *(:1348, local)*
- `Map.SeedFloor` *(:1361, function)*
- `Map.Caption` *(:1383, function)*
- `ensureDots` *(:1406, local)*
- `styleDot` *(:1463, local)*
- `clearDots` *(:1476, local)*
- `paint` *(:1482, function)*
- `context` *(:1545, local)*
- `Map.LoadedId` *(:1553, function)*
- `Map.ReadoutAnchor` *(:1588, function)*
- `fillReadout` *(:1601, function)*
- `Map.Readout` *(:1637, function)*
- `Map.ShownArt` *(:1652, function)*
- `Map.Load` *(:1659, function)*
- `Map.Show` *(:1753, function)*
- `dragTo` *(:1786, local)*
- `Map.BeginDrag` *(:1797, function)*
- `Map.EndDrag` *(:1829, function)*
- `Map.Dragging` *(:1855, function)*
- `refreshControls` *(:1881, local)*
- `buildControls` *(:1890, function)*
- `btn` *(:1916, local)*
- `Map.ToggleControls` *(:1973, function)*
- `Map.ControlsShown` *(:1979, function)*
- `Map.Toggle` *(:1981, function)*
- `step` *(:1990, local)*
- `applyView` *(:2018, local)*
- `Map.Zoom` *(:2033, function)*
- `Map.Pan` *(:2035, function)*
- `Map.SetZoom` *(:2036, function)*
- `Map.StepZoom` *(:2049, function)*
- `Map.NextStage` *(:2059, function)*
- `Map.CycleZoomStage` *(:2068, function)*
- `Map.ZoomStages` *(:2072, function)*
- `Map.ResetZoom` *(:2076, function)*
- `Map.PanStep` *(:2084, function)*
- `Map.Recenter` *(:2091, function)*
- `Map.WheelZoom` *(:2107, function)*
- `Map.RightPan` *(:2109, function)*
- `Map.SetWheelZoom` *(:2110, function)*
- `Map.SetRightPan` *(:2116, function)*
- `Map.SetPan` *(:2125, function)*
- `panTo` *(:2135, local)*
- `Map.BeginPan` *(:2141, function)*
- `Map.EndPan` *(:2149, function)*
- `Map.Panning` *(:2156, function)*
- `Map.Repaint` *(:2158, function)*
- `Map.Floor` *(:2162, function)*
- `Map.Init` *(:2177, function)*
- `Map.MapIDOf` *(:2389, function)*
- `Map.TimeSpan` *(:2389, function)*
- `Map.RunList` *(:2389, function)*

## `object.lua`  —  hookscript: OnClick

**pushes:** `StaticPopup_Show`

- `NS.Tests.Register` *(:92, function)*
- `NS.Tests.Run` *(:99, function)*
- `subject` *(:174, local)*
- `setReach` *(:195, local)*
- `answersFor` *(:201, local)*
- `nameOf` *(:209, local)*
- `refresh` *(:238, local)*
- `commitName` *(:534, local)*
- `installPopups` *(:541, local)*
- `Object.Init` *(:574, function)*
- `b.func` *(:722, assigned)*
- `b.func` *(:722, assigned)*
- `b.func` *(:722, assigned)*
- `b.func` *(:722, assigned)*
- `e.func` *(:921, assigned)*
- `e.func` *(:921, assigned)*
- `numBox` *(:1027, local)*
- `zText` *(:1387, local)*
- `Object.Toggle` *(:1433, function)*
- `Object.IsShown` *(:1438, function)*
- `parentOf` *(:1439, local)*

## `options.lua`

- `Options.FrameSize` *(:79, function)*
- `Options.Fits` *(:88, function)*
- `Options.Table` *(:112, function)*
- `Options.Lanes` *(:136, function)*
- `Options.BuildFrame` *(:166, function)*
- `Options.SeatMap` *(:208, function)*
- `Options.Toggle` *(:238, function)*
- `Options.Init` *(:254, function)*
- `Options.MapFloor` *(:268, function)*

## `panespec.lua`

- `only` *(:47, local)*
- `Spec.Build` *(:172, function)*

## `promoter.lua`

**pushes:** `StaticPopup_Show`

- `isPromoted` *(:75, local)*
- `selectedNode` *(:77, local)*
- `rawSelected` *(:84, local)*
- `authoringMapID` *(:90, local)*
- `refresh` *(:95, local)*
- `initDropdown` *(:232, local)*
- `info.func` *(:237, assigned)*
- `none.func` *(:248, assigned)*
- `b.func` *(:269, assigned)*
- `installPopups` *(:275, local)*
- `mintRoute` *(:323, local)*
- `mintBeacon` *(:338, local)*
- `mintNote` *(:359, local)*
- `Promoter.Init` *(:371, function)*
- `Promoter.Toggle` *(:655, function)*
- `Promoter.IsShown` *(:660, function)*

## `routes.lua`

**pulls:** `UnitName`

- `Routes.Init` *(:52, function)*
- `Routes.Inherit` *(:65, function)*
- `Routes.InheritSummary` *(:75, function)*
- `tbl` *(:93, local)*
- `Routes.Get` *(:127, function)*
- `Routes.Rename` *(:132, function)*
- `Routes.Delete` *(:139, function)*
- `Routes.Ids` *(:144, function)*
- `Routes.DropRetired` *(:180, function)*
- `Routes.MigrateRIDs` *(:219, function)*
- `Routes.List` *(:264, function)*
- `Routes.NextStage` *(:303, function)*
- `nextBeaconId` *(:332, local)*
- `Routes.AddBeacon` *(:337, function)*
- `Routes.Unplace` *(:406, function)*
- `Routes.PositionOf` *(:415, function)*
- `Routes.WorldOf` *(:421, function)*
- `Routes.SetName` *(:431, function)*
- `Routes.NameOf` *(:438, function)*
- `Routes.DeleteNote` *(:445, function)*
- `Routes.DeleteBeacon` *(:464, function)*
- `Routes.Count` *(:475, function)*
- `Routes.OrdinalOf` *(:574, function)*
- `Routes.ChildrenOf` *(:587, function)*
- `Routes.ChildrenAsMinted` *(:606, function)*
- `Routes.OrdinalMatches` *(:615, function)*
- `Routes.ChildAt` *(:630, function)*
- `Routes.PathOf` *(:652, function)*
- `Routes.ListensNow` *(:667, function)*
- `Routes.ChildCount` *(:681, function)*
- `nextChildId` *(:694, local)*
- `mint` *(:701, local)*
- `Routes.AddChildFromNode` *(:714, function)*
- `Routes.AddChildHere` *(:728, function)*
- `Routes.DeleteChild` *(:740, function)*
- `Routes.ParentOf` *(:754, function)*
- `Routes.StageOf` *(:785, function)*
- `has` *(:887, local)*
- `Routes.SetChildSense` *(:953, function)*
- `Routes.SenseOf` *(:967, function)*
- `Routes.Sense` *(:969, function)*
- `Routes.RowsOf` *(:1027, function)*
- `Routes.SetRow` *(:1042, function)*
- `Routes.RowIncomplete` *(:1063, function)*
- `Routes.SetChildBoss` *(:1070, function)*
- `Routes.BossOf` *(:1081, function)*
- `Routes.ArmsWith` *(:1105, function)*
- `Routes.SetChildRole` *(:1116, function)*
- `Routes.SetChildStage` *(:1134, function)*
- `Routes.SetChildIfUnseen` *(:1146, function)*
- `Routes.ChildIfUnseen` *(:1160, function)*
- `Routes.SetChildIcon` *(:1176, function)*
- `Routes.IconOf` *(:1187, function)*
- `Routes.SetChildShape` *(:1189, function)*
- `setReach` *(:1209, local)*
- `Routes.SetChildReach` *(:1217, function)*
- `Routes.SetBeaconReach` *(:1221, function)*
- `Routes.ReachOf` *(:1266, function)*
- `Routes.SetChildAction` *(:1299, function)*
- `Routes.AcceptanceOf` *(:1382, function)*
- `Routes.RoleMatches` *(:1396, function)*
- `Routes.ChildrenWithRole` *(:1404, function)*
- `Routes.SetOutcome` *(:1440, function)*
- `Routes.OutcomeOf` *(:1448, function)*
- `Routes.SetStage` *(:1482, function)*
- `Routes.StageMatches` *(:1492, function)*
- `Routes.Gaps` *(:1506, function)*
- `Routes.Outcome` *(:1526, function)*
- `Routes.StageOrder` *(:1535, function)*
- `Routes.BeaconAt` *(:1547, function)*
- `noteKey` *(:1575, local)*
- `routeNotes` *(:1580, local)*
- `Routes.SetRouteNote` *(:1587, function)*
- `Routes.RouteNoteOf` *(:1598, function)*
- `Routes.NotePlane` *(:1621, function)*
- `Routes.GetNotes` *(:1631, function)*
- `Routes.AddNote` *(:1636, function)*
- `Routes.NoteCount` *(:1647, function)*
- `Routes.Create` *(:1651, function)*
- `Routes.Place` *(:1651, function)*
- `Routes.SetChildOrdinal` *(:1651, function)*
- `Routes.SetChildFireOn` *(:1651, function)*
- `notes` *(:1651, local)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.Load` *(:58, function)*
- `db` *(:85, local)*
- `Store.StampSchema` *(:91, function)*
- `Store.SetProbe` *(:164, function)*
- `Store.Probe` *(:166, function)*
- `merge` *(:167, local)*
- `Store.Point` *(:177, function)*
- `Store.Open` *(:208, function)*
- `Store.Get` *(:227, function)*
- `Store.Close` *(:232, function)*
- `Store.Rename` *(:246, function)*
- `Store.SetComment` *(:258, function)*
- `Store.Delete` *(:267, function)*
- `Store.Ids` *(:272, function)*
- `Store.AddLeg` *(:313, function)*
- `Store.SetTestPin` *(:324, function)*
- `Store.SetOutside` *(:331, function)*
- `Store.SetArrival` *(:337, function)*
- `Store.SetInstance` *(:350, function)*
- `Store.SetMapArt` *(:368, function)*
- `Store.AddBoss` *(:384, function)*
- `Store.BossNames` *(:402, function)*
- `Store.RouteTable` *(:446, function)*
- `Store.RouteNoteTable` *(:470, function)*
- `Store.NoteTable` *(:477, function)*
- `Store.NextRouteId` *(:487, function)*
- `Store.GetUI` *(:495, function)*
- `Store.SetUI` *(:504, function)*
- `Store.SetUIRun` *(:521, function)*
- `Store.UIRun` *(:526, function)*
- `Store.AddMarker` *(:529, function)*
- `Store.Counts` *(:529, function)*
- `mapFraction` *(:529, local)*
- `composeId` *(:529, local)*

## `ui.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetTime`

- `UI.Init` *(:67, function)*
- `UI.Register` *(:101, function)*
- `UI.Get` *(:117, function)*
- `UI.Keys` *(:122, function)*
- `UI.Misses` *(:128, function)*
- `UI.BadKinds` *(:130, function)*
- `UI.List` *(:131, function)*
- `UI.Click` *(:150, function)*
- `UI.Set` *(:158, function)*
- `UI.Read` *(:168, function)*
- `UI.PlanClear` *(:196, function)*
- `UI.PlanAdd` *(:201, function)*
- `UI.PlanSize` *(:211, function)*
- `UI.Plan` *(:213, function)*
- `UI.RunId` *(:214, function)*
- `UI.Step` *(:218, function)*
- `UI.RunPlan` *(:274, function)*
- `UI.Tick` *(:289, function)*
- `UI.Finish` *(:306, function)*
- `UI.Running` *(:318, function)*
- `UI.Summary` *(:323, function)*

## `widget.lua`

- `refresh` *(:24, local)*
- `toggleArm` *(:49, local)*
- `Widget.Init` *(:64, function)*
- `Widget.Pin` *(:220, function)*
- `Widget.Toggle` *(:228, function)*
