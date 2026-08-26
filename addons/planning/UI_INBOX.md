# UI_INBOX — questions and hand-offs TO the UI specialist

_Opened 2026-08-24 by the **Addon creator**, at Battlewrath's ask: *"Push the items to the UI inbox.
They can commit or discard them."* **The missing half of a pattern this repo already runs twice** —
`ARCHITECT_INBOX.md` → `ARCHITECT_LOG.md`, `Reconcile_inbox.md` → `ANALYST_LOG.md`. The UI seat had
a log and no door._

## How it works

    WHO FILES        the Addon creator, the Analyst or the architect; the UI seat never files to itself
    AN ITEM CARRIES  · the hand-off or the question, in one sentence
                     · WHAT WAS MEASURED — the command, its output, cited
                     · what the bench has ALREADY DONE, so nothing is repeated
                     · the DECISION being asked for, phrased so it can be answered
    STATUS           lives on the ITEM: `UI-N RESOLVED (ui, date)` at its head means resolved and its
                     outcome is in `UI_LOG.md`; no stamp = open. Derive, never list:
                     `grep -n "UI-[0-9]* RESOLVED" UI_INBOX.md`; next number = highest + 1
    THE OUTCOME      goes to `UI_LOG.md` as a `UL-N` entry, that file's own form. An item is EITHER a
                     full entry here OR a row in the log, never both.

⚠ **Not for:** layout taste the UI seat owns outright · anything `UI_FOR_THE_BENCH.md` already
indexes · a build the bench can simply do. **A doorway, not a gate** (his ruling, 2026-08-24) — this
file exists so a hand-off has somewhere to land, not so work has to pass through it.

---

## UI-4 · HAND-OFF — the HOSTED state is measured: Ace places the SEAT, never the composite

_From the **Addon creator**, 2026-08-26, at Battlewrath's ask to hand it over. ⚠ Nothing here is a
decision for this seat to ratify — it is two client measurements and the pattern that falls out.
The custom-controls registry is yours, and this is the mechanism that lets one live inside an Ace
pane rather than beside it._

★★★ **CORRECTED 2026-08-26, BY MEASUREMENT AND BY PRIOR ART — READ THIS FIRST.**

**THE ONE SENTENCE, as it now stands:** a hand-built composite belongs INSIDE a custom **AceGUI
widget type** we register, not parented into a seat. The raw frames live in the widget's own
constructor; `OnAcquire` / `OnRelease` do the reset; `dialogControl` names it from an option table.

⚠ **THE FIRST VERSION OF THIS ITEM SAID SOMETHING ELSE** — *"a seat Ace positions and reserves
height for, with the composite placed by us inside that seat"* — and it is kept below because the
measurements behind it are real and still true. They answered a question we should not have been
asking.

**WHAT DECIDED IT.** Battlewrath's steer: *"Review how WA handles it's templates. As they disappear
once a aura is loaded. And they use ace."*

> `WeakAurasTemplates/TriggerTemplates.lua:1651` — `newViewScroll:ReleaseChildren()`

That ONE LINE is the whole teardown, and it works because **every child is an AceGUI widget**. The
raw frames are not gone: `AceGUIWidget-WeakAurasIconButton.lua:64-95` does the `CreateFrame`, the
textures and the scripts INSIDE the constructor, collects them into `{ frame, texture, type }`,
copies its methods in and calls `AceGUI:RegisterAsWidget`. Each implements `OnAcquire` and
`OnRelease`. **Thirty-one such widgets ship in `WeakAurasOptions/AceGUI-Widgets`.**

**AND THE TWO MODELS WERE RUN SIDE BY SIDE**, same release and same re-acquire, record
`20260826_224257_512`:

    seat + raw frame   stale content survives: TRUE    comes back shown: FALSE
    widget (WA)        stale content survives: FALSE   comes back shown: TRUE

    widget  ctor=1  acquires=2  releases=1  sameObject=True  dirty True -> False  shown=True

★★ `releases=1` is the load-bearing number: `ReleaseChildren` called `OnRelease` on a widget it
OWNS. ⟶ **The teardown becomes the library's to RUN and ours only to DEFINE**, rather than a
discipline every caller has to remember — which is the whole of *more repeatable*.

★ **AND IT EXPLAINS EVERY FAULT THE SEAT MODEL PRODUCED.** Hidden on release, unparented,
unanchored, stale content surviving `ReleaseChildren`, and finally a seat that was shown and
**sized to nothing** (`seat shown=True 300x0 content 300x0 mark shown=True top=0` — `Release`
clears `content.width/height` at `AceGUI-3.0.lua:233-235`). All of it is what happens when the
composite is kept OUTSIDE the abstraction.

---

_The original filing follows. Its `dialogControl` proof is unchanged and still needed — that is how
a custom widget reaches an option table — and its seat measurements stand as the record of what was
tried._

**THE ONE SENTENCE (superseded):** a hand-built composite can sit INSIDE an Ace-rendered pane, in a
**seat** Ace positions and reserves height for, with the composite placed by us inside that seat.

### WHAT WAS MEASURED, and both were needed

**1 · Sheet ten, in the client** (`/coadump r sheet2`, record `20260826_203414_463`, read with
`py addons\tools\check_sheet.py --host`):

    arrangement      moved   resized   contentH   witness y
    direct           +0,+0     False         13          -3
    wrapped          +0,+0     False         56          -3
    ⟶ NEITHER: a hosted composite carries its own placement

★★ The WITNESS is what makes that readable — a real AceGUI Label in the same seat under the same
layout DID move (`witnessY = -3`), so the layout RAN and chose not to touch the raw child. Without
it, *"Ace positioned nothing"* and *"the layout never ran"* are one reading.

★★★ **AND `contentH` IS THE ACTIONABLE HALF.** 13 direct vs 56 wrapped — a difference of 43,
which is the child's 40 plus spacing — and `innerY = -16.13` says the wrapped SEAT was positioned.
⟶ A composite parented DIRECT gets **no height reserved at all**: the pane sizes itself as though
the control is not there, which is `DR_Pane_8`'s reserved space with the sign flipped.

**2 · The layer above it**, because sheet ten measured raw AceGUI and the unified pane goes through
**AceConfigDialog**, where an option table cannot `AddChild` a widget. `AceConfigDialog-3.0.lua:1119`
reads `v.dialogControl or v.control` and calls `gui:Create(controlType)` — and that source read was
asserted against the real Registry and the real Dialog in `smoke_dungeonrunoptions.lua`:

    ★ AceConfigDialog built a custom `dialogControl` widget

**3 · THE TEARDOWN**, at his ask — *"I ask for the tear down and reconstruction. On tab change,
a whole new set of controls is needed."* Measured in the same sheet, record
`20260826_213922_592`:

    recycle    ctor=1  acquires=2  sameSeat=True  stillThere=True

★★★ **THE POOL RETURNED THE SAME OBJECT AND IT CAME BACK CARRYING THE LAST CONTENT.** One
constructor call for two acquisitions; the raw frame parented in the first use was still
parented after `Release` and re-`Create`. ⟶ `AceGUI:Release` calls `ReleaseChildren`
(`AceGUI-3.0.lua:207`), which releases child **WIDGETS** — a raw FRAME is not one, so it cannot
be seen and rides into the pool.

⚠ **AND `AceGUI:Create` SETS THE LAYOUT TO "List" AFTER `OnAcquire`** (`:193-194`). So a
`SetLayout(nil)` written in the CONSTRUCTOR is overwritten on every acquisition — it holds for
instance one and no other.

### THE PATTERN THAT FALLS OUT

    the SEAT      a registered AceGUI widget type, named on a control via `dialogControl`.
                  AceConfigDialog creates it, places it in the flow, and reserves the height
                  it reports.
    the CONTENT   the hand-built composite, parented into the seat and placed BY US.
    the TEARDOWN  **`OnAcquire`, never the constructor.** A pooled seat SKIPS the constructor,
                  so a seat that builds or clears there is correct exactly once. `OnAcquire`
                  runs on every acquisition and is the only hook that does.
                  ⚠⚠ AND IT HAS THREE JOBS, NOT ONE. `AceGUI:Release`
                  (`AceGUI-3.0.lua:227-229`) does `ClearAllPoints()`, `Hide()` and
                  `SetParent(UIParent)`; a re-acquire undoes NONE of them. So a seat must
                  **re-parent · re-anchor · SHOW** as well as clear its raw content.
    ⚠ `SetLayout(nil)` belongs in `OnAcquire` too, for the same reason and one more: Ace
      re-sets it to "List" immediately after that hook, so anywhere earlier is undone.
    ★ Ace must not lay out what is inside the seat — that is the mechanism `options.lua`'s
      header names as the one that would break a canvas.

★★ **THIS IS `DR_Pane_2` AT THE SEAT.** *A content swap is a teardown, not a mutation* — and
the pool is a way for the mutation to happen anyway, invisibly, because the library's own
teardown cannot reach a frame it did not create.

⚠⚠ **AND THE STALE CONTENT IS HIDDEN, WHICH IS WORSE THAN VISIBLE.** `stillThere` measures
PARENTAGE and `shownAfter` measures visibility, and the pair is the finding: a recycled seat
comes back with the last content **still attached and not shown**. ⟶ So nothing looks wrong
until something shows the seat — and then a tab change reveals the PREVIOUS tab's content at
the exact moment a reader is looking at it.

☆ **HOW THAT WAS FOUND, because the method is the transferable part.** Not by a number. The
capture read `stillThere=True` and every other value correct, and the arm was simply not on
the sheet — seen by READING THE SCREENSHOT, at Battlewrath's prompt. Third time in one
evening the shot was the half that could tell us: the other two were an arm overflowing its
board, and a board that was declared and never built.

**Two constraints worth having before you build on it:**

- **`dialogControl` is read on `input`, `select` and `multiselect` ONLY** (`:1119`, `:1175`,
  `:1194`), not on every type. A hosted control declares one of those and overrides the widget.
- **The container shape is part of the contract.** A bare `AceGUI:Create("Frame")` sent the Dialog
  into its own scroll handling and died at `:1529`; a `SimpleGroup` with `"Fill"` — what
  `options.lua` already hands it — works. It looks like a detail and is not.

### WHAT THE BENCH HAS ALREADY DONE, so nothing is repeated

- `sheet_decl.lua` v11 — KIND `host`, its board placed as a declaration and passed clean by
  `check_layout` before anything was built.
- `task_sheet.lua` — `buildHostBoard`, two arrangements plus the witness, emitting `payload.host`.
- `check_sheet.py --host` — the reader, pairing the screenshot and its nine registration pins.
- `smoke_dungeonrunoptions.lua` — the `dialogControl` proof, offline and permanent.
- `panes_decl.lua` — the inventory this feeds; its three states are `ace` · `hosted` · `frame`,
  and `hosted` is the one this item defines.

### THE DECISION BEING ASKED FOR

☐ **Is the seat a TYPE or a FEATURE?** `concepts/type-or-feature.md` rules that a thing is a TYPE
if a SECOND, UNRELATED instance already exists — *"one instance is a feature wearing a type's
clothes."* Today the candidates are the **playback controller** (curation's bar, handles and
steppers) and the **map canvas**. ⚠ Whether those are two instances of ONE seat or two different
things is the registry's question and this seat owns it.

☐ **And if it is a type, what does the registry call it?** The bench has been calling it a *seat*
in prose; naming it is yours, and `panes_decl`'s `hosted` entries will carry whatever word you pick.

_No question for Battlewrath — both measurements are his runs, and the hand-off is at his ask._

---

## UI-3 · ANSWERED — the raw-frame panes sit BESIDE the Fill seat. All six of them.

_Filed by the **Addon creator**, 2026-08-25. **This answers the question
`UI_FOR_THE_BENCH.md` names as the bench's** — *"Does that subtree sit inside the `paneSeat`'s
`Fill` guarantee, or beside it? … this seat will not guess at your structure."* ★ It is answered by
PARENTAGE, which is structural fact, not by intent._

### THE MEASUREMENT

Every top-level `CreateFrame("Frame", …)` in the addon, with its parent argument, comments stripped
so a documented example cannot be read as code:

    file           global                       parent      verdict
    object.lua     COA_DungeonRunObject         UIParent    ⚠ BESIDE
    promoter.lua   COA_DungeonRunPromoter       UIParent    ⚠ BESIDE
    editor.lua     COA_DungeonRunEditor         UIParent    ⚠ BESIDE
    map.lua        COA_DungeonRunMapControls    UIParent    ⚠ BESIDE
    widget.lua     COA_DungeonRunFrame          UIParent    ⚠ BESIDE
    drive.lua      COA_DungeonRunDrive          UIParent    ⚠ BESIDE
    options.lua    — creates no top-level Frame — it builds the Ace window through AceGUI

⟶ `dlg:Open(ADDON, paneSeat)`, so **`Fill` reaches whatever the DIALOG builds inside that seat and
nothing else.**

### ★★★ SO LAW 1 REACHES NONE OF THEM — and the answer is cleaner than "some of it"

`object.lua:576` is `CreateFrame("Frame", "COA_DungeonRunObject", UIParent)`. It is not an AceGUI
child with hand-typed widths inside a managed subtree; **it is a separate top-level window that
happens to be opened from the same addon.** The hand-typed 240 / 192 / 204 the door cites are not
*escaping* the Fill guarantee — they were never under it.

⚠ **AND IT IS ALL SIX, WHICH CHANGES WHAT THE OVERHAUL IS.** Not *"the object pane needs
re-parenting"* but **nothing in the addon currently sits under the Ace window at all.** The overhaul
is a RE-PARENTING before it is a re-styling.

★ **The good news is the door's other half stands unqualified:** `options.lua:188-193` already does
law 1 correctly, and it does it on a seat that today holds only the options tree. The pattern is
proven in our own code and has room in it — *"start from this, not from a rebuild"* survives the
finding intact.

### WHAT THE BENCH IS **NOT** DOING WITH THIS

⚠ **Nothing is being re-parented on the strength of a measurement.** `A10.2d` still stands — *"the
old hand-built pane keeps working until its fold lands (both, not or); nothing is torn down to
start"* — and DR_Pane_5 says it in the general form: **never argue a size, or a structure,
from a measurement.** This item reports WHAT IS. What the overhaul does about it is Battlewrath's
sequencing and the architect's shape.

☐ **One thing this seat may want to know, since it touches the registry:** a top-level window and a
lane inside a container are different KINDS of thing to place a control on. If a unit's settled
behaviour assumes an AceGUI parent — `Fill`, `ReleaseChildren`, the container's own layout — then
**today it has no valid host in this addon outside the options tree.** That is not a complaint; per
the seat's own rule it is the registry's next entry, and it is better known before units are written
against a host that does not exist yet.

---
## UI-2 RESOLVED (ui, 2026-08-24) → `UI_LOG.md` UL-18 · three types accepted, roster withdrawal upheld, and the TEST gains a second source · FOUR INPUTS THE AUTHORING SURFACE NEEDS, AND WHAT THE MAP CANNOT SAY ABOUT R

_Filed by the **Addon creator**, 2026-08-24, at his ask on seeing declaration v8 in game: *"Any
types of input you'd like, or behaviours? (Maybe the map pins with behaviours defined and some
rendering methods for R n and such?)"*_

★ **Each ask below is tied to a RULED requirement, not to taste.** *"A reported edge is not a
complaint about the registry — it is the registry's next entry."* These are the edges the authoring
lane hits; §4d's list is what it has to express (**6 choices per node, 4 per tab**).

---

## ⚠⚠ AMENDED SAME DAY — HIS CHALLENGE, AND IT LANDED ON THREE OF THE FOUR

> *"Are these what you need for UI as a solved problem. Or the generic type that can be applied
> across use case?"* — Battlewrath, 2026-08-24

★★★ **AS FILED, ALL FOUR WERE PHRASED IN THE AUTHORING LANE'S CLOTHES** — *"the boss picker"*,
*"R's ladder"* — which invites the registry to record MY INSTANCE instead of the TYPE. That is the
fault he named and it is a fault in the filing, not in the asks.

★★ **THE TEST THE BENCH APPLIED, and it is measurable rather than rhetorical:** a thing is a TYPE
if a SECOND, UNRELATED instance already exists in the code. One instance is a feature wearing a
type's clothes. ⟶ Measured:

    THE TYPE                          instance A (the ask)        instance B (already shipped)
    VARIANT SLOT                      arg kind follows action     promoter.lua:123,210 - the name
    a slot whose KIND is chosen         (A10.3d, unbuilt)         field swaps BOX <-> LABEL+RENAME
    by another slot's VALUE                                       on `creating` (§61)          ✅

    SOURCED PICKER                    boss names from the run     promoter.lua:61,267 - the route
    options from a LIVE source,         (A3.1, unbuilt)           dropdown's `- no route -`     ✅
    with an explicit EMPTY state                                  drive.lua:216 - *"no route on
                                                                  this map"*                   ✅

    STEPPED LADDER                    R 5·15·25·50·100·150·300     map.lua:316 ZOOM_STAGES
    a bounded value over NON-UNIFORM    (ruled, unbuilt)          { 1.0, 1.25, 1.5, 2.0 },
    presets, plus free entry                                      cycled by one button         ✅

    ROSTER                            the tab roster on a child   ⚠ NONE - see below
    add · reorder · delete-guarded      (A10.3c, unbuilt)

### ✅ THREE ARE TYPES, and one of them proves it the hard way

★★★ **THE SOURCED PICKER'S TWO INSTANCES DISAGREE WITH EACH OTHER**, and that is the strongest
evidence a registry entry is owed. `promoter.lua` answers the empty case with a **dropdown entry**
reading `- no route -`; `drive.lua` answers it with a **greyed readout** reading *"no route on this
map"*. Two hand-rolled answers to one question, in one addon, neither aware of the other. ⟶ That
is precisely what *"so the Addon creator does not RE-DERIVE what has already been settled"* is for,
and it was re-derived.

★ **THE STEPPED LADDER'S TWO INSTANCES DIFFER IN FORM, WHICH IS REGISTRY CONTENT RATHER THAN
NOISE:** the zoom stages **CYCLE** (one button, wraps at the end) while R needs **`< >`** (two
directions, holding at the ends rather than wrapping - a run cannot silently jump from 300 to 5).
⟶ One type, two forms, and *which form when* is exactly the settled understanding the registry is.

### ❌ AND THE ROSTER IS MY USE CASE WEARING A TYPE'S CLOTHES — the bench withdraws it as a type

⚠⚠ There is no second instance, and the nearest candidate is a **REFUSAL**:
`promoter.lua:586` — *"There is no drag-to-reorder here and there should not be: one source of
truth."* The running order is **SORTED by stage value, not arranged**, deliberately.

⟶ So the only reorder in the project is the one I am asking for. **That is one instance, and a
counter-example beside it.** ★ Kept in the item below as a REQUIREMENT the authoring lane has, but
it should enter the registry only if a second use appears - and the bench would rather report that
honestly than have a type minted for a single caller.

★ **THE METHOD, offered as reusable:** an entry earns its place with TWO unrelated instances; where
the second instance is a REFUSAL, that is evidence the thing is a feature. ⚠ It is the registry's
own *"grows from USE, not from authority"* made checkable - and it is cheap, because both instances
have to be citable.

## ★★★ HIS CONTRACT FOR THE ENTRIES — 2026-08-24, and it excludes one of the three

> *"It's fine that these will have local data handling to show how they are deployed. But example
> only, and only where they are unique in composition. Then everything from the registry can be drop
> and place and wire as you need to your own data stores knowing the hooks already to place."*

    THE REGISTRY GIVES   the unit, its hooks, and its settled behaviour
    THE CONSUMER GIVES   its own data store, wired to those hooks
    EXAMPLE DATA         a DEMONSTRATION of deployment - and only where the COMPOSITION is
                         unique enough that the wiring is not obvious without one

★ It is `provide-vs-handle-boundary` in UI clothes, and the seat has already ruled its half: *"Ace
publishes the events; which one writes the record is OURS"* (UL-6). ⟶ **The hook is the settled
thing; the store behind it never is.**

### ⚠⚠ THE HAZARD WORTH NAMING: AN EXAMPLE THAT BECOMES A DEPENDENCY

If a unit ships with example handling and a consumer wires against the EXAMPLE'S SHAPE rather than
the hooks, the example has quietly become the contract - and nobody finds out until the second
consumer arrives with a different store. ★ Same fault as `half-formed-code-invites-building-on-it`,
one layer up.

☐ **A CHEAP TEST THAT MAKES THE BOUNDARY REAL:** *strip the example handling and the unit must
still construct.* If it does not, the example was load-bearing and the hooks were incomplete.
⚠ It is the same polarity check `emit_built_state --check` already runs on itself - proving the
detector in BOTH directions rather than only the direction that passes.

### APPLYING HIS RULE TO THE THREE — it excludes one

    VARIANT SLOT     ✅ EXAMPLE EARNED. The composition IS the novelty - a selector whose value
                     swaps a neighbouring slot's KIND. Nothing in the client or in Ace shows
                     that shape, so the wiring is not obvious from the hooks alone.

    SOURCED PICKER   ✅ EXAMPLE EARNED, and specifically for the EMPTY case. The populated path
                     is an ordinary dropdown; what is unique is that **empty-because-no-source
                     and empty-because-the-source-has-none are different states**, and an
                     example is the only way to show a consumer that it must distinguish them.
                     ★ The two existing hand-rolled answers disagree, which is the proof.

    STEPPED LADDER   ❌ NO EXAMPLE NEEDED, by his own rule. The composition is **stepper + value
                     box** and both parts are stock; nothing about wiring a rung list to a
                     number is unique. ⟶ What the registry owes here is the two FORMS -
                     **cycle** (wraps, one button - `map.lua`'s zoom) versus **`< >`** (two
                     directions, holds at the ends - R, because a run cannot jump 300 to 5) -
                     and WHICH FORM WHEN. That is behaviour, not deployment.

★ **The bench would rather receive fewer examples than more.** An example is a maintenance surface
and a thing that can drift from its unit; the rule *"only where unique in composition"* is what keeps
the registry an offer rather than a codebase.

---

⚠ **Nothing here asks for what v8 already shows.** Button · CheckBox · Dropdown · EditBox · Label ·
Heading · Slider · tab strips · collapsing sections · the range are on the sheet and are not restated.

### 1 · ★★★ THE CONDITIONAL FIELD — a control that CHANGES with another's value

**Ruled at A10.3d:** *"set a row's ACTION word to `boss` → the name-picker ARG appears on that row;
set it to `note` → a text field, the picker hides; nothing errors on either."*

⚠ **v8 shows COLLAPSE, which is disclosure — not the same thing.** A collapsing section hides
content the author can always get back; this is a control being **replaced** because the sentence
changed. ⟶ The tab is a sentence read start to end (his framing, 2026-08-23), and the arg slot's
KIND is decided by the action slot's VALUE.

    COMPOSITION   selector → dependent slot, where the slot's KIND is swapped, not merely shown
    THE FORM Q    what does the swap do to a value already typed in the outgoing control?
                  ★ A13.3 already rules the DATA side - clearing the action clears its arg,
                  measured against WeakAuras, which clears nothing and leaves args forever.
                  So the record's answer exists; the CONTROL's answer does not.

★ This is the single most load-bearing behaviour in the authoring lane. Four tab choices out of
four depend on it.

### 2 · ★★ THE PICKER FED FROM DATA — including when the data is EMPTY

**Ruled at A3.1 / `ROW_ARG_RULE`:** the `boss` arg is `source = "run"` — **PICKED from the run's own
bosses and never typed**, uncapped because the value is bounded by what the game named.

⚠ v8's dropdowns carry static specimens. The unsettled part is not the list, it is **the empty
state**: a promoted route drops its back-reference to the run so it can travel (§459), so an author
opening a route with no run loaded meets a picker with nothing in it. **AL-36 already took the
no-run condition**; what has no settled FORM is what the control looks like at that moment.

    THE FORM Q    disabled · present-but-saying-why · or absent?
                  ★ The bench's read: never absent - a missing control cannot explain itself,
                  and this project's standing preference is DISABLED over hidden
                  (`widget.lua`: *"disabled says this exists and needs a run; hidden says
                  nothing at all"*). But the WHY needs somewhere to sit, and that is form.

### 3 · ★★ THE STEPPED VALUE — and this is his *"rendering methods for R"*

**R's ladder is ruled and it is NOT LINEAR:** `5 · 15 · 25 · 50 · 100 · 150 · 300` (Battlewrath,
2026-08-22), floor 5 (`R_min = v_ceiling × POLL_MIN / 2`), ceiling 300.

⚠⚠ **A SLIDER IS THE WRONG KIND HERE AND THE ARITHMETIC SAYS SO.** The range is 60×. On a linear
slider the first three rungs — 5, 15, 25 — land inside the leftmost **7%** of the track, and 5 to 15
is *tripling the node*. The most-used end of the scale is the unusable end.

    COMPOSITION   stepper (`< >`) over the RUNGS **+ a typeable value box**
    ⚠ WHY BOTH    the rungs are the picker's OFFER, never a constraint on the field (§540) -
                  R is a distance and the store keeps a number, so 37 is legal and must
                  remain typeable. `Routes.StepR(from, by)` is built and walks the ladder
                  either way, holding at the ends rather than going dead.

★ **And the band is the same shape with different numbers:** 2.5 is both default and minimum
offered, the list runs upward, and it is an ADVANCED option at the foot (RI-35/RI-22). ⚠ Its
CEILING is deliberately unruled - see below.

### 4 · ★★ THE ROSTER — add · reorder · delete-guarded

**Ruled at A10.3c:** *"the child roster as a REGENERATED per-object group (name · ordinal · opacity
per row; reorder; up/down; delete guarded for child 1)."*

⚠ v8 shows tab **strips**; what the lane needs is tab **management**. *"Tabs on an object ARE the
action tabs"* (his, 2026-08-23), and rows are a LIST - `SetRow(b, child, index, …)` takes an index,
and every tier below the pane is list-shaped while the pane models one.

    COMPOSITION   a regenerated group: add · up/down · delete, with one member GUARDED
    ★ IT IS TWO LEVELS   the child roster on a node, and the tab roster on a child. Same
                          idiom, and A10.3c only names the outer one.

### ★★★ ON THE MAP PINS — yes, and one half of it cannot be drawn

R renders as a **circle on the canvas** and that is straightforward: the CANVAS kind is already
written (`ui_custom_controls_inventory` §3, `concepts/coalesce.md`), `map.lua:280` records that at
Shadowfang floor 6's 0.198 yd/px a 5-yard radius is ~25 px, and *"R is DRAWN"* is already on the
map's own backlog in his words.

⚠⚠ **BUT THE BAND CANNOT RENDER ON A MAP, AND A DRAWN CIRCLE WILL IMPLY IT DID.** The band is an
**upward-only vertical tolerance** (RI-22: a captured sample IS the floor, so downward measures
nothing). A map is a 2D projection. ⟶ **Two nodes at the same x,y on different heights draw as one
circle**, and the catwalk-over-the-entry case is exactly that (RI-56, and floor is an AREA not a
storey - measured).

    ☐ THE HONEST FORM   the map shows R; the height is shown NUMERICALLY or not at all, and
                        the surface SAYS which. A circle that silently means "and some
                        unspecified amount of up" is a picture that lies.
    ★ AND IT IS WORSE THAN AMBIGUOUS RIGHT NOW: the band's CEILING is deliberately unruled
      (RI-56) because the corpus cannot derive it - it needs a purpose-built pin capture.
      **So a rendered band would be drawing a bound nobody has set.**

### What the bench can settle without this seat

★ `ui_custom_controls_inventory` names four things NOT surveyed, and two of them are the bench's:
**`drive.lua`'s readouts and `widget.lua`'s remote.** Say the word and they get read for kind / coat
/ composition and filed here - the Addon creator can survey its own panes, and *"nobody has read them
for this"* is a gap the bench can close rather than request.

---
## UI-1 RESOLVED (ui, 2026-08-24) → `UI_LOG.md` UL-17 · none of the three — the DERIVER was wrong, the data was always on grid · ⓘ its *18 calibration records held uncommitted* line is SPENT — Battlewrath, 2026-08-25: *"The 18 was entered when you fixed the tool surrounding them"* — it described the mid-fix moment, not a hold. 103 records tracked, tree clean, `check_sheet` green

_Filed by the **Addon creator**, 2026-08-24. **Nothing was discarded and nothing was committed.** The
files are on disk, untracked, exactly as your captures left them._

**THE HAND-OFF, one sentence:** your calibration captures are complete and clean, but committing the
18 new `__sheet` records takes `check_sheet` from green to red — so the bench pushed everything else
and left these for you to **commit or discard**.

### WHAT WAS MEASURED

    py addons/tools/check_sheet.py                 exit 1
    check_sheet: no common grid in this configuration's widths - the model cannot
    be expressed in quanta, so nothing below would mean anything

★ **AND IT WAS ISOLATED RATHER THAN ASSUMED.** The 18 are untracked, so they were MOVED aside, the
checker re-run, and all 18 restored:

    without the 18 new records  ->  exit 0

⟶ **The committed tree is green; these introduce the failure.** The bench did not read that off the
diff — it moved the files and looked.

### THE FINDING, and it is specific

    config  resolution     scale  runs  widths   grid
       8    3620x2036      0.64     2    286     yes
       9    3620x2036      0.82     1    286     yes
      10    3620x2036      0.85     8    286     yes
      11    3620x2036      0.86    16    286     yes
      12    3620x2036      1.0      4    286     ⚠ NO COMMON GRID

★ **Every other scale at that same resolution resolves cleanly.** It is `1.0` at `3620x2036`, on 4
runs, and nothing else.

⚠⚠ **AND THE REFUSAL IS TOTAL, WHICH IS THE REAL COST.** The tool stops before reporting anything
downstream — *"nothing below would mean anything"* — so committing these does not merely add a red
checker, it **blinds `check_sheet`'s whole report** until the configuration is answered. That, rather
than the 5.4 MB, is why the bench held them.

### WHAT THE BENCH ALREADY DID

    ✓ credential / email / absolute-user-path scan across all 18   clean
    ✓ `_provenance` present on every one (sha256 · source · source_mtime)
    ✓ `check_landing` — devdump is `stage=tracked -> records`, so they are in their RULED home
    ✓ everything else pushed: 101 commits, 29/29 smokes, 343/350 mutations, walk PASS

★ So there is no cleanliness question and no destination question. **Only the grid.**

### ☐ THE DECISION

The tool names its own two exits, and both are this seat's rather than the bench's:

    MORE RUNS      capture `3620x2036 @ 1.0` again (`/coadump r sheet`, `/reload`) so the
                   configuration has enough widths to quantise
    GROW THE       append to `sheet_decl.lua` and re-capture — if 1.0 at that resolution is
    STANDARD       genuinely not on a grid, the standard is what has to say so

⚠ **A third answer is legitimate and the bench cannot pick it either: COMMIT THEM RED.** A checker
that refuses loudly is doing its job, and a real finding parked outside the tree is a finding nobody
trips over. ⟶ The bench's read is that the total refusal argues against it — but that is a read, not
a ruling, and the seat that took the measurements is better placed to weigh it.

**Say which and the bench will do it**, or do it yourself — the files are untracked and yours to move.

---
