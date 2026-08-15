# COA_Landmarks — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_7 file(s) · 71 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `c91b0da49264`._

## `beacon.lua`  —  **OnUpdate ×1** (0 persistent) · hooks: SelectQuestLogEntry

**pulls:** `GetCurrentPlayerPosition`, `GetTime`
**pushes:** `C_SuperTrack.GetSuperTrackedPosition`, `C_SuperTrack.GetTargetState`, `SuperTrackerUtil.ClearSuperTrackedPosition`, `SuperTrackerUtil.SetSuperTrackedPosition`

- `Beacon.PinnedId` *(:94, function)*
- `Beacon.Clear` *(:128, function)*
- `Beacon.CannotGuide` *(:138, function)*
- `arrivalConditionMet` *(:162, local)*
- `poll` *(:188, local)*
- `onUpdate` *(:230, function)*
- `Beacon.Init` *(:240, function)*
- `Beacon.OwnsSlot` *(:265, function)*
- `Beacon.Pin` *(:265, function)*

## `core.lua`  —  events: ADDON_LOADED, PLAYER_ENTERING_WORLD

**pulls:** `GetAddOnMetadata`

- `NS.Print` *(:27, function)*
- `lockedComplaint` *(:34, local)*
- `NS.CaptureHere` *(:45, function)*

## `editor.lua`

**pulls:** `UnitName`
**pushes:** `StaticPopup_Show`

- `label` *(:25, local)*
- `line` *(:36, local)*
- `tryComplete` *(:70, local)*
- `Editor:Build` *(:89, function)*
- `accept` *(:199, local)*
- `info.func` *(:251, assigned)*
- `info.func` *(:251, assigned)*
- `doTransfer` *(:284, local)*
- `Editor:RefreshGhost` *(:333, function)*
- `Editor:RefreshTransfer` *(:338, function)*
- `info.func` *(:353, assigned)*
- `Editor:RefreshOwner` *(:363, function)*
- `Editor:RefreshTiers` *(:371, function)*
- `Editor:Open` *(:378, function)*
- `Editor:Close` *(:403, function)*
- `splitAtCursor` *(:412, local)*

## `minimap.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `AtlasInfo`

- `place` *(:21, local)*
- `Minimap_:Init` *(:27, function)*

## `pins.lua`  —  events: WORLD_MAP_UPDATE · hookscript: OnShow

**pulls:** `AtlasInfo`, `GetCurrentMapContinent`, `GetCurrentMapZone`

- `showNote` *(:53, local)*
- `onClick` *(:85, local)*
- `acquire` *(:104, local)*
- `Pins:Refresh` *(:121, function)*
- `Pins:Init` *(:154, function)*
- `setIcon` *(:169, local)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.TierYards` *(:49, function)*
- `Store.TierLabel` *(:56, function)*
- `Store.Load` *(:69, function)*
- `db` *(:91, local)*
- `Store.GetUI` *(:101, function)*
- `Store.SetUI` *(:111, function)*
- `composeAlias` *(:131, local)*
- `Store.Create` *(:169, function)*
- `Store.Backfill` *(:200, function)*
- `Store.Get` *(:226, function)*
- `visibleToMe` *(:245, local)*
- `Store.IsMine` *(:252, function)*
- `Store.Visible` *(:257, function)*
- `Store.ForMap` *(:268, function)*
- `Store.Count` *(:276, function)*
- `Store.SplitTags` *(:285, function)*
- `Store.KnownTags` *(:303, function)*
- `Store.SuggestTags` *(:320, function)*
- `Store.KnownOwners` *(:338, function)*
- `Store.TransferOwner` *(:358, function)*
- `Store.Set` *(:378, function)*
- `Store.SetOwner` *(:392, function)*
- `Store.Delete` *(:398, function)*
- `composeId` *(:406, local)*
- `mapFraction` *(:406, local)*

## `widget.lua`

**pulls:** `GetRealZoneText`, `GetSubZoneText`
**pushes:** `SetMapByID`, `ShowUIPanel`

- `btn` *(:21, local)*
- `Widget:Init` *(:30, function)*
- `Widget:BeginRename` *(:129, function)*
- `Widget:Hold` *(:139, function)*
- `Widget:Held` *(:144, function)*
- `zoneLine` *(:148, local)*
- `Widget:Refresh` *(:155, function)*
- `Widget:Show` *(:174, function)*
- `Widget:Hide` *(:179, function)*
- `Widget:Toggle` *(:186, function)*
