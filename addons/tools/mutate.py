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

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
SPECS = os.path.join(HERE, "mutations")
LUA = os.path.join(ROOT, ".tools", "lua51", "lua5.1.exe")


def read(path):
    return io.open(path, encoding="utf-8").read()


def write(path, text):
    io.open(path, "w", encoding="utf-8", newline="\n").write(text)


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

    orig = {p: read(p) for p in files.values()}
    bad = 0
    try:
        for m in muts:
            path, what = files[m["file"]], m["what"]
            src = orig[path]
            n = src.count(m["find"])
            if n != 1:
                print("  ?? ANCHOR  %-46s  found %dx" % (what, n))
                bad += 1
                continue

            write(path, src.replace(m["find"], m["replace"], 1))
            code, out = run_smoke(m["smoke"])
            write(path, src)

            if code == 0:
                print("  !! SILENT  %-46s  the suite passed with this broken" % what)
                bad += 1
            elif m["expect"] not in out:
                last = (out.strip().splitlines() or [""])[-1][:120]
                print("  ~~ WRONG   %-46s  bit, but not on its own message" % what)
                print("             wanted %r, last line: %s" % (m["expect"], last))
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
