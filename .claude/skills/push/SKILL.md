---
name: push
description: The push regiment on this repo — what happens at a push, what receipt it leaves, and how a reconcile pass reads that log to find stale docs. Use before or after pushing to git, when asked to push, when reading push receipts, when reconciling docs against code, or when wondering whether the checker desk still agrees with itself.
---

# Push — the act leaves a receipt, and the receipt is the reconcile log

**This is a regiment, not a tool.** The tools already existed. Measured 2026-08-26: the bench had
**thirteen checkers** and its reconcile runner (menu `[7]`) was **wired to two, unchanged since
2026-08-16, while nine of the eleven it missed were born after that date.** Nothing was missing
except the habit of running them at a moment that recurs. ⟶ The push is that moment.

## 1 · Who pushes

**Only the Addon Creator pushes.** The helm is a PUSH lock, not a commit lock — every seat commits
freely; the trunk moves by one hand. If you are not that seat, commit and stop. `py operations/boot.py --lane <yours>`
answers this and says why the trunk moved.

## 2 · What happens automatically

`.githooks/pre-push` runs `addons/tools/emit_push_receipt.py` and appends a block to
`addons/planning/audit/push_receipts.md`. It costs ~9s and **it never gates** — it exits 0 even when
the emitter fails. A stop on the Addon Creator's push is not something the Analyst seat installs.

Wired by `core.hooksPath = .githooks`, so it fires from a shell `git push`, from `git_push.bat`, or
from an IDE. **If receipts stop appearing, check that config first** — a hook that silently stopped
running is the exact failure this regiment exists to prevent.

⚠ **The receipt lands one push late.** The hook writes after the pushed commits exist, so each
receipt ships with the *next* push and the tree is dirty by one file right after pushing. That is
the accepted cost of keeping the log in the repo rather than on one machine.

## 3 · How to read a receipt — the part that matters

Each row is `checker · exit · fingerprint · marks · can-go-red`.

**The reconcilable signal is the FINGERPRINT, diffed against the previous receipt.** Two
independent observations of the desk — at push N and at push N+1, neither derived from the other.
That is what makes it a check rather than a coin (§526: drift is only detectable where two
independent sources can disagree).

    a fingerprint that MOVED     → the question. That checker's sources stopped agreeing the way
                                   they did last push. **A question, never a verdict** — lag is
                                   expected during active development, and the docs are the
                                   authority, so a difference is something to look at.
    a fingerprint that HELD      → proof of no change. **Not proof of health.**
    exit code                    → the smaller half. All thirteen exit 0 today.

## 4 · ⚠⚠ The ceiling, and it is printed in every receipt

**Read the `can-go-red` column. Do not read a number here.** It is derived from the mutation suite
at run time, so it cannot drift — and this section restated one anyway, in the same breath as
explaining why it must not.

⚠ **The restated count has now been wrong TWICE, which is the argument.** Written as *3 of 13*, it
was corrected to *13 of 13* within a day — and that correction was **itself stale by 2026-08-28**,
when two more checkers had landed and the receipts read *15 of 16*. ⟶ **The column was right the
whole time; the prose beside it was the second copy, and a second copy does not stop drifting just
because someone recently fixed it.** `concepts/` rules the same way: a home is an INDEX, never a
copy.

⟶ **Read an unproven green as *unmeasured*, never as *clean*.** That is the part that never goes
stale, whatever the count is: seven inert guards were measured on this bench in a single week, and
a log of OKs reads as coverage when some of those bulbs have never been proven to light.

★★ **AND `PROVEN` IS NOT `CORRECT`.** Every receipt says so in its own footer: *"a bite proves the
GUARD, never that the fact it guards is true."* A checker that can go red is one whose silence is
worth something — it is not a checker that is asking the right question.

## 5 · At a reconcile pass

Read the receipts back to the last pass and act on **moved fingerprints only**. Then run the desk
loud where one moved. Do not re-run everything and re-read everything — that is how the middle
outgrows the product.

**Do not hand-edit `push_receipts.md`.** It is machine-emitted; a hand-edited receipt is a
fabricated observation, and the whole regiment rests on the two observations being independent.
