# Phase 4 — verify + the receipts ledger

**Goal:** the closed verification loop that LICENSES autonomy (P8): a batch is
trustworthy because machines checked it, not because a human watched it.
Principles: P3, P7, P8.

## The four checks (per aura; verify service extends plane/verify.py)

- **V1 — roundtrip:** decode(encode(t)) ≡ t. Already inline in assemble and
  the codec; verify re-asserts it on the FINAL artifact.
- **V2 — canon-diff clean:** phase 3's canon_diff is empty or fully inside the
  frozen normalization whitelist.
- **V3 — settle-equality:** settle(final table) ≡ the fill_receipt's field set
  (the settle engine exists in plane/diagnose.py). Proves no residue entered
  anywhere in the chain — P9 checked END-TO-END, not just at the filler.
- **V4 — goldens:** frozen dockets → byte-identical import strings.
  plane/verify.py IS this harness already (bless/verify/classify, inert-diff
  auto-pass, FLAG list as the intelligence kernel); extend its entry point
  from BOM-stems to dockets and carry the phase 1 + 2 exit-gate tests forward
  as permanent goldens (Corpse Explosion docket-path; the seven R1–R7
  rejection fixtures).

## The receipts ledger

`runtime/receipts/ledger.jsonl` — every service run appends one line:

```json
{"ts": ..., "svc": "fill|assemble|canon|encode|verify", "docket": "...",
 "in_hash": "...", "out_hash": "...", "verdict": "green|red|warn",
 "unresolved": 0, "flags": []}
```

Anomaly-biased by design: greens are one line; reds/warns carry the named
rule/diff that fired. This IS the data layer of the independent activity feed
(`[[independent-activity-feed-receipts]]`) — the view (Electron watcher) can
land later on top of a ledger that already exists.

## The boundary that stays human (P8)

What machines CANNOT check: does the aura behave right IN-GAME (trigger
semantics, visual fit). That residual is batched — a sample per batch imported
on the sandbox account, eyes at the boundary. The ledger records WHICH auras
had live eyes on them (`"live_checked": true` on a verify line), so coverage
of the human boundary is itself visible, never assumed.

## Exit gate
A full batch runs unattended to green receipts; one deliberately-broken input
per stage produces a red with the correct named cause; the ledger shows both.
