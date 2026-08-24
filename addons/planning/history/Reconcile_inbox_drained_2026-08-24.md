# Reconcile inbox — DRAINED 2026-08-24

_Items whose reasoning is finished. The CONCLUSION lives in `ANALYST_LOG.md`; this file keeps the working-out, so a conversation and its conclusions do not share a page._

---

## RI-73 DRAINED (Analyst, 2026-08-24) · ⚠ `330` IN THE UI SCOPE IS A HEIGHT — **fixed at TWO sites, not one**

_Outcome: both readings corrected in `ui_overhaul_scope.md`; `ANALYST_LOG` 2026-08-24. Verified by
grep before and after._

**The item was right and it under-counted.** It named the headline finding (`:71`); the same
sentence is written again at `:362` — *"the child subject needs 575px in a 330px pane"* — inside the
paragraph that settles §101. ⟶ Correcting only the one the reader complained about would have left
the identical trap in the paragraph a reader reaches by following the argument.
★ **A misreading found once has a second home more often than not**, and the grep costs nothing.

Both now read *"in a pane 330px TALL"*, with the supersession named: `object.lua` has shipped **600**
since §104 (*"★★ 600 TALL, NOT 330"*, `f:SetWidth(240); f:SetHeight(600)`).

⚠ The item's own framing is the part worth keeping: *"nothing is wrong, and that is exactly why it
bites."* Two documents that agree can still cost a false claim, because **the cost is in what a
sentence AFFORDS a cold reader**, not in whether it is true.

---

## RI-74 DRAINED (Analyst, 2026-08-24) · the TEXT constants get a register home — **two lines, not three**

_Outcome: `dungeonrun_interface_inventory.md` → `Constants, sourced`; `ANALYST_LOG` 2026-08-24.
`check_sheet.py` re-run afterwards to prove its machine-read line still parses._

**⟶ The decision was already made by the record, so this is an APPLY and not a choice.**
`check_sheet.py:276` states the pattern outright — *"REFUSES rather than defaulting… a fallback here
would be the copy this function exists to abolish, and it would be silent"* — and `smoke/frames.lua`
names the section as the home. A sourced formula with a measurement behind it belongs there; the
tool holds no copy and stops if the line goes.

**★★★ BUT ONE OF THE THREE WAS ALREADY REGISTERED UNDER ANOTHER NAME.** `q = 3 × aspect /
(10 × uiScale)` is `TEXT_GRID_COLUMNS = 2560` written for a caller with no client:
**`768 / 2560 = 0.3 = 3/10`, exactly.** Checked against the tool's own measurements rather than the
algebra alone —

    1440x1080 @ 0.65    q measured 0.6153846121    3 x (4/3)   / 6.5 = 0.61538461
    1920x1080 @ 0.64    q measured 0.8333334359    3 x (16/9)  / 6.4 = 0.83333333
    1920x1200 @ 0.64    q measured 0.7500000761    3 x 1.6     / 6.4 = 0.75

⟶ So it landed as a THIRD LINE ON THE EXISTING ENTRY, not a new one. **Two expressions of one
constant, in one place, is a home; in two places it is the second copy** — which is the exact
discipline this section exists to hold.

★ And the 16:10 row earns its place: the width quantum tracks the **screen's own** aspect (nominal
16:9 would predict 0.8333, not 0.75). `q_v` uses the NOMINAL 16:9. **That difference is the whole
reason both exist**, and it is what the 0.0123% gap measures — one mechanism seen at two aspects,
never two mechanisms.

**NEW, and genuinely new:** `q_v = 3 × (16/9) / (10 × uiScale) = 8 / (15 × uiScale)` and the tested
rule `advance = round(size / q_v) × q_v`.

⚠ **The per-font `k`/`c` table stays emitted and cited, never copied** — the item said so and it is
right. **The formulae are sourced CLAIMS a reader can check; the table is an ARTEFACT.**

---

## RI-75 DRAINED (Analyst, 2026-08-24) · two ☐ that predate this week — **one closed, one is the bench's**

_Outcome: `dungeonrun_interface_inventory.md` reconciled; `ANALYST_LOG` 2026-08-24. Item 2 is a code
change and is named back, not made._

**1 · `Layout.H` vs the measured control heights — ✅ CLOSED, and the answer is a CATEGORY.**
⚠⚠ The two tables **do not measure the same population**, so subtracting them manufactures a
finding that is not there — side by side they look like a 120% error on the edit box, and there is
no error. THREE populations, each correctly stated where it lives:

    Layout.H          what the CLIENT DECLARES for a FrameXML template (`layout.lua:88`, which says
                      so itself: *"SOURCED, NOT PROVEN AGAINST OUR PANE: these are the TEMPLATE sizes"*)
    object.lua        what OUR hand-built pane actually sizes — mostly 20 (`panespec.lua:186`)
    the measured set  what an ACEGUI WIDGET becomes — from the sheet, AceGUI at minor `1.#INF`

⟶ The discriminator is now written where the ☐ was: **ask which widget stack the surface is built
on.** Neither table is wrong; using the wrong one would be, and nothing does today.
★ `check` shows all three at once — template 26, our chip 20, AceGUI 24: **three right answers to
three different questions** ([[a-name-is-not-a-use]]).
⚠ The ☐ expected *"agreement or disagreement, it is a number either way."* It is neither, and **no
shipping code changes** — which is the finding, not a dodge. It also does NOT imply a migration:
**AL-46 scopes the Ace3 default to the PLUMBING** and states it *"does NOT extend to the
layout/offline domain — frame model, panespec, coordinate space, driver, route contract."*

**2 · `COA_DevDump/sheet_decl.lua`'s duplicate specimen list — ⟶ NAMED BACK TO THE BENCH.**
This is a code deletion in a shipped file, gated on `task_geom` reading `sheet_decl` instead. **The
dev manages the tree, not the Analyst**, and a doc disagreement is not a licence to cut code. The
item's own reasoning is the strongest argument for doing it soon and stands unaltered: the sheet is
a calibration standard whose discipline is append-only and single-source, and **a second copy of its
specimen list is the one thing that discipline cannot tolerate.**

---

## RI-76 DRAINED (Analyst, 2026-08-24) · the architect's three record corrections — **five sites, not one**

_Outcome: `interface/drive.md` ×3 · `interface/remote.md` ×2 · `ANALYST_LOG` scope note.
`check_interface.py` and `emit_outstanding.py` re-run afterwards. `ANALYST_LOG` 2026-08-24._

**1 · the test drive's home.** The item named the ☐ and said *"any other register row citing G3/D-E
follows"* — there were **four more**: `drive.md`'s prose, its emitted Outstanding entry, its Hopes
and dreams line, and `remote.md`'s temporary-door note. All now name **the REMOTE's second tab**
(Run capture · Test drive), with the old reading kept as a dated headstone rather than deleted.

**2 · AL-13's grammar.** No live site in `interface/` at all — the hits were in `ARCHITECT_INBOX.md`,
which is the conversation that PRODUCED AL-50 and already carries its outcome. ⟶ The one record that
needed the note was **the Analyst's own log** (RI-49's row, which ends *"plus a dock-all strip"*):
scoped, so nobody generalises the pane's way-back grammar to every tabbed surface.

**3 · the surface structure.** `interface/remote.md` gains the two tabs as an **☐, never a built
claim** — a register describes what IS — with AL-50's fixed-strip grammar and the reason it is fixed
(this file's own 16px justification, plus AL-7's *the remote must not claim UI*).
⚠ `UI_LOG.md:119` still carries AL-47's original derivation (*"drive… owed a fold-in"*, *"remote…
BORN a tab"*). **Left alone deliberately: it is the UI seat's log, and `UI_LOG.md:42` already
carries the correction above it.** A log is a history; cross-bench reference is allowed and writing
their record is not.

★★ THE PATTERN ACROSS BOTH ITEMS TODAY, and it is the same one RI-73 gave: **a correction filed
against one site had more sites every time.** RI-73 named 1 of 2; this named 1 of 5. ⟶ The grep the
filer suggests is the floor, not the answer.
