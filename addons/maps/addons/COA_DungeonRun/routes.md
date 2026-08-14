# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_8 file(s) · 171 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `5a7445714b5f`._

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
- `authoringMapID` *(:265, local)*
- `Map.AuthoringMapID` *(:272, function)*
- `stillLoaded` *(:278, local)*
- `Map.RunsFor` *(:344, function)*
- `Map.ArtFor` *(:364, function)*
- `Map.PointsOn` *(:384, function)*
- `Map.ClampWindow` *(:437, function)*
- `Map.SkipStep` *(:449, function)*
- `Map.Envelope` *(:453, function)*
- `Map.Window` *(:455, function)*
- `Map.Peeking` *(:456, function)*
- `repaintIfShown` *(:457, local)*
- `Map.ResetTime` *(:463, function)*
- `Map.Span` *(:474, function)*
- `Map.SetEnvelope` *(:476, function)*
- `Map.FloorAt` *(:499, function)*
- `Map.SeparateHandles` *(:518, function)*
- `Map.ResetView` *(:531, function)*
- `Map.TrackingFloor` *(:537, function)*
- `Map.SetTrackFloor` *(:539, function)*
- `Map.SetWindow` *(:545, function)*
- `Map.SetPeek` *(:563, function)*
- `Map.InWindow` *(:571, function)*
- `Map.VisibleOn` *(:596, function)*
- `Map.Painted` *(:610, function)*
- `Map.LayerShown` *(:628, function)*
- `Map.SetLayerShown` *(:630, function)*
- `Map.Layers` *(:636, function)*
- `Map.Hidden` *(:653, function)*
- `Map.SetHidden` *(:656, function)*
- `Map.ArtKey` *(:668, function)*
- `Map.Rank` *(:692, function)*
- `Map.ArtForPoint` *(:696, function)*
- `Map.ClearOnSelect` *(:726, function)*
- `fireSelect` *(:728, local)*
- `Map.Selected` *(:732, function)*
- `Map.Select` *(:734, function)*
- `Map.Describe` *(:747, function)*
- `add` *(:757, local)*
- `Map.FillTooltip` *(:802, function)*
- `Map.Offset` *(:817, function)*
- `Map.TilePath` *(:823, function)*
- `Map.TileRect` *(:844, function)*
- `byName` *(:877, local)*
- `Map.SeedFloor` *(:890, function)*
- `Map.Caption` *(:912, function)*
- `ensureDots` *(:935, local)*
- `styleDot` *(:962, local)*
- `clearDots` *(:975, local)*
- `paint` *(:981, function)*
- `context` *(:1029, local)*
- `Map.LoadedId` *(:1037, function)*
- `Map.ShownArt` *(:1042, function)*
- `Map.Load` *(:1049, function)*
- `Map.Show` *(:1130, function)*
- `Map.Toggle` *(:1134, function)*
- `step` *(:1143, local)*
- `Map.Floor` *(:1152, function)*
- `Map.Init` *(:1165, function)*
- `Map.MapIDOf` *(:1242, function)*
- `Map.TimeSpan` *(:1242, function)*
- `Map.AddOnSelect` *(:1242, function)*
- `Map.RunList` *(:1242, function)*

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
