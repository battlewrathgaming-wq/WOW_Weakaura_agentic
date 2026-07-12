"""
runner.py - the service-call runner: Claude's proxy for machinery-calling under YOUR runtime.

Leave this open in a terminal (launch it yourself - that's the whole point). It polls
runtime/queue/ for service-call requests (small JSON files Claude writes), executes ONLY
whitelisted services under YOUR runtime, prints each call live, and writes a receipt to
runtime/receipts/ that Claude reads back.

Because YOU launched it, every call is YOUR process: kill Claude's session and this keeps
running - in-flight calls finish, receipts land. Steering (Claude) and machinery (here) are
decoupled by process ownership, not by promise. That is the kill-test, satisfied structurally.

  py runner.py        # poll the queue ~1s, stdlib only, no deps. Ctrl-C to stop.

SAFETY: only SERVICES in the whitelist below ever run. An unknown/absent service is REFUSED
(a receipt is written recording the refusal; nothing executes). There is no arbitrary-shell path.
"""
import datetime
import glob
import json
import os
import subprocess
import sys
import time

_ROOT = os.path.dirname(os.path.abspath(__file__))
RUNTIME = os.path.join(_ROOT, "runtime")
QUEUE = os.path.join(RUNTIME, "queue")
RECEIPTS = os.path.join(RUNTIME, "receipts")
PROCESSED = os.path.join(RUNTIME, "processed")
ERRORED = os.path.join(RUNTIME, "errored")      # quarantine for a file that blew up mid-handle
_WA = os.path.join(_ROOT, "Weak Auras")


# --- the WHITELIST: service name -> argv builder. Conservative: read-only to start. -------
def _svc_decode(args):
    """decode <mode> [name]   - mode in peek/diff/raw (read-only inspection)."""
    mode = args[0] if args else "peek"
    if mode not in ("peek", "diff", "raw"):
        raise ValueError("decode mode must be peek/diff/raw, got %r" % mode)
    argv = ["py", os.path.join(_WA, "plane", "decode.py"), mode]
    if len(args) > 1 and args[1]:
        argv.append(str(args[1]))
    return argv


def _svc_verify(args):
    """verify [verify [stem...]]  - the assemble-stage regression harness (READ-ONLY).
    Refuses `bless`: moving the golden baseline is a deliberate LOCAL judgment, never a
    runner-triggerable action."""
    if args and str(args[0]) == "bless":
        raise ValueError("verify is read-only via the runner; run `bless` locally to move a golden")
    return ["py", os.path.join(_WA, "plane", "verify.py")] + [str(a) for a in args]


def _svc_seeds(args):
    """seeds probe <wa-source-file> [mode]  - READ-ONLY defaults probe (prints; writes nothing).
    `freeze` (writing trigger_seed_defaults.json) is refused - that's a deliberate LOCAL action."""
    if not args or str(args[0]) != "probe":
        raise ValueError("seeds via the runner is probe-only (read-only); run `freeze` locally")
    return ["py", os.path.join(_WA, "wa_index", "extract_seed_defaults.py")] + [str(a) for a in args]


SERVICES = {
    "decode": _svc_decode,
    "verify": _svc_verify,           # read-only regression harness; `bless` refused
    "seeds": _svc_seeds,             # read-only defaults probe; `freeze` refused
    # add here (one line each), only with Battlewrath's approval:
    #   "derive":  lambda a: ["py", os.path.join(_WA, "plane", "derive_contracts.py")],
    #   "assemble":lambda a: ["py", os.path.join(_WA, "plane", "assemble.py"), os.path.join(_WA,"plane","boms", str(a[0]))],
}


def _now():
    return datetime.datetime.now().isoformat(timespec="seconds")


def _handle(qpath):
    name = os.path.basename(qpath)
    try:
        req = json.load(open(qpath, encoding="utf-8"))
    except Exception as e:
        req = {"_parse_error": "%s: %s" % (type(e).__name__, e)}
    service, args = req.get("service"), (req.get("args") or [])
    stamp = datetime.datetime.now().strftime("%H:%M:%S")
    print("[%s] call: service=%r args=%r" % (stamp, service, args))
    receipt = {"queued_file": name, "service": service, "args": args, "received": _now()}

    if service not in SERVICES:
        receipt["status"] = "REFUSED"
        receipt["error"] = "service not in whitelist %s" % sorted(SERVICES)
        print("    REFUSED (not whitelisted)")
    else:
        try:
            argv = SERVICES[service](args)
            receipt["argv"] = argv
            t0 = time.time()
            proc = subprocess.run(argv, capture_output=True, text=True, cwd=_ROOT)
            receipt.update(status=("ok" if proc.returncode == 0 else "nonzero-exit"),
                           exit=proc.returncode, seconds=round(time.time() - t0, 2),
                           stdout=proc.stdout, stderr=proc.stderr)
            print("    ran -> exit %d (%.2fs)" % (proc.returncode, receipt["seconds"]))
        except Exception as e:
            receipt["status"] = "ERROR"
            receipt["error"] = "%s: %s" % (type(e).__name__, e)
            print("    ERROR - %s" % receipt["error"])

    receipt["done"] = _now()
    stem = os.path.splitext(name)[0]
    with open(os.path.join(RECEIPTS, stem + ".json"), "w", encoding="utf-8") as f:
        json.dump(receipt, f, indent=1, ensure_ascii=False)
        f.write("\n")


def _drain_one(qpath):
    """Handle a queue file exactly ONCE, then GUARANTEE it leaves the queue - to processed/
    on success, errored/ if the handler blew up. This is the anti-runaway invariant: a file
    the runner has picked up can NEVER be re-processed on the next poll, whatever happens."""
    name = os.path.basename(qpath)
    dest = PROCESSED
    try:
        _handle(qpath)
    except Exception as e:
        dest = ERRORED
        print("    !! handler error: %s: %s  (quarantined to errored/)" % (type(e).__name__, e))
    finally:
        try:
            os.replace(qpath, os.path.join(dest, name))
        except Exception:
            try:
                os.remove(qpath)               # last resort - it must not survive to loop
            except Exception:
                pass


def main():
    try:                                   # live feed flushes per line even when redirected
        sys.stdout.reconfigure(line_buffering=True)
    except Exception:
        pass
    for d in (QUEUE, RECEIPTS, PROCESSED, ERRORED):
        os.makedirs(d, exist_ok=True)
    print("service-runner live under your runtime - watching:")
    print("  " + QUEUE)
    print("whitelist: %s   (poll ~1s, Ctrl-C to stop)\n" % sorted(SERVICES))
    try:
        while True:
            for q in sorted(glob.glob(os.path.join(QUEUE, "*.json")), key=os.path.getmtime):
                _drain_one(q)
            time.sleep(1.0)
    except KeyboardInterrupt:
        print("\nstopped.")


if __name__ == "__main__":
    main()
