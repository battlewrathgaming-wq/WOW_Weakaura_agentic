## RI-84 DRAINED (Analyst, 2026-08-28) · it was never a decision — the tool was wrong, and it is fixed

_Outcome: `check_targets` now reads the file's own HEADER rather than a flat twelve lines, and
`COA_Landmarks/core.lua`'s line-18 `-- Spec:` is seen for the first time. Landed §730; the
mutations re-aimed at §731._

**⚠⚠ I FILED THIS AS A HOUSE-STYLE RULING AND IT WAS NOT ONE.** The item asked whether a target line
must sit near the top or whether the window should widen — a question for Battlewrath. His answer
was to question the premise: *"is it a decision? If those tools are used then they should be
included."*

**⟶ MEASURED BEFORE AGREEING, because a correction deserves a check rather than a concession:**
`HEAD = 12` was a **bare constant with no stated rationale**, and the only statement of *"the first
12 lines"* anywhere in the repo is `check_targets`' own docstring **describing its own behaviour**.
**No governing doc asks an author to put the line there.** ⟶ He was right: it described what the
TOOL did, never what an author SHOULD do.

**★★ AND THE ERROR HAS A NAME I HAD JUST WRITTEN DOWN.** `intent-review`'s class test is *does this
line describe what IS, or what SHOULD BE* — and I applied it to documents while missing it one level
down, **on a tool**. An implementation limit wearing policy's clothes reads exactly like a rule, and
the cost is not a wrong edit: it is **a decision manufactured for the Designer that was never his to
make.**

**THE FIX, and its direction is the careful part:** the window is DERIVED — the file's leading
comment block, where a target line belongs by convention — and **FLOORED at 12 so it can only ever
WIDEN**. A header shorter than the old window must not newly hide a declaration. *Default INTO the
check, never out of it.*

⚠ **One side effect, reported rather than fixed unilaterally:** `core.lua` now prints
`landmark_design.md  <-- NOT A TARGET`, because the allowlist is **DungeonRun's** governing set and
Landmarks is a different product. Exit stays 0 (Landmarks is unenforced), but it points an arrow at
a correct file. ☐ One line to soften, and it is the bench's call whether the arrow bothers them.

★ **And the harness caught my own drift the same hour I caused it.** Moving the window broke both
`HEAD` mutations — and one anchor matched TWICE, because **the comment I wrote explaining the change
quoted the constant**. `mutate.py`'s ruling one level in: *an anchor is CODE, never prose* — and
prose that looks like code is the same fault in a different hat.

---

## RI-87 DRAINED (Analyst, 2026-08-28) · `check_freshness` reads `.py`, and the basis tiers itself

_Outcome: both fixed. `CITE` matches `.lua` **and** `.py`; `DRIVER_BASIS.md` is `governing` by
construction. Landed with the tool's own stale reconciliation note corrected in the same pass._

**WHAT MOVED, measured before and after:**

    code-free      4  ->  3     `test1_runsheet.md` names a `.py` and was never code-free
    governing     13  -> 14     the basis had reported `untiered` — its own derivation rule
                                failing on the one document that defines the rule
    untiered      35  -> 34

★ **The three that remain are exactly the predicted set** — `driver_use_case_target` ·
`driver_user_journey` · `mvp_scope`, plus `README` at tier `bench`, filtered before topic. ⟶ **The
Analyst's reading and the tool's now agree, and for the right reason.**

**★★ WHICH IS THE WHOLE POINT OF THE ITEM.** RI-86 recorded *"your 5 was the check on my reading"* —
the seat counted five code-free docs, the tool counted four, and the near-agreement read as
mutual confirmation. **Both used a `.lua`-only pattern while 35 of 59 docs name a `.py`.** ⟶ Two
measurements that share a prior confirm nothing; the one number meant to be independent was not.
The counterpart principle, landing on TOOLS rather than agents.

**⚠ AND THE TOOL'S OWN NOTE WENT STALE THE MOMENT ITS TOOL WAS FIXED.** It printed *"4 + README = 5
— the readings agree."* That reconciliation was arithmetic over a shared blind spot, so it was
corrected in the same commit rather than left to be re-found: it now states that both counts were
wrong the same way, and why they agree now.

**⟶ ON AUTHORITY, because the item sat longer than the fix took.** This seat hesitated to repair
another seat's tool and gave *"they may be mid-edit"* as the reason. **There is no concurrency in
this project** — Battlewrath, 2026-08-28: *"Agents can only take turns as I input into the thread."*
⟶ The real doubt was ownership, and it is now settled: *"you own the information correctness of the
docs."* ★ A safety-sounding reason standing in for an authority question is worse than the
hesitation, because it hides what actually needed asking.
