# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_10 file(s) · 215 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `ec49c223d850`._

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

## `map.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ArtSize` *(:184, function)*
- `Map.TileGrid` *(:186, function)*
- `layerDef` *(:232, local)*
- `resolve` *(:242, local)*
- `currentRun` *(:256, local)*
- `authoringMapID` *(:287, local)*
- `Map.AuthoringMapID` *(:294, function)*
- `stillLoaded` *(:300, local)*
- `Map.RunsFor` *(:366, function)*
- `Map.ArtFor` *(:386, function)*
- `Map.PointsOn` *(:406, function)*
- `Map.ClampWindow` *(:459, function)*
- `Map.SkipStep` *(:471, function)*
- `Map.Envelope` *(:475, function)*
- `Map.Window` *(:477, function)*
- `Map.Peeking` *(:478, function)*
- `repaintIfShown` *(:479, local)*
- `Map.ResetTime` *(:485, function)*
- `Map.Span` *(:496, function)*
- `Map.SetEnvelope` *(:498, function)*
- `Map.FloorAt` *(:521, function)*
- `Map.SeparateHandles` *(:540, function)*
- `Map.ResetView` *(:553, function)*
- `Map.TrackingFloor` *(:559, function)*
- `Map.SetTrackFloor` *(:561, function)*
- `Map.SetWindow` *(:567, function)*
- `Map.SetPeek` *(:585, function)*
- `Map.InWindow` *(:593, function)*
- `Map.VisibleOn` *(:618, function)*
- `Map.Painted` *(:632, function)*
- `Map.LayerShown` *(:650, function)*
- `Map.SetLayerShown` *(:652, function)*
- `Map.Layers` *(:658, function)*
- `Map.Hidden` *(:675, function)*
- `Map.SetHidden` *(:678, function)*
- `Map.ArtKey` *(:690, function)*
- `Map.Rank` *(:714, function)*
- `Map.ArtForPoint` *(:718, function)*
- `Map.SetMoveArmed` *(:755, function)*
- `Map.MoveArmed` *(:762, function)*
- `Map.AddOnEdit` *(:768, function)*
- `Map.ClearOnEdit` *(:773, function)*
- `Map.OpenEditor` *(:775, function)*
- `Map.AddOnSelect` *(:782, function)*
- `Map.ClearOnSelect` *(:790, function)*
- `fireSelect` *(:792, local)*
- `Map.Selected` *(:796, function)*
- `Map.Select` *(:798, function)*
- `Map.Describe` *(:815, function)*
- `add` *(:827, local)*
- `Map.ArtKeys` *(:879, function)*
- `Map.KeyFacts` *(:888, function)*
- `Map.FillTooltip` *(:896, function)*
- `Map.Offset` *(:920, function)*
- `Map.FractionAt` *(:940, function)*
- `Map.Draggable` *(:954, function)*
- `Map.TilePath` *(:975, function)*
- `Map.TileRect` *(:998, function)*
- `byName` *(:1031, local)*
- `Map.SeedFloor` *(:1044, function)*
- `Map.Caption` *(:1066, function)*
- `ensureDots` *(:1089, local)*
- `styleDot` *(:1127, local)*
- `clearDots` *(:1140, local)*
- `paint` *(:1146, function)*
- `context` *(:1202, local)*
- `Map.LoadedId` *(:1210, function)*
- `Map.ReadoutAnchor` *(:1243, function)*
- `fillReadout` *(:1256, function)*
- `Map.Readout` *(:1287, function)*
- `Map.ShownArt` *(:1302, function)*
- `Map.Load` *(:1309, function)*
- `Map.Show` *(:1394, function)*
- `dragTo` *(:1427, local)*
- `Map.BeginDrag` *(:1438, function)*
- `Map.EndDrag` *(:1466, function)*
- `Map.Dragging` *(:1492, function)*
- `Map.Toggle` *(:1494, function)*
- `step` *(:1503, local)*
- `Map.Repaint` *(:1515, function)*
- `Map.Floor` *(:1519, function)*
- `Map.Init` *(:1532, function)*
- `Map.MapIDOf` *(:1640, function)*
- `Map.TimeSpan` *(:1640, function)*
- `Map.RunList` *(:1640, function)*

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
