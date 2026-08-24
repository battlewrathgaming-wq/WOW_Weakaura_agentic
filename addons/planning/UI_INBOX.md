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

## UI-2 · FOUR INPUTS THE AUTHORING SURFACE NEEDS, AND WHAT THE MAP CANNOT SAY ABOUT R

_Filed by the **Addon creator**, 2026-08-24, at his ask on seeing declaration v8 in game: *"Any
types of input you'd like, or behaviours? (Maybe the map pins with behaviours defined and some
rendering methods for R n and such?)"*_

★ **Each ask below is tied to a RULED requirement, not to taste.** *"A reported edge is not a
complaint about the registry — it is the registry's next entry."* These are the edges the authoring
lane hits; §4d's list is what it has to express (**6 choices per node, 4 per tab**).

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
## UI-1 · 18 CALIBRATION RECORDS ARE HELD UNCOMMITTED — they turn `check_sheet` red, and the call is yours

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
