# -*- coding: utf-8 -*-
r"""check_anchors.py - every mutation's `find` string resolves in its file, exactly once.

    py addons/tools/check_anchors.py            every spec
    py addons/tools/check_anchors.py dungeonrun one spec
    py addons/tools/check_anchors.py --all      list the ones that resolve too, not just faults

★★★ WHY THIS EXISTS - THREE BREAKS IN THREE CONSECUTIVE COMMITS, all mine, 2026-08-27.

A mutation's `find` quotes a line of Lua VERBATIM. Edit that line and the anchor stops
resolving - and the row does not disappear. It sits in the file reading like a guard:

    §706  the `AcceptanceOf` fallback was rewritten     anchor caught, moved in the same commit
    §707  `object.lua`'s note setter was rewritten      anchor MISSED -> `?? ANCHOR found 0x`
    §708  §707's own new anchor was rewritten           anchor MISSED -> `?? ANCHOR found 0x`

⚠⚠ THE LESSON WAS NOT FORGOTTEN. It was written into two commit messages and broken anyway,
because each break wore a different shape. `machines-do-the-mechanical-work`: a discipline that
has to be REMEMBERED at the moment of an unrelated edit is not a discipline, it is luck.

★★ AND `mutate.py` ALREADY REPORTS THIS. It prints `?? ANCHOR found 0x` and always has. What
it cannot be is CHEAP - it rewrites files and runs a smoke per row, minutes for 388 of them, so
it is a thing you run at the end rather than after an edit. This asks the same question in
under a second, which is the only reason it gets asked.

⚠ WHAT IT CANNOT SAY: that the anchor still points at the RIGHT line. A `find` that resolves
somewhere irrelevant is a live anchor guarding nothing, and only `mutate.py` running the smoke
can tell. ⟶ This proves the anchor is ATTACHED, never that it is aimed.

★★★ EXACTLY ONE THING IS FATAL, and the exemption is deliberate:

    [!] EXIT 1   a `find` that resolves 0 times, or more than once, in a row NOT labelled
                 `[PENDING`. Unambiguous: the file is named, the string is ours, it is absent
                 or it is not unique - and a non-unique anchor mutates whichever came first.
    ~   TOLD     a `[PENDING ...]` row. `dungeonrun.json` carries five of them parked behind
                 the Actions profile pass (§365) and one has been orphaned for weeks ON
                 PURPOSE. Failing on those would make this permanently red, and a gate that
                 cannot be green trains its reader to ignore it - the lesson `check_cites.py`
                 paid for at §468.
"""

import io
import json
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
SPECS = os.path.join(HERE, "mutations")
ROOT = os.path.dirname(os.path.dirname(HERE))


def read(path):
    try:
        return io.open(path, encoding="utf-8", errors="replace").read()
    except IOError:
        return None


def main():
    argv = [a for a in sys.argv[1:] if not a.startswith("--")]
    show_all = "--all" in sys.argv[1:]

    names = sorted(f for f in os.listdir(SPECS) if f.endswith(".json"))
    if argv:
        names = [n for n in names if any(a in n for a in argv)]
        if not names:
            sys.exit("no spec matched %r" % argv)

    orphan, dupe, ok, parked, nofile = [], [], [], [], []

    for name in names:
        spec = json.loads(read(os.path.join(SPECS, name)))
        files = spec.get("files", {})
        for m in spec.get("mutations", []):
            what = m.get("what", "")
            key, find = m.get("file"), m.get("find")
            where = "%s · %s" % (name.replace(".json", ""), what[:64])
            rel = files.get(key)
            if not rel:
                nofile.append((where, key))
                continue
            body = read(os.path.join(ROOT, rel))
            if body is None:
                nofile.append((where, rel))
                continue
            n = body.count(find) if find else 0
            # ⚠ PARKED ROWS ARE COUNTED AND SHOWN, never silently skipped - an exemption
            # nobody can see is indistinguishable from a checker that missed something.
            if what.startswith("[PENDING"):
                if n != 1:
                    parked.append((where, n))
                continue
            if n == 0:
                orphan.append((where, rel))
            elif n > 1:
                dupe.append((where, rel, n))
            else:
                ok.append(where)

    print("")
    print("   MUTATION ANCHORS - does every `find` still resolve, exactly once")
    print("   " + "-" * 64)

    for where, rel in orphan:
        print("   [!] ORPHAN   %s" % where)
        print("                its `find` is NOT in %s - the row looks like a guard and is not" % rel)
    for where, rel, n in dupe:
        print("   [!] NOT UNIQUE %s" % where)
        print("                its `find` appears %dx in %s - it mutates whichever comes first" % (n, rel))
    for where, key in nofile:
        print("   [!] NO FILE  %s  (`%s` is not in the spec's `files` map)" % (where, key))
    for where, n in parked:
        print("   ~   PARKED   %s  (resolves %dx)" % (where, n))
    if parked:
        print("       ★ `[PENDING ...]` rows are TOLD, never fatal - see the header.")

    if show_all:
        for where in ok:
            print("   ok  %s" % where)

    bad = len(orphan) + len(dupe) + len(nofile)
    print("")
    print("   resolved %d   orphan %d   not-unique %d   no-file %d   parked-and-loose %d"
          % (len(ok), len(orphan), len(dupe), len(nofile), len(parked)))
    print("")
    print("   ⚠ ATTACHED IS NOT AIMED. This proves the `find` is present; whether it still")
    print("     quotes the line the row means is what `mutate.py` answers by running it.")
    print("")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
