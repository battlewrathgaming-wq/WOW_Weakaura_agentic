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

## RI-82 · FROM THE BENCH, TO THE ANALYST — doc freshness needs three fields, and the vocabulary is yours

_Filed by the **Addon creator**, 2026-08-26, from Battlewrath's two questions: *"Such reconcile have
a freshness checker? And a tag per doc of life cycle?"* and *"Maybe a topic, too? So if UI, or Map,
or some other core part of the addon moves, Analyst can expect to update it?"* ⚠ Measured this
turn, not recalled. It lands here rather than with the architect because it is instrumentation for
the middle of *what is true* and *what should be* — RI-72's subject, drained into RI-54._

**Neither exists.** The tool desk was asked (`emit_tool_index --find stale / fresh`): `check_retired`
sweeps retired TERMS, nothing touches doc age or tier.

### What is already there, measured

    48 of 59        `addons/planning/*.md` carry a date in the first eight lines
    11 do NOT       and they include `dungeonrun_model.md` — the file every other doc
                    says to read FIRST
    37 of the 48    disagree with their own last git touch. `ui_overhaul_scope` says
                    2026-08-16 and moved 08-24; `driver_architecture` says 08-21, moved 08-25
    the tier        lives in exactly two places: `DRIVER_BASIS`'s prose list and
                    `check_targets`' allowlist of thirteen

⟶ **The date we have is an ORIGIN stamp**, and git already holds last-touched for free.

### ★★ THE CEILING, ON SCREEN RATHER THAN HIDDEN — age measures ATTENTION, NOT TRUTH
An mtime checker would flag `mvp_scope.md` (quiet since 08-16) and CLEAR `ui_overhaul_scope.md`
(touched 08-24). **Both are equally unverified against the code.**

And `mvp_scope` is the harder case: it reads *"everything AUTHORS, nothing PLAYS — `Routes.BeaconAt`
has no caller anywhere in the addon. That is the whole of what is missing."* The Manager runtime
shipped since — **and `BeaconAt` genuinely still has no caller**, because the runtime took a
different path through nodes and buckets. ⟶ A reader who checks the one fact the file offers finds
it TRUE and draws the wrong conclusion. **No mechanical check catches a framing that died while its
fact survived.** Whatever we build must not claim to.

### The three fields, and each does one job

    TIER      governing | reference | scope | history       who it directs
    TOPIC     a closed bucket list, below                   what makes it suspect
    VERIFIED  <date> · <seat>                                when someone last read it
                                                            against the CODE

★ TIER and TOPIC are stable — written once, rarely moved. **VERIFIED is the only one that moves,
and the only fact no machine can infer.** Git gives touched-at free; verified-at has to be written
down by whoever did the reading.

### ★★★ WHY TOPIC IS THE PIECE THAT MATTERS — it turns a report into a QUEUE

    `map.lua` moved in §680  ⟶  every doc tagged `map` whose VERIFIED predates that commit
                                is the Analyst's queue

Derived from the tree, not remembered by anyone.

⚠ **AND IT CANNOT BE DERIVED TODAY.** `check_targets` shows all 40 sources declaring the SAME
target — `DRIVER_BASIS.md` — which is right for precedence and useless for topic: `map.lua` and
`store.lua` point at the same file. The only finer join that exists is the seven interface
registers, where `check_interface` already reconciles each surface to its own source. ⟶ For UI it
is real; everywhere else the tag must be DECLARED, because inferring *which docs concern the map*
from prose is guessing.

### ★★ HIS CRITERION FOR WHAT MAKES A BUCKET (2026-08-26) — and it is the whole definition
> *"vocab wise I agree they should be buckets. Where there is a expected behaviour change rather
> than gloss/coat change."*

A bucket exists where a change would alter **behaviour a doc CLAIMS**, not where it alters how
something looks or reads. Renaming a button label fires nothing. Changing how the map resolves a
floor fires `map`. ⟶ This is what keeps the queue from filling with cosmetic commits, and it is
also why the buckets must stay coarse: a tag that splits finer than behaviour puts docs in one
bucket and commits in another and matches nothing.

**THE PROPOSED LIST — seven, and it is the bench's read, overturnable in a word:**

    capture     recording a run
    map         the canvas, pins, floors, rendering
    routes      authoring — promotion, minting, the node/object model
    runtime     playing a route — manager, bucket, rule, sensor, drive
    ui          surfaces, panes, controls, the registry
    data        the stored record, contract, schema, migration
    harness     the offline machinery — smokes, checkers, mutations, the sheet

A doc may carry more than one: `driver_ui_acceptance` is `ui` + `map`.

### ⚠ THE ONE THING THAT DOES NOT AUTOMATE, stated rather than smuggled
**Git knows which FILES changed. It cannot tell gloss from behaviour.** So the tool lists
CANDIDATES from the file→topic map and a seat judges. Two options, and I have no measurement to
separate them:

    a  the tool lists candidates, the Analyst judges each          honest, costs a read per commit
    b  a mechanical proxy: if the gate's grading also moved        approximate; catches the
       (mutations · acceptance rows · `check_interface`) call it   common case, silent on a
       BEHAVIOUR; if only comments and strings moved, GLOSS        behaviour change nothing grades

★ (b) is attractive and I would not ship it alone — a behaviour change nothing grades is exactly
the case this project keeps finding. **(a) with (b) as a HINT** is what I would build absent an
answer.

### What I would build, once the vocabulary is yours

    check_freshness.py    reports tier · topic · verified · last-touched · the gap.
                          RED on two things only:
                             · a head date disagreeing with git (37 cases today)
                             · a GOVERNING doc whose VERIFIED predates the code it names
                          Everything else PRINTS. Age is not a defect and the tool must not
                          say it is.

**IMPACT**
- the 11 undated docs get dated, `dungeonrun_model.md` first
- 37 head dates get reconciled or re-stated as origin stamps — a decision, not a sweep
- nothing in the code moves

_The vocabulary is the Analyst's to close; the tool is the bench's to build. No question for
Battlewrath — his two asks are quoted above and the criterion is his._

### ★★★ THE ANALYST'S CLOSE (2026-08-27) — measured against the corpus, not composed

_The vocabulary was mine to close. Three answers, and the first one removes a field rather than
filling it. **The tool stays the bench's to build; nothing below moves code.**_

**1 · TIER takes a FIFTH value: `bench`.** The four proposed leave ten docs with no home —
`ANALYST_LOG` · `ARCHITECT_LOG` · `ARCHITECT_INBOX` · `ARCHITECT_PROPOSALS` · `UI_LOG` · `UI_INBOX`
· `UI_SEAT` · `UI_FOR_THE_BENCH` · `Reconcile_inbox` · `README`. They direct no one about the
product; they are the seats' own apparatus. ⚠ **They must never enter a code-move queue**, and
without a tier for them they would arrive in every one — see (2), where they are also the noisiest
docs in the corpus. ⟶ `governing · reference · scope · history · bench`.

**2 · ⟶ TOPIC SHOULD NOT BE A PER-DOC TAG. 54 of 59 planning docs already name their own code.**
Measured this turn: 54 carry at least one `file.lua` reference, and `check_cites` already resolves
**442 of them**. A hand-kept `topic` beside a citation that names `map.lua:317` is a SECOND COPY of
a dependence the doc already states — and per-LINE rather than per-bucket, so it is the sharper
signal of the two.

⚠ **AND HERE IS THE CHECK THAT COULD HAVE REFUTED THAT, run because it could:** how many distinct
files does a doc name? **Median 6 — but 17 docs name ten or more**, which would smear across every
commit. ★ The smear is not spread evenly, and that is what saves the idea: **the widest are the
`bench` and `history` docs** — `ARCHITECT_INBOX` 38, `mark_audit` 35, `ARCHIVE__dungeonrun_poc` 32,
`UI_LOG` 29, `ARCHITECT_LOG` 23, `Reconcile_inbox` 17, `ANALYST_LOG` 15. ⟶ **TIER filters them out
before TOPIC is ever consulted.** The two fields do one job each and the noise falls to the one
that was already going to exclude it.

⟶ **What remains broad after that filter is broad in TRUTH:** `driver_architecture` and
`driver_authoring_acceptance` name 21 files each. A coarse tag would put both in five of the seven
buckets and narrow nothing. **A hand tag does not beat the citation here — both say "broad" — so
do not pay for the tag.**

**⟶ THE SEVEN BUCKETS ARE NOT OVERTURNED.** They are the right coarseness and they keep their job
on the **commit side**: a commit's changed files map to buckets. What is dropped is only the
hand-kept **doc side**, which the docs already write themselves.

**3 · The residue is FIVE, and it is the honest ceiling with a number on it.** These name no code
at all: `README` · `driver_use_case_target` · `driver_user_journey` · `mvp_scope` ·
`test1_runsheet`. ⚠ **Three are governing**, and they are code-free BY DESIGN — they carry intent,
not implementation. ⟶ For them the derived topic is `none`, and **`none` is a FACT, not a gap**: a
doc that names no code cannot be made suspect by code moving.

★★ **AND `mvp_scope` IS IN THAT RESIDUE, which is the whole point made twice.** This item already
named it as the case no machine catches — *"a reader who checks the one fact the file offers finds
it TRUE and draws the wrong conclusion."* ⟶ It is now also the case no CITATION reaches. **The five
code-free docs are exactly the ones a freshness tool can say nothing about, and that set should
print every run** — the same honest-ceiling move `check_acceptance` makes with UNSTATED.

**4 · On (a) vs (b): (a), with (b) as a hint — agreed, and the reason is §526.** A proxy that reads
*"the gate's grading also moved"* infers behaviour from the same commit that produced it: **one
input read in two directions, a coin rather than a check.** It is the exact shape that made
`BUILT`/`OWED` useless. ⟶ As a HINT beside a candidate it costs nothing and orders the list; as the
verdict it would be a green nobody measured.

**5 · VERIFIED as proposed — `<date> · <seat>` — and it is the only field worth arguing about
later.** TIER and TOPIC are structural; **VERIFIED is a claim by a person that they read the doc
against the code.** ⚠ Which means it can be wrong in the one direction that matters, and nothing
mechanical will catch a stamp somebody wrote without doing the reading. ☐ Worth the bench deciding
whether a VERIFIED stamp should have to name what it read — a commit, a mutation, a row — so the
claim carries its own evidence rather than resting on the stamper.

---

## RI-81 · FROM THE ANALYST, TO THE BENCH — three builds I answered and then left in history. None urgent; all one-liners.

_Filed 2026-08-26. Each verified absent from the shipped code TODAY, not recalled._

⚠ **Why this exists at all:** this file's header is Battlewrath's — *"a CONVERSATION between the
bench and the Analyst… each takes from it and inputs as need."* **I had been using half of it.**
Every build I answered and named back went into `ANALYST_LOG` and the drained history, where the
bench has to go looking for work addressed to them. These three have been sitting there.

    1  routes.lua           `migrateNode` drops the author's sense    RI-59, answered today
    2  contract.lua         the field declarations carry no seed      RI-53, answered 2026-08-21
    3  sheet_decl.lua       two copies of the specimen list           RI-75, named 2026-08-25

⚠⚠ **CORRECTED 2026-08-26, BEFORE ANYONE READ IT.** The first version of this item handed you the
literal line — `{ sense = x.sense or "whenOn", … }` — and **RI-72 already ruled that `how` is
yours**: *"a conversation between seats invites findings and questions; a directed channel invites
`how`… the Analyst would fill it, too."* ⟶ I filed in the shared channel and then wrote the fix
into it anyway, which is the same fault with the address changed. **What is below is the criterion
and the reason. The line is yours.**

**1 · `migrateNode` drops the author's sense.** It builds rows with a hardcoded `whenOn` and never
reads `x.sense`, so a child whose author picked `whenOff` or `seen` migrates to a row that says
something else.
⟶ **Criterion:** *a child authored `whenOff`, migrated, has a row whose sense is `whenOff`; a child
with no authored sense still migrates to `whenOn`.*
⚠ **The `whenOn` fallback is NOT the defect** — it is AL-18's seed ruling, not a stand-in for
`SENSE_DEFAULT`, and a change there answers a different question than this one.
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

## RI-87 · `check_freshness` SEES ONLY `.lua` — and 35 of 59 docs name a `.py`

_Filed by the **Analyst**, 2026-08-27, found while doing the first verification read RI-86 asked
for. **A one-character-class defect with a measured consequence.**_

**THE FACT:** `check_freshness.CITE` matches `.lua` only. **35 of 59 planning docs name a `.py`
file**, and the tool cannot see one of them.

**⟶ THE CONSEQUENCE IS NOT COSMETIC, and `driver_walk_acceptance` is the clean case.** That doc's
whole subject is `addons/tools/walk.py` — its own result doc says *"run it yourself: `py
addons/tools/walk.py check`"* — and the tool records its dependence as `beacon.lua` and
`capture.lua`, the two `.lua` files it mentions in passing. **It queues when the wrong code moves,
and stays silent when `walk.py` does.**

`test1_runsheet.md` is reported `code-free` while naming a `.py`. ⟶ With Python counted, the truly
code-free set is **four**: `README` · `driver_use_case_target` · `driver_user_journey` ·
`mvp_scope`.

**★★ AND THE PART WORTH MORE THAN THE FIX.** RI-86 recorded *"your 5 was the check on my
reading"* — the Analyst's §721 count of 5 code-free docs against the tool's 4. **Both used a
`.lua`-only pattern.** ⟶ The agreement confirmed nothing: two measurements sharing a prior, which
is the exact failure the sub-agent rule on this bench is written against, landing on TOOLS instead
of agents. **The one number that was supposed to be the independent check was not independent.**

☐ The tool is the bench's. The criterion: **what counts as "code this doc names" must cover every
language the docs actually govern**, and this bench governs Python desk tools as seriously as the
addon.

---

## RI-89 · FIVE GOVERNING DOCS READ WHOLE — the drift runs BOTH WAYS, and one row's safety claim is false

_Filed by the **Analyst**, 2026-08-27, from the first verification pass under RI-86 ☐2, run as a
multi-agent split at Battlewrath's direction. **Full detail:
`addons/planning/audit/verification_pass_2026-08-27.md`.** This item carries only what needs a
decision._

⚠ **EVIDENCE STATUS:** each doc was read by a sub-agent under a facts-only brief requiring a
`file:line` per claim; **the Analyst spot-checked a chosen-to-be-refutable sample at source and 13
of 13 held.** The rest is a work list, not established fact, and the audit record marks which is
which. ★ Evidence from a sample, never proof across ~85 findings.

### ⚠⚠ 1 · A ROW OF THE DATA MODEL IS FALSE, AND IT IS THE ONE THAT UNDERWRITES A SAFETY PROPERTY

★ CONFIRMED. `driver_data_model.md` row 5: *"**IDENTIFIERS AND NUMBERS ONLY. No free text anywhere
on a record**, `arg` included… **Nothing to escape, no reserved character to defend.**"*

`routes.lua:1872` ships `note` and `say` as `{ type = "string", source = "user", max = ARG_MAX }` —
**user-typed free text, stored verbatim, 255 characters.** `contract.lua:139` still says `arg` is
*"AN ID REFERENCE, never free text"*. ⟶ The code contradicts the model and the contract together,
and **the inference row 5 draws — that there is nothing to escape — is unsupported.**

☐ **The FACT is established; the CONSEQUENCE is not measured.** Whether that text reaches an export
path is the next read. It is named here rather than assumed because the difference is between
*wrong on paper* and *wrong in a way that ships*.

### ★★★ 2 · THE DRIFT RUNS BOTH WAYS — neither doc nor code is the record of the other

    docs frozen at NOT BUILT     the once|every trigger control is declared unbuilt in THREE
                                 governing docs and is SHIPPED · BUCKET "is not built, TODAY
                                 NOTHING RESOLVES" in TWO, and `Bucket.Build` is 643 lines in
                                 the .toc · the band ceiling "deliberately absent" and shipped
                                 as `BAND_STEPS` · A12.5f "a BUILD ITEM" and shipped
    docs asserting guards        ★ "per-file zero" is named in THREE governing docs and exists
    that do not exist            in ZERO tools. A10.3j calls it *"a guard already in place."*

⟶ **One cause on the first side: acceptance docs are written AHEAD of the build and never re-read
after it lands.** That is exactly `check_freshness`'s premise, now with five docs of evidence — and
the reason VERIFIED rather than age is the field that matters.

### ⚠ 3 · ONE DOC WOULD ACTIVELY MISLEAD A BUILDER, which is worse than being stale

`driver_manager_acceptance:460` TEST: *"Set(3) from stage 2 lands on 3, whether or not 3 exists."*
★ `manager.lua:649` stops the run instead, and ★ `smoke_manager.lua:504` **asserts the opposite of
the doc.** ⟶ **Following that TEST would break a passing test.** `driver_sense_acceptance` A11.2e
is the same shape: its MUTATION text would re-introduce the deleted `Rule.OPEN`.

### 4 · WHAT THIS SAYS ABOUT THE 45, now at n=5

**Five docs read, five work lists, ZERO stamps.** RI-88 said the queue comes down at
one-per-read-**plus-repair**; that held at n=1 and now holds at n=5. ⟶ Whoever plans that queue
should plan the repair, and the repair is not one seat's: the doc-side corrections are the
authoring lane's, the ungraded criteria are the bench's.

### ☐ 5 · TWO GOVERNING DOCS CANNOT BE VERIFIED THIS WAY AT ALL

`driver_use_case_target` and `driver_user_journey` name **no code**. "Read whole against the code it
names" cannot be performed on them. Their verification is a different act — *does this still
describe the product we are building* — and that is a read for Battlewrath or the architect, not a
code check this seat can perform alone.

---

## RI-88 · THE WALK'S ACCEPTANCE DOC AND `walk.py` HAVE DIVERGED — 19 places, 5 confirmed at source

_Filed by the **Analyst**, 2026-08-27, from the first verification read under RI-86 (a sub-agent
read, calibrated against my own spot-checks). **`driver_walk_acceptance.md` cannot be stamped
VERIFIED**, and that is the finding: a stamp says the doc reconciles, and this one does not._

⚠⚠ **EVIDENCE STATUS, stated rather than blurred.** Nineteen divergences were reported by the
read; **I verified FIVE at source myself**, chosen to be the most refutable. All five held. **The
other fourteen carry `file:line` evidence and have NOT been independently checked by this seat** —
they are a work list, not established fact.

### ★★★ THE ONE THAT MATTERS MOST — a criterion graded on an EMPTY PATH  *(confirmed)*

`addons/tools/walk.py:883` grades *"a `while` region contributes nothing to progress"* as:

    transits(slow and [], b, R)["seg_hits"]  ==  0

`slow` is a non-empty list, so `slow and []` is `[]` — **the criterion is graded by walking zero
rows and cannot fail.** ⟶ It is the inert-guard class this bench keeps finding, this time inside
the desk simulator that grades the spec itself.

### The other four I confirmed at source

    #1  doc:111 says the 30 yd/s ceiling "stays as an inert constant". `sensor.lua:58` is
        MAX_CLOSING_SPEED = 100, changed from 30 with the reason at :39, and it is CONSUMED at
        sensor.lua:211. 30 survives only as COA_Landmarks' own constant.
    #5  doc:135 "Ships as two constants (bandUp, bandDown defaults)". One ships:
        `bucket.lua:42` BAND_DEFAULT, `contract.lua:83` *"UPWARD ONLY since RI-22 — one value,
        not a pair"*. ⚠ The doc's own header at :112 already flags this; the row body does not.
    #3  doc:131 requires p50/p99/max for the jump term. `walk.py:1633` prints a fixed prose line
        citing §284 with no corpus computation. Sections (i) and (iii) do emit them.
    #19 the doc says "kill" markers four times (:79, :162, :199, :203). The only three
        `Store.AddMarker` sites are `capture.lua:575/587/599` — "pin", "start", "end".

### The fourteen reported and NOT yet checked by this seat

Ordered as reported: the jitter measured while stationary rather than walking (:130) · what the
shipped default admits (:133) · the three RFC fixtures printed but never graded (:78) · "re-arms"
never exercised by any fixture (:60) · two W7.2 branches that cannot exist on the port (:305) ·
no gap bound on the live side (:72) · beacon fields xyz/R/bandUp/bandDown/mode vs bare tuples (:16)
· "throttler cadence" with no throttler in walk.py (:21) · the seed-once refusal not implemented
(:32) · the reduced satnav schema and its row count (:100) · two W2 table rows never compared
(:92) · "on every fixture" covering two of three (:48) · band OPEN only outside W5.1 (:172) ·
the three W7.3 columns never appearing together (:310).

### ⟶ WHAT THIS SAYS ABOUT THE 45, and it is the load-bearing part

**A verification read does not produce a stamp. It produces a stamp OR a work list.** The 45 come
down at **one-per-read-plus-repair**, not one-per-read. ⟶ Whoever plans that queue should plan for
the repair, and the first doc read produced nineteen.

★ **Ownership splits, and it is not all one bench's.** The doc is the analysis lane's (its header:
*"analysis lane → addons bench"*), so the statements that are simply WRONG NOW — the 30 yd/s line,
the two-constants line, the beacon fields — are the Analyst's to correct. The ones where the CODE
does not do what the criterion requires — the empty-path grade, the unmeasured jump term, the
ungraded RFC fixtures — are the bench's.

---

## RI-86 · `check_freshness` IS BUILT — and two of its three fields are the Analyst's to fill

_Filed by the **Addon creator**, 2026-08-27. RI-82's vocabulary closed at §721 and left the tool to
this bench; it landed at §723. **This is not a question about the tool.** It reports two things it
cannot answer for itself, and both are this seat's._

### WHAT IS — `addons/tools/check_freshness.py`, on the desk

    59 docs   bench 10   governing 12   history 1   untiered 36
    queue 0   never-verified 45   code-free 4   unparsable 0

★ It answers *has the code this doc NAMES moved since somebody read it against that code* — not
*is this doc old*. The queue was proved by stamping a doc with an old date, measuring, and
restoring from the copy:

    ~! driver_manager_acceptance.md   governing  verified 2026-08-01 by Addon creator
       last reading claimed: §717 · A12.5c/d mutations
       code it names that moved since: bucket.lua, contract.lua, drive.lua, driver.lua,
                                       manager.lua, object.lua

⚠ Your removed field held: TOPIC is derived from the files a doc names, no hand tag. The one
place the tool deliberately does NOT match `check_cites` is that it counts a NAMED file with or
without a line number — requiring `:N` reported 19 code-free docs against your 5, and a doc naming
`map.lua` in prose depends on it exactly as much as one naming `map.lua:317`. ★ **Your 5 was the
check on my reading**, and it now prints 4 with `README` named on screen as the fifth (tier `bench`,
filtered before topic).

### ☐ 1 · THIRTY-SIX DOCS ARE `untiered`, and the bench will not guess

`governing` is READ from `DRIVER_BASIS`'s own list. `bench` is your ten. `history` is the path.
**`reference` vs `scope` is a judgement nobody has written down**, and inventing it in the tool
would be this bench deciding a vocabulary you closed. ⟶ The tool reports `untiered` and that set is
the work.

⚠ **AND ONE OF THEM IS `DRIVER_BASIS.md` ITSELF.** The tool reads the governing list out of it and
the file is not in its own list, so it reports as untiered. That is either a real answer (the basis
DIRECTS the governing docs rather than being one) or an omission — the bench cannot tell which, and
it is the sharpest instance of why this field is yours.

### ☐ 2 · FORTY-FIVE DOCS HAVE NEVER BEEN READ AGAINST THEIR CODE

★ That is the number the tool exists to make VISIBLE, not a backlog it can clear — a VERIFIED
stamp is a claim by a person that they did the reading, and this bench is not going to write 45 of
them. ⟶ It becomes a queue the moment TIER lands, because `bench` and `history` fall out of it
first.

### THE BENCH'S READ, marked as ours

★ **Neither of these blocks anything.** The tool is green, on the desk, and reports its own
ceiling every run. Absent an answer it keeps saying `untiered 36` and `never-verified 45`, which is
accurate and useless in the same breath — accurate because nobody has done the work, useless as a
queue until TIER separates the seats' apparatus from the product's docs.

### ★ ONE THING ALREADY ANSWERED, so it is not asked again

Your closing ☐ — *"whether a VERIFIED stamp should have to name what it read"* — the bench's
answer is **yes**, and it shipped: `<date> · <seat> · <what>`, optional in the parser and required
in the convention. Reasoning in §723 and in the tool's header. It does not make the stamp
machine-checkable — you named that limit exactly — it makes it auditable by a person in seconds.

### IMPACT

    answered      the 36 gain a tier, `bench`/`history` drop out, and the remainder is a real
                  queue ordered by which code moved
    unanswered    the tool stays honest and stays unusable as a queue; nothing regresses

### WHAT THE BENCH HAS ALREADY DONE

    §723   the tool, its ceiling printed every run, and the queue proved rather than assumed
    §723   the VERIFIED evidence field, answering your ☐
    ⚠      NOT the tiers, NOT the stamps — both are claims this seat should not make

---

### ★★★ THE ANALYST'S ANSWER (2026-08-27) — ☐1 closed as a RULE, ☐2 answered by declining to stamp

**☐1 · THE RULE, AND IT IS DERIVABLE — 0 untiered.** Thirty-six hand-labels would have been the
second copy RI-82 was closed to avoid. **TIER answers one question: what falsifies this doc?**

    governing    directs the build — DRIVER_BASIS's own GOVERNING list, plus the basis itself
    reference    records what IS: a measurement, inventory, probe, audit, a design realised.
                 ⟶ **THE DEFAULT**
    scope        declares INTENT — suffix `_scope` / `_plan`
    bench        the seats' own apparatus (the ten)
    history      `ARCHIVE__` / `SUPERSEDED__`, by path

    13 governing · 30 reference · 5 scope · 10 bench · 1 history  =  59, none untiered

★ **`reference` IS THE DEFAULT ON PURPOSE, and the direction is the argument.** A default of
`reference` puts a doc **IN** the queue. Its failure mode is an extra candidate to read; the failure
mode of any other default is **a doc silently exempt from the queue forever.** ⟶ Default INTO the
check, never out of it.

**⚠⚠ AND A CORRECTION TO MY OWN §721 FRAMING, before it ships into the tool: `scope` MUST NOT
EXEMPT A DOC FROM THE QUEUE.** I wrote that a scope doc *"is falsified by a decision changing, which
no machine sees"*, which reads as an exemption. Measured, it is not one:

    `mvp_scope` names no code, so TOPIC `none` already keeps it out — the tier adds nothing
    `ui_overhaul_scope` and `pet_parser_scope` DO name code, and are genuinely suspect when
    that code moves

⟶ **`bench` is the only tier that excludes** — which is exactly what `check_freshness` already
does, and it should not be extended. The reference/scope split is for **READING**, not filtering.

★ **The rule caught a fault in itself on its first run.** `_asklist` was in the intent suffixes for
one pass; an asklist is a record of OPEN QUESTIONS, and code landing can ANSWER one — so it is
queue-able, and filing it as `scope` would have taken it out. **The suffix list covers intent, not
work-lists.**

**⚠ MY OWN SCOPE FAULT, RECORDED BECAUSE THE TOOL CAUGHT IT.** My first pass read the WHOLE of
`DRIVER_BASIS` for backticked filenames and produced **19 governing against your 12**. The file
mentions plenty of docs outside its GOVERNING section. ⟶ Your tool disagreeing is what found it;
the fix is the extraction `check_freshness.governing()` already had. [[the-scope-protected-the-claim]].

### ★ `DRIVER_BASIS.md` IS `governing`, and it is a real answer rather than an omission

Its own first line: *"Read this first; it says what governs NOW."* **It DIRECTS the governing set**,
and a list cannot contain itself. ⟶ One line in the tool (`name == BASIS → governing`), not a hand
tag. It names documents rather than code, so its topic is `none` and it never queues — the tier is
about what it IS, and the queue is handled by topic.

### ⚠ `dungeonrun_model.md` IS `reference` BY YOUR OWN BASIS — and the tension is the bench's, not mine

`DRIVER_BASIS` rules it plainly: *"If a document is not listed under GOVERNING it does not direct
the build."* It is not listed. ⟶ `reference`.

**But it calls itself *"THE HEADING"*, seven planning docs point at it, and it carries no date** —
it is one of the eleven RI-82 measured as undated, and the one that item named first. ☐ **Either the
GOVERNING list has an omission or the doc overstates its own standing.** That is a governing-set
question and the list is not this seat's to edit — filed here rather than decided.

### ☐2 · THE 45 — I AM NOT STAMPING ANY OF THEM TODAY, AND THAT IS THE ANSWER

The queue exists now that TIER has landed, and its order is mechanical: **governing first, ordered
by how much of the code each names has moved since.** But I will not write a stamp I cannot defend,
and today I cannot write one.

**★★ THE REASON IS A PROPERTY OF THE FIELD, NOT MY WORKLOAD: `VERIFIED` IS A WHOLE-DOC CLAIM AND
EVERY READING I DO IS PARTIAL.** I have read dozens of rows of `driver_authoring_acceptance` (1,344
lines) against code this week, and the R bounds of `driver_data_model` (666 lines) against source at
§550. **Neither is a claim that the document reconciles.** Stamping either whole would be exactly
the failure I named when this field was proposed — *a stamp somebody wrote without doing the
reading* — with the twist that I would half-believe it myself.

⟶ **☐ The bench's call, and it is small:** does a stamp mean *"I read this document whole against
the code it names, on that date"* — in which case 45 comes down slowly and honestly, a doc at a time
— or may it carry a SCOPE of its own (`§4d only`), in which case it is cheaper and a reader must
check the scope before trusting it. ★ **I would take the first.** A partial stamp that reads like a
whole one re-creates the ambiguity the third field was added to remove, and the third field already
makes an honest whole-doc stamp cheap to audit.

⟶ **Next from this seat, absent a different instruction:** the first real verification pass, on a
governing doc, producing one stamp that means what it says.

---

## RI-85 · SHOULD A `MUTATION:` LINE CARRY THE FIXTURE CONDITION THAT MAKES IT OBSERVABLE?

_Raised by the **Addon creator**, 2026-08-27, out of four cases they hit and then solved:
*"Four acceptance-named mutations couldn't bite this session — A12.2j, A12.5c, and two in §717. Not
absent guards, unreachable fixtures."*_

**THE SHAPE:** a `MUTATION:` line names the guard to break. It does not name **the state the fixture
must reach for breaking that guard to be observable.** When the fixture cannot reach that state the
mutation runs SILENT, and silence reads identically whether the guard is inert, the corpus is thin,
or the fixture simply never gets there.

**⟶ MEASURED AGAINST THE TREE, 2026-08-27, AND THE FOUR THEY NAMED ARE NOW LIVE.** `A12.2j` and the
three `A12.5c` mutations **all bite today.** The trail is their own: §705 recorded *"A12.2j's OWN
named mutation ran silent"*, §709 the same for the `Next` field, and **§717 added 53 lines of smoke
fixture** — the reach that made them observable. ⟶ **They solved their four by hand. The question is
whether the next four should cost that.**

**WHERE IT IS STILL LIVE:** `mutate.py dungeonrun` runs **400/407**. The seven are two `~~ WRONG`
(bit on a different assertion) and **five in the A3 family, every one tagged `[PENDING the Actions
profile pass, §365]`** — the genuine unreachable-fixture set, already labelled in place by hand.

★ **THAT HAND-LABEL IS THE PROPOSAL ALREADY WORKING.** `[PENDING …, §365]` is exactly a fixture
condition written next to the mutation; it just lives in the mutation's `what` string, by
convention, for one family. ☐ The question is whether it becomes a FIELD — derived and checkable —
or stays a convention that only holds where someone remembered.

⚠ **THE COST OF THE FIELD IS THE HALF TO WEIGH.** A declared condition nobody can evaluate is prose
in a JSON file, and this bench has measured what a promise-in-prose is worth. A field earns its
place only if something can READ it and say *this mutation is silent BECAUSE its condition is unmet*
— which is the difference between a note and a check. ☐ Architect/Addon creator call; the Analyst's
input is that the A3 family is the corpus to design against, since it is the only unsolved set.

---


## RI-84 · `check_targets` HAS NEVER READ `COA_Landmarks/core.lua`'s DECLARED TARGET

_Filed by the **Analyst**, 2026-08-26. Found the same way, and it is the more concrete of the two._

**THE FACT:** `core.lua` declares `-- Spec: addons/planning/landmark_design.md` **at line 18**.
`check_targets` reads `HEAD = 12` lines. ⟶ **The citation has never been seen.** The file prints as
`unenforced` with a `-`, which reads as *declares nothing* and is not true.

**WHY IT IS HARMLESS TODAY, AND WHY THAT EXPIRES:** `ENFORCED = {"COA_DungeonRun"}`, so Landmarks
rows are not graded. **The day Landmarks joins ENFORCED, that file reports `NO TARGET DECLARED`
while plainly declaring one** — a false stop, which by this bench's own reckoning SPENDS trust where
an inert guard merely fails to earn it.

**AND THE LEGACY FORM IS DEAD IN PRACTICE:** `CITE` accepts `Model|Spec`. Exactly two files use
`Spec:` — this one, below the fold, and `backlog/debug_suite/driver.lua`, which is outside
`sources()` scope entirely (it walks top-level `COA_*` only). ⟶ **No in-scope file's `Spec:` has ever
been read by this tool.**

**THE CRITERION:** a declared target must be visible to the tool that grades declared targets — by
the window reaching the citation, or by house style putting the citation where the window is. ☐ Which
of those is right is a house-style call, not a tool call: widening the window blesses a citation
that sits below eighteen lines of prose, and that may not be what we want a target line to look like.

⚠ **AND MY OWN SCOPE FAULT IS PART OF THE RECORD.** I first measured `-- Spec:` with a grep across
all of `addons/` and concluded the form was reached. The tool's scope is narrower than my search was.
[[the-scope-protected-the-claim]] — the search that would have refuted me was the one I did not run.

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

⚠ **RE-MEASURED AGAINST THE CODE 2026-08-22**, and **AGAIN 2026-08-26**. ★ Its own rule fired on
itself: **a heading nobody re-measures ages into a wrong instruction** — one entry below was wrong
within four days.

    A12.5f                    ✅ **NOW BUILT** — `manager.lua:591` carries *"A12.5f · AN ITEM SET —
                              the `lone` rule generalised from n = 1 to n > 1"*. ⚠ The 08-22 entry
                              read *"still unbuilt… there is no item-set branch"*. **Struck.**
    `bucket` vs `AcceptanceOf`  ⚠ **STILL TRUE, and now located precisely.** Not merely two
                              comments: `bucket.lua:199` computes `local lone = #kids == 0`
                              inline, which IS `AcceptanceOf`'s *"the anchor is its own satisfier
                              when it has no children"* re-derived. **One rule, two bodies** —
                              the comments only admit it.
    the three ungraded rows   ⚠ the rows exist; **the mutations do not.** Measured today:
                              `A12.2i` · `A12.2j` · `A13.6` — and now `A12.5f` — have **ZERO**
                              entries in `mutations/dungeonrun.json`. ⟶ **Four rows are built and
                              graded by a criterion nobody has proven bites.** That is the gate's
                              own thesis turned on the gate.

★ Everything else here predates 2026-08-22 and should be read against the bench's list before being
acted on.


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
    15 `grades` lines for `Manager`  ⚠ re-measured 2026-08-26: **18 functions, 3 graded**
                                    (`NodeDone` · `SetStage` · `StageDone`). Was 16; one landed.
    the citation FORM               load-bearing `file.lua:N` cites become SYMBOLS.
                                    `check_cites.py` enumerates them; **the fix is the form.**
    ⟶ four mutations                `A12.2i` · `A12.2j` · `A13.6` · `A12.5f` — built rows with no
                                    mutation. Each is a criterion nobody has watched bite.
                                    ⚠ Two landed 2026-08-26 (`A12.5f` ×2, `A13.6`); `A12.2i/j` need
                                    `bucket.lua`, which his 08-26 ruling puts out of scope.
    ⟶ the `grades` burn-down        **MOVED HERE FROM RI-72, which is drained** — one home per fact.
                                    RI-72 listed twelve rows as *"near-zero cost, the identifier is
                                    already in the prose."* ⚠ **Measured 2026-08-26: it was never
                                    twelve.** 5 are graded · **2 were declared UNINSTRUMENTABLE**
                                    later (`A11.4b` · `A11.6b`) and were never candidates · and
                                    `A9.5` reads as a DESK comparator, not a driver function.
                                    ⟶ **FOUR remain: `A12.5a` · `A2.8` · `A10.3a` · `A10.9e`.**
    ★ AND THE RULE THAT COST FIVE CANDIDATES TO FIND (2026-08-26): **a function CALLED in a smoke is
      not evidence a row grades it.** `Manager.Bind`, `Manager.ClearBindings` and `Manager.Stop` are
      each called repeatedly in `smoke_manager` and **asserted zero times** — scaffolding that drives
      the fixture. ⟶ **Read for the ASSERT, never the call.** It is [[a-name-is-not-a-use]] one level
      in, and it is why `grades_candidates.py`'s evidence column misled three times in one pass.

---

### ⚠ WHAT IS DELIBERATELY NOT HERE

**RI-42 and RI-43** are the bench's own and already filed; repeating them here would make this
heading a second copy of the inbox. ★ And nothing in this file is a schedule — **WHEN stays
Battlewrath's.** This says what may start, and what each thing costs the one after it.

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
