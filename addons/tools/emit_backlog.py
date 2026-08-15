"""emit_backlog.py - lift code out to the backlog BEFORE it is cut (§112).

★★★ WHY A TOOL AND NOT A COPY-PASTE. His: *"can we emit the content wholesale to a
backlog folder as snippets, before we cut them from code?"* Wholesale is the operative
word - a hand-picked excerpt is a summary, and a summary of code is exactly what you
cannot rebuild from. This lifts whole files, whole mutation entries and whole smoke
regions, and it records where each came from.

★★ AND IT RUNS BEFORE THE CUT, never after. Afterwards the line numbers are gone, the
mutation anchors no longer match, and the smoke regions have to be found by memory -
which is how a removal quietly becomes a loss.

⚠ THE BACKLOG IS NOT A HOLDING PEN FOR LIVE CODE. It sits outside `deploy.py`'s
MANIFEST (which is keyed by addon folder name), so nothing here can reach a client.
Its job is reconstruction, and `addons/planning/debug_suite_plan.md` says what the
reconstruction owes.

Usage:
    py addons\\tools\\emit_backlog.py debug_suite
"""
import io
import json
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))

# ---------------------------------------------------------------------
# ★ THE SPEC. One entry per backlog set: whole files, mutation files by their
# `file` key, smoke regions by the symbols that appear in them, and named code
# blocks pulled out by their opening line.
# ---------------------------------------------------------------------
SETS = {
    "debug_suite": {
        "why": "driver.lua and walk.lua leave COA_DungeonRun - the recorder records, "
               "it does not drive and it does not test.",
        "plan": "addons/planning/debug_suite_plan.md",
        "files": [
            "addons/COA_DungeonRun/driver.lua",
            "addons/COA_DungeonRun/walk.lua",
        ],
        "mutations": {"spec": "addons/tools/mutations/dungeonrun.json",
                      "keys": ["driver", "walk"]},
        "smoke": {"path": "addons/tools/smoke/smoke_dungeonrunpromoter.lua",
                  "symbols": ["Driver.", "Walk.", 'load("driver', 'load("walk'],
                  "gap": 12},
        "blocks": [
            {"path": "addons/COA_DungeonRun/core.lua",
             "open": 'elseif cmd == "drive" then',
             "close": r"^\s*elseif cmd == ", "name": "core_verb_drive"},
            {"path": "addons/COA_DungeonRun/core.lua",
             "open": 'elseif cmd == "walk" then',
             "close": r"^\s*elseif cmd == ", "name": "core_verb_walk"},
            {"path": "addons/COA_DungeonRun/promoter.lua",
             # ★ Opens on the COMMENT, not the CreateFrame. The rationale above a
             # widget is the part that cannot be rebuilt from the widget - "a slash
             # command you have to already know is not a surface" is a design
             # decision, and the code below it is just its consequence.
             "open": "§95: A PLAY BESIDE THE ROUTE",
             "close": r"^\s*nameBox:SetPoint", "name": "promoter_play_button"},
            # ⚠ The REGISTRATION is a separate site from the creation, and the
            # first pass lifted only the button. A registry entry left behind is a
            # key pointing at nothing - exactly the §97.1 miss class.
            {"path": "addons/COA_DungeonRun/promoter.lua",
             "open": 'R("promoter.play", playBtn',
             "close": r'^\s*R\("promoter\.note"', "name": "promoter_play_registration"},
            {"path": "addons/COA_DungeonRun/core.lua",
             "open": "NS.Driver.Init()",
             "close": r"^\s*NS\.UI\.Init\(\)", "name": "core_init_calls"},
        ],
    },
}


def read(path):
    return io.open(os.path.join(ROOT, path), encoding="utf-8", newline="").read()


def write(path, text):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    io.open(full, "w", encoding="utf-8", newline="\n").write(text)


def head():
    """The commit the backlog was taken at - the actual recovery point."""
    try:
        return subprocess.check_output(["git", "rev-parse", "--short", "HEAD"],
                                       cwd=ROOT).decode().strip()
    except Exception:
        return "unknown"


def lift_smoke(spec):
    """Contiguous regions mentioning the symbols, with their line numbers kept.

    ⚠ Regions, not lines. An assertion without the fixture above it is not a test,
    it is a sentence - so anything within `gap` lines of a hit rides along.
    """
    src = read(spec["path"])
    lines = src.split("\n")
    hits = [i for i, l in enumerate(lines)
            if any(sym in l for sym in spec["symbols"])]
    if not hits:
        return [], 0
    runs, start, prev = [], hits[0], hits[0]
    for i in hits[1:]:
        if i - prev > spec["gap"]:
            runs.append((start, prev))
            start = i
        prev = i
    runs.append((start, prev))
    out = []
    for a, b in runs:
        lo, hi = max(0, a - 3), min(len(lines), b + 4)   # a little context each side
        out.append((lo + 1, hi, "\n".join(lines[lo:hi])))
    return out, len(hits)


def lift_block(b):
    src = read(b["path"]).split("\n")
    start = next((i for i, l in enumerate(src) if b["open"] in l), None)
    if start is None:
        return None
    close = re.compile(b["close"])
    end = next((i for i in range(start + 1, len(src)) if close.match(src[i])), len(src))
    return start + 1, end, "\n".join(src[start:end])


def main():
    name = sys.argv[1] if len(sys.argv) > 1 else ""
    if name not in SETS:
        print("usage: py addons\\tools\\emit_backlog.py <%s>" % "|".join(SETS))
        return 2
    spec = SETS[name]
    out = "addons/backlog/%s" % name
    at = head()
    index = ["# Backlog: %s" % name, "",
             "_Lifted at commit **%s** - the last commit with this code live._" % at, "",
             spec["why"], "",
             "★ What the reconstruction owes: `%s`" % spec["plan"], "",
             "⚠ **Nothing here is live.** `deploy.py`'s MANIFEST is keyed by addon folder",
             "name, so this folder cannot reach a client.", "", "---", ""]

    # --- whole files -------------------------------------------------
    index.append("## Whole files")
    index.append("")
    for f in spec["files"]:
        text = read(f)
        base = os.path.basename(f)
        write("%s/%s" % (out, base), text)
        index.append("- `%s` - %d lines, from `%s`" % (base, text.count("\n") + 1, f))
    index.append("")

    # --- mutations ---------------------------------------------------
    ms = json.load(io.open(os.path.join(ROOT, spec["mutations"]["spec"]),
                           encoding="utf-8"))
    keep = [m for m in ms["mutations"] if m.get("file") in spec["mutations"]["keys"]]
    files = {k: v for k, v in ms["files"].items() if k in spec["mutations"]["keys"]}
    write("%s/mutations.json" % out,
          json.dumps({"note": "lifted from %s at %s - re-point `smoke` and `find` "
                              "before reuse" % (spec["mutations"]["spec"], at),
                      "files": files, "mutations": keep},
                     ensure_ascii=False, indent=2) + "\n")
    index += ["## Mutations", "",
              "`mutations.json` - **%d** entries. Each is a guard with its own message;"
              % len(keep),
              "the `find` anchors point at code that is about to move, so they are a",
              "SPECIFICATION here rather than something runnable.", ""]
    for m in keep:
        index.append("- [%s] %s" % (m["file"], m["what"]))
    index.append("")

    # --- smoke regions -----------------------------------------------
    regions, nhits = lift_smoke(spec["smoke"])
    body = ["-- Smoke regions lifted from %s at %s." % (spec["smoke"]["path"], at),
            "-- ⚠ NOT RUNNABLE. Fixtures above and below each region were left behind;",
            "-- these are the assertions and their immediate context, kept so the rules",
            "-- they encode can be rebuilt against whatever drives next.", ""]
    for lo, hi, text in regions:
        body += ["", "-- ===== original lines %d-%d =====" % (lo, hi), text]
    write("%s/smoke_regions.lua" % out, "\n".join(body) + "\n")
    index += ["## Smoke regions", "",
              "`smoke_regions.lua` - **%d** regions, %d referencing lines."
              % (len(regions), nhits),
              "⚠ Not runnable: the fixtures around them stayed behind.", ""]

    # --- named blocks ------------------------------------------------
    index.append("## Call sites")
    index.append("")
    for b in spec["blocks"]:
        got = lift_block(b)
        if not got:
            index.append("- ⚠ `%s` NOT FOUND in `%s`" % (b["name"], b["path"]))
            continue
        lo, hi, text = got
        write("%s/%s.lua" % (out, b["name"]),
              "-- %s:%d-%d at %s\n\n%s\n" % (b["path"], lo, hi, at, text))
        index.append("- `%s.lua` - `%s:%d-%d`" % (b["name"], b["path"], lo, hi))
    index.append("")

    write("%s/README.md" % out, "\n".join(index))
    print("backlog/%s written at %s: %d file(s), %d mutation(s), %d smoke region(s)"
          % (name, at, len(spec["files"]), len(keep), len(regions)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
