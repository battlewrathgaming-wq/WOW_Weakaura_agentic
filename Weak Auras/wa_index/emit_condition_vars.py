"""
emit_condition_vars.py - surface the CONDITIONS-VARIABLE map from data already harvested.

The coverage packet exposed that condition `check.variable` names were best-effort guesses. The facts already exist:
- prototype triggers: index_grounded rows carry `conditionType` (226 of them) = the vars a condition may check,
  keyed by trigger namespace. Harvested from Prototypes.lua; never surfaced to authoring.
- aura2 (function-driven): the sheet's `provides` block (BuffTrigger2 UpdateMatchData auto-state).

Emits -> engine/Fact_basis/maps/condition_vars.json : per trigger surface, variable -> conditionType.
Authoring reads it (the palette/conditions.md points here); a later gate tier can check `check.variable` against it.

  py emit_condition_vars.py
"""
import json
import os
import time

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)
INDEX = os.path.join(_THIS, "index_grounded.json")
AURA2 = os.path.join(_WA, "engine", "Fact_basis", "sheets", "trigger", "aura2.json")
OUT = os.path.join(_WA, "engine", "Fact_basis", "maps", "condition_vars.json")


def main():
    g = json.load(open(INDEX, encoding="utf-8"))
    out = {}
    for r in g:
        if r.get("section") == "trigger" and r.get("conditionType"):
            ns = r.get("namespace") or "?"
            out.setdefault(ns, {})[r["name"]] = {"conditionType": r["conditionType"],
                                                 "display": r.get("display"), "source": r.get("source")}
    a2 = json.load(open(AURA2, encoding="utf-8"))
    prov = {}
    for ev in a2.get("events", []):
        for p in ev.get("options", {}).get("provides", []):
            prov[p["name"]] = {"conditionType": "provides", "source": "BuffTrigger2 UpdateMatchData (sheet provides)"}
    out["aura2/Aura"] = prov

    table = {"_meta": {"what": "condition check.variable surface per trigger namespace. Prototype rows = args with "
                               "conditionType (index_grounded, from Prototypes.lua); aura2 = the sheet's provides "
                               "(function-driven trigger - names are the auto-state fields).",
                       "emitted": time.strftime("%Y-%m-%d"),
                       "caveat": "aura2 condition-var NAMES via GetTriggerConditions may refine the provides list - "
                                 "live grading of the coverage packet's condition members is the check."},
             "surfaces": out}
    json.dump(table, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    n = sum(len(v) for v in out.values())
    print("condition-vars: %d surfaces, %d variables -> %s" % (len(out), n, os.path.relpath(OUT, _WA)))
    cd = out.get("Cooldown Progress (Spell)", {})
    print("Cooldown Progress (Spell) vars:", ", ".join(sorted(cd)) or "(none)")
    print("aura2 provides:", ", ".join(sorted(prov)))


if __name__ == "__main__":
    main()
