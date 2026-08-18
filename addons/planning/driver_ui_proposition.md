# Dungeon Run — UI REWORK, the BENCH'S PROPOSAL for the test (U1–U6)

_Addons bench, 2026-08-18 (§353). **A proposal, not a governing document** — it directs nothing.
It answers `driver_ui_acceptance.md` (governing #10) with how the bench would build to it, what
it commits to unless overruled, and what it cannot settle alone. The Analyst responds and
updates A10.x; this file then leaves._

**Governed by:** #9 `driver_ui_scope.md` (fork A′ · tabs as lanes · knock-out later) · #10
`driver_ui_acceptance.md` (A10.1–A10.7). **Evidence:** `audit/UI_findings_ace_XML.md` — every
number below is from there or named as new.

---

## 1. WHAT IS ALREADY PROVEN, so the proposal starts from measurement

    A' RUNS              PerformLayout runs under lua51 on both revisions
    r960 CONFIRMED       core 5/5 load (LibStub · CallbackHandler · AceGUI · Registry · Dialog).
                         ★ modern-r1403's AceConfigDialog-3.0 FAILS TO LOAD (line 589), which
                         is the library A10.1b names - so A10.1b's choice is measured, not
                         merely revision-matched
    OPTION TABLE OK      a Dungeon-Run-shaped table (TabGroup, three lanes, the node editor's
                         three items in data-flow order) VALIDATES through AceConfigRegistry
    TEMPLATES READ       1209 virtual definitions out of the MPQ; F.New applies them; 0 unresolved
    API SURFACE          every name r960 reaches is attested on this fork; 0 NO MATCH

**The one thing standing between here and A10.1c:** `Dialog:Open` reaches TabGroup and stops on
`PanelTemplates_TabResize` — a Blizzard FrameXML **function**. `patch-B` carries 823 `.lua`
files including `Interface\FrameXML\UIPanelTemplates.lua` (28 KB), which defines it. See **U6**.

---

## 2. PROPOSED BUILD ORDER — each step named by what PROVES it

    P1  FRAMEXML LUA INTO THE HARNESS          proof: Dialog:Open returns a frame (U6)
    P2  THE LITE BUILD lands in the addon      proof: the .toc loads it; a LOUD failure names a
                                               missing lib (A10.1's fourth mutation) (U1, U5)
    P3  THE SKELETON FRAME - three empty lanes proof: A10.1a/c - check_rects on Ace-produced
                                               rects, zero overlaps, nothing off-frame (U2)
    P4  THE TEXT-METRICS SWEEP                 proof: A10.1c's "N verified · M unverifiable",
                                               by name. Vary the GetStringWidth stub; the rects
                                               that move ARE the list
    P5  FOLD, in A10.2a's order                proof: A10.2c per pane - grep + check_interface
                                               still 1:1 (U3)
    P6  A10.3 node editor · A10.4 tell · A10.5 remote

★ **P3 before P5 on purpose.** The skeleton is where `check_rects` first reads rects it did not
produce itself, and every later fold is measured against a frame already known to be clean. A
fold landing into an unverified container would make its first red ambiguous.

⚠ **P4 before P5, also on purpose.** Until the blind spot is named, every geometry green after
it carries an unknown, and A10.2's per-pane greens would inherit it silently.

---

## 3. WHAT THE BENCH COMMITS TO UNLESS OVERRULED

**R1 — FOLD TO OPTION SUBTREES KEYED BY GROUP, never one flat table.** From Battlewrath's
diagram: the three TabGroup lanes and the three knocked-out columns are **the same three groups
in two containers**. Under A′ that is `AceConfigDialog:Open(app, container)` with a different
container — nearly free. ★ So `args.node.args.*`, not `args.*`.

⚠ **This is what makes D-C ("knock-out later") cheap rather than a debt.** Subtree → knock-out is
later a container swap. Flat → knock-out is a rebuild, and "later" quietly becomes "expensive."
The diagram makes knock-out look structural; the subtree shape is what lets it not be, and it
costs nothing to hold now.

**R2 — A10.7 step 3 tests EXISTING behaviour from a new door.** `editor.lua` already has the
envelope, window, play/pause and skip. The checklist step is "reach it by click from the RUN
lane", not "build playback." Worth A10 saying so, because it reads as new work.

**R3 — The old pane stays live during its fold (A10.2d, restated as a commitment).** Nothing is
torn down to start; both paths work until the fold's own criterion is green.

---

## 4. OPEN — the bench cannot settle these

### U1 · Which AceGUI widget files ship in the lite build?

A10.1b says *"AceGUI core whole, widget files subset"* without naming the subset.

    from ui_scope §4's needs   TabGroup · SimpleGroup · InlineGroup · Label · Heading · Button ·
                               EditBox · CheckBox · Dropdown (+ DropDown-Items) · Slider
    the judgement call         WINDOW (and/or Frame) - the container a knocked-out group lives
                               in. Nothing in A10.1-A10.5 needs it, because knock-out is later.

**Bench read (overturnable):** **ship Window.** ⚠ Not because knock-out is in scope — because
cutting it makes knock-out a re-add plus a re-test of the lite build's boundary, and keeping it
is one file. ★ Same logic as R1: the cheap thing now is the thing that keeps "later" cheap.

### U2 · A10.1c says "zero overlaps" — over WHICH set?

`F.Overlaps` compares a flat list. Ace nests deeply: frame → TabGroup → group → widget → the
widget's own template regions. **A child inside its container is not an overlap**, but an
all-pairs comparison over a flattened tree calls it one, and the report would be unreadable.

    a  SIBLINGS ONLY, recursively - compare within each parent, walk down. Catches the two
       faults that started frames.lua (an orphaned heading, a clipped button) and stays quiet
       about containment.
    b  LEAVES ONLY - compare only frames with no children. Simpler; loses container-vs-container.
    c  DECLARED CONTROLS ONLY - compare only what the interface file names. Smallest, and blind
       to anything Ace creates that we did not declare.

**Bench read:** **(a)**, and A10.1c should say so — "zero overlaps" is currently a criterion
whose result depends on a choice nobody has made.

### U3 · A10.2c's grep — how does it tie a `SetPoint` to a DECLARED control?

*"literal `SetPoint` on DECLARED controls = 0 (grep)"*. A bare grep for `SetPoint(` finds every
one, declared or not; the criterion is about the declared ones.

    a  WALK FROM THE INTERFACE FILE - each row already carries its anchor (`forms object.lua ·
       \`noteBox = CreateFrame(\``), so the check resolves the local name and looks for
       `<name>:SetPoint(`. ⚠ Depends on those anchors being accurate - the A9.2 rot class, and
       10 anchors in `map` are dead right now.
    b  PER-FILE ZERO - once a pane is folded, assert its file contains no literal SetPoint at
       all. Blunt, unambiguous, and it forbids hand-placing anything in a folded file.
    c  ALLOWLIST - a named list of frames still permitted to hand-place, shrinking to empty.

**Bench read:** **(b)**, with (c) as the transition. It cannot rot, it needs no anchor, and the
fold is per-file anyway. (a) makes a correctness check depend on comment accuracy, which is the
thing that just failed twice.

### U4 · Does A10.7 run against folded panes only, or a mixed state?

A10.2a folds `object.lua` first and run options LAST; A10.7's steps 2–3 are the FIRST things
Battlewrath does and belong to the run lane. So the gate's opening steps exercise the
last-folded pane.

    a  MIXED IS FINE - A10.2d already says the old pane keeps working, so the checklist may pass
       with editor.lua's existing bar reached from the new frame's RUN lane.
    b  GATE ON FULL FOLD - A10.7 runs only when every pane in A10.2a is folded.

**Bench read:** **(a)** — it is what A10.2d already permits, and it lets live testing start
earlier, which is the stated reason the brief exists (*"menu / command fatigue"*). Flagged
because it is better decided than discovered at the gate.

### U5 · Where does the shipped Ace live, and what stops the checkers tripping on it?

`COA_GuardianPlates` already ships `Libs/LibStub/` — so the convention exists:
`addons/COA_DungeonRun/Libs/`.

⚠ **`check_targets` does not flag GuardianPlates' vendored files today, and that is an ACCIDENT
rather than a rule** — it enumerates with `os.listdir` (top level only, no recursion), so
subfolders were never scanned. Ace3 would add ~40 files that a recursive version would demand
target headings from.

**Bench read:** make the exemption EXPLICIT — a `Libs/` path segment is vendored, exempt, and
**REPORTED as exempt** so the number is visible. ★ Same distinction `match_api_terms.py` already
draws between our code and vendored library code, and an exemption nobody can see is the same
shape as a silent pass.

### U6 · FrameXML Lua into the harness — whole file, or the functions Ace reaches?

`Dialog:Open` needs `PanelTemplates_TabResize`. `UIPanelTemplates.lua` is 28 KB in patch-B and
defines TabResize, SetTab, SelectTab and UpdateTabs.

    a  LOAD THE FILE WHOLE, from the archive, like the templates. It is the client's own code,
       so the harness runs the real thing. ⚠ Unknown until run: what else it pulls in.
    b  STUB THE FOUR FUNCTIONS. Certain and small; ★ and it is the creator-dialect trap - our
       PanelTemplates_TabResize would be right until Blizzard's arithmetic and ours disagree,
       with nothing to notice.
    c  LOAD WHOLE, FALL BACK TO STUBS where a file will not run, and REPORT which.

**Bench read:** **(c)**. (a) is right in principle and (b) is the thing we keep telling
ourselves not to do; (c) gets the real code where it runs and names the exceptions instead of
hiding them. ⚠ The cost of (a)/(c) is unmeasured — it is one run to find out, and I would rather
run it than argue it.

---

## 5. NEEDING RESOLUTION, but not questions for the designer

    A9.6's row       says "the checker's canvas equals the shipped pane size (read from one
                     place, not typed twice)". There were TWO sites and neither matched that
                     description: a stale probe CAPTURE, and a typed constant under a comment
                     claiming provenance. Both fixed (§351). The row should say what it now
                     guards, or A10.1c inherits a criterion describing a mechanism that never
                     existed.
    A9.2             10 dead mutation anchors, every one in `map`. Untouched by the UI work and
                     unrelated to it - listed so it is not re-discovered as a UI finding.
    Dungeon Routes   A10.1b says it ships no Ace. No action for this bench; noted so the
                     boundary is on the record.

---

## 6. NOT IN THIS PROPOSAL

    the knock-out BEHAVIOUR (D-C: later; R1 is only about not foreclosing it) · visual style ·
    the personal-note pane · export/import · the consumer's slots · which words the naming pass
    lands on · anything in A10.6

---
_The bench builds P1–P6 in order once U1–U6 have answers, and will start on P1 regardless since
U6 is the only question it touches and (c) is safe under any of the three._
