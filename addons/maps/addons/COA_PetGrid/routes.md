# COA_PetGrid — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_3 file(s) · 27 function(s) · **2 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `2af42707fc0f`._

## `core.lua`  —  **OnUpdate ×2** (2 persistent) · events: ADDON_LOADED

- `saveTopAnchor` *(:61, local)*
- `pinTopLeft` *(:71, local)*
- `applyChrome` *(:98, local)*
- `newRow` *(:117, local)*
- `acquireRow` *(:152, local)*
- `releaseRows` *(:159, local)*
- `newHeader` *(:173, local)*
- `acquireHeader` *(:195, local)*
- `releaseHeaders` *(:206, local)*
- `NS.layout` *(:218, function)*
- `place` *(:223, local)*
- `NS.writeRows` *(:252, function)*
- `NS.SetMode` *(:291, function)*

## `feed_demo.lua`

- `tickDemo` *(:19, local)*

## `feed_live.lua`  —  events: COMBAT_LOG_EVENT_UNFILTERED, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED

**pulls:** `GetTime`

- `newAcc` *(:65, local)*
- `newRec` *(:70, local)*
- `close` *(:94, local)*
- `bump` *(:112, local)*
- `missField` *(:118, local)*
- `onCleu` *(:124, local)*
- `sweepBuffs` *(:179, local)*
- `scanPlates` *(:190, local)*
- `reconcile` *(:210, local)*
- `fmtPct` *(:251, local)*
- `fmtDmg` *(:256, local)*
- `rates` *(:262, local)*
- `buildRows` *(:272, local)*
