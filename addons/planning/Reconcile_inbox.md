# THE ANALYST INBOX (`Reconcile_inbox.md`) — a CONVERSATION between the bench and the Analyst

⚠⚠ **RESTRUCTURED 2026-08-21 at Battlewrath's ask:** *"Restructure the reconcile inbox to be Analyst
inbox. It's a conversation, each takes from it and inputs as need. Then a log to extract the IS /
IS NOT and reasoning / outcome."*

★★★ **WHAT CHANGED, and why it was needed.** This was a ONE-WAY relay: the bench filed, the designer
drained. **There was no channel from the bench to the Analyst at all** — so Dev's findings on the
Analyst's own acceptance rows, and the "genuinely blocked and yours" lists, arrived by BATTLEWRATH
RELAYING THEM. ⟶ That is the traffic that least needs his judgement, and it was the traffic he
carried. **Now both seats write here and both read here.**

★ **THE NAME STAYS, and it stopped needing a gloss.** Reconciliation IS the Analyst's job
(`driver_architecture.md` §0: *"reconciles IMPLEMENTATION against the model and the governing
docs"*), so the file is named for what it does. ⚠ And the path is an IDENTITY — 25 citations across
14 files, a tool, and `operations/HELM.md` — so renaming it to relabel it would be the
shift-and-renumber fault one layer up (R7).

    WHO WRITES     the **Addon creator** and the **Analyst**, both ways. Battlewrath DRAINS what
                   reaches him; either seat may answer the other without him.
    WHAT IT IS     the CONVERSATION — open questions, options, measurements, marked reads.
    WHAT IT IS NOT the conclusions. Those go to **`ANALYST_LOG.md`** in his form:
                   **question · outcome · NOT statement · IS statement · cite.**
                   ⚠⚠ **The NOT line is the point** — an outcome recorded only as what was chosen
                   leaves the rejected shape free to drift back.
    ONE LEVEL UP   `ARCHITECT_INBOX.md` / `ARCHITECT_LOG.md`, for the macro model.
    THE PROSE      `history/Reconciliation_inbox_drained.md` — read for WHY, never for WHAT.

★ **THE INVARIANT, now across two files:** an item is EITHER a full entry here OR a row in the log,
never both. **Derive status, never read it:** `py addons/tools/check_inbox.py`.

_Battlewrath, 2026-08-19: **"Too many competing thoughts / statements degrade the utility of the
planning files. It's where we settle what is true."** ⚠ Kept short on purpose: an inbox that grows
is one nobody empties — and now that two seats write to it, that matters more, not less._

_Standing channel, opened 2026-08-18 (§325)._

## How it works

    EITHER SEAT FILES   a question it cannot settle alone, with everything needed to settle it -
                        options, costs, what is already built on an assumption, and the bench's
                        own read MARKED AS THE BENCH'S so it can be overturned in one word.
    ★ A TIE BREAK      is a DIFFERENT SHAPE (Battlewrath, §342): "tie break with instruction
                        instead of deliberation." When two governing docs disagree the rule has
                        ALREADY decided which wins - weighing them again is the builder doing
                        the thing the rule forbids. So it states the tie and lists INSTRUCTION
                        LINES to pick from. No bench read.
    THE DESIGNER DRAINS rules it · reconciles every record the ruling touches · checks the
                        IMPACT list below the item and says which parts actually moved.
    THE ITEM LEAVES     to §DRAINED at the foot with a one-line outcome and where it landed.
                        Removed entirely once the records carry it.

⚠ **An item is not a discussion.** If it needs a conversation it belongs in chat first and arrives
here as a question with options. **A row with no options is not ready to be drained.**

★ **Every item carries an IMPACT block**, because *"test against impact"* is the drain's second
half: a ruling that changes nothing on disk and a ruling that invalidates a shipped guard are
different events and should not look the same in an inbox.

⚠ **This file is a CHANNEL, not a governing document.** It directs nothing; it holds questions
until they are answered. `DRIVER_BASIS.md` is the authority and should carry a pointer to this so
nobody mistakes an open question here for a ruling.

---

# OPEN

_**Status lives on the ITEM, never in a header** (bench finding 2026-08-19: two conventions were
live — RI-1..8 inherited "drained" from the section, RI-9.. carried their own stamp — so a hand
header compensated and went stale within a day, on RI-18). **The one convention: an item is DRAINED
when its text begins `RI-N DRAINED (who, date)`; an item without that stamp is OPEN.** Derive,
don't read a list: `grep -n "RI-[0-9]* DRAINED" Reconcile_inbox.md` gives the drained; every other
`## RI-` heading is open; the next number is the highest present + 1. Sections are PLACEMENT only
(open items sit here, drained items move below) — the stamp is the truth if they ever disagree._

---

## RI-81 · FROM THE ANALYST, TO THE BENCH — three builds I answered and then left in history. None urgent; all one-liners.

_Filed 2026-08-26. Each verified absent from the shipped code TODAY, not recalled._

⚠ **Why this exists at all:** this file's header is Battlewrath's — *"a CONVERSATION between the
bench and the Analyst… each takes from it and inputs as need."* **I had been using half of it.**
Every build I answered and named back went into `ANALYST_LOG` and the drained history, where the
bench has to go looking for work addressed to them. These three have been sitting there.

    1  routes.lua:326,330   `{ sense = x.sense or "whenOn", … }`        RI-59, answered today
    2  contract.lua         `seed =` on the fields that have one        RI-53, answered 2026-08-21
    3  sheet_decl.lua       delete the duplicate specimen list          RI-75, named 2026-08-25

**1 · `migrateNode` drops the author's sense.** It hardcodes `whenOn` and never reads `x.sense`.
⟶ Criterion: *a child authored `whenOff`, migrated, has a row whose sense is `whenOff`; a child
with no authored sense still migrates to `whenOn`.* ⚠ **The `whenOn` fallback STAYS** — it is
AL-18's seed ruling, not a stand-in for `SENSE_DEFAULT`, and changing it answers a different
question.
★ **Not urgent, and ordered rather than pressing** (Battlewrath, 2026-08-26: *"'On migration' is an
over state. No beacon / child could be fully authored right now."*). The reason to do it before the
surface completes is that **`migrateNode` is one-shot** — it returns early once a node has rows, so
a node that migrates with `whenOn` can never be repaired by re-running it.

**2 · `contract.lua` is already the pane of glass and is missing one key.** RI-53 measured that of
14 module constants only TWO are defaults, and that `contract.lua` already declares every field
with its type, optional-ness, zero-meaning and `why`. ⟶ `seed =` on the entries that have one —
`trigger` = once · `step` = the minted ordinal · `band` = 2.5, **which moves OUT of `bucket.lua`
and stops being a second copy.** The SEED ROW (B0) stays at its door and POINTS.

**3 · `sheet_decl.lua` still carries two copies of the specimen list.** `task_geom` is to read this
file instead, and the second copy goes when it does. ★ Its own discipline is the argument: a
calibration standard that is append-only and single-source **cannot tolerate a second copy of its
specimen list.**

_No question for Battlewrath. Each is the bench's to build or to push back on; the dev manages the
tree and none of these was made from a doc._

## RI-79 · FROM THE ARCHITECT — the LAW PASS Battlewrath is sending the Analyst: form and ground rules
_Filed by the **Design architect**, 2026-08-25, so the pass arrives with its form on the record.
Battlewrath: "I'll get reconcil agent to do a law pass first. Relates to; Does not relate to; Lesson to
learn for un-related" — refined same turn: "Or just a primitive. So it's the principle behind the law
that generalises." Born from AI-34/AL-60, where a law's WORDING was pattern-matched and its scope
over-reached._

**The pass, per law — all 22, as they were numbered L1–L22 before the rename:**

    PRIMITIVE       the principle behind the law — the thing that GENERALISES. The law's wording does
                    not generalise; the primitive does. (DR_UI_21's is predictability: "a system users know
                    rather than react to." row.md's rule answers a different primitive — stable
                    structure — which is why AI-34's stitch was a family resemblance, not a shared law.)
    RELATES TO      what the law has actually governed — cited to the ruling/instance.
    DOES NOT RELATE what someone reached for it on and was wrong — CITED INSTANCES ONLY (DR_UI_21 has two:
                    AI-33's subject/space boundary · AI-34's neighbours strike). ⚠ Where no instance
                    exists, write "none yet" — authoring negative scope cold is
                    dont-extend-past-the-evidence run in reverse.
    LESSON          for the unrelated case: WHY it looked related. The tripwire for the next reader.

★ **ANALYST'S HALF DONE 2026-08-25 → `law_pass_draft.md`, filed to the architect as AI-35.**
The item stays OPEN: **the landing in §5 is the architect's**, and an item is not finished because
one side of it is. ⟶ The measurement that shaped the draft: **of 22 laws, ONE has been fought over**
— DR_UI_21 with 5 boundary/strike lines, DR_Content_15 with 1 that is a recovery rather than a wrong reach, and
zero for the other twenty. So twenty entries read *"none yet"*.

**Routing:** the Analyst DRAFTS against the record (the log, the inbox items, the strikes — the instances
are filed); the L-series is the architect's to write, so drafted boundaries and primitives fold into
`driver_architecture.md` §5 through the architect. Their pass, the architect's landing.
_No question for Battlewrath — his form, recorded. The instruction reaches the Analyst from him; this row
is so the form does not arrive re-worded._

## RI-72 · THE ANALYST'S OWN INSTRUMENTATION — status is PROSE, and that is what lets acceptance rot both ways

**Filed by: the Analyst, 2026-08-22**, at his ask: *"specifically for your self. Any work flow or
tooling issues around maintaining the middle of 'What is true' and 'What should be' (Divorced of
execution.)"*

⟶ **Yes, and it is one problem with two faces.** The middle I hold is `code` ↔ `governing set`, and
it went stale in BOTH directions inside two days without anything noticing.

    §467 (2026-08-21)   the docs said things were BUILT that were not — found by a four-agent sweep
    §504 (2026-08-22)   the docs said things were UNBUILT that were — found by a new tool

★★ **Two directions, two one-off investigations, zero standing signal.** Each cost hours and each
found real things; neither can run tomorrow morning by itself.

### ★★★ THE ROOT, IN ONE LINE: A ROW'S STATUS IS PROSE

`OWED` · `NOT BUILT` · `LANDED` · `WRITTEN AHEAD` are **words inside a sentence.** Nothing derives
them, so nothing can contradict them.

⚠ **And the project already solved this exact problem one layer up.** `Reconcile_inbox.md` had the
same fault and `check_inbox.py` fixed it: an item is DRAINED when its text begins `RI-N DRAINED`,
status is DERIVED, and the tool refuses when what an item says about itself and what the convention
reads disagree. ⟶ **Acceptance has no equivalent.** The inbox cannot lie about its state; the
acceptance briefs can, and did, twice.

### ⟶ THE PROPOSAL, small and shaped on what already works

    A DERIVABLE TOKEN   one per row, in the row's own head, from a closed set:
                        `OWED` · `BUILT` · `RETIRED` · `ADVISORY`
    A GUARD             `check_acceptance.py` derives it and REFUSES on a contradiction it can
                        actually see:
                          · a row says OWED and its `grades` function is DEFINED  → stale, doc behind
                          · a row says BUILT and its `grades` function is ABSENT  → stale, doc ahead
                          · a row says RETIRED and nothing near it marks a retirement → the
                            headstone convention `check_retired` already reads

★ **Both of this week's failures are in that table.** A12.4b said the code term was unchosen while
`Routes.TRIGGERS` shipped; A12.2f said `Bucket.Build` had no orphan check while `bucket.lua` was
headed *"A12.2f · NO SILENT ORPHAN"*. **Each is one line of derivation away from being caught the
same day.**

### ⚠⚠ AND THE HONEST CEILING, WHICH IS THE REAL FINDING

    acceptance rows        195
    rows with a `grades` line   48   (25%)

**Three quarters of the acceptance has no join to code at all.** ⟶ For those rows no guard is
possible, in either direction, ever — not because the guard is hard but because **nothing connects
the row to anything that could move under it.**

★★ So the tooling answer and the coverage answer are the same answer: **`grades` IS the middle I am
being asked to hold, and it exists for a quarter of it.** ⚠ `emit_built_state` has printed that 25%
honestly all along and I have been reading it as a coverage statistic. **It is not — it is the
fraction of my own seat that is instrumented.**

⬜ **What I would do, in order, and none of it is urgent:** the token and the guard first (cheap,
and it catches the two shapes that actually bit) · then `grades` lines added as rows are TOUCHED,
never as a sweep — 147 rows of retro-fitting is churn, and a row nobody is reading is a row nobody
is misled by.

### ❌ AND NO, THE BENCH SHOULD NOT GET AN ANALYST-TO-BENCH INBOX — asked and answered

Battlewrath, 2026-08-22: *"And should the bench have an inbox? Or is that offering too much
guidance? (Dev work is solving the problem against a criteria.)"*

⬜ **FIRST, THE PREMISE: THEY ALREADY HAVE ONE.** `Reconcile_inbox.md` IS the bench's inbox and has
been since he restructured it — *"it's a conversation, each takes from it and inputs as need."*
RI-58..71 are the bench's own filings. **The channel is not missing.**

★★★ **AND A DIRECTED ONE SHOULD NOT BE ADDED, for the reason in his own parenthesis.** A
conversation between seats invites findings and questions. **A directed channel invites `how`** —
that is what a channel pointed at one seat is FOR, and `how` is the bench's. ⚠ The Analyst would
fill it, too: this session alone I recommended S1 over S2, (b) over (a), and keying `ROW_ARG_TYPE`
on the action. **Each was right and each landed through a channel that made me mark it as my read
rather than a direction.** The marking is what kept it honest, and a directed inbox removes the
thing that forces the marking.

★★ **THE ADDRESS THE BENCH ACTUALLY LACKS ALREADY EXISTS AND IS `grades`.** A row cannot reach a
builder today; the builder must find the row. ⟶ A `grades` line IS the row addressing the code —
and it is **guidance-proof by construction: you cannot smuggle a solution into a function name.**
It says WHICH function answers the criterion and nothing about how it should.

⟶ **So the answer is not a new channel; it is coverage of the one we designed to be incapable of
over-guiding.** 48 of 195. Same finding as this item's ceiling, reached from his question instead
of from my tooling — which is the strongest signal either half has.

### ⚠⚠ THE STATUS TOKEN — THE ANALYST'S POSITION, WRITTEN BEFORE TWO AGENTS WERE ASKED (2026-08-22)

_Per his standing rule — *a sub-agent is a reasoning tool for where you would agree with your own
outcome* — this is recorded BEFORE the comparison, so agreement confirms and disagreement is the
finding. It argues AGAINST my own earlier framing of the token as "the biggest single win"._

#### 1 · ⚠⚠⚠ THE TOKEN MUST NOT BE DERIVED FROM WHETHER THE GRADED FUNCTION EXISTS

That existence is **the signal `check_acceptance` compares the token against.** Derive one from the
other and the check compares the code to itself and passes forever. ⟶ **It would be the sixth
inert guard on this project's record (§457 · §458 · §465 · §472 · §511) — and the first one built
deliberately.**

★★ **The token's whole worth is that it CAN DISAGREE with the code.** A status derived from the
code can never disagree, so it can never catch anything.

#### 2 · ⚠ "RECOVERY" IS MOSTLY NOT RECOVERY — measured

    58 rows carry `grades` and no status.
    25   a status word appears somewhere in the BODY
    34   no status word anywhere at all

⚠⚠ **But the 25 are not a free pass.** The first three sampled carry **two or three CONFLICTING
words** — `A12.1c` OWED *and* SHIPPED · `A12.4b` OWED *and* LANDED · `A12.5d` OWED *and* RETIRED —
because a row's body is a **HISTORY**, not a status. ⟶ Choosing among them is a judgement about
which one is current, and choosing wrong writes a FALSE status into the index people read instead
of the row.

#### 3 · ⟶ SO THERE IS NO CHEAP BULK PASS HERE, and this is where it differs from the prose tests

    THE PROSE TESTS   the thinking was DONE; only the shape was unreadable. Recovery, near-zero
                      judgement, and 31 rows landed in one pass.
    THE STATUS TOKEN  a FRESH CLAIM someone must be willing to be WRONG about.

★ **I called this "the biggest single win" twice and the measurement does not support it.** It is
the biggest *available* win only if the claims are made honestly — 58 guessed tokens would be 58
new things for the checker to confirm against itself.

#### ⚠⚠⚠ THE THREE-WAY OUTCOME (2026-08-22) — BOTH AGENTS AGREED, AND THE AGREEMENT IS WORTH LESS THAN IT LOOKS

**⚠ FIRST, A FAULT IN THE METHOD, MINE.** I filed this position to THIS FILE before spawning, to
make its independence provable in git. It made it **discoverable**: both agents found and quoted it
(`:165-215`, `:207-217`). ⟶ The commit's independence claim was true about TIMING and false about
CONTENT. **A read filed to the shared surface is no longer a hidden card.** ⟶ Next time the prior
position goes to the scratchpad and lands after.

★★ Both answered **"No, not 58"** — but neither was an independent confirmation, so the value is in
what they added, not in the agreement.

**★★★ THE FINDING (B's, measured by me before accepting):**

    graded symbols NOT DEFINED in the shipped code ....... 0

⟶ Existence is the ONLY signal on the other side of the comparison, so:

    BUILT     19 rows   ⚠ THE ARM CANNOT FIRE ON ANY ROW. Writing BUILT writes SILENCE.
    OWED       5 rows   fires INSTANTLY on anything - and existence is not a criterion being MET
    RETIRED    7 rows   ✅ the only LIVE arm: it checks a HEADSTONE, which is a DOC fact

★★★ **`BUILT` and `OWED` are ONE input read in two directions — a coin, not a check.** ⟶ This
CORRECTS my §1 above: I wrote *don't DERIVE the token from existence.* The truth is sharper —
**you cannot avoid deriving from it, because existence is all that is over there.** ⟶ **The token
was never the missing piece. The COUNTERPART is.**

**★★ AND THE COUNTERPART ALREADY EXISTS**, handed over by B without being named as one — the code
CITES THE ROW BY ID. Measured across every `.lua` in the repo (691 files — `check_cites.py`'s fault
was scoping to one addon, so the scope was taken first):

    row ids named in Lua ................................ 122
    graded rows that are UNSTATED and CITED BY CODE ...... 43

⟶ **A citation is INDEPENDENT of existence**: a human wrote it at build time, naming the row. Two
signals that can genuinely disagree — which is the whole property `BUILT` lacks.

**⟶ THE WORKED INSTANCE — `A8.4`, live right now.** The row's head reads *"**LIVE DEFECT**:
`composeId(name, n)` bakes the route NAME into the key."* The code names the row at **15 sites**
across `routes.lua`, `store.lua` and `promoter.lua`, and they say the opposite — *"`composeId` IS
GONE, not parked"*, and `Routes.MigrateRIDs` IS the migration the row asks someone to write. ⟶ **Six
checkers on this bench and none of them see it**, because every one compares a doc to whether a
SYMBOL exists.

⚠ **I HAND-COPIED FIVE LINE NUMBERS HERE FIRST, and `check_cites.py` counted them among its 35
ambiguous citations the same hour.** ⟶ Replaced with symbols and quoted sentences, and the sites are
left to `--queue`, which emits them. ★ [[machines-do-the-mechanical-work]] carries this failure
TWICE already; **the fault is never forgetting the lesson, it is not recognising its new shape.**

⚠ **WHAT THIS DOES NOT ESTABLISH.** 4 rows say BUILT and are cited by nothing (`A12.10b` `A12.10d`
`A12.2j` `A12.5c`) — all landed THIS SESSION, so "not cited" most likely means YOUNG, not stale.
The absence direction is not evidence yet. **Only the presence direction has a proven instance.**

#### ⟶ THE BURN-DOWN, MOVING (2026-08-22)

    the queue           43 -> 42   `A8.4` drained: LIVE DEFECT struck, BUILT §335, smokes RUN
    `checked`           22 -> 23
    the harness         `addons/tools/mutate.py` + `_mutate_selftest.py` - 8 mutations, 3 checkers

⚠ **A8.4 IS THE PROOF THE COUNTERPART WORKS, AND ALSO THE PROOF IT IS NOT A VERDICT.** The 15
citations pointed at it; what SETTLED it was running `smoke_dungeonrunroutes.lua` (A8.4's M1-M7,
including M4 *a colon in the name round-trips* - the exact defect the row called live) and
`smoke_dungeonrunpromoter.lua`. ⟶ The queue says WHERE TO LOOK. It never says what is true.

#### 4 · ⟶ WHAT I WOULD ACTUALLY DO

**Not 58.** Assert the token only where the status is LOAD-BEARING — a row a builder would act on
differently depending on the answer — and leave the rest UNSTATED. ⚠ **An unstated status is
honest; a guessed one is worse than nothing**, and the count stays visible either way because the
tool prints it.

★★ Which is the same shape as the rest of this station: **declare what you know, name what you do
not, and never let a number decide which.**

---

### ⚠⚠ CORRECTED THE SAME DAY — "53% INVISIBLE" WAS MEASURING **ERA**, NOT KIND

_At his ask: *"Let's explore what the grading is. And where it is useful."* ⟶ Exploring it broke
the framing filed below, an hour after filing it._

**The split by row family, which tracks age:**

    family      rows   TEST: line   test in PROSE   neither   grades
    A1-A9         54        5            28           21        20
    A10-A11       72       26            17           29        14
    A12-A13       43       41             2            0        31

★★★ **A12/A13 — this week's work — is 41 of 43 with a `TEST:` line and ZERO with neither.** The
oldest families are almost none. ⟶ **The convention HARDENED over the last week and the older rows
predate it.** What I filed as *"53% of acceptance is invisible"* is far more a measure of when a
row was written than of what kind of row it is.

⚠ **AND THE SPECIFIC THING THAT BROKE IT:** `A1.3` reads *"Test: unset → `ReachOf` nil AND the
resolved band"* — **a real test, written in prose rather than on a `TEST:` line.** My detector
counted it as untested. ⟶ **47 rows carry a test the tools cannot read.** They are not ungraded;
they are unparseable.

### ⟶ SO THE REVISED BURN-DOWN, and it is cheaper than the one below

    47 rows   THE TEST ALREADY EXISTS, IN PROSE. Moving it to a `TEST:` line is near-zero
              THOUGHT - the thinking was done when the row was written. **Cheapest real win.**
    45 rows   a STATUS TOKEN on the `grades only` set (unchanged - still the biggest single win)
    50 rows   the genuine question: RECORD or unfinished CRITERION? Triage, on touch.
    12 rows   a `grades` line where the identifier is already in the prose

### ★★★ AND THE ANSWER TO **WHERE GRADING IS USEFUL**, from this week's evidence only

    IT CATCHES A CRITERION THAT IS WRONG.   A12.7a tested *"Set(1) at stage 3 → the run is at 1"*
                                            and AL-23 rules `max`. **The row would have failed
                                            CORRECT CODE.** ⟶ Grading protects the code from the
                                            doc, which is the direction nobody expects.
    IT CATCHES THE RECORD GOING STALE.      Both ways: §467 (said built, was not) and §504 (said
                                            unbuilt, was). Neither was found by reading.
    THE MUTATION IS WHAT MAKES A TEST REAL. Five guards went inert while printing green. **Without
                                            its mutation a test is a claim, not a check.**

    ⬜ IT DOES **NOT** USEFULLY GRADE A RULING. `A2.9` — *"a stage change is NOT a tab"* — gates
    nothing; it SHAPES other rows. `A3.1` is a wording correction. Instrumenting those would be
    inventing a join to satisfy a counter.

★★ **THE RULE, and it is testable per row:** *grading is useful exactly where something can be
SILENTLY WRONG and there is a PLACE THE BEHAVIOUR LIVES.* No silence, no place — no grade.

---

### ⟶ WHAT "FULLY UNLOCKED" MEANS, MEASURED (2026-08-22) — the burn-down for the round trips

Battlewrath: *"We'll do round trips until this station is fully unlocked. Then Dev has a more
stable state to pick up from."* ⟶ So it needs a NUMBER rather than a feeling. Measured across the
five briefs, by what an instrument can actually see:

    both  (grades + status)    20   11%    fully checked, both directions
    grades only                45   26%    the emitter sees them; staleness cannot be caught
    status only                13    7%    a status with nothing to check it against
    NEITHER                    91   53%    ⚠⚠ invisible to every instrument this station owns
    ─────────────────────────────────
    total                     169

★★★ **53% IS THE LOCK**, and it is a truer number than the 26% coverage figure I have been
quoting — that one counted `grades` alone and hid the fact that most graded rows still cannot be
caught going stale.

### ⚠⚠ AND "UNLOCKED" IS **NOT** 169/169 — that target would be a lie

Of the 91 invisible rows, **only 12 already name a real function.** The rest largely grade a
DISTINCTION or a RULING rather than a behaviour — *"supertrack is a characteristic, not a
behaviour"* has no function to point at, and never will. ⟶ Forcing a `grades` line onto those
would be inventing a join to satisfy a counter.

★★ **THE HONEST TARGET: every row is EITHER instrumented OR declared uninstrumentable.** That is
reachable, and it is the same move `emit_built_state` already makes — *"UNMAPPED, not ungraded —
the tool cannot tell which, and says so."* A row that cannot be checked should SAY it cannot, or
every future measurement reads it as debt.

### THE BURN-DOWN, cheapest first

    1  45 rows · ADD A STATUS TOKEN to the `grades only` rows.
       ★ THE BIGGEST SINGLE WIN: they already carry the join, so a status moves each from
       half-visible to catchable in BOTH directions - which is the failure that cost §467 and
       §504. One word per row.
    2  12 rows · ADD A `grades` LINE to the invisible rows that ALREADY NAME a function in their
       text (A12.2c · A12.5a · A12.9a · A2.8 · A9.1 · A9.5 · A2.10c · A10.3a · A10.3e · A10.9e ·
       A11.4b · A11.6b). Near-zero cost - the identifier is already sitting in the prose.
    3  13 rows · the `status only` set: does each have a function? Some will; some are rulings.
    4  79 rows · TRIAGE, NOT CONVERSION. Mark the ones that genuinely cannot be instrumented.
       ⚠ **ON TOUCH, NEVER AS A SWEEP** - 79 rows of retro-fitting is the churn this project
       refuses, and a row nobody is reading is a row nobody is misled by. The COUNT is honest
       without the pass, because the tool computes it any time.

⚠ **AND NONE OF THIS IS BLOCKING DEV.** The station is stable for what it can see today; this
burn-down widens what it can see. ★ The thing that would actually block is the opposite —
declaring 100% and instrumenting rows that have nothing to instrument.

### ⚠ AND ONE FAULT THAT IS MINE ALONE, NOT TOOLING

I mangled a shell heredoc **three times this session** — a regex with `\n` in it, twice more with
quoted escapes — and each time the fix was to write the script to a file instead.
★ [[author-in-a-file-not-in-the-shell]] already says this, and names the tell exactly: *about to
quote a quote → write the file.* ⟶ **Knowing the rule did not fire it.** The correction is
mechanical rather than attentional: **any script carrying a regex or an escape goes to a file
first, with no judgement call at the moment of writing** — because the judgement is what failed.

---

## RI-65 · ★ A6.1 AND A6.2 ARE UNCOVERED — and A10.5b names A6.1 as the test drive's FIRST PROOF

★ RE-MEASURED 2026-08-23 by running the smoke: **still 2 of 18 UNCOVERED**, A6.1 and A6.2 unchanged. Left OPEN — and it is blocked on RI-66, which has no listener to prove.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** `smoke_dungeonrunroutes` reports *"2 of 18 criteria UNCOVERED"* —
**A6.1** *a boss kill alone moves the stage* and **A6.2** *both witnesses required; either alone
does not advance*.

**IMPACT:** A10.5b makes A6.1 the acceptance that the test drive remote exists to run
(*"advance on just a boss kill against a landed capture"*). The pane is built and its first proof
is not.

**THE BENCH'S READ:** blocked on the item below — there is no boss listener to prove.

---

## RI-66 · ★ THE `boss` LISTENER DOES NOT EXIST — the test drive fakes it with a button

★ RE-MEASURED 2026-08-23: no CLEU listener exists in `manager.lua`. ⚠ A12.4c rules the listener's DISARM lifecycle (*"a CLEU listener must go with it"*) — that is the lifecycle of a thing that does not yet exist, so it does not close this item.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** nothing arms a CLEU listener for a boss kill. `drive.lua` binds `boss` to a body
that parks the ctx and waits for a **Boss down** button press.

**WHAT IS:** `drive.lua`'s binder, with the reason stated in place — *"A10.5b's proof is advance
on just a boss kill; the listener is the thing being specified, and a harness that guesses at it
would prove the guess."*

**IMPACT:** the whole boss half of the grammar is unexercised against the client. A12.4c's
pending-tab shape IS built and graded offline; what is missing is the thing that completes it.

**THE BENCH'S READ:** `capture.lua` already reads engage events and boss tokens on this fork and
`rfc_combat` measured them live — so the client half is known. ☐ What is not settled is whether
the manager's listener is capture's code reused or its own.

---

## RI-54 — THE HEADING · every open end as directed work, in order, with its criterion named

**Filed by: the Analyst, 2026-08-21**, at Battlewrath's instruction: *"Your role is to help
materialize and resolve the open ends for Dev. Not give back problems. That means future heading
too. What can't be done is the material for development, not caution."*

⟶ **Nothing below is a question.** Every line is a thing to build, the row that grades it, and what
must land first. ⚠ Where a decision is genuinely someone's, it says whose **and says what unblocks
without it** — a heading that stops at a decision is a problem handed back.

---

## ⚠⚠ SCOPE CORRECTED 2026-08-22 — THIS IS NOT THE BUILD RANKING. RI-58..71 IS.

**Battlewrath asked whether the Analyst's communication on the next leg is clear enough to follow.
Measured: it was not.** This item was filed 2026-08-21 and the bench filed its own fourteen-item
implementation gap list the next day (**RI-58..71**, ranked, measured against the shipped code).
⟶ **Two headings existed and neither pointed at the other**, and a builder reading both got two
orderings — the older one being this.

★★★ **AND IT IS THE SAME FAULT THE ANALYST FLAGGED THREE TIMES THE SAME DAY IN OTHER PEOPLE'S
DOCUMENTS:** an index that RESTATES rather than POINTS is a second copy that drifts (DR_Process_18/DR_Content_20 — the
concept homes, the enumerated action list in A10.x, `Routes.ACTIONS`). **This heading was the
fourth instance and it was mine.**

    THE BUILD RANKING       **`RI-58..71`** — the bench's, ranked, measured. **Read that first.**
                            Where an item below overlaps one of theirs, THEIRS is the current one:
                            RI-62 (the trigger door) · RI-60 (the arg door) · RI-69 (`SetNext`).
    WHAT THIS ITEM KEEPS    only what is NOT in their list — the cross-cutting items and the
                            Analyst's own queue, below. ⟶ It is a companion to their ranking, not
                            a rival to it.

⚠ **RE-MEASURED AGAINST THE CODE 2026-08-22, so the entries below are not taken on trust:**
`A12.5f` is **still unbuilt** (`manager.lua` completes a stage on `lone and stage > 0`; there is no
item-set branch) · `bucket.lua` **still re-implements** `AcceptanceOf`'s rule in two comments ·
the three built-but-ungraded rows now have criteria and are runnable.
★ Everything else here predates 2026-08-22 and should be read against the bench's list before
being acted on. **A heading nobody re-measures is a heading that ages into a wrong instruction.**


---

### ⟶ START NOW — nothing blocks any of these

    A12.5f   THE ITEM SET COMPLETES          a beacon whose items are ALL step 0 completes when
             ⭑ bench                          ALL of them do. The `lone` rule generalised from
                                              *an item of one* to *an item set*.
                                              ★ Do this FIRST of the three ordinal items: it makes
                                              the run correct no matter how a route was authored,
                                              which turns the mint below from a blocker into a
                                              preference.
    A12.2i   ✅ ALREADY BUILT (§470) — the row landed today. **Run it.**
    A12.2j   ✅ ALREADY BUILT (§473) — the row landed today. **Run it.**
    A13.6    ✅ ALREADY BUILT (§471) — the row landed today. **Run it.**
             ⚠ Three items shipped and were ungraded for a week. The rows exist now; the gate
             gets three more mutations, not three more decisions.

    —        BUCKET CALLS `AcceptanceOf`        it cites the rule in two comments and
             ⭑ bench                            re-implements it. **One rule, two bodies.**
                                                Small, and it removes a copy that can drift.

---

### ⟶ THE `Next` FIELD — AL-21 said YES; this is what YES costs

    1  the STORE fields          `nextType` / `nextArg`. ★ `contract.lua` has DECLARED them all
       ⭑ bench                   along — **the declaration is ahead of the store**, so this is
                                 filling a shape, not designing one.
    2  the PICKER                A2.9: Step · Stage · Set N, the offer following what exists.
       ⭑ bench                   ⬜ **Analyst owes one row first** — the picker must OFFER
                                 *nothing follows* as an entry whose selection stores NOTHING
                                 (`SetChildSense`'s shipped shape, §79). That is how *no fourth
                                 word* and *select back into it* are both satisfied.
    3  one `NodeDone` BRANCH     the bench's own estimate: *"one branch in one function, and the
       ⭑ bench                   tests move with it."*  Graded by **A12.5c** and **A12.5d**.
    4  the `role` MIGRATION      complete → Stage · set+N → Set(N) · start/update → positions.
       ⭑ bench                   Graded by **A12.5e**. ⚠ WAITS on A10.3 (the replacement pane) —
                                 `role` is live until then. → and `DropRetired` runs AFTER it.

---

### ⟶ `Trigger` — ruled BUILD; two rows are written and waiting

    the PICKER      one control, closed two-value list, default the common case.  **A10.3k**
    the RUNTIME     One time default; Every time re-runs the action and never re-completes.
                    **A12.4b** · **A12.4e**
    ⭑ bench         ⬜ THE CODE TERM IS YOURS. The display words already exist in `contract.lua`
                    (One time · Every time); only the stored id is unchosen.
                    ⚠ **An adaptor row is owed WITH it, not after** — A13.5's measured lesson:
                    the adaptor carries no sense word, A5.1 passes a miss through, so whatever
                    the code term is, that is what the author reads.

---

### ⟶ THE ORDINAL DEFAULT — a steering call that no longer gates anything

    THE QUESTION    should placement MINT an ordinal? `Routes.NextOrdinal` exists with no
                    production caller.
    ⭑ Battlewrath   ⚠ **NOT A BLOCKER, and that is the point of doing A12.5f first.** The door is
       or architect  already shipped (`SetChildOrdinal`, `ordBox`, declared and registered) — an
                    author can set an ordinal today. Only the MINT is unwired.
    EITHER WAY      A12.5f makes the run correct; the mint only decides whether the all-step-0
                    case is rare or ordinary.

---

### ⟶ THE DEFAULTS DECLARATION (RI-53, his answer taken)

    `seed =` ON `contract.lua`      it already declares every field with type, optional, zero
    ⭑ bench                         meaning and `why`. **One more key, no new file.**
                                    ⚠ `band`'s 2.5 moves out of `bucket.lua` — one default with
                                    two homes today — and wants its own row rather than riding.
    THE MINT-AND-COMPARE CHECK      mint one of each through the SHIPPED doors under lua51, dump
    ⭑ Analyst                       what the record carries, FAIL on disagreement with the
                                    declaration. ★ Not a grep — a grep is fooled by where a
                                    literal lives. It makes *"what a freshly placed node carries"*
                                    a PRINTED FACT.

---

### ⟶ THE ANALYST'S OWN QUEUE, so it is visible rather than implied

    the `Next` picker row           owed before the picker is built (above)
    RI-50 rows 2 and 3              the comparand row · the standing closed-verb regression
    16 `grades` lines for `Manager`  its functions are graded by nothing; each needs a read
    the citation FORM               load-bearing `file.lua:N` cites become SYMBOLS.
                                    `check_cites.py` enumerates them; **the fix is the form.**

---

### ⚠ WHAT IS DELIBERATELY NOT HERE

**RI-42 and RI-43** are the bench's own and already filed; repeating them here would make this
heading a second copy of the inbox. ★ And nothing in this file is a schedule — **WHEN stays
Battlewrath's.** This says what may start, and what each thing costs the one after it.

---

## RI-50 — THE ARG IS RAW TEXT USED AS A COMPARAND · the guard, and WA's precedent for it

**Filed by: Addon creator, 2026-08-21 (§465), at Battlewrath's instruction.** Acceptance is owed;
the guard is the bench's to build. His two sentences are the whole item:

> *"One thing against build and accept pre-formed. **Security.** It could be a window for arbitrary
> code. Where the build process and what that means in code expression would be owned by the users
> own addon, not what the authoring addon states is capable."*
>
> *"And I think the answer is in WA again. **User input for the CLEU is just raw text called by the
> log reader for the filter.**"*

### ✅ HE IS RIGHT, AND THE FORK IS STRONGER THAN "RAW TEXT"

Read from the INSTALLED Ascension fork (fact authority; upstream is secondary), read-only:

    Prototypes.lua:3160+   the COMBAT_LOG_EVENT_UNFILTERED prototype
      sourceName           type = "string"
                           test = "sourceNameChecker:Check(sourceName)"
      preamble             "local nameRealmChecker = Private.ExecEnv.ParseNameCheck(%q)"
    WeakAuras.lua:5990     ParseNameCheck - a HAND-WRITTEN character scanner that turns the
                           user's text into LOOKUP TABLES (`name` / `realm` / `full`)

★★★ **So the user's text becomes TABLE KEYS, and `Check` is an equality lookup.** It is never
executed, and — the part worth having — **it is never used as a Lua PATTERN either.** A hand-written
scanner where `string.find` would have been shorter is a deliberate choice, and it is the choice
that makes a hostile name inert rather than merely non-executable.

**Three tiers, in the fork's own order of preference:**

    1  TEXT → A SET, CHECKED BY EQUALITY     the strongest. The text is data all the way down.
    2  WHEN SOURCE MUST BE GENERATED         the value is interpolated with `%q` — Lua's OWN
                                             string-literal escape — so it cannot leave the
                                             literal. (`test = "… UnitGUID(%q) …"`.)
    3  THE TYPE IS IN THE CONTRACT           the prototype declares `type = "string"`, so the
                                             type is checked before the value is ever used.

⚠ **Tier 2 is the fallback, not the pattern to copy.** We generate no source and should keep it
that way; it is recorded because it shows what WA does when it cannot avoid it.

### ✅ WHAT THIS SETTLES FOR US

`ROW_ARG` already names the field per action (`boss = "name"`, `note`/`say` = `"content"`), and
every one of them is TEXT. The arg is a COMPARAND or a payload of text — never a selector of
behaviour. ⟶ **`Routes.ROW_ARG` is our `type = "string"`, and it is not enforced.**

Measured against a hostile route (§464):

    arg = "Ragnaros"       BUILT   string     <-- as intended
    arg = { evil = true }  BUILT   TABLE
    arg = 1234             BUILT   number
    arg = true             BUILT   boolean

### ⬜ OWED — acceptance for three rows, and the bench builds them

    1  TYPE AT BUILD    BUCKET refuses an `arg` that is not the type its action declares,
                        naming it. Every ROW_ARG entry is text today, so the check is
                        *must be a string* — written to READ a declared type when one lands
                        rather than be edited (§458: a copy drifts, a read cannot).
    2  NEVER A PATTERN  The consumer treats the arg as a COMPARAND, never as a Lua pattern
                        and never formatted into source. ★ This is the row WA's scanner
                        exists for, and it is the one that would be missed — a string is
                        still hostile if it is handed to `string.find` as a pattern.
    3  THE CLOSED VERB  A standing regression row: a route naming `loadstring` or `__index`
                        is refused BY NAME. It passes today (§464); nothing proves it stays
                        true, and it is the guarantee everything else rests on.

⚠ **AND ONE THING THE ARCHITECT HOLDS, not the Analyst** (already in AI-5): `Bucket.Resolve`, when
installed, **bypasses the closed-vocabulary check**. Under his principle that may be correct —
resolution is the consuming addon's to own — but rows 1-3 are only as strong as that seam. Noted
here so acceptance does not claim more than it can.

---

## RI-43 · THREE CODE ITEMS FROM THE AI-2 AUDIT — one live defect, two read-site conversions

_Filed 2026-08-21 by the **Analyst** from `audit/reconcile_architecture_2026-08-21.md` §E. ⚠ These
are CODE and therefore the bench's; the doc half of §E is already corrected. Nothing here is a
ruling — each is a measurement with its citation._

### ⚠⚠ E1 · A LIVE DEFECT — an invented altitude inside a recorded distance

    capture.lua:159   local dx, dy, dz = x - pin.x, y - pin.y, (z or 0) - (pin.z or 0)

A missing `z` on either side silently becomes **0**, and the result is written to the record as
`out.od`. The guard four lines up checks `x and pin.x` and **not** `z`.

★ **The comment directly above it refuses this exact pattern:** *"A distance to a point nobody is
tracking is arithmetic, not a second term — and it would sit in the record looking exactly like a
good one."* ⟶ **Guard by SELECTION: refuse the pair, as `Rule.Usable` does, rather than default the
axis.** (Battlewrath's standing rule, 2026-08-21: *"No infinity expressions in code. Guard by
selection."* — the same law reaches a zero-default that fabricates a coordinate.)

### ✅ E1 BUILT §441 (Addons bench) — and two things the item did not have

**Guarded by selection on all SIX terms; `usableCoord` is local to `capture.lua` so recording a
run does not depend on the driver's rule. Mutation 5/5, each on its own message.**

⚠ **E1 IS WIDER THAN THE ITEM SAYS: `y - pin.y` was unguarded too.** The guard tested two of
six. ★ That axis merely RAISES inside the `pcall` and costs `od`; only `z` had the `or 0` that
FABRICATES. Both are closed, and the distinction is the point — losing a term is honest, and
writing a wrong one is not.

⚠⚠ **AND IT WAS ENTIRELY UNGRADED.** §441 measured it before writing a row: **putting the
defaulting code back turned NO smoke red at all.** ★ The fix would have landed with nothing
holding it, and the next person to "simplify" the guard would have met a green suite.

★★★ **THE FINDING WORTH KEEPING — `usableCoord` ALMOST DID NOT EARN ITS PLACE.** Mutation
gutted it to `return true` and the smoke **still passed**: for a NIL axis, simply dropping the
`or 0` is enough, because `z - pin.z` raises and the `pcall` costs the term. ⟶ The guard
looked load-bearing and was not. **It earns its place only on NaN and infinity** — and NaN is
the worse fabrication, because `nil` errors while `0/0` is a number, so `math.sqrt` returns NaN
and the record carries a distance that is not one. `type(0/0) == "number"` is TRUE (A11.2e), so
only `v ~= v` refuses it. Rows added for both.

⚠ **A BENCH ERROR WORTH RECORDING:** it first went looking in `smoke_chain`, which also has an
`od` — but that is **COA_DevDump's**, a different addon. *A grep found the word and not the
file.* The real seam was already there: `Capture.TestPin(x, y, z, mapID)`, so a z-less pin
needed no new door and no exported helper.

✅ **AND THE OTHER `or 0` HITS ARE A DIFFERENT CLASS, checked and left alone:** `core.lua:157`,
`core.lua:159`, `map.lua:1107` and `task_api.lua:249` all default a missing axis inside a
FORMATTED STRING. ★ A display default is read once by a human and gone; E1's was written to the
record. Named here so the next sweep does not re-raise them as the same fault.

### ✅ E2 AND E3 BUILT §451 (Addons bench) — and E2's framing did not survive measurement

**E3 · FIXED.** `routes.lua`'s band comment had three stale clauses and one that aged
perfectly. ★ The survivor is kept and now carries its teeth: *"NO DEFAULT IS INVENTED HERE"*
became `A11.2h`, which deleted `Rule.OPEN` and made the rule REFUSE a nil band. ⚠ The three
that were wrong are named rather than deleted: R2 IS ruled (RI-22/RI-35, upward-only, floors at
2.5) · it is not `±` (`bandDown` retired §402) · and it did not land on that line but at
`bucket.lua`, per model row 27. ⟶ **The prediction was reasonable when written and the answer
went somewhere else** — which is exactly why a comment may not promise where a future thing
will live. It may say what it REFUSES to do, and that half aged fine.

**E2 · CLASSIFIED, NOT SWEPT — and three of the four do not survive the framing.** ⚠ The item
calls `Routes.BeaconAt` *"most load-bearing"*; measured, the four sites are three different
things:

    NextStage   `used[b.stage or 0]` then `while used[n]` from **n = 1** → the slot is
                written and never read. **A NO-OP.** Left as-is: the `or` is what keeps a
                nil out of a table key, so removing it would let the line THROW.
    Gaps        same, for TWO reasons — the report loop runs `for n = 1, top` and 0 can
                never raise `top`. **A NO-OP**, already pinned by *"GAPS REPORTED 0"*.
    StageOrder  ★ **RULED AND GRADED.** A stageless node sorts to the HEAD, which is
                **RI-18 Q5's "no-stage first" falling out for free**, and the promoter smoke
                asserts it by name. Removing this `or 0` would be a behaviour change dressed
                as a tidy-up.
    BeaconAt    the ONLY one that changes an answer, and only at **index 0**.

⚠⚠ **AND AT INDEX 0 IT MAY BE RIGHT.** Stage 0 means ALWAYS ELIGIBLE, and `Bucket.FirstStage`
returns 0 for a route with no staged beacon — so a caller asking *"what is live before the
sequence starts"* and being handed the recovery beacon is a defensible answer. ★ Nothing calls
it (`emit_built_state`: test-only). **The bench does not choose**: the behaviour is PINNED by a
row that asserts WHAT HAPPENS and says plainly it makes no claim that it is correct.

⟶ Each site now says which of the three it is, so the pattern sweep does not re-raise a
no-op or un-rule RI-18 Q5.

### ✅ L2.1 BUILT §451 — the two missing refusals (A12.2b, A12.2f)

    A12.2b   *"two beacons at stage N - re-slot in the editor"*. ★ The RUNTIME half of a
             guarantee whose author-time half (A10.3e's picker) does not exist: three doors
             still accept a second and TELL-AND-TRUST holds at those doors, so the refusal
             lives at BUCKET and the manager never meets a duplicate either way.
             ⚠⚠ **STAGE 0 IS EXEMPT** — RI-40 pools every recovery beacon there BY RULE, and
             the guarantee is about POSITIONS IN THE SEQUENCE. A blanket check breaks that,
             so the smoke grades both halves.
    A12.2f   *"address X:Y resolves to no characteristic"*. ⚠ Nothing writes a row `cid`
             today — a row lives under its child, so the address is implicit — and an orphan
             arrives on IMPORT, which reconstructs by matching the node prefix. ★ A row
             naming its OWN child is fine, and that row is graded too: the check is about an
             address with NOTHING BEHIND IT, not about the presence of one.

✅✅ **AND RI-41's FIXTURE NO LONGER BUILDS.** `probe_bid.lua` now prints the refusal.
§440 measured two beacons at one stage in LOCKSTEP; §448's bare rows removed the shared SLOT;
A12.2b refuses the shape outright. ⟶ **The lockstep is unreachable rather than merely
dissolved**, which is what A12.2b's own mutation predicted. The probe is kept and run — it
demonstrates the refusal the manager's guarantee stands on.

⚠ **A MUTATION WENT UNREACHABLE AND THAT IS WORTH THE NOTE:** `K3` converted a nil stage to 1,
which after A12.2b made the stageless beacon a SECOND ANCHOR beside `b1` — so the duplicate
refusal fired first and K3 stopped grading what it names. ★ **A new guard can make an old
mutation unreachable**, and that is a thing to look for rather than a surprise. Retargeted to 2.

Mutation **28/28** on bucket after the four new rows.

### E2 · FOUR `b.stage or 0` READ SITES SURVIVE THE FIX `rule.lua:48` HEADSTONES

    routes.lua:379 · :1805 · :1853 · :1862

Most load-bearing is `Routes.BeaconAt` (`:1862`): `if (b.stage or 0) >= (index or 0) then return b end`
— **a stageless beacon reads as stage 0 and is returned as the beacon at index 0**, which is the same
*"a node not in the sequence acts as though it is"* shape A2.10a exists to refuse.
⚠ HIGH on the pattern, **LOW on reachability today** — no product-side ratchet consumer exists.

### E3 · A COMMENT THAT POINTS THE NEXT READER AT THE WRONG FILE

`routes.lua:1512-1513` says the band default *"lands as an `or` on this line and it will be the ONLY
place it lives"*. ★ It landed at **`bucket.lua:198`**. All three of its clauses are stale — the band
IS ruled, it is NOT `±`, and it is not on that line. **The first sentence (`ReachOf` returns raw nil)
is still correct and should survive the edit.**

### ⚠⚠ E4 · MEASURED 2026-08-21 — **NO REAL AUTHORED ROUTE BUILDS TODAY**

`py addons/tools/inspect_route.py bucket`, run against the RFC scrape (a real dungeon run, not a
fixture):

    ROUTE Test-15   map 33   beacons 3
    Bucket.Build on the REAL store shape (smokes use a stub Routes):
      REFUSED: child 1 of beacon 1 has no radius

★ **THE REFUSAL IS CORRECT AND IS THE DESIGN WORKING** — loud, named, and exactly what
`bucket.lua:179-181` is for. `Routes.ReachOf` returns raw nil when the author set nothing (RI-2)
and the bucket refuses rather than inventing a value.

⟶ **But it means every route in the corpus refuses at build**, because reach was never authored.
⚠⚠ And it joins the doc correction made the same day: `driver_programmatic_model.md:426` promised
*"the default radii apply when the author sets nothing"* — **there is no radius default at all**,
only a band default (`bucket.lua:198`). The doc promised a fallback the code deliberately lacks,
and the corpus proves the refusal fires on real data.

✅★ **ANSWERED THE SAME DAY (Battlewrath, 2026-08-21):** *"We're testing there ahead of what can be
authored. So there's a grade on authoring. A default 5 yards R is expected. Enforced at the picker.
We can have that the standing R."*
⟶ **THE REFUSAL IS A GRADE ON AUTHORING, NOT A DEFECT.** The corpus predates the picker; the
picker defaults R to 5 and floors there, and the bucket goes on refusing nil — which after the
picker ships can only mean pre-picker data. ★ Landed as **A10.3e-R**, with the reason: `R_min =
v_ceiling × POLL_MIN / 2 = 5`, so R, the poll floor and the travel ceiling are one relationship.
⚠ No bucket-side default for R, deliberately — a tolerance has a safe default, a SIZE does not.

    ~~THE QUESTION THIS RAISED, now closed:~~
      does reach get a DEFAULT (like the band's 2.5), or does the PICKER make it unskippable
      (A10.3e), or do existing routes simply refuse until re-authored?
    ★ All three are defensible; the pickers make the third harmless. **Named, not answered.**

### ⚠ E5 · THE STATIC SHAPE VIEW CONFLATES THE ROUTE WITH THE RUN

`emit_store_inventory.py --shapes` reports **16 fields** on `r`; the live store's route carries
**7**. The extra nine (`arrival bosses closedAt comment instance legs markers outside testPinSet`)
are the RUN's — the analyser groups by VARIABLE NAME and `r` names both.
★ The tool documents that limit already (*"a receiver is a variable name, not a type"*); what is
new is the SIZE of it, and that the conflation is exactly the RUN vs ACTIVE ROUTE distinction AL-1
ruled as a term. ⟶ Use `inspect_route.py shape` when the question is *what shape is this really*.

    IMPACT
      E4   nothing breaks — no consumer calls Build on a stored route yet. ★ Cheap to settle now,
           and it is the first thing a live test drive would hit.
      E5   documentation only; the two tools now say the same thing from opposite directions.
      E1   a plausible-looking `od` is already being written wherever a z is absent. Nothing
           downstream consumes `od` yet, so this is cheap now and a corrupt corpus later.
      E2   none today; it is a trap for the ratchet consumer when one lands.
      E3   documentation only — but it is the kind that sends someone to the wrong file.

---

## RI-42 · THE ROUTE MANAGER — the runtime tier has an owner; the bench shapes it

_Filed 2026-08-21 by the **Design architect (Fable)**. ⚠ This is an INSTRUCTION handed down, not a
question: Battlewrath accepted the architect's proposal the same day ("Yes. That matches."). Nothing
to drain; the item leaves when `driver_data_model.md`'s runtime tier (§A6) carries it._

**What was settled** — `driver_architecture.md` §4b (the order of effects) and §3b (the new part):

    THE ROUTE MANAGER is the ONE stateful owner of an ACTIVE ROUTE: the offer for this map and the one
    selection · current stage · current step · the completion LEDGER · firing Next · the bucket swap ·
    the three tracker writes (entry lure · supertrack tab · the park) · arming/disarming listeners ·
    the stage line · the terminal state · the one saved slot (selected RID, never progress).
    It never polls, never evaluates geometry, never interprets on the hot path, never mutates the
    armed list mid-poll, never holds two active routes.
    THE SENSOR keeps the in-set AND the previous in-set and returns changed nodes by address WITH
    the transition word (When on · Seen · When off), after the poll.
    THE INSTRUCTION SET is the manager's TICK LIST — built at BUILD from the records (function + arg
    ID ride the BEHAVIOUR record, once per tab; every record opens with the gate), never exported.
    Terms: a RUN is the Run side's capture; an ACTIVE ROUTE is the Routes side's live route.
    "Pre-load" is RETIRED: ingest → bucket → arm.

**What this closes for the bench** (no longer open): RI-38 (the designator is the manager) · the
raiser (the ledger firing Next) · the ledger's owner (the manager — "the sensor's" is superseded) ·
re-arm (= the bucket swap) · throttle ownership (the sensor's) · G18 (the previous in-set).

### ✅ THE SENSOR'S CONTRACT — SHAPED AND BUILT §452 (Addons bench)

**A11.3e · A11.3c · A11.3b, all three, and G18 with them.** `Poll` returns the nodes whose
verdict CHANGED, BY ADDRESS, each with its transition word; the sensor is RESETTABLE and its
state READABLE. Mutation 21/21.

    inSet    who is inside NOW           the verdict this poll
    wasIn    who was inside LAST poll    differencing gives whenOn / whenOff
    everIn   who has EVER been inside    `seen`, which is a HISTORY not a transition

⚠⚠ **WHAT WAS ACTUALLY BROKEN:** `Poll` did `armed.inSet[n] = hit or nil` **in place**, so
the previous verdict never survived and **the transition was destroyed every poll**. Two of the
three floor words were not computable from anything the sensor held. ★ And `snapshot()` dropped
`rows`, so a report had no tabs to attach a word to — A11.3e names both as one build step, and
they were.

### ★★ ONE SHAPE DECISION, MARKED AS THE BENCH'S — how `seen` is emitted

RI-42 puts *"the sensor's contract … the transition word"* in the bench's column, so this is
shape rather than a reading of a row:

> **A node entering for the FIRST time is reported twice — `whenOn` AND `seen`.**

★ Why: A11.3e says *"with the transition word"* (singular) and A12.4a has the manager run
*"only the tabs whose sense-word MATCHES"*. ⟶ **For a `seen` tab to ever run, the word must be
emitted** — and `seen` is not a re-wording of `whenOn`, it is a different fact that happens to
become true at the same instant. ⚠ It satisfies both rows' tests unchanged: a node entered then
left still reports When on ONCE and When off ONCE, and `seen` is neither of those.
⚠ `seen` fires ONCE and never again — *has been in at least once* survives leaving and coming
back, so a re-entry is `whenOn` and nothing more. That row is graded.

⟶ **Cheap to push back on:** if design wants one word per change plus a `first` flag instead,
it is a two-line change and the tests move with it.

### ⚠ AND A MUTATION SET NEEDED FOUR REPAIRS, three of which are the same lesson

`if not armed then return nil end` now appears THREE times (`Poll`, `Reset`, `State`), so an
anchor that once matched one line matched several — **caught as an ANCHOR MISS because the set
counts occurrences rather than replacing the first.** ★ That count is the only reason it was a
miss and not a silent wrong target. And `M12`'s expectation named a frame COUNT that moved the
moment the new block armed the sensor again; it grades the sentence now, not the number.

⚠⚠ **FOURTH HEREDOC CASUALTY TODAY.** Two of those repairs were mangled by `py - <<'EOF'`
eating a `\n` inside a Python string. The standing rule — *author in a FILE, never in the
shell* — has no "unless it is small" clause, and the small ones are exactly where it keeps
happening.

### ✅ THE MANAGER DOES NOT WRITE TO THE SENSOR — recorded §453, with the ratio measured

> ★★★ **THE PRINCIPLE, in his words (2026-08-21): *"The manager swaps out the SELECTION
> rather than telling the sensor what to bounce."***
>
> ★★★ **AND ITS OTHER HALF, same day: *"We expressed the park behaviour. The sensor is
> BLIND to what it's reading. So it lives with the manager."***

⟶ **ONE LEVER, ONE DIRECTION.** The manager writes a LIST; it never writes a RULE. And it
generalises past completion — a stage advance, a step advance, a node completing, a narrowing
for cost are all **the same act**: hand over a different selection. ★ That is why there is no
second mechanism to design: `Designate` already IS the channel, and everything the manager
might want to say to the sensor is sayable as *"here is what to watch now"*.

### ★★ THE TWO HALVES ARE ONE LAW, and stating both is what makes it usable

    IN     the manager writes a LIST, never a RULE          — nothing to bounce, only a selection
    OUT    the sensor reports an ADDRESS, never a MEANING   — nothing to interpret, only a change

⟶ **The sensor cannot know that an address is a park, a lure, a recovery beacon or a boss.**
Each of those is a MEANING, and `A12.1a` already puts all three tracker writes - entry lure,
supertrack tab, the park - with the manager. ★ A sensor able to point the arrow would first
have to learn what it was looking at, **and that is the moment it stops being blind.**

⚠⚠ **AND THIS CORRECTS A ROW OF THE BENCH'S OWN.** `driver_sensor_brief` G8 read
*"A11.9's supertracker escapement IS NOT WIRED to the sensor"* — framing the park as a gap
the SENSOR owed. It never was: `A12.3c` writes the lure on arming (*"tray-0 items never write
the arrow"*) and `A12.8a` writes the park at terminal. ★ The geometry was built in §414 and the
wiring was always the manager's; the brief had it filed under the wrong owner. Corrected §456,
and the fence line with it.

✅ **BOTH HALVES ARE NOW ENFORCED, not agreed.** `smoke_sensor` asserts there is no
`Bounce`/`Exclude`/`Drop`/`Complete`/`Ledger`/`SetComplete` door **and** no
`Park`/`SuperTrack`/`Lure`/`Track` write, with a mutation each. Sensor mutations 23/23.

⚠ **And the sensor never learns WHY.** It holds the in-set, the previous in-set and the
history — nothing about stages, steps, ledgers or completion. A sensor that knew the reason
would be holding a second copy of the manager's state, which is the fault named oftener than
any other here.

**His question (2026-08-21):** *"Does the manager need a way to write to sensor on what to
bounce based on completion? IE. Seen. And also completion."* · *"In a bucket, 10 steps, so that
1/10 or 1/10 + step 0 continue to be evaluated. Did step N's make it into the rows?"*

**✅ ANSWER: NO WRITE IS NEEDED, and the numbers say why more plainly than the argument does.**
`addons/tools/smoke/probe_steps.lua` (new, §453; a PROBE, outside the `smoke_*` glob):

    BUILT      11 nodes in bucket 1 · steps 0-10 ALL PRESENT · 21 behaviour rows carried
    EVALUATED  2 nodes, 3 rows per step — the pass-through + step N

⟶ **Yes, every step's rows made it in.** Built once, carried whole, and the gate hands out
**2 of 11**. ★ **The nine idle steps are never ARMED**, so there is nothing for the manager to
tell the sensor to bounce — the sensor has never heard of them. The filter is the hand-out, and
it already happened.

### THE THREE MECHANISMS THAT COVER IT, none of which is a write

    `seen`               SELF-LIMITING. `everIn` fires it once and never again (§452, graded).
                         Nothing needs telling.
    a completed STEP     LEAVES AT THE ADVANCE. The step gate bounces it - the same
                         `0-or-exact` rule. The sensor need not know WHY the hand-out changed.
    re-firing after      **`Trigger`'s question, and RI-27 already holds it on two axes:**
    completion           *retry while incomplete* is the DEFAULT and not a control
                         (*"the ratchet tells the instruction to stop listening"*); *run again
                         after complete* is TRIGGER, default NO, opted into per node.
                         ⚠ NOT BUILT, no code term chosen - reserved as the bench's.

### ⚠⚠ AND A WRITE WOULD PUT COMPLETION IN TWO PLACES

`A12.1a` makes the LEDGER the manager's, and RI-42 says *"the sensor's is superseded"* in those
words. ★ A sensor that knew what was complete would hold a second copy that can disagree — the
fault this project names oftener than any other. ⚠ `A12.1b` also forbids mutating the armed list
mid-poll, so such a write would have to be sequenced AFTER a poll — **which is exactly what the
bucket swap already is.** The channel exists; it is called `Designate`.

★ **The one real adjacency points the other way.** `A12.4c`: *"listeners disarm on `When off`"*
— the manager disarming ITS OWN listeners on the sensor's report. Information flows
**sensor → manager**, and the manager acts on its own side of the line.

### ⚠ WHAT WOULD CHANGE THE ANSWER, named so it is not re-argued from feel

A `Trigger: One time` node that is complete keeps being EVALUATED while its step is current —
2 nodes, 3 rows, at a 0.1 s floor. **That is cost, not correctness**, and it is bounded by the
hand-out rather than by the route's size. ⟶ If it ever matters the honest lever is a NARROWER
HAND-OUT (the swap re-arming without the completed node), not a back-channel into the sensor:
the manager already owns what to hand out, so the same knowledge stays in one place.

### ⚠⚠ A HARNESS DEFECT FOUND WHILE ANSWERING THIS, and it is the worst kind

§453: `mutdriver` **left a mutation in the tree** - `push(bucket.stages[Bucket.ALWAYS])`
deleted - and the NEXT run copied that damaged file out as its own "original". ⟶ Every
mutation after that graded against a broken baseline, and two reported ANCHOR MISS for a line
that had been DELETED rather than moved.

★ **A backup taken from a broken file is not a backup.** The gate caught it (`mutdriver` FAIL,
`walk exit 1`) and `git checkout` restored it - but the failure mode is one where a green run
would have meant nothing at all.

    ✅ BASELINE PROVEN   every set now runs its smoke BEFORE mutating and REFUSES to start
                        if it is not green. A silent wrong baseline becomes a stop.
    ✅ RESTORE IN A      `mutdriver` restores in a `finally`. The per-mutation restore was
       `finally`        correct until something raised between the write and the restore.

⚠ Both guards are about the same thing: **a tool that repairs damage must not be able to
inherit it.**

**What is now the bench's to SHAPE** (build-shape, not rulings): the runtime tier's declaration
(bucket · items · armed snapshot · the manager's state) · the sensor's contract (arm/disarm/reset
take and return; the transition word) · the binder's shape (`Bucket.Resolve`) · `Driver.Designate`
becomes the manager's, called by the ledger · the one saved slot.
    ALSO (R8, same day): mirror into `contract.lua`'s comment — *"a stage is a beacon; a beacon with
    children becomes a stage with steps"*; Step = the child's position in its stage's sequence,
    restarting each stage; `bucket.lua`'s `step = c.ordinal` is derivable from it.
    ALSO (R10, same day) — THE READER'S SURFACE, for the Analyst to reconcile into A10.5 / A11.5 / A11.9:
    · the reader has ONE FIXED DISPLAY — stage / step · the note; the manager EMITS, NEVER IN CHAT;
      NO diagnostics in-flight (hit / first-hit is the author's TEST DRIVE readout, A10.5, not the reader's)
    · RECOVERY NEVER USES THE SUPERTRACKER — tray-0 items never write the arrow; the entry lure is the
      stage slot's; a re-run = leave and re-enter the dungeon
    · the NAMES table ships and the READOUT VIEW resolves names at display time (driver never opens it)
    · the Receive box (multi-line + Read) lives on the reader's remote; an in-game SYNC channel (join
      when sharing / on "in instance"; opt-in "Sync with tank") is NAMED for later, not built
    · THE READER HAS TWO PANES (moment 4): a NOTE PANE (stage / step · note — information and direction;
      all that shows when things go well) and the REMOTE (select · Arm ↔ Stop · correct-when-lost,
      COLLAPSIBLE to a media-player-like corrector). Steering never owns the reader's UI. → A10.5's
      reader-side counterpart when the Analyst writes it
    ALSO (F1 → AL-10, 2026-08-21): `Contract.BEHAVIOUR` is UNCHANGED (address only; no stage/step);
      the bucket composes the gate per row from the characteristic record; the Analyst writes the
      DEMONSTRATION rows — lookalike routes on one map never mix by address · composed gate == the
      node's prefix · an orphan address is refused at build, named. "The instruction set is the
      MANIFEST" (Battlewrath). The architect runs the WA / profile-addon prior-art check.
    ALSO (AL-15/16, 2026-08-21) — TWO MEASURED PRIOR-ART FILES for the UI leg, `audit/prior_art_worldmap_*` and
      `audit/prior_art_ace_field_*`, and three build facts from them: (1) our widget set LACKS `ScrollFrame`
      (AceConfigDialog's root and every tall pane need it — A10.1b's list grows by one); (2) the live AceGUI
      will be 41 (AI_VoiceOver serves it, unrenamed) — r960 is the FLOOR; A10.1b's "measured" reads as
      "measured on the floor", and the harness should also run under 41; (3) RULED by Battlewrath
      (2026-08-21): adopt AceDB for UI state (fold · selection · dock · geometry) — the client-wide
      convention; namespaces per the census (selection → profile · fold → char · geometry → profile ·
      dock → global, per AL-13). A10.1b's shipped set gains AceDB-3.0 (+ AceConfig-3.0 for parity with
      every other embedder); the Analyst writes the row.
      The bench's dock/undock build should cite LibellusLeti's detach/embed pair and the client's
      WorldMapFrame proxy-anchor trick rather than invent from nothing.
    ALSO (AI-5 → AL-17, 2026-08-21) — THE POSED TAB IS DEFINED in architecture §4b: `{address · gate ·
      sense · fn · arg}`. For the bench: `Bucket.Build` REFUSES a node with no rows (by name) and an arg not
      of its declared type (reading ROW_ARG); `known()` consults the closed list BEFORE any resolver;
      the store hook MIGRATES flat `sense/action/boss` → rows once, told — never converted at build;
      defaults materialise as rows at authoring. For the Analyst: A12 rows for the tab's fields and the
      three refusals; RI-49's `Next` is a build question (the store's `role`+`setStage` → `Next(Type,arg)`).
    ALSO (AI-6 → AL-18) — THE SEED: placing a node materialises one row `whenOn` with NO action (= reached);
      a row's action is OPTIONAL and the arg guard runs only when one is present; NO fourth sense-word; an
      added row starts unset ("Select a sense type") and is incomplete, told. Bench: both doors accept a
      nil action; re-seat the `routes.lua:1308` comment to the list it annotates.
    ALSO (AI-8 → AL-19, Battlewrath's word) — `supertrack` LEAVES ROW_ACTIONS (now boss · note · say · open);
      the characteristic record gains LED TO (tick, default on; tray-0 nodes unticked, choice hidden); the
      manager reads it when writing the entry lure; §471's migration converts a stored supertrack row into
      the tick. DR_Content_17 is the general rule: a capability sits in the layer where it has meaning.

    IMPACT
      on disk now      driver.lua (state → the manager) · sensor.lua (previous in-set; transition
                       word) · bucket.lua (binding at build) · store.lua (one selected-RID slot) ·
                       driver_data_model.md §A6 (mirror §4b; E1/E2 owners named) · driver_sensor_brief
      shipped guards   none break; smoke_driver's "nothing calls Designate" assert RETIRES when the
                       ledger calls it
      criteria         A11.3 (the ledger's owner) · A11.9 (who writes the tracker) · a new A-row set
                       for the manager when the Analyst writes it
      does nothing to  the record kinds · the rule · the UI leg · the author side

---

---

## ⟶ DRAINED ITEMS LIVE IN `history/`, NOT HERE (2026-08-22)

**28 settled items** — 73% of this file — moved to
`history/Reconcile_inbox_drained_2026-08-22.md`, verbatim.
⟶ **Their conclusions are in `ANALYST_LOG.md`, one row each**, which is what a reader should use.
The archive is the reasoning; git is the history. ★ This file is now what it says it is: the OPEN
conversation between the bench and the Analyst.
