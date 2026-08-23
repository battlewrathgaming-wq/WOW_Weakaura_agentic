---
name: boot
description: Run this repo's session boot sequence before doing any work — asserts your role, checks whether your seat holds the helm, reports why the trunk moved, and routes you to your bench shelf and lane state. Use at the start of every session on this project, after a compaction, when you are unsure which seat you hold, or before touching the tree.
---

# Boot — run it, do not recall it

**Reading is not booting.** Battlewrath, 2026-08-12: *"harden the boot sequence, so it's doing the
work instead of regret of missing it."* A remembered sequence fails slowly; this one executes.

## 1 · Run it first, before anything else

```bash
py operations/boot.py --lane <your lane>
```

⚠ **Do not guess the lane and do not take one from a doc.** Assert the seat you actually hold. If
the name is not accepted, the tool prints every lane it knows — take it from there, never from
memory. (The lane list on the memory spine was measured stale by one day on 2026-08-22: two seats
had been added that it did not carry. **The tool is the authority; a restated list is the second
copy that drifts.**)

### ⚠⚠ If you do not know which seat you hold — ASK BATTLEWRATH. Do not infer it.

Not from the directory you are editing, not from a file you happened to open, not from a lane name
that merely looks close, and **not from a document's "you"**. PROTOCOL.md §1: *role is inferred
from the live chat, and the human is the authority* — a self-label in a shared file buys provenance,
never truth about who you are now.

★ **The role trailed atop every message is the only isolated memory space that says who THIS thread
is.** Everything else on disk is shared, so it cannot answer the question — a doc statement is
always true, and read as self, any role can match it. ⟶ **An inferred bench is an inferred
authority**, and the helm, the lane file and the write permissions all hang off it.

⟶ One sentence from Battlewrath settles it. A thread once mis-read its own vestigial self-label as
proof it was another bench, and the apparatus could not self-correct.

Exit `0` clear · `1` conditions raised. ★ **It never TAKES the helm** — a lock you acquire by
looking is worse than one you forget. Taking stays a deliberate act with a stated heading.

What it answers, in order: you carry your role → does your role hold the helm → if not, what are
the CONDITIONS → if that is a close-out or communication failure, **that is the work** → and why
the trunk moved, which is what a *different bench* arriving cold needs. It also catches the merge
hazard where `origin` is ahead of you.

## 2 · Then read, in this order

1. **The spine** — `memory/MEMORY.md` auto-loads; it carries only what is shared.
2. **YOUR bench shelf** — the arrival note for your bench, linked from the spine. Not another
   bench's.
3. **`operations/<your lane file>`** — the now-state. `boot.py` prints which file that is for you.

⚠ `operations/ROUTER.md` before asserting any client behaviour — one client, one Lua, whichever
bench you are on. `operations/PROTOCOL.md` is how the system runs.

## 3 · Carry the band every response

`operations/PROTOCOL.md` §1b holds the schema. It is a reminder of **what files to REACH FOR** —
naming an unopened file is the point, not a lie:

```
<Model> <Role>.
**Boot**        what you RAN to orient. Commands and files, PAST TENSE.
**Files**       what this turn reaches for.
**Memories**    which memories fired, by [[name]].
**Instrument**  turn-invariant constraints — only while no guard enforces them.
```

★ Why it is not ceremony, measured: a session ran **33 days / 11 compactions** while `boot.py`
decayed to nothing in days. The docs are still read, but **the chat chooses which ones**, so they
only ever answer the questions already being asked. After a compaction the band is the one thing
pointing at disk rather than at the thread.

## Related

- Before building or naming a new tool, run the **tools** skill. **A name is a claim about what
  already exists**, and the desks are bigger than any one agent has opened.
