# COA_GuardianPlates — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_4 file(s) · 140 function(s) · **2 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `6c90b4bbcd71`._

## `AggroPlates.lua`

- `GetConfig` *(:37, local)*
- `Color` *(:48, local)*
- `CurrentPalette` *(:73, local)*
- `Apply` *(:81, local)*
- `ApplyAll` *(:105, local)*
- `ClearAll` *(:114, local)*
- `Aggro.OnUnitAdded` *(:131, function)*
- `Aggro.OnUnitRemoved` *(:136, function)*
- `Aggro.OnReclassify` *(:142, function)*
- `Aggro.HandleCommand` *(:177, function)*

## `Core.lua`  —  **OnUpdate ×1** (1 persistent) · events: GROUP_ROSTER_UPDATE, NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED, PLAYER_ENTERING_WORLD, PLAYER_ROLES_ASSIGNED, ROLE_CHANGED_INFORM, UNIT_HEALTH, UNIT_MAXHEALTH, UNIT_THREAT_LIST_UPDATE, UNIT_THREAT_SITUATION_UPDATE · hooks: frame, texture · timers: C_Timer.After

**pulls:** `GetTime`, `UnitName`

- `Print` *(:114, local)*
- `ns.IndexUnit` *(:166, function)*
- `ns.GetIndexedPlate` *(:175, function)*
- `ns.GetUnitGUID` *(:180, function)*
- `ns.ResolvePlateForRemoval` *(:193, function)*
- `ns.IsFriendlyPlayer` *(:209, function)*
- `ns.IsFriendlyNonPlayer` *(:220, function)*
- `ns.IsFriendlyPetOrGuardian` *(:235, function)*
- `ns.IsFriendlyNPC` *(:241, function)*
- `ns.IsGroupOrRaidFriendlyPlayer` *(:250, function)*
- `ns.IsHostileUnit` *(:271, function)*
- `ns.IsPotentialThreatUnit` *(:300, function)*
- `RefreshPlayerRole` *(:364, local)*
- `ns.GetPlayerRole` *(:375, function)*
- `RefreshGroupRoster` *(:410, local)*
- `ns.GetGroupUnits` *(:460, function)*
- `DoRefresh` *(:464, local)*
- `ns.GetHealthBar` *(:552, function)*
- `GetSiblings` *(:604, local)*
- `ns.RefreshPlateSiblings` *(:611, function)*
- `ns.SetSuppressed` *(:623, function)*
- `ns.SetPartialReveal` *(:640, function)*
- `ns.SetHealthBarColor` *(:664, function)*
- `ns.ClearHealthBarColor` *(:696, function)*
- `ns.HasHealthBarColorOverride` *(:722, function)*
- `ns.SetNameColor` *(:734, function)*
- `ns.ClearNameColor` *(:746, function)*
- `ns.HasNameColorOverride` *(:758, function)*
- `GetOrCreateGlowFrame` *(:775, local)*
- `GetOrCreateFallbackBorder` *(:791, local)*
- `StopGlowStyle` *(:978, local)*
- `BoostSaturation` *(:994, local)*
- `ns.SetGlow` *(:1034, function)*
- `ns.ClearGlow` *(:1109, function)*
- `ns.EnsureSteerableOptions` *(:1221, function)*
- `ns.SetPlateOption` *(:1234, function)*
- `ns.RefreshPlateColor` *(:1244, function)*
- `ns.RefreshPlateBorder` *(:1249, function)*
- `ns.SetPlateColorOverride` *(:1256, function)*
- `ns.SetNativeAggro` *(:1267, function)*
- `ns.GetNativeAggroHighlightFrame` *(:1277, function)*
- `ns.GetNativeAggroHighlightTexture` *(:1305, function)*
- `EnsureAggroRecolorHook` *(:1365, local)*
- `ns.SetNativeAggroHighlightColor` *(:1383, function)*
- `ns.ClearNativeAggroHighlightColor` *(:1403, function)*
- `EnsureAggroSuppressHook` *(:1438, local)*
- `ns.SuppressNativeAggroHighlight` *(:1454, function)*
- `ns.ClearNativeAggroHighlightSuppress` *(:1472, function)*
- `LogAggroStackHook` *(:1507, local)*
- `ns.WatchNativeAggroHighlight` *(:1516, function)*
- `ns.ForceShowNativeAggroHighlight` *(:1547, function)*
- `ns.ClearForcedNativeAggroHighlight` *(:1570, function)*
- `ns.ScanGlobalsForPattern` *(:1612, function)*
- `ns.ScanGlobalTablesForPattern` *(:1642, function)*
- `ns.DumpFunctionUpvalues` *(:1669, function)*
- `ns.GetSpeculativeAggroHookStatus` *(:1759, function)*
- `GetOrCreateHandRolledGlow` *(:1840, local)*
- `ns.SetHandRolledGlow` *(:1852, function)*
- `ns.ClearHandRolledGlow` *(:1870, function)*
- `LogRemovedRestore` *(:1884, local)*
- `ns.ClearUnitState` *(:1904, function)*
- `ns.IsReclassifyOverloaded` *(:2047, function)*
- `ns.ScanNow` *(:2103, function)*
- `DescribeRegion` *(:2152, local)*
- `WalkProbeTree` *(:2187, local)*
- `BuildProbeDump` *(:2220, local)*
- `ns.ProbeNow` *(:2240, function)*
- `FormatRegionLine` *(:2281, local)*
- `DumpSectionLines` *(:2299, local)*
- `ns.ProbeUnit` *(:2319, function)*
- `ns.SetLogStoreFilter` *(:2390, function)*
- `ns.GetLogStoreFilter` *(:2394, function)*
- `ns.IsLogging` *(:2398, function)*
- `ns.Log` *(:2404, function)*
- `ShortGUID` *(:2438, local)*
- `ns.DescribeUnit` *(:2444, function)*
- `ns.PerfStart` *(:2453, function)*
- `ns.PerfEnd` *(:2458, function)*
- `SetLogging` *(:2464, local)*
- `MatchesFilter` *(:2481, local)*
- `DumpLog` *(:2486, local)*
- `GetOrCreateCopyFrame` *(:2538, local)*
- `ns.ShowCopyableText` *(:2594, function)*
- `CopyLog` *(:2609, local)*
- `ns.RegisterRenderTest` *(:2659, function)*
- `RunRenderTestCycle` *(:2675, local)*
- `RunStep` *(:2692, local)*
- `ns.GetNameRegion` *(:2920, function)*
- `ns.GetUnitFrame` *(:2920, function)*
- `RefreshSiblingsCache` *(:2920, local)*

## `EnemyPlates.lua`

**pulls:** `UnitName`

- `SeedThreatColorDefault` *(:240, local)*
- `GetConfiguredThreatColor` *(:267, local)*
- `IsEffectivelyTanking` *(:334, local)*
- `IsAnotherMemberApproachingAggro` *(:397, local)*
- `HasAnyGroupThreatEntry` *(:454, local)*
- `GetThreatColorForUnit` *(:543, local)*
- `StatesMatch` *(:645, local)*
- `ClearAppliedState` *(:652, local)*
- `ApplyThreatColorForUnit` *(:692, local)*
- `DisarmThreatColors` *(:796, local)*
- `SetThreatMode` *(:813, local)*
- `ApplyThreatColorToAllActive` *(:824, local)*
- `Attached` *(:855, local)*
- `ns.Enemy.OnUnitAdded` *(:860, function)*
- `ns.Enemy.OnReclassify` *(:874, function)*
- `ns.Enemy.OnThreatEvent` *(:880, function)*
- `ns.Enemy.OnUnitRemoved` *(:891, function)*
- `RenderTestAggroBroadcast` *(:1061, local)*
- `RenderTestHandRolledGlow` *(:1121, local)*
- `RenderTestNativeAggroColor` *(:1170, local)*
- `ns.Enemy.RenderTestApply` *(:1312, function)*
- `IsInstanceFillZone` *(:1312, local)*
- `TryApply` *(:1312, local)*

## `FriendlyPlates.lua`  —  **OnUpdate ×1** (1 persistent)

**pulls:** `GetTime`

- `NPCColorStatesMatch` *(:233, local)*
- `ApplyNPCColorForUnit` *(:241, local)*
- `UpdatePlateForUnit` *(:272, local)*
- `UpdateHealAlertForUnit` *(:310, local)*
- `SweepHealAlertExpirations` *(:338, local)*
- `DisarmNPCColors` *(:369, local)*
- `SetEnabled` *(:382, local)*
- `SetHealerModeEnabled` *(:405, local)*
- `ns.Friendly.OnUnitAdded` *(:438, function)*
- `ns.Friendly.OnReclassify` *(:447, function)*
- `ns.Friendly.OnThrottledTick` *(:452, function)*
- `ns.Friendly.OnHealthEvent` *(:457, function)*
- `ns.Friendly.IsSuppressed` *(:464, function)*
- `ns.Friendly.OnUnitRemoved` *(:471, function)*
- `ReapplySuppressed` *(:513, local)*
- `Attached` *(:642, local)*
- `ApplyNPCColorToAllActive` *(:642, local)*
