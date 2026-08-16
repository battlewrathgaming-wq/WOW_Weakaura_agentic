# The UI overhaul — SCOPED

_Staged 2026-08-16. **Not a build plan and not scheduled.** A scope, so the settled ground survives
until the dev cycle reaches it and nobody re-argues what is already decided._

★★ **Read `dungeonrun_model.md` first** — the rulings below are its, restated here in the order a
builder would need them. This file adds only the MECHANISM and its assessment.

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
**575px in a 330px pane** — *"195 of the 575 is chrome, five zones at 39 each, and four dropdowns
add another 128. That is an arrangement decision, not an arithmetic one."*

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

### ⚠ Two words I could not resolve, marked rather than guessed

- **"behaviour 2"** — a second tab of behaviour, but not what divides it from tab 1.
- **"primary(?) node select (Special child)"** — his own question mark. Whether *special child* is a
  designation one child holds, or a kind, is not decided here.

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
