# plane/ — the docket → aura round-trip pipeline

Turns a **docket** (settled design facts) into a WeakAura import string and proves it reimport-stable. Spell-first,
minimal: we author the smallest structure WA accepts + our reasoning; WA's own acceptor completes the rest (P11 — the
lever). No corpus reproduction in this path.

## The flow

```
reasoning-docket --expand(contract)--> full docket --fill--> delta --bounce(canon+reconcile)--> A --encode--> import string
                                                                                                │
                                          live client = ground truth ◄─────────────────────────┘ (import, re-export, diff)
```

- **`expand.py`** — the EXPANDER (plane_v2 `THE_SPLIT.md` L3). Reasoning-only docket → the full-declare docket (fill's
  input) by DERIVING what the contract implies but was never chosen: `type`←event, `use_X`←filter-present,
  multiEntry→arrays+coerce, `combination`→`activation.disjunctive`, uid present→use / blank→mint. Contract-DRIVEN (reads
  `../wa_index/contract.json`), never a hand ruleset; idempotent (fill-missing); gaps are LOUD (`sys.exit` wall→expand,
  never a silent guess). An elaboration/defaulting pass — its output is exactly what `fill` takes, so fill is unchanged.
- **`fill.py`** — the DUMB filler. Docket (intent) → the aura-table DELTA in WA's shapes: nesting
  (`class`→`load.class.single`), dict→array (`changes`), triggers + the `activation` combination (disjunctive /
  activeTriggerMode), conditions, subregions, and a **sourced** `internalVersion`. No defaults, no validation, no reasoning.
- **`reconcile.py`** — the fill/canon → codec GATE ("controlled bounce"). `bounce(aura) = reconcile(canon(aura))`:
  run WA's acceptor, then fix the shape mismatch the JSON boundary introduces — the mixed-key `triggers` table (JSON
  stringifies int keys `1,2` → the codec mis-encodes them as string map keys → real WA reads `#triggers==0` and resets
  the aura). TARGETED (only `triggers` arrays), not a blanket normalizer; the single home for fill→codec shape fixes.
  Owns `canon` + `_to_lua`.
- **canon** (in reconcile → runs `../wa_lua_verify/canon.lua`) — WA's `PreAdd` headless: Modernize + validate +
  regionValidate + data_stub. Completes everything the docket omits (region defaults, skeleton, subregion defaults).
- **`../weakaura_codec.py`** — LibSerialize + LibDeflate encode/decode (the `!WA:2!…` import string).
- **`roundtrip.py`** — the anchor test: `fill → bounce → encode → decode → bounce → diff == clean`. GREEN = reimport-
  stable headless; the **ground-truth gate stays the live client** (`../wa_lua_verify` is a fast proxy, not truth).
- **`diff.py`** — deep diff for the round-trip.
- **`dockets/`** — the specs, in **two forms**: the `*.reasoning.json` (reasoning-only — what the inventory emits, what
  the expander consumes) and the full `*.docket.json` (expand's output = fill's input). `corpse_explosion.v2–v4` (icon:
  single spell → 2-trigger + condition), `player_health.v1` (health bar), `player_health_any` (2-trigger "any" existence-
  filter bar — has both a `.reasoning.json` and the `.v1.docket.json` golden they expand to).

## Run

```
py expand.py dockets/player_health_any.reasoning.json   # reasoning-docket → full docket (contract-derived)
py roundtrip.py corpse_explosion.v4.docket.json         # round-trip a full docket → GREEN/RED + weight
```

The reasoning-docket is authored against the **sheets/contract** in `../wa_index/` (select + handling); the **expander**
derives the rest, so it is born shape-correct. fill and reconcile stay dumb; the contract's pre-flight lives in the class
inventory. See `../plane_v2/THE_SPLIT.md` for the full layer stack + proving order.

## Lineage (earlier corpus-based tooling in this folder)

`diagnose.py` (corpus method-flattening), `assemble.py` / `derive_contracts.py` / `harvest_parts.py` and
`goldens/` `parts/` `boms/` are the earlier parts/BOM approach. The current ship path is docket→fill→bounce→codec
(spell-first, refusing the corpus-reproduction trap); the parts tooling is grounding, not the ship path.
