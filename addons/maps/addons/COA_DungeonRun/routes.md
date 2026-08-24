# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_23 file(s) · 510 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `dc8975639269`._

## `adaptor.lua`

- `Adaptor.Has` *(:114, function)*
- `Adaptor.Codes` *(:119, function)*
- `Adaptor.Word` *(:125, function)*

## `bucket.lua`

- `known` *(:83, local)*
- `num` *(:100, local)*
- `wholeStage` *(:108, local)*
- `Bucket.Build` *(:119, function)*
- `who` *(:245, local)*
- `Bucket.NextStage` *(:545, function)*
- `Bucket.NextStep` *(:559, function)*
- `Bucket.FirstStage` *(:575, function)*
- `Bucket.FirstStep` *(:583, function)*
- `Bucket.Stage` *(:587, function)*
- `push` *(:593, local)*

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
- `usableCoord` *(:138, local)*
- `trackerProbe` *(:142, local)*
- `recapAttackers` *(:228, local)*
- `engagedBosses` *(:277, local)*
- `inInstance` *(:289, local)*
- `onUpdate` *(:365, function)*
- `Capture.Arm` *(:420, function)*
- `Capture.Stop` *(:481, function)*
- `Capture.RunId` *(:506, function)*
- `Capture.TestPin` *(:515, function)*
- `Capture.ClearTestPin` *(:534, function)*
- `Capture.Profile` *(:539, function)*
- `Capture.SampleEvery` *(:541, function)*
- `Capture.Pulls` *(:542, function)*
- `Capture.Pin` *(:570, function)*
- `onCombatStart` *(:580, local)*
- `onCombatEnd` *(:589, local)*
- `onPlayerDead` *(:611, local)*
- `onEncounterEngage` *(:618, local)*
- `captureOrigin` *(:632, function)*
- `onEnteringWorld` *(:706, local)*
- `Capture.Init` *(:710, function)*
- `captureMapArt` *(:735, function)*
- `Capture.ArmDev` *(:735, function)*

## `contract.lua`

- `Contract.Fields` *(:132, function)*
- `Contract.Optional` *(:142, function)*

## `core.lua`  —  events: ADDON_LOADED

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`
**pushes:** `SuperTrackerUtil.ClearSuperTrackedPosition`, `SuperTrackerUtil.SetSuperTrackedPosition`

- `NS.Say` *(:66, function)*
- `status` *(:70, local)*
- `probe` *(:107, local)*
- `list` *(:121, local)*
- `slash` *(:134, local)*

## `debuglog.lua`

- `DebugLog.Running` *(:52, function)*
- `DebugLog.Name` *(:55, function)*
- `DebugLog.Start` *(:64, function)*
- `DebugLog.Stop` *(:82, function)*
- `DebugLog.Note` *(:106, function)*
- `DebugLog.Poll` *(:121, function)*
- `DebugLog.Record` *(:147, function)*
- `DebugLog.ArmErrors` *(:164, function)*
- `DebugLog.DisarmErrors` *(:174, function)*
- `walk` *(:225, local)*
- `DebugLog.ReadFrames` *(:247, function)*
- `DebugLog.Count` *(:292, function)*
- `DebugLog.Report` *(:292, function)*
- `rect` *(:292, local)*

## `drive.lua`

**pulls:** `GetCurrentPlayerPosition`, `GetTime`

- `mapNow` *(:80, local)*
- `bind` *(:89, local)*
- `Drive.At` *(:176, function)*
- `Drive.AtId` *(:178, function)*
- `Drive.Shown` *(:179, function)*
- `Drive.Refusal` *(:182, function)*
- `Drive.RouteText` *(:186, function)*
- `Drive.Waiting` *(:188, function)*
- `Drive.Readout` *(:192, function)*
- `refresh` *(:200, local)*
- `Drive.Reoffer` *(:252, function)*
- `Drive.Cycle` *(:265, function)*
- `Drive.ToggleArm` *(:272, function)*
- `Drive.Wire` *(:310, function)*
- `Sensor.OnChange` *(:315, assigned)*
- `Drive.Unwire` *(:323, function)*
- `Drive.BossDown` *(:334, function)*
- `Drive.ToggleLog` *(:342, function)*
- `Drive.Init` *(:391, function)*
- `Drive.Toggle` *(:499, function)*
- `Drive.Offered` *(:513, function)*
- `readout` *(:513, local)*
- `checkAhead` *(:513, local)*

## `driver.lua`

- `Driver.Sample` *(:40, function)*
- `Driver.Start` *(:52, function)*
- `Driver.Stop` *(:81, function)*
- `Driver.Running` *(:93, function)*
- `Driver.Designate` *(:114, function)*
- `Driver.Status` *(:128, function)*

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
- `Layout.SetFolded` *(:242, function)*
- `Layout.IsFolded` *(:248, function)*
- `Layout.Foldable` *(:255, function)*
- `hide` *(:259, local)*
- `show` *(:263, local)*
- `Layout.Apply` *(:273, function)*
- `Layout.Height` *(:332, function)*

## `manager.lua`

- `offered` *(:78, local)*
- `Bucket_ALWAYS_get` *(:93, local)*
- `say` *(:106, local)*
- `note` *(:122, local)*
- `count` *(:127, local)*
- `Manager.Bound` *(:156, function)*
- `Manager.ClearBindings` *(:160, function)*
- `Manager.Running` *(:182, function)*
- `Manager.Stage` *(:185, function)*
- `Manager.Step` *(:186, function)*
- `Manager.Bucket` *(:187, function)*
- `Manager.Selected` *(:190, function)*
- `Manager.Ledger` *(:197, function)*
- `armCurrent` *(:228, local)*
- `disarmAll` *(:277, local)*
- `Manager.Stop` *(:290, function)*
- `nodeComplete` *(:376, local)*
- `held` *(:380, function)*
- `completer` *(:385, local)*
- `Manager.OnPoll` *(:407, function)*
- `Manager.SetStage` *(:645, function)*
- `Manager.StepOn` *(:670, function)*
- `Manager.StageDone` *(:687, function)*
- `Manager.Rearm` *(:707, function)*
- `Manager.Bind` *(:719, function)*
- `Manager.Offer` *(:719, function)*
- `Manager.Select` *(:719, function)*
- `nodeLatched` *(:719, function)*
- `Manager.NodeDone` *(:719, function)*
- `unbound` *(:719, local)*

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
- `subject` *(:176, local)*
- `setReach` *(:197, local)*
- `answersFor` *(:203, local)*
- `nameOf` *(:211, local)*
- `refresh` *(:240, local)*
- `commitName` *(:532, local)*
- `installPopups` *(:539, local)*
- `Object.Init` *(:572, function)*
- `b.func` *(:720, assigned)*
- `b.func` *(:720, assigned)*
- `b.func` *(:720, assigned)*
- `b.func` *(:720, assigned)*
- `e.func` *(:919, assigned)*
- `e.func` *(:919, assigned)*
- `numBox` *(:1025, local)*
- `zText` *(:1375, local)*
- `Object.Toggle` *(:1421, function)*
- `Object.IsShown` *(:1426, function)*
- `parentOf` *(:1427, local)*

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
- `Spec.Build` *(:226, function)*

## `promoter.lua`

**pushes:** `StaticPopup_Show`

- `isPromoted` *(:76, local)*
- `selectedNode` *(:78, local)*
- `rawSelected` *(:85, local)*
- `authoringMapID` *(:91, local)*
- `refresh` *(:96, local)*
- `initDropdown` *(:253, local)*
- `info.func` *(:258, assigned)*
- `none.func` *(:269, assigned)*
- `b.func` *(:292, assigned)*
- `installPopups` *(:298, local)*
- `mintRoute` *(:346, local)*
- `mintBeacon` *(:361, local)*
- `mintNote` *(:382, local)*
- `Promoter.Init` *(:394, function)*
- `Promoter.Toggle` *(:694, function)*
- `Promoter.IsShown` *(:699, function)*

## `routes.lua`

- `Routes.Init` *(:52, function)*
- `Routes.Inherit` *(:71, function)*
- `Routes.InheritSummary` *(:81, function)*
- `tbl` *(:99, local)*
- `Routes.Get` *(:149, function)*
- `Routes.Rename` *(:154, function)*
- `Routes.Delete` *(:161, function)*
- `Routes.Ids` *(:166, function)*
- `strayArgs` *(:234, local)*
- `untrack` *(:296, local)*
- `migrateNode` *(:315, local)*
- `Routes.MigrateRows` *(:337, function)*
- `Routes.DropRetired` *(:360, function)*
- `Routes.MigrateRIDs` *(:458, function)*
- `Routes.List` *(:503, function)*
- `Routes.NextStage` *(:542, function)*
- `nextBeaconId` *(:576, local)*
- `Routes.AddBeacon` *(:581, function)*
- `Routes.Unplace` *(:674, function)*
- `Routes.PositionOf` *(:683, function)*
- `Routes.ParkFor` *(:720, function)*
- `Routes.ParkClearance` *(:761, function)*
- `Routes.WorldOf` *(:780, function)*
- `Routes.SetName` *(:790, function)*
- `Routes.NameOf` *(:797, function)*
- `Routes.DeleteNote` *(:804, function)*
- `Routes.DeleteBeacon` *(:823, function)*
- `Routes.Count` *(:834, function)*
- `Routes.OrdinalOf` *(:953, function)*
- `Routes.ChildrenOf` *(:966, function)*
- `Routes.ChildrenAsMinted` *(:985, function)*
- `Routes.OrdinalMatches` *(:994, function)*
- `Routes.NextOrdinal` *(:1019, function)*
- `Routes.OrdinalGaps` *(:1045, function)*
- `Routes.ChildAt` *(:1074, function)*
- `Routes.PathOf` *(:1096, function)*
- `Routes.ListensNow` *(:1111, function)*
- `Routes.ChildCount` *(:1125, function)*
- `nextChildId` *(:1138, local)*
- `mint` *(:1223, local)*
- `Routes.AddChildFromNode` *(:1241, function)*
- `Routes.AddChildHere` *(:1255, function)*
- `Routes.DeleteChild` *(:1267, function)*
- `Routes.ParentOf` *(:1281, function)*
- `Routes.StageOf` *(:1312, function)*
- `has` *(:1414, local)*
- `Routes.SetChildSense` *(:1480, function)*
- `Routes.SenseOf` *(:1494, function)*
- `Routes.Sense` *(:1496, function)*
- `Routes.OfferedTrigger` *(:1660, function)*
- `Routes.SetTrigger` *(:1666, function)*
- `Routes.TriggerOf` *(:1679, function)*
- `Routes.SetNext` *(:1686, function)*
- `Routes.NextOf` *(:1702, function)*
- `Routes.IsPosition` *(:1729, function)*
- `Routes.LedTo` *(:1746, function)*
- `Routes.RowsOf` *(:1815, function)*
- `Routes.SetRow` *(:1833, function)*
- `Routes.RowIncomplete` *(:1882, function)*
- `Routes.SetChildBoss` *(:1889, function)*
- `Routes.BossOf` *(:1900, function)*
- `Routes.ArmsWith` *(:1924, function)*
- `Routes.SetChildRole` *(:1935, function)*
- `Routes.SetChildStage` *(:1953, function)*
- `Routes.SetChildIfUnseen` *(:1965, function)*
- `Routes.ChildIfUnseen` *(:1979, function)*
- `Routes.SetChildIcon` *(:1995, function)*
- `Routes.IconOf` *(:2006, function)*
- `Routes.SetChildShape` *(:2008, function)*
- `setReach` *(:2054, local)*
- `Routes.SetChildReach` *(:2067, function)*
- `Routes.SetBeaconReach` *(:2071, function)*
- `Routes.ReachOf` *(:2133, function)*
- `Routes.SetChildAction` *(:2170, function)*
- `Routes.RoleMatches` *(:2268, function)*
- `Routes.ChildrenWithRole` *(:2276, function)*
- `Routes.SetOutcome` *(:2312, function)*
- `Routes.OutcomeOf` *(:2342, function)*
- `Routes.SetStage` *(:2376, function)*
- `Routes.StageMatches` *(:2392, function)*
- `Routes.Gaps` *(:2406, function)*
- `Routes.Outcome` *(:2430, function)*
- `Routes.StageOrder` *(:2458, function)*
- `Routes.BeaconAt` *(:2487, function)*
- `noteKey` *(:2515, local)*
- `routeNotes` *(:2520, local)*
- `Routes.SetRouteNote` *(:2527, function)*
- `Routes.RouteNoteOf` *(:2538, function)*
- `Routes.NotePlane` *(:2561, function)*
- `Routes.GetNotes` *(:2571, function)*
- `Routes.AddNote` *(:2576, function)*
- `Routes.NoteCount` *(:2587, function)*
- `Routes.Create` *(:2591, function)*
- `Routes.Place` *(:2591, function)*
- `Routes.SetChildOrdinal` *(:2591, function)*
- `Routes.StepR` *(:2591, function)*
- `Routes.AcceptanceOf` *(:2591, function)*
- `notes` *(:2591, local)*

## `rule.lua`

- `Rule.Usable` *(:78, function)*
- `Rule.Gate` *(:88, function)*
- `Rule.PointFire` *(:103, function)*
- `Rule.Evaluate` *(:124, function)*
- `finite` *(:149, local)*

## `sensor.lua`  —  **OnUpdate ×1** (0 persistent)

- `Sensor.CreateFrame` *(:62, assigned)*
- `snapshot` *(:138, local)*
- `Sensor.Arm` *(:145, function)*
- `Sensor.Disarm` *(:172, function)*
- `Sensor.IsArmed` *(:180, function)*
- `Sensor.Armed` *(:182, function)*
- `Sensor.NextIn` *(:191, function)*
- `Sensor.Poll` *(:219, function)*
- `report` *(:229, local)*
- `Sensor.Reset` *(:271, function)*
- `Sensor.InSet` *(:284, function)*
- `Sensor.State` *(:296, function)*
- `n` *(:299, local)*
- `Sensor.OnUpdate` *(:307, function)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.Load` *(:63, function)*
- `db` *(:90, local)*
- `Store.StampSchema` *(:96, function)*
- `Store.SetProbe` *(:169, function)*
- `Store.Probe` *(:171, function)*
- `merge` *(:172, local)*
- `Store.Point` *(:182, function)*
- `Store.Open` *(:213, function)*
- `Store.Get` *(:238, function)*
- `Store.Close` *(:243, function)*
- `Store.Rename` *(:257, function)*
- `Store.SetComment` *(:269, function)*
- `Store.Delete` *(:278, function)*
- `Store.Ids` *(:283, function)*
- `Store.AddLeg` *(:324, function)*
- `Store.SetTestPin` *(:335, function)*
- `Store.SetOutside` *(:342, function)*
- `Store.SetArrival` *(:348, function)*
- `Store.SetInstance` *(:361, function)*
- `Store.SetMapArt` *(:379, function)*
- `Store.AddBoss` *(:395, function)*
- `Store.BossNames` *(:413, function)*
- `Store.RouteTable` *(:457, function)*
- `Store.RouteNoteTable` *(:481, function)*
- `Store.NoteTable` *(:488, function)*
- `Store.NextRouteId` *(:498, function)*
- `Store.GetUI` *(:511, function)*
- `Store.SetUI` *(:520, function)*
- `Store.SetSelectedRoute` *(:543, function)*
- `Store.SelectedRoute` *(:553, function)*
- `Store.SetUIRun` *(:569, function)*
- `Store.UIRun` *(:574, function)*
- `Store.AddMarker` *(:577, function)*
- `Store.Counts` *(:577, function)*
- `mapFraction` *(:577, local)*
- `composeId` *(:577, local)*

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
- `Widget.Pin` *(:243, function)*
- `Widget.Toggle` *(:251, function)*
