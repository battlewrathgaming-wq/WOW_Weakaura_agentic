# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_11 file(s) · 258 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `858e857b3edb`._

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
- `Map.ZoomAnchor` *(:227, function)*
- `Map.PanClamp` *(:236, function)*
- `layerDef` *(:284, local)*
- `resolve` *(:294, local)*
- `currentRun` *(:308, local)*
- `authoringMapID` *(:339, local)*
- `Map.AuthoringMapID` *(:346, function)*
- `stillLoaded` *(:352, local)*
- `Map.RunsFor` *(:418, function)*
- `Map.ArtFor` *(:438, function)*
- `Map.PointsOn` *(:458, function)*
- `Map.ClampWindow` *(:511, function)*
- `Map.SkipStep` *(:523, function)*
- `Map.Envelope` *(:527, function)*
- `Map.Window` *(:529, function)*
- `Map.Peeking` *(:530, function)*
- `repaintIfShown` *(:531, local)*
- `Map.ResetTime` *(:537, function)*
- `Map.Span` *(:548, function)*
- `Map.SetEnvelope` *(:550, function)*
- `Map.FloorAt` *(:573, function)*
- `Map.SeparateHandles` *(:592, function)*
- `Map.ResetView` *(:605, function)*
- `Map.TrackingFloor` *(:611, function)*
- `Map.SetTrackFloor` *(:613, function)*
- `Map.SetWindow` *(:619, function)*
- `Map.SetPeek` *(:637, function)*
- `Map.InWindow` *(:645, function)*
- `Map.VisibleOn` *(:670, function)*
- `Map.Painted` *(:684, function)*
- `Map.LayerShown` *(:702, function)*
- `Map.SetLayerShown` *(:704, function)*
- `Map.Layers` *(:710, function)*
- `Map.Hidden` *(:727, function)*
- `Map.SetHidden` *(:730, function)*
- `Map.ArtKey` *(:742, function)*
- `Map.Rank` *(:766, function)*
- `Map.ArtForPoint` *(:770, function)*
- `Map.SetMoveArmed` *(:807, function)*
- `Map.MoveArmed` *(:814, function)*
- `Map.AddOnEdit` *(:820, function)*
- `Map.ClearOnEdit` *(:825, function)*
- `Map.OpenEditor` *(:827, function)*
- `Map.AddOnSelect` *(:834, function)*
- `Map.ClearOnSelect` *(:842, function)*
- `fireSelect` *(:844, local)*
- `Map.Selected` *(:848, function)*
- `Map.Select` *(:850, function)*
- `Map.Describe` *(:867, function)*
- `add` *(:879, local)*
- `Map.ArtKeys` *(:931, function)*
- `Map.KeyFacts` *(:940, function)*
- `Map.FillTooltip` *(:948, function)*
- `Map.Offset` *(:972, function)*
- `Map.FractionAt` *(:992, function)*
- `Map.Draggable` *(:1006, function)*
- `Map.TilePath` *(:1027, function)*
- `Map.TileRect` *(:1050, function)*
- `byName` *(:1083, local)*
- `Map.SeedFloor` *(:1096, function)*
- `Map.Caption` *(:1118, function)*
- `ensureDots` *(:1141, local)*
- `styleDot` *(:1179, local)*
- `clearDots` *(:1192, local)*
- `paint` *(:1198, function)*
- `context` *(:1254, local)*
- `Map.LoadedId` *(:1262, function)*
- `Map.ReadoutAnchor` *(:1295, function)*
- `fillReadout` *(:1308, function)*
- `Map.Readout` *(:1342, function)*
- `Map.ShownArt` *(:1357, function)*
- `Map.Load` *(:1364, function)*
- `Map.Show` *(:1449, function)*
- `dragTo` *(:1482, local)*
- `Map.BeginDrag` *(:1493, function)*
- `Map.EndDrag` *(:1521, function)*
- `Map.Dragging` *(:1547, function)*
- `refreshControls` *(:1564, local)*
- `buildControls` *(:1571, function)*
- `btn` *(:1597, local)*
- `Map.ToggleControls` *(:1647, function)*
- `Map.ControlsShown` *(:1653, function)*
- `Map.Toggle` *(:1655, function)*
- `step` *(:1664, local)*
- `applyView` *(:1690, local)*
- `Map.Zoom` *(:1701, function)*
- `Map.Pan` *(:1703, function)*
- `Map.SetZoom` *(:1704, function)*
- `Map.StepZoom` *(:1718, function)*
- `Map.ZoomStep` *(:1723, function)*
- `Map.CycleZoomStep` *(:1725, function)*
- `Map.ResetZoom` *(:1732, function)*
- `Map.PanStep` *(:1740, function)*
- `Map.Recenter` *(:1747, function)*
- `Map.WheelZoom` *(:1763, function)*
- `Map.RightPan` *(:1765, function)*
- `Map.SetWheelZoom` *(:1766, function)*
- `Map.SetRightPan` *(:1772, function)*
- `Map.SetPan` *(:1781, function)*
- `panTo` *(:1791, local)*
- `Map.BeginPan` *(:1797, function)*
- `Map.EndPan` *(:1805, function)*
- `Map.Panning` *(:1812, function)*
- `Map.Repaint` *(:1814, function)*
- `Map.Floor` *(:1818, function)*
- `Map.Init` *(:1831, function)*
- `Map.MapIDOf` *(:1975, function)*
- `Map.TimeSpan` *(:1975, function)*
- `Map.RunList` *(:1975, function)*

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
