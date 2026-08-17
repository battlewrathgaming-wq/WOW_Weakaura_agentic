# Dungeon Run — AUTHORING acceptance (item 1 + item 2's first proof + the adaptor)

_Analyst, 2026-08-17, on the bench's proposition (`driver_bench_proposition.md`). Target §9 said
"the editor's own criteria (not yet written) gate Dungeon Run" — these are they, for the docket's
items 1–3. Written BEFORE the code, from the proposition's smoke plan (§8) and the model, so the
smoke is written to the criterion. **Every assertion must be shown to BITE** (mutation named per
row); a green that has not been mutated is not evidence. The Analyst tests each on landing._

Where R1/R2/R3 are unruled, the criterion is written to hold either way.

---

## A1 · G2 — reach on a childless beacon
- **A1.1** `Routes.SetBeaconReach(b, radius, up, down)` stores; `Routes.ReachOf(x)` returns the
  CHILD's fields when present, else the BEACON's. Additive; no existing signature changes.
- **A1.2** A childless beacon is RUNNABLE: `AcceptanceOf(b)` returns the beacon AND `ReachOf`
  returns a reach for it. `/dr walk`'s unrunnable-stages report no longer lists a childless
  beacon that has a radius.
- **A1.3** Height untouched: the beacon's `z` is still the read's (`routes.lua:29-31`); band is a
  tolerance over it. If R2 = default, `ReachOf` returns ±2.5 when the beacon carries none.
- **mutation** delete the beacon branch of `ReachOf` → A1.2 fails on its own message; A1.1 for
  children still passes.

## A2 · the child ordinal (`4.1:3`, `4.1:3.1`)
- **A2.1** A stored, sparse ordinal on the child; `ChildrenOf(b)` returns children in ordinal
  order; inserting `3.1` renumbers NOTHING (every other ordinal byte-identical before/after).
- **A2.2** `4.1:3` resolves to exactly one child; `4.1:3.1` to another; the full path is unique
  route-wide.
- **A2.3** Two children on one ordinal is TOLD (pane + `/dr walk` report), never refused (S4).
- **A2.4** The parent's management surface and the child's own pane write the SAME field (one
  home, two doors — model §1).
- **mutation** make insertion renumber → A2.1's stability assert fails; give two children one
  ordinal → A2.3 shows the tell and nothing errors.

## A3 · G10 — the boss child kind + name picker
- **A3.1** A child `kind` (a new axis beside `role`) with `boss`; its picker is fed ONLY from the
  run's `r.bosses` (`store.lua:364`); the author cannot type a name.
- **A3.2** Two senses offered on it: *boss engaged* · *boss killed* (model §2).
- **A3.3** NO refusal needed (Battlewrath, 2026-08-17): the driver's arming call takes the name
  as its argument — `listen(UNIT_DIED, name)` — so a boss child with NO name has nothing to pass
  and NOTHING ARMS. The unfiltered listener cannot be expressed because the arming function has
  no unfiltered form (same law as position: fixed mechanism, instruction supplies the parameter;
  WA's firehose guard by construction). Editor TELLS ("no name — it will not listen"); `/dr walk`
  marks the stage unrunnable; S4 tell-and-trust intact. Test: a nameless boss child arms nothing
  and is told; a named one arms exactly one dest-name listener.
- **A3.4** Nothing about a set, a count, or a grouping is stored or shown (capture.lua:234 bound).
- **mutation** emit a nameless boss child → nothing arms and the tell shows (A3.3); offer a typed
  name → A3.1 rejects the path; arm a named one → exactly one listener, for that dest name.

## A4 · G1 — the reader note (written to hold under either R1 answer)
- **A4.1** A note resolves to EXACTLY ONE string for a child at runtime, ≤ ~200 chars (target §4).
- **A4.2** If REFERENCED: the pane shows a note field on the child; saving creates/updates a
  `NoteTable` entry keyed to that child; re-pointing to share is a separate, later action. If
  OWNED: one field on the child. Either way A4.1 holds and §91's reasoning is recorded next to
  whichever is chosen.
- **A4.3** The note is a CHOICE option: a child with no note has none, and nothing renders.
- **mutation** two children pointing at one referenced note, edit once → both read the new
  string (referenced) / only one changes (owned) — the test names which world it is in.

## A5 · the adaptor (`code : user`)
- **A5.1** Panes render user words through ONE lookup function; a miss PASSES THROUGH the code
  term (ruled §295).
- **A5.2** Every value in `ROLES / SHAPES / ACTIONS` (and every new kind/sense/next as it lands)
  resolves or passes through — the pane never errors on a missing row.
- **A5.3** `check_interface.py` gains a third check: every user-visible string in a pane
  resolves through the table; every code term reaching a pane has a row. Loud at the bench,
  silent for the author.
- **A5.4** Rows are filed AS TERMS LAND (§9): a term reaches a pane → it gets a row or is filed
  under an existing one; `emit_adaptor_table.py` is a drift check on the confirmed state, run
  AFTER, never a term planner.
- **A5.5** The user column reads against the naming law (model §3b) — one column, human-read.
- **mutation** remove a row → the pane still renders (pass-through) AND the checker reports it.

## A6 · item 2's first proof — a stage advance on JUST a boss kill
- **A6.1** In the test driver (mode of `/dr walk` if R3 = mode), against a landed capture that
  carries boss names + engage timestamps + `UNIT_DIED`: a boss child's *boss killed* sense
  satisfies → the beacon's next (`advance` or `set:stage`) fires → the stage moves. No new capture.
- **A6.2** The two witnesses both required: engage seen for that name AND `UNIT_DIED` on that
  name; either alone does not advance (advisory §11).
- **A6.3** The pin trace (C-4) is recorded per set/arrive/clear before "point here" is replayed;
  until then A6.1 grades the ADVANCE, not the pointing.
- **A6.4** Readout carries `hit · skip · false_advances`, never `stage` alone (W7.3).
- **mutation** drop the `UNIT_DIED` witness → A6.2 must NOT advance; feed a name not in the
  run → nothing arms.

## A7 · smoke hygiene
- **A7.1** `smoke_dungeonrunroutes.lua` stands up EMPTY on the existing load chain BEFORE any
  hole lands (proposition §10 step 2), so every assertion has somewhere to go.
- **A7.2** Each A-row's mutation is recorded next to its green — a green without its mutation
  is reported as UNMUTATED, not as PASS.

---

_How I test: run each smoke on landing; apply the named mutation myself; report PASS / FAIL /
UNMUTATED with the observed message. Failures return as observations. R1/R2/R3 change which
branch of A3.3 / A1.3 / A6.1 applies, not whether the row exists._
