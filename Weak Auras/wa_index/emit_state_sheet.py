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
import re
import subprocess
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
LUA = os.path.join(_ROOT, ".tools", "lua51", "lua5.1.exe")
EXTRACT = os.path.join(_THIS, "extract.lua")
WA = "F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAuras"
PROTOS = os.path.join(WA, "Prototypes.lua")
INDEX = os.path.join(_THIS, "index_grounded.json")
AURA2_OPTS = os.path.join(os.path.dirname(WA), "WeakAurasOptions", "BuffTrigger2.lua")  # aura2 SELF-REPORT source
AURA2_RUNTIME = os.path.join(WA, "BuffTrigger2.lua")   # aura2 RUNTIME handler - the READ form (the trigger.X it reads)
GENERIC_OPTS = os.path.join(os.path.dirname(WA), "WeakAurasOptions", "GenericTrigger.lua")  # custom SELF-REPORT source
GENERIC_RUNTIME = os.path.join(WA, "GenericTrigger.lua")   # custom RUNTIME handler - the READ form (trigger.X it reads)
SCHEMA = os.path.join(_THIS, "aura_trigger_schema.json")   # aura2 corpus ENRICHMENT (idioms / rank-resolution)
SEEDS = os.path.join(_THIS, "trigger_seed_defaults.json")
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
    # --- HANDLING rules (the shaping grammar sourced with the lever: HOW its value must be shaped) ---
    me = arg.get("multiEntry")
    if isinstance(me, dict):
        row["multiEntry"] = {"operator": me.get("operator"), "limit": me.get("limit")}
        row["value_shape"] = "array"                 # value + operator stored as ARRAYS (limit = MAX, AND-combined)
    if arg.get("operator_types"):
        row["operator_types"] = arg.get("operator_types")   # constrains the operator set (else full < <= = > >= ~=)
    init = arg.get("init")
    if isinstance(init, str) and not init.startswith("<func"):
        row["reads"] = init                          # flatten/semantic: the native signal the value derives from
    if arg.get("formatter"):
        row["formatter"] = arg.get("formatter")
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
        proto_h = {k: proto.get(k) for k in ("progressType", "statesParameter") if proto.get(k) is not None}
        for flag in ("timedrequired", "automatic", "automaticrequired"):
            if proto.get(flag):
                proto_h[flag] = proto.get(flag)
        events.append({
            "event": ns,
            "display": display.get(ns, ns),
            "handling": proto_h,                     # prototype-level rules: progress model (region-compat) + state scope
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


LEVER_TYPES = {"toggle", "select", "input", "multiselect", "range", "number", "color", "toggleWithIcon"}


def _extract_trigger_options(optsfile, probetype=None):
    """Run extract.lua triggeroptions -> a trigger system's OWN self-reported option surface (its options
    builder called under stubs with a probe of `probetype`; every option WA's builder declares)."""
    cmd = [LUA, EXTRACT, "triggeroptions", optsfile] + ([probetype] if probetype else [])
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        sys.exit("extract.lua triggeroptions failed: " + proc.stderr[:400])
    return json.loads(proc.stdout)


def _lever_rows(raw):
    """self-reported options -> input rows (levers only, ordered)."""
    rows = []
    for key, o in sorted(raw.items(), key=lambda kv: (kv[1].get("order") if isinstance(kv[1], dict) else 0) or 0):
        if not isinstance(o, dict) or o.get("type") not in LEVER_TYPES:
            continue
        rows.append({"name": key, "display": o.get("name"), "surface": "input",
                     "input_type": o.get("type"), "order": o.get("order"), "value_domain": o.get("values"),
                     "conditional": bool(o.get("conditional")),
                     "enabled_when": "conditional" if o.get("conditional") else "always"})
    return rows


def _runtime_reads(handler_path):
    """The fields a runtime handler READS off the trigger table (`trigger.X`) - the read/stored form, sourced from the
    runtime itself. Needed for FUNCTION-DRIVEN triggers whose options-builder names diverge from what WA actually reads
    (aura2: options spellid1/name1 vs read auranames/auraspellids; WA's Modernize collapses one to the other)."""
    if not os.path.exists(handler_path):
        return set()
    txt = open(handler_path, encoding="utf-8", errors="replace").read()
    return set(re.findall(r"trigger\.([a-zA-Z_][a-zA-Z0-9_]*)", txt))


def build_aura2():
    """The Aura trigger (BuffTrigger2) is function-driven, so no event_prototype to scan - but its options
    builder SELF-REPORTS via GetBuffTriggerOptions (extract.lua triggeroptions). That is the authoritative,
    complete input surface (not a corpus-curated list). `conditional` = the option's hidden-fn gating (the
    tier-1 exclusivity FLAG; the readable relationship is the live-probe pass, still to come). provides = the
    auto-state the trigger flattens (UpdateMatchData). The corpus schema is demoted to an ENRICHMENT block."""
    raw = _extract_trigger_options(AURA2_OPTS)
    schema = json.load(open(SCHEMA, encoding="utf-8"))
    default_state = {"type": "aura2"}
    default_state.update(json.load(open(SEEDS, encoding="utf-8")).get("aura2", {}))  # unit=player, debuffType=HELPFUL
    inputs = _lever_rows(raw)
    # UNION the RUNTIME-READ fields: BuffTrigger2's own `trigger.X` reads = the read/stored form a docket authors and
    # WA matches on. The OPTIONS builder names diverge for spell-matching (spellid1/name1); the runtime reads
    # auranames/auraspellids, and Modernize collapses one into the other (BuffTrigger2:3200-3247). SOURCED from the
    # runtime, not invented - the sheet must reflect the form WA reads, else the gate flags a correct docket malform.
    _opt = {r.get("name") for r in inputs}
    for name in sorted(_runtime_reads(AURA2_RUNTIME) - _opt):
        inputs.append({"name": name, "surface": "runtime-read",
                       "note": "read off the trigger by BuffTrigger2 (read form); the options-builder name diverges"})
    for row in inputs:                        # match-family-not-rank policy
        if row["name"] == "useName":
            row["policy"] = {"our_policy": True, "why": "match-family-not-rank: drive-from-ID in auranames, all ranks"}
        elif row["name"] == "useExactSpellId":
            row["policy"] = {"our_policy": False, "why": "match-family-not-rank: exact spellId pins one rank"}
    auto = schema.get("read", {}).get("_auto_state", "")
    provides = [{"name": f.strip().rstrip("."), "surface": "provides"}
                for f in (auto.split(":", 1)[1] if ":" in auto else "").split(",") if f.strip()]
    event = {
        "event": "Aura", "display": "Aura", "default_state": default_state,
        "drive_from_id": "spellId in auranames (useName) - family match; not auraspellids (useExactSpellId)",
        "options": {"inputs": inputs, "provides": provides, "internal": []},
        "enrichment": {   # corpus REFERENCE, not the surface
            "idioms": schema.get("_idioms"),
            "axis_roles": {a: schema.get(a, {}).get("_role") for a in ("catch", "resolve", "show", "read")},
            "rank_resolution": schema.get("resolve", {}).get("_rank_resolution")},
    }
    return {
        "trigger_type": "aura2", "type_display": "Aura", "event_count": 1, "events": [event],
        "_meta": {"source": "SELF-REPORTED via extract.lua triggeroptions -> GetBuffTriggerOptions (WA's own "
                            "options builder). provides = auto-state (BuffTrigger2 UpdateMatchData). corpus schema "
                            "= enrichment only, NOT the surface. `conditional` = tier-1 exclusivity flag.",
                  "input_count": len(inputs)},
    }


def build_custom():
    """Custom has no event_prototype, but its options SELF-REPORT via GetGenericTriggerOptions (probed
    type=custom). This is the custom-SPECIFIC surface (event/check/hide/duration config) - a thin wrapper.
    The code boxes (Custom Trigger / Name / Icon / Texture / Stack Info) are COMMON trigger options
    (AddCommonTriggerOptions, shared across ALL triggers), a separate common-options self-report - noted."""
    inputs = _lever_rows(_extract_trigger_options(GENERIC_OPTS, "custom"))
    # UNION the code-entry code-box slots the OPTIONS builder hides (they render as multiline editors, not option rows):
    # custom / customVariables / customName / customIcon / customTexture / customDuration / customStacks. Same divergence
    # aura2 had, SOURCED from the runtime GenericTrigger.lua's own `trigger.X` reads. But GenericTrigger is the SHARED
    # runtime for ALL generic types, so a blanket union would pull in event/spellId/unit/... - scope to WA's own `custom`
    # naming convention (every user-Lua box is prefixed `custom`). Slots become KNOWN fields; the Lua VALUE stays trusted
    # user-content-by-construction (the gate's custom exception: "slots verified, payload trusted").
    _opt = {r.get("name") for r in inputs}
    for name in sorted(r for r in _runtime_reads(GENERIC_RUNTIME) if r.startswith("custom") and r not in _opt):
        inputs.append({"name": name, "surface": "runtime-read",
                       "note": "code-entry box read off the trigger at runtime; hidden from the options self-report"})
    event = {
        "event": "Custom", "display": "Custom", "default_state": {"type": "custom", "custom_type": "event"},
        "note": "code-entry wrapper: the user writes Lua. The Custom Trigger / Name / Icon / Texture / Stack "
                "Info code boxes are COMMON trigger options (AddCommonTriggerOptions), shared across ALL "
                "triggers - NOT custom-specific; a separate common-options self-report (stubbed here).",
        "options": {"inputs": inputs, "provides": [], "internal": []},
    }
    return {
        "trigger_type": "custom", "type_display": "Custom", "event_count": 1, "events": [event],
        "_meta": {"source": "SELF-REPORTED via extract.lua triggeroptions -> GetGenericTriggerOptions (probe "
                            "type=custom). Custom-specific options only; the common code-boxes are the shared "
                            "common-options layer (TODO, applies to all types).",
                  "input_count": len(inputs)},
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
                    o["name"], o.get("surface", ""), o.get("input_kind") or o.get("axis") or "",
                    o.get("value_domain") or "", o.get("default") if o.get("default") is not None else "",
                    "✓" if o.get("required_seed") else "", "✓" if o.get("gated") else "",
                    ("→%s" % pol.get("our_policy")) if pol else ""))
    return "\n".join(out) + "\n"


def _routes(sheet):
    """ROUTING INDEX (light MD): the MAIN levers (input surface) as one line each, grouped by event, pointing to
    the full sheet for detail. The inventory's browse-MENU and a routed-read locator - choosing a lever never
    requires reading how EVERY lever works (context-in-flight is expensive; overload -> drift). Pure projection,
    regenerated with the sheet. `rule` = the one thing to know before opening detail (array-shape / value-domain);
    the full handling waits in <type>.json."""
    cat = sheet.get("trigger_type")
    out = ["# %s - routing index" % cat,
           "_Main (input) levers only. Open `%s.json` for full handling. "
           "rule: `array`=multiEntry (value+operator as arrays) - `dom:X`=value-domain X (see domains.json)._" % cat]
    for e in sheet.get("events", []):
        pt = (e.get("handling") or {}).get("progressType")
        out.append("\n## %s%s" % (e.get("event"), ("  - progress: %s" % pt) if pt else ""))
        rows = e.get("options", {}).get("inputs", [])
        if not rows:
            out.append("_(no input levers)_")
            continue
        out.append("| lever | type | rule |")
        out.append("|---|---|---|")
        for o in rows:
            rule = "array" if o.get("value_shape") == "array" else \
                   ("dom:%s" % o["value_domain"] if o.get("value_domain") else "")
            nm, disp = o.get("name"), o.get("display")
            label = "%s (%s)" % (nm, disp) if disp and disp != nm else nm
            out.append("| %s | %s | %s |" % (label, o.get("arg_type") or o.get("input_type") or "", rule))
    return "\n".join(out) + "\n"


def _emit(sheet, want_md):
    os.makedirs(OUTDIR, exist_ok=True)
    cat = sheet["trigger_type"]
    jpath = os.path.join(OUTDIR, cat + ".json")
    with open(jpath, "w", encoding="utf-8") as f:
        json.dump(sheet, f, ensure_ascii=False, indent=1)
        f.write("\n")
    with open(os.path.join(OUTDIR, cat + ".routes.md"), "w", encoding="utf-8") as f:  # the routing index (light)
        f.write(_routes(sheet))
    if want_md:
        with open(os.path.join(OUTDIR, cat + ".md"), "w", encoding="utf-8") as f:
            f.write(_md(sheet))
    print("  %-10s -> %-12s %d events (+routes)" % (cat, cat + ".json", sheet["event_count"]))


# trigger types WA drives outside event_prototypes (special-cased in GenericTrigger/options)
IMPLEMENTED_SPECIALS = ("aura2", "custom")   # function-driven; self-reported via triggeroptions
TODO_SPECIALS = ()


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    protos = _extract_prototypes().get("triggers", {})
    by_opt, display = _index_lookup()
    # the sourced worklist: distinct prototype 'type' == Private.category_event_prototype
    proto_types = sorted({p.get("type") for p in protos.values()
                          if isinstance(p, dict) and p.get("type")})
    print("trigger-type worklist (sourced): %s + specials %s" % (proto_types, list(IMPLEMENTED_SPECIALS)))
    print("  still TODO (not event_prototypes): %s" % list(TODO_SPECIALS))
    cats = args if (args and args[0] != "all") else proto_types + list(IMPLEMENTED_SPECIALS)
    print("emitting -> %s/" % os.path.relpath(OUTDIR, _ROOT))
    special = {"aura2": build_aura2, "custom": build_custom}
    for category in cats:
        sheet = special[category]() if category in special else build(category, protos, by_opt, display)
        _emit(sheet, "--no-md" not in sys.argv)


if __name__ == "__main__":
    main()
