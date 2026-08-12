# COA_DungeonRun — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_4 file(s) · 35 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `705ec1406486`._

## `capture.lua`  —  **OnUpdate ×1** (0 persistent) · events: PLAYER_ENTERING_WORLD, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, ZONE_CHANGED_NEW_AREA

**pulls:** `UnitIsGhost`

- `inInstance` *(:48, local)*
- `onUpdate` *(:71, function)*
- `Capture.Stop` *(:115, function)*
- `Capture.RunId` *(:126, function)*
- `Capture.Pulls` *(:128, function)*
- `onCombatStart` *(:132, local)*
- `onCombatEnd` *(:141, local)*
- `onEnteringWorld` *(:151, local)*
- `Capture.Init` *(:157, function)*
- `Capture.Arm` *(:176, function)*

## `core.lua`  —  events: ADDON_LOADED

- `NS.Say` *(:4, function)*
- `status` *(:8, local)*
- `list` *(:23, local)*
- `slash` *(:36, local)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.Load` *(:45, function)*
- `db` *(:66, local)*
- `Store.Point` *(:95, function)*
- `Store.Open` *(:122, function)*
- `Store.Get` *(:141, function)*
- `Store.Close` *(:146, function)*
- `Store.Delete` *(:152, function)*
- `Store.Ids` *(:157, function)*
- `Store.AddMarker` *(:171, function)*
- `Store.AddLeg` *(:185, function)*
- `Store.SetOutside` *(:193, function)*
- `Store.SetArrival` *(:199, function)*
- `Store.Counts` *(:208, function)*
- `Store.GetUI` *(:220, function)*
- `Store.SetUI` *(:229, function)*
- `mapFraction` *(:233, local)*
- `composeId` *(:233, local)*

## `widget.lua`

- `refresh` *(:21, local)*
- `toggleArm` *(:39, local)*
- `Widget.Init` *(:54, function)*
- `Widget.Toggle` *(:110, function)*
