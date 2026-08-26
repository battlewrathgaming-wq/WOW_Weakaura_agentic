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
import json
import os
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ADDONS = os.path.dirname(HERE)
LOG = os.path.join(ADDONS, "staging", "io_faults.jsonl")


def _record(op, path, exc, nbytes=None):
    """Append one fault. ⚠ NEVER raises - a failure to log must not mask the fault
    it was trying to describe, which would be the diagnostic destroying the
    diagnosis."""
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
        }
        d = os.path.dirname(LOG)
        if not os.path.isdir(d):
            os.makedirs(d)
        with open(LOG, "a", encoding="utf-8") as fh:
            fh.write(json.dumps(row) + "\n")
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
    try:
        with open(tmp, "wb") as fh:
            fh.write(data)
        os.replace(tmp, path)
    except OSError as e:
        # ⚠ THE SCRATCH FILE GOES, WHATEVER HAPPENED. A `.foo.lua.fileio-tmp` left in a
        # source folder is a file that looks like a mutant and is not tracked - the exact
        # confusion this whole change exists to prevent, arriving by the back door.
        try:
            if os.path.exists(tmp):
                os.remove(tmp)
        except OSError:
            pass
        _record(op, path, e, nbytes=len(data) if data is not None else None)
        raise


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
