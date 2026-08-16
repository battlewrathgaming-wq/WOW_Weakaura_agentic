# WeakAuras' options UI — the idioms, and what each one answers

_Read from screenshots of **WeakAuras 5.21.2 Beta** as it ships on this client, 2026-08-16._

★★★ **Why this file exists.** Battlewrath: *"Sharing weakauras with you from sight. Showing you how
they handle a lot of this. And the trends (Why I wanted weak aura basis)."*

★★ **This is the fork's OWN WeakAuras**, not a style reference from outside — so it is the
authority on what this client's UI idiom is. A pane built in these shapes is one a user has
already learned to read.

⚠⚠ **READ FROM PICTURES, NOT MEASURED.** Every entry below is a SHAPE, and not one of them carries
a number. Paddings, insets, row heights and label offsets are unknown here and must not be
inferred from a screenshot. ☐ `task_geom`'s reference walk already measures the client's own
panels by name — pointing it at `WeakAurasOptions` would turn this file's shapes into constants.

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

## ☐ What this file cannot tell us

- **No numbers.** Shapes only. Measuring `WeakAurasOptions` with the existing reference walk is one
  probe change away and would make this file's idioms into constants.
- **Whether dependent controls are hidden or disabled.** `Gradient Orientation` sits beside
  `Enable Gradient` unticked; a screenshot cannot say whether it is greyed. ⚠ That matters — §49
  chose ABSENT rather than disabled for authoring panes, and if WA disables, the two idioms
  disagree and the reason is worth knowing.
