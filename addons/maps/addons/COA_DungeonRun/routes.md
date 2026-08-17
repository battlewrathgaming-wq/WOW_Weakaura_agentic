# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_13 file(s) · 349 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `d2f11f836cbf`._

## `calibrate.lua`

- `Calibrate.Init` *(:57, function)*
- `Calibrate.Clear` *(:63, function)*
- `spread` *(:121, local)*
- `Calibrate.Fit` *(:144, function)*
- `Calibrate.Apply` *(:179, function)*
- `Calibrate.For` *(:238, function)*
- `Calibrate.Floor` *(:249, function)*
- `Calibrate.ToWorld` *(:264, function)*
- `Calibrate.Report` *(:271, function)*
- `solve3` *(:286, local)*
- `build` *(:286, local)*

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`, `UnitIsGhost`, `UnitName`
**pushes:** `C_SuperTrack.GetSuperTrackedPosition`, `C_SuperTrack.GetTargetState`, `SetMapToCurrentZone`, `SuperTrackerUtil.ClearSuperTrackedPosition`, `SuperTrackerUtil.SetSuperTrackedPosition`

- `Capture.PendingPin` *(:85, function)*
- `dumpTrackedGlobal` *(:105, local)*
- `trackerProbe` *(:122, local)*
- `recapAttackers` *(:189, local)*
- `engagedBosses` *(:238, local)*
- `inInstance` *(:250, local)*
- `onUpdate` *(:326, function)*
- `Capture.Stop` *(:417, function)*
- `Capture.RunId` *(:442, function)*
- `Capture.TestPin` *(:451, function)*
- `Capture.ClearTestPin` *(:470, function)*
- `Capture.Profile` *(:475, function)*
- `Capture.SampleEvery` *(:477, function)*
- `Capture.Pulls` *(:478, function)*
- `Capture.Pin` *(:506, function)*
- `onCombatStart` *(:516, local)*
- `onCombatEnd` *(:525, local)*
- `onPlayerDead` *(:547, local)*
- `onEncounterEngage` *(:554, local)*
- `captureOrigin` *(:568, function)*
- `onEnteringWorld` *(:642, local)*
- `Capture.Init` *(:646, function)*
- `captureMapArt` *(:671, function)*
- `Capture.Arm` *(:671, function)*

## `core.lua`  —  events: ADDON_LOADED

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `NS.Say` *(:31, function)*
- `status` *(:35, local)*
- `probe` *(:72, local)*
- `list` *(:86, local)*
- `slash` *(:99, local)*

## `editor.lua`  —  **OnUpdate ×2** (0 persistent)

**pulls:** `GetCurrentPlayerPosition`
**pushes:** `StaticPopup_Show`

- `clock` *(:72, local)*
- `toPx` *(:79, local)*
- `toSec` *(:84, local)*
- `refresh` *(:125, local)*
- `initDropdown` *(:206, local)*
- `info.func` *(:214, assigned)*
- `b.func` *(:238, assigned)*
- `installPopups` *(:251, local)*
- `Editor.Init` *(:282, function)*
- `handle` *(:463, local)*
- `drag` *(:481, local)*
- `widthBtn` *(:517, local)*
- `stepBtn` *(:536, local)*
- `Editor.SyncAll` *(:740, function)*
- `Editor.SyncPeek` *(:748, function)*
- `tick` *(:778, local)*
- `Editor.StopPlay` *(:790, function)*
- `Editor.TogglePlay` *(:797, function)*
- `Editor.Toggle` *(:805, function)*

## `layout.lua`

**pulls:** `AtlasInfo`

- `Layout.DROPDOWN_FIELD` *(:116, assigned)*
- `Layout.DROPDOWN_TEXT` *(:118, assigned)*
- `Layout.DROPDOWN_ART` *(:119, assigned)*
- `Layout.SkinDivider` *(:136, function)*
- `Layout.NewZone` *(:157, function)*
- `Layout.AddRow` *(:199, function)*
- `hide` *(:219, local)*
- `show` *(:223, local)*
- `Layout.Apply` *(:233, function)*
- `Layout.Height` *(:285, function)*

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
- `Map.KindKey` *(:897, function)*
- `Map.ArtKey` *(:923, function)*
- `Map.Rank` *(:931, function)*
- `Map.ArtForPoint` *(:935, function)*
- `Map.SetMoveArmed` *(:987, function)*
- `Map.MoveArmed` *(:994, function)*
- `Map.SetPickArmed` *(:1001, function)*
- `Map.PickArmed` *(:1006, function)*
- `Map.ArmedFor` *(:1010, function)*
- `Map.Disarm` *(:1012, function)*
- `Map.AddOnEdit` *(:1018, function)*
- `Map.ClearOnEdit` *(:1023, function)*
- `Map.OpenEditor` *(:1025, function)*
- `Map.AddOnSelect` *(:1032, function)*
- `Map.ClearOnSelect` *(:1040, function)*
- `fireSelect` *(:1042, local)*
- `Map.Selected` *(:1046, function)*
- `Map.ClickSelect` *(:1060, function)*
- `Map.Select` *(:1069, function)*
- `Map.Describe` *(:1088, function)*
- `add` *(:1100, local)*
- `Map.Palette` *(:1171, function)*
- `Map.ArtKeys` *(:1177, function)*
- `Map.KeyFacts` *(:1186, function)*
- `Map.FillTooltip` *(:1194, function)*
- `Map.Offset` *(:1219, function)*
- `Map.FractionAt` *(:1240, function)*
- `Map.Draggable` *(:1260, function)*
- `Map.TilePath` *(:1288, function)*
- `Map.TileRect` *(:1311, function)*
- `byName` *(:1344, local)*
- `Map.SeedFloor` *(:1357, function)*
- `Map.Caption` *(:1379, function)*
- `ensureDots` *(:1402, local)*
- `styleDot` *(:1459, local)*
- `clearDots` *(:1472, local)*
- `paint` *(:1478, function)*
- `context` *(:1541, local)*
- `Map.LoadedId` *(:1549, function)*
- `Map.ReadoutAnchor` *(:1584, function)*
- `fillReadout` *(:1597, function)*
- `Map.Readout` *(:1633, function)*
- `Map.ShownArt` *(:1648, function)*
- `Map.Load` *(:1655, function)*
- `Map.Show` *(:1749, function)*
- `dragTo` *(:1782, local)*
- `Map.BeginDrag` *(:1793, function)*
- `Map.EndDrag` *(:1825, function)*
- `Map.Dragging` *(:1851, function)*
- `refreshControls` *(:1877, local)*
- `buildControls` *(:1886, function)*
- `btn` *(:1912, local)*
- `Map.ToggleControls` *(:1969, function)*
- `Map.ControlsShown` *(:1975, function)*
- `Map.Toggle` *(:1977, function)*
- `step` *(:1986, local)*
- `applyView` *(:2014, local)*
- `Map.Zoom` *(:2029, function)*
- `Map.Pan` *(:2031, function)*
- `Map.SetZoom` *(:2032, function)*
- `Map.StepZoom` *(:2045, function)*
- `Map.NextStage` *(:2055, function)*
- `Map.CycleZoomStage` *(:2064, function)*
- `Map.ZoomStages` *(:2068, function)*
- `Map.ResetZoom` *(:2072, function)*
- `Map.PanStep` *(:2080, function)*
- `Map.Recenter` *(:2087, function)*
- `Map.WheelZoom` *(:2103, function)*
- `Map.RightPan` *(:2105, function)*
- `Map.SetWheelZoom` *(:2106, function)*
- `Map.SetRightPan` *(:2112, function)*
- `Map.SetPan` *(:2121, function)*
- `panTo` *(:2131, local)*
- `Map.BeginPan` *(:2137, function)*
- `Map.EndPan` *(:2145, function)*
- `Map.Panning` *(:2152, function)*
- `Map.Repaint` *(:2154, function)*
- `Map.Floor` *(:2158, function)*
- `Map.Init` *(:2173, function)*
- `Map.MapIDOf` *(:2385, function)*
- `Map.TimeSpan` *(:2385, function)*
- `Map.RunList` *(:2385, function)*

## `object.lua`  —  hookscript: OnClick

**pushes:** `StaticPopup_Show`

- `NS.Tests.Register` *(:88, function)*
- `NS.Tests.Run` *(:95, function)*
- `parentOf` *(:145, local)*
- `subject` *(:150, local)*
- `answersFor` *(:166, local)*
- `nameOf` *(:171, local)*
- `refresh` *(:186, local)*
- `commitName` *(:363, local)*
- `installPopups` *(:370, local)*
- `Object.Init` *(:403, function)*
- `b.func` *(:551, assigned)*
- `b.func` *(:551, assigned)*
- `b.func` *(:551, assigned)*
- `b.func` *(:551, assigned)*
- `numBox` *(:713, local)*
- `none.func` *(:796, assigned)*
- `e.func` *(:822, assigned)*
- `zText` *(:1058, local)*
- `Object.Toggle` *(:1112, function)*
- `Object.IsShown` *(:1117, function)*

## `panespec.lua`

- `only` *(:44, local)*
- `Spec.Build` *(:168, function)*

## `promoter.lua`

**pushes:** `StaticPopup_Show`

- `isPromoted` *(:71, local)*
- `selectedNode` *(:73, local)*
- `rawSelected` *(:80, local)*
- `authoringMapID` *(:86, local)*
- `refresh` *(:91, local)*
- `initDropdown` *(:228, local)*
- `info.func` *(:233, assigned)*
- `none.func` *(:244, assigned)*
- `b.func` *(:265, assigned)*
- `installPopups` *(:271, local)*
- `mintRoute` *(:319, local)*
- `mintBeacon` *(:334, local)*
- `mintNote` *(:355, local)*
- `Promoter.Init` *(:367, function)*
- `Promoter.Toggle` *(:651, function)*
- `Promoter.IsShown` *(:656, function)*

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
- `nextBeaconId` *(:213, local)*
- `Routes.AddBeacon` *(:218, function)*
- `Routes.Unplace` *(:285, function)*
- `Routes.PositionOf` *(:294, function)*
- `Routes.WorldOf` *(:300, function)*
- `Routes.SetName` *(:310, function)*
- `Routes.NameOf` *(:317, function)*
- `Routes.DeleteNote` *(:324, function)*
- `Routes.DeleteBeacon` *(:343, function)*
- `Routes.Count` *(:354, function)*
- `Routes.ChildCount` *(:407, function)*
- `nextChildId` *(:419, local)*
- `mint` *(:426, local)*
- `Routes.AddChildFromNode` *(:439, function)*
- `Routes.AddChildHere` *(:453, function)*
- `Routes.DeleteChild` *(:465, function)*
- `Routes.ParentOf` *(:479, function)*
- `has` *(:575, local)*
- `Routes.SetChildRole` *(:604, function)*
- `Routes.SetChildStage` *(:622, function)*
- `Routes.SetChildIfUnseen` *(:634, function)*
- `Routes.ChildIfUnseen` *(:648, function)*
- `Routes.SetChildIcon` *(:664, function)*
- `Routes.IconOf` *(:675, function)*
- `Routes.SetChildShape` *(:677, function)*
- `Routes.SetChildReach` *(:687, function)*
- `Routes.SetChildAction` *(:719, function)*
- `Routes.GoToTarget` *(:782, function)*
- `Routes.SetChildFireOn` *(:792, function)*
- `Routes.OnRampOf` *(:861, function)*
- `Routes.AcceptanceOf` *(:892, function)*
- `Routes.Heads` *(:911, function)*
- `Routes.BrokenLinks` *(:925, function)*
- `Routes.Cycles` *(:936, function)*
- `Routes.RoleMatches` *(:955, function)*
- `Routes.ChildrenWithRole` *(:963, function)*
- `Routes.SetOutcome` *(:999, function)*
- `Routes.OutcomeOf` *(:1007, function)*
- `Routes.SetStage` *(:1022, function)*
- `Routes.StageMatches` *(:1032, function)*
- `Routes.Gaps` *(:1046, function)*
- `Routes.Outcome` *(:1066, function)*
- `Routes.StageOrder` *(:1075, function)*
- `Routes.BeaconAt` *(:1087, function)*
- `notes` *(:1106, local)*
- `Routes.NotePlane` *(:1108, function)*
- `Routes.GetNotes` *(:1118, function)*
- `Routes.AddNote` *(:1123, function)*
- `Routes.NoteCount` *(:1134, function)*
- `Routes.Place` *(:1138, function)*
- `Routes.ChildrenOf` *(:1138, function)*
- `Routes.SetChildGoTo` *(:1138, function)*
- `Routes.SetChildOnRamp` *(:1138, function)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.Load` *(:51, function)*
- `db` *(:72, local)*
- `Store.SetProbe` *(:140, function)*
- `Store.Probe` *(:142, function)*
- `merge` *(:143, local)*
- `Store.Point` *(:153, function)*
- `Store.Open` *(:184, function)*
- `Store.Get` *(:203, function)*
- `Store.Close` *(:208, function)*
- `Store.Rename` *(:222, function)*
- `Store.SetComment` *(:234, function)*
- `Store.Delete` *(:243, function)*
- `Store.Ids` *(:248, function)*
- `Store.AddLeg` *(:289, function)*
- `Store.SetTestPin` *(:300, function)*
- `Store.SetOutside` *(:307, function)*
- `Store.SetArrival` *(:313, function)*
- `Store.SetInstance` *(:326, function)*
- `Store.SetMapArt` *(:344, function)*
- `Store.AddBoss` *(:360, function)*
- `Store.RouteTable` *(:398, function)*
- `Store.NoteTable` *(:406, function)*
- `Store.NextRouteId` *(:416, function)*
- `Store.GetUI` *(:424, function)*
- `Store.SetUI` *(:433, function)*
- `Store.SetUIRun` *(:450, function)*
- `Store.UIRun` *(:455, function)*
- `Store.AddMarker` *(:458, function)*
- `Store.Counts` *(:458, function)*
- `mapFraction` *(:458, local)*
- `composeId` *(:458, local)*

## `ui.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetTime`

- `UI.Init` *(:64, function)*
- `UI.Register` *(:98, function)*
- `UI.Get` *(:114, function)*
- `UI.Keys` *(:119, function)*
- `UI.Misses` *(:125, function)*
- `UI.BadKinds` *(:127, function)*
- `UI.List` *(:128, function)*
- `UI.Click` *(:147, function)*
- `UI.Set` *(:155, function)*
- `UI.Read` *(:165, function)*
- `UI.PlanClear` *(:193, function)*
- `UI.PlanAdd` *(:198, function)*
- `UI.PlanSize` *(:208, function)*
- `UI.Plan` *(:210, function)*
- `UI.RunId` *(:211, function)*
- `UI.Step` *(:215, function)*
- `UI.RunPlan` *(:271, function)*
- `UI.Tick` *(:286, function)*
- `UI.Finish` *(:303, function)*
- `UI.Running` *(:315, function)*
- `UI.Summary` *(:320, function)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:46, local)*
- `Widget.Init` *(:61, function)*
- `Widget.Pin` *(:208, function)*
- `Widget.Toggle` *(:216, function)*
