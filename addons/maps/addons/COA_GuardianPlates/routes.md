# COA_GuardianPlates — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_4 file(s) · 140 function(s) · **2 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `d66faf986c46`._

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
- `ns.IndexUnit` *(:158, function)*
- `ns.GetIndexedPlate` *(:167, function)*
- `ns.GetUnitGUID` *(:172, function)*
- `ns.ResolvePlateForRemoval` *(:185, function)*
- `ns.IsFriendlyPlayer` *(:201, function)*
- `ns.IsFriendlyNonPlayer` *(:212, function)*
- `ns.IsFriendlyPetOrGuardian` *(:227, function)*
- `ns.IsFriendlyNPC` *(:233, function)*
- `ns.IsGroupOrRaidFriendlyPlayer` *(:242, function)*
- `ns.IsHostileUnit` *(:263, function)*
- `ns.IsPotentialThreatUnit` *(:292, function)*
- `RefreshPlayerRole` *(:352, local)*
- `ns.GetPlayerRole` *(:363, function)*
- `RefreshGroupRoster` *(:398, local)*
- `ns.GetGroupUnits` *(:448, function)*
- `DoRefresh` *(:452, local)*
- `ns.GetHealthBar` *(:540, function)*
- `GetSiblings` *(:592, local)*
- `ns.RefreshPlateSiblings` *(:599, function)*
- `ns.SetSuppressed` *(:611, function)*
- `ns.SetPartialReveal` *(:628, function)*
- `ns.SetHealthBarColor` *(:652, function)*
- `ns.ClearHealthBarColor` *(:684, function)*
- `ns.HasHealthBarColorOverride` *(:710, function)*
- `ns.SetNameColor` *(:722, function)*
- `ns.ClearNameColor` *(:734, function)*
- `ns.HasNameColorOverride` *(:746, function)*
- `GetOrCreateGlowFrame` *(:763, local)*
- `GetOrCreateFallbackBorder` *(:779, local)*
- `StopGlowStyle` *(:962, local)*
- `BoostSaturation` *(:978, local)*
- `ns.SetGlow` *(:1018, function)*
- `ns.ClearGlow` *(:1093, function)*
- `ns.EnsureSteerableOptions` *(:1205, function)*
- `ns.SetPlateOption` *(:1218, function)*
- `ns.RefreshPlateColor` *(:1228, function)*
- `ns.RefreshPlateBorder` *(:1233, function)*
- `ns.SetPlateColorOverride` *(:1240, function)*
- `ns.SetNativeAggro` *(:1251, function)*
- `ns.GetNativeAggroHighlightFrame` *(:1261, function)*
- `ns.GetNativeAggroHighlightTexture` *(:1289, function)*
- `EnsureAggroRecolorHook` *(:1349, local)*
- `ns.SetNativeAggroHighlightColor` *(:1367, function)*
- `ns.ClearNativeAggroHighlightColor` *(:1387, function)*
- `EnsureAggroSuppressHook` *(:1422, local)*
- `ns.SuppressNativeAggroHighlight` *(:1438, function)*
- `ns.ClearNativeAggroHighlightSuppress` *(:1456, function)*
- `LogAggroStackHook` *(:1491, local)*
- `ns.WatchNativeAggroHighlight` *(:1500, function)*
- `ns.ForceShowNativeAggroHighlight` *(:1531, function)*
- `ns.ClearForcedNativeAggroHighlight` *(:1554, function)*
- `ns.ScanGlobalsForPattern` *(:1596, function)*
- `ns.ScanGlobalTablesForPattern` *(:1626, function)*
- `ns.DumpFunctionUpvalues` *(:1653, function)*
- `ns.GetSpeculativeAggroHookStatus` *(:1739, function)*
- `GetOrCreateHandRolledGlow` *(:1816, local)*
- `ns.SetHandRolledGlow` *(:1828, function)*
- `ns.ClearHandRolledGlow` *(:1846, function)*
- `LogRemovedRestore` *(:1860, local)*
- `ns.ClearUnitState` *(:1880, function)*
- `ns.IsReclassifyOverloaded` *(:2023, function)*
- `ns.ScanNow` *(:2079, function)*
- `DescribeRegion` *(:2128, local)*
- `WalkProbeTree` *(:2163, local)*
- `BuildProbeDump` *(:2196, local)*
- `ns.ProbeNow` *(:2216, function)*
- `FormatRegionLine` *(:2257, local)*
- `DumpSectionLines` *(:2275, local)*
- `ns.ProbeUnit` *(:2295, function)*
- `ns.SetLogStoreFilter` *(:2366, function)*
- `ns.GetLogStoreFilter` *(:2370, function)*
- `ns.IsLogging` *(:2374, function)*
- `ns.Log` *(:2380, function)*
- `ShortGUID` *(:2414, local)*
- `ns.DescribeUnit` *(:2420, function)*
- `ns.PerfStart` *(:2429, function)*
- `ns.PerfEnd` *(:2434, function)*
- `SetLogging` *(:2440, local)*
- `MatchesFilter` *(:2457, local)*
- `DumpLog` *(:2462, local)*
- `GetOrCreateCopyFrame` *(:2514, local)*
- `ns.ShowCopyableText` *(:2570, function)*
- `CopyLog` *(:2585, local)*
- `ns.RegisterRenderTest` *(:2635, function)*
- `RunRenderTestCycle` *(:2651, local)*
- `RunStep` *(:2668, local)*
- `ns.GetNameRegion` *(:2896, function)*
- `ns.GetUnitFrame` *(:2896, function)*
- `RefreshSiblingsCache` *(:2896, local)*

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
