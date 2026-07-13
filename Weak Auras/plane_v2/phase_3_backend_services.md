# Phase 3 — batch the back end as bench services

**Goal:** the mechanical stages behind the filler run as whitelisted bench
services (`py call.py <svc>` — runner.py SERVER / call.py CLIENT over
runtime/queue + receipts), batchable over N auras. Extensions of proven
pieces, not new machines. Principles: P1, P7, P8.

## 3.1 — assembler: one → many

plane/assemble.py assembles one BOM into one aura (proven byte-real). Extend:
- accept a filled-parts BATCH (the filler's output for a whole docket),
- group-wrap N auras against the mask (parent group + positions from the
  mask's slot geometry — the WHERE layer finally consumed mechanically),
- keep the existing encode→decode→encode roundtrip self-check per aura.
Zero new reasoning; the assembler stays dumb.

## 3.2 — canon: headless Modernize as a service

The missing middle. Run WA's Modernize/normalize headlessly (the wa_lua_verify
harness technique — real WA source under Lua 5.1, game API stubbed) over each
assembled table:

```
aura_tables → canonical tables + canon_diff.json
```

canon_diff classifies every field Modernize touched. Expected: empty, or a
WHITELISTED normalization set (learned here, frozen as data). Anything outside
the whitelist = RED — a pipeline defect upstream, never hand-patched (fix the
filler/assembler, re-run). Per the standing rule: harness findings that are
genuinely novel get one live-export confirmation before the whitelist grows.

## 3.3 — encode: codec as a service

weakaura_codec.py wrapped as a service: canonical table → import string, plus
the roundtrip check (decode(encode(t)) ≡ t) inline. Trivial; exists as a
library, needs only the service wrapper (decode already is one).

## 3.4 — service registry

New whitelist entries: `fill`, `assemble`, `canon`, `encode` (joining decode,
verify, seeds). Each: defined I/O, no free-form args, receipts to the ledger
(phase 4). This keeps the bounded-autonomy shape — judgment at the whitelist
boundary, machines in the interior.

## Exit gate
One command takes a multi-aura docket to N import strings with receipts at
every stage, no human in the loop, on the sandbox account for live spot-checks.
