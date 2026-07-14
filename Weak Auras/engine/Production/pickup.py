"""
pickup.py - the PICKUP: drain Docket_stage into Docket_complete, one PACK at a time.

A PID is a PACK ID (self-describing). A class inventory's auras are linked by pack id; once they pass the gate they're
staged into Docket_stage/<PID>/. Pickup drains each PID folder: gather the pack (one GROUP docket + its member
dockets), bundle them into ONE group import string (many auras, one group), land it in Docket_complete/, log the run
to the register, and clear the folder. It authors NOTHING - it wraps gated content (bundle runs the proven chain).

Pickup is DOMAIN logic (it knows dockets + packs). HOW it runs unattended is the RUNTIME's job (separate, deferred).
This is a BATCH drain - it processes every PID folder present now (or one target); the runtime is what makes it online.
Ignores anything that isn't a well-formed PID folder (loose files, scratch dirs, the .gate.json stubs) = staging flexibility.

Read locations are CONSTANTS (inventory + wrap chain both migrate later - repoint, don't rewrite).

  py pickup.py            -> drain every PID folder in Docket_stage
  py pickup.py <PID...>   -> drain the given pack(s)
"""
import glob
import json
import os
import shutil
import sys
import time

_THIS = os.path.dirname(os.path.abspath(__file__))
PLANE = os.path.join(_THIS, "..", "..", "plane")                 # the wrap chain (bundle->expand/fill/bounce/codec); migrates in later
sys.path.insert(0, PLANE)
import bundle as bundlemod                                        # the flat-group assembler (proven chain)

STAGE = os.path.join(_THIS, "Docket_stage")
COMPLETE = os.path.join(_THIS, "Docket_complete")
REGISTER = os.path.join(COMPLETE, "register.jsonl")              # the domain-level done-log (distinct from runtime receipts)
GROUP_REGIONS = ("dynamicgroup", "group")


def _drain_pack(pid):
    """One PID folder -> one group import string. Gather (group docket + members), bundle, land, register, clear."""
    pid_dir = os.path.join(STAGE, pid)
    files = sorted(glob.glob(os.path.join(pid_dir, "*.docket.json")))
    if not files:
        return {"pid": pid, "ok": False, "error": "no dockets in the pack folder"}
    items = [(f, json.load(open(f, encoding="utf-8"))) for f in files]
    groups = [(f, d) for f, d in items if d.get("regionType") in GROUP_REGIONS]
    members = [(f, d) for f, d in items if d.get("regionType") not in GROUP_REGIONS]
    if len(groups) != 1:                                         # a pack IS a group - exactly one group docket
        return {"pid": pid, "ok": False, "error": "expected 1 group docket, found %d" % len(groups)}

    manifest = {"group": groups[0][1], "children": [f for f, _ in members]}   # bundle loads the child paths
    try:
        s = bundlemod.bundle(manifest)                          # -> one group import string (round-trip-verified inside)
    except SystemExit as e:                                     # bundle guards with sys.exit; survive it, leave the folder
        return {"pid": pid, "ok": False, "error": "bundle: %s" % e}
    except Exception as e:
        return {"pid": pid, "ok": False, "error": "%s: %s" % (type(e).__name__, e)}

    os.makedirs(COMPLETE, exist_ok=True)
    out = os.path.join(COMPLETE, pid + ".txt")
    with open(out, "w", encoding="utf-8") as f:
        f.write(s + "\n")                                       # the content vehicle's final product - the import string
    rec = {"pid": pid, "group": groups[0][1].get("id"), "members": [d.get("id") for _, d in members],
           "chars": len(s), "when": time.strftime("%Y-%m-%dT%H:%M:%S"), "output": os.path.relpath(out, _THIS)}
    with open(REGISTER, "a", encoding="utf-8") as r:
        r.write(json.dumps(rec, ensure_ascii=False) + "\n")     # append to the register (runs-complete log)
    shutil.rmtree(pid_dir)                                       # drain = consume; the pack is spent exhaust now
    return {"pid": pid, "ok": True, **rec}


def main():
    pids = [a for a in sys.argv[1:] if not a.startswith("-")]
    if not pids:
        pids = sorted(d for d in os.listdir(STAGE) if os.path.isdir(os.path.join(STAGE, d))) if os.path.isdir(STAGE) else []
    if not pids:
        print("pickup: no PID folders in Docket_stage"); return
    ok = fail = 0
    for pid in pids:
        r = _drain_pack(pid)
        if r["ok"]:
            ok += 1
            print("  PACKED   %-22s -> %s  (%d member%s, %d chars)"
                  % (pid, r["output"], len(r["members"]), "" if len(r["members"]) == 1 else "s", r["chars"]))
        else:
            fail += 1
            print("  FAILED   %-22s   %s" % (pid, r["error"]))
    print("\npickup: %d packed, %d failed" % (ok, fail))


if __name__ == "__main__":
    main()
