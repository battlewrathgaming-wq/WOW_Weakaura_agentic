## RI-83 DRAINED (Analyst, 2026-08-27) · the ruling was the Addon creator's, the denominator is now on screen, and the parked mutation BITES

_Outcome: closed and PROVEN closed. `check_interface` prints `sizes: N declared size(s) parsed and
compared against the source`, and the mutation that exposed the gap now bites on its own message._

**THE DEFECT:** breaking `SIZE` — a `×` typed as an ASCII `x`, this bench's own recurring fault —
dropped every one of the 21 declared sizes the tool can read, **and its output did not change.** It
reported size MISMATCHES, and zero parsed sizes yields zero mismatches. ⟶ **It could not tell "no
sizes declared" from "all sizes agree."**

**THE RULING, and it is better than the criterion that was filed** (the Addon creator, 2026-08-27):

> *"a checker must report its denominator, not a floor … A floor needs a number nobody measured and
> goes stale; a denominator is derived at run time and can't."*

★ RI-83 offered three shapes — a floor, a count, or a refusal — and the ruling picked the one with a
REASON rather than the one in the middle. It is the same law the receipt's `can-go-red` column
already runs on: **derived at run time cannot drift, restated in prose always can.**

**⚠ THE FIRST LANDING DID NOT CLOSE IT, AND THE MUTATION IS HOW WE KNOW.** `check_interface` gained
`hosted: N surface(s) are a MODE of another's frame, so NO size was compared for them`. That is a
true and useful note — and it answers a NEIGHBOURING question: how many surfaces correctly have no
size. It is read from the HEADER, not from `SIZE`. ⟶ With only that line, **breaking `SIZE` still
changed nothing** and the parked mutation stayed silent. The denominator being asked for was *sizes
actually parsed and compared*.

**THE FINISH:** `SIZES_COMPARED` collects the stems whose declared size was parsed, mirroring the
existing `HOSTED_SURFACES` pattern, and the count prints **unconditionally** — a zero is the whole
finding, so it must not hide behind an `if`. ⟶ `sizes: 5`. **A run that read nothing cannot print
it**, which is the property the ruling was buying.

★★ **AND THE MUTATION WAS THE ACCEPTANCE TEST, not a formality.** It was parked
`[known SILENT, recorded]` on 2026-08-26 with its cause written beside it, kept rather than deleted
because *deleting it to clear the count is the move that turns a finding into a lie.* **It bit the
moment the denominator existed** — nobody had to remember what the fix was for. ⟶ That is what a
parked mutation is FOR, and this is the first case on the desk that shows the whole arc: found by
mutation, filed as a criterion, ruled by the bench, finished by the seat, and closed by the same
mutation going live.

