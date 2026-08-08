# DBC Reconcile — the plan (a seed, not a charter)

_Homeless until now: a project of its own, scoped in conversation 2026-08-08 (Battlewrath + aura bench) and
parked here so it isn't re-derived. **Nothing is built.** This is the design as talked out, with the facts that
were checked on the night. Whoever picks it up owns the charter; this file only stops the thinking being lost._

## The goal, stated as an acceptance test

**When Lesser Zombie changes, or leaves the game, we get a clean readout of it** — in a sentence, before anyone
notices something broke. Not "our data is fresh." A named, testable criterion: *change one spell upstream, and
the pump names it.*

Today that fails silently. If a summon's TTL changed tomorrow, every summon-count tracker built on the old
number would drift, and the first report would be a player saying "the count feels wrong."

## The shape: a waterfall with a pump (Battlewrath)

Everything flows downstream — sources → tables → joins → contracts → products — and **starting the engine
replaces everything from upstream as contract/mechanical emits.** Nothing at any level is hand-maintained.

The payoff, stated plainly: **once the game-data layer is pumped rather than frozen, nothing downstream needs to
be trusted — only sources and transforms.** Every wrong answer becomes a gear fix that re-flows. That is already
how this project works below the data layer; this extends it to the one input still hand-frozen.

## The pipeline (Battlewrath's five steps)

1. **Build from DBC**, data-tagged with markers used down the pipeline.
2. **Check the website** for talent-tree correctness and ability reference.
3. **A greedy live verification pull** against spell IDs.
4. **Split into a proven table of live, with reference.**
5. **Split into distinct lookup tables.**

### Why three sources and not one — each answers a DIFFERENT question

| witness | authority for |
|---|---|
| **DBC (in MPQ)** | does this EXIST — what the client knows (tooltips, ranges, display) |
| **talent trees / builder web** | can anyone REACH it — dev-authored structure |
| **live API pull** | does it RESOLVE and BEHAVE — what the server actually does |

No single one separates live content from project history. **The join does.** Proven already: the three ghost
specs (Rot 10 spells · Wildwalker 8 · Engravement 12, against real trees' 41–97) were caught by dev-tree
membership *minus* attribution — a join, never by inspecting rows. And the benches have already seen the
witnesses disagree (the addons bench's "PvE power spells = tooltip display artifacts, not application
machinery" — DBC said one thing, live behaviour another).

## Design decisions taken in the conversation

**Markers are a WITNESS RECORD, not a verdict.** Store *which witnesses attested a row and how*
(`dbc: yes · tree: Animation · live: resolved+rendered`); let each consumer derive its own verdict. A verdict
field (`live: true/false`) permanently destroys the distinction between "content deleted", "became a ghost"
and "gated/broken" — and those want different responses. Same house law as everywhere: emit, don't interpret;
re-running an interpretation is cheap, lost evidence isn't.

**The live pull is CHARACTER-SCOPED — design for it.** `GetSpellInfo(id)` answers for anything in the client's
DBC whether learnable or not, so used naively it just re-reads the DBC through another window. Its genuinely
additional witnesses are narrower: does the tooltip *render* (catches broken/stub content), and is it
known/reachable for *this* character — which only ever covers one class:spec per character logged in. The
trees remain the reachability witness for the other 20 classes.

**The useful outputs are the JOINS, not the raw rows.** Evidence from our own usage: nothing in the pipeline
reasons off `coa_spells.json` — everything reads `resolved.json`, which is *derived* (axes + typed edges).
Emit both, with the derivation scripted, or the derived layer silently becomes hand-maintained again.

**Curation stays on the CONSUMER side (Battlewrath's cut).** Taste (the mask), class knowledge, accepted-gap
calls, corpus patterns — none of it belongs in the flow. The pump emits an opinion-free fact table: what
exists, what's reachable, what verified live, on whose witness. What to *do* about that is the contract's job,
on the far side of the gate. This makes the pump's charter SIMPLER — no exemptions, no protected regions, no
don't-overwrite markers; it can replace its whole output every run precisely because nothing curatorial lives
there. And it sharpens what the diff is for: not "did we lose our tuning" (nothing to lose) but **"did the game
change, and where."**

## The output contract (three lines, and they are the whole trick)

**Sorted · line-per-record · no wall-clock.**

- **Git IS the lookback** (Battlewrath) — content-addressed, deduplicated, already backed up. A bespoke history
  store reimplements it worse. Same trick the helm already uses (`git log -- operations/HELM.md` = custody
  history for free).
- **But diff-friendly ≠ idempotent, and we have a cautionary example in-house.** `creator/picker/emit_library.py`
  is byte-idempotent (`sort_keys=True`, no wall-clock) — correct for trust — yet writes with
  `separators=(",",":")` and no indent, so `library.json` is **one 5.7 MB line**. Git versions it happily and
  every re-pump reads as "the line changed." Zero signal. **Choose JSONL up front** (one record per line, sorted
  by ID): a changed spell becomes one changed line, git packs it well, and the delta report is a small formatter
  over `git diff` rather than a program with its own state.
- **Idempotence is the precondition for the diff to mean anything**, not a separate virtue: a non-idempotent
  pump buries the real change in noise — the same failure as the single-line file by another route.
- Bonus that falls out: the diff is **reviewable before it is accepted** — read what a patch did to the game
  before letting it flow downstream.

## The first mechanical hurdle: MPQ precedence

The client carries `common`, `common-2`, `expansion`, `lichking`, `patch-2…patch-5`, `patch-A` — and the addons
bench found `patch-B`. WoW resolves DBCs by archive precedence (letters beat numbers, later beats earlier), and
**Ascension's custom content lives in the high-priority patches**. Extracting `Spell.dbc` from the wrong archive
hands you vanilla 3.3.5 data wearing a CoA filename — silently. First correctness requirement: honour the load
order. First test: does an extracted row match what the live client reports.

## Facts checked on the night (2026-08-08)

- `Input/*_talents.json`: `extracted 2026-07-01`, `realm: voljin-alpha`, schemaVersion 3, 21 files.
  **"voljin-alpha" is the devs' own DBC organisation label, NOT a build-quality signal (Battlewrath) — the data
  is live, but mixed with their whole project history.** So the problem is not stale-vs-current; it is
  **live-mixed-with-historical, in a source that does not mark the difference.**
- `dependencies/coa_spells.json`: 9,152 spells, DBC-shaped schema (`effectAura`, `effectMisc`,
  `effectTriggerSpell`, `procFlags`, `spellClassMask`, …) and **no provenance keys whatsoever** — no build
  stamp, no extraction date, no source note. A standing invariant-7 debt: everything downstream rests on a file
  that cannot say where it came from. **Version-stamp per TABLE**, not per project, so drift is measurable
  per table.

## Consumer note (the aura bench, as an affected party)

This supersedes both files the aura pipeline reads. `resolved.json` feeds the resolver, the select recipes,
`pull_target_tracker.families()`, `creator/picker/emit_library.py`, and every contract press; `coa_spells.json`
feeds them too. A clean rebuild is a **breaking change** to that bench — mechanical to refit, but the choice
(emit a compatibility view, or plan a cutover) is far cheaper made at design time than after 21 classes of
tables exist.

## Status

**SEED ONLY.** Not started, not scheduled, no bench assigned. Suggested first goal, if it starts: not
rebuild-everything, but **extract one table from the correct archive, diff it against what we have, and report
the drift** — that exercises the whole hard path (MPQ precedence · DBC decode · schema mapping · provenance
stamping · the diff readout) at a scope one session can finish, and the drift number tells you whether the
project is urgent or background.
