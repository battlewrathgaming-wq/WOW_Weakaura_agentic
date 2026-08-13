# COA_PetGrid — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_3 file(s) · 27 function(s) · **2 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `b2031147db18`._

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

- `newAcc` *(:62, local)*
- `newRec` *(:67, local)*
- `close` *(:91, local)*
- `bump` *(:109, local)*
- `missField` *(:115, local)*
- `onCleu` *(:121, local)*
- `sweepBuffs` *(:176, local)*
- `scanPlates` *(:187, local)*
- `reconcile` *(:207, local)*
- `fmtPct` *(:248, local)*
- `fmtDmg` *(:253, local)*
- `rates` *(:259, local)*
- `buildRows` *(:269, local)*
