# COA_DevDump — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_27 file(s) · 147 function(s) · **0 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `616577dd7d01`._

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


## `range_walk.lua`

- `clamp` *(:26, local)*
- `W.Clamp` *(:40, function)*
- `W.SkipStep` *(:49, function)*
- `W.Select` *(:55, function)*
- `W.Apply` *(:67, function)*
- `W.Run` *(:90, function)*

## `route_chain.lua`


## `sheet_decl.lua`


## `task_api.lua`

**pulls:** `GetAddOnMetadata`, `GetCVar`, `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetLocale`, `GetMapInfo`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetRealmName`, `GetSubZoneText`, `GetTime`, `UnitClass`, `UnitIsGhost`, `UnitName`

- `newBox` *(:94, local)*
- `boxReadsBack` *(:115, local)*
- `verdictOf` *(:381, local)*
- `behaviours` *(:392, local)*
- `describe` *(:463, local)*
- `opaque` *(:514, local)*
- `matrix` *(:536, local)*
- `summarise` *(:570, local)*
- `finish` *(:642, local)*

## `task_callwitness.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetAddOnMetadata`, `GetCVar`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`

- `makeTimer` *(:86, local)*
- `wrapCount` *(:96, local)*
- `wrapVoid` *(:103, local)*
- `resolvePath` *(:122, local)*
- `addTarget` *(:132, local)*
- `Self:ContextTick` *(:147, function)*
- `Self:FlushBuckets` *(:163, function)*
- `snapshotEnv` *(:196, local)*
- `structuralFingerprint` *(:242, local)*
- `noop` *(:323, local)*

## `task_census.lua`

- `kindOf` *(:13, local)*

## `task_chain.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCurrentPlayerPosition`, `GetTime`
**pushes:** `C_SuperTrack.GetSuperTrackedPosition`, `C_SuperTrack.GetTargetState`, `SuperTrackerUtil.ClearSuperTrackedPosition`, `SuperTrackerUtil.SetSuperTrackedPosition`

- `try` *(:40, local)*
- `pos` *(:47, local)*
- `dist3` *(:51, local)*
- `readings` *(:60, local)*
- `event` *(:74, local)*
- `setBeacon` *(:84, local)*
- `clearBeacon` *(:103, local)*
- `advance` *(:113, local)*
- `buildPanel` *(:126, local)*

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


## `task_geom.lua`

**pulls:** `GetCVar`

- `specimens` *(:59, local)*
- `rectOf` *(:99, local)*
- `attach` *(:153, local)*

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

## `task_sheet.lua`  —  **OnUpdate ×2** (0 persistent) · hookscript: OnTextChanged · timers: C_Timer.After

**pulls:** `GetCVar`

- `buildSheet` *(:29, local)*
- `place` *(:48, local)*
- `sheet.SetPage` *(:148, function)*
- `buildCollapseBoard` *(:257, local)*
- `redraw` *(:276, local)*
- `buildRegistration` *(:339, local)*
- `buildRangeBoard` *(:404, local)*
- `x` *(:445, local)*
- `makeHandle` *(:449, local)*
- `drag` *(:459, local)*
- `btn` *(:503, local)*
- `clock` *(:516, local)*
- `armAt` *(:619, local)*
- `seat` *(:628, local)*
- `witness` *(:644, local)*
- `rawChild` *(:654, local)*
- `snap` *(:665, local)*
- `w.SetLabel` *(:728, assigned)*
- `w.SetLabel` *(:728, assigned)*
- `w.SetText` *(:729, assigned)*
- `w.SetText` *(:729, assigned)*
- `w.SetDisabled` *(:730, assigned)*
- `w.SetDisabled` *(:730, assigned)*
- `w.OnAcquire` *(:794, assigned)*
- `widget.OnAcquire` *(:909, assigned)*
- `widget.OnRelease` *(:916, assigned)*
- `widget.Dirty` *(:920, assigned)*
- `widget.IsDirty` *(:921, assigned)*
- `buildScrollBoard` *(:972, local)*
- `makeColumn` *(:1083, local)*
- `refresh` *(:1122, local)*
- `stepper` *(:1146, local)*
- `buildTabBoard` *(:1170, local)*
- `buildBoard` *(:1280, local)*
- `rowPitch` *(:1294, local)*
- `label` *(:1304, local)*
- `buildOne` *(:1327, local)*
- `swatchRow` *(:1439, local)*
- `runSheet` *(:1456, local)*
- `measureStrip` *(:1759, local)*
- `rowsOf` *(:1880, local)*
- `isOpen` *(:1959, local)*
- `measureState` *(:1965, local)*
- `unionRegions` *(:2190, local)*
- `measureArt` *(:2223, local)*
- `check` *(:2310, local)*
- `finish` *(:2438, local)*
- `near` *(:2741, local)*
- `buildHostBoard` *(:2857, local)*
- `buildGutterProto` *(:2857, local)*

## `task_spec.lua`

- `try` *(:22, local)*

## `task_talents.lua`

**pulls:** `UnitClass`

- `shallow` *(:22, local)*

## `task_timers.lua`  —  **OnUpdate ×1** (0 persistent) · timers: C_Timer.After

**pulls:** `GetTime`

- `total` *(:84, local)*
- `record` *(:91, local)*
- `onUpdate` *(:106, local)*
- `bounce` *(:129, local)*

## `task_tooltip.lua`

- `renderLines` *(:18, local)*

## `task_unitstate.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetMapInfo`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`, `UnitClass`

- `try` *(:60, local)*
- `raw` *(:77, local)*
- `profile` *(:85, local)*
- `arguments` *(:174, local)*
- `add` *(:177, local)*
- `mark` *(:254, local)*
- `buildPanel` *(:274, local)*
- `truthy` *(:467, local)*
