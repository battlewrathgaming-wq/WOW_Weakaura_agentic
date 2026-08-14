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
| **`debugprofilestop()`** is available for self-measurement | addons · used by the route driver: 0.0061 ms/scan over 7079 scans *(measured)* |

---

## ROUTING — which bench holds a concept

_A bench fills **its own row**. An empty cell means that bench has not built a shelf yet, not that it
has nothing to say._

| Concept | Bench | Where |
|---|---|---|
| client API: what to reach for, and the traps | **addons** | `addons/maps/intent.md` |
| **code shapes** — structures solved once (registry-not-a-slot, create-then-edit, new-else-original, transient handler, by-exception envelope, control-before-conclusion) | **addons** | `addons/maps/intent.md` · *Shapes* |
| rulings and measured facts living **in code** | **addons** | `addons/maps/notes.md` (emitted) · `py addons/tools/emit_notes.py` |
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
