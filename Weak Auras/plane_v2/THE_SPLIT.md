# The Split — the layer stack, its contracts, and one-layer-at-a-time proving

The generation pipeline as **layers with contracts between them**, and the order we build+prove them (each layer
red-tested against a known input/output before the next). Reflects the crystallised reasoning of 2026-07-13; where it
diverges from the older `phase_*.md`, this is current (esp. filler-vs-expander + pre-flight-in-inventory, below).

## The stack (each layer: what it owns, in → out)

| # | layer | owns | in → out |
|---|-------|------|----------|
| 1 | **Inventory** | content · identity/relationship · **reasoning** | facts → **docket** |
| 2 | **Docket** | the **UNDECIDABLE** (transient exhaust, regenerable) | — |
| 3 | **Expander** *(NEW gear)* | derive CONTENT from the contract (*adds* fields) | reasoning-docket + contract → full-content delta |
| 4 | **Fill** | rearrange STRUCTURE (*reads nothing, adds nothing*) | full-content delta → WA-shaped delta |

**Expander vs Fill (the boundary, by what each consults):** the **expander reads the contract and ADDS content** —
the fields WA needs that were never *chosen* (`type`←event, `use_X`←filter-present, array-wrap←multiEntry, value-coerce,
uid). The **fill reads nothing and REARRANGES** — full content → WA's table shapes (triggers→`{trigger,untrigger}`,
combination→string-keys-on-triggers, dict→array). **The expander's OUTPUT == fill's INPUT today** (the full-declare form,
= the hand-authored `.docket.json`), so the expander automates the hand-expansion and fill is UNCHANGED. Separate on
purpose: fill stays dumb/contract-free (can't be wrong, just reshapes); ALL derivation risk isolates in the one testable stage.
| 5 | **Bounce** | canon + reconcile (WA acceptor + shape-fix) | delta → completed aura |
| 6 | **Codec** | LibSerialize+Deflate | aura → import string |

## The one law that partitions everything

**Contract supplies the DERIVABLE; the docket supplies the UNDECIDABLE.** A field belongs in the docket iff it either
(a) **INSTRUCTS** the filler beyond what the contract can derive, or (b) **RESOLVES a CONFLICT** the machine can't decide.
Else out (derivable → the expander derives it; decorative → theater).
- **Instructs:** region · event/unit/filter · surface-tags (filter/conditions/progress — *where* a var goes) · uid-or-blank.
- **Resolves conflict** ("many want one slot"): `combination` · `activeTriggerMode` (N triggers → one display) · condition
  **precedence** (order → which change wins) · uid-on-import (same → update the colliding aura, new → a new one).

## The contracts (interfaces) between layers

- **Inventory → Docket:** the docket schema — `uid`-or-blank · `region` · `triggers[{event, unit, filter/conditions/progress}]`
  · `combination`. `type` is OMITTED (derivable: event→type is unique, verified). Versioning = the inventory choosing a new
  uid (keep → update; N+1 → new aura); **no version field**.
- **Docket → Expander:** the reasoning-docket + `wa_index/contract.json` (select + handling). The expander applies FOUR
  transforms (type-from-event · use_X-from-filter-presence · multiEntry→array · value-type-coerce) + the uid rule
  (present → use; blank → mint). **Derives from the contract, never a hand ruleset.**
- **Expander → Fill → Bounce → Codec:** the aura-delta as fill takes it today; the rest UNCHANGED.

## Proving order (one layer at a time)

- **L4–6 (fill · bounce · codec): DONE + LIVE-PROVEN** — `player_health_any` landed clean in-game (`d109c14`).
- **L3 Expander — BUILT + RED-GREEN (2026-07-13, `plane/expand.py`).** `expand(reasoning-docket) == the live golden`
  (clean diff), and the full chain reasoning→expand→fill→bounce→round-trip is GREEN with a byte-identical import string to
  the hand golden. Derives `type`←event, `use_X`←filter-present, multiEntry→arrays+coerce, uid present→use / blank→mint,
  all from `contract.json`. Idempotent (fill-missing). Gaps are LOUD (`sys.exit` wall→expand for non-multiEntry / unknown
  event), never a silent guess. The born-correct loop now *runs* (contract → correct output), not just enabled.
- **L1–2 Generator — after.** Red-test: the generator emits the reasoning-docket that the (proven) expander expands to the
  golden. Proves the "reduce" — inventory → docket — where one hand-aura becomes the batch.
- **Parallel axis: Groups / batch.** The multi-aura structure (manifest + assembler; the mask realised). Independent of the
  L1–3 vertical; slot in when the single-aura vertical is mechanised.

## Laws each layer honors

- **Fill stays dumb** (structural only); the **expander** applies contract-derived rules; the **inventory** holds reasoning
  + identity. Three owners, no overlap, nothing re-derived.
- **Pre-flight (validation) lives in the INVENTORY**, not the filler — a backstop against the contract, not the mechanism.
  (This supersedes phase_2's "filler = R1–R7 validator gate": the filler is not the gate; the sheet makes the docket
  born-correct, the inventory checks it, the filler expands + translates.)
- **Derive-not-scaffold** · **uid = inventory-owned or mint-if-blank** · **docket is transient exhaust.**

## Status snapshot (2026-07-13)

BUILT + live-proven: sheets · handling · domains · routes · `_shared` · contract · fill · bounce · codec (`d109c14`) ·
**expander** (`plane/expand.py`, red-green 2026-07-13, uncommitted). NOT built: **generator** (next — inventory →
reasoning-docket) · groups. The reasoning for both is settled and recorded (memory: `generation-flow-and-state-sheets`);
building them is now construction against this plan, not discovery.
