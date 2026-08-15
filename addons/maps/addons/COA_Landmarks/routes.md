# COA_Landmarks — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_7 file(s) · 71 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `d66faf986c46`._

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

- `NS.Print` *(:22, function)*
- `lockedComplaint` *(:29, local)*
- `NS.CaptureHere` *(:40, function)*

## `editor.lua`

**pulls:** `UnitName`
**pushes:** `StaticPopup_Show`

- `label` *(:25, local)*
- `line` *(:36, local)*
- `tryComplete` *(:67, local)*
- `Editor:Build` *(:86, function)*
- `accept` *(:196, local)*
- `info.func` *(:246, assigned)*
- `info.func` *(:246, assigned)*
- `doTransfer` *(:279, local)*
- `Editor:RefreshGhost` *(:328, function)*
- `Editor:RefreshTransfer` *(:333, function)*
- `info.func` *(:348, assigned)*
- `Editor:RefreshOwner` *(:358, function)*
- `Editor:RefreshTiers` *(:366, function)*
- `Editor:Open` *(:373, function)*
- `Editor:Close` *(:398, function)*
- `splitAtCursor` *(:407, local)*

## `minimap.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `AtlasInfo`

- `place` *(:18, local)*
- `Minimap_:Init` *(:24, function)*

## `pins.lua`  —  events: WORLD_MAP_UPDATE · hookscript: OnShow

**pulls:** `AtlasInfo`, `GetCurrentMapContinent`, `GetCurrentMapZone`

- `showNote` *(:50, local)*
- `onClick` *(:79, local)*
- `acquire` *(:98, local)*
- `Pins:Refresh` *(:115, function)*
- `Pins:Init` *(:148, function)*
- `setIcon` *(:161, local)*

## `store.lua`

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `UnitName`
**pushes:** `SetMapToCurrentZone`

- `Store.TierYards` *(:47, function)*
- `Store.TierLabel` *(:54, function)*
- `Store.Load` *(:67, function)*
- `db` *(:89, local)*
- `Store.GetUI` *(:99, function)*
- `Store.SetUI` *(:109, function)*
- `composeAlias` *(:129, local)*
- `Store.Create` *(:167, function)*
- `Store.Backfill` *(:198, function)*
- `Store.Get` *(:224, function)*
- `visibleToMe` *(:243, local)*
- `Store.IsMine` *(:250, function)*
- `Store.Visible` *(:255, function)*
- `Store.ForMap` *(:266, function)*
- `Store.Count` *(:274, function)*
- `Store.SplitTags` *(:283, function)*
- `Store.KnownTags` *(:301, function)*
- `Store.SuggestTags` *(:318, function)*
- `Store.KnownOwners` *(:336, function)*
- `Store.TransferOwner` *(:356, function)*
- `Store.Set` *(:376, function)*
- `Store.SetOwner` *(:390, function)*
- `Store.Delete` *(:396, function)*
- `composeId` *(:404, local)*
- `mapFraction` *(:404, local)*

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
