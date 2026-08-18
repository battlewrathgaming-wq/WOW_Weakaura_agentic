# Dungeon Run — BENCH PROPOSITION for docket items 1–3

_Addons bench, 2026-08-17, answering the docket from Battlewrath via the Analyst. Read against
`driver_use_case_target.md §9` (sorting), `driver_scoping.md` (fifteen + §R),
`driver_programmatic_model.md §5` (the four holes, the ruled order), `driver_user_journey.md`
(the capture milestones). **Nothing here is built.** Sequence, insertion points, and three things
I want ruled before I touch the panes._

---

## 0. Three corrections to the docket's picture of the code

I read the files before proposing, and the ground differs from the account in three places. All
three change the shape of the work.

**★ G2 is a FIELD gap, not a logic gap — the fallback already ships.**
`routes.lua:862` `OnRampOf(b)` returns the beacon when no child carries the on-ramp;
`routes.lua:893` `AcceptanceOf(b)` returns the beacon when `#ChildrenOf(b) == 0`. The childless
beacon is *already* lure + acceptance in one, exactly as S2's addendum rules. What is missing is
that a beacon has nowhere to put `radius / up / down` — a child has `Routes.SetChildReach`
(`:688`) and a beacon has nothing. **So this is one storage field plus one accessor, not a
second code path.**

**⚠⚠ G1 is NOT "restore the removed field", and this is the one I will not guess at.**
`routes.lua:802` records that §91 removed the per-child note setters **on a ruling**, in his
words: *"with ids a note is likely a CONSUMER several children reference — you update one note.
On route export, the same note or a ref lookup is set into both."* `store.lua:407`
`Store.NoteTable()` already exists for that shape. Target §4 rules a note is a choice option
≤ ~200 chars but does not re-decide **owned or referenced**. Putting a string back on the child
re-breaks §91; building the table adds an object the author must manage. → **R1 below.**

**★ G10's picker already has its source, with a bound attached.**
`store.lua:364` accumulates `r.bosses` per pull, and `capture.lua:234` states the bound plainly:
*"NOT 'bosses', AND NOT ENCOUNTERS. We hold unit names that had a boss token at that moment."*
So the picker offers **names**, the author picks one, and nothing claims a set or a count. That
is target §3's "picked, never typed" satisfied by construction, and §17 not crossed.

---

## 0b. THE ARCHITECTURE LINE — and why there is no second artifact

**Battlewrath, §294:** *"'Move super tracker because X says so' holds. But right now it's hard
coded. Where it's the load route, then, start route (arm), then, instruction says: Driver reads,
acts."*

    load route      the author's form, as stored
    arm             compile it HERE, in memory
    instruction     read from that
    driver          acts

★★ **What `task_chain` is missing is X, not the mechanism.** The task holds the instruction
itself — *arrive within 5 → advance → set next* — so the driver is not reading an instruction, it
**is** one. `emit_chain_route.py` writes `{x, y, z, mapID, kind, n}` and nothing more, because the
beacons have nothing more: sense, when-true and next are exactly what item 1 puts on the panes.
**The hard-coding is a placeholder shaped like item 1's output.**

### ★★★ ONE STORED FORM — checked against WeakAuras, not assumed

Battlewrath raised it and it is checkable from our own basis (`audit/addon_weakauras.md`):

    data.load / triggers / conditions       what is STORED — a declarative table
    ConstructFunction(load_prototype, …)    compiled to a Lua source string ON `Add`
    Private.LoadFunction → checkConditions  in memory, per session, NEVER persisted

★ **So WA's "flatten" is a function applied at load, not a second artifact** — and `Modernize` is
the proof rather than an inference: it exists to upgrade *old stored auras on the way in*, which
you only ever need if what is stored is the author's versioned form. Compiled output you would
simply recompile. The transported form is the same form again (`serialize → compress → encode`).

⚠⚠ **This bears on D-3's MECHANISM, not its ruling.** D-3 ruled two languages *by construction* —
editor source, consumer flattened. WA's shape says **one stored language, compiled at arm**. The
intent survives; the second artifact does not.

### The adaptor carries the two vocabularies instead (Battlewrath, §295)

    STORED        one form, in the CODE's meaning — travels, compiles at arm
    THE PANES     render through a LOOKUP FUNCTION: code term → author word
    THE CONSUMER  reads the stored form directly; nothing to translate

★★ **A called function cannot drift the way a documented table can.** §3b asked for the `code :
user` table as documentation with a grep rule; making the panes **call** it means a string cannot
reach a pane except through the table. The grep still earns its place — it catches the stray
literal that bypassed the function — but it is now catching an exception rather than enforcing
the rule.

**RULED (Battlewrath, §295): PASS THROUGH on a miss.** A row that does not exist renders the code
term. ★ And that is the better split, not a compromise: the author never sees our bookkeeping,
and **the bench does** — the function is silent, the checker is loud, each in front of the person
who can act on it.

**⚠ Versioning: a stamp from day one, no migration code.** WA needs `Modernize` because it has
years of stored auras; **we have none** — Battlewrath: *"right now there is no version control to
be concerned with, but building looking forward is important."* So the stored form carries a
`schema_version` and nothing reads it yet. Same shape as S11's *build so we can, hygienically*.

## 1. SEQUENCE — item 1's four holes, reordered, with the reason

The docket lists them reach · note · boss · ordinal and does not rule an order within the item.
I would take them in this order, because each one's *unknowns* are smaller than the next's:

    1  G2   reach on a childless beacon    a field + one accessor; nothing else waits on a ruling
    2  —    child ordinal (`4.1:3`)         the ADDRESSING every later hole uses to say which child
    3  G10  boss child kind + name picker   the first NEW KIND; proves the kind mechanism on a
                                            source that already exists (store.lua:364)
    4  G1   the reader note                 LAST — blocked on R1, and only on R1

★ **The reason for 2 before 3 and 4:** a new child kind and a note reference both have to say
*which child*. `4.1:3` is the identity everything else addresses through (model §1), so building
a kind first means addressing it twice.

⚠ **What I would NOT do:** touch `map.lua` (2,385 lines) for any of the four. All four land on
the object pane and its store shape — `routes.lua` + `object.lua` + the `object.md` interface
file. The map draws what the store holds; it does not need to know a beacon gained a radius.

## 2. HOW EACH LANDS — insertion points, no rewrite

**G2 — reach on a childless beacon.**
Mirror the child's three numbers onto the beacon and resolve through one accessor:

    Routes.SetBeaconReach(b, radius, up, down)     beside SetChildReach (routes.lua:688)
    Routes.ReachOf(x)                              child fields if present, else beacon's

★ `ReachOf` is the only new call site anything downstream needs; `OnRampOf`/`AcceptanceOf` already
return the right object, so the walk and the flatten ask the same question of both. **Additive.
No existing signature changes.**
⚠ Height stays inherited (`routes.lua:29-31`) — the beacon's `z` comes from its read; the band is
a tolerance over it (§287), never a height.

**Child ordinal.**
A stored field on the child + a display rule. The parent's surface manages ordinals *across* the
set (model §1); each child still edits its own on its own pane. `Routes.ChildrenOf` returns an
array today, so order is positional — the ordinal makes it **explicit and sparse** (`3.1` inserts
without renumbering, which is the model's whole point).
⚠ One real risk: two children given the same ordinal. **Tell-and-trust (S4)** — the pane shows the
collision, the flatten reports it, nothing refuses.

**G10 — boss child kind.**
A `kind` on the child (today `role` carries `complete`/`set`; the four kinds of model §1b are a
different axis) + a picker fed from `Store` over the run's `r.bosses`. Two senses per the model:
*boss engaged* and *boss killed*.
⚠ The kill witness is `UNIT_DIED` by dest name — Skada's shape (`driver_neighbours.md` 8b/8c):
**register CLEU on arm, subevent lookup, unregister on disarm.** That is consumer-side, not
editor-side, so item 1 stops at *the author can pick a name and say what happens*; the listener is
Dungeon Routes' (target §9 sorting).

**G1 — the note.** Deferred to R1.

## 3. ITEM 2 — the test driver has a home and a precedent

⚠ It should not be a seventh surface. `/dr walk` already exists and already reports per-stage
runnability (`routes.lua:890` names its unrunnable-stages report), and `editor.lua` has the play
pacer the model wrote. S10 rules the MVP is *"a suite option of Dungeon Run"*.

**Proposition: the test driver is a MODE of the existing walk, not a new pane.** Two things S4 asks
for, both readouts over what the store already holds:

    walk the dataset      per node: its triggers, and whether each would fire on this run
    cycle nodes near me   in-client: step through nodes by distance and see what they do

★ **First proof, per the journey's milestones:** a stage advance on **just a boss kill**, against
what is already captured — names + engage timestamps + `UNIT_DIED` (all present). No new capture
needed for it, which is why it is the right first proof.
⚠ It needs the **per-stage pin trace (C-4)** before it can replay *"point here"* — that is the one
capture change the journey rules as **now**, and it is small: record what the driver pointed at and
when, the way `task_chain` already does (`§289`, every set/arrive/clear as an event row).

## 4. ITEM 3 — the adaptor table, and a checker that already exists

§3b wants the `code : user` table **verifiable**: every user-visible string in a pane resolves
through it; every code term reaching a pane has a row.

★★ **`addons/tools/check_interface.py` is already that checker, one check short.** It reads
`addons/planning/interface/*.md` as the authority (`:43`), regex-extracts declared controls
(`:259`) and asserts registration both directions (`:268`, currently 98 of 98). **Adding "every
user-visible string resolves through the adaptor table" is a third function in the same file,
same pattern, same exit code.** No new machinery, and it makes the naming law gradeable rather
than reviewable.

⚠ Per the docket: inventory the `code` column **as each term is touched**, correct drift there,
then free the `user` column. **I would not sweep** — a sweep is a rewrite wearing a different
name, and `driver_reconciliation.md §1#10` shows what a rename-in-bulk costs.

---

## 5. WHAT I WANT RULED FIRST — three, in order of what they block

**R1 · Is a note OWNED by a child, or REFERENCED from a note table?** *(blocks G1, nothing else)*
§91 removed the per-child setters on the referenced reading; `Store.NoteTable()` exists for it;
target §4 does not re-decide it. Owned is one field and re-breaks a ruling. Referenced is a table,
a picker, and an author-facing object — but it is what §91 actually said. **I will not pick this
one.**

**R2 · Does a childless beacon carry a band, or inherit the ±2.5 default?** *(sizes G2's pane)*
§287 rules the band a tolerance erring tight, and §286 rules its ceiling is set by where beacons
go. If it is a **default**, the beacon carries one number (`radius`) and the pane is one field. If
it is **per-beacon**, three fields and three ways to get it wrong. ★ My leaning, labelled: default,
with the band exposed only where an author has a reason — but the pane size is the author's call.

**R3 · Is the test driver a MODE of `/dr walk`, or its own suite entry?** *(sizes item 2)*
`/dr walk` exists with a per-stage report. S10 says "suite option". These may be the same thing
said twice — if so it is an extension, and item 2 gets materially smaller.

---

## 6. Bounds check on this proposition

    own-position detection            G2/ordinal/G10 are authoring; detection unchanged
    height never invented             beacon z stays inherited (routes.lua:29-31); band is
                                      tolerance over a sampled z
    no combat model                   the boss picker offers NAMES from the run; no grouping,
                                      no count, no pack (capture.lua:234 bound carried through)
    no dungeon knowledge              nothing shipped per-dungeon; the picker's source is the
                                      run's own record
    no route grading                  the test driver reports what fired, never whether it
                                      was good
    consumer computes nothing         the CLEU listener is consumer-side and out of item 1;
      resolvable at authoring         the boss NAME is resolved at authoring
    beacon only from a read           unchanged — no new spawn path proposed

## 7. Housekeeping owed, and where it sits

The audits' bench items are independent of 1–3 and I would take them first, in one pass, because
several are stale TEXT that a reader would act on: `walk.py` W1 summary "eight" → ten · the
`w32` MEASURED/UNMEASURED contradiction · W5 emitting first-proximity time and timeline rows to a
file (W7.1's golden does not exist yet) · posture §3 and the `rfc_combat` result marked withdrawn
in place · the "12 landed runs mapID-constant" claim corrected and `20260812_113949_493__satnav`
added as a **W1.3 real-data fixture** — ⚠ that last one is the better finding of the two: the
straddle branch was reachable all along and my "synthetic by necessity" was wrong.

**`COA_DevDump/route_chain.lua` — RULED (Battlewrath, §292/§293), and my guard was aimed at the
wrong thing twice before it landed.**

I flagged it as looking like the per-dungeon content §17 refuses (`driver_reconciliation.md §2 /
C3 §5.3`) and offered gitignore-or-name. **§292: keep it, with its why-not.** So I annotated it as
a *fixture* and drew the line at the file — probe input here, shipped content there.

⚠⚠ **§293 moved the line where it belongs:** *"it is the UPSTREAM being invalidated for that code.
IE. loading the route. Inherently they are the same. Take information. Use it perform function."*

★★★ **Loading a route is loading a route.** The consumer takes information and performs a
function; it cannot see what produced the file and does not need to. **So `route_chain.lua` is not
a fixture resembling a route — it IS one**, and there is no second species to defend it against.

    VALID     every position came from a READ. This file: generated from a landed
              capture, carrying its sha.
    INVALID   positions invented, typed, or shipped as knowledge nobody observed —
              which is what §17 refuses, and what pfQuest/GatherMate2's node lists are.
              Not because of where they live. Because nobody read them.

⚠ **So the failure condition is not "it moves out of a probe addon". It is a position in it that
did not come from a read** — the seed-once law, which is the only thing that has ever separated us
from the shipped-data neighbours. Location is incidental; provenance is the whole of it.

★ **Consequence for §3 above:** I under-labelled `task_chain` as *"not the driver"*. If loading and
driving are the same operation, it is **a consumer with a fixed rule and no ratchet** — partial,
not a different kind of thing. That makes item 2's test driver less of a new build than the
proposition assumed, and strengthens R3.

---

## 8. SMOKE PLAN — what proves each hole landed

★ **The harness already exists.** `smoke_dungeonrunpromoter.lua:31-36` loads
`store → routes → object → map` under stubs and its own comment says *"everything above tests
routes.lua"*. So nothing new is stood up — but that smoke is about §61's MINT, and item 1 is a
different subject, so I would split **`smoke_dungeonrunroutes.lua`** off the same load chain and
keep each smoke about one thing.

⚠ **Every assertion below must be shown to BITE** — break the guard, watch that check fail, on
its own message. The recorded yield of this discipline here has been bad *tests*, not bad code
(a vacuous `.v == nil`, a verdict and a pass/fail read from opposite conditions), so a smoke that
has not been mutated is not evidence.

    G2 reach       SetBeaconReach stores; ReachOf resolves CHILD first, else BEACON;
                   a childless beacon is RUNNABLE (AcceptanceOf returns it AND it now
                   has a reach to return)
      mutation     delete the beacon branch of ReachOf → the childless case must fail,
                   and nothing else may

    ordinal        insert 3.1 → nothing renumbers (sparse and stable);
                   `4.1:3` resolves to exactly one child, `4.1:3.1` to another;
                   TWO children on one ordinal is TOLD, never refused (S4)
      mutation     make insertion renumber → the stability assert must fail

    G10 boss       a boss child carries a NAME drawn from the run's r.bosses and nothing
                   else; ⚠ the FLATTEN REFUSES a boss child with no name
      why          neighbours §8: WA refuses unfiltered CLEU at authoring — "the format
                   cannot express the firehose". Ours is the same guard one layer up:
                   a nameless boss child would compile to an unfiltered listener
      mutation     emit a nameless boss child → the flatten must refuse, not warn

    G1 note        deferred on R1 — but the assertion is the same either way:
                   a note resolves to EXACTLY ONE string for a child. Owned or
                   referenced changes the lookup, not the test.

    adaptor        the lookup PASSES THROUGH on a miss (renders the code term);
                   every value in ROLES / SHAPES / ACTIONS resolves or passes through
      mutation     remove a row → the pane still renders, and the CHECKER reports it.
                   That split is the point: silent for the author, loud at the bench.

★ **All of it is offline.** These are store-shape and resolver changes; no client, no trip. The
one thing that needs the client is item 2's first proof, and it needs no new capture.

## 9. INVENTORY PLAN — it FOLLOWS the code, and the emit is a drift check

⚠⚠ **CORRECTED (Battlewrath, §297) before it was built.** I proposed emitting the `code` column
now, from current source, as a complete term list. His: *"the inventory plan is just a plan
otherwise it's circular. The code needs coding and divergence as functions are needed is
inspected. What lands and is confirmed gets a real inventory. Or filtered under existing
inventory items."*

★★★ **Circular is exactly right.** The four holes ADD terms. An inventory emitted from today's
source is stale before anything uses it — and worse, it would be a plan the code is then written
*to*, which inverts which one is the ground.

    THE CODE IS THE GROUND
      write the function       →  inspect divergence AT THAT POINT: is this a new term,
                                  or does it belong under one already on file?
      it lands and is confirmed →  THEN it gets a row, or is filed under an existing one
      the machine              →  checks that nothing landed WITHOUT a row

★ **So `emit_adaptor_table.py` is a drift check on the confirmed state, not a term planner.** Its
question is *"did anything reach a pane that has no row?"* — asked after, of what exists. That is
`check_interface.py`'s third check with a source to compare against, and it can only be written
once there is something confirmed to compare.

⚠⚠ **And this is the SECOND time in two days I proposed a machine that decides ahead of the work
when its role is to check behind it.** A-5 was the same shape: I described the variance rule as a
per-run *placement decider* and the analysis lane corrected it to a *verifier*. Same correction,
same direction, one day apart — the tell is a machine whose output is consumed by the decision
that produces its input.

★ What survives unchanged: **discovery is mechanical, naming is taste** (§3b), and
`emit_notes.py` / `emit_helpers.py` remain the precedent — emit the inventory, leave the
judgement. Only the *timing* was wrong, and timing was the whole of it.

---

## 10. STATUS, AND WHAT HAPPENS ON A GREEN

**Reviewable now. Testable in part, and the gap is structural rather than an omission.**

    item 2   drives, so W1–W7 apply directly. Its first proof — a stage advance on JUST a
             boss kill against what is already captured — needs no new capture.
    item 1   Dungeon Run. ⚠ Target §171: "the editor's own criteria (not yet written) gate
             Dungeon Run." There is no acceptance surface. §8 above makes it gradeable AT
             THE BENCH; it does not make it accepted.
    item 3   §3b's naming law is the only gate, and it is reviewable rather than runnable
             until the emitted table and the third check exist.

⚠ **So a review here means "the Analyst agrees with the approach", which is worth having and is
not a pass.** Said plainly so a green on this file is not later read as a green on the work.

**On a green, in this order — and the first two need no ruling:**

    1  the housekeeping pass (§7) — it is stale TEXT a reader would act on, and the
       straddle fixture correction is the better of the two findings in it
    2  smoke_dungeonrunroutes.lua stood up EMPTY against the existing load chain, so
       every hole after it lands with its assertion already having somewhere to go
    3  G2 → the child ordinal → G10        (G1 waits on R1)
    4  the adaptor's rows filed AS EACH TERM LANDS (§9) - new row, or filed under one
       already on file. emit_adaptor_table.py + the third check come AFTER, as the
       drift check on what was confirmed
    5  item 2, once R3 says whether it is a mode of /dr walk or its own entry

★ **2 before 3 is deliberate.** A smoke written after the code it tests is written to the code;
a smoke written first is written to the criterion. The difference has shown up twice in this arc
already.

---

## 11. What steps 1 and 2 found on the way through (2026-08-18, §298–299)

Both are recorded here because both are the sequence working, not the sequence failing.

**§298 — posture §12 was killed by its own stated kill-condition.** The straddle branch was never
unreachable: `20260812_113949_493__satnav` carries mapIDs `{1: 29, 389: 57}`. W1.3 has a real-data
fixture now. ★ The tell: I counted 12 RUNS and never asked whether any ROW differed from its
neighbour — a per-run summary cannot answer a per-row question, and it returned an answer anyway.

**W5.6 landed with it** — the golden the port is graded against, **written once then COMPARED**, on
walk.py's own law that the goldens came first. `--regold` is the only way to move one. Mutating the
segment clamp `1.0 → 1.2` moves all three fixtures and each names its row.

### ⚠⚠ 11a. `kind` IS ALREADY TAKEN — A3.1 needs a different word

**The empty smoke found it before a line of the feature existed, which is the argument for step 2
made without me having to make it.** A3.1 proposes *"a child `kind` (a new axis beside `role`) with
`boss`"*. `kind` is the **structural discriminator** and has three values already:

    beacon    routes.lua:224      set at AddBeacon
    child     routes.lua:429      set at mint
    note      routes.lua:1129     set at AddNote

★ And it is not a spare field being squatted on — `SetName` (`:314`) and `NameOf` (`:320`) **branch
on it** to decide whether they are writing `text` or `name`. A boss child carrying `kind = "boss"`
would fall off the child-naming path onto the beacon one, silently. The mutation is in the smoke:
setting `place.kind = "boss"` at the mint goes red on its own message.

⚠ **Reported, not renamed — A3 is the Analyst's row and the term is theirs.** What the bench can
supply is the constraint: the new axis needs a word that is not `kind`, `role`, `shape`, `action`,
`icon`, `outcome` or `stage`. The smoke asserts whichever word lands; it asserts the collision
today so it cannot be re-discovered later as a bug.

★ Note the shape of this: the criterion was written before the code, and reading it against the
code is what surfaced the collision. Had the smoke been written after G10, `kind = "boss"` would
have been the thing under test, and the test would have agreed with it.

## 12. What I am blocked on, and what I am proceeding on

★ Split deliberately, because they are different asks. A **BLOCKER** means guessing would put a
wrong word or a wrong shape into many files and the cost of undoing it is the reason to wait. A
**PROCEEDING-ON** means I have taken a position, it is visible in one place, and correcting it
later is a small edit — I am naming it so it is a decision you saw rather than one you inherit.

### 12a. Blockers — I would rather wait than guess

    B1  A3's axis WORD                    G10        the term lands in the field, the picker,
                                                     the adaptor row and every later smoke.
                                                     `kind` is taken (§11a), `detect` is the
                                                     pane's zone label (§13c). Down to `sense`
                                                     or `detector`; I recommend `sense`.
                                                     ★ And §13c found it is NOT a new axis -
                                                     model §3 already calls it `sense` and has
                                                     `reach here` on it, so G10 is smaller than
                                                     A3.1 describes and joins onto G2.
    B2  R1 — note OWNED or REFERENCED     G1         two different data shapes, not two names
    B3  R3 — the test driver's HOME       item 2     a mode of `/dr walk`, or its own entry

⚠ B1 is the one that costs most if guessed, and least if answered: it is one word, and §13 below
exists so that answering it is a *choice between two or three candidates the code already
endorses* rather than an open naming exercise.

### 12b. Proceeding on — stated, correct me and it is a small edit

    P1  R2 unruled, so ReachOf returns   nil for an unset band, never 2.5. A default returned
                                          from a read is indistinguishable from a number an
                                          author typed. When R2 rules, it is one `or`, one line.
    P2  `SetBeaconReach` keeps its name   even though the house convention is bare-means-beacon
                                          (`SetStage`, `SetOutcome`) — see §13 R4. `SetReach` /
                                          `SetChildReach` would hide the asymmetry in a way the
                                          §85 band cannot afford.
    P3  A2's ordinal SITS BESIDE list     order, it does not replace it. `ChildrenOf` sorts by
                                          ordinal; the table order stays the insertion record.
    P4  the beacon half of `4.1` is DONE  `SetStage` already `tonumber`s, so 4.1 stores today.
                                          A2 is the CHILD half only.
    P5  A1.2's report is asserted as the  RULE, not the sentence — this repo's own precedent on
                                          these two rules (§300). The pane string is the pane's.
    P6  the 12 rotted mutation anchors    are NOT mine this arc. Flagged, not silently carried.

## 13. Naming rules for the CODE side — READ OFF routes.lua, not invented

★★★ **Why this is absent rather than forgotten.** §3b is the naming law and it governs the
**user** column: *"the code may keep its own words underneath."* That is the right split — but it
means the code side has had **no rule at all**, and §11a is what that costs: I found `kind` was
taken by running into it, not by checking against anything.

⚠⚠ **These are DESCRIPTIONS, and each one carries its own count.** They were read off the file,
not proposed. A rule supported by ten instances is a house style; a rule supported by one is an
observation that happens to be true once, and it is marked as one so nobody builds on it as law.
**Where a rule and the file disagree, the file is right and the rule is wrong.**

### 13a. The field vocabulary as it actually stands

Every field a point carries, grouped by the QUESTION it answers. This is the whole surface:

    WHERE      x · y · z · mapX · mapY · mapC · mapZ · mapID · floor      (PLACE, inherited)
               atX · atY · atWorldX · atWorldY                           (§68's placement pair)
    WHAT IS IT kind · id · children · stage                              (structure)
    CALLED     name · text · icon                                        (presentation)
    WHEN FIRE  radius · bandUp · bandDown · shape · fireOn                (detection)
    WHAT THEN  role · action · goTo · setStage · ifUnseen · outcome · onRamp   (response)

★ **One axis the MODEL has and the CODE does not: `sense`** (§13c correction 3). Today a
child's sense is IMPLIED - it has a radius, so it means *reach here*. Nothing stores the
choice because there has only ever been one. B1 is the word for making it explicit, and the
first thing it would store is the value G2 just shipped.

### 13b. The rules, with their basis

**R1 · ONE WORD ANSWERS ONE QUESTION.** No field above appears in two groups. `kind` answers
*what sort of object* and nothing else; `role` answers *what it does* and nothing else.
_Basis: all 32 fields in 13a, none appearing twice. This is the rule §11a broke._

**R2 · A NEW AXIS NAMES ITS QUESTION FIRST, ITS VALUE SECOND.** The word is chosen to fit the
column it lands in — a boss child is not a new *sort of object*, it is a new *thing to detect*,
so its word belongs in WHEN-FIRE beside `fireOn` and `shape`, not in WHAT-IS-IT beside `kind`.
_Basis: the grouping above holds for every existing field; ⚠ but no field has yet been ADDED
under it, so this is the first use rather than a tested rule. ★ §13c then found the boss work
is not adding an axis at all - it is adding VALUES to one the model already has, which is the
answer this rule should have produced had I applied it before writing it._

**R3 · VALUES ARE A CLOSED, DECLARED LIST OR THEY ARE NOT A VOCABULARY.** `ROLES`, `SHAPES`,
`ACTIONS` are published tables; `SetChildShape` refuses a value not in `SHAPES`. A new axis gets
its table beside them or it is a free-text field pretending to be a vocabulary.
_Basis: 3 of 3 existing vocabularies. Strong._

**R4 · NAME THE SUBJECT ONCE THERE ARE TWO.** `SetStage`/`SetOutcome` are bare and mean *the
beacon*; `SetChildRole`/`SetChildIcon` name theirs. That worked while each field had exactly one
subject. **Reach is the first field with two, and a bare `SetReach` would inherit "beacon" by a
convention the reader cannot see.** So both subjects get named. _Basis: 14 setters follow the
positional rule; ⚠ this rule is its correction, written at the first case that breaks it (P2)._

**R5 · A READER THAT TAKES A FIELD OFF A POINT IS `<Noun>Of`.** `PositionOf` `WorldOf` `NameOf`
`ChildrenOf` `ParentOf` `IconOf` `ReachOf` `OnRampOf` `AcceptanceOf` `OutcomeOf`.
_Basis: 10 of 11. ⚠ `ChildIfUnseen` is the eleventh and breaks the shape — a wart, not a
counter-example to copy. Counters (`Count` `ChildCount` `NoteCount`) and route-wide derivations
(`StageOrder` `Gaps` `Heads`) are a different class and this rule says nothing about them._

**R6 · WHEN A FIELD HAS A RAW AND A RESOLVED READING, SPLIT THE PAIR.** `OutcomeOf(b)` returns
the stored field or nil; `Outcome(b)` returns stored-else-`stage+1`. A caller that wants to know
*was this authored* and a caller that wants *what happens* are different callers.
_Basis: ONE instance. Recorded because it is load-bearing where it exists — not offered as law._

**R7 · WHERE THE SOURCE HAS A WORD, THE SOURCE WINS.** A3's picker is fed from `r.bosses`
(`store.lua:364`); the field is `bosses` because the capture calls it that. No creator dialect.
_Basis: the standing project rule, and `mapID`/`floor`/`bosses` all carry the source's word._

### 13c. What R1–R7 narrow B1 to — CORRECTED 2026-08-18 (§302)

⚠⚠ **The first cut of this section was wrong twice and under-read the model once. Battlewrath
asked one word — *"Detector?"* — and checking it against the file is what found all three.**

**★ CORRECTION 1 — `detect` is OUT, and it fails on the rule I wrote for `kind`.**
`object.lua:690` — `kidLabel:SetText("detect")`. **`detect` is already the pane's ZONE LABEL** for
the whole detection block. I leaned toward it as *"the only one the model, the pane and the code
already agree on"* — they agree on it because it is the GROUP'S name. Putting a field under it
called `detect` is a group and a member sharing one word, which is R1, which is exactly what
`kind` did. ⚠ **I found this by being asked, not by checking, one section after writing the rule
that forbids it.**

**★ CORRECTION 2 — my objection to `sense` was spurious.** I wrote that A3.2 uses "sense" for the
two VALUES, so *"the axis and its values would share a word"*. **That is the house pattern, not a
fault:** `role` → `ROLES`, `shape` → `SHAPES`, `action` → `ACTIONS`. An axis is named for what its
values are. The objection describes three of three existing vocabularies.

**★★★ CORRECTION 3, the one that matters most — IT IS NOT A NEW AXIS.**
Model §3 gives the defaults, and `sense:` appears on **every row**, not the boss row:

    childless beacon   sense: reach here          · when true: point here · next: advance
    boss child         sense: boss engaged/killed · when true: say the note · next: advance

So the axis exists in the model, it is called `sense`, and **`reach here` is already a value on
it.** A3.1's *"a new axis beside `role`"* under-reads that: the boss work adds two VALUES to an
axis the model already has, and G2's childless beacon is the first value on the same axis. That
changes what G10 is — smaller, and joined to work already done.

### The two that survive

    sense       the MODEL'S OWN WORD for this exact axis, with a value already on it (§3).
                Noun. Values are senses, which is how ROLES/SHAPES/ACTIONS all read.
                ⚠ More abstract than `detector` for someone meeting it cold.

    detector    BATTLEWRATH'S OWN WORD, twice in the file: routes.lua:748 *"The first
                detector would point action: super tracker at the pos of the goto target"*
                and :783 *"every redirect here is detector-driven"*. Noun. Does not
                collide with the `detect` zone label — a group and a member with
                different words is the ordinary relationship.
                ⚠ In both of those quotes it names the CHILD THAT DETECTS, not what is
                detected. `child.detector = "bossKilled"` reads "this child's detector is
                boss-killed", which parallels `child.role = "complete"` and is fine — but
                the analysis lane uses `detector` for the RADIUS VOLUME throughout
                (*"a 5 yd detector"*, *"the chord through the detector"*), so the word
                already carries two meanings across the two lanes.

★ **My recommendation is `sense`, and it is a recommendation rather than a lean this time.**
R7 says the source's word wins, and the source for THIS AXIS is model §3, which names it and has
already put `reach here` on it. Choosing `detector` renames an axis that exists rather than naming
a new one — and it spends a word that is already doing two other jobs.

⚠ **The counter-argument is real and it is §3b's:** *"every verb in a drop-down must be
SELF-DESCRIBING"* — and "sense" is the more abstract of the two for an author meeting it cold.
**But §3b governs the PANE word and the adaptor decouples the two (§0b).** The pane can read
`detector`, or `what satisfies this`, or anything that lands; the field underneath stays `sense`.
That is precisely what the adaptor was built to make cheap. **B1 is a CODE-side question only.**

### 13d. When these become a checker, and why NOT yet

⚠ **A documented rule drifts; a called one cannot.** That is this proposition's own argument for
making the adaptor a lookup FUNCTION rather than a table in a file (§0b), and it applies to R1–R7
with equal force. Three of them are mechanically checkable against `routes.lua` as it stands:

    R1   every field name appears under exactly one question-group   parse the assignments,
                                                                     assert the grouping is a
                                                                     partition, not a cover
    R3   every axis with more than one legal value has a published   `Routes.<AXIS>` table
         table, and its setter refuses a value not in it
    R5   every reader that takes a field off a point is `<Noun>Of`   with `ChildIfUnseen` as a
                                                                     NAMED, single exemption

★ **And they are deliberately not built here.** Same law as the inventory plan (§9, Battlewrath):
*"the code needs coding and divergence as functions are needed is inspected. What lands and is
confirmed gets a real inventory."* A naming checker written before the term it would govern is a
machine whose output feeds the decision that produces its input — the exact shape corrected twice
in this arc already. **The trigger is B1 being answered:** the new axis lands, and the checker
lands with it as the drift check on a vocabulary that now has something to drift from.

⚠ R2, R4, R6 and R7 are NOT checkable and should not be forced into a checker to look complete.
R2 and R4 are judgements about which column a word belongs in; R6 describes one instance; R7 needs
a source to compare against. A checker that graded them would be grading its own guess.

---

_Asked back: **R1** (note owned or referenced) · **R2** (band per-beacon or the ±2.5 default) ·
**R3** (test driver as a mode of `/dr walk`) — and, added 2026-08-18, **B1** (§12a): the word for
A3's boss axis, because `kind` is taken. §13 narrows it to a shortlist rather than leaving it
open. Everything else in items 1–3 I can sequence and land without a further ruling.

The Analyst tests item 2 against W1–W7 and the naming pass against §3b; items 1 and 3 have no acceptance surface until Dungeon Run's criteria exist._
