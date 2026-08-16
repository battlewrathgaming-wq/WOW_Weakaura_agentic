# WeakAuras' options UI — the idioms, and what each one answers

_**WeakAuras 5.21.2 Beta** as it ships on this client. Shapes read from screenshots, 2026-08-16;
every NUMBER read from `Interface/AddOns/WeakAurasOptions` and `AceGUI-3.0` on disk._

★★★ **Why this file exists.** Battlewrath: *"Sharing weakauras with you from sight. Showing you how
they handle a lot of this. And the trends (Why I wanted weak aura basis)."*

★★ **This is the fork's OWN WeakAuras**, not a style reference from outside — so it is the
authority on what this client's UI idiom is. A pane built in these shapes is one a user has
already learned to read.

⚠⚠ **AND I SAID THESE HAD NO NUMBERS.** They do. Battlewrath: *"It's not - not a number. You're
just no reached for it. We have the addon as reference."* The addon is on disk at
`Interface/AddOns/WeakAurasOptions` and every constant below is READ FROM ITS SOURCE — I had
proposed a probe and a capture to recover numbers that were already sitting in a file.

★★★ **Same shape as the very first lesson on this bench:** search our own basis before calling
something unverified. A screenshot is a secondary source when the primary one is installed.

---

## ★★★ THE WIDTH SYSTEM — the thing worth taking

    AceConfigDialog-3.0.lua   width_multiplier = 170     ONE control unit, in pixels
    WeakAuras/Init.lua        normalWidth = 1.3          so a normal control is 221
                              halfWidth   = 0.65                            110.5
                              doubleWidth = 2.6                             442

★★ **A control's width is a MULTIPLE, never a pixel count.** `width = "half"` gives
`width_multiplier / 2`, `"double"` gives `× 2`, `"full"` fills the row. Nothing in the options
tree types a width.

★★★ **AND THE PANE IS DERIVED FROM THE UNIT, NOT THE OTHER WAY ROUND.** `OptionsFrame.lua` anchors
the content container at

    container.frame:SetPoint("TOPLEFT", frame, "TOPRIGHT", -63 - WeakAuras.normalWidth * 340, 0)

340 is `2 × width_multiplier`, so the content column is **`normalWidth × 340 + 63`** wide — change
the width unit and the pane resizes to match its controls.

⚠⚠ **WE DO THIS BACKWARDS.** Our panes are 240 and 320 because someone typed 240 and 320, and every
control is then fitted into that by hand — which is why the Remote had four content boxes and
Promotion has four left edges. **Their pane is sized BY its controls; ours has controls fitted TO
the pane.** That is the trend behind all the others.

## The frame, measured from its own source

    defaultWidth  830     minWidth  750        OptionsFrame.lua
    defaultHeight 665     minHeight 240
    inset          17     left and right, every container
    bottom         10-12
    top           -63 / -65 / -67   title, filter box, tree
    tree width    170     buttonsContainer - EXACTLY one width unit
    tree -> content gap  17
    content top   -28     the tab strip's own band
    side panel    250     dynamicTextCodesFrame

## Widget geometry, from AceGUI-3.0

    EditBox      height 26 without a label, 44 WITH one
                 label at TOPLEFT (0, -2), height 18
                 the box itself sits at (7, -18) when labelled, (7, 0) when not
                 inner box height 19, inset 6 from the left
    CheckBox     24 tall plain; 28 + description height when it carries one
                 check square 24; description at TOPRIGHT of the box + (5, -21)
    Slider       44 tall - label 15, slider 15, value box 14
                 label spans the full width at TOPLEFT (0,0)
    Heading      18 tall, caption centred, two 8px rules either side
    Dropdown     list height + 34   (20 scrollframe + 14 item placement)

★★★ **THE LABEL COSTS 18 AND THE ROW GROWS TO FIT IT** — 26 becomes 44. That is the answer to
*"where does the label go"* stated as arithmetic: above, always, and the row pays for it.

---

## ★★★ THE FORMS THEY REACH FOR — counted across every display type

*"We also have from source exactly what forms they reach for in their display methods."* We do.
`RegionOptions/*` and `SubRegionOptions/*` declare every display's options as DATA, and the whole
vocabulary is eleven `type` values:

    range          92    a number with min / max / step
    toggle         65    a checkbox
    select         54    a dropdown
    point          54    an anchor-point picker
    input          44    a text field
    description    35    STATIC PROSE
    execute        28    a button
    color          22    a colour swatch
    header         15    A CAPTIONED RULE
    area            6    a multiline box
    multiselect     1    many-of

### ★★★ It answers the label question from source, and settles it

**`description` and `header` are option TYPES, in the same list as button and dropdown.** A static
descriptor is not a lesser thing that sits beside a control — it is an ENTRY, ordered among the
others, and so is a zone caption. 35 descriptions and 15 headers against 28 buttons: the furniture
is not an afterthought in their vocabulary, it is *more* of the surface than the buttons are.

★ Which is the same conclusion §135 reached the slow way — a label is static, a readout responsive —
arrived at here as a fact about how the client's own UI is built.

### And our vocabulary is nearly theirs, arrived at independently

    execute      -> action
    toggle       -> selection · tick
    select       -> selection · dropdown
    range        -> selection · range
    input/area   -> input · free / identifying
    description  -> label
    header       -> the zone caption we have been calling a divider

### ⚠⚠ What we have and they do not: `arm` — and the reason is the whole difference

Nothing in their eleven holds a state open. Battlewrath, on why:

> *"They don't need it. They read the game state to trigger these auras. Where we tell a system to
> read the game in the absence of triggers or permission."*

★★★ **A WeakAura is DECLARATIVE against events the client already emits.** It says *when this is
true, show this* — so there is nothing to turn on, and `arm` would be a control with no job.

★★★ **We are a recorder where there is no event to declare against.** The pin exists precisely
because the client is silent, and a run has to be started by a person because nothing else is
going to say when it began. **`arm` is not a richer vocabulary — it is the shape of a tool that
reads the game rather than one the game notifies.**

⚠ **And the arms on the AUTHORING panes are not that.** `object.move`, `object.pick`, peek, latch,
play hold state open because of how they were built:

> *"We use arm for move because that's how we made it, not that it's optimal. (But it works for us.
> Keep things static until you want to move it.)"*

★ So there are **two arms** and only one of them is structural. `remote.arm` is forced by the
absence of a trigger. The rest are a build choice with a defensible principle behind it — keep a
thing static until you ask for it — and they are not evidence for anything.

⚠⚠ **What they have and we do not:** `color`, `point` (an anchor picker — 54 uses, the third most
common thing in the whole options tree), and `multiselect`. `point` is worth its own look: the map
and the object pane both ask *where*, and the client's own UI has a form for that question.

### Width is declared 340 times and typed 30

    WeakAuras.normalWidth   240 uses
    WeakAuras.doubleWidth    51
    indentWidth (0.15)       39
    WeakAuras.halfWidth       4
    raw pixels             ~30    and nearly all of those are icon sizes - 32, 48, 64

★★ **A raw number is the exception and it is reserved for things that are genuinely a size**, not a
layout. Everything that is layout is a multiple of the unit.

### A property is a DESCRIPTOR, not code

`RegionPrototype.AddProperties` declares each animatable/conditional property as a table:

    display   the human label
    setter    or `action` - the function that applies it
    type      number · string · sound · chat · customcode · glowexternal · progressSource
    limits    min · max · softMin · softMax · bigStep · isPercent · validate

★★★ **This is the seven-slot question, already answered in a shipping addon.** The model banked
*act · response type · response time · has effect · duration · exit · outcome* as a theoretical.
Theirs is narrower — `display · setter · type · limits` — and the UI is GENERATED from it. ⚠ The
lesson is not that ours should be theirs; it is that the descriptor pays for itself only when
something reads it, and here the options window IS the reader.

---

## The idioms

### ★★★ Zones are TABS first, then captioned rules

Eight tabs in two rows — `Group · Display · Trigger · Conditions · Actions` over
`Animations · Load · Custom Options · Information`. Inside a tab, sections are announced twice
over:

    ▼ Dynamic Group Settings          a collapsible header with a chevron
    ───── Bar Color Settings ─────    a centred caption ON a horizontal rule

Captions seen: *Bar Color Settings · Icon Settings · Spark Settings · Border Settings · Custom
Functions · On Show · On Hide · General · Player · Start · Main · Finish · Compatibility Options ·
Enable Debug Log · Trigger Combination*.

★ **Answers:** *"Title labels and dividers. Zone designation over discreet text."* And it is the
answer to a 600px Object pane holding five zones in one scroll — WA does not scroll five zones, it
tabs them.

### The label sits ABOVE the field

`Grow` · `Align` · `Space` · `Sort` · `Bar Texture` · `Orientation` · `Spark Texture` — small, grey,
left-aligned, directly over the control it names.

★ **Answers:** the label question. WA keeps per-field labels AND zone headings; the labels simply
never compete for the row. ⚠ Which is a third position beside the two we had — not *"labels or
zones"* but *"labels above, zones over them"*.

### Free text COMMITS on a button

The `Event(s)` box and the `Custom Trigger` box each carry their own **Accept**; the code box adds
a red **Expand**.

★★ **Answers:** the defect found while registering — our edit boxes guard `OnTextChanged` on
`userInput`, so a typed value lands in the field and not in the route. WA's answer for anything
larger than a word is an explicit commit, which also gives a test line something to press.

### A toggle and the thing it governs pair across two columns

`Group by Frame` + its dropdown · `Enable Gradient` + `Gradient Orientation` · `Show Spark` + its
texture path. The switch on the left, what it controls on the right, one row.

### A range is `‹ value ›` — both arrows, always

`Space` · `Stagger` · `Limit` · `Group Scale` · `Group Alpha` · `Bar Alpha`. Never a bare slider.

★ **Answers:** what `selection · range` looks like — the two handles and the two step buttons in
Curation are the same family, built without the idiom.

### Negation is marked IN the label, in red

`! In Encounter` · `Not Mystic Enchant` · `! Not Spell Known`. A convention, not a second control.

### A colour is a swatch beside its name

`Bar Color/Gradient Start` · `Gradient End` · `Background Color`.

### A path field carries a browse button

`Group Icon` and `Spark Texture` both end in a folder button.

### The Load tab is Curation's filter problem, already solved

A two-column checkbox grid under `General` and `Player` captions — *In Combat · Alive · PvP Mode
Active · In Vehicle · Mounted* beside *Never · ! In Encounter · In Manastorm · Has Vehicle UI*.

★ **Answers:** the kind-ticks. Same job — say what applies — laid out as a grid under captions
rather than a column of lone checkboxes.

### The list on the left is a tree

Per-row icon, expand caret, and two small toggles on the right of every row. Groups nest and
collapse.

---

### ★★ Dependents are HIDDEN far more than they are disabled — and §49 agrees

Counted in `WeakAurasOptions`:

    hidden = ...     596 uses
    disabled = ...   160

Both exist, and both are functions of the current state rather than flags — `hidden = function(info,
...) return hiddenAll(data, info, ...) end`. ★ So the ratio is the ruling: **absent is the default
and disabled is the exception**, which is what §49 chose for the authoring panes without knowing
the client's own options UI had already landed there ~4:1.

⚠ It does not say WHICH exception. That is the remaining question, and it is answerable from the
same source whenever it matters — the 160 disabled sites are readable.
