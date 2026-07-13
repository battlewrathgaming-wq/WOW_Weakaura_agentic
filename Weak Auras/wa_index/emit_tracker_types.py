"""
emit_tracker_types.py - the MECHANICAL treatment vocabulary (statesheets/tracker/treatments.json).

REFLECTS THE GAME: which native trigger each tracker treatment IS + the config SLOTS it needs. It NEVER holds our
custom functions. A custom tracker (e.g. Life Force's stack-delta flash) is the native `custom` trigger - already
reflected in the contract (slots custom_type / events / duration / ...) - filled with a PAYLOAD the DESIGNER
provides; the pipeline only SAFELY WRAPS that payload toward export. The sheet holds SLOTS + what we config, never
the Lua.

A docket carries mechanical STEPS, not meaning: "I am this, treat me" - treatment, region, class, + the sourced
fields. The pipeline PICK-AND-PLACES; it never interprets. Semantic archetypes (DoT/HoT/buff) and specific payloads
(the delta stateupdate) are UPSTREAM authoring samples the pipeline can't depend on. Only name/id is user-facing
character. A field belongs here IFF WA requires it (sourced against the trigger surface).

  py emit_tracker_types.py   -> statesheets/tracker/treatments.json  (+ prints the gap check)
"""
import json
import os

_THIS = os.path.dirname(os.path.abspath(__file__))
CONTRACT = os.path.join(_THIS, "contract.json")
OUTDIR = os.path.join(_THIS, "statesheets", "tracker")

# treatment -> the real WA trigger + docket-role -> WA-field aliases + facets (each reads a native trigger field).
# No archetype defaults, no custom Lua - just which trigger this treatment IS and the slots a tracker fills.
TREATMENTS = {
    "cooldown": {"trigger": ["spell", "Cooldown Progress (Spell)"],
                 "fields": {"ability": "spellName"},
                 "facets": {"cooldown": ["handling", "progressType"]}},
    "aura":     {"trigger": ["aura2", "Aura"],
                 "fields": {"aura": "spellid1", "unit": "unit", "polarity": "debuffType", "own": "ownOnly"},
                 "facets": {"presence": ["input", "matchesShowOn"], "stacks": ["input", "stacks"],
                            "duration": ["input", "rem"]}},
    # the native escape hatch: the sheet reflects the SLOTS only. the designer supplies the Lua PAYLOAD (e.g. the
    # delta stateupdate - live-confirmed export 04) and the pipeline safely WRAPS it toward export. never our function.
    "custom":   {"trigger": ["custom", "Custom"], "payload": True,
                 "fields": {"mode": "custom_type", "events": "events", "duration": "duration"},
                 "facets": {}},
}


def build():
    c = json.load(open(CONTRACT, encoding="utf-8"))
    out, gaps = {}, []
    for name, t in TREATMENTS.items():
        ttype, event = t["trigger"]
        surf = c["trigger"].get(ttype, {}).get(event, {})
        inputs, handling = surf.get("inputs", {}), surf.get("handling", {})
        fields = {}
        for role, field in t["fields"].items():
            sourced = field in inputs
            if not sourced:
                gaps.append("%s.%s: field %r absent from %s/%s surface" % (name, role, field, ttype, event))
            fields[role] = {"field": field, "sourced": sourced}
        facets = {}
        for fname, kk in t.get("facets", {}).items():
            kind, key = kk
            ok = (kind == "handling" and key in handling) or (kind == "input" and key in inputs)
            if not ok:
                gaps.append("%s facet %r: %s.%s absent - TRUE GAP" % (name, fname, kind, key))
            facets[fname] = {"reads": {"kind": kind, "key": key}, "sourced": ok}
        rec = {"trigger": {"type": ttype, "event": event}, "fields": fields, "facets": facets}
        if t.get("payload"):
            rec["payload"] = True                                # designer supplies Lua; pipeline safely wraps it
        out[name] = rec
    return {"domain": "tracker", "treatment_count": len(out), "treatments": out,
            "_meta": {"principle": "reflects THE GAME (config slots), never our custom functions. a docket = mechanical "
                                   "steps not meaning. archetypes (DoT) + payloads (delta) are UPSTREAM samples; the "
                                   "pipeline pick-and-places, never interprets. custom = native trigger, slots reflected, "
                                   "PAYLOAD supplied by the designer + safely wrapped. only name/id is user character.",
                      "source": "projection over contract.json trigger surfaces; fields validated (sourced).",
                      "gaps": gaps}}


def main():
    os.makedirs(OUTDIR, exist_ok=True)
    sheet = build()
    with open(os.path.join(OUTDIR, "treatments.json"), "w", encoding="utf-8") as f:
        json.dump(sheet, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print("tracker treatments -> statesheets/tracker/treatments.json (%d treatments)" % sheet["treatment_count"])
    print("GAP CHECK:")
    for g in sheet["_meta"]["gaps"]:
        print("  -", g)
    if not sheet["_meta"]["gaps"]:
        print("  (none)")


if __name__ == "__main__":
    main()
