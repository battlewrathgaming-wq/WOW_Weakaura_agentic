"""
emit_load_sheet.py - the LOAD domain state sheet (sibling to the trigger/display emitters). The load_prototype's
conditions (class / spec / talent / level / zone / equipment / ...), each gated by a use_X toggle, ALL AND-ed
together - the "chain": every ENABLED condition must be true for the aura to load. Sourced from extract.lua
prototypes (result.load) joined onto the grounded index (value-domains, input_kind).

  py emit_load_sheet.py   -> statesheets/load/load.json
"""
import json
import os
import subprocess
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
LUA = os.path.join(_ROOT, ".tools", "lua51", "lua5.1.exe")
EXTRACT = os.path.join(_THIS, "extract.lua")
PROTOS = "F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAuras/Prototypes.lua"
INDEX = os.path.join(_THIS, "index_grounded.json")
OUTDIR = os.path.join(_THIS, "statesheets", "load")


def _load_prototype():
    proc = subprocess.run([LUA, EXTRACT, "prototypes", PROTOS], capture_output=True, text=True)
    if proc.returncode != 0:
        sys.exit("extract.lua prototypes failed: " + proc.stderr[:400])
    return json.loads(proc.stdout).get("load") or {}


def _index_load():
    """section == 'load' records from the grounded index -> by option name (value-domains, input_kind, default)."""
    by = {}
    for r in json.load(open(INDEX, encoding="utf-8")):
        if isinstance(r, dict) and r.get("section") == "load" and r.get("name"):
            by[r["name"]] = r
    return by


def build():
    proto = _load_prototype()
    by = _index_load()
    conditions = []
    for a in proto.get("args", []):
        if not isinstance(a, dict):
            continue
        name = a.get("name")
        if not name or a.get("type") == "description":     # skip section-title rows
            continue
        ix = by.get(name, {})
        conditions.append({
            "name": name,
            "use_toggle": "use_" + name,
            "type": a.get("type"),
            "input_kind": ix.get("input_kind"),
            "value_domain": ix.get("values"),
            "value_domain_source": ix.get("values_source"),
            "default": a.get("default") if not (isinstance(a.get("default"), str) and a["default"].startswith("<func"))
                       else "(dynamic)",
        })
    return {
        "domain": "load",
        "chain": "AND - every ENABLED condition (use_X true) must be true for the aura to load; unset conditions "
                 "impose no constraint. This is the load chain the docket declares into.",
        "condition_count": len(conditions),
        "conditions": conditions,
        "_meta": {"source": "extract.lua prototypes -> load_prototype args, grounded via index_grounded.json "
                            "(section=load). Same arg structure as triggers; each condition has a use_X toggle."},
    }


def main():
    sheet = build()
    os.makedirs(OUTDIR, exist_ok=True)
    with open(os.path.join(OUTDIR, "load.json"), "w", encoding="utf-8") as f:
        json.dump(sheet, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print("load domain -> %s  (%d conditions, AND-ed)"
          % (os.path.relpath(os.path.join(OUTDIR, "load.json"), _ROOT), sheet["condition_count"]))


if __name__ == "__main__":
    main()
