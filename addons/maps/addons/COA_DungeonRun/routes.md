# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_11 file(s) · 244 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `0e57264f3dbd`._

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

- `Driver.Cost` *(:58, function)*
- `here` *(:65, local)*
- `inInstance` *(:70, local)*
- `Driver.Reached` *(:84, function)*
- `beaconAt` *(:100, local)*
- `say` *(:106, local)*
- `report` *(:108, local)*
- `scan` *(:128, local)*
- `Driver.Arm` *(:157, function)*
- `Driver.Stop` *(:177, function)*
- `Driver.Armed` *(:191, function)*
- `Driver.Stage` *(:193, function)*
- `Driver.Route` *(:194, function)*
- `initDropdown` *(:196, local)*
- `b.func` *(:211, assigned)*
- `Driver.Init` *(:215, function)*
- `Driver.Toggle` *(:271, function)*

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
- `Map.ZoomAnchor` *(:217, function)*
- `Map.PanClamp` *(:226, function)*
- `layerDef` *(:274, local)*
- `resolve` *(:284, local)*
- `currentRun` *(:298, local)*
- `authoringMapID` *(:329, local)*
- `Map.AuthoringMapID` *(:336, function)*
- `stillLoaded` *(:342, local)*
- `Map.RunsFor` *(:408, function)*
- `Map.ArtFor` *(:428, function)*
- `Map.PointsOn` *(:448, function)*
- `Map.ClampWindow` *(:501, function)*
- `Map.SkipStep` *(:513, function)*
- `Map.Envelope` *(:517, function)*
- `Map.Window` *(:519, function)*
- `Map.Peeking` *(:520, function)*
- `repaintIfShown` *(:521, local)*
- `Map.ResetTime` *(:527, function)*
- `Map.Span` *(:538, function)*
- `Map.SetEnvelope` *(:540, function)*
- `Map.FloorAt` *(:563, function)*
- `Map.SeparateHandles` *(:582, function)*
- `Map.ResetView` *(:595, function)*
- `Map.TrackingFloor` *(:601, function)*
- `Map.SetTrackFloor` *(:603, function)*
- `Map.SetWindow` *(:609, function)*
- `Map.SetPeek` *(:627, function)*
- `Map.InWindow` *(:635, function)*
- `Map.VisibleOn` *(:660, function)*
- `Map.Painted` *(:674, function)*
- `Map.LayerShown` *(:692, function)*
- `Map.SetLayerShown` *(:694, function)*
- `Map.Layers` *(:700, function)*
- `Map.Hidden` *(:717, function)*
- `Map.SetHidden` *(:720, function)*
- `Map.ArtKey` *(:732, function)*
- `Map.Rank` *(:756, function)*
- `Map.ArtForPoint` *(:760, function)*
- `Map.SetMoveArmed` *(:797, function)*
- `Map.MoveArmed` *(:804, function)*
- `Map.AddOnEdit` *(:810, function)*
- `Map.ClearOnEdit` *(:815, function)*
- `Map.OpenEditor` *(:817, function)*
- `Map.AddOnSelect` *(:824, function)*
- `Map.ClearOnSelect` *(:832, function)*
- `fireSelect` *(:834, local)*
- `Map.Selected` *(:838, function)*
- `Map.Select` *(:840, function)*
- `Map.Describe` *(:857, function)*
- `add` *(:869, local)*
- `Map.ArtKeys` *(:921, function)*
- `Map.KeyFacts` *(:930, function)*
- `Map.FillTooltip` *(:938, function)*
- `Map.Offset` *(:962, function)*
- `Map.FractionAt` *(:982, function)*
- `Map.Draggable` *(:996, function)*
- `Map.TilePath` *(:1017, function)*
- `Map.TileRect` *(:1040, function)*
- `byName` *(:1073, local)*
- `Map.SeedFloor` *(:1086, function)*
- `Map.Caption` *(:1108, function)*
- `ensureDots` *(:1131, local)*
- `styleDot` *(:1169, local)*
- `clearDots` *(:1182, local)*
- `paint` *(:1188, function)*
- `context` *(:1244, local)*
- `Map.LoadedId` *(:1252, function)*
- `Map.ReadoutAnchor` *(:1285, function)*
- `fillReadout` *(:1298, function)*
- `Map.Readout` *(:1332, function)*
- `Map.ShownArt` *(:1347, function)*
- `Map.Load` *(:1354, function)*
- `Map.Show` *(:1439, function)*
- `dragTo` *(:1472, local)*
- `Map.BeginDrag` *(:1483, function)*
- `Map.EndDrag` *(:1511, function)*
- `Map.Dragging` *(:1537, function)*
- `Map.Toggle` *(:1539, function)*
- `step` *(:1548, local)*
- `applyView` *(:1574, local)*
- `Map.Zoom` *(:1585, function)*
- `Map.Pan` *(:1587, function)*
- `Map.SetZoom` *(:1588, function)*
- `Map.StepZoom` *(:1600, function)*
- `Map.SetPan` *(:1604, function)*
- `panTo` *(:1614, local)*
- `Map.BeginPan` *(:1620, function)*
- `Map.EndPan` *(:1628, function)*
- `Map.Panning` *(:1635, function)*
- `Map.Repaint` *(:1637, function)*
- `Map.Floor` *(:1641, function)*
- `Map.Init` *(:1654, function)*
- `Map.MapIDOf` *(:1781, function)*
- `Map.TimeSpan` *(:1781, function)*
- `Map.RunList` *(:1781, function)*

## `object.lua`

**pushes:** `StaticPopup_Show`

- `subject` *(:47, local)*
- `refresh` *(:53, local)*
- `commitName` *(:94, local)*
- `installPopups` *(:101, local)*
- `Object.Init` *(:125, function)*
- `Object.Toggle` *(:217, function)*
- `Object.IsShown` *(:222, function)*

## `promoter.lua`

**pushes:** `StaticPopup_Show`

- `isPromoted` *(:62, local)*
- `selectedNode` *(:64, local)*
- `rawSelected` *(:71, local)*
- `authoringMapID` *(:77, local)*
- `refresh` *(:82, local)*
- `initDropdown` *(:163, local)*
- `info.func` *(:168, assigned)*
- `none.func` *(:179, assigned)*
- `b.func` *(:200, assigned)*
- `installPopups` *(:206, local)*
- `mintRoute` *(:232, local)*
- `mintBeacon` *(:247, local)*
- `mintNote` *(:263, local)*
- `Promoter.Init` *(:275, function)*
- `Promoter.Toggle` *(:401, function)*
- `Promoter.IsShown` *(:406, function)*

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
- `Routes.SetName` *(:264, function)*
- `Routes.NameOf` *(:271, function)*
- `Routes.DeleteNote` *(:278, function)*
- `Routes.DeleteBeacon` *(:286, function)*
- `Routes.Count` *(:297, function)*
- `notes` *(:314, local)*
- `Routes.NotePlane` *(:316, function)*
- `Routes.GetNotes` *(:326, function)*
- `Routes.AddNote` *(:331, function)*
- `Routes.NoteCount` *(:342, function)*
- `Routes.Place` *(:346, function)*

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
