# The intent shelf — reach here for direction

_The addons bench's own list. **Sized to our use case, not to WoW.** You arrive knowing what you want
to DO; this says what is in play for it._

**Routing:** [pre-flight](#the-pre-flight) · [**what it carries**](#-what-the-shelf-carries-and-why) · [where am I](#where-am-i-and-where-is-that) · [typing](#text-fields-and-typing) ·
[**visual**](#visual--pixels-scale-and-coordinate-spaces) · [frames and cost](#frames-timing-and-cost) ·
[**the manners**](#the-manners--how-we-behave-on-someone-elses-machine) · [**Lua itself**](#lua-51-itself--the-language-traps) · [nameplates and threat](#nameplates-and-threat) ·
[what is on the map now](#what-is-on-the-map-right-now) · [calls that LIE](#calls-that-are-not-what-they-look-like) ·
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

⚠ **44 of 59 tagged facts are SILENT.** That is not a detail about the notes — it is what this bench
has actually been paying for. A shelf that carried everything would be a second index; a shelf that
carries the silent set is the thing you could not have worked out for yourself.

### ★★ And the rule is CHECKED, not asserted

```
py addons/tools/emit_notes.py --reach
```

Every `SILENT` and `CULTURE` note, against this page, keyed on **the API name in its headline**.
⚠ **Reachable means A SEARCHER FINDS IT** — not that a section is thematically about it. That
distinction is the whole check: a judgement I make about my own document is worth nothing.

★★★ **Its first run said 16 of 37.** The shelf was carrying **under half** of exactly the class it
exists to carry, and there was no section at all for **CULTURE** — a rule I had written that same
morning. ⚠ **I had predicted this pass would mostly REMOVE rows.** It removed none. The fault was
never over-carriage.

★★ **And the cross-bench router was AHEAD of this page on nine of them.** `operations/ROUTER.md` already carried the Lua traps, the custom classes, the spec getter and the macro-conditional method while the bench's own shelf did not — because a fact gets written *there* when it is found to be universal, and nobody was checking that it also landed *here*. ⚠ The general shelf outran the specific one, which is the reverse of what either was built for.

★ **One note is deliberately not carried here:** *an unsupported macro conditional and a currently-false one are both falsey — only asking BOTH polarities separates them*. That is the **macros** bench's concept. It sits in the router as a client fact, and the routing table hands it over. ⚠ **Reaching it is not the same as owning it**, and the lane rule is the stronger of the two.

★ It reports `UNREACHED` and `UNKEYED` separately and rules on neither. An unkeyed note carries no
API name — most of the manners are like this — and no token test can speak to those, so they are
handed over rather than guessed at.

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

## The manners — how we behave on someone else's machine

_★★★ **This section exists because nothing else protects it.** A `SILENT` fact at least fails; a
manner does not fail at all. No test goes red, no client breaks, and the audit that read six thousand
comment lines could not have flagged one. It just quietly becomes an addon that takes more than it
was given._

| The manner | What it forbids | Ruled at |
|---|---|---|
| ★★★ **a plugin owns NO machinery — loading it DECLARES INTEREST** | a plugin that installs handlers, hooks or frames of its own. It contributes **data**; the host owns the machinery. ★ The whole plugin architecture in one sentence | `COA_StatePlates_Aggro/Options.lua:3` |
| ★★★ **an instrument is READ-ONLY on someone's live client** | probing anything that PUSHES — `SetCVar`, `SuperTrackerUtil.*`, `SetMapByID`, `ShowUIPanel`, `PlaySound`. ⚠ A diagnostic that damages the machine it is diagnosing is not a diagnostic. Probing PUSH would have to write each call's **restore before the call** | `COA_DevDump/task_api.lua:18` |
| ★★★ **pinning is ALWAYS a user act** | anything that re-pins on its own. Convenience that takes the supertrack slot back is a tool deciding what the player is doing | `COA_Landmarks/beacon.lua:103` |
| ★★★ **no validation on authoring** | refusing the author's input. Duplicate stages, out-of-order stages and fractions are all legal — they are **told** what they are doing (match count, gaps line, running order) and then trusted with it. ⚠ Refusing would be **grading the work** | `COA_DungeonRun/routes.lua:374` |
| ★★★ **the note is PULLED, never pushed** | anything that announces itself on approach — no toast, no proximity chatter. It is on the tooltip **when you hover**, and silent otherwise | `COA_Landmarks/pins.lua:59` |
| ★★★ **read-only on data that is not ours** | writing to another addon's SavedVariables. Fold only **known** fields, **note** the unknown ones, and never normalise someone else's record | `MancerLedger/core.lua:24` |
| ★★ **the driver INFORMS, it never grades** | completion counts, "you missed one", scores, streaks. It says where things are; what that is worth is not ours to say | `COA_DungeonRun/driver.lua:92` |
| ★★ **turning a feature OFF collapses to baseline IMMEDIATELY** | leaving residue for a TTL or a despawn to clear eventually. His: *"turning something off shouldn't lead to more work because it was on"* | `COA_GuardianPlates/FriendlyPlates.lua:398` |
| ★★ **the host's handlers no-op until the satellite attaches** | a host that acts on a concern nobody declared. ★ The other half of *a plugin owns no machinery* — and ⚠ the **restore path stays UNGATED**, because restore must always be safe to run | `COA_GuardianPlates/FriendlyPlates.lua:425` |
| ★★ **use the CLIENT'S OWN widgets** | bespoke dialogs. `StaticPopup` looks and behaves like everything the user already knows; custom code locks them out of a surface they never had to learn | `COA_DungeonRun/editor.lua:211` |
| ★★ **show "-", never a false zero** | printing `0` for something we did not observe. A permanent minion raised before the pull was not summoned during it — `0` would be a claim; `-` says we did not see it | `MancerLedger/core.lua:371` |
| ★★ **no borrowed clocks** | a custom internal ticker where the game runs one — `C_Timer.After`, not our own `OnUpdate` accumulator | `COA_GuardianPlates/Core.lua:497` |
| ★★ **the minimap is a CONTROL surface, never a DISPLAY one** | pins, blips, rotation handling. A button riding the edge is a control; a readout is noise on a surface the player did not offer us | `COA_Landmarks/minimap.lua:6` |
| ★★ **one line of chat per run, by exception** | narration. `NS.Say` exists for the **policy**, not the plumbing — a tool that talks is one people learn to stop reading | [records](#records-and-persistence) |
| ★★ **zero persistent `OnUpdate`** | a handler that outlives its gesture. Install on arm, clear on stop; the census counts installs against clears | [frames and cost](#frames-timing-and-cost) |
| ★ **baseline OFF** | shipping switched-on. Presence is not permission. ⚠ Wheel-zoom and right-drag default off because **the wheel belongs to the world camera and right-drag to camera-look** — an addon that takes either on install has taken something nobody offered | `COA_DungeonRun/map.lua:1684` |

---

## Where am I, and where is that?

| Intent | Picked | Notes |
|---|---|---|
| the player's world position | `GetCurrentPlayerPosition()` · stock | → x, y, z, **mapID**. ⚠ the 4th return is the **internal** mapID, **not** `GetCurrentMapAreaID` — 33 vs 765 in SFK *(measured)* |
| which floor am I on / how many are there | `GetCurrentMapDungeonLevel()` · `GetNumDungeonMapLevels()` · stock | 7 for Shadowfang *(measured)* |
| am I in an instance | `IsInInstance()` · stock | ⚠ returns **`1`, not `true`** (plus the type string) *(measured)*. Test truthiness, never `== true` |
| map fraction ↔ world **yards** | `NS.Calibrate` · **ours** | **No stock answer**: the client gives fractions and it gives yards, and relates them nowhere. A **6-param affine** fitted per mapID from our own captures. ⚠ Six and not four because **the client's map axes are SWAPPED AND NEGATED versus world axes, and the convention differs BY MAP** — two independent scales fit a map that happens to agree and mis-place every point on one that does not, with no error either way *(`COA_DungeonRun/calibrate.lua:70`)*. ★ **World space — the screen-side half is `Map.FractionAt` under [visual](#visual--pixels-scale-and-coordinate-spaces)**, and the two chain: cursor → fraction → yards |
| is a point close enough to count | `Driver.Reached(px,py,pz, bx,by,bz, r, band)` · **ours** | **No stock proximity test.** Planar **and** vertical, never one alone — a walkway 9.71 yd up sits 3.12 yd away on the map |
| point the super tracker at a spot | `SuperTrackerUtil.SetSuperTrackedPosition(x,y,z,mapID)` · stock | ⚠ **PUSH — changes client state.** ⚠ **AC-17:** the `C_SuperTrack.*` form looks right, skips the priority ladder, and is silently overwritten. ⚠⚠ **ACROSS A MAP BOUNDARY it returns `Invalid` with distance `0.00` — not nil** — while `IsSuperTrackingAnything()` still reports true. **Zero satisfies every radius test**, so any distance-only *“am I there yet”* fires the instant you zone, and a loading screen does the same *(measured, F38)*. Arrival needs the state **and** the distance, judged **sustained** *(`COA_Landmarks/beacon.lua:14`)*. ⚠ Hooking `SelectQuestLogEntry` to yield the slot also fires on **`QUEST_TURNED_IN`** — `UpdateSelectedQuest` calls it unconditionally — so a turn-in reads as a selection *(`COA_Landmarks/beacon.lua:254`)* |

## Text fields and typing

| Intent | Picked | Notes |
|---|---|---|
| know an edit came from a **human** | `OnTextChanged`'s 2nd arg `userInput` · stock | **`false`** for a programmatic `SetText`, true when typed *(measured)*. `COA_Landmarks` hand-rolled `s.suppress` before we knew this existed |
| know **when** the handler fires | — · stock behaviour | **Deferred** a frame · **coalesced** to one fire however many sets · **change-only**, so setting the same value fires nothing *(measured)*. §81's "unbounded freeze" rested on the opposite and was never real |
| complete a tag **inline** as the user types | **ours** — replicated, not borrowed | ⚠ `AutoComplete_Update` / `GetAutoCompleteResults` is a **C API that only ever returns PLAYER NAMES**. The stock inline mechanism cannot be pointed at another vocabulary, so the behaviour is rebuilt. ⚠ And `OnTextChanged` fires on **DELETION** too — completing on a shrink makes the field impossible to edit backwards |
| read the field inside the handler | `GetText()` · stock | ⚠ the handler sees the **final** text, not the value that triggered it — a raced `first`/`second` reports `second` *(measured)* |

## Visual — pixels, scale and coordinate spaces

_★ The boundary that makes this section honest: **screen and texture space live here; WORLD space
lives under [where am I](#where-am-i-and-where-is-that)**. A cursor is screen space, a yard is world
space, and the bugs happen where someone subtracts one from the other._

| Intent | Picked | Notes |
|---|---|---|
| turn a **cursor position** into frame coordinates | `GetCursorPosition()` ÷ `<frame>:GetEffectiveScale()` · stock | ⚠⚠ **Divide by the scale of the FRAME you compare against**, never `UIParent`'s unless that IS the frame. Mixing two scale spaces is **masked while they match** — the default — so it is correct by coincidence until something rescales. Cost a latent bug in `COA_Landmarks/minimap.lua` while `MancerLedger` had it right: **the bench held the bug and its fix, and neither site carried a comment** |
| screen point → map fraction | `Map.FractionAt(cx, cy, scale, left, top)` · **ours** | **No stock answer** for our own canvas. ★ It takes the scale as a **PARAMETER** and reads `GetLeft`/`GetEffectiveScale` **live** — which is why zoom and pan cost it nothing, and why it never mixed spaces |
| decide which overlapping thing gets the CLICK | **frame level** · stock | ⚠ **Frame level drives HIT TESTING as well as draw order**, and ties fall to **list order** — so a cluster both draws and clicks whichever happened to be added last. ★ One ladder settles both, and a thing you cannot select is the same fault in a worse place *(`COA_DungeonRun/map.lua:156`)* |
| crop a texture | `SetTexCoord` **after** `SetTexture` · stock | ⚠ the crop **SURVIVES** a new texture on the raw API *(measured)*. §19's reset lives in a stock Lua wrapper (the POI mixin path) that this bench never goes through |
| crop a dungeon tile to the map space | `Map.TileRect(i)` · **ours** | **No stock geometry.** ⚠ **`WorldMapDetailFrame` is 1002×668 in COORDINATES while the tile art is 4×3×256 = 1024×768** — the client's own map clips the padding rather than exposing it, so every tile carries the ratio |
| pick the tile file for a dungeon FLOOR | `Map.TilePath(mapFile, floor, i, terrain)` · **ours** | ⚠⚠ **A TERRAIN MAP SHIFTS THE LEVEL BY ONE** — the client's own `WorldMapFrame.lua:463` does `if DungeonUsesTerrainMap() then level = level - 1 end`. Ignore it and the lowest floor asks for a file that does not exist (blank — loud) while **every floor above loads the WRONG ART under the RIGHT points**, which looks like a working map. ★ Take the flag from the **RUN, captured at arm** — `DungeonUsesTerrainMap()` describes the map being *shown*, and authoring happens from a city *(`COA_DungeonRun/map.lua:1061`)* |
| a glow with many dashes | pass `length` explicitly · LibCustomGlow | ⚠ `PixelGlow_Start`'s auto-derive is `floor((w + h) * (2 / N - 0.1))`, which **goes non-positive at N ≥ 20** — and a negative length renders **nothing at all** *(`COA_GuardianPlates/Core.lua:925`)* |
| draw a client icon at a known crop | read **`AtlasInfo[name]`** directly · stock table | `{ texture, w, h, left, right, top, bottom, flipH, flipV }` → `SetTexture` + `SetTexCoord`. ⚠ **Not `SetAtlas`**: it additionally **forces the atlas's native size** and **fails silently under `pcall`** — which is how a pin ends up wrong-sized or blank |

## Frames, timing and cost

| Intent | Picked | Notes |
|---|---|---|
| run every frame, then stop | `SetScript("OnUpdate", fn)` / `(…, nil)` · stock | The census counts installs vs clears; **zero persistent** is the bench standard |
| **wake me in N seconds** | `C_Timer.After(delay, fn)` · stock | ⚠ **This row was WRONG on its first outing** — it said *"no stock scheduler, `C_Timer` is absent"*, and Battlewrath challenged it. `C_Timer` is **a genuine Ascension client global, not a shim** (`COA_GuardianPlates` Core.lua:503 uses it; TurboPlates relies on it directly). His ruling, already recorded in v3.5.5: *"we don't engrain custom internal clocks when we can have the game do it for us"* |
| step work across **FRAMES** | `D.Cycle(step, perFrame, onDone)` · **ours** | **What stock lacks:** `C_Timer.After` waits in **seconds**, and this needs **frames** — paced walking (the census does 400 keys/frame) and frame-accurate spacing (the api probe separates events by exactly 60 frames). ⚠ Reach for `C_Timer.After` first; this is only for when the unit really is a frame |
| what else does `C_Timer` offer | **unknown** | ⚠ `NewTicker`/`Cancel` are **unverified here**. The census records `C_Timer` as a table with **no enumerable members**, so a name search finds nothing — see the warning under *when this shelf is empty* |
| measure what something costs | `debugprofilestop()` · stock | The driver self-measures with it: 0.0061 ms/scan over 7079 scans *(measured)*. ⚠ **It can SILENTLY NOT ADVANCE** — a run reporting 0 ms of observer cost is a stopped clock as often as it is a cheap handler, so show the timer moved before believing the number *(`COA_DevDump/task_cleu.lua:24`)* |
| what is an ADDON costing | `GetAddOnCPUUsage()` · stock | ⚠ **Returns 0 unless `scriptProfile` is `1` AND the client has been restarted since** — the cvar does not take effect in-session. A zero here means *“profiling is off”* far more often than *“free”* |

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
| read a combat-log event | the classic **varargs tuple** · stock — layout in [`ROUTER.md`](../../operations/ROUTER.md) | `1` ts · `2` sub · `3-5` src · `6-8` dst · `9+` suffix *(`COA_PetGrid/feed_live.lua:4`)*. ⚠ **`CombatLogGetCurrentEventInfo` is FURNITURE on this fork** — it exists, and the varargs tuple is what is real |
| know a row is **my** pet | `bandOk(flags, MINE)` **and** `bandOk(flags, PET + GUARDIAN)` · **ours** | **No stock helper.** Any-bit masks: MINE `0x1` · PET `0x1000` · GUARDIAN `0x2000`. ⚠ **Necromancer minions carry PET, not GUARDIAN** *(measured)*. ⚠ The `+` builds the mask arithmetically on purpose — `bit` may be absent at load — and only works because the bits are **disjoint** |
| what a CLEU listener **costs here** | **57–82 lines/second** in a dungeon *(measured)* · `addons/planning/cleu_on_this_fork.md` | ⚠⚠ **Measure ALLOCATION, not time.** Profiling on this fork found **GC pressure**, not call count — and timing a handler that does almost nothing mostly measures the timer. `/coadump st cleu` has three arms (`none` · `count` · `masked`) switched in-session so client state cannot differ between them |
| flag a hot listener in the census | `HOT_EVENTS` in `emit_addon_census.py` | ★ **An event joins that list only once MEASURED.** Seeding it on a hunch makes the flag mean *"someone thought this was expensive"* instead of *"this is the event we measured"* — and a flag that means the first thing is one people learn to skip |
| know when a pet **died** | ⚠ **not `UNIT_DIED`** · **ours**: buff-instance witness + TTLs | **`UNIT_DIED` is SILENT for overwrite-despawn** — 0 of 71 in the record *(measured)*. ⚠ Bound: that record held overwrites but **no enemy kills**, so death-by-enemy is untested. `UNIT_DIED` stays a bonus path, never the liveness source |

## What is on the map right now

| Intent | Picked | Notes |
|---|---|---|
| what is selected | `Map.Selected()` · `Map.AddOnSelect(fn)` · **ours** | **No stock answer** — these are our own frames. ⚠ a **registry**, not a single slot: two panes both listen, and one slot let whichever initialised last silently take it (§63) |
| what is loaded / what am I authoring against | `Map.LoadedId("run"\|"route")` · `Map.AuthoringMapID()` · **ours** | **No stock answer.** ⚠ authoring follows what is **LOADED**; the in-route driver follows where the **PLAYER** is (§64) |
| which floor a route is on at time T | `Map` tracks the **most recent node** · **ours** | ⚠ **FLOOR INDEX IS NOT ROUTE ORDER** — SFK_Run4 runs 1, 2, back to 1, 7, 3, 4, 5, 6. Scrubbing across a transition empties the canvas with nothing on screen to say where the route went, which reads as a **broken scrubber** rather than a floor change. ★ Take the last point **at or before** the window's end across every floor, so a quiet stretch still shows where you ARE *(`COA_DungeonRun/map.lua:605`)* |
| a route's running order | `Routes.StageOrder(id)` · **ours** | **No stock answer.** Sorted by stage **value**. ⚠ **Stage is a LABEL, not an array index** — `Routes.DeleteBeacon` leaves gaps, and `4.1` is an ordinary stage. Anything that treats the order as `1..n` renumbers a route the author arranged by hand |

## Calls that are not what they look like

_★ Two families here. One **throws** where you expected a nil; the other **runs something** where you
expected a read._

| Intent | Picked | Notes |
|---|---|---|
| a unit's name / class / state | `UnitName(u)` · `UnitClass(u)` · stock | ⚠ **THROW on nil or a bad unit** — `Usage: ...` *(measured)*. `local n = UnitName(u); if not n then` never reaches its check |
| the same trap, same fix | `UnitIsGhost` · `GetPlayerMapPosition` · `GetCVar` · `GetDifficultyInfo` · `GetAddOnMetadata` · stock | ⚠ all throw *(measured)*. `GetDifficultyInfo` throws from **inside the client's own** `GlobalFunctions.lua:263` |
| open a settings panel | `InterfaceOptionsFrame_OpenToCategory(panel)` — **called TWICE** · stock | ⚠ The first call opens the frame on the **wrong panel**; only the second lands. Calling it once reads as a wiring bug *(`COA_GuardianPlates/FriendlyPlates.lua:633`)* |
| drag a small precise distance | ⚠ **not** `RegisterForDrag` — press-to-grab (`OnMouseDown` + `OnUpdate`) | ⚠ **`RegisterForDrag` has a MOVEMENT THRESHOLD.** A small nudge never starts a drag at all and nothing reports the miss, so a fine-adjust handle reads as **ignoring you** *(`COA_DungeonRun/editor.lua:384`)* |
| read the player's spec | `GetSpecializationInfo` · stock | ⚠⚠ **NOT A PURE GETTER.** It runs `ConvertOldSavedSpec`, so **reading it can change saved state**. Never call it to satisfy a display, a log line or a probe |

## Lua 5.1 itself — the language traps

_★★ **Not the client — the LANGUAGE.** Every one of these is silent, every one shipped at least once,
and they are the only rows here that are **universal**: they hold for any bench writing Lua, which is
why they also sit in [`operations/ROUTER.md`](../../operations/ROUTER.md)._

| Intent | Picked | Notes |
|---|---|---|
| count what a call returned | `select("#", ...)` · stock | ⚠⚠ **`#{ pcall(f) }` IS A TRAP.** A nil anywhere makes a sequence **with holes**, and `#` on that is undefined — Lua may stop at the first one. **Bit live: eight values asked for, TWO recorded**, and the record simply looked short rather than wrong |
| choose between two values | plain `if / elseif` | ⚠⚠ **`cond and X or Y` BREAKS whenever X is itself falsy** — `true and nil` is `nil`, so the chain falls through to Y **despite the condition matching**. **Confirmed live twice**, and banned in `COA_GuardianPlates` for it. It is only safe when X can never be `nil` or `false`, which is a promise about a value's whole future |
| call something that may throw | `local ok, a, b = pcall(f, ...)` · stock | ⚠⚠ **TWO traps in one call.** ① every real return **SHIFTS BY ONE** — `UnitClass`'s TOKEN is the **third** value; `select(2, …)` hands back the localized name, the near-useless one *(hit twice in one session)*. ② the first return is **"did it error"**, **not** the callee's own boolean — `local ok, shown = pcall(f)` reads `ok` as success when the function returned false *(`COA_DevDump/payload_macros.lua:88`, `COA_GuardianPlates/EnemyPlates.lua:1088`)* |
| call a local function defined **below** | forward-declare: `local f` … then `function f()` | ⚠⚠ **A `local function` referenced above its declaration resolves to a NIL GLOBAL** — and `SetScript("OnUpdate", nil)` is **legal**, so the handler silently never runs. ⚠ **Shipped live twice, recorded five times across two addons.** ⚠ Dropping the `local` to "fix" it leaks into `_G` instead |
| reset a table to its defaults | clear the nil-valued keys **by name** | ⚠ **A nil-valued default is INVISIBLE to `pairs()`**, so `for k,v in pairs(defaults) do db[k] = v end` silently skips it and the **old value survives the reset** *(`COA_PetGrid/core.lua:346`)* |
| put a path in a string | `"Interface\\Minimap\\…"` — double every backslash | ⚠⚠ **Lua 5.1 SILENTLY DROPS an unknown escape**: `"Interface\Path"` becomes `InterfacePath`, no error, no warning — a texture that just never appears. `addons/tools/check_escapes.py` walks the manifest for it |

## Nameplates and threat

_★ `COA_GuardianPlates` is the largest surface on the bench and the most API-hostile; every row here
was **measured against a live pull**, and every one of them fails quietly._

| Intent | Picked | Notes |
|---|---|---|
| the plate frame for a unit | `C_NamePlate.GetNamePlateForUnit(u)` · stock | ⚠⚠ **FAILS at `NAME_PLATE_UNIT_REMOVED` time** — the plate is already gone when the event tells you about it, **20/20 live**. Removal has to resolve from **our own** unit→plate map, not from the API |
| which creature a plate belongs to | `ns.plateOwner` / `ns.activeUnits` · **ours** | ⚠ **The SAME creature is announced under TWO unit tokens at once** — e.g. `nameplate1` *and* `target`, same GUID, same plate frame. Unguarded, every consumer **double-processes one plate**. Guard on the **GUID**, not the token *(`COA_GuardianPlates/Core.lua:130`)* |
| am I tanking this / who else is close | `UnitDetailedThreatSituation(unit, mob)` · stock | ⚠ **Returns nil ACROSS THE BOARD when you have no threat-table entry** — indistinguishable from "no data" unless you check first. ⚠ `rawPercentage` can **EXCEED 100** and **stops updating** past the pull, so it ranks but does not measure |
| is a mob engaged at all | `UnitAffectingCombat(unit)` · stock | → [combat state and death](#combat-state-and-death). ⚠ Not the same question as `isTanking` |
| find every plate on screen | `C_NamePlateManager.EnumerateActiveNamePlates()` · stock | ⚠ **Not by cursor rect.** Native plates are **`WorldFrame` children** and smooth-stacking **stretches `WorldFrame` 8×**, so hit-testing in `UIParent` coordinates misses them — what the cursor finds is the rendered visual **without the unit token**. Each enumerated plate carries `_unit`, set at `NAME_PLATE_UNIT_ADDED` *(`COA_DevDump/task_plates.lua:4`)* |
| the client's own aggro highlight | `_G[healthBarName .. "aggroHighlight"]` · stock, **by name** | ⚠⚠ **NOT `healthBar.aggroHighlight`** — that field does not exist, and the guess was a **100% deterministic failure that read as a styling problem**. The frame is reachable only through `_G` by constructed name *(`COA_GuardianPlates/Core.lua:1282`)* |
| branch on a class | ⚠ **don't** — `CoA`'s classes are **ENTIRELY CUSTOM** | **No Warrior/Paladin/Druid/DK on this fork.** Any stock class-token branch is dead code that never reports being dead. Class identity joins through the token, see `Fact_basis/maps/class_table.json` *(`COA_GuardianPlates/EnemyPlates.lua:183`)* |

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
