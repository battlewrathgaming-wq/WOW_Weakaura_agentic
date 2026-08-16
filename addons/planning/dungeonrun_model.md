# DungeonRun — the model

★★★ **THE HEADING. The companion to the inventory.** Everything below says what these things
**are**. `dungeonrun_interface_inventory.md` says what exists to work them, and each surface exists
so **this model can be realized**.

    model         what these things ARE                     ⬅ here
      ↓
    inventory     what exists, per surface                  interface/<surface>.md
      ↓ hopes     what a surface still needs to serve the model, at its foot
    devlog        why it is, and how it got argued           interface/devlog/

⚠ **Nothing here is a build note.** The chronology lives in `dungeonrun_poc.md`, which is the
archive — routed to by kind, not read through.

---

## The mission

**A route is EMITTED from play, not placed by hand.**

> *"The capture start to finish in a simple dungeon will self-report the map handling."*

★★★ That one line retires floors and dungeon textures as **design** work. We do not model floors.
We capture a run through a multi-floor dungeon and **read what came back** — emit, then look.

**A dungeon route IS a sequence of pulls, so the pulls are the route.**

### ★★ We build the instrument, not the expertise

> *"We're not trying to solve the authoring for them. That takes insight. Experience with the
> encounters — or lessons learned, and this is their tool for learning."*

⚠ **Held lightly.** His own instruction: *"we'll refine it as we go… just don't over-harden to be
over-confident."* The answer to *what is this* has already moved three times, each move from play
rather than from thinking harder — a capture POC, then one that had to be **displayed**, then
**curated**, then used by a player who is also a **sensor**. ★ Expect a fifth, and the thing that
moves it will be a run the model has no room for.

★★★ **The boundary, drawn from five directions and always the same line:** we hold **what
happened**, and hand over the means to see it. Never learn dungeons. Hold no roster and no list of
anything the user owns. Never become a heatmap. Curation edits the view, never the capture.
⚠ **Anything that starts telling the user what a good route IS has crossed it — and it will look
like helpfulness on the way over.**

★ **Which is also why we record richly.** The old reason was ours: a richer file is one where we
can find our own mistakes. The better reason is the user's — **the learner does not yet know what
will matter**, so filtering at capture decides for them before they have had the run that would
have taught them.

---

## Capture is the only spawn

> *"The only basis we have to spawn is to capture. So we capture. Then promote into their lanes."*

★★★ **Nothing is created from nothing.**

| how a point enters | |
|---|---|
| **passively** | travel legs sampled once a second, combat start and end |
| **deliberately** | a pin dropped where you stand — still a capture, because you are standing there |

**So every point came from someone actually BEING somewhere.** A derived point is a position nobody
ever stood at.

⚠ **The gate is on ORIGIN, not on POSITION.** This once read *"no free-hand placement anywhere,
ever"*, which claimed more than was meant and would have banned dragging during editing.

> *"Users dragging beacons everywhere is improper - but user choice. We give them tools to do it
> well. But we don't gate them."*

★ A beacon must **come from** a capture; where you move it afterwards is yours.

---

## Two lanes, chosen at promotion

| lane | lives | shape | lifecycle |
|---|---|---|---|
| **"for me"** | on the **MAP** | a persistent personal marker + note | **outlives every route.** Route replacement cannot touch it |
| **"for a run"** | in the **ROUTE** | an ordered sequence of beacons and notes | exportable; **replaced wholesale on import** |

★ The lane answers questions that were being asked separately. *"Stand here for battle horn"* is
**for me** — map-anchored, so it survives any route ever imported.

---

## ★★★ A beacon is a THEATRE, not a point

> *"I pick a location, but really I'm interested in the theatre space. So I then drag it out the
> direct way… Then I inspect each data sample for what children I need and where."*

**You are not marking a spot. You are claiming a scene, then annotating inside it.**

### The anchor's demotion

> *"Now the beacon / anchor is just that. It is the logical grouping of every condition and state
> driver under it."*

★ It shed exactly three jobs, and the child vocabulary already covered all three: the radius is
**draw**, the waypoint is **place**, the note is **print**.

⚠⚠ **So the anchor's own position is a LABEL POSITION, not a fact.** You drag it clear precisely so
it stops covering the sample you are about to inspect — and **nothing downstream may consume it**.
★ A mint kicks it to one side, because spawning on top of the node buries the first sample you
want to look at.

### Children are sample-sourced, and absolute

A child takes its **full x/y/z from any sample on the loaded map** — not the parent's z, not an
offset from it.

> *"A beacon that on 1 plane detects when a user is in wanted distance, to then show a jump
> location on a ledge where that ledge has been detected, stops one design intent from needing to
> become 2 beacons with separate detectors."*

★★ **That is the rule-vs-capability distinction.** Requiring one beacon per position would be a
rule we invented; letting a child carry its own position is a capability, and it removes the
tension rather than legislating around it.

---

## What a beacon ANSWERS

★★★ **Three answers, and with children it offloads each one INDEPENDENTLY.**

| | |
|---|---|
| **on-ramp** | *come find me* — where the player joins this stage |
| **note** | *give this to the player* |
| **ratchet** | *done when found* — the stage advances |

★ A bare beacon with no children gives all three itself. That is why **the anchor is its own
satisfier when it is childless** — and, with children and none flagged, it is **not**: the author
offloaded the job and has not finished, which is exactly what an unrunnable route is.

---

## The stage, and the ratchet

**A checkpoint is a cheap beacon**, and the whole of what one is is the **outcome of satisfaction**.

    complete    index = max(index, outcome)     the RATCHET — nothing walks it backwards
    set         index = N                       an assignment, and only `if unseen`

⚠ **`set` is the one role that stays exclusive**, and for a reason the others do not have: two
assignments in one theatre have **no defined result**, not merely an unclear one. Two
stage-completes are legal — any child satisfies — and refusing one would be grading the author.

★ **The stage is set at the mint through a ghosted field** showing the next free round number, and
it walks gaps. You can type your own, including a **4.1 between 4 and 5** — inserting detail must
never renumber anything.

★★ **No validation on authoring.** Duplicate stages, out-of-order stages and fractions are all
legal. The author is **told** — a match count, a gaps line, a running order sorted by stage value —
and then trusted. ⚠ Refusing would be grading the work.

---

## The three surfaces, three questions

| surface | the question it answers |
|---|---|
| **the map** | *what is this?* |
| **curation** | *what am I looking at?* |
| **promotion** | *what should this become?* |
| **the object pane** | *what is this one thing, exactly?* |

★ And the editor's product is **comprehension**, not a route. The route is what falls out of
understanding the run.

---

## What is deliberately absent

⚠ Written down because absence is a decision, and an undocumented absence gets "fixed" by the next
person:

- **No dungeon knowledge.** No floor plans, no boss rosters, no supported-dungeons list.
- **No heatmap**, no aggregation across users, no scoring.
- **No judgement of a route.** Not *"you missed one"*, not a completion count.
- **No capture-time filtering.** The truthful view is quietened downstream, reversibly.
- **No consumer.** ⚠ §113 removed the driver and the walk: **the recorder records.** A route
  runner is a separate addon with its own remote, and the test suite is its own bounded activity.

---

## Where the rest lives

| | |
|---|---|
| **what exists to work this** | `dungeonrun_interface_inventory.md` → `interface/<surface>.md` |
| **why a surface is the way it is** | `interface/devlog/<surface>/<feature>.md` |
| **the chronology** | `dungeonrun_poc.md` — the archive |
| **notes, export, import, sharing** | `satnav_ledger.md` |
| **what the debug suite owes** | `debug_suite_plan.md` |
