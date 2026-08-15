# DungeonRun interface inventory — the collating index

★★★ **This is the AUTHORITY, not a report.** It is not generated from the code and does not mirror
it. The code complies with what is written here; where the two disagree, **the code is wrong**
until we decide otherwise.

> *"Once made, the inventory is authority / source of truth until our consideration changes."*

★★ **And nothing reaches the client that is not in here first.**

> *"It is allocated on the disk first, then makes it in-game after geometry checks. […] If we don't
> know how we'll track it, don't add it to the game until we know how."*

★★★ **What it is for:**

> *"Collating all the abstracts into a fixed reasoning space."*

⚠ Which is why every seeding pass has found something. A number in a source file is a fact about
that file; the same number written here has to sit beside the others and answer to them. Curation's
dead space, three unregistered dropdowns, an orphaned header, a 5px nudge nobody could explain —
none were hidden. They were never in one place at one scale.

---

## The two registers

★★ **This file is FACTUAL. `addons/maps/intent.md` is DIRECTIONAL.**

> *"There is a line - thoughts and what enters code. Intent - as is the very word use, is
> directional. Inventory is our factual basis. We didn't have a home for it before."*

⚠ `intent.md` may carry a rule with **no code behind it** — a forecast. **This file may not.**
Every row describes something that exists, or something declared that the code must comply with.
A wish does not belong in the factual basis.

---

## The surfaces

★★★ **One file per surface**, because seven surfaces described at depth is not one document. Each
holds what that surface **does**, **how** it achieves it, what it **refuses**, what it **holds**,
how you **interact** with it, and every child with its numbers and how it forms in code.

> *"So if I ask you how something works. We have already formed the answer. (And so we have a
> reasoning space over the code and it's function whole, rather than per source trace.)"*

| surface | file | size | state |
|---|---|---|---|
| **Recorder Remote** | [`interface/remote.md`](interface/remote.md) | 240 × 124 | ⚠ rename pending |
| **Map** | [`interface/map.md`](interface/map.md) | **rule** → 1034 × 722 | |
| **Map controls** | [`interface/map_controls.md`](interface/map_controls.md) | 240 × 168 | |
| **Curation** | [`interface/curation.md`](interface/curation.md) | 320 × 366 | ⚠ content still laid out for 280 |
| **Promotion** | [`interface/promotion.md`](interface/promotion.md) | 320 × 400 | |
| **Object** | [`interface/object.md`](interface/object.md) | 240 × 600 | ★ the only one declared in `panespec.lua` |

⚠ **The Driver was removed in §113.** It is not a surface; `driver.lua` and `walk.lua` left with
the debugging suite. See [`debug_suite_plan.md`](debug_suite_plan.md).

★ **Six, enumerated from source** — every top-level frame parented to `UIParent`. The list this
replaced was written from memory: it named three, conflated `widget.lua` with `map.lua`'s controls,
and missed the map frame entirely.

---

## ★★★ The opening chain

    Recorder Remote ── starts a run
                    └─ opens Map ─┬─ opens Map controls
                                  └─ opens Curation ── opens Promotion ── mints into Object

★★ **The Remote is the only front door**, so everything downstream is reachable only through it. A
change there is a change to whether the rest of the addon can be reached at all.

⚠⚠ **And the panes OVERLAP on screen.** Curation, Promotion and Object are `DIALOG` + toplevel; the
Map is `HIGH`. So the three draw over the Map, and its own **"Controls"** and **"Curate"** buttons
read through wherever their backdrops are not opaque. ★ That is what he saw and reported as text
across the Curation tab labels — not that pane's widgets at all.

⚠ **No check can see that.** Every geometry check asks whether *one* pane is internally consistent.
Nothing asks whether two panes collide on screen, and no per-pane pass ever can.

---

## Shared vocabulary

**The slots.** Placement and identity:

| slot | what it expresses |
|---|---|
| **pane** · **zone** · **row** | where it sits in the structure |
| **span** | `full` · `left` · `right` — never an x |
| **kind** | dropdown · edit · check · button · readout |
| **subjects** | when it applies |
| **numbers** | the settled values, so the geometry tool has something to **assert** |
| **forms** | the code that makes it exist, and what it is wired to |

And function, per surface: **does** · **how** · **interacts** · **holds** · **refuses**.

Two slots a **pane** has that a child does not:

| slot | what it expresses |
|---|---|
| **column** | the content x and usable width every child's `span` resolves against |
| **relates** | ties to other panes — shared edges, stacking, what opens what |

★★★ **No pixels in the intent slots.** A `108` expresses *"second column"* — write the 108 and we
keep the arithmetic and lose the reason. `layout.lua` derives every offset from its constants.

★★★ **`numbers` and `forms` sit adjacent on purpose.** That adjacency caught the field-vs-art bug:
`forms` said `SetWidth(200)` and `numbers` said the art is 250, and the play button was sitting in
the 50 nobody had accounted for.

---

## Constants, sourced

From the client's own panels (`Outputs/client_interface/patch-B/`):

    6    header → its own content      Ascension_AddonPanel/AddonPanelTemplates.xml
    8    row → row                     FrameXML/InterfaceOptionsPanels.xml
    12   zone → zone                   AddonPanelTemplates.xml
    24   a bigger break                recorded, not adopted

⚠ **A dropdown has three widths and they are not interchangeable**
(`SharedXML/UIDropDownMenu.lua:962`):

    field  w        the sunken area the selection reads in
    text   w - 25   the string inside that field
    art    w + 50   the frame, and the arrow that reacts to a click

⚠ **A control template carries a size only when the control has an inherent one.** Three of eight
declare none — `InputBoxTemplate`, `UIPanelButtonTemplate`, `UIPanelScrollFrameTemplate`. So
`Layout.H` is a default, never an authority.

---

## Standing counts

| | |
|---|---|
| surfaces | 6 — all with a file |
| declared in `panespec.lua` | **1** (Object) |
| ⚠ unregistered controls | **most of them** — the Map, Map controls, Curation and the Remote have none |
| ⚠⚠ unregistered **dropdowns** | **3** — `object.target`, `object.outcome`, `editor.run` |
| ⚠ in code, in no entry | 3 — `setBox`, `outcomeBox`, `stageGhost` |
| ⚠ orphaned saved key | `driverPos`, from the removed Driver |

★★★ **The geometry probe can only ask about registered controls**, so the counts above are the
measure of how much of the interface is invisible to it. §103's walker fixes the *instrument* — it
enumerates a pane's children rather than trusting the registry — but a control still needs a name
here to be reasoned about.
