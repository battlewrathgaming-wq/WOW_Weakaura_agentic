# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_6 file(s) · 112 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `2f9581a55811`._

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: INSTANCE_ENCOUNTER_ENGAGE_UNIT, PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `GetMapInfo`, `UnitIsGhost`, `UnitName`

- `recapAttackers` *(:66, local)*
- `engagedBosses` *(:105, local)*
- `inInstance` *(:117, local)*
- `onUpdate` *(:156, function)*
- `Capture.Stop` *(:207, function)*
- `Capture.RunId` *(:222, function)*
- `Capture.Pulls` *(:224, function)*
- `onCombatStart` *(:228, local)*
- `onCombatEnd` *(:237, local)*
- `onPlayerDead` *(:254, local)*
- `onEncounterEngage` *(:261, local)*
- `captureOrigin` *(:275, function)*
- `onEnteringWorld` *(:334, local)*
- `Capture.Init` *(:338, function)*
- `Capture.Arm` *(:363, function)*

## `core.lua`  —  events: ADDON_LOADED

- `NS.Say` *(:4, function)*
- `status` *(:8, local)*
- `list` *(:23, local)*
- `slash` *(:36, local)*

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

- `Map.ArtSize` *(:124, function)*
- `Map.TileGrid` *(:126, function)*
- `Map.RunsFor` *(:179, function)*
- `Map.ArtFor` *(:199, function)*
- `Map.PointsOn` *(:215, function)*
- `Map.ClampWindow` *(:267, function)*
- `Map.SkipStep` *(:279, function)*
- `Map.Envelope` *(:283, function)*
- `Map.Window` *(:285, function)*
- `Map.Peeking` *(:286, function)*
- `repaintIfShown` *(:287, local)*
- `Map.ResetTime` *(:293, function)*
- `Map.Span` *(:304, function)*
- `Map.SetEnvelope` *(:306, function)*
- `Map.SetWindow` *(:315, function)*
- `Map.SetPeek` *(:326, function)*
- `Map.InWindow` *(:334, function)*
- `Map.VisibleOn` *(:354, function)*
- `Map.Hidden` *(:374, function)*
- `Map.SetHidden` *(:377, function)*
- `Map.ArtKey` *(:389, function)*
- `Map.Rank` *(:403, function)*
- `Map.ArtForPoint` *(:407, function)*
- `Map.SetOnSelect` *(:424, function)*
- `Map.Selected` *(:427, function)*
- `Map.Select` *(:428, function)*
- `Map.Describe` *(:438, function)*
- `add` *(:448, local)*
- `Map.FillTooltip` *(:491, function)*
- `Map.Offset` *(:506, function)*
- `Map.TilePath` *(:512, function)*
- `Map.TileRect` *(:533, function)*
- `byName` *(:566, local)*
- `Map.SeedFloor` *(:579, function)*
- `Map.Caption` *(:601, function)*
- `ensureDots` *(:616, local)*
- `styleDot` *(:643, local)*
- `clearDots` *(:656, local)*
- `paint` *(:662, function)*
- `context` *(:708, local)*
- `Map.LoadedId` *(:714, function)*
- `Map.ShownArt` *(:719, function)*
- `Map.Show` *(:726, function)*
- `Map.Toggle` *(:753, function)*
- `step` *(:759, local)*
- `Map.Init` *(:775, function)*
- `Map.MapIDOf` *(:852, function)*
- `Map.TimeSpan` *(:852, function)*
- `Map.RunList` *(:852, function)*

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
- `Store.Counts` *(:313, function)*
- `Store.GetUI` *(:325, function)*
- `Store.SetUI` *(:334, function)*
- `Store.AddMarker` *(:338, function)*
- `mapFraction` *(:338, local)*
- `composeId` *(:338, local)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:39, local)*
- `Widget.Init` *(:54, function)*
- `Widget.Toggle` *(:117, function)*
