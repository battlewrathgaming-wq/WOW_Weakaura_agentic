# The UI overhaul — SCOPED

_Staged 2026-08-16. **Not a build plan and not scheduled.** A scope, so the settled ground survives
until the dev cycle reaches it and nobody re-argues what is already decided._

★★ **Read `dungeonrun_model.md` first** — the rulings below are its, restated here in the order a
builder would need them. This file adds only the MECHANISM and its assessment.

---

## ★★★ THE OVERHAUL IS THE DECISION PASS, NOT A REDESIGN

> *"The capability on its own had legs, and then gives the context for the decision making pass. As
> each element is not in isolation. Which belongs to the overhaul."*

★★★ **So this is not a queue of deferred work — it is the point where everything built is on screen
TOGETHER and gets judged in company rather than alone.** Which reframes both piles the project has
been accumulating:

    every ☐ banked        one more element that will be ruled on IN CONTEXT
    every capability      one more thing giving that context

★★ **They are the same accumulation seen from opposite sides**, and it is why *"it still doesn't
have enough content to reason what-goes-where"* was a correct call rather than a stall. ⚠ **The bank
is not debt. It is the agenda.**

---

## ★★★ The dependency, and it decides the order

> *"I'd move the build on disk to that. But it's wrapped up in the UI overhaul. Which still doesn't
> have enough content to reason what-goes-where within that pane."*

    1. CONTENT        what needs to exist on these surfaces at all
    2. ARRANGEMENT    what goes where, once there is a whole to divide
    3. DESCRIPTION    panespec stops being a proposal and becomes the intended pane
    4. PORT           object.lua builds FROM it; map.lua and promoter.lua get one

⚠ **Steps 3 and 4 cannot move first**, and I argued once that they could. `panespec.lua` and
`object.lua` describe *different panes* — order, pairing, the title row and the content column all
differ (enumerated on `interface/object.md`). So building from the spec today would visibly
rearrange the identity zone: **the port IS a redesign.**

★ **Tabs are a partition, and you cannot partition content you have not got.** Cut the Object pane
today and you cut around the twenty controls that happen to exist, then re-cut the moment the
readout box takes ten of them away.

---

## The mechanism — `panespec.lua` + `layout.lua`

**Made 2026-08-15 (§101), touched twice, and it was never a description of the built pane.** It came
out of the offline-resolver work: a pane declared as data so `layout.lua` could compute geometry
against the client's own constants and the smoke could check it before anything reached the game.

★ Its own header says what it is: *"the arrangement below is a PROPOSAL to be cut about. The engine
underneath it does not care what the answer is."* It needed **an** arrangement to have something to
measure, so I wrote one in.

**What it holds:**

    Spec.zones     zones -> rows -> cells       { key, x, kind, w? }
    Spec.W / H     per-kind sizes
    rowHidden      which subject states a row applies to
    Spec.footer    the test line, deliberately NOT a zone
    Layout         gaps SOURCED from the client - 6 header-to-content, 8 row-to-row,
                   12 zone-to-zone. A row is as tall as its tallest cell.
                   A dropdown is budgeted at +50 for its art (§103)

★★ **And its headline finding is still the open arrangement question:** the child subject needs
**575px in a pane 330px TALL** — *"195 of the 575 is chrome, five zones at 39 each, and four
dropdowns add another 128. That is an arrangement decision, not an arithmetic one."*
⚠ **`330` IS A HEIGHT AND IT IS SUPERSEDED** (RI-73, 2026-08-24). Panes are written width-first
everywhere else here (`240 × 600`, `280 × 206`), so `330px pane` reads as a WIDTH. It is the height
the wireframe measured against, and `object.lua` has shipped **600** since §104: *"★★ 600 TALL, NOT
330 (§104)"*, `f:SetWidth(240); f:SetHeight(600)`. ⟶ The two documents do not disagree; the sentence
was only unmisreadable to someone who already knew. **It cost a published false claim** — this seat
read it as a width and told Battlewrath *"object.md's 240 is wrong by ~25%"*, then retracted it
(UL-9).

⚠ Which is exactly what tabs answer. Five zone-chromes at 39px is 195px spent on saying where you
are; a tab strip says it once.

---

## ★★★ Assessment against WeakAuras' options tree

_Mine, from reading both. Idioms and constants: `reference/weakauras_idioms.md`._

**They agree on the principle**, which is why panespec is a candidate for the overhaul rather than
something the overhaul replaces: **the pane is data, positions are computed, the author declares
WHAT and the engine decides WHERE.**

### ⚠ Two places WeakAuras is plainly ahead

| | |
|---|---|
| **no typed coordinates** | Ours still carries one per cell — `{ "object.move", 178, "check" }`. WA gives `order` and `width` and never a position; its Flow layout wraps and stacks. **Our engine already computes y. The x is the half we did not finish** — and a hand-typed x inside a declaration is the same class of thing as Promotion's four content columns |
| **width is a UNIT, not pixels** | We carry a bag — `Spec.W = { edit=100, check=26, button=80, dropdown=100 }` plus per-cell overrides. They carry `width_multiplier = 170` and three multipliers off it, and **the pane derives from the unit**. That is the thing that would have prevented *"the pane got wider and the content did not"* |

### ★ Two places ours differs for a reason

| | |
|---|---|
| **`hidden` is a static subject set** | `only("beacon","child","note")` against WA's `hidden = function(...)`, 596 uses. Theirs is more expressive; **ours is OFFLINE-CHECKABLE** — the smoke enumerates all four subject states including *nothing selected*, which is the state the orphaned heading survived into. Keep ours |
| **a header belongs to a ZONE** | Theirs is an entry in the list with an order like any other. Ours makes a caption a PROPERTY of its zone, and the file defends it: *"there is no way to write one that outlives its content."* Written after the orphan bug, so it is earned |

### ⚠ What the mechanism does not have yet

- **A level above zones.** `Spec.zones` is flat with `Spec.footer` beside it. Tabs need a container
  over them — which is how WA does it, tabs containing sections containing entries. An extension of
  the same shape, not a rework.
- **Explicit `order` numbers instead of array position.** ★ The cheapest change with the widest
  effect: it is what lets a pane be assembled by more than one contributor, which the readout box
  needs the moment several things send to it.

---

## ★★★ THE FOUR TAB STRIPS — structure decides them, the author never picks

★★ **A node's tab strip is DERIVED from what it is and what it has**, not configured. Which is the
flattening rule at the surface level: no decision offered, because the answer was already made by
the shape of the thing.

    beacon, no children   Face : Stage 1 : Stage 2
    beacon, with children Face : Children (name · opacity) : What they are doing
    child, FIRST          Face : Stage 1 : Action (N)
    child, not first      Face : Action (N)

★★★ **FACE IS UNIVERSAL** — all four carry it, which fits it being the condensed *what is
actionable now* surface. Everything after it is what that node's structure earns.

★★★ **And this reads §225's "swap" properly: the tabs are not lost. THE BEACON CHANGES WHAT IT
IS** — from actor to theatre — and its behaviour goes from authored to derived. ★ Its two child
tabs share one order, so the list is learned once and read twice.

### ★★★ THE STAGE TABS ARE THE CLOSED LOOP — an ON-RAMP and an OFF-RAMP

    Stage tab 1   ON-RAMP    on stage match     set supertracker on my waypoint y/n
                                                update note y/n
    Stage tab 2   OFF-RAMP   for stage complete reach my waypoint
                                                update note y/n

⚠ **Tab 2 mixes two categories and the spec must name them separately**: *reach my waypoint* is the
CONDITION for completion; *update note* is an ACTION on it. Otherwise the second tab reads as a list
of actions whose first entry is not one.

★★ **Two control forms inside a tab**, which is §84's *"multiple flags can be true, unless they
compete"*: EXCLUSIVE choices and INDEPENDENT y/n toggles. The spec needs both, not one.

### ⚠⚠ THE OFF-RAMP CARRIES NO TRACKER ACTION

> *"Which discounts the next super tracker, as that is stage's 3 choice."*

★★★ **Only an ON-RAMP ever moves the tracker across stages.** The off-ramp satisfies and optionally
takes the note; pointing at what comes next is the next stage's job on entry. ⚠ **This is a RULE,
not an omission from the sketch** — without it written down, someone notices tab 2 has fewer options
than tab 1 and helpfully adds one.

    index becomes 2   beacon 2's ON-RAMP    come find me · note?
    you arrive        its OFF-RAMP          take the note? · satisfy
    index becomes 3   beacon 3's ON-RAMP    …

### ★★ The off-ramp SPLITS when there are children

    condition   PER CHILD, any number of them — "any child with the flag satisfies" (§90)
    outcome     THE BEACON'S. One answer for the group

★ Which is why a child has a Stage 1 and no Stage 2 — there is nothing for it to hold. ★★ **And
close-out becomes an ACTION when the beacon is not self-completing**: `advance stage` and `set stage
to N` sit in `Action (N)`, so any child can carry it.

### ★★★ SO SELF-COMPLETION IS STRUCTURAL, NEVER AUTHORED

A childless beacon closes itself because it HAS a Stage 2. A beacon with children closes via a child
carrying the close-out action. **The author never picks between those two mechanisms** — which one
applies follows from whether children exist, exactly as the tab strip does.

### ★★ `complete` and `set` ARE ACTIONS, and `role` may not survive

They sat in `Routes.ROLES` and they WRITE TO THE INDEX, which is an act. Moving them into `Action
(N)` puts them where they behave — and it settles a boundary the model could not previously place,
because the scope doc filed `role` under *condition* while two of its values did things.

    complete  ->  an action: advance the stage
    set       ->  an action: set the stage to N
    start     ->  "annotates arrival at the stage"   — that is the ON-RAMP phase
    update    ->  "annotates progress within it"     — that is just when an action fires

⚠ Half becomes actions, half becomes the phase the tab already names. **Whether `role` survives at
all is a question for the build, not for now.**

### ⚠⚠ THE TRANSITION DESTROYS THE BEACON'S OWN ACTIONS

> *"Loses them. Passing them on sounds nice. But creates a data handling and staleness issue."*

★ The same posture as every other superseded-state call here: **parked state is what gets built on
later.** Migrating a childless beacon's actions into its first child would look generous and would
leave a copy nobody owns.

## ★★★ THE CONSEQUENCE REGISTER — a third text tone, and it speaks only when there is something to lose

> *"We can include a inline text just below it. A mild highlight tone. Of what that does. What is a
> safety check for someone new is an annoyance for someone used to the tool."*

★★ **It replaces the confirm dialog rather than joining it.** A gate is protection for a first-time
user and friction for every later one; a line that states the consequence informs both and stops
neither.

    hint          standing instruction, grey        ALWAYS
    object.test   high contrast, fed by an act      AFTER
    consequence   mild highlight                    WHILE THE CONDITION HOLDS

★★★ **Its rule is what keeps it clear of the addon's own law** that *a caveat printed permanently is
a caveat people learn to read past*. **It is not permanent — it is conditional on being true.**
Silent on a bare beacon; present the moment that beacon has actions to lose.

★ **The tone is a LOOKUP, not a ruling.** The pane's three tones are taken — grey is inert, gold is
*the authored thing*, red is a fault — and consequence is none of those. ⚠ But a colour cannot be
judged in isolation, so it is assigned by being SEEN beside the other three, not decided in prose.
Candidates live in the table; the line reads from it; swapping is an edit and a reload.

## Decided (his, this session)

- **Object gets a FACE and TABS** — *"face: What it is / Tab 1: Behaviours"*. The face is the
  subject's identity, visible whatever tab is open, because every tab describes that object.
- **The zones are already the tabs** — the split falls out of the `zone` each row carries.
- **Compact vs presenting.** The Remote is compact (16px inset, no dividers). Map · Curation ·
  Promotion · Object are presenting: wider inset, title labels, dividers, and **zones designated
  rather than every field carrying its own small grey word**.
- **Labels above the field**, per the client's own idiom — and the row grows to pay for it, 26 → 44.
- **TWO readout boxes on the editor**, split by what caused them: **cursor** (`map.readout`, a
  tooltip) and **response** (`object.test`, fed by the act). They conflict in one box — hover would
  wipe the emission, which is the failure §87 built the test line to avoid.
- **HOVER IDs; CLICK HOLDS.** Hover shows *just enough to identify it and read its state* and
  commits you to nothing. Clicking **holds** the subject and is what opens the edit surfaces.
  ★ A content rule, so it decides what goes in the cursor readout without arguing case by case:
  the moment a control appears there, it is the wrong surface.
- ⚠ **CORRECTION — the drop-down is not click-to-hold's cousin.** I read it as the same intent on a
  surface with nothing to click. It is not: *"the drop down was specific to a stable interface on
  the editor to filter the readout box."* It **filters what the readout box SHOWS**, and it lives on
  a stable surface — a persistent part of the editor, not something that comes and goes.
  ★ So they are two mechanisms doing two jobs: **click-to-hold picks the SUBJECT; the drop-down
  filters the readout's CONTENT.** Both survive; neither replaces the other.
- **The face and the tooltip are the same content at two densities** — one source, two
  renderings. A face that disagrees with its own tooltip is a bug nobody would look for.
- **The driver has ONE sender** and no ladder problem at all. Presentation is an editor question.
- **We inform; we do not act.** Anything that performs a gameplay input is out.

### ★★★ The shape of the edit interface

> *"The map editing interface will be a lighter version of WA. Tabs, drop downs, ticks, sliders.
> Loaded based on the decision tree followed."*

★★ **A LIGHTER WA, and the last clause is the mechanism**: what appears depends on the choices
already made. That is WeakAuras' `hidden = function(state)` — 596 uses — and it is already this
addon's rule: *"a determined option is not shown. Picking `radius` does not then ask you to tick one
point"* (§49, absent rather than disabled).

**The beacon:**

    face      what it is
    tab 1     node behaviour
    tab 2     behaviour 2
    …
    last      META DATA

**The child:**

    face      what it is, plus the primary node select (a "special child")
    tab 1     its BEACON STAND-IN

⚠⚠ **AND THE RULE THAT MAKES IT A TREE RATHER THAN A MENU:**

> *"If beacon has a child, it loses it's tab 1."*

★★★ **The beacon's own node behaviour is surrendered when a child takes that job.** Which is §95's
finding — *what a beacon ANSWERS*, and whether a child has taken it over — made STRUCTURAL in the
interface instead of reported in a grey line. You cannot author a contradiction, because the tab
that would hold it is not there.

★ It also explains the child's tab 1 being *"its beacon stand-in"*: the job did not vanish, it
MOVED. One tab disappears from the parent and appears on the child, and the pane shows which of
them is doing it.

### ★★★ THE SPECIAL CHILD — one per group, and it is the beacon's stand-in

> *"In a group only 1 can be it. And it's the first spawned by ordinal/consequence. So it has a
> special tab 1. The rest don't get the same behaviour to be the stage advanced lure as a global
> reach waypoint / supertracker destination."*

| | |
|---|---|
| **how many** | exactly **one** per group |
| **which one** | the **first spawned by ordinal / consequence** — not chosen, derived |
| **what only it does** | be the **stage-advance lure**: the global reach waypoint, and the supertracker destination |
| **what it gets** | a **special tab 1**, which the others do not have |

★★ **And that is why it stands in for the beacon.** The beacon's job was to point the tracker and
advance the stage; the special child takes exactly that job, which is why the parent *loses its
tab 1* the moment one exists. ⚠ **One destination at a time is a fact about the tracker, not a rule
we chose** — you cannot be pointed at two places, so only one child can hold it.

### ★★★ A TAB IS AN ACTION — not a category of settings

> *"Then the rest, and the special child, can have: Tab 1: Update notes / Tab 2: Set way tracker /
> Tab 3: Say LOS / Tab 4:… Where another is: Tab 1: Update note (*Clear) / Tab 2: Stage complete"*

★★★ ⚠⚠ **SUPERSEDED IN PART (§234), AND THE CORRECTION IS HIS OWN TYPO CORRECTING ITSELF.** He wrote
*"Action tab 1"*, struck it, and wrote **"Stage tab 1"** — and the structure followed the second
one. **A TAB IS NOT ALWAYS AN ACTION. A STAGE TAB IS A PHASE, and it CONTAINS actions.** What
survives from below is that actions are tabs too, on children, alongside the phase tabs. See *the
four tab strips* further down; read that first, and this section for the reasoning that got there.

**So the tab strip is the child's LIST OF ACTIONS, one per tab, and it differs per child.** Two
children in the same group carry different strips because they do different things. That is
*"loaded based on the decision tree followed"* stated concretely.

⚠⚠ **AND IT CHANGES `object.action` FROM ONE-OF TO MANY-OF.** Today it is a single drop-down with
two values, `nothing` and `supertrack` — a child does one thing. Under this a child updates a note
**and** sets the way tracker **and** says LOS, each with its own configuration surface.

★ **Which is exactly WeakAuras' shape**, and it is the third time the two designs have met from
different directions: a WA display has one trigger, its conditions, and **a LIST of actions** —
sound, chat, custom code, glow — each configured separately. Ours is trigger (detect) → condition
(role, stage) → **actions (the tabs)**.

★ **It also answers *behaviour 2*.** Not a second category — just the second action. The beacon's
strip is the same pattern as the child's.

### ★★★ AND A TAB IS SPAWNED FROM THE END OF THE ONE BEFORE IT

> *"So we spawn tab 2 as an option at the end of spawn 1."*

★★ **The strip is not a menu of possibilities — it is a record of decisions.** You configure an
action, and at the foot of that tab is the option to add another. Tab 3 does not exist until tab 2
asks for it.

**What falls out:**

- **No empty tabs, ever.** A tab exists because somebody asked for one, which is the same guarantee
  `panespec` gives a zone heading: it cannot outlive its content because it has no independent life.
- **The strip's length IS the child's complexity**, readable at a glance without opening anything.
- ★★★ **It flattens the decision, which is this bench's first design rule.** The alternative is a
  blank pane offering eight actions at once. This asks one question at a time, and only after you
  have finished the last thing you started.
- ★ **It is the house pattern's fourth appearance** — capture then promote · pin then meaning ·
  mint then author · **spawn then configure**. The mechanical part is immediate and the meaning
  comes after.
- ⚠ **And it gives the action list an authoring ORDER for free**, because tabs are created in
  sequence. Whether that is also the EXECUTION order is still open — but the sequence now exists as
  a fact rather than needing to be invented later.

### ★★★ WHY IT IS A TAB STACK AND NOT WA'S SCROLL — the pane sits ON the workspace

> *"I'm borrowing from WA. They have trigger 1, then create trigger 2. And that is one page that
> scrolls down. We have isolated actions that build as a tab stack, so we can keep the pane limited.
> As it's a pane sitting on a pane."*

| | |
|---|---|
| **WeakAuras** | trigger 1, then trigger 2, down **one scrolling page**. Its options window is 830 × 665, standalone, and **it IS the workspace** — nothing is behind it that matters |
| **ours** | isolated actions as a **tab stack**, bounded. **Our pane sits ON the map** — the thing being edited is underneath it |

★★★ **So the divergence is forced, not stylistic.** A scrolling page grows with the content; every
pixel it grows is map it covers. **A tab stack is bounded by construction** — ten actions and one
action occupy the same footprint.

★★ **And it settles §101's open finding.** The child subject needs 575px in a pane 330px TALL
(⚠ a HEIGHT, superseded by §104's 600 — RI-73; the second site, which the item did not name). A scroll
answers that by growing; **tabs answer it by partitioning**, which is the only one of the two an
overlay can afford. Five zone-chromes at 39px each is 195px spent saying where you are — a tab strip
says it once.

⚠ **The trade, and it is answered:** WA's scroll keeps everything visible at once and ours cannot.

> *"I think a simple readout on the face that is the flattened list of what each tab settled out.
> Concise over vorbose. They have the tab to inspect each config. And a later test driver that can
> expose information."*

★★★ **THE FACE CARRIES A FLATTENED SUMMARY — one line per tab, what it settled to.** So the
all-at-once view is not lost, it is moved and compressed: **the face says WHAT, the tab says HOW.**

    face      the flattened list. Concise. A glance, not a report.
    the tab   the configuration behind one line of it
    later     a test driver that exposes the deeper information

★★ **Same shape as `usage`**, settled this same day: a summary word per control, with act · response
· outcome underneath it on inspection. **Summary at the glance layer, decomposition on demand** —
and it is now the third place that shape has been chosen, which makes it a house idiom rather than
a coincidence.

★ **And it extends the face/tooltip rule.** *"The face and the tooltip are the same content at two
densities."* If the flattened action list is part of *what this thing is*, it belongs in the hover
too — so a tooltip answers **what it is and what it does**, and clicking is what lets you change it.

⚠ *"Concise over verbose"* is the bar, and it is a real constraint: a summary that needs reading is
a report, and a report belongs in the tab. The test driver is where verbosity is allowed —
`debug_suite_plan.md`, which is also where §113 put the test-driver work when it was cut.

★ It also lines up with the model's own rule: *the addon occupies only what the user opens.* A pane
that grows as you author occupies more the more you use it, which is that rule leaking.

### ★★★ SPACE IS PER MODE — the panes that are not needed are not there

> *"At that point, Curation and route don't need to display. So that affords space for the rich
> information."*

★★★ **The pane budget is not fixed — it is a function of what you are doing.** Walking is not
authoring, so Curation and Promotion close, and the space they were holding becomes the timeline's.

★★ **Which resolves an apparent contradiction in this file.** The tab stack exists because *"a pane
sits ON the map"* and every pixel it grows is map it hides. The walk's timeline is rich and wide —
and that is not a violation, because **in walk mode there is no editing pane above the map.** Two
different modes, two different budgets, and neither has to compromise for the other.

★ **It is the model's own rule doing real work:** *the addon occupies only what the user opens.*
Modes are how that stays true as the addon grows — not by every surface being small, but by only
the surfaces of one activity being present at once. ⚠ Compare the Remote, which is a gate of
activity: *"I'm doing a run" or "I'm reviewing a run"*. This is the same cut, one level down.

### ⚠ Still open, and marked rather than guessed

★★★ **RETIRED (§232), and not deferred — THE TRIGGER IS BINARY.** This was banked as *whether the
authoring order is also the EXECUTION order*. Battlewrath: *"without conditions to test, you can't
pace execution. Currently it is binary."*

**Many actions all act when the binary is met.** They fire on the same true, at the same instant,
so there is no sequence to observe and nothing to answer. ⚠ **The question was malformed rather
than unanswered** — it presumed an ordering exists. Picking one now would be inventing a rule for a
distinction that does not exist.

★ And the trigger band is why: `radius` · `wire` · `reach` are all VOLUME, `ifUnseen` is a state and
`fireOn` is a stage phase. **Nothing anywhere varies over time**, so there is no axis to pace
along. *"It's a question we're not looking to answer."*

Still open, then:
- What `* Clear` is under *Update note* — a sub-option of that action, on its own tab.

## Open

- **The content list.** 19 hopes across six surface files, ~2,900 words, uncollated — nobody can
  see the whole of what wants to exist. ☐ *A gather, not a conversion; hopes are prose, not jobs.*
- **What goes where**, which waits on the above.
- **The 575-in-330 finding** — the arrangement decision §101 raised and nobody has taken.
- Whether `behaviour` and `stage` are one tab or two. A beacon's stage is what it ANSWERS and its
  behaviour is what it DOES; §79 called the outcome *"the whole of what a checkpoint is"*, which
  argues they belong together.
- The six ☐ that are the same job wearing three hats — Map, Promotion and Object all
  *"not declared in panespec, every number hand-typed"*.

## Out of scope

- Rebuilding the engine. It works, it is sourced from the client's constants, and the smoke drives
  it today — it caught a real 38px dropdown collision before the client saw it.
- The map render and `map.readout`'s internals. Separate surface, separate question.
