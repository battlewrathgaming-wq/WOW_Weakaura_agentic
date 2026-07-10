"""
build_index.py - drive extract.lua over all of WeakAuras' declarative source and
flatten it into one FLAT lever index: every load option, trigger arg, region /
subregion field, and condition change-lever, each traceable to its section.

This is the reference authority ("what levers exist"), complementary to the
harvested corpus ("which levers a working aura uses"). Runs WA's own tables under
Lua 5.1 (extract.lua) - not regex.

Output:
  index.json          - flat list of lever records
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
WA = ("F:/games/Ascension_wow/resources/ascension-live/Interface/AddOns/WeakAuras")


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


def _arg_record(section, namespace, arg, source):
    """A load/trigger arg -> a config lever (checkable if it has conditionType)."""
    name = arg.get("name")
    if not name:
        return None
    return {
        "section": section,
        "namespace": namespace,
        "name": name,
        "role": "config",
        "type": arg.get("type"),
        "checkable": bool(arg.get("conditionType")),
        "conditionType": arg.get("conditionType"),
        "values": arg.get("values"),
        "display": arg.get("display"),
        "source": source,
    }


def _field_records(section, namespace, default_table, source):
    """A region/subregion default() field -> a data 'field' lever (its default value)."""
    out = []
    for k, v in default_table.items():
        out.append({
            "section": section, "namespace": namespace, "name": k,
            "role": "field", "type": type(v).__name__, "default": v, "source": source,
        })
    return out


def _property_records(section, namespace, properties, source):
    """A region/subregion property -> a condition CHANGE-lever."""
    out = []
    for k, meta in properties.items():
        m = meta if isinstance(meta, dict) else {}
        # skip shared props our no-op AddProperties couldn't fully populate
        if not m.get("type"):
            continue
        out.append({
            "section": section, "namespace": namespace, "name": k,
            "role": "change", "type": m.get("type"), "setter": m.get("setter"),
            "values": m.get("values"), "source": source,
        })
    return out


def main():
    records = []

    # --- prototypes: load + triggers ---
    proto = run("prototypes", os.path.join(WA, "Prototypes.lua"))
    if proto:
        for arg in (proto.get("load") or {}).get("args", []):
            r = _arg_record("load", "", arg, "Prototypes.lua")
            if r:
                records.append(r)
        for tname, tdef in (proto.get("triggers") or {}).items():
            for arg in (tdef or {}).get("args", []):
                r = _arg_record("trigger", tname, arg, "Prototypes.lua")
                if r:
                    records.append(r)

    # --- regions ---
    rdir = os.path.join(WA, "RegionTypes")
    for fn in sorted(os.listdir(rdir)):
        if not fn.endswith(".lua"):
            continue
        data = run("region", os.path.join(rdir, fn))
        if not data:
            continue
        for name, entry in data.items():
            src = f"RegionTypes/{fn}"
            records += _field_records("region", name, entry.get("default", {}), src)
            records += _property_records("region", name, entry.get("properties", {}), src)

    # --- subregions ---
    sdir = os.path.join(WA, "SubRegionTypes")
    for fn in sorted(os.listdir(sdir)):
        if not fn.endswith(".lua"):
            continue
        data = run("subregion", os.path.join(sdir, fn))
        if not data:
            continue
        for name, entry in data.items():
            src = f"SubRegionTypes/{fn}"
            # prefer the aurabar default variant, else icon, else none/plain
            dft = (entry.get("default_aurabar") or entry.get("default_icon")
                   or entry.get("default_none") or entry.get("default") or {})
            records += _field_records("subregion", name, dft, src)
            records += _property_records("subregion", name, entry.get("properties", {}), src)

    # --- write ---
    idx = os.path.join(_THIS, "index.json")
    with open(idx, "w", encoding="utf-8") as f:
        json.dump(records, f, indent=1, ensure_ascii=False)
        f.write("\n")

    # summary
    summary = {"total": len(records), "by_section": {}, "namespaces": {}, "checkable_levers": 0}
    for r in records:
        s = r["section"]
        summary["by_section"][s] = summary["by_section"].get(s, 0) + 1
        ns = f"{s}:{r['namespace']}" if r["namespace"] else s
        summary["namespaces"][ns] = summary["namespaces"].get(ns, 0) + 1
        if r.get("checkable"):
            summary["checkable_levers"] += 1
    summary["by_section"] = dict(sorted(summary["by_section"].items()))
    summary["namespaces"] = dict(sorted(summary["namespaces"].items()))
    with open(os.path.join(_THIS, "index_summary.json"), "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"wrote index.json  ({len(records)} lever records)")
    print(f"  by section: {summary['by_section']}")
    print(f"  checkable (condition CHECK) levers: {summary['checkable_levers']}")
    print(f"  region/subregion CHANGE-levers: {sum(1 for r in records if r['role']=='change')}")


if __name__ == "__main__":
    main()
