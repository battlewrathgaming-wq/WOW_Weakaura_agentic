# COA_GuardianPlates — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_4 file(s) · 140 function(s) · **2 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `aafc34056bc5`._

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
- `ns.IsPotentialThreatUnit` *(:287, function)*
- `RefreshPlayerRole` *(:347, local)*
- `ns.GetPlayerRole` *(:358, function)*
- `RefreshGroupRoster` *(:393, local)*
- `ns.GetGroupUnits` *(:443, function)*
- `DoRefresh` *(:447, local)*
- `ns.GetHealthBar` *(:535, function)*
- `GetSiblings` *(:587, local)*
- `ns.RefreshPlateSiblings` *(:594, function)*
- `ns.SetSuppressed` *(:606, function)*
- `ns.SetPartialReveal` *(:623, function)*
- `ns.SetHealthBarColor` *(:647, function)*
- `ns.ClearHealthBarColor` *(:679, function)*
- `ns.HasHealthBarColorOverride` *(:705, function)*
- `ns.SetNameColor` *(:717, function)*
- `ns.ClearNameColor` *(:729, function)*
- `ns.HasNameColorOverride` *(:741, function)*
- `GetOrCreateGlowFrame` *(:758, local)*
- `GetOrCreateFallbackBorder` *(:774, local)*
- `StopGlowStyle` *(:957, local)*
- `BoostSaturation` *(:973, local)*
- `ns.SetGlow` *(:1013, function)*
- `ns.ClearGlow` *(:1088, function)*
- `ns.EnsureSteerableOptions` *(:1200, function)*
- `ns.SetPlateOption` *(:1213, function)*
- `ns.RefreshPlateColor` *(:1223, function)*
- `ns.RefreshPlateBorder` *(:1228, function)*
- `ns.SetPlateColorOverride` *(:1235, function)*
- `ns.SetNativeAggro` *(:1246, function)*
- `ns.GetNativeAggroHighlightFrame` *(:1256, function)*
- `ns.GetNativeAggroHighlightTexture` *(:1281, function)*
- `EnsureAggroRecolorHook` *(:1341, local)*
- `ns.SetNativeAggroHighlightColor` *(:1359, function)*
- `ns.ClearNativeAggroHighlightColor` *(:1379, function)*
- `EnsureAggroSuppressHook` *(:1414, local)*
- `ns.SuppressNativeAggroHighlight` *(:1430, function)*
- `ns.ClearNativeAggroHighlightSuppress` *(:1448, function)*
- `LogAggroStackHook` *(:1483, local)*
- `ns.WatchNativeAggroHighlight` *(:1492, function)*
- `ns.ForceShowNativeAggroHighlight` *(:1523, function)*
- `ns.ClearForcedNativeAggroHighlight` *(:1546, function)*
- `ns.ScanGlobalsForPattern` *(:1588, function)*
- `ns.ScanGlobalTablesForPattern` *(:1618, function)*
- `ns.DumpFunctionUpvalues` *(:1643, function)*
- `ns.GetSpeculativeAggroHookStatus` *(:1729, function)*
- `GetOrCreateHandRolledGlow` *(:1806, local)*
- `ns.SetHandRolledGlow` *(:1818, function)*
- `ns.ClearHandRolledGlow` *(:1836, function)*
- `LogRemovedRestore` *(:1850, local)*
- `ns.ClearUnitState` *(:1870, function)*
- `ns.IsReclassifyOverloaded` *(:2013, function)*
- `ns.ScanNow` *(:2069, function)*
- `DescribeRegion` *(:2118, local)*
- `WalkProbeTree` *(:2153, local)*
- `BuildProbeDump` *(:2186, local)*
- `ns.ProbeNow` *(:2206, function)*
- `FormatRegionLine` *(:2247, local)*
- `DumpSectionLines` *(:2265, local)*
- `ns.ProbeUnit` *(:2285, function)*
- `ns.SetLogStoreFilter` *(:2356, function)*
- `ns.GetLogStoreFilter` *(:2360, function)*
- `ns.IsLogging` *(:2364, function)*
- `ns.Log` *(:2370, function)*
- `ShortGUID` *(:2404, local)*
- `ns.DescribeUnit` *(:2410, function)*
- `ns.PerfStart` *(:2419, function)*
- `ns.PerfEnd` *(:2424, function)*
- `SetLogging` *(:2430, local)*
- `MatchesFilter` *(:2447, local)*
- `DumpLog` *(:2452, local)*
- `GetOrCreateCopyFrame` *(:2502, local)*
- `ns.ShowCopyableText` *(:2558, function)*
- `CopyLog` *(:2573, local)*
- `ns.RegisterRenderTest` *(:2623, function)*
- `RunRenderTestCycle` *(:2639, local)*
- `RunStep` *(:2656, local)*
- `ns.GetNameRegion` *(:2884, function)*
- `ns.GetUnitFrame` *(:2884, function)*
- `RefreshSiblingsCache` *(:2884, local)*

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
