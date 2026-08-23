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

## ★★★ DECIDED — where view-state lives: FILTER vs GENERATE

> *"I think the clean cut is. Curation can filter from the data set. Map controls can generate
> better reading through population."*

| surface | it does this to the picture |
|---|---|
| **Curation** | **FILTERS from the data set** — subtractive. Which captured data is present |
| **Map controls** | **GENERATES reading aids through population** — additive. Things drawn that are not in the capture |

★★ **The test is one question:** *does it change WHICH captured data is present, or does it draw
something that was never captured?*

    combat / travel leg ticks     remove data from view          → Curation
    the time envelope and window  remove data from view, by time → Curation
    zoom, pan, recentre           neither; it aids reading       → Map controls
    detector radii                DRAWN from a reach value       → Map controls
    same-height painted zones     COMPUTED from Z tolerance      → Map controls

★★★ **AND IT GIVES MAP CONTROLS A MODEL IT DID NOT HAVE.** It was described as a view pad — nine
buttons and two ticks. On this cut it is **the surface that makes the picture more readable
without changing what is in it**, and magnification is simply the first member of that family
rather than the whole of it.

⚠ **This is what keeps it from being whack-a-mole.** His constraint: *"I don't want editing to be
whack a mole vs 3 different surfaces."* The cut is not a filing convention — it means a new
control has exactly one place it can go, decided by what it does rather than by where there was
room.

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

### ★★★ How wide a STRING is — the one number the offline model used to refuse

The scaling half is **community knowledge and is stated first on purpose**: 1 UI unit = 1/768 of the
screen height × a ratio; pixel-perfect scale = `768/vRes`; and ElvUI's `E.mult` — installed on this
client at `ElvUI/Core/PixelPerfect.lua` — simplifies to **`768/(vRes × scale)`, one DEVICE PIXEL in UI
units** (warcraft.wiki.gg *UI scaling*). Everything below sits on top of that, adding one term.

    TEXT_GRID_COLUMNS = 2560    a FontString width quantises to hRes/2560 DEVICE PIXELS
                                = GetScreenWidth()/2560 UI units = E.mult × hRes/2560

⚠⚠ **THIS LINE IS READ BY A MACHINE.** `check_sheet.py` parses `TEXT_GRID_COLUMNS` out of this file
rather than holding its own copy, and **refuses to run if it cannot find it** — so the doc and the
tool cannot quietly disagree. Rename it and the checker stops, which is the intended failure.

Measured over **nine** configurations — 5 resolutions, 3 aspect ratios, 4 UI scales — worst
disagreement `1.0e-07`. At a 2560-wide display the quantum is exactly one device pixel, which is
plausibly the constant's origin; ⚠ that is an **inference**, and nothing in the client's Lua carries a
2560. Re-derived from the captures on every run: `py addons\tools\check_sheet.py`.

★ **And the per-em constant depends on uiScale ALONE** — identical to four decimals across four
resolutions and three aspect ratios at one scale. ⚠⚠ It is **not smooth** in scale (0.64→0.65 jumps
14.608→15.853, non-overlapping plateaus), so **a scale that has not been measured must be measured,
never interpolated** — one `/coadump r sheet`.

⚠ Offline text is still not exact: held-out error 1 q on FRIZQT @ 12, up to 9 q on FRIZQT @ 10, because
our advances are unhinted and the client rasterises through FreeType. **Carry the error bar; do not
round it away.** Basis and reasoning: `ui_sheet_spec.md` · `UI_LOG.md` UL-1/UL-3.

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
| ★ registered controls | **96 of 96** — every declared control on every surface (§131, §133, §134) |
| patterns, and their MEASURED members | **5 keys, 22 members** — `kind` 2 · `handle` 2 · `step` 2 · `tile` 12 |
| ⚠ in code, in no entry | **1** — `stageGhost` (was 3; `setBox` and `outcomeBox` are now named) |
| ⚠ orphaned saved key | `driverPos`, from the removed Driver |
| ☐ **outstanding, all surfaces** | **18** — `py addons/tools/emit_outstanding.py` |

★★★ **The geometry probe can only ask about registered controls**, and that sentence used to be a
warning. §131 closed it: the walker enumerates a pane's children *and* every child now resolves to
a key, so a geometry row reads `mapcontrols.left` instead of `mapcontrols.(unregistered Button #4)`.

### ★★★ MEASURED — the greedy capture, §132

`records/20260816_053425_564__geom.json`, six panes open, taken live.

| | |
|---|---|
| registrations that received a frame | **84 of 84** — `oursMissing` is empty |
| panes walked | **6**, all shown, all rects matching the source exactly |
| children enumerated | **67** |
| of those, registered | **56** |
| of those, NOT registered | **11** — and all eleven are identified |

    map           6 children     0 unregistered
    mapcontrols  11 children     0 unregistered
    editor       20 children     9 unregistered   patterns · width pair · Close
    promoter      7 children     1 unregistered   Close
    object       19 children     1 unregistered   Close
    remote        4 children     0 unregistered

### ⚠⚠⚠ THE ROW FORMAT IS LOAD-BEARING, AND I BROKE IT AGAIN THE SAME DAY

§132 recorded that `object.test` was invisible to the checker because its row read `(footer)` where
the pattern wants `zone` or `kind`. **One commit later I wrote the five new rows INDENTED**, inside
prose rather than in the listing — and the checker reported them as *registered and in NO surface
file*, which is the same blindness from the other side.

★★★ **A DECLARED ROW STARTS AT COLUMN 0 AND ITS SECOND WORD IS `zone` OR `kind`.** That is the
contract, it is enforced by a regex in `check_interface.py`, and nothing else about the file is
checked. A row that is beautiful prose is not a row.

⚠ The lesson is not *"remember the format"* — I had just written the paragraph about the format.
It is that **a lesson recurs in a new shape and the new shape does not look like the lesson.** The
first was a wrong word in the right place; the second was the right words in the wrong column. Only
the checker saw both, which is the argument for running it before believing a document.

★★★ **THE COUNT WAS NOT INFLATED. IT WAS SHORT.** The suspicion was that 76-odd controls was too
many and containers were padding it. Measured: the eleven unregistered children are six pattern
members, two undeclared width buttons and three undeclared Close buttons — every one a real
control, none of them a container. ⚠ **A document drifts DOWNWARD, not upward** — things get built
and not written; nothing gets written and not built.

### ★★★ THE SECOND CAPTURE, §134 — the region loop verified

`records/20260816_055430_568__geom.json`, six panes open, **with a run loaded** this time.

| | |
|---|---|
| members enumerated | **164** — 67 children + **97 regions** |
| unregistered CHILDREN | **0** — the frame side is fully named |
| readouts measured, first time ever | **21** |
| unanchored rows | **0** — the handles had points, as predicted |

★★ **The readouts arrived with their text**, which is the thing the offline font model needs:
`editor.width` at 165.0 for *"window 18:29 of 0:00 - 18:29"*, `map.ref` at 313.8, `remote.title` at
79.7. Every one of those was unmeasurable this morning.

⚠ **AN EMPTY READOUT MEASURES 1 × 1.** Seven did — `object.stagematch`, `object.kids`,
`object.match`, `editor.hint` and three more were blank at capture. So a drift check on a readout
is only meaningful when the readout has content, and a capture taken on an idle pane will report
almost every one of them as a pixel. ★ Third appearance of the same law: **zero, absent, unanchored
and EMPTY are four different things that look alike in a record.**

### The 97 regions split cleanly

    55  Texture      template art — backdrops, dropdown pieces, check-button frames. NOT OURS.
    21  FontString   ★ ALL OURS, and none of them had a key
    21  FontString   the registered readouts

★★ **The 21 unregistered ones were the find.** Six are now declared (§134): the pane titles for
Promotion and the Object pane — *four surfaces declared a title and two did not* — plus the route
name label, §80's stage ghost, the running-order heading and the gaps line. Nine more are the
running order itself, now `promoter.order.1` … `.9`.

★★ **RULED (§135): a label is STATIC, a readout is RESPONSIVE.** The test is whether anything
calls SetText on it after build. Five rows retagged `usage label` — the four panes that name
THEMSELVES, plus `editor.showlabel`. `map.title` and `object.title` stay readouts: they name what
the pane is SHOWING, and they change.

★ The six remaining field labels stay unregistered — furniture, recorded here rather than given
rows: "stage" · "behaviour" · "on success" · "detect" · "carries over from the node" · "stage".
The region walk measures them anyway, key or no key.

★★★ **And the standing rule for text that is not furniture:** *"If it informs decision making, it
belongs in the readout box we'll be making in the footer space."* ⚠ Deliberately left there — the UI
side is going to be redone, and a taxonomy built now would be built against a surface about to change.

### ⚠⚠ AND THE CHECKER CANNOT SEE A COMPUTED REGISTRATION

`R(("promoter.order.%d"):format(i), row)` and `R("editor.kind." .. spec.key, cb)` are registered at
runtime and invisible to `check_interface.py`, which matches a literal string. Eleven live controls
sat outside the static score in both directions without a word. ★ **Only the capture proves them** —
which is the argument for the capture being part of the loop rather than an occasional check.

### ⚠⚠ THE INSTRUMENT HAD A HOLE: 21 READOUTS WERE NEVER MEASURED

`GetChildren` does not return FontStrings — they are REGIONS. The reference walk enumerates
children *and* regions; the pane walk enumerates children only. So every readout we own — a
quarter of the whole inventory — is registered, is reachable by a typed line, and **has never been
measured by our own probe.** ☐ raised on the Map, which holds the most of them.

★ The panes' own rects DID match the source on all six, so the offline model holds where it was
tested. That is a smaller claim than it looks: it tested the six frames whose numbers are typed in
one place each, and not one of the 21 things whose position is computed.

⚠ **THE FOUR PATTERNS ESCAPE THE SCORE.** A key holding `<...>` stands for a family — nine kind
ticks, two handles, two steps, twelve tiles — and the checker excludes it from both sides rather
than pretend one key is one control. That is right for the *count* and a hole in the *coverage*:
nothing verifies that a pattern's members exist at all. ☐ raised on Curation.

★★ **What the pass found is the argument for doing it.** Registering is a walk down every build
function, and it turned up eight buttons whose handles were thrown away, two reach boxes with no
key, two controls the document had marked *justify or cut*, a row the checker's own regex could not
see, and a citation pointing at the wrong widget. **None of those were visible from either side
alone** — they live exactly at the join the checker reads.
