# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_8 file(s) · 171 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `6843ab89e33c`._

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
- `viewMapID` *(:239, local)*
- `stillLoaded` *(:250, local)*
- `Map.RunsFor` *(:316, function)*
- `Map.ArtFor` *(:336, function)*
- `Map.PointsOn` *(:356, function)*
- `Map.ClampWindow` *(:409, function)*
- `Map.SkipStep` *(:421, function)*
- `Map.Envelope` *(:425, function)*
- `Map.Window` *(:427, function)*
- `Map.Peeking` *(:428, function)*
- `repaintIfShown` *(:429, local)*
- `Map.ResetTime` *(:435, function)*
- `Map.Span` *(:446, function)*
- `Map.SetEnvelope` *(:448, function)*
- `Map.FloorAt` *(:471, function)*
- `Map.SeparateHandles` *(:490, function)*
- `Map.ResetView` *(:503, function)*
- `Map.TrackingFloor` *(:509, function)*
- `Map.SetTrackFloor` *(:511, function)*
- `Map.SetWindow` *(:517, function)*
- `Map.SetPeek` *(:535, function)*
- `Map.InWindow` *(:543, function)*
- `Map.VisibleOn` *(:568, function)*
- `Map.Painted` *(:582, function)*
- `Map.LayerShown` *(:600, function)*
- `Map.SetLayerShown` *(:602, function)*
- `Map.Layers` *(:608, function)*
- `Map.Hidden` *(:625, function)*
- `Map.SetHidden` *(:628, function)*
- `Map.ArtKey` *(:640, function)*
- `Map.Rank` *(:664, function)*
- `Map.ArtForPoint` *(:668, function)*
- `Map.ClearOnSelect` *(:698, function)*
- `fireSelect` *(:700, local)*
- `Map.Selected` *(:704, function)*
- `Map.Select` *(:706, function)*
- `Map.Describe` *(:719, function)*
- `add` *(:729, local)*
- `Map.FillTooltip` *(:774, function)*
- `Map.Offset` *(:789, function)*
- `Map.TilePath` *(:795, function)*
- `Map.TileRect` *(:816, function)*
- `byName` *(:849, local)*
- `Map.SeedFloor` *(:862, function)*
- `Map.Caption` *(:884, function)*
- `ensureDots` *(:907, local)*
- `styleDot` *(:934, local)*
- `clearDots` *(:947, local)*
- `paint` *(:953, function)*
- `context` *(:1001, local)*
- `Map.LoadedId` *(:1009, function)*
- `Map.ShownArt` *(:1014, function)*
- `Map.Load` *(:1021, function)*
- `Map.Show` *(:1084, function)*
- `Map.Toggle` *(:1088, function)*
- `step` *(:1097, local)*
- `Map.Floor` *(:1106, function)*
- `Map.Init` *(:1119, function)*
- `Map.MapIDOf` *(:1196, function)*
- `Map.TimeSpan` *(:1196, function)*
- `Map.AddOnSelect` *(:1196, function)*
- `Map.RunList` *(:1196, function)*

## `promoter.lua`

**pulls:** `GetCurrentPlayerPosition`
**pushes:** `StaticPopup_Show`

- `isPromoted` *(:62, local)*
- `selectedNode` *(:64, local)*
- `rawSelected` *(:71, local)*
- `hereMapID` *(:73, local)*
- `refresh` *(:81, local)*
- `initDropdown` *(:151, local)*
- `info.func` *(:156, assigned)*
- `none.func` *(:167, assigned)*
- `b.func` *(:193, assigned)*
- `installPopups` *(:199, local)*
- `mintRoute` *(:225, local)*
- `mintBeacon` *(:240, local)*
- `mintNote` *(:256, local)*
- `Promoter.Init` *(:268, function)*
- `Promoter.Toggle` *(:395, function)*
- `Promoter.IsShown` *(:400, function)*

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
