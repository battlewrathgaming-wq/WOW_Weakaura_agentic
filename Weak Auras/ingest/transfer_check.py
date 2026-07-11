"""
transfer_check.py - grade each ingested pack for TRANSFERABILITY against our own
WA's capability (wa_index/index.json). Answers: which of a pack's building blocks
are reproducible on our WotLK 3.3.5a / WA 5.21.2 server, and which are foreign
(retail-only trigger types, unknown state vars, unknown change properties, etc.).

The point (esp. for retail packs): learn the expert GRAMMAR (structure) that uses
only levers WE have; flag the CONTENT/features we can't reproduce so they never
leak into what we generate. Structure is transferable; foreign features are not.

    py transfer_check.py            # grade every pack in reference/
    py transfer_check.py <name>     # one pack (verbose foreign list)
"""
import json
import os
import sys
from collections import Counter

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)
IDX = os.path.join(_WA, "wa_index", "index.json")
REF = os.path.join(_THIS, "reference")

_UNIVERSAL_TRIGGER_TYPES = {"aura2", "custom"}   # not event-prototype keyed, but ours has them
_LOGICAL = {"AND", "OR"}
_EXTRA_CHANGE = {"customcode", "glowexternal", "chat", "sound", "alpha"}


def _index_sets():
    idx = json.load(open(IDX, encoding="utf-8"))
    return {
        "regions": {r["namespace"] for r in idx if r["section"] == "region"},
        "triggers": {r["namespace"] for r in idx if r["section"] == "trigger"},
        "change": {r["name"] for r in idx if r.get("role") == "change"} | _EXTRA_CHANGE,
        # valid check variables = anything CHECKABLE in conditions (conditionType
        # present) or a pure state var, plus the universal trigger states every
        # trigger exposes implicitly (show/changed), plus the AND/OR logical nodes.
        # + aura2/Cast/unit state vars WA exposes but our event_prototypes index
        #   doesn't cover (BuffTrigger2 etc.) - known index-coverage gap, not foreign.
        "state": ({r["name"] for r in idx if r.get("checkable") or r.get("input_kind") == "state"}
                  | {"show", "changed", "stacks", "duration", "expirationTime",
                     "buffed", "unitCount", "initialTime", "matchCount", "matched", "name", "unit"}
                  | _LOGICAL),
    }


def _walk_checks(chk, out):
    """collect check variables from a (possibly recursive AND/OR) check tree."""
    if not isinstance(chk, dict):
        return
    if "variable" in chk:
        out.append(chk["variable"])
    for sub in chk.get("checks", []) or []:
        _walk_checks(sub, out)


def grade(rec, S):
    nodes = [rec["root"]] + rec.get("children", [])
    foreign = {"regionType": Counter(), "trigger": Counter(),
               "checkVar": Counter(), "changeProp": Counter()}
    seen = {"regionType": set(), "trigger": set(), "checkVar": set(), "changeProp": set()}
    for n in nodes:
        if not isinstance(n, dict):
            continue
        rt = n.get("regionType")
        if rt:
            seen["regionType"].add(rt)
            if rt not in S["regions"]:
                foreign["regionType"][rt] += 1
        # triggers (dict or list shaped)
        trg = n.get("triggers")
        tlist = (list(trg.values()) if isinstance(trg, dict) else trg) or []
        for t in tlist:
            tr = t.get("trigger") if isinstance(t, dict) else None
            if not isinstance(tr, dict):
                continue
            ev, ty = tr.get("event"), tr.get("type")
            key = ev or ty
            if key:
                seen["trigger"].add(key)
                known = (ev in S["triggers"]) or (ty in _UNIVERSAL_TRIGGER_TYPES) or (ev is None and ty in S["triggers"])
                if not known:
                    foreign["trigger"][key] += 1
        # conditions
        for c in (n.get("conditions") or []):
            if not isinstance(c, dict):
                continue
            cv = []
            _walk_checks(c.get("check", {}), cv)
            for v in cv:
                seen["checkVar"].add(v)
                if v not in S["state"]:
                    foreign["checkVar"][v] += 1
            for ch in (c.get("changes") or []):
                if not isinstance(ch, dict):
                    continue
                p = ch.get("property") or ""
                base = p.split(".")[-1] if p.startswith("sub.") else p
                if base:
                    seen["changeProp"].add(base)
                    if base not in S["change"]:
                        foreign["changeProp"][base] += 1
    return seen, foreign


def main():
    S = _index_sets()
    one = sys.argv[1] if len(sys.argv) > 1 else None
    files = sorted(f for f in os.listdir(REF) if f.endswith(".json"))
    print(f"{'pack':32} {'origin':9} {'iv':7} transferable?  foreign blocks")
    print("-" * 96)
    for f in files:
        if one and one not in f:
            continue
        rec = json.load(open(os.path.join(REF, f), encoding="utf-8"))
        p = rec.get("provenance", {})
        origin = p.get("origin", "ascension" if not f.lower().startswith("retail_") else "retail")
        seen, foreign = grade(rec, S)
        nf = sum(sum(c.values()) for c in foreign.values())
        distinct = {k: sorted(v) for k, v in foreign.items() if v}
        verdict = "CLEAN" if nf == 0 else f"{len(sum(distinct.values(), []))} foreign type(s)"
        print(f"{f[:-5][:32]:32} {origin:9} {str(p.get('internalVersion')):7} {verdict:14} "
              f"{ {k: list(v) for k, v in distinct.items()} if distinct else '' }")
        if one and distinct:
            for cat, items in distinct.items():
                print(f"    foreign {cat}: {items}")


if __name__ == "__main__":
    main()
