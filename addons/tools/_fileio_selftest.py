# -*- coding: utf-8 -*-
r"""_fileio_selftest.py - prove the atomic write and its bounded retry actually bite.

    py addons/tools/_fileio_selftest.py

★★★ WHY THIS EXISTS. `fileio.write_atomic`'s retry was authorised on three conditions
(Battlewrath, 2026-08-26): *"a retry that has limited attempts and self reports"*, and
only after the fault was NAMED rather than brute-forced. Each of those is a property, and
a property nobody has watched fail is an unproven green - which is this bench's own named
worst case. ⟶ So the first attempt is made to fail on purpose and the recovery is watched.

⚠ WHAT IT CANNOT SAY. That the real fault recovers. The real one is an `OSError [Errno 22]`
from outside the process, eight times in eleven days; this drives the same exception in
through `open` and proves the HANDLING. Whether the OS relents on a retry is what the log
answers over time, and that is the whole reason every attempt is recorded.

★ THE LOG IS REDIRECTED, deliberately. An earlier run of this test wrote four synthetic
rows into `staging/io_faults.jsonl` and they had to be stripped by hand - a diagnostic
record with test rows in it makes every frequency count wrong, which is the one thing that
log is for.
"""
import io as _io
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import fileio                                             # noqa: E402


def main():
    tmpdir = os.path.join(HERE, "..", "staging", "_fileio_selftest")
    tmpdir = os.path.abspath(tmpdir)
    if not os.path.isdir(tmpdir):
        os.makedirs(tmpdir)
    target = os.path.join(tmpdir, "target.txt")
    _io.open(target, "wb").write(b"original")

    real_log = fileio.LOG
    fileio.LOG = os.path.join(tmpdir, "faults.jsonl")
    if os.path.exists(fileio.LOG):
        os.remove(fileio.LOG)
    del fileio.RECOVERED[:]
    # ⚠ THE COUNTERS TOO. They are module-level and cumulative by design - that is what
    # makes them a run denominator - so a test that asserts exact numbers must start from
    # a known zero rather than from whatever the process did before it.
    fileio.WRITES, fileio.FAULTS = 0, 0

    real_open = open
    calls = {"n": 0}

    def flaky(path, mode="r", *a, **k):
        if mode == "wb" and str(path).endswith(".fileio-tmp"):
            calls["n"] += 1
            if calls["n"] == 1:
                raise OSError(22, "Invalid argument")
        return real_open(path, mode, *a, **k)

    def always(path, mode="r", *a, **k):
        if mode == "wb" and str(path).endswith(".fileio-tmp"):
            calls["n"] += 1
            raise OSError(22, "Invalid argument")
        return real_open(path, mode, *a, **k)

    try:
        # ---- 1 · IT RECOVERS, and the bytes land
        fileio.open = flaky
        try:
            fileio.write_atomic(target, b"new bytes", op="write:selftest")
        finally:
            fileio.open = real_open

        assert _io.open(target, "rb").read() == b"new bytes", \
            "THE RETRY DID NOT LAND THE WRITE: it recovered from nothing"
        assert calls["n"] == 2, "expected one retry, saw %d attempt(s)" % calls["n"]

        # ---- 2 · IT SELF-REPORTS, and the log GAINS a row rather than losing one
        assert fileio.RECOVERED, \
            "THE RECOVERY WAS SILENT: a run that heals without saying so is exactly the " \
            "fault the original CAPTURE-OVER-RETRY ruling was written against"
        assert fileio.RECOVERED[-1][1] == 2, "the ledger names which attempt succeeded"

        rows = [json.loads(ln) for ln in _io.open(fileio.LOG, encoding="utf-8")]
        assert len(rows) == 1, \
            "EVERY ATTEMPT MUST BE RECORDED: the log gained %d row(s), not 1" % len(rows)
        assert rows[0]["attempt"] == 1 and rows[0]["attempts"] == 3, \
            "the row carries WHICH attempt failed and out of how many - the detail a " \
            "bare fault could never give, and what makes the retry cost nothing in " \
            "diagnosability"
        assert rows[0]["op"] == "write:selftest", "and the phase it failed in"

        # ---- 2b · WHICH STEP, because the whole drive-it-and-see turns on it
        # A `scratch` fault means the contention is the DIRECTORY or the volume; a
        # `replace` fault means it is the TARGET - a lock on the existing file. Opposite
        # findings, and before the label they were the same row.
        assert rows[0]["step"] == "scratch", \
            "THE ROW DOES NOT SAY WHICH STEP FAILED: `scratch` and `replace` mean " \
            "opposite things about what is contending, and a drive period that cannot " \
            "tell them apart answers nothing. got %r" % rows[0].get("step")

        # ---- 3 · IT IS BOUNDED, and an unrecoverable fault still RAISES
        calls["n"] = 0
        fileio.open = always
        raised = False
        try:
            fileio.write_atomic(target, b"never lands", op="write:selftest")
        except OSError:
            raised = True
        finally:
            fileio.open = real_open

        assert raised, \
            "AN UNRECOVERABLE FAULT MUST STILL RAISE: a retry that swallows is the thing " \
            "the ruling forbids, and the caller's `finally` would never learn of it"
        assert calls["n"] == 3, "bounded at THREE attempts, saw %d" % calls["n"]

        # ---- 4 · AND THE TARGET IS UNTOUCHED - what atomicity buys over an in-place write
        assert _io.open(target, "rb").read() == b"new bytes", \
            "A FAILED WRITE CHANGED THE TARGET: the whole point of building in scratch is " \
            "that a lost race leaves the live file exactly as it was"
        leftovers = [f for f in os.listdir(tmpdir) if f.endswith(".fileio-tmp")]
        assert not leftovers, \
            "SCRATCH FILE LEFT BEHIND (%r): an untracked `.fileio-tmp` beside a source " \
            "file looks like a mutant, which is this change's own fault by the back door" \
            % leftovers

        # ---- 5 · THE DENOMINATOR. *"8 faults over 11 days"* is not a rate without it.
        assert fileio.WRITES >= 2, \
            "WRITES ARE NOT COUNTED: a fault count with no denominator cannot say whether "\
            "the rate changed, which is the only question the drive period asks. got %d" \
            % fileio.WRITES
        # ⚠ FOUR: one failed attempt on the write that recovered, plus three on the write
        # that exhausted. A first cut asserted 3 while its own message said four - the
        # prose was right and the check was wrong, which is the harder way round to spot.
        assert fileio.FAULTS == 4, \
            "FAULTS ARE NOT COUNTED: one failed attempt on the recovered write plus three "\
            "on the exhausted one is four recorded rows across two writes. got %d" \
            % fileio.FAULTS

        # ★ And the summary row lands, because an atexit that silently does nothing is
        # a denominator that is never written down.
        fileio.summary()
        rows = [json.loads(ln) for ln in _io.open(fileio.LOG, encoding="utf-8")]
        run = [r for r in rows if r.get("op") == "run"]
        assert len(run) == 1, "one run row, got %d" % len(run)
        assert run[0]["writes"] == fileio.WRITES and run[0]["faults"] == fileio.FAULTS, \
            "the run row must agree with the counters it reports"
    finally:
        fileio.LOG = real_log
        fileio.open = real_open
        del fileio.RECOVERED[:]
        # ⚠⚠ AND THE COUNTERS GO TO ZERO, which is not tidiness - it is the second half of
        # the redirect. `fileio.summary()` is registered with `atexit`, so it fires AFTER
        # this block has already restored `LOG`, and it wrote a synthetic
        # `{"tool": "_fileio_selftest.py", "writes": 2, "faults": 4}` row straight into the
        # real diagnostic log on its first outing. ★ Zeroing makes `summary()` take its own
        # `if not WRITES: return`, so the test leaves no trace by the tool's own rule
        # rather than by a special case.
        fileio.WRITES, fileio.FAULTS = 0, 0

    print("  fileio: recovers · bounded at 3 · records every attempt · says so · "
          "leaves the target whole · no scratch")
    return 0


if __name__ == "__main__":
    sys.exit(main())
