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
