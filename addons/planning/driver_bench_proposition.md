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

    B1  ★ RULED `sense`, 2026-08-18     G10        the model's own word (§3), and NOT a new
                                                     axis: `reach here` was already a value
                                                     on it, and §5 says outright *"the default
                                                     sense has no field"*. So G10 is smaller
                                                     than A3.1 describes and joins onto G2.
                                                     UNBLOCKED - §13c.
    B2  R1 — note OWNED or REFERENCED     G1         two different data shapes, not two names
    B3  R3 — the test driver's HOME       item 2     a mode of `/dr walk`, or its own entry

★ **B1 is answered and the answer was in the source the whole time.** I built §13's rules to
narrow it, then narrowed it to the wrong candidate twice; Battlewrath answered it by quoting
the model's defaults table back. **The rules are still worth having - but they rank candidates,
and reading the document that names the thing beats ranking.** §13c keeps the four wrong turns
because they were all the same wrong turn.

⚠ **B2 and B3 remain open, and both are ordinary waits** - a data shape and a placement.
Neither has a source sentence I have failed to read; I checked.

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
is not adding an axis at all - it is adding VALUES to `sense`, which model §5 had already
recorded as fieldless. ⚠ This rule did not produce that; READING THE MODEL did._

**R3 · A VOCABULARY IS DECLARED IN ONE PLACE AND THE SETTER CHECKS AGAINST IT.** `ROLES`,
`SHAPES`, `ACTIONS` are published tables, and `SetChildRole` / `SetChildShape` / `SetChildAction`
each return the OLD value rather than store an unknown one. A new axis is declared beside them or
it is a free-text field pretending to be a vocabulary.
_Basis: 3 of 3. ⚠ `SetChildFireOn` checks an INLINE list and publishes no table — the one that
broke the pattern._

⚠ **CORRECTED §305 — I wrote "a CLOSED, declared list". "Closed" is my word and it is wrong.**
Battlewrath: **"The right side isn't a limit. Just options."** and **"The options are programmatic
options. Sense is the first stage of that."**

    sense  →  when true  →  next          sense is STAGE ONE of the author's selection

★ The right-hand side of model §2's box is **what the program can offer**, and it grows as the
program can offer more. The table is declared and checked so a typo cannot reach the store; the
list is open. Declared ≠ closed, and I had collapsed the two.

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

### 13c. B1 — RULED `sense` (Battlewrath, 2026-08-18). Read from the source, not from my rules

**The ruling is the model's own line, and it needed no argument from me:**

    childless beacon   sense: reach here          · when true: point here · next: advance
    boss child         sense: boss engaged/killed · when true: say the note · next: advance
    — driver_programmatic_model.md §3

★ **That is the axis, with two of its values already written down.** `reach here` and
`boss engaged/killed` sit in the same column, on the same word, for the same question. The boss
work adds values to it; it does not introduce it.

⚠⚠ **And §5 states the gap outright, in the model's own words:**
*"G2 reach on a childless beacon (**the default sense has no field**)."* The model already knew
the axis was unstored — there has only ever been one sense, so nothing had to record which. **B1
is giving a field to a thing the model named and the code never carried.**

### What the source says `sense` MEANS — §2's box, read rather than summarised

    SELECT A SENSE
      POSITION   geometry: radius | wire      firing: once | while      · scene entered
      STATE      in combat · falling / landed · alive / dead · mounted
      EVENT      boss engaged (name from the run) · boss killed (name from the run)

★★ **`sense` is STAGE ONE of `sense → when true → next`** (Battlewrath, §305), and what the box
lists on the right is **what the program can offer** — options, not a limit, growing as the
program can offer more.

★ **POSITION is not one of the picks.** It is INTRINSIC to the node — §1b makes it the listening
filter, and you change it by dragging. Its configuration is `radius | wire`, which is `shape`,
already in the code; `once | while` has no term at all (G15).

⚠ **So the thing to keep straight is what is BESIDE `sense` and what is UNDER it.** `shape` and
the firing kind configure a position sense; they do not compete with it. `sense` says *which
sense*; they say *how that one behaves*. That is R1 holding, not R1 in trouble.

★ **G15 stays a separate gap and is NOT part of B1.** `once | while` is unnamed in the code and
was already logged as its own hole. Naming `sense` does not name it, and folding it in here would
be the one-step-past-the-evidence move.

### What I got wrong on the way, kept because the shape of it repeats

    first cut    recommended `detect`      it is the pane's ZONE LABEL (object.lua:690) - the
                                           same group-and-member collision as `kind`, written
                                           one section after the rule that forbids it
    correction 2 objected to `sense`       axis-and-values sharing a word IS the house pattern
                                           (role→ROLES, shape→SHAPES, action→ACTIONS)
    correction 3 "it is not a new axis"    ★ TRUE, and I reached it from a table prefix rather
                                           than from §5's plain sentence. Right answer, wrong
                                           basis - which is the failure whether or not it lands
    then         nearly withdrew it        having read §2's box I was about to call `sense` a
                                           CONTAINER and reopen a question the source had shut.
                                           Battlewrath: *"This answers it though. Sense."*

⚠⚠ **The tell across all four is one thing: I kept reasoning ABOUT the word instead of reading
what the document says it means.** §13 exists so naming is decided from the file. It works — and
it does not work if the reasoning runs on ahead of the reading, which is the failure mode the
rules were written to stop and which produced three of these four in one sitting.

### On `detector`, since it was the better question

Not spent, and worth keeping free. In both of Battlewrath's uses it names **the child that
detects** — *"the first detector would point action…"* (`routes.lua:748`), *"every redirect here
is detector-driven"* (`:783`) — which is a name for the OBJECT, not for the axis. The analysis
lane uses it for the radius volume besides. It stays available for the tab/child concept if that
ever needs a word, and `sense` does not have to fight it for one.

★ And §3b still governs the pane independently: the author may meet *"detector"*, *"what
satisfies this"*, or anything that reads. The adaptor is what makes that free (§0b).

### 13e. ⚠ REPORT WITHDRAWN, and what the context gave instead (§304)

**I reported §2's box as drift — headed *"two kinds"*, listing three. Battlewrath: *"I don't
think it's this. Position is intrinsic to the node. Not a property in the attributes. You change
it by dragging it."* He is right, and §1b is where it is written down:**

    Beacon · childless · ORDINAL       ← position + the general stage (ratchet / maxSeen)
    Beacon · childless · NON-ORDINAL   ← position + general stage
    Child  · NON-ORDINAL               ← position + its beacon being current
    Child  · ORDINAL                   ← the child ordinal: previous satisfied → this one listens

    "The store's filter set is therefore small: (position, stage) for the first three kinds;
     (position, stage, child-ordinal) for the fourth. Nothing else is needed to know who is awake."

★★ **`position` there is the LISTENING FILTER, not something an author picks.** Every node has
one; you move it by dragging. So it is not a third selectable kind sitting beside STATE and
EVENT, and the box's *"two kinds"* is not obviously the miscount I called it. **I read a box in
isolation and reported a discrepancy that the section before it explains.**

⚠ The `(position AND state)` line under the box is still the sentence I was reading, and I cannot
settle from the text alone whether *"two kinds"* means *position+state* (written before EVENT) or
*the two you SELECT*. **What I can settle is that my report named the wrong thing as the fault**,
and the design point above is worth more than the discrepancy was.

### ★★★ And it changes how `sense` is stored — for the better

If position is intrinsic, then **`sense: reach here` is not the author selecting a position
kind. It is what a node does with NO sense chosen.** Which is exactly why §5 can say *"the
default sense has no field"* — there is nothing to store for the default, because the default is
the node being a node.

**So `sense` takes the shape `outcome` already has** (`object.lua`, §79): *"the default stores
NOTHING — `outcome` stays nil — so a route full of ordinary beacons carries no field at all and
nothing has to be migrated."*

    sense UNSET     reach here — the intrinsic position sense, configured by radius/band/shape
    sense SET       a departure from it: a state, or an event (boss engaged / boss killed)

★ **And R6 applies, which is the second instance of a rule I had recorded as having only one:**

    Routes.SenseOf(x)    the STORED field, nil when the author chose nothing
    Routes.Sense(x)      the RESOLVED sense: stored, else `reach here`

Same split as `OutcomeOf` / `Outcome`, for the same reason — *was this authored* and *what does
this do* are different questions from different callers. ⚠ R6's basis in 13b should read TWO
instances once G10 lands, not one.

★ **What this buys G10:** no migration, no default written into any existing beacon, and the
childless beacon G2 shipped needs no `sense` value at all — it already IS the default. G10 adds
the SET case only.

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

## 14. REVIEWED AGAINST THE FIRST SPEC (orientation, §306)

**The route there, taken rather than assumed.** `dungeonrun_poc.md` is the first spec by date
(2026-08-13, 7,432 lines) and its own first instruction is a redirect: *"DO NOT READ THIS TOP TO
BOTTOM… ★★★ Start with the model. `dungeonrun_model.md` is the heading — the mission, capture as
the only spawn, the two lanes, the beacon as a theatre, the ratchet, and what is deliberately
absent. It is short, and it is what anyone actually needs."*

⚠ **And it is a DIFFERENT document from the one I have been building against.**
`driver_programmatic_model.md` is the DRIVER's model, a day younger. The heading is the addon's.
Everything below comes from reading the heading, which I had not done in this arc.

### 14a. What it CONFIRMS — and G2 is better founded than I argued for it

**★★★ G2 is the mechanism for the model's own pacing, not the convenience field I proposed.**
My §0 called it *"a FIELD gap, not a logic gap"*. The flight-list section says what it is for:

> *"AND THE FLATTEN DENORMALISES. One child with two thresholds (supertrack within 150, complete
> within 50) becomes TWO steps sharing an anchor, each carrying its own radius… Which is where
> '1 for come find me, 2 for you found me' finally lives: **not two radii on one node, but two
> steps on one position.**"*

★ **A beacon with its own reach and a child with its own reach at the same position IS two steps
on one position.** Before G2 the beacon could not hold the second radius, so nested-radius pacing
had no home. ⚠ And the same passage rules out what I might otherwise have reached for next: **not
two radii on one node** — so `ReachOf` returning ONE triple per point is right, and a multi-reach
field would be the wrong shape.

**★★ `sense` lands exactly in the step form.** The model gives the step four parts —
*anchor · comparison · predicate · effect* — and `sense` is the predicate slot. And the bare case
is stated outright: *"a bare beacon means **come here**, which is the whole of what it means."*
That is `sense` unset, from a third document, arrived at independently.

### 14b. ★ THE TEST THE MODEL HANDS US, run over this proposition

> *"It also gives a cheap test for any future authoring feature: **can it flatten to a step?**
> If a control cannot become a line in that list, it is not authorable."*

    G2 beacon reach   anchor = the beacon's position, comparison = within radius        ✔ a step
    sense             the PREDICATE slot of the same step                               ✔ a step
    the note          effect = *say this*                                               ✔ a step
    child ordinal     ✘ NOT a step — and correctly so. It is an ADDRESS, and the
                      flatten resolves references away entirely (*"the driver never
                      learns references exist"*). It flattens AWAY, which is the
                      right answer for an identity rather than a failure of the test.

### 14c. ⚠ The sheet row I was about to report as a tension — RESOLVED (Battlewrath, §306)

The model's address sheet reads:

    What is my stage?        beacon `b.stage`  ✔        child  not asked  —

and the section above it is headed **"A CHILD HAS NO STAGE, BECAUSE IT HAS A PARENT"**, refusing a
child stage because it *"would be a COPY of its parent's"*. I had this queued as a challenge to A2.

**It is not one.** Battlewrath: **"BID:CID and an in-group staging as an offer when needed."**

    what the model REFUSES     a child carrying a copy of the parent's route stage
    what C10 SETTLED           `BID:CID` - separate identities joined by a colon (`4.1:3`)
    in-group staging           an OFFER, taken when the author wants a chain; not a default

★ **Two different questions, and only one of them was ever refused.** *What stage am I on* is the
parent's, one hop away. *Which one am I within this beacon* is the child's own, and nothing about
it is derived from the parent. **A2 is unblocked and its shape is settled**: an ordinal, sparse,
optional, never a stage.

⚠ The sheet row is the older statement (2026-08-16) and C10 is 2026-08-17. Reported so a reader
arriving at the sheet does not take *"not asked"* as current.

### 14d. ★★ Two things the model NAMES that the code does not have

**`Routes.StageOf(node)` — asked for by name, absent everywhere.**

> *"Take the flat check as a FUNCTION, not a field: `Routes.StageOf(node)` — its own stage if a
> beacon, its parent's if a child. One predicate, computed, never stale."*

Not in `routes.lua`'s sixty functions, not in the driver docs, not in any smoke. ★ It is already
in the house shape — `<Noun>Of` (R5) and a resolved reading (R6) — and it is what every consumer
of *which stage is this* should be calling instead of reaching for `.stage` and branching.

**The child ICON has a setter and no door.** The sheet's *"`icon` ✘ NOTHING WRITES IT"* is still
true: `Routes.SetChildIcon` and `Routes.IconOf` exist in `routes.lua`, and **nothing in
`object.lua` or `promoter.lua` calls either.** ⚠ A setter with no caller is the shape that invites
building on it — it reads as a finished feature to whoever finds it next.

⚠ **Neither is in scope for items 1–3 and I am not folding them in.** Recorded as found, with
`StageOf` the one worth taking first because the ordinal work is about to touch exactly the
question it answers.

---

_Asked back: **R1** (note owned or referenced) · **R2** (band per-beacon or the ±2.5 default) ·
**R3** (test driver as a mode of `/dr walk`). **B1 is CLOSED** — ruled `sense` on 2026-08-18
from the model's own defaults table (§13c). Everything else in items 1–3 I can sequence and
land without a further ruling.

⚠ **A report I made here is WITHDRAWN (§13e).** I flagged §2's sense box as headed "two kinds"
while listing three. Battlewrath: position is INTRINSIC to the node - you change it by dragging
- and §1b says so plainly, as the listening filter. I read one box without the section that
explains it. **Nothing for the Analyst; the finding was mine to correct.**

The Analyst tests item 2 against W1–W7 and the naming pass against §3b; items 1 and 3 have no acceptance surface until Dungeon Run's criteria exist._
