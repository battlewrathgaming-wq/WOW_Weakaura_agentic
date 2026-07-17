# backlog — the missions

_Ordered by leverage. Each is designed and waiting on exactly this bench._

## ✅ THE FIRST GOAL — DELIVERED 2026-07-15 (same day it was set): the CLIENT-SURFACE CENSUS

**`addons/maps/census/` is the deliverable** — start at `census.routes.md`, then `runtime/runtime.routes.md`.
Three witnesses joined: DECLARED (patch-B.MPQ extraction — ALL client code in one 6.8MB archive; 88 C_* namespaces
/ 1028 attested members / 736 events, 213 custom-registered) × BASELINE (stock 3.3.5 run from the client's own
APIDocumentation addon) × RUNTIME (the `census` task's cycled 51,855-global _G walk) → 91 runtime namespaces,
1003 attested + **284 runtime-only members** (zero shipped call sites), function buckets. Tools:
`extract_interface.py` · `baseline_extract.lua` · `emit_census.py` · `reduce_census.py` (all deterministic,
sha256/runId-anchored). Refinements banked, not blocking: clean-profile re-run (splits the 1526 unattributed
functions) · the 8 listfile-less art archives · 5 failed GlueXML extracts (named in the manifest).

## ✅ 1. The spec capture — CLOSED 2026-07-17 (source reframe + live record)

Record `20260717_042419_240__spec.json`: **numSpecs=20** (the observed 20-entry list = 20 swap-spell
slots, contiguous dev block ~979986+), 1 unlocked, active=1, both systems captured (SpecializationUtil +
C_CharacterAdvancement). Names confirmed absent by design — they're player labels (see the reframe below);
`load.specialization` = per-USER config keyed by INDEX. The aura bench can wire it on that basis. The
reframe note (kept):

## (reframe) 1. The spec-name capture — REFRAMED BY SOURCE 2026-07-17 (task `spec` deployed, capture pending)

**The source finding (SpecializationUtil.lua, patch-B):** spec NAMES are PLAYER-AUTHORED labels in a
per-character custom WTF file (`SetSpecializationName` → `SpecializationSaved`; default "Specialization N")
— **not class facts.** A per-class index→name map is not derivable; the mechanical key WA stores is the
INDEX, and the per-slot game facts are `SPEC_SWAP_SPELLS[i]` + `IsSpecializationUnlocked(i)` (IsSpellKnown-
derived) + `C_CharacterAdvancement.GetActiveSpecID`. **Implication for the aura bench:** `load.specialization`
is per-USER config (their own labeled slots), not pack content. Trap found + avoided: `GetSpecializationInfo`
runs a legacy migration that MUTATES saved data — the deployed `spec` task uses pure getters only. Original
mission text below (kept for the trail):

## (original) 1. The spec-name capture (unblocks `load.specialization` for EVERY pack)

The load's `specialization` is an index-keyed multiselect (fork `Prototypes.lua:1075`, `IsSpecActive(i)`, domain
built live per class via `SpecializationUtil`). We need **index → spec-name per class** (a 20-entry list was observed).
Two routes: read WA's own Load-tab dropdown (it renders `"i. Name"` — the exact stored keys), or a dump tool calling
the SpecializationUtil API directly (mind: a naive one-liner returned `nil nil, true` — the return signature needs
source-checking first). Capture per class character. Output → a map (`spec_index.json`-shaped, per class, anchored).
**Now census-backed:** read the rows first — `maps/census/namespaces/C_CharacterAdvancement.routes.md` (spec
members incl. GetActiveSpecializations-family) + the `ASCENSION_CA_SPECIALIZATION_ACTIVE_ID_CHANGED` event
(events.json, registered) + `SpecializationUtil` sightings; build the task file (v2 spine) from those citations.

## ✅ 2. The tooltip gap-fill — CAPTURED 2026-07-17 (119/119, all SetSpellByID)

Record `20260717_042514_616__tooltip.json`: every custom-range description hole rendered by the game
itself (`derive_tooltip_holes.py` → `maps/tooltip_holes.json` = the derivation; `tooltip holes` = the
baked task arg). REMAINING (small offline gear, unbuilt): merge the rendered lines into the inventory
text for those ids. Original design below:

## (original) 2. The tooltip gap-fill micro-scan (~13 spells; designed 2026-07-12, parked)

The description holes the scrape couldn't carry: ~13 custom-class spells with raw `$`-variables or NULL text (the
Necromancer minion-command set etc.). `GameTooltip:SetSpellByID(id)` → read `GameTooltipTextLeftN:GetText()` → dump →
merge into the ability text. Bounded read-only ID list; the render is the ARBITER (accept-empty only on the game's
verdict). COA_DevDump extension — the design is in the memory/warm-start trail.

## 3. The WA-env harvest (the scripting lane's chartered first step)

For `creator/ingredients/custom.md`: harvest the aura-script sandbox surface — the allowed API (inverse of
`AuraEnvironment.lua`'s `blockedFunctions`/`blockedTables`) + the TSU state contract. Method: source-scan first
(the live_keys pattern); a dump addon only for what's runtime-built. Output → a map the palette cites.

## ✅ 4. The macro-conditional probe — DELIVERED 2026-07-17 (5-context matrix, beyond the asked pair)

Records `20260717_04*__macros.json` (+ `20260717_contexts.md` labels): rest / spell-form / stealth /
combat / mounted. Control row settled in all five (`@` = pass-through); [combat] polarity flips with the
independent stamp (triangulation proven); two free stamp findings (stealth = form 1; the spell-form is
GetShapeshiftForm-invisible). **The verdict map is the MACROS bench's next build** — raw is on the trunk.
Harness: `wrap_payload.py` + `task_macros` (payload verbatim, sha-anchored). Original ask below:

## (original) 4. The macro-conditional probe (cross-lane ask — STAGED, designed, one bounded pass)

**THE ASK: `macros/probe/ASK.md`** (payload `probe_core.lua` + `probe_rows.json`). Staged by the macros bench
2026-07-17; **the harness is yours** — this is the payload and the read, not a task file.

Your standing item says "addon-side captures may serve where source-scans stall." This is that case exactly:
`macros/basis/conditionals.json` is **empty and unfillable from source** — `SecureCmdOptionParse` is called 49× in
`ChatFrame.lua` and **defined nowhere in Lua** (your own census buckets it `stock-capi`), so the conditional
vocabulary lives in the binary; the attested-usage seed measured **zero** (no conditional literal in any shipped
file). The live client is the only channel.

**Bounded:** one task, one pass, ~90 reads (63 flag pairs + 13 targets + 1 control + ~30 context), **pure reads, no
state touched**, resident API only — **every call verified present in `maps/census/runtime/globals.json` before
composing**. Compiles under Lua 5.1 (`luac5.1 -p`) and exercised headlessly against stubs. **No restart needed to
try it** — plain `/run`, or the client's built-in dev console (`/luaconsole`), which is the cheap iterate-first path.

**The one request: land it RAW.** `run()` returns `schema="macros.probe.raw/1"` — the parser's own returns
(`flags[x].pos/.neg`) plus a context stamp. It deliberately computes **no** verdicts in-game: those are derived
offline in a map, so a wrong matrix costs a re-derivation instead of another client session. Broad now, consolidate
after.

**Two riders:** read the `[@banana]` control row first (it decides how all 13 target rows are read); and a second
pass in a *different* context (in combat / mounted / in a form) separates "false here" from "always false" — but
**don't block on it, one pass is worth landing.**

## Standing / emergent

- **COA_DevDump hygiene**: it's the seed tool — adopt it into this bench deliberately (repo copy is the dev copy;
  deploy step to the client; version anchor in its .toc).
- **The existing root material** (`Mob_Autogroup/`, `Addon refs_threat/`): assess → adopt-by-rebuilding or archive.
  Not precious.
- **Whatever the aura bench's walls need next**: combatlog subevent keys (a GenericTrigger code-scan), the
  per-region animation-capability harvest — addon-side captures may serve where source-scans stall.
