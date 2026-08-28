# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_25 file(s) · 558 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `616577dd7d01`._

## `adaptor.lua`

- `Adaptor.Has` *(:206, function)*
- `Adaptor.Codes` *(:211, function)*
- `Adaptor.Word` *(:217, function)*

## `bosswatch.lua`  —  events: COMBAT_LOG_EVENT_UNFILTERED

- `BossWatch.Died` *(:58, function)*
- `onEvent` *(:81, local)*
- `BossWatch.Start` *(:89, function)*
- `BossWatch.Stop` *(:98, function)*
- `BossWatch.Arm` *(:109, function)*
- `BossWatch.Disarm` *(:127, function)*
- `BossWatch.Armed` *(:140, function)*
- `BossWatch.Names` *(:147, function)*
- `BossWatch.Listening` *(:154, function)*

## `bucket.lua`

- `known` *(:91, local)*
- `num` *(:108, local)*
- `wholeStage` *(:116, local)*
- `Bucket.Build` *(:127, function)*
- `who` *(:257, local)*
- `Bucket.NextStage` *(:557, function)*
- `Bucket.NextStep` *(:571, function)*
- `Bucket.FirstStage` *(:587, function)*
- `Bucket.FirstStep` *(:595, function)*
- `Bucket.Stage` *(:599, function)*
- `push` *(:605, local)*

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

- `Contract.Seed` *(:180, function)*
- `Contract.Fields` *(:187, function)*
- `Contract.Optional` *(:197, function)*

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

- `mapNow` *(:85, local)*
- `bind` *(:94, local)*
- `Drive.At` *(:201, function)*
- `Drive.AtId` *(:203, function)*
- `Drive.Shown` *(:207, function)*
- `Drive.Refusal` *(:213, function)*
- `Drive.RouteText` *(:221, function)*
- `Drive.Waiting` *(:226, function)*
- `Drive.Readout` *(:230, function)*
- `Drive.Reoffer` *(:301, function)*
- `Drive.Cycle` *(:314, function)*
- `Drive.ToggleArm` *(:321, function)*
- `Drive.Wire` *(:369, function)*
- `Drive.Unwire` *(:388, function)*
- `Drive.BossDown` *(:417, function)*
- `Drive.ToggleLog` *(:440, function)*
- `Drive.Init` *(:489, function)*
- `Drive.Toggle` *(:571, function)*
- `Drive.Offered` *(:579, function)*
- `readout` *(:579, local)*
- `refresh` *(:579, local)*
- `checkAhead` *(:579, local)*

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
- `wire` *(:126, local)*
- `announce` *(:167, local)*
- `say` *(:184, local)*
- `note` *(:200, local)*
- `count` *(:205, local)*
- `Manager.Bound` *(:234, function)*
- `Manager.ClearBindings` *(:238, function)*
- `Manager.Running` *(:260, function)*
- `Manager.Stage` *(:263, function)*
- `Manager.Step` *(:264, function)*
- `Manager.Bucket` *(:265, function)*
- `Manager.Selected` *(:268, function)*
- `Manager.Ledger` *(:275, function)*
- `armCurrent` *(:306, local)*
- `disarmAll` *(:355, local)*
- `Manager.Stop` *(:368, function)*
- `nodeComplete` *(:475, local)*
- `held` *(:479, function)*
- `completer` *(:484, local)*
- `hotAt` *(:530, local)*
- `slowEvery` *(:538, local)*
- `Manager.Rail` *(:544, function)*
- `railFrom` *(:556, local)*
- `Manager.OnPoll` *(:591, function)*
- `Manager.SetStage` *(:844, function)*
- `Manager.StepOn` *(:869, function)*
- `Manager.StageDone` *(:886, function)*
- `Manager.Rearm` *(:906, function)*
- `Manager.Bind` *(:918, function)*
- `Manager.Offer` *(:918, function)*
- `Manager.Select` *(:918, function)*
- `nodeLatched` *(:918, function)*
- `Manager.NodeDone` *(:918, function)*
- `unbound` *(:918, local)*

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
- `Map.AddOnSelect` *(:1036, function)*
- `Map.ClearOnSelect` *(:1045, function)*
- `fireSelect` *(:1047, local)*
- `Map.Selected` *(:1051, function)*
- `Map.ClickSelect` *(:1065, function)*
- `Map.Select` *(:1074, function)*
- `Map.Describe` *(:1093, function)*
- `add` *(:1105, local)*
- `Map.Palette` *(:1176, function)*
- `Map.ArtKeys` *(:1182, function)*
- `Map.KeyFacts` *(:1191, function)*
- `Map.FillTooltip` *(:1199, function)*
- `Map.Offset` *(:1224, function)*
- `Map.FractionAt` *(:1245, function)*
- `Map.Draggable` *(:1265, function)*
- `Map.TilePath` *(:1293, function)*
- `Map.TileRect` *(:1316, function)*
- `byName` *(:1349, local)*
- `Map.SeedFloor` *(:1362, function)*
- `Map.Caption` *(:1384, function)*
- `ensureDots` *(:1407, local)*
- `styleDot` *(:1467, local)*
- `clearDots` *(:1480, local)*
- `paint` *(:1486, function)*
- `context` *(:1549, local)*
- `Map.LoadedId` *(:1557, function)*
- `Map.ReadoutAnchor` *(:1592, function)*
- `fillReadout` *(:1605, function)*
- `Map.Readout` *(:1641, function)*
- `Map.ShownArt` *(:1656, function)*
- `Map.Load` *(:1663, function)*
- `Map.Show` *(:1757, function)*
- `dragTo` *(:1790, local)*
- `Map.BeginDrag` *(:1801, function)*
- `Map.EndDrag` *(:1833, function)*
- `Map.Dragging` *(:1859, function)*
- `refreshControls` *(:1885, local)*
- `buildControls` *(:1894, function)*
- `btn` *(:1920, local)*
- `Map.ToggleControls` *(:1977, function)*
- `Map.ControlsShown` *(:1983, function)*
- `Map.Toggle` *(:1985, function)*
- `step` *(:1994, local)*
- `applyView` *(:2022, local)*
- `Map.Zoom` *(:2037, function)*
- `Map.Pan` *(:2039, function)*
- `Map.SetZoom` *(:2040, function)*
- `Map.StepZoom` *(:2053, function)*
- `Map.NextStage` *(:2063, function)*
- `Map.CycleZoomStage` *(:2072, function)*
- `Map.ZoomStages` *(:2076, function)*
- `Map.ResetZoom` *(:2080, function)*
- `Map.PanStep` *(:2088, function)*
- `Map.Recenter` *(:2095, function)*
- `Map.WheelZoom` *(:2111, function)*
- `Map.RightPan` *(:2113, function)*
- `Map.SetWheelZoom` *(:2114, function)*
- `Map.SetRightPan` *(:2120, function)*
- `Map.SetPan` *(:2129, function)*
- `panTo` *(:2139, local)*
- `Map.BeginPan` *(:2145, function)*
- `Map.EndPan` *(:2153, function)*
- `Map.Panning` *(:2160, function)*
- `Map.Repaint` *(:2162, function)*
- `Map.Floor` *(:2166, function)*
- `Map.Init` *(:2181, function)*
- `Map.MapIDOf` *(:2393, function)*
- `Map.TimeSpan` *(:2393, function)*
- `Map.RunList` *(:2393, function)*

## `object.lua`  —  hookscript: OnClick

**pushes:** `StaticPopup_Show`

- `NS.Tests.Register` *(:92, function)*
- `NS.Tests.Run` *(:99, function)*
- `subject` *(:176, local)*
- `setReach` *(:197, local)*
- `answersFor` *(:203, local)*
- `nameOf` *(:211, local)*
- `refresh` *(:240, local)*
- `commitName` *(:537, local)*
- `installPopups` *(:544, local)*
- `Object.Init` *(:577, function)*
- `b.func` *(:728, assigned)*
- `b.func` *(:728, assigned)*
- `b.func` *(:728, assigned)*
- `b.func` *(:728, assigned)*
- `e.func` *(:929, assigned)*
- `e.func` *(:929, assigned)*
- `numBox` *(:1046, local)*
- `zText` *(:1399, local)*
- `Object.Toggle` *(:1445, function)*
- `Object.IsShown` *(:1450, function)*
- `parentOf` *(:1451, local)*

## `options.lua`

- `Options.FrameSize` *(:79, function)*
- `Options.Fits` *(:88, function)*
- `subject` *(:120, local)*
- `parentOf` *(:129, local)*
- `word` *(:140, local)*
- `BODIES.ordinal` *(:197, assigned)*
- `BODIES.next` *(:230, assigned)*
- `BODIES.nextArg` *(:266, assigned)*
- `BODIES.trigger` *(:301, assigned)*
- `BODIES.reach` *(:348, assigned)*
- `BODIES.band` *(:385, assigned)*
- `BODIES.ledTo` *(:417, assigned)*
- `Options.Refresh` *(:457, function)*
- `argPool` *(:473, local)*
- `tabGroup` *(:480, local)*
- `live` *(:483, local)*
- `write` *(:485, local)*
- `tabStrip` *(:609, local)*
- `BODIES.tabs` *(:666, assigned)*
- `BODIES.note` *(:670, assigned)*
- `buildLane` *(:702, local)*
- `body.name` *(:723, assigned)*
- `body.disabled` *(:729, assigned)*
- `Options.Missing` *(:740, function)*
- `Options.Table` *(:742, function)*
- `Options.Lanes` *(:804, function)*
- `Options.BuildFrame` *(:834, function)*
- `Options.SeatMap` *(:876, function)*
- `Options.Toggle` *(:906, function)*
- `Options.Init` *(:922, function)*
- `Options.MapFloor` *(:941, function)*
- `BODIES.stage` *(:941, assigned)*

## `panes_decl.lua`

- `Panes.Applies` *(:322, function)*
- `Panes.Unformable` *(:337, function)*
- `Panes.Lanes` *(:352, function)*

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
- `Routes.StagesPresent` *(:557, function)*
- `Routes.NextStage` *(:575, function)*
- `nextBeaconId` *(:609, local)*
- `Routes.AddBeacon` *(:614, function)*
- `Routes.Unplace` *(:707, function)*
- `Routes.PositionOf` *(:716, function)*
- `Routes.ParkFor` *(:753, function)*
- `Routes.ParkClearance` *(:794, function)*
- `Routes.WorldOf` *(:813, function)*
- `Routes.SetName` *(:823, function)*
- `Routes.NameOf` *(:830, function)*
- `Routes.DeleteNote` *(:837, function)*
- `Routes.DeleteBeacon` *(:856, function)*
- `Routes.Count` *(:867, function)*
- `Routes.OrdinalOf` *(:986, function)*
- `Routes.ChildrenOf` *(:999, function)*
- `Routes.ChildrenAsMinted` *(:1018, function)*
- `Routes.OrdinalMatches` *(:1027, function)*
- `Routes.NextOrdinal` *(:1052, function)*
- `Routes.OrdinalGaps` *(:1078, function)*
- `Routes.ChildAt` *(:1107, function)*
- `Routes.PathOf` *(:1129, function)*
- `Routes.ListensNow` *(:1144, function)*
- `Routes.ChildCount` *(:1158, function)*
- `Routes.StandsAlone` *(:1178, function)*
- `nextChildId` *(:1190, local)*
- `mint` *(:1298, local)*
- `Routes.AddChildFromNode` *(:1316, function)*
- `Routes.AddChildHere` *(:1330, function)*
- `Routes.DeleteChild` *(:1342, function)*
- `Routes.ParentOf` *(:1356, function)*
- `Routes.StageOf` *(:1387, function)*
- `has` *(:1489, local)*
- `Routes.SetChildSense` *(:1555, function)*
- `Routes.SenseOf` *(:1569, function)*
- `Routes.Sense` *(:1571, function)*
- `Routes.OfferedSense` *(:1803, function)*
- `Routes.OfferedTrigger` *(:1810, function)*
- `Routes.SetTrigger` *(:1816, function)*
- `Routes.TriggerOf` *(:1829, function)*
- `Routes.SetNext` *(:1836, function)*
- `Routes.NextOf` *(:1852, function)*
- `Routes.IsPosition` *(:1879, function)*
- `Routes.LedTo` *(:1896, function)*
- `Routes.SetLedTo` *(:1912, function)*
- `Routes.RowsOf` *(:2000, function)*
- `Routes.SetRow` *(:2018, function)*
- `Routes.RowIncomplete` *(:2078, function)*
- `Routes.SetChildBoss` *(:2085, function)*
- `Routes.BossOf` *(:2096, function)*
- `Routes.ArmsWith` *(:2120, function)*
- `Routes.SetChildRole` *(:2131, function)*
- `Routes.SetChildStage` *(:2149, function)*
- `Routes.SetChildIfUnseen` *(:2161, function)*
- `Routes.ChildIfUnseen` *(:2175, function)*
- `Routes.SetChildIcon` *(:2191, function)*
- `Routes.IconOf` *(:2202, function)*
- `Routes.SetChildShape` *(:2204, function)*
- `setReach` *(:2250, local)*
- `Routes.SetChildReach` *(:2263, function)*
- `Routes.SetBeaconReach` *(:2267, function)*
- `Routes.ReachOf` *(:2329, function)*
- `Routes.SetChildAction` *(:2366, function)*
- `Routes.RoleMatches` *(:2464, function)*
- `Routes.ChildrenWithRole` *(:2472, function)*
- `Routes.SetOutcome` *(:2508, function)*
- `Routes.OutcomeOf` *(:2538, function)*
- `Routes.SetStage` *(:2572, function)*
- `Routes.StageMatches` *(:2588, function)*
- `Routes.Gaps` *(:2602, function)*
- `Routes.Outcome` *(:2626, function)*
- `Routes.StageOrder` *(:2654, function)*
- `Routes.BeaconAt` *(:2683, function)*
- `noteKey` *(:2726, local)*
- `Routes.NoteAnchorOf` *(:2743, function)*
- `routeNotes` *(:2750, local)*
- `Routes.SetRouteNote` *(:2757, function)*
- `Routes.RouteNoteOf` *(:2768, function)*
- `Routes.NotePlane` *(:2791, function)*
- `Routes.GetNotes` *(:2801, function)*
- `Routes.AddNote` *(:2806, function)*
- `Routes.NoteCount` *(:2817, function)*
- `Routes.Create` *(:2821, function)*
- `Routes.Place` *(:2821, function)*
- `Routes.SetChildOrdinal` *(:2821, function)*
- `Routes.StepR` *(:2821, function)*
- `Routes.AcceptanceOf` *(:2821, function)*
- `notes` *(:2821, local)*

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

- `gui` *(:44, local)*
- `refresh` *(:50, local)*
- `toggleArm` *(:74, local)*
- `Widget.Mount` *(:99, function)*
- `Widget.Restrip` *(:119, function)*
- `Widget.Mode` *(:137, function)*
- `Widget.CurrentMode` *(:158, function)*
- `Widget.Init` *(:160, function)*
- `Widget.Pin` *(:346, function)*
- `Widget.Toggle` *(:354, function)*
