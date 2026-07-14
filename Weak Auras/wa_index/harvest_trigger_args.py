"""
harvest_trigger_args.py - the prototype-arg ATTRIBUTES map (required / multiEntry / enable / init / type per arg).

The coverage packet exposed the debt: prototype-trigger declares pass the gate on vocabulary alone - whether an arg is
required (participates without use_), multiEntry (arrays), enable-gated, or init="arg" (an event payload, not config)
was never surfaced. The extraction ALREADY dumps it (extract.lua `prototypes` = the raw event_prototypes/load_prototype
tables); build_index's flattener just dropped the attributes. This keeps them.

Emits -> engine/Fact_basis/maps/trigger_args.json : per trigger prototype, arg -> attributes. Function-valued fields
(enable=function, test=...) arrive however extract serializes them - carried verbatim, marked, never guessed.

  py harvest_trigger_args.py
"""
import json
import os
import subprocess
import time

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA_DIR = os.path.dirname(_THIS)
LUA = os.path.normpath(os.path.join(_THIS, "..", "..", ".tools", "lua51", "lua5.1.exe"))
EXTRACT = os.path.join(_THIS, "extract.lua")
PROTOTYPES = "F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAuras/Prototypes.lua"
OUT = os.path.join(_WA_DIR, "engine", "Fact_basis", "maps", "trigger_args.json")

KEEP = ("name", "type", "required", "multiEntry", "init", "enable", "conditionType", "showExactOption",
        "canBeCaseInsensitive", "optional", "orConjunctionGroup", "hidden", "test", "display")


def main():
    proc = subprocess.run([LUA, EXTRACT, "prototypes", PROTOTYPES], capture_output=True, text=True)
    if proc.returncode != 0:
        raise SystemExit("extract failed: " + proc.stderr[:400])
    raw = json.loads(proc.stdout)

    def args_of(proto):
        out = []
        for a in (proto or {}).get("args", []) or []:
            if not isinstance(a, dict) or not a.get("name"):
                continue
            rec = {k: a[k] for k in KEEP if k in a and a[k] is not None}
            out.append(rec)
        return out

    table = {"_meta": {"what": "prototype-arg attributes per trigger (and load): required = participates without "
                               "use_<name>; multiEntry = value/operator are ARRAYS; init='arg' = event payload; "
                               "enable = gated by another field (functions carried verbatim). From the RAW "
                               "event_prototypes dump - the attributes build_index's flattener dropped.",
                       "source": PROTOTYPES, "harvested": time.strftime("%Y-%m-%d")},
             "load": args_of(raw.get("load")),
             "triggers": {tname: args_of(tdef) for tname, tdef in (raw.get("triggers") or {}).items()}}
    json.dump(table, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    trig = table["triggers"]
    n = sum(len(v) for v in trig.values())
    print("trigger prototypes: %d | args kept: %d (+%d load args) -> %s"
          % (len(trig), n, len(table["load"]), os.path.relpath(OUT, _WA_DIR)))
    cd = {a["name"]: a for a in trig.get("Cooldown Progress (Spell)", [])}
    sn = cd.get("spellName", {})
    print("spot - Cooldown Progress (Spell).spellName:", json.dumps(sn, ensure_ascii=False)[:220])


if __name__ == "__main__":
    main()
