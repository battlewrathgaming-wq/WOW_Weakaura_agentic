"""
console.py - the Production CONSOLE: a drivable terminal for the machine.

Spawn it and DRIVE it - type commands, watch the state change, inspect the actual products. It stays open (a REPL),
unlike run.py (the one-shot receipted runner, which this can invoke via `run`). This is the fresh terminal you sit in.

Commands:
  status              what's staged / completed / in the register
  stage               author -> gate -> Docket_stage
  pickup [PID]        drain Docket_stage -> Docket_complete   (all packs, or one PID)
  run                 stage then pickup, receipted  (= run.py)
  show <PID>          inspect a pack: staged dockets, or the DECODED group (proves a real aura, not just a file)
  clear               wipe stage + complete + receipts (fresh start)
  help  ·  quit / exit

  py console.py
"""
import glob
import json
import os
import shutil
import subprocess
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
STAGE = os.path.join(_THIS, "Docket_stage")
COMPLETE = os.path.join(_THIS, "Docket_complete")
REGISTER = os.path.join(COMPLETE, "register.jsonl")
sys.path.insert(0, os.path.join(_THIS, "..", "..", "plane"))
sys.path.insert(0, os.path.join(_THIS, "..", ".."))
import weakaura_codec as wc                                       # to DECODE a product in `show`


def _sh(args):
    """run a pipeline script as a subprocess, streaming its output straight into the console (live)."""
    subprocess.run(["py"] + args, cwd=_THIS)


def _pids(root):
    return sorted(d for d in os.listdir(root) if os.path.isdir(os.path.join(root, d))) if os.path.isdir(root) else []


def cmd_status():
    staged = _pids(STAGE)
    print("  STAGED packs:")
    for p in staged or []:
        n = len(glob.glob(os.path.join(STAGE, p, "*.docket.json")))
        print("    %-24s %d docket(s)" % (p, n))
    if not staged:
        print("    (none)")
    done = sorted(f for f in os.listdir(COMPLETE) if f.endswith(".txt")) if os.path.isdir(COMPLETE) else []
    print("  COMPLETED:")
    for f in done or []:
        print("    %-24s %d bytes" % (f, os.path.getsize(os.path.join(COMPLETE, f))))
    if not done:
        print("    (none)")
    runs = sum(1 for _ in open(REGISTER, encoding="utf-8")) if os.path.exists(REGISTER) else 0
    print("  REGISTER: %d run(s) logged" % runs)


def cmd_show(pid):
    txt = os.path.join(COMPLETE, pid + ".txt")
    stg = os.path.join(STAGE, pid)
    if os.path.exists(txt):                                       # completed -> DECODE it, prove it's a real group
        s = open(txt, encoding="utf-8").read().strip()
        try:
            d, ch = wc.decode_group_import_string(s)
            print("  %s  (%d chars, decoded):" % (pid, len(s)))
            print("    group   : %s  [%s]" % (d.get("id"), d.get("regionType")))
            print("    children: %s" % ", ".join("%s [%s]" % (c.get("id"), c.get("regionType")) for c in ch))
            print("    controlledChildren: %s" % (d.get("controlledChildren") or []))
        except Exception as e:
            print("  %s: could not decode as a group (%s)" % (pid, e))
    elif os.path.isdir(stg):                                      # still staged -> list the pack's dockets
        print("  %s  (staged):" % pid)
        for f in sorted(glob.glob(os.path.join(stg, "*.docket.json"))):
            d = json.load(open(f, encoding="utf-8"))
            print("    %-26s %s [%s]" % (os.path.basename(f), d.get("id"), d.get("regionType")))
    else:
        print("  %s: not found (not staged, not completed)" % pid)


def cmd_clear():
    for root in (STAGE, COMPLETE, os.path.join(_THIS, "receipts")):
        if os.path.isdir(root):
            for e in os.listdir(root):
                p = os.path.join(root, e)
                shutil.rmtree(p) if os.path.isdir(p) else os.remove(p)
    print("  cleared: Docket_stage, Docket_complete, receipts")


HELP = __doc__[__doc__.index("Commands:"):__doc__.index("\n\n  py")]


def main():
    print("=== COA Production console ===   (type 'help', 'quit' to leave)")
    while True:
        try:
            line = input("prod> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break
        if not line:
            continue
        parts = line.split()
        c, args = parts[0].lower(), parts[1:]
        if c in ("quit", "exit", "q"):
            break
        elif c in ("help", "h", "?"):
            print(HELP)
        elif c == "status":
            cmd_status()
        elif c == "stage":
            _sh(["stage.py"])
        elif c == "pickup":
            _sh(["pickup.py"] + args)
        elif c == "run":
            _sh(["run.py"])
        elif c == "show":
            cmd_show(args[0]) if args else print("  usage: show <PID>")
        elif c == "clear":
            cmd_clear()
        else:
            print("  unknown command: %r  (type 'help')" % c)


if __name__ == "__main__":
    main()
