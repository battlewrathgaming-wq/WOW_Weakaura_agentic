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
| **`OnTextChanged` is DEFERRED** a frame, **COALESCED** to one fire however many sets, and **CHANGE-ONLY** — setting the same value fires nothing | addons · *(measured, `/coadump r api` run 5)* |
| its **2nd argument `userInput`** is `false` for a programmatic `SetText`, true when a human typed | addons · *(measured)*. ★ The clean way to stop a refresh loop, rather than comparing before writing |
| the handler reads the **final** text, not the value that triggered it | addons · *(measured)* — a raced `first`/`second` reports `second` |
| **`IsInInstance()` returns `1`, not `true`** (plus the type string) | addons · *(measured)*. Test truthiness, never `== true` |
| **These THROW rather than returning nil:** `UnitName` · `UnitClass` · `UnitIsGhost` · `GetPlayerMapPosition` · `GetCVar` · `GetDifficultyInfo` · `GetAddOnMetadata` | addons · *(measured)*. ⚠ `local n = UnitName(u); if not n then` never reaches its check. `GetDifficultyInfo` throws from **inside the client's own** `GlobalFunctions.lua:263` |
| **`SetTexture` does NOT reset `TexCoord`** on the raw texture API — the crop survives | addons · *(measured)*. ⚠ The reset lives in a **stock Lua wrapper** (the POI mixin path); generalising it to the raw API shaped a test suite wrongly for months |
| **Lua 5.1 SILENTLY DROPS an unknown escape** — `"Interface\Path"` becomes `InterfacePath`, no error | addons · *(measured against `.tools/lua51`)*. Shipped a border-less frame for weeks. Guard: `addons/tools/check_escapes.py` |
| `SuperTrackerUtil.SetSuperTrackedPosition(x,y,z,mapID)` works; **`C_SuperTrack.*` is silently overwritten** | addons · AC-17. Looks right, skips the priority ladder |
| **`InputBoxTemplate` EditBoxes MUST BE NAMED** — its `$parentMiddle` texture anchors relativeTo `$parentLeft`/`$parentRight` **by name**, so a nameless box loses its middle and renders as two floating end-caps | aura/addons · **cost a live bug in `COA_Landmarks`**, carried into `COA_DungeonRun/widget.lua`. ⚠ And broken again in `task_api.lua` the day this router was written — an audit found it, not a person |
| **`GetCursorPosition()` is in SCREEN pixels** — divide by the effective scale of the **FRAME you compare against**, never `UIParent`'s unless that IS the frame | addons · ⚠ **masked whenever the two scales happen to match, which is the default** — so it is correct by coincidence until something rescales. `COA_Landmarks/minimap.lua` mixed Minimap-space against UIParent-scale; `MancerLedger/minimap.lua` had it right all along. **The bench held both the bug and its fix and neither site carried a comment.** Found by audit |
| **Combat state: EDGES FROM THE EVENTS, STATE FROM THE API.** `PLAYER_REGEN_DISABLED`/`_ENABLED` mark the transitions; `UnitAffectingCombat("player")` is the state, read fresh | addons · ⚠ **`PLAYER_REGEN_ENABLED` also fires when lockdown lifts for reasons that are not a pull ending.** ★ Cross-checked against the **installed WeakAuras fork** — `WeakAuras.lua:1700-1701` registers both events, `:1570` recomputes the API call on every scan. **The aura bench's own subject already answers this**, which is this router's thesis in miniature |
| **`AscensionUI.DeathRecap` is readable ONLY at `PLAYER_DEAD`** — `CurrentRecap` rolls on `PLAYER_UNGHOST` and `PLAYER_ENTERING_WORLD` | addons · fork-specific. ⚠ It folds `SPELL_HEAL` as well as damage, so `attacker` can be a **healer** — filter on `isPlayer` or you attribute a death to whoever healed you |
| **CLEU on 3.3.5 is the classic VARARGS tuple** — `1` ts · `2` subevent · `3-5` src (GUID, name, flags) · `6-8` dst · `9+` suffix. `CombatLogGetCurrentEventInfo` is **furniture** on this fork | addons · verified in `addons/planning/pet_parser_scope.md`. ⚠ Suffix positions: SWING crit `15` · SPELL amount `12` / crit `18` · SWING_MISSED missType `9` · SPELL_MISSED `12`. **Any bench writing a combat-log trigger needs this** |
| **`UnitExists` returns `1`, not `true`** — never compare against `true` | addons · the archetypal 3.3.5-ism, and the same shape as `IsInInstance` |
| **`GetPlayerMapPosition` returns `0,0` when the world map shows a DIFFERENT zone** — `SetMapToCurrentZone` fixes it, but is only safe to call while the map is **hidden** | addons · *"the single most common map-coord bug"*; pfQuest guards identically. ⚠ `GetCurrentMapDungeonLevel` has the same disease — it reports the floor **the map is showing** |
| **The mapID from `GetCurrentPlayerPosition` is the CONTINENT**, not the zone the world map draws | addons · ⚠ a stored fraction is valid **only** against the continent+zone pair it was taken on — matching on mapID alone scatters every pin across the continent |
| ⚠⚠ **Across a map boundary, supertracking returns state Invalid with distance `0.00` — NOT nil** — while `IsSuperTrackingAnything()` still reports true | addons · **ZERO SATISFIES EVERY RADIUS TEST**, so any distance-only *"am I there yet"* check fires the instant you zone. A loading screen does the same. `GetSuperTrackedPosition`'s distance is engine 3D yards (mean error 1e-5 over 1,758 samples) — **never compute your own** |
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
