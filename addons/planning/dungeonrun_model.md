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

## ★★★ The addon occupies only what the user opens

> *"We want our addon to be non-invasive. Provide the minimal functionality to get them started.
> And let UI occupation and invasiveness be driven directly by the user."*

★★ **A rule the addon has been following without ever having been stated.** Every one of these
was decided separately, and they are the same rule:

| | |
|---|---|
| the Remote is a **gate**, and opens only the Map | nothing else appears until you choose it |
| mouse-wheel zoom and right-drag **default OFF** | the wheel belongs to the world camera and right-drag to camera-look |
| the note is **PULLED on hover**, never announced | no toast, no proximity chatter |
| point facts are a **tooltip**, not a panel | hovering answers; nothing broadcasts |
| panes open from **panes**, never from events | the addon does not decide it is time for you to look at something |
| the test line is **blank until asked** | a caveat printed permanently is a caveat people learn to read past |

★★★ **THE ENTRY IS A SURFACE, NOT A COMMAND.**

> *"A user shouldn't have to know every command or macro access we create. That's power user
> space."*

⚠ A slash command you have to already know is not a surface. So a capability reachable ONLY by
typing is, by that fact, unavailable to most users — which is a thing to decide deliberately, not
to arrive at because a button was never added. ★ The slash surface is the power path and it earns
its place; it does not substitute for a door.

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

### ★★★ And a run is a SURFACE READ

> *"The Run data collection is a surface read (Basis of where a play can stand, because they
> have)."*

**We are not recording a path. We are recording where a player CAN stand — proven by one having
stood there.** ★ Which is why the sampler runs once a second regardless of what is happening:
every sample is evidence of standability, and a boring one is as much evidence as an interesting
one. It is also the sharper reason to record richly — the value of a sample is not in the moment
it was taken.

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

## ★★★ Curation is DISTINCTION — and it has two sides

**Valuation, across runs.** Naming and commenting are not conveniences, they are the curation:

> *"That is you curating that run. Assigning value. Out of 10 runs, 2 might represent the best
> runs. […] This lets you rank/value your own performance, and curate runs before you seek to
> extract."*

★ Which is why they are the only part of curation that touches the record — a judgement about a
run is *about* the run, and it has to survive.

**Readability, within a run.** Information becomes noise when distinction cannot be made; and a
run is a **duration**, which cannot be read at once. So filtering and the time window are not
conveniences either — they are how a mass becomes something you can reason about.

★★★ **AND THE CUT BETWEEN CURATION AND MAP CONTROLS IS FILTER vs GENERATE:**

> *"Curation can filter from the data set. Map controls can generate better reading through
> population."*

    Curation       SUBTRACTIVE   which captured data is present
    Map controls   ADDITIVE      draws what the capture never held

★ One question decides where a new control goes: *does it change which captured data is present,
or does it draw something that was never captured?* ⚠ Which is the defence against editing
becoming whack-a-mole across three surfaces.

★★★ **YOU CANNOT REDUCE WHAT YOU CANNOT READ.** Curation is a precondition of Promotion, not a
step beside it:

    curate      value the runs, then frame the one you chose
       ↓
    promote     reduce the framed evidence into a route

---

## ★★★ Promotion is REDUCTION

> *"Promotion is extracting from a single run, allowing inspection of others, and organising
> that into a coherent, reduced data set that becomes a Route."*

**A run is many samples. A route is few beacons.** Promotion is the step that decides which of
the evidence was of value enough to become the basis of an instruction — and the product is
**coherence**, not capture.

★★ **AND THE ROUTE'S FORM IS DICTATED BY ITS CONSUMER, not by the capture.**

> *"A route has to be able to communicate to a player using the route. So this is done as
> Beacons and stages."*

★ That is why a beacon carries the three answers at all. The shape is not a convenient way to
store points — it is the shape of **telling someone what to do next**.

★★★ **A beacon either directly calls a player, or expands into many signals and instructions.**
That is the childless-anchor rule stated as identity rather than as a special case: with no
children it speaks for itself; with children it has delegated speaking.

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

★★★ **STAGE IS STRUCTURAL, BUT ORDINAL.** Every beacon has one, and what it names is a
**position in the sequence**.

> *"It's structural, but ordinal. A stage loses meaning when it can be two things. If 2 stages
> are in type, (1 boss or the other.) 4.0 and 4.1 is preferred before 5."*

⚠⚠ **SO A DUPLICATE COSTS THE STAGE ITS MEANING.** If two beacons both say *stage 4*, then
*stage 4* no longer identifies a position — the ordinal has stopped being ordinal. That is a
real loss, not a neutral one.

★★★ **AND THE FRACTION IS THE INTENDED EXPRESSION.** Two things at nearly the same point in
the run — one boss or the other — are **4.0 and 4.1**, not two 4s. ★ That is what the fractional
insert is FOR, and it is a stronger reason than *inserting detail should never renumber*: the
fraction keeps the ordering total while still saying *these two belong together*.

★★ **No validation on authoring — and it is a COURTESY, not an absence of conflict.** Duplicate
stages, out-of-order stages and fractions are all accepted. ⚠ But a duplicate IS a conflict of
meaning, which is exactly why the match count exists: it is not a neutral readout, it is telling
the author that a stage has stopped being ordinal. We **tell and trust**; we do not refuse, and
we do not pretend the two options are equally good.

---

## ★★★ The map is the primary storytelling space

**Where data becomes legible; where a person recounts moments in time and assigns meaning; and
where events become lessons for the next run.**

★★★ **WE GIVE CONTEXT. THEY DERIVE MEANING.**

> *"We do not derive meaning. We just help give context on it."*

★★ **Information becomes noise when distinction cannot be made** — which is why filtering and
the time window exist at all, and why they change what you SEE and never the record. Distinction
is a reading operation.

⚠ **It ships.** So it is whoever holds it's storytelling space, not ours — a second and
independent reason it never learns a dungeon. Detail and what falls out of it:
`interface/map.md`.

---

## ★★★ The control vocabulary — six usages

**What a control is FOR, as distinct from what widget it is.** Every control row in a surface
file carries a `usage`; `kind` stays the widget, because `panespec.lua` resolves heights from
it and `forms` records the actual `CreateFrame` call.

| usage | |
|---|---|
| **icon** | identity and language. No interaction — it is how a thing is RECOGNISED |
| **readout** | reports. No interaction |
| **action** | **press → response.** The consequence is the press's own, and there is nothing between them |
| **selection** | you CHOOSE. `tick` · `dropdown` · `range` · `arm` |
| **input** | `free` annotates · `identifying` becomes a key |
| **navigation** | moves the VIEW, never the data |

### ★★ Selection is the parent, and `arm` belongs to it

> *"Arm - as selection. It precedes something. For runs it's then the data capture. For object
> drag it's so you can. So both are selections."*

★ An arm is a choice that a FOLLOWING act consumes. `object.move` selects *this object is the
one being dragged*; `remote.arm` selects *this run is the one being captured*.

★★★ **AND THE TEST IS STEPS BETWEEN, NOT SILENCE.** His:

> *"It is a button, that selects the name you picked and starts the run consuming the name.
> So it is a selection. It is an action too - but it has steps between. Where act is
> press-response."*

    action       press → response.  Nothing between them
    arm          press → … → outcome.  Something is bound, and the outcome arrives later

⚠ **So an arm can be perfectly visible and still not be an action.** `remote.arm` obviously
does something — the count starts moving. It is still a selection, because the press CONSUMES
the name you typed and BEGINS a run; the run is what produces the outcome, over time.

★★ **An arm is often where an `input · identifying` gets consumed.** The name is free to change
until the arm binds it. That is a real relationship between two usages and it only became
visible once both had names.

### ⚠⚠ Re-testing all 15 `action` tags — and I bent the rule to protect two

Applying *press → response* to every control already tagged `action` threw up two:

    editor.play    press → the window steps once a second until it runs off the end
    editor.peek    press-and-HOLD → the whole run shows while the button is down

⚠ **I invented a second question to keep them as actions** — *does the press BIND anything?* —
and concluded neither did, so both could stay. His reply:

> *"Press-response already argues against your case. Pressing the play holds open a 15min (sec
> selection) action. And held alters the display until released."*

★★★ **THE RULE ALREADY ANSWERED IT.** Neither is press → response. Play **holds open a
duration**; peek **alters the display until released**. A second discriminator was not needed — I
reached for one because the first one disagreed with tagging I had already done.

**Corrected:**

    editor.play    selection · range    it TRAVERSES the window position, automatically
    editor.peek    selection · tick     a tick you HOLD rather than latch

★★ **And the code already said so.** `editor.latch` exists precisely to make peek persistent — a
latch for a momentary toggle. You do not latch an action. The pair was sitting there the whole
time saying peek is a tick.

⚠ **The failure worth remembering is not the mis-tag, it is the rescue.** When a rule disagreed
with work already done, I extended the rule instead of redoing the work. See
[[dont-extend-past-the-evidence]].

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
