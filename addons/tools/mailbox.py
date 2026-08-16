r"""mailbox.py - the one place anything I make gets handed over.

★★★ WHY (Battlewrath, 2026-08-16): *"You ad-hoc updated the options which as changing
the tool for conveinence. If we want that, it goes into a mailbox on the bench."*

I built two tools and grew the bench menu an eighth key to reach them. ⚠ THE MENU IS A
CONTRACT - seven keys someone has learned - and I edited it for my own convenience,
which is the thing a tool's users never asked for and always pay for. Worse, it does not
stop: every tool I make would want a key, and the menu becomes a list of my output
rather than a description of the work.

★ SO THE MAILBOX IS THE LAST STRUCTURAL ADDITION. One stable slot. Everything I produce
lands IN it. The numbers stay the working loop; letters are the meta shelf, beside
[A]dvanced and [Q]uit.

⚠ AN ENVELOPE NEVER MOVES THE THING. Artifacts stay where they belong - staging/,
records/, the board's workspace - and the envelope points at them, carrying what it is,
when it landed and WHY. A mailbox that copies files is a second copy that goes stale.

    py addons/tools/mailbox.py                    list what is waiting
    py addons/tools/mailbox.py open 2             open item 2
    py addons/tools/mailbox.py add --title ... --what ... --why ... --open <path>
"""

import argparse
import datetime
import glob
import io
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
ROOT = os.path.dirname(os.path.dirname(HERE))
BOX = ROOT + "/addons/mailbox"


def items():
    """Newest first. An unreadable envelope is LISTED, not hidden - a file that
    exists and cannot be parsed is a thing to see, not a thing to skip."""
    out = []
    for p in sorted(glob.glob(BOX + "/*.json")):
        try:
            e = json.load(io.open(p, encoding="utf-8"))
        except Exception as err:
            e = {"title": os.path.basename(p), "what": "UNREADABLE: %s" % err,
                 "why": "", "landed": "", "open": "", "run": ""}
        e["_path"] = p
        out.append(e)
    out.sort(key=lambda e: e.get("landed", ""), reverse=True)
    return out


def show():
    es = items()
    print("")
    if not es:
        print("   The mailbox is empty.")
        print("")
        print("   Things land here rather than becoming menu keys. Nothing is waiting.")
        return 0
    print("   %d item(s) waiting. Nothing here has been opened for you." % len(es))
    print("")
    for i, e in enumerate(es, 1):
        mark = "[%d]" % i if i < 10 else "   "
        print("   %s %s" % (mark, e.get("title", "(untitled)")))
        if e.get("what"):
            print("        %s" % e["what"])
        if e.get("why"):
            print("        why: %s" % e["why"])
        tgt = e.get("open") or e.get("run") or ""
        print("        %s   landed %s" % (tgt, (e.get("landed") or "")[:16]))
        print("")
    if len(es) > 9:
        # ⚠ SAID, NOT SILENT. `choice` takes single keys, so items past nine are
        # listed and not openable from here.
        print("   ⚠ %d item(s) past [9] are listed but not keyable - open them by path."
              % (len(es) - 9))
        print("")
    return 0


def open_item(n):
    es = items()
    if not 1 <= n <= len(es):
        print("   no item %d" % n)
        return 1
    e = es[n - 1]
    tgt = e.get("open")
    if tgt:
        p = os.path.join(ROOT, tgt).replace("/", os.sep)
        if not os.path.exists(p):
            # ★ The envelope outlived the thing. Say which, rather than failing blank.
            print("   %s is gone from disk." % tgt)
            if e.get("run"):
                print("   remake it:  %s" % e["run"])
            return 1
        print("   opening %s" % tgt)
        os.startfile(p) if hasattr(os, "startfile") else subprocess.call(["xdg-open", p])
        return 0
    if e.get("run"):
        print("   running %s" % e["run"])
        return subprocess.call(e["run"], shell=True, cwd=ROOT)
    print("   nothing to open on that item")
    return 1


def add(a):
    if not os.path.isdir(BOX):
        os.makedirs(BOX)
    stamp = datetime.datetime.now()
    slug = "".join(c if c.isalnum() else "-" for c in a.title.lower()).strip("-")[:48]
    e = {"title": a.title, "what": a.what or "", "why": a.why or "",
         "landed": stamp.strftime("%Y-%m-%d %H:%M:%S"),
         "open": (a.open or "").replace("\\", "/"), "run": a.run or ""}
    p = "%s/%s__%s.json" % (BOX, stamp.strftime("%Y%m%d_%H%M%S"), slug)
    io.open(p, "w", encoding="utf-8", newline="\n").write(
        json.dumps(e, indent=1, ensure_ascii=False))
    print("landed: %s" % a.title)
    return 0


def main():
    ap = argparse.ArgumentParser(add_help=False)
    sub = ap.add_subparsers(dest="cmd")
    sub.add_parser("list")
    o = sub.add_parser("open")
    o.add_argument("n", type=int)
    d = sub.add_parser("add")
    d.add_argument("--title", required=True)
    d.add_argument("--what", default="")
    d.add_argument("--why", default="")
    d.add_argument("--open", default="")
    d.add_argument("--run", default="")
    a = ap.parse_args()
    if a.cmd == "open":
        return open_item(a.n)
    if a.cmd == "add":
        return add(a)
    return show()


if __name__ == "__main__":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    sys.exit(main())
