# COA_DevDump — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_19 file(s) · 67 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `c91b0da49264`._

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
- `D.Begin` *(:304, function)*

## `payload_macros.lua`

**pulls:** `GetTime`, `UnitClass`, `UnitName`

- `ask` *(:41, local)*
- `askPair` *(:49, local)*
- `askTarget` *(:65, local)*
- `contextStamp` *(:80, local)*
- `try` *(:82, local)*
- `controlRow` *(:158, local)*
- `run` *(:271, local)*

## `payload_tooltipids.lua`


## `task_api.lua`

**pulls:** `GetAddOnMetadata`, `GetCVar`, `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetLocale`, `GetMapInfo`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetRealmName`, `GetSubZoneText`, `GetTime`, `UnitClass`, `UnitIsGhost`, `UnitName`

- `newBox` *(:84, local)*
- `boxReadsBack` *(:105, local)*
- `verdictOf` *(:371, local)*
- `behaviours` *(:382, local)*
- `describe` *(:453, local)*
- `opaque` *(:498, local)*
- `matrix` *(:520, local)*
- `summarise` *(:554, local)*
- `finish` *(:626, local)*

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
- `structuralFingerprint` *(:237, local)*
- `noop` *(:318, local)*

## `task_census.lua`

- `kindOf` *(:13, local)*

## `task_cleu.lua`  —  **OnUpdate ×1** (0 persistent) · events: COMBAT_LOG_EVENT_UNFILTERED, PLAYER_REGEN_DISABLED

**pulls:** `GetTime`

- `onMasked` *(:84, local)*
- `applyArm` *(:95, local)*
- `openSegment` *(:145, local)*
- `onUpdate` *(:162, local)*
- `onEvent` *(:195, local)*
- `calibrateTimer` *(:207, local)*
- `onCount` *(:363, local)*
- `closeSegment` *(:363, local)*

## `task_cvarlog.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCVar`, `GetTime`

- `readAll` *(:26, local)*
- `copyShallow` *(:35, local)*
- `mancerBackups` *(:42, local)*

## `task_dump.lua`

- `scalar` *(:40, local)*
- `keyFor` *(:51, local)*
- `serialise` *(:57, local)*
- `collect` *(:122, local)*

## `task_frames.lua`


## `task_macros.lua`


## `task_perf.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCVar`, `GetTime`


## `task_petlog.lua`  —  **OnUpdate ×1** (0 persistent) · events: COMBAT_LOG_EVENT_UNFILTERED

**pulls:** `GetTime`

- `bandOk` *(:33, local)*
- `petFlags` *(:45, local)*
- `readCleu` *(:49, local)*
- `onCleu` *(:58, local)*
- `snapshotTick` *(:109, local)*

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

- `try` *(:22, local)*

## `task_talents.lua`

**pulls:** `UnitClass`

- `shallow` *(:22, local)*

## `task_tooltip.lua`

- `renderLines` *(:16, local)*
