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

## RI-44 · THE DEVELOPMENT LINE ITEMS, IN DEPENDENCY ORDER — for his word on WHEN

    RI-44 DRAINED (Battlewrath, 2026-08-21) — YES to the pacing (both chains; the defect today; the
          engine proven on synthetic rows), WITH THE SEQUENCE NOTE THAT GOVERNS IT: **"Push the editor
          to richness before worrying about export and Dungeon Routes. The bench can synthetic as it
          needs to PROVE rather than A/B client testing. Dungeon Routes earns everything Dungeon Run
          proves — not that Dungeon Run cannot test drive; it is that deciding how we present
          information assumes the information is structured enough to reach them."** ⟶ CHAIN 1 LEADS;
          Chain 2 runs as far as proving needs, on synthetics; Chain 3 (the reader's screen) waits on
          structure. Logged ARCHITECT_LOG AL-12; architecture §7.

_Filed 2026-08-21 by the **Analyst**, the last of his four asks on the reconcile. ⚠⚠ **THIS IS A
PROPOSAL, NOT A RECORD** — it was first written into `audit/reconcile_architecture_2026-08-21.md`
with a pointer from `DRIVER_BASIS.md`, and he moved it here: *"I'm trying to keep decisions /
discussion isolate so that the docs don't keep shifting."* ★ An audit records what was found; a
plan proposes what to do about it — the first is settled when measured, the second is discussion
until he rules. **It leaves the inbox when he takes it, not before.**_

**WHAT IS ASKED:** nothing about ORDER — the order is derived and its two fixed sequences are
already his and the architect's. What is asked is **WHEN**, and whether any chain runs first.


_Produced 2026-08-21, the last of Battlewrath's four asks. ⚠ **ORDERED BY WHAT BLOCKS WHAT, not by
size or by value.** Two independent chains run in parallel; the only cross-edges are named. Nothing
here is a schedule — a chain says what cannot start before what._

★ **THE TWO FIXED SEQUENCES IT OBEYS**

    HIS, for the author side (E-0)      interface onto Ace → style WA-coded → a settled home
                                        for each → then the rows wire
    THE ARCHITECT'S, F2 (AL-9)          the bucket's duplicate refusal lands BEFORE the manager

---

## CHAIN 1 — THE AUTHOR SIDE. Strictly sequential; his order, and nothing in it may be reordered.

    L1.1  INTERFACE ONTO THE ACE METHOD                                      A10.1 · A10.2
          The folding pass: hand-placed controls become Ace-readable, one pane at a time.
          ⚠ BLOCKS EVERYTHING BELOW IT IN THIS CHAIN. `object.lua` is hand-placed `SetPoint`
          arithmetic today (`-276 - (i-1) * 22`); computed padding is a different construction,
          not a restyle.

    L1.2  THE STYLE / GRAMMAR, WA-CODED                                      A10.3 · E-0 step 2
          The IDIOM, generically — not their code. Tabs · tone · **Ace computed padding** · ONE
          universal pane with FOLD IN / FOLD OUT · TAB IN TAB (Object options → Beacon/child →
          Action 1, Action 2).
          ★★ **Tabs are ADDED BY CHOICE: "Action 1 · add action · Action 2".** Not a fixed set,
          and NOT the word "Trigger" — that is taken (`contract.lua:87`, a NODE field).
          ⟶ This is where the action TABS come into existence (§B P3b).

    L1.3  A SETTLED HOME FOR EACH                                            A10.3 · A10.6
          Every control placed where it belongs, once.

    L1.4  THE ROWS WIRE                                                      D1 · A11.1
          `object.lua` moves from `SetChildSense`/`SetChildRole`/`SetChildAction` to
          `Routes.SetRow`, which gains its first product caller.
          ★ **The consumer needs NO change** — `bucket.lua` already reads the ruled shape, and
          `SetRow(b, child, index, …)` already takes the index a tab strip supplies.

    L1.5  THE PICKERS                                                        D7 · A10.3e
          Stage and ordinal doors as SELECTIONS with a floor, replacing three free-text boxes.
          ⚠ NEEDS L1.1–L1.3. ★ Closes the author-time half of one-beacon-per-stage, and the
          reach box's "no floor, no clamp" with it.

---

## CHAIN 2 — THE CONSUMER SIDE. Runs in parallel with Chain 1; only L2.6 has a cross-edge.

    L2.1  THE BUCKET'S TWO MISSING REFUSALS                       D3 · A12.2b · A12.2f
          ONE named line each, in a list that already holds fourteen:
            · a second anchor at one stage — *"two beacons at stage N — re-slot in the editor"*
            · an address that resolves to no characteristic — no silent orphan
          ⚠⚠ **F2 SEQUENCES THIS BEFORE THE MANAGER.** Cheapest item on either chain and it
          closes the guarantee A12 is written on.
          ★ A12.2f is also the third leg of the isolation demonstration RI-23 stands on.

    L2.2  `Sensor.Sample`                          ✅ CLOSED §435, verified §455 · D9 · A11.4
          ~~Position acquisition — CALLED at `sensor.lua:204` and DEFINED NOWHERE.~~
          ★ **MEASURED:** `driver.lua:77` binds `Sensor.Sample = Driver.Sample`, which reads
          `Store.Point()` — the shipped own-position read, already WORLD `x, y, z, mapID`.
          `Stop` clears the binding, so S9's *"nothing armed, nothing running"* holds.
          ⚠ The claim was true when filed and §435's pipeline closed it; nothing re-read it
          until now. **A line item is a claim about state and ages like one.**

    L2.3  THE PREVIOUS IN-SET AND THE TRANSITION WORD                  D2 · A11.3e · §6 G18
          `sensor.lua` keeps ONE `inSet` and overwrites it; `snapshot()` drops `rows`.
          ⟶ Three parts, one step: keep the prior verdict · return the CHANGED set by address
          with **When on · Seen · When off** · carry the node's rows into the snapshot.
          ⚠⚠ **BLOCKS ALL DISPATCH.** The entire sense vocabulary is uncomputable without it, and
          §6 marked it CLOSED when it is not.

    L2.4  THE ACTION BINDER AND THE MISSING VERBS                           D4 · A12.2c
          `Bucket.Resolve = nil`; `adaptor.lua` has no word for `note`, `say` or `boss`; the
          authorable action set is `nothing | supertrack`.
          ⟶ Three of §4b step 4's four dispatch verbs have neither a door nor a callable.
          ⚠ CROSS-EDGE: the WORDS are an authoring-vocabulary question and want L1.2's tabs to
          have somewhere to put them; the BINDER itself does not.

    L2.5  THE ONE SAVED SLOT                                ✅ BUILT §455 · D5 · A12.9a
          `Store.SetSelectedRoute(rid)` / `Store.SelectedRoute()`. One key, overwritten;
          `nil` CLEARS rather than storing a blank, because "none" must be
          indistinguishable from never having selected. Mutation 5/5.
          ★★ **THE SECOND MUTATION IS THE ONE THAT MATTERS, and A12.9a says so:** *save
          `currentStage` → the test for "not armed after reload" STILL PASSES*. A resumed
          run looks perfectly well-behaved from outside, so the row **reads the STORE**
          rather than the driver — and it runs TWICE, because a cursor written on the
          second select would slip past a check that only looked once.
          ⚠ It sits ABOVE the key-count row: a saved cursor trips BOTH and only the
          progress row says why. **Tenth instance of specific-behind-general this week.**
          ✅ And `store.lua:506`'s *"Session-only UI state"* moved in the same pass, as this
          item said it must — the table hangs off `COA_DungeonRunDB`, so it persists. The
          second half of the sentence was right: kept apart from `runs` so the RECORDS stay
          data only.
          Selected RID or none, overwritten, never appended. Progress never saved.
          ★ Its home already exists and is already one-record-overwritten in shape
          (`store.lua:521-536`). ⚠ When it lands, `store.lua:506`'s *"Session-only UI state"*
          comment becomes wrong — that table is in SavedVariables — and moves in the same pass.

    L2.6  THE ROUTE MANAGER            ✅ BUILT §461 (one gap: RI-49) · D6 · A12.1–A12.9
          The one stateful owner. **NEEDS L2.1 (F2), L2.3 (dispatch), L2.4 (something to call),
          L2.5 (reload).** ⚠ CROSS-EDGE: it can be built and graded against synthetic rows before
          L1.4 wires the author's; it cannot be DEMONSTRATED end-to-end until L1.4 lands.

---

## CHAIN 3 — THE READER'S SURFACE. Needs Chain 1's method and Chain 2's manager.

    L3.1  THE TWO PANES                                                      A10.8a–c
          The NOTE PANE (stage / step · note) and the collapsible REMOTE. No diagnostics in
          flight; the manager EMITS and is never in chat.
          ⚠ NEEDS L1.1–L1.2 for the method and L2.6 for anything to display.

    L3.2  THE RECEIVE BOX AND THE IMPORT DOOR                          A10.8d · §3b import ✗
          Multi-line + Read, decode → PRESENT → save. ⚠ The SYNC channel is NAMED, NOT BUILT.

    L3.3  THE TRACKER ESCAPEMENT'S WIRING                              A11.9 · A12.3c · A12.8a
          The arrow always has a defined target: a tab's, or the PARK. **Tray-0 never writes it.**
          ⚠ The geometry is built and measured; the wiring needs L2.6.

---

## OFF BOTH CHAINS — start any time, block nothing

    X1  RI-43's three code items — ⚠ **E1 is a LIVE DEFECT** (`capture.lua:159` invents an
        altitude inside a recorded distance). Cheap now; a corrupt corpus later.
    X2  The isolation demonstration's first two rows (A12.2d, A12.2e) — gradeable against
        `smoke_bucket` today; only A12.2f needs L2.1.
    X3  The `grades` citation spread — coverage is the honest ceiling on every UNGUARDED claim.
    X4  The personal-note plane's per-role dimension (§3a: the PLANE is built; the dimension is not).

---

## ⚠ WHAT THIS ORDER DOES NOT DECIDE

    · WHEN any of it happens — that is Battlewrath's.
    · WHETHER L2.6 waits for L1.4 — the architect sequenced L2.1 before L2.6 and said nothing
      about the chains' relative pace; they are independent by construction.
    · The COMPLETION LEDGER (V2), the CLEU listener, the flattener/exporter and the test-drive
      remote sit behind L2.6 and are not broken out — they are the manager's own build.


**Architect's read (marked, 2026-08-21 — the pace RI-44 says I left unsaid):**
- The ORDER is right: both fixed sequences honoured, the cross-edges are the real ones.
- PACE, one proposal for Battlewrath's word: **start both chains now** (independent by construction).
  **X1 first, today** — E1 is a live defect and every capture before the fix is a corrupted corpus;
  an hour's work. Then **Chain 2 runs to L2.6 graded on SYNTHETIC rows** while Chain 1 does its
  interface work: the consumer chain is the hot path (L16), the shorter chain, and it delivers the
  isolation demonstration (AL-10's condition) earliest. L1.4 is the first cross-edge that matters —
  the manager is DEMONSTRATED end-to-end only when the author's rows wire; it is graded before then.
- Two sharpenings: **L2.2 (`Sensor.Sample`) goes FIRST in Chain 2**, ahead of L2.1 — smaller than a
  refusal, and every later grade needs a sample to feed; and L2.1's orphan-address refusal is the
  third leg of the demonstration, so L2.1 + X2 complete it the day L2.1 lands.
- Nothing here is WHEN — that stays his.

---


---

## RI-49 — ❓ `Next(Type, arg)` AND `role` + `setStage` ARE TWO VOCABULARIES FOR ONE THING

**Filed by: Addon creator, 2026-08-21 (§461), building the manager (L2.6).** ★ One question,
with both sides on screen. It is the ONLY thing that stopped; everything else in A12 is built.

### The two shapes, verbatim

    driver_data_model.md row 12   `Next` IS ONE FIELD, `(Type, arg)` — Step · Stage · Set(N),
                                  the arg present only for Set
    routes.lua                    `Routes.ROLES = { "start", "update", "complete", "set" }`
                                  plus `child.setStage`, which is *"what a `set` role ASSIGNS"*

⚠ **`routes.lua` has no `Next` field at all**, and `Bucket.Build` therefore carries none onto
the entry. So the manager has nothing to fire.

### What I could and could not derive

✅ **The path that needs no `Next` is fully specified and is BUILT** — A12.5a's *Step* (the next
positive ordinal) and A12.5b's *runs dry* (the next stage PRESENT). That is a whole run: the
manager arms, dispatches, completes nodes, advances steps, advances stages across an exposed
gap, and reaches terminal. 19 mutations, each on its own row.

⬜ **An AUTHORED `Next` of `Stage` or `Set(N)` is not built**, because deriving it means deciding
the mapping, and four readings all look plausible from here:

    A   role `set` + setStage  ==  Next(Set, N),  and `complete` == Next(Stage)
    B   role is the TAB's part in the node (start/update/complete are a lifecycle),
        and `Next` is a separate field nobody has added yet
    C   `Next` is the model's NAME for what `role` already is, and row 12 is describing
        `routes.lua` in different words
    D   `role` is the AUTHOR's word and `Next` the RUNTIME's, and BUCKET is where one
        becomes the other

★ **B and D would both mean the store is incomplete rather than differently-named**, and that is
a build item for Chain 1, not a rename. A and C would mean the manager reads `role` today. I am
not choosing between them: *"where a row and the code disagree, report it"*, and this is a
disagreement about what a shipped field MEANS.

### ⚠ What it costs while it waits — nothing structural

The manager's `NodeDone` already has the shape: it asks *what does this node's completion say to
do next*, and today the answer is always *Step, else the stage ran dry*. Adding the authored
cases is one branch in one function, and the tests move with it. **Nothing is blocked and
nothing is guessed** — `manager.lua` carries the gap NAMED in its header, `driver.lua`-style.

### ✅ Two bench shape-decisions inside L2.6, marked as MINE and cheap to push back on

1. **A callable returns whether its tab is DONE.** `fn(ctx) -> true` completes now; `false`/`nil`
   leaves it PENDING and `ctx.complete()` closes it later. ⚠ Not speculative — A12.4c is written
   on the pending case (*"a reader leaves a node's reach mid-stage and its CLEU listener must go
   with it"*), and a `boss` tab finishes when the boss dies, not when the tab ran.
2. **An unbound action word is refused AT ARM, naming the word**, rather than discovered at
   dispatch. Checking on the hot path would find it mid-run and mid-combat, one tab at a time.

---

## RI-48 — L2.4's ARG HALF IS BUILT; TWO-SIDE GATING RECORDED; NO QUESTION LEFT

**Filed by: Addon creator, 2026-08-21 (§458).** L2.4 splits three ways and only the third
needs anyone's word.

### ✅ BUILT — an incomplete row no longer reaches the driver

`Routes.ROW_ARG` names which actions take an arg and what it is. It was consumed by
**nothing but its own smoke** — `RowIncomplete` is the author-time *TOLD* half (A3.2) and
had no runtime counterpart. Measured before writing anything:

    boss with a name          BUILT
    boss with NO name         BUILT      <-- A3.3: arms nothing
    boss with a BLANK name    BUILT      <-- same
    say with no content       BUILT      <-- same
    supertrack with an arg    BUILT      <-- see the question below

⟶ The first four are settled by row 24 (BUCKET fails loudly) plus A3.3 (it arms nothing),
so BUCKET now refuses them **naming the field**: *"the action boss has no name"*, *"the
action say has no content"*. Three refusal rows, three mutations, 34/34.

### ✅ BUILT — and the reason the first cut of it was INERT is worth more than the gate

The gate was correct and **did nothing**: `smoke_bucket`'s stub had no `ROW_ARG`, so `want`
was nil and the suite went green over three fixtures that should have been refused.

★★★ **That is §457 again, one commit later, in a shape the §457 fix did not cover.** §457
was closed by COPYING the two vocabulary lists correctly into the stub. A copy is correct on
the day it is written and drifts the day the shipped file grows a third table — which was
the very next day.

⟶ `addons/tools/smoke/_vocab.lua` now **READS** `SENSE_WORDS`, `ROW_ACTIONS` and `ROW_ARG`
out of the shipped `routes.lua` (it loads standalone under `loadfile` + varargs). Each is
`assert`-named, so a table renamed upstream fails on its own line rather than arriving as
nil and switching a gate off. **A copy drifts; a read cannot.** Mutation N6 is that failure
made permanent.

### ★★★ TWO-SIDE GATING, AND THE TWO SIDES CANNOT GATE THE SAME THING

**Battlewrath, 2026-08-21:** *"The intent is a boss name is from a data sample. IE, recorded
in the run, then the picker populates from the run data. But 2 side gating is useful."*

✅ **The chain is built and it is exactly that.** `capture.lua:278 engagedBosses()` records
boss-tagged units per pull → `store.lua:414 BossNames(runId)` de-duplicates and sorts them →
`object.lua:940/1262` builds the menu from that list alone — *"FED ONLY FROM THE RUN
(A3.1)"* — → `SetChildBoss` / `SetRow` refuse a name that is not on `offered`. The menu is
CLOSED and the author cannot type.

⚠ **BUT THE TWO SIDES GATE DIFFERENT PROPERTIES, and this is forced by the data, not a
shortfall:**

    AUTHOR-TIME   SetRow / SetChildBoss   MEMBERSHIP   is this name one the run offered?
    BUILD-TIME    Bucket.Build            PRESENCE     is there a name at all?

★ **BUCKET CANNOT CHECK MEMBERSHIP, AND MUST NOT LEARN HOW.** `routes.lua:14` — *"promotion
COPIES, so once a beacon exists it owes its origin nothing, and the §25.2 back-reference is
DROPPED"* — and `:458` gives the reason: a run link could never survive the route reaching
*"someone else's machine"*. The run is gone by construction at build time, and re-attaching
one would break the portability that makes an exported route worth exporting.

⚠⚠ **AND THE CONSEQUENCE IS THE ONE THAT MATTERS:** an imported route names bosses from
*someone else's* run. If BUCKET ever gained a membership check, **every imported route would
be refused on a map you had not cleared yet** — the offer list is about THIS run's authoring,
never about whether a name is valid. ⟶ Presence is the strongest thing the build side can
honestly assert, and it is the right thing for it to assert.

✅ So the two sides compose rather than duplicate: authoring cannot produce a name the run
never showed, and BUILD cannot ship a row that arms nothing — whatever machine it came from.

### ⚠ ONE GAP THE SAME MEASUREMENT SURFACED — named, not alarming

`Routes.SetRow` has **no production caller**. `SetChildBoss` has two (`object.lua:952`,
`:1263`), both correctly passing `names`, so the CHARACTERISTIC side is live. The ROW side
— the `sense:action:arg` instruction set — is authored by tabs that do not exist yet
(**L1.2 / A10.3f–j, STOPPED on instruction**). ⟶ Author-time membership gating for row args
lands with those tabs; the door is already written and already takes `offered`. **Not a
defect — a build-order edge, recorded so it is not rediscovered as one.**

---

### ✅ WAS A QUESTION, ANSWERED FROM THE REPO — an arg on an action that takes none

`Routes.ROW_ARG.supertrack` is `nil`, and its comment says *"`nil` means the action takes
nothing — **not that anything is allowed**."* Today this builds and carries the stray value
to the driver:

    { sense = "whenOn", action = "supertrack", arg = "junk" }   -->  BUILT, arg = junk

⚠ It cannot be authored through the pane — A10.3a says the fields follow the action word, so
supertrack offers none. It can only arrive from a hand-edited SavedVariables or an importer.

**Three answers, and I have not taken one:**

    REFUSE   row 24, consistent with the three above  — but refuses a whole route over a
             field that changes no behaviour
    DROP     the row's contract is ROW_ARG-shaped, so an arg the action does not take is
             not part of the row — but a silent drop is the shape we distrust
    CARRY    today's behaviour — the hot path ignores it, and a future action that grows
             an arg finds the value already there

### ✅ ANSWERED — BY PRECEDENT, AND I SHOULD HAVE FOUND IT BEFORE FILING THE QUESTION

**`Routes.DropRetired` already rules this exact class**, and `routes.lua:194` names both of
this case's sources in one sentence: *"a `goTo` can arrive from a **hand-edited
SavedVariables or an import written against an older build**, and neither of those bumps a
schema version."* Its ruling:

> *"loaded and dropped, **NEVER SILENTLY HONOURED**… And it is **TOLD rather than refused**,
> which is the same S4 line the rest of the editor holds: the author is not stopped, they are
> informed that a thing they authored no longer exists. Their route still runs."*

✅ **BUILT §460 — drop and tell, at load, in `DropRetired`, at BOTH levels.** Seven rows, seven mutations, each biting on its own. The two that carry the weight are the ones that stop it being *strip every arg*: a `boss` name MUST survive (A3.3 — stripping it silently disarms every boss listener in the file), and an UNKNOWN action keeps its arg, because the action is the foreign thing and a half-retired row is harder to diagnose than a whole one. ⚠ `Routes.RowsOf` is deliberately not used — it materialises `rows = {}` as a side effect, so a sweep built on it would dirty every route on every load.

⟶ **DROP AND TELL, at load, in `DropRetired`.** Every branch of my three-way was already
decided:

    REFUSE   ruled out — S4: told, not stopped; the route still runs
    CARRY    ruled out — "never silently honoured"; a field nothing in the build knows
    DROP     ruled IN — but SAID, and A2.12b's mutation bites on a silent drop

★ And A2.12b is the precedent for the SHAPE of the change too: `fireOn` joined *"the same
function, one more field in the condition, because the reason is identical."* An arg on an
action that takes none is one more condition in `DropRetired`, **counted and said
separately** — `routes.lua:201` is explicit that folding it into an existing counter would
announce the wrong thing, and *"a message that misdescribes what it dropped is worse than no
message."*

⚠⚠ **AND IT MOVES THE LAYER.** This does not belong in BUCKET at all. `DropRetired` runs on
every load, so a stray arg never survives to reach the build — BUCKET's side stays PRESENCE
only, exactly as the asymmetry above requires. The "two sides" are author-time membership and
build-time presence; **the load sanitiser is a third, older side that was already doing this
job for four other fields.**

### ⚠ MY FAILURE HERE, RECORDED BECAUSE IT IS THE ONE I REPEAT

I filed a three-way question, took a lean, and labelled it *"a preference, not a
measurement"* — while the answer sat in a shipped file, in a comment that names this case's
two sources verbatim. **Searching my own basis was the step I skipped**, and the tell was
right there: I wrote *"it can only arrive from a hand-edited SavedVariables or an importer"*
without asking whether anything already handled arrivals of that kind. ★ A question I can
answer from the repo is not a question for Battlewrath.

### ⬜ NOT BUILT — the binder proper, and it is not blocked by this

`Bucket.Resolve` is still nil, and its own comment already rules the shape: *"Binding a
callable is a later step, and it goes through this seam rather than around it."* ⟶ The
callables are the **manager's** (A12.1a puts all three tracker writes there, and the fence
holds: *we generate the input contract, never the consumer's handling*), so the binder can
only be filled when L2.6 exists. A12.2c's two grading rows — unknown word refused at build,
named — are **already green** as of §457.

⚠ Recorded against RI-42's shape column, where *"the binder's shape"* is already owed: the
row will carry the WORD (records and the address need it) **and** what the resolver returned
alongside it, rather than the word being replaced by a function.

---

## RI-47 — BUCKET GATED ON THE DISPLAY VOCABULARY (bench finding, self-reported, FIXED)

**Filed by: Addon creator, 2026-08-21 (§457). Not a question — a defect of this bench's own,
recorded because it corrects a line already written into L2.4.**

### What was wrong

`bucket.lua`'s `known(code)` validated every authored `sense` and `action` against
**`Adaptor.Has`**. That is the wrong table:

    Routes.ROW_ACTIONS   MAY AN AUTHOR WRITE THIS?   the gate — `SetRow` checks it too
    Adaptor.Word(code)   WHAT DOES A HUMAN SEE?      display; A5.1 PASSES A MISS THROUGH

Measured against the shipped files:

    ROW_ACTION  boss        adaptor word?  NO   <-- refused at build
    ROW_ACTION  note        adaptor word?  NO   <-- refused at build
    ROW_ACTION  say         adaptor word?  NO   <-- refused at build
    ROW_ACTION  supertrack  adaptor word?  YES
    SENSE_WORDS whenOn / seen / whenOff    NO   <-- all three refused at build

⟶ **Three of four authorable actions and all three senses would have been refused**, and a
miss in the adaptor is explicitly *not* an error — A5.1 passes the code term through. So a
COSMETIC gap was being read as a REFUSAL.

### Why it survived four commits

Two masks, and the second is the one worth keeping:

1. `smoke_bucket`'s stub read `Has = function(c) return c == "arrive" or c == "boss" end` —
   **more permissive than the real adaptor**, which carries no word for `boss` at all.
   ★ `frames.lua`'s own law, one file over: *a model that disagrees with the client is worse
   than no model.* The stub now carries the shipped lists verbatim.

2. ★★★ **THE SUITE ONLY GRADED WHAT THE GATE STOPPED.** Both vocabulary rows were refusal
   rows — `detonate` is refused, `whenever` is refused — and both stayed green the entire
   time. **A refusal-only suite passes a gate that refuses everything.** A gate is graded by
   what it LETS THROUGH.

   `smoke_bucket` now walks `Routes.ROW_ACTIONS` and `Routes.SENSE_WORDS` themselves and
   asserts each word builds — so a word added to `routes.lua` and forgotten in BUCKET fails
   on its own name. Mutations N1 (gate reads the display table), N2 (lists crossed) and N3
   (gate admits anything) each bite on their own row. **31/31.**

### And the fixtures were speaking an invented language

Every fixture in `smoke_bucket`, `smoke_driver` and `probe_bid` wrote `sense = "arrive"`.
**No shipped list carries that word.** The permissive stub accepted it, so ten fixtures were
authored in a vocabulary the client does not have. All moved to `whenOn`.

### ⚠ THE ONE THING THIS CHANGES UPSTREAM

L2.4 records *"the adaptor has no word for `note`, `say` or `boss`"* as a gap. **That is
still true and still worth closing — but it is COSMETIC**, a display term, and it was
masking a build-blocking one. No route carrying those actions would have reached the driver.
⟶ Nothing is asked of the Analyst here; the line is filed so the log carries the correction.

---

## RI-46 · A10.2a's ORDER DOES NOT FIT THE PANE — measured by building it

**RI-46 DRAINED (Battlewrath, 2026-08-21)** — *"We can do it now."*

    Q  the object pane needs 714 on a 600 ceiling. Fold zones, grow the pane, or both at once?
    O  **NONE OF THE THREE — the premise was wrong.** DOCK / UNDOCK moves from a later job to a
       NOW job (D-C overturned), and the bolt-on column is sized TO FIT THE LARGEST CONTENT.
    ✗  the pane does NOT have to hold everything · no zone defaults folded to make room · 600 is
       NOT the budget the side panel works in
    ✓  the bolt-on has the MAP SURFACE'S vertical extent, not `object.lua`'s 600 · a group has
       TWO layouts — the shared tall column docked, a per-group TEMPLATE undocked · the way back
       is carried by the pane that left (A10.9d)
    →  `driver_ui_scope.md` D-C · A10.9a-f · A10.2a

★★ **WHY IT MOVED, in his terms and worth keeping:** dock/undock was deferred as **chrome**. The
overflow made it **structural** — without it a step in the LEADING chain could not execute at all.
⟶ *A thing set aside as cosmetic became the blocker for the work that leads.*
⚠ And the Analyst's three options all assumed ONE PANE MUST HOLD EVERYTHING. They are kept visible
in the item so the false premise stays legible, not because any of them was taken.

**Filed by the Addons bench, 2026-08-21 (§444), building L1.1.** ⚠ A MEASUREMENT, not an
objection: the fold was written, the pane refused it, and the refusal is the finding.

### WHAT WAS BUILT AND WHAT HAPPENED

A10.2a orders **`object.sense` · `object.ordinal` · `object.note` FIRST** — *"the three the
checker cannot see today AND the three that SURVIVE into the node editor"* — and says the rest
of the object pane *"is NOT folded — it is REPLACED by A10.3's controls"*, with `A10.2d` keeping
the old pane live meanwhile.

★ The three were declared into `Spec` in the zones `interface/object.md` names for them
(a new `note` zone, since there was none). The pane smoke then said:

    THE PANE FOR 'child' NEEDS 714, PAST THE 600 CEILING

⟶ **600 is `object.lua`'s real pane height, not a test constant.** So the fold of the three
overflows the pane **before** the replacement frees any room.

### ⚠⚠ THE TWO HALVES OF A10.2a ARE COUPLED BY A HEIGHT BUDGET, and the row does not say so

*"A10.2 folds what survives; A10.3 builds the model's shape"* reads as two independent jobs in a
stated order. ★ **They share 600 pixels.** Folding the three ADDS ~114px of declaration while
the replacement that would REMOVE `role / shape / reach / action / outcome / unseen` has not
happened — and `A10.2d` (*"nothing is torn down to start"*) is what forbids taking them out
first. ⟶ The order as written cannot be executed at the current height.

### THE OPTIONS, and the bench picks none

⚠⚠⚠ **THE ANALYST'S FRAMING OF THESE OPTIONS RESTS ON A FALSE PREMISE — corrected 2026-08-21
after Battlewrath produced the LAYOUT DIAGRAM and asked *"are we talking about this?"*.**

★★★ **ALL THREE OPTIONS ASSUME ONE PANE MUST HOLD EVERYTHING. THE DESIGN SAYS IT NEVER HAS TO.**
The diagram shows a UNIFIED INPUT PANE with every group **knock-out**-able into its own placed
panel, and *"collapses when all knocked out"*. ⟶ **Knock-out is RELOCATION, not collapse** — a
different mechanism from A10.3f's fold-to-header, and the one that actually answers a height budget.

★★ **AND IT IS NOT A NEW IDEA — IT IS ON RECORD, AND THE GROUNDWORK WAS DELIBERATE:**

    A10.1a   *"the diagram's three lanes and three knocked-out columns are the same three groups
             in two containers; subtree keeps knock-out A CONTAINER SWAP later, flat makes it a
             REBUILD"* — THIS diagram, cited in the first acceptance row.
    A10.1b   WINDOW vendored with the widget set — *"one file now keeps knock-out cheap later"*.
    `driver_ui_scope.md:132`  knock-out = *"a CONTAINER behaviour (dock/undock)"*.
    D-C      **KNOCK-OUT → later. Chrome, not data flow.** · A10.6 lists it under WHAT IS OUT.

⚠⚠ **SO THE REAL QUESTION IS NOT WHICH ZONES FOLD.** It is:

> **THE PANE DOES NOT FIT. DOCK/UNDOCK WOULD FIX IT. IT IS SCHEDULED AS A LATER JOB
> (`driver_ui_scope.md` D-C). SHOULD IT MOVE TO NOW?**

★ There is a real argument that it does, and it is D-C's own words: knock-out was deferred as
*"chrome, not data flow"* — a cosmetic. **714 over 600 makes it STRUCTURAL**: without it, L1.1
cannot execute at the current height, and L1.1 is in the LEADING chain. ⟶ **A thing deferred as
chrome has become the blocker for a step in the chain that leads.**

⚠ The Analyst's read, marked: the fold (A10.3f, built §444) and knock-out are COMPLEMENTS, not
alternatives — fold is per-zone within a pane, knock-out moves a group out of it. **Both are wanted;
only the second answers a budget.** ★ Nothing about A10.3f's landing is wasted either way.

    —— THE OPTIONS AS FIRST WRITTEN, kept so the false premise is visible ——

    a  DEFAULT SOME ZONES FOLDED   A10.3f's fold (built §444) is exactly the mechanism for a
                                   pane that does not fit. ⚠ But WHICH zones open by default
                                   is a taste decision, and a pane that opens mostly closed
                                   is a different product from one that opens showing its work.
    b  THE PANE GROWS              600 is `object.lua`'s own number, not a client limit.
                                   ⚠ `Options.Fits` exists; whether the screen budget allows
                                   714 is his, not the bench's.
    c  FOLD AND REPLACE TOGETHER   do A10.2a and A10.3's replacement as ONE step, so the
                                   removal pays for the addition. ⚠ Contradicts A10.2d's
                                   *"both, not or"*, which exists so nothing is torn down
                                   before its replacement works.

★ The bench's read is **(a)**, because the fold is built and costs nothing further — but the
DEFAULTS are the decision and they are taste, which is the one thing this bench does not own.

### ✅ WHAT LANDED ANYWAY — the capability, which is needed under every option

**`Layout.SetFolded` / `IsFolded` / `Foldable` (A10.3f), mutation 5/5.** A zone collapses to its
HEADER and back; the header stays SHOWN; nothing is rebuilt, so an unfold cannot come back from
defaults. ⚠ A headerless zone REFUSES to fold — with nothing left on screen it would read as
`hidden`, and that distinction is the whole point:

    hidden   declared · per subject · the whole zone goes, leaving no gap
    folded   chosen   · per zone    · rule + header stay, rows go

⚠ **A TEST DEFECT WORTH RECORDING:** the header row first asserted `FZ.label and FZ.rule` —
their EXISTENCE — and a mutation that HID them walked straight through it. The fold behaved
exactly like a hide with the row green. ★ The frame model tracks `IsShown`, so it now asserts
the visible thing rather than the object.

### ✅ AND THE DECLARATION WAS REVERTED, deliberately

`panespec.lua` is back to its committed state. ⚠ Landing a declaration that overflows the pane
would leave a red smoke standing as the record of an open question — and a red suite stops
being information the second it is normal. The three go in with the answer.

## RI-45 · L1.1's SIZING, MEASURED — the declared pane EXISTS and `object.lua` does not use it

**RI-45 DRAINED (Analyst, 2026-08-21)** — both halves answered in acceptance; no ruling was
needed from Battlewrath.

    Q  does A10.2b MEAN Ace's option table, or NAME a property?
    O  **(b), the bench's read — and the ambiguity was MINE.** A10.2b now names the PROPERTY:
       *declared, not hand-placed, with a get/set per control*.
    ✗  it does NOT mandate Ace's option table · `Spec` is NOT superseded · the `check_interface`
       1:1 join does NOT move
    ✓  `panespec.lua`'s `Spec` satisfies it, is BUILT, and is checked 1:1 · which renderer the
       pane uses is the BENCH'S (mechanism is gears)
    →  A10.2b (reworded)

    Q  can A10.3i close E-0's author side alone?
    O  **NO — it depends on A10.3g/h**, and the bench was right to refuse to invent the policy.
    ✗  do NOT route two independent dropdowns through `SetRow` · do NOT invent a
       half-authored-row policy to close E-0 early
    ✓  a TAB IS ADDED AS A UNIT, so a row is complete when it exists · the container is already
       vendored (`AceGUIContainer-TabGroup.lua`)
    →  A10.3i (dependency stated)

★★ **AND THE ITEM CORRECTED A FALSE COMMENT THAT WOULD HAVE MISLED THE SIZING:** `Spec.Build`
claimed *"`object.lua` and `smoke_dungeonrunpromoter.lua` walk the SAME function"* — and
`object.lua` walks neither `Spec` nor `Layout`. ★ A reader would have believed the object pane was
already declaration-driven, **which is exactly the belief L1.1's sizing turns on.**
⟶ So L1.1 is not *write a fold* — it is **WIRE THE ONE THAT EXISTS**. Materially smaller than the
chain line reads.
★ The bench also WITHDREW its own vocabulary question unprompted, with the reasoning kept. That is
the channel working in the direction it was built for.

**Filed by the Addons bench, 2026-08-21 (§442), orienting before L1.2 as instructed.** ⚠ Nothing
here is a ruling; each line is a measurement with its citation.

### ✅ THE PRECONDITION IS MET, so the fold may start

`A10.2 PRECONDITION` wants the runtime lookup before the first fold. ★ `adaptor.lua` is that one
lookup, and `object.lua:156` records **`SENSE_TEXT` and `ROLE_TEXT` RETIRED HERE**.

### ★★★ THE MEASUREMENT THAT CHANGES THE SIZING

    panespec.lua        THE OBJECT PANE, DECLARED (§101) - zones, subjects, controls, as DATA.
                        Exports `Spec`, and `Spec.Build` IS REACHED - by `check_interface.py`
                        and a smoke. **The declaration is built and it is checked.**
    layout.lua          `Layout.Apply` / `Layout.Height` reached by `smoke_dungeonrunpromoter`.
                        **The engine is built and PROVEN on another pane.**
    object.lua          calls NEITHER. **43 literal `SetPoint`.**

⟶ **So L1.1 is not "write a fold" — it is WIRE THE ONE THAT EXISTS.** The declaration, the
engine and the 1:1 checker are all in place and only `object.lua` still hand-places. ★ That is a
materially smaller and better-founded step than it reads as from the chain line.

### ✅ WITHDRAWN 2026-08-21 (§443) — THE VOCABULARY QUESTION WAS THE BENCH'S, NOT THE INBOX'S

**Battlewrath asked plainly: *"is it an inbox question?"* — and it is not.** ★ The reasoning,
so the withdrawal is not just a retraction:

    the TEST governs, not the prose   A10.2c grades *"the folded pane's file contains NO
                                      literal `SetPoint`"* — a PROPERTY. `Spec` delivers it.
    the burden is on the artefact     `Spec` is built AND checked (`check_interface` 1:1).
                                      An Ace options table would have to demonstrate why it
                                      is NEEDED; *existing is not a reason to ship*, and
                                      neither is a field list matching Ace's wording.
    mechanism is GEARS                intelligence in DESIGN, transform in static gears. Which
                                      renderer the pane uses is the bench's to answer.

⚠ **Why it got filed anyway: A10.2b's field list matches Ace's word for word and that spooked
me.** That is not a reason to spend his attention, and naming it here is cheaper than the
habit.

### ★★ TWO MEASUREMENTS THAT CAME OUT OF CHECKING BEFORE WITHDRAWING

**1 · `Layout` CAN HIDE A ZONE; IT CANNOT FOLD ONE.** `Layout.NewZone` takes
`hidden = function(subject) -> true to omit entirely`, and a hidden zone *"does not leave a
gap"*. ⚠ A10.3f wants **fold to its header and back** — the header STAYS and the content
collapses — and `hidden` is a function of the SUBJECT, not a user toggle. ⟶ **Different
behaviour, and L1.1 gains one capability rather than none.** Bench work, not a question: the
SHAPE is already ruled by A10.3f's own text.

**2 · ⚠⚠ `Spec.Build`'s OWN COMMENT WAS FALSE, and it was the one that mattered.** It read
*"`object.lua` and `smoke_dungeonrunpromoter.lua` walk the SAME function"* — the anti-drift
join, stated as fact. **`object.lua` walks neither `Spec` nor `Layout`.** ★ A reader would have
believed the object pane was already declaration-driven, which is precisely the belief L1.1's
sizing turns on. Corrected §443; it may name `object.lua` again the day the fold lands.

### ⚠ WHAT STAYS AN INBOX QUESTION — one thing, and it is authoring behaviour

`A10.2b` says each folded control is **an option-table entry** (`type · name · order · hidden ·
values · get/set`) — Ace's shape. §101's `Spec` declares **zones / subjects / cells** — the
project's own. **Both exist; they are different shapes.**

    a  A10.2b MEANS Ace's option table   ⇒ `Spec` is superseded for this pane and the
                                            `check_interface` 1:1 join moves with it
    b  A10.2b NAMES THE PROPERTY          ⇒ "declared, not hand-placed, with a get/set per
       and `Spec` IS the fold                control" - and `Spec` already satisfies it

★ The bench reads (b) — A10.2c's test is *"the folded pane's file contains NO literal
`SetPoint`"*, which is about the PROPERTY rather than the library, and `Spec` delivers it. ⚠ But
A10.2b's field list is Ace's vocabulary word for word, so the reading is not free.

### ✅ AND A10.3's STRIP HAS ITS WIDGET ALREADY

`AceGUIContainer-TabGroup.lua` is vendored in the TOC. ★ A10.3g's tab-in-tab and A10.3h's
`Action 1 · add action · Action 2` need no new container.

**A10.3i CANNOT CLOSE ALONE — it needs the strip, or a ruling.**

`Routes.SetRow` *"writes the whole declaration or it writes nothing"* (RI-17): it requires a
valid sense AND a valid action, so it cannot store a half-authored row. ⚠ `object.lua` today
offers sense and action as **two independent dropdowns**, so routing each through `SetRow` would
silently drop the author's first pick — against `A10.4a` (*"TELL, never lock"*).
⟶ **What is unruled is how the pane holds a HALF-AUTHORED row.** With the strip (A10.3g/h) the
question may not arise, because a tab is added as a unit. Without it, closing E-0 means inventing
that policy, and the bench will not.

### ✅ BUILT THIS PASS, off the same orientation

`inspect_route.py` on the RFC scrape reported **"child 1 of beacon 1 has no radius"** against a
beacon with **ZERO children**. ★ There is no child 1 — the beacon IS the node (A1.2). Row 24
wants a refusal that names what was missing; that one named something that does not exist. Fixed
§442: the refusals say **"beacon 1 has no radius"** when the beacon is the node. Same class as the
invented `CID` in the address, one message over.

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

## RI-19 · THE GOLDEN WATCH — `walk.py check` cannot reach W1 or W5

**RI-19 DRAINED (Opus 5 Analyst, 2026-08-19) — WITHDRAWN, never true.** ⚠ Stamped per RI-29:
the withdrawal was in the text and not in the STAMP, so the file's own convention
(`grep "RI-N DRAINED"`) still read it as an open question. **A record-keeping gap, not a
decision** — and exactly the kind that makes a "no hanging items" claim measurably false.

**RI-19 WITHDRAWN — IT WAS NEVER TRUE (Opus 5 Analyst, 2026-08-19).** ⚠⚠ The defect this item
reported had already been fixed at **`5725b7d` §376 — *"RI-19 (a) - `walk.py check` now covers
every body, one exit code"*** — a commit that was an ancestor of HEAD before this session
started. `walk.py check` prints `BODIES: W1 PASS · W5 PASS` and returns one exit code for all
five bodies.

⚠ **How it was got wrong, stated exactly, because the mechanism matters more than the item.**
`main()` begins at `walk.py:1754` and builds its aggregate at **`:1777-1783`** — inside the very
range I read (`1752-1872`) and reported on. I also ran the tool and piped it through `tail -6`,
which cut off the `BODIES` line that would have contradicted me. ★ **I inherited the claim from
the sense proposition's stale A9.5 note, then read the source looking for the mechanism of a
defect I already believed in.** Confirmation, described as measurement.

★ **What survives:** A11.7a's REWORDING is still the right criterion — one command over every
body, one exit code, hooked to landing — and it is now SATISFIED rather than red. The row is
updated. ⚠ The coverage sub-agent inherited this false claim as its O8; that report is history
and is not corrected in place.


_Filed 2026-08-19 by **Opus 5 — Design/acceptance setter**. ⚠ This item is mostly MEASURED FACT.
The acceptance rewording under it is mine and TAKEN, not asked; one build-shape choice is the
bench's and carries options. A9.5 named this blocker; what follows is its exact shape._

### What was measured (2026-08-19, read-only, on the tree as it stands)

    py addons/tools/walk.py check     PASS - every W2/W3/W4 golden reproduced
    py addons/tools/walk.py w1        PASS - all ten criteria
    py addons/tools/walk.py w5        W5.4 PASS · W5.6 all three goldens SAME

★ **The goldens have NOT drifted.** `w5_SFK_live` · `w5_SFK_Run4` · `w5_rfc_combat` all read SAME.
The reference the Lua port will be graded against is intact today. This item is not about their
contents.

### The finding — one notch wider than "the goldens are unwatched"

`main()` (`addons/tools/walk.py:1752`) gates by MODE. `w32`, `w5` and `w1` each return early;
`check` then falls through to `w2` / `w3` / `w4` and nothing else. So:

1. **The three w5 goldens are unwatched BY CONSTRUCTION**, not by neglect. `w5_6` already does the
   right thing — absent → WRITE and say so, present → COMPARE, `--regold` the only way to move one,
   named so it appears in the shell history of whoever moved it. It is a working watch that the
   only routine command cannot reach. ⚠ The docstring is honest (`check` = "all three", meaning
   W2/W3/W4); the gap is between the acceptance rows and the aggregate, not inside the tool.

2. ★★ **AND W1 IS OUTSIDE THE AGGREGATE TOO — this half has not been named anywhere.** W1 is the
   RULE's own ten structural criteria, and `driver_sense_acceptance.md` A11.2 grades the port
   against exactly those: **W1.3** the mapID straddle · **W1.7** the walkway band at the
   interpolated z · **W1.9** the clamp · **W1.10** the gap bound. A11.2's own mutations are written
   as "→ W1.3 fails", "→ W1.7's walkway fixture fires where it must not". So the port's fidelity
   rows point at criteria the routine check does not exercise.

⚠ **The failure mode is the one this project keeps finding:** a green that means less than it
looks like. `walk.py check` PASS reads as "the desk is sound" and covers three of five bodies of
criteria. Same class as §322's dead registrations and A4.2's tests that pass in either world.

### The one thing that is the bench's to choose

Where "watched" is made operational. All three are cheap; none is a new instrument.

    a  `check` ABSORBS w1 and w5 - one command, one exit code, non-zero if any body fails
       ⚠ changes what `check` has meant since it was written; its docstring line moves too
    b  a NEW `all` mode; `check` keeps its current W2/W3/W4 meaning
       ⚠ two aggregate words, and the wrong one is the one already in every doc and runsheet
    c  modes untouched; the LANDING HOOK runs all three commands
       ⚠ the contract lives in the hook, not the tool - invisible to anyone running by hand

**Opus 5's read (marked as mine, overturnable in a word): (a).** The reason is not tidiness — it is
that the failure being guarded against is *someone runs the documented command and believes it*.
(b) leaves the believed word covering three fifths; (c) leaves it covering three fifths for every
hand-run. ★ And the tell that (a) is right: A11.7a's own mutation — perturb a w5 golden by one byte
→ the check reds — **passes at the `w5_6` layer and fails at the aggregate layer today.** Under (a)
the mutation and the command finally describe the same event.

    IMPACT
      on disk now      addons/tools/walk.py main() mode gate + its module docstring line 22
                       ("check  all three against the stated goldens") - the word "three" moves
      shipped guards   NONE break. All five bodies pass RIGHT NOW (measured above), so this is a
                       coverage change with no expected red - ⚠ which is exactly why it is easy
                       to defer and exactly why it will not announce itself later
      criteria         A11.7a REWORDED (below) · A11.2's mutation rows gain a runner that
                       actually executes them
      does nothing to  the goldens' contents · W7.1 byte-equality · the row shape (A11.1) ·
                       the isolated load (A11.6a) · anything in the UI leg

### The rewording I am taking as acceptance setter (not a ruling request)

**A11.7a**, from *"the three `w5_*.golden.txt` files are WATCHED — `walk.py check` (or a sibling)
runs them on every landing"* to:

> **A11.7a** ONE COMMAND runs every body of desk criteria — W1 (the rule's structure), W2/W3/W4
> (the calibration goldens) and W5 (including W5.6's three golden comparisons) — and returns
> non-zero if any of them moves. That command is hooked to landing. **Test:** perturb a w5 golden
> by one byte → the aggregate reds; run the aggregate with W1 deliberately broken → it reds.
> ⚠ The row is RED while any body sits outside the aggregate, whatever the bodies individually
> report. Measured 2026-08-19: all five pass individually; two are unreachable from `check`.

Rationale for the change of wording: the old row could be read as satisfied by *"someone runs
`walk.py w5` before a landing"*, and a golden watched by remembering to watch it is the thing the
row exists to forbid. ★ It also promotes P1 from a chore to a shaped task — the bench's own
accepted build order already puts it first, and it is now specified rather than asserted.

**Needs one word:** the (a)/(b)/(c) choice above — and it is the BENCH's word, not Battlewrath's,
unless the bench would rather it were ruled.

**Analyst (Fable) read, 2026-08-19:** measurements REPRODUCED by running (`check` PASS · `w1` PASS
all ten · `w5` W5.4 PASS, W5.6 all three SAME). The finding is right and one notch sharper than
A9.5 named it — W1 outside the aggregate is the half that A11.2's own mutations depend on. The
rewording is APPLIED to A11.7a (it was written here, not in the row — applied now, marked as the
stand-in's wording reviewed by the Analyst). (a) agreed: the command people believe must cover what
the rows cite; (b) splits the believed word, (c) hides the contract in a hook. The bench's word;
nothing waits on Battlewrath. ⚠ For the stand-in: print the role line (`Analyst.`) as the first
line of every response — Battlewrath's standing instruction for this seat — and when taking a
row's wording, LAND it in the row in the same turn, not only in the inbox; the inbox is a channel,
the row is the record.

---


---

## RI-22 · BAND becomes OPTION BANDS — and the reach door has no guard

**RI-22 DRAINED (Battlewrath 2026-08-20 - his best working model, not a ruling; records
reconciled by Opus 5 Analyst) - THE BAND IS UPWARDS ONLY.**

    the shape     ONE upward value. Not a pair, not a symmetric list, not named pairs -
                  the option-shape question dissolves because there is no downward half.
    the default   2.5 yards.
    the placement ADVANCED. "More of a advances option than every day setting, so bottom
                  of the list."
    the store     THE NUMBER. "Store the number. The choice is a look up."

* HIS REASON, and it is corroborated rather than taken: "our data points are captured from the
floor level." ROUTER 280 has a unit's z as its BASE POINT (emulator source), so a sample IS the
floor and downward tolerance measures nothing. And 2.5 up covers the measured jump apex of
~1.64 (ROUTER, four flat jumps read between IsFalling's edges).

! VERIFIED, AND BOTH OF US HAD IT WRONG FIRST. He recalled the tests as "up 2.5, not +/-";
measured, W3.2's candidate row passes BAND_CANDIDATE as BOTH up and down (walk.py:1360) and
W1.7's fixtures say "band +-2". I claimed the change "moves every w5 golden"; measured, the
goldens are produced with bands OPEN and say so in their own header - "Bands are OPEN here. The
band is a SEPARATE criterion (W3.2)". -> What actually moves is W1.7's fixtures and W3.2's sweep.
The rule already takes band_up and band_down separately, so up-only is band_down = 0, not a
signature change.

-> UNBLOCKS the reach and band pickers (A10.3e). Records: A1.3's raw-nil wording, W1.7, W3.2,
setReach's third argument.


_Filed 2026-08-19 (§383) by the **Addons bench** at Battlewrath's ask: **"I'll bring in reconcile,
but follow form. Option bands, but most likely won't be used. Just correction for when their
application needs some head room on detection."** Follows the P1/P2 landing in RI-20._

### ⚠ FIRST, A CORRECTION TO THE PREMISE — Band IS expressed in code

Battlewrath, same turn: *"Band has had no code expression yet for the addon. We hand wrote it in
our py golden tests."* ⚠ **Measured, and that is not the state on disk.** Band has a shipped
authoring path:

    object.lua:478-479   upBox / downBox - FREE-ENTRY EditBoxes, with HasFocus guards
    routes.lua:1210      setReach(p, radius, up, down)
    routes.lua:1269      Routes.ReachOf - the A1.1 pure accessor, returns all three
    adaptor.lua:64-65    bandUp -> "up" · bandDown -> "down"

★ **It is true that the RULE was written in `walk.py` first** (60 references) and that the golden
fixtures are hand-written — but the addon has both a store and an editor for it. **So this item is
a CHANGE TO SHIPPED UI, not a greenfield decision**, and the same applies to the pre-config radius
landed in §381c: `radBox` is the identical shape.

### ★★★ AND THE LOOK FOUND SOMETHING WORTH MORE THAN THE BAND ANSWER

`setReach` is `p.radius = tonumber(radius) or p.radius`, three times. Measured on our own
Lua 5.1.5 (`.tools/lua51`), 2026-08-19:

    tonumber("abc")    -> nil        the `or` keeps the OLD value. No feedback, no red.
    tonumber("")       -> nil        same
    tonumber("-5")     -> -5         a NEGATIVE radius, stored
    tonumber("1e400")  -> 1.#INF     ★★ and it PASSES the `or` guard - Inf is truthy

**⚠⚠ SO INFINITY ENTERS THE STORE TODAY, FROM A TYPO, THROUGH THE SHIPPED EDITOR.**
`driver_sense_acceptance.md` A11.2e says the DRIVER rejects NaN and Inf — and there is a producer
upstream manufacturing Inf, which nothing between them would notice.

★ **That makes RI-20 P2a and P3 LIVE INSTANCES rather than format questions**, and it changes what
they are asking. Not *"what should the format do with a non-finite"* but *"the editor has no door
guard, and the driver's rejection is the only thing standing there."* ⚠ A guard at the far end of
a pipe is not the same as a guard at its mouth: the value is already stored, already exported,
already shared before the driver ever sees it.

⚠ **The bench is NOT fixing this in this item.** It is recorded because it lives in the exact
function the Band change touches, and whoever takes that change should know the guard is missing
BEFORE they move the field rather than after.

### The change itself

Band moves from FREE ENTRY to an OPTION SET — the config class from §382, joining senses, actions
and the radius menu. Battlewrath's framing: *"most likely won't be used. Just correction for when
their application needs some head room on detection."*

★ **Which is a design fact worth carrying, not just a note:** Band is an EXCEPTION KNOB, not a
routine authoring field. The common case is "none". That argues for a default that costs nothing
to express and for the option list to be short and coarse rather than fine.

    a  ONE option list, symmetric - the author picks a band and it applies up and down
       ★ simplest; ⚠ loses the up/down asymmetry the store and the rule both already have
    b  TWO indices, up and down, from the SAME option list
       ★ keeps the existing shape exactly; costs one more slot on the line
    c  ONE index into a list of PAIRS (none · small · tall-up-only · ...)
       ★ one slot, and asymmetry survives as authored combinations
       ⚠ the list is a taste artifact - somebody has to choose the useful pairs

**Bench read (marked as the bench's, overturnable in a word): (b).** ⚠ Not because it is best in
the abstract — (c) is tempting and cheaper on the line — but because **`walk.py` and `ReachOf` and
the store and the editor all already carry up and down as independent values**, and (b) is the only
option that changes nothing but the input widget. (c) asks somebody to invent a pair list for a
field Battlewrath expects to be mostly unused, which is invention in a place the basis says not to
invent. ★ If the line's width ever matters, (c) remains available as a later projection — the
export can compose a pair index from two stored values, which is the same composing law as
`Stage:Step`.

    IMPACT
      on disk now      object.lua:478-479 (two EditBoxes -> a picker) · routes.lua:1210
                       setReach (accepts an index, or is fed one) · adaptor.lua:64-65 gains
                       the option words · the new option table itself, wherever config lives
      shipped guards   ⚠ A1.1's ReachOf is a PURE ACCESSOR and stays pure - it returns what
                       is stored and does not care where it came from. The smoke rows that
                       assert reach values keep passing IF the stored form stays numeric;
                       if the store holds an INDEX instead, every one of them moves.
                       ★ THAT IS THE REAL QUESTION UNDER (a)/(b)/(c) AND IT IS NOT ASKED
                       ABOVE: does the STORE hold the index, or the resolved number?
      criteria         A11.2's fidelity rows gain a bounded domain for band (a small win) ·
                       nothing in W1 moves - the RULE is unchanged, only the authoring
      does nothing to  the sense rule · the row grammar · the note tables · the UI leg's
                       Ace3 work · the reader/data split

### ⚠ THE QUESTION THE OPTIONS ABOVE DO NOT COVER

**Does the STORE hold the index, or the resolved number?** §382 settled what goes on the WIRE
(config-class values need not ship). It did not settle the store. Both work:

    STORE THE NUMBER   ReachOf and every smoke row are untouched; the picker resolves on the
                       way in. ⚠ And a config change later does NOT retro-apply to old routes.
    STORE THE INDEX    a config change moves every route that used it. ⚠ And ReachOf either
                       stops being pure or starts returning indices, which A1.1 forbids in
                       spirit if not in letter.

★ **The bench leans STORE THE NUMBER**, because A1.1's pure accessor is a shipped, tested
property and the other option trades it away for a retro-apply nobody has asked for. ⚠ Marked as a
lean, not a read — it is genuinely a design call about whether a config edit should reach backwards
into authored routes, and that is a taste question about authoring, not a structural one.

---


---

## RI-24 · THE STORE INVENTORY — two fields with no consumer, and one disposition owed

**RI-24 DRAINED (Battlewrath 2026-08-20 - his best working model, not a ruling; records
reconciled by Opus 5 Analyst) - THE FIELD IS NOT SPECULATIVE, IT IS WRONGLY SOURCED.**

> "Nothing scraped about the character should leave into export. That's for the user to disclose
> what characters they play. Who, When, Author notes? (Like Weak Auras. Doesn't disclose the
> character / account who authored.)"

** THE QUESTION WAS THE WRONG ONE and his answer replaces it. This item asked keep-or-drop.
`route.author` is minted as `UnitName("player")` (routes.lua:121) - that IS scraped character
data, and shipping it in an export is disclosure the author never made. -> The disposition is
neither: the field is REPLACED by user-supplied metadata.

    OUT   author = UnitName("player")     scraped, and travels
    IN    who / when / author notes       the author types them, or leaves them empty

* It lands on a law already on file - RI-4's "the origin on someone else's data does not travel"
- and on the bench's own manners: read-only on data that is not ours.

! WIDER REACH, named not acted on: `runs[].character` is the same shape on the capture side. A
run is EVIDENCE and never travels (store.lua, 61), so it is not a leak today - but it is the same
field minted the same way, and whoever builds export should meet this sentence before they meet
that one.

_★ **BENCH UPDATE 2026-08-20 (§392, §400) — two of this item's three parts have landed, and
only D-2 is still a ruling.**_

    D-1  `fireOn` RETIRE          ✓ BUILT §392 (A2.12). Setter removed whole with a
                                  headstone; a stored value dropped and TOLD through
                                  `DropRetired`, on every load. Five mutations bite.
    the `store.lua` HEADER        ✓ FIXED §400. This item's own finding - the `Shape:`
                                  block said `schemaVersion = 1` (it is 2), keyed `runs`
                                  by NAME (keyed by id since A8.4), and named none of
                                  `routes` · `routeNotes` · `notes` · `ui`, all four of
                                  which that file creates. ⚠ REMOVED rather than
                                  corrected: correcting it would have rebuilt the thing
                                  that rots. It now POINTS at the curated fact and the
                                  emitted evidence, and keeps only the composite shapes
                                  (`<point>` · `<marker>` · `<leg>`) the emitter cannot
                                  say. **The only safe mirror is no mirror.**
    D-2  `author` / `madeAt`      ⚠ STILL OPEN - Battlewrath's word, unchanged.

_Filed 2026-08-19 by **Opus 5 — Analyst**, at Battlewrath's ask: **"We need a heading fixed-ish on
our data model before we over build selections. We need an inventory of what is stored and how. And
then flatten that into a going forward fact. I'd rather re-write now and sort our debt, than
tangle."**_

**THE TWO ARTEFACTS:**

    addons/tools/emit_store_inventory.py       the machine
    addons/planning/history/store_inventory.md   EMITTED evidence - never hand-edit, re-run it
    addons/planning/driver_stored_state.md     ★ THE GOING-FORWARD FACT: the root, the records,
                                               the six laws the store already obeys, the debt

### ⚠⚠ THE FINDING THAT JUSTIFIES EMITTING RATHER THAN WRITING

`store.lua`'s own header carries a `Shape:` block describing the saved-variables table. It
documents `runs`, `markers` and `legs` — and **does not mention `routes`, `routeNotes`, `notes` or
`ui`, all four of which the same file creates.** ★ The one authoritative description of the store
had stopped being one, silently. A hand-written inventory would have been the same thing again.

### ★ THE APPARATUS CORRECTED ITSELF THREE TIMES, and each correction is a fact about the store

    1  the extractor missed indexed writes, indented constructor pairs and single-line
       constructors      -> caught by --check BEFORE any list was emitted
    2  scanning only COA_DungeonRun/ called `bosses` and `names` dead - the SMOKES assert on
       both (smoke_dungeonrun:366-368).  ⚠ A debt list that cannot see the test suite marks
       tested fields as dead, which is the one way this tool could do real damage
    3  scanning only Lua called `testPinSet` dead - `walk.py` reads it off a landed run.
       ★ THE SAVED FILE IS A CONTRACT BETWEEN TWO LANGUAGES and the inventory has to see
       both ends of it

⟶ debt list 35 → 15 → 11, every cut from a measured hole rather than from judgement.

### The two that are real

**D-1 · `fireOn` — RETIRED BY RULING, STILL SHIPPED.** `Routes.SetChildFireOn` (`routes.lua:1351`)
stores `child.fireOn` as `start | update | complete`, and **has no caller anywhere** — no pane, no
smoke, no interface row. RI-5: *"There is NO firing field — G15 IS the during/when-off pairing."*
**Analyst read:** RETIRE whole, the way A2.6 retired `goTo` and `onRamp` — with `DropRetired`
telling and dropping a stored value on load. ⚠ It survived that clean-out once already, which is
the argument for removing rather than parking. **Bench work; no ruling needed unless you disagree.**

**D-2 · `author` and `madeAt` — stored on every route, read by nobody. NEEDS ONE WORD.**
Minted at `routes.lua:121-122` as `UnitName("player")` and `time()`.

    a  KEEP - they are the route-level provenance RI-4's export ruling turns on
       ("the import landing becomes the new origin"; "the origin on someone else's data
       does not travel"). ⟶ they gain a named consumer and a criterion when export lands.
    b  DROP - speculative fields with no consumer and no named future, minted on every
       route since the day routes existed.

**Analyst read (marked as mine): (a)** — the export ruling already needs the material, and a field
about to acquire a consumer is a different thing from a dead one. ⚠ But that is a guess about what
export will want, and the guess is exactly what this pass was run to stop; **it is your word.**

    IMPACT
      on disk now      routes.lua:1351 SetChildFireOn (D-1, a removal) · routes.lua:121-122
                       (D-2, two mint fields) · nothing else moves either way
      shipped guards   NONE break. ⚠ `fireOn` has no test, which is why it survived - a
                       removal wants a DropRetired-style mutation the way A2.6's did
      criteria         a new row if (a): what provenance survives an import, testable at
                       the same time as A8.5's export-travel half
      does nothing to  the line · the sense rule · W1-W7 · the pickers · the UI leg


## RI-26 · G5 — THE REPRESENTATION, and it now blocks a queued build step

**RI-26 DRAINED (Battlewrath 2026-08-20 - his best working model, not a ruling; records
reconciled by Opus 5 Analyst) - A SERIALIZED STRING, TWO-STAGE LOAD.**

    the transport   AceSerializer (shipped, Ace3/wotlk-r960) -> LibDeflate compress ->
                    LibDeflate:EncodeForPrint, behind a VERSION PREFIX.
    the load        TWO STAGES. 1) decode and PRESENT - map, route name, bosses - and ask
                    "save this as a route?" (the WeakAuras shape). 2) on accept it becomes a
                    saved route, written to SavedVariables on reload or logout.
    the surface     a MULTI-LINE EDIT BOX, never chat. ROUTER:123 - the chat edit box is
                    capped at 255 letters and a route is ~2 KB.

* WHAT THE CHOICE COST, corrected before he took it: the Analyst said it needed TWO libraries we
do not ship. LibDeflate is on this machine TWICE - vendored in TidyPlates_ThreatPlates and in the
WeakAuras copy under export/ - and it bundles the encoders, so it is ONE library, and WeakAuras
uses it ON THIS FORK. The cost claim was asserted without looking.

** AND THE PREVIEW IS FREE. Stage 1 needs map, route and node NAMES plus the run-derived boss
names - which are exactly the two side tables A2.6 already defines and the driver never opens.
Nothing extra is carried to make the preview work.

** A4.17 IS OVERTURNED BY THIS, and by nothing else: a version prefix ships from the FIRST string.
The deferral held while a reader could look at what they got. Under an opaque blob a decode
failure and "this is from a newer version" are the same event, and WeakAuras carries `!WA:2!` here
for that reason.

! THE TENSION HE NAMED, DEFERRED ON PURPOSE (Battlewrath, 2026-08-20): "there is a tension with no
chat use... this is for people meeting for a session. So there is no external source in that
moment. So we'd need a batch share protocol between users via a hidden channel when they share.
But that's deferred. No chat user facing route is fine."
-> SEEDED as S12 rather than designed. * And the transport already accommodates it: LibDeflate
ships EncodeForPrint AND EncodeForWoWAddonChannel, so the session-sync path is an ENCODER SWAP
plus chunking, not a format change. ! The per-message size cap on this client is NOT RECORDED in
ROUTER - a client fact to measure the day it is built, not to assume now.


_Filed 2026-08-19 by **Opus 5 — Analyst**, after a sub-agent coverage audit found that the model's
own **"★ THE NEXT THING TO DECIDE"** (`driver_data_model.md` §B, G5) had **no item in this channel**
— so the decision the heading says comes next had no route to the person who makes it. ★ That is
the finding, not the question; the question below has been open since `history/data_model_findings.md`
O1._

**WHY IT IS URGENT NOW, measured.** The sense brief's build order **P2** is *"the row SHAPE as a
declared contract + fixture list"* (`driver_sense_acceptance.md`) — **P2 builds the artefact G5
decides the shape of.** P3 and P4's fixtures are then built on P2's output. A wrong start here does
not stay local.

### The question

**How is a record represented on the wire, and do behaviours NEST inside the node's record or sit
as SIBLING records?** These are one question because the answer to the first constrains the second.

    a  POSITIONAL TEXT, siblings.  One line per record, fields by position, delimiter-separated;
       behaviours are their own lines sharing the node's address.
       ★ GatherMate ships exactly this (`string.format("%d:%s:%s:%d", ...)`) - the only shape
         with a peer precedent in a live addon
       ★ "an empty slot means absent" is expressible, which the model already relies on
       ⚠ CANNOT skip a variable-width unknown - so it must carry a version if it ever grows
         (RI-20 P1, and D10's MAVLink correction: only a FIXED-width payload is skippable)

    b  KEYED / STRUCTURED.  Field names present; behaviours may nest as a list on the node.
       ★ field ORDER stops costing anything, and G6/Q5's ingest order assertion becomes belt
         over braces rather than the only guard
       ★ nesting is natural, so 1 read per node rather than 1 + N
       ⚠ heavier on the wire, and the wire is a string a person pastes into chat
       ⚠ ⚠ it makes the format SELF-DESCRIBING, which is the property that would let a stale
         reader silently accept a record it does not fully understand

    c  POSITIONAL, NESTED.  One line per node carrying its behaviours inline as a repeating group.
       ★ fewest records, and the node/tab relationship is visible in one line
       ⚠ a variable-length repeating group is EXACTLY the variable-width unknown (a) cannot
         skip - it takes (a)'s cost without (a)'s simplicity

**Analyst read (marked as mine, overturnable in a word): (a).** ⚠ Not because it is elegant — (b)
is more forgiving to write and to read. Because **(a) is the only one with a shipped peer
precedent**, because *empty means absent* is already load-bearing in the model (`§A3.10`, stage 0),
and because the read-count argument for (b) was measured away: reads are an INGEST cost paid once,
and the 1 Hz pass walks buckets, never records (`A11.1a`, `#3 §A5.19`). ⚠ **The honest cost of (a):
it is the option that will need a version token first**, and A17 currently says we need none — that
is true today because there is no installed base, and (a) is the choice most likely to change it.

    IMPACT
      on disk now      NONE - there is no exporter and no importer. ★ This is the last moment
                       it is free; P2 is the step that stops it being free.
      blocks           sense P2 (the contract file) -> P3, P4's fixtures. Nothing else.
      criteria         A11.1a's contract row · A11.1c (the no-free-text smoke, which is
                       written against a token stream and would need re-aiming under (b))
      does nothing to  the store (already node-major) · the sense rule · W1-W7 · the UI leg ·
                       the two side tables · the driver's read order

## RI-27 · TRIGGER — a node field, not built, and its default

**RI-27 DRAINED (Battlewrath 2026-08-20 - his best working model, not a ruling; records
reconciled by Opus 5 Analyst) - TWO AXES, HELD APART.**

    retry while incomplete    the DEFAULT BEHAVIOUR. Completion ends it. NOT a control.
                              "the ratchet tells the instruction to stop listening, so whilst
                              active, they can repeat try the stage/step until the action tabs
                              are complete."
    run again after complete  TRIGGER. Default NO; opted into per node.

** Holding them apart is what settles it, and conflating them is what made this item circle for
an afternoon.** Both of his cases are STAGELESS and want opposite answers - a recovery beacon must
not re-set once consumed (no), a "get back on course" marker should speak whenever you are there
(yes) - which is only expressible because the second axis exists and is authored.

* **His frequency read, recorded as shape rather than as a rule:** *"We might want to repeatably
force a note when in a area that clears it's own note. But generally a dungeon is sequential.
Course correct is a catch all."* -> the opt-in is the exception; sequential is the common case,
which is why the default is NO.

! **Still not built, and no code term is chosen** (driver_adaptor_table.md:147). Nothing waits on
this - it is drained so the DISTINCTION survives, not because a build step needed it.


_Filed 2026-08-19 by **Opus 5 — Analyst**. ⚠ **This item replaces four rewrites of itself and a
spawned RI-28, all of which reconciled an error of mine rather than a question of the project's.**
What that error was is at the foot, in four lines, because it is the only part of the churn worth
keeping._

### WHAT THE RECORD ALREADY SAYS

    the CONTROL   RI-5, 2026-08-18. The pane is exactly three - sense · what I do · IF SEEN
                  (once | every) as its own control. Time lives in the DURING | WHEN OFF
                  pairing, not here; G15 (`while`) IS that pairing.
    the WORD      driver_adaptor_table.md:147, 2026-08-18: "resolves the SEEN / IF SEEN
                  collision: Seen is the sense-word (touched me); the re-arm control is
                  labelled Trigger. Meaning unchanged (RI-5)." A naming fix, nothing more.
    ★★ NOT BUILT  the same row, verbatim: "the once | every control - NOT BUILT; code term the
                  bench's the day it lands (no identifier invented here)."

### HIS POSITION (2026-08-19, best working model)

**Trigger is on the NODE, not the action tabs.** *"That's still on the complete of all tabs. So I
think the trigger is on the node not the action tabs."*

★ **Two things in the record already agree, and neither is `ifUnseen`:** the shipped row is
`{ sense, action, arg }` with no trigger field (`routes.lua:1057`), and RI-17's grammar is three
parts, `<sense>:<action>:<arg>`. **Trigger was the only field on the BEHAVIOUR record the ruled
grammar never had.** → `driver_data_model.md` §A1.1 and A11.1a carry the move.

### ★★ THE MATCHED PAIR — why it must be authored and cannot be inferred

    a RECOVERY BEACON     stageless · ONCE        consumed; must not re-set your stage
    a COURSE CORRECTOR    stageless · EVERY TIME  "get back on course" - speaks whenever
                                                  you are there

**Both stageless, opposite answers.** So Trigger cannot be derived from the node's kind, its stage,
or its always-open status. ★ And it is a toolkit rather than a feature: a stageless node (§385c)
+ always-open (A11.3d) + Trigger every time + a note = course correction, with nothing built for it.

### THE OPEN QUESTION — the default, and it carries no risk

**Once, or every time?** His argument for every-time: *"Ratcheting already serves a lot"* — a staged
node completes and the index moves past it, so `once` duplicates the ratchet; the nodes that need
`once` are the ones outside it.

✓ **AND THE RISK I ATTACHED TO THIS IS VOID.** I claimed an every-time default would put `Set(N)`
nodes back in the re-set trap. Battlewrath: **"Set has already proven to need to fire once as a
part of node completion."** Completion owns set-idempotence — which is the same reason I gave for
retiring `ifUnseen` two paragraphs earlier in the item this replaces. **Both cannot be true and
completion is the one that is.** So the default is an ordinary authoring choice with nothing
dangerous behind it.

    IMPACT
      on disk now      NONE. The control is not built and has no code term.
      records          A10.3a's dropdown (order, default) · §A1.1's Trigger slot on the
                       CHARACTERISTIC record · the adaptor row, which already carries the label
      does nothing to  `ifUnseen` (see below) · the sense-word pairing · completion (A2.7) ·
                       the record split · W1-W7

### ⚠ NOT PART OF THIS ITEM — `ifUnseen`

**It dies with `role` when `Next(Type, arg)` lands** (Battlewrath: *"I'd say die"*), because
completion owns set-idempotence. **It is not Trigger renamed** — it is gated on `role == "set"`
in the pane (`object.lua:466`), says so in its own comment (`routes.lua:1143`), and its only
consumer tests the role first (`backlog/debug_suite/walk.lua:95`). ⟶ Carried with the `Next` work
in `driver_built_state.md`, not here. **Keeping the two joined is what made this item circle.**

### ⚠⚠ HOW THIS ITEM GOT LONG — four lines, kept as the lesson

1. The record never joined `Trigger` to `ifUnseen`. **I made that join**, then spent an afternoon
   reconciling it against documents that had been consistent the whole time.
2. I filed a gap that governing #4 had already closed (*"step-on / still-on is not a field"*) —
   the second time in one session, after RI-19.
3. I checked where `ifUnseen` is STORED and not where it is READ, which is the memory
   [[stored-field-isnt-live-check-consumption]] failing to fire on its own case.
4. Each of his refinements was written up as a position and superseded by his next sentence —
   the exact staleness-manufacture recorded in [[shaped-not-ruled]] that morning.

---

## RI-29 · "NO HANGING ITEMS" vs THE FILE — a status conflict, reported not resolved

**RI-29 DRAINED (Opus 5 Analyst, 2026-08-20) - THE SET IS EMPTY. DEVELOPMENT IS OPEN.**

His claim was "no hanging items that need reconciling" and the bench measured it false. It was.
It is now true: with RI-26 landed, this item is the last heading in the file and it is this one.

* THE BENCH WAS RIGHT TO FILE IT rather than accept the claim - the file said otherwise and a
status asserted against a countable fact is checkable. ! And it corrected itself mid-write when
RI-19 changed under it, which is why the count it reported was five and not six.

-> Derive, never read a list: grep "RI-[0-9]* DRAINED" gives the drained; every other ## RI-
heading is open. That convention is what made this item answerable at all.

_⚠ **BENCH UPDATE 2026-08-20 — THE BASIS OF THIS ITEM HAS MOVED, and it is recorded rather
than quietly dropped.** The measurement in it (*"0 stamps anywhere in the file"*) is no longer
true: RI-19 · RI-30 · RI-32 now carry stamps, and RI-19's was exactly what this item asked
for — a record-keeping gap, not a decision. ★ **So the disagreement it reported between the
record and the instruction is closed by events**, and the four instruction lines below are
moot as written._

_★ What the item was FOR still stands and is worth keeping in the drain: the file's own
convention is the only status, and a claim about state is measurable against it. **Ready to
stamp; nothing waits on it.**_

_Filed 2026-08-19 (§387) by the **Addons bench** at Battlewrath's ask: **"Put it in reconcile.
Better it's challenged and clarified."** ⚠ **RI-28 is SKIPPED** — it was spawned and withdrawn by
the Analyst (named in RI-27's own text), so reusing the number would read as that item returning._

### The conflict, stated

> **Battlewrath, 2026-08-19: *"Development should be opened up again. No hanging items that need
> reconciling."***

⚠ **Measured against this file, by this file's own convention** (*"an item is DRAINED when its text
begins `RI-N DRAINED (who, date)`; an item without that stamp is OPEN"*):

    grep -c "RI-[0-9]* DRAINED"  ->  0 stamps anywhere in the file
    open headings                ->  RI-19 · RI-22 · RI-24 · RI-26 · RI-27

⚠⚠ **AND THE FILE CHANGED WHILE THIS ITEM WAS BEING WRITTEN**, which corrects one of its own five.
Recorded rather than quietly edited, because it changes the count:

    RI-19  carries **"RI-19 WITHDRAWN — IT WAS NEVER TRUE"** (Opus 5 Analyst, 2026-08-19) —
           the defect was already fixed at `5725b7d` §376, an ancestor of HEAD before the
           session began. ★ So it is NOT a hanging question; **it wants a STAMP, not a
           ruling**, and by the file's own convention (no `RI-N DRAINED` prefix) it still
           reads as OPEN to a grep. ⟶ **A record-keeping gap, not a decision.**

★ **So the genuinely open set is FOUR**: RI-22 (bench-side) · RI-24 · RI-26 · RI-27. ⚠ And one of
those four, RI-26, is the one that says it blocks a build step.

★ **The bench is not disputing the call — it cannot see what was settled in conversation.** It is
reporting that the record and the instruction disagree, which is the one thing this channel exists
to surface. ⚠ **And it has now been wrong once inside this very item**, which is the argument for
filing rather than asserting in chat.

### What was measured (read-only, 2026-08-19)

**Tree health is GOOD** against the Analyst's landing:

    20/20 smokes (exit codes, not last lines)   ·   targets 32/32   ·   walk W1 PASS · W5 PASS

**⚠ AND THE ANALYST'S LANDING IS UNCOMMITTED.** Fifteen paths in the working tree:

    retired    driver_bench_proposition.md · driver_data_model_proposition.md ·
               driver_sense_proposition.md  -> history/
    new        driver_data_model.md · driver_built_state.md · driver_stored_state.md ·
               audit/{built_state,store_inventory,doc_comprehension_test}.md ·
               tools/{emit_store_inventory,emit_built_state}.py ·
               history/Reconciliation_inbox_drained.md
    modified   DRIVER_BASIS.md · dungeonrun_model.md · driver_programmatic_model.md ·
               driver_{authoring,sense,ui}_acceptance.md · tools/check_targets.py

**⚠ RI-26 STATES IT BLOCKS A BUILD STEP**, in its own words: the sense brief's **P2** is *"the row
SHAPE as a declared contract + fixture list"*, **"P2 builds the artefact G5 decides the shape of"**,
and its IMPACT line reads *"blocks: sense P2 (the contract file) -> P3, P4's fixtures. Nothing
else."*

★ **That is why this is filed rather than asked-and-proceeded.** Building P2 with G5 open is the
shape of §317 — *"Building code against the wrong target"* — and the bench would rather raise it
than find it afterwards.

### ⚠ AND ONE THING ABOUT THE BENCH'S OWN BASIS

**The bench has not read the new documents.** `driver_data_model.md`, `driver_built_state.md`,
`driver_stored_state.md` and the three new audits landed while this bench was elsewhere. ★ Whatever
is instructed below, **the bench reads those before it builds** — stating it here so it is a step
rather than an assumption.

### Instruction lines (a status conflict, so no deliberation — §342)

    ⚑ RI-19 is a STAMP in every line below, not a choice - it is withdrawn, not open.

    a  ALL FOUR ARE SETTLED. Stamp RI-22/24/26/27 DRAINED; development opens on everything.

    b  THE ANALYST'S THREE ARE SETTLED (RI-24 · RI-26 · RI-27); RI-22 is BENCH-SIDE and never
       gated you. Stamp the three; the bench drains RI-22 itself and opens.

    c  RI-26 STANDS. Sense P2 waits on G5; development opens on everything else, and the
       bench is told what "everything else" is.

    d  "NO HANGING ITEMS" MEANT YOUR SIDE OF THE PASS. The items stand as filed; development
       opens on bench-side work only until each is drained in turn.

**⚠ No bench read on which of these is true** — it is a fact about intent, and the bench cannot
measure intent. ★ **A bench read on the MECHANICAL part only, and it holds under every option:**
**the Analyst's landing should be COMMITTED before any development starts.** Fifteen uncommitted
paths including three file renames is a body of work that a bad afternoon loses, and every option
above builds on top of it.

    IMPACT
      on disk now      NOTHING changes by filing this. The conflict is reported, not acted on.
      shipped guards   none. All gates pass right now, which is why this is a records question
                       rather than a repair - ⚠ and why it would be easy to proceed past.
      at risk          15 uncommitted paths, 3 of them renames, none recoverable from git
      blocks           only what RI-26 says it blocks - sense P2, and P3/P4's fixtures via it
      does nothing to  the sense rule · W1-W7 · the adaptor · the UI leg · any shipped addon

---

## RI-30 · TWO NEW DOCUMENTS DISAGREE ON THE ROW — measured, one line

**RI-30 DRAINED (Opus 5 Analyst, 2026-08-20) — the bench was right and the line is fixed.**
`driver_stored_state.md` §2 now reads `ROW  sense · action · arg`, with the measurement and the
reason recorded beside it. ★ It wanted a CORRECTION, not a ruling — and the bench filed rather
than edited because the file is the Analyst’s, which is the right call and is why it was caught.

_Filed 2026-08-19 (§389) by the **Addons bench**, from orientation on the Analyst's landing.
⚠ **Not a ruling ask.** It is a factual disagreement between two documents that landed in the same
pass, measured against source. Reported rather than edited, because writing another bench's
document is not this bench's to do._

### The disagreement

    driver_data_model.md:31-38   Trigger MOVED TO THE NODE. "the shipped row is
                                 { sense, action, arg } with no trigger field (routes.lua:1057)"
    driver_stored_state.md:48    ROW    sense · action · trigger · arg

### Measured (2026-08-19, read-only)

    routes.lua:1057   rows[index] = { sense = sense, action = action, arg = arg }
    grep for a STORED trigger across addons/COA_DungeonRun/*.lua   ->  NO HITS
                      (no `.trigger`, no `trigger =`, on a row or on a node)

⟶ **`driver_data_model.md` is right and `driver_stored_state.md:48` is wrong.** ★ And the second
measurement is the stronger one: **`Trigger` is not stored anywhere at all**, which is consistent
with the model's own note that *"the control is NOT BUILT"* (`driver_adaptor_table.md:147`).

### Why it is worth a line rather than a silent fix

★ **A1.1 moved Trigger OFF the row deliberately**, and its own note says two sources already
disagreed with it having been there — costing *"an afternoon reconciling this slot against a field
that was never it."* ⚠ **A builder reading `driver_stored_state.md` §2 would put it straight back**,
because that file's whole job is to say what the store holds, and §2 is the table they would copy.

⚠ **And it is the one row in §2 that is not measurable from the emitter** — the emitted inventory
reports fields that are WRITTEN, and a field never written cannot appear in it. So the emit-and-
compare loop that keeps the rest of that file honest **cannot catch this one**, which is the reason
it is filed rather than left to the next re-emit.

    IMPACT
      on disk now      one line in driver_stored_state.md §2. Nothing in code.
      shipped guards   none. ⚠ And none would catch it - no smoke asserts the row's FIELD SET,
                       only its values (`smoke_dungeonrunroutes`), so a fourth key would pass.
      criteria         none move. A1.1 already rules the placement; this is the fact table
                       catching up to it.
      does nothing to  the sense rule · the record shapes · RI-27's remaining half (may a node
                       run again once complete) - that is the LIVE question about Trigger and
                       this item does not touch it

★ **No options and no bench read**, because there is no choice here — a measurement disagrees with
a sentence. The only judgement is whose hand corrects it.

---

## RI-31 · AUDIT SCOPE — do the remaining five follow the three into `history/`?

**RI-31 DRAINED (Battlewrath 2026-08-20) - THE FIVE FOLLOW THE THREE.**

> "If you feel their ready to leave because the planning holds what is useful, they can leave."
> "Move them. Their more examples of the same text to infer seperately. Source of truth and pointers."

* HIS CONDITION WAS A TEST AND IT WAS RUN, not judged. For each of the five: is it cited from a
governing or basis document, and is what it is cited FOR carried where it is cited?

    peer_data_stores       -> driver_data_model.md C, and the basis PEER AUDIT section
    prior_art_formats      -> C, seeds S1 / S2, and the basis PRIOR ART section
    prior_art_execution    -> C (D10-D14), and the basis EXECUTOR PRIOR ART section
    data_model_findings    -> A11.6a (isolation unproven), and the basis BENCH FINDINGS section
    UI_findings_ace_XML    -> driver_ui_scope.md 3b (A-prime DEMONSTRATED), A9.6 / A10.1

All five passed both halves. 1,393 lines moved; every audit/ pointer re-aimed; a sweep for stale
pointers outside history/ returns none.

** HIS REASON IS SHARPER THAN THE ONE THIS ITEM ASKED WITH. The bench asked whether they MISLEAD.
He answered on duplication instead: a finished audit restating a settled conclusion is another
text an agent reads as CURRENT, and it can drift from the one that governs. Source of truth and
pointers.

! AND WHAT THE MOVE DOES NOT DO, measured and reported before he said go: the basis keeps FOUR
summary sections for these audits, 54 lines, on the reading path. Moving 1,393 lines out of audit/
does not shorten what a builder reads - it removes four more places to infer from. The bench's
classification (none of the five carries a one-direction-solid warning) was CORRECT and was simply
not the criterion that decided it.


_Filed 2026-08-19 (§390) by the **Addons bench**. ⚠ Filed rather than asked in chat, per
Battlewrath 2026-08-19: **"Put it into the inbox if it needs my input. I'm specifically making a
barrier so chat sprawl doesn't enter into intent."**_

### What was done, and the criterion used

§388 moved three audits to `history/` on his instruction (*"Audits that can be misleading should be
in history"*). ★ The criterion the bench applied was **each file's own header — does it say a
reading of it can be wrong?** Three answered yes and each is solid in ONE direction only:

    history/built_state.md            "a function with callers may still have no criterion"
    history/store_inventory.md        "a field WITH reads can still be dead"
    history/doc_comprehension_test.md "a CLEAN at one layer says NOTHING about the layer below"

### The question

**Five audits stayed in `audit/`, and the bench chose that rather than being told it.**

    peer_data_stores.md      MEASURED, read-only, on the installed client
    prior_art_formats.md     SOURCED from published specs
    prior_art_execution.md   SOURCED from published specs
    data_model_findings.md   the five shaping iterations; "it directs nothing"
    UI_findings_ace_XML.md   F1-F9, measured under the harness

★ **None carries a one-direction-solid warning** — they report what was measured or what a spec
says, and a wrong reading of them is a misreading rather than an artefact of the method. ⚠ **But
that is the BENCH's classification of his rule, applied to the bench's own files**, which is
exactly the shape that should not be self-certified.

    a  THE FIVE STAY. The rule is about METHOD - an instrument whose positive readings cannot
       be trusted - and measured/sourced findings are not instruments.
       ⚠ `audit/` then holds only findings, which makes the folder mean one thing.

    b  ALL AUDITS LIVE IN `history/`. The folder itself is the signal: anything not a
       governing document or a stated FACT is history, whatever its method.
       ⚠ `driver_data_model.md` §C cites the first four as the evidence for its
       compared-and-not-selected list - that citation moves with them, 4 pointers.

    c  A SPLIT ON AGE, not method: the three superseded by driver_data_model.md go; the two
       still cited stay. ⚠ The bench reads this as the weakest - it makes the folder's
       meaning depend on something invisible from inside it.

**Bench read (marked as the bench's, overturnable in a word): (a)** — because `audit/` and
`history/` would then differ by a property a reader can check from the file itself, which is the
only kind of filing rule that survives someone new. ⚠ Held weakly: (b) is simpler to state and
simpler to obey, and simplicity has beaten checkability on this project before.

    IMPACT
      on disk now      (a) nothing · (b) 5 file moves + 4 pointer rewrites in
                       driver_data_model.md §C, all mechanical and verifiable by grep
      shipped guards   none, under any option
      criteria         none. ⚠ `check_targets` does not read audits, so nothing goes red
                       either way - which is why this needs saying rather than failing
      does nothing to  any record, any rule, any code

---

## RI-32 · A STAGELESS NODE WITH A STORED OUTCOME — A2.10a is silent, and I built the strict read

**RI-32 DRAINED (Battlewrath 2026-08-20, records reconciled by Opus 5 Analyst) — (a) AS
BUILT, PLUS THE TELLING.** ★ The bench found the answer itself and could not take it:
*"(c)-without-the-refusal — store it, ignore it, and SAY so — is the shape that matches
§81 best, and the bench did not build it because A2.10a does not mention telling and
inventing a message is not the builder's to do."* **That was the right boundary to hold**
— the row was silent and a builder should not fill a criterion's silence with a string.

⟶ **A2.10a now carries it:** the strict read stands (`Outcome` answers nil), the editor
SAYS SO when the value is stored, and the message must be accurate — **stored and
DORMANT, not lost**, because giving the node a stage revives it. ⚠ No refusal: §81
forbids validation on authoring, so (c)'s refusing half is out and its telling half is in.
⚠ The wording is the naming pass's; the row fixes what it must convey.

_Filed 2026-08-19 (§393) by the **Addons bench** while building A2.10a. ⚠ Filed rather than
asked in chat, per the barrier._

### What the row says, and the gap

**A2.10a:** *"A STAGELESS NODE DOES NOT PROMOTE THE INDEX. Completing it runs its tabs and moves
the ratchet NOT AT ALL. `Outcome` must answer 'no promotion' for a node with no stage - not 1,
and not the current index either."*

★ **Unconditional, so that is what was built:** `Outcome` returns `nil` for a stageless node
before it looks at `b.outcome`. ⚠ **But `SetOutcome` is reachable from the pane for any beacon**,
so an author CAN store a checkpoint on a stageless node - and the build now ignores it silently.

### The question

    a  UNCONDITIONAL nil, as built. A node outside the sequence cannot promote the
       sequence, whatever is stored on it.
       ⚠ silently ignores something the author typed
    b  HONOUR a stored `b.outcome`. An explicit checkpoint is an author instruction and
       beats a default; only the DEFAULT (`self + 1`) is meaningless without a stage.
       ⚠ re-opens the trap A2.10a closed, by a different door - the node is still not
       in the sequence, and now it moves the index to a literal
    c  REFUSE `SetOutcome` ON A STAGELESS NODE, and TELL. The value never exists, so
       nothing is ignored and nothing is honoured.
       ⚠ refusing is GRADING the author, which §81's ruling forbids on authoring
       ("NO validation on authoring - duplicate stages, out-of-order and fractions are
       all legal, the author is TOLD"). ★ The telling half fits that ruling; the
       refusing half does not.

**Bench read (marked as the bench's, overturnable in a word): (a) as built, and it is what the
row says.** ⚠ But (c)-without-the-refusal - **store it, ignore it, and SAY so** - is the shape
that matches §81 best, and the bench did not build it because A2.10a does not mention telling and
inventing a message is not the builder's to do.

    IMPACT
      on disk now      routes.lua Outcome (built, (a)) · one smoke row asserting the override
      shipped guards   the row is GREEN under (a) and RED under (b) - it is asserted, so a
                       ruling for (b) is a one-line change to both, not a hunt
      criteria         A2.10a gains a sentence either way; §81's authoring ruling is the
                       thing (c) argues with
      does nothing to  the eight-consumer contract · A2.10c · the stage 0 rules · anything
                       outside `Routes.Outcome`
---

## RI-33 · WHAT THE DRIVER NEEDS vs WHAT THE BENCH BUILT TO PROVE IT

**RI-33 DRAINED (Battlewrath 2026-08-20 - his best working model, not a ruling; records
reconciled by Opus 5 Analyst) - BUILD FROM NEED, NOT FROM PRECEDENCE.**

> "Anything on the bench has to prove it's needed in live code. But we build from need to function
> not on precedence. Precedence is the proof we can. Not the implementation the addon needs."

*** THE ITEM ASKED WHICH OF THREE. HIS ANSWER IS THE PRINCIPLE UNDER ALL THREE, and it selects
(b) as a consequence rather than as a preference. `walk.py` is PROOF WE CAN detect. W7.1's
byte-equality turned that proof into a specification, and this sentence separates them again.

    THE DESK      proves the rule is reproducible. It reconstructs a FIXED-CADENCE RECORDING
                  and must interpolate. Segment interpolation, interpolated-z, v_max are its
                  answers to ITS problem.
    THE DRIVER    matches POS against constraints and calls functions. It CONTROLS WHEN IT
                  LOOKS, so it throttles up on approach instead of reconstructing a path.
    THE BURDEN    is on the bench artefact. Existing is not a reason to ship.

* AND THE MEASUREMENTS TAKEN AFTER THIS ITEM WAS FILED ALL POINT THE SAME WAY - none of them
was sought to support it:
    GetUnitSpeed is dynamic and reports yards/second (ROUTER, measured 2026-08-20) -> the
      driver has a real closing-speed input and does not need to infer motion from geometry
    the parked standoff returns a live distance, 1600 -> 1583.31 (ROUTER, measured) -> the
      driver gets a continuous verifier without any desk machinery
    the export contract holds 17 fields and NONE is desk machinery (RI-33's own measurement)
      -> the thing the driver reads never carried it in the first place

-> W7.1 MOVES. It stays as the DESK's calibration - byte-equality between the desk and any
reimplementation OF THE DESK - and stops being the driver's shipping requirement. The driver is
graded on OUTCOMES at the ruled radii and the ruled cadence; W7.2's synthetics become that
surface. A11.2a narrows to point + band + gate; segment, interpolated-z and v_max are desk-side.

! UNBLOCKS P3, the Lua port, which is what this item said it blocked. And it avoids the cost the
item named: porting machinery under (a) and then deleting it under (b).


_Filed 2026-08-20 (§408) by the **Addons bench** at Battlewrath's ask: **"I'd roll this whole
conversation into a inbox item. Then design can spec what the driver needs vs what we build to
prove it on the bench that we can."** Evidence: `audit/s9_teleport_guard.md` (§406, §407) and the
measurements below._

### ★★★ HIS OBSERVATION, WHICH IS THE ITEM

> *"Part of our tooling to prove we can is being snuck into the addon as a requirement, simply
> because it exists."*

**It is true, and the mechanism is nameable.** `driver_walk_acceptance.md` **W7.1 requires the Lua
port to be BYTE-EQUAL to the desk.** That single criterion converts every decision inside
`walk.py` — segment interpolation, the interpolated-z band, `TELEPORT_VMAX`, the teleport door,
S9 — into a **shipping requirement**, not because the driver needs them but because the desk has
them. ⚠ **The proving instrument became the specification by transitivity, and nobody decided
that.** It is not a mistake anyone made; it is what byte-equality means when the reference was
built to answer a different question.

⚠ **And the bench walked into it.** §406 and §407 audited S9 as a product question through two
rounds. The measurements are sound; the prior question — *does this belong in the addon at all* —
was never asked until Battlewrath asked it.

### THE MEASUREMENTS (all read-only; `walk.py` restored from a scratchpad copy, never regolded)

**1 · S9 is real.** `transits` (`walk.py:569-575`) falls back on THREE conditions — a hole, a
mapID change, a TELEPORT (`d3/Δgt > v_max`). The three `broken` recomputations (`:1047 :1159
:1276`) fall back on TWO. The teleport door is absent from all three, and those produce the w5
goldens that W7.1 grades against.

**2 · Adding the guard moves NO golden** — and that is because the goldens are BLIND to it, not
because the rules agree. The four qualifying samples are in `RFC_Run2_Messy-2` and
`RFC_Run3_Messy-5`; the goldens cover `SFK_live`, `SFK_Run4`, `rfc_combat`. Overlap: **none**.

**3 · The four are release-to-graveyard after a wipe** — three sit within ~3 s of a recorded
death, at ~1.0 s cadence, so `gap_bound` does not catch them. ⚠ The fourth is 55.8 s from any
death and is left UNATTRIBUTED rather than tidied into the story.

**4 · The cadence claim this bench made DIED.** §406 argued a denser sample would push false
teleports up. Measured, legitimate movement only:

        0.2 s runs   5 runs   fastest 50.6 yd/s   margin to v_max 2.0x
        1 Hz  runs   7 runs   fastest 56.9 yd/s   margin to v_max 1.8x

★ Flat across cadence, and the 1 Hz figure is HIGHER — the opposite of the prediction. The
premise assumed a burst shorter than the sampling window; the real bursts last about a second and
dominate both. **A granular throttle between 0.2 s and 1 Hz is free of this concern.**

**5 · ★★ AND AT THE RULED MENU, THE MACHINERY HAS ALMOST NO WORK.** Battlewrath, this
conversation: *"a drop down option. Min 5 yards. Probably up to 50. Steps between."* At the
measured 0.2 s floor, top legitimate speed covers **10.12 yd per sample**:

        R          skippable by a CENTRAL pass?   a graze is missable only outside
        5          YES, by 0.12 yd               (any)
        8          no                             77% of the disc
        10         no                             86%
        20         no                             97%
        50         no                             99%

⟶ **`segment_fire` has work only at R = 5, only at charge speed, and only for a graze.** Position
is ABSOLUTE — Battlewrath: *"the player position is absolute. It is as fresh and accurate as the
rate we sample it."* — so both endpoints are simply true, and interpolation is not reconstructing
a noisy signal. **It is compensating for not sampling fast enough**, and 0.2 s was measured as
fast enough to catch a player in R.

### WHAT V_MAX DOES, stated once so the spec does not have to re-derive it

    mapID change   are these the same coordinate space?      frame validity
    gap_bound      did I look often enough to interpolate?   temporal density
    v_max          is this displacement achievable?           spatial plausibility

★ Three orthogonal questions; `v_max` is the only one that asks whether two positions are
MUTUALLY REACHABLE, which is why the corpse-run case (287 yd in 1.0 s) passes `gap_bound` and
fails only it. ⟶ **`v_max` is the upper wall of the window where segment interpolation is valid;
the sample rate is the lower wall.** Between 50 and 100 yd/s at R = 5 is the entire regime where
`segment_fire` both matters and can be trusted.

### The question for design

**What does the DRIVER need, and what did the BENCH build to prove it could be done?** They have
not been separated, and W7.1 is what keeps them fused.

    a  BYTE-EQUALITY STANDS. The port reproduces the desk whole, and S9 is settled first so
       the two agree on which rule is being reproduced.
       ⚠ Ships segment interpolation, the interpolated-z band and v_max into a product whose
       ruled radii give them ~no work.
    b  THE DRIVER IS GRADED ON OUTCOMES. Does it fire where it should, at the RULED radii and
       the RULED cadence - the desk stays the calibration instrument it was built to be.
       ⚠ W7.1 is rewritten, and W7.2's synthetics become the grading surface instead.
    c  A SPLIT: byte-equality for the RULE's core (point + radius + band), outcome-grading for
       the parts the ruled parameters make unreachable.
       ⚠ Someone must draw the line, and a line drawn wrong is worse than either whole answer.

**⚠ NO BENCH READ on which.** This is a scope decision about what the product IS, not a build
shape, and the bench is the party whose work is on both sides of it. ★ The bench reads offered
are only the measurable ones above.

    IMPACT
      on disk now      NOTHING. No code changes on any option; walk.py is untouched and the
                       goldens are as they were.
      shipped guards   none break under any option. ⚠ And under (a) NOTHING GRADES S9 either
                       way until a fixture covering a teleport pair exists - the corpus
                       already holds two such runs, so no capture is needed.
      criteria         W7.1 is the row that moves under (b) or (c) · A11.2's port rows inherit
                       whichever is chosen · S9's disposition follows rather than leads
      does nothing to  the contract and fixtures (§405) · the rule's core (point + radius +
                       band) · anything already built for A1-A5
      ⚠ blocks         P3, the Lua port. Building it under (a) and then moving to (b) means
                       porting machinery twice, and the second port is the one that deletes.

### ★★★ HIS READ (Battlewrath, 2026-08-20) — THE SPLIT, and it is a clean one

> *"There is use on V_max. But it's on the editor side. Simulating a data route and seeing what
> triggered. As that's our process. But the driver only needs to be able to match POS against
> restraints and then call functions. And the failure is not detecting them in a R as a player
> behaviour of speed. IE. If they teleport over a R, between our samples. And that's why we
> throttle up on approach. (Up as in greater cadence.)"*

    EDITOR / DESK   v_max, segment interpolation, the interpolated-z band. The PROCESS is
                    simulating an authored route against captured data to see what triggered.
    DRIVER          match POS against constraints; call functions. Nothing more.
    THE FAILURE     NOT "speed as a player behaviour" - it is MISSING a beacon because the
                    player crossed R between two samples.
    THE ANSWER      throttle UP on approach - greater cadence - not a reconstructed path.

★★ **Why the split is structural rather than a preference:** the desk reconstructs from a
FIXED-CADENCE RECORDING and has no choice but to interpolate; **the driver controls when it
looks.** Interpolation is the desk's answer to a problem the driver does not have.

⟶ And it re-frames the failure this bench had been analysing. §406-§407 chased a FALSE FIRE
(a fictional path sweeping beacons the player never neared). His failure is the opposite and it
is the one that matters in-game: **a MISS.** A false fire is an editor-side artefact of replaying
a recording; a miss is a player standing in the right place while nothing happens.

### ⚠ ONE CONSEQUENCE, marked as the bench's inference and not part of his position

To throttle up ON APPROACH the driver must know it is approaching — and it knows distance only
from the last sample. To decide how long it may wait before looking again it needs an assumption
about how fast that distance can close. **That is a maximum-speed bound.**

    desk     v_max VALIDATES a path      "was that displacement travel?"     backward-looking
    driver   a speed bound SCHEDULES     "how soon could they reach R?"      forward-looking

⟶ roughly `next_interval = clamp(distance_to_nearest_R / V_assumed, floor 0.2, ceiling)`.

★ **Same constant, opposite direction, and a different KIND of number.** The desk's is a
plausibility threshold and being wrong means a wrong verdict. The driver's is a SAFETY bound and
the errors are asymmetric: too high costs extra samples (cheap), too low means a miss (the
failure he named). ⚠ So they should not share a value just because they share a name.

⚠ **The bench has not seen the throttle plan** and this may already be in it. Recorded so the
spec does not have to re-derive it, not as a proposal.

### WHERE THAT LEAVES THE OPTIONS ABOVE

His read is **(b) or (c)** — the driver graded on outcomes, with the desk kept as the instrument
it was built to be. ⚠ It does not by itself say which, because (c)'s line — *byte-equality for the
rule's core, outcome-grading for the rest* — still has to be drawn, and **the core he names
(match POS against constraints) is narrower than `walk.py`'s core**: no segment, no interpolated
z. ★ That is the thing for design to spec.

⚠ **S9 becomes an EDITOR question under this read**, not a driver one. The teleport guard's
absence from the three `broken` recomputations still affects what the simulation reports to an
author — which is `walk.py`'s job and still worth settling — but it stops blocking P3.

### ★★ TWO REDUNDANCY IDEAS (Battlewrath, 2026-08-20), checked against ROUTER

> *"When an instruction isn't using the supertracker, we position it off-map... so we have a
> constant yard reading. Just a thought for redundancy. Also there might be an API for current
> speed."*
>
> *"Nothing 'owns' the super tracker. It accepts last over write. So our owning it is just
> setting it to a parked position after something has consumed the super tracker. First
> position, boot it 1.6k out of reach of every node (Min/Max, pick the lowest or highest
> diff.)"*

#### 1 · THE PARKED PIN — the design works; the word "off-map" is what does not

⚠⚠ **"Off-map" in the literal sense is already measured and it fails silently.** `ROUTER:107`:
across a MAP boundary the tracker returns *"state Invalid with distance `0.00` — NOT nil"* while
`IsSuperTrackingAnything()` still reports true, and **1,386 consecutive confident zeros** were
recorded walking RFC holding an SFK pin, against our own arithmetic reading 1,946–2,217 yd.
★ ROUTER's own note: **zero satisfies every radius test.** A cross-map park is a false-positive
generator, not redundancy.

★★★ **But PARKING FAR AWAY ON THE SAME mapID is a different thing and it works.** `ROUTER:99`,
measured: the limits are **range and map change, never zone crossing** — past ~1500 yd *"the
CLIENT stops drawing the beacon while the ENGINE keeps returning true distance"*, measured to
3,742 yd, *"so our readout is uncapped"*.

⟹ **1.6k out is exactly the right number**: beyond the draw range, so nothing is shown to the
player, and inside the engine's live reading. ★ And the enabler is already on file — **mapID is
the CONTINENT** (`ROUTER:99`: *"mapID is the continent, and 1,291 yd of travel never changed
it"*), so a park point 1.6k from every node is trivially the SAME mapID and never reaches the
Invalid case at all.

★ **And the ownership framing was the bench's error, corrected here.** `ROUTER:85`: *"THE PIN IS
A SLOT YOU WRITE TO — A NEW SET NEEDS NO RELEASE... the pin only cares about being set."* Nothing
owns it; last write wins. The only durable property is that **nothing in the client's flow clears
it** (`ROUTER:84`), which is what makes a parked value persist — the mechanism, not a hazard.

    THE PARK POINT   1.6k beyond the extreme of the node set - his "Min/Max, pick the lowest
                     or highest diff", i.e. take the bounding box and go out on whichever
                     axis gives the most clearance
    WHAT IT BUYS     a CONSTANT, ENGINE-COMPUTED distance to a known fixed point. The engine's
                     figure is 3D yards at mean error 1e-5 over 1,758 samples (ROUTER:107),
                     so it is an INDEPENDENT check on our own arithmetic - which is redundancy
                     in the real sense: a second instrument, not a second copy of the first.
    ⚠⚠ THE 'COST' THE BENCH RAISED HERE WAS ALREADY RULED, and re-raising it was the
                     error. `driver_use_case_target.md` §1, Battlewrath verbatim: **"No
                     'give back' mechanism: if anything else sets the tracker meanwhile it
                     wins, by our logic (REINFORCEMENT, NEVER ARBITRATION) and by
                     construction (last write)."** And `driver_scoping.md:175` carries
                     **set supertracker** as a ruled ACTION among the fifteen. ★ So the pin
                     is a product SURFACE, not an incursion, and there is no contest to lose:
                     we write, anything else that writes wins, we write again next stage.
                     ⚠ The bench inherited `COA_Landmarks`' occupy/release contract - which
                     is precisely what ROUTER:84's own sentence warns against, *"a product
                     difference to make DELIBERATELY, not to inherit"* - while quoting that
                     sentence. Scoping closed 2026-08-17; this was settled before the item.
    ★ AND IT STRENGTHENS THE PARK rather than qualifying it. Under reinforcement-never-
                     arbitration a parked pin is just another write, and §1's DEATH LOCATION
                     POINTER is already the same mechanism - on death write the reader's own
                     position, on alive write the route's lure again. A parked reference is
                     that shape with a FIXED target.

#### 2 · `GetUnitSpeed` — it EXISTS, and it is UNMEASURED IN MOTION

    attested   census × 3 (`GetUnitSpeed = "function"`), and `task_unitstate.lua` already
               calls it - `speed = try(GetUnitSpeed, "player")` at :110 and :426
    recorded   every sample in `20260817_161324_797__unitstate.lua` reads **speed = 0**

⚠ **So it exists and returns a number; whether it returns a USEFUL number in motion is
unmeasured** — the probe sampled standing still. ★ That is a cheap gap: the call site already
exists, it needs samples taken while moving.

★★ **And it bears directly on the throttle.** The scheduling bound above is an ASSUMPTION about
how fast the player could close a distance. A true speed reading replaces the assumption with a
measurement — which removes a tunable from the driver rather than adding one to get wrong.
⚠ `task_unitstate`'s own design note is the reason to trust it if it reads: the probe is built so
*"the fields ARGUE WITH EACH OTHER, so a wrong reading has somewhere to show up"* — `IsSwimming`
against `GetUnitSpeed` against `IsFalling`.

⚠ Both are RECORDED, not proposed. The park point is a product decision about the player's quest
arrow; the speed probe is a measurement nobody has taken.

### ★★★ THE DISPOSITION FRAME (Battlewrath, 2026-08-20) — and where it already lands

> *"Test what is being built. And if it is a editor or a driver question. If it's a driver it
> shapes what needs exporting, which I think was the first ask. If it's a editor need, it lives
> in the files we ship as a part of that function. Still not user facing."*

★★ **It COMPOSES with a discriminator already ruled rather than competing with it.**
`driver_data_model.md` §A2.8 splits on **who DEFINES a value** — config we control never goes on
the wire, run-derived must. His splits on **who CONSUMES the capability**. Two axes, three
outcomes:

    driver-consumed + run-derived    →  TRAVELS in the export
    driver-consumed + config          →  ships in the addon, not on the wire
    editor-only                       →  ships in the addon, NEVER crosses the wire at all

⚠ **And "still not user facing" is the property that makes the third row safe**: an editor-only
capability is shipped code with no authoring surface, so it cannot leak into the author's model
of what a route IS. That is the same law as the two side tables the driver never opens.

### ★★ MEASURED: THE EXPORT SHAPE DOES NOT MOVE UNDER EITHER ANSWER

Every field in `contract.lua` (§405) classified against **his** definition of the driver — *match
POS against constraints, then call functions*:

    gate         4     mapID · rid · stage · step
    address      2     bid · cid
    constraint   5     posX · posY · posZ · r · band
    what-next    3     nextType · nextArg · trigger
    call         3     sense · action · arg
    UNCLASSIFIED 0

★★★ **No desk machinery is in the contract** — no segment state, no interpolated z, no `v_max`,
nothing that exists to reconstruct a fixed-cadence recording. The contract was written from
§A1's record shape, and it turns out to contain exactly his five roles and nothing else.

⟶ **So the export is already scoped to the driver's needs, and the first ask is answered.**
Whichever way editor-vs-driver falls, `contract.lua` and `fixtures_route.lua` stand unchanged.

### ⟶ WHAT IS ACTUALLY BLOCKED, narrowed

    NOT blocked   the export shape (§405) · the contract · the fixtures · what needs exporting,
                  which was the first ask
    BLOCKED       the RULE's port to Lua (P3 / A11.2) - and only the parts whose SHAPE depends
                  on the answer: whether the driver reproduces `walk.py` whole (segment,
                  interpolated z, v_max) or implements the five roles above and is graded on
                  outcomes at the ruled radii and cadence.

★ **So the question to test is narrower than it looked at the top of this item**: not *"what does
the driver need"* in general — the contract answers that — but **"which of `walk.py`'s machinery
is a REQUIREMENT of the driver, and which is the desk's answer to a problem the driver does not
have (a fixed-cadence recording it cannot re-sample)."**

⚠ Bench read on that framing only, not on the answer: the five roles are what the RECORD carries,
and the record was derived from §A1 before this conversation started. That is corroboration by
independent route rather than a bench opinion.

---

### ★★★ ANALYST INPUT ON RI-41 (2026-08-20) — READING (a), AND IT IS NOT A READING

⚠⚠ **IT IS AN EXISTING RULING THAT NEVER REACHED A GOVERNING DOC.**
`ARCHIVE__dungeonrun_poc.md:6710`, at the stage field's mint:

> *"**A duplicate stage is ALLOWED.** It shows as two adjacent rows in the running order, and
> refusing it would be grading the author's work (SS75). **The consequence is real and theirs:
> satisfying the first promotes straight past the second.**"*

⟶ **That is RI-41's measurement, ruled, and accepted as the AUTHOR'S consequence.** The item's
reading (a) — *"lockstep is intended and the pairing by number needs saying out loud"* — is
correct, and the second half of that sentence is the whole of the work.

⚠⚠⚠ **CORRECTED WITHIN THE HOUR — MY FIRST INPUT SAID "NO BID LEVEL IS OWED" AND IT WAS WRONG.**
I gave input on RI-41 from the bench's summary WITHOUT READING RI-41, found the archive quote,
and read it too fast. ★ Read at the right speed it says the opposite of what I claimed.

    the RULING          *"**SATISFYING** the first promotes straight past the second"*
    what SATISFIES      `Routes.AcceptanceOf` (`routes.lua:1648`) - a DESIGNATED child with
                        `role == "complete"`, or the beacon itself when childless
    the MEASUREMENT     completing `left:l1` - which need not be `left`'s satisfier at all -
                        advances the shared cursor and strands `right:r1`

⟶ **The ruled behaviour requires `left` to be SATISFIED. The measured behaviour strands `right`
on a PARTIAL WALK of `left`.** Those are different, and the second is stronger than anything the
author was told they own.

★★★ **SO THE ARCHIVE DOES NOT CLOSE RI-41 — IT CONSTRAINS IT, AND IT CONSTRAINS IT TOWARD (b).**
A per-BID cursor reproduces the ruled outcome: `left` must reach its own satisfier before
anything promotes. The shared cursor produces an outcome nobody ruled.

⚠ **AND THE BENCH'S WITHDRAWN REASONING WAS RIGHT THE FIRST TIME.** §439 declined to file on the
grounds that S4 covers it; §440 withdrew that as *"weak"* because S4 *"says nothing about what
the BUCKET does with them"*. **I then re-made the withdrawn argument from a different citation.**
★ A stronger quote, and still not one that reaches the bucket.

★ **The third reading stays open and is now the cheap one:** `AcceptanceOf` makes a beacon's
completion an EXPLICITLY AUTHORED child rather than a positional accident, which is a per-beacon
concept — so (b) is the smaller conceptual change than it looked, whatever its build cost.
⚠ Rarity still is not the test; but *"write down which"* is a legitimate outcome and this is the
evidence to write it down against.

### ⚠⚠⚠ THE FINDING UNDER THE FINDING — A LIVE RULING STRANDED IN AN ARCHIVE

The governing set carries SS81's **legality** (`driver_authoring_acceptance.md:490` — *"duplicate
stages, out-of-order and fractions are all legal, the author is TOLD"*) and **not the
consequence**. The consequence exists in exactly one place: an `ARCHIVE__` file.

★★ **Which is why the bench could measure the behaviour and find no ruling for it.** Not a
reading failure — the answer was not in the readable set.

⚠⚠ **AND IT IS A HOLE IN THE ANALYST'S OWN TOOL.** `check_retired.py` skips `ARCHIVE__` files by
construction, and so does every sweep. ⟶ **An archive can hold a LIVE ruling, and nothing checks
for that** — the same fault the tool exists to catch, one level up: *a scope that excludes what
would answer the question.*

    OWED
    · lift the CONSEQUENCE into `driver_authoring_acceptance.md` beside SS81's legality,
      citing the archive as its source - it is a live ruling in an archived file either way
    · ⚠ RI-41 itself STAYS OPEN - the question, with its context, is below.

★ **Nothing to build.** The bench's judgement not to pin was right for the reason it gave — the
shape needs a raiser to be reachable — and it is doubly right now: a pin would grade a path the
author has already been told is theirs.

### ★★★ THE QUESTION, WITH ITS CONTEXT (Battlewrath's framing, 2026-08-20)

> *"I'd say it's whatever beacon you're currently stood on / child that needs satisfying. Which
> is the purpose of sense and the sensor. Where is used your stage and step to filter or 0."*

⟶ **THAT REFRAMES IT, AND THE CODE AGREES: THERE IS NO CURSOR.** `Bucket.Stage(bucket, stage,
step)` (`bucket.lua:295`) is a **FILTER** — it takes stage and step as ARGUMENTS and returns the
matching set. Stage 0 passes through wholesale with no step gate; within the current stage the
step is *"0 or exact match, everything else BOUNCES"*. **Nothing inside advances anything.**

★ So the item's *"shared step cursor"* names a structural consequence rather than a built
mechanism: **whoever calls `Bucket.Stage` must pass ONE step value for the whole stage.** There
is no cursor to move — there is a caller who has to choose a number.

### ⚠⚠ AND THE FAULT IS A SCOPING MISMATCH, IN ONE LINE

    STAGE   is ROUTE-scoped.   Every beacon draws from one stage numbering, so filtering a
                               stage across beacons is meaningful - that is what it is FOR.
    STEP    is BEACON-scoped.  `contract.lua`: *"the child ordinal"* - each beacon numbers
                               its OWN children from 1, and `left`'s 1 and `right`'s 1 are
                               positions in two different sequences.

⟶ **`Bucket.Stage` applies a BEACON-scoped number as a STAGE-WIDE filter.** `left:l1` and
`right:r1` are armed together for no reason but the integer, which is exactly what the probe
measured.

### ★★ HIS MODEL, STATED SO IT CAN BE RULED ON OR CORRECTED

    the SENSOR is the authority for WHERE YOU ARE. Its whole purpose is to answer *"which
    armed thing am I in"*, so the run does not need to hold a position - it needs to hold a
    FILTER, and the sensor resolves the rest.
    STAGE and STEP are that filter, *"or 0"* - the always-eligible pass-through.
    SATISFYING is done by *"whatever beacon you're currently stood on / child that needs
    satisfying"* - which `Routes.AcceptanceOf` already makes explicit: a DESIGNATED
    `role == "complete"` child, or the beacon itself when childless.

⟶ Under this model `right:r1` is not *"unreachable"* because something moved past it. **It is
unreachable only if the FILTER stops admitting it** — and that is the thing to rule on.

### ⟶ SO THE QUESTION IS ONE THING, AND IT IS ABOUT THE FILTER

> **WHO CHOOSES THE `step` ARGUMENT, AND IS ONE VALUE RIGHT FOR A WHOLE STAGE?**
>
>   ⓐ ONE VALUE PER STAGE — the filter is route-wide, and two beacons at one stage advance
>     together by number. ⚠ Then the pairing needs saying out loud, and a partial walk of
>     `left` can strand `right` in a way the SS75 ruling (*"**satisfying** the first"*) does
>     not describe.
>   ⓑ ONE VALUE PER BEACON — the filter is `[stage][BID][step]`, each beacon's own sequence
>     filtered by its own ordinal. ★ Reproduces the ruled outcome: `left` must reach its own
>     satisfier before anything promotes.
>   ⓒ NO STEP FILTER AT THE STAGE LEVEL AT ALL — arm the whole current stage and let the
>     SENSOR say which node the player is in, with the step used only to order what
>     completes. ⚠ Closest to his words as written, and the one the bench has not costed.

★ **ⓒ is added by the Analyst, not by him, and is flagged as such** — it follows from *"the
purpose of sense and the sensor"* taken literally, and it may be what he means or may be a step
past the evidence. **Bringing it as an option rather than an interpretation.**

⚠⚠ **AND THE MODEL DOES NOT ANSWER IT — WHICH IS WHY THE QUESTION EXISTS.** Row 11 says
*"`Stage:Step` ARE COMPOSED AT EXPORT from the live tree"* and never says from WHICH FIELD or at
WHAT SCOPE. The equivalence lives only in code (`bucket.lua:170`: `local step = c.ordinal`)
against a field `contract.lua:74` calls *"the child ordinal"* — beacon-scoped by its own words.
★ **Filed as model §B `P3a`**: RI-41 is that gap surfacing as behaviour, and answering *"what is
Step scoped to"* answers ⓐ/ⓑ/ⓒ as a consequence rather than as a separate choice.

⚠ **NOTHING WAITS ON THIS.** No raiser exists (RI-38, G8), so no caller chooses a step yet. ★ The
window is the same as every other open item today: **free while nothing calls it.**

## RI-41 ✅ DRAINED 2026-08-20 · TWO BEACONS AT ONE STAGE SHARE ONE STEP CURSOR — measured

**RI-41 DRAINED (Battlewrath, 2026-08-21)** — the stamp `check_inbox.py` derives from; the
reasoning is below and in `ANALYST_LOG.md`.

**DRAINED BY THE STRUCTURE, NOT BY A RULING ON IT** (Battlewrath, 2026-08-20):

> *"Left right is a construction of implementation and isn't expressed in authoring. It should be
> a per line entry, just like the instruction set."*
> *"The bucket itself is the stage. The steps are the bare rows. A stage childless is an item of
> one."*

    Bucket stage 0        (always listened to)
    Bucket stage 1        Beacon
    Bucket stage 2        Child · Child · Child

⟶ **ONE LEVEL. `bucket[stage][step]` becomes ONE BUCKET PER STAGE HOLDING BARE ROWS.** `step` is
a FIELD used to filter and order, never a table key. ★ **The `[step]` slot was the whole fault** —
it was the only thing that ever related `left:l1` to `right:r1`, and authoring never expressed it.
⟶ ⓐ/ⓑ/ⓒ all fall away: there is no shared slot, no per-BID key needed, and no rule to write.

**AND THE RUNTIME LOOP IS HIS, per line:**

    SENSE      checks the resolved POS — is the player in it?
    TRIGGER    if true, fire the function
    ALIVE      keep it alive for whilst in it
    COMPLETE   mark complete, and complete the STEP or the BEACON depending on the
               beacon/step order
    ALWAYS     listen to 0

⚠ **Model §A5b row 23 carries the shape; §B P3a is answered with it** (a step's scope is the
beacon's, and it never was a key). ⚠ **P3b stays open** — the action TABS still do not exist on
the authoring surface, which is what *"per line entry, just like the instruction set"* now needs.

⚠ **The one constraint the flattening must not lose is A11.2g:** rows of the SAME node share ONE
geometry evaluation per sample. Bare rows are the ARMING and COMPLETION unit; the NODE remains the
EVALUATION unit.

★ The bench's judgement not to pin was right and is now moot — **the shape it would have pinned
is the shape that is going away.**

<details><summary>THE WORKING — kept whole, answered by the structure</summary>

## RI-41 · (the working) TWO BEACONS AT ONE STAGE SHARE ONE STEP CURSOR

**Filed by the Addons bench, 2026-08-20 (§440), at Battlewrath's ask** — *"Do you want to enter
that into reconcile? I'll get them to note it across docs."*

⚠ **§439 recorded this inside RI-40 and did NOT file it, on the reasoning that §90 S4 already
ruled duplicate stages TELL-AND-TRUST.** ★ That reasoning was weak and is withdrawn: S4 settles
that duplicate stages may EXIST and must be told rather than prevented. **It says nothing about
what the BUCKET does with them**, and `bucket.lua` is three days old.

### THE MEASUREMENT — read-only probe, two beacons both at stage 1, each with steps 1-2

    loaded 4, bounced 0
      stage 1 step 1 : left:l1  right:r1
      stage 1 step 2 : left:l2  right:r2

    slot occupancy under stage 1:   step 1 holds 2   ·   step 2 holds 2

⟶ **The bucket is keyed `[stage][step]` with NO BID LEVEL**, so two beacons at one stage run
in **LOCKSTEP**: one step cursor drives both, and `left`'s step N is armed with `right`'s step N
for no reason but the number.

### ★★★ THE CONSEQUENCE, and it is the ordinal fault one level up

Completing `left:l1` advances the shared cursor to 2. ⚠ **`right:r1` then becomes unreachable
without ever having been completed** — `right`'s whole sequence can be skipped by walking
`left`'s. ★ That is the same shape as §436's *"if it's checking every step in a ordinal, it can
complete every ordinal"*, moved from within-a-beacon to across-beacons.

⚠ **AND IT IS ONLY REACHABLE WITH A RAISER**, which does not exist (RI-38, G8). So this is a
property of the structure today, **not an observed failure** — nothing advances a cursor yet.

### THE QUESTION FOR DESIGN — two readings, and the bench picks neither

    a  LOCKSTEP IS INTENDED     two beacons at one stage are ONE position with two places,
                                and their ordinals are meant to pair. ⚠ Then the pairing by
                                NUMBER needs saying out loud, because nothing states it and
                                an author would have to infer it from behaviour.

    b  THEY ARE INDEPENDENT     each BID carries its own step cursor, and the key needs a BID
                                level (`[stage][BID][step]`). ⚠ Then RI-38's raiser problem
                                is per-beacon rather than per-run, which is a larger change
                                than it looks.

★ **A third possibility the bench will not assume away:** duplicate stages may be rare enough
in practice that either answer is fine, and the right outcome is to WRITE DOWN which one it is
rather than to build for it. ⚠ The bench has no evidence either way — `AddBeacon` mints
distinct stages (`NextStage`), so a duplicate only arises when an author sets one deliberately.

### ⚠ NOTHING BUILT, AND NOTHING PINNED

Unlike RI-40, this behaviour is **not** pinned by a smoke row. ★ Deliberate: RI-40's pin was
worth its cost because the shape was authorable TODAY and produced a wrong-looking sequence.
This one needs a raiser to be reachable at all, so a pin would grade a path nothing can walk —
*existing is not a reason to ship*. ⟶ The probe is TRACKED at `addons/tools/smoke/probe_bid.lua` - outside the `smoke_*` glob because it asserts nothing and prints instead; it is
reproducible in one run and costs nothing to re-take when the answer matters.

</details>

## RI-40 ✅ DRAINED 2026-08-20 · MAY A STAGE-0 BEACON HAVE CHILDREN? — measured, not argued

**RI-40 DRAINED (Battlewrath, 2026-08-20.)**

> *"beacon 0 are locked out of having children. Self completing only. **A stage can still have
> 0 to solve for in a stage.**"* · *"it'd be sliced at Bucket 0, so where Stage = 0 BID: if
> CID bounce."*

    O  BUCKET 0 IS SLICED — where Stage = 0, a `BID:CID` BOUNCES. The `BID` is admitted and
       becomes self-completing; only the `CID` is dropped, and the count is TOLD (§90 S4).
    ✗  NOT a build refusal · the beacon is NOT lost with its children · STEP 0 is untouched
    ✓  built §439, mutation 22/22 · an existing route carrying one still BUILDS, so the
       migration question the bench raised never arises
    →  #3 §A1.4a · `bucket.lua` · `smoke_bucket`

### ★★ A BOUNCE BEAT THE BENCH'S REFUSAL, and the reason is worth keeping

The bench proposed **refusing the BUILD** on row 24's *"BUCKET may fail LOUDLY"*. ⚠ That was
the worse answer: it breaks every existing route carrying one and raises a
refusal-or-`DropRetired` migration call. ★ **A bounce is the gate doing its ordinary job** — a
`CID` under stage 0 does not match, so it is not admitted, and the route still builds.
⟶ Row 24 is about shapes that must not REACH A RUN. This one never does.

### ⚠ AND THE BENCH SLICED IT WRONG FIRST

A first cut emptied `kids` entirely and **lost the recovery beacon along with its children**.
★ *"BID: if CID bounce"* keeps the `BID` — the literal reading and the useful one agree, and
the bench had neither until the probe showed a route with no recovery node in it at all.

### ⚠ WHAT REMAINS OPEN, and it is not this item

**Finding 2's wider half:** two beacons sharing a POSITIVE stage still pool their step slots,
because the bucket is keyed `[stage][step]` with no BID level. ★ Under the slice, stage 0's
half of that dissolves (every stage-0 node is childless, so `stages[0][0]` holds many BIDs —
which IS *"reads through every BID"*). ✅ **FILED AS RI-41 (§440)**, at his ask - and the §439 reasoning for NOT
filing it is withdrawn there: §90 S4 settles that duplicate stages may EXIST, not what the
BUCKET does with them. ★ Measured since: they run in **LOCKSTEP** on one step cursor, so
completing one beacon's step can strand the other's.

---

### ⬇ THE ITEM AS FILED, kept whole

**Filed by the Addons bench, 2026-08-20 (§437), at Battlewrath's ask:**

> *"If 0BID have children is a question. As is today they should be able to. Something to
> consider if they should."*

✅ **HIS THREE CONFIRMATIONS FIRST, all matching what is built** (§436): a target bucket is
either **`BID` : many children** or **`BID` bucket : `BID` item** (the childless beacon, A1.2);
it **bounces within the bucket on step**; and **stage 0 reads through every `BID`**.

### ★★★ THE MEASUREMENT — a route with a staged sequence and TWO stage-0 beacons

Fixture: `b1` at stage 1 with steps 1–3; `rec` at stage 0 with steps 1–3; `rec2` at stage 0
with step 1. ⚠ Read-only probe against the shipped `bucket.lua`, not a thought experiment.

    stage 1 at step 1     5 armed : b1:p1  rec:r1 rec:r2 rec:r3  rec2:q1
    stage 1 at step 2     5 armed : b1:p2  rec:r1 rec:r2 rec:r3  rec2:q1
    stage 1 at step 3     5 armed : b1:p3  rec:r1 rec:r2 rec:r3  rec2:q1

### ⚠⚠ FINDING 1 — A STAGE-0 SEQUENCE IS NOT A SEQUENCE

`rec`'s three steps are armed **all at once, at every step of the run**. ★ That is exactly the
fault §436 just fixed at stage level, alive inside stage 0 — and it is alive *because* stage 0
is taken WHOLESALE, which is his own ruling and the right one for a catch-all.

⟶ **The two rules collide inside stage 0**, and only there:

    "stage 0 is the pass through · always valid bucket"     → no step gate
    "an ordinal is a POSITION IN A SEQUENCE"                → needs a step gate

⚠ With no gate, a player who walks past `rec`'s step 3 completes it without ever reaching
steps 1 or 2. **Authoring a sequence under a recovery beacon today produces something that
looks ordered and is not.**

### ⚠⚠ FINDING 2 — AND SLOTS POOL ACROSS BIDs, which is separate and wider

    stage 0's own slots:  step 1 holds 2   ← `rec:r1` AND `rec2:q1`, different BEACONS
                          step 2 holds 1
                          step 3 holds 1

★ The bucket is keyed `[stage][step]` with **no BID level**, so two beacons sharing a stage
share their step slots. ⚠ **This is not confined to stage 0** — two beacons at stage 1 would
pool their step 1s the same way.

⚠⚠ **REPORTED AS MEASURED, NOT AS A DEFECT.** §90 S4 already ruled duplicate stages
**TELL-AND-TRUST** — report the collision, never prevent it — so duplicates EXISTING is settled
and the bench is not re-opening it. What is new is what the BUCKET does with them, and `bucket`
is two days old. ★ It may be exactly right: at one (stage, step) the run arms everything there,
and "two beacons at the same stage" may simply mean both are live.

### ★★★ HIS DIRECTION, SAME DAY — option (a), and it dissolves Finding 1 entirely

> *"And it might be beacon 0 are locked out of having children. Self completing only.
> **A stage can still have 0 to solve for in a stage.**"*

⚠⚠ **AND THE SECOND SENTENCE IS THE ONE THAT MATTERS**, because it separates two things
both called "0" that the bench had been treating as one shape:

    STAGE 0   the recovery beacon        → LOCKED CHILDLESS. Self-completing only.
    STEP 0    an ordinalless child       → UNCHANGED. Still allowed inside a stage, still
              of a STAGED beacon           the pass-through, still checked at every step.

★ **Finding 1 stops existing under this.** If a stage-0 beacon cannot carry children then
there is no stage-0 sequence to be un-sequenced, and the two rules stop colliding: stage 0
holds only self-completing single items, so "taken wholesale" and "an ordinal is a position"
never meet. ⟶ The collision was not a flaw in either rule; it was a shape that should not
exist.

★★ **And it lands cleanly on A1.2 rather than against it.** *"A childless beacon is
RUNNABLE"* — `AcceptanceOf`: *"the anchor is its own satisfier when it has no children."* A
recovery beacon that completes itself is exactly the object A1.2 already describes. The lock
does not invent a new kind of node; it says stage 0 may only ever be that kind.

⚠ **Finding 2 partly dissolves and partly does not.** Under the lock every stage-0 node is
childless, so its step is always `0` and `stages[0][0]` holds many BIDs — which IS *"reads
through every BID"*, correct by his own description. ⟶ But the pooling of two beacons sharing
a POSITIVE stage is untouched and stays open below.

### ⚠ WHAT THE BENCH WOULD BUILD, AND WHAT IT WILL NOT DECIDE

    ✅ BUCKET REFUSES     a stage-0 beacon with children is a named refusal at BUCKET.
                          Row 24: BUCKET may fail and should fail LOUDLY, and this is a
                          shape that must never reach a run.
    ⚠ THE EDITOR'S HALF  whether the pane OFFERS "add child" on a stage-0 beacon is
                          A10.3's, and §90 S4's posture is TELL-AND-TRUST rather than
                          prevent. ★ A refusal at BUCKET and a lock at the pane are
                          different decisions and the bench owns only the first.
    ⚠ EXISTING ROUTES    a route already carrying one would stop building. Whether that is
                          a refusal or a DropRetired-style told-and-dropped is a call, not a
                          detail — `DropRetired` is the shipped precedent for exactly this.

### THE QUESTION FOR DESIGN — his, with the evidence attached

1. **May a stage-0 beacon carry children at all?** Today it can (`AddBeacon(id, node, 0)`
   stores `stage = nil`, and `AddChildFromNode` does not care). ★ The options the measurement
   surfaces, none of them the bench's to pick:

        a  NO CHILDREN ON A 0BID     the recovery beacon is its own single item, always.
                                     ⚠ Costs the authoring shape A2.5 already allows.
        b  CHILDREN, NO ORDER        allowed, and their ordinals are documented as MEANINGLESS
                                     inside stage 0. ⚠ Then the pane must not offer a step
                                     picker there, or it offers a lie.
        c  A CURSOR PER 0BID         stage 0 keeps its own step position per beacon. ⚠ A second
                                     cursor, and RI-38's raiser problem multiplied by every
                                     recovery beacon.

2. ★ **Is slot-pooling across BIDs intended?** Separate from Q1 and wider than stage 0.

⚠ **NOTHING BUILT.** The behaviour is pinned by a smoke row labelled as MEASURED-AND-UNDER-
QUESTION so it cannot drift while this is open, and that row cites this item.

### ★★ ANALYST INPUT ON RI-39 (2026-08-20) — THE READOUT ONLY, AND THE WORDING IS THE DEFECT

✅ **Q1: yes, A11.5a's "V1 has no stage" is about the READOUT.** The row is titled *"THE READOUT
— what V1 can honestly report"*; its argument is that S8 *"imports STAGE semantics"* into the
report; its examples are all result columns. **The sentence was written to justify not REPORTING
stage results and was never a claim about the data.**

★★★ **AND THE STRONGEST EVIDENCE IS THE INCIDENT ITSELF: it misled the bench that wrote the
driver.** A row that its own intended reader took literally is defective as written, whatever it
meant. ⟶ **The wording is fixed, not the code.**

⚠ **Q2 answers itself once Q1 does:** `AddBeacon` minting a stage is NOT the thing that is wrong.
If it were, every authored route in existence would be invalid — a far larger claim than a
readout row can carry, and one nothing else on disk supports.

✅ **`Bucket.FirstStage` is the right call and worth naming as such:** lowest positive stage, else
0. **Derived rather than chosen**, so it survives either ruling — and stage 0 is *always
eligible* (row 10), not *"the first stage"*, which is precisely the distinction SS435's walk
found by failing. ★ *Walks prove the JOINS.*

    OWED
    · narrow A11.5a's sentence to the readout explicitly, and say why (it was read literally)
    · nothing else - the code is correct on both sides

## RI-39 · "V1 HAS NO STAGE" — BUT THE EDITOR MINTS ONE FOR EVERY BEACON

**RI-39 DRAINED (Battlewrath, 2026-08-21)** — *"Well. It has stage in the editor. Just no local,
readable expression."*

    Q  is A11.5a's *"V1 has no stage"* about the READOUT only, or about the data?
    O  NEITHER, quite — and his wording is finer than the question. **The DATA has stage.**
       What V1 lacks is a **LOCAL, READABLE EXPRESSION** of it.
    ✗  V1 routes are NOT stageless · `AddBeacon` minting a stage is NOT the thing that is wrong
       · the row is NOT a claim about the store
    ✓  every authored route carries stages 1..N · V1 REPORTS the IN set by address and the
       per-target first-hit index · `stage` is not a RESULT at either level
    →  A11.5a (reworded) · A12.3a · `Bucket.FirstStage`

★★ **AND IT NAMES WHERE STAGE DOES BECOME READABLE:** the READER'S NOTE PANE — A10.8a,
*"stage / step · the note"*. ⟶ **Two surfaces, and only one of them is V1's.** The sense leg has
no expression of stage; Chain 3's pane is where a human meets it. That is why the row could read
as a claim about the data — it was written before the reader's surface had anywhere to live.

⚠ §435's walk is what stopped the literal reading becoming code: pinning the driver at stage 0
handed out only the recovery beacon on a real route. **`Bucket.FirstStage` — lowest positive,
else 0 — was derived rather than chosen and survives this ruling unchanged.**

**Filed by the Addons bench, 2026-08-20 (§435). ⚠ REPORTED, NOT RESOLVED** —
*"Don't mutate code from doc disagreement"* (Battlewrath, 2026-08-20), the same instruction
A11.2h was filed under.

### THE TWO TEXTS

    #11  A11.5a          *"V1 has no stage, so V1's readout is: per sample, the set of
                          addresses the player is IN"* · *"The stage timeline (W5.3) and
                          W7.3's hit · skip · false_advances are graded at V2, **when a
                          stage exists**"*
    code `routes.lua`    `AddBeacon`: **`b.stage = want or Routes.NextStage(id)`** — every
         :409-440         beacon gets a stage. Only an explicit `0` request stores `nil`.

⟶ **Every authored route today has stages 1..N.** So *"V1 has no stage"* is true of the
READOUT (no stage-level results) and false of the DATA.

### ★★★ HOW IT SURFACED — the walk caught what no unit smoke could

§435 pinned the driver's stage at `Bucket.ALWAYS` (0) on the strength of that sentence. ⚠ On
any real route **that hands out ONLY the recovery beacon** — stage 0 is *always eligible*, and
the two authored steps at stage 1 would never be armed. **The route would not run, and every
unit smoke would still be green**, because `smoke_bucket`, `smoke_sensor` and `smoke_rule` each
build their own node shape and none of them meets a minted stage.

★ It was the END-TO-END WALK over a route in the STORE's shape that failed, on its second
assertion. *Walks prove the JOINS; harnesses prove the parts.*

### ✅ WHAT THE BENCH DID INSTEAD OF PICKING A SIDE

`Bucket.FirstStage(bucket)` reads the LOWEST POSITIVE STAGE PRESENT, falling back to 0.
**Correct under either reading:**

    a route with no stages    every node converts to 0 → first stage is 0 → all of it
    a route with stages 1..N  first stage is 1, plus stage 0 (row 23's *WITH stage 0*)

⚠ Stage 0 is *"always eligible"* (row 10), **not "the first stage"** — a recovery beacon is
not where a run begins, which is why the lowest POSITIVE stage wins when one exists.

### THE QUESTION FOR DESIGN

1. **Is A11.5a's "V1 has no stage" about the READOUT only?** The bench reads it that way — the
   row is titled for the readout and its examples are all result columns — but it is written
   as a statement about V1 as a whole, and it was read literally once already, today, by the
   bench that wrote the driver.
2. ⚠ **If V1 routes really are meant to be stageless, then `AddBeacon` minting a stage is the
   thing that is wrong**, and that is a change to shipped authoring behaviour. The bench will
   not make it from a doc reading.
3. ★ **Companion to RI-38, and probably answered with it:** RI-38 asks who ADVANCES the stage;
   this asks whether there is one to advance in V1 at all. ⚠ The bench's pin answers only
   *where a run starts*, and it is derived rather than chosen so it survives either ruling.

### ★★ ANALYST INPUT ON RI-38 (2026-08-20) — THE OWNER IS THE LAYER THAT OWNS COMPLETION

★ The item settles the SHAPE (rows 24/26, corroborated by WA) and asks where the layer lives.
⟶ **It lives with COMPLETION, and that is derivable rather than a preference:**

    what raises an advance   a node COMPLETING whose `Next` is Stage
    what knows completion    RI-16's rule - a child completes when ALL its tabs have
                             completed - which needs a per-node, per-tab ledger
    where that ledger is     `driver_data_model.md` E2, undrawn, V2

⟶ **So `currentStage` belongs with the completion ledger** — one owner for *"where is the run"*,
which is the run's state and is neither the sensor's (it senses) nor BUCKET's (it structures).
⚠ The sensor RAISES; that layer PERFORMS the swap after the poll returns (row 26). ★ Three
things, three jobs, and the third one is unbuilt rather than unplaced.

⚠⚠ **AND THE ITEM'S OWN PROPOSED NEXT STEP IS SUPERSEDED BY ITS SUCCESSOR.** RI-38 (SS434)
proposes wiring *"`Bucket.Stage(bucket, 0)` for the STAGELESS V1, where the designator is a
constant"*. **SS435 then proved that hands out ONLY the recovery beacon on any real route**, and
replaced it with `Bucket.FirstStage`. ⟶ **Read the next step as `FirstStage`, not 0.** ★ Filed
here rather than silently corrected because the item is the bench's record of what it proposed.

## RI-38 ✅ DRAINED 2026-08-21 · THE TWO SEQUENCES ON BUCKETS — who DESIGNATES the current one?

**RI-38 DRAINED (Analyst, from RI-42 + the AI-2 audit, 2026-08-21)** — the stamp `check_inbox.py` derives from; the
reasoning is below and in `ANALYST_LOG.md`.

**⟶ THE DESIGNATOR IS THE ROUTE MANAGER.** RI-42 (2026-08-21) already listed this under *"what
this closes for the bench (no longer open): **RI-38 (the designator is the manager)**"* — and the
item was never stamped, so the inbox disagreed with itself and `driver_architecture.md` §6 G1
copied the older side. ⚠ **Found by the AI-2 audit (finding B9) and landed 2026-08-21.**

    the OWNER      the Route Manager — the one stateful owner of an Active Route (AL-2)
    the RAISER     a node COMPLETING whose `Next` is Stage; the ledger fires it
    the SWAP       after the poll returns, never inside one (model row 26 · A12.6a)
    graded by      `driver_manager_acceptance.md` A12.1a · A12.5a · A12.6a

★ **The bench's proposed next step in this item is superseded by its own successor:** it reads
*"wire `Bucket.Stage(bucket, 0)` for the STAGELESS V1"*, and §435 proved that hands out ONLY the
recovery beacon on a real route — replaced by `Bucket.FirstStage` (RI-39, A12.3a). **Read the next
step as `FirstStage`, not 0.**


**Filed by the Addons bench, 2026-08-20 (§434), at Battlewrath's framing:**

> *"there are 2 sequences on buckets. Structuring them. And then checking current stage to
> designate which bucket. Or the run-time knowing how to check which bucket. Maybe sensor.
> which depends on a stage being current to run it's steps or sense the childless beacon
> (A bucket with one item)."*

### ✅ THE FIRST SEQUENCE IS BUILT AND THE SECOND IS NOT

    STRUCTURING     ✅ `Bucket.Build` — `bucket[stage][step]`, §433/§434, rows 23-27
    DESIGNATING     ⚠ `Bucket.Stage(bucket, stage)` will HAND OUT any stage asked for.
                    **Nothing holds `currentStage`, and nothing calls either function.**

### ★★★ THE PRIOR ART ANSWERS "MAYBE SENSOR" — AND THE ANSWER IS NO, FOR A STRUCTURAL REASON

WeakAuras separates the two absolutely (`driver_sensor_brief` §3c, read from the installed
fork): a dedicated **`loadFrame`** decides WHO IS LOADED, and `GenericTrigger`'s hot path only
INDEXES what that produced. ⟶ The designator is a **load-condition layer**, never the thing
that fires.

⚠⚠ **And the sensor cannot be it here without a loop.** The sensor's own output is what raises
a stage advance; if the sensor also chose the bucket, its output would change its input
mid-poll. ★ **Model row 26 already forbids exactly that** — *"it happens AFTER a poll returns,
never inside one — the sensor's result changes the sensor's input, so the armed list must not
be mutated mid-poll."* ⟶ So the sensor RAISES the advance and something above it PERFORMS the
swap. That is one layer, and it is unowned rather than undecided.

★ **And ours is strictly simpler than WA's**, which is worth stating because it makes the
missing layer small: WA re-runs `loadFuncs` for EVERY aura against ~14 state events, because
player state moves from many directions. **Our load condition has ONE input (the stage) and ONE
source of change (the sensor's output)**, so an advance moves two buckets and re-evaluates
nothing.

### ★★ "A BUCKET WITH ONE ITEM" WAS A LIVE DEFECT, AND HIS QUESTION FOUND IT

*"or sense the childless beacon (A bucket with one item)"*. ⚠ **§433's `Bucket.Build` REFUSED a
childless beacon** — *"beacon %s has no children to sample"*. ✅ Fixed §434.

    A1.2  governing acceptance   **"A childless beacon is RUNNABLE"**
    A2.5                         the last child deleted → *"its tabs RETURN to the parent,
                                 which is childless again and behaves as its own single child"*
    A2.6                         an ordinal child is *"the same object as a childless beacon"*
    shipped code                 `Routes.AcceptanceOf`: *"the anchor is its own satisfier
                                 when it has no children"*

⟶ **Four sources, one of them a governing row and one of them a shipped function, and the
bench read none of them** — it built against `ChildrenOf` because that was the accessor it
already knew. ★ *A docket is a working set, not a basis.*

✅✅ **AND HE STATED THE ADDRESS FORM INDEPENDENTLY, minutes later:** *"On the instruction set.
I imagine it'll terminate as `BID:` where a child is `BID:CID`."* ★ That is exactly what the fix
produces — arrived at from `contract.lua:63` and row 2 on this side, and from the shape on his,
**and the two met without either being shown the other.** ⚠ Worth recording as corroboration
rather than as a ruling: it says the bench read the contract correctly, which is a different and
weaker claim than the bench having been told.

⚠ **The second defect fell out of the first:** the lone node addressed itself
`mapID:rid:solo:solo`, **inventing a child id by duplicating the beacon's**. `contract.lua:63`
types `cid` as `optional = true`, and row 2 makes the address the whole ancestry — a repeated
segment claims a child that does not exist. Found by mutation, because the first version of the
row checked for the beacon id, which is present either way.

### THE QUESTION FOR DESIGN — one thing, and the bench will not answer it

**WHO OWNS `currentStage`, AND WHAT RAISES THE ADVANCE?** The shape is settled by rows 24/26 and
corroborated by WA; what is unowned is where the layer LIVES and what its trigger is.
⚠ The bench is not building it: an advance needs a COMPLETION to raise it, and completion is
not the sensor's today (`driver_sensor_brief` G8, A11.9). ★ So this bites when completion
lands, and answering it before then costs nothing — answering it after means unpicking a
lifecycle that grew by default.

★ What the bench CAN do without it, and proposes as the next step rather than as a ruling:
wire `Bucket.Build` → `Bucket.Stage(bucket, 0)` → `Sensor.Arm` for the STAGELESS V1, where the
designator is a constant. That runs the chain end to end with nothing invented and leaves the
layer's shape entirely open.

## RI-36 ✅ DRAINED 2026-08-20 · THE MODEL IS NOT SPECIFIC ENOUGH ON CONSTRUCTION

**RI-36 DRAINED (Opus 5 Analyst, 2026-08-20.)** ⚠ Stamp added §431 by the Addons bench per the
file’s own convention — the heading’s tick is invisible to , which is
what this file tells every reader to run. **Same shape as RI-34’s, which  was built
for and names in its own docstring.**

**⟶ THE RECORD IS `driver_data_model.md` §A5b, ROWS 23–27. Read it there, not here.**
⚠ This item is the WORKING; the model is the SELECTION. Where they disagree, the model wins.

    Q1  should #3 gain a CONSTRUCTION section?     ✅ YES - §A5b added, rows 23-27
    Q2  what is "pre-load"?                        ✅ TERM RETIRED. Two phases named by what
                                                      they do: BUCKET and STAGE
    Q3  the sensor's TWO SETS                      ⚠ STILL OWED IN CODE, correctly - no stage
                                                      to advance means no consumer and no test
                                                      (`driver_sensor_brief.md` G3)

### WHAT WAS DECIDED, in one line each — the reasoning is in §A5b

    23  two phases: BUCKET once per run · STAGE per advance
    24  ★★★ BUCKET may fail LOUDLY; STAGE may NOT. If STAGE can fail, BUCKET did not do its job
    25  BUCKET resolves the ACTION, not only the target - nothing authored is interpreted hot
    26  a stage advance SWAPS buckets, after a poll returns, never inside one
    27  the store's `nil` becomes `0` at BUCKET, once - and the store KEEPS nil, because
        `nil + 1` throws where `0 + 1` silently returns 1 (A2.10a's defect)

### ★ THE METHOD IS INSPECTABLE — peers cited BY FUNCTION in §A5b

⚠⚠ **CITED FOR SHAPE, NOT IMPLEMENTATION** (*"precedence is the proof we can, not the
implementation the addon needs"*). Six citations, each verified 2026-08-20 to resolve to the
named declaration on its exact line — `LoadEvent` · `ScanEvents` · `UnloadDisplays` ·
`scanForLoadsImpl` · the `loadFrame` event list · `CreateFunctionCache`, plus our own
`Routes.List`. ★ **Two were wrong on first writing** (cited where the table is FILLED rather than
where the function is DECLARED) and were corrected before landing — the citation-rot shape this
project has met before.

### ⚠ WHAT THE ITEM FOUND ABOUT US, kept because it is the third instance this week

§427 edited the line four rows above A11.3d and did not read down; §429 then grepped for *"stage
gate"*, *"bounce"* and *"continue gate"* — **never for `bucket`**, the one word the answer was
written in. ★ *An absence is a claim about everywhere I did not look.* ⚠ And the Analyst repeated
the shape twice more in the same session: reading a comment four lines above the code that
superseded it (S7), and claiming a minimum was unenforced from reading one setter.

---

<details><summary>THE WORKING — kept whole, superseded by §A5b</summary>

## RI-36 · (the working)

⚠⚠ **REFRAMED 2026-08-20, SAME DAY IT WAS FILED. ★ THE ITEM STAYS OPEN — only its FORK is
retired, and the fork was already
answered on disk, in two places.** Battlewrath:

> *"There are 2 layers. The sensor doesn't carry both. The sensor checks against the current
> bucket / pre-load items. For reconciliation though. Clearly the model isn't specific enough on
> contruction."*

### ⟶ WHAT THE RETIRED FORK ASKED, answered on disk since 2026-08-19

**A11.3d** — *"THE SENSOR HOLDS TWO SETS, and the second one is recovery"*, his words
*"keeps open the items out of stage, or out of step (for its stage)"*:

    THE GATED SET        nodes at the current stage / step
    THE ALWAYS-OPEN SET  stage 0, and ordinalless children within their stage (§311)
                         ★ built ONCE at ingest, never re-tested against the gate
    Test: advance the stage → the gated set changes and the always-open set does not.

**A11.1a** — *"ingest asserts the order and builds the index (mapID → stage → ordinal buckets,
the no-step bucket always read); the 1 Hz pass walks the bucket, never the lines."*

⟶ **So neither fork limb was right.** The gate is resolved at INGEST by BUCKETING — not
re-armed per stage change (limb A), not re-tested per poll (limb B). And *"two layers"* is the
acceptance doc's own phrase already (`driver_sense_acceptance.md:279`).

### ⚠⚠ HOW THE BENCH MISSED IT — and it is the worst instance of the week

§427 **edited the line four rows above A11.3d** (A11.3's split table, re-pointing its citation)
and did not read down. Then §429 grepped for *"stage gate"*, *"bounce"* and *"continue gate"* —
**never for `bucket`**, the one word the answer is written in. ★ *An absence is a claim about
everywhere I did not look*, and the search scope excluded the term that would have refuted it.
⚠ Third question this week whose answer was already recorded (RI-35 half, RI-34's evidence,
this whole). **The pattern is not forgetting a lesson — it is not recognising its new shape.**

### ★★★ WHAT IS LIVE, and it is HIS point rather than the bench's

**CONSTRUCTION IS ABSENT FROM GOVERNING #3.** `driver_data_model.md` declares itself the entry
point for the STORED and EXPORTED form, and carries the two record kinds, the address, the
numbers, the export shape — **and nothing at all about how any of it is LOADED.** The ingest
bucketing is in #11 (A11.1a), the two sets are in #11 (A11.3d), *"pre-load items"* is in neither.

⟶ A reader arriving at the governing entry point learns what a record IS and nothing about how
it becomes a thing the driver can run. ⚠ **That is exactly the gap that produced this item:** the
bench read #3, found no construction, and invented a fork.

### THE QUESTION FOR DESIGN

### ★★★ HIS DIRECTION, 2026-08-20 — STAGE THE MATERIAL THAT FITS THE CURRENT GATE

> *"We need to stage the material that fit within the current gate. Say. MAPID:RID:Stage, then it
> looks through step, if no step, it holds stage, so the samples have something to check without
> reading through 40 lines. As it has to sample at 0.1. **By the time it's sampling it should have
> a target in mind.**"*

★★ **AND THE LAST SENTENCE IS THE ARCHITECTURE: the sensor should be CHECKING, not SEARCHING.**

### ✅ IT IS A11.1a, and the arithmetic says why 0.1 forces it

A11.1a already rules *"ingest asserts the order and builds the index (mapID → stage → ordinal
buckets, the no-step bucket always read); the 1 Hz pass walks the bucket, never the lines."*
⟶ **Same structure.** What his sketch adds is `RID` — and it belongs, because a store holds many
routes and only one runs: **RID is a SELECTION made before bucketing, not a bucket dimension.**
A11.1a omits it only because it assumed the route was already chosen.

⚠⚠ **AND THE COST IS REAL, MEASURED AGAINST THE BUILT CODE.** `Sensor.NextIn` and `Sensor.Poll`
each walk the whole armed list, so a poll costs `2N` node-visits and `N` square roots. The corpus
holds a **58-beacon** route:

    whole route armed     N=58    116 visits/poll    1,160/s at 10 Hz    580 sqrt/s
    one stage staged      N=5      10 visits/poll      100/s at 10 Hz     50 sqrt/s
                                                            ⟶ 12x

★ **The floor is what makes it bite.** At the old 0.2 s this was half the cost and nobody would
have noticed; at 0.1 it doubles, and it doubles the term that scales with route length. ⟶ **The
right fix is to reduce N, not to micro-optimise the loop** — which is exactly what he is saying.

### ⚠⚠ TWO THINGS THE SKETCH IMPLIES AND DOES NOT STATE

**① STAGE 0 MUST RIDE ALONG — it is a DIFFERENT bucket from "no step".** A11.3d holds two
always-open kinds and the sketch names one:

    "if no step, it holds stage"      = ordinalless children WITHIN their stage   ✓ named
    stage 0                           = the RECOVERY beacon                       ⚠ not named

★ The recovery beacon exists precisely so a player who has gone off-route can rejoin, **so it
must be armed whatever the current stage is.** ⟶ The armed set is `current stage's bucket + its
no-step bucket + stage 0`, and dropping the third would make recovery work everywhere except
after the run has moved on — the one case it is for.

**② THE RE-STAGE POINT MUST BE DEFINED, because this design makes re-staging MANDATORY.**
If the armed set is the current stage's bucket, a stage advance must rebuild it. ⚠ And the
advance is caused by **the sensor's own output** — a node firing whose `Next` is Stage. So the
sensor's result changes the sensor's input, and the armed list cannot be mutated mid-poll.

★★ **MAVLink answers the same shape and is worth borrowing the SHAPE of:** `autocontinue` moves
the cursor *when the command completes*, as a discrete step BETWEEN items, never during one.
⟶ So: **re-stage AFTER the poll returns, never inside it.** ⚠ Recorded as the constraint, not as
a mechanism — where the call sits is construction's design, which is Q1 below.

⚠ **This also RETIRES the last live piece of the old fork.** Limb A's cost was *"the driver must
RE-ARM at each stage change, which is a lifecycle event nothing has specified"* — under his
direction that re-arm is not a cost of one limb, **it is the design**, and it now has a stated
point rather than a gap.

### ★★★ THE ANALYST'S RECOMMENDATION — TWO PHASES, AND THE REASON IS FAILURE SEMANTICS

_Asked for directly, 2026-08-20: **"What would you suggest? … This is a run time computer science
question on best practice."** ⚠ A RECOMMENDATION, not a ruling. Gating stays his._

★★ **THERE ARE THREE FREQUENCIES, AND ONE OF THEM CANNOT BE ALLOWED TO FAIL.**

    once per run      the route is chosen           expensive is fine · failing is fine
    per stage advance maybe 10-30 times a dungeon   ⚠⚠ MID-RUN, MID-COMBAT
    10 Hz             the poll                      a CHECK, never a search

⟶ **The middle row decides it.** A stage advance is triggered by the sensor's OWN OUTPUT — a node
firing whose `Next` is Stage. If staging stage 4 is the moment we discover stage 4 names an action
the runtime does not hold, **there is no good answer**: abort the run, or skip the stage, with the
player standing in a dungeon. ★ **So validation has to happen where failing is free, and that is
once per run, before anything arms.** That is the field's answer too (ASL · BT.CPP · Home Assistant
all fail at load and name what was missing — `driver_sensor_brief.md` §3b).

    RESOLVE   once per run.   MAY fail, and SHOULD fail loudly. Pull the route out of the
              store, assert the order, build the index, and check every `action` / `arg` /
              `sense` id names something the runtime actually holds. Cost is irrelevant here.
    STAGE     every advance.  MAY NOT fail. A pure lookup into a structure RESOLVE already
              proved correct: current stage's bucket + its no-step bucket + stage 0.

★★★ **THE INVARIANT, and it is the whole recommendation in one line:**

> **If STAGE can fail, RESOLVE did not do its job.**

### ★ THREE SUPPORTS, of which the first is ordinary computer science

**① PREPROCESS / QUERY.** Build the index once at `O(N)`; select a bucket at `O(1)` per advance.
Folding them into one step rebuilds the index on every advance — `O(N)` × 30 instead of × 1. ⚠ The
absolute numbers are small (58 beacons); **the shape is the point**, and it is the same shape as
`r2` being pre-squared once in `snapshot()` rather than per sample.

**② TESTABILITY.** Two phases make *"does this route load?"* answerable **without a running
sensor** — the same property A11.3c demanded of the sensor, applied one layer out. Under one
phase the validation is only reachable by arming.

**③ ⚠⚠ WE ALREADY RUN A LOAD PHASE, so this is not a new concept in this addon.** `Routes.Init()`
(`routes.lua:53-57`) runs `MigrateRIDs` then `DropRetired` at `ADDON_LOADED` — *drop and TELL* is
already our house answer to "the stored data mentions something retired". ★ And `Adaptor.Codes()`
already holds the "what the runtime has" side. **Nothing yet checks a route's ids against it** —
which is RI-22's index-into-a-grown-table, still unowned.

### ⚠ AND THE SCOPE DISCIPLINE, because it cuts against building both today

**V1 IS STAGELESS. There is ONE bucket, so STAGE and RESOLVE collapse into the same call and the
split has no consumer.** ⟶ *Existing is not a reason to ship*, and neither is symmetry.

★★ **So: decide the BOUNDARY now, defer the second function.** What must exist today is not two
functions — it is the stated rule that **validation happens before arming and nothing after it is
allowed to fail.** One function may do both in V1. ⚠ **The boundary is free to state now and
expensive to retrofit**, because retrofitting it means finding every place that learned to cope
with a failure that should never have reached it.

### ✅ SETTLED 2026-08-20 — THE TERM IS DROPPED AND THE PHASES ARE NAMED BY WHAT THEY DO

> Battlewrath: *"I'd drop the word I used and go for what described what they do. One reads
> through the whole saved variables that gets offered. Gates on Map, picks the right RID, then
> buckets each stage, so it can work through steps. Stage 0 falls out naturally into a bucket.
> And step 0 never has a value to gate against."*
>
> *"What loads on boot of WoW is the full saved variables. We don't get to decide what section.
> So we filter on map first for relevance. Dungeon Run already does this for loading an authored
> route against a map."*

⟶ **"pre-load" is retired as a term.** Two phases, each named by its dumb action:

    BUCKET   once per run.   Read the offered store whole - the client hands us ALL of
                             SavedVariables and we do not choose the section - keep this
                             MAP for relevance, pick the RID, lay the route out in stage
                             buckets so steps can be worked through.
    STAGE    per advance.    Hand the current stage's bucket (with stage 0) to `Arm`.

✅ **AND THE MAP FILTER IS SHIPPED PRECEDENT, not a new idea.** `Routes.List(mapID)`
(`routes.lua:335-341`) already walks every route id and keeps `r.mapID == mapID` — the editor
does exactly this to offer an authored route against a map. ★ Note it gates on a **route-level**
`mapID`, so a route belongs to ONE map and floors live in `PLACE` — which retires an Analyst
worry about multi-floor routes before it was worth raising.

### ⚠⚠ ONE CONVERSION THE DESIGN NEEDS, AND ROW 10 ALREADY ORDERED IT

Both *"falls out naturally"* claims are true **of the RECORD and not of the STORE.** Data model
row 10: **`nil` in the store, `0` on the record.**

    stage 0    a stageless beacon holds `stage = nil` -> `bucket[nil]` is a Lua ERROR to
               write and silently nothing to read
    step 0     an un-ordinalled child has no step value at all - the same nil

⟶ **So BUCKET is where row 10's conversion gets performed**, and it is one line: normalise nil to
0 on the way in. ★ Not a flaw in the design — it is the design's one required step, and row 10
already gave the reason: *"A value, never an empty slot, because missing / absent / truncated all
look alike."*

⚠⚠ ~~And the stage-0 bucket will be EMPTY until the stageless beacon lands; `AddBeacon` forces a
stage (seed S7).~~ **STRUCK 2026-08-20, WRONG WHEN WRITTEN — S7 IS CLOSED.** `AddBeacon`
(`routes.lua:432-436`) already takes `0` as the stageless REQUEST and stores `nil`. ★ The
Analyst read a comment four lines above the code that superseded it (`:416` still opens *"ALWAYS
A STAGE… no path in through here either. Owed"*, and the ★★★ S7 block below it is the
correction). ⟶ **The stage-0 bucket can be populated today.**

### ⚠⚠ "IS NIL NEEDED?" — YES, AND THE BENCH HAD ALREADY PROVED IT BETTER

⚠⚠ **§395 REACHED THIS FIRST AND MEASURED MORE.** `routes.lua:418-429` already rules it:
*"`0` is the RECORD form of 'always eligible' and `nil` is the STORE form. So a caller asking
for 0 gets `nil` stored, and the two forms never both exist."* — with the reason: *"In Lua
`not 0` is FALSE, so a STORED zero is not stageless to anything that tests the field… **The
eight consumers were measured against NIL; storing 0 quietly un-measures them.**"*

★ The Analyst's arithmetic below is the same conclusion reached independently and against SEVEN
sites rather than eight. **Kept because the `nil + 1` demonstration is the crisp form, and it
CITES §395 rather than standing beside it.** ⟶ Where they differ, §395 wins: it is in the code,
next to the door it governs.

### THE ANALYST'S WORKING, arriving at §395's answer

> Battlewrath: *"0 -> nil -> 0. Is Nil needed? Either a beacon mints as 0 or it's ordinal. And
> children can start as 0 and get promoted into a ordinal."*

★ **The instinct is right about DOWNSTREAM and wrong about the STORE, and the evidence is one of
our own defects.**

    nil + 1   ->  THROWS: "attempt to perform arithmetic on a nil value"
    0   + 1   ->  silent, returns 1

⟶ **`nil` is a LOUD absence; `0` is a silent one.** And A2.10a (§393) is exactly that trap
firing: `Routes.Outcome` read `b.outcome or ((b.stage or 0) + 1)`, which answers **1** for a
stageless node — *"sending the player back to the START of the route on the completion of a
recovery beacon"*.

⚠⚠ **THE `or 0` WAS THE BUG.** With `0` stored instead of nil the line would read `b.stage + 1`,
give the same wrong answer, and have **no `or 0` left to point at.** ★ Storing 0 does not remove
the trap — it removes the tell.

### ✅ SO THE REAL FINDING IS NOT "DROP NIL", IT IS "STOP CONVERTING SEVEN TIMES"

Measured across the addon, the nil→0 conversion is paid at **seven scattered read sites**
(`object.lua:314` · `promoter.lua:166` · `routes.lua:379 · 1805 · 1853 · 1862` and the sort at
`:1824`) — and `routes.lua:1036` converts BACK to nil. ⚠ **That is the actual wart: not the nil,
but that every consumer re-decides how to spell it.**

⟶ **BUCKET is the one door, and this is a second job for it beyond relevance-filtering:**

    the STORE     `nil`   absence stays LOUD - arithmetic on it throws       (unchanged)
    BUCKET        the ONE conversion, at the door, once
    downstream    `0`     a value, never an empty slot                       (row 10)

★ Everything downstream of BUCKET sees a number and never writes `or 0` again; `Routes.Outcome`'s
nil test stays because it is UPSTREAM, in the editor, where the loudness is the point.

⚠ **STILL OPEN AND SEPARATELY HIS:** whether the EDITOR mints a child at `0` explicitly. That is
a different question from the store's spelling — it asks whether *"no ordinal yet"* is a state the
AUTHOR should see and promote out of, which is a pane decision, not a driver one.

★ Everything else stands: the RESOLVE/STAGE failure boundary above is unchanged — **BUCKET is
where validation lives and may fail loudly; STAGE may not fail** — and stage 0 riding along plus
re-staging AFTER a poll returns are still the two consequences.



★ Whether **"pre-load"** IS this staging step under his own name, or a phase BEFORE it (e.g.
resolving the route out of the store, validating that every `action`/`arg` id names something the
runtime holds — the field's *"fail loudly at load"*, `driver_sensor_brief.md` §3b). ⟶ The two
readings are still both open, and the answer decides whether construction is one step or two.

★ **A SENSOR BRIEF NOW EXISTS — `driver_sensor_brief.md`** (Analyst, 2026-08-20), at
Battlewrath's ask. ⚠ **It rules nothing and takes no governing number** — precisely because Q1
is the designer's call and a brief must not settle it by existing. 8 LINES (each citing its row),
2 SEAMS, **9 GAPS in the order they bite**, grounded in `sensor.lua` as built.

★★ **Two it found that were on nobody's list:** `Sensor.Sample` is called and DEFINED NOWHERE, so
*"the sensor is built"* and *"the sensor is sampling"* are different claims · and **the sense words
are TRANSITIONS while the sensor keeps no previous verdict** — `Poll` overwrites `inSet[n]` without
reading the old value, so `whenOn`/`seen`/`whenOff` have nothing to compare against. ⚠ Neither is
a defect today (nothing consumes a sense word until the flight list exists) — **both are design
questions rather than later bug fixes.**

1. **Should #3 gain a CONSTRUCTION section**, or should it point at #11 and say so? ⚠ The bench
   will not choose — #3 is the selection file and what belongs in it is the designer's call.
2. ★ **What is "pre-load"?** The term is his and appears nowhere on disk. A11.1a's index is built
   AT INGEST; whether pre-load is that same step under another name, or a stage before it, is not
   derivable from what is written.
3. ⚠ **The sensor's TWO SETS are OWED in code.** `sensor.lua` holds one flat list. Under a
   stageless V1 every node's stage reads 0 → always-open, so the flat list is *behaviourally*
   right today and *structurally* missing the split. **Not built — it has no consumer until
   stages land**, and *existing is not a reason to ship*. Recorded so it is not discovered late.

---

### ⬇ THE FORK AS FILED, kept whole (RETIRED, not a ruling) - WHO APPLIES THE PREFIX BOUNCE?

**Filed by the Addons bench, 2026-08-20 (§429). ⚠ A DESIGN FORK WITH V2 CONSEQUENCES**, not a
blocker: P5 is built and green either way.

### THE INSTANCE, on screen

`rule.lua` gates on **mapID only**, and that is correct — A11.2a says *"the gate: same mapID,
tested FIRST"*, and a sample carries no `RID`, `Stage` or `Step` to test against:

    function Rule.Gate(sampleMapID, nodeMapID)
        return sampleMapID ~= nil and sampleMapID == nodeMapID
    end

`sensor.lua`'s `Arm(list)` takes **whatever list it is handed** and applies no prefix bounce.
⟶ So today the four-part gate is applied by nobody, because nothing yet builds the list.

### THE FORK

    A   THE CALLER GATES.  The flight list is built pre-gated and `Arm` receives only admitted
        records. ★ Fits *"It's a flight list. Not dynamic."* exactly — fixed once armed.
        ⚠ But `Stage` ADVANCES during a run. Under A the driver must RE-ARM at each stage
        change, which is a lifecycle event nothing has specified.

    B   THE SENSOR GATES PER POLL.  The whole route is armed once and `Poll` bounces on the
        prefix before the geometry. ⚠ Survives a stage advance with no re-arm — but it makes
        the armed set a superset of the live set, so "armed" and "eligible" stop being the
        same thing, and the in-set has to say which it holds.

★ **V1 does not choose between them.** Stageless means every node continues, so A and B are
indistinguishable until stages land. ⚠ **Which is exactly why it is worth answering now rather
than at the moment the difference first bites** — by then there is a built lifecycle to unpick.

### WHAT THE BENCH IS NOT DOING

Not building either. ⚠ The gate has no live consumer yet (nothing constructs a flight list), and
*the burden is on the bench artefact — existing is not a reason to ship.* ★ Recorded now because
the RULING arrived now, and the model row (§A1.4a) that carries it should not have to guess at
its own consumer.

</details>

## RI-35 ✅ DRAINED 2026-08-20 · A11.4b SAYS `R` AND `BAND` ARRIVE AS INDEXES. RI-22 SAID THEY ARE NUMBERS.

**RI-35 DRAINED (Battlewrath, 2026-08-20), verbatim:**

> *"Yes. Indexes is complete. User pick. R 5 the lowests. 2.5 above the lowest offered."*

    O  YES - snapshot at arm is the intended reading. THE MENU IS CLOSED; the user PICKS
       from it; the store holds the NUMBER (12a stands unchanged).
    ✗  the index is NOT a live lookup the driver performs · R does NOT go below 5 · the band
       does NOT go below 2.5
    ✓  R's offered list floors at 5 · **band's list ALSO floors at 2.5 and runs UPWARD** -
       2.5 is the minimum and the default at once · A11.4b's index framing is finished
    →  A11.4b (headstone) · #3 §A3b 12a · A10.3e

### ★★ AND MOST OF IT WAS ALREADY ON DISK - the bench filed a question half-answered

⚠ **`R = 5` was already ruled**, in RI-34: *"R = 5 IS THE FLOOR IN THE PICKER DROPDOWN"*
(`Reconcile_inbox.md:1508`, Battlewrath, same day). And 12a already said *"the choice is a
LOOKUP"* - which is the menu. ★ So RI-35 asked about a mechanism whose two halves were
recorded in two different files, and the bench read one of them.

⟶ **What is genuinely NEW is the word "complete": the offered set is CLOSED.** That is what
makes an index well-defined at all, and it is why both readings of the ruling converge - a
closed menu the user picks from, whose chosen VALUE is what the store keeps. ★ Under either
reading `sensor.lua` is unchanged: it receives numbers and snapshots them.

### ⟶ WHAT THIS SETTLES FOR THE DRIVER: nothing moves, and that is the useful outcome

`sensor.lua` already takes numbers off the record and snapshots them at arm. **The ruling
confirms the built shape rather than redirecting it.**

⚠⚠ **AND THE LANE WAS CORRECTED THE SAME DAY.** Battlewrath: **"read a table per value" is on
the picker side. The sensor its self will have absolute values by the time it reaches it.
Defined in the BID:CID or BID for that POS of the node.*★ So A11.4b's requirement does not
relocate INTO the driver — it was never the driver's. `R` and `Band` are CHARACTERISTICS of the
node, carried at `BID:CID` beside `POS`; the lookup happened once, at authoring time.
⟶ The bench had re-aimed the requirement at the node record to keep it alive on this side.
**The snapshot it justified is right; the justification was borrowed from another lane.** Its
warrant is A11.3's *"running inventory of the RESOLVED position(Parameters)"* — a snapshot in
his own words. ★ Same fault-shape as the band misparse above: **taking a true sentence and
finding it a home on the side I happened to be building.** ⚠ And it does NOT hand the driver a
validator: the author's door is a dropdown, so R ≥ 5 is enforced by the OFFERING, not by a
guard - the Analyst's contrary claim was already struck in RI-34 as a scope fault (reading
`setReach`'s bare `tonumber` and concluding the minimum was unenforced everywhere).

### ⚠⚠ THE BENCH READ THE BAND RULING BACKWARDS - corrected by Battlewrath, same day

The ruling reads *"2.5 above the lowest offered"*, and the bench took it as **"2.5 sits above
some lower offer"** — concluding the band list extended BELOW 2.5, and filing the unnamed
floor as owed to A10.3e. ❌ **Wrong. It parses as "2.5 [and] above [is] the lowest offered":
2.5 IS the band's floor, and the list runs UPWARD from it.**

✅ **So nothing is owed, and the two pickers have the same shape:** an offered list with a
ruled minimum — **R floors at 5, band floors at 2.5** — enforced by the OFFERING rather than
by a guard in the driver.

★ And the correct reading is the one that agrees with everything already on disk: 12a makes
2.5 the DEFAULT, RI-22 made the band **upward only** because *"our data points are captured
from the floor level"*, and 2.5 covers the measured jump apex of ~1.64. ⚠ **A floor below 2.5
would have been the one value in the design that pointed downward** — the bench built a gap
out of a misparse and did not check it against a single one of those.

### ★★★ THE LESSON THIS ITEM ACTUALLY CARRIES - a doc that flagged its own dependency

A11.4b wrote *"whether the EDITOR stores an index or a number is RI-22's open question and
this does not answer it."* ★ **That is a correctly-written row.** It named its dependency, in
its own text, at the point of use. ⚠ **And it still went stale, because nothing reads flags.**
A dependency recorded in prose is a note to a human who happens to be looking at that line -
it is not a link anything can traverse when the depended-on item drains.

⟶ **Third instance this week of a note that became false without being touched** (RI-34's
`MAX_CLOSING_SPEED` line, §424's stale floors, this). *A grep finds moved words; it cannot
find moved load.* ★ The candidate countermeasure - **when an RI drains, sweep for rows that
NAME it** - is mechanical and cheap, and is banked as a tooling seed rather than built on the
strength of one item.

---

### ⬇ THE ITEM AS FILED, kept whole - A11.4b SAYS `R` AND `BAND` ARRIVE AS INDEXES. RI-22 SAID THEY ARE NUMBERS.

**Filed by the Addons bench, 2026-08-20 (§425, building P5). ⚠ REPORTED, NOT RESOLVED** —
`DRIVER_BASIS.md`: *"if two governing docs disagree, the LOWER number wins and the
disagreement is REPORTED, not resolved by the builder."*

### THE TWO TEXTS

    #3   driver_data_model.md 12a      "the STORE holds the number, not the menu index"
         contract.lua (§405)           `r` and `band` are both typed "number"
    #11  driver_sense_acceptance.md    A11.4b: "`R` and `Band` reach the driver as INDEXES
         A11.4b                        into its own config table"

⟶ **3 < 11, so the build took the number.** `sensor.lua` snapshots the node's values at arm.

### ★★ AND A11.4b DISCLAIMED ITS OWN PREMISE — the disagreement is a TIMING artefact

A11.4b carries this scope line verbatim:

> *"⚠ This is the driver's side only; whether the EDITOR stores an index or a number is
> RI-22's open question and this does not answer it."*

★ **RI-22 then answered it.** The row was written correctly, against an open question, and
was left standing when the question closed. ⚠ **Nothing in A11.4b's text changed when RI-22
drained** — the same shape as RI-34's `MAX_CLOSING_SPEED` note: *a grep finds moved words, it
cannot find moved load.* **Third instance this week, and the first where the doc had
explicitly flagged its own dependency.** The flag did not help, because nothing reads flags.

### ⟶ WHAT THE BENCH BUILT, so the ruling knows what it is amending

A11.4b's TEST was *"arm, then break the config table; the pass still runs on the values it
resolved."* With numbers there is no config table to break, so that test is **vacuous** —
which would have been a green row proving nothing.

★ **The REQUIREMENT survives its mechanism: nothing may read a table per sample.** With
numbers on the record, the thing that can still be re-read is **the node record itself**, and
holding a live reference to it is the same per-sample lookup wearing another shape — worse,
because the parameters can then change *underneath a run*. So `Sensor.Arm` **snapshots**, and
`smoke_sensor` arms on a node, then moves it and inflates its radius; a reference follows and
a snapshot does not. Mutation confirms the row bites (`M3`).

### THE QUESTION FOR DESIGN

1. **Is "snapshot at arm" the intended reading of A11.4b now that indexes are gone?** The
   bench believes yes and has built it, but the row no longer says what it tests.
2. **Should A11.4b be re-worded, or headstoned and replaced?** ⚠ The bench will not rewrite
   an acceptance row's text — that is the fault the reconcile machine exists to prevent.
3. ★ **Is there a class of A11 rows with the same dependency?** A11.4b is the one P5 walked
   into. A row that names an open RI is a row whose premise can expire silently, and the
   bench has no way to find the others except by building into them one at a time.

## RI-37 ~~· AN OPEN BAND HAS NO WIRE SPELLING~~ ✅ RETIRED 2026-08-20 — THE PREMISE WAS WRONG

**RI-37 DRAINED (retired — premise refuted by Battlewrath, 2026-08-20.)** ⚠ Stamp added §431;
*retired* closes an item exactly as *drained* does, and the grep only reads one word.

**Battlewrath: *"Band is set as 2.5 yards and can be picked upwards. Infinity is an insane
proposal."*** ⟶ **THERE IS NO OPEN BAND.** RI-35 settled it the same day: *"band's list ALSO
floors at 2.5 and runs UPWARD — 2.5 is the minimum and the default at once"*, the menu is CLOSED
and the store holds the NUMBER. **So `Rule.OPEN` is unreachable from any authored record**, and
the question this item asked cannot arise.

    the residue, and both halves are already ruled
    · a store `band` of nil means THE AUTHOR HAS NOT PICKED - RI-2's nil exactly
      (*"raw (nil = the author set nothing); the consumer resolves"*), NOT "open"
    · on export it ships as the resolved number, per row 10 (*"a value, never an empty slot"*)
      ⟶ 2.5, the floor and the default at once. Nothing to decide.

⚠ **`Rule.OPEN` stays CORRECT where it is and is wrong as a wire concept:** it is the pure
rule's fallback for a nil it may be handed (`dz <= (bandUp or Rule.OPEN)`), not a value any
record can carry. ★ The Analyst read a code affordance as a data state.

★ **WHAT SURVIVES THE ITEM** is the row 27 guard it produced — the nil→value conversion is PER
FIELD — which stands with a corrected band value.

<details><summary>THE WORKING — kept whole, premise refuted</summary>

## RI-37 · (the working) AN OPEN BAND HAS NO WIRE SPELLING — and the exporter does not exist yet

_Filed 2026-08-20 by the **Analyst** after Battlewrath's ask to re-read the flight-controller
prior art (`history/prior_art_execution.md`, §384). ★ The audit predicted this exact field; the
code arrived at the same answer independently by mutation; **nobody has joined them.**_

### ★★ WHAT THE PRIOR ART ALREADY SAID, and we have been living it without naming it

MAVLink — hands-off, safety-critical, two decades in service — **gives NaN a JOB**: `param4: yaw
(degrees, or NaN for NO CHANGE)`. The audit drew the three-way split:

    a  REJECT everywhere                                          A11.2e as written
    b  REPRESENT, meaning undefined                               CBOR
    c  REJECT where it is nonsense, ASSIGN MEANING where          MAVLink
       "unset" is a real state of a field whose every
       finite value is legitimate

⚠ The audit then named **the exact field it would bear on**: *"does any of our fields have a
legitimate UNSET… `Band` being optional (RI-22) is exactly such a field."*

★★★ **AND `rule.lua` (§416) SHIPPED (c) WITHOUT CITING IT.** `Rule.OPEN = math.huge` is a
non-finite value carrying meaning, while non-finite is otherwise refused:

    if band ~= nil and band ~= Rule.OPEN and not finite(band) then return false end

Its own comment: *"nil and OPEN are the same INTENT expressed two ways, and a rule that accepts
one and refuses the other punishes being explicit."* ⟶ **That is option (c), arrived at by
mutation testing, matching a flight controller's answer.** The convergence is worth the record.

### ✅ THE TRANSPORT CARRIES IT — measured, not assumed

`math.huge` round-trips through AceSerializer. Run against the vendored library:

    5        wire ^1^N5^^         -> 5           ROUND-TRIPS
    2.5      wire ^1^N2.5^^       -> 2.5         ROUND-TRIPS
    inf      wire ^1^N1.#INF^^    -> inf         ROUND-TRIPS
    -inf     wire ^1^N-1.#INF^^   -> -inf        ROUND-TRIPS

It is deliberate: `serNaN`/`serInf`/`serNegInf` and `DeserializeNumberHelper`. ⚠ **One fragility,
named not feared:** the wire token is `tostring(1/0)` computed AT LOAD TIME, so it is the
platform's spelling — `1.#INF` here. Every CoA user runs the same 3.3.5 client, so it holds; it
is a platform string rather than a defined token, and that is the sort of thing that only bites
across builds. **No action proposed.**

### ⚠⚠ SO THE ONLY REAL GAP IS `nil`, AND IT IS A ONE-LINE DECISION

    contract.lua:80    { name = "band", type = "number" }        NOT optional
    the store          band may be nil (the author never set one)
    the wire           a required number field - so nil has NOWHERE to go

★ `Contract.Optional("characteristic","band")` returns **false**, so an emitted empty slot fails
the contract check, and omitting the field shifts every position after it.

⚠⚠ **NARROWED 2026-08-20 — IT IS NOT A THREE-WAY CHOICE. ROW 10 ALREADY RULES THE PRINCIPLE.**

    ~~② make `band` optional and emit an empty slot for nil~~   ⟶ REFUSED BY ROW 10:
       *"A value, never an empty slot, because missing / absent / truncated all look alike."*
       ⚠ The empty-slot pattern IS shipped (`nextArg`, `trigger`) — but there it means a
       genuine ABSENCE ("this Next type has no arg"). **An open band is a MEANING, not an
       absence**, so it takes a value like stage 0 does.
    ~~③ emit a sentinel that is not inf (0? -1?)~~              ⟶ REFUSED: inventing a
       sentinel while a working one is in the code and already round-trips. ★ And **0 is
       actively wrong for this field** — see the asymmetry below.

⟶ **SO THE ONLY QUESTION LEFT IS YES / NO:** an open band ships as `Rule.OPEN` (infinity),
normalised at export so nil and OPEN have one wire spelling. ✅ Measured to round-trip through
the vendored AceSerializer (`serInf` + `DeserializeNumberHelper`).

### ★★ AND A SHARPENING THAT CAME OUT OF ROW 27 — `nil` MEANS TWO DIFFERENT THINGS

    stage / step    nil -> 0    -> always eligible        (row 10)
    band            nil -> ∞    -> always vertically in   (`Rule.PointFire`: `dz <= (bandUp
                                                          or Rule.OPEN)`)

★ Both spell *"no constraint"* — and they land on **opposite ends of the number line**, because
a gate you must MATCH relaxes toward 0 while a tolerance you must FALL WITHIN relaxes toward ∞.
⚠⚠ **So row 27's conversion at BUCKET is PER FIELD, not one rule.** A single blanket `nil → 0`
would make every open band mean *"dz must be exactly 0"* — the most restrictive value, from the
most permissive intent. **Recorded here because row 27 could otherwise be read as one sweep.**

⟶ **My read is ①**, and only because `rule.lua` already ruled that nil and OPEN are one intent:
under ② the wire re-creates the two spellings the rule just collapsed, and a reader would have to
re-derive that they mean the same thing. Under ③ we would be inventing a sentinel while a
working one is already in the code and already round-trips. ★ **① adds no field, no optionality,
and no new number.**

    IMPACT
      on disk now      NOTHING. ★★ THE EXPORTER IS NOT BUILT - `contract.lua` declares the
                       shape and `smoke_contract.lua` tests it, and that is all. **This is
                       free to decide now and expensive to decide after P2 lands.**
      criteria         A11.1 (the row shape, P2 - THE LIVE STEP) · A11.2e's non-finite
                       clause gains a stated exception instead of an incident note
      does nothing to  the rule · the constants · the park · the fixtures

### ★ AND ONE PRE-EMPTIVE GUARD FOR P2, from the same audit

G-code's **modal state** and polyline's **delta encoding** buy compactness with the same currency:
**sequential dependence.** The audit priced both out against Battlewrath's recovery rule — *"the
driver will need to always listen to update beacons… otherwise recovery can't be done"* — because
**a row that must be readable out of order cannot be modal and cannot be a delta.**

⚠ **P2 is exactly the step where both will look attractive again**, which the audit predicted in
those words. ★ Nothing to decide; recorded so the answer is reachable at the moment the question
arrives, rather than re-argued.

</details>

## RI-34 ✅ DRAINED 2026-08-20 · THE POLL FLOOR MOVES TO 0.1 — and the divisor with it

**RI-34 DRAINED (Opus 5 Analyst, 2026-08-20).** ⚠ Stamp added §422 per the file's own
convention - the heading's tick and the body's "CONFIRMED AND EXTENDED" are both invisible
to `grep "RI-[0-9]* DRAINED"`, which is what this file tells every reader to run. The
outcome below is unchanged; only its READABILITY to the convention is.

**RI-34 CONFIRMED AND EXTENDED 2026-08-20 (Opus 5, Analyst). ✅ THE FLOOR IS 0.1, AND IT IS
NECESSARY BUT NOT SUFFICIENT — `MAX_CLOSING_SPEED` IS THE OTHER HALF AND IT BINDS HARDER.**

★ **The arithmetic confirms rather than proposes, exactly as filed**, and it survives the more
conservative figure: the bench used 50.6 yd/s (the 0.2 s runs); the corpus also holds **56.9
yd/s** (the 1 Hz runs, inbox §RI-33 §4). The conclusion holds under 56.9, so the answer is not
sensitive to which figure is picked. FLOOR must be `< 2R/v` = **0.176 s** at 56.9 — 0.1 gives
1.76× margin; **0.2 fails by a factor of 1.14.**

### ★★★ HOW IT WAS CAUGHT — and it was not caught by the doc pass

Battlewrath, 2026-08-20: **"What flagged this is that we landed on 0.1 needed for 5 R on a
point. They reported the spec as 0.2."** ⟶ A live conclusion collided with a written spec.

⚠⚠ **AND THE SPEC THEY READ BACK WAS MINE, FROM AN HOUR EARLIER.** A11.2f had no floor in it
at all before the catch-up pass — the number lived in the asklist, and I PROMOTED it into the
acceptance brief as spec while fixing the row's reason. ★ The bench's finding said *"the row's
ANSWER may still be right; its REASON is spent"*, and **I audited the reason and never audited
the answer.** I inherited the scope of the report — the same fault, one level up, as A11.2f
inheriting `30` from COA_Landmarks without re-checking its premise.

★★ **BOTH NUMBERS WERE IN ADJACENT ROWS OF THE SAME EDIT AND I NEVER MULTIPLIED THEM.** A11.2a:
R = 5, samples through the centre. A11.2f: a 0.2 s floor. `5 × 2 < 50.6 × 0.2` was sitting there.

⚠⚠ **THE LIMIT THIS EXPOSES IN THE RETIREMENT-GREP DISCIPLINE (RI-33's lesson, filed the same
day): A GREP FINDS MOVED WORDS. IT CANNOT FIND MOVED LOAD.** Nothing in A11.2f's text changed
when the rule narrowed, so no search could surface it — and yet the narrowing is exactly what
broke it. Under segment the floor was a COST setting (finer = more phantoms, coarser = fewer);
under point-only it became a CORRECTNESS setting (coarser = missed beacons). **Same number, new
job, no textual trace of the change.**

⟶ **SO THE DISCIPLINE GAINS A SECOND HALF.** When a rule narrows, the grep is not enough:
**re-derive the CONSTANTS the rule now leans on, rather than re-citing them.** Ask what each
constant is now load-bearing FOR, not whether it still reads correctly.

★ And the general form, which is why this is worth the space: **consistency checking finds rows
that disagree with a moved premise; it cannot find a row that is consistent and wrong.** Only
working the mechanism does — which is what "5 R on a point" was.

### ⚠⚠ BUT THE FLOOR ALONE CHANGES NOTHING, AND THIS IS THE FINDING

The filing says the two constants *"multiply rather than substitute"*. ★ Measured, it is
stronger than that: **against a fast approach the floor does not move the failure by a single
yard.** Simulating the ruled schedule `nextIn = max(FLOOR, (dist−R)/MAX_CLOSING_SPEED)` over
every approach distance to R = 5:

    FLOOR   MAX_CLOSING   does any approach skip R=5 entirely?
    0.20        30        SKIPPABLE at 50.6 and 56.9 yd/s
    0.20        57        SKIPPABLE at 50.6 and 56.9      ← floor fixed, still broken
    0.10        30        SKIPPABLE at 50.6 and 56.9      ← constant fixed, still broken
    0.10        57        ✅ safe at every measured speed  ← the only safe cell

★★ **The two failures are DIFFERENT and each constant owns one:**

    the APPROACH   a poll far out schedules a long wait. At 60 yd the schedule is
                   (60−5)/30 = 1.833 s, and 56.9 yd/s covers 104 yd in that time — the
                   player is 44 yd PAST the beacon before the next sample. ⚠ The floor is
                   a MINIMUM and this failure is in the MAXIMUM, so the floor cannot see it.
                   ⟶ Fixed only by MAX_CLOSING_SPEED ≥ the fastest real closing speed. The
                   proof is exact: with `MCS ≥ v`, travel `v(d−R)/MCS ≤ (d−R)`, so the next
                   sample lands no nearer than R — the approach can never overshoot.
    the CROSSING   once a sample lands at the boundary, the player must not cross the
                   DIAMETER before the next one. ⟶ Fixed only by the floor: `v·FLOOR < 2R`.

⟶ **ONE DECISION, NOT TWO: both constants move together, or neither does anything.**

    POLL_MIN            0.20  →  **0.10**              his word, confirmed by the arithmetic
    MAX_CLOSING_SPEED     30  →  **100** (= TELEPORT_VMAX)  ✅ settled - see below

⚠⚠ **MY "≥ 57, 60 SUGGESTED" WAS WRONG — WITHDRAWN 2026-08-20, same day.** Battlewrath:
*"I can tell you how fast a reaper charge is. Not what we will ever see."* ★ He is right that
any value set from the CORPUS MAXIMUM is a bet on the fastest ability that will ever exist on
this fork, and 60 loses that bet cheaply: **measured, MCS = 60 is unsafe at 100 yd/s** — a speed
the desk itself classifies as travel.

★★★ **WHAT THE CONSTANT ACTUALLY BUYS, which is the question he asked: PERMISSION TO SLEEP.**
It is a CPU dial and has no other job. Larger = shorter sleeps = more polls = safer. So it
should not be set from what we have SEEN; it should be set from **the fastest thing we are
OBLIGED to treat as movement** — and the project already ruled that number.

    minimum MCS safe to TELEPORT_VMAX (100 yd/s)      95      measured
    ⟶ MAX_CLOSING_SPEED = TELEPORT_VMAX = 100                 above it, with margin

    cost at 100, a 60 yd run-in at 7 yd/s     37 polls over 7.9 s  =  4.7 polls/s
                                              the 0.1 s floor applies from 15 yd out

⟶ **The throttle's speed assumption and the desk's travel ceiling become ONE constant, and they
should be: both answer "what is the fastest thing we must treat as movement?"** Above it, the
desk already says not-travel; below it, the schedule is now provably safe at every speed.

★ **AND NO DYNAMISM IS NEEDED** (his other option). `GetUnitSpeed` is dynamic and measured
(`ROUTER`), but reading it would only save polls in the region where polls are already cheap,
and it cannot predict a charge that has not started yet. **Build from need: the fixed value is
safe to the ruled ceiling, so the dynamic version buys nothing.**

⚠ **THE UNTESTED HALF, named rather than assumed:** 4.7 polls/s is cheap in ARITHMETIC — the
rule is a handful of ops per armed node. What is NOT measured is the cost of
`GetCurrentPlayerPosition()` at that rate. ★ Macro-testable in minutes, exactly as `GetUnitSpeed`
was. If it is expensive, the dial moves down and the safe ceiling moves with it.

★ **Nothing is blocked either way** — no shipped constant carries it, `rule.lua` takes no
cadence, and the throttle belongs to the sensor, which is not built.

### ★★ AND THE PROVENANCE OF `30` EXPLAINS ITSELF ONCE YOU LOOK

`landmark_design.md`'s constants table: **`MAX_CLOSING_SPEED` 30 yd/s — *"~29 is a 310% flying
mount, so this has headroom"*.** ⟶ The number was chosen for **COA_Landmarks**, in the open
world, where the fastest closer is a flying mount. The driver inherited it whole.

⚠ **A dungeon has no flying mounts, and it does have charge abilities.** So the constant is not
wrong — it is *correct for the addon it was chosen for and wrong for the one that inherited it*,
which is the SAME inheritance fault as segment (RI-33): a decision carried across a boundary
without its premise being re-checked on the other side. ★ It also confirms `ROUTER`'s existing
ruling from the other direction — *"tolerable there (a late arrival notice) and not for a driver
(a missed beacon)"* — by naming WHY the two differ: **different worst cases, not different
tolerances.**

⚠ **`landmark_design.md` IS NOT STALE AND MUST NOT BE "FIXED".** Its 30 and its 0.20 are that
product's own, correct for it. ★ It is the clearest case yet of why a retirement grep yields a
WORK LIST and not a defect list.

### ★★★ HIS REFRAME, AND IT IS THE RIGHT ONE — SLEEP IS A DISTANCE QUESTION

Battlewrath, 2026-08-20: **"Permission to sleep is distance. Not speed. (Though ability to close
distance to the point within the sample rate is the failure.) At 0.1 time into the point is
quicker than any unit moves in the game."**

★★ **Verified, and it relocates the guarantee.** At the 0.1 s floor and R = 5, skipping a beacon
needs `2R/T` = **100 yd/s — which the desk already calls not-travel.** ⟶ So **the FLOOR is the
safety guarantee, and `MAX_CLOSING_SPEED` is not a safety parameter at all.** It only decides
**when we are allowed to stop polling at the floor** — an optimisation, exactly as he says.

⚠ Re-read against this, the failure my simulation found was never a floor failure: at MCS = 30
the player was 60 yd out, slept 1.833 s and covered 104 yd. **The floor never applied, because
sleeping is what happens when you are far away.** The bug was sleeping too long, not sampling
too coarsely.

★ **AND THE HANDOFF IS EXACT, which is why `MCS ≥ v` is self-correcting rather than lucky.**
A charge from his 35 yd range, MCS = 100:

    v = 7.0 yd/s    30 samples, ends 4.59 yd    INSIDE
    v = 30.0        7 samples,  ends 3.20 yd    INSIDE
    v = 56.9        3 samples,  ends 4.88 yd    INSIDE
    v = 100.0       1 sample,   ends 5.00 yd    INSIDE - exactly on the boundary

⟶ The proportional zone always hands off AT the boundary, never past it. **So the constant is
better stated as the distance it produces: `MCS = 100` ⟺ "poll at the floor from 15 yd out."**
★ Same arithmetic, and the number a human sets becomes YARDS, which can be judged, instead of a
speed ceiling for abilities that do not exist yet, which cannot.

### ⚠⚠⚠ AND THE CONSEQUENCE HE DID NOT ASK FOR: R's MINIMUM IS NOW LOAD-BEARING

His claim holds **at R = 5.** It does not hold below it — the floor's guarantee is `2R/T`, so:

    R = 5    10 across    skippable only above 100 yd/s   = TELEPORT_VMAX, safe
    R = 2     4 across    skippable above  40 yd/s        ⚠ ORDINARY CHARGE SPEED

★★★ **And the three numbers are ONE relationship, any two fixing the third:**

        R_min  =  v_ceiling × POLL_MIN / 2  =  100 × 0.1 / 2  =  5

⟶ **R = 5 is not a convention. It is exactly what the floor implies.** Nobody derived it that
way; it arrived as a taste value and turns out to be the arithmetic one.

✅ **AND IT IS ALREADY HELD: R = 5 IS THE FLOOR IN THE PICKER DROPDOWN** (Battlewrath,
2026-08-20). ⚠ The Analyst filed it as an owed guard on the strength of `setReach`
(`routes.lua:1471`) being a bare `tonumber` — **reading the SETTER and claiming the MINIMUM was
unenforced, without checking the door the author actually uses.** Struck. ★ The same scope fault
that produced the "SetRow has zero callers" and "MigrateRIDs is test-only" corrections: a claim
about everywhere, made from one place.

⟶ **So nothing is owed here. What the derivation adds is only the WHY:** 5 was picked as a
sensible smallest radius and turns out to be exactly `v_ceiling × POLL_MIN / 2`. ★ Worth keeping
because it ties the picker's floor to the poll floor — **if either moves, the other must.**

### ✅ ON THE TELEPORT COINCIDENCE — true, and more fragile than it reads

The filing says the skip speed at a 0.1 floor is 100.0 yd/s, *"which is `TELEPORT_VMAX` exactly
… by two independent routes."* ★ Verified: `TELEPORT_VMAX = 100.0` (`walk.py:490`), and the
derivations really are independent — one is geometry (`2R/T` = 10/0.1), one is the desk's
judgement about what counts as travel.

⚠ **But it holds at R = 5 and moves with R.** At R = 6 the skip speed is 120 and they part. So
it is a pleasing property of the ruled MINIMUM radius, **not a structural meeting** — worth
noting so nobody later cites it as the reason the floor is principled.

### ✅ THE EVIDENCE-INVERSION READ IS ACCEPTED, and it corrects something of mine

The bench is right that `audit_C`'s *"0.2 s SILENT / 1 Hz DETECTED"* was measured **with segment
in the rule**, that a phantom needs a chord to sweep, and that under point-only a coarse cadence
can only under-detect. ⟶ **The direction of that comparison inverts, and the w5 two-rates and
cut-corner blocks want re-running under point-only.** Their current output is sound for the rule
they measured and misleading for the one that ships.

★★ **AND IT LANDS ON A11.2a, WHICH I WROTE AN HOUR EARLIER.** That row argued point-only was
sufficient from *"7.1 samples through the centre at run speed"* and topped its cost table at a
*"30 yd/s ceiling"*. ⚠ **Run speed is the MEDIAN and 30 is not the corpus ceiling — 56.9 is.**
At 56.9 the failure is not the 20% rim-clip the row named; it is a **whole beacon skipped**. I
graded the median and called it sufficiency. ⟶ A11.2a now states both constants as
PRECONDITIONS rather than as background, so the narrowing cannot be read as unconditional.

_Filed 2026-08-20 (§419) by the **Addons bench** at Battlewrath's ask: **"Can you land those in
the inbox so we have something the state against. And it moves to 0.1 I believe to bring the 5
yard min (10 across) into tolerance."** ⚠ Filed as the STATE, not as a question - the value is
his and the arithmetic below confirms it rather than proposing it._

### ★★★ HIS REASONING, MEASURED — and it closes on a number worth seeing

Under **point + band + gate** (A11.2a, narrowed 2026-08-20) there is no chord to catch a pass
the samples missed. So the floor's whole job is: **the player must not be able to cross a
beacon's DIAMETER between two samples.** With the ruled minimum radius of 5 (10 across) and the
fastest legitimate movement measured at **50.6 yd/s** (RI-33 §4):

    floor     travel/sample     R=5 (10 across)               speed needed to skip R=5
    0.20 s    10.12 yd          SKIPPABLE by 0.12 yd          50.0 yd/s
    0.10 s     5.06 yd          covered, 4.94 yd of margin   100.0 yd/s

⚠ **At 0.2 s the floor is already defeated** — 50.0 yd/s is what it takes, and 50.6 is what the
corpus holds. The margin is NEGATIVE by 0.6 yd/s.

★★★ **And at 0.1 s the number that defeats it is 100.0 yd/s — which is `TELEPORT_VMAX` exactly.**
The desk set that threshold as *"a real charge must survive, and only an instantaneous
relocation must not"*. ⟶ **So at a 0.1 s floor, the only thing that can skip an R=5 beacon is
something the desk already classifies as not-travel.** The floor and the teleport threshold meet,
by two independent routes.

### ⚠⚠ AND THE EVIDENCE FOR THE OLD FLOOR ARGUES FOR A TRADE-OFF THAT NO LONGER EXISTS

`audit_C_evidence_bounds.md` records **cut-corner: 0.2 s SILENT / 1 Hz DETECTED** and two-rates
**0.2 s 12/18/18/18 vs 1 Hz 13/16/16/18** — finer sampling apparently detecting LESS. ★ Read
correctly, 0.2 s is RIGHT there: the fixture is a 90° turn with the beacon INSIDE the corner, and
the desk's own line is *"the COARSER path detects MORE, because a cut corner is a PHANTOM HIT."*
1 Hz's extra detections are transits that never happened.

⚠ **But all of it was measured WITH SEGMENT IN THE RULE.** A phantom needs a chord to sweep;
`first_visits` interpolates between samples. Under point + band + gate there is no chord, so a
coarse cadence can no longer over-detect — **it can only under-detect.**

⟶ **The direction of the whole comparison inverts.** Under the old rule coarse was dangerous
because it INVENTED hits; under the new one coarse is dangerous because it MISSES them, and finer
is strictly better with no phantom cost. ★ **The evidence for the cadence was gathered against a
rule that has since been narrowed**, which is why it reads as arguing against the move.

★ If the floor lands at 0.1, `walk.py w5`'s two-rates and cut-corner blocks are worth re-running
under point-only — their current output is sound for the rule they measured and misleading for
the one that ships.

### THE STATE — every site that carries the number

    driver_sense_acceptance.md    A11.2f          ★ THE LIVE ROW - "POLL_MIN floor of 0.2 s"
    driver_analysis_asklist.md    :59-62          the formula and all four constants
                                  :298 :391       prose that reasons FROM 0.2
    audit/audit_A_prior_work.md   :29             COA_Landmarks' shipped values
    audit/audit_B_model_delta.md  :141            the shipping-constants line
    audit/audit_C_evidence_bounds.md :20 :46      the throttler constants
                                  :51 :72 :73     the two-rates and cut-corner evidence rows
    audit/s9_teleport_guard.md    :106-108        "the 0.2 s floor stands on its own footing"

⚠ **`MAX_CLOSING_SPEED = 30` TRAVELS WITH IT** in three of those, and it is the same shape of
error one level along: the corpus measured legitimate closing at **56.9 yd/s**, so a schedule
dividing by 30 under-polls whenever the player is faster than the constant admits. `ROUTER`
already rules it *"tolerable there (a late arrival notice) and not for a driver (a missed
beacon)"* — and a floor of 0.1 does not fix it, because the two multiply rather than substitute.

    IMPACT
      on disk now      NOTHING in code - no shipped constant carries the floor yet. `rule.lua`
                       is pure and takes no cadence; the throttle belongs to the sensor, which
                       is not built. ★ Which is why moving it now is free and moving it after
                       the sensor is not.
      shipped guards   none break. ⚠ And none would CATCH a wrong floor either - nothing polls
                       yet, so the number is currently prose in SEVEN files - and prose is the only
                       thing that can carry a constant nothing executes.
      criteria         A11.2f is the row that moves · the two-rates and cut-corner evidence
                       rows want re-running under point-only · A11.9d's witness cadence
                       ("1 Hz is enough, never on the fine poll") is unaffected
      does nothing to  the rule · the contract · the fixtures · the park

---

# THE SETTLED SET — ⟶ MOVED TO `ANALYST_LOG.md` (2026-08-21)

_Battlewrath: **"Then a log to extract the IS / IS NOT and reasoning / outcome."** ★ The
flattened rows — question · outcome · NOT · IS · cite — now live in `ANALYST_LOG.md`.
**A conversation and its conclusions should not share a page:** this file is what is being
decided; the log is what was._

⚠ The invariant that governed the old footer still holds and is now ACROSS the two files:
**an item is EITHER a full entry above OR a row in the log, never both.**
