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

---

## RI-55 DRAINED (Analyst, 2026-08-24) · three rows read OWED — **already satisfied on 2026-08-22, and nobody closed the item**

_Outcome: no change needed. Verified by `check_acceptance.py --all`, not by reading._

    manager:132  A12.2b   BUILT   Bucket.Build
    manager:203  A12.2f   BUILT   Bucket.Build
    manager:226  A12.2g   BUILT   Bucket.Build

All three carry `✅ BUILT (verified 2026-08-22 …)` with the refusal string quoted, and
`check_acceptance` reports **contradictions 0**. They were cleared the same day the checker was
built — incidentally, as part of proving the tool — and the item stayed open for two days after.

★★ **THE ITEM BECAME THE SHAPE IT NAMED.** Its own words: *"A row that describes its own resolution
while still flagged OWED is the shape a reader trusts and should not."* ⟶ An inbox item that
describes its own resolution while still flagged OPEN is the same shape, one layer up. **Work that
resolves an item incidentally does not close it**, and nothing on either side noticed for two days.

⚠ Its filing note is worth keeping for the same reason it was written: *"I took 53 from a grep run
BEFORE writing and the Analyst had filed 53/54 in between. `check_inbox` caught the collision —
**derive the number at write time, never carry one.**"*

---

## RI-70 DRAINED (Analyst, 2026-08-24) · mutation coverage — **15 dead anchors down to 1, and that one is parked**

_Outcome: `addons/tools/mutations/dungeonrun.json`, 14 mutations re-anchored + 1 `expect`
corrected. Every claim below is the harness's own output, re-run after each pass._

    filed 2026-08-22   13 dead      re-measured 2026-08-23   14 dead      measured today   15
    after              1 dead       329/350 biting  ->  343/350

**★★★ THE GUARDS WERE ALIVE. THE ANCHORS HAD MOVED.** That is the finding, and it is the opposite
of what a rot count suggests — nothing needed retiring:

    the mint          `tonumber(stage)` became `want`, hoisted above an `if` — 2 anchors
    the outcome       `b.outcome or ((b.stage or 0) + 1)` became `(b.stage + 1)`; the OLD text now
                      lives in the COMMENT above it, which is why an exact match found 0x — 2
    the walk / gaps   `Routes.NextOrdinal` grew a byte-identical `while used[n] do n = n + 1 end`,
                      so three anchors went AMBIGUOUS rather than missing — 3
    the arity         **RI-22 retired `bandDown`**: `ReachOf` returns TWO values and `setReach`
                      takes THREE args. Five anchors still named the three-value era — 5
    two more          a `folded or (...)` widened one guard; `_metricUsed` gained a third site — 2

⟶ **Every narrowing reaches for BRACKETING CODE, never a comment** — `mutate.py`'s own ruling, and
the one that produced this rot in the first place.

**⚠ ONE CORRECTION WAS NOT AN ANCHOR AT ALL.** *"ReachOf invents no default while R2 is unruled"*
re-anchored cleanly and then reported `~~ WRONG`. The mutation writes `x.bandUp or 2.5` — it
defaults the **BAND** — while its `expect` named the **RADIUS** assertion, which a band-defaulting
mutation can never trip. ★ So it could not have bitten on its own message even when the anchor was
alive. **A dead anchor hid a second fault underneath it**, and the harness's `~~ WRONG` verdict is
exactly what surfaced it.

**⟶ RESIDUE, NAMED RATHER THAN SWEPT:**

    5   `[PENDING the Actions profile pass, §365]` — LEFT DELIBERATELY. `adaptor.lua` records
        `bossEngaged` STRUCK (RI-15) and `bossKilled` gone as a value. **Retiring something the
        bench parked is not the same as clearing rot**, and the pass they wait on is not mine.
    2   `~~ WRONG` — *the running order sorts by stage VALUE* · *A2 - clearing an ordinal takes the
        child OUT of the line*. These are ASSERTION ORDERING inside the smokes, not anchors: the
        named assert sits behind one that fires first. `mutate.py`'s own legend says the fix —
        *"Order the precise assertion FIRST"* — and it is a test-file edit, so it is named here.

⚠ **NO SHIPPED LUA CHANGED.** Only the spec. The harness verifies its own restore and `git status`
confirms it: nothing under `COA_DungeonRun/` or `smoke/` is modified.
