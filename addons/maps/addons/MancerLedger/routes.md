# MancerLedger — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_3 file(s) · 68 function(s) · **3 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `974d4e7876de`._

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
- `validFight` *(:163, local)*
- `foldFight` *(:177, local)*
- `rebuildSeen` *(:241, local)*
- `markSeen` *(:245, local)*
- `harvest` *(:260, local)*
- `fmtN` *(:317, local)*
- `prettyId` *(:324, local)*
- `missPct` *(:331, local)*
- `missBreakdown` *(:336, local)*
- `cadence` *(:351, local)*
- `statsFor` *(:358, local)*
- `compare` *(:402, local)*
- `cadS` *(:417, local)*
- `sumS` *(:421, local)*
- `timeS` *(:424, local)*
- `profileNew` *(:470, local)*
- `profileUse` *(:485, local)*
- `profileDelete` *(:493, local)*
- `profileResetLog` *(:501, local)*
- `profileOff` *(:509, local)*
- `profileRename` *(:517, local)*
- `NS.GetDb` *(:535, assigned)*
- `NS.locked` *(:545, assigned)*
- `HandleSlash` *(:567, function)*

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
