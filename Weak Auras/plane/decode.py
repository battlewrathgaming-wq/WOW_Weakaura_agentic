"""
decode.py - decode captured WA exports (ingest/inbox) into a legible, SETTLED view.

Replaces ad-hoc inline decode snippets - which vary run to run and leave room for
error - with ONE deterministic tool: same drop, same view, every time. It reuses the
SAME settle engine as the pipeline (diagnose.settle_trigger), so what prints is the
TRUE levers (cross-type residue / touched-off / companions / stored-defaults stripped),
not the raw stored noise.

  py decode.py [peek] [name]   # newest inbox drop (or <name>), SETTLED per trigger
  py decode.py diff            # RAW field delta between the two newest drops
                               #   (per-option write - the toggle-sweep workhorse)
  py decode.py raw [name]      # full RAW decoded trigger(s), nothing stripped

Reads whatever paste_drop.py dropped into ingest/inbox/.
"""
import glob
import json
import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))   # plane/
_WA = os.path.dirname(_THIS)                          # Weak Auras/
for _p in (_WA, _THIS):
    if _p not in sys.path:
        sys.path.insert(0, _p)
import weakaura_codec as wc
import index_schema as ix
import diagnose as dg

INBOX = os.path.join(_WA, "ingest", "inbox")


def _drops():
    return sorted(glob.glob(os.path.join(INBOX, "*.txt")), key=os.path.getmtime)


def _pick(name):
    if name:
        p = os.path.join(INBOX, name if name.endswith(".txt") else name + ".txt")
        if not os.path.exists(p):
            raise SystemExit("no such drop: " + name)
        return p
    ds = _drops()
    if not ds:
        raise SystemExit("inbox empty - drop a WA export via paste_drop first")
    return ds[-1]


def _root(path):
    return wc.decode_import_string_raw(open(path, encoding="utf-8").read().strip())["d"]


def _triggers(root):
    trg = root.get("triggers", {})
    tl = list(trg.values()) if isinstance(trg, dict) else (trg or [])
    return [t["trigger"] for t in tl if isinstance(t, dict) and isinstance(t.get("trigger"), dict)]


def cmd_peek(name=None):
    path = _pick(name)
    root = _root(path)
    print("drop  :", os.path.basename(path))
    print("region:", root.get("regionType"))
    idx = ix.load_index()
    a2, a2c, a2d = dg._aura2_allow(), dg._aura2_companions(), dg._aura2_defaults()
    for i, tr in enumerate(_triggers(root), 1):
        ns, _mode, active, off, xtype, defaulted = dg.settle_trigger(tr, idx, a2, a2c, a2d)
        levers = {k: v for k, v in (active or {}).items() if k not in ("type", "event")}
        print("\n--- trigger %d : %s ---" % (i, ns))
        print("  TRUE levers    :", json.dumps(levers, sort_keys=True) if levers else "(none - bare/default)")
        if defaulted:
            print("  folded default :", sorted(defaulted))
        if off:
            print("  touched-off    :", sorted(off))
        if xtype:
            print("  cross-type res :", sorted(xtype))


def cmd_raw(name=None):
    path = _pick(name)
    root = _root(path)
    print("drop  :", os.path.basename(path), " region:", root.get("regionType"))
    for i, tr in enumerate(_triggers(root), 1):
        print("\n--- trigger %d (raw) ---" % i)
        print(json.dumps(tr, indent=1, sort_keys=True))


def cmd_diff():
    ds = _drops()
    if len(ds) < 2:
        raise SystemExit("need two drops to diff (have %d)" % len(ds))
    old_t, new_t = _triggers(_root(ds[-2])), _triggers(_root(ds[-1]))
    print("diff  : %s  ->  %s" % (os.path.basename(ds[-2]), os.path.basename(ds[-1])))
    for i in range(max(len(old_t), len(new_t))):
        a = old_t[i] if i < len(old_t) else {}
        b = new_t[i] if i < len(new_t) else {}
        deltas = [(k, a.get(k, "<absent>"), b.get(k, "<absent>"))
                  for k in sorted(set(a) | set(b)) if a.get(k) != b.get(k)]
        print("\n--- trigger %d ---" % (i + 1))
        if not deltas:
            print("  (identical)")
        for k, av, bv in deltas:
            print("  %-22s %s  ->  %s" % (k, av, bv))


def main():
    args = sys.argv[1:]
    mode = args[0] if args else "peek"
    rest = args[1] if len(args) > 1 else None
    if mode == "peek":
        cmd_peek(rest)
    elif mode == "diff":
        cmd_diff()
    elif mode == "raw":
        cmd_raw(rest)
    else:
        cmd_peek(mode)   # a bare filename => peek that file


if __name__ == "__main__":
    main()
