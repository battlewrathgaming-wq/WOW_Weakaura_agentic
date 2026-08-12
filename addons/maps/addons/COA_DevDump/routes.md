# COA_DevDump — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_16 file(s) · 46 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._

## `core.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetAddOnMetadata`, `GetRealmName`, `UnitClass`, `UnitName`

- `D.Print` *(:37, function)*
- `trim` *(:42, local)*
- `D.ParseFieldList` *(:47, function)*
- `D.Commit` *(:83, function)*
- `D.RegisterTask` *(:104, function)*
- `D.DescribeWidget` *(:122, function)*
- `walk` *(:139, local)*
- `D.WalkFrameTree` *(:161, function)*
- `D.NewCollector` *(:171, function)*
- `c:Start` *(:180, function)*
- `c:Stop` *(:185, function)*
- `D.Cycle` *(:195, function)*
- `taskNames` *(:219, local)*
- `D.Begin` *(:284, function)*

## `payload_macros.lua`

**pulls:** `GetTime`, `UnitClass`, `UnitName`

- `ask` *(:37, local)*
- `askPair` *(:45, local)*
- `askTarget` *(:61, local)*
- `contextStamp` *(:76, local)*
- `try` *(:78, local)*
- `controlRow` *(:151, local)*
- `run` *(:264, local)*

## `payload_tooltipids.lua`


## `task_callwitness.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetAddOnMetadata`, `GetCVar`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`

- `makeTimer` *(:81, local)*
- `wrapCount` *(:91, local)*
- `wrapVoid` *(:98, local)*
- `resolvePath` *(:117, local)*
- `addTarget` *(:127, local)*
- `Self:ContextTick` *(:142, function)*
- `Self:FlushBuckets` *(:158, function)*
- `snapshotEnv` *(:191, local)*
- `structuralFingerprint` *(:235, local)*
- `noop` *(:316, local)*

## `task_census.lua`

- `kindOf` *(:13, local)*

## `task_cvarlog.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCVar`, `GetTime`

- `readAll` *(:26, local)*
- `copyShallow` *(:35, local)*
- `mancerBackups` *(:42, local)*

## `task_frames.lua`


## `task_macros.lua`


## `task_perf.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCVar`, `GetTime`


## `task_petlog.lua`  —  **OnUpdate ×1** (0 persistent) · events: COMBAT_LOG_EVENT_UNFILTERED

**pulls:** `GetTime`

- `bandOk` *(:31, local)*
- `petFlags` *(:36, local)*
- `readCleu` *(:40, local)*
- `onCleu` *(:49, local)*
- `snapshotTick` *(:100, local)*

## `task_plates.lua`

**pulls:** `UnitName`


## `task_probe.lua`


## `task_satnav.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `C_CVar.GetBool`, `GetCurrentPlayerPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`
**pushes:** `C_SuperTrack.GetSuperTrackedPosition`, `C_SuperTrack.GetTargetState`, `C_SuperTrack.IsSuperTrackingAnything`, `C_SuperTrack.SetSuperTrackedPosition`, `SuperTrackerUtil.ClearSuperTrackedPosition`, `SuperTrackerUtil.HasValidScreenPosition`, `SuperTrackerUtil.SetSuperTrackedPosition`

- `try` *(:33, local)*
- `globalPinState` *(:42, local)*
- `sample` *(:49, local)*

## `task_spec.lua`

- `try` *(:19, local)*

## `task_talents.lua`

**pulls:** `UnitClass`

- `shallow` *(:22, local)*

## `task_tooltip.lua`

- `renderLines` *(:16, local)*
