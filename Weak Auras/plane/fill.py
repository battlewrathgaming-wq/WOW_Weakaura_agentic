"""
fill.py - the DUMB filler. Reads a docket (the mechanical structured spec - NO reasoning; that lives in the
class inventory, the one reasoning element) and emits the aura-table DELTA: region + triggers + load + the
positively-declared fields. WA's own acceptor (canon) completes the skeleton from data_stub + region default;
the corpus is not in this path. No R1-R7 yet - the dumbest thing that produces the docket's aura, byte-verified
by the round-trip; checks grow from real failures, not imagined ones (refuse spec-first armor).

  fill(docket_dict) -> aura table (dict)
  py fill.py <docket.json>            -> aura table JSON on stdout

The docket declares INTENT-BEARING fields positively (even when they equal WA's default - e.g. cooldownEdge);
the pure data_stub skeleton is left to WA. internalVersion is SOURCED (a fresh aura declares the current one).
"""
import json
import os
import re
import sys

_WEAKAURAS_LUA = "F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAuras/WeakAuras.lua"


def _internal_version():
    """current internalVersion, SOURCED from WeakAuras.lua:4 (never hardcoded) so it can't drift."""
    txt = open(_WEAKAURAS_LUA, encoding="utf-8", errors="replace").read()
    m = re.search(r"local internalVersion\s*=\s*(\d+)", txt)
    if not m:
        sys.exit("fill: could not source internalVersion from WeakAuras.lua")
    return int(m.group(1))


def fill(docket):
    aura = {
        "id": docket["id"],
        "uid": docket["uid"],
        "internalVersion": _internal_version(),          # positive-declared, sourced
        "regionType": docket["region"],
    }
    triggers = {}
    for i, t in enumerate(docket.get("triggers", []), 1):
        trig = {"type": t["type"], "event": t["event"]}
        trig.update(t.get("declare", {}))                # the declared trigger fields
        triggers[i] = {"trigger": trig, "untrigger": {}}
    aura["triggers"] = triggers
    load = docket.get("load") or {}
    if "class" in load:
        aura["load"] = {"class": {"single": load["class"]}}
    for field, value in (docket.get("display") or {}).items():   # positive display declarations (top-level)
        aura[field] = value
    conditions = docket.get("conditions") or []                  # check (trigger var) -> changes (display prop)
    if conditions:
        aura["conditions"] = [
            {"check": c["check"],
             "changes": [{"property": p, "value": v} for p, v in c["changes"].items()]}
            for c in conditions
        ]
    return aura


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: py fill.py <docket.json>")
    docket = json.load(open(sys.argv[1], encoding="utf-8"))
    json.dump(fill(docket), sys.stdout, ensure_ascii=False, indent=1)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
