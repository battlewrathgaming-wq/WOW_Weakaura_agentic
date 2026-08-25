# Reconcile inbox — DRAINED 2026-08-26

_The working-out. Conclusions live in `ANALYST_LOG.md`._

---

## RI-47 DRAINED (Analyst, 2026-08-26) · the bucket's gate — **verified in the shipped source, not taken from the heading**

_Outcome: no action. The bench's self-reported fix is real._

The item said `bucket.lua`'s `known(code)` validated authored words against **`Adaptor.Has`** — the
DISPLAY table — so `boss`, `note` and `say` were refused at build because no adaptor word exists for
them. ⟶ `bucket.lua:86` now reads:

    local list = Routes and (kind == "sense" and Routes.SENSE_WORDS or Routes.ROW_ACTIONS)

**The gate is the AUTHORING vocabulary, which is the correct table.** ★ And the distinction the item
drew is the durable part: *`ROW_ACTIONS` answers "may an author write this?"; `Adaptor.Word` answers
"what does a human see?"* — and `DR_Content_20`'s A5.1 passes a miss through, so a display table can
never be a gate.

⚠ Verified by reading the source. RI-55 sat open two days after its own resolution, so a heading
that says FIXED is a claim like any other.

---

## RI-48 DRAINED (Analyst, 2026-08-26) · L2.4's arg half — **the heading was right, and the filer had already corrected himself**

_Outcome: no action. Nothing outstanding._

The item opens *"L2.4 splits three ways and only the third needs anyone's word"* — so the heading's
*"NO QUESTION LEFT"* looked like it contradicted the body. It does not: the third part closes with
**"✅ ANSWERED — BY PRECEDENT, AND I SHOULD HAVE FOUND IT BEFORE FILING THE QUESTION."**

⟶ The bench found `Routes.ROW_ARG.supertrack = nil` already carries the answer (*"`nil` means the
action takes no arg"*), and that an arg on `supertrack` can only arrive from a hand-edited
SavedVariables or an importer — not from the pane, which offers none.

★★ **The line worth keeping is the filer's own:** *"an answer from the repo is not a question for
Battlewrath."* That is the same rule this seat works to, written by the other side of the bench.

---

## RI-53 DRAINED (Analyst, 2026-08-26) · a defaults store — **ANSWERED, and the build is NAMED BACK, not made**

_Outcome: the analysis stands; `contract.lua` is shipped code and the dev manages the tree._

**His question:** *"Should we build a defaults store, so each can read from it? And maintaining it
is one pane of glass rather than per function / system?"*

**⟶ The measurement changed the shape of the answer twice.** Of 14 module constants only **TWO** are
defaults; 8 are caps/floors and 4 are identity. ★ **A defaults store built from what LOOKS like
defaults would have had two members** — the scattering he could see is almost entirely caps and
identity, and neither belongs in one.

**⟶ The real defaults are BEHAVIOURAL** and none is a named constant; each lives inside a code path.
And `contract.lua` is already the pane of glass: every field declared with its type, its
optional-ness, its ZERO MEANING and a `why`, **and it is already the one place that reconciles the
STORE form against the RECORD form per field.** A seed is one more property of a field it already
fully describes.

    ⟶ THE ANSWER   `seed =` on the entries that have one. No new module, no new file, no new
                   convention.
    GOES IN        field-level seeds — `trigger` = once · `step` = the minted ordinal ·
                   `band` = 2.5, which moves OUT of `bucket.lua` and stops being a second copy
    STAYS OUT      the SEED ROW (B0) — a whole RECORD, not a field. It stays at its door and
                   POINTS at the declaration, or it becomes the fifth seed convention.

**⚠⚠ NOT EXECUTED, and that is why this drain says so out loud.** Measured today: **`seed =` appears
nowhere** — not in `contract.lua`, not in any register. ⟶ The reasoning is finished and belongs in
the log; **the build is the bench's**, because `contract.lua` ships and a doc conclusion is not a
licence to edit shipped code.
★ Same shape as RI-75's second half and RI-78's code half: **drain the analysis, name the build.**

---

## RI-59 DRAINED (Analyst, 2026-08-26) · **CARRY IT.** The loss is ONGOING, not historical — and the migration writes a third value

_Outcome: the Analyst's owed answer, below. The one-line change is in shipped code and is the
bench's. `ANALYST_LOG` 2026-08-26._

**THE ASK:** *"whether the migration should carry `x.sense` for data already on disk, or whether
that data is accepted as lost."*

### ⟶ CARRY IT — and the deciding fact is not about old data at all

`routes.lua:273` states it plainly: ***"until L1.4 moves the pane onto rows, a pane edit still
writes a flat field."*** ⟶ **The pane writes `child.sense` TODAY.** `migrateNode` returns early only
when a node already has rows, so it fires on exactly the nodes the pane is authoring through the
flat path right now.

★★ **So this is not a question about data already on disk** — the flat write path is live, and
HELM has **Chain 1 STOPPED at L1.2** with L1.4 the leg that moves the pane onto rows.

⚠⚠⚠ **BUT I OVERSTATED WHAT THAT MEANS, and Battlewrath corrected it the same day:** *"'On
migration' is an over state. No beacon / child could be fully authored right now."* ⟶ **No author is
losing a sense today** — the surface cannot author a node end-to-end (RI-65/RI-66: the boss listener
is unbuilt, the test drive fakes it with a button). ★ I proved the WRITE PATH exists and claimed
AUTHORS were using it. Struck: ~~*every node authored between now and L1.4 silently loses its
sense*~~ — that set is empty today.

⟶ **The answer is unchanged and the reason is better.** The window is SHUT and will open when the
surface completes. Because `migrateNode` is one-shot, a loss after that point is unrecoverable — so
the line lands **before** authoring completes rather than in response to damage. **Ordered, not
urgent.**

⚠ And the field is real, declared and authored — `contract.lua:95`:
`{ name = "sense", type = "id", why = "whenOn | seen | whenOff - the floor words" }`.

### ★★★ A SECOND FINDING THE ITEM DID NOT NAME: the migration writes a THIRD value

    Routes.SENSE_DEFAULT   = "reachHere"     routes.lua:1475
    Routes.Sense(x)        = x.sense or SENSE_DEFAULT   -> an unset CHILD resolves to reachHere
    migrateNode            writes `sense = "whenOn"`    -> hardcoded, neither the author's nor that

⟶ Two nodes with identical authored state behave differently depending on whether they were
migrated. ⚠ **But this is NOT a defect on its own**, and saying so matters: `SENSE_DEFAULT` answers
*what does an unset CHILD do*, while a migrated ROW's `whenOn` matches **AL-18's seed ruling** — the
seed row is `When on` with no action. **Two different questions, two right answers.** ★ The fault is
only that the migration uses the row answer for a field the AUTHOR had already answered.

### ⟶ WHAT THE BENCH BUILDS — one line, and the fallback stays

    rows[#rows + 1] = { sense = x.sense or "whenOn", action = x.action }     routes.lua:326
    rows[#rows + 1] = { sense = x.sense or "whenOn", action = "boss", arg = x.boss }        :330

⚠ **The `whenOn` fallback STAYS.** It is AL-18's seed, not a stand-in for `SENSE_DEFAULT`, and
changing it would alter behaviour for nodes whose author never picked a sense — a different
question, and not one this item asked.

⚠⚠ **AND IT IS ONE-SHOT, which is why it is worth doing before the next capture.** `migrateNode`
returns early once a node has rows, so a node that migrates with `whenOn` **can never be repaired by
re-running the migration** — the authored field is orphaned permanently at that moment. Every day
this is open converts more authored senses into unrecoverable ones.

★ THE ANALYST'S HALF IS THIS ANSWER. The edit is in `routes.lua`, which ships, and **the dev manages
the tree** — so it is named, not made. Its criterion writes itself: *a child authored `whenOff`,
migrated, has a row whose sense is `whenOff`; a child with no authored sense still migrates to
`whenOn`.*

---

## RI-56 DRAINED (Analyst, 2026-08-26) · the R bounds now have a model home; the band's ceiling was never owed one

_Outcome: `driver_data_model.md` gains the R bounds beside the `band nil → 2.5` row. Part 2 needed
nothing built and still does not._

**PART 1 — the ☐ is closed.** The item said the model *"records `band nil → 2.5` in its field table
but carries no R bounds row."* Verified: **zero** R rows there, and all three constants shipped —
`R_FLOOR = 5` (`routes.lua:1184`), `R_CEILING = 300` (`:1203`), `R_STEPS` (`:1204`). Now recorded,
with each one's provenance carried rather than flattened:

    R_FLOOR    DERIVED - v_ceiling × POLL_MIN / 2. Asserted at test time, never recomputed.
    R_CEILING  ⚠ HIS JUDGEMENT, NO DERIVATION - *"maybe 300 yards"*. Recorded as RULED, not as
               measured, so nothing later reads it as though something computed it.
    R_STEPS    the picker's OFFER, never a constraint - and its ENDS are the bounds.

★ **A third case joined the per-field conversion block, and it is not a conversion.** `stage/step`
convert `nil → 0` and `band` converts `nil → 2.5`; **`radius` is REFUSED BY NAME**, because once the
mint carries the floor, a nil radius can only mean pre-default data. Three fields, three different
answers to the same absence — which is exactly why the block says *"BUCKET converts by field."*

⟶ And the thing a reader most needs: **`A10.3e-R` enforced the floor AT THE PICKER; his word moved
it to THE MINT.** A node is drivable the moment it exists rather than when someone opens a pane.

**PART 2 — nothing was owed, and that is the finding.** The band's ceiling is *"undefined"*, and the
`10` arrived hedged with the reason it might be wrong. ⚠ **Building it would turn a hypothesis into
a bound that later reads as decided.** Nothing was built and nothing should be.

★★ **The bench's own correction inside this item is worth keeping.** It first proposed settling the
ceiling from the corpus — group points by the client's `floor` label and read the gap between
groups. The mechanism works; the conclusion does not, **because `floor` does not mean height**
(Battlewrath: *"One floor is a area. A area can have overlapping spaces within the same space, such
as a cat walk above the entry."*). ⟶ Measured across 24 corpus files and 8 (map, floor) groups, and
withdrawn by measurement rather than by argument. **That is the shape to keep: a filed read
corrected by its own filer, with the data shown.**
