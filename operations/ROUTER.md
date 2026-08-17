# The router — one client, one Lua, six benches

_Cross-bench. **Read this before deciding a client behaviour is unknown**, whichever bench you are on._

## Why it exists

> *"Everything we do is mostly LUA. And that's universal. Every finding and function weak auras has
> had to determine has cross cutting to us."* — Battlewrath, 2026-08-15

★★★ **The substrate is ONE client and ONE Lua.** A WeakAura's custom trigger, a macro conditional and
an addon's frame handler all run against the same API, the same 5.1, the same fork. So a fact one
bench pays to establish is **already true for every other bench**, and today there is no way for them
to learn it.

⚠ The cost is measured, not hypothetical. In one session the addons bench ran **five live probe
cycles** to establish that `OnTextChanged` carries a `userInput` flag — an idiom already shipped in
our own `COA_Landmarks`, contradicting a ruling recorded in a third addon. That was *within* one
bench. Across benches there is not even a place to look.

## ⚠ READ `addons/invariants.md` FIRST — it predates this and outranks it

**The transferable LAWS already existed and I built this beside them instead of connected to them.**
`addons/invariants.md` says *"read before any code"*, is cited from `addons/README.md` and
`operations/STATE.md`, and I did not open it while building an entire cross-bench surface.

★ **Where they were earned, because provenance is demanded of every other row here.** The aura bench,
2026-07-11→15, building content **programmatically** for WeakAuras to load — *"in a manner normally
it'd never see (it's driven by user input)"*. An unusual situation: machine-authored input into a
system whose ordinary path is a human clicking. ★★ **The lessons carry regardless**, which is the
claim the file makes for itself and the reason it is titled the way it is.

| | |
|---|---|
| `addons/invariants.md` | **LAWS** — how to work. The live client outranks everything · nothing without versioned source · **a stored field isn't a live field** · harvest once, map, cite · never fabricate mechanical output · by-exception reporting · defined I/O goes through machining · secondary sources for concepts, the installed client for facts |
| **this file** | **FACTS** — what the client and Lua actually do, and which bench holds which concept |

⚠ Invariant 3 caught something the same week it was ignored: a `★★` comment in `capture.lua`
asserted a guard that had been deleted, while the same file refuted it 200 lines earlier. *A stored
field isn't a live field* — reappearing as a stored **comment** that isn't a live one.

## ★ The split that makes this work

| | |
|---|---|
| **UNIVERSAL** | true for every bench because it is a property of the client or of Lua. Lives **here**. |
| **APPLICATION** | how a bench uses it, and why. Lives on **that bench's shelf**. |

★ `IsInInstance` returning `1` is universal. *"Crop a dungeon tile to the map space"* is the addons
bench applying it. **Anyone may add a universal fact; nobody writes another bench's application.**

★★★ **AND IT CARRIES ITS CONSEQUENCE.** His axis, and it outranks the universal/application one
for deciding what anyone needs to be *told* rather than left to discover: a fact that **throws**
teaches itself the first time you hit it; a fact that fails **SILENTLY** produces something that
looks like it worked. ⚠ **47 of 63 tagged facts on this bench are silent** — which is why a router
exists at all, because nobody hits a silent failure and goes looking for a document.

★★★ **AND CULTURE IS THE OTHER END OF IT.** *"How we decide to be respectful on someone's
machine. Nothing that will ever manifest in code rejection or be 'bad code'."* ⚠ **SILENT and CULTURE
are the two classes that most need writing down, for opposite reasons** — silent because the failure
hides, culture because there is no failure at all. An audit cannot find a culture breach; a test
cannot fail on one. The record is the only thing holding it.

⚠ **A universal fact carries its provenance.** *(measured)* means a live run proved it, with the
bench and the instrument named. Unmarked means inherited from reading — and an inherited reading is
how a stale trap shaped an entire test suite for months.

---

## UNIVERSAL — the client and Lua, true everywhere

_Seeded by the addons bench, 2026-08-15. **These are not addon facts; they are client facts.**_

| Fact | Provenance |
|---|---|
| **`C_Timer` EXISTS** and is a genuine Ascension global, not a shim. `C_Timer.After(delay, fn)` works | addons · in use since `COA_GuardianPlates` v3.5.5. ⚠ **It enumerates as an EMPTY table in the 51,855-global census**, so a name search finds nothing while it works perfectly — *a name search proving absence proves nothing* |
| ★★★ **`C_Timer.After` IS FRAME-DRIVEN, AND IS THE SAME CLOCK AS AN `OnUpdate` ACCUMULATOR** | addons · *(measured 2026-08-16, `records/20260816_160953_117__timers.json`)*. Both walked one coded schedule side by side for 193s at 20 fps. **Error is CONSTANT at every magnitude** — +26ms mean whether 1s or 10s was asked, which is **0.53 of a frame**; max 1.14 frames. It QUANTISES to the next frame and does not defer, does not floor, and never bursts. ★★★ **Confirmed at a second framerate**: in a dungeon at 137.6 fps (frame 7.3ms) the median error fell to **6ms = 0.83 frames**, against 29ms = 0.58 frames at 20 fps — **the error moves with the FRAME.** ⚠ The MEAN is higher in frames at high fps (1.32) because individual frames hitch to 34ms; **the median is the mechanism, the tail is the client.** Drift also falls with framerate: +1.08% at 20 fps, **+0.37% at 137 fps.** ⚠⚠ **The two mechanisms tracked each other to a mean of 0.04ms and never diverged by more than 5ms** — so `C_Timer` buys NO timing advantage over an accumulator. ⚠ Both drift **+1.08%** because each reschedules from *now*, so per-tick rounding compounds — **neither holds absolute cadence over a long run** |
| **`OnTextChanged` is DEFERRED** a frame, **COALESCED** to one fire however many sets, and **CHANGE-ONLY** — setting the same value fires nothing | addons · *(measured, `/coadump r api` run 5)* |
| its **2nd argument `userInput`** is `false` for a programmatic `SetText`, true when a human typed | addons · *(measured)*. ★ The clean way to stop a refresh loop, rather than comparing before writing |
| the handler reads the **final** text, not the value that triggered it | addons · *(measured)* — a raced `first`/`second` reports `second` |
| **`IsInInstance()` returns `1`, not `true`** (plus the type string) | addons · *(measured)*. Test truthiness, never `== true` |
| **These THROW rather than returning nil:** `UnitName` · `UnitClass` · `UnitIsGhost` · `GetPlayerMapPosition` · `GetCVar` · `GetDifficultyInfo` · `GetAddOnMetadata` | addons · *(measured)*. ⚠ `local n = UnitName(u); if not n then` never reaches its check. `GetDifficultyInfo` throws from **inside the client's own** `GlobalFunctions.lua:263` |
| **`SetTexture` does NOT reset `TexCoord`** on the raw texture API — the crop survives | addons · *(measured)*. ⚠ The reset lives in a **stock Lua wrapper** (the POI mixin path); generalising it to the raw API shaped a test suite wrongly for months |
| **Lua 5.1 SILENTLY DROPS an unknown escape** — `"Interface\Path"` becomes `InterfacePath`, no error | addons · *(measured against `.tools/lua51`)*. Shipped a border-less frame for weeks. Guard: `addons/tools/check_escapes.py` |
| **The supertracker's live tenant is the QUEST waypoint, and it is BLIND to what wrote it** | addons · Battlewrath 2026-08-16. ⚠ **CORRECTED §242 by F24, which is measured:** the client's ladder ranks **Position ABOVE Quest**, and *nothing in the client's flow clears our position* — so passivity does not hand it back, it **wins permanently and silently blocks the player's quest arrow**. A deliberate re-track by the player takes the slot; nothing passive does. `COA_Landmarks` answers this with a hard contract — *occupy on an explicit pin → release on arrival → NEVER reclaim* (AC-12, AC-19) — and a route driver re-points every stage, which is "reclaim" under it. **A product difference to make deliberately, not to inherit.** ⚠ Nothing recorded this, and its absence let a whole design conversation treat *"who owns the slot"* as a contest between our own modules when the incumbent was always the player's quest arrow |
| ⚠ **It can be LOST while you still hold the intent**, so a route may need a low-cadence HEARTBEAT re-setting the position | addons · a map boundary invalidates it (row above) and other writers overwrite silently. His: *"we might need a heart beat to keep reinforcing it. But not a race."* ★ **Reinforcement, never arbitration** — nothing is being contested, so a tight loop trying to win would be solving a problem that does not exist |
| `SuperTrackerUtil.SetSuperTrackedPosition(x,y,z,mapID)` works; **`C_SuperTrack.*` is silently overwritten** | addons · AC-17. Looks right, skips the priority ladder |
| **`InputBoxTemplate` EditBoxes MUST BE NAMED** — its `$parentMiddle` texture anchors relativeTo `$parentLeft`/`$parentRight` **by name**, so a nameless box loses its middle and renders as two floating end-caps | aura/addons · **cost a live bug in `COA_Landmarks`**, carried into `COA_DungeonRun/widget.lua`. ⚠ And broken again in `task_api.lua` the day this router was written — an audit found it, not a person |
| **`GetCursorPosition()` is in SCREEN pixels** — divide by the effective scale of the **FRAME you compare against**, never `UIParent`'s unless that IS the frame | addons · ⚠ **masked whenever the two scales happen to match, which is the default** — so it is correct by coincidence until something rescales. `COA_Landmarks/minimap.lua` mixed Minimap-space against UIParent-scale; `MancerLedger/minimap.lua` had it right all along. **The bench held both the bug and its fix and neither site carried a comment.** Found by audit |
| **Combat state: EDGES FROM THE EVENTS, STATE FROM THE API.** `PLAYER_REGEN_DISABLED`/`_ENABLED` mark the transitions; `UnitAffectingCombat("player")` is the state, read fresh | addons · ⚠ **`PLAYER_REGEN_ENABLED` also fires when lockdown lifts for reasons that are not a pull ending.** ★ Cross-checked against the **installed WeakAuras fork** — `WeakAuras.lua:1700-1701` registers both events, `:1570` recomputes the API call on every scan. **The aura bench's own subject already answers this**, which is this router's thesis in miniature |
| **`AscensionUI.DeathRecap` is readable ONLY at `PLAYER_DEAD`** — `CurrentRecap` rolls on `PLAYER_UNGHOST` and `PLAYER_ENTERING_WORLD` | addons · fork-specific. ⚠ It folds `SPELL_HEAL` as well as damage, so `attacker` can be a **healer** — filter on `isPlayer` or you attribute a death to whoever healed you |
| **CLEU on 3.3.5 is the classic VARARGS tuple** — `1` ts · `2` subevent · `3-5` src (GUID, name, flags) · `6-8` dst · `9+` suffix. `CombatLogGetCurrentEventInfo` is **furniture** on this fork | addons · verified in `addons/planning/pet_parser_scope.md`. ⚠ Suffix positions: SWING crit `15` · SPELL amount `12` / crit `18` · SWING_MISSED missType `9` · SPELL_MISSED `12`. **Any bench writing a combat-log trigger needs this** |
| **`UnitExists` returns `1`, not `true`** — never compare against `true` | addons · the archetypal 3.3.5-ism, and the same shape as `IsInInstance` |
| **`GetPlayerMapPosition` returns `0,0` when the world map shows a DIFFERENT zone** — `SetMapToCurrentZone` fixes it, but is only safe to call while the map is **hidden** | addons · *"the single most common map-coord bug"*; pfQuest guards identically. ⚠ `GetCurrentMapDungeonLevel` has the same disease — it reports the floor **the map is showing** |
| ★★★ **BOSS ENGAGEMENT IS AN EVENT PLUS A TOKEN POLL — NOT AN API YOU QUERY** | addons · `INSTANCE_ENCOUNTER_ENGAGE_UNIT` fires (`capture.lua:667`, handled `:675`), then `boss1`..`boss5` are read with `UnitExists`/`UnitName` (`engagedBosses()` `:239`). **Live-verified 2026-08-13** (record `20260813_014009_176`) and in the data: RFC run 1 holds *Taragaman the Hungerer* against pull 12. ⚠ `UnitExists` returns **1, not true**. ⚠⚠ **IT DOES NOT DELIVER ENCOUNTERS.** `capture.lua:225` is explicit: *"NOT 'bosses', AND NOT ENCOUNTERS. We hold unit names that had a boss token at that moment. Whether two of those names belong to ONE fight is dungeon knowledge, which §17 says we do not hold."* ★ So a NAME is available and a grouping is not — which is enough for a `UNIT_DIED`-on-name validation, and not enough to call anything per-encounter |
| ★★★ **`_G.SUPER_TRACKED_POSITION` CARRIES THE TARGET'S WORLD POSITION — so the tracker is readable AGNOSTICALLY** | addons · §253, measured. Keys are exactly `mapID x y z`, all numbers, and they match what was pinned to the digit. ★ **You do NOT have to have set the pin to compute a second term** — `GetSuperTrackedPosition` gives screen x/y plus distance, and this global gives the world point. ⚠ Nobody had looked before: the satnav probe read only its `mapID`, to check the client still held our intent |
| ★★★ **ENGINE DISTANCE == OUR OWN ARITHMETIC, MEASURED INSIDE A DUNGEON ACROSS SEVEN FLOORS** | addons · §253, SFK `test1` walk: **1,739 paired samples, 0–264 yd, mean \|sd−od\| 3e-6, worst 1.9e-5, zero rows diverging by >1 yd.** ★ Independently reproduces F28/F39 (which were outdoor) in the environment that actually matters, and answers the cross-floor question: **the tracker held across all seven floors with no divergence at all** |
| ★★ **WHAT LIMITS SUPERTRACKING IS RANGE AND MAP CHANGE — NEVER ZONE CROSSING** | addons · Battlewrath 2026-08-17, from his own Durotar→Orgrimmar testing: *"the limit is 1.5k yards. Not the zone crossing."* Three behaviours, and they get confused with each other: **a zone border does nothing** (F30/F36 — mapID is the continent, and 1,291 yd of travel never changed it); **past ~1500 yd the CLIENT stops drawing the beacon** while the engine keeps returning true distance (F22/F32/F35 — measured to 3,742 yd, so our readout is uncapped); **a MAP change declines outright** — Invalid, `sd = 0.00`, still claiming to track (F38). ★ **Design against range and map change. Zone crossing is not a constraint and never was** |
| **A DUNGEON IS ONE INSTANCE — there are no zone boundaries INSIDE one** | addons · Battlewrath 2026-08-17: *"a zone is a load screen barrier and every dungeon is a single instance."* ★ One mapID, one continuous coordinate space, wall to wall; the only boundary is the loading screen at entry/exit. ⚠ So *"cross a boundary while inside"* is not a thing that can be asked for — the analysis lane asked for exactly that and this bench repeated it. **Inside a dungeon the only axis is FLOORS** |
| **The mapID from `GetCurrentPlayerPosition` is the CONTINENT**, not the zone the world map draws | addons · ⚠ a stored fraction is valid **only** against the continent+zone pair it was taken on — matching on mapID alone scatters every pin across the continent |
| ★★★ **A UNIT'S POSITION `z` IS ITS BASE POINT — THE GROUND. Model height does NOT enter the coordinate** | addons · §280 · ⚠ **provenance is EMULATOR SOURCE, not our own measurement** — TrinityCore 3.3.5 `Object.cpp`, `WorldObject::UpdateGroundPositionZ` writes the terrain height straight into z (`z = new_z`), and *everything* needing a body point adds `GetCollisionHeight()` **on top** (`GetPositionZ() + GetCollisionHeight()` for the hit sphere; `z += GetCollisionHeight()` for LoS). ★ The proof is by construction: if `GetPositionZ()` were the model centre, adding a full collision height for LoS would overshoot by a body. Collision height comes from `CreatureModelData.dbc` and is **never written back into the position**. ★★ **So a stored beacon z travels safely between players of different races** — the question that matters for a route, and it had never been asked here. Model heights span Gnome ♀ 1.01 m to Tauren ♂ 2.77 m (≈1.9 yd), which would have consumed 76% of the ruled ±2.5 yd band had it entered. ⚠ RESIDUAL: our own getter is fork-native (row below), so this certifies the ENGINE coordinate, not Ascension's Lua wrapper. Two characters of different races on one spot would close it; two Forsaken (measured, `dz` p50 −0.000, max 0.201 over 29 same-floor pairs) only shows the reading is consistent |
| ⚠⚠ **TWO position APIs exist and their ARGUMENT ORDER DIFFERS** | addons · §280 · `GetCurrentPlayerPosition()` → **x, y, z, mapID** and is **FORK-NATIVE**: the string lives in `Extensions.dll`, not `Ascension.exe`, and stock 3.3.5 has **no Lua that returns a world z at all** (`GetPlayerMapPosition` is normalised x/y only; `UnitPosition` arrived in 6.0.2 and even there retail documents `positionZ` as *"Always 0, a placeholder"*). ⚠⚠ **CORRECTED §283 — I claimed `UnitPosition(unit)` exists here returning `y, x, z, instanceId`. THAT IS NOT ESTABLISHED and the row overstated it.** The basis was a call site in a shipped third-party addon (`AscensionLogsCompanion`) — `local ok, y, x, z, instanceId = pcall(UnitPosition, unit)` — and **a `pcall` call site is evidence of an ATTEMPT, not of existence**; wrapping it is what you do when you do not know. The globals census says **absent**, but ⚠ *the census cannot prove absence either* — the entire supertracker API is missing from it and demonstrably works (same as `C_Timer` enumerating empty). ★ So: **unresolved, with contradictory evidence, and `task_unitstate` settles it by asking.** ★★ IF it exists, the swapped order is a silent-failure trap worth the warning — retail documents `positionZ` as *"Always 0, a placeholder"*, so even a working call may not carry a usable z here. ★ What IS established: stock 3.3.5 has **no Lua returning a world z at all**, so external documentation describes a different function than the one we call |
| **Movement constants: base run 7.0 yd/s · gravity 19.29110527 · a player's jump apex is NOT a server constant** | addons · §280 · emulator source: `baseMoveSpeed[MOVE_RUN] = 7.0f` (`Unit.cpp`) and `gravity = 19.29110527038574` (`MovementUtil.cpp`). ★ **7.0 corroborated by our own capture to three decimals — `test1` median moving speed is 7.000**, which also settles a wiki disagreement (Fandom says 7.1111; the emulator and our data agree against it). ⚠⚠ **The jump apex cannot be looked up:** `MovementInfo` carries a per-jump `zspeed` **sent by the CLIENT**, so no server constant for a player's apex exists — apex = `zspeed² / 38.582`. ★★★ **MEASURED §284, and all three prior candidates are dead.** Four flat on-foot jumps read between **`IsFalling`'s edges** (the client says airborne — no shape-hunting in `z`): apex **1.6289 / 1.6359 / 1.6387 / 1.6404**, spread 0.0115. ★★ The sampled peak under-measures by at most `0.5·g·(dt/2)² = 0.0965 yd`, because near the apex vertical velocity → 0 — so the **true apex lies in [1.6404, 1.7368]** and the implied launch is **7.955–8.186 yd/s**. ★ **`zspeed = 8.0` exactly gives 1.6588, the only candidate in range.** ⚠ EXCLUDED: `terminal_safeFall_length` 1.27002 and the folklore 1.5 are both *below the measured peak*; **our own §73 figure of ~1.9 is above the bound and is retired** — it came from runs that were never landed. `DEFAULT_PLAYER_COMBAT_REACH 1.5f` is horizontal and a likely source of the folklore. ★ Mounted jump measured 1.5726 and mounted top speed **17.50 yd/s** — still well under `MAX_CLOSING_SPEED`'s 30. Reproduce: `records/*__unitstate.json`, `py addons/tools/walk.py w32` |
| ★★ **`UnitPosition` DOES NOT EXIST on this client — asked and answered** | addons · §284 · the `unitstate` probe records `declared["UnitPosition"] = "nil"`. ⚠ This retires a row I wrote earlier the same day claiming it existed with swapped `y, x` order, inferred from a **`pcall` call site** in a third-party addon — which is evidence of an *attempt*, not existence. ★ The census also said absent, but the census **cannot prove absence** (the whole supertracker API is missing from it and works), so neither source settled it; the probe did, by asking. **`GetCurrentPlayerPosition` is the only world-position getter here** |
| ★ **CHARACTER HEIGHT is measurable in-game against a water surface — no DBC extraction** | addons · §284, Battlewrath's method. Water is a fixed plane, so wading changes only the GROUND: standing with the surface at the ankles vs at the hips differs by **0.9645 yd**, giving a hip height of ~1.06 yd and a total of ~1.9–2.1 yd for a Forsaken — inside the 173–189 cm reference bracket. ⚠ A mark taken with the surface at the HEAD is unusable: `IsSwimming` reads `1` there, so the feet are off the lakebed. ★ And the absolute values corroborate the base-point row above — ankle-deep reads **−0.11**, hip-deep **−1.08**, which are *foot depths*; a model-centre origin would have put ankle-deep near **+0.85**. No Lua API reports model height (no `UnitHeight`, no bounding radius, no model scale — checked), so this or the packed DBC are the only routes |
| ⚠⚠ **Across a map boundary, supertracking returns state Invalid with distance `0.00` — NOT nil** — while `IsSuperTrackingAnything()` still reports true | addons · **ZERO SATISFIES EVERY RADIUS TEST**, so any distance-only *"am I there yet"* check fires the instant you zone. A loading screen does the same. `GetSuperTrackedPosition`'s distance is engine 3D yards (mean error 1e-5 over 1,758 samples). ⚠⚠ **§267 CORRECTION — this row used to end *"never compute your own", and that instruction is OVERRULED.*** Battlewrath ruled 2026-08-17 (asklist H0-b): **detection uses our OWN positions; the tracker's reading is for CALIBRATION.** The original guard was against *two distances that disagree* — the 1e-5 proof retired that risk, and computing our own is the only thing that makes a declined `0.00` detectable at all. ★ Measured much harder since: a cross-map pin was accepted **silently** and returned **1,386 consecutive confident zeros** while our own arithmetic read 1,946–2,217 yd (`test2`, RFC walked holding an SFK pin) |
| ★★ **`GetTargetState()` SEPARATES A DECLINE FROM A DISTANCE — and carries a proximity flip at 5.5 yd** | addons · *(measured; **6,809 rows across 8 runs, TWO INSTRUMENTS and both environments** — 4 satnav probes outdoors 2026-08-12, 4 DungeonRun dev captures in two dungeons 2026-08-17)*. **`0` = declined** (cross-map pin: 1,386/1,386 rows) · **`2` = tracking** · **`4` = inside the flip**. The boundary brackets to **(5.4603, 5.5172]** — 5.0 and 6.0 both excluded, and **0 rows contradict `sd ≤ 5.5 ⟺ ts == 4`**. ★ **No hysteresis** (inward 4.65–6.36, outward 4.63–6.37) and **no speed dependence** (flip distance flat across 3.58–5.60 yd/s), so it is a live distance threshold and not a lag — **nothing about it needs debouncing.** ★★ The two instruments were built for different jobs five days apart and neither knew about this; the outdoor probes **tightened** the indoor bracket rather than merely agreeing with it. ⚠ **STILL BOUNDED:** every pin measured was one WE set — a real quest POI has never been walked, so a per-POI radius is *unexcluded, not ruled out*; and `sd` is 3D, so this close a 2D threshold fits the same data. ⚠⚠ **The client acts on NONE of it** — the pin survived four round trips in and out, so this is a state to READ, never a satisfaction signal. Satisfaction stays the consumer's own rejection rule. Reproduce: `py addons/tools/read_tracker_state.py threshold` |
| **`pcall`'s FIRST return is "did it error"**, not the callee's boolean | addons · ⚠ `local ok = pcall(f)` counts every call as a success. Under `pcall`, all return values **shift by one** |
| **The `cond and X or Y` idiom BREAKS whenever X is itself falsy** | addons · confirmed live, twice. **Banned in this codebase** in favour of plain `if`/`elseif` |
| **A `local function` referenced ABOVE its declaration resolves to a nil global** — and `SetScript("OnUpdate", nil)` is legal, so the handler silently never runs | addons · ⚠ recorded **five times across two addons** because it shipped live twice. Dropping `local` to "fix" it leaks into `_G` |
| **SavedVariables globals do not exist while a file body executes** — the DB is nil until `ADDON_LOADED`; and at `ADDON_LOADED` a frame has **no rect** (`GetLeft()` = nil) | addons · UI modules must reach data through an accessor, and any anchor migration must wait for the first laid-out frame |
| **`GetLeft`/`GetTop` return values in the FRAME's scale space**, not UIParent's | addons · same family as the `GetCursorPosition` rule — a saved position drifts every time the user rescales |
| **CoA's classes are ENTIRELY CUSTOM** — no Warrior/Paladin/Druid/DK | addons · ⚠ any `UnitClass`-based role detection never matches, so ported class logic is **silently dead** here |
| **`{ pcall(f) }` + `#` is a TRAP** — a nil anywhere makes a sequence with holes, so `#` under-counts. `select("#", ...)` is the only honest count | addons · ⚠ bit on live use: **eight values asked for, two recorded** |
| **`GetSpecializationInfo` is NOT a pure getter** — it migrates AND CLEARS legacy fields and auto-creates db entries | addons · ⚠⚠ **a "read" that mutates state.** Decode names offline from `WTF/SpecializationSaved.wtf` instead |
| **An unsupported macro conditional and a currently-false one are BOTH falsey** — only asking **both polarities** (`[x]` and `[nox]`) separates them | addons · ★ the core method for probing conditional support on **any** client |
| **`GetAddOnCPUUsage` returns 0** unless `scriptProfile` is 1 **and** the client has reloaded since | addons · ⚠ a zero column is otherwise misread as "free" |
| ★★ **`Screenshot()` exists, and AT MOST ONE FILE SURVIVES PER SECOND** | addons · *(measured 2026-08-15)*. The name carries one-second resolution, so a second shot inside the same second yields **no extra file** — silently. ⚠ Measured against the filesystem, not the client: 4 requests → 3 files. A same-frame pair gave ONE; `C_Timer.After(0, ...)` (next frame, same second) gave ONE; a 1.2s gap gave TWO. ★★★ **So spacing is a hope and counting is the check** — anything automating shots must compare labels written against files landed, or the index runs quietly off-by-one from the first collision onward |
| **`Button:Click()` dispatches `OnClick` SYNCHRONOUSLY** — the handler has run by the next statement | addons · *(measured 2026-08-15, live)*. ★ So a text-driven test can press and assert on the same line |
| ★★ **`Click()` FIRES ON A HIDDEN FRAME** | addons · *(measured)*. ★★★ **This is the fact that shapes a UI test**: a script needs no *open the pane first* ordering, so the whole class of "it failed because the wrong pane was up" does not exist. CheckButton inherits Button, so a tick is pressable the same way |
| **`CheckButton:GetChecked()` returns `1` / `nil`, NOT `true` / `false`** | addons · *(measured)*. ⚠ The same 3.3.5-ism as `UnitExists` and `IsInInstance` — test truthiness, never `== true`. Audited across this repo when it was measured: no site compares against `true` |
| **The chat edit box is capped at 255 letters** — `ChatFrameEditBoxTemplate` declares `letters="255"` | addons · **sourced from the client's own `FrameXML/ChatFrame.xml:21`**, not recalled. ⚠ Anything driven by typed text — a test script, a `/run`, a slash verb — must fit one line in 255. ⚠⚠ **The MACRO-FILE limit is a DIFFERENT number and is NOT this one**; no MacroFrame exists in the patch-B extraction, so it is unknown here and belongs to the **macros** bench, whose standing rule is that recall is inadmissible |
| **Addon Lua cannot read files from disk** — a build can only be identified by a runtime structural fingerprint | addons · file hashes are an offline step |
| **`AutoComplete_Update`/`GetAutoCompleteResults` is a C API returning PLAYER NAMES only** | addons · ⚠ the stock inline-completion mechanism cannot be reused for any other vocabulary — it must be replicated |
| **`AtlasInfo[name] = {texture,w,h,left,right,top,bottom,flipH,flipV}`** — and `SetAtlas` additionally forces native size and **fails silently under `pcall`** | addons · texture + `SetTexCoord` read straight off `AtlasInfo` is the deterministic path |
| **`C_NamePlate.GetNamePlateForUnit` FAILS at `NAME_PLATE_UNIT_REMOVED` time** — the plate is already gone when the event announces it | addons · **20/20 live**. ⚠ Removal must resolve from the addon's **own** unit→plate map; any trigger that asks the API on removal simply never fires |
| **The SAME creature is announced under TWO unit tokens at once** — e.g. `nameplate1` *and* `target`, same GUID, same plate frame | addons · ⚠ unguarded, **every consumer double-processes one plate**. Guard on the GUID, never the token |
| **`UnitDetailedThreatSituation` returns nil ACROSS THE BOARD when you have no threat-table entry** | addons · ⚠ indistinguishable from *“no threat”* unless checked first. ⚠ `rawPercentage` can **exceed 100** and stops updating past the pull — it ranks, it does not measure |
| **The client's native aggro highlight is `_G[healthBarName .. "aggroHighlight"]`**, not a field on the health bar | addons · ⚠ `healthBar.aggroHighlight` was a guess that failed **100% deterministically** and read as a styling problem. The frame is reachable only by constructed name |
| **`WorldMapDetailFrame` is 1002×668 in COORDINATES while its tile art is 4×3×256 = 1024×768** | addons · ⚠ the client's own map clips the padding rather than exposing it, so anything drawing on the detail frame carries the ratio |
| **`WORLD_MAP_UPDATE` fires whenever the displayed map changes** | addons · the correct rebuild trigger; no timer needed |
| **`debugprofilestop()` exists and is callable anywhere** — a free-running ms counter, not combat-restricted | addons · from **Wowpedia** (secondary). ⚠⚠ **But it can SILENTLY NOT ADVANCE**: a 0 ms observer cost means *distrust the reading*, not *it was free* — observed, and therefore governing (**invariant 8**). The driver's 0.0061 ms/scan over 7079 scans is safe because the total was non-zero |

---

## ROUTING — which bench holds a concept

_A bench fills **its own row**. An empty cell means that bench has not built a shelf yet, not that it
has nothing to say._

| Concept | Bench | Where |
|---|---|---|
| client API: what to reach for, and the traps | **addons** | `addons/maps/intent.md` |
| **code shapes** — structures solved once (registry-not-a-slot, create-then-edit, new-else-original, transient handler, by-exception envelope, control-before-conclusion) | **addons** | `addons/maps/intent.md` · *Shapes* |
| rulings and measured facts living **in code** | **addons** | `addons/maps/notes.md` (emitted) · `py addons/tools/emit_notes.py` |
| **combat log** — filtering, pet flags, what a listener COSTS | **addons** | `addons/maps/intent.md` · *Combat log (CLEU)* · study: `addons/planning/cleu_on_this_fork.md`. ⚠ The tuple LAYOUT is above in this file — it is a client fact, not an addons one |
| what the client declares at all — `_G`, atlas, worldmap | **addons** | `addons/maps/census/` · `maps/atlas/` · `maps/worldmap/` |
| **UI layout geometry, and auditing a pane for overlaps** | **aura** (origin) · **addons** (copy) | `Weak Auras/geometry.py` + `space_audit.py` → copied to `addons/tools/geometry.py` + `layout_audit.py`. ★★ **A COPY, NOT AN IMPORT** — a shared module both benches must agree on is §63's fault at the repo scale; each bench adapts its own. ⚠ **The addons side found this only because he said it existed**: a pane was hand-positioned with magic y-offsets and shipped exactly the overlap `geometry.py`'s docstring already names. This row is the fix for that |
| **Checking a pane's layout WITHOUT the client** | **addons** | `addons/tools/smoke/frames.lua` — a stub that KEEPS its geometry: it records `SetPoint`/`SetSize`, resolves the anchor graph to absolute rects, and reports overlaps and overhangs. Run by `smoke_dungeonrunpromoter.lua`; `py addons/tools/pane_audit.py` prints the inventory. ⚠⚠ **It cannot know a FontString's extent** — that is text × font, and the one thing only the client can answer. `F.Unmeasured()` NAMES them rather than guessing, and that list is what a measuring run turns into constants. ★ The 2010 `WoW UI Designer` approximated font metrics and its own notes concede they were wrong; we have the client on access, so we do not have to |
| **What a DungeonRun beacon/route/run IS** | **addons** | `addons/planning/dungeonrun_model.md` — ★★★ **the heading**: the mission, **capture is the only spawn**, the two lanes, **a beacon is a THEATRE not a point**, the ratchet, and what is deliberately absent. ⚠ `dungeonrun_poc.md` is a 70,000-word ARCHIVE routed to by kind — **do not read it through**. Short version first, always |
| **How a COA_DungeonRun surface WORKS — before tracing source** | **addons** | `addons/planning/interface/<surface>.md` — one file per surface: what it **does**, **how**, what it **refuses**, what it **holds**, how you **interact**, and every child with its numbers and how it forms in code. ★★★ **The answer is usually already formed** — six surfaces, and this exists because nearly every question was answered by a grep, three of them wrongly. ⚠ THREE REGISTERS: `interface/<surface>.md` is FACTUAL and is the **authority** (the code complies with it); `interface/devlog/<surface>/<feature>.md` is the reasoning, including the wrong turns; the **hopes** at each file's foot are directional. ⚠⚠ Nothing reaches the client that is not in the factual file first. Index: `addons/planning/dungeonrun_interface_inventory.md` |
| what our own addons declare and cost | **addons** | `addons/maps/addons/<Addon>/routes.md` · `frame_cost.md` |
| WeakAuras mechanics, the corpus, adoption | **aura** | `memory/aura-shelf.md` → `operations/` *(no intent shelf yet)* |
| the macro surface: sourced commands, probed conditionals | **macros** | `memory/macros-shelf.md` → `operations/Macros.md` |
| class mechanics, theorycraft, per-class findings | **class_design** | `memory/class-design-shelf.md` → `operations/Class_design.md` |
| class feel, story, identity | **class_identity** | `memory/class-identity-shelf.md` → `operations/Class_identity.md` |
| turning identities into music | **suno** | `memory/suno-shelf.md` → `Class_identity/Suno/` |

---

## How to use it

**Adding a universal fact:** name it, name the bench, name the provenance. If a live run proved it,
say *(measured)* and which instrument. ★ **Do not move it out of the code** — the note stays where it
governs something; this is a pointer, and proximity is what makes a note work at all.

**Adding a routing row:** your own bench only. ⚠ The lane rule stands — *hand off across it, do not
write another bench's documentation.*

**When it is empty for you:** say so. ★ A checked blank and an unexamined blank look identical
afterwards, and only one of them is a decision.

**⚠ Correcting a row:** say the row is corrected and **leave the old instruction visible**, as the
supertracker row now does. A silently rewritten fact is indistinguishable from one that was always
right — and a bench that acted on the old form has no way to find out that it moved.

---

## ⚠ OPEN — raised by Battlewrath, 2026-08-17, not actioned

> *"Maybe at some point transfer some material in house. A lot of that basis is our project needs."*

★ Several rows here are **addons-project needs wearing the clothes of client facts.** The split at
the top of this file already gives the test — UNIVERSAL vs APPLICATION — and it has been applied
loosely, in one direction: things got added here because they were *learned* here, not because
another bench would ever hit them.

**The test when this happens: would a DIFFERENT bench hit this?** If only we would, it belongs on
our shelf. ⚠ And moving a row is not deleting it — the addons bench keeps it, this file keeps the
pointer, or the fact simply stops being cross-bench and nobody is worse off.

⚠ Flagged rather than done, so it survives a compaction. Whoever picks it up should read this as a
question to work, **not as a backlog item that has already been agreed** — the rows worth moving
have not been named, and naming them is most of the work.
