"""
build_index.py - drive extract.lua over all of WeakAuras' declarative source and
flatten it into one FLAT lever index: every load option, trigger arg, region /
subregion field, and condition change-lever, each traceable to its section.

NAME RECONCILIATION (Battlewrath, 2026-07-11): the canonical id of every lever /
namespace is the term WA ACCEPTS in the data table (regionType value, trigger
event key, arg name, property name) - never our invention. WA's OWN display label
(prototype `name`, subregion registration label, region `displayName`, arg
`display`) rides alongside as `*_display`, sourced from WA, so we speak WA's
terminology without drift. Our constraint is what WA can accept.

Output:
  index.json          - flat list of lever records
  vocabulary.json     - accept-term -> WA display label, per section (the reconciliation)
  index_summary.json  - counts per section / namespace

    py build_index.py
"""
import json
import os
import subprocess
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
LUA = os.path.normpath(os.path.join(_THIS, "..", "..", ".tools", "lua51", "lua5.1.exe"))
EXTRACT = os.path.join(_THIS, "extract.lua")
_ADDONS = "F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns"
WA = f"{_ADDONS}/WeakAuras"
WAO = f"{_ADDONS}/WeakAurasOptions"


def run(mode, path):
    proc = subprocess.run([LUA, EXTRACT, mode, path], capture_output=True, text=True)
    if proc.returncode != 0:
        print(f"  [warn] {mode} {os.path.basename(path)}: {proc.stderr.strip()}")
        return None
    try:
        return json.loads(proc.stdout)
    except json.JSONDecodeError as e:
        print(f"  [warn] {mode} {os.path.basename(path)}: bad JSON ({e})")
        return None


def region_display_map():
    """regionType (accept) -> WA displayName, from WeakAurasOptions/RegionOptions."""
    out = {}
    rodir = os.path.join(WAO, "RegionOptions")
    if not os.path.isdir(rodir):
        print("  [warn] WeakAurasOptions/RegionOptions not found - region displays skipped")
        return out
    for fn in sorted(os.listdir(rodir)):
        if fn.endswith(".lua"):
            data = run("regionoptions", os.path.join(rodir, fn))
            if data:
                out.update(data)
    return out


def _arg_record(section, namespace, ns_display, arg, source):
    name = arg.get("name")
    if not name:
        return None
    return {
        "section": section, "namespace": namespace, "namespace_display": ns_display,
        "name": name, "role": "config", "type": arg.get("type"),
        "checkable": bool(arg.get("conditionType")), "conditionType": arg.get("conditionType"),
        "values": arg.get("values"), "display": arg.get("display"), "source": source,
    }


def _field_records(section, namespace, ns_display, default_table, source):
    return [{
        "section": section, "namespace": namespace, "namespace_display": ns_display,
        "name": k, "role": "field", "type": type(v).__name__, "default": v, "source": source,
    } for k, v in default_table.items()]


def _property_records(section, namespace, ns_display, properties, source):
    out = []
    for k, meta in properties.items():
        m = meta if isinstance(meta, dict) else {}
        if not m.get("type"):  # shared props our no-op AddProperties can't fully populate
            continue
        out.append({
            "section": section, "namespace": namespace, "namespace_display": ns_display,
            "name": k, "role": "change", "type": m.get("type"),
            "setter": m.get("setter"), "values": m.get("values"),
            "display": m.get("display"), "source": source,
        })
    return out


def main():
    records = []
    vocab = {"region": {}, "trigger": {}, "subregion": {}}

    # --- prototypes: load + triggers (WA display = prototype 'name') ---
    proto = run("prototypes", os.path.join(WA, "Prototypes.lua"))
    if proto:
        for arg in (proto.get("load") or {}).get("args", []):
            r = _arg_record("load", "", None, arg, "Prototypes.lua")
            if r:
                records.append(r)
        for tname, tdef in (proto.get("triggers") or {}).items():
            ns_display = (tdef or {}).get("name")
            vocab["trigger"][tname] = ns_display
            for arg in (tdef or {}).get("args", []):
                r = _arg_record("trigger", tname, ns_display, arg, "Prototypes.lua")
                if r:
                    records.append(r)

    # --- regions (WA display from WeakAurasOptions) ---
    rmap = region_display_map()
    rdir = os.path.join(WA, "RegionTypes")
    for fn in sorted(os.listdir(rdir)):
        if not fn.endswith(".lua"):
            continue
        data = run("region", os.path.join(rdir, fn))
        if not data:
            continue
        for name, entry in data.items():
            src = f"RegionTypes/{fn}"
            disp = rmap.get(name)
            vocab["region"][name] = disp
            records += _field_records("region", name, disp, entry.get("default", {}), src)
            records += _property_records("region", name, disp, entry.get("properties", {}), src)

    # --- subregions (WA display from registration label) ---
    sdir = os.path.join(WA, "SubRegionTypes")
    for fn in sorted(os.listdir(sdir)):
        if not fn.endswith(".lua"):
            continue
        data = run("subregion", os.path.join(sdir, fn))
        if not data:
            continue
        for name, entry in data.items():
            src = f"SubRegionTypes/{fn}"
            disp = entry.get("display")
            dft = (entry.get("default_aurabar") or entry.get("default_icon")
                   or entry.get("default_none") or entry.get("default") or {})
            if dft or entry.get("properties"):
                vocab["subregion"][name] = disp
            records += _field_records("subregion", name, disp, dft, src)
            records += _property_records("subregion", name, disp, entry.get("properties", {}), src)

    # --- shared region levers (RegionPrototype.AddProperties) ---
    rp = run("regionprototype", os.path.join(WA, "RegionTypes", "RegionPrototype.lua"))
    if rp:
        src = "RegionTypes/RegionPrototype.lua"
        records += _property_records("region", "_shared", "(all regions)", rp.get("shared_properties", {}), src)
        records += _field_records("region", "_shared", "(all regions)", rp.get("shared_defaults", {}), src)

    # --- animation (call the Options builder, capture its arg schema) ---
    # namespace = phase (start/main/finish); name = the accepted field key after
    # the phase prefix (animation.<phase>.<name>). Proves the Options-tab read
    # method (reusable for Actions/Custom Options).
    _acetype = {"toggle": "bool", "range": "number", "input": "string",
                "color": "color", "select": "select"}
    anim = run("animoptions", os.path.join(WAO, "AnimationOptions.lua"))
    if anim:
        for fld, spec in anim.items():
            if not isinstance(spec, dict) or spec.get("type") in ("header", "description", "execute"):
                continue
            parts = fld.split("_", 1)
            if len(parts) != 2 or parts[0] not in ("start", "main", "finish"):
                continue
            phase, name = parts
            vals = spec.get("values")
            vals = vals if isinstance(vals, str) else None
            if name == "preset":  # per-phase dynamic list -> resolve by convention
                vals = f"anim_{phase}_preset_types"
            disp = spec.get("name")
            disp = disp if isinstance(disp, str) and disp != "<function>" else None
            records.append({
                "section": "animation", "namespace": phase, "namespace_display": phase.capitalize(),
                "name": name, "role": "config", "type": _acetype.get(spec.get("type"), spec.get("type")),
                "values": vals if vals != "<function>" else None,
                "display": disp, "source": "WeakAurasOptions/AnimationOptions.lua",
            })

    # --- value-domains (Types.lua) - the allowed values a select/list lever accepts ---
    vd_raw = run("types", os.path.join(WA, "Types.lua")) or {}
    value_domains = {k: v for k, v in vd_raw.items() if v and isinstance(v, (dict, list))}
    refs = set(r["values"] for r in records if isinstance(r.get("values"), str))
    unresolved = sorted(x for x in refs if x not in value_domains)
    with open(os.path.join(_THIS, "value_domains.json"), "w", encoding="utf-8") as f:
        json.dump(dict(sorted(value_domains.items())), f, indent=1, ensure_ascii=False); f.write("\n")

    # --- input_kind: the UI control-form of each option (how the agent fills it) ---
    # region/subregion FIELD entries only carry their default's Python type, so
    # enrich them from the matching condition change-lever's real WA type (e.g.
    # the `desaturate` field -> bool -> toggle; `iconSource` -> list -> dropdown).
    change_types = {(r["section"], r["namespace"], r["name"]): r.get("type")
                    for r in records if r.get("role") == "change"}
    _KIND = {
        "toggle": ("bool", "toggle", "boolean"),
        "dropdown": ("select", "list", "multiselect", "tristate", "unit"),
        "value": ("number", "range", "int", "float", "currency"),
        "reference": ("spell", "string", "str", "input", "item", "icon", "longstring",
                      "aura", "texture", "textureLSM", "talent", "mysticenchant", "NoneType"),
        "color": ("color",),
        "action": ("glowexternal", "sound", "chat", "customcode"),  # imperative condition actions
        "ui": ("header", "description", "collapse"),
        "structured": ("dict", "list"),
    }
    _T2K = {t: k for k, ts in _KIND.items() for t in ts}

    def _input_kind(r):
        t = r.get("type")
        if r.get("role") == "field":
            t = change_types.get((r["section"], r["namespace"], r["name"]), t)
        if t is None:
            return "state"  # trigger state vars: read in conditions, not set at creation
        return _T2K.get(t, "other")

    for r in records:
        r["input_kind"] = _input_kind(r)

    # --- write ---
    with open(os.path.join(_THIS, "index.json"), "w", encoding="utf-8") as f:
        json.dump(records, f, indent=1, ensure_ascii=False); f.write("\n")
    for k in vocab:
        vocab[k] = dict(sorted(vocab[k].items()))
    with open(os.path.join(_THIS, "vocabulary.json"), "w", encoding="utf-8") as f:
        json.dump(vocab, f, indent=2, ensure_ascii=False); f.write("\n")

    summary = {"total": len(records), "by_section": {}, "checkable_levers": 0,
               "change_levers": 0, "namespaces_with_wa_display": {}}
    for r in records:
        s = r["section"]
        summary["by_section"][s] = summary["by_section"].get(s, 0) + 1
        if r.get("checkable"):
            summary["checkable_levers"] += 1
        if r["role"] == "change":
            summary["change_levers"] += 1
    summary["by_section"] = dict(sorted(summary["by_section"].items()))
    summary["namespaces_with_wa_display"] = {k: len(v) for k, v in vocab.items()}
    summary["value_domains"] = len(value_domains)
    summary["unresolved_value_refs"] = unresolved
    with open(os.path.join(_THIS, "index_summary.json"), "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False); f.write("\n")

    print(f"wrote index.json ({len(records)} levers), vocabulary.json, value_domains.json, index_summary.json")
    print(f"  by section: {summary['by_section']}")
    print(f"  value-domains: {len(value_domains)}  |  unresolved value refs: {len(unresolved)} {unresolved[:6]}")
    print(f"  vocabulary (accept -> WA display): "
          f"regions {len(vocab['region'])}, triggers {len(vocab['trigger'])}, subregions {len(vocab['subregion'])}")


if __name__ == "__main__":
    main()
