"""
expand.py - the EXPANDER (plane_v2 THE_SPLIT layer 3). Reasoning-only docket -> the full-declare docket
(fill's input), by DERIVING the content the contract IMPLIES but that was never CHOSEN. The output is exactly
what fill takes today, so fill/bounce/codec are unchanged.

Contract-DRIVEN, never a hand ruleset (the shaping rules are sourced into wa_index/contract.json). An
ELABORATION/DEFAULTING pass (cf. compiler desugaring, schema defaulting, k8s mutating-admission):
IDEMPOTENT - fills MISSING derivable fields, never clobbers one that's provided.

The transforms:
  - type       <- event   (contract reverse-index; event->type is unique, verified)
  - use_<var>  <- a filter on <var> is present   (enable-from-presence)
  - multiEntry -> operator + value wrapped as ARRAYS, value string-coerced   (the sheet's multiEntry rule)
  - combination -> activation.disjunctive
  - uid        <- present: use it; blank/absent: mint   (inventory provides stable ones; blank = one-off)

  expand(reasoning_docket) -> fill-ready docket
  py expand.py <reasoning.json>   -> the fill-ready docket on stdout
"""
import json
import os
import sys
import uuid

_THIS = os.path.dirname(os.path.abspath(__file__))
CONTRACT = os.path.join(_THIS, "..", "wa_index", "contract.json")


def _contract():
    return json.load(open(CONTRACT, encoding="utf-8"))


def _event_to_type(contract):
    """reverse-index event name -> trigger type (unique across types, verified)."""
    out = {}
    for tname, events in contract.get("trigger", {}).items():
        for ev in events:
            out[ev] = tname
    return out


def _mint_uid():
    return "coa" + uuid.uuid4().hex[:13]


def expand(doc):
    contract = _contract()
    ev2type = _event_to_type(contract)

    out = {}
    if doc.get("id"):
        out["id"] = doc["id"]
    out["uid"] = doc["uid"] if doc.get("uid") else _mint_uid()   # present -> use; blank -> mint
    out["region"] = doc["region"]

    triggers = []
    for t in doc.get("triggers", []):
        event = t["event"]
        ttype = t.get("type") or ev2type.get(event)              # derive type from event (keep if provided)
        if not ttype:
            sys.exit("expand: no trigger type for event %r (contract gap?)" % event)
        tinputs = contract["trigger"][ttype][event]["inputs"]

        declare = {}
        if "unit" in t:
            declare["unit"] = t["unit"]
        for var, spec in (t.get("filter") or {}).items():        # existence-surface filters
            declare["use_" + var] = True                         # enable-from-presence
            op, value = spec["op"], spec["value"]
            io = tinputs.get(var, {})
            if io.get("multiEntry"):                             # multiEntry -> arrays + string-coerce
                declare[var + "_operator"] = [op]
                declare[var] = [str(value)]
            else:                                                # non-multiEntry: TBD (flag when a case hits it)
                sys.exit("expand: %r is not multiEntry - non-multiEntry filter shape not yet derived (wall->expand)" % var)
        triggers.append({"type": ttype, "event": event, "declare": declare})
    out["triggers"] = triggers

    if doc.get("combination"):
        out["activation"] = {"disjunctive": doc["combination"]}
    return out


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: py expand.py <reasoning.json>")
    doc = json.load(open(sys.argv[1], encoding="utf-8"))
    json.dump(expand(doc), sys.stdout, ensure_ascii=False, indent=1)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
