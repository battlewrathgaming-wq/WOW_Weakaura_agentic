# plane_v2 — the agentic pipeline spec (machinery-first)

Spec for the second plane: the pipeline that runs **without a human steering each
artifact**. plane/ (v1) proved the dumb assembler reproduces a hand-build
byte-for-byte; v2 wires the full chain — extraction → contract → docket → fill →
assemble → canon → encode → verify — as **hard machines with structured data
outputs**, so agents drive it end-to-end and every run leaves receipts.

This folder is SPEC (documents). Code lands in plane/ (extending v1) and
wa_index/ (extending the emitters) as each phase is built. Authored 2026-07-13
from the Fable review session; see blueprint/README.md for the reasoning spine
this fits inside — nothing here replaces it.

## The target data flow

```
coa_spells.json + mask + statesheets/          (FACTS — exist or phase 0)
        │
   [docket generator | agent]  →  docket.json          (the ONLY reasoning output)
        │
   [filler]      docket.json + contract.json  →  parts + fill_receipt.json
   [assembler]   parts + mask                 →  aura tables        (v1, extended)
   [canon]       aura tables                  →  canonical + canon_diff.json
   [encode]      canonical                    →  import strings     (codec, exists)
   [verify]      all of the above             →  receipt.json       (v1, extended)
```

Every arrow is a bench service (`py call.py <svc>`), deterministic, agent-free.
The agent's entire write surface is `docket.json`.

## The phases

| # | doc | build | unblocks |
|---|-----|-------|----------|
| 0 | [phase_0_extraction_contract.md](phase_0_extraction_contract.md) | finish emitters → **contract.json** | filler correctness |
| 1 | [phase_1_docket_schema.md](phase_1_docket_schema.md) | freeze the docket schema | filler, generator, agent |
| 2 | [phase_2_filler.md](phase_2_filler.md) | **fill.py** — the validator gate (R1–R7) | frame-invention becomes impossible |
| 3 | [phase_3_backend_services.md](phase_3_backend_services.md) | batch assembler + canon + encode as services | end-to-end runs |
| 4 | [phase_4_verify_receipts.md](phase_4_verify_receipts.md) | verify (V1–V4) + receipts ledger | unattended batches |
| 5 | [phase_5_first_product.md](phase_5_first_product.md) | docket generator over coa_spells.json | the pack; proof at scale |

Phases 0–1 are emitter/spec work. Phase 2 is the one genuinely new machine —
it gets the compiler checklist + Go gate. Phases 3–4 extend proven pieces.
Phase 5 is a batch run.

## Where the intelligence sits

Same law as v1 (blueprint: one reasoning element): all reasoning is in the
docket's author. v2 adds the STRUCTURAL enforcement — the filler machine-rejects
any write not licensed by the contract, so "the agent cannot invent the frame"
stops being discipline and becomes a property the pipeline has.

Every aura is built **reasoning-first**: reasoning (the docket — composition +
values + why) → conditional logic (grammar over sourced provides/properties) →
assembly (mechanical drop into the source-derived skeleton; WA's own acceptor
completes it — P11). The corpus supplies NO structure anywhere: it trains the
reasoning and verifies the output, nothing else. It was the only form of
reasoning available about what the data should look like before the index
existed; the index now IS that reasoning's source.

## Companion docs

[PRINCIPLES.md](PRINCIPLES.md) — the guiding principles, stated once ·
[GAP_BRIDGE.md](GAP_BRIDGE.md) — the honest map from existing machinery to each
v2 stage: what's reused as-is, what's extended, what's new ·
[ACCEPTANCE.md](ACCEPTANCE.md) — **what we ACCEPTED from this spec and how we enter it**
(spell-first, P11-leveraged, refusing spec-first armor). Read this to know the chosen path,
not just the possible one. This spec is a signpost; ACCEPTANCE is the decision.
