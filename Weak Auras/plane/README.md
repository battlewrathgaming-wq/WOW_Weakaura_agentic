# plane/ — the docket → aura round-trip pipeline

Turns a **docket** (settled design facts) into a WeakAura import string and proves it reimport-stable. Spell-first,
minimal: we author the smallest structure WA accepts + our reasoning; WA's own acceptor completes the rest (P11 — the
lever). No corpus reproduction in this path.

## The flow

```
docket --fill--> delta --bounce(canon+reconcile)--> A --encode--> import string
                                                     │
                    live client = ground truth ◄─────┘ (import, re-export, diff)
```

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
- **`dockets/`** — the settled-fact specs. `corpse_explosion.v2–v4` (icon: single spell → 2-trigger + condition),
  `player_health.v1` (health bar), `player_health_any.v1` (2-trigger "any" existence-filter bar).

## Run

```
py roundtrip.py corpse_explosion.v4.docket.json     # round-trip one docket → GREEN/RED + weight
```

The docket is authored against the **sheets/contract** in `../wa_index/` (select + handling), so it is born
shape-correct; fill and reconcile stay dumb and the contract's pre-flight lives in the class inventory.

## Lineage (earlier corpus-based tooling in this folder)

`diagnose.py` (corpus method-flattening), `assemble.py` / `derive_contracts.py` / `harvest_parts.py` and
`goldens/` `parts/` `boms/` are the earlier parts/BOM approach. The current ship path is docket→fill→bounce→codec
(spell-first, refusing the corpus-reproduction trap); the parts tooling is grounding, not the ship path.
