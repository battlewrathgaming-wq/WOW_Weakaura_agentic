# Notes in the code — rulings and measured facts

_Emitted by `addons/tools/emit_notes.py`. **Never hand-edited.**_

★★ **The notes live WITH THE CODE and this does not move them.** Proximity is what makes them work — you are already in the block one governs, and you did not have to know it existed. This is a **pointer** so they are also findable from outside the file, which is the failure it was built for: a ruling about timers sat in `COA_GuardianPlates` for a month while the intent shelf claimed the opposite.

★ **The tag is the pruning decision.** A block earns `RULING:` or `FACT:` only when it is **settled** — that is what keeps this an inventory rather than a second log of uncertainties.

**6 ruling(s) · 9 fact(s) · 1 open.**

## RULINGS

_Decisions and their reasoning. Mostly his._

| Wt | What | Governs | Where |
|---|---|---|---|
| ★★★ | capture is the ONLY spawn - everything downstream inherits, nothing derives | `(file)` | `COA_DungeonRun/capture.lua:29` |
| ★★★ | we hold WHAT HAPPENED, never what the world is or what it meant | `(file)` | `COA_DungeonRun/capture.lua:30` |
| ★★★ | PLACE carries, EVENT does not - a beacon is a statement about a SPOT | `PLACE` | `COA_DungeonRun/routes.lua:48` |
| ★★ | the driver INFORMS, it never grades - no completion count, no "you missed" | `Driver.Reached` | `COA_DungeonRun/driver.lua:92` |
| ★★ | all edit options of an object live in ITS OWN pane, not the creation surface | `(file)` | `COA_DungeonRun/object.lua:6` |
| ★★ | don't engrain custom internal clocks when the game can do it for us | `recheckPending` | `COA_GuardianPlates/Core.lua:476` |

## FACTS

_Measured behaviour of the client or our own data._

| Wt | What | Governs | Where |
|---|---|---|---|
| ★★★ | WorldMapDetailFrame is 1002x668 (coordinates) while the tile art is 4x3x256 = 1024x768 | `Map.Offset` | `COA_DungeonRun/map.lua:990` |
| ★★★ | stage is a LABEL, not an array index - DeleteBeacon leaves gaps, and 4.1 is ordinary | `Routes.NextStage` | `COA_DungeonRun/routes.lua:172` |
| ★★★ | CLEU on 3.3.5 is the classic VARARGS tuple - 1 ts, 2 sub, 3-5 src, 6-8 dst | `(file)` | `COA_PetGrid/feed_live.lua:4` |
| ★★★ | OnTextChanged is DEFERRED a frame, COALESCED to one fire, and CHANGE-ONLY (measured) | `o:SetText` | `tools/smoke/harness.lua:99` |
| ★★ | debugprofilestop can SILENTLY NOT ADVANCE - a 0ms observer cost means | `(file)` | `COA_DevDump/task_cleu.lua:24` |
| ★★ | the fraction->world fit is a MAP constant, not a run constant (0.000203 yd worst, measured) | `(file)` | `COA_DungeonRun/calibrate.lua:48` |
| ★★ | a walkway 9.71 yd above its floor sits only 3.12 yd away on the map (measured) | `Driver.Reached` | `COA_DungeonRun/driver.lua:91` |
| ★★ | GetCursorPosition() is in SCREEN pixels - divide it by the effective | `b:SetScript` | `COA_Landmarks/minimap.lua:56` |
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
| `COA_DungeonRun/editor.lua` | 17 | 3 | 0 | 1 |
| `tools/smoke/smoke_api.lua` | 6 | 7 | 2 | 5 |
| `COA_DungeonRun/capture.lua` | 11 | 3 | 2 | 3 |
| `COA_DungeonRun/object.lua` | 9 | 4 | 1 | 5 |
| `tools/smoke/harness.lua` | 3 | 3 | 2 | 8 |
| `tools/smoke/smoke_dungeonrun.lua` | 12 | 2 | 0 | 2 |
| `COA_DungeonRun/driver.lua` | 9 | 4 | 0 | 1 |
| `COA_DevDump/task_cleu.lua` | 6 | 2 | 0 | 1 |
| `COA_DungeonRun/calibrate.lua` | 7 | 2 | 0 | 0 |
| `tools/smoke/smoke_cleu.lua` | 8 | 1 | 0 | 0 |
| `tools/smoke/smoke_dungeonruncalibrate.lua` | 5 | 4 | 0 | 0 |
| `COA_DungeonRun/store.lua` | 5 | 0 | 0 | 0 |
| `COA_DungeonRun/core.lua` | 1 | 1 | 0 | 1 |
| `COA_Landmarks/beacon.lua` | 3 | 0 | 0 | 0 |
| `COA_Landmarks/minimap.lua` | 1 | 1 | 0 | 1 |
| `COA_DungeonRun/widget.lua` | 1 | 1 | 0 | 0 |
| `COA_Landmarks/editor.lua` | 2 | 0 | 0 | 0 |
| `COA_Landmarks/store.lua` | 2 | 0 | 0 | 0 |
| `tools/smoke/smoke_dump.lua` | 2 | 0 | 0 | 0 |
| `COA_DevDump/core.lua` | 1 | 0 | 0 | 0 |
| `COA_DevDump/task_dump.lua` | 1 | 0 | 0 | 0 |
| `COA_DevDump/task_petlog.lua` | 0 | 0 | 0 | 1 |
| `COA_GuardianPlates/Core.lua` | 0 | 1 | 0 | 0 |
| `COA_PetGrid/feed_live.lua` | 0 | 0 | 1 | 0 |
| **TOTAL** | **348** | **127** | **22** | **67** |

⚠ **A file with hundreds of marks and no ★★★, beside one written in an afternoon with several, is not a ranking — it is a record of who was excited when.** That is the shape to watch for here.

---

## The convention

```lua
-- ★★ RULING: <one line>   weight, then kind. Either may stand alone.
-- FACT: <one line>        measured behaviour of the client or our data
```

On its own line inside the comment block that already explains it. The body stays in the file; this carries only the headline, what it governs, and where.

⚠ **`Governs` is emitted, never typed** — a hand-kept scope goes stale the moment a function moves, which is the rot this exists to avoid.
