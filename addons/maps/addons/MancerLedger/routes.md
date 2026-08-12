# MancerLedger — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_3 file(s) · 68 function(s) · **3 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `03fe9999f9ca`._

## `core.lua`  —  **OnUpdate ×1** (1 persistent) · events: ADDON_LOADED, PLAYER_ENTERING_WORLD, PLAYER_REGEN_ENABLED

**pulls:** `GetAddOnMetadata`

- `pushHistory` *(:49, local)*
- `chat` *(:57, local)*
- `say` *(:64, local)*
- `sayOnce` *(:69, local)*
- `consumerVersion` *(:79, local)*
- `driverDb` *(:88, local)*
- `driverVersion` *(:92, local)*
- `fingerprint` *(:103, local)*
- `captureState` *(:113, local)*
- `stateLine` *(:132, local)*
- `getProfile` *(:140, local)*
- `activeProfile` *(:144, local)*
- `validFight` *(:156, local)*
- `foldFight` *(:170, local)*
- `rebuildSeen` *(:234, local)*
- `markSeen` *(:238, local)*
- `harvest` *(:253, local)*
- `fmtN` *(:310, local)*
- `prettyId` *(:317, local)*
- `missPct` *(:324, local)*
- `missBreakdown` *(:329, local)*
- `cadence` *(:344, local)*
- `statsFor` *(:351, local)*
- `compare` *(:392, local)*
- `cadS` *(:407, local)*
- `sumS` *(:411, local)*
- `timeS` *(:414, local)*
- `profileNew` *(:460, local)*
- `profileUse` *(:475, local)*
- `profileDelete` *(:483, local)*
- `profileResetLog` *(:491, local)*
- `profileOff` *(:499, local)*
- `profileRename` *(:507, local)*
- `NS.GetDb` *(:522, assigned)*
- `NS.locked` *(:532, assigned)*
- `HandleSlash` *(:554, function)*

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
