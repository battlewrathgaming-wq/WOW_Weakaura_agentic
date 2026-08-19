# DOC COMPREHENSION TEST — can the documents answer, without the chat?

_Battlewrath, 2026-08-19: **"There is a saying. If you can't describe it to a 5 year old, you don't
know it. This isn't a infer from chat task. Just a read of our docs to respond from."**_

**★ THIS TESTS THE DOCUMENTS, NOT THE AGENT.** Each question is answered by opening the relevant
file fresh, under a word limit. ⚠ Where the documents cannot answer, the answer is *"they cannot"* —
a gap found is worth more than a fluent answer assembled from conversation, and filling one from
chat would destroy the only thing this measures.

★★ **THE METHOD (Battlewrath, 2026-08-19): questions DESCEND BY ABSTRACTION on the same
subject.** *"The gaps will come in further questioning on the same first question. This is
cutting it by abstraction."* ⚠ So a CLEAN at one layer says NOTHING about the layer below it —
the top answer is meant to be short and lossy, and what it dropped is the next question, not a
defect. **Read a row with its layer, never alone.**

    CLEAN     one document said it, plainly, and I quoted or compressed it
    REACHED   correct but assembled - several files, or I had to compose it myself
    FAILED    the documents could not answer it

⚠ Appended after each answer, never reconstructed at the end. Evidence, not instruction — this file
directs nothing.

---

## Q1 · "In 15 words. What is the addon we are making?"

**ANSWER (14 words).**

> Two addons: one records dungeon runs and authors routes, one guides players along them.

**SOURCE.** `driver_use_case_target.md` (governing #1) §0 — *"What is not solved is combat
ORGANISATION: getting the player to the combat, giving them enough to solve the trash and any notes
for the boss, and then where to go and how to route to the next engagement"* — and its §9, the two
products and the sorting rule.

**VERDICT — CLEAN.** Governing #1 opens with the statement in Battlewrath's own words, and it is
the first thing in the file. Nothing had to be assembled.

**LAYER 1 — the whole product in one line.** What fifteen words hold is the SHAPE: capture →
author → follow. What they leave for the layer below is the POSITIONING — *not* combat
information, which WeakAuras and DBM already solve, but combat **organisation** — and with it
what the addon deliberately refuses to do. ⚠ Recorded as the next question, not as a loss.

**EXPOSES.** Nothing. #1 is doing its job.

---

## Q2 · "How are the two addons constructed? (language, method.) 30 words total."

**ANSWER (27 words).**

> Both in Lua. Dungeon Run ships Ace3; Dungeon Routes ships none. Tests are written first, then run
> offline in a fake client before anything reaches the game.

**SOURCE — three files, none of which is about this.** `driver_use_case_target.md` §9 for the two
products and the sorting rule · `driver_ui_scope.md` for Ace3 (fork A′, r960) and its Q1 answer
*"SHIP in Dungeon Run only, harness copy for the checker; Dungeon Routes ships none"* · the same
file for the harness running `PerformLayout` under `lua51` offline.

**VERDICT — REACHED, with one FAILED part.**

⚠⚠ **THE PRODUCT LANGUAGE IS STATED NOWHERE IN THE GOVERNING SET.** Grepped across #1, #2, #3, #4
and #9 for any assertion that the addons are written in Lua: **nothing.** It is everywhere by
implication — `.lua` filenames, `lua51`, the client — and asserted as a fact by no document. ★ I
answered "Lua" from having read the code all day, which is precisely the inference-from-context this
test forbids. **A reader arriving cold could not get it from the governing files.**

⚠ The METHOD half is also assembled rather than stated: *criteria written before the code*, *smokes*,
*mutation testing* and *the offline harness* are each visible in an acceptance brief, and no document
says "this is how we build." The shape had to be composed by me.

**EXPOSES — two, and the first is cheap.**
1. **No statement of what the products ARE MADE OF.** Language, the client they target, what each
   ships in `Libs/`, and where Python is allowed (the desk, never the product). One short block in
   governing #1 would close it — the file already owns "what the product IS".
2. **No statement of the METHOD.** Acceptance-before-code, the offline harness, smokes, mutation.
   ⚠ Worth naming as a candidate rather than a defect: it may belong to `operations/`, which owns how
   the system runs, rather than to the driver's governing set.

---

## Q3 · "From a user facing view, what makes each addon distinct. How do we best serve them? 20 words. 2 lines. Each for the addons per."

**ANSWER — DUNGEON RUN, the author (20 words).**

> You mark places on your recorded run, set how close counts, write notes.
> Pick from what it saw — no typing.

**ANSWER — DUNGEON ROUTES, the reader (17 words).**

> You follow someone's route: where to go, what to know.
> Guidance and easy controls. Nothing interrupts you.

**SOURCE.** `driver_use_case_target.md` (governing #1) **§3 The AUTHOR** — *"Nothing else is
authorable"*, *"the sample OFFERS, the author DECIDES"*, *"boss names: picked, never typed"* — and
**§2 The READER** — *"a glance at an arrow and one short line"*, *"Nothing is pushed"*.

**VERDICT — REACHED for the author, FAILED for the reader.** The FACTS are in the right sections of
one file. The LANGUAGE is not: both answers had to be translated out of the document's vocabulary
before they meant anything to the person they describe.

### ⚠⚠ HOW THIS ROW WAS GOT WRONG FIRST — kept, because the failure is the finding

My first answers were faithful compressions of §2 and §3, and I marked them CLEAN:

    ~~You author: places, radii, notes, order - nothing else is authorable.~~
    ~~The sample offers; the author decides. Picked, never typed.~~
    ~~You follow someone's route: an arrow, one short line, your own screen.~~
    ~~Nothing is pushed; your own sensor and ratchet.~~

Battlewrath: *"My own addition. It sounds nice. But it's just that. A sensor or a rachet means
nothing to the end user. It offers guidance and easy controls."*

★★★ **The question said USER FACING and I answered in MECHANISM WORDS** — *sensor*, *ratchet*,
*radii*, *authorable*. A player has none of those and would not recognise the product from that
sentence. ⚠ **A faithful compression of internal vocabulary is still internal vocabulary**, which is
why the row read CLEAN while failing the five-year-old test. ★ And the second answer was only
checked because the first was wrong — the author's line carried the identical fault and would have
stood.

### ⚠⚠ THE FINDING — the file that owns the user-facing view does not speak user-facing

`driver_user_journey.md` states the principle at its own head: *"Reader-word and author-word are
kept on their own sides (expressions §4 principle)."* And governing #1 §2 — the section whose
entire subject is the reader — is written in ours: *own position*, *own ratchet*, *five sensors,
not one plus four displays*.

★ That makes it CHECKABLE rather than a matter of taste: **a section addressed to a person should
contain no term from the code's vocabulary**, and `driver_adaptor_table.md` already holds the
two-sided `code : user` mapping such a check would read from.

**EXPOSES.** #1 §2 wants rewriting in the reader's words and §3 in the author's. His line *"It
offers guidance and easy controls"* is the model for what §2 should read like. ⚠ Recorded, not
done — this file records; it does not edit governing documents.

_★ CONVENTION, set here (Battlewrath, 2026-08-19): **a corrected answer replaces the original in
place**; the original is kept struck beneath it, because how it was got wrong is the part worth
reading._

---

## Q4 · "HOW. What are the methods deployed in our addons that converge as handling types. 30 words each. A line for each."

**ANSWER — seven, each under 30 words.**

> **We read; the game never tells us.** We ask the game where you are, on a clock. Nothing in the
> client announces anything, so everything we know we went and looked for.
>
> **Capture is the only spawn.** Nothing is invented. Every place in a route began as a position we
> recorded while somebody walked there.
>
> **Promotion is reduction.** A run is thousands of samples; a route is a handful of marks.
> Promoting decides which evidence was worth keeping.
>
> **Our rejection is the shape.** The game gives us one thing: our own position. Every distance is
> ours to compute, and a radius or height limit is just what we refuse.
>
> **We inform; we never act for the player.** We show and we tell. We never move you, cast for you,
> or play any part of the game on your behalf.
>
> **We tell; we never lock.** Two marks on the same number is allowed. We say so and let the author
> decide. Refusing would be grading their work.
>
> **We work it out rather than keep it.** Anything we can compute from what we already hold, we
> compute — a second copy is a thing that can disagree.


### ⚠⚠ CORRECTED BY BATTLEWRATH — AND THE HEADING DOCUMENT WAS WRONG, NOT ONLY MY LINE

> *"The game returns one distance = one position(ours). Distance is the relevance. Distance is
> offered is only when the super tracker is set and active."*

★★★ **This is the test's first find in a GOVERNING document.** I wrote *"the game returns one
distance"* — and I wrote it because `dungeonrun_model.md:908` says exactly that: *"The engine
returns ONE scalar — a 3D distance from a point."* Measured against the client facts:

    ROUTER.md:105   `GetCurrentPlayerPosition` is the ONLY world-position getter on this fork
    ROUTER.md:97    the engine's distance comes from `GetSuperTrackedPosition` - so it exists
                    only while a supertracker is SET AND ACTIVE, and only to that ONE target
    ROUTER.md:98    engine distance == OUR OWN ARITHMETIC, 1,739 paired samples, worst 1.9e-5
                    -> that run PROVED our arithmetic. It did not supply it.

★★ **And the shape of the error is the one this whole session keeps meeting.** The section's
QUOTE — Battlewrath's own — is right: *"A position is a point... The game only ever treats it as a
single point."* **The Analyst's gloss underneath it drifted into "the engine returns a distance",
and the gloss is what a builder reads.** A correct quotation with a wrong summary under it.

⚠ **What it would have cost.** A driver tests many targets per sample. If the engine supplied
distance you could ask per target; it cannot, so the sensor holds the targets and computes N
distances from one position. Under the old sentence that design reads as an arbitrary choice
instead of the only option.

✓ **STRUCK IN PLACE** in `dungeonrun_model.md` with the client facts cited — not left for a later
pass, per the standing rule that an un-struck sentence is a live instruction.

**SOURCE.** Five are section headings in `dungeonrun_model.md`, the addon's HEADING: *"We read the
game; the game does not notify us"* (:511) · *"Capture is the only spawn"* (:82) · *"Promotion is
REDUCTION"* (:689) · *"THE GAME HAS NO SHAPES. OUR REJECTION IS THE SHAPE."* (:903) · *"We inform.
We do not act for the player."* (:241). The sixth is `driver_scoping.md` S4 tell-and-trust, carried
in code at `routes.lua:613`. The seventh is `driver_stored_state.md` §3 law 1, from `routes.lua:112`.

**VERDICT — REACHED.** Every line is a real law with a home, and **no document gathers them.** Five
sit as separate `##` headings inside a 1,611-line file, one is a scoping decision, one is a law
about the store. The set is mine; the members are the docs'.

⚠⚠ **AND THAT IS THE FINDING, because these are the most reusable things we own.** They are not
driver rules or editor rules — they hold across both addons and would hold in a third. A new
mechanism should be checked against them (*does this act for the player? does it invent a place?
does it lock the author?*), and there is nowhere to check it against. ★ The model states each one
brilliantly and states them **apart**, so they read as observations about their own section rather
than as a repertoire.

**EXPOSES.** A short standing list — the handling types, one line each, pointing at the section
that argues it. ⚠ Candidate home is `dungeonrun_model.md` itself, which already owns all five of
the strong ones; it would be an index over its own headings, not new material.

---

## Q5 · "For each line, on a new item set: list how those are mechanically driven. Cite of API/function and a lean descriptor."

_Every line number below was read from source for this answer, not carried from a sub-agent report._

**1 · WE READ; THE GAME NEVER TELLS US**

    GetCurrentPlayerPosition() -> x,y,z,mapID   fork-native; the ONLY world-position getter
                                                on this client            ROUTER.md:103,105
    SetScript("OnUpdate", fn) + accumulator     our clock. SAMPLE_EVERY = 1.0 s
                                                                          capture.lua:45,171
    SetScript("OnUpdate", nil) on disarm        the handler exists only while recording
                                                                          capture.lua:181
    RegisterEvent(...)                          state EDGES only - REGEN_DISABLED/ENABLED,
                                                PLAYER_DEAD, ZONE_CHANGED_NEW_AREA,
                                                INSTANCE_ENCOUNTER_ENGAGE_UNIT. Never position
                                                                          capture.lua:687-692

**2 · CAPTURE IS THE ONLY SPAWN**

    Store.Point()                               mints one point: x,y,z,mapID · mapX/Y/C/Z ·
                                                floor · zone,subZone · t,gt   store.lua:178
    Store.AddLeg / Store.AddMarker              append-only; never cleaned or deduped (DR-9)
                                                                          store.lua:314 / :293
    PLACE whitelist (9 fields) + Routes.Inherit what carries from a sample into a node; EVENT
                                                fields do not             routes.lua:64
    Routes.AddBeacon                            refuses a node with no mapX - "refuse rather
                                                than store a ghost"       routes.lua:342

**3 · PROMOTION IS REDUCTION**

    promoter.lua guard                          refuses an already-promoted point
                                                                          promoter.lua:69-82
    Routes.AddBeacon / Routes.AddChildHere      the surviving sample becomes a node
                                                                          routes.lua:338 / :729
    Routes.Gaps / Routes.StageOrder             what the author sees while reducing - order is
                                                a VIEW, never a stored sort  routes.lua:1507 / :1536

**4 · OUR REJECTION IS THE SHAPE**

    setReach(p, radius, up, down)               stores the three rejection numbers on the node
                                                                          routes.lua:1210
    Routes.ReachOf(x)                           pure accessor; nil when the author set nothing
                                                                          routes.lua:1267
    walk.py point_fire / segment_fire           OUR arithmetic; band applied at the INTERPOLATED
                                                z, never at an endpoint   walk.py:320-323
    GetSuperTrackedPosition · _G.SUPER_TRACKED_POSITION
                                                the engine's distance - a WITNESS only, and only
                                                while a tracker is set    ROUTER.md:97,98

**5 · WE INFORM; WE NEVER ACT FOR THE PLAYER**

    SuperTrackerUtil.SetSuperTrackedPosition(x,y,z,mapID)
                                                the pointer. pcall-wrapped; C_SuperTrack.* is
                                                silently overwritten      capture.lua:423,503
                                                                          ROUTER.md:88
    terminal release                            REQUIRED, not manners - nothing in the client
                                                clears it                 ROUTER.md:85
    (no call site)                              no movement and no cast API is called anywhere
                                                in the addon

**6 · WE TELL; WE NEVER LOCK**

    Routes.StageMatches(id, stage, except)      COUNTS collisions, refuses none  routes.lua:1493
    Routes.OrdinalMatches(b, n, except)         same, scoped to the parent       routes.lua:616
    Routes.ChildAt(id, path)                    returns the child AND the hit count, because
                                                `4.1:3` may be ambiguous         routes.lua:631

**7 · WE WORK IT OUT RATHER THAN KEEP IT**

    Routes.ParentOf(id, child)                  computed, never stored           routes.lua:755
    Routes.StageOf(id, node)                    a child's stage is its parent's  routes.lua:786
    Routes.Outcome(b)                           stored-else stage+1              routes.lua:1527
    Routes.StageOrder(id) / ChildrenOf(b)       order is a VIEW                  routes.lua:1536 / :588
    Routes.AcceptanceOf(b)                      what satisfies a beacon          routes.lua:1383
    Routes.ListensNow(b, child, satisfied)      STATELESS - `satisfied` is a set the CALLER owns
                                                                                 routes.lua:668

**VERDICT — REACHED, and cheaply.** Every mechanism has a named function and a line, and I found
them all in the source in one pass. ⚠ But **no document maps a law to its mechanism**: the model
argues each handling type without naming a single function, and the code states each law in a
comment without naming the law it serves. The mapping above did not exist anywhere before this
answer.

★ It is the shape `driver_stored_state.md` already uses for the store (law → `routes.lua:112`), one
level up. The same two columns over the seven handling types would make each law CHECKABLE rather
than admirable.
