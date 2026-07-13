"""
gate.py - the PRE-FLIGHT WORD-MATCH (engine, AT the line).

Catches correctness BEFORE the docket forms: word-matches every token in a docket against the known-sources, so nothing
invented reaches the pipeline. Below the line everything TRUSTS the docket is WA-literal - this is what makes that safe.
It would have stopped my own `treat`/`facet` cold.

Per token:
  KEY (addressable)  -> a known WA field in the contract           else MALFORM (invented/typo)
  VALUE (content)    -> domain-bound field: value in the domain      (known) else MALFORM (bad enum)
                        ability-ref field (spellIds/spellid1): id in class-data -> KNOWN-ABILITY else USER-INPUT
                        name-ref field (auranames/name1/spellName), or free field -> USER-INPUT
  id / uid           -> IDENTITY (the only human character a docket carries; never word-matched)
Malform STOPS the docket; everything else passes. Verdict is EPHEMERAL (the caller keeps only malform, until fixed).

Known-sources: contract.json (WA vocab + domains), coa_spells.json (ability identity; optional - skip -> user-input).

  gate(docket_dict) -> {"passed": bool, "verdicts": [...], "malform": [...]}
  py gate.py <docket.json>
"""
import json
import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
CONTRACT = os.path.join(_THIS, "..", "wa_index", "contract.json")
CLASSDATA = os.path.join(_THIS, "..", "..", "Outputs", "spell_dbc", "coa_spells.json")

ID_REF_FIELDS = {"spellIds", "spellid1"}                       # values are spell IDs -> checkable vs class-data
NAME_REF_FIELDS = {"auranames", "name1", "spellName"}          # values are names -> user-input (no name index yet)
IDENTITY_KEYS = {"id", "uid"}


def _load(path):
    return json.load(open(path, encoding="utf-8")) if os.path.exists(path) else None


def _as_list(v):
    return v if isinstance(v, list) else [v]


def gate(docket, contract=None, classdata=None):
    contract = contract if contract is not None else _load(CONTRACT)
    v = []
    def mark(path, verdict, note=""):
        v.append({"path": path, "verdict": verdict, "note": note})

    for k in IDENTITY_KEYS:
        if k in docket:
            mark(k, "identity")

    region = docket.get("region", docket.get("regionType"))
    if region is not None:
        ok = region in contract.get("display", {})
        mark("region", "known-field" if ok else "malform", "" if ok else "%r not a known regionType" % region)

    for i, t in enumerate(docket.get("triggers", []) or []):
        tp = "triggers[%d]" % i
        ttype, event = t.get("type"), t.get("event")
        events = contract.get("trigger", {}).get(ttype)
        if events is None:
            mark(tp + ".type", "malform", "%r not a known trigger type" % ttype); continue
        mark(tp + ".type", "known-field")
        surface = events.get(event)
        if surface is None:
            mark(tp + ".event", "malform", "%r not an event of %s" % (event, ttype)); continue
        mark(tp + ".event", "known-field")
        inputs = surface.get("inputs", {})
        for key, val in (t.get("declare") or {}).items():
            fp = "%s.declare.%s" % (tp, key)
            io = inputs.get(key)
            if io is None:
                mark(fp, "malform", "%r not a field of %s/%s" % (key, ttype, event)); continue
            dom = io.get("domain")
            if isinstance(dom, dict):
                bad = [x for x in _as_list(val) if str(x) not in dom and x not in dom]
                mark(fp, "known-field" if not bad else "malform", "" if not bad else "value(s) %s not in domain" % bad)
            elif key in ID_REF_FIELDS and classdata is not None:
                unknown = [x for x in _as_list(val) if str(x) not in classdata]
                mark(fp, "known-ability" if not unknown else "user-input",
                     "" if not unknown else "id(s) %s not in class-data" % unknown)
            else:
                mark(fp, "user-input")

    load = docket.get("load") or {}
    if "class" in load:
        mark("load.class", "user-input", "class token (a class-list known-source is a later layer)")

    return {"passed": not any(x["verdict"] == "malform" for x in v),
            "verdicts": v, "malform": [x for x in v if x["verdict"] == "malform"]}


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: py gate.py <docket.json>")
    docket = json.load(open(sys.argv[1], encoding="utf-8"))
    r = gate(docket, classdata=_load(CLASSDATA))
    for x in r["verdicts"]:
        print("  %-11s %-30s %s" % (x["verdict"], x["path"], x["note"]))
    print("\nGATE: %s" % ("PASS" if r["passed"] else "MALFORM x%d - docket blocked" % len(r["malform"])))


if __name__ == "__main__":
    main()
