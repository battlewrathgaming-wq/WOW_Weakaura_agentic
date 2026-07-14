# findings — what the coverage packet has caught (running log)

_The instrument's purpose: find gaps, not celebrate the proven. Every entry: found → disposition._

## 2026-07-14 — first firing (36 members, 8 region types, 8 trigger types)

1. **GATE CRASH on dict-valued declare** — `debuffClass: {magic: true}` (a trigger-multiselect stored form) hit the
   domain check's scalar assumption → TypeError. **FIXED**: domain check validates dict KEYS (`gate.py`).
2. **GATE VOCABULARY missing stored-form companions** — prototype-driven surfaces (spell/unit/item/combatlog/addons)
   list the arg (`spellName`) but not `use_<name>` / `<name>_operator` / `use_exact_<name>` — which ConstructFunction
   REQUIRES in the stored form (participation @815). aura2 masked this (its harvest carries explicit toggles).
   **FIXED**: gate accepts a companion when its base arg is on the surface (map-cited, `gate.py _companion`).
3. **combatlog `subeventPrefix`/`subeventSuffix` not on the options surface** — stored keys the options builder never
   enumerates (the aura2-residue story's cousin, reversed: handler-read but never optioned). **RECORDED boundary**;
   the spellId route used in the row. Resolve when the combatlog surface gets its liveness harvest.
4. **Press hygiene** — a renamed row left its stale docket behind. **FIXED**: the press cleans its pid's files first.
5. **KNOWN WALL (by design): nested groups** — `group`/`dynamicgroup` can't ride as members (bundle is flat-only);
   the packet's own group covers dynamicgroup. Unbuilt, on record.

**Round-trip verified through the machine:** 55 staged 0 blocked · packet packed (36 members, 4274 chars) · decode:
3-trigger member intact (types + disjunctive + per-trigger conditions), custom function string verbatim,
activeTriggerMode preserved, subtext canon-completed. Regions shipped: icon 18 · aurabar 8 · text 2 · texture 2 ·
progresstexture 2 · stopmotion 1 · model 1 · empty 2.

## 2026-07-14 — the sourcing debts, paid same evening

- **Conditions-variable surface → `maps/condition_vars.json`** (`emit_condition_vars.py`): 37 surfaces, 238 variables —
  surfaced from data ALREADY harvested (index rows carried `conditionType` all along; aura2 = the sheet's provides).
  Validates the packet's condition guesses: `onCooldown`/`spellUsable`/`insufficientResources` are real Cooldown
  Progress (Spell) vars.
- **Prototype-arg attributes → `maps/trigger_args.json`** (`harvest_trigger_args.py`): 44 trigger prototypes, 473 args
  (+45 load args) with `required`/`multiEntry`/`enable`/`init`/`conditionType` — the attributes build_index's flattener
  dropped, kept from the raw `extract.lua prototypes` dump. Immediate yield: `spellName` is **required** (participates
  without `use_`), `showExactOption` present.
- **combatlog subevents, sharpened:** `subeventPrefix/Suffix` are neither optioned NOR prototype args — handler-special
  (GenericTrigger builds the CLEU registration from them in code). Their harvest = a GenericTrigger code-scan
  (live_keys' method), when combatlog earns its palette file.

## 2026-07-14 — LIVE GRADING (Battlewrath, in-game; packet landed clean in whole)

6. **V17 (GTFO alertType): a SELECT stores the KEY, not the display string.** Landed as an unset select —
   `"High Damage"` shipped, but `gtfo_types` is array-keyed (`1=High Damage`). Root: an array-keyed Lua domain
   serializes to a JSON LIST → displays kept, keys became positions → the gate's dict-only domain check couldn't run.
   The keys are DERIVABLE (list domain ⇒ 1-based indices), so: **FIXED at the gate** (list-domains validated as
   indices, the verdict note carries the key→display mapping) + the row corrected (`alertType: 1`). Demonstrated:
   the old form now BLOCKS. Class closed for every array-keyed select domain, not just GTFO.

7. **LIVE CRASH (test events): machine-made auras lacked `subRegions` entirely.** `RegionPrototype.lua:45
   ipairs(data.subRegions)` — WA's runtime iterates the field unguarded because every UI-created aura carries it
   (the UI seeds it; the live capture's aura has `subRegions: []`). Canon does NOT seed it (our shipped Blight: 32
   fields, no subRegions) — ours were the first bare auras WA has ever met. Import/display fine; any subregion walk
   (anchor resolution, test events) crashes. **FIXED at fill**: `subRegions` always present, `[]` minimum,
   capture-grounded. Affects ALL products latently → the end-of-grading re-press picks it up everywhere.

## The round trip — VERIFIED LOSSLESS (2026-07-14, the final check)

Battlewrath re-exported the imported packet from WA; full table diff vs our shipped string
(`ingest/inbox/export_20260714_roundtrip_coverage.txt`, diff classified ADDED/MUTATED/DROPPED):
- **36/36 members both ways; zero of our content mutated; zero dropped.** uid/id/loads byte-stable (the
  `use_class` multi form and the `use_never` sentinel round-trip exactly); V10's spell trigger field-identical.
- **Every delta is client-ADDED**: `tocversion`, per-region option defaults (the aurabar spark family, text font,
  progresstexture fore/background…), default subregions (icons +1 subbackground, bars +2 — our declared subtext
  preserved beneath the insertion), `activeTriggerMode: -10` on the triggers table. WA completing its own table on
  its own side — exactly the custody chain's claim, now proven from the client's mouth: **the only author of
  non-docket content is WA.**

## The live half — GRADED (2026-07-14, Battlewrath): landed clean in whole

Everything else passed. Yield of the full loop: **a reference sheet** (the ingredients palette), **a pressure test**
(this packet), **a validation loop** (press → gate → machine → decode → live grading → findings), and **3 live fixes**
(the select-key gate rule · the subRegions container · the V17 row). Post-grading re-press: all five packs regenerated
with the fixes — every member in every pack carries `subRegions`, V17 ships `alertType=1`. The packet re-imports
whenever the next system change wants its pressure test: `py coverage.py` → stage → pickup → import.

## 2026-07-14 — the reverse gear's first ore (the Necromancer capture, 36 auras)

8. **PRESS-PATH ESCAPE BUG (gear finding):** an aura whose custom-code string contains `\` escapes (LF Delta Test)
   breaks the fill→canon JSON/Lua boundary (`Invalid \escape`). The one closure failure in 36. Home: the canon
   bridge's string escaping (reconcile `_to_lua` / canon.lua's JSON emitter). OPEN — fix at the gear.
9. **Residue quantified in the wild:** hand-built auras carry heavy type-switch residue (the UI keeps old trigger
   fields — Blight 18, Lich frost 18, Glacial tap 14...). The stub's residue LEDGER measures pack hygiene per aura;
   the docket is cleaner than its source, and closure stays honest (CLEAN +n residue).
10. **Trigger-side participation law = a named wall:** event-prototype triggers are consumed by GenericTrigger's
   test path, NOT ConstructFunction:815 (that's the LOAD law) — ungated selects still count. v1 keeps present args;
   the GenericTrigger harvest closes it properly.
