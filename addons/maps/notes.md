# Notes in the code — rulings and measured facts

_Emitted by `addons/tools/emit_notes.py`. **Never hand-edited.**_

★★ **The notes live WITH THE CODE and this does not move them.** Proximity is what makes them work — you are already in the block one governs, and you did not have to know it existed. This is a **pointer** so they are also findable from outside the file, which is the failure it was built for: a ruling about timers sat in `COA_GuardianPlates` for a month while the intent shelf claimed the opposite.

★ **The tag is the pruning decision.** A block earns `RULING:` or `FACT:` only when it is **settled** — that is what keeps this an inventory rather than a second log of uncertainties.

**13 ruling(s) · 42 fact(s) · 1 open.**

## RULINGS

_Decisions and their reasoning. Mostly his._

| Wt | What | Governs | Where |
|---|---|---|---|
| ★★★ | capture is the ONLY spawn - everything downstream inherits, nothing derives | `(file)` | `COA_DungeonRun/capture.lua:29` |
| ★★★ | we hold WHAT HAPPENED, never what the world is or what it meant | `(file)` | `COA_DungeonRun/capture.lua:30` |
| ★★★ | PLACE carries, EVENT does not - a beacon is a statement about a SPOT | `PLACE` | `COA_DungeonRun/routes.lua:48` |
| ★★★ | meaning, exactly-where and which-zone are OURS; HOW TO TRAVEL is NOT | `(file)` | `COA_Landmarks/core.lua:6` |
| ★★★ | if the CODE and the BRIEF disagree, the BRIEF is right and the code is | `(file)` | `COA_Landmarks/core.lua:19` |
| ★★★ | the note is PULLED on hover - NOTHING announces itself on approach | `if lm.what ~= "" then WorldMapTooltip:Ad` | `COA_Landmarks/pins.lua:59` |
| ★★★ | this file's laws are NUMBERED AND CITED (AC-46..) - a behaviour that | `(file)` | `COA_Landmarks/store.lua:21` |
| ★★★ | a StatePlates plugin owns NO machinery - loading it DECLARES INTEREST, | `(file)` | `COA_StatePlates_Aggro/Options.lua:3` |
| ★★★ | READ-ONLY on the driver DB; fold only KNOWN fields and NOTE unknown ones; | `(file)` | `MancerLedger/core.lua:24` |
| ★★ | the driver INFORMS, it never grades - no completion count, no "you missed" | `Driver.Reached` | `COA_DungeonRun/driver.lua:92` |
| ★★ | all edit options of an object live in ITS OWN pane, not the creation surface | `(file)` | `COA_DungeonRun/object.lua:6` |
| ★★ | don't engrain custom internal clocks when the game can do it for us | `recheckPending` | `COA_GuardianPlates/Core.lua:485` |
| ★★ | the minimap is a CONTROL surface, never a DISPLAY one - no pins, no | `(file)` | `COA_Landmarks/minimap.lua:6` |

## FACTS

_Measured behaviour of the client or our own data._

| Wt | What | Governs | Where |
|---|---|---|---|
| ★★★ | an UNSUPPORTED macro conditional and a currently-FALSE one are both | `ask` | `COA_DevDump/payload_macros.lua:29` |
| ★★★ | under pcall ALL return values SHIFT BY ONE - UnitClass's TOKEN is the | `local okc, className, classToken = pcall` | `COA_DevDump/payload_macros.lua:88` |
| ★★★ | `{ pcall(f) }` + `#` is a TRAP - a nil anywhere makes a sequence with | `collect` | `COA_DevDump/task_dump.lua:112` |
| ★★★ | GetSpecializationInfo is NOT a pure getter - it runs ConvertOldSavedSpec, | `(file)` | `COA_DevDump/task_spec.lua:9` |
| ★★★ | a `local function` referenced ABOVE its declaration resolves to a NIL | `local pendingKilledBy, pendingWhy   -- s` | `COA_DungeonRun/capture.lua:52` |
| ★★★ | UnitExists returns 1, NOT true - never compare against `true` | `engagedBosses` | `COA_DungeonRun/capture.lua:118` |
| ★★★ | AscensionUI.DeathRecap is readable ONLY at PLAYER_DEAD - CurrentRecap | `onPlayerDead` | `COA_DungeonRun/capture.lua:341` |
| ★★★ | WorldMapDetailFrame is 1002x668 (coordinates) while the tile art is 4x3x256 = 1024x768 | `Map.Offset` | `COA_DungeonRun/map.lua:990` |
| ★★★ | stage is a LABEL, not an array index - DeleteBeacon leaves gaps, and 4.1 is ordinary | `Routes.NextStage` | `COA_DungeonRun/routes.lua:172` |
| ★★★ | CoA's classes are ENTIRELY CUSTOM - no Warrior/Paladin/Druid/DK, so | `if COA_GuardianPlatesDB.threatMode == 2` | `COA_GuardianPlates/EnemyPlates.lua:183` |
| ★★★ | the `cond and X or Y` idiom BREAKS whenever X is itself falsy | `if stateName ~= "secure" and stateName ~` | `COA_GuardianPlates/EnemyPlates.lua:986` |
| ★★★ | pcall's FIRST return is "did it error", NOT the callee's own boolean | `local ok2, shown = pcall(ns.ForceShowNat` | `COA_GuardianPlates/EnemyPlates.lua:1088` |
| ★★★ | across a map boundary supertracking returns Invalid with distance 0.00 | `(file)` | `COA_Landmarks/beacon.lua:14` |
| ★★★ | GetPlayerMapPosition returns 0,0 when the world map shows a DIFFERENT | `mapFraction` | `COA_Landmarks/store.lua:141` |
| ★★★ | the mapID from GetCurrentPlayerPosition is the CONTINENT, not the zone | `mapFraction` | `COA_Landmarks/store.lua:150` |
| ★★★ | CLEU on 3.3.5 is the classic VARARGS tuple - 1 ts, 2 sub, 3-5 src, 6-8 dst | `(file)` | `COA_PetGrid/feed_live.lua:4` |
| ★★★ | OnTextChanged is DEFERRED a frame, COALESCED to one fire, and CHANGE-ONLY (measured) | `o:SetText` | `tools/smoke/harness.lua:99` |
| ★★ | addon Lua CANNOT read files from disk - so a build can only be identified | `structuralFingerprint` | `COA_DevDump/task_callwitness.lua:232` |
| ★★ | debugprofilestop can SILENTLY NOT ADVANCE - a 0ms observer cost means | `(file)` | `COA_DevDump/task_cleu.lua:24` |
| ★★ | _G is full of CYCLES and an unguarded walk hangs the client - but | `if seen[v] then` | `COA_DevDump/task_dump.lua:62` |
| ★★ | GetAddOnCPUUsage returns 0 unless scriptProfile is 1 AND the client has | `(file)` | `COA_DevDump/task_perf.lua:12` |
| ★★ | the fraction->world fit is a MAP constant, not a run constant (0.000203 yd worst, measured) | `(file)` | `COA_DungeonRun/calibrate.lua:48` |
| ★★ | a walkway 9.71 yd above its floor sits only 3.12 yd away on the map (measured) | `Driver.Reached` | `COA_DungeonRun/driver.lua:91` |
| ★★ | GetCurrentMapDungeonLevel reports the floor the WORLD MAP IS SHOWING, | `mapFraction` | `COA_DungeonRun/store.lua:83` |
| ★★ | the SAME creature is announced under TWO unit tokens at once | `ns.plateOwner` | `COA_GuardianPlates/Core.lua:122` |
| ★★ | GetNamePlateForUnit FAILS at NAME_PLATE_UNIT_REMOVED time - 20/20 live | `ns.ResolvePlateForRemoval` | `COA_GuardianPlates/Core.lua:178` |
| ★★ | UnitAffectingCombat(unit) is true only once a mob is ACTUALLY ENGAGED by | `ns.IsPotentialThreatUnit` | `COA_GuardianPlates/Core.lua:289` |
| ★★ | the native aggro frame is NOT healthBar.aggroHighlight - it is | `local okName, healthBarName = pcall(heal` | `COA_GuardianPlates/Core.lua:1266` |
| ★★ | debug.getupvalue sees closure-captured tables no _G scan can reach - | `ns.DumpFunctionUpvalues` | `COA_GuardianPlates/Core.lua:1645` |
| ★★ | "BackdropTemplate" is a RETAIL 8.0+ requirement - on 3.3.5 SetBackdrop | `GetOrCreateCopyFrame` | `COA_GuardianPlates/Core.lua:2505` |
| ★★ | UnitDetailedThreatSituation's rawPercentage can EXCEED 100 and STOPS | `IsAnotherMemberApproachingAggro` | `COA_GuardianPlates/EnemyPlates.lua:354` |
| ★★ | UnitDetailedThreatSituation returns nil ACROSS THE BOARD when you have | `GetThreatColorForUnit` | `COA_GuardianPlates/EnemyPlates.lua:518` |
| ★★ | GetSuperTrackedPosition's distance is ENGINE-computed 3D yards (mean | `local _, _, dist = C_SuperTrack.GetSuper` | `COA_Landmarks/beacon.lua:176` |
| ★★ | AutoComplete_Update / GetAutoCompleteResults is a C API that only ever | `splitAtCursor` | `COA_Landmarks/editor.lua:51` |
| ★★ | EditBox OnTextChanged fires on DELETION too - completing on a shrink makes | `grew` | `COA_Landmarks/editor.lua:226` |
| ★★ | GetCursorPosition() is in SCREEN pixels - divide it by the effective | `b:SetScript` | `COA_Landmarks/minimap.lua:59` |
| ★★ | AtlasInfo[name] = {texture,w,h,left,right,top,bottom,flipH,flipV} - and | `setIcon` | `COA_Landmarks/pins.lua:27` |
| ★★ | WORLD_MAP_UPDATE fires whenever the DISPLAYED map changes - the correct | `f` | `COA_Landmarks/pins.lua:156` |
| ★★ | GetLeft/GetTop return values in the FRAME's scale space, not UIParent's | `db.topX` | `COA_PetGrid/core.lua:63` |
| ★★ | at ADDON_LOADED a frame has NO rect yet - GetLeft() returns nil | `pinner` | `COA_PetGrid/core.lua:84` |
| ★★ | SavedVariables globals DO NOT EXIST while a file body executes - the DB | `NS.GetDb` | `MancerLedger/core.lua:526` |
| ★★ | its 2nd arg `userInput` is FALSE for a programmatic SetText, true when typed (measured) | `o:SetText` | `tools/smoke/harness.lua:100` |

## OPEN

_**Not settled.** Each says what would settle it. ⚠ An open question dressed in real figures reads as a finding — which is how a trap gets quoted forward past its evidence. RULING and FACT both mean SETTLED; this is the third status, and it exists because a block can be well-researched and still not be an answer._

| Wt | What | Governs | Where |
|---|---|---|---|
| ★★ | does DungeonUsesTerrainMap() agree with the DBC floor mark? | `probe` | `COA_DungeonRun/core.lua:29` |

---

## Star census — where the emphasis actually sits

★★ **Weight and kind are orthogonal and they compose:** `-- ★★ RULING: …`. The star says **where to slow down** while scanning a long file; the prefix says **what kind of thing** it is. An audit recommended replacing the stars — that was the wrong call, because they answer a question the prefixes do not.

⚠ **But the audit's real finding stands: they were anti-correlated with value** — 307 marks all inside two addons, while four others carried zero between them and roughly 160 rulings. Inflation is invisible from inside one file, so it is printed here.

| ★ | means |
|---|---|
| ★★★ | **miss this and you break something.** Rare by construction |
| ★★ | **this is WHY it is like this** — the reasoning a change has to respect |
| ★ | worth noticing while passing |
| ⚠ | a trap, a limit, or a thing that is not what it looks like |

| File | ★ | ★★ | ★★★ | ⚠ |
|---|---|---|---|---|
| `COA_DungeonRun/map.lua` | 71 | 26 | 1 | 4 |
| `tools/smoke/smoke_dungeonrunmap.lua` | 62 | 23 | 3 | 5 |
| `tools/smoke/smoke_dungeonrunpromoter.lua` | 38 | 22 | 1 | 9 |
| `COA_DevDump/task_api.lua` | 25 | 6 | 7 | 15 |
| `COA_DungeonRun/routes.lua` | 21 | 5 | 2 | 2 |
| `COA_DungeonRun/promoter.lua` | 19 | 6 | 0 | 3 |
| `COA_DungeonRun/capture.lua` | 11 | 3 | 5 | 5 |
| `COA_DungeonRun/editor.lua` | 17 | 3 | 0 | 1 |
| `tools/smoke/smoke_api.lua` | 6 | 7 | 2 | 5 |
| `COA_DungeonRun/object.lua` | 9 | 4 | 1 | 5 |
| `tools/smoke/harness.lua` | 3 | 3 | 2 | 8 |
| `tools/smoke/smoke_dungeonrun.lua` | 12 | 2 | 0 | 2 |
| `COA_DungeonRun/driver.lua` | 9 | 4 | 0 | 1 |
| `COA_GuardianPlates/Core.lua` | 0 | 7 | 0 | 6 |
| `COA_GuardianPlates/EnemyPlates.lua` | 0 | 2 | 3 | 5 |
| `COA_DevDump/task_cleu.lua` | 6 | 2 | 0 | 1 |
| `COA_DungeonRun/calibrate.lua` | 7 | 2 | 0 | 0 |
| `tools/smoke/smoke_cleu.lua` | 8 | 1 | 0 | 0 |
| `tools/smoke/smoke_dungeonruncalibrate.lua` | 5 | 4 | 0 | 0 |
| `COA_Landmarks/store.lua` | 3 | 0 | 3 | 2 |
| `COA_Landmarks/beacon.lua` | 3 | 1 | 1 | 2 |
| `COA_DungeonRun/store.lua` | 5 | 1 | 0 | 0 |
| `COA_Landmarks/editor.lua` | 2 | 2 | 0 | 2 |
| `COA_DevDump/task_dump.lua` | 1 | 1 | 1 | 2 |
| `COA_Landmarks/minimap.lua` | 2 | 2 | 0 | 1 |
| `COA_Landmarks/pins.lua` | 1 | 2 | 1 | 1 |
| `COA_DevDump/payload_macros.lua` | 1 | 0 | 2 | 1 |
| `COA_PetGrid/core.lua` | 0 | 2 | 0 | 2 |
| `COA_Landmarks/core.lua` | 2 | 0 | 2 | 0 |
| `MancerLedger/core.lua` | 1 | 1 | 1 | 1 |
| `COA_DungeonRun/core.lua` | 1 | 1 | 0 | 1 |
| `COA_DevDump/task_perf.lua` | 0 | 1 | 0 | 1 |
| `COA_DevDump/task_spec.lua` | 0 | 0 | 1 | 1 |
| `COA_StatePlates_Aggro/Options.lua` | 1 | 0 | 1 | 0 |
| `COA_DungeonRun/widget.lua` | 1 | 1 | 0 | 0 |
| `tools/smoke/smoke_dump.lua` | 2 | 0 | 0 | 0 |
| `COA_DevDump/core.lua` | 1 | 0 | 0 | 0 |
| `COA_DevDump/task_callwitness.lua` | 0 | 1 | 0 | 0 |
| `COA_DevDump/task_petlog.lua` | 0 | 0 | 0 | 1 |
| `COA_PetGrid/feed_live.lua` | 0 | 0 | 1 | 0 |
| **TOTAL** | **356** | **148** | **41** | **95** |

⚠ **A file with hundreds of marks and no ★★★, beside one written in an afternoon with several, is not a ranking — it is a record of who was excited when.** That is the shape to watch for here.

---

## The convention

```lua
-- ★★ RULING: <one line>   weight, then kind. Either may stand alone.
-- FACT: <one line>        measured behaviour of the client or our data
```

On its own line inside the comment block that already explains it. The body stays in the file; this carries only the headline, what it governs, and where.

⚠ **`Governs` is emitted, never typed** — a hand-kept scope goes stale the moment a function moves, which is the rot this exists to avoid.
