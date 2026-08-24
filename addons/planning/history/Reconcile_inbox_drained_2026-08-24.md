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
