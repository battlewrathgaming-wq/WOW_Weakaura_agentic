# CONCEPT HOME · `pane build` — how a pane is CONSTRUCTED, and what is true once it is DRAWN

_A HOME is an INDEX, never a second copy (AL-26, Battlewrath 2026-08-22: "a home is better than a
run-time cost — it's greppable and inspectable"). It says what the concept IS in a few lines, its
closed list, and POINTS at every place that rules or grades it. The pointed-at documents stay
authoritative; if this page and one of them disagree, the document is right and this page has
drifted. Opened 2026-08-25 by the UI specialist on his ask: *"maybe we need a concept page for how
UI construction and rendering should be performed."*_

## WHAT IT IS
**A pane is not built. It is DECLARED, and then rebuilt from the declaration whenever its content
changes.** Two halves, and confusing them is where every defect in this arc came from:

    CONSTRUCTION   how a pane comes to exist. Answerable OFFLINE, before anything runs.
    RENDERING      what is true once it has been through a draw. Answerable only in-client.

⚠ **The line between them is a DRAW.** A number you can compute from a declaration is construction;
a number that needed a frame on screen is rendering, and asking for it too early returns a plausible
zero rather than an error.

---

## THE CLOSED LIST · CONSTRUCTION — six, and each was paid for

    DR_Pane_1  WIDTH FLOWS DOWN, NEVER UP
       A container's `Fill` sets its child to the container's size; content never argues about
       width. The frame decides once, at the top. ⟶ A pane whose width comes from its content
       has no stable width at all - it has whatever this content happened to need.
       ★ Ours already: `COA_DungeonRun/options.lua:188-193` - paneSeat SetWidth + SetLayout("Fill").

    DR_Pane_2  A CONTENT SWAP IS A TEARDOWN, NOT A MUTATION
       `ReleaseChildren()` then rebuild. ⟶ The space a pane RESERVES is a property of the
       content CURRENTLY RENDERED, and mutating in place leaves that property deciding for
       content that is no longer there.
       ✗ NOT the PANE torn down - the pane persists; it is the CONTENT ON it that goes
       ✗ NOT an AceGUI-only law - `ReleaseChildren` is one library's spelling of it, and a
         raw-frame pane owes the same discipline with its own children
       ✗ NOT "nothing may ever be hidden" - the scroll bar IS hidden, deliberately, and
         that is the law working rather than an exception to it
       ✓ the pane keeps its identity, its position and its size across a swap
       ✓ the reserved space is RE-DECIDED from the content that now exists
       ✓ no state survives the swap, so none can disagree with what is on screen
       ★★ HIS EXAMPLE, 2026-08-25, and it is the reason the law was made: *"A pane that
       has an always built in scroll bar must preserve that space and hide it. A display on
       that pane only holds the scroll bar defined space whilst that is rendered content. WA
       does this with drop down content."* ⟶ `AceGUIWidget-DropDown.lua:138-152`:
       `viewheight < height` → `slider:Hide()` and the child anchors TOPRIGHT at **0**;
       otherwise `slider:Show()` and the child anchors at **-12**. Hidden, never destroyed;
       the CONTENT'S ANCHOR claims or yields the space.
       ⚠ THE TEXT NEEDED THIS. The Addon creator read *"teardown"* as the PANE, concluded a
       raw-frame pane could not obey (frames cannot be destroyed in this client) and filed
       that as an argument for the Ace fold. Wrong premise, wrong conclusion, and the words
       *"nothing is hidden in place"* beside a law whose own example HIDES something are what
       carried it there.

    DR_Pane_3  THE LAYOUT IS A DECLARATION THE MACHINE CAN CONTRADICT
       Coordinates are DATA, checked offline for overlap, overhang and containment before a client
       ever runs. ⚠ And the builder READS that declaration - a builder that keeps its own copy of
       the numbers is the second copy that drifts.

    DR_Pane_4  PLACEMENT WITHIN IS THE LIBRARY'S; THE ARRANGEMENT IS OURS
       AceGUI publishes Flow · List · Fill · Table. We do not write a layout engine; ours would be
       a coat. What is ours is which containers sit where, and why.

       ★★★ THE BOUNDARY, in his words (2026-08-25): *"We define the frame. And where the
       content is within Ace's form, it controls the content. The map isn't ace content. So
       earns being separate."*

           THE FRAME       OURS - position, backdrop, movability, size. It is a window,
                           and a window is the client's job.
           THE CONTENT     ACE'S, wherever Ace can FORM it - layout, teardown, the pool.
           THE EXCEPTION   content Ace cannot form EARNS its own frame.

       ★★ *"EARNS"* IS THE WHOLE WORD. Separateness is not a default and not a preference -
       it is a TEST a surface passes by having content no Ace form expresses. ⟶ The map:
       a scaled canvas with its own coordinate space and points at FRACTIONS of it. Flow,
       List, Fill and Table cannot say *"a point at 0.63, 0.41"*, so the map earns it.
       AL-49 reached the same answer from the *when* (steering, not authoring); this reaches
       it from the CONTENT, and two independent routes to one answer is the strongest form
       this project gets.

       ✗ NOT "our panes are separate windows" - that is where they HAPPEN to be, not a rule.
         All six are raw frames because they PREDATE the Ace decision, not because they
         earned anything
       ✗ NOT a licence to keep hand-placing inside a frame we define - the frame being ours
         says nothing about its contents
       ✗ NOT all-or-nothing per surface - the map's CANVAS earns separation; the map's
         CONTROLS are ordinary buttons and are Ace-formable inside the map's own frame
       ✓ one frame may hold BOTH: Ace content where Ace can form it, and non-Ace content
         where it cannot
       ✓ the remote is the ordinary case - our frame, and everything inside it Ace's
       ✓ reimplementing Ace's handling on raw frames is a COAT, whatever the frame is
         (`concepts/type-or-feature.md`; the bench wrote one on 2026-08-25 and reverted it -
         a hand-rolled release-and-rebuild, which is `ReleaseChildren` without the pool)

    DR_Pane_5  NEVER ARGUE A SIZE FROM A MEASUREMENT
       A measurement answers *does this fit TODAY*. It never answers *must the design be this way*.
       ⟶ A machine that PICKS a pane size promotes a fits-today number into a rule.

    10 A REGISTER IS A TABLE OF CONTENTS, NOT A DEFENCE
       Battlewrath, 2026-08-25: *"editing the UI is a table of contents rather than trying to
       justify the UI."* A surface register says **which controls, in what order, and what each
       is FOR**. ⟶ **Where a line is arguing for a placement, the placement is in the wrong
       hands** - the argument is not the problem, it is the TELL.
       ★ THE TEST, and it is one question: *if this justification were deleted, would anything
       be lost?* If yes, the number is ours and DR_Pane_4 says it should not be.
       ★★ IT IS NUMBERED 10 AND SITS ON THE CONSTRUCTION SIDE. Out of sequence deliberately:
       1-5 construction and 6-9 rendering are CITED across the bench, and renumbering to make
       this one read as 6 would break every citation to buy a tidier list.
       ✗ NOT a ban on WHY. A register carries what a control is FOR, what it REFUSES, and why it
         exists at all - that is MEANING, it is ours, and no library can hold it
       ✗ NOT retroactive on the hand-placed surfaces. Five of the six still declare real content
         boxes, and their numbers still need defending until they fold - a justification is only
         dead weight once the decision has moved
       ✗ NOT DR_Pane_5 restated. 5 says do not argue a size FROM a measurement; 10 says do not argue
         a placement AT ALL, because it is not yours to argue
       ✓ which controls, in what order, and what each is for
       ✓ a number that SURVIVES is one no library could own - the frame's own rect, the page's
         origin, the row the strip occupies
       ✓ the justification disappearing is the PROOF the fold worked, not a loss of record
       ★★★ THE EVIDENCE IS `interface/remote.md`, before and after 2026-08-25 (§665). It carried
       paragraphs defending numbers: *"-82 and w 50 are HIS, dragged on the board"*; a 2px gap
       *"four off the house GAP of 6 - outside the normaliser's tolerance, so it is read as a
       decision, not a tremor"*; and §144's SIX PIXEL OVERLAP, shipped live, two identical
       3-slice buttons reading as one button with a missing end cap. ⟶ The replacement is five
       lines and three fractions - `options 0.32 · map 0.30 · arm 0.36` - and **relative widths
       cannot overlap**, so the defence had nothing left to defend.

## THE CLOSED LIST · RENDERING — four, and three of them return a plausible wrong

    DR_Pane_6  A RECT IS NOT RESOLVED UNTIL IT HAS BEEN THROUGH A DRAW
       Create, show and read in one tick and you get zeros and "unplaced". ⟶ Measure a SHOWN frame,
       a frame later. ⚠ Report a not-yet-resolved value as **DEFERRED**, never as 0 - a zero that
       means "the layout has not happened" is indistinguishable in a file from a measured zero.

    DR_Pane_7  GEOMETRY LANDS ON A QUANTUM GRID - COMPARE WITH TOLERANCE, NEVER `==`
       `q = 3 x aspect / (10 x uiScale)` across, `q_v = 8 / (15 x uiScale)` down. Nothing comes back
       exactly integral. ⚠ An exact comparison returns FALSE while every number agrees, and it has
       done so three times on this bench.

    DR_Pane_8  A PANE THAT CAN SCROLL HAS TWO WIDTHS
       A scrollbar appears at `content >= viewport + 2` and takes 20 off the usable width; the
       narrower content then wraps TALLER. ⟶ Budget the minus-20 width for anything that might
       scroll. ★ With DR_Pane_1 in place the flip moves the inner column ONLY - the pane does not move.
       ✗ NOT a separate law from 2 - it is the SAME FACT from the other side. 8 says the
         reserved space exists; 2 says WHEN it is decided. A pane that mutates content in
         place has DR_Pane_8's number and no moment at which to re-read it
       ✗ NOT a property of the PANE - the pane's width does not change; the usable width does
       ✓ the ±20 belongs to the CONTENT CURRENTLY RENDERED, and only while it is rendered
       ✓ a mode/tab swap is the moment it is re-decided, which is why 2 requires a rebuild

    DR_Pane_9  A PANE HAS TWO NATURES AND A RUN MUST SERVE BOTH
       The MEASURED half (build, read, release) and the LOOKED-AT half (persistent, on screen).
       ⚠ Building, measuring and releasing produces a correct record and an EMPTY pane - three
       separate defects on this bench came from shipping only the first.

---

## WHERE IT IS RULED AND GRADED — read these; this page only points
    UL-30   width flows down · a swap is a teardown        WA `OptionsFrame.lua:1197-1231`,
                                                           `AceGUI-3.0.lua:665-674` (Fill)
    UL-25   the layout is declared, and READ               `check_layout.py`, `sheet_decl.lua` `pane`
    UL-16   a measurement is of TODAY                      his distinction, and the correction to mine
    UL-21   the cliff, and the two widths                  `AceGUIContainer-ScrollFrame.lua` :102 :114
                                                           :117 :183
    UL-24   `==` on a scaled float                         and its two ancestors, §578 · derive_quantum
    UL-28   DEFERRED, never 0                              and a progress line that counted an empty run
    UL-13   the looked-at half                             *"No tabs seen"* - the run was correct
    UL-14   rebuilt on every toggle, WA's model            the collapse board
    ui_sheet_spec.md                                       the two natures, named before either was built

## THE TWO PAGES THAT OPERATE ONE LEVEL BELOW THIS ONE
    concepts/art-and-rect.md   the picture is not the box - a control's drawn art vs its rect
    concepts/row.md            what shares a line, and what earns one

## THE SKILL THAT MAKES DR_Pane_3 FIRE
`layout` — **standing practice on sheet work.** ⚠ The overlap check existed in three places and was
reached for zero times before it was fronted by a skill; a law nobody invokes is a law that fails
quietly. `py addons/tools/check_layout.py`.

## WHAT THIS PAGE DOES NOT CLAIM
That these are all the laws, or that they are settled beyond revision. ⚠ Two are OPEN right now:
- **The gutter, A or B** — flip the inner width or reserve it always. `UL-22` posed it, `UL-29`
  measured the cost (a permanent extra text line), `UL-30` showed the architecture makes it smaller
  than it looked. **Battlewrath's call, unmade.**
- **Whether raw-frame panes sit inside the `Fill` guarantee.** `object.lua` builds `CreateFrame`
  children with hand-typed widths, not AceGUI children. Whether DR_Pane_1 reaches them is the Addon
  creator's structure, and nobody has answered it.
