# The intent shelf — reach here for direction

_The addons bench's own list. **Sized to our use case, not to WoW.** You arrive knowing what you want
to DO; this says what is in play for it._

**Routing:** [pre-flight](#the-pre-flight) · [where am I](#where-am-i-and-where-is-that) · [typing](#text-fields-and-typing) ·
[**visual**](#visual--pixels-scale-and-coordinate-spaces) · [frames and cost](#frames-timing-and-cost) ·
[what is on the map now](#what-is-on-the-map-right-now) · [calls that THROW](#calls-that-throw-rather-than-return-nil) ·
[records](#records-and-persistence) · [**shapes**](#shapes--solved-structures-not-functions) · [when this shelf is empty](#when-this-shelf-is-empty)

## Why it exists

I ran five live probe cycles to establish that `OnTextChanged` passes a `userInput` flag — an idiom
**already shipped in `COA_Landmarks/editor.lua`**. My reading was *"I should have grepped harder."*
Battlewrath's was better:

> *"Only stands if the expectation is to know and always use the correct input form, or, more, an
> expectation to perfectly track what functions exist (stock, custom)... So to me that leads to
> better cataloguing on our side."*

★ **Recall is mechanical work, so it gets an index rather than a resolution to try harder.**

## The pre-flight

**Before a `Build!`, in the discussion — not mid-build.** Three questions, answered in a line or two:

1. **Intent** — is there a row for this? (this page)
2. **Shape** — is the structure already solved? ([shapes](#shapes--solved-structures-not-functions))
3. **Ruling** — does one govern it? (`addons/maps/notes.md`, or grep it)

★★ **It belongs in the discussion because that is where we have already stopped.** Mid-build the
momentum is toward writing, and consulting anything is a context switch nobody takes — his: *"the
step normally is invent, as you're building something."* At the point we are talking about what to
build, looking it up costs nothing.

★ **"Nothing on any of the three" is a complete answer**, and stating it is the point: the empty
result becomes **deliberate** rather than unexamined, and that is the whole difference between
inventing and re-inventing.

## How to read a row

**`Picked` is what is actually in play** — not a menu. It carries its origin: **`stock`** (the
client's own) or **`ours`**.

★★ **A row picked `ours` must say what stock lacked.** His point, and it is the stronger half: it
does not just rank stock first, **it forces you to establish what stock even IS.** You cannot write
*"no stock answer"* without having looked — so the search happens once, here, and everyone after
reads the result instead of repeating it. A row picked `ours` with no such note is **visibly
incomplete**.

★★ **THE FIRST CHALLENGE TO THIS PAGE FOUND A WRONG ROW**, which is the shelf working rather than
failing. I wrote *"no stock scheduler on 3.3.5"*; he said *"I'm sure we used it as a scheduler (wake
me in 2 secs)"*, and he was right — and the row contradicted **a ruling of his already recorded in
another addon.** ⚠ It was an **unmarked** note, i.e. inherited from reading, which is exactly the
class this page flags as challengeable. **Challenge unmarked rows.**

⚠ **`(measured)` means a live run proved it** — mostly `addons/planning/api_probe_runsheet.md`.
Unmarked notes are inherited from reading, and an inherited reading is how §19's trap got generalised
into a fiction that shaped the test suite for months.

---

## Where am I, and where is that?

| Intent | Picked | Notes |
|---|---|---|
| the player's world position | `GetCurrentPlayerPosition()` · stock | → x, y, z, **mapID**. ⚠ the 4th return is the **internal** mapID, **not** `GetCurrentMapAreaID` — 33 vs 765 in SFK *(measured)* |
| which floor am I on / how many are there | `GetCurrentMapDungeonLevel()` · `GetNumDungeonMapLevels()` · stock | 7 for Shadowfang *(measured)* |
| am I in an instance | `IsInInstance()` · stock | ⚠ returns **`1`, not `true`** (plus the type string) *(measured)*. Test truthiness, never `== true` |
| map fraction ↔ world **yards** | `NS.Calibrate` · **ours** | **No stock answer**: the client gives fractions and it gives yards, and relates them nowhere. A 6-param affine fitted per mapID from our own captures. ★ **World space — the screen-side half is `Map.FractionAt` under [visual](#visual--pixels-scale-and-coordinate-spaces)**, and the two chain: cursor → fraction → yards |
| is a point close enough to count | `Driver.Reached(px,py,pz, bx,by,bz, r, band)` · **ours** | **No stock proximity test.** Planar **and** vertical, never one alone — a walkway 9.71 yd up sits 3.12 yd away on the map |
| point the super tracker at a spot | `SuperTrackerUtil.SetSuperTrackedPosition(x,y,z,mapID)` · stock | ⚠ **PUSH — changes client state.** ⚠ **AC-17:** the `C_SuperTrack.*` form looks right, skips the priority ladder, and is silently overwritten |

## Text fields and typing

| Intent | Picked | Notes |
|---|---|---|
| know an edit came from a **human** | `OnTextChanged`'s 2nd arg `userInput` · stock | **`false`** for a programmatic `SetText`, true when typed *(measured)*. `COA_Landmarks` hand-rolled `s.suppress` before we knew this existed |
| know **when** the handler fires | — · stock behaviour | **Deferred** a frame · **coalesced** to one fire however many sets · **change-only**, so setting the same value fires nothing *(measured)*. §81's "unbounded freeze" rested on the opposite and was never real |
| read the field inside the handler | `GetText()` · stock | ⚠ the handler sees the **final** text, not the value that triggered it — a raced `first`/`second` reports `second` *(measured)* |

## Visual — pixels, scale and coordinate spaces

_★ The boundary that makes this section honest: **screen and texture space live here; WORLD space
lives under [where am I](#where-am-i-and-where-is-that)**. A cursor is screen space, a yard is world
space, and the bugs happen where someone subtracts one from the other._

| Intent | Picked | Notes |
|---|---|---|
| turn a **cursor position** into frame coordinates | `GetCursorPosition()` ÷ `<frame>:GetEffectiveScale()` · stock | ⚠⚠ **Divide by the scale of the FRAME you compare against**, never `UIParent`'s unless that IS the frame. Mixing two scale spaces is **masked while they match** — the default — so it is correct by coincidence until something rescales. Cost a latent bug in `COA_Landmarks/minimap.lua` while `MancerLedger` had it right: **the bench held the bug and its fix, and neither site carried a comment** |
| screen point → map fraction | `Map.FractionAt(cx, cy, scale, left, top)` · **ours** | **No stock answer** for our own canvas. ★ It takes the scale as a **PARAMETER** and reads `GetLeft`/`GetEffectiveScale` **live** — which is why zoom and pan cost it nothing, and why it never mixed spaces |
| crop a texture | `SetTexCoord` **after** `SetTexture` · stock | ⚠ the crop **SURVIVES** a new texture on the raw API *(measured)*. §19's reset lives in a stock Lua wrapper (the POI mixin path) that this bench never goes through |
| crop a dungeon tile to the map space | `Map.TileRect(i)` · **ours** | **No stock geometry** for a 4×3×256 art grid against a 1002×668 coordinate space; the client's own map clips the padding rather than exposing it |

## Frames, timing and cost

| Intent | Picked | Notes |
|---|---|---|
| run every frame, then stop | `SetScript("OnUpdate", fn)` / `(…, nil)` · stock | The census counts installs vs clears; **zero persistent** is the bench standard |
| **wake me in N seconds** | `C_Timer.After(delay, fn)` · stock | ⚠ **This row was WRONG on its first outing** — it said *"no stock scheduler, `C_Timer` is absent"*, and Battlewrath challenged it. `C_Timer` is **a genuine Ascension client global, not a shim** (`COA_GuardianPlates` Core.lua:503 uses it; TurboPlates relies on it directly). His ruling, already recorded in v3.5.5: *"we don't engrain custom internal clocks when we can have the game do it for us"* |
| step work across **FRAMES** | `D.Cycle(step, perFrame, onDone)` · **ours** | **What stock lacks:** `C_Timer.After` waits in **seconds**, and this needs **frames** — paced walking (the census does 400 keys/frame) and frame-accurate spacing (the api probe separates events by exactly 60 frames). ⚠ Reach for `C_Timer.After` first; this is only for when the unit really is a frame |
| what else does `C_Timer` offer | **unknown** | ⚠ `NewTicker`/`Cancel` are **unverified here**. The census records `C_Timer` as a table with **no enumerable members**, so a name search finds nothing — see the warning under *when this shelf is empty* |
| measure what something costs | `debugprofilestop()` · stock | The driver self-measures with it: 0.0061 ms/scan over 7079 scans *(measured)* |

## What is on the map right now

| Intent | Picked | Notes |
|---|---|---|
| what is selected | `Map.Selected()` · `Map.AddOnSelect(fn)` · **ours** | **No stock answer** — these are our own frames. ⚠ a **registry**, not a single slot: two panes both listen, and one slot let whichever initialised last silently take it (§63) |
| what is loaded / what am I authoring against | `Map.LoadedId("run"\|"route")` · `Map.AuthoringMapID()` · **ours** | **No stock answer.** ⚠ authoring follows what is **LOADED**; the in-route driver follows where the **PLAYER** is (§64) |
| a route's running order | `Routes.StageOrder(id)` · **ours** | **No stock answer.** Sorted by stage **value** — stage is a label, not an index, and deleting leaves gaps |

## Calls that THROW rather than return nil

| Intent | Picked | Notes |
|---|---|---|
| a unit's name / class / state | `UnitName(u)` · `UnitClass(u)` · stock | ⚠ **THROW on nil or a bad unit** — `Usage: ...` *(measured)*. `local n = UnitName(u); if not n then` never reaches its check |
| the same trap, same fix | `UnitIsGhost` · `GetPlayerMapPosition` · `GetCVar` · `GetDifficultyInfo` · `GetAddOnMetadata` · stock | ⚠ all throw *(measured)*. `GetDifficultyInfo` throws from **inside the client's own** `GlobalFunctions.lua:263` |

## Records and persistence

| Intent | Picked | Notes |
|---|---|---|
| say something to the user | `NS.Say(msg)` · **ours** | Wraps `DEFAULT_CHAT_FRAME:AddMessage`, which stock provides — **ours exists for the POLICY, not the plumbing**: by exception, one line per run, never a commentary |
| persist UI state | `Store.SetUI(k, v)` · `Store.GetUI()` · **ours** | **No stock answer** beyond raw SavedVariables. ⚠ store `nil` to clear, never `false` — the store is by-exception |
| one record per capture | `D.Begin(task, args)` → payload → `D.Commit(summary)` · **ours** | **No stock answer.** The watcher lands it into `addons/landing/records/` |

## Shapes — solved structures, not functions

_A shape is not a call. It is a **structure we worked out once**, and it is what gets re-invented
because each addon builds into a new lane of one that already solved it._

| Shape | Picked | Notes |
|---|---|---|
| a callback with **more than one listener** | a **registry**, never a single slot | ⚠ §63: the curation pane and the object pane both listen for the selection. One slot let **whichever initialised last silently take it**, and the other pane simply never updated — which reads as a dead pane, not as a wiring fault. `Map.AddOnSelect` / `AddOnEdit` |
| creating a thing that needs **meaning** later | **create then edit** | The object exists the moment you press the button, carrying only what it inherited; name, cue, radii are edited in-field afterwards. Capture then promote · pin then meaning · mint then author. ★ **The mechanical part is immediate and the meaning waits** — which is also why none of the three needs a dialog |
| an object that gets **moved or corrected** | **new else original** | Keep what it was born as, add what it became, and read the pair. §68's drag, §80's ghost text. ★ *"How we got here"* survives export and works on someone else's machine, which a back-reference to the source never could |
| work that must run **while something is happening** | **transient handler** — install on arm, clear on stop | The census counts installs vs clears; **zero persistent OnUpdate** is the bench standard. A handler that outlives its gesture is a cost nobody asked for |
| reporting a run to a human | **the by-exception envelope** | One record per run, **one chat line**, and silence when nothing happened. `D.Begin` → payload → `D.Commit`. ⚠ A tool that narrates is one people stop reading |
| proving something **did not** happen | **control before conclusion** | ⚠ A claim of absence is unfalsifiable until the detector is shown to work. `SetChecked does NOT fire OnClick` was worthless until the probe **clicked the button first** — in a run where everything measured zero, it "agreed" for entirely the wrong reason |
| a guard whose failure case **no fixture reaches** | **build the fixture, or file no mutation** | ⚠ The most common weak test this bench produces. Either construct the case (a throwing API stub, `breakReadback`) or record that none could bite — never leave a guard that cannot fail looking like coverage |

## When this shelf is empty

| Intent | Picked | Notes |
|---|---|---|
| what does the client offer at all | `addons/maps/census/` · `maps/atlas/` · `maps/worldmap/` | Machine-emitted, name-indexed. **51,855 globals** — the reason this shelf exists. ⚠⚠ **AND IT HAS HOLES:** `C_Timer` enumerates as an **empty table**, so `C_Timer.After` appears nowhere in it despite working. **A name search proving absence proves nothing** — check `grep` over our own addons too |
| what do WE define | `addons/maps/addons/<Addon>/routes.md` | Machine-emitted per file, never hand-edited |
| has anyone measured it | `addons/planning/api_probe_runsheet.md` · `/coadump r api` | The instrument for turning a reading into a *(measured)* |
| ★ **is there a ruling about this already** | `addons/maps/notes.md` | Emitted index of every `RULING:` / `FACT:` living in the code. ⚠ **This shelf's C_Timer row was wrong because a ruling sat unread in another addon** — grep that index before writing a new row here |

---

⚠ **It grows BY EXCEPTION**, from the moments we reached and missed. Every row above was earned — by
being wrong, or by measuring. Assigning intent to 51,855 globals up front produces a document nobody
finishes and nobody trusts.

⚠ **The mechanical half is never hand-typed.** Signatures, existence and who-defines-what already
live in `maps/` and the census; this is the **direction** layer over them.

⚠ **No line index, deliberately.** Line ranges rot on the first inserted row — the same rot that
moved eight mutation anchors in one session. If this outgrows a scroll, the index gets **generated**
with a `--check` mode like the census has. The trigger is *"I scrolled past what I wanted twice"*,
not a guess now.
