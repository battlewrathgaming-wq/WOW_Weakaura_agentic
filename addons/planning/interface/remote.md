# Recorder Remote — the front door

_`widget.lua` · `COA_DungeonRunFrame` · **240 × 197** · page x=8, width 224_

★★★ **197, AND THE HEIGHT IS NOW A SUM.** 8 pad + **37 strip** (MEASURED — `check_sheet
--tabs`, specimen `remote`, ONE row at 240) + 4 + **140 page** + 8 pad. 124 was the hand-placed
layout's height and cannot hold a strip: the old heading was a font string, the strip is a widget.

★★★ **AND `content x=16, width 208` IS RETIRED — NOT MOVED, RETIRED.** The remote's content
is AceGUI's now, so the inset inside the page is **the library's to decide and not ours to
declare**. What is still ours is the PAGE: where it starts and how wide it is. ⟶ The 16 was a
real justification for a real decision; that decision is no longer at this level.
⚠ The ☐ below asking for a checker on the header's content box therefore **dissolved rather
than being done** — there is no longer a content box here for it to check.

★★★ **THE 16 WAS JUSTIFIED, AND IT IS KEPT HERE AS THE REASON THE REMOTE IS SMALL** — the
number itself went with the fold (above), the argument did not, and it is what AL-50's fixed
strip rests on. Every other surface declares 18.
*"The remote is more compact by nature. UI's that claim space prefer presentation over
compactness."* A gate is small and every pixel it takes is one it did not need; a pane that has
claimed a third of the screen owes structure back. See the model's *compactness and
presentation* section.

★★★ **The factual register.** What exists, or what the code must comply with.

★ **Reconciled by `check_interface.py`** — the file and global named above, the declared size, and every `forms · phrase` citation. Bench menu **[7] Reconcile**, or run it directly. ⚠ It checks the mechanical part only; whether `does`, `how` and `refuses` are still true is curation.

⚠ **The header still names the CURRENT file and global, not the declared ones** — deliberately. The checker reconciles against what exists; the rename is the ☐ below.

☐ **RENAME PENDING.** Declared `DungeonRun_Recorder_Remote`; the code still says
`COA_DungeonRunFrame` and `widget.lua`. Frame name, file name and every reference move together
or not at all.

> *"So it's DungeonRun_Recorder_Remote (Like a remote to a TV.) Then DungeonRun_Drive (The addon
> that people use just to run routes) will have _remote as its primary entry."*

★★ **`_Remote` is a PATTERN.** An addon's remote is the one surface that turns it on and reaches
everything else — small, always to hand, and not the thing itself. A TV remote is not the
television.

★★★ **THE STRIP IS BUILT AND THE `Run` TAB IS LIVE** (2026-08-25). An AceGUI `TabGroup` at
(0, -8), 240 wide, built from what has MOUNTED itself — and **the strip replaced the heading**,
his call: *"The strip is self descriptive."* `remote.title` is retired with it.

☐ **ONE TAB STILL OWED — Test drive.** `drive.lua` is still its own frame and the temporary
door in the Run mode still opens it (A10.2d: both, not or). The tab appears when drive mounts
itself; the door goes in the same move.
⚠ **The strip shows ONE tab today**, which is correct and not a defect: a mode that has not
folded has no tab, rather than a dead one.

☆ The line this replaces read *"TWO TABS OWED"* and carried a standing ⚠ that neither was
built (AL-49, from his structure of 2026-08-24; RI-76). The standing structure it named is
unchanged: **pane = THREE** (Curation · Promotion · Object) · **remote = its own widget, two
tabs** · **map = its own pane**. `interface/drive.md` carries the other side of this.

★★ **AND THE STRIP'S GRAMMAR IS FIXED** (AL-50, confirmed by Battlewrath 2026-08-24 — *"That all
tracks. Confirmed."*). The two tabs are **MODES OF ONE WIDGET**, not two panes sharing a frame:
**same texture, no undock, no per-tab return band.** The 240 carries a strip and no band.
⟶ This is a **NAMED exception** to AL-13's *"nothing is one-way"*, whose dock/undock grammar is
**scoped to the unified pane's groups**. ★ Named rather than silent, because a general reassurance
that quietly stops applying somewhere is worse than one that never promised.
⚠ The reason it is fixed is this file's own 16px justification — *"the remote is more compact by
nature"* — plus AL-7: the remote sits beside the flight so it does NOT claim UI, and an undockable
mode would create the third floating thing the remote exists to avoid.

---

## ★★★ The model — what it IS

**The Remote is a GATE OF ACTIVITY.** Two branches, and everything else is downstream of picking
one:

> *"It's a gate of activity. (I'm doing a run) or (I'm reviewing a run). Each branch from there."*

    I'm DOING a run      →  name it, arm it, pin what the client will not tell us
    I'm REVIEWING a run  →  open the Map, and the whole reviewing chain behind it

★★ **Which is why it is small, and why it must stay small.** A gate needs two doors, not a
control panel. Every control that is not one of the two branches is a control asking to be
somewhere else.

### ★★★ And nobody should have to know a command to use it

> *"A user shouldn't have to know every command or macro access we create. That's power user
> space."*

★ So the Remote is the **discoverable** path and the slash surface is the **power** path. ⚠ They
are not alternatives of equal standing: a slash command you have to already know is not a
surface, and anything reachable ONLY by typing is, by that fact, not available to most users.

### What falls out of it

| behaviour | why |
|---|---|
| **240 × 165, a strip and a page** | ★ the gate now says which branch you are ON, which is what a gate with two doors owes you. ⚠ It still grew two doors it did not declare — `options` (A10.1d) and `drive` (A10.5) — and folding them into a mode did not un-grow them: the MODEL above is the thing to revisit, not the buttons |
| **it is the only front door** | a gate is where you choose; everything downstream is behind a choice |
| **it opens the Map and nothing else** | reviewing is one branch, and the Map is its door — not five shortcuts to five panes |
| **it shows a count, never a judgement** | how many points, not whether that is enough |
| **it is not an editor** | choosing an activity is not doing it |

★ **The two branches are already in the layout**, though not marked as such: `name` · `pin` ·
`arm` · `count` serve DOING; `map` serves REVIEWING.

## does

1. **Starts and stops a run** — the capture.
2. **Pins a point** where the client emits no event and the player is the sensor.
3. **Names** the run being captured.
4. **Opens the Map**, which is the door to everything else.

## refuses

- ⚠ **It is not an editor.** Nothing about a captured point is changed here.
- ⚠ **It shows a count, not a judgement.** How many points, not whether that is enough.

## relates

★★★ **It is the ONLY front door.** Everything downstream is reachable only through it:

    Recorder Remote ── starts a run
                    └─ opens Map ─┬─ opens Map controls
                                  └─ opens Curation ── opens Promotion ── mints into Object

⚠ **So a change here is a change to whether the rest of the addon can be reached at all.**

## holds

    window pos     persists    Store.SetUI
    (arm state)    NOT held    it asks Capture every refresh

## children

```
remote.pane      kind frame   usage — (the surface itself)
                 does  the pane itself. `set("close")` hides it, `read` reports shown
                 ★ REGISTERED §128

remote.strip     kind readout   usage label     forms widget.lua · `strip = gui():Create("TabGroup")`
                 does  THE STRIP IS THE TITLE. `read` reports the live mode key
                 numbers TOPLEFT (0, -8) · w 240 · h 37 — ONE row, MEASURED
                 ★★★ IT REPLACED `remote.title`, his call 2026-08-25: *"The strip is self
                    descriptive."* Two tabs reading `Run` and `Test drive` say what the
                    widget IS and what it is DOING; a heading above them is a third line
                    saying less.
                 ⚠ THE TAB WIDTHS ARE NOT OURS and are not declared here. AceGUI sizes each
                    tab from its TEXT (`PanelTemplates_TabResize`). We declare the ROW; the
                    library divides it. A number here would be a measurement written down
                    as a decision — DR_Pane_5.

remote.mode      kind readout   usage readout   forms widget.lua · `host = gui():Create("SimpleGroup")`
                 does  the live mode's content. `read` reports which mode is built
                 numbers TOPLEFT (8, -49) · w 224 · h 108
                 ★★★ AND THE MODE'S CONTROLS ARE NOT CHILDREN OF THIS REGISTER — deliberately,
                    and this is the change of KIND the fold made.

                    ⟶ They are RELEASED and rebuilt on every switch (DR_Pane_2), so
                    there is no stable reference for a registry to hold. A key pointing at
                    a widget AceGUI has returned to its pool is worse than no key: it reads
                    live and answers about whatever now occupies that slot.

                    ★ So the MODE is the registered thing and what it contains is read
                    through it. `remote.pin`, `.name`, `.count`, `.arm`, `.map`, `.options`
                    and `.drive` are RETIRED as keys — the controls all still exist, and
                    every one of them is asserted in `smoke_dungeonrunwidget.lua`, which is
                    where their behaviour is now pinned instead.

                 ★★ WHAT THE RUN MODE HOLDS, in order, and NONE of them carries an x or a y:

                        pin       "Pin here", full width
                        name      the run name; LOCKS at capture
                        count     how many points so far
                        options   0.32 · map 0.30 · arm 0.36 — the footer trio
                        drive     ☆ TEMPORARY, full width — the door to `drive.lua`

                    ⚠⚠ RELATIVE WIDTHS, WHICH IS THE POINT. §144 shipped a SIX PIXEL OVERLAP
                    between `options` and `arm`, live, found by a human on a screenshot:
                    two identical 3-slice buttons read as ONE button with a missing end
                    cap. §145 then fixed it by hand-dragging — -82 w50, -136 w58, a 2px gap
                    four off the house GAP of 6. ⟶ Relative widths CANNOT overlap, and the
                    gap stops being a number anyone has to choose or defend.

                    ☆ `drive` GOES WHEN `drive.lua` MOUNTS ITSELF AS THE SECOND MODE. It was
                    on the title row before the fold, for a reason that has dissolved with
                    the row: *"the footer's numbers are his."* There is no hand-placed
                    footer now. A10.2d — both, not or, until the tab lands.

```

★★★ **THE HEADER SAID `content x=16, width 208` ALL ALONG — AND NOTHING EVER CHECKED IT.**
The code shipped `pin` at 20 w200 and `name` at 22 w190. Three numbers, three different content
boxes, and the one at the top of this file was the only one nobody was following. §145's drag did
not invent a form; it landed on what this document had already declared.

★★★ **THAT ☐ DISSOLVED RATHER THAN BEING DONE.** It read: *"`check_interface.py` does not
read the header's content box — it reconciles the file, the global and the declared SIZE, but not
the stated inset and width against the children's numbers."* Written because the header said
`content x=16, width 208` while the code shipped `pin` at 20 w200 and `name` at 22 w190.

⟶ **There is no content box here to check any more.** The controls carry no x and no width;
AceGUI places them. The checker gained nothing and lost nothing — the disagreement it would have
caught cannot now be written. ★ Recorded rather than deleted, because *"we did it"* and *"the
question stopped existing"* are different answers and only one of them transfers to the other
five surfaces, which are still hand-placed and still have real content boxes.
⚠ **So the check is still owed THERE** — filed against the panes that still declare one, not
against this file.

★★★ **AND THE ANCHOR NOTE IS RETIRED WITH THE ANCHORS.** It read *"three of its six children
are BOTTOM-anchored — count, arm and map. That is the right anchor for a footer row."* True of
the hand-placed layout, and now meaningless: **nothing in the mode is anchored by us at all.**
AceGUI's Flow layout places every control, and DR_Pane_4 says placement within is the
library's. ⟶ The only anchors left in this file are the strip's and the page's, which are the
two things the frame still owns.

★ **All three registered keys are live** — `remote.pane`, `remote.strip`, `remote.mode`. The
probe sees the front door, which mode it is in, and that it is in one.

---

## Outstanding

<!-- OUTSTANDING:BEGIN - emitted by emit_outstanding.py, do not edit by hand -->

2 items:

- RENAME PENDING. Declared `DungeonRun_Recorder_Remote`; the code still says `COA_DungeonRunFrame` and `widget.lua`. Frame name, file name and every reference move together or not at all.
- ONE TAB STILL OWED — Test drive. `drive.lua` is still its own frame and the temporary door in the Run mode still opens it (A10.2d: both, not or). The tab appears when drive mounts itself; the door goes in the same move. ⚠ The strip shows ONE tab today, which is correct and not a defect: a mode that has not folded has no tab, rather than a dead one.

<!-- OUTSTANDING:END -->

---

## Hopes and dreams

_What this surface still needs so **the model** can be realized (`dungeonrun_model.md`). Not technical — the backlog to realize._

- **It becomes `DungeonRun_Recorder_Remote`.** A remote to a TV — the one surface that turns
  the recorder on and reaches everything else.

  > *"So it's DungeonRun_Recorder_Remote (Like a remote to a TV.) Then DungeonRun_Drive (The
  > addon that people use just to run routes) will have _remote as its primary entry."*

- **And it gets a sibling.** A second addon for players who only want to run a route, with a
  remote of its own. This one records; that one drives.
