# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_6 file(s) · 85 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `8c2f40d82afa`._

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

## `editor.lua`

**pulls:** `GetCurrentPlayerPosition`

- `refresh` *(:69, local)*
- `initDropdown` *(:99, local)*
- `info.func` *(:107, assigned)*
- `b.func` *(:131, assigned)*
- `Editor.Init` *(:135, function)*
- `Editor.Toggle` *(:217, function)*

## `map.lua`

**pulls:** `GetCurrentPlayerPosition`, `GetMapInfo`

- `Map.ArtSize` *(:124, function)*
- `Map.TileGrid` *(:126, function)*
- `Map.RunsFor` *(:167, function)*
- `Map.ArtFor` *(:187, function)*
- `Map.PointsOn` *(:203, function)*
- `Map.VisibleOn` *(:219, function)*
- `Map.Hidden` *(:238, function)*
- `Map.SetHidden` *(:241, function)*
- `Map.ArtKey` *(:253, function)*
- `Map.Rank` *(:267, function)*
- `Map.ArtForPoint` *(:271, function)*
- `Map.SetOnSelect` *(:288, function)*
- `Map.Selected` *(:291, function)*
- `Map.Select` *(:292, function)*
- `Map.Describe` *(:302, function)*
- `add` *(:312, local)*
- `Map.FillTooltip` *(:355, function)*
- `Map.Offset` *(:370, function)*
- `Map.TilePath` *(:376, function)*
- `Map.TileRect` *(:397, function)*
- `byName` *(:430, local)*
- `Map.SeedFloor` *(:443, function)*
- `Map.Caption` *(:465, function)*
- `ensureDots` *(:480, local)*
- `styleDot` *(:507, local)*
- `clearDots` *(:520, local)*
- `paint` *(:526, function)*
- `context` *(:572, local)*
- `Map.LoadedId` *(:578, function)*
- `Map.ShownArt` *(:583, function)*
- `Map.Show` *(:590, function)*
- `Map.Toggle` *(:613, function)*
- `step` *(:619, local)*
- `Map.Init` *(:635, function)*
- `Map.MapIDOf` *(:712, function)*
- `Map.RunList` *(:712, function)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.Load` *(:47, function)*
- `db` *(:68, local)*
- `Store.Point` *(:113, function)*
- `Store.Open` *(:144, function)*
- `Store.Get` *(:163, function)*
- `Store.Close` *(:168, function)*
- `Store.Delete` *(:174, function)*
- `Store.Ids` *(:179, function)*
- `Store.AddLeg` *(:220, function)*
- `Store.SetOutside` *(:229, function)*
- `Store.SetArrival` *(:235, function)*
- `Store.SetInstance` *(:248, function)*
- `Store.SetMapArt` *(:257, function)*
- `Store.AddBoss` *(:272, function)*
- `Store.Counts` *(:284, function)*
- `Store.GetUI` *(:296, function)*
- `Store.SetUI` *(:305, function)*
- `Store.AddMarker` *(:309, function)*
- `mapFraction` *(:309, local)*
- `composeId` *(:309, local)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:39, local)*
- `Widget.Init` *(:54, function)*
- `Widget.Toggle` *(:117, function)*
