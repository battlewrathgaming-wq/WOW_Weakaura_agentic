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
