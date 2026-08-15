# COA_PetGrid — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_3 file(s) · 27 function(s) · **2 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `ba4d4c9390aa`._

## `core.lua`  —  **OnUpdate ×2** (2 persistent) · events: ADDON_LOADED

- `saveTopAnchor` *(:61, local)*
- `pinTopLeft` *(:68, local)*
- `applyChrome` *(:93, local)*
- `newRow` *(:112, local)*
- `acquireRow` *(:147, local)*
- `releaseRows` *(:154, local)*
- `newHeader` *(:168, local)*
- `acquireHeader` *(:190, local)*
- `releaseHeaders` *(:201, local)*
- `NS.layout` *(:213, function)*
- `place` *(:218, local)*
- `NS.writeRows` *(:247, function)*
- `NS.SetMode` *(:286, function)*

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
