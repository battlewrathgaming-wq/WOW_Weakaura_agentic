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


def _couple_selfpoint(doc, contract):
    """selfPoint is coupled to grow(+align)/gridType by WA's options set logic; the region reads data.selfPoint
    DIRECTLY and never re-derives it. So when a dynamicgroup docket authors a grow/gridType (and hasn't pinned
    selfPoint itself), inject the paired value from the contract's GENERATED coupling table - any grow ships correct.
    Returns the selfPoint, or None if not applicable. Respects an explicitly-authored selfPoint (idempotent)."""
    if doc.get("region") != "dynamicgroup" or doc.get("selfPoint") is not None:
        return None
    cpl = (contract.get("display", {}).get("dynamicgroup", {}) or {}).get("coupling")
    if not cpl:
        return None
    grow = doc.get("grow")
    if grow == "GRID":
        return (cpl.get("by_gridtype") or {}).get(doc.get("gridType"))
    if grow:
        align = doc.get("align") or "CENTER"                     # unset/CENTER = the set function's else-branch
        return ((cpl.get("by_grow_align") or {}).get(grow) or {}).get(align)
    return None


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

    region = doc.get("region")
    if region in ("dynamicgroup", "group"):                      # group arrangement -> the display bucket (fill copies it to top-level)
        surface = (contract.get("display", {}).get(region, {}) or {}).get("option_surface", {})
        display = dict(out.get("display") or {})
        for lever in surface:
            if lever in doc:
                display[lever] = doc[lever]                      # authored arrangement rides through (validated lever)
        sp = _couple_selfpoint(doc, contract)                    # dynamicgroup-only inside; couples grow(+align)/gridType -> selfPoint
        if sp is not None:
            display["selfPoint"] = sp                            # derived pairing (grow authored, selfPoint not pinned)
        elif doc.get("selfPoint") is not None:
            display["selfPoint"] = doc["selfPoint"]              # explicit selfPoint respected
        if display:
            out["display"] = display
    return out


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: py expand.py <reasoning.json>")
    doc = json.load(open(sys.argv[1], encoding="utf-8"))
    json.dump(expand(doc), sys.stdout, ensure_ascii=False, indent=1)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
