"""
emit_tracker_types.py - the TRACKER TYPE registry (statesheets/tracker/types.json).

Resolves the class Battlewrath named: a tracker's PARAM SHAPE is set by the native SIGNAL it reads.
Cooldown-signal trackers are spell-driven (drive-from-ID); aura-signal trackers (buff/stack/dot/hot) read a
buff-window and need aura RESOLUTION (which aura / unit / polarity) plus a FACET (presence/stacks/duration).

Each archetype is OUR design (which type exists, its defaults), but every PARAM is a real trigger field
VALIDATED against the contract's trigger surface - sourced where the source dictates, GAP-flagged where it does
not (e.g. stack DELTA is not a native aura2 field; it is a composition). Same standard as the trigger/display
sheets: a PROJECTION over contract.json, no new extraction.

  py emit_tracker_types.py   -> statesheets/tracker/types.json  (+ prints the gap check)
"""
import json
import os

_THIS = os.path.dirname(os.path.abspath(__file__))
CONTRACT = os.path.join(_THIS, "contract.json")
OUTDIR = os.path.join(_THIS, "statesheets", "tracker")

# OUR archetype design. params map a docket ROLE -> the WA trigger FIELD it fills; facet = what is shown.
# signal = the native reader (cooldown vs aura/buff-window) - THE axis that sets the param shape.
ARCHETYPES = {
    "cooldown":    {"signal": "cooldown", "trigger": ["spell", "Cooldown Progress (Spell)"], "region": "icon",
                    "params": {"ability": "spellName"}, "defaults": {}, "facet": "cooldown"},
    "buff":        {"signal": "aura", "trigger": ["aura2", "Aura"], "region": "icon",
                    "params": {"aura": "spellid1", "unit": "unit", "polarity": "debuffType", "own": "ownOnly"},
                    "defaults": {"polarity": "HELPFUL", "unit": "player"}, "facet": "presence"},
    "stack":       {"signal": "aura", "trigger": ["aura2", "Aura"], "region": "text",
                    "params": {"aura": "spellid1", "unit": "unit", "polarity": "debuffType", "own": "ownOnly"},
                    "defaults": {"unit": "player"}, "facet": "stacks"},
    "stack_delta": {"signal": "aura", "trigger": ["aura2", "Aura"], "region": "text",
                    "params": {"aura": "spellid1", "unit": "unit", "polarity": "debuffType", "own": "ownOnly"},
                    "defaults": {"unit": "player"}, "facet": "delta"},
    "dot":         {"signal": "aura", "trigger": ["aura2", "Aura"], "region": "aurabar",
                    "params": {"aura": "spellid1", "unit": "unit", "polarity": "debuffType", "own": "ownOnly"},
                    "defaults": {"polarity": "HARMFUL", "unit": "target"}, "facet": "duration"},
    "hot":         {"signal": "aura", "trigger": ["aura2", "Aura"], "region": "aurabar",
                    "params": {"aura": "spellid1", "unit": "unit", "polarity": "debuffType", "own": "ownOnly"},
                    "defaults": {"polarity": "HELPFUL", "unit": "target"}, "facet": "duration"},
}

# facet -> the sourced field/handling it reads. (None, None) = a COMPOSITION gap: no native field carries it.
FACET_SOURCE = {
    "cooldown": ("handling", "progressType"),   # the trigger's own timed progress
    "presence": ("input", "matchesShowOn"),      # show-on-match
    "stacks":   ("input", "stacks"),             # aura2 current stack count
    "duration": ("input", "rem"),                # aura2 remaining time
    "delta":    (None, None),                     # GAP: stack CHANGE is not a native field - a composition
}


def build():
    c = json.load(open(CONTRACT, encoding="utf-8"))
    types, gaps = {}, []
    for name, a in ARCHETYPES.items():
        ttype, event = a["trigger"]
        surface = c["trigger"].get(ttype, {}).get(event, {})
        inputs = surface.get("inputs", {})
        handling = surface.get("handling", {})
        params = {}
        for role, field in a["params"].items():
            sourced = field in inputs
            if not sourced:
                gaps.append("%s.%s: field %r absent from %s/%s surface" % (name, role, field, ttype, event))
            params[role] = {"field": field, "sourced": sourced}
        fkind, fkey = FACET_SOURCE.get(a["facet"], (None, None))
        facet_sourced = (fkind == "handling" and fkey in handling) or (fkind == "input" and fkey in inputs)
        if not facet_sourced:
            why = "no native field (composition)" if fkind is None else "%s.%s absent" % (fkind, fkey)
            gaps.append("%s: facet %r NOT sourced - %s" % (name, a["facet"], why))
        types[name] = {"signal": a["signal"], "trigger": {"type": ttype, "event": event}, "region": a["region"],
                       "params": params, "defaults": a.get("defaults", {}),
                       "facet": {"name": a["facet"], "reads": {"kind": fkind, "key": fkey}, "sourced": facet_sourced}}
    return {"domain": "tracker", "type_count": len(types), "types": types,
            "_meta": {"source": "projection over contract.json trigger surfaces. archetypes are DESIGN; every param is "
                                "VALIDATED against the trigger field (sourced) or gap-flagged. signal = native reader "
                                "(cooldown = spell-driven / drive-from-ID; aura = buff-window, needs aura resolution).",
                      "gaps": gaps}}


def main():
    os.makedirs(OUTDIR, exist_ok=True)
    sheet = build()
    with open(os.path.join(OUTDIR, "types.json"), "w", encoding="utf-8") as f:
        json.dump(sheet, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print("tracker types -> statesheets/tracker/types.json (%d types)" % sheet["type_count"])
    print("GAP CHECK (source dictates; where it does not, flagged):")
    for g in sheet["_meta"]["gaps"]:
        print("  -", g)
    if not sheet["_meta"]["gaps"]:
        print("  (none)")


if __name__ == "__main__":
    main()
