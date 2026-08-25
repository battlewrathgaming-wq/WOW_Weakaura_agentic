# Reconcile inbox — DRAINED 2026-08-26

_The working-out. Conclusions live in `ANALYST_LOG.md`._

---

## RI-47 DRAINED (Analyst, 2026-08-26) · the bucket's gate — **verified in the shipped source, not taken from the heading**

_Outcome: no action. The bench's self-reported fix is real._

The item said `bucket.lua`'s `known(code)` validated authored words against **`Adaptor.Has`** — the
DISPLAY table — so `boss`, `note` and `say` were refused at build because no adaptor word exists for
them. ⟶ `bucket.lua:86` now reads:

    local list = Routes and (kind == "sense" and Routes.SENSE_WORDS or Routes.ROW_ACTIONS)

**The gate is the AUTHORING vocabulary, which is the correct table.** ★ And the distinction the item
drew is the durable part: *`ROW_ACTIONS` answers "may an author write this?"; `Adaptor.Word` answers
"what does a human see?"* — and `DR_Content_20`'s A5.1 passes a miss through, so a display table can
never be a gate.

⚠ Verified by reading the source. RI-55 sat open two days after its own resolution, so a heading
that says FIXED is a claim like any other.

---

## RI-48 DRAINED (Analyst, 2026-08-26) · L2.4's arg half — **the heading was right, and the filer had already corrected himself**

_Outcome: no action. Nothing outstanding._

The item opens *"L2.4 splits three ways and only the third needs anyone's word"* — so the heading's
*"NO QUESTION LEFT"* looked like it contradicted the body. It does not: the third part closes with
**"✅ ANSWERED — BY PRECEDENT, AND I SHOULD HAVE FOUND IT BEFORE FILING THE QUESTION."**

⟶ The bench found `Routes.ROW_ARG.supertrack = nil` already carries the answer (*"`nil` means the
action takes no arg"*), and that an arg on `supertrack` can only arrive from a hand-edited
SavedVariables or an importer — not from the pane, which offers none.

★★ **The line worth keeping is the filer's own:** *"an answer from the repo is not a question for
Battlewrath."* That is the same rule this seat works to, written by the other side of the bench.

---

## RI-53 DRAINED (Analyst, 2026-08-26) · a defaults store — **ANSWERED, and the build is NAMED BACK, not made**

_Outcome: the analysis stands; `contract.lua` is shipped code and the dev manages the tree._

**His question:** *"Should we build a defaults store, so each can read from it? And maintaining it
is one pane of glass rather than per function / system?"*

**⟶ The measurement changed the shape of the answer twice.** Of 14 module constants only **TWO** are
defaults; 8 are caps/floors and 4 are identity. ★ **A defaults store built from what LOOKS like
defaults would have had two members** — the scattering he could see is almost entirely caps and
identity, and neither belongs in one.

**⟶ The real defaults are BEHAVIOURAL** and none is a named constant; each lives inside a code path.
And `contract.lua` is already the pane of glass: every field declared with its type, its
optional-ness, its ZERO MEANING and a `why`, **and it is already the one place that reconciles the
STORE form against the RECORD form per field.** A seed is one more property of a field it already
fully describes.

    ⟶ THE ANSWER   `seed =` on the entries that have one. No new module, no new file, no new
                   convention.
    GOES IN        field-level seeds — `trigger` = once · `step` = the minted ordinal ·
                   `band` = 2.5, which moves OUT of `bucket.lua` and stops being a second copy
    STAYS OUT      the SEED ROW (B0) — a whole RECORD, not a field. It stays at its door and
                   POINTS at the declaration, or it becomes the fifth seed convention.

**⚠⚠ NOT EXECUTED, and that is why this drain says so out loud.** Measured today: **`seed =` appears
nowhere** — not in `contract.lua`, not in any register. ⟶ The reasoning is finished and belongs in
the log; **the build is the bench's**, because `contract.lua` ships and a doc conclusion is not a
licence to edit shipped code.
★ Same shape as RI-75's second half and RI-78's code half: **drain the analysis, name the build.**
