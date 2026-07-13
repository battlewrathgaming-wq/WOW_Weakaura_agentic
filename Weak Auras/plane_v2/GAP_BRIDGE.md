# Gap bridge — from the machinery we have to plane_v2

The honest map, per stage: REUSE (as-is) / EXTEND (same machine, wider mouth) /
NEW (build). Grounded in a direct read of plane/, wa_index/, and the bench
(2026-07-13). The headline: **v2 is mostly inserting stages between machines
that already work** — only the filler and the canon service are truly new.

| v2 stage | existing machinery | verdict |
|---|---|---|
| extraction | extract.lua: prototypes/region/subregion/regionoptions/animoptions/triggeroptions/seed_defaults modes | REUSE — phase 0 is emitters over captures that already fire |
| skeleton | `Private.data_stub` (Types.lua:3284) is a plain literal — the `types` mode's getmetatable==nil scan should ALREADY emit it | REUSE — confirm + shape into the contract's `skeleton` domain (0.0) |
| state sheets | emit_state_sheet.py (`build()` is domain-generic already) | EXTEND — point it at load/display/animations; add _common + unresolved + enabled_when |
| contract | index_grounded.json + value_domains + seeds (separate files) | NEW but thin — compile_contract.py is a JOIN, no new extraction |
| docket | plane/boms/*.bom.json + assemble.py's fill convention | EXTEND — the docket IS the BOM + why + slot/spell identity; apply_fills already speaks dotted contract keys |
| filler | apply_fills() writes fills UNCHECKED | **NEW — the one real machine.** Slots between BOM-load and part emission; R1–R7 |
| parts | harvest_parts / derive_contracts (corpus-derived) | REPURPOSE — corpus parts become verification fixtures (P6); the filler authors parts from contract + BASE_AURAS instead. This IS the named "index as write-from-blank instructor" step |
| assembler | assemble.py — lanes, holes, identity mint, per-aura codec roundtrip, byte-proven | EXTEND — batch input + mask-driven group wrap. No logic changes |
| canon | wa_lua_verify harness technique (real WA source under Lua 5.1) exists; Modernize.lua sits in the install | **NEW service, old technique** — the missing middle. The normalization whitelist starts EMPTY and is learned from real canon_diffs |
| encode | weakaura_codec.py (lossless, proven) | REUSE — service wrapper only; decode is already a bench service |
| verify | plane/verify.py — goldens, bless/verify, diff CLASSIFY, inert auto-pass, FLAG kernel | EXTEND — docket entry point + V2 canon-diff + V3 settle-equality; V4 already exists |
| settle | diagnose.py 4-layer settle engine + SHA-cached stub | REUSE — V3 calls it on final tables |
| receipts | runtime/queue + receipts (bench transport) | EXTEND — one ledger.jsonl convention over what runner.py already writes |
| batch driver | menu.bat / call.py chaining | EXTEND — one orchestrator service (`run`) that sequences fill→…→verify per docket |

## The insights that fall out of the map

**1. The BOM→docket continuity is the cheapest big win.** assemble.py already
consumes exactly the docket's spine (part refs, lanes, fills, conditions). So
phase 1+2 have a built-in proof: run the SAME Corpse Explosion subject through
the docket path and byte-match v1's golden. v2's first end-to-end test costs
nothing to design — it's v1's own regression, re-entered through the new door.

**2. The parts folder flips ownership, and that resolves a standing tension.**
Today parts/ is corpus-derived and settle-depth was retrofitted to clean it
(the uncommitted derive_contracts experiment). In v2 the filler AUTHORS parts
from the contract ALONE — barren by construction (R7), no settling needed.
This is deliberate, not incidental (P11): the corpus was TRAINING DATA for
what the logic looks like, and it leaked into being the code basis — v2
removes it from the authoring path entirely. WA's own acceptor (data_stub +
validate + Modernize, WeakAuras.lua:2951) is the completer, so source-only
minimal parts are sufficient by WA's own standard (reimport-diff clean).
The corpus-derived parts don't die: they become the fixtures the corpus-
attribution check (0.8) and V4 verify against, and the corpus keeps its
training-data job — informing the docket author's CHOICES (BASE_AURAS
primitives re-authored as source-cited dockets, corpus-CONFIRMED — phase 1).
Derivation stops being load-bearing; it becomes evidence. The pending
settle/blank fixes shrink to whatever the fixtures still need — worth
re-scoping BEFORE spending the Go on them.

**3. verify.py's FLAG kernel is the pattern for canon's whitelist.** The two
are the same shape: a mechanical diff, a frozen classify-list, and a human
reviewing only what the list can't call inert. Build canon_diff to verify.py's
conventions (same classify/bless vocabulary) and the review surface stays ONE
learned skill, not two.

**4. The bench is already the autonomy substrate.** runner.py/call.py with a
whitelist + receipts is exactly the execution model phases 3–4 need — no new
transport, just new service names. The wall→expand→commit contract applies
unchanged: each phase lands as a service, gets committed, then gets driven.

**5. The extraction stubs and the canon stubs are the same harness family.**
extract.lua's permissive-stub environment and wa_lua_verify's are siblings.
Phase 3.2 should grow from that lineage (one shared stub layer, two consumers)
rather than a third bespoke environment — the stub layer is where subtle
wrongness breeds, so it wants exactly one implementation to audit.

**6. What is genuinely absent** (so nobody hunts for a bridge that isn't
there): the contract compiler (thin join), fill.py (the gate — checklist +
Go), the canon service wrapper, the docket generator, the ledger convention,
and the exclusivity-probe emitter mode. Everything else on the table above is
reuse or extension of something already proven.
