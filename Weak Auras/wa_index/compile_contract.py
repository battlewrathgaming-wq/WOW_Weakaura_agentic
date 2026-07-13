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
            # inputs carry the HANDLING (shaping grammar): value_shape/multiEntry (ARRAY rule), operator set, domain.
            inputs = {o["name"]: {"default": o.get("default"), "domain": o.get("value_domain"),
                                  "shape": o.get("value_shape"), "multiEntry": o.get("multiEntry"),
                                  "operator_types": o.get("operator_types")}
                      for o in opts.get("inputs", []) if o.get("name")}
            # must-assert = required AND no usable default (spellName has none; track defaults to "auto")
            must_assert = [o["name"] for o in opts.get("inputs", [])
                           if o.get("required_seed") and o.get("default") in (None, "", "(dynamic)")]
            # the CONDITION-check surface is the conditionType axis (spellUsable/onCooldown/... incl surface=internal),
            # NOT the store-based `provides` (the contract itself caught that hole).
            condition_vars = [o["name"] for o in allopts if o.get("conditionType") and o.get("name")]
            # event handling: progressType (region-compat) + statesParameter (state scope)
            events[e.get("event")] = {"must_assert": must_assert, "condition_vars": condition_vars,
                                      "handling": e.get("handling") or {}, "inputs": inputs}
        out[tname] = events
    return out


def _display_section():
    sheets = _load("display")
    shared = sheets.pop("_shared", None) or {}                 # the regionPrototype cross-cutting layer
    shared_targets = set(shared.get("shared_change_targets", []))
    out = {}
    for rname, sheet in sheets.items():
        fields = {o["name"]: {"default": o.get("default"), "kind": o.get("kind"),
                              "condition_target": bool(o.get("condition_target"))}
                  for o in sheet.get("options", []) if o.get("name")}
        region_t = set(sheet.get("condition_change_targets", []))
        entry = {"fields": fields,
                 "change_targets": sorted(region_t | shared_targets)}       # region-specific UNION shared
        surf = sheet.get("option_surface")
        if surf:
            entry["option_surface"] = surf.get("levers", {})   # group/dynamicgroup: arrangement levers (trigger-grade)
        cpl = sheet.get("coupling")
        if cpl:
            entry["coupling"] = cpl                             # dynamicgroup: grow/gridType -> selfPoint derivation
        out[rname] = entry
    return out, {"shared_change_targets": sorted(shared_targets),
                 "condition_actions": shared.get("condition_actions", [])}


def _load_section():
    sheet = _load("load").get("load", {})
    conds = {c["name"]: {"type": c.get("type"), "domain": c.get("value_domain")}
             for c in sheet.get("conditions", []) if c.get("name")}
    return {"chain": sheet.get("chain"), "conditions": conds}


def _domains():
    path = os.path.join(SHEETS, "domains.json")
    return json.load(open(path, encoding="utf-8")).get("domains", {}) if os.path.exists(path) else {}


def _domain_refs(trigger):
    """every value_domain named across trigger inputs -> the referenced domain names (to resolve/validate)."""
    refs = set()
    for events in trigger.values():
        for ev in events.values():
            for io in ev.get("inputs", {}).values():
                d = io.get("domain")
                if isinstance(d, str):
                    refs.add(d)
    return refs


def _display_domain_refs(display):
    """value-domains named across region option_surfaces (group/dynamicgroup arrangement levers) -> for dangling check."""
    refs = set()
    for region in display.values():
        for lever in (region.get("option_surface") or {}).values():
            d = lever.get("values")
            if isinstance(d, str):
                refs.add(d)
    return refs


def main():
    trigger = _trigger_section()
    display, display_shared = _display_section()
    domains = _domains()
    refs = _domain_refs(trigger) | _display_domain_refs(display)
    dangling = sorted(r for r in refs if r not in domains)   # a lever pointing at a missing domain = loud
    contract = {
        "_meta": {"built_from": "statesheets/{trigger,display,load} + domains.json - a JOIN, no new extraction",
                  "pre_flight": "read by the class-inventory pre-flight (NOT the pipeline): assert must_assert present, "
                                "values in domain, condition check-var in a trigger `condition_vars`, change-prop in a "
                                "region `change_targets`. Docket + fill stay dumb.",
                  "condition_join": "check reads trigger[type][event].condition_vars (the conditionType axis) -> "
                                    "change hits display[region].change_targets",
                  "handling": "each trigger input carries its shaping grammar: shape/multiEntry (ARRAY rule), "
                              "operator_types, domain (names a domains key); event.handling = progressType "
                              "(region-compat) + statesParameter (state scope). The sheet resolved the shape.",
                  "domain_refs": sorted(refs), "dangling_domains": dangling},
        "trigger": trigger,
        "display": display,
        "display_shared": display_shared,
        "load": _load_section(),
        "domains_available": sorted(domains),
    }
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(contract, f, ensure_ascii=False, indent=1)
        f.write("\n")
    nt = sum(len(ev) for ev in contract["trigger"].values())
    print("contract -> %s" % os.path.relpath(OUT, os.path.dirname(_THIS)))
    print("  trigger : %d types, %d events (with handling)" % (len(contract["trigger"]), nt))
    print("  display : %d regions" % len(contract["display"]))
    print("  load    : %d conditions (%s)" % (len(contract["load"]["conditions"]),
                                              "AND" if "AND" in (contract["load"]["chain"] or "") else "?"))
    print("  domains : %d available, %d referenced, %d DANGLING %s"
          % (len(domains), len(refs), len(dangling), dangling if dangling else ""))


if __name__ == "__main__":
    main()
