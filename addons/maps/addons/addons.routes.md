# Addon census — what OUR addons define, cost, and touch

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

We built `task_callwitness` because someone else's addon had no self-reporting. This is ours. **`frame_cost.md` is the half that matters** — it is the file the Mancer stutter investigation wished existed for the addon it was chasing.

## COA_DevDump
_16 file(s) · 46 function(s) · **6 OnUpdate handler(s)**_

### `core.lua`  —  **OnUpdate ×1** (0 persistent)

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

**pulls:** `GetAddOnMetadata`, `GetRealmName`, `UnitClass`, `UnitName`

### `payload_macros.lua`

- `ask` *(:37, local)*
- `askPair` *(:45, local)*
- `askTarget` *(:61, local)*
- `contextStamp` *(:76, local)*
- `try` *(:78, local)*
- `controlRow` *(:151, local)*
- `run` *(:264, local)*

**pulls:** `GetTime`, `UnitClass`, `UnitName`

### `payload_tooltipids.lua`

### `task_callwitness.lua`  —  **OnUpdate ×1** (0 persistent)

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

**pulls:** `GetAddOnMetadata`, `GetCVar`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`

### `task_census.lua`

- `kindOf` *(:13, local)*

### `task_cvarlog.lua`  —  **OnUpdate ×1** (0 persistent)

- `readAll` *(:26, local)*
- `copyShallow` *(:35, local)*
- `mancerBackups` *(:42, local)*

**pulls:** `GetCVar`, `GetTime`

### `task_frames.lua`

### `task_macros.lua`

### `task_perf.lua`  —  **OnUpdate ×1** (0 persistent)

**pulls:** `GetCVar`, `GetTime`

### `task_petlog.lua`  —  **OnUpdate ×1** (0 persistent) · events: COMBAT_LOG_EVENT_UNFILTERED

- `bandOk` *(:31, local)*
- `petFlags` *(:36, local)*
- `readCleu` *(:40, local)*
- `onCleu` *(:49, local)*
- `snapshotTick` *(:100, local)*

**pulls:** `GetTime`

### `task_plates.lua`

**pulls:** `UnitName`

### `task_probe.lua`

### `task_satnav.lua`  —  **OnUpdate ×1** (0 persistent)

- `try` *(:33, local)*
- `globalPinState` *(:42, local)*
- `sample` *(:49, local)*

**pulls:** `C_CVar.GetBool`, `GetCurrentPlayerPosition`, `GetRealZoneText`, `GetSubZoneText`, `GetTime`

**pushes:** `C_SuperTrack.GetSuperTrackedPosition`, `C_SuperTrack.GetTargetState`, `C_SuperTrack.IsSuperTrackingAnything`, `C_SuperTrack.SetSuperTrackedPosition`, `SuperTrackerUtil.ClearSuperTrackedPosition`, `SuperTrackerUtil.HasValidScreenPosition`, `SuperTrackerUtil.SetSuperTrackedPosition`

### `task_spec.lua`

- `try` *(:19, local)*

### `task_talents.lua`

- `shallow` *(:22, local)*

**pulls:** `UnitClass`

### `task_tooltip.lua`

- `renderLines` *(:16, local)*

## COA_GuardianPlates
_4 file(s) · 140 function(s) · **2 OnUpdate handler(s)**_

### `AggroPlates.lua`

- `GetConfig` *(:33, local)*
- `Color` *(:44, local)*
- `CurrentPalette` *(:69, local)*
- `Apply` *(:77, local)*
- `ApplyAll` *(:101, local)*
- `ClearAll` *(:110, local)*
- `Aggro.OnUnitAdded` *(:127, function)*
- `Aggro.OnUnitRemoved` *(:132, function)*
- `Aggro.OnReclassify` *(:138, function)*
- `Aggro.HandleCommand` *(:173, function)*

### `Core.lua`  —  **OnUpdate ×1** (1 persistent) · events: GROUP_ROSTER_UPDATE, NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED, PLAYER_ENTERING_WORLD, PLAYER_ROLES_ASSIGNED, ROLE_CHANGED_INFORM, UNIT_HEALTH, UNIT_MAXHEALTH, UNIT_THREAT_LIST_UPDATE, UNIT_THREAT_SITUATION_UPDATE · hooks: frame, texture · timers: C_Timer.After

- `Print` *(:106, local)*
- `ns.IndexUnit` *(:155, function)*
- `ns.GetIndexedPlate` *(:164, function)*
- `ns.GetUnitGUID` *(:169, function)*
- `ns.ResolvePlateForRemoval` *(:180, function)*
- `ns.IsFriendlyPlayer` *(:196, function)*
- `ns.IsFriendlyNonPlayer` *(:207, function)*
- `ns.IsFriendlyPetOrGuardian` *(:222, function)*
- `ns.IsFriendlyNPC` *(:228, function)*
- `ns.IsGroupOrRaidFriendlyPlayer` *(:237, function)*
- `ns.IsHostileUnit` *(:258, function)*
- `ns.IsPotentialThreatUnit` *(:283, function)*
- `RefreshPlayerRole` *(:343, local)*
- `ns.GetPlayerRole` *(:354, function)*
- `RefreshGroupRoster` *(:389, local)*
- `ns.GetGroupUnits` *(:439, function)*
- `DoRefresh` *(:443, local)*
- `ns.GetHealthBar` *(:530, function)*
- `GetSiblings` *(:582, local)*
- `ns.RefreshPlateSiblings` *(:589, function)*
- `ns.SetSuppressed` *(:601, function)*
- `ns.SetPartialReveal` *(:618, function)*
- `ns.SetHealthBarColor` *(:642, function)*
- `ns.ClearHealthBarColor` *(:674, function)*
- `ns.HasHealthBarColorOverride` *(:700, function)*
- `ns.SetNameColor` *(:712, function)*
- `ns.ClearNameColor` *(:724, function)*
- `ns.HasNameColorOverride` *(:736, function)*
- `GetOrCreateGlowFrame` *(:753, local)*
- `GetOrCreateFallbackBorder` *(:769, local)*
- `StopGlowStyle` *(:952, local)*
- `BoostSaturation` *(:968, local)*
- `ns.SetGlow` *(:1008, function)*
- `ns.ClearGlow` *(:1083, function)*
- `ns.EnsureSteerableOptions` *(:1195, function)*
- `ns.SetPlateOption` *(:1208, function)*
- `ns.RefreshPlateColor` *(:1218, function)*
- `ns.RefreshPlateBorder` *(:1223, function)*
- `ns.SetPlateColorOverride` *(:1230, function)*
- `ns.SetNativeAggro` *(:1241, function)*
- `ns.GetNativeAggroHighlightFrame` *(:1251, function)*
- `ns.GetNativeAggroHighlightTexture` *(:1276, function)*
- `EnsureAggroRecolorHook` *(:1336, local)*
- `ns.SetNativeAggroHighlightColor` *(:1354, function)*
- `ns.ClearNativeAggroHighlightColor` *(:1374, function)*
- `EnsureAggroSuppressHook` *(:1409, local)*
- `ns.SuppressNativeAggroHighlight` *(:1425, function)*
- `ns.ClearNativeAggroHighlightSuppress` *(:1443, function)*
- `LogAggroStackHook` *(:1478, local)*
- `ns.WatchNativeAggroHighlight` *(:1487, function)*
- `ns.ForceShowNativeAggroHighlight` *(:1518, function)*
- `ns.ClearForcedNativeAggroHighlight` *(:1541, function)*
- `ns.ScanGlobalsForPattern` *(:1583, function)*
- `ns.ScanGlobalTablesForPattern` *(:1613, function)*
- `ns.DumpFunctionUpvalues` *(:1638, function)*
- `ns.GetSpeculativeAggroHookStatus` *(:1724, function)*
- `GetOrCreateHandRolledGlow` *(:1801, local)*
- `ns.SetHandRolledGlow` *(:1813, function)*
- `ns.ClearHandRolledGlow` *(:1831, function)*
- `LogRemovedRestore` *(:1845, local)*
- `ns.ClearUnitState` *(:1865, function)*
- `ns.IsReclassifyOverloaded` *(:2008, function)*
- `ns.ScanNow` *(:2064, function)*
- `DescribeRegion` *(:2113, local)*
- `WalkProbeTree` *(:2148, local)*
- `BuildProbeDump` *(:2181, local)*
- `ns.ProbeNow` *(:2201, function)*
- `FormatRegionLine` *(:2242, local)*
- `DumpSectionLines` *(:2260, local)*
- `ns.ProbeUnit` *(:2280, function)*
- `ns.SetLogStoreFilter` *(:2351, function)*
- `ns.GetLogStoreFilter` *(:2355, function)*
- `ns.IsLogging` *(:2359, function)*
- `ns.Log` *(:2365, function)*
- `ShortGUID` *(:2399, local)*
- `ns.DescribeUnit` *(:2405, function)*
- `ns.PerfStart` *(:2414, function)*
- `ns.PerfEnd` *(:2419, function)*
- `SetLogging` *(:2425, local)*
- `MatchesFilter` *(:2442, local)*
- `DumpLog` *(:2447, local)*
- `GetOrCreateCopyFrame` *(:2497, local)*
- `ns.ShowCopyableText` *(:2553, function)*
- `CopyLog` *(:2568, local)*
- `ns.RegisterRenderTest` *(:2618, function)*
- `RunRenderTestCycle` *(:2634, local)*
- `RunStep` *(:2651, local)*
- `ns.GetNameRegion` *(:2879, function)*
- `ns.GetUnitFrame` *(:2879, function)*
- `RefreshSiblingsCache` *(:2879, local)*

**pulls:** `GetTime`, `UnitName`

### `EnemyPlates.lua`

- `SeedThreatColorDefault` *(:237, local)*
- `GetConfiguredThreatColor` *(:264, local)*
- `IsEffectivelyTanking` *(:331, local)*
- `IsAnotherMemberApproachingAggro` *(:392, local)*
- `HasAnyGroupThreatEntry` *(:449, local)*
- `GetThreatColorForUnit` *(:535, local)*
- `StatesMatch` *(:637, local)*
- `ClearAppliedState` *(:644, local)*
- `ApplyThreatColorForUnit` *(:684, local)*
- `DisarmThreatColors` *(:788, local)*
- `SetThreatMode` *(:805, local)*
- `ApplyThreatColorToAllActive` *(:816, local)*
- `Attached` *(:847, local)*
- `ns.Enemy.OnUnitAdded` *(:852, function)*
- `ns.Enemy.OnReclassify` *(:866, function)*
- `ns.Enemy.OnThreatEvent` *(:872, function)*
- `ns.Enemy.OnUnitRemoved` *(:883, function)*
- `RenderTestAggroBroadcast` *(:1051, local)*
- `RenderTestHandRolledGlow` *(:1108, local)*
- `RenderTestNativeAggroColor` *(:1157, local)*
- `ns.Enemy.RenderTestApply` *(:1299, function)*
- `IsInstanceFillZone` *(:1299, local)*
- `TryApply` *(:1299, local)*

**pulls:** `UnitName`

### `FriendlyPlates.lua`  —  **OnUpdate ×1** (1 persistent)

- `NPCColorStatesMatch` *(:233, local)*
- `ApplyNPCColorForUnit` *(:241, local)*
- `UpdatePlateForUnit` *(:272, local)*
- `UpdateHealAlertForUnit` *(:310, local)*
- `SweepHealAlertExpirations` *(:338, local)*
- `DisarmNPCColors` *(:369, local)*
- `SetEnabled` *(:382, local)*
- `SetHealerModeEnabled` *(:401, local)*
- `ns.Friendly.OnUnitAdded` *(:430, function)*
- `ns.Friendly.OnReclassify` *(:439, function)*
- `ns.Friendly.OnThrottledTick` *(:444, function)*
- `ns.Friendly.OnHealthEvent` *(:449, function)*
- `ns.Friendly.IsSuppressed` *(:456, function)*
- `ns.Friendly.OnUnitRemoved` *(:463, function)*
- `ReapplySuppressed` *(:505, local)*
- `Attached` *(:632, local)*
- `ApplyNPCColorToAllActive` *(:632, local)*

**pulls:** `GetTime`

## COA_StatePlates_Aggro
_1 file(s) · 1 function(s) · **0 OnUpdate handler(s)**_

### `Options.lua`  —  events: ADDON_LOADED

- `API` *(:14, local)*

## COA_StatePlates_Friendly
_1 file(s) · 7 function(s) · **0 OnUpdate handler(s)**_

### `Options.lua`  —  events: ADDON_LOADED

- `API` *(:14, local)*
- `CreateColorRow` *(:51, local)*
- `Refresh` *(:70, local)*
- `SetColor` *(:75, local)*
- `ClearColor` *(:79, local)*
- `ColorPickerFrame.func` *(:88, assigned)*
- `ColorPickerFrame.cancelFunc` *(:92, assigned)*

**pushes:** `ShowUIPanel`

## COA_StatePlates_Enemy
_1 file(s) · 8 function(s) · **0 OnUpdate handler(s)**_

### `Options.lua`  —  events: ADDON_LOADED

- `API` *(:13, local)*
- `CreateThreatColorRow` *(:49, local)*
- `Default` *(:68, local)*
- `Refresh` *(:70, local)*
- `SetColor` *(:74, local)*
- `ResetColor` *(:78, local)*
- `ColorPickerFrame.func` *(:87, assigned)*
- `ColorPickerFrame.cancelFunc` *(:91, assigned)*

**pushes:** `ShowUIPanel`

## COA_PetGrid
_3 file(s) · 27 function(s) · **2 OnUpdate handler(s)**_

### `core.lua`  —  **OnUpdate ×2** (2 persistent) · events: ADDON_LOADED

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

### `feed_demo.lua`

- `tickDemo` *(:19, local)*

### `feed_live.lua`  —  events: COMBAT_LOG_EVENT_UNFILTERED, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED

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

**pulls:** `GetTime`

## COA_Landmarks
_7 file(s) · 71 function(s) · **2 OnUpdate handler(s)**_

### `beacon.lua`  —  **OnUpdate ×1** (1 persistent) · hooks: SelectQuestLogEntry

- `Beacon.PinnedId` *(:55, function)*
- `Beacon.Clear` *(:83, function)*
- `Beacon.CannotGuide` *(:92, function)*
- `arrivalConditionMet` *(:116, local)*
- `poll` *(:139, local)*
- `onUpdate` *(:163, local)*
- `Beacon.Init` *(:176, function)*
- `Beacon.OwnsSlot` *(:200, function)*
- `Beacon.Pin` *(:200, function)*

**pulls:** `GetCurrentPlayerPosition`, `GetTime`

**pushes:** `C_SuperTrack.GetSuperTrackedPosition`, `C_SuperTrack.GetTargetState`, `SuperTrackerUtil.ClearSuperTrackedPosition`, `SuperTrackerUtil.SetSuperTrackedPosition`

### `core.lua`  —  events: ADDON_LOADED, PLAYER_ENTERING_WORLD

- `NS.Print` *(:22, function)*
- `lockedComplaint` *(:29, local)*
- `NS.CaptureHere` *(:40, function)*

**pulls:** `GetAddOnMetadata`

### `editor.lua`

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

**pulls:** `UnitName`

**pushes:** `StaticPopup_Show`

### `minimap.lua`  —  **OnUpdate ×1** (0 persistent)

- `place` *(:18, local)*
- `Minimap_:Init` *(:24, function)*

**pulls:** `AtlasInfo`

### `pins.lua`  —  events: WORLD_MAP_UPDATE · hookscript: OnShow

- `showNote` *(:50, local)*
- `onClick` *(:79, local)*
- `acquire` *(:98, local)*
- `Pins:Refresh` *(:115, function)*
- `Pins:Init` *(:148, function)*
- `setIcon` *(:161, local)*

**pulls:** `AtlasInfo`, `GetCurrentMapContinent`, `GetCurrentMapZone`

### `store.lua`

- `Store.TierYards` *(:47, function)*
- `Store.TierLabel` *(:54, function)*
- `Store.Load` *(:67, function)*
- `db` *(:89, local)*
- `Store.GetUI` *(:99, function)*
- `Store.SetUI` *(:109, function)*
- `composeAlias` *(:129, local)*
- `Store.Create` *(:160, function)*
- `Store.Backfill` *(:191, function)*
- `Store.Get` *(:217, function)*
- `visibleToMe` *(:236, local)*
- `Store.IsMine` *(:243, function)*
- `Store.Visible` *(:248, function)*
- `Store.ForMap` *(:259, function)*
- `Store.Count` *(:267, function)*
- `Store.SplitTags` *(:276, function)*
- `Store.KnownTags` *(:294, function)*
- `Store.SuggestTags` *(:311, function)*
- `Store.KnownOwners` *(:329, function)*
- `Store.TransferOwner` *(:349, function)*
- `Store.Set` *(:369, function)*
- `Store.SetOwner` *(:383, function)*
- `Store.Delete` *(:389, function)*
- `composeId` *(:397, local)*
- `mapFraction` *(:397, local)*

**pulls:** `GetCurrentMapContinent`, `GetCurrentMapZone`, `GetCurrentPlayerPosition`, `GetPlayerMapPosition`, `GetRealZoneText`, `GetSubZoneText`, `UnitName`

**pushes:** `SetMapToCurrentZone`

### `widget.lua`

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

**pulls:** `GetRealZoneText`, `GetSubZoneText`

**pushes:** `SetMapByID`, `ShowUIPanel`

## MancerLedger
_3 file(s) · 68 function(s) · **4 OnUpdate handler(s)**_

### `core.lua`  —  **OnUpdate ×1** (1 persistent) · events: ADDON_LOADED, PLAYER_ENTERING_WORLD, PLAYER_REGEN_ENABLED

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

**pulls:** `GetAddOnMetadata`

### `minimap.lua`  —  **OnUpdate ×3** (2 persistent)

- `stateColor` *(:42, local)*
- `paint` *(:50, local)*
- `NS.onFold` *(:67, assigned)*
- `place` *(:76, local)*
- `dragTick` *(:84, local)*
- `popEntry` *(:123, local)*
- `hidePopout` *(:140, local)*
- `showPopout` *(:144, local)*

### `ui.lua`

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
