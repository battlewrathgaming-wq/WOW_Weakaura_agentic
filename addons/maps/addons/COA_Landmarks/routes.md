# COA_Landmarks — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_7 file(s) · 71 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `8ba4d85c0bf9`._

## `beacon.lua`  —  **OnUpdate ×1** (0 persistent) · hooks: SelectQuestLogEntry

**pulls:** `GetCurrentPlayerPosition`, `GetTime`
**pushes:** `C_SuperTrack.GetSuperTrackedPosition`, `C_SuperTrack.GetTargetState`, `SuperTrackerUtil.ClearSuperTrackedPosition`, `SuperTrackerUtil.SetSuperTrackedPosition`

- `Beacon.PinnedId` *(:94, function)*
- `Beacon.Clear` *(:131, function)*
- `Beacon.CannotGuide` *(:141, function)*
- `arrivalConditionMet` *(:165, local)*
- `poll` *(:191, local)*
- `onUpdate` *(:233, function)*
- `Beacon.Init` *(:243, function)*
- `Beacon.OwnsSlot` *(:270, function)*
- `Beacon.Pin` *(:270, function)*

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
- `visibleToMe` *(:249, local)*
- `Store.IsMine` *(:256, function)*
- `Store.Visible` *(:261, function)*
- `Store.ForMap` *(:272, function)*
- `Store.Count` *(:280, function)*
- `Store.SplitTags` *(:289, function)*
- `Store.KnownTags` *(:307, function)*
- `Store.SuggestTags` *(:324, function)*
- `Store.KnownOwners` *(:342, function)*
- `Store.TransferOwner` *(:362, function)*
- `Store.Set` *(:382, function)*
- `Store.SetOwner` *(:396, function)*
- `Store.Delete` *(:402, function)*
- `composeId` *(:410, local)*
- `mapFraction` *(:410, local)*

## `widget.lua`

**pulls:** `GetRealZoneText`, `GetSubZoneText`
**pushes:** `SetMapByID`, `ShowUIPanel`

- `btn` *(:21, local)*
- `Widget:Init` *(:30, function)*
- `Widget:BeginRename` *(:131, function)*
- `Widget:Hold` *(:141, function)*
- `Widget:Held` *(:146, function)*
- `zoneLine` *(:150, local)*
- `Widget:Refresh` *(:157, function)*
- `Widget:Show` *(:176, function)*
- `Widget:Hide` *(:181, function)*
- `Widget:Toggle` *(:188, function)*
