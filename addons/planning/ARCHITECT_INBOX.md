# ARCHITECT_INBOX — questions TO the Design architect, from the Creator and the Analyst

_Opened 2026-08-21 at Battlewrath's ask. **A funnel, pointed at the architect.** The Addon creator
(bench) and the Analyst file here when they need: HOW to resolve something the model leaves open ·
WHAT IS EXPECTED of a part or a surface · PERMISSION where *what is* (code, a shipped guard, a
criterion) conflicts with *what should be* (`driver_architecture.md`, the governing docs). The
architect answers in `ARCHITECT_LOG.md` — outcome and reasoning — so this file stays INPUT, upstream.
Where an answer needs Battlewrath's word the architect takes it to him and logs his word as the
outcome. The bench's own channel to Battlewrath, `Reconcile_inbox.md`, is unchanged._

## How it works

    WHO FILES        the Creator or the Analyst; the architect never files to itself
    AN ITEM CARRIES  · the conflict or the blank, in one sentence
                     · WHAT IS — code / guard / criterion, cited (file:line or doc §)
                     · WHAT SHOULD BE — the architecture or governing passage, cited
                     · the asker's READ, marked as theirs, and what they would do absent an answer
                     · IMPACT if answered either way (one line each); absent = "none known"
    FLATTEN          one proposal phrased for yes/no where the asker can; a menu only when
                     measurement cannot separate the options — and say that is why
    STATUS           lives on the ITEM: `AI-N RESOLVED (architect, date)` at its head means resolved
                     and its outcome is in the LOG; no stamp = open. Derive, never list:
                     `grep -n "AI-[0-9]* RESOLVED" ARCHITECT_INBOX.md`; next number = highest + 1
    LEAVES           a resolved item moves under the RESOLVED heading below with its stamp and a
                     pointer to the log entry; removed entirely once the records the log names
                     carry it

⚠ **Not for:** rulings Battlewrath has already given (apply them, cite them) · build-shape choices
that are the bench's own · acceptance wording that is the Analyst's own. An item that is really one
of those gets answered "yours — here is the rule that decides it" and logged as such.


⚠⚠ **A NOTE ON EDITING THIS FILE, WRITTEN TWICE BECAUSE THE FIRST NOTE CAUSED THE SECOND**
**(Analyst, 2026-08-21).** A script anchored on the resolved-section heading cut this file in half
and duplicated its sections — twice. ★ The second time, **the thing it anchored on was the warning
itself**: my note quoted that heading verbatim in order to warn against quoting it verbatim.

⟶ **THE RULE, and it now holds because nothing here spells the headings out:** a document that
describes its own structure must refer to its sections by DESCRIPTION, never by their literal text.
Anchor edits on an item id (`AI-2`) or a unique sentence — never on a section heading.

# OPEN

_(no open items. The next number is the highest `AI-N` present + 1 — derive it, never read it here.)_

---

# RESOLVED

## AI-18 · ★★★ AN ACTOR MODULE — one owner for OUTPUT, and it is the shape three rulings already wanted

_Filed by the **Addon creator**, 2026-08-22. **His proposal; the bench's measurement of what it
lands on.** Nothing built._

> *"It might be we have an actor module that specifically handles the output. So chat and player
> behaviour. Such as marking a target by name. (If they have it, raid markers)"* — Battlewrath

### ★★ IT LANDS ON A SEAM THAT IS ALREADY OPEN

`manager.lua` says it in its own header: *"nothing here invents what `note`, `say` or `boss` DO"*,
and `Manager.Bind` exists so a CONSUMER supplies the handling. ⚠ **Today the only implementation
of those three words is the test drive's harness** (`drive.lua`), which says of itself that its
bodies *"carry no authority over what a shipped reader's addon would do."*

⟶ **An actor module is the missing shipped consumer of a binder that was built for it.** Not a
new architecture — the occupant of a slot that has been empty since §461.

### ★★★ AND IT RESOLVES THREE OPEN THINGS STRUCTURALLY RATHER THAN BY COMMENT

    AI-17            A10.8c rules the manager is NEVER in chat; `manager.lua` has six `say()`
                     calls. With an actor the manager names an ACT and never knows the surface -
                     chat, the reader's note pane, or a marker is the actor's business.
                     ★ The conflict stops needing a warning comment because it stops existing.

    RI-58..60        the behaviour record's `action` and `arg` have no shipped meaning at all.
                     The actor is where the ruled meanings live, so the pane can be wired to a
                     vocabulary that something actually IMPLEMENTS.

    the security ask **his own, 2026-08-21:** *"It could be a window for arbitary code. Where the
                     build process and what that means in code expression would be owned by the
                     users own addon, not what the authoring addon states is capable."*
                     ⟶ An actor module IS that sentence as a module.

★ It is also `travelling data NAMES, never SUPPLIES` made concrete: a route NAMES a verb from a
closed list the consumer publishes; the consumer's actor owns what the verb DOES and whether it is
permitted. ⚠⚠ **And that memory's own warning applies exactly here: *the verb side gets closed;
the ARG side leaks.*** A raid marker takes a NAME — untrusted text from a travelling file, driving
a client action. **The arg boundary is the thing to draw explicitly in this design**, because a
typed promise in prose is not a check.

### THE MEASUREMENTS — what the client can actually do

✅ **RAID MARKERS EXIST ON THIS FORK.** `SetRaidTarget`, `GetRaidTargetIndex`,
`SetRaidTargetIcon`, `SetRaidTargetIconTexture` — present in **two independent census scrapes**
(2026-07-15 and 2026-07-17).

⚠⚠ **BUT "BY NAME" IS THE HARD HALF, AND IT IS NOT AN API.** `SetRaidTarget(unit, index)` takes a
**UNIT TOKEN**. There is no name→unit lookup on this fork — checked the census for one. So a route
saying *mark Baron Silverlaine* has nothing to hand the call.

★★★ **AND WE HAVE ALREADY SOLVED IT ONCE, IN THIS REPO.** `COA_GuardianPlates/Core.lua`
maintains a unit-token index populated from `NAME_PLATE_UNIT_ADDED` / `_REMOVED` and resolves
plates with `C_NamePlate.GetNamePlateForUnit` (pcall-wrapped, `Core.lua:195`). Both APIs are on
this fork. ⚠ It also records a live finding worth carrying over: *"same GUID, same tick,
`NAME_PLATE_UNIT_ADDED` fired for BOTH tokens"* — so a name can resolve to more than one token.

⟶ **Marking by name is reachable for anything with a nameplate on screen, and for nothing else.**
That is a real bound, not a blocker — and it is the honest one to design against rather than
discover.

### ⚠ TWO SILENT-FAILURE HAZARDS THE ACTOR MUST OWN

    PERMISSION   `SetRaidTarget` needs party/raid standing (leader or assist in a raid). Without
                 it the call NO-OPS. ☐ The exact behaviour on this fork is UNVERIFIED - one live
                 probe settles it, and it must be probed rather than assumed.
    RANGE        no plate, no token, no mark. A mob named in a route that is out of render range
                 cannot be marked at all.

★ Both fail the same way: **nothing happens and nothing says so** - which is row 24's whole
complaint. ⟶ An actor that cannot act must REPORT, and where that report goes is the actor's
question too (the author's diagnostics, never the reader's screen - AL-6).

### THE BENCH'S READ

★ **Yes, and it is cheap** — the seam is open, the binder is built, the three words are already
named, and the marker API is confirmed present.

☐ **What design owes before it is built**, and none of it is the bench's:

1. **The closed verb list.** `note` · `say` · `boss` exist. Does `mark` join them, and does it
   take an arg with `source = "run"` (picked from what the run saw) like `boss` does, or typed?
   ⚠ `boss` is already PICKED and uncapped precisely because a picked value is bounded by what
   the game named — the same argument fits `mark` and would close the arg leak by construction.
2. **What `say` MEANS.** The test drive prints it rather than sending it, deliberately (*"a
   rehearsal that talks to the party is a rehearsal the author stops running"*). A real actor has
   to decide the channel, and whether a rehearsal flag exists.
3. **Whether the actor is OURS or the READER'S.** His security framing says the consumer's own
   addon owns it. ⟶ If so, `DungeonRun` ships an actor for TESTING and `Dungeon Routes` ships the
   real one, and the boundary between them is a published list rather than shared code.

---
## AI-14 · ★★★ THE TASTE BUDGET IS GOING TO THE WRONG LANE — two measured instances

_Filed by the **Addon creator**, 2026-08-22, at his ask: *"on the design side. Anything that has stood out as under-developed, or incorrect development lane vs taste/choice?"* ★ Observations from the IMPLEMENTATION seat — what the code makes visible about the design, not design opinions._

**THE OBSERVATION:** Battlewrath's attention has been spent this week on numbers, and the two
places it was spent are both places a MACHINE could have answered — while the questions only he
can answer have not been asked.

### INSTANCE 1 · a measurement question asked as a taste question (2026-08-22, mine)

I asked him for the BAND's upper limit. He answered *"undefined limit (Maybe 10 yards, that's when
we get into floor above clipping)"* — hedged, with a **physical reason attached**.

★★ **THE HEDGE PLUS THE REASON IS THE TELL.** *Floor above clipping* is not a preference; it is
a distance between two standable surfaces, and distances are measured. ⟶ I had put a
MEASUREMENT into the TASTE lane, and the correct answer to it was *"go and measure."*

⚠ Compare the R floor, which is correctly placed: `R_min = v_ceiling × POLL_MIN / 2 = 5`. Nobody
asked him for 5. ★ And the R CEILING (300) is also correctly placed — it is a judgement about how
big a thing a node may be, with no derivation available. **Three questions, two lanes, and only
one of them was routed wrong.**

☐ **THE RULE I WOULD ADOPT:** when an answer comes back hedged AND carrying a physical reason,
the reason is the SPEC FOR A MEASUREMENT and asking him again is asking the wrong lane.

### INSTANCE 2 · taste doing arithmetic that nothing enforces

§144 shipped a **six-pixel overlap** between two buttons on the recorder remote, live, found by a
human looking at a screenshot. §145 he then dragged the numbers on a board.

⚠⚠ **AND `remote.md`'s OWN ☐ SAYS WHY THAT HAPPENED:** *"`check_interface.py` does not read the
header's content box. It reconciles the file, the global and the declared SIZE, but not the stated
inset and width against the children's numbers. **That check would have caught this the day it was
written.**"* The header had said `content x=16, width 208` all along; the code shipped `pin` at 20
w200 and `name` at 22 w190 — three different content boxes, and the one at the top of the file was
the only one nobody followed.

⟶ **So the house rules (the 16/18 margin, the GAP of 6) exist as PROSE and are enforced by his
eye.** Every pixel he drags is arithmetic a checker could hold, and the taste that should be going
into what a surface SAYS is going into whether two edges line up.

**IMPACT if unaddressed:** the pattern repeats per pane, and each repeat costs a deploy, a
screenshot and a board session.

**THE BENCH'S READ:** ☐ the content-box check is small and already specified in `remote.md`'s own
outstanding line — the bench can build it on a word. That is the cheapest change on this list and
it buys back attention rather than spending it.

---

## AI-15 · ★★★ THE AUTHOR'S VOCABULARY IS UNDER-DEVELOPED — the runtime grew a language and nobody has asked what the AUTHOR must know

_Filed by the **Addon creator**, 2026-08-22, at his ask: *"on the design side. Anything that has stood out as under-developed, or incorrect development lane vs taste/choice?"* ★ Observations from the IMPLEMENTATION seat — what the code makes visible about the design, not design opinions._

**THE OBSERVATION:** the consumer tier now implements a rich language. Nothing has asked how
much of it a person should have to hold.

    stage · ordinal / step · step 0 (always-eligible, NOT first) · lone (a childless beacon
    IS the node) · ledTo · trigger once|every · AND a second latch per node ·
    Next(step|stage|set) · sense whenOn|whenOff|seen · action · arg · R · band

⚠⚠ **THIS CUTS AGAINST THE #1 DESIGN RULE.** `plays-by-flattening-decisions`: *reduce decision
load, encode the rule, never add a choice.* Every term above is a choice, and each arrived
correctly — each closed a real hole. **The sum is what nobody has looked at.**

★★ **AND A10.3's BRIEF QUIETLY ASSUMES THE ANSWER.** *"The spec is the pane"* is the first
acceptance row — but the spec it currently names is **the RUNTIME's spec**. Building the pane 1:1
against the runtime is the path of least resistance and would hand the author all thirteen terms.

★ Two of the thirteen are already the good pattern and prove it can be done: `step 0` is a VALUE
rather than a slot, and `ledTo` is a TICK with a default that stores nothing. Both reduce load
rather than adding it.

☐ **THE QUESTION, and it is design's alone:** which of these does an author CHOOSE, which are
DERIVED from position, and which should never surface at all? ⚠ It is much cheaper now than after
the pane is built to match the runtime — and RI-58..71 means the pane is about to be rewired
against exactly that vocabulary.

**THE BENCH'S READ:** this is the item I would most want answered before the wiring pass, because
the wiring pass is where the answer gets baked in by default if nobody gives one.

---

## AI-16 · ★★ NOTHING RETIRES A VOCABULARY — `DropRetired` exists for stored fields and has no counterpart for OFFERED lists

_Filed by the **Addon creator**, 2026-08-22, at his ask: *"on the design side. Anything that has stood out as under-developed, or incorrect development lane vs taste/choice?"* ★ Observations from the IMPLEMENTATION seat — what the code makes visible about the design, not design opinions._

**THE OBSERVATION:** `Routes.ACTIONS = { "supertrack" }` sat live in a shipped pane after
A2.6/AL-19 retired `supertrack` as an action, and nothing anywhere refused it (RI-58).

**WHAT IS**

    routes.lua      `Routes.DropRetired()` — drops STORED fields from an older build and SAYS
                    when one arrives. The pattern works, and it runs at Init.
    routes.lua      `ACTIONS` / `ROW_ACTIONS` — two OFFERED lists, one retired, both live,
                    nothing comparing them
    object.lua      the pane offers the retired list

★★ **THE ASYMMETRY IS THE FINDING.** This project is careful about retiring DATA — `fireOn`,
`goTo`, `bandDown`, `onRamp` were all *removed, not parked*, with a sweeper that reports stragglers.
**The same discipline has never been applied to the words a pane OFFERS**, and an offered word is
the one an author actually touches.

⚠ It is also the shape `half-formed-code-invites-building-on-it` names, one level up: not dead
code, a dead VOCABULARY, and it looked exactly like a working control.

☐ **THE QUESTION:** should a retired term be mechanically detectable? The bench can see one cheap
form — a single source of truth for each list with retirement stamped on the entry rather than the
entry deleted from one list and left in another. That is a design shape, not a build choice, which
is why it is here.

---

## AI-17 · ★ A10.8c AND THE MANAGER DISAGREE, AND THE CODE DOES NOT SAY SO

_Filed by the **Addon creator**, 2026-08-22, at his ask: *"on the design side. Anything that has stood out as under-developed, or incorrect development lane vs taste/choice?"* ★ Observations from the IMPLEMENTATION seat — what the code makes visible about the design, not design opinions._

**THE OBSERVATION:** `A10.8c` rules **THE MANAGER EMITS; IT IS NEVER IN CHAT** — *"Not `print`,
not a channel, not a whisper."* `manager.lua` has six `say()` call sites, all reaching `NS.Say`,
all landing in the chat frame.

★ **AND IT IS NOT A DEFECT TODAY.** A10.8 is explicitly *"WRITTEN AHEAD — CHAIN 3 WAITS … a
criterion waiting for its moment, not a queue item."* There is no reader's pane for the manager to
emit into, so chat is the only surface that exists.

⚠⚠ **WHAT IS MISSING IS THE MARK.** Nothing in `manager.lua` points at A10.8c. Whoever builds
the reader's pane meets six chat calls with no note saying they are on borrowed time — and this
project's own standing complaint is that *a governing document reads as DESCRIPTION when much of
it is PRESCRIPTION* (`driver_built_state.md`'s opening).

☐ **THE QUESTION, and it is small:** mark it now in the code, or accept that A10.8c's own
"written ahead" framing is enough? **The bench's read: mark it**, one line at `say`, because the
cost is one line and the failure mode is a builder discovering a ruling by breaking it.

★ Filed rather than fixed, because a comment asserting a ruling's reach is a claim about the
model, and `don't mutate code from doc disagreement` puts that here.

---
## AI-13 · WHAT A FLOOR GATE BUYS — and what it costs at the doorway that swaps the tile

_Filed by the **Addon creator**, 2026-08-22, at Battlewrath's direction: **"push it to design so we
can consider implimentation. On what it buys."** Measured, not built. Supersedes `RI-57`, which
stays open pending this._

**THE QUESTION, one sentence:** should the sense rule gain a FLOOR test as the cheap half of a
two-sided check — *"right floor location"* then *"right exact envelope"* — given that the node
most likely to need one is the DOORWAY, which is exactly where the label is least stable?

### WHAT IS

    rule.lua:87    `Rule.Gate(sampleMapID, nodeMapID)` — mapID ONLY. No floor test exists.
    rule.lua:104   `Rule.PointFire` — radius then `dz >= 0 and dz <= bandUp`. Geometry alone.
    store.lua:187  the SAMPLE carries `floor` (DR-33)
    routes.lua:69  `PLACE` carries `floor` onto every minted node

⟶ **Both sides already hold the field and nothing reads it.** This is a wiring question, not a
data question.

### WHAT SHOULD BE

    driver_neighbours.md §GatherMate2   floor equality is listed among "the cheap idioms"
                                        worth taking, in the verdict that also names the
                                        posture we refuse
    rule.lua:83 (`Rule.Gate`'s own note) "the cheapest test first, and it is not an
                                        optimisation … a small dx/dy across a map boundary
                                        is a coincidence rather than a proximity"

★ Two AREAS overlapping in world space are that same coincidence one level down — and Battlewrath
has since fixed what a floor IS: *"One floor is a area. A area can have overlapping spaces within
the same space, such as a cat walk above the entry."* So a floor is not a storey, and floor equality
discriminates AREAS, which geometry cannot.

### ★★★ HIS OWN OBJECTION, AND IT IS THE REASON THIS IS HERE RATHER THAN BUILT

> *"There are things like changing a floor at speed and the pointer is the door way that swaps into
> the floor tile."*

⚠⚠ **A node placed AT a doorway sits on the boundary where the label swaps.** So the gate would be
least reliable at precisely the nodes that lead — the ones the supertracker points at.

### THE MEASUREMENTS (corpus, 11,804 positioned samples · 13 runs)

    COVERAGE      9,549 with floor / 2,255 without. The bulk of the gaps are PRE-DR-33,
                  but not all: 5 of ~6,900 recent samples carry none (~0.07%). The client
                  withholds it occasionally and we do not control when.

    FLAPPING      30 floor transitions across the corpus. **6 of them are A → B → A** —
                  the label went and came straight back. **20%.**

    SPEED         median 7.0 yd/s across a swap, max 10.3. ⚠ That is RUNNING speed:
                  **the corpus contains no high-speed or teleport transition at all**,
                  so 20% is a FLOOR on the flap rate, not a ceiling. His "at speed"
                  case is un-measured, not measured-safe.

### THE BENCH'S READ (mine, and what I would do absent an answer)

★ The gate is worth having but **only as a PERMISSIVE test** — refuse when both sides are known
and differ, fall through whenever either is absent:

    if sampleFloor and nodeFloor and sampleFloor ~= nodeFloor then return false end

⚠ A strict equality is a new SILENT-STALL mode, which is this project's worst failure: a nil or
flapped floor refuses a node the player is standing in, the tab never completes, the stage never
advances, and nothing says why. `Rule.Gate` refuses a nil `mapID` and is right to — a dungeon
always has one. **Floor is not that field.**

⚠⚠ **BUT PERMISSIVE DOES NOT ANSWER THE DOORWAY.** A flap is two KNOWN values that differ, so
the fall-through never fires — the gate refuses, correctly by its own rule, at the node that leads.
⟶ That is the part the bench cannot resolve from the model, and it is the question.

### FLATTENED

**Q1 · Does the sense rule gain a floor test at all?** YES / NO.
**Q2 · If yes — what protects the doorway?** ⚠ A menu, because measurement cannot separate these:

    (a) NOTHING. Authors do not place nodes on thresholds; the R5 reach spans the swap anyway.
    (b) THE NODE OPTS OUT. A per-node "any floor" tick, authored where a threshold is meant.
    (c) STICKY. The gate uses the LAST STABLE floor rather than this sample's, so a flap
        cannot refuse. ⚠ Buys the doorway, adds runtime state to a rule that has none.
    (d) SEEN-ONCE. A node the player has been inside on the right floor stops floor-gating.

**Q3 · What is it FOR?** ☐ The bench cannot cost this honestly. **No overlapping-area false fire
has ever been OBSERVED** — the gate is reasoned from GatherMate2's idiom and from `Gate`'s own
principle, not from a fault we have seen. If the answer is *"it buys correctness we have not needed
yet"*, that is a real answer and cheaper than four options.

### ★★★ ADDED 2026-08-22 — BATTLEWRATH'S REFINEMENT, WHICH DISSOLVES Q2

> *"I think the best case is what floor pre-ceeds and is next (and current), so a 3 tile listen.
> (More importantly before and current), as the sequence to reaching that location will most likely
> be 2 pattern match across way points."*

★★ **A NODE LISTENS ON A SET, NOT A VALUE** — `{preceding, current, next}`, weighted toward
*preceding and current* because that is the pair a reader actually arrives through.

★ **AND IT ANSWERS THE DOORWAY WITHOUT PICKING FROM Q2's MENU.** A flap is `A → B → A` between
*adjacent* floors, and adjacent floors are both in the set by construction — so the 20% flap stops
being a failure mode rather than being worked around. ⚠ The four options I listed (nothing / opt-out
tick / sticky / seen-once) were all runtime patches for a problem this removes at BUILD time.

★★★ **AND IT BELONGS IN THE BUCKET, WHICH IS WHERE THE ORDER IS KNOWN.** `Bucket.Build` already
resolves exactly this class of field — `trigger` (*"resolved here, so the manager never meets an
absent field and an authored `once` as two different things"*) and `ledTo` (derived from position,
never stored). ⟶ A `floors` set is the same shape: **derived at authoring time, riding the
CHARACTERISTIC record**, and the runtime test stays a set membership on 2-3 integers.

⚠ **ONE WRINKLE, NAMED NOT SOLVED: *preceding* is not always single-valued.** Several nodes share
STEP 0 within a stage (an ordinalless child is *always eligible*, not *first*), and a stage-0
recovery beacon has no position at all. ★ But the nodes with a well-defined predecessor are exactly
the ones `Routes.IsPosition` admits — **the same set that is LED TO** (AL-19). That symmetry looks
load-bearing rather than lucky, and is worth the architect's eye.

### ⚠⚠ THE PLUMBING FACT, MEASURED — THE FLOOR NEVER REACHES THE SENSOR TODAY

`bucket.lua:475-509` builds its node from an **explicit whitelist**:

    x · y · z · mapID · r · band · stage · step · lone · nextType · nextArg · trigger ·
    ledTo · address · rows

⟶ **`floor` is not on it.** The authored node HAS one (`PLACE` carries it, `routes.lua:69`) and the
SAMPLE has one (`store.lua:187`, DR-33), but the bucket drops it, so nothing downstream of authoring
has ever seen a floor. ★ `sensor.lua`'s snapshot copies every key it is given, so the whitelist is
the only gate.

★ **SO NO OPTION HERE IS "FREE".** Every floor-aware answer costs the same first line — carry the
field through the bucket — and the choice between them is about what is DERIVED there, not about
whether plumbing is needed. ⚠ That also means the question cannot be settled by *"we already have
the data"*: we have it at both ends and nowhere in the middle.

### IMPACT

    ANSWERED YES   a 3-line change in `rule.lua`, ONE field carried through `bucket.lua`
                   (plus whatever the 3-tile set derives there), its acceptance row in
                   A11.2, and the fixtures. The bench builds it.
    ANSWERED NO    nothing is built; `RI-57` drains citing this; the measurements stay on
                   record so the next person does not re-derive them.
    UNANSWERED     the bench does NOT build it. A permissive gate that refuses at doorways is
                   worse than no gate, because it fails where it matters and nowhere else.

---
## AI-12 RESOLVED (Battlewrath, 2026-08-22) → `ARCHITECT_LOG.md` AL-22 · Trigger, ruled on what it does; A12.4b's attribution corrected

**⟶ A12.4b's ✅ and quotation come off (the quote was about Next). Trigger IS now ruled, by its own word: a node
field, Once | Every time — Once: the manager sends it to the sensor once, it completes and leaves the offered
list; Every time: the manager maintains it in the list. Completion once per arming. The flattened question
("does a completed node re-run its Next?") → NO by the architect's rule, standing until overturned; Set's
regress is the one word still his.**

_Filed by the **Addon creator**, 2026-08-22 (§484), **from Battlewrath's correction of this
bench**. ⚠ I told him `Trigger` was ruled and ready to build. It is not, and the row that made me
think so is the item._

### THE CONFLICT

    driver_manager_acceptance.md A12.4b
      "`Trigger` says once or every time. ✅ RULED 2026-08-21 (Battlewrath): BUILD IT —
       *make it an exception by selection, not by many states of the same UI.*"

**Battlewrath, 2026-08-22:** *"I said this about **next**, letting a node not force a stage
advancement by opt out."*

⟶ **The quote is real and the attribution is not.** It authorises the `Next` OPT-OUT - which is
what §479's landing and AL-21's addendum built - and A12.4b uses it to mark `Trigger` RULED.
★ A row carrying a ✅ and a quotation is the strongest thing a reader can meet; this one sent this
bench to the top of a build list for a mechanism nobody has decided.

### ★★★ REFRAMED BY BATTLEWRATH, 2026-08-22 — REPEAT IS THE MANAGER'S LIST

> *"The sense is defined by the manager's offered list. So **repeat is a function of the manager to
> re-state or not**."*

★★ **THAT DISSOLVES THE FIELD AND KEEPS THE BEHAVIOUR.** `Trigger` was being asked to STORE
*"does this run again"* on the node. It does not need to: a node runs again **iff the manager
re-offers it**, and the manager already owns the offered list by his older rule - *"the manager
swaps out the SELECTION rather than telling the sensor what to bounce."* ⟶ Same law, one tier down.

⚠ **AND IT KEEPS THE SENSOR BLIND**, which a stored `Trigger` would not have: the sensor evaluates
whatever list it is handed and never learns that a node is *spent*. Spent is a MEANING.

### WHAT IS — measured against the reframe (§485)

    manager.lua armCurrent   builds the list from `Bucket.Stage` ALONE. The ledger is never
                             consulted at arming - `active.done` is read only by
                             `nodeComplete` and written by `completer`.
    ⟶ so "repeat" today is  **ALWAYS**, for anything that stays armed. Not a default anyone
                             chose; the consequence of the list never being filtered.

★ And that is why the two live cases behave the same today when they should not:

    the wrong-way note   SHOULD repeat - his own example. Stays offered. ✓ correct by luck.
    the escapement       fires its `Set(N)` on EVERY re-entry, because it also stays offered.

### ⟶ SO THE QUESTION IS BETTER SHAPED THAN THE ONE ABOVE

It is no longer *"what does `Trigger` store"* but:

> **WHEN DOES THE MANAGER DROP A COMPLETED NODE FROM THE OFFERED LIST?**

★ The bench's read, marked as its own: an ordinalled node needs no rule - completing it advances
the step and the whole bucket is swapped, so it leaves by construction. The rule is only ever about
nodes that STAY armed, which is bucket 0 and the step-0 greedy set. ⚠ And those are exactly the two
that disagree: the note wants re-stating, the escapement probably does not.

⚠ **Absent an answer the bench does nothing** - but the shape of the answer is now a MANAGER rule
rather than a stored field, which is smaller, keeps the closed vocabulary closed, and needs no code
term (the thing A12.4b has been stalled on).

### AND HIS SECOND HALF NARROWS WHAT THE WORD MEANS

> *"You are right that one time COMPLETE. (**Not** one time sense, which isn't a thing in code.
> Just making anti statement.)"*

★ So whatever `Trigger` governs, it is **COMPLETION**, not sensing. ⚠ The bench had been reading
it as *"the action fires once"* - which is what produced the claim that the shipped default was
inverted. It was not; the axes are different.

### WHAT IS — measured, §484

    completion   a node completes ONCE. `done[i]` is set and never cleared, and
                 `nodeComplete` stays true. ✅ already correct.
    the action   RE-RUNS on every qualifying transition - a wrong-way note shows again on
                 re-entry, which is what his own example wants.
    ⚠ BUT       a completed node whose `Next` is `Set(N)` now RE-FIRES that Next on every
                 re-entry (reachable only since §484 fixed A12.7a). Walking back through a
                 recovery beacon steps the run again.

### THE ASKER'S READ, marked as MINE

★ The re-firing of the ACTION looks right and his wrong-way case wants it. **The re-firing of
`Next` is the one I would not guess.** *"One time COMPLETE"* reads as: the node completed, so its
completion consequences do not run twice - which would mean the escapement fires once per arming,
not once per entry. But a reader walking back into recovery arguably wants sending again.

**Absent an answer the bench does nothing** - the behaviour is live and observable now, and both
readings are defensible.

### ✅ FLATTENED

> **Does a node that has already completed run its `Next` again when it re-qualifies?**
> **NO** → completion is once and its consequences are once; the ledger gates `NodeDone`.
> **YES** → re-entry re-fires, and `Trigger` (if it lands) governs the ACTION only.

⚠ And separately: **A12.4b's ✅ and its quotation want removing**, whatever the answer - the row
should say what it actually is, which is *not built and not ruled*.

### IMPACT

    ANSWERED     `Trigger`'s scope stops being ambiguous, and A12.4b can be written truthfully.
    UNANSWERED   a completed recovery beacon re-steps the run on every walk-through, which
                 nobody has agreed to - and the acceptance brief still tells the next reader
                 the mechanism is RULED.

---


## AI-10 RESOLVED (architect, 2026-08-22) → `ARCHITECT_LOG.md` AL-24 · an ordinalled node cannot complete without advancing — by definition, not by hole

**⟶ NO. An ordinal is a position in a sequence and completing a position IS the hand-off (the constant lives
in the ordinal — R7 / AL-13). A node that should complete without moving the sequence is not in the sequence:
give it no ordinal (the tray). The derivation stays total; no fourth type.**

_Filed by the **Addon creator**, 2026-08-22 (§483), at Battlewrath's ask to put each decision item
in separately. ⚠ Left OPEN by the bench at §479 rather than closed by failure of imagination, and
AL-21's addendum took the landing without reaching it._

### THE BLANK, in one sentence

`Next` ABSENT is now an OUTCOME whose meaning is DERIVED from position — **and the derivation has
exactly one shape it cannot express**: an ordinalled node that completes but must not advance.

### WHAT IS

    manager.lua NodeDone   ordinalled + absent Next -> Manager.StepOn (the ordinal moves)
                           zero node  + absent Next -> nothing follows
                           explicit Step/Stage/Set  -> the instruction, either way
    §479 / AL-21 addendum  "ordinalled → Step; zero node → nothing follows; explicit → the
                           instruction" - TAKEN as the rule

⟶ So an ordinalled node has **no way to say *I complete and nothing follows***. Absent means Step;
an explicit `step` means Step. There is no third state.

### WHAT SHOULD BE — unknown, which is the item

Battlewrath's own framing is what makes the question live: *"child 0 isn't expected to start the
ordinal, **unless that is its instruction**"* — the zero node got an escape. The ordinalled node
never asked for one, and nobody has said whether it needs one.

### THE ASKER'S READ, marked as MINE

★ **I cannot construct a route that wants it.** A node at step 3 that completes and refuses to move
to step 4 simply stalls the ordinal — the reader stands in a finished place with nothing to walk
to. Every case I tried collapses into either *"it should be a zero node"* (it is a detector, not a
position) or *"it should advance"*.

⚠ **But I have been wrong about a step-0 node's abilities once already this week** (RI-52: I said a
greedy node could not complete; it can, and always could). So this is filed as UNKNOWN rather than
as NO.

**Absent an answer the bench does nothing** — the derivation stands and covers every route anyone
can currently author.

### ✅ FLATTENED

> **Is there a route that wants an ordinalled node to complete and advance nothing?**
> **NO** → the landing is complete as ruled; this item closes and the derivation needs no fourth
> state. **YES** → the explicit word §479 rejected is needed after all, and the landing is wrong.

### IMPACT

    ANSWERED NO    nothing changes; a known hole is closed as *not a hole*, which is worth the
                   line because the next reader will otherwise re-find it.
    ANSWERED YES   `Next` grows a fourth type after all, the closed list grows (the direction
                   AL-19 moved away from), and §479's reasoning needs revisiting.
    UNANSWERED     a documented gap in a rule that is otherwise total. Cheap to carry, but it
                   is the kind of gap that gets rediscovered as a defect.

---

## AI-11 RESOLVED (Battlewrath, 2026-08-22) → `ARCHITECT_LOG.md` AL-25 · a client-only seam is accepted by the IN-GAME DEBUG LOG, against the DevDump precedent

**⟶ Thin adapter YES — and its acceptance is not a look but a RECORD: an in-game DEBUG LOG (its own module,
so the project is not built as a test suite) captures background behaviour during a named test run —
the manager's decisions, the sensor as BUCKETS (transitions + throttle state), never a line per second —
and what DIFFERED is the evidence. Precedent: COA_DevDump's chain test advanced per arrival in the client.**

_Filed by the **Addon creator**, 2026-08-22 (§483). ⚠ This is a METHOD question, not a shape one,
and it blocks the last unblocked item on Chain 3._

### THE CONFLICT, in one sentence

`driver_architecture.md` §7 (AL-12, Battlewrath) says **the bench PROVES on synthetic rows, not A/B
in the client** — and L3.3's tracker wiring is a seam that *cannot* be proven that way, because
what it does is call the client.

### WHAT IS

    manager.lua   `Manager.Tracker` is a declared SEAM: `{ Point(node), Park() }`, nil by default.
                  The manager's lure and park logic is BUILT and graded against a double that
                  RECORDS which node it was handed (A12.3c · A12.8a · tray-0 never lures).
    capture.lua   already calls `SuperTrackerUtil.SetSuperTrackedPosition` /
                  `ClearSuperTrackedPosition`, guarded by a `_G` existence test and `pcall`.
                  **So the client door exists and has a shipped precedent.**

⟶ What is missing is ~10 lines that hand the manager's seam to that door — and **nothing the bench
can write proves those ten lines work.** A double proves the manager; only the client proves the
adapter.

### WHAT SHOULD BE

§7 is a principle about where CONFIDENCE comes from, not a ban on client code — `capture.lua` is
full of it. But the acceptance briefs have no row shape for *"this was verified by looking at it"*,
and A11.9's escapement is graded on geometry that was built in §414 and never watched.

### THE ASKER'S READ, marked as MINE

★ I would build the adapter **thin enough to be read rather than tested** — no branching, no
derivation, a direct hand-off with the same `_G` guard and `pcall` `capture.lua` uses — and record
that its acceptance is **a deploy-and-look by Battlewrath**, named as such rather than dressed as a
smoke row. ⚠ The bench must not deploy (his standing rule), so the looking is his either way; the
question is whether that counts as ACCEPTANCE or as an ungraded claim.

### ✅ FLATTENED

> **Is a thin client adapter, accepted by a named deploy-and-look rather than by a smoke row, an
> acceptable close for L3.3 — or does §7 require it stay unbuilt until a harness exists that can
> prove it offline?**

### IMPACT

    ANSWERED       L3.3 becomes buildable, and the answer sets the pattern for every remaining
                   client-touching seam (the action bodies, the note surface, the chat line).
    UNANSWERED     the manager can arm, dispatch, advance and park — and the arrow never moves
                   in the game. The whole tier stays unobservable to the person it is for.

---

## AI-9 RESOLVED (architect, 2026-08-21) → `ARCHITECT_LOG.md` AL-21 · `Next` is a field the store owes; `role` is the old pane's

**⟶ YES — `Next(Type, arg)` joins the store (the declaration already exists), one authoring door, one
`NodeDone` branch. ONE correction to the reading: `role` is not a concern that stays — it is the OLD PANE's
spelling, editor-side and live only until A10.3 replaces that pane (A10.2a already lists it among the
replaced); the store hook then MIGRATES it deterministically (`complete` → Next(Stage) · `set`+setStage →
Next(Set,N) · `start`/`update` → nothing, they are positions). The one-rule-two-bodies finding is the bench's.**

**Filed by: the Analyst, 2026-08-21**, closing RI-49's original question rather than passing it
on. ⚠⚠ **Battlewrath's instruction is why this is a PROPOSAL and not the four readings:** *"The
system is not to refer a question with a better question."* ⟶ RI-49 filed four readings and
declined to choose, correctly — it had no measurement. **There is one now, and it separates them,
so choosing is the work rather than the overreach.**

### THE PROPOSAL, flattened

> **`Next(Type, arg)` is a field the STORE owes and does not have. `role` + `setStage` are NOT
> that field under another name — they are an EDITOR-side concept and they stay. YES / NO.**

### WHAT IS — measured today, four places

    contract.lua    DECLARES `nextType` and `nextArg` on the CHARACTERISTIC record, with `why`
    routes.lua      has NEITHER. It has `ROLES = { start, update, complete, set }`, `child.role`,
                    `child.setStage`
    bucket.lua      carries NEITHER onto the entry — only `ledTo`, computed at build
    manager.lua     `Manager.NodeDone` reads **`node.lone` and `node.step`. Nothing else.**

### ⟶ WHY THE OTHER THREE READINGS FAIL, and each fails on a fact rather than a preference

    A  role `set`+setStage == Next(Set,N), `complete` == Next(Stage)   ❌ both need the MANAGER
    C  `Next` is the model's NAME for what `role` already is            ❌ to read `role`. It
                                                                          does not.
    D  `role` is the author's word, `Next` the runtime's, BUCKET converts ❌ no `nextType` in
                                                                          `bucket.lua`. There is
                                                                          no conversion.
    B  `role` is a separate concern; `Next` is a field nobody added      ✅ describes the code

### ★★★ AND THE CHECK THAT WOULD HAVE MADE ME OVERREACH IS THE ONE WORTH REPORTING

I was one step from proposing that `role` follow `goTo` and `fireOn` — both RETIRED, named here
only as the precedent — into removal: *authored, stored, read by nothing.* **It is read.**

    routes.lua  `Routes.AcceptanceOf(b)`   `if c.role == "complete" then return c end`
                                           — *which child satisfies this beacon*
    object.lua                             the ONE real consumer of `AcceptanceOf`
    bucket.lua                             ⚠ mentions it in TWO comments (*"already encodes
                                           exactly this"*) and **reimplements the rule instead
                                           of calling it**

⟶ **`role` is not dead; it is EDITOR-SIDE**, and it answers the AUTHOR's question. ★★ Which makes
B stronger than B stated itself: **`role` and `Next` were never two words for one thing. They are
two different things that both got called "what happens next", on opposite sides of the driver
split** — one asks *which child satisfies this beacon*, the other says *where the run goes when it
does*.

⚠ ⬜ A smaller thing the same check found, NOT part of this proposal: `bucket.lua` cites
`AcceptanceOf` as authority and re-implements its rule. **One rule, two bodies.** The bench's, and
filed here only because it surfaced under the same read.

### IMPACT

    YES   `nextType`/`nextArg` join the store (the declaration exists already) · an authoring
          door · `NodeDone` gains one branch. ★ The bench already said the shape is ready:
          *"adding the authored cases is one branch in one function."* Nothing else moves, and
          `role` is untouched.
    NO    **`Stage` and `Set(N)` stay unauthorable.** §479's landing covers the DERIVED case
          only, so two of `Next`'s three types can never be expressed — and the recovery beacon
          (`Set N`, named in §4b as *the tray's* escapement) is one of them.

### ⬜ WHAT THIS ITEM DOES NOT ASK

The FOURTH selectable value (*nothing follows*) from RI-49's fall-out is a separate decision and
is not bundled here. ★ And RI-53 notes where both land: **`contract.lua` already describes these
fields, so whatever is answered gets written where the description already is.**


---

## AI-7 RESOLVED (architect, 2026-08-21) → `ARCHITECT_LOG.md` AL-20 · six stale build-state claims, edited

**⟶ All six corrected at their cites; build-state sentences replaced by pointers to the checker that
derives them (`emit_built_state.py`); the counts removed rather than updated. The dead `routes.lua:474`
comment is the bench's.**

**Filed by: the Analyst, 2026-08-21**, from `audit/staleness_2026-08-21.md` (four read-only
agents, one axis each). ⚠⚠ **NOTHING IS ASKED EXCEPT THE EDIT.** These are not disagreements about
design — they are claims about BUILD STATE that the code has moved past. The Analyst corrected the
identical claims in its own acceptance documents and **stopped at your files**, because #0 and the
basis register are yours.

⟶ **Every row is re-runnable at its cite. If any is wrong, it is wrong at the cite.**

### THE SIX

    1  §3b SENSOR ROW      ⚠⚠ THE LARGEST STALE BLOCK IN THE SET. The row's whole "TODAY / OWED"
       (architecture)      split is inverted: `Sensor.Arm` allocates FOUR sets, not one
                           (`{nodes, inSet, wasIn, everIn}`) · `Poll` swaps them and returns
                           `changed`, entries `{address, word, node}`, emitting WHEN_ON / SEEN /
                           WHEN_OFF · `snapshot()` CARRIES `rows`. **The entire OWED half is
                           built.**

    2  §6 G18             *"ZERO code behind it today (D2); until it lands the sense vocabulary
       (architecture)      is unimplementable from what the sensor keeps."* → built, as above.
                           ★★ WHY THIS ONE IS DIFFERENT IN KIND: it is **L2.3, Chain 2's
                           "BLOCKS ALL DISPATCH" item.** A stale BLOCKER stops work that is
                           already unblocked — worse than a stale fact.

    3  §6 G19b            *"`sensor.lua`'s header still calls it owed."* → **the word `owed` does
       (architecture)      not occur in `sensor.lua` at all.** The cited evidence is gone; the
                           gap itself the Analyst did not adjudicate.

    4  §6 / G6            *"fourteen named refusals today, none for this"* (two beacons at one
       (architecture)      stage) → **16 refusals**, and one of them IS this:
                           *"two beacons at stage %s (%s and %s) - re-slot in the editor"*.
                           ⚠ The manager brief quotes that same refusal verbatim, so two
                           governing documents disagreed with each other.
                           ⬜ `ARCHITECT_INBOX.md` AI-1 carries the same sentence.

    5  THE MANAGER        *"NOTHING IN IT IS BUILT… No row carries a `grades` line for a manager
       (DRIVER_BASIS)      function — the identifiers do not exist yet."* → `manager.lua` landed
                           §461 with **16 `Manager.*` functions**, in the `.toc`, its header
                           naming the brief that grades it.

    6  THREE COUNTS       §5's *"fourteen macro laws"* → **16** (L1-L14 plus L15 and L16, both
       (DRIVER_BASIS)      added by the commit that wrote "fourteen") · §A's *"22 selected rows"*
                           → **27 base rows plus 4a / 12a / 17a-d** · `ReachOf`'s *"one production
                           call site"* → **two** (`object.lua`'s ratchet tell AND `bucket.lua`'s
                           row-27 band conversion, the second load-bearing).

### ⚠⚠ AND ONE THAT IS NOT A DOC FAULT — THE SOURCE LIED, AND FOUR DOCS INHERITED IT

`DRIVER_BASIS.md` carries *"PRECONDITION: `AddBeacon` still forces a stage."* It does not — S7
(§395) landed. **But the doc quoted faithfully:**

    routes.lua:474   ⚠ ALWAYS A STAGE … the stageless RECOVERY beacon has no
    routes.lua:475     path in through here either. Owed, no impact yet.
    routes.lua:476   ★★★ S7 (§395): 0 IS THE STAGELESS REQUEST …
    routes.lua:491       if want == 0 then b.stage = nil

★★ **The dead comment sits directly above its own replacement.** Four planning documents quote it
as a live blocker. ⟶ *The doc quoted faithfully; the source lied* — the one failure mode
**"the source is truth" cannot catch**, and it spread precisely because each author did the right
thing. ⬜ **The comment is the bench's to remove; the four citations are corrected or filed.**

### ★ WHAT THE AUDIT ALSO FOUND, offered as evidence rather than as an ask

**Zero ghosts.** All **39** `grades` citations across seven documents resolve to real functions —
against **~31 of ~55 drifted line numbers** in those same documents. ⟶ The clean axis is the one
`emit_built_state.py` already REFUSES on. **A guard beat a convention by a wide margin on one
afternoon**, and that is the argument for the next guard rather than the next instruction.

⬜ **THE ANALYST'S READ, marked as mine and not an ask:** three of these four axes are things a
document cannot keep true about itself. A build-status claim, a line number and a count all decay
the instant they are typed. ⟶ Where a governing doc must assert build state, the durable form is
**a pointer to the checker that derives it**, not the state itself.

**ABSENT AN ANSWER I do nothing here** — your files stay as they are, and the audit file records
the divergence. ⚠ Only #2 has a cost while it sits: it tells a reader that dispatch is blocked.



---

## AI-8 RESOLVED (Battlewrath, 2026-08-21) → `ARCHITECT_LOG.md` AL-19 · `supertrack` is a characteristic, not a behaviour

**⟶ YES, and it is the GENERAL RULE (L17): a capability sits in the layer where it has meaning. `supertrack`
leaves ROW_ACTIONS and becomes the node's LED TO tick — on by default, ticking off a choice, tray-0 UNTICKED
and the choice not surfaced. Per NODE. The when-on/when-off lure-back argument dissolves: re-pin on the
remote is the user's control. The §471 migration branch becomes "set the tick".**

_Filed by the **Addon creator**, 2026-08-21 (§475), from Battlewrath's own reading. It touches the
CLOSED CAPABILITY LIST, which is the security boundary (§464), and the SEED that AL-18 just ruled —
so it is asked, not built._

**His words:**

> *"Way point can't be a choice via the sense / act / what to act. The super tracker is what gets
> the player TO the sense site. So if it is a option, it lives in the character, not behaviour.
> Behaviour would only be if it was pointing OUTWARDS, which we have since disallowed."*

### WHAT IS — and the code agrees with him more than the model does

    routes.lua:1267   Routes.ROW_ACTIONS = { "boss", "note", "supertrack", "say" }
    data model A1.1   BEHAVIOUR record = `MapID:RID:BID:CID : Sense : action : arg`
    object.lua:486    A2.6 - *"`supertrack` now points at the node's OWN position - the only
                      place it can name - so there is no second choice to offer"*
    A12.3c            **the MANAGER writes the stage's ENTRY LURE to the tracker ON ARMING**
    RI-42             the manager owns *"the three tracker writes (entry lure · supertrack tab
                      · the park)"*

★★★ **THE TIMING IS THE ARGUMENT, and it is stronger than "wrong record".** A behaviour row
fires on its SENSE. The only sense that fits a waypoint is `whenOn` — arrival — so a
`whenOn:supertrack` row **points the arrow at the node the reader is already standing in.** The
sense fires on arrival and the action's entire job was to get them there. ⟶ The row form is not
merely misplaced, it is **incoherent**: there is no moment at which it can usefully run.

★★ **AND A2.6 IS WHAT MADE IT SO.** While `supertrack` could point OUTWARDS at another node it
was a genuine choice about a TARGET, and a behaviour. A2.6 removed the picker — it can now name
only itself — and at that moment it stopped being a choice about anything except *"is this node
led to?"*, which is a property OF THE NODE. **The field did not move; the mechanism under it did,
and the field was never re-seated.**

★ **THE MODEL ALREADY HALF-KNOWS THIS.** RI-42 lists *"the supertrack tab"* among the manager's
own tracker writes, beside the entry lure. If `supertrack` were purely a row action the manager
would not need it named there — it would just be another callable. Two mechanisms are doing one
job, and A12.3c's is the one that runs at the right time.

### ⟶ WHAT THE BENCH READS THIS AS (marked as the asker's)

> **`supertrack` leaves `ROW_ACTIONS` and becomes a node CHARACTERISTIC** — a flag on the
> characteristic record beside POS, R and Band, **default ON**, which is exactly Battlewrath's
> *"maybe a tick on by default. Tick off otherwise."* The manager already reads the node to write
> the lure (A12.3c); it would read this flag to decide whether to.

⚠ **What it costs, named so the decision is not blind:**

    ROW_ACTIONS      loses a word. ★ The closed capability list SHRINKS, which is the safe
                     direction for a security boundary - one fewer verb a travelling file may name.
    ROW_ARG_RULE     `supertrack`'s absence entry becomes moot; nothing else changes.
    MigrateRows      ⚠ **§471 IS WRONG UNDER THIS READING** - it converts `child.action ==
                     "supertrack"` into a ROW. It would instead set the characteristic, and the
                     node would take the arrival seed like any other. **One branch, and the
                     migration has not shipped to a player yet.**
    A13.1            **unchanged** - the seed is still `When on` with no action. If anything this
                     makes it cleaner: with waypointing off the row list, "no action" means
                     purely *reached*.
    A12.4d           unchanged.
    the pane         the action dropdown loses its only shipped value and gains a tick. That is
                     L1.2's, and it is a smaller pane rather than a larger one.

⚠ **AND ONE THING THAT IS NOT THE BENCH'S TO ASSUME:** whether the flag is authored per NODE or
inherited per route/stage. Battlewrath said *"it lives in the character"*; the bench read that as
the node's characteristic record, but a route-level default with a per-node override is the same
sentence and a different data shape.

### IMPACT

    ANSWERED     one word leaves the closed list, one branch of the migration changes, and the
                 pane gets simpler. Nothing built this week is invalidated except that branch.
    UNANSWERED   `supertrack` stays a row action that can only fire after the reader has already
                 arrived where it would have pointed them, and two mechanisms keep doing one job.

---

## AI-6 RESOLVED (architect, 2026-08-21) → `ARCHITECT_LOG.md` AL-18 · the seed's sense and action; no fourth sense-word

**⟶ Q1 NO — no fourth word: the seed's sense is `When on` (arrival IS the behaviour — a stage is "get you
into the room"); "satisfied as soon as the gate opens" describes no node we have. Q2 — S1's mechanism with
a plainer meaning: a row's ACTION is OPTIONAL (reached — nothing else); the arg guard runs only when an
action is present; an ADDED row starts unset ("Select a sense type") and is incomplete, told, until picked.
The `routes.lua:1308` comment is the bench's to re-seat (one blank line).**

**Filed by: the Analyst, 2026-08-21.** Battlewrath directed the DIRECTION here rather than to the
bench: *"I would say leave a item in the architect inbox of the direction."* ⟶ **Two decisions, one
already his; the rest is yours.** The measurements behind this are in `Reconcile_inbox.md` RI-51,
F1 third pass, and every line is re-runnable at its cite.

### THE BLANK, in one sentence

A beacon is PLACED before its behaviour is decided, so a seeded Action 1 must exist and must not
stall the run — and neither the sense list nor the action list has a term for *"nothing to wait
for."*

### WHAT IS

    routes.lua:1306   `Routes.SENSE_WORDS = { "whenOn", "seen", "whenOff" }` — three.
    routes.lua:1320   `Routes.ROW_ACTIONS = { "boss", "note", "supertrack", "say" }` — four, and
                      every one of them is a real capability a travelling route may NAME.
    routes.lua:467
    routes.lua:1006   `AddBeacon` and `mint` write kind · id · name · stage · placement, and
                      **no `sense`, `action`, `boss` or `rows`.**
    routes.lua:1356
    bucket.lua:64     BOTH doors check the ACTION word regardless of the sense, so a seeded row is
                      refused today whatever its sense says.

### WHAT SHOULD BE

    §4b (yours, 2026-08-21)   *"sense — one of the **three** sense-words — a **closed set**;
                                anything else REFUSED at build by name."*
    AL-17 (yours)               *"defaults are materialised as real rows at authoring time so a
                                runnable node always has one."*  ⟶ The seed is ruled; its CONTENT
                                is not.

### ✅ ALREADY RULED BY BATTLEWRATH, 2026-08-21 — the facing word, so it is not asked here

> *"**'Select a sense type'**, use facing. Then however we want to express it internal."*

★ The display word is a **PROMPT, not a state name** — it tells the author they have not picked
without naming a value to them. ⚠ Measured: `adaptor.lua` carries **no sense word at all** and A5.1
passes a miss through, so **the code word is what the author reads until an adaptor row lands.**
⟶ An adaptor row is owed with the term, not after it. That part is the bench's and is not asked
here either.

### ⟶ Q1 — THE FOURTH SENSE WORD. **Flattened for yes/no.**

**PROPOSAL: add a fourth sense word meaning *satisfied as soon as the gate opens*, and make it the
seed's sense. YES / NO.**

★ **The reason it belongs in the sense position and not the verb list**, and it is the argument
rather than a preference:

    routes.lua:1304   *"the node's SENSE is per node … the row answers **AT WHICH EDGE of that**."*
                      ⟶ **"At which edge" has a degenerate answer: NO EDGE.** The fourth word is
                      that question asked of a node with nothing to wait for — not a new concept.
    AND               self-termination is a statement about **WHEN**, not about **WHAT**. A no-op
                      in `ROW_ACTIONS` would be a timing property wearing a verb's clothes — the
                      same fault `set` / `ratchet` were struck for (`routes.lua:1310-1318`).
    AND               `ROW_ACTIONS` is the CLOSED CAPABILITY LIST. Its value is that it reads as
                      exactly *what a route can make happen*; a no-op is harmless to run and
                      corrosive to read.

    ⚠ THE COST      §4b's *"three"* and *"closed set"* become four, dated. **A closed set gaining
                    a member is your edit by definition** — which is why this is here and not on
                    the bench.
    ⚠ THE NAME      [[naming-primes-the-agent]]: name by the dumb action. *"Not set"* names an
                    AUTHORING ABSENCE; the behaviour is *satisfied when the gate opens*. ⟶ The
                    code word wants the second thing; **"Select a sense type" is the facing word
                    and is already ruled.** ⬜ The code term itself is yours — the Analyst records
                    the law that picks it, not the word.

    IMPACT YES      B0 gains its content; B2 becomes a guard on the impossible case rather than
                    the common one; §4b edited, dated.
    IMPACT NO       the seed needs a term somewhere else, and the only other place is the verb
                    list — which is the thing the argument above says not to do.

### ⟶ Q2 — WHAT THE SEEDED ROW'S **ACTION** IS. ⚠ **A menu, and the reason is stated.**

Q1 removes the need for a no-op VERB; it does not remove the need for a legal action VALUE, because
both doors check the word. **Measurement cannot separate these two — they differ in what the
vocabulary MEANS, not in what anything does** — so it is a choice, not a finding.

    S1  THE PAIR IS THE UNIT     a row whose sense TERMINATES carries no action; the grammar reads
                                 *"action required unless the sense terminates."*
        ★★ PRECEDENT, EXACT      `ROW_ARG.supertrack = nil` ALREADY makes the ARG required-or-not
                                 by READING a declaration keyed on the action word
                                 (`bucket.lua:287`). S1 is the same mechanism one level up —
                                 a `SENSE_TERMINAL` declaration, read and never copied.
        ✅ AND IT COSTS NOTHING ELSEWHERE. Measured on lua5.1: reading `t[nil]` is legal and
        yields nil (only WRITING a nil key raises). So `Routes.RowIncomplete` reading
        `ROW_ARG[row.action]` with no action gets nil and reports the row **COMPLETE** — correct
        by construction, with no special case added to it.

    S2  A NO-OP RETURNS TO `ROW_ACTIONS`     one table cheaper; pays it into the capability list.

**THE ANALYST'S READ, marked as mine: S1** — it keeps `ROW_ACTIONS` meaning one thing, and the
precedent for a required-or-not field read from a declaration is already shipped.
**ABSENT AN ANSWER I do nothing here** — I cannot write B0's or B2's acceptance without it, and
that is the correct cost. ⚠ It blocks only those two: **B4 · B1 · B3 are independent of both
questions** and the bench has been told so.

### ⚠⚠ AND ONE THING NEITHER OF US SHOULD RESOLVE ALONE — a live ambiguity in the file

`routes.lua:1308` — *"⚠ AN OPEN LIST, NAMED AS THEY LAND (model §2). Adding one is a line here plus
the driver's implementation."* **That comment sits BETWEEN the two declarations**: below
`SENSE_WORDS`, above `ROW_ACTIONS`, and its body discusses `set` / `ratchet`, which are ACTION
candidates. ⟶ **The file does not say which list it annotates**, and *"is `SENSE_WORDS` an open
list"* is precisely what Q1 asks. ★ Whoever wrote it knows; one blank line fixes it. **Reported,
not resolved** — the Analyst will not guess a comment's subject and then cite it back as authority.


---

## AI-5 RESOLVED (architect, 2026-08-21) → `ARCHITECT_LOG.md` AL-17 · THE POSED PAYLOAD — what BUCKET emits per tab, defined rather than described

**⟶ DEFINED in `driver_architecture.md` §4b (the posed tab: address · gate · sense · fn · arg; Next and
Trigger stay the node's; completion the ledger's) · the flat form is MIGRATED ONCE by the store hook, never
converted at build · the empty node is REFUSED by name, YES · the arg is a typed VALUE guarded by reading
the declaration, YES · the resolver binds only words on the closed list (the bypass is closed).**

### ⚠⚠ CORRECTED BY THE ASKER, SAME DAY — THREE OF THE FIVE QUESTIONS WERE ALREADY ANSWERED

**Battlewrath, 2026-08-21, on reading the item:** *"It was said the instruction set carries the
gate and the ID. Then the table for an ID is self enclosed on it's full tab layout. … Basically
the instruction set is a manifest."*

★ **He is describing `driver_data_model.md` A1.1 and A1.4a, which I did not open before filing.**
I built this item from RI-42 and the acceptance brief — a working set, not the basis. The model
already carries it:

    CHARACTERISTIC  (the TABLE)             MapID:RID:BID:CID : Stage : Step : POS : R : Band
                                            : Next(Type,arg) : Trigger
                                            *absolute values, resolved at AUTHORING time;
                                             the driver is handed them*
    BEHAVIOUR       (the INSTRUCTION SET)   MapID:RID:BID:CID : Sense : action : arg
                                            *ordered by gate; every term a REFERENCE the driver
                                             resolves against functions it already has*

★★★ **BOTH ARE KEYED BY THE ADDRESS, and A1.2 says there is no second key-space:** *"OWNERSHIP
IS THE ADDRESS. There is no ownership table."* ⟶ **The "ID" the manifest carries IS THE ADDRESS**,
and *"the table for an ID is self-enclosed on its full tab layout"* is the CHARACTERISTIC record
under that same address. One key, two records.

**What that closes, and each was a question above:**

    Q4 arg ID vs arg VALUE   ❌ THE QUESTION WAS MALFORMED. I read RI-42's *"arg ID"* as a
                             separate id-space for arguments. There is none. The ID is the
                             ADDRESS; A1.4a already rules every term on the behaviour record a
                             REFERENCE the driver resolves.
    Q3 `Next`                ✅ ANSWERED BY PLACEMENT. `Next(Type, arg)` is on the
                             CHARACTERISTIC record - the TABLE - beside POS, R, Band and
                             Trigger, and those are *absolute, resolved at authoring time*. It
                             never rides the manifest. ⚠ RI-49 shrinks to its remaining half:
                             is `role` + `setStage` the STORE's spelling of that table field, or
                             is `Next` still OWED as a field? That is a build question, not a
                             vocabulary one.
    Q2 the fields            ✅ LARGELY ANSWERED. The behaviour record is `Sense : action : arg`,
                             opening with the gate. ★ And A1.1's own note says the Trigger move
                             *"makes the BEHAVIOUR record and the ruled grammar the same thing"* -
                             the grammar being `<sense>:<action>:<arg>`, **which is the shipped
                             row** (`routes.lua:1057`). ⟶ **`child.rows` IS the instruction set.**
                             It was never a competing shape; the flat fields are the older one.

### ★★★ A CONSTRAINT ON ANY ANSWER — SECURITY. "POSED" MAY NOT MEAN "PRE-FORMED"

**Battlewrath, 2026-08-21:**

> *"One thing against build and accept pre-formed. **Security.** It could be a window for arbitrary
> code. Where the build process and what that means in code expression would be owned by the users
> own addon, not what the authoring addon states is capable."*

★ **A route is DATA THAT TRAVELS.** `routes.lua:14` drops the run back-reference precisely so a
route can reach *"someone else's machine"*. ⟶ Everything on it is therefore UNTRUSTED INPUT, and
the line *"posed for execution"* must never be read as *"the route supplies the thing executed"*.

★★ **THE MODEL ALREADY STATES THIS PROPERTY — as an implementation note, not as a boundary.**
A1.4a: *"every term is a REFERENCE the driver resolves against **functions it already has**."*
⟶ **"Functions it already has" IS the security boundary**, and it deserves to be written as one:

    THE ROUTE MAY          NAME a verb, from a closed list the CONSUMING addon publishes
    THE ROUTE MAY NOT      supply, select, or influence WHAT that verb does

⚠ So `arg` is not *"a reference"* in the same sense `action` is. An action name is resolved against
a closed table; an argument is a VALUE handed to a function. Whatever AI-5's answer is, **the answer
has to say which of the manifest's terms are resolved against local tables and which are values**,
because they carry different trust.

### ✅ MEASURED AGAINST A HOSTILE ROUTE — one half holds, one half does not

    THE VERB SIDE HOLDS.   `bucket.lua`'s gate validates `action` against `Routes.ROW_ACTIONS`,
    the closed authorable set (§457). A route naming a function the addon never published is
    refused BY NAME:

        action=boss           BUILT
        action=__index        REFUSED  unknown action (__index)
        action=loadstring     REFUSED  unknown action (loadstring)

    ✅ And `Manager.Bind` is the other half of the same property: the CONSUMING addon registers
    its own callables and the route never supplies one; an unbound word is refused at arm.

    ❌ THE ARG SIDE DOES NOT. `ROW_ARG` says `boss` takes a *name*, and NOTHING CHECKS THE TYPE:

        arg = "Ragnaros"       BUILT   arg is a string      <-- as intended
        arg = { evil = true }  BUILT   arg is a TABLE
        arg = 1234             BUILT   arg is a number
        arg = true             BUILT   arg is a boolean

⚠ **This is not arbitrary code by itself** — SavedVariables carry data, not functions — but it is
an UNTYPED PAYLOAD reaching a consumer that was promised a name. A body doing `arg:sub()` or handing
it to a client API meets a table; a body that ITERATES one is doing what the FILE said rather than
what the addon said. ★ That is the shape of his objection, one level down from the verb.

**⟶ The bench's proposal, flattened, and it presupposes no answer above:**

> **BUCKET refuses an `arg` that is not the type its action declares, naming it.** Every entry in
> `Routes.ROW_ARG` today is a TEXT field (`name`, `content`), so the guard is *must be a string*,
> written so that when an action takes something else `ROW_ARG` grows a type and the guard READS it
> rather than being edited. (§458's lesson: a copy drifts, a read cannot.)

⚠ **AND ONE THING THE ARCHITECT SHOULD KNOW ABOUT THE SEAM:** `Bucket.Resolve`, when installed,
**bypasses the closed-vocabulary check** — `known()` returns the resolver's answer before consulting
`ROW_ACTIONS`. Under his principle that is arguably CORRECT, since resolution is the consuming
addon's to own; but it means *"a route can only name a published verb"* holds only as strongly as
whoever installs the resolver. ★ Named here so the binder's definition can decide it deliberately
rather than inherit it.

---

### ✅ SO WHAT IS ACTUALLY OPEN IS ONE THING AND ONE GUARD

> **1. THE CONVERSION.** The pane writes `child.sense` / `child.action` / `child.boss`; the model's
> instruction set is `child.rows`. **Nothing converts.** Is the flat form CONVERTED at build with
> the pane left as it is, or MIGRATED once and the pane moved onto rows? ⚠ Only one of those makes
> L1.2 a migration rather than a build, and that is the whole of its scope.
>
> **2. THE EMPTY NODE** (unchanged, and still a yes/no). May BUCKET refuse a node carrying no
> behaviour records, naming it? It can never complete (`manager.lua:276`), so today such a route
> arms, points the arrow, and silently never advances.

⚠ **The measurement below stands** — a route authored through the shipped doors builds with zero
tabs and stalls in silence. Only the QUESTIONS shrank, not the fault.

⬜ **Everything after this heading is the item as first filed**, kept rather than rewritten: it is
the record of what the bench believed, and three of its questions being answerable from a document
the bench did not open is the more useful fact.

---


_Filed by the **Addon creator**, 2026-08-21 (§461), **at Battlewrath's explicit direction.** He gave
the behaviour and then declined to let it be built from the giving:_

> *"Sense action boss as the flat form. The Route addon should know how to handle them. In-bucket I
> think replace them with the function call handling / however that looks, so when a stage and step
> is true, and the sense condition is met, the payload is already posed for execution. **But that's a
> description. Better is getting it defined upstream so we're not designing by flight.**"*

★ **So this item asks for a DEFINITION, not a yes/no** — and says so deliberately, against the
FLATTEN rule, because he named the failure mode he wants avoided. The one thing I would flatten is
in the READ below.

### THE BLANK, in one sentence

**Three open threads are one seam** — the flat author fields, the action binder, and `Next` — and
all three are answered by defining **the fields of one posed tab record that BUCKET emits**.

### WHAT IS — measured, not recalled

    routes.lua:1258 SetChildSense    writes child.sense    ─┐
    routes.lua:1639 SetChildAction   writes child.action    ├ THE FLAT FORM. What the pane authors.
    routes.lua:1322 SetChildBoss     writes child.boss     ─┘  object.lua:921/1077/1251/1313.
    routes.lua:1294 SetRow           writes child.rows     ── THE ROWS FORM. **No production caller.**
    bucket.lua:293                   READS child.rows      ── the runtime's only input
    bucket.lua:46   Bucket.Resolve = nil                   ── the declared binding seam, unused

⚠⚠ **AND THE HALVES DO NOT MEET.** A route authored through the shipped doors was run through
`Bucket.Build` today:

    AddBeacon -> beacon 1, rows 0
    Bucket.Build -> BUILT 1 nodes          <-- it does NOT refuse

⟶ The node arrives with **zero tabs**, and `manager.lua:276` (`#rows == 0` → never complete) means
the route **arms, points the arrow, and silently never advances.** No refusal, no message. That is
the failure class row 24 exists to prevent, and it is live today.

### WHAT SHOULD BE — and the architecture already says it

**RI-42, the architect's own instruction, is nearly his sentence verbatim:**

> *"THE INSTRUCTION SET is the manager's TICK LIST — built at BUILD from the records (function +
> arg ID ride the BEHAVIOUR record, once per tab; every record opens with the gate), never
> exported."*

**A12.2c:** *"Every action word is BOUND to its callable at build; nothing authored is interpreted on
the hot path."*
**`bucket.lua:44`'s own seam note:** *"Binding a callable is a later step, and it goes through this
seam rather than around it."*

★★ **So the RULE is settled and has been for a week. What has never been written down is the
RECORD** — which fields a posed tab carries, and what BUCKET does to get from `child.sense` /
`child.action` / `child.boss` to it. Every part named above is waiting on that one definition.

### WHAT THE DEFINITION HAS TO SETTLE — the questions the bench hit, in the order it hit them

    1  FLAT → POSED   Is the flat form CONVERTED at build (the pane keeps writing it), or
                      REPLACED by an authoring door that writes tabs directly? He says the Route
                      addon *"should know how to handle them"*, which reads as convert — but
                      whether the flat form survives as the authored truth or becomes a legacy
                      shape read once and migrated is a different answer, and only one of them
                      makes L1.2 a migration.
    2  THE FIELDS     What does one posed tab carry? The bench's working set is
                      `{ gate, sense, fn, arg }` — RI-42 names three of those (*"function + arg
                      ID"*, *"every record opens with the gate"*) and A12.4a needs the sense word
                      to match on. **Is that the record, or is it missing something?**
    3  `Next`         RI-49, unchanged: model row 12 rules `Next` ONE field `(Type, arg)`;
                      `routes.lua` stores `role` + `setStage` and has no `Next`. If `Next` rides
                      the posed record, this is the same definition and not a second one.
    4  ARG ID         RI-42 says *"arg ID"*, not *"arg"*. Today `bucket.lua:293` carries the arg
                      VALUE. If an ID is meant, what resolves it, and when?
    5  THE EMPTY NODE Does a node with no tabs REFUSE at build? It cannot complete, so it cannot
                      advance a run. (See the flattened question below.)

### THE ASKER'S READ, marked as MINE

★ **I would define one posed tab as `{ gate, sense, fn, arg }`, produced by BUCKET, and have the
flat fields CONVERTED into exactly one such tab at build.** That satisfies every citation above
without adding a concept: the gate is already composed (A12.2e), the sense is already matched
(A12.4a), `fn` is what `Bucket.Resolve` was declared for, and a converted flat node yields the one
tab the pane can author today. ⚠ **But it is a read, and §457/§458 are two commits in a row where my
read of a shape was wrong in a way only measurement found.** I am not building on it.

**Absent an answer I do nothing here** — which is the correct cost, because Chain 2 is complete and
the seam is the only thing between a stalled route and a running one.

### ✅ THE ONE THING I WOULD FLATTEN, because it is a guard and not a design

> **May BUCKET refuse a node that carries no tabs, naming it?**

Such a node can never complete (`manager.lua:276`) and therefore can never advance a stage, so it is
a silent stall wearing the shape of a working route. ⚠ It is a one-line refusal in a list of
fifteen, and it does not presuppose ANY answer above — whatever a posed tab turns out to be, a node
with none of them is not runnable. **Yes and it lands today; no and it is recorded as deliberate.**

### IMPACT

    ANSWERED    the seam closes; L2.4's binder, RI-49's `Next` and L1.2's scope all follow from
                one definition instead of three guesses. The manager needs one branch added.
    UNANSWERED  a route authored in the client today arms and silently never advances, and the
                bench builds nothing further on the consumer side.
    THE GUARD   answered either way, the silent stall stops being silent.

---

## AI-3 RESOLVED (architect 1/3/4; Battlewrath 2 — 2026-08-21) → `ARCHITECT_LOG.md` AL-13 · dock / undock is NOW; four blanks

**⟶ all four answered: a group = an interface surface minus the map · return = the COLLAPSED STRIP (dock
all) in the bolt-on's own texture grammar + a PER-TAB return band on each undocked window, one language,
a drawer by illusion · dock state account-wide · one declaration, two arrangements.**


_Filed by the **Addon creator**, 2026-08-21 (§446), at Battlewrath's direction after RI-46
moved D-C from later to now._

**THE BLANK, IN ONE SENTENCE:** `A10.9a-f` rule the dock/undock BEHAVIOUR completely, and
nothing enumerates the **groups** it operates on, says **how an undocked group returns**, says
**where dock state lives**, or declares the **undocked templates** — so the bench cannot build
it without inventing product behaviour.

★ **WHAT IS ALREADY RIGHT, so it is not re-opened:** A10.9's core property — *every visibility
is DERIVED from ONE piece of state* (docked / undocked, per group), with the tab, the panel and
the strip all functions of it. That is the flattening rule doing real work and it is what makes
the mechanism small. **The gap is enumeration and lifecycle, not principle.**

### ✅ EVIDENCE FIRST — the measurement A10.9f asks for, as far as it can go today

`addons/tools/smoke/probe_pane_height.lua` (new, §446; a PROBE, outside the `smoke_*` glob
because it prints and asserts nothing):

    DECLARED HEIGHT PER SUBJECT - the OBJECT group only
      beacon    415        child     535        note      169        none      113
      ---> tallest subject: child at 535
    FOLD, measured: 4 foldable zone(s) on the tallest subject
      all open   535       all folded  169

⟶ **The object group demands 535 today**, ~649 once A10.2a's three land (RI-46's 714 was that
number against `object.lua`'s 600 pane, which A10.9f says is the wrong budget). ★ Folding every
zone frees 366. **A10.9f's *"which group is tallest"* still cannot be answered** — see blank 1.

---

### BLANK 1 · WHAT IS A GROUP? — and it blocks the column's size

    WHAT IS         `panespec.lua` declares ONE group, the object pane (`Spec.SUBJECTS`).
                    `curation` · `map_controls` · `promotion` · `remote` · `map` have
                    interface files under `planning/interface/` and NO `Spec`.
    WHAT SHOULD BE  `A10.9b`: *"one tab per group that is currently docked"*.
                    `A10.9f`: the column is *"sized to FIT THE LARGEST CONTENT"*.
    MY READ (bench) a GROUP is one interface file — six of them — because that is the only
                    enumeration that exists and `check_interface` already reconciles it 1:1.
    ABSENT AN ANSWER I would measure only the object group and size nothing, which is where
                    this run stopped.
    IMPACT   yes →  four `Spec` declarations are owed before the column can be sized. Bench work,
                    large but mechanical.
             no  →  the grouping is something else and the four declarations may be wasted.

★ **FLATTENED TO YES/NO:** *is a group one interface file?*

### BLANK 2 · HOW DOES AN UNDOCKED GROUP COME BACK? — your own open "maybe"

    WHAT IS         nothing. No restore path exists in code or in acceptance.
    WHAT SHOULD BE  `A10.9d`: *"A10.9d's strip is one resolution and it is still his 'maybe'.
                    **What is now clear is that SOMETHING must restore; which thing is his.**"*
    MY READ (bench) none offered. ⚠ This is a hole in the MIDDLE of the mechanism, not at its
                    edge: undock is reachable the moment dock/undock ships, and a group with no
                    way back is a group the author loses.
    ABSENT AN ANSWER **I would not ship undock at all** — shipping a one-way door is worse than
                    shipping neither half.
    IMPACT          either way it is small to build; the cost of guessing is a user-facing
                    behaviour nobody chose.

### BLANK 3 · WHERE DOES DOCK STATE LIVE?

    WHAT IS         nothing stores it. `COA_DungeonRunDB` is per account (`store.lua`).
    WHAT SHOULD BE  `A10.9`: *"the whole structure adds ONE piece of user-facing state —
                    docked / undocked, per group"* — which says its SHAPE and not its HOME.
    MY READ (bench) account-wide, beside the other UI preferences, because it is a preference
                    about the tool and not about a route. ⚠ A route-scoped dock state would
                    travel on export, and `RI-24`'s law is that nothing about the author's own
                    setup travels.
    ABSENT AN ANSWER I would take my read — it follows from RI-24 rather than from taste — but
                    it is user-visible, so it is named here rather than assumed silently.
    IMPACT   either  one field; the risk is only that it is in the wrong file to change later.

### BLANK 4 · THE UNDOCKED TEMPLATES

    WHAT IS         none declared. Only `Spec`'s docked-column shape exists.
    WHAT SHOULD BE  `A10.9f`: *"UNDOCKED · PER-GROUP, from a TEMPLATE"*, and the parity law:
                    the two forms *"may not diverge in CONTENT — same controls, same get/set,
                    same adaptor labels — only in arrangement."*
    MY READ (bench) the parity law makes a template DERIVABLE: same cells, different
                    arrangement. ★ So a template could be a re-layout of the SAME declaration
                    rather than a second one — which would make A10.9f's parity MUTATION
                    structurally impossible instead of merely graded.
    ABSENT AN ANSWER I would build docked only, and leave undock unreachable.
    IMPACT   yes →  one declaration per group, two arrangements. Parity cannot break.
             no  →  two declarations per group, and parity needs the guard A10.9f describes.

★ **FLATTENED TO YES/NO:** *is the undocked template a re-ARRANGEMENT of the same declaration,
rather than a second declaration?*

---

## AI-4 RESOLVED (architect, 2026-08-21) → `ARCHITECT_LOG.md` AL-14 · the record/surface join, handed over for the inventory

_Filed by the **Addon creator**, 2026-08-21 (§447). ⚠ **INPUT FOR THE AUDIT, not a build
request.** Battlewrath ruled the emitting tool NEGATIVE and put this with design as *"part of
the audit and then inventory work"* — so this is the measurement handed over rather than kept._

**HIS FRAME, which is what makes this worth measuring** (2026-08-21): three things are true —
**what we have today**, which shows information in different levels of completeness · **what we
store as functions** · **what we need to surface to the author**. ★ *"This is a pass to try and
answer the last 2, to get to the first."* ⟶ The pane is DERIVED from the record and the
authoring need, not from today's pane.

### THE JOIN — `contract.lua`'s declared fields against `interface/object.md`'s 37 controls

**STORED AND SURFACED (9)**

    stage    → object.stage        step  → object.ordinal      r      → object.reach
    band     → object.reach.up     sense → object.sense        action → object.action
    nextType → object.outcome      nextArg → object.outcome.n   arg    → object.boss

**STORED, NOT SURFACED (4)**

    trigger        ⚠ A RECORD FIELD THE AUTHOR CANNOT SET. Already known and already
                   stated: *"the once | every control — NOT BUILT; code term the bench's
                   the day it lands"* (`driver_adaptor_table.md:147`).
    posX/Y/Z       ✅ DELIBERATE, not a gap. A2.5: *"Position is the node's (map), never on
                   the behaviour pane."* Named here so the inventory does not re-raise it.

**SURFACED, NOT STORED (5)**

    object.role · object.shape · object.match · object.unseen · object.answers

★★★ **AND THIS IS THE FINDING WORTH THE FILING.** `A10.2a` already rules that
`role / shape / action / outcome / unseen` are *"NOT folded — REPLACED by A10.3's controls"*.
**The contract says WHY: they are not in the record.** ⟶ A design instinct and a mechanical
fact arriving at the same answer independently, which is the strongest corroboration this
project gets — and it means the replacement is not a preference to defend.

### ⟶ WHAT IT IMPLIES FOR (3), offered as the bench's read and not as an answer

**The authoring surface is far smaller than today's pane suggests: NINE fields to author, ONE
owed control (`trigger`), and position handled on the map.** ⚠ **Fourteen of the 37 controls
carry no record field at all.** ★ That number is the *"different levels of completeness"* made
countable, and it is the input the inventory needs rather than a conclusion about it.

### THE ONE QUESTION — flattened

**`trigger` is a declared record field with no control and no chosen code term.** Everything
else above is either surfaced, deliberately map-side, or already marked for replacement.

    MY READ (bench)  it is owed a control in the A10.3 pass, alongside the others, rather
                     than separately — it is a NODE field (`contract.lua:87-90`), so it
                     belongs wherever the node's other fields land.
    ABSENT AN ANSWER I would not add it. A11.2/A11.3 do not consume it, so nothing in the
                     driver is blocked, and inventing the code term is explicitly not the
                     bench's (`driver_adaptor_table.md:147` reserves it).
    IMPACT   yes →   one control and one adaptor row, in a pass already touching the pane.
             no  →   the record keeps a field nothing can write, which the export will
                     eventually have to explain.

★ **FLATTENED TO YES/NO:** *does `trigger` get its control in the A10.3 pass?*

### ⚠ AND WHAT WAS NOT BUILT, recorded so it is not re-proposed by accident

The bench offered `emit_surfaced.py` — this join, EMITTED rather than typed, so it cannot go
stale the way `store.lua`'s own `Shape:` block did. **Ruled NEGATIVE.** ★ If the inventory work
later wants it kept live, the shape is above and the two inputs are both declarations we own;
it would need a declared exceptions list carrying reasons (side tables the driver never opens;
position is map-side) so it reports real gaps rather than artefacts of the join.

---

## AI-2 RESOLVED (architect, 2026-08-21) · the reconcile audit’s 20 corrections to the architecture doc

**⟶ OUTCOME IN `ARCHITECT_LOG.md` AL-9.** **YES — all 20 landed**, each marked *"(AI-2 audit,
corrected 2026-08-21)"*. **A6** now reads *the next stage PRESENT in the route*. **C1/G6** and **C2/G18**
are marked **CLOSED BY DESIGN, OPEN IN BUILD**. **F2 decided:** the bucket’s duplicate-stage refusal
(D3) is **SEQUENCED BEFORE the manager** (D6). **C4** became law **L15**, home A11.2a. Two fault shapes
earned rules in §7: *closed means built*, and *a multi-part gap is struck only when every part has its
citation*. ★ **F1 answered separately in AL-10** — RI-23 stands, R2 is satisfied by the MANIFEST,
**conditional on a demonstration the Analyst writes as three A-rows**. **AL-11** adds **L16** (the hot
path is sensor → action; the swap is a rebuild by eviction, never optimised).

<details><summary>THE ITEM AS FILED</summary>


**THE ASK, one sentence:** the seven-pass reconcile Battlewrath ordered is complete and stored at
**`addons/planning/audit/reconcile_architecture_2026-08-21.md`** — 55 findings, every one cited on
both sides — and **20 of them are corrections to `driver_architecture.md` itself**, which is yours.
I need your response on those before I touch the governing docs or the acceptance, which is the
order he set: *"Split what needs architecture correction, get response, then work on the governing
docs and update the acceptance."*

⚠ **THIS ITEM DOES NOT RESTATE THE AUDIT.** The detail, the citations and the confidence marks are
in that file; a second copy is a copy that can disagree. What follows is only what you need to
answer.

### WHAT IS — the audit's own classification of your document

    A · ARCHITECTURE CORRECTION   16 findings   the macro doc lost a distinction the mechanics
                                                doc drew; §7 says the mechanics doc is right
    C · FALSE CLOSURE              4 findings   a §6 gap marked CLOSED that is open

★ **Thirteen §6 closures were followed and found genuinely closed**, and §1 verified clean
throughout, so this is a targeted list rather than a verdict on the document.

### THE FOUR THAT MOST NEED YOUR JUDGEMENT, not mine

    A6   §4b step 5 says "Stage -> +1". L3 permits an authored gap, so stages 1,2,5 are legal;
         +1 arms stage 3, which `Bucket.Stage` resolves to bucket 0 ALONE. ⚠⚠ THE RUN STALLS
         WITH ONLY RECOVERY ARMED. This is a defect in the ACCEPTED spec, not doc drift.
         ⚠ And my A12.5a quietly paraphrased it to "the next positive stage" instead of
         reporting the disagreement — my fault, against A12's own preamble. Both need your word
         on the wording before I correct either.

    C1   §6 G6 and §4 both say duplicates "cannot be authored", present tense, no status marker.
         AL-8 answered AI-1 by pointing at the bucket's refusal — and the audit READ the refusal
         list: **fourteen named refusals, none for a duplicate stage.** AL-8's own words were
         "its NEXT named refusal". ⟶ The guarantee is enforced at NEITHER end today, and A12 is
         written on it. A12.2b marks it OWED correctly; §6 and §4 read as shipped.

    C2/C3 G18 is a false closure at three hops with zero code behind it (RI-42's own IMPACT block
         lists the same work as still owed, in the item whose closing list says G18 is done).
         G19 closed a TWO-PART gap on a citation answering ONE part — the surviving half ("the
         in-set's semantics once armed ≠ eligible") is now hidden inside struck text. G3 has the
         same shape. ★ **A multi-part gap struck on a partial answer** is a fault shape worth a
         rule, not just four fixes.

    C4   G4's zone-change ruling exists ONLY as struck text inside §6, uncited. Repo-wide grep for
         "highest identity" returns ONE hit — the gap line itself. §7 rules answers land in the doc
         that owns the part, NEVER here. ⟶ **It disappears when §6 is drained.**

### THE ANALYST'S READ (mine, marked)

All 20 are DRIFT-DOWN or FALSE-CLOSURE by §7's own rule, so **the architecture file is what
changes** and none of them needs Battlewrath. ⟶ Absent an answer I would do nothing to your
document and proceed only on sections B and E (the governing docs and the stale values), which
are mine — but that leaves §6 asserting two closures that are open, which is the state that
produced C1 in the first place.

**FLATTENED, one yes/no:**

> **Do you take the 20 corrections to `driver_architecture.md` yourself — so I proceed on B and E
> (governing docs, acceptance, stale values) in parallel and do not touch your file?**

    YES   clean seat separation; I start on B/E now and the two passes do not collide.
          IMPACT: none on me. §6's two false closures stay asserted until you land them.
    NO    hand me the list and I make them as an Analyst edit, marked and dated as yours.
          IMPACT: faster, but §0 puts THIS document in your seat and a correction I write into
          it is the Analyst editing the architect's work — which is the thing I flagged before
          filing AI-1 and would rather not do by default.

### ⚠ AND THREE THAT ARE BATTLEWRATH'S, which the inbox routes through you

    F1  ★★★ R2 and RI-23 point OPPOSITE WAYS, two days apart, both his. R2 (2026-08-21) puts the
        gate on every record — `MapID:RID:BID:CID:stage:step`. RI-23 (2026-08-19) retired exactly
        that repetition: model row 4, *"NODE FIELDS APPEAR ONCE. Eleven fields previously repeated
        per row and could disagree with themselves."* Cost if R2 stands: `Contract.BEHAVIOUR` gains
        two fields and every fixture row moves.
    F2  C1 — accept the window, or sequence the duplicate refusal before the manager is built?
    F3  ✅ **WITHDRAWN — Battlewrath answered it directly on 2026-08-21, before this item was
        read.** *"This is known. We're still in development and this has yet to be wired in.
        Interface work is needed first onto the ace method, fixing the style / grammer to be WA
        coded. And then giving each a settled home."* ⟶ E-0 is a SEQUENCE POSITION, not a
        disconnect; the audit's entry is reclassified and the Analyst's "outranks everything else"
        framing is withdrawn as a severity call that was not the Analyst's to make.
        ~~E-0: `object.lua` writes ZERO rows
        (it never calls `Routes.SetRow`, which has no product caller), and `bucket.lua:207-221`
        reads rows with NO fallback. **A node authored today arms with no behaviour at all.** The
        two halves of the product do not connect, whatever else lands. Does that reorder the build?

⚠ **IMPACT if AI-2 goes unanswered:** I proceed on B and E, which is real work and does not
collide — but the manager's acceptance stays written against a guarantee nothing enforces, and
§6 keeps two closed gaps that are open.


---


</details>





## AI-1 RESOLVED (architect, 2026-08-21) · the tray guarantees one beacon per stage; three doors still accept a second

**⟶ OUTCOME IN `ARCHITECT_LOG.md` AL-8.** YES, and the guarantee has TWO sides: the picker is the
AUTHOR-TIME half, `Bucket.Build`'s named refusal is the RUNTIME half — so **the window the Analyst
named closes AT LOAD rather than at A10.3e**, and the manager never meets a duplicate whether or not
the pickers have landed. An imported pre-slot route meets the same refusal.

    LANDED   `driver_manager_acceptance.md` A12.2b   Analyst, written
             `driver_authoring_acceptance.md` A2.10   the sentence, written
             `Bucket.Build`'s refusal list            bench, OWED — one named reason

<details><summary>THE ITEM AS FILED</summary>

**THE CONFLICT, one sentence:** AL-4 makes one-beacon-per-stage a property of CONSTRUCTION and hands
the Route Manager *"one anchor per stage for free"* — but the pickers that would construct it are not
built, and the three doors that mint a stage today all accept a duplicate.

**WHAT IS**

    promoter.lua:530-537   `stageBox`, free text, deliberately NOT SetNumeric
                           (*"4.1 is the whole point of the field existing"*)
    routes.lua:432-436     `AddBeacon(id, node, stage)` — `want` passes through unchecked
    routes.lua:1483-1489   `SetStage` — a bare `tonumber`
    driver_data_model.md   row 9 says so in as many words: *"the guard arrives with the pickers
                           (A10.3e), and until then the rule is a ruling with no enforcement"*
    architecture §3a       **Pickers (stage / ordinal doors) — status ✗**

**WHAT SHOULD BE**

    ARCHITECT_LOG AL-4     *"no shift, no renumber; duplicates cannot be authored"* ·
                           *"dissolves RI-41 / G6 and A2.3 by construction"* ·
                           *"the manager's bucket gets one anchor per stage for free"*
    architecture §4 (R7)   *"no duplicates by construction (model §1 SLOTS · A2.10)"*

**MEASURED, so the size is not guessed:** across all 12 scraped stores, **6 carry stages and NONE
carries a duplicate** — every one is `[1, 2, 3]`. ⟶ The conflict is real in the TYPE and **empty in
the DATA today.**

**THE ANALYST'S READ (mine, marked):** the guarantee is sound and the exposure is a WINDOW, not a
defect — the doors close when A10.3e lands, and nothing yet consumes the guarantee because the Route
Manager is ✗. ⟶ **Absent an answer I would grade the Route Manager against the guarantee and note in
its acceptance that the guarantee is unenforced until A10.3e**, rather than ask the bench to add an
interim refusal — which would also cut against tell-and-trust.

**FLATTENED, one yes/no:**

> **Is A10.3e (the pickers) a PRECONDITION of the Route Manager relying on one-anchor-per-stage —
> so the manager may assume it and its acceptance cites A10.3e as the guard?**

    YES   the manager is written to the guarantee, and A10.3e is named as what makes it true.
    NO    the manager must tolerate a duplicate stage at run time — which reopens RI-41 and makes
          the tray an authoring convenience rather than a structural guarantee.

⚠ **Why this is the architect's and not mine:** it decides whether a DIRECTION may be relied on
before the thing that enforces it exists.

★ **The architect answered better than the item asked** — neither branch, because a third guard
already existed in the part that has one.

</details>
