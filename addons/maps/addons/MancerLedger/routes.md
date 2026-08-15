# MancerLedger — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_3 file(s) · 68 function(s) · **3 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `c91b0da49264`._

## `core.lua`  —  **OnUpdate ×1** (1 persistent) · events: ADDON_LOADED, PLAYER_ENTERING_WORLD, PLAYER_REGEN_ENABLED

**pulls:** `GetAddOnMetadata`

- `pushHistory` *(:53, local)*
- `chat` *(:61, local)*
- `say` *(:68, local)*
- `sayOnce` *(:73, local)*
- `consumerVersion` *(:83, local)*
- `driverDb` *(:92, local)*
- `driverVersion` *(:96, local)*
- `fingerprint` *(:107, local)*
- `captureState` *(:117, local)*
- `stateLine` *(:136, local)*
- `getProfile` *(:144, local)*
- `activeProfile` *(:148, local)*
- `validFight` *(:160, local)*
- `foldFight` *(:174, local)*
- `rebuildSeen` *(:238, local)*
- `markSeen` *(:242, local)*
- `harvest` *(:257, local)*
- `fmtN` *(:314, local)*
- `prettyId` *(:321, local)*
- `missPct` *(:328, local)*
- `missBreakdown` *(:333, local)*
- `cadence` *(:348, local)*
- `statsFor` *(:355, local)*
- `compare` *(:396, local)*
- `cadS` *(:411, local)*
- `sumS` *(:415, local)*
- `timeS` *(:418, local)*
- `profileNew` *(:464, local)*
- `profileUse` *(:479, local)*
- `profileDelete` *(:487, local)*
- `profileResetLog` *(:495, local)*
- `profileOff` *(:503, local)*
- `profileRename` *(:511, local)*
- `NS.GetDb` *(:529, assigned)*
- `NS.locked` *(:539, assigned)*
- `HandleSlash` *(:561, function)*

## `minimap.lua`  —  **OnUpdate ×3** (2 persistent)

- `stateColor` *(:42, local)*
- `paint` *(:50, local)*
- `NS.onFold` *(:67, assigned)*
- `place` *(:76, local)*
- `dragTick` *(:84, local)*
- `popEntry` *(:123, local)*
- `hidePopout` *(:140, local)*
- `showPopout` *(:144, local)*

## `ui.lua`

- `cells` *(:35, local)*
- `dInt` *(:51, local)*
- `fmtCells` *(:100, local)*
- `fmtDelta` *(:106, local)*
- `divider` *(:150, local)*
- `sortedProfileNames` *(:166, local)*
- `makeDropdown` *(:179, local)*
- `info.func` *(:189, assigned)*
- `makeButton` *(:219, local)*
- `applyColLayout` *(:295, local)*
- `acquireContentRow` *(:312, local)*
- `releaseContentRows` *(:343, local)*
- `writeRow` *(:351, local)*
- `writeWideRow` *(:368, local)*
- `placeRow` *(:379, local)*
- `headerTexts` *(:383, local)*
- `renderStats` *(:389, local)*
- `renderCompare` *(:426, local)*
- `renderHistory` *(:492, local)*
- `repaintToken` *(:598, local)*
- `NS.ui.Show` *(:669, function)*
- `NS.ui.Toggle` *(:683, function)*
- `NS.ui.RefreshIfShown` *(:687, function)*
- `NS.ui.SelectProfile` *(:691, function)*
