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

## ★★★ THE WALK — the model watched running, and the check we did not have

> *"I was thinking 'walk' could be a literal sprite on the map walking through the supertracker
> way points. And showing a record of what triggered as a timeline."*

    a sprite    walks the route through its waypoints, on the map
    a timeline  a record of WHAT TRIGGERED, in the order it fired

★★★ **AND THIS IS THE MISSING CHECK.** The model already records the cost of owning our own
trigger space: *"a wrong WeakAuras trigger is a wrong reading of a TRUE VALUE, and the game keeps
correcting it. A wrong trigger of OURS is a wrong MODEL, and nothing outside us disagrees."*
**A walk is the disagreement.** You watch the route run and see whether it does what you meant —
which is the only external check available to a system whose triggers are its own.

★★ **And the timeline is an EMISSION, not an interpretation.** It reports what fired, in order,
rather than explaining what should have. That is the bench's own law and it is why the walk can be
trusted as evidence: it has no opinion.

### ★★★ AND THE SPRITE CAN WALK A RUN'S DATA — which makes it a ROUTE TEST

> *"The sprite can walk a run's data. So then you can route test if your detectors are positioned
> where many player paths converge with a route."*

★★★ **The route is what you MEANT; a run is where somebody actually WENT.** Walk the sprite along
a run, against the route's detectors, and you find out whether they fire for a path that is not
yours. Do it across several runs and the question becomes the real one: **are the detectors where
the paths CONVERGE, or only where I happened to walk?**

★★ **Which is the failure mode of a shared route, and nothing else we have can see it.** A route
authored from one run is tested by that run by construction — every detector sits on the path it
was drawn from. The first person to take a slightly different line is the first test, and by then
it is their problem.

⚠⚠ **AND IT REVALUES THE RUNS WE ALREADY DISCARD.** Curation ranks runs and *"out of 10 runs, 2
might represent the best."* This says the other eight are not waste — **they are the adversarial
corpus.** The messy run is the most useful one for this, because it is the one that does not
follow the intended line.

### ⚠⚠ IT RUNS IN-GAME, PACED BY `play` — and offline would be a SECOND IMPLEMENTATION

> *"It'd have to run in-game. Which is where the play function comes in. Then it's a paced
> equation on timescale update."*

★ I had written this up as an offline calculation — *"route coverage becomes a bench number"* —
on the grounds that a position against a reach is arithmetic. **It is arithmetic, and that is not
the point.**

★★★ **AN OFFLINE VERSION WOULD RE-IMPLEMENT THE TRIGGER LOGIC.** Reach, the asymmetric band,
`unseen`, the live stage, a role already satisfied — evaluating those outside the addon means a
SECOND EVALUATOR that must agree with the first, with nothing noticing when they stop. That is
the drift this bench refuses everywhere else, and I proposed it here without seeing it.

★★ **In-game, the REAL evaluator is what runs.** The route's own detection code, the real stage
machine, the real reach — fed a RECORDED position stream instead of the player's. ⚠ Nothing is
modelled; the thing itself is exercised, and that is the only reason the result means anything.

★★★ **AND `play` IS ALREADY THE PACER.** It exists, it steps the window through time until it runs
off the end, and Curation is built around it. **The walk is `play` with a different subject** —
the same clock driving a position instead of a window. *"A paced equation on timescale update."*

★ Same shape as §172: **we own both ends, so we do not simulate — we feed the real thing a
different input.** There, package and unpackage are both ours so the round trip is real. Here, the
evaluator is ours so the walk is real.

### ★★★ AND IT IS AN ADDON FEATURE, NOT AN INSTRUMENT

> *"This is a addon feature. They don't have our bench."*

⚠ I finished the last correction with *"landed as a record, read on the bench"* — which is how WE
would use it and has nothing to do with the person it is for. **A route author has no pull script,
no records folder, no Python and no `COA_DevDump`.** Everything the walk produces has to be
readable inside the addon or it does not exist.

★★ **Which inverts what I kept reaching for.** I twice tried to reduce the walk to a NUMBER,
because a number suits a bench. **For the user the walk IS the interface** — you watch the sprite
take a line you did not take and see the detector it misses. The count is the summary of that, not
a substitute for it.

★ Which is the shape settled twice already today: **summary at the glance, decomposition on
demand.** The count belongs on the face; the walk is the inspection. And *concise over verbose*
sets the bar for the count.

**What survives:**

- **The corpus already exists for US** — RFC 2 runs (99, 232 legs), SFK 2 runs (315, 698). Four
  real paths, nothing new to capture, so the feature can be built against real data from day one.
- **The count is still the right summary** — how many of N runs each detector fired for. A
  detector that fires for 1 of 4 is on *your* path, not *a* path. ⚠ Shown IN THE ADDON.

### ★★★ THE ROUTE TRAVELS; THE RUNS STAY HOME — and that is sufficient

> *"You watch it on runs you've completed. On routes you've made or imported. All of this is the
> addon giving A user the ability to test and validate their route from within the editor."*

⚠ I had just raised this as an open question — *the adversarial corpus is other people's runs, so
either runs travel too or the test is limited to one player.* **Wrong, and from the direction I
did not look.**

★★★ **AN IMPORTED ROUTE WALKED AGAINST YOUR OWN RUNS IS ALREADY THE CROSS-PERSON TEST.** The route
came from somebody else; the paths are yours. Two people's data meets — **and only one of the two
ever had to move.**

    your route      × your runs      does it work for how I actually walk
    their route     × your runs      does THEIR route work for how I walk

★★ So runs never need to travel, and the 317KB payload problem never arrives. **The pairing that
matters is `this route × these paths`, and importing a route makes one half foreign for free.**

★ **And the scope is one user, in the editor.** Not a community data pool, not a shared corpus —
*"the addon giving A user the ability to test and validate their route from within the editor."*
Everything above stays inside one person's client.

⚠ **One correctness note, and the data already solves it.** A run is SAMPLED, so a detector can be
passed between two samples and never appear to fire. **The store holds LEGS, not just points** —
segments — so the test is segment-against-reach, not point-against-reach. ★ Had we stored points
only, this idea would need a re-capture; it does not.

⚠ **THIS IS THE ARC §113 CUT IT FOR.** `walk.lua` was removed absolutely — *"that all comes in the
driver / debugging side. And if we want a audit green light on a run. It gets named and designed.
Not smuggled in."* ★ It is being named and designed. The removal is what made that possible: there
was nothing half-formed left to build on.

---

## ★★★ We inform. We do not act for the player.

> *"Even if capable, we might wipe /cast off the table. That might fall into bot behaviour.
> Automated gameplay."*

★★★ **This settles the question without the capability answer**, and that is the point worth
noticing: I had a ☐ open to find out whether the client permits a cast from Lua. It is moot. **A
thing we would not ship does not need to be possible.**

**The line:**

| | |
|---|---|
| **ours** | anything that changes what the player KNOWS — a marker, the tracker, a readout, a route |
| **not ours** | anything that performs a gameplay input on their behalf |

★★ **The test for any proposed action:** does it act in the WORLD, or does it act on the player's
UNDERSTANDING? A supertracker arrow is understanding. A cast is the world. ⚠ And an addon that
plays for you is a bot however good its reasons — which is a rule about what this tool IS, not a
rule about servers.

⚠ **The nearest edge is the announce, and it is worth naming rather than leaving to be discovered.**
Chat is the addon SPEAKING IN THE PLAYER'S NAME. Established practice on this client — boss mods
and WeakAuras both do it — and still the closest thing we have to the line. ★ It stays on the
right side of it while it DESCRIBES what is happening (*"LOS PULL"*) rather than issuing
instructions to other people as though the player wrote them.

## ★★★ The readout box has TWO LIVES, and the second one decides its design

> *"The readout box doubles as our note boxes later that live on the driver UI."*

★★ The box was defined by what belongs IN it — *"if it informs decision making, it belongs in the
readout box we'll be making in the footer space."* This says what it BECOMES:

| | what it carries | who wrote it |
|---|---|---|
| **authoring** | the running order, counts, matches, gaps — what you weigh before promoting | derived, by us |
| **driving** | the note on the beacon you have reached | **authored, by a stranger** |

★★★ **So it is one component that must hold both derived text and authored text**, and the
second case is the one that constrains it. Three things fall out that would not be obvious from
the authoring side alone:

⚠ **It is the surface where §159's rendering hole actually lands.** A note is the field most
likely to be long, most likely to be read carefully, and most likely to come from someone the
runner has never met. `|c`, `|T` and `|H` close HERE first, or the escaping is decoration.

★★ **It is how a route author speaks to a runner** — and the only sanctioned way. §157 forbids
acting for the player and puts chat on the edge of the line; a note in a box the runner opened is
neither. **The box is the safe channel**, which makes it load-bearing rather than a convenience.

⚠ **CORRECTION — the focus drop-down is NOT a driver control.** I put it on the wrong side.

> *"The drop down focus isn't on the driver side. That's editorial focus instead of the editor
> trying to dictate what is useful right now."*

★★ It is an AUTHORING control, and the word *editorial* is the whole of it: **the human decides
what the box is looking at, instead of the software deciding for them.** Without it the box
follows selection and hover — which is the editor asserting what matters this second. With it,
you pin the box to the thing you are actually working on and go and touch other things.

### ★★★ What it IS: an output-only box that reads what is SENT to it

> *"A text box that is output only, that can read information sent to it."*

★ **A sink with many senders and one display** — which is a pattern this addon already has.
`NS.Tests.Register(key, fn)` on the Object pane is exactly it: *"ONE SURFACE, MANY CONTRIBUTORS —
a REGISTRY, never a line per control."* The readout box is that generalised past one pane.

### ★★★ The two lives are DIFFERENT MACHINES, not one machine at two sizes

> *"On the driver side, you already hold the notes in a sequences body. You reach XYZ when on
> stage 6, then the addon populates the text box. So that's one source showing different text at
> different internal conditions."*

★★★ **ONE SENDER ON THE DRIVER.** The notes are already in the route, in sequence, and the only
thing that changes is which condition is live. ⚠ **So the driver has no ladder problem at all** —
there is nothing to arbitrate between, no sort, no limit, no flagging contest. The whole of the
presentation question is an EDITOR-side question, which halves it.

> *"On the editor side. The box is reacting like a tooltip and like a response readout. Many input
> streams. But user driven by action. So maybe two readout boxes. Editor response and cursor
> events."*

★★ **And the split is already latent in the code**, unnamed as a pair:

    map.readout    a floating panel over the canvas, mouse DISABLED, title + key/value rows
                   -> the CURSOR box. What you are pointing at.
    object.test    §87's one high-contrast line, fed by the ACT: "they're clicking the button,
                   so that can emit the look-up"
                   -> the RESPONSE box. What you just did, and what it produced.

⚠⚠ **And they conflict in one box, which is the argument for two.** Hover is constant and
transient; a response is a record you want to keep reading. Share a box and moving the mouse wipes
the emission — which is precisely the failure §87 built the test line to avoid.

### ⚠ CORRECTION to §159: sanitise at the BOUNDARY, not at the render

> *"Once loaded, I don't think the display notes need the same zero trust. (processing / render
> time concern.)"*

★ Right, and it is better than either of the positions before it. I wrote *"the render is where
they close"* — which pays the cost **once per draw**, forever, on a surface the driver repaints
every stage change.

★★★ **The escape belongs where a document BECOMES data — at import.** Once per route, not once
per frame, and after that the store holds text that is safe by construction and everything
downstream can render it plainly.

⚠ **It holds only while nothing untrusted enters the store by another door.** Import is the door
today. If a second one ever opens — a paste, a party sync, a file drop — it inherits the same
obligation, and that is the thing to notice rather than the escaping itself.

### ★★★ HOVER IDs. CLICK HOLDS, AND HOLDING IS WHAT OPENS AN EDIT SURFACE

> *"Mouse over / tool tip — information that shows just enough to ID and get a understanding of
> it's state. Click to hold — it's edit surfaces."*

| | shows | commits you to |
|---|---|---|
| **hover** | just enough to **identify** it and read its **state** | nothing. Move the mouse and it is gone |
| **click** | the **edit surfaces** | the thing. It is now what you are working on |

★★ **This is a CONTENT rule, and content is what the arrangement was waiting on.** It says what
belongs in the cursor readout without anybody arguing case by case: *identity and state, and
nothing you could change.* The moment a control appears, it is the wrong surface.

### ★★★ Three things converge on it

**1. ⚠ CLICK-TO-HOLD IS NOT THE DROP-DOWN.** I read the two as one intent on surfaces with and
without something to click. They are two jobs: *"the drop down was specific to a stable interface
on the editor to filter the readout box."* ★ **Click-to-hold picks the SUBJECT. The drop-down
filters the readout's CONTENT**, from a persistent surface. Both survive.

**2. IT IS THE CURSOR/RESPONSE SPLIT SEEN FROM THE MAP.** Hover feeds the cursor box; clicking
hands the subject to the edit surfaces and to the response box. Same division, arrived at from a
different direction — which is the useful kind of agreement.

**3. ★★ THE FACE AND THE TOOLTIP ARE THE SAME CONTENT AT TWO DENSITIES.** Object's FACE is *what
it is* — the subject's identity, held while the tabs change. The hover is *what it is*, compressed
to a tooltip. **One source, two renderings**, and that is worth building as one thing: a face that
disagrees with its own tooltip is a bug nobody would ever look for.

⚠ **And it sets a test for the map's hover, which does not have one today.** `map.readout` is a
floating panel of title and four key/value rows, mouse disabled. Whether those four rows are
*identity and state* or whatever fitted is unrecorded — and now checkable against a rule.

### ⚠ THREE OPEN QUESTIONS — his, and not answered here

> *"How do we flag when information is sent. And what is the ladder for presentation. And is the
> read out one note only, or a dynamic rendering space with a divider per note."*

**1. Flagging.** ★ What bears on it: the two lives differ in WHO ASKED.

    authoring   the human asks - hover, select, press. The box ANSWERS.
    driving     the world tells - you arrived. The box ANNOUNCES.

★★ **An answer needs no flag** — you asked it and you are already looking. **An announcement does**
— you were playing. So the flagging problem is only ever about UNSOLICITED information, which is
half the surface it first appears to be.

**2. The ladder.** ⚠ The ranking is taste and is not decided here. But the client has a FORM for
exactly this: a WeakAuras dynamic group is one space that many things want, and its controls are
`Grow` · `Sort` · `Limit` · `Space` · `Stagger`. That is a presentation ladder, already built, in
the idiom users know. ★ And §87 already fixed one rung: **emit on the act, do not catch before**
— warn ahead only when the act is irreversible.

**3. One note or many.** ★ It may not be either/or: **`Limit` is the difference.** Promotion
already runs the crude version — `ORDER_ROWS` lines with a *"… N more"* overflow. One component,
limit 1 where the space is small, limit N where it is not.

⚠⚠ **And the driver's constraint is not just SIZE — it is that information is STAGED.**

> *"The driver UI would be limited in this. But also the information is staged instead of response
> to cursor."*

★★★ Which changes what the box is FOR. Cursor-driven, it holds whatever you are pointing at and
is replaced the moment you point elsewhere. Stage-driven, **arrival is the event** — the note is
there because you reached something, it did not replace an answer to a question, and nobody is
looking at the pane when it lands.

### ★★★ NO INPUT REACHES AN INTERPRETER

> *"This is me thinking about protecting this tool from being used maliciously. So we make any
> input fail at proper programmatic pass through, which forcing it into /say or /party does."*

★★★ **The rule, stated once: text a person supplies reaches a SINK, never a PARSER.** A sink can
display it or transmit it and can do nothing else with it. There is no validator to get past,
because there is nothing on the other side to get to.

⚠ **This matters because a route is a document from a stranger.** Every name, comment, stage and
announce in it was typed by someone the runner has never met, and it arrives as data on their
machine. Three sinks, three rules:

| sink | the rule |
|---|---|
| **chat** | the channel is an ARGUMENT — `SendChatMessage(msg, "SAY")`. ⚠ Never `RunMacroText`, which executes what this one says |
| **execution** | there is none. No `loadstring`, no `RunScript`, no macro executor, at any point in the shipping addon |
| **rendering** | ☐ NOT YET SOLVED — see below |

★★ **Two of the three are true today, and verified rather than assumed.** `COA_DungeonRun` contains
no executor of any kind. `COA_DevDump` has one `loadstring`, and the distinction is the whole
point: it evaluates **an expression the developer typed at a slash command** — input from the
person at the keyboard, never from a document.

⚠⚠ **THE THIRD IS A REAL, PRESENT HOLE.** A WoW `FontString` INTERPRETS what it is given: `|c`
colours, `|T` textures, and `|H…|h` hyperlinks. We pass route and beacon names straight into
`SetText`, several of them inside our own `|cffffd100%s|r` wrappers. **A crafted name in a shared
route can therefore render as a fake item link or an icon**, in a pane the runner trusts. Nothing
executes — but the display lies, which is enough to be used.
☐ Escape or strip `|` sequences on every field that came from a document, at the render.

★ And the guard for all of it is one line rather than a doctrine: **a shipping file that gains an
executor should fail a test**, not rely on a reviewer noticing.

### ★★★ And the announce is consented to, and improper BY CONSTRUCTION

> *"On the driver side. If a route has a /say configured. To tick out of using that input. And
> because it reaches the check box, our input capture for what that is is first programmed
> "/say". So if someone enters "/run" it'd be improper by construction. "/say /run"."*

**Two mechanisms, and they are independent — either alone would be thin.**

★★ **1. THE RUNNER CONSENTS.** A route is a document from a stranger. Its announces are a tick on
the DRIVER side, so a downloaded route can never make you speak. ⚠ Opt-out is the floor; the
question of default-on or default-off is a separate one, and the wheel-zoom ruling says an addon
that takes something nobody offered has taken it.

★★★ **2. THE AUTHOR CANNOT REACH THE COMMAND.** They supply a MESSAGE; the command is ours. Type
`/run` and you get `/say /run` — a person saying the words *"/run"* out loud. Harmless, visible,
and obviously wrong to whoever wrote it. **The wrong thing is not blocked, it is made absurd.**

★ **And on this client it is stronger than a prefix.** `SendChatMessage(message, "SAY")` takes the
channel as an ARGUMENT — there is no slash command anywhere in the send path, so a payload cannot
become one. WeakAuras does exactly this (`WeakAuras.lua`, its chat action). ⚠⚠ **The property
holds only while we never route through a macro executor.** `RunMacroText` would execute what
`SendChatMessage` merely says, and swapping one for the other silently removes the entire
guarantee. That is the line to defend, and it is one call.

★ **Two details worth taking from theirs**: every send is wrapped in `pcall`, and it refuses to
fire at all while the options window is open — nobody announces to a party because you were
editing. Ours is the same rule with different surfaces: no announce while Curation or Promotion
is open.

★ Same family as the addon occupying only what the user opens, and as *provide, never handle*:
three statements of one posture — **the player stays the one playing.**

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

### ★★★ And at playback it inverts: OUR trigger is an internal state

> *"It's why I look to WA as a model. We have the potential to match some use. But the trigger is
> an internal state, where WA can only read the game values."*

★★★ **WeakAuras' trigger space is bounded by what the client exposes** — an aura, a health value,
a cast, a combat-log line. Rich, and entirely borrowed. It cannot trigger on *"the player has
reached beacon 3's detector"* because no such value exists in the game.

**Ours does, because we made it.** `reach` · `unseen` · a live `stage` · a `role` that has already
been satisfied — not one of those is a game value. The client supplies POSITION and nothing else;
every trigger is evaluated against a route we authored and a run state we hold.

| | |
|---|---|
| **capture** | we read the game because nothing notifies us |
| **playback** | we barely read the game at all — position in, and the rest is our own state |

★★ **Which is why matching some of WA's use is realistic while copying its architecture is not.**
The forms transfer — triggers, conditions, an options tree that generates itself. The SOURCE of
truth does not: theirs is the client, ours is a document a player authored.

⚠⚠ **AND THAT IS THE COST, STATED PLAINLY.** A wrong WeakAuras trigger is a wrong reading of a
true value, and the game will keep correcting it. **A wrong trigger of ours is a wrong MODEL, and
nothing outside us disagrees.** There is no external check — which is the whole argument for the
test surface, for user-story walks, and for §87's rule that the pane EMITS what an act actually
produced rather than predicting it.

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

### ★★★ Children ARE the everyman surface

> *"If we was expecting users to program a beacon's behaviour, that's cutting into the everyman.
> The children are that program set broken into everyman access. Triggers and condition setting.
> But the project as a whole isn't limited."*

★★★ **This is why children exist, stated in the terms that decide it.** A beacon's behaviour is a
program. Handed over whole it is a code box, and a code box is the wall — the same wall custom
Lua is inside a WeakAura. **Broken into children it becomes a set of triggers and conditions**,
which is exactly the shape WeakAuras chose for the same reason.

    detect     shape · reach · reach.up · reach.down · unseen    -> the TRIGGER
    condition  role · stage · stage match · ramp                 -> WHEN it applies
    instruct   action · target · outcome                         -> WHAT it does

★★ **So the dropdowns are not a simplification of the real thing — they ARE the real thing**, and
the Object pane is where a program gets written without anyone writing a program. ⚠ Which sets a
hard test for every future beacon feature: **if it can only be expressed as "describe the
behaviour", it is not finished — it has to decompose into a trigger and a condition, or it does
not belong on this surface.**

★ And the boundary is exactly where the previous section put it: the beacon's behaviour surface
is everyman-bound because a user inputs into it. **The addon around it is not.**

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

## ★★★ RUN DATA IS HIDDEN. THE PRODUCT IS NEVER HIDDEN.

> *"On the beacon case. I only ever see that being per-node opaque-ness / transparency, instead of
> a full hide. They're the product on top of the map."*

| | | |
|---|---|---|
| **run data** | leg · combatleg · start · done · dead · pin | **HIDE.** It is raw material, and noise you are trying to see past |
| **the beacon** | beacon | **NEITHER** (§224). Always at full — it is the thing you are placing |
| **its children** | child · note | **FADE**, per child, and the control lives on the beacon |

★★★ **And the reason is not aesthetic.** You fade rather than hide so you can trace the map
underneath *while still seeing what you have already placed*. Hidden, it is not context — it is
absent. ★ Which is why fade is the FLOOR of what the product gets, and the beacon does not even
take that.

⚠⚠ **AND AN INVISIBLE AUTHORED OBJECT INVITES A DUPLICATE.** Hide a beacon and the place it sits
looks empty, so the next act is to mint a second one there. **Fading cannot cause that**, because
the thing is still on screen. ★ A filter over the product is not a smaller version of a filter over
the run; it is a different risk.

★ It also explains why the filter list stops where it does. Curation's six ticks are the run,
**and there was never a seventh for beacons** — not an omission, a category.

### ★★★ THE BEACON IS ALWAYS ON SHOW. THE CHILDREN FADE, FROM THE BEACON.

> *"I plan that the beacon is always on show. Its children can be addressed in the beacon with
> per-child opacity slider. And when you click the beacon it always shows its children at 100%
> visibility."*

    the beacon    ALWAYS visible. No hide, no fade. It is the thing you are placing.
    its children  PER-CHILD opacity, and the control lives ON THE BEACON
    on click      every child of that beacon returns to 100%

★★★ **So opacity is a RESTING state and selection overrides it.** You quieten a beacon's children
to read the map, and the instant you are working on that beacon they are all back. ⚠ Which means
you can never be editing something you cannot see — the gesture that starts the work is the same
one that restores it.

★★ **And it is §177's rule again**: *hover IDs, click holds.* Clicking a beacon holds it, and
holding it means its children come to full. **The same act, one layer down.**

### ★ It also closes the art-key trap completely

⚠ A per-TYPE opacity — *"all beacons at 40%"* — would resolve a kind, and `Map.ArtKey` returns a
beacon's ICON rather than its kind. **Per-CHILD opacity addressed through its parent never
resolves a kind at all**, so the hazard has nowhere to appear. ★ Not avoided by care; **avoided by
the shape of the control.**

### ★★★ AN ICON IS NOT AN IDENTITY CLAIM — THERE IS NO UNIQUENESS IN IT

> *"Icon should never have been an identity claim. As there's no uniqueness."*

**Identity needs uniqueness. Appearance is SHARED, by design.** Two beacons wearing `kill` are not
one thing seen twice — but `Map.ArtKey` returns the icon, so every consumer downstream was asking
a shared attribute to answer a question only a unique one can.

★★ **And that is why it produced SEVERAL faults rather than one.** Five call sites consume the art
key, and exactly one of them is asking about appearance:

    map.lua :922         ArtForPoint   which glyph to draw     ← the only honest consumer
    map.lua :818         hidden[...]   whether you can SEE it
    map.lua :917         Map.Rank      what draws on top — AND WHAT YOU CAN CLICK
    map.lua :1077        LABEL[key]    what the tooltip CALLS it
    map.lua :1164 :1566  TIP_COLOR     what colour it reads as

⚠ **Four identity questions answered by a picture.** The filter escape, the rank tie, the tooltip
name — not three bugs. **One claim, inherited four times.**

★ **`RANK`'s own comment is the proof, because it is a patch:** *"every beacon ICON ranks as a
BEACON"* (`map.lua`:210), `kill = 7` sitting beside `beacon = 7`. That row exists to UNDO the
icon's identity claim, by hand, at one consumer. It was never a ruling about ranking — it was
damage control, and it covers only the consumer it was written for.

### ★★★ THE ICON IS A CHILD'S. THE PALETTE IS OURS.

> *"I think that is now a purely child option. The user can make a system of what each child does.
> We offer the palette."*

    we offer   the VOCABULARY — a curated set of words, not a picker over 3,144
    they mean  what each word says in THEIR system, and we attach no behaviour to the choice

★★ **So the icon must stay UNREADABLE to the code.** If the meaning is the user's, any branch we
write on `icon` is a branch on semantics we do not hold. It selects a crop. Nothing else.

★ **And it did not creep in — it PREDATES children.** `ART` is §61; the child is §83. The icon went
on the beacon because at §61 the beacon was the only authored object there was. `map.lua`:118 still
carries the reasoning, and the reasoning is right: *"a beacon is not reporting a state — it is an
INSTRUCTION, so its iconography carries the meaning."* ★★ **The instruction is the CHILD now**
(*"the children are that program set broken into everyman access"*), so the icon follows the
instruction to where the instruction went.

⚠⚠ **THE CONDITION IT SHIPS UNDER, and it is not optional.** `Map.Rank` resolves *through*
`Map.ArtKey` (`map.lua`:917), so a child wearing an icon inherits that icon's rank:

    child = 8        beacon = 7        kill = 7

`AddChildHere` mints a child at EXACTLY its beacon's position. Give it `kill` and it drops 8 → 7,
ties with the thing it is sitting on, and a tie falls to list order — *"the exact fault the ladder
prevents, in the one place nobody would look"* (`map.lua`:211). Its un-iconed siblings stay at 8
and stay clickable. ★★★ **So within one group some children are selectable and some are not,
decided by whether the user picked a picture** — and it would read as the icon breaking them.

**The split: art answers what you LOOK LIKE, rank answers what you ARE.** A child ranks as a child
whatever it wears. ★ Which also retires the beacon branch outright: with no icon on it, a beacon
always answers `beacon`, and §222's filter is exact by construction rather than by luck.

### ★★ AND THE BEACON'S TAB 1 BECOMES THE CHILD ROSTER

> *"when a beacon gains a child, its tab 1 controls for behaviour is swapped with a child tab.
> Showing each by name. And then an opacity slider per."*

★ **Coherent for a reason already in the model:** the special child IS the beacon's behaviour
(§219 — one per group, first by ordinal). So a beacon with a child was carrying a tab 1 that
duplicated child 1. **The swap replaces a duplicate with the thing you need at that moment** —
which children exist, and how loud each one is. Name plus slider per row is the whole tab.

⚠ And it is where §224's per-child opacity LIVES: addressed from the beacon, one row per child.
**Per-node, never per-kind** — which is what keeps the art key out of it entirely.

★★ **ANSWERED, not banked (§225).** The icon renders with no authoring path — `ART.kill`,
`RANK.kill = 7` and the `ArtKey` branch all exist and nothing assigns `point.icon`. *"I'm not even
sure where that system crept in."* It crept in by predating children, and it leaves by following
the instruction to them. See the two sections above.

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
| **the timed breakdown, scoped** | `planning/timed_breakdown_scope.md` — the log join: store while they race, attribute after |
| **the overhaul, scoped** | `planning/ui_overhaul_scope.md` — the mechanism, its assessment against WA, decided / open |
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

