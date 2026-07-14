"""
roundtrip_diff.py - the round-trip verifier WITH MEMORY: diff a shipped pack against WA's own re-export,
match every delta against the triaged pattern registry (known_deltas.json), and surface ONLY the novel ones.

The point (Battlewrath, 2026-07-14): pattern-recognize and re-apply, rather than reason every solution. The first
round trip was triaged by hand (client-defaults vs mutations vs artifacts); that triage now lives in the registry.
Every future round trip: recognized deltas collapse to one summary line - anything the registry doesn't know is a
FINDING and gets printed in full. New signatures are appended to the registry ONLY after triage (judgment stays
human/agent; recognition is mechanical).

Alignment: subRegions are diffed TYPE-ALIGNED (our subtext vs their subtext), so the client inserting default
subregions doesn't false-report drops (the first run's positional artifact, fixed here).

  py roundtrip_diff.py <ours.txt> <theirs.txt>
  py roundtrip_diff.py necromancer-death-target <reexport.txt>     (pack name resolves to Docket_complete/)
"""
import json
import os
import re
import sys
from collections import defaultdict

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
sys.path.insert(0, os.path.join(_ROOT, "Weak Auras"))
import weakaura_codec as wc

COMPLETE = os.path.join(_ROOT, "Weak Auras", "engine", "Production", "Docket_complete")
REGISTRY = os.path.join(_THIS, "known_deltas.json")


def _load_string(arg):
    p = arg if os.path.exists(arg) else os.path.join(COMPLETE, arg + ".txt")
    return open(p, encoding="utf-8").read().strip()


def _num_eq(a, b):
    try:
        return float(a) == float(b)
    except (TypeError, ValueError):
        return False


def deep(a, b, path=""):
    """yield (kind, path, ours, theirs); dict-recursive, list-positional EXCEPT subRegions (type-aligned)."""
    if isinstance(a, dict) and isinstance(b, dict):
        for k in sorted(set(a) | set(b), key=str):
            p = "%s.%s" % (path, k) if path else str(k)
            if k not in b:
                yield ("DROPPED", p, a[k], None)
            elif k not in a:
                yield ("ADDED", p, None, b[k])
            else:
                yield from deep(a[k], b[k], p)
    elif isinstance(a, list) and isinstance(b, list):
        if path.endswith("subRegions"):                       # TYPE-ALIGNED: client inserts defaults around ours
            by_type_a, by_type_b = defaultdict(list), defaultdict(list)
            for x in a:
                by_type_a[x.get("type") if isinstance(x, dict) else None].append(x)
            for y in b:
                by_type_b[y.get("type") if isinstance(y, dict) else None].append(y)
            for ty in sorted(set(by_type_a) | set(by_type_b), key=str):
                xs, ys = by_type_a.get(ty, []), by_type_b.get(ty, [])
                for i, (x, y) in enumerate(zip(xs, ys)):
                    yield from deep(x, y, "%s[%s#%d]" % (path, ty, i))
                for x in xs[len(ys):]:
                    yield ("DROPPED", "%s[%s]" % (path, ty), x, None)
                for y in ys[len(xs):]:
                    yield ("ADDED", "%s[%s]" % (path, ty), None, y)
        else:
            if len(a) != len(b):
                yield ("MUTATED", path + ".#len", len(a), len(b))
            for i, (x, y) in enumerate(zip(a, b)):
                yield from deep(x, y, "%s[%d]" % (path, i))
    else:
        if a != b and not _num_eq(a, b):
            yield ("MUTATED", path, a, b)


def _norm_triggers(t):
    """triggers may be a pure list (ours) or a mixed dict (client adds string keys). Split -> (list, extras)."""
    if isinstance(t, list):
        return t, {}
    nums = [t[k] for k in sorted((k for k in t if str(k).isdigit()), key=int)]
    return nums, {str(k): v for k, v in t.items() if not str(k).isdigit()}


def member_deltas(o, t):
    """diff one member; triggers normalized so shape noise doesn't mask content."""
    o, t = dict(o), dict(t)
    on, oe = _norm_triggers(o.pop("triggers", []))
    tn, te = _norm_triggers(t.pop("triggers", []))
    yield from deep(o, t)
    yield from deep(on, tn, "triggers")
    yield from deep(oe, te, "triggers")                       # combination keys (client stamps activeTriggerMode)


def main():
    if len(sys.argv) < 3:
        sys.exit("usage: py roundtrip_diff.py <ours: pack-name|path> <theirs: path>")
    op, ok = wc.decode_group_import_string(_load_string(sys.argv[1]))
    tp, tk = wc.decode_group_import_string(_load_string(sys.argv[2]))
    reg = json.load(open(REGISTRY, encoding="utf-8"))["signatures"]

    def recognize(kind, p, b):
        pn = re.sub(r"\[\d+\]", "[*]", re.sub(r"\[\w+#\d+\]", "[*]", p))
        for s in reg:
            if s["kind"] == kind and re.search(s["path"], pn):
                vt = s.get("value_to")
                if vt and not re.search(vt, json.dumps(b, default=str)):
                    continue
                return s
        return None

    om, tm = {k.get("id"): k for k in ok}, {k.get("id"): k for k in tk}
    print("members  ours %d | theirs %d | missing %s | extra %s"
          % (len(om), len(tm), sorted(set(om) - set(tm)) or "-", sorted(set(tm) - set(om)) or "-"))

    known, novel = defaultdict(int), []
    for mid in sorted(set(om) & set(tm)):
        for kind, p, a, b in member_deltas(om[mid], tm[mid]):
            sig = recognize(kind, p, b)
            if sig:
                known[(sig["verdict"], sig["why"][:58])] += 1
            else:
                novel.append((mid, kind, p, a, b))
    for kind, p, a, b in deep(op, tp, ""):                    # the group parent
        sig = recognize(kind, p, b)
        if sig:
            known[(sig["verdict"], sig["why"][:58])] += 1
        else:
            novel.append(("(group)", kind, p, a, b))

    print("\nRECOGNIZED (the registry absorbed these - no reasoning needed):")
    for (verdict, why), n in sorted(known.items(), key=lambda kv: -kv[1]):
        print("  x%-4d %-15s %s" % (n, verdict, why))
    if novel:
        print("\n*** NOVEL deltas - findings, triage these (then append the verdicts to known_deltas.json): ***")
        for mid, kind, p, a, b in novel:
            print("  %-10s %-8s %-44s %s -> %s" % (mid, kind, p,
                  json.dumps(a, default=str)[:48], json.dumps(b, default=str)[:48]))
        sys.exit(1)
    print("\nROUND TRIP CLEAN - zero novel deltas; everything matched the registry.")


if __name__ == "__main__":
    main()
