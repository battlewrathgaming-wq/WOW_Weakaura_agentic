# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_6 file(s) · 114 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `bda1c4afc22b`._

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `GetMapInfo`, `UnitIsGhost`, `UnitName`

- `recapAttackers` *(:66, local)*
- `engagedBosses` *(:105, local)*
- `inInstance` *(:117, local)*
- `onUpdate` *(:156, function)*
- `Capture.Stop` *(:207, function)*
- `Capture.RunId` *(:222, function)*
- `Capture.Pulls` *(:224, function)*
- `Capture.Pin` *(:252, function)*
- `onCombatStart` *(:262, local)*
- `onCombatEnd` *(:271, local)*
- `onPlayerDead` *(:288, local)*
- `onEncounterEngage` *(:295, local)*
- `captureOrigin` *(:309, function)*
- `onEnteringWorld` *(:368, local)*
- `Capture.Init` *(:372, function)*
- `Capture.Arm` *(:397, function)*

## `core.lua`  —  events: ADDON_LOADED

- `NS.Say` *(:4, function)*
- `status` *(:8, local)*
- `list` *(:24, local)*
- `slash` *(:37, local)*

## `editor.lua`  —  **OnUpdate ×2** (0 persistent)

**pulls:** `GetCurrentPlayerPosition`
**pushes:** `StaticPopup_Show`

- `clock` *(:64, local)*
- `toPx` *(:71, local)*
- `toSec` *(:76, local)*
- `refresh` *(:92, local)*
- `initDropdown` *(:163, local)*
- `info.func` *(:171, assigned)*
- `b.func` *(:195, assigned)*
- `installPopups` *(:205, local)*
- `Editor.Init` *(:236, function)*
- `handle` *(:366, local)*
- `drag` *(:380, local)*
- `widthBtn` *(:401, local)*
- `stepBtn` *(:417, local)*
- `Editor.SyncPeek` *(:494, function)*
- `tick` *(:508, local)*
- `Editor.StopPlay` *(:520, function)*
- `Editor.TogglePlay` *(:527, function)*
- `Editor.Toggle` *(:535, function)*

## `map.lua`

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ArtSize` *(:137, function)*
- `Map.TileGrid` *(:139, function)*
- `Map.RunsFor` *(:192, function)*
- `Map.ArtFor` *(:212, function)*
- `Map.PointsOn` *(:228, function)*
- `Map.ClampWindow` *(:280, function)*
- `Map.SkipStep` *(:292, function)*
- `Map.Envelope` *(:296, function)*
- `Map.Window` *(:298, function)*
- `Map.Peeking` *(:299, function)*
- `repaintIfShown` *(:300, local)*
- `Map.ResetTime` *(:306, function)*
- `Map.Span` *(:317, function)*
- `Map.SetEnvelope` *(:319, function)*
- `Map.SetWindow` *(:328, function)*
- `Map.SetPeek` *(:339, function)*
- `Map.InWindow` *(:347, function)*
- `Map.VisibleOn` *(:367, function)*
- `Map.Hidden` *(:387, function)*
- `Map.SetHidden` *(:390, function)*
- `Map.ArtKey` *(:402, function)*
- `Map.Rank` *(:417, function)*
- `Map.ArtForPoint` *(:421, function)*
- `Map.SetOnSelect` *(:438, function)*
- `Map.Selected` *(:441, function)*
- `Map.Select` *(:442, function)*
- `Map.Describe` *(:452, function)*
- `add` *(:462, local)*
- `Map.FillTooltip` *(:507, function)*
- `Map.Offset` *(:522, function)*
- `Map.TilePath` *(:528, function)*
- `Map.TileRect` *(:549, function)*
- `byName` *(:582, local)*
- `Map.SeedFloor` *(:595, function)*
- `Map.Caption` *(:617, function)*
- `ensureDots` *(:632, local)*
- `styleDot` *(:659, local)*
- `clearDots` *(:672, local)*
- `paint` *(:678, function)*
- `context` *(:724, local)*
- `Map.LoadedId` *(:730, function)*
- `Map.ShownArt` *(:735, function)*
- `Map.Show` *(:742, function)*
- `Map.Toggle` *(:769, function)*
- `step` *(:775, local)*
- `Map.Init` *(:791, function)*
- `Map.MapIDOf` *(:868, function)*
- `Map.TimeSpan` *(:868, function)*
- `Map.RunList` *(:868, function)*

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
- `Store.GetUI` *(:328, function)*
- `Store.SetUI` *(:337, function)*
- `Store.AddMarker` *(:341, function)*
- `Store.Counts` *(:341, function)*
- `mapFraction` *(:341, local)*
- `composeId` *(:341, local)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:46, local)*
- `Widget.Init` *(:61, function)*
- `Widget.Pin` *(:142, function)*
- `Widget.Toggle` *(:150, function)*
