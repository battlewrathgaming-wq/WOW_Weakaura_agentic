# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_8 file(s) · 169 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `4d668e740ac4`._

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `GetMapInfo`, `UnitIsGhost`, `UnitName`

- `recapAttackers` *(:66, local)*
- `engagedBosses` *(:113, local)*
- `inInstance` *(:125, local)*
- `onUpdate` *(:164, function)*
- `Capture.Stop` *(:215, function)*
- `Capture.RunId` *(:230, function)*
- `Capture.Pulls` *(:232, function)*
- `Capture.Pin` *(:260, function)*
- `onCombatStart` *(:270, local)*
- `onCombatEnd` *(:279, local)*
- `onPlayerDead` *(:296, local)*
- `onEncounterEngage` *(:303, local)*
- `captureOrigin` *(:317, function)*
- `onEnteringWorld` *(:376, local)*
- `Capture.Init` *(:380, function)*
- `Capture.Arm` *(:405, function)*

## `core.lua`  —  events: ADDON_LOADED

- `NS.Say` *(:4, function)*
- `status` *(:8, local)*
- `list` *(:24, local)*
- `slash` *(:37, local)*

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

## `map.lua`

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ArtSize` *(:169, function)*
- `Map.TileGrid` *(:171, function)*
- `layerDef` *(:210, local)*
- `resolve` *(:220, local)*
- `currentRun` *(:234, local)*
- `stillLoaded` *(:240, local)*
- `Map.RunsFor` *(:306, function)*
- `Map.ArtFor` *(:326, function)*
- `Map.PointsOn` *(:346, function)*
- `Map.ClampWindow` *(:399, function)*
- `Map.SkipStep` *(:411, function)*
- `Map.Envelope` *(:415, function)*
- `Map.Window` *(:417, function)*
- `Map.Peeking` *(:418, function)*
- `repaintIfShown` *(:419, local)*
- `Map.ResetTime` *(:425, function)*
- `Map.Span` *(:436, function)*
- `Map.SetEnvelope` *(:438, function)*
- `Map.FloorAt` *(:461, function)*
- `Map.SeparateHandles` *(:480, function)*
- `Map.ResetView` *(:493, function)*
- `Map.TrackingFloor` *(:499, function)*
- `Map.SetTrackFloor` *(:501, function)*
- `Map.SetWindow` *(:507, function)*
- `Map.SetPeek` *(:525, function)*
- `Map.InWindow` *(:533, function)*
- `Map.VisibleOn` *(:558, function)*
- `Map.Painted` *(:572, function)*
- `Map.LayerShown` *(:590, function)*
- `Map.SetLayerShown` *(:592, function)*
- `Map.Layers` *(:598, function)*
- `Map.Hidden` *(:615, function)*
- `Map.SetHidden` *(:618, function)*
- `Map.ArtKey` *(:630, function)*
- `Map.Rank` *(:654, function)*
- `Map.ArtForPoint` *(:658, function)*
- `Map.ClearOnSelect` *(:688, function)*
- `fireSelect` *(:690, local)*
- `Map.Selected` *(:694, function)*
- `Map.Select` *(:696, function)*
- `Map.Describe` *(:709, function)*
- `add` *(:719, local)*
- `Map.FillTooltip` *(:764, function)*
- `Map.Offset` *(:779, function)*
- `Map.TilePath` *(:785, function)*
- `Map.TileRect` *(:806, function)*
- `byName` *(:839, local)*
- `Map.SeedFloor` *(:852, function)*
- `Map.Caption` *(:874, function)*
- `ensureDots` *(:897, local)*
- `styleDot` *(:924, local)*
- `clearDots` *(:937, local)*
- `paint` *(:943, function)*
- `context` *(:991, local)*
- `Map.LoadedId` *(:999, function)*
- `Map.ShownArt` *(:1004, function)*
- `Map.Load` *(:1011, function)*
- `Map.Show` *(:1065, function)*
- `Map.Toggle` *(:1069, function)*
- `step` *(:1078, local)*
- `Map.Floor` *(:1087, function)*
- `Map.Init` *(:1100, function)*
- `Map.MapIDOf` *(:1177, function)*
- `Map.TimeSpan` *(:1177, function)*
- `Map.AddOnSelect` *(:1177, function)*
- `Map.RunList` *(:1177, function)*

## `promoter.lua`

**pulls:** `GetCurrentPlayerPosition`
**pushes:** `StaticPopup_Show`

- `isPromoted` *(:62, local)*
- `selectedNode` *(:64, local)*
- `rawSelected` *(:71, local)*
- `hereMapID` *(:73, local)*
- `refresh` *(:81, local)*
- `initDropdown` *(:136, local)*
- `info.func` *(:141, assigned)*
- `none.func` *(:152, assigned)*
- `b.func` *(:178, assigned)*
- `installPopups` *(:184, local)*
- `mintBeacon` *(:207, local)*
- `mintNote` *(:232, local)*
- `Promoter.Init` *(:244, function)*
- `Promoter.Toggle` *(:369, function)*
- `Promoter.IsShown` *(:374, function)*

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
- `Routes.List` *(:133, function)*
- `byName` *(:142, local)*
- `Routes.AddBeacon` *(:163, function)*
- `Routes.DeleteBeacon` *(:175, function)*
- `Routes.Count` *(:186, function)*
- `notes` *(:203, local)*
- `Routes.NotePlane` *(:205, function)*
- `Routes.GetNotes` *(:215, function)*
- `Routes.AddNote` *(:220, function)*
- `Routes.NoteCount` *(:231, function)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.Load` *(:47, function)*
- `db` *(:68, local)*
- `Store.Point` *(:113, function)*
- `Store.Open` *(:144, function)*
- `Store.Get` *(:163, function)*
- `Store.Close` *(:168, function)*
- `Store.Rename` *(:182, function)*
- `Store.SetComment` *(:194, function)*
- `Store.Delete` *(:203, function)*
- `Store.Ids` *(:208, function)*
- `Store.AddLeg` *(:249, function)*
- `Store.SetOutside` *(:258, function)*
- `Store.SetArrival` *(:264, function)*
- `Store.SetInstance` *(:277, function)*
- `Store.SetMapArt` *(:286, function)*
- `Store.AddBoss` *(:301, function)*
- `Store.RouteTable` *(:339, function)*
- `Store.NoteTable` *(:347, function)*
- `Store.NextRouteId` *(:357, function)*
- `Store.GetUI` *(:365, function)*
- `Store.SetUI` *(:374, function)*
- `Store.AddMarker` *(:378, function)*
- `Store.Counts` *(:378, function)*
- `mapFraction` *(:378, local)*
- `composeId` *(:378, local)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:46, local)*
- `Widget.Init` *(:61, function)*
- `Widget.Pin` *(:142, function)*
- `Widget.Toggle` *(:150, function)*
