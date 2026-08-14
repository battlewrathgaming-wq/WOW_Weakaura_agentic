# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_8 file(s) · 171 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `118ccc9fd353`._

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
- `authoringMapID` *(:250, local)*
- `Map.AuthoringMapID` *(:260, function)*
- `stillLoaded` *(:266, local)*
- `Map.RunsFor` *(:332, function)*
- `Map.ArtFor` *(:352, function)*
- `Map.PointsOn` *(:372, function)*
- `Map.ClampWindow` *(:425, function)*
- `Map.SkipStep` *(:437, function)*
- `Map.Envelope` *(:441, function)*
- `Map.Window` *(:443, function)*
- `Map.Peeking` *(:444, function)*
- `repaintIfShown` *(:445, local)*
- `Map.ResetTime` *(:451, function)*
- `Map.Span` *(:462, function)*
- `Map.SetEnvelope` *(:464, function)*
- `Map.FloorAt` *(:487, function)*
- `Map.SeparateHandles` *(:506, function)*
- `Map.ResetView` *(:519, function)*
- `Map.TrackingFloor` *(:525, function)*
- `Map.SetTrackFloor` *(:527, function)*
- `Map.SetWindow` *(:533, function)*
- `Map.SetPeek` *(:551, function)*
- `Map.InWindow` *(:559, function)*
- `Map.VisibleOn` *(:584, function)*
- `Map.Painted` *(:598, function)*
- `Map.LayerShown` *(:616, function)*
- `Map.SetLayerShown` *(:618, function)*
- `Map.Layers` *(:624, function)*
- `Map.Hidden` *(:641, function)*
- `Map.SetHidden` *(:644, function)*
- `Map.ArtKey` *(:656, function)*
- `Map.Rank` *(:680, function)*
- `Map.ArtForPoint` *(:684, function)*
- `Map.ClearOnSelect` *(:714, function)*
- `fireSelect` *(:716, local)*
- `Map.Selected` *(:720, function)*
- `Map.Select` *(:722, function)*
- `Map.Describe` *(:735, function)*
- `add` *(:745, local)*
- `Map.FillTooltip` *(:790, function)*
- `Map.Offset` *(:805, function)*
- `Map.TilePath` *(:811, function)*
- `Map.TileRect` *(:832, function)*
- `byName` *(:865, local)*
- `Map.SeedFloor` *(:878, function)*
- `Map.Caption` *(:900, function)*
- `ensureDots` *(:923, local)*
- `styleDot` *(:950, local)*
- `clearDots` *(:963, local)*
- `paint` *(:969, function)*
- `context` *(:1017, local)*
- `Map.LoadedId` *(:1025, function)*
- `Map.ShownArt` *(:1030, function)*
- `Map.Load` *(:1037, function)*
- `Map.Show` *(:1118, function)*
- `Map.Toggle` *(:1122, function)*
- `step` *(:1131, local)*
- `Map.Floor` *(:1140, function)*
- `Map.Init` *(:1153, function)*
- `Map.MapIDOf` *(:1230, function)*
- `Map.TimeSpan` *(:1230, function)*
- `Map.AddOnSelect` *(:1230, function)*
- `Map.RunList` *(:1230, function)*

## `promoter.lua`

**pushes:** `StaticPopup_Show`

- `isPromoted` *(:62, local)*
- `selectedNode` *(:64, local)*
- `rawSelected` *(:71, local)*
- `authoringMapID` *(:77, local)*
- `refresh` *(:82, local)*
- `initDropdown` *(:157, local)*
- `info.func` *(:162, assigned)*
- `none.func` *(:173, assigned)*
- `b.func` *(:194, assigned)*
- `installPopups` *(:200, local)*
- `mintRoute` *(:226, local)*
- `mintBeacon` *(:241, local)*
- `mintNote` *(:257, local)*
- `Promoter.Init` *(:269, function)*
- `Promoter.Toggle` *(:396, function)*
- `Promoter.IsShown` *(:401, function)*

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
- `Routes.DeleteBeacon` *(:185, function)*
- `Routes.Count` *(:196, function)*
- `notes` *(:213, local)*
- `Routes.NotePlane` *(:215, function)*
- `Routes.GetNotes` *(:225, function)*
- `Routes.AddNote` *(:230, function)*
- `Routes.NoteCount` *(:241, function)*

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
