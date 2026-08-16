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

## ★★★ We are the product, not the thing authored inside one

> *"The everyman when it comes to code. That's true when a user can input into it. But the whole
> project is a full-code project. So we're not limited in our capability by everyman principle.
> That was true for Weakauras, as the product around them was already programmed."*

★★★ **A WeakAura must stay modifiable in WA's own UI**, because the user authors *inside*
WeakAuras. ⚠ But WeakAuras itself — the product around the aura — was written by people who were
not limited by that at all. **We are that outer product.**

| | |
|---|---|
| **what everyman governs** | what we EXPOSE — the panes, the routes people run, and the rule that a slash command you must already know is not a surface |
| **what it does NOT govern** | how we BUILD. There is no user-authoring layer in our Lua, so a gesture, a custom widget or a computed layout locks nobody out of anything |

⚠ **The failure this prevents** is refusing a capable implementation on everyman grounds when the
everyman never touches it. ★ *Can they find it* stays a real question — discoverability is not
the same argument, and it is the one that actually applies to a gesture nothing on screen teaches.

---

## ★★★ We read the game; the game does not notify us

> *"They read the game state to trigger these auras. Where we tell a system to read the game in
> the absence of triggers or permission."*

★★★ **This is the difference between this addon and every aura on the client**, and it explains
the two things that are otherwise odd about it. A WeakAura is DECLARATIVE — *when this is true,
show this* — against events the client already emits. It never needs turning on.

**We have no event to declare against.** So:

| | |
|---|---|
| **a run is ARMED by a person** | nothing else is going to say when it began |
| **the pin exists at all** | the client is silent exactly where the moment matters |

★★ Which is why `arm` is in our control vocabulary and in none of the eleven forms the client's
own options UI uses. ⚠ **It is not a richer vocabulary. It is the shape of a tool that reads
rather than one that is told.**

⚠ **And the arms on the authoring panes are a different thing** — `object.move`, `object.pick`,
peek, latch, play hold state open *because of how they were built*: *"that's how we made it, not
that it's optimal. But it works for us. Keep things static until you want to move it."* A
defensible principle, and not evidence for anything.

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

## ★★★ The control vocabulary — usage is a SUMMARY

**A control is described by three things. `usage` is the word that summarises them.**

> *"It's there where usage helps. It's a summary of actions. What it does in descriptor terms."*

| | |
|---|---|
| **act** | how you operate it — press · tick · dropdown · drag · type |
| **response** | what happens when you do. **instant** or **delayed** |
| **outcome** | when the result completes. **instant** or **delayed** |

★★★ **This is why the earlier attempts kept collapsing.** The words were asserted as categories
and argued over; they had no definitions underneath them. Decomposed, each one is a *triple*, and
an argument about which box a control belongs in becomes a reading of its three parts.

### The summaries

| usage | act | response | outcome |
|---|---|---|---|
| **action** | press | instant | **instant** |
| **arm** | press or tick | instant | **delayed** — holds open until a further act, or until turned off |
| **selection** | tick · dropdown · drag | instant | instant — one choice of many |
| **input** | type | instant | produces a VALUE. `free` annotates · `identifying` becomes a key |
| **readout** | — | — | **responsive** — reports, and its text changes with state. No interaction |
| **label** | — | — | **static** — a descriptor or cue for what something is. No interaction |
| **icon** | — | — | identity and language. No interaction |

★★ **The outcome is what separates an arm from an action**, and his two worked examples are the
definition:

> *"Remote arm: Act: Press the button. Duration: Instant (Consume name, start capture). Outcome:
> Delayed (Once turned off again.)"*

> *"Object.move: Act: tick select. Response: Instant (You can now move the object). Outcome:
> Delayed. Holds open until you turn off."*

⚠ Both RESPOND instantly. Neither is finished. That is the whole distinction, and it is why
*"does nothing visible"* was the wrong test — `remote.arm` visibly starts recording and is still
an arm, because the outcome is not done until it is turned off.

### Label and readout — the line between them is STATIC

> *"A readout is responsive/reactive and informational. I would imagine labels are static in what
> they display."* · *"A label should be static. It's a descriptor or cue for what something is."*

★ **The test is mechanical**: does anything call `SetText` on it after build? Source-checkable, no
judgement — and it cuts across the pane titles rather than along them. Four panes name THEMSELVES
(Curation · Promotion · Dungeon run · Map controls) and are labels; two name WHAT THEY ARE SHOWING
(the run, the subject) and are readouts.

★★★ **AND THE RULE FOR WHAT COMES NEXT:**

> *"If it informs decision making, it belongs in the readout box we'll be making in the footer
> space."*

So text does not get scattered across a surface as it is needed. A cue for what a field IS stays
beside the field; anything a person WEIGHS goes to one place. ⚠ Left at that deliberately — the UI
side is going to be redone, and a taxonomy built now would be built against a surface that is
about to change.

### ⚠ And what is NOT a usage

**Navigation is an OUTCOME, not a usage.** It decomposes exactly like anything else:

> *"Action: Press. Response time: Instant. Outcome: Move the pan by amount."*

★ Which is already carried by the `does` slot. Same for FILTER vs GENERATE — that is a question
about the SURFACE, answered by its model, not a property of a control.

⚠ **I had both as usages**, which is how a taxonomy grows: a real distinction gets noticed and
filed in the nearest available slot rather than its own. The test that catches it — *is this how
you operate it, or what it produces?*

---

## ★★★ Compactness and presentation are different jobs

> *"The remote is more compact by nature. UI's that claim space prefer presentation over
> compactness. Title labels and dividers. Zone designation over discreet text."*

★★★ **So the Remote's 16px inset and everybody else's 18 is not an inconsistency to reconcile.**
It is the consequence of what each surface IS. A gate is small and every pixel it takes is a
pixel it did not need; a surface that has already claimed a third of the screen owes the reader
structure in return for the space.

| | |
|---|---|
| **compact** | the Remote. Tighter inset, no dividers, no zone headings. It is a gate |
| **presenting** | Map · Curation · Promotion · Object. Wider inset, title labels, dividers, and **zones designated** rather than each field carrying its own small grey word |

⚠ **ZONE DESIGNATION OVER DISCREET TEXT** is the part with teeth. The presenting panes currently
name a field with a label beside it — *"stage"*, *"behaviour"*, *"on success"*, *"detect"* — which
is the compact answer applied to a surface that is not compact. A zone says it once, with a
heading and a divider, for everything inside it.

★ Which also answers the six labels banked earlier: they are not waiting for a word in the
vocabulary, they are waiting to be REPLACED by the zone they sit in.

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
| **how the client's own UI does it** | `planning/reference/weakauras_idioms.md` — WeakAuras' idioms, read from sight |
| **the chronology** | `dungeonrun_poc.md` — the archive |
| **notes, export, import, sharing** | `satnav_ledger.md` |
| **what the debug suite owes** | `debug_suite_plan.md` |

---

## Hopes and dreams

*Not technical. What this document should eventually hold, and the backlog to realise it. Every
surface file carries one of these; the model was the last factual file without one.*

### The seven slots — the programmatic form of `usage`

> *"Act : Response type : Response time : Has effect : Duration of effect : Exit of effect :
> Outcome — might be the programmatic question to the discussion."*

**Three words are what a human reads on a row. Seven questions are what a machine would ask to
derive one.** Same relation as model → inventory: the summary is what you read, the decomposition
is what makes it checkable.

Two of the seven earn their place immediately, because they carry distinctions the current scheme
flattens into prose:

**⚠ EXIT OF EFFECT.** All six arms tag identically today, and they end four different ways:

    editor.peek     release
    editor.latch    a second act on the same control
    remote.arm      a stop act ELSEWHERE
    editor.play     exhaustion — it runs off the end of the window

That is currently living in the `does` sentence, which no tool can read.

**HAS EFFECT.** Separates readouts and icons by a stated fact rather than by an em-dash that means
*nothing to say here*. A `—` is the absence of an answer; `has effect: no` is an answer.

The other five collapse into what we have — act stays act, response type and response time are the
`response` half, duration and outcome are the `outcome` half.

### A third kind of text — banked, not settled

> *"They're not labels. They're self descriptions of the buttons."* · *"Bank it. It's asking me to
> describe a theoretical at the moment."*

Two lines in Curation sit between `label` and `readout` and are neither:

    editor.width   "window 18:29  of  0:00 - 18:29"   what the halve/double pair has the width set to
    editor.skip    "skip 110s"                        what one press of a step button will move

★ Each reports **its own control's current setting**. Not an identity, because it changes with use;
not a readout, because nobody weighs it against anything — it is the button describing itself.

⚠ **Left unnamed on purpose.** A word here would be invented rather than observed, and there are
two of them — too thin a basis for a category, and the UI redo may remove the need entirely.
★ The same question is open for `editor.width` itself: *"I don't know what editor.width is"* —
whether the line belongs on the surface at all is upstream of what to call it.

### The four identity displays — held, not applied

    map.title              the run name              tagged readout
    object.title           the subject               tagged readout
    promoter.name.current  the route                 tagged readout
    map.floor              which floor is selected   tagged readout

> *"The display box is reactive. But it's from a single source. What it was named as on creation.
> So it's a identity lable being displayed."* · *"And it's in the context of being the selection
> from the drop down selector."* · *"Things like floor is a lable."*

★ Which makes the §135 test necessary but not sufficient: `SetText`-after-build catches *does the
text change*, not *whose change it is*. For these four the change belongs to the SELECTOR — the
dropdown above, or prev/next either side — and the text itself is an identity fixed at creation.

⚠ **HELD RATHER THAN APPLIED**, at his word. The rows still read `readout`. ★ And the reason is
process, not doubt: *"A bit of overwhelm at the moment. Broad topics with no clear examples and
then being asked to make a ruling on them."* The rulings were arriving as categories rather than
as things on a screen. This waits for the UI redo, where the instance can be pointed at.

### Gesture — banked, and it may replace some of this

> *"It might be we find better forms. Such as gesture (hold vs tap) and such. We just haven't
> gotten into that."*

★ **`act` currently reads `press · tick · dropdown · drag · type`, and `press` is doing two jobs.**
The evidence is already in the inventory:

    editor.peek    press and HOLD - the view opens while the button is down
    remote.arm     TAP - press once, and the capture runs until a second tap

Both tag `arm` today because both have a delayed outcome. ⚠ But the outcome is delayed for two
different reasons, and *hold* versus *tap* names that where *arm* only records the consequence.

⚠⚠ **Not pursued, deliberately.** Two instances is where the last category was banked for being
too thin, and the same applies here. It is written down so that when a third arrives it is
recognised as the same question rather than met fresh.

### What would make it real

★ **When rows are GENERATED rather than authored.** Seven slots hand-typed across 79 rows is a
maintenance tax with no reader; seven slots emitted from a registration is a queryable surface.
The trigger is the registration score reaching the point where the registry, not this document,
is the thing that knows what exists.

★ **And then a syntax.** His shape for it: `devlog/vocabulary/` carries the VALID OPTIONS for each
slot — the enumerated values `exit` may take, what `response type` ranges over — so the slots are
a grammar and not seven free-text fields. Devlog is surface-scoped today; the vocabulary is the
one thing that is cross-surface and still develops, which is what would justify the folder.

⚠ Until then the three-word summary stands, and this section is the reason it is a summary rather
than the whole answer.

