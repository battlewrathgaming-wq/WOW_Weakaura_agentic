# plane_v2 — the generation reasoning space

The map of the **agentic generation pipeline**: turning a class's abilities into WeakAuras with no human
steering each artifact. The ONE reasoning element is the **docket author** (the class inventory); everything
downstream is dumb, deterministic gears. This folder is the reasoning/spec space — the working CODE lives in
[`../plane/`](../plane/README.md) (the pipeline) and [`../wa_index/`](../wa_index/statesheets/README.md) (the menu).

## The flow

```
sheets + contract + mask + coa_spells.json     (the sourced FACTS)
        │
   inventory reasons  →  docket.json            (the ONLY reasoning output — settled facts)
        │
   fill → bounce (canon + reconcile) → encode   (dumb gears)  →  import string
        │
   live client = ground truth
```

The agent's entire write surface is `docket.json`. It reads the sheets (select **+ handling**) so the docket is
**born shape-correct**; the gears never reason about shape.

## Built vs spec

**Built + (mostly) live-proven this era** — the sheets/contract foundation and the round-trip body:
- `../wa_index/statesheets/` — the MENU: per-type/region sheets with **handling** (the shaping grammar) + light
  `.routes.md` browse-indexes + `domains.json` (shared catalog) + `_shared.json` (regionPrototype layer).
- `../wa_index/contract.json` — the pre-flight resource (must-assert · condition-vars · change-targets · handling).
- `../plane/` — `fill.py` (dumb filler) → `reconcile.py` (the canon+reconcile **bounce** gate) → codec; proven on
  icon, bar, and 2-trigger + existence-filter dockets.

**Spec — still to build** (phase docs below):
- The **docket generator** (inventory → dockets, the "reduce" — where one hand-aura becomes the BATCH).
- Batch services + receipts (unattended runs at scale).

## Why it holds

Reasoning-first, source-not-corpus: reasoning (the docket) → conditional logic (grammar over sourced
provides/properties) → assembly (dumb drop; WA's own acceptor completes it — the **P11** lever). The corpus supplies
NO structure — it trains reasoning and verifies output, nothing else; the source (index/sheets/contract) IS the
structure's authority. Law added this era: the **shaping grammar is sourceable too**, so the docket is born correct
rather than fixed by round-tripping (memory: `source-is-authority-for-rule-sets`).

## Docs

- [ACCEPTANCE.md](ACCEPTANCE.md) — **the chosen path** (spell-first, P11-leveraged); the decision, not just the possibility.
- [PRINCIPLES.md](PRINCIPLES.md) · [GAP_BRIDGE.md](GAP_BRIDGE.md) — the principles + the reuse/extend/new map.
- phases: [0 extraction](phase_0_extraction_contract.md) · [1 docket schema](phase_1_docket_schema.md) · [2 filler](phase_2_filler.md) · [3 backend](phase_3_backend_services.md) · [4 verify](phase_4_verify_receipts.md) · [5 first product](phase_5_first_product.md).
- The reasoning SPINE this fits inside: [`../blueprint/README.md`](../blueprint/README.md) — nothing here replaces it.
