"""mutate.py - break each guard on purpose, and confirm the smoke bites ON ITS OWN
MESSAGE.

    py addons/tools/mutate.py dungeonrun
    py addons/tools/mutate.py dungeonrun --only "the pin tops"    # substring filter
    py addons/tools/mutate.py --list

★ THE YIELD IS WEAK TESTS, NOT WEAK CODE. Across the sessions that built
COA_DungeonRun this found SIX bad tests and ONE live bug, against zero bad guards
the smoke had already passed. A green suite says *the code did what the test looked
at*; it never says *the test looked at the right thing*. This is the cheap way to
ask the second question, and the answer is usually about the test.
See memory/mutation-tests-find-weak-tests.md for the three forms it keeps finding.

★★★ RULING: A MUTATION ANCHOR IS CODE, NEVER PROSE.

Two anchors here were written against COMMENT text and both died the day that file
was documented - `-- ★ A CLICK DROPS IT` and a three-line note above
`refreshControls()`. ⚠ THE FAILURE MODE IS THE BAD ONE: the mutation reports
`?? ANCHOR ... found 0x` and STOPS TESTING ANYTHING while still sitting in the file
looking like coverage. It was caught only because the count moved, 216 -> 214.

★ So an anchor names the LINE THAT DOES THE WORK. If a comment must be in the
pattern to make it unique, the pattern is in the wrong place - reach for the
bracketing code instead.

Each mutation reports one of:

    ok BITES   the suite failed, on the assertion we NAMED. What we want.
    !! SILENT  the suite PASSED with the guard broken. The test is worthless.
    ~~ WRONG   it failed, but on someone else's assertion - the right failure with
               the wrong cause, which means the named one never ran. Order the
               precise assertion FIRST.
    ?? ANCHOR  the `find` text is gone or ambiguous. The spec has drifted from the
               source; fix the spec, do not delete the entry.

★ AND IT RESTORES, THEN VERIFIES THE RESTORE. This harness edits live source. The
scratchpad version left a mutation on disk TWICE, and both times it was caught only
because the next command happened to be the smoke. A restore you do not check is a
restore you are trusting - so every file is read back and compared, and anything
that did not go back is named loudly and fails the run.

The failure this guards against comes from OUTSIDE the process. The second incident
arrived as `OSError: Invalid argument` reading a repo file, and the likely cause was
the volume dropping mid-run (Battlewrath: "I had a connection issue"). If reads can
blip then writes can too, so the restore is wrapped per file: one that raises still
names itself instead of taking the whole report down, and a verify that cannot read
counts as DIRTY.
"""

import argparse
import io
import json
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fileio as _fio                     # noqa: E402 - path set above

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
SPECS = os.path.join(HERE, "mutations")
LUA = os.path.join(ROOT, ".tools", "lua51", "lua5.1.exe")


# ★ BINARY, DELIBERATELY. Text mode re-encodes line endings, so every file this
# harness touched came back byte-DIFFERENT from what git had - LF where the working
# tree holds CRLF. `git status` then reports modified files with an EMPTY diff, and
# a run that behaved perfectly looks like it left the tree dirty. That cost a real
# investigation: a restore was assumed broken when the content was identical.
#
# Bytes also make the post-restore verify mean what it says - byte for byte, with
# no encoding layer that could quietly "fix" a difference.
# ★★ AND EVERY TOUCH IS RECORDED WHEN IT FAULTS. Both `OSError` incidents landed
# here, so the byte access goes through fileio, which writes one line to
# addons/staging/io_faults.jsonl and RE-RAISES. His call, over the retry I offered:
# a retry hides the frequency you would diagnose from. See fileio.py.
read = _fio.read_bytes


# ★★★ THE TWO WRITES ARE LABELLED, because they are not the same event and the log
# could not tell them apart. APPLY has no subprocess before it; RESTORE lands the
# instant after `lua5.1.exe` had the file open and exited.
#
# ⚠ I read the first two captures backwards - assumed the mutant was LONGER, so
# "attempted > on disk" looked like the apply. Most mutants replace code with a
# one-line comment and are SHORTER, and measuring the clean file settled it: both
# were RESTORES. A guess wearing the clothes of a diagnosis, twice in one day.
#
# ★★ SO THE LABEL IS THE FALSIFIABLE PART. His hypothesis is a read/write race, and
# the reader is the EXITING LUA PROCESS rather than our own read - Windows does not
# guarantee the handle is released when `subprocess.run` returns. That predicts every
# future fault is a RESTORE. One landing on an APPLY kills it, and the log now says
# which without anyone having to reason from byte counts.
def write(path, data, why="write"):
    try:
        with open(path, "wb") as fh:
            fh.write(data)
    except OSError as e:
        _fio._record(why, path, e, nbytes=len(data) if data is not None else None)
        raise


def load_spec(name):
    path = os.path.join(SPECS, name + ".json")
    if not os.path.exists(path):
        sys.exit("no such spec: %s\n  have: %s" % (path, ", ".join(list_specs()) or "none"))
    return json.loads(read(path))


def list_specs():
    if not os.path.isdir(SPECS):
        return []
    return sorted(f[:-5] for f in os.listdir(SPECS) if f.endswith(".json"))


def run_smoke(smoke):
    r = subprocess.run([LUA, smoke], capture_output=True, text=True, cwd=ROOT)
    return r.returncode, (r.stdout or "") + (r.stderr or "")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("spec", nargs="?", help="name under addons/tools/mutations/")
    ap.add_argument("--list", action="store_true", help="list available specs")
    ap.add_argument("--only", help="run only mutations whose description contains this")
    args = ap.parse_args()

    if args.list or not args.spec:
        print("specs: " + (", ".join(list_specs()) or "none"))
        return 0

    os.chdir(ROOT)
    spec = load_spec(args.spec)
    files = spec["files"]
    muts = spec["mutations"]
    if args.only:
        muts = [m for m in muts if args.only.lower() in m["what"].lower()]
        if not muts:
            sys.exit("--only %r matched nothing" % args.only)

    # ★ Baseline first. Mutating on top of a red suite makes every result
    # meaningless, and the failure would look like the harness rather than the tree.
    smokes = sorted({m["smoke"] for m in muts})
    for smoke in smokes:
        code, out = run_smoke(smoke)
        if code != 0:
            print("!! BASELINE RED - fix the suite before mutating:\n" + out.strip())
            return 2

    # ★★★ THE READ IS INSIDE THE TRY, and that is not fussiness - it is the hole this
    # tool actually fell through. An `OSError: Invalid argument` on this line escaped
    # main() entirely, so the `finally` below never ran, and two mutants sat in the
    # tree looking like ordinary edits: `if true then` in task_cleu.lua and a rows
    # truncation in map.lua. ⚠ THE TREE WAS POISONED BY THE TOOL THAT GUARDS IT.
    #
    # ★★ The BASELINE RED check is what caught it, one run later - which is the case
    # for a tool refusing to work on a suite it has not seen go green first.
    bad = 0
    orig = {}
    try:
        orig = {p: read(p) for p in files.values()}
        for m in muts:
            path, what = files[m["file"]], m["what"]
            src = orig[path]
            # The spec is authored with plain \n; the working tree may hold \r\n.
            # Translate the PATTERN to the file's convention rather than the file
            # to the pattern's - the file's bytes are what must come back untouched.
            nl = b"\r\n" if b"\r\n" in src else b"\n"
            find = m["find"].encode("utf-8").replace(b"\n", nl)
            repl = m["replace"].encode("utf-8").replace(b"\n", nl)
            n = src.count(find)
            if n != 1:
                print("  ?? ANCHOR  %-46s  found %dx" % (what, n))
                bad += 1
                continue

            write(path, src.replace(find, repl, 1), "write:apply")
            code, out = run_smoke(m["smoke"])
            write(path, src, "write:restore")

            if code == 0:
                print("  !! SILENT  %-46s  the suite passed with this broken" % what)
                bad += 1
            elif m["expect"] not in out:
                # ★ SHOW WHAT ACTUALLY FIRED, not the last line of the traceback.
                # This printed "[C]: ?" for every WRONG verdict, which is the tail of
                # a Lua stack trace and tells you nothing - so a WRONG could not be
                # diagnosed without re-running the mutation by hand. The interpreter
                # puts the assertion message on the FIRST line, after "<file>:<n>:".
                hit = ""
                for line in out.splitlines():
                    if ".lua:" in line and ("assert" in line or ": " in line):
                        hit = line.strip()
                        break
                if ".lua:" in hit:
                    hit = hit.split(".lua:", 1)[1]
                    hit = hit.split(":", 1)[-1].strip()
                print("  ~~ WRONG   %-46s  bit, but on a DIFFERENT assertion" % what)
                print("             wanted %r" % m["expect"])
                print("             fired  %s" % (hit or "(no message found)")[:104])
                bad += 1
            else:
                print("  ok BITES   %-46s  -> %s" % (what, m["expect"]))
    finally:
        # ★ Restore, then VERIFY the restore. See the module docstring.
        #
        # Every step here is wrapped, because the failure this guards against comes
        # from OUTSIDE the process: the second scratchpad incident arrived as
        # `OSError: Invalid argument` on a repo file, and the likely cause was the
        # volume dropping mid-run. If reads can blip then WRITES can too - so a
        # restore that raises must still name the file rather than taking the whole
        # report down with it, and a verify that cannot read is treated as DIRTY.
        dirty = []
        for p, s in orig.items():
            try:
                write(p, s)
                if read(p) != s:
                    dirty.append(p + "  (restored, but does not match)")
            except OSError as e:
                dirty.append("%s  (%s)" % (p, e))
        if dirty:
            print("\n!! TREE LEFT MUTATED - `git checkout --` these:")
            for p in dirty:
                print("   " + p)
            bad += len(dirty)

    for smoke in smokes:
        code, out = run_smoke(smoke)
        if code != 0:
            print("!! POST-RUN RED - the tree did not come back clean:\n" + out.strip())
            bad += 1

    print("\n%d/%d mutations bite on their own message" % (len(muts) - bad, len(muts)))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
