# COA_GuardianPlates — what it defines, and what it touches

_Emitted by `addons/tools/emit_addon_census.py`. Never hand-edited._

_4 file(s) · 140 function(s) · **2 persistent OnUpdate handler(s)** — see `frame_cost.md` beside this file._
_Source fingerprint `ba4d4c9390aa`._

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
- `ns.GetHealthBar` *(:531, function)*
- `GetSiblings` *(:583, local)*
- `ns.RefreshPlateSiblings` *(:590, function)*
- `ns.SetSuppressed` *(:602, function)*
- `ns.SetPartialReveal` *(:619, function)*
- `ns.SetHealthBarColor` *(:643, function)*
- `ns.ClearHealthBarColor` *(:675, function)*
- `ns.HasHealthBarColorOverride` *(:701, function)*
- `ns.SetNameColor` *(:713, function)*
- `ns.ClearNameColor` *(:725, function)*
- `ns.HasNameColorOverride` *(:737, function)*
- `GetOrCreateGlowFrame` *(:754, local)*
- `GetOrCreateFallbackBorder` *(:770, local)*
- `StopGlowStyle` *(:953, local)*
- `BoostSaturation` *(:969, local)*
- `ns.SetGlow` *(:1009, function)*
- `ns.ClearGlow` *(:1084, function)*
- `ns.EnsureSteerableOptions` *(:1196, function)*
- `ns.SetPlateOption` *(:1209, function)*
- `ns.RefreshPlateColor` *(:1219, function)*
- `ns.RefreshPlateBorder` *(:1224, function)*
- `ns.SetPlateColorOverride` *(:1231, function)*
- `ns.SetNativeAggro` *(:1242, function)*
- `ns.GetNativeAggroHighlightFrame` *(:1252, function)*
- `ns.GetNativeAggroHighlightTexture` *(:1277, function)*
- `EnsureAggroRecolorHook` *(:1337, local)*
- `ns.SetNativeAggroHighlightColor` *(:1355, function)*
- `ns.ClearNativeAggroHighlightColor` *(:1375, function)*
- `EnsureAggroSuppressHook` *(:1410, local)*
- `ns.SuppressNativeAggroHighlight` *(:1426, function)*
- `ns.ClearNativeAggroHighlightSuppress` *(:1444, function)*
- `LogAggroStackHook` *(:1479, local)*
- `ns.WatchNativeAggroHighlight` *(:1488, function)*
- `ns.ForceShowNativeAggroHighlight` *(:1519, function)*
- `ns.ClearForcedNativeAggroHighlight` *(:1542, function)*
- `ns.ScanGlobalsForPattern` *(:1584, function)*
- `ns.ScanGlobalTablesForPattern` *(:1614, function)*
- `ns.DumpFunctionUpvalues` *(:1639, function)*
- `ns.GetSpeculativeAggroHookStatus` *(:1725, function)*
- `GetOrCreateHandRolledGlow` *(:1802, local)*
- `ns.SetHandRolledGlow` *(:1814, function)*
- `ns.ClearHandRolledGlow` *(:1832, function)*
- `LogRemovedRestore` *(:1846, local)*
- `ns.ClearUnitState` *(:1866, function)*
- `ns.IsReclassifyOverloaded` *(:2009, function)*
- `ns.ScanNow` *(:2065, function)*
- `DescribeRegion` *(:2114, local)*
- `WalkProbeTree` *(:2149, local)*
- `BuildProbeDump` *(:2182, local)*
- `ns.ProbeNow` *(:2202, function)*
- `FormatRegionLine` *(:2243, local)*
- `DumpSectionLines` *(:2261, local)*
- `ns.ProbeUnit` *(:2281, function)*
- `ns.SetLogStoreFilter` *(:2352, function)*
- `ns.GetLogStoreFilter` *(:2356, function)*
- `ns.IsLogging` *(:2360, function)*
- `ns.Log` *(:2366, function)*
- `ShortGUID` *(:2400, local)*
- `ns.DescribeUnit` *(:2406, function)*
- `ns.PerfStart` *(:2415, function)*
- `ns.PerfEnd` *(:2420, function)*
- `SetLogging` *(:2426, local)*
- `MatchesFilter` *(:2443, local)*
- `DumpLog` *(:2448, local)*
- `GetOrCreateCopyFrame` *(:2498, local)*
- `ns.ShowCopyableText` *(:2554, function)*
- `CopyLog` *(:2569, local)*
- `ns.RegisterRenderTest` *(:2619, function)*
- `RunRenderTestCycle` *(:2635, local)*
- `RunStep` *(:2652, local)*
- `ns.GetNameRegion` *(:2880, function)*
- `ns.GetUnitFrame` *(:2880, function)*
- `RefreshSiblingsCache` *(:2880, local)*

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
