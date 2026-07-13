# Acceptance — what we take from plane_v2, and how we enter it

Decision record, 2026-07-13. Fable provided fresh eyes → plane_v2 (the spec) + memory notes.
**Acceptance is the primary agent's.** plane_v2, PRINCIPLES, GAP_BRIDGE, and the memory notes are
**signposts to remodel on, not authority.** This note fixes what we ACCEPT and the ENTRY POINT chosen,
so the direction is findable and doesn't live only in chat. Nothing here is literal-day-bound.

## The lever everything hangs on — P11

WA ships its own acceptor: `data_stub` + `validate` + Modernize complete any minimal aura, and
**reimport-diff is pass/fail**. So we do NOT reproduce WA's data model — we provide *the minimum + the
reasoning* and let WA finish. That collapses the hard problem: the filler becomes "drop the docket's fills
into a barren skeleton," verify becomes "WA accepts it unchanged." **Everything else in plane_v2 is
scale-armor around this core.** The body is lean: `source-self-report(graded) → docket(reasoning) →
minimal-fill → WA-completes → verify`. Four parts + WA's engine.

## The round-trip that has to close (the target, stated once)

```
docket → fill → assemble → Modernize → encode → decode → re-Modernize → diff == clean   (+ WA reimport-diff clean)
```
- **Repeatable** = deterministic machines + receipts.
- **Scalable** = a MECHANICAL generator over coa_spells.json + batch + a closed verify loop (no human per aura).

## ACCEPTED (keep — several already proven live)

- **P6** source is authority / corpus is the hole-detector — PROVEN 2026-07-12 by the aura2 correction
  (we'd treated the corpus schema as body; the source self-report was the body; inverting it made the
  system leaner and truer).
- **P4/P5** execute-don't-paraphrase / sweep-axes-for-`enabled_when` — the `triggeroptions` mode IS P4;
  the exclusivity probe IS P5 (sweep probes + diff key-sets, never read `hidden` bodies).
- **P11** WA-completes (the lever above).
- **P3** grade every extraction fact (literal / executed-clean / stub-degraded / needs-live); grades 3–4
  go on a LOUD `unresolved` list. **P7** receipts. **P8** autonomy only where the loop is closed.
  **P10** mechanical-before-agentic.
- GAP_BRIDGE's honest headline: v2 is mostly inserting stages between machines that already work — **only
  the filler and the canon service are genuinely new.**

## REMODEL (the sledgehammer, held out — where we DON'T take it as authority)

- **SPELL-FIRST, not phase-first.** Enter through ONE spell; let the machine grow to fit what the spell
  demands. Do NOT build the 6 phases as a spec-then-build order.
- **Refuse spec-first armor.** R1–R7 filler checks, the receipts ledger, the orchestrator, the contract
  type-system — built when the one spell, then the batch, ACTUALLY demand them. Pouring them up front guards
  *imagined* failure modes ([[intelligence-vs-gears-and-tooling-backlog]] run backwards).

## THE PATH (moving toward)

1. **One spell, full round-trip, MINIMAL.** Corpse Explosion (has a v1 golden — re-enter v1's own
   regression through the docket door, nearly free per GAP_BRIDGE insight #1). Builds the three new-but-thin
   pieces: contract = a JOIN of sheets+skeleton+seeds we already have · filler = dumb (barren parts from the
   contract; R-checks added only as THIS aura forces them) · canon = a Modernize wrapper. **Proves the body.**
   First move: write the FAILING round-trip test (red), build everything to green. Filler = the one new
   machine → compiler checklist + Go when reached.
2. **Finish the honest surface.** Our 8 trigger-type state sheets (committed thru `2ac5423`) are phase-0
   extraction, INCOMPLETE against plane_v2's own principles: add P3 grades + a loud `unresolved` list (the
   aura2 stub-degradation + custom code-boxes are prose today), sweep for `enabled_when` (P5), un-stub the
   common-options layer (`AddCommonTriggerOptions`). Small, reuse-heavy — the real "finish phase 0."
3. **Bucket + generate + receipt.** Bucket the spells (lane/behaviour), a mechanical docket generator over
   coa_spells (P10), batch the proven chain with a receipts ledger + closed-loop verify. Repeatable + scalable.

See also: `README.md`/`PRINCIPLES.md`/`GAP_BRIDGE.md` (the spec) · `blueprint/README.md` (the reasoning
spine this fits inside) · memory `generation-flow-and-state-sheets`.
