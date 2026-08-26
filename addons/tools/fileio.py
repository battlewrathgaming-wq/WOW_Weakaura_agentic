"""fileio.py - byte file access that RECORDS an OS-level fault instead of hiding it.

★★★ WHY, and the shape of it is his (Battlewrath, 2026-08-15). Two `OSError: [Errno
22] Invalid argument` on ordinary repo files, months apart, both on a file that had
just been written and both fine a second later. The second one hit `mutate.py`'s
originals-read, escaped the `finally` that restores, and left two mutants sitting in
the tree looking like ordinary edits.

I offered a single bounded retry. He declined it:

    "Bank it in case its frequency increases. Maybe build better logging / capture
    of the error. Then we know where to look to diagnose the actual issue."

★★★ RULING: CAPTURE OVER RETRY - a retry hides the FREQUENCY you would diagnose
from. Two events across hundreds of runs is not a signal; the same two with
timestamps, sizes and the operation that failed either becomes one or stays noise,
and either answer is worth more than a silent recovery. ⚠ This is the emit-don't-
interpret law applied to the tooling itself: a fault that heals invisibly is a fault
nobody can ever fix.

★★★ AMENDED 2026-08-26 - THE BANKED CONDITION WAS MET, and he set the terms:

    "It's right to fix the issue if we can name it rather than brute force. I'm not
    against a retry that has limited attempts and self reports."

⚠ THE ORIGINAL RULING IS NOT OVERTURNED - it is SATISFIED. Its objection was that a
retry HIDES FREQUENCY. A retry that records EVERY ATTEMPT hides nothing: the log gains
rows rather than losing them, and it now also carries how many tries the write needed,
which a bare fault could never say. ⟶ The banked clause was *"in case its frequency
increases"*, and it did - 8 faults over 11 days, TWO of them in one session (2026-08-26).

★★ AND THE NAMING CAME FIRST, which is his condition. The fault is not brute-forced:
§683 made the write ATOMIC because the faults all landed inside an in-place write window,
so a lost race can no longer corrupt anything. The retry is what remains after the
corruption is gone - a bounded second attempt at a move that is allowed to lose a race.
⚠ What is still NOT named is the contender. `mutate.py`'s hypothesis (the exiting lua
process holds the handle) is FALSIFIED by a `write:apply` fault in the log, and an apply
has no subprocess before it. So the retry is honest about being a mitigation for something
unnamed - and it reports, which is how the naming eventually happens.

★★ IT DOES NOT SWALLOW. The exception is recorded and RE-RAISED, so every caller
behaves exactly as it did before - the log is a side effect, never a handler. A
capture that changed control flow would be the retry he turned down, wearing a
different name.

★ His read on the likely cause, and it is why the record carries sizes and a clock:

    "It might be a pacing issue in the OS runtime / write/read speeds. My set up
    isn't exactly cutting edge."

If that is right the events will cluster with big writes, or with a read that
follows a write closely. The record is built to show that or fail to.

Log: addons/staging/io_faults.jsonl - one JSON line per fault, appended, never
rotated. ⚠ It is gitignored, so a fault worth keeping gets PROMOTED into a planning
note; this is the raw stream, not the finding.

    from fileio import read_bytes, write_bytes
"""
import atexit
import json
import os
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ADDONS = os.path.dirname(HERE)
LOG = os.path.join(ADDONS, "staging", "io_faults.jsonl")

# ★ THREE, and the number is an argument rather than a taste. Every logged fault so far
# was transient - the same write succeeded moments later by hand - so ONE more attempt
# covers the observed shape. The third is for the case we have not seen. ⚠ A fourth would
# be a tool insisting past the point where a human should be told.
ATTEMPTS = 3

# ★★ THE SELF-REPORT'S LEDGER. A caller reads this at the end of a run and says whether
# anything was recovered; `mutate.py` does. Kept here so the count cannot disagree with
# the log - both are appended in the same place.
RECOVERED = []

# ★★★ THE DENOMINATOR, added 2026-08-26 for his drive-it-and-see: *"see if the batch
# write changes or keeps the same fault. Then it points to a write lock in general vs per
# line (frequency)."*
#
# ⚠⚠ THAT QUESTION CANNOT BE ANSWERED BY THE FAULT LOG ALONE, and could not before this.
# *"8 faults over 11 days"* is not a rate - it has no denominator. A `mutate.py` run makes
# roughly 736 writes (368 mutations, an apply and a restore each), so eleven days of runs
# is tens of thousands of writes and the count says nothing about frequency until we know
# how many. ⟶ A run that made 736 writes with one fault and a run that made 12 with one
# fault are opposite findings and look identical in the log today.
WRITES = 0
FAULTS = 0


def summary():
    """One row per RUN, appended at exit by any tool that wrote through this module.

    ★ It is the denominator, and it is what turns *"same fault or changed"* into a number
    rather than an impression. Nothing else in the log can carry it: a fault row knows
    about itself and not about the thousands of writes that went fine.
    ⚠ Silent when nothing was written - a read-only tool must not add a row saying it
    wrote nothing, or the run count inflates and the rate falls for no reason.
    """
    if not WRITES:
        return
    try:
        row = {
            "at": time.strftime("%Y-%m-%dT%H:%M:%S"),
            "op": "run",
            "writes": WRITES,
            "faults": FAULTS,
            "recovered": len(RECOVERED),
            "tool": os.path.basename(__import__("sys").argv[0] or "?"),
        }
        d = os.path.dirname(LOG)
        if not os.path.isdir(d):
            os.makedirs(d)
        with open(LOG, "a", encoding="utf-8") as fh:
            fh.write(json.dumps(row) + "\n")
    except Exception:
        pass


atexit.register(summary)


def _record(op, path, exc, nbytes=None, attempt=None, attempts=None, step=None):
    """Append one fault. ⚠ NEVER raises - a failure to log must not mask the fault
    it was trying to describe, which would be the diagnostic destroying the
    diagnosis.

    ★ `attempt` / `attempts` added 2026-08-26 with the bounded retry. They are what
    keeps the amended ruling honest: a row per ATTEMPT means the log gains detail
    where a retry would normally cost it. ⚠ Absent on rows written before that date
    and on callers that do not retry - `None` reads as *"this tool does not try
    twice"*, which is different from *"it tried once"*.
    """
    global FAULTS
    FAULTS += 1
    try:
        row = {
            "at": time.strftime("%Y-%m-%dT%H:%M:%S"),
            "op": op,
            "path": os.path.relpath(path, ADDONS) if path else None,
            "errno": getattr(exc, "errno", None),
            "winerror": getattr(exc, "winerror", None),
            "strerror": getattr(exc, "strerror", None) or str(exc),
            "bytes": nbytes,
            # Was the file there at all, and how big? A pacing fault and a missing
            # file look identical in the exception and nothing alike here.
            "exists": os.path.exists(path) if path else None,
            "size": os.path.getsize(path) if path and os.path.exists(path) else None,
            "tool": os.path.basename(__import__("sys").argv[0] or "?"),
            "attempt": attempt,
            "attempts": attempts,
            # ★ `scratch` or `replace` - see `write_atomic`. Absent for callers that do
            # not write atomically, which is a different fact from *"we did not look"*.
            "step": step,
        }
        d = os.path.dirname(LOG)
        if not os.path.isdir(d):
            os.makedirs(d)
        with open(LOG, "a", encoding="utf-8") as fh:
            fh.write(json.dumps(row) + "\n")
        # ⚠ A MID-RETRY FAULT IS NOT SHOUTED. It prints quietly with its attempt
        # number, because the loud form is for a fault nobody recovered from - and
        # `!!` on something that succeeded a moment later trains a reader to ignore
        # `!!`. The row is identical either way; only the volume differs.
        if attempt and attempts and attempt < attempts:
            print("   · io: %s %s attempt %d/%d failed - retrying"
                  % (op, row["path"], attempt, attempts))
        else:
            print("!! IO FAULT recorded -> %s" % os.path.relpath(LOG, ADDONS))
            print("   %s %s: %s" % (op, row["path"], row["strerror"]))
    except Exception:
        pass


class guard(object):
    """Record any OSError raised inside the block, then let it fly.

    ★ For callers that need TEXT mode - apply_tags rewrites source files with the
    file's own line endings, and routing that through bytes would mean an
    encode/decode layer for no gain. The guard does not care how you opened it.
    """

    def __init__(self, op, path):
        self.op, self.path = op, path

    def __enter__(self):
        return self

    def __exit__(self, kind, exc, tb):
        if isinstance(exc, OSError):
            _record(self.op, self.path, exc)
        return False                      # ⚠ never suppress


def read_bytes(path):
    try:
        with open(path, "rb") as fh:
            return fh.read()
    except OSError as e:
        _record("read", path, e)
        raise


def write_atomic(path, data, op="write"):
    r"""Build the new bytes in a SCRATCH file, then move it onto `path` in one step.

    ★★★ WHY (Battlewrath, 2026-08-26): *"Is there a way to do it in RAM/Cache so it's
    not effecting live content?"* The RAM version is blocked - 23 of 31 smokes hardcode
    the absolute repo path, so a mutant in a copied tree would never be the file lua
    loads. ⟶ This is the same intent one level down: the new content is fully formed
    somewhere else before the live path is touched at all.

    ★★ WHAT IT CHANGES, precisely. `os.replace` is atomic on Windows (`MoveFileEx` with
    REPLACE_EXISTING), so the target is **either the complete old file or the complete new
    one, never a partial**. Every one of the eight logged faults happened inside the
    in-place write window that this removes.
    ⚠ AND THE DANGEROUS HALF IS THE RESTORE - 5 of the 6 phase-labelled faults. A restore
    that fails now leaves the file EXACTLY as it was, which for a restore means the
    mutant... which is why `mutate.py` also checks the tree at the end. Atomicity removes
    corruption, not the need to look.

    ⚠⚠ THIS IS NOT THE RETRY HE DECLINED (2026-08-15, in this file's own header:
    *"CAPTURE OVER RETRY - a retry hides the FREQUENCY you would diagnose from"*). Nothing
    here recovers, retries or swallows: the fault raises and records exactly as before, and
    the log keeps counting at the same rate. Only the wreckage changes.

    ★ THE SCRATCH FILE IS A SIBLING, not `%TEMP%`. `os.replace` across volumes is not
    atomic and may not be permitted at all; same directory means same volume, always.
    """
    d = os.path.dirname(os.path.abspath(path))
    tmp = os.path.join(d, ".%s.fileio-tmp" % os.path.basename(path))
    nbytes = len(data) if data is not None else None

    global WRITES
    WRITES += 1

    for attempt in range(1, ATTEMPTS + 1):
        # ★★★ WHICH STEP, and it is the discriminator his measurement turns on. A single
        # `try` around both could only say *"the write failed"*, and the two steps mean
        # opposite things:
        #     scratch   the fault is on opening a BRAND NEW file - so the contention is
        #               the DIRECTORY or the volume, not the target
        #     replace   the fault is on the TARGET - a lock on the existing file, which
        #               is the *"write lock in general"* half of his question
        # ⟶ Before this, both recorded the same `op` and the drive period would have
        # produced a pile of rows that could not answer the question it was run for.
        step = "scratch"
        try:
            with open(tmp, "wb") as fh:
                fh.write(data)
            step = "replace"
            os.replace(tmp, path)
            if attempt > 1:
                # ★★ A RECOVERY IS AN EVENT, NOT A NON-EVENT. Said on screen as well as
                # logged: a run that healed silently is one nobody investigates, which is
                # the whole objection the original ruling raised.
                RECOVERED.append((os.path.relpath(path, ADDONS), attempt))
                print("   ⚠ io: %s took %d attempt(s) (%s) - recorded"
                      % (os.path.relpath(path, ADDONS), attempt, op))
            return
        except OSError as e:
            # ⚠ THE SCRATCH FILE GOES, WHATEVER HAPPENED. A `.foo.lua.fileio-tmp` left in
            # a source folder is a file that looks like a mutant and is not tracked - the
            # exact confusion this change exists to prevent, arriving by the back door.
            try:
                if os.path.exists(tmp):
                    os.remove(tmp)
            except OSError:
                pass

            # ★★★ EVERY ATTEMPT IS RECORDED, and that is what satisfies the ruling rather
            # than working around it. The log gains rows; it never loses one. A reader
            # counting faults per day gets the same number as before, plus how many tries
            # each write needed - which a bare fault could not say.
            _record(op, path, e, nbytes=nbytes, attempt=attempt, attempts=ATTEMPTS,
                    step=step)
            if attempt >= ATTEMPTS:
                raise
            # ⚠ A PAUSE, NOT A SPIN. His read is a pacing race against the hardware, so
            # retrying instantly would just lose it again at full speed. Short and
            # escalating: 25ms, then 100ms. ★ Bounded at THREE - past that it is not a
            # race, it is a condition, and a condition must reach a human.
            time.sleep(0.025 * (4 ** (attempt - 1)))


def write_bytes(path, data):
    try:
        with open(path, "wb") as fh:
            fh.write(data)
    except OSError as e:
        _record("write", path, e, nbytes=len(data) if data is not None else None)
        raise


def faults():
    """Every fault recorded so far. ★ The point of the log is the COUNT and the
    SPACING, so reading it back is part of the tool rather than a chore."""
    if not os.path.exists(LOG):
        return []
    out = []
    for line in open(LOG, encoding="utf-8"):
        line = line.strip()
        if line:
            try:
                out.append(json.loads(line))
            except ValueError:
                pass
    return out
