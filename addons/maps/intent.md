# The intent shelf — reach here for direction

_The addons bench's own list. **Sized to our use case, not to WoW.** You arrive knowing what you want
to DO; this says what is in play for it._

**Routing:** [pre-flight](#the-pre-flight) · [**what it carries**](#-what-the-shelf-carries-and-why) · [where am I](#where-am-i-and-where-is-that) · [typing](#text-fields-and-typing) ·
[**visual**](#visual--pixels-scale-and-coordinate-spaces) · [frames and cost](#frames-timing-and-cost) ·
[what is on the map now](#what-is-on-the-map-right-now) · [calls that THROW](#calls-that-throw-rather-than-return-nil) ·
[**combat & death**](#combat-state-and-death) · [**CLEU**](#combat-log-cleu) · [records](#records-and-persistence) · [**shapes**](#shapes--solved-structures-not-functions) · [when this shelf is empty](#when-this-shelf-is-empty)

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

## ★★★ What the shelf carries, and why

`addons/maps/notes.md` indexes **every** tagged ruling and fact. This shelf carries far fewer, and
the rule is his:

> *"Some are taste and preference. Some are things that will make the written code fail silently /
> loudly / throw error."*

| the note | who teaches it | belongs |
|---|---|---|
| **fails SILENTLY** | **nobody.** It produces something that looks like it worked | ★★★ **the shelf** — this is the only class you cannot learn by doing |
| **throws / hangs / renders nothing** | the client, the first time | the index. Expensive once, then learned |
| **a design decision** | the ruling itself, when you read the file | the index, and the file it governs |
| ★★★ **CULTURE** — manners on someone else's machine | **nobody, ever.** No test goes red. No client breaks | ★★★ **the shelf** — writing it down is the *only* protection it has |

★★★ **SILENT and CULTURE are the two that most need writing down, and for opposite reasons.** His,
on *"a plugin owns no machinery; loading it declares interest"*:

> *"This is about culture. How we decide to be respectful on someone's machine. Nothing that will
> ever manifest in code rejection or be 'bad code'."*

Silent because the failure **hides**. Culture because there **is no failure** — it just quietly
becomes an addon that takes more than it was given. Baseline-off · no borrowed clocks · nothing that
nags · nothing that judges · read-only on data that is not ours · zero persistent `OnUpdate` · one
line of chat, not a commentary.

⚠ **31 of 42 tagged facts are SILENT.** That is not a detail about the notes — it is what this bench
has actually been paying for. A shelf that carried everything would be a second index; a shelf that
carries the silent set is the thing you could not have worked out for yourself.

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

## Combat state and death

_★ Both are **multi-source** on 3.3.5, and the cross-checks are where the work is._

| Intent | Picked | Notes |
|---|---|---|
| ★★★ **know if the player is in combat** | `UnitAffectingCombat("player")` · stock — read **fresh** | ★★ **DR-1: EDGES FROM THE EVENTS, STATE FROM THE API.** `PLAYER_REGEN_DISABLED`/`_ENABLED` are markers only — two events, no filtering, none of CLEU's cost. ⚠ **`PLAYER_REGEN_ENABLED` also fires when lockdown lifts for reasons that are not a pull ending**, so the event is never the state. ★ Verified against the **installed WeakAuras fork** (`WeakAuras.lua:1700-1701` registers both; `:1570` recomputes `UnitAffectingCombat` on every scan) — the most load-sensitive addon here never infers the state from the event that woke it. Restates `COA_Landmarks` AC-24 |
| know if an **enemy** is engaged | `UnitAffectingCombat(unit)` · stock | ★ True only once a mob is **actually engaged by someone** — that is what puts an entry on its threat table. ⚠ Not the same question as `isTanking`, which is `false` both for a mob nobody has threat on **and** one tanked by someone else; conflating them made an unpulled mob render as lost aggro |
| know the player is **dead** | `UnitIsDeadOrGhost("player")` · `UnitIsGhost("player")` · stock | Two states, not one — the point records `dead` and `ghost` separately |
| ★★★ **what killed the player** | `AscensionUI.DeathRecap` · **fork-specific**, read at `PLAYER_DEAD` | ⚠⚠ **`PLAYER_DEAD` is the ONLY moment it is readable.** `CurrentRecap` **rolls** on `PLAYER_UNGHOST` and `PLAYER_ENTERING_WORLD`, so a later read finds an empty buffer — and combat may not drop for several seconds, so it is held until the end marker is written. ⚠ **`isPlayer` is a FILTER, not decoration:** the recap folds `SPELL_HEAL` too, so a heal lands with `attacker` set to the **healer** — which once put his own character in a `killedBy`. ★ **ONE field, `attacker`** — the rest (damage, school, crit) is damage analysis, a lane combat parsers already serve. ★ Returns `(names, nil)` **or `(nil, reason)`**, because a silent absence would read as *"nothing killed us"* |
| know an **enemy** died | ⚠ see [CLEU](#combat-log-cleu) — `UNIT_DIED` is **silent for overwrite-despawn** | *(measured — 0 of 71)*. Liveness comes from the buff-instance witness + TTLs |

## Combat log (CLEU)

_★ The **layout** is universal and lives in `operations/ROUTER.md` — it is a client fact any bench
writing a trigger needs. **This section is how THIS bench uses it**, and what that cost to learn._

| Intent | Picked | Notes |
|---|---|---|
| read a combat-log event | the classic **varargs tuple** · stock — layout in [`ROUTER.md`](../../operations/ROUTER.md) | `1` ts · `2` sub · `3-5` src · `6-8` dst · `9+` suffix. ⚠ **`CombatLogGetCurrentEventInfo` is FURNITURE on this fork** — it exists, and the varargs tuple is what is real |
| know a row is **my** pet | `bandOk(flags, MINE)` **and** `bandOk(flags, PET + GUARDIAN)` · **ours** | **No stock helper.** Any-bit masks: MINE `0x1` · PET `0x1000` · GUARDIAN `0x2000`. ⚠ **Necromancer minions carry PET, not GUARDIAN** *(measured)*. ⚠ The `+` builds the mask arithmetically on purpose — `bit` may be absent at load — and only works because the bits are **disjoint** |
| what a CLEU listener **costs here** | **57–82 lines/second** in a dungeon *(measured)* · `addons/planning/cleu_on_this_fork.md` | ⚠⚠ **Measure ALLOCATION, not time.** Profiling on this fork found **GC pressure**, not call count — and timing a handler that does almost nothing mostly measures the timer. `/coadump st cleu` has three arms (`none` · `count` · `masked`) switched in-session so client state cannot differ between them |
| flag a hot listener in the census | `HOT_EVENTS` in `emit_addon_census.py` | ★ **An event joins that list only once MEASURED.** Seeding it on a hunch makes the flag mean *"someone thought this was expensive"* instead of *"this is the event we measured"* — and a flag that means the first thing is one people learn to skip |
| know when a pet **died** | ⚠ **not `UNIT_DIED`** · **ours**: buff-instance witness + TTLs | **`UNIT_DIED` is SILENT for overwrite-despawn** — 0 of 71 in the record *(measured)*. ⚠ Bound: that record held overwrites but **no enemy kills**, so death-by-enemy is untested. `UNIT_DIED` stays a bonus path, never the liveness source |

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
