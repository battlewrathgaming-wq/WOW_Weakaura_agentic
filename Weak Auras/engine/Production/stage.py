"""
stage.py - the thing that turns an authored docket into a FILE in Docket_stage.

The class inventory (agent-owned) authors a docket per slot: the mechanical proof the slot can function - WA-literal,
every class decision already baked in (the watched spellId is IN the docket, because design put it there). This tool
does ONE job: read an authored docket, run the GATE, and on a clean read WRITE the docket as a file into
Docket_stage/<pid>/. That staged file is the CONTENT VEHICLE - it rides to final export verbatim.

  - clean read (no malform) -> stage the file + a stub of any soft flags beside it (ephemeral).
  - malform                 -> STUB the issue, do NOT stage; the docket goes back to the inventory for a fix.

This authors NOTHING. It gates and files. Past here the pipeline only WRAPS the staged content in the minimal
footprint headless WA needs; WA fills the rest of the table data we don't define.

Read locations are CONSTANTS (the class inventory is due an overhaul - repoint, don't rewrite).

  py stage.py            -> stage every authored docket in DOCKET_SOURCE
  py stage.py <file...>  -> stage the given docket(s)
"""
import glob
import json
import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
ENGINE = os.path.dirname(_THIS)
sys.path.insert(0, ENGINE)
import gate                                                       # engine/gate.py - the pre-flight word-match

DOCKET_SOURCE = os.path.join(_THIS, "_authored")                 # where the inventory hands authored dockets (constant)
STAGE = os.path.join(_THIS, "Docket_stage")                      # the content-vehicle queue, grouped by pid
CLASSDATA = gate._load(gate.CLASSDATA)                           # ability identity known-source (spellIds -> known-ability)


def _slug(s):
    return "".join(c if c.isalnum() else "_" for c in str(s)).strip("_").lower() or "docket"


def stage_one(docket):
    """gate the authored docket; on a clean read write it into Docket_stage/<pid>/. Returns the outcome record."""
    r = gate.gate(docket, classdata=CLASSDATA)
    pid = docket.get("pid", "_ungrouped")
    slug = _slug(docket.get("id"))
    out = {"id": docket.get("id"), "pid": pid, "passed": r["passed"], "flags": r["flags"]}
    if not r["passed"]:
        return out                                               # malform -> stubbed, not staged (goes back to inventory)
    d = os.path.join(STAGE, pid)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, slug + ".docket.json"), "w", encoding="utf-8") as f:
        json.dump(docket, f, ensure_ascii=False, indent=1)       # the content vehicle - written VERBATIM, no authoring
        f.write("\n")
    with open(os.path.join(d, slug + ".gate.json"), "w", encoding="utf-8") as f:
        json.dump(r["flags"], f, ensure_ascii=False, indent=1)   # the gate stub beside it - ephemeral (soft flags only)
        f.write("\n")
    out["staged"] = os.path.relpath(os.path.join(d, slug + ".docket.json"), ENGINE)
    return out


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    paths = args or sorted(glob.glob(os.path.join(DOCKET_SOURCE, "*.json")))
    if not paths:
        sys.exit("stage: no authored dockets in %s" % os.path.relpath(DOCKET_SOURCE, ENGINE))
    staged = blocked = 0
    for p in paths:
        docket = json.load(open(p, encoding="utf-8"))
        r = stage_one(docket)
        if r["passed"]:
            staged += 1
            soft = " (%d soft flag%s)" % (len(r["flags"]), "" if len(r["flags"]) == 1 else "s") if r["flags"] else ""
            print("  STAGED   %-22s -> %s%s" % (r["id"], r["staged"], soft))
        else:
            blocked += 1
            bad = [f for f in r["flags"] if f["verdict"] in ("malform", "invalid")]
            print("  BLOCKED  %-22s   %d incorrect input:" % (r["id"], len(bad)))
            for f in bad:
                print("             - %s (%s): %s" % (f["path"], f["verdict"], f["note"]))
    print("\nstage: %d staged, %d blocked" % (staged, blocked))


if __name__ == "__main__":
    main()
