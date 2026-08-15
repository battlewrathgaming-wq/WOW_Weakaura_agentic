# Notes in the code — rulings and measured facts

_Emitted by `addons/tools/emit_notes.py`. **Never hand-edited.**_

★★ **The notes live WITH THE CODE and this does not move them.** Proximity is what makes them work — you are already in the block one governs, and you did not have to know it existed. This is a **pointer** so they are also findable from outside the file, which is the failure it was built for: a ruling about timers sat in `COA_GuardianPlates` for a month while the intent shelf claimed the opposite.

★ **The tag is the pruning decision.** A block earns `RULING:` or `FACT:` only when it is **settled** — that is what keeps this an inventory rather than a second log of uncertainties.

**82 ruling(s) · 63 fact(s) · 1 open.**

★★★ **`SILENT` is the column that matters.** Battlewrath: *"some are taste and preference. Some are things that will make the written code fail silently / loudly / throw error."* A fact that **throws** teaches itself the first time you hit it. A fact that fails **silently** produces something that looks like it worked — you will never learn it from the symptom, so it has to be reachable BEFORE you need it.

⚠ **47 of 63 facts here are SILENT.** That is the finding, not a detail: almost everything this bench has paid to learn is a failure that does not announce itself.

★★★ **And `CULTURE` is the far end of the same axis.** *"This is about culture. How we decide to be respectful on someone's machine. Nothing that will ever manifest in code rejection or be 'bad code'."* **SILENT and CULTURE are the two classes that most need writing down, for opposite reasons** — silent because the failure HIDES, culture because there IS no failure. No test goes red. It just quietly becomes an addon that takes more than it was given.

## RULINGS

_Decisions and their reasoning. Mostly his. **`CULTURE` = manners on someone else's machine** — baseline-off, no borrowed clocks, nothing that nags, nothing that judges, read-only on data that is not ours. ⚠ **Breaking one is never bad code and never fails a test.** Writing it down is the only protection it has._

| Fails | Wt | What | Governs | Where |
|---|---|---|---|---|
| **CULTURE** | ★★★ | the probe is READ-ONLY on the client - PULL only, never PUSH | `(file)` | `COA_DevDump/task_api.lua:18` |
| **CULTURE** | ★★★ | NO validation on authoring - refusing would be GRADING the | `Routes.SetStage` | `COA_DungeonRun/routes.lua:488` |
| **CULTURE** | ★★★ | action handlers NO-OP until the satellite attaches - Core carries | `Attached` | `COA_GuardianPlates/FriendlyPlates.lua:425` |
| **CULTURE** | ★★★ | pinning is ALWAYS a user act (AC-12) - nothing in this addon | `Beacon.Pin` | `COA_Landmarks/beacon.lua:103` |
| **CULTURE** | ★★★ | the note is PULLED on hover - NOTHING announces itself on approach | `if lm.what ~= "" then WorldMapTooltip:Ad` | `COA_Landmarks/pins.lua:59` |
| **CULTURE** | ★★★ | a StatePlates plugin owns NO machinery - loading it DECLARES INTEREST, | `(file)` | `COA_StatePlates_Aggro/Options.lua:3` |
| **CULTURE** | ★★★ | READ-ONLY on the driver DB; fold only KNOWN fields and NOTE unknown ones; | `(file)` | `MancerLedger/core.lua:24` |
| **CULTURE** | ★★ | the driver INFORMS, it never grades - no completion count, no "you missed" | `Driver.Reached` | `COA_DungeonRun/driver.lua:92` |
| **CULTURE** | ★★ | use the CLIENT'S OWN widgets - StaticPopup, not a bespoke dialog | `installPopups` | `COA_DungeonRun/editor.lua:211` |
| **SILENT** | ★★ | every beacon ICON ranks as a BEACON - `kill` is a WORD a beacon | `note` | `COA_DungeonRun/map.lua:210` |
| **CULTURE** | ★★ | wheel-zoom and right-drag default OFF - the wheel belongs to the | `wheelTick` | `COA_DungeonRun/map.lua:1874` |
| **CULTURE** | ★★ | don't engrain custom internal clocks when the game can do it for us | `recheckPending` | `COA_GuardianPlates/Core.lua:497` |
| **CULTURE** | ★★ | turning a feature OFF collapses to baseline IMMEDIATELY, never | `SetHealerModeEnabled` | `COA_GuardianPlates/FriendlyPlates.lua:398` |
| **CULTURE** | ★★ | the minimap is a CONTROL surface, never a DISPLAY one - no pins, no | `(file)` | `COA_Landmarks/minimap.lua:6` |
| **CULTURE** | ★★ | observed-in-fight accounting shows "-", never a FALSE ZERO | `sumS` | `MancerLedger/core.lua:371` |
| — | ★★★ | every experiment carries a CONTROL, and a dead apparatus must be LOUD | `BOX_N` | `COA_DevDump/task_api.lua:44` |
| — | ★★★ | a name search proving ABSENCE proves NOTHING. I wrote "no stock scheduler, | `OPAQUE` | `COA_DevDump/task_api.lua:480` |
| — | ★★★ | the instrument must not MANUFACTURE - or add to - the effect it measures | `(file)` | `COA_DevDump/task_callwitness.lua:15` |
| — | ★★★ | capture is the ONLY spawn - everything downstream inherits, nothing derives | `(file)` | `COA_DungeonRun/capture.lua:29` |
| — | ★★★ | we hold WHAT HAPPENED, never what the world is or what it meant | `(file)` | `COA_DungeonRun/capture.lua:30` |
| — | ★★★ | the addon NEVER LEARNS DUNGEONS (§17) - no bounding box, no DBC, no | `(file)` | `COA_DungeonRun/map.lua:8` |
| — | ★★★ | the PRECEDENCE LADDER is not a display preference - enter and terminal | `RANK` | `COA_DungeonRun/map.lua:156` |
| — | ★★★ | §61 - promoted objects sit ABOVE the pin. The authored thing outranks its | `RANK` | `COA_DungeonRun/map.lua:196` |
| — | ★★★ | §48 - TIME IS THE MAIN FILTER, and three quantities must not be conflated | `Map.TimeSpan` | `COA_DungeonRun/map.lua:606` |
| — | ★★★ | §43 - CURATION EDITS THE VIEW, NEVER THE CAPTURE | `Map.Hidden` | `COA_DungeonRun/map.lua:861` |
| — | ★★★ | §34 - SELECTION is the SINGLE coupling point between the two frames | `local arm            -- { what = "move"` | `COA_DungeonRun/map.lua:930` |
| — | ★★★ | MANY LISTENERS, never one slot (§63) - §61 adds a third surface, and one | `local arm            -- { what = "move"` | `COA_DungeonRun/map.lua:939` |
| — | ★★★ | it is an OBJECT, NOT A MODE - his: *"It is on that object. Only promoted | `local arm            -- { what = "move"` | `COA_DungeonRun/map.lua:949` |
| — | ★★★ | ONE ARM, CARRYING WHAT IT IS ARMED FOR - never two arm slots | `local arm            -- { what = "move"` | `COA_DungeonRun/map.lua:960` |
| — | ★★★ | the MAP answers "what is this?" - his, 2026-08-13. The map identifies; | `TIP_COLOR` | `COA_DungeonRun/map.lua:1078` |
| — | ★★★ | DRAGGABLE MEANS PROMOTED - a node is CAPTURE, and DR-9 with §43 forbid | `Map.Draggable` | `COA_DungeonRun/map.lua:1195` |
| — | ★★★ | §36 - LOCATION SORTS THE LIST; IT NEVER CHOOSES THE VIEW | `Map.RunList` | `COA_DungeonRun/map.lua:1265` |
| — | ★★★ | §76 - the panel is UI, NOT map. His: *"zoom shouldn't mean the content | `local ax, ay = Map.ReadoutAnchor(dx * zo` | `COA_DungeonRun/map.lua:1564` |
| — | ★★★ | gate on `userInput`, do not COMPARE before writing - the flag makes the | `stageBox:SetScript` | `COA_DungeonRun/object.lua:291` |
| — | ★★★ | PLACE carries, EVENT does not - a beacon is a statement about a SPOT | `PLACE` | `COA_DungeonRun/routes.lua:48` |
| — | ★★★ | a child carries NO STAGE. The anchor holds the stage, and ANY CHILD | `Routes.ChildrenOf` | `COA_DungeonRun/routes.lua:341` |
| — | ★★★ | exactly ONE module touches the saved-variables global (DR-20) | `(file)` | `COA_DungeonRun/store.lua:3` |
| — | ★★★ | BOTH clocks on every point, and they are not redundant (DR-4) | `Store.Point` | `COA_DungeonRun/store.lua:117` |
| — | ★★★ | Core is the ONLY code that draws - SetAlpha, SetStatusBarColor, | `(file)` | `COA_GuardianPlates/Core.lua:19` |
| — | ★★★ | meaning, exactly-where and which-zone are OURS; HOW TO TRAVEL is NOT | `(file)` | `COA_Landmarks/core.lua:6` |
| — | ★★★ | if the CODE and the BRIEF disagree, the BRIEF is right and the code is | `(file)` | `COA_Landmarks/core.lua:19` |
| — | ★★★ | this file's laws are NUMBERED AND CITED (AC-46..) - a behaviour that | `(file)` | `COA_Landmarks/store.lua:21` |
| — | ★★ | we COMPOSE OUR OWN FRAME rather than touching WorldMapFrame | `(file)` | `COA_DungeonRun/map.lua:26` |
| — | ★★ | the PIN is deliberately off both axes - a CATCH-ALL carries no meaning | `ATLAS` | `COA_DungeonRun/map.lua:84` |
| — | ★★ | DR-35 puts the COMBAT leg BELOW the travel leg - where two paths | `RANK` | `COA_DungeonRun/map.lua:184` |
| — | ★★ | DR-36 puts the PIN above the terminal stop - it is the only point that | `RANK` | `COA_DungeonRun/map.lua:190` |
| — | ★★ | markers SCALE WITH THE MAP (his call) - a marker represents a FOOTPRINT, | `local ZOOM_MIN, ZOOM_MAX = 1.0, 4.0` | `COA_DungeonRun/map.lua:288` |
| — | ★★ | `timed` is the flag that matters - a run's envelope is a coordinate in | `RUN_LISTS` | `COA_DungeonRun/map.lua:365` |
| — | ★★ | §60's SECOND PLANE cost exactly one row, which is what the table was | `{ key = "notes", timed = false, art = fa` | `COA_DungeonRun/map.lua:380` |
| — | ★★ | each slot resolves through its OWN store - the route side reads NS.Routes | `resolve` | `COA_DungeonRun/map.lua:397` |
| — | ★★ | match on the mapID the RUN'S OWN POINTS carry - display reads it from the | `Map.MapIDOf` | `COA_DungeonRun/map.lua:510` |
| — | ★★ | GUARDED ON IDENTITY, and the guard is the whole point | `Map.ArtFor` | `COA_DungeonRun/map.lua:549` |
| — | ★★ | WHICH LISTS a layer keeps is the LAYER'S to declare (§61) | `Map.PointsOn` | `COA_DungeonRun/map.lua:571` |
| — | ★★ | SKIP IS DERIVED, never another decision to make - window / 10, floored | `Map.SkipStep` | `COA_DungeonRun/map.lua:654` |
| — | ★★ | §48's LADDER, in order, each rung only NARROWING what the one above left | `Map.VisibleOn` | `COA_DungeonRun/map.lua:794` |
| — | ★★ | ONE PLACE draws everything, from every loaded layer, in layer order | `Map.Painted` | `COA_DungeonRun/map.lua:825` |
| — | ★★ | a BEACON DRAWS AS ITS ICON - the field the user picked, not a type we | `if point.kind == "beacon" then` | `COA_DungeonRun/map.lua:898` |
| — | ★★ | §34's boundary for the THIRD gesture - the map OWNS the right-click | `Map.AddOnEdit` | `COA_DungeonRun/map.lua:999` |
| — | ★★ | Describe is PURE, because it IS the whole readout - a wrong word here is | `Map.Describe` | `COA_DungeonRun/map.lua:1048` |
| — | ★★ | CLAMPED, because off the art is not a position | `Map.FractionAt` | `COA_DungeonRun/map.lua:1180` |
| — | ★★ | a ROUTE ALONE is a legitimate view - §61's none-option on the run slot | `if routeName then` | `COA_DungeonRun/map.lua:1326` |
| — | ★★ | §69 - THREE GESTURES on one object: hover reads, left click selects | `d:RegisterForClicks` | `COA_DungeonRun/map.lua:1359` |
| — | ★★ | the OnUpdate exists ONLY while the drag is in flight - installed on | `d:RegisterForDrag` | `COA_DungeonRun/map.lua:1381` |
| — | ★★ | §20.2 - LOCATION SEEDS THE VIEW, read from the SAME calls capture used | `context` | `COA_DungeonRun/map.lua:1481` |
| — | ★★ | ONE CONTENT SOURCE, TWO PRESENTATIONS - both render Map.Describe, so the | `READOUT_ROWS` | `COA_DungeonRun/map.lua:1499` |
| — | ★★ | the NOTE PLANE is LOAD-DRIVEN like every other layer - a plane that | `loaded.notes` | `COA_DungeonRun/map.lua:1648` |
| — | ★★ | NO ARGUMENT = NO RUN (§36) - the retirement of the auto-pick. Guessing | `Map.Show` | `COA_DungeonRun/map.lua:1686` |
| — | ★★ | ARMED, AND THIS EXACT OBJECT - one guard, not two. A second Draggable | `if not dot or dot.point ~= Map.MoveArmed` | `COA_DungeonRun/map.lua:1738` |
| — | ★★ | A CLICK DROPS IT - what he reached for, rather than the client's own | `canvas:EnableMouse` | `COA_DungeonRun/map.lua:1758` |
| — | ★★ | the button READS THE VIEW, never a stored index - it shows where you | `refreshControls` | `COA_DungeonRun/map.lua:1812` |
| — | ★★ | a pane that REMOVES an object asks for a redraw, and must not have to know | `applyView` | `COA_DungeonRun/map.lua:1931` |
| — | ★★ | §76 - THE ZOOM CONTROLS LIVE ON THE MAP, not in curation | `applyView` | `COA_DungeonRun/map.lua:1937` |
| — | ★★ | THE NEXT STAGE ABOVE WHERE YOU ARE, wrapping at the top - defined against | `Map.NextStage` | `COA_DungeonRun/map.lua:1985` |
| — | ★★ | THE COMMAND STRIP is his layout - one header row, and the bottom bar is | `local MARGIN, STRIP, FOOT = 16, 40, 14` | `COA_DungeonRun/map.lua:2097` |
| — | ★★ | HIGH, above the action bars - his: *"when you're using it, you're using | `frame:SetFrameStrata` | `COA_DungeonRun/map.lua:2119` |
| — | ★★ | all edit options of an object live in ITS OWN pane, not the creation surface | `(file)` | `COA_DungeonRun/object.lua:6` |
| — | ★★ | modules RESTORE FIRST, Core wipes shared tables SECOND - a module cannot | `(file)` | `COA_GuardianPlates/Core.lua:92` |
| — | ★★ | no spec->role INFERENCE TABLE will be built. UnitGroupRolesAssigned | `ns.playerRole` | `COA_GuardianPlates/Core.lua:345` |
| — | ★★ | a diagnostic hook logs UNCONDITIONALLY, outside the match branch - logging | `ns.GetSpeculativeAggroHookStatus` | `COA_GuardianPlates/Core.lua:1725` |
| — | ★★ | prefer a texture WE create and own over any frame the native driver owns | `HAND_ROLLED_GLOW_TEXTURE` | `COA_GuardianPlates/Core.lua:1775` |
| — | ★★ | orphan recovery is STOP FILTERING, not DETECTION - we hold no character | `Store.showAll` | `COA_Landmarks/store.lua:238` |
| — | ★★ | the driver's per-GUID grain is deliberately UNFOLDED - a KNOWN field we | `units` | `MancerLedger/core.lua:159` |

## FACTS

_Measured behaviour of the client or our own data._

| Fails | Wt | What | Governs | Where |
|---|---|---|---|---|
| **SILENT** | ★★★ | an UNSUPPORTED macro conditional and a currently-FALSE one are both | `ask` | `COA_DevDump/payload_macros.lua:29` |
| **SILENT** | ★★★ | under pcall ALL return values SHIFT BY ONE - UnitClass's TOKEN is the | `local okc, className, classToken = pcall` | `COA_DevDump/payload_macros.lua:88` |
| **SILENT** | ★★★ | C_Timer works on this fork but has NO ENUMERABLE MEMBERS - `pairs` | `OPAQUE` | `COA_DevDump/task_api.lua:478` |
| **SILENT** | ★★★ | `{ pcall(f) }` + `#` is a TRAP - a nil anywhere makes a sequence with | `collect` | `COA_DevDump/task_dump.lua:112` |
| **SILENT** | ★★★ | GetSpecializationInfo is NOT a pure getter - it runs ConvertOldSavedSpec, | `(file)` | `COA_DevDump/task_spec.lua:9` |
| **SILENT** | ★★★ | a `local function` referenced ABOVE its declaration resolves to a NIL | `local pendingKilledBy, pendingWhy   -- s` | `COA_DungeonRun/capture.lua:52` |
| **SILENT** | ★★★ | UnitExists returns 1, NOT true - never compare against `true` | `engagedBosses` | `COA_DungeonRun/capture.lua:118` |
| **SILENT** | ★★★ | AscensionUI.DeathRecap is readable ONLY at PLAYER_DEAD - CurrentRecap | `onPlayerDead` | `COA_DungeonRun/capture.lua:341` |
| **SILENT** | ★★★ | the coordinate space and the tile art are TWO DIFFERENT SIZES | `local TILE_COLS, TILE_ROWS, TILE_PX = 4` | `COA_DungeonRun/map.lua:42` |
| **SILENT** | ★★★ | WorldMapDetailFrame is 1002x668 (coordinates) while the tile art is 4x3x256 = 1024x768 | `Map.Offset` | `COA_DungeonRun/map.lua:1162` |
| **SILENT** | ★★★ | a TERRAIN MAP shifts the dungeon level by ONE - the client's own | `Map.TilePath` | `COA_DungeonRun/map.lua:1211` |
| **SILENT** | ★★★ | stage is a LABEL, not an array index - DeleteBeacon leaves gaps, and 4.1 is ordinary | `Routes.NextStage` | `COA_DungeonRun/routes.lua:172` |
| **SILENT** | ★★★ | CoA's classes are ENTIRELY CUSTOM - no Warrior/Paladin/Druid/DK, so | `if COA_GuardianPlatesDB.threatMode == 2` | `COA_GuardianPlates/EnemyPlates.lua:183` |
| **SILENT** | ★★★ | the `cond and X or Y` idiom BREAKS whenever X is itself falsy | `if stateName ~= "secure" and stateName ~` | `COA_GuardianPlates/EnemyPlates.lua:986` |
| **SILENT** | ★★★ | pcall's FIRST return is "did it error", NOT the callee's own boolean | `local ok2, shown = pcall(ns.ForceShowNat` | `COA_GuardianPlates/EnemyPlates.lua:1088` |
| **SILENT** | ★★★ | across a map boundary supertracking returns Invalid with distance 0.00 | `(file)` | `COA_Landmarks/beacon.lua:14` |
| **SILENT** | ★★★ | GetPlayerMapPosition returns 0,0 when the world map shows a DIFFERENT | `mapFraction` | `COA_Landmarks/store.lua:141` |
| **SILENT** | ★★★ | the mapID from GetCurrentPlayerPosition is the CONTINENT, not the zone | `mapFraction` | `COA_Landmarks/store.lua:150` |
| **SILENT** | ★★★ | CLEU on 3.3.5 is the classic VARARGS tuple - 1 ts, 2 sub, 3-5 src, 6-8 dst | `(file)` | `COA_PetGrid/feed_live.lua:4` |
| **SILENT** | ★★★ | OnTextChanged is DEFERRED a frame, COALESCED to one fire, and CHANGE-ONLY (measured) | `o:SetText` | `tools/smoke/harness.lua:99` |
| **SILENT** | ★★ | debugprofilestop can SILENTLY NOT ADVANCE - a 0ms observer cost means | `(file)` | `COA_DevDump/task_cleu.lua:24` |
| **SILENT** | ★★ | GetAddOnCPUUsage returns 0 unless scriptProfile is 1 AND the client has | `(file)` | `COA_DevDump/task_perf.lua:12` |
| **SILENT** | ★★ | native plates are WorldFrame children and smooth-stacking stretches | `(file)` | `COA_DevDump/task_plates.lua:4` |
| **SILENT** | ★★ | the client's map axes are SWAPPED AND NEGATED versus world axes, and | `solve3` | `COA_DungeonRun/calibrate.lua:70` |
| **SILENT** | ★★ | PLAYER_ENTERING_WORLD also fires on LOGIN and on every /reload | `onEnteringWorld` | `COA_DungeonRun/capture.lua:440` |
| **SILENT** | ★★ | RegisterForDrag has a MOVEMENT THRESHOLD - a small precise nudge | `handle` | `COA_DungeonRun/editor.lua:384` |
| **SILENT** | ★★ | frame level drives HIT TESTING as well as draw order, and ties | `RANK` | `COA_DungeonRun/map.lua:176` |
| **SILENT** | ★★ | GetCurrentMapAreaID() is OFF BY ONE from the internal mapID - the | `Map.MapIDOf` | `COA_DungeonRun/map.lua:516` |
| **SILENT** | ★★ | FLOOR INDEX IS NOT ROUTE ORDER - SFK_Run4 runs 1, 2, back to 1, 7, | `Map.FloorAt` | `COA_DungeonRun/map.lua:699` |
| **SILENT** | ★★ | a wrong ART KEY still renders - every wrong answer draws something, | `Map.ArtKey` | `COA_DungeonRun/map.lua:880` |
| **SILENT** | ★★ | written as a BRANCH, never `run and Map.ArtFor(...) or hereFile` | `if run then mapFile = Map.ArtFor(run, he` | `COA_DungeonRun/map.lua:1427` |
| **SILENT** | ★★ | GetCurrentMapDungeonLevel reports the floor the WORLD MAP IS SHOWING, | `mapFraction` | `COA_DungeonRun/store.lua:87` |
| **SILENT** | ★★ | the SAME creature is announced under TWO unit tokens at once | `ns.plateOwner` | `COA_GuardianPlates/Core.lua:130` |
| **SILENT** | ★★ | GetNamePlateForUnit FAILS at NAME_PLATE_UNIT_REMOVED time - 20/20 live | `ns.ResolvePlateForRemoval` | `COA_GuardianPlates/Core.lua:186` |
| **SILENT** | ★★ | UnitAffectingCombat(unit) is true only once a mob is ACTUALLY ENGAGED by | `ns.IsPotentialThreatUnit` | `COA_GuardianPlates/Core.lua:297` |
| **SILENT** | ★★ | PixelGlow_Start's auto dash-length goes NEGATIVE at N >= 20 - | `threatWarning` | `COA_GuardianPlates/Core.lua:925` |
| **SILENT** | ★★ | the native aggro frame is NOT healthBar.aggroHighlight - it is | `local okName, healthBarName = pcall(heal` | `COA_GuardianPlates/Core.lua:1282` |
| **SILENT** | ★★ | UnitDetailedThreatSituation's rawPercentage can EXCEED 100 and STOPS | `IsAnotherMemberApproachingAggro` | `COA_GuardianPlates/EnemyPlates.lua:354` |
| **SILENT** | ★★ | UnitDetailedThreatSituation returns nil ACROSS THE BOARD when you have | `GetThreatColorForUnit` | `COA_GuardianPlates/EnemyPlates.lua:518` |
| **SILENT** | ★★ | AutoComplete_Update / GetAutoCompleteResults is a C API that only ever | `splitAtCursor` | `COA_Landmarks/editor.lua:51` |
| **SILENT** | ★★ | EditBox OnTextChanged fires on DELETION too - completing on a shrink makes | `grew` | `COA_Landmarks/editor.lua:226` |
| **SILENT** | ★★ | GetCursorPosition() is in SCREEN pixels - divide it by the effective | `b:SetScript` | `COA_Landmarks/minimap.lua:59` |
| **SILENT** | ★★ | AtlasInfo[name] = {texture,w,h,left,right,top,bottom,flipH,flipV} - and | `setIcon` | `COA_Landmarks/pins.lua:27` |
| **SILENT** | ★★ | GetLeft/GetTop return values in the FRAME's scale space, not UIParent's | `db.topX` | `COA_PetGrid/core.lua:63` |
| **SILENT** | ★★ | nil-valued defaults are INVISIBLE to `pairs()` | `db.topX, db.topY = nil, nil  -- nil defa` | `COA_PetGrid/core.lua:346` |
| **SILENT** | ★ | InterfaceOptionsFrame_OpenToCategory must be called TWICE - the first | `pcall` | `COA_GuardianPlates/FriendlyPlates.lua:633` |
| **SILENT** | ★ | SelectQuestLogEntry ALSO fires on QUEST_TURNED_IN - UpdateSelectedQuest | `if _G.hooksecurefunc and _G.SelectQuestL` | `COA_Landmarks/beacon.lua:254` |
| — | ★★ | addon Lua CANNOT read files from disk - so a build can only be identified | `structuralFingerprint` | `COA_DevDump/task_callwitness.lua:237` |
| — | ★★ | _G is full of CYCLES and an unguarded walk hangs the client - but | `if seen[v] then` | `COA_DevDump/task_dump.lua:62` |
| — | ★★ | the fraction->world fit is a MAP constant, not a run constant (0.000203 yd worst, measured) | `(file)` | `COA_DungeonRun/calibrate.lua:48` |
| — | ★★ | a walkway 9.71 yd above its floor sits only 3.12 yd away on the map (measured) | `Driver.Reached` | `COA_DungeonRun/driver.lua:91` |
| — | ★★ | 3.3.5 has NO SetClipsChildren - a ScrollFrame viewport with the canvas as its | `local ZOOM_MIN, ZOOM_MAX = 1.0, 4.0` | `COA_DungeonRun/map.lua:282` |
| — | ★★ | ONE SECOND IS THE FLOOR - points carry `t` at second resolution, so a | `MIN_WIDTH` | `COA_DungeonRun/map.lua:637` |
| — | ★★ | the native UpdateHealthBorder / UpdateAggroHighlight ARE a complete tank-threat | `(file)` | `COA_GuardianPlates/AggroPlates.lua:10` |
| — | ★★ | debug.getupvalue sees closure-captured tables no _G scan can reach - | `ns.DumpFunctionUpvalues` | `COA_GuardianPlates/Core.lua:1661` |
| — | ★★ | "BackdropTemplate" is a RETAIL 8.0+ requirement - on 3.3.5 SetBackdrop | `GetOrCreateCopyFrame` | `COA_GuardianPlates/Core.lua:2529` |
| — | ★★ | GetSuperTrackedPosition's distance is ENGINE-computed 3D yards (mean | `local _, _, dist = C_SuperTrack.GetSuper` | `COA_Landmarks/beacon.lua:179` |
| — | ★★ | WORLD_MAP_UPDATE fires whenever the DISPLAYED map changes - the correct | `f` | `COA_Landmarks/pins.lua:156` |
| — | ★★ | at ADDON_LOADED a frame has NO rect yet - GetLeft() returns nil | `pinner` | `COA_PetGrid/core.lua:84` |
| — | ★★ | SavedVariables globals DO NOT EXIST while a file body executes - the DB | `NS.GetDb` | `MancerLedger/core.lua:532` |
| — | ★★ | its 2nd arg `userInput` is FALSE for a programmatic SetText, true when typed (measured) | `o:SetText` | `tools/smoke/harness.lua:100` |
| — | ★ | SetSpellByID may be ABSENT on this backported client - SetHyperlink("spell:<id>") | `(file)` | `COA_DevDump/task_tooltip.lua:10` |
| — | ★ | SetMapByID is NOT guaranteed present on this client - pcall it and let the | `pcall` | `COA_Landmarks/widget.lua:99` |

## OPEN

_**Not settled.** Each says what would settle it. ⚠ An open question dressed in real figures reads as a finding — which is how a trap gets quoted forward past its evidence. RULING and FACT both mean SETTLED; this is the third status, and it exists because a block can be well-researched and still not be an answer._

| Fails | Wt | What | Governs | Where |
|---|---|---|---|---|
| — | ★★ | does DungeonUsesTerrainMap() agree with the DBC floor mark? | `probe` | `COA_DungeonRun/core.lua:29` |

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
| `COA_DungeonRun/map.lua` | 9 | 72 | 18 | 20 |
| `tools/smoke/smoke_dungeonrunmap.lua` | 62 | 23 | 3 | 5 |
| `tools/smoke/smoke_dungeonrunpromoter.lua` | 42 | 25 | 4 | 13 |
| `COA_DevDump/task_api.lua` | 25 | 6 | 11 | 17 |
| `COA_DungeonRun/routes.lua` | 26 | 8 | 5 | 7 |
| `COA_DungeonRun/object.lua` | 15 | 6 | 3 | 9 |
| `COA_DungeonRun/promoter.lua` | 19 | 6 | 0 | 3 |
| `COA_DungeonRun/capture.lua` | 11 | 4 | 5 | 6 |
| `COA_DungeonRun/editor.lua` | 18 | 5 | 0 | 2 |
| `COA_GuardianPlates/Core.lua` | 2 | 12 | 1 | 9 |
| `tools/smoke/smoke_api.lua` | 6 | 7 | 2 | 5 |
| `tools/smoke/harness.lua` | 3 | 3 | 2 | 8 |
| `tools/smoke/smoke_dungeonrun.lua` | 12 | 2 | 0 | 2 |
| `COA_DungeonRun/driver.lua` | 9 | 4 | 0 | 1 |
| `COA_DungeonRun/calibrate.lua` | 7 | 3 | 0 | 1 |
| `COA_GuardianPlates/EnemyPlates.lua` | 0 | 2 | 3 | 5 |
| `COA_Landmarks/beacon.lua` | 4 | 1 | 2 | 3 |
| `COA_Landmarks/store.lua` | 4 | 1 | 3 | 2 |
| `COA_DevDump/task_cleu.lua` | 6 | 2 | 0 | 1 |
| `COA_DungeonRun/store.lua` | 6 | 1 | 2 | 0 |
| `tools/smoke/smoke_cleu.lua` | 8 | 1 | 0 | 0 |
| `tools/smoke/smoke_dungeonruncalibrate.lua` | 5 | 4 | 0 | 0 |
| `MancerLedger/core.lua` | 2 | 3 | 1 | 1 |
| `COA_PetGrid/core.lua` | 0 | 3 | 0 | 3 |
| `COA_Landmarks/editor.lua` | 2 | 2 | 0 | 2 |
| `COA_DevDump/task_dump.lua` | 1 | 1 | 1 | 2 |
| `COA_Landmarks/minimap.lua` | 2 | 2 | 0 | 1 |
| `COA_Landmarks/pins.lua` | 1 | 2 | 1 | 1 |
| `COA_DevDump/payload_macros.lua` | 1 | 0 | 2 | 1 |
| `COA_GuardianPlates/FriendlyPlates.lua` | 1 | 1 | 1 | 1 |
| `COA_Landmarks/core.lua` | 2 | 0 | 2 | 0 |
| `COA_DevDump/task_callwitness.lua` | 0 | 1 | 1 | 1 |
| `COA_DungeonRun/core.lua` | 1 | 1 | 0 | 1 |
| `COA_DevDump/task_perf.lua` | 0 | 1 | 0 | 1 |
| `COA_DevDump/task_plates.lua` | 0 | 1 | 0 | 1 |
| `COA_DevDump/task_spec.lua` | 0 | 0 | 1 | 1 |
| `COA_GuardianPlates/AggroPlates.lua` | 1 | 1 | 0 | 0 |
| `COA_StatePlates_Aggro/Options.lua` | 1 | 0 | 1 | 0 |
| `COA_DungeonRun/widget.lua` | 1 | 1 | 0 | 0 |
| `tools/smoke/smoke_dump.lua` | 2 | 0 | 0 | 0 |
| `COA_DevDump/core.lua` | 1 | 0 | 0 | 0 |
| `COA_DevDump/task_petlog.lua` | 0 | 0 | 0 | 1 |
| `COA_DevDump/task_tooltip.lua` | 1 | 0 | 0 | 0 |
| `COA_PetGrid/feed_live.lua` | 0 | 0 | 1 | 0 |
| `COA_Landmarks/widget.lua` | 1 | 0 | 0 | 0 |
| **TOTAL** | **320** | **218** | **76** | **137** |

⚠ **A file with hundreds of marks and no ★★★, beside one written in an afternoon with several, is not a ranking — it is a record of who was excited when.** That is the shape to watch for here.

---

## The convention

```lua
-- ★★ RULING: <one line>   weight, then kind. Either may stand alone.
-- FACT: <one line>        measured behaviour of the client or our data
```

On its own line inside the comment block that already explains it. The body stays in the file; this carries only the headline, what it governs, and where.

⚠ **`Governs` is emitted, never typed** — a hand-kept scope goes stale the moment a function moves, which is the rot this exists to avoid.
