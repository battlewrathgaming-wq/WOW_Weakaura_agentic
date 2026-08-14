# COA_GuardianPlates — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_4 file(s) · 140 function(s) · **2 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `402a00989383`._

## `AggroPlates.lua`

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

## `Core.lua`  —  **OnUpdate ×1** (1 persistent) · events: GROUP_ROSTER_UPDATE, NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED, PLAYER_ENTERING_WORLD, PLAYER_ROLES_ASSIGNED, ROLE_CHANGED_INFORM, UNIT_HEALTH, UNIT_MAXHEALTH, UNIT_THREAT_LIST_UPDATE, UNIT_THREAT_SITUATION_UPDATE · hooks: frame, texture · timers: C_Timer.After

**pulls:** `GetTime`, `UnitName`

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

## `EnemyPlates.lua`

**pulls:** `UnitName`

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

## `FriendlyPlates.lua`  —  **OnUpdate ×1** (1 persistent)

**pulls:** `GetTime`

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
