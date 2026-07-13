# Phase 0 — finish the extraction; compile the contract

**Goal:** every WA domain self-reported into state sheets, merged into ONE
consumable artifact — `wa_index/contract.json` — the only file the filler reads.
Principles: P3, P4, P5, P6.

Most extraction machinery already exists in `wa_index/extract.lua` — modes
`prototypes` (also dumps `load_prototype`), `region`, `subregion`,
`regionoptions`, `animoptions`, `triggeroptions`, `seed_defaults`,
`aura_seed_defaults`. This phase is mostly EMITTERS, not new extraction.

## Work items

### 0.0 — the aura skeleton (data_stub)
WA declares its own minimal aura table: `Private.data_stub` (Types.lua:3284 —
a plain literal, so the existing `types` extract mode should ALREADY capture
it; confirm, don't rebuild). Its comment states WA's own standard: *the
minimal stub that prevents false positives in a reimport diff*. And WA ships
the ACCEPTOR that completes it: on every Add, `regionValidate(data)` →
`Private.validate(data, data_stub)` → subregion-default merge → Modernize
(WeakAuras.lua:2951). Shape the stub into the contract as the `skeleton`
domain. Consequence for the whole pipeline: we provide the MINIMUM, WA's own
machinery completes — the corpus is needed for NO structure (P11).

### 0.1 — load sheet
`statesheets/load/load.json` from the already-captured `load_prototype`.
Reuse `build()` in emit_state_sheet.py near-verbatim; it is one prototype in
the same arg shape. Sheet shape identical to the trigger sheets.

### 0.2 — display sheets
`statesheets/display/<region>.json` reshaping the existing region/subregion
dumps: `default` → seeds; `properties` → the condition-writable surface
(what condition `changes` may target); regionoptions display names joined on.
Include the `regionprototype` shared levers as a `_common` sheet for the domain.

### 0.3 — animations sheet
`statesheets/animations/animations.json` from the existing `animoptions` mode;
value-domain markers (anim_types etc.) resolve against value_domains.json.

### 0.4 — common trigger options
ONE new extract hook: capture `AddCommonTriggerOptions` the same way
`triggeroptions` captures builders; emit `statesheets/trigger/_common.json`.
Every trigger sheet is incomplete without it (name/icon/texture/stack code
boxes appear on ALL triggers). Already noted as the stub in build_custom().

### 0.5 — exclusivity probe (the modal sweep)
New emitter mode, no new technique (P5): per trigger type, sweep the probe
along its modal axes —
- custom: `custom_type` ∈ event / status / stateupdate
- aura2: `unit` × `debuffType` (player/target/multi × HELPFUL/HARMFUL)
- unit-family: `use_specific_unit` on/off
call the options builder once per probe state, diff the returned key-sets.
Output per option: `"enabled_when": {"axis": ["values"]}` — gating as data,
replacing the boolean `conditional` flag. The diff IS the modal structure.

### 0.6 — unresolved blocks (the honesty layer)
Every emitter appends `"unresolved": [{option, what_dropped, grade}]` for any
function-value it could not resolve (dropped `values=fn`, errored `name=fn`,
`(dynamic)` defaults omitted from default_state, failed pcalls). Grades per P3.
Without this the filler's rejections are not trustworthy.

### 0.7 — the contract compiler
`wa_index/compile_contract.py`: merge ALL sheets into one flat map —

```
(domain, type, event, option) → { input_kind, value_domain, default,
                                  required_seed, enabled_when,
                                  stores_condition_var, policy, grade }
```

→ `wa_index/contract.json`. Stamp `_meta` with WA provenance (versionString
5.21.2 Beta / internalVersion 86 / source-file hashes) — a provenance stamp on
the artifact, same habit as the export's VERIFICATION.md.

### 0.8 — corpus attribution check (P6)
`wa_index/attribute_corpus.py` (read-only verifier): every field observed
across the settled corpus (plane/diagnose.py stubs) + ingest reference pool
must map to a contract row or known residue. Unattributable fields = extraction
holes, reported loudly. Run once here; re-run whenever the contract changes.
Flavor question to answer while here: do Types_ClassicPlus.lua /
Types_Wrath.lua contribute value-domains the Types.lua pass missed?

## Exit gate
contract.json exists, covers skeleton / trigger (8 types + _common) / load /
display / animations, every row graded, unresolved lists emitted, corpus
attribution run with holes either closed or named-and-accepted.
