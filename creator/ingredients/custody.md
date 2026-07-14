# custody — who holds the content, and what they may do to it

_The pipeline's chain of custody, source-traced and live-proven 2026-07-14. If you ever have to ask "how does it
work" — this is the answer. One law over all of it: **content is authored ONCE, at the docket; past the gate, nothing
authors — it validates, wraps, or completes.** Fixes go to the contract / gears / maps, never into an artifact by hand._

```
AUTHOR            GATE                 PACK                WRAP                        LAND            LIVE
contract ─┐
          ├→ docket → stage.py→gate.py → Docket_stage/<pid>/ → pickup.py → bundle ──→ Docket_complete → client
palette ──┘   (_authored/, flat)         (accepted, verbatim)   (1 group   (expand→fill→   <pid>.txt  +   import
(hand or                                                         + members)  canon→reconcile  register       │
 populate)                                                                    →codec)                        ▼
                                                                                                     the final authority
```

## Station by station

| station | receives | MAY do | may NOT do |
|---|---|---|---|
| **AUTHOR** (agent hand / `populate.py` pressing a contract) | an ask / a contract | invent the logic freely from the palette; press meaning → WA-literal (shapes from `maps/arg_shapes.json`) | write a stored form by hand that a map derives; use a key not on the menu |
| **GATE** (`stage.py` → `engine/gate.py`) | authored dockets (`_authored/*.json`, flat) | judge every input: vocab (contract) → **liveness** (`maps/live_keys.json`) → domain (`domains.json`) → corpus (`coa_spells.json`); stub soft flags beside the file | edit ANYTHING — on pass it writes the docket **VERBATIM** into `Docket_stage/<pid>/`; on block, back to the author |
| **PACK** (`pickup.py`) | a pid folder (exactly 1 group docket + members) | gather, order, hand to bundle; land the product; append the register; consume the folder | author; repair; accept a group-less pack (structural FAIL, folder preserved) |
| **WRAP** (`bundle` → `expand` → `fill` → `canon` → `reconcile` → `codec`) | the pack's dockets | `expand`: derive only what the docket IMPLIES (type←event, coupling), idempotent · `fill`: emit the declared DELTA, containers only, verbatim fields · **`canon`: WA's OWN acceptor completes the full table — the ONLY author of non-docket content in the entire chain** · `reconcile`: one targeted key-shape fix · `codec`: encode (round-trip verified inside) | invent content; translate a stored form (that's how the dead-config shipped — deleted, not fixed) |
| **LAND** (`Docket_complete/`) | the group import string | `<pid>.txt` + a register line (the domain log); `run.py` runs additionally write receipts (the runtime log — console/direct runs do NOT) | — |
| **LIVE** (the client) | the string | WA validates on import; Modernize runs; **the game outranks everything upstream** — a live finding fixes the contract/gears/maps, never the artifact | — |

## The proofs behind each claim (all run, none asserted)

- Gate verbatim + by-exception verdicts: red battery 7/7 blocked at the correct tier, greens untouched.
- Nothing-past-the-gate-authors: a ~6-decision docket ships as a 30+-field aura — every extra field written by canon.
- Determinism / operator-independence: Battlewrath's own pickup run reproduced the agent-side products **byte-identical**.
- Live: four packs imported cleanly and correctly (2026-07-14).

## When something is wrong

The artifact is never the patient. Trace which station let it through, fix THAT layer, re-press:
wrong word → the contract/palette · dead key → the liveness harvest · wrong shape → the arg-shapes map ·
wrong member → the select recipe · wrong look → the docket's declares · anything live-only → capture it, then upstream.
