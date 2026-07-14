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

## Awaiting the live half

Import `Docket_complete/verification-coverage.txt`. The checklist IS the member ids. Watch especially:
- **V34 MUST NOT APPEAR** (use_never sentinel) — if visible, load is broken.
- The prototype-trigger members (V10-V15, V17, V21-V22, V26, V28, V30): which are alive vs dead-config = the
  priority list for the next liveness harvests.
- V16/V23 (custom): do the functions run in the sandbox.
