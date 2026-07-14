"""
run.py - the RUNTIME: run the Production pipeline scripts, capture receipts, report.

The fresh terminal entry for the machine. It runs the py scripts (stage -> pickup) as SUBPROCESSES, captures each
one's output + exit code as a RECEIPT, and prints a clear report - so you can run it yourself, look at the output, and
KNOW it worked, without taking anyone's word for it. It survives a script erroring (captured as a non-zero exit, not a
crash). It knows NOTHING about dockets or packs - that is pickup's domain; the runtime just runs scripts and reports.

Split (Battlewrath): pickup = DOMAIN (dockets/packs) · runtime = INFRA (run the scripts, receipts, resilience,
visibility). Online/unattended operation + menu-spawn are deferred - this is the run-once, look-and-trust core.

  py run.py            -> run the full pipeline (stage -> pickup); prints a report, writes a receipt
"""
import json
import os
import subprocess
import sys
import time

_THIS = os.path.dirname(os.path.abspath(__file__))
RECEIPTS = os.path.join(_THIS, "receipts")
COMPLETE = os.path.join(_THIS, "Docket_complete")
REGISTER = os.path.join(COMPLETE, "register.jsonl")
STEPS = [("stage", "stage.py"), ("pickup", "pickup.py")]         # the pipeline, in order


def _run_step(script):
    p = subprocess.run(["py", script], cwd=_THIS, capture_output=True, text=True, encoding="utf-8", errors="replace")
    return {"script": script, "exit": p.returncode, "out": (p.stdout or "").rstrip(), "err": (p.stderr or "").rstrip()}


def main():
    stamp = time.strftime("%Y-%m-%dT%H:%M:%S")
    print("=== Production run  %s ===\n" % stamp)

    steps = []
    for name, script in STEPS:
        r = _run_step(script); r["name"] = name; steps.append(r)
        print("[%-6s] %s" % (name, "ok" if r["exit"] == 0 else "EXIT %d" % r["exit"]))
        for line in r["out"].splitlines():
            print("   " + line)
        for line in r["err"].splitlines():
            print("   ! " + line)                                # a real crash surfaces here, not swallowed
        print()

    # visibility: the actual products, where they are, and the running log
    outs = sorted(f for f in os.listdir(COMPLETE) if f.endswith(".txt")) if os.path.isdir(COMPLETE) else []
    print("Outputs (Docket_complete/ - import strings, ready to paste into WA):")
    for f in outs:
        print("   %-30s %d bytes" % (f, os.path.getsize(os.path.join(COMPLETE, f))))
    runs = sum(1 for _ in open(REGISTER, encoding="utf-8")) if os.path.exists(REGISTER) else 0
    print("Register: %d run(s) logged (Docket_complete/register.jsonl)" % runs)

    # the receipt: an independent record of THIS run (what ran, exit codes, products)
    os.makedirs(RECEIPTS, exist_ok=True)
    errs = [s for s in steps if s["exit"] != 0]
    receipt = {"when": stamp, "ok": not errs, "steps": steps, "outputs": outs}
    rp = os.path.join(RECEIPTS, stamp.replace(":", "") + ".json")
    with open(rp, "w", encoding="utf-8") as f:
        json.dump(receipt, f, ensure_ascii=False, indent=1)
    print("Receipt: %s" % os.path.relpath(rp, _THIS))

    print("\nRUN %s  -  %d step%s, %d error%s"
          % ("OK" if not errs else "HAD ERRORS", len(steps), "" if len(steps) == 1 else "s",
             len(errs), "" if len(errs) == 1 else "s"))
    sys.exit(0 if not errs else 1)


if __name__ == "__main__":
    main()
