"""
emit_state_sheet.py - emit a per-trigger-TYPE state sheet (the COMPLETE option surface) as JSON,
for the generation pipeline. Mirrors the WA UI decision tree: Type -> Event -> Options(+provides).

Sourced from the raw event_prototypes (via extract.lua, the authority) joined onto the grounded index
(value domains, display names, input_kind). NOT derived from captures - a capture is structurally blind
to the 'provides' fields (they're never written to a clean-slate export), so it only VALIDATES the input
surface. Space is cheap, reasoning is scarce: the sheet emits the whole surface so design reads, not re-derives.

Per option it records: surface (input vs provides), input_kind, arg type, value-domain, default, whether it
is a required SEED (-> use_X=true), whether it is GATED by an enable (tier-1 mutual exclusivity), whether it
STOREs a condition variable, and any companion-toggle POLICY (e.g. exact-spell-name -> match-family-not-rank).

  py emit_state_sheet.py spell            -> statesheets/trigger/spell.json  (+ .md)
  py emit_state_sheet.py spell --no-md    -> json only

statesheets/ holds one folder per WA DOMAIN (load, trigger, display, animations, ...); this emitter
fills the TRIGGER domain (one file per trigger TYPE: spell, aura, unit, ...).
"""
import json
import os
import subprocess
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
LUA = os.path.join(_ROOT, ".tools", "lua51", "lua5.1.exe")
EXTRACT = os.path.join(_THIS, "extract.lua")
WA = "F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAuras"
PROTOS = os.path.join(WA, "Prototypes.lua")
INDEX = os.path.join(_THIS, "index_grounded.json")
# statesheets/ is the home for every WA DOMAIN (load, trigger, display, animations, ...).
# This emitter fills the TRIGGER domain; siblings emit the others in the same shape.
DOMAIN = "trigger"
OUTDIR = os.path.join(_THIS, "statesheets", DOMAIN)

# UI type-category display names (the top dropdown Battlewrath sees)
TYPE_DISPLAY = {"spell": "Spell", "unit": "Player/Unit Info", "aura2": "Aura",
                "custom": "Custom", "item": "Item", "addons": "Other Addon"}


def _extract_prototypes():
    """Run extract.lua under Lua 5.1 -> the raw event_prototypes table (the authority)."""
    proc = subprocess.run([LUA, EXTRACT, "prototypes", PROTOS], capture_output=True, text=True)
    if proc.returncode != 0:
        sys.exit("extract.lua failed: " + proc.stderr[:400])
    return json.loads(proc.stdout)


def _index_lookup():
    """(namespace, option) -> grounded record; namespace -> UI display name."""
    idx = json.load(open(INDEX, encoding="utf-8"))
    by_opt, display = {}, {}
    for r in idx:
        if not isinstance(r, dict) or r.get("section") != "trigger":
            continue
        ns, nm = r.get("namespace"), r.get("name")
        by_opt[(ns, nm)] = r
        if r.get("namespace_display"):
            display[ns] = r["namespace_display"]
    return by_opt, display


def _gated(enable):
    # extract.lua serialises a function as a string marker; a real enable = conditional option
    return enable is not None and not (isinstance(enable, bool) and enable is False)


def _option(ns, arg, by_opt):
    """One option row: everything a designer needs to decide fill vs leave-to-default."""
    name = arg.get("name")
    ix = by_opt.get((ns, name), {})
    arg_type = arg.get("type")
    surface = "input" if arg_type else ("provides" if arg.get("store") else "internal")
    gated = _gated(arg.get("enable"))
    required = bool(arg.get("required"))
    row = {
        "name": name,
        "display": ix.get("display") or name,
        "surface": surface,                              # input | provides | internal
        "input_kind": ix.get("input_kind"),             # reference|toggle|value|dropdown
        "arg_type": arg_type,                            # spell|toggle|number|select|None(=provides)
        "value_domain": ix.get("values"),
        "value_domain_source": ix.get("values_source"),
        "default": arg.get("default") if not isinstance(arg.get("default"), str)
                   or not arg["default"].startswith("<func") else "(dynamic)",
        "required_seed": required,                       # required -> use_X seeded true
        "gated": gated,                                  # enable present -> tier-1 exclusivity
        "enabled_when": "conditional" if gated else "always",
        "stores_condition_var": bool(arg.get("store")),  # exposes a condition variable
        "conditionType": ix.get("conditionType"),
    }
    if arg.get("showExactOption"):
        row["policy"] = {"knob": "use_exact_" + name, "wa_default": True, "our_policy": False,
                         "why": "match-family-not-rank (name-match catches the whole family)"}
    return row


def _default_state(ns, proto):
    """The seed the emitter would plug (required->use_X=true + scalar default). Companion toggles
    (exact) are policy, deliberately OFF, so they are omitted here - matching an exact-off capture."""
    state = {"type": proto.get("type"), "event": ns}
    for arg in proto.get("args", []):
        if not isinstance(arg, dict):
            continue
        if arg.get("required") and not (arg.get("type") == "multiselect" and arg.get("multiNoSingle")):
            state["use_" + arg["name"]] = True
            d = arg.get("default")
            if d is not None and not (isinstance(d, str) and d.startswith("<func")):
                state[arg["name"]] = d
    return state


def build(category, protos, by_opt, display):
    events = []
    for ns, proto in sorted(protos.items()):
        if not isinstance(proto, dict) or proto.get("type") != category:
            continue
        inputs, provides, internal = [], [], []
        for arg in proto.get("args", []):
            if not isinstance(arg, dict) or not arg.get("name"):
                continue
            row = _option(ns, arg, by_opt)
            {"input": inputs, "provides": provides}.get(row["surface"], internal).append(row)
        events.append({
            "event": ns,
            "display": display.get(ns, ns),
            "default_state": _default_state(ns, proto),
            "options": {"inputs": inputs, "provides": provides, "internal": internal},
        })
    return {
        "trigger_type": category,
        "type_display": TYPE_DISPLAY.get(category, category),
        "event_count": len(events),
        "events": events,
        "_meta": {"source": "extract.lua event_prototypes + index_grounded.json",
                  "note": "provides/internal fields are source-only (captures are blind to them); "
                          "exact-spell-name is our-policy OFF (match-family-not-rank)"},
    }


def _md(sheet):
    out = ["# Trigger type: %s  (`%s`)\n" % (sheet["type_display"], sheet["trigger_type"]),
           "_%d events. input = you fill · provides = trigger outputs (conditions/subregions) · "
           "seed = forced on · gated = conditional._\n" % sheet["event_count"]]
    for e in sheet["events"]:
        out.append("\n## %s  (`%s`)" % (e["display"], e["event"]))
        out.append("default state: `%s`\n" % json.dumps(e["default_state"]))
        out.append("| option | surface | input | domain | default | seed | gated | policy |")
        out.append("|---|---|---|---|---|---|---|---|")
        for grp in ("inputs", "provides", "internal"):
            for o in e["options"][grp]:
                pol = o.get("policy", {})
                out.append("| %s | %s | %s | %s | %s | %s | %s | %s |" % (
                    o["name"], o["surface"], o["input_kind"] or "", o["value_domain"] or "",
                    o["default"] if o["default"] is not None else "", "✓" if o["required_seed"] else "",
                    "✓" if o["gated"] else "", ("exact→%s" % pol["our_policy"]) if pol else ""))
    return "\n".join(out) + "\n"


def _emit(sheet, want_md):
    os.makedirs(OUTDIR, exist_ok=True)
    cat = sheet["trigger_type"]
    jpath = os.path.join(OUTDIR, cat + ".json")
    with open(jpath, "w", encoding="utf-8") as f:
        json.dump(sheet, f, ensure_ascii=False, indent=1)
        f.write("\n")
    if want_md:
        with open(os.path.join(OUTDIR, cat + ".md"), "w", encoding="utf-8") as f:
            f.write(_md(sheet))
    print("  %-10s -> %-12s %d events" % (cat, cat + ".json", sheet["event_count"]))


# trigger types WA drives outside event_prototypes (special-cased in GenericTrigger/options)
SPECIAL_TYPES = ("aura2", "custom")


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    protos = _extract_prototypes().get("triggers", {})
    by_opt, display = _index_lookup()
    # the sourced worklist: distinct prototype 'type' == Private.category_event_prototype
    proto_types = sorted({p.get("type") for p in protos.values()
                          if isinstance(p, dict) and p.get("type")})
    print("trigger-type worklist (sourced): %s" % proto_types)
    print("  + special (not event_prototypes, TODO): %s" % list(SPECIAL_TYPES))
    cats = args if (args and args[0] != "all") else proto_types
    print("emitting -> %s/" % os.path.relpath(OUTDIR, _ROOT))
    for category in cats:
        _emit(build(category, protos, by_opt, display), "--no-md" not in sys.argv)


if __name__ == "__main__":
    main()
