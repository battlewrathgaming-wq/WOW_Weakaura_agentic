# The intent shelf — what we reach for, and what already answers it

_The addons bench's own list. **Sized to our use case, not to WoW.** Reach here for
DIRECTION before working out which of 51,855 globals applies._

## Why this exists

I ran five live probe cycles to establish that `OnTextChanged` passes a `userInput` flag —
an idiom **already in `COA_Landmarks/editor.lua`, and shipped**. My first reading was that I
should have grepped harder. Battlewrath's, which is the right one:

> *"Only stands if the expectation is to know and always use the correct input form, or, more, an
> expectation to perfectly track what functions exist (stock, custom). And then perfectly input them
> when required. So to me that leads to better cataloguing on our side."*

★ **Recall is mechanical work, so it gets an index rather than a resolution to try harder.** Blaming
diligence for a lookup failure is how you get the same failure again with guilt attached.

## How to use it

**Intent first.** Everything else the bench has is name-indexed — the census lists every global,
`maps/addons/<Addon>/routes.md` lists every function we define — and a name index only helps once you
already know the name, which is exactly the moment that fails. Intent is what you have when you start.

**The ladder: intent → stock → ours → invent.** You only invent when the first three are empty *and
you can see they are empty.* That is the whole job of this page.

⚠ **Stock is ranked first on purpose.** Inheriting the client's own vocabulary beats a wrapper
(`source-as-truth, no creator dialect`). A row where "ours" exists and "stock" is blank is worth a
second look — sometimes it means there was no stock answer, and sometimes it means nobody checked.

---

| Intent | Stock | Custom (ours) |
|---|---|---|
| **know a text edit came from a HUMAN** | `OnTextChanged`'s 2nd arg `userInput` — **false** for a programmatic `SetText`, true when typed *(measured, api run 5)* | — · `COA_Landmarks` hand-rolled `s.suppress` before we knew |
| **know when text actually changed** | `OnTextChanged` is **deferred a frame, coalesced to one fire, and CHANGE-ONLY** — setting the same value fires nothing *(measured)* | — |
| **point the super tracker** | `SuperTrackerUtil.SetSuperTrackedPosition(x, y, z, mapID)` | — · ⚠ **AC-17: `C_SuperTrack.SetSuperTrackedPosition` skips the priority ladder and is silently overwritten.** Looks right, isn't |
| **the player's world position** | `GetCurrentPlayerPosition()` → x, y, z, **mapID** | ⚠ the 4th return is the **internal** mapID, NOT `GetCurrentMapAreaID` (765 vs 33 in SFK, measured) |
| **which floor / how many** | `GetCurrentMapDungeonLevel()` · `GetNumDungeonMapLevels()` | `Map.Floor()` · `Map.StepFloor()` |
| **map fraction ↔ world yards** | — | `NS.Calibrate` — a 6-param affine **fitted from our own captures**, per mapID |
| **is a point close enough** | — | `Driver.Reached(px,py,pz, bx,by,bz, radius, band)` — planar **and** vertical, never one alone |
| **am I in an instance** | `IsInInstance()` | ⚠ returns **1**, not `true` (plus the type string). Guard with truthiness, never `== true` |
| **crop a texture** | `SetTexCoord` **after** `SetTexture` | `Map.TileRect(i)` · ⚠ the crop is **NOT** reset by `SetTexture` on the raw API *(measured — §19's reset is a stock Lua wrapper we never use)* |
| **run every frame, then stop** | `SetScript("OnUpdate", fn)` / `(…, nil)` | ⚠ the census counts installs vs clears; **zero persistent** is the bench standard |
| **pace work across frames** | — | `D.Cycle(step, perFrame, onDone)` — also how a probe waits out a deferred event |
| **a unit's name / class** | `UnitName(unit)` · `UnitClass(unit)` | ⚠ **these THROW on nil or a bad unit**, they do not return nil *(measured)*. Same for `UnitIsGhost`, `GetPlayerMapPosition`, `GetCVar`, `GetDifficultyInfo` |
| **say something to the user** | `DEFAULT_CHAT_FRAME:AddMessage` | `NS.Say` — and the bench rule is **by exception**: one line per run, not a commentary |
| **persist UI state** | — | `Store.SetUI(key, v)` / `Store.GetUI()` · ⚠ store `nil` to clear, never `false` — the store is by-exception |
| **one record per capture** | — | `D.Begin(task, args)` → payload → `D.Commit(summary)`; the watcher lands it |
| **what does the client offer at all** | — | `addons/maps/census/` (51,855 globals) · `maps/atlas/` · `maps/worldmap/` |
| **what do WE define** | — | `addons/maps/addons/<Addon>/routes.md`, machine-emitted per file |

---

## The rules that keep it usable

★ **It grows BY EXCEPTION, from the moments we reached and missed.** Every row above was earned —
by being wrong, or by measuring. Assigning intent to 51,855 globals up front produces a document
nobody finishes and nobody trusts.

★ **The mechanical half is never hand-typed.** Signatures, existence, and who-defines-what already
live in `maps/` and the census. This page is the **direction** layer over them, and duplicating their
content would just create a second thing to go stale.

⚠ **A trap belongs beside its answer, not in a lessons file.** `C_SuperTrack` and
`GetCurrentMapAreaID` both look correct and both cost real sessions. A catalogue that lists only
right answers does not stop you taking the convincing wrong one.

⚠ **Measured facts say so.** *(measured)* means a live run proved it — mostly
`addons/planning/api_probe_runsheet.md`. Anything unmarked is inherited from reading, and inherited
readings are how §19's trap got generalised into a fiction that shaped the test suite for months.
