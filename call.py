"""
call.py - the CLIENT half of the runner: queue a service call and HOLD OPEN for its receipt.

One command does the whole round-trip: write a queue file into runtime/queue/, then poll
runtime/receipts/ until the receipt lands (or timeout), and print it. The runner (the server,
under Battlewrath's runtime) does the actual execution; this only queues + awaits in the
caller's runtime, so the steering/machinery decoupling is preserved - call.py runs nothing.

  py call.py <service> [args...]
      py call.py verify
      py call.py decode peek export_20260712_065648_02.txt

Exit 0 if the service ran ok; 1 on refuse/nonzero/error; 3 on timeout (no runner listening).
"""
import datetime
import json
import os
import sys
import time

_ROOT = os.path.dirname(os.path.abspath(__file__))
QUEUE = os.path.join(_ROOT, "runtime", "queue")
RECEIPTS = os.path.join(_ROOT, "runtime", "receipts")
HOLD_SECONDS = 30


def main():
    args = sys.argv[1:]
    if not args:
        raise SystemExit("usage: call.py <service> [args...]")
    service, sargs = args[0], args[1:]
    os.makedirs(QUEUE, exist_ok=True)
    os.makedirs(RECEIPTS, exist_ok=True)

    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    stem = "call_%s_%s" % (service, stamp)
    qpath = os.path.join(QUEUE, stem + ".json")
    with open(qpath, "w", encoding="utf-8") as f:
        json.dump({"service": service, "args": sargs}, f)
    print("queued %s.json (service=%s args=%s) - holding for receipt..." % (stem, service, sargs), flush=True)

    rpath = os.path.join(RECEIPTS, stem + ".json")
    deadline = time.time() + HOLD_SECONDS
    while not os.path.exists(rpath) and time.time() < deadline:
        time.sleep(0.25)

    if not os.path.exists(rpath):
        print("TIMEOUT after %ds - no receipt." % HOLD_SECONDS)
        if os.path.exists(qpath):
            print("  queue file still pending -> the runner isn't listening (start runner.bat / py runner.py).")
        return 3

    receipt = json.load(open(rpath, encoding="utf-8"))
    print(json.dumps(receipt, indent=1, ensure_ascii=False))
    return 0 if receipt.get("status") == "ok" else 1


if __name__ == "__main__":
    sys.exit(main())
