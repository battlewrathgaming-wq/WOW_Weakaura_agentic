# runtime.routes - the runtime census reduction (pass 3 joined to the witnesses)

_Record `20260715_191602_521__census.json` (runId 20260715_191602_521, Gravekeeper/NECROMANCER) | reduced 2026-07-15_

- runtime globals: 51855 (6282 functions / 1098 tables / 29777 widgets)
- C_* namespaces at runtime: 91 (+3 declared-only: C_ChallengeMode, C_CoA, C_RealmMerge)
- namespace members: 1003 attested + 284 RUNTIME-ONLY (the surface shipped code never calls) + 18 declared-only
- flat functions: 2058 stock-capi / 2698 shipped-ui / 1526 unattributed (mixture - see grain)

## Biggest runtime-only surfaces (uncalled API = pure discovery)

- `C_MysticEnchant` - 35 runtime-only members (of 60)
- `C_GMTicket` - 24 runtime-only members (of 27)
- `C_Wildcard` - 14 runtime-only members (of 60)
- `C_BuildEditor` - 13 runtime-only members (of 63)
- `C_CharacterAdvancement` - 13 runtime-only members (of 132)
- `C_GameMode` - 13 runtime-only members (of 21)
- `C_GroupFinder` - 13 runtime-only members (of 14)
- `C_TemporalContracts` - 10 runtime-only members (of 16)
- `C_Challenge` - 9 runtime-only members (of 35)
- `C_TrackerHeader` - 8 runtime-only members (of 15)
- `C_CollectorCache` - 7 runtime-only members (of 7)
- `C_LootLockout` - 7 runtime-only members (of 10)
- `C_CharacterCreate` - 6 runtime-only members (of 33)
- `C_LoyaltyPass` - 6 runtime-only members (of 6)
- `C_Quest` - 6 runtime-only members (of 30)
