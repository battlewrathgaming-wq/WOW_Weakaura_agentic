"""
compile_contract.py - JOIN the domain state sheets into ONE contract: the "resource of observed defaults"
the inventory's PRE-FLIGHT checks an aura's asserts against, and the generator emits toward. No new
extraction (GAP_BRIDGE: contract = a thin JOIN); it gathers what the sheets already sourced + verified:

  - required   : per trigger type+event, the fields that MUST be asserted (required_seed)
  - defaults   : per field, WA's observed default (display = canon-verified; trigger = runtime fallback)
  - domains    : per field, the legal value-domain (assert validity)
  - provides   : per trigger event, the condition CHECK vars (spellUsable ...)
  - change_targets : per region, the condition CHANGES props (desaturate ...)  -> the two halves of a join
  - load chain : AND (source+live verified)

The pre-flight (in the class inventory, NOT the pipeline) reads this to check: required present · values in
domain · condition check-var is a real provides · change-prop is a real change_target. Docket + fill stay dumb.

  py compile_contract.py   -> contract.json
"""
import glob
import json
import os

_THIS = os.path.dirname(os.path.abspath(__file__))
SHEETS = os.path.join(_THIS, "statesheets")
OUT = os.path.join(_THIS, "contract.json")


def _load(domain):
    return {os.path.basename(f)[:-5]: json.load(open(f, encoding="utf-8"))
            for f in glob.glob(os.path.join(SHEETS, domain, "*.json"))}


def _trigger_section():
    out = {}
    for tname, sheet in _load("trigger").items():
        events = {}
        for e in sheet.get("events", []):
            opts = e.get("options", {})
            allopts = opts.get("inputs", []) + opts.get("provides", []) + opts.get("internal", [])
            inputs = {o["name"]: {"default": o.get("default"), "domain": o.get("value_domain")}
                      for o in opts.get("inputs", []) if o.get("name")}
            # must-assert = required AND no usable default (spellName has none; track defaults to "auto")
            must_assert = [o["name"] for o in opts.get("inputs", [])
                           if o.get("required_seed") and o.get("default") in (None, "", "(dynamic)")]
            # the CONDITION-check surface is the conditionType axis (spellUsable/onCooldown/... incl surface=internal),
            # NOT the store-based `provides` (the contract itself caught that hole).
            condition_vars = [o["name"] for o in allopts if o.get("conditionType") and o.get("name")]
            events[e.get("event")] = {"must_assert": must_assert, "condition_vars": condition_vars, "inputs": inputs}
        out[tname] = events
    return out


def _display_section():
    out = {}
    for rname, sheet in _load("display").items():
        fields = {o["name"]: {"default": o.get("default"), "kind": o.get("kind"),
                              "condition_target": bool(o.get("condition_target"))}
                  for o in sheet.get("options", []) if o.get("name")}
        out[rname] = {"fields": fields, "change_targets": sheet.get("condition_change_targets", [])}
    return out


def _load_section():
    sheet = _load("load").get("load", {})
    conds = {c["name"]: {"type": c.get("type"), "domain": c.get("value_domain")}
             for c in sheet.get("conditions", []) if c.get("name")}
    return {"chain": sheet.get("chain"), "conditions": conds}


def main():
    contract = {
        "_meta": {"built_from": "statesheets/{trigger,display,load} - a JOIN, no new extraction",
                  "pre_flight": "read by the class-inventory pre-flight (NOT the pipeline): assert must_assert present, "
                                "values in domain, condition check-var in a trigger `condition_vars`, change-prop in a "
                                "region `change_targets`. Docket + fill stay dumb.",
                  "condition_join": "check reads trigger[type][event].condition_vars (the conditionType axis) -> "
                                    "change hits display[region].change_targets"},
        "trigger": _trigger_section(),
        "display": _display_section(),
        "load": _load_section(),
    }
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(contract, f, ensure_ascii=False, indent=1)
        f.write("\n")
    nt = sum(len(ev) for ev in contract["trigger"].values())
    print("contract -> %s" % os.path.relpath(OUT, os.path.dirname(_THIS)))
    print("  trigger : %d types, %d events" % (len(contract["trigger"]), nt))
    print("  display : %d regions" % len(contract["display"]))
    print("  load    : %d conditions (%s)" % (len(contract["load"]["conditions"]),
                                              "AND" if "AND" in (contract["load"]["chain"] or "") else "?"))


if __name__ == "__main__":
    main()
