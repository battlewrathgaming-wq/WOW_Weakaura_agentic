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

## ★★★ The waterfall

    model         what these things ARE                    dungeonrun_model.md ← THE HEADING
         ↓
    inventory     what exists to work them, per surface     ← this file, and interface/*.md
         ↓  hopes    what a surface still needs so the model can be realized
    devlog        why it is, and how it got argued          interface/devlog/

★★ **Each surface exists so the model can be realized.** That is what its `does` slot is
answering, and it is why the hopes sit at its foot rather than in a list of their own — a hope is
**what this surface still needs in order to serve the model**.

⚠ The mission lives in the model's header, not here and not in six places.

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

## ⚠ OPEN — where view-state lives

> *"I don't want editing to be whack a mole vs 3 different surfaces."*

Three surfaces already touch what you see, and two proposed enrichments have no obvious home:

| surface | what it changes today |
|---|---|
| **Curation** | which data types are drawn, and which slice of TIME |
| **Map controls** | zoom, pan, recentre — and the two input opt-ins |
| **the Map itself** | which layers are loaded, the selection, the floor |

**Homeless:** same-height plane tinting with a user-claimed colour, and detector radii drawn
around beacons and children.

★ **A candidate axis, offered rather than ruled:**

    Curation        changes WHAT DATA is in view      — legibility of the record
    Map controls    changes WHERE THE VIEW IS         — the viewport

⚠ On that line both enrichments are **Curation's**: a plane tint and a detector radius are about
reading the data, not about positioning the camera. ★ And it would give Map controls a reason to
stay small, which is the whack-a-mole defence.

⚠⚠ **NOT DECIDED.** Recorded so the next enrichment has somewhere to be argued rather than being
placed wherever there was room — which is how three surfaces became three surfaces.

---

## Not surfaces

★ Top-level frames that are **machinery**, not something anyone looks at. Declared here because
`check_interface.py` reports any `UIParent` frame with no surface file, and an exemption belongs
on disk rather than hardcoded in the tool.

| frame | what it is |
|---|---|
| `COA_DungeonRunUIStepper` | `ui.lua`'s transient `OnUpdate` host for a test plan. Created hidden, script installed on run and cleared at the end — zero persistent OnUpdate is the bench standard and the census counts installs against clears |

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

## The three registers

★★★ **Hopes → devlog → inventory.** Each has a home, and mixing them is what blurred before:

| | where | what it holds |
|---|---|---|
| **hopes** | the foot of each surface file | what it should hold and do. Not technical |
| **devlog** | `interface/devlog/<surface>/<feature>.md` | why it is, and how it got argued. Including the wrong turns |
| **inventory** | `interface/<surface>.md` | what IS, or what is declared for code to comply with |

> *"I feel it's partly your 'Why it is'. And I think it can be the middle ground of hopes and
> implementation. The messy space that things get developed and comment logged into."*

★★ **A folder per surface, a file per feature** — *"we can dump reasoning into a feature there
before it gets built. And then annotate what fell out of it."*

⚠ **The devlog is not an authority.** When something settles it moves to the factual file; the
devlog keeps the reasoning, never the ruling. If the two disagree, the factual file wins.

★ **The wrong turns are the point.** A settled fact says what to do; the argument says why the
other options were rejected — which is what stops them being re-proposed in six weeks.

⚠ Created only where there is content. **Map** and **Map controls** have none: nothing has been
developed about them yet, only described.

---

## Each surface carries its own footer

★★★ **One place to inspect what is true and what is outstanding.** Every surface file ends with
two sections, and the split keeps the registers visible:

| | |
|---|---|
| **Outstanding** | ☐ items — the code disagrees with the file, or something declared is not built. A JOB. **Emitted** by `emit_outstanding.py` from the marks in place, never typed |
| **Hopes and dreams** | authored, and deliberately **not technical**. What the surface should hold and do |

> *"Their not technical in nature. Their expressions of what it should hold and do. The backlog
> to realize."*

⚠ **Two markers, because one was doing two jobs.** ☐ is a job; ⚠ is a caution that is nobody's
job — *the grab area is four times the visual* is true, deliberate, and will never be "done".
A blanket ⚠ scrape produced noise for exactly that reason.

★ **The outstanding half is emitted so the same fact never lives twice.** The mark stays beside
the row it is about; the footer collects. `py addons/tools/emit_outstanding.py --check` fails if
a footer is stale.

⚠ **Where he has said nothing about a surface, its hopes section is EMPTY and says so.**
Inventing them would put fiction in the one place meant to read as direction.

---

## Keeping it current

**Bench menu → [7] Reconcile.** Read-only, five checks, nothing changed.

| | |
|---|---|
| `check_interface.py` | the surface docs against the source — file, global, declared size, every citation, and any pane with no surface file |
| ↳ **and the spec** | every cell `panespec.lua` builds against the width and height the surface file declares. ★ **Direction matters**: the file is the authority, so a difference reads as *the spec has drifted*, never as *the doc is out of date* |
| `emit_outstanding.py --check` | a stale ☐ footer |
| `emit_notes.py --reach` | tagged notes reach the shelf; no dangling citation |
| `emit_addon_census.py --check` | the declared-surface census |
| `deploy.py` | repo against client |

★★★ **LAG IS EXPECTED, AND IT IS NOT A FAULT.** His framing:

> *"Curation of input is still needed. But so it's not justification. It's fact that there will
> be lag during active development. But so we can reconcile and shake out what proved false
> rather than keep building on them."*

⚠ **So it reports DRIFT, never failure, and it does not assume the code is right.** This file is
the authority — a difference is a question about which side moved, and the answer is often that
the code did something the declaration had not caught up with.

⚠ **And it only checks the mechanical part.** Whether `does`, `refuses` or `how` are still true
is curation, and a tool that claimed to check them would be exactly the justification he warned
against.

★★★ **THE POSITIONAL VALUES ARE THE CHURN, AND THAT IS WHY THEY GET A CHECK.** His:

> *"Those are the values that will change a lot, positional. Stable value assignments that need
> to alter as we build. Code is more specific to how it ties into the next so isn't fit for
> emitting."*

⚠ So the numbers are **declared in both registers and generated in neither**. `panespec.lua` is
not a source of truth — it is the code complying with the surface file — and the machine only
reports when the two disagree. ★ Emitting the spec FROM the doc was considered and rejected: the
spec carries `hidden` predicates and zone structure, which are how one thing ties into the next,
and that is not fit for emitting.

★ **It earned itself immediately**: on its first run it found **29 points of drift**, 27 of them
citations that had rotted within hours of being written — `object.lua`'s all +1 from a comment
that grew, `promoter.lua`'s all −1 from a `local` that was removed. The format is phrases now.

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
| ☐ **outstanding, all surfaces** | **13** — `py addons/tools/emit_outstanding.py` |

★★★ **The geometry probe can only ask about registered controls**, so the counts above are the
measure of how much of the interface is invisible to it. §103's walker fixes the *instrument* — it
enumerates a pane's children rather than trusting the registry — but a control still needs a name
here to be reasoned about.
