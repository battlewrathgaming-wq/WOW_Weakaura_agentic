# Notes in the code — rulings and measured facts

_Emitted by `addons/tools/emit_notes.py`. **Never hand-edited.**_

★★ **The notes live WITH THE CODE and this does not move them.** Proximity is what makes them work — you are already in the block one governs, and you did not have to know it existed. This is a **pointer** so they are also findable from outside the file, which is the failure it was built for: a ruling about timers sat in `COA_GuardianPlates` for a month while the intent shelf claimed the opposite.

★ **The tag is the pruning decision.** A block earns `RULING:` or `FACT:` only when it is **settled** — that is what keeps this an inventory rather than a second log of uncertainties.

**6 ruling(s) · 6 fact(s).**

## RULINGS

_Decisions and their reasoning. Mostly his._

| What | Governs | Where |
|---|---|---|
| capture is the ONLY spawn - everything downstream inherits, nothing derives | `(file)` | `COA_DungeonRun/capture.lua:29` |
| we hold WHAT HAPPENED, never what the world is or what it meant | `(file)` | `COA_DungeonRun/capture.lua:30` |
| the driver INFORMS, it never grades - no completion count, no "you missed" | `Driver.Reached` | `COA_DungeonRun/driver.lua:92` |
| all edit options of an object live in ITS OWN pane, not the creation surface | `(file)` | `COA_DungeonRun/object.lua:6` |
| PLACE carries, EVENT does not - a beacon is a statement about a SPOT | `PLACE` | `COA_DungeonRun/routes.lua:48` |
| don't engrain custom internal clocks when the game can do it for us | `recheckPending` | `COA_GuardianPlates/Core.lua:476` |

## FACTS

_Measured behaviour of the client or our own data._

| What | Governs | Where |
|---|---|---|
| the fraction->world fit is a MAP constant, not a run constant (0.000203 yd worst, measured) | `(file)` | `COA_DungeonRun/calibrate.lua:48` |
| a walkway 9.71 yd above its floor sits only 3.12 yd away on the map (measured) | `Driver.Reached` | `COA_DungeonRun/driver.lua:91` |
| WorldMapDetailFrame is 1002x668 (coordinates) while the tile art is 4x3x256 = 1024x768 | `Map.Offset` | `COA_DungeonRun/map.lua:990` |
| stage is a LABEL, not an array index - DeleteBeacon leaves gaps, and 4.1 is ordinary | `Routes.NextStage` | `COA_DungeonRun/routes.lua:172` |
| OnTextChanged is DEFERRED a frame, COALESCED to one fire, and CHANGE-ONLY (measured) | `o:SetText` | `tools/smoke/harness.lua:99` |
| its 2nd arg `userInput` is FALSE for a programmatic SetText, true when typed (measured) | `o:SetText` | `tools/smoke/harness.lua:100` |

---

## The convention

```lua
-- RULING: <one line>      a decision and its reasoning
-- FACT:   <one line>      measured behaviour of the client or our data
```

On its own line inside the comment block that already explains it. The body stays in the file; this carries only the headline, what it governs, and where.

⚠ **`Governs` is emitted, never typed** — a hand-kept scope goes stale the moment a function moves, which is the rot this exists to avoid.
