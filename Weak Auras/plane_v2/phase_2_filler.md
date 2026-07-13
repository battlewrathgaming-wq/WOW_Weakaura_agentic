# Phase 2 — the filler (the validator gate)

**Goal:** `plane/fill.py` — the ONE genuinely new hard machine. Deterministic:

```
docket.json + contract.json + trigger_seed_defaults.json
    → parts + fill_receipt.json        (or a rejection report)
```

This is where "the agent cannot invent the frame" becomes a pipeline PROPERTY
(P2). It is a COMPILER file: it gets the 4-step checklist + the Go gate before
any code lands. Principles: P1, P2, P3, P7, P9.

## Position in the chain

v1's apply_fills() writes docket fills onto a part with zero checking. The
filler inserts BETWEEN docket load and part emission: it VALIDATES every fill
against the contract, plugs seeds and policies, and emits parts the assembler
consumes unchanged. The assembler stays dumb; the filler is not smart either —
it is a type-checker executing rules, no judgment.

## Reject rules (enumerated; each rejection names its rule + the contract row searched)

- **R1** — fill field not in contract as `surface: input` → REJECT.
- **R2** — value outside a resolved `value_domain` → REJECT. Domain
  unresolved / grade 3–4 (P3) → WARN, pass, flag in receipt. Never silently
  trust, never silently block on a hole in our own extraction.
- **R3** — required seeds auto-plugged from the contract's default_state; a
  docket cannot omit them and may not contradict them without a `why`.
- **R4** — fill violates `enabled_when` (writes an option its modal state
  disables) → REJECT.
- **R5** — policy defaults applied mechanically (`use_exact_* = false`,
  match-family-not-rank); docket may override only with an explicit `why`.
- **R6** — condition `check.var` must exist in the trigger's `provides` with
  `stores_condition_var: true`; `changes.prop` must exist in the region's
  properties surface → REJECT otherwise.
- **R7 (barren guarantee, P9)** — the emitted part contains EXACTLY:
  seeds ∪ policy fields ∪ docket fills. SET-EQUALITY check, not a diff.

## fill_receipt.json

Per written field:
```json
{"field": "...", "value": ..., "source": "docket|seed|policy",
 "licensed_by": "<contract row key>", "why": "<from docket, if docket-sourced>"}
```
Plus: rejections (empty on success), warnings (R2 grade-degraded passes),
input hashes (docket, contract). This is P7 at the field level — a later
look-back is an audit, not a re-derivation.

## The authoring path is source-only (P11)

The filler authors parts from the contract ALONE: the skeleton domain
(data_stub), region/subregion defaults, trigger default_state + seeds, and the
docket's fills — the "index as write-from-blank instructor" step, mechanised.
NO corpus-derived table sits anywhere in the authoring path. The corpus keeps
exactly two jobs, both outside this machine: training data for the docket
author's reasoning (which compositions humans converge on), and verification
(coverage check 0.8, diff fixtures). v1's harvested parts/ demote to fixtures;
harvest_parts / derive_contracts stop being load-bearing — re-scope the
pending settle/blank fixes to whatever the FIXTURES still need before
spending that Go.

## Exit gate
The Corpse Explosion docket fills → assembles → byte-matches v1's golden.
A deliberately-bad docket (one violation per rule R1–R7) produces seven named
rejections. And the acceptance test WA itself defines (the data_stub comment):
author from blank → source-only structure → WA's Add/validate/Modernize →
**reimport-diff CLEAN** — headless via the canon path, confirmed once live on
the sandbox account (P8 boundary). All carried forward as verify goldens.
