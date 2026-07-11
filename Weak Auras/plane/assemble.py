"""
assemble.py - the DUMB assembler for the generic plane. Zero reasoning: read a
BOM, drop each part into its lane, fill holes, mint identity, emit a WA data
table, encode to an import string. All intelligence lives upstream (the BOM,
authored by the agent/human); everything here is mechanical.

Lanes:
  region  -> the base body (exactly one)
  trigger -> triggers[next index]  (1-based, in BOM order)
  load    -> the load block

    py assemble.py boms/corpse_explosion_availability.bom.json

Writes out/<name>.table.json (the data table) and out/<name>.import.txt (the
import string). Verifies the table survives a codec encode->decode->encode
round-trip before writing - a table that doesn't is a bug here, not shipped.
"""
import copy
import json
import os
import re
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_WEAKAURAS = os.path.dirname(_THIS)
sys.path.insert(0, _WEAKAURAS)
import weakaura_codec as wc

PARTS = os.path.join(_THIS, "parts")
OUT = os.path.join(_THIS, "out")
_PLACEHOLDER = re.compile(r"^\{\{(\w+)\}\}$")


def load_part(part_id):
    path = os.path.join(PARTS, part_id + ".json")
    if not os.path.exists(path):
        raise SystemExit(f"unknown part {part_id!r} ({path} missing)")
    return json.load(open(path, encoding="utf-8"))


def set_path(d, path, value):
    """Set a (possibly dotted) field path, e.g. 'class.single'."""
    keys = path.split(".")
    for k in keys[:-1]:
        d = d.setdefault(k, {})
    d[keys[-1]] = value


def apply_fills(template, lane, fills):
    """Fill a derived part by OVERRIDING fields on its core. Trigger core is the
    inner `trigger` dict; region / subregion / load core is the dict itself. Fill
    keys are WA field names, dotted for nesting (e.g. 'class.single')."""
    t = copy.deepcopy(template)
    core = t["trigger"] if lane == "trigger" and isinstance(t.get("trigger"), dict) else t
    for field, value in (fills or {}).items():
        set_path(core, field, value)
    return t


def build_conditions(bom, roles):
    """The JOIN former. Build conditions[] from the BOM's join spec. Each join:
        { when: { role, var, value }, then: [ { set:<property>, value } ] }
    references a trigger by ROLE; we resolve role -> the index the assembler
    allocated (roles are semantic; indices are mechanical). Leaf checks only for
    now - recursive AND/OR check trees are the next grammar add. Change target is
    a bare region/sub property; `sub.M` role-resolution is a later extension."""
    conditions = []
    for j in bom.get("join", []):
        w = j["when"]
        if w["role"] not in roles:
            raise SystemExit(f"join 'when' references unknown trigger role {w['role']!r} "
                             f"(known: {sorted(roles)})")
        changes = [{"property": c["set"], "value": c["value"]} for c in j["then"]]
        conditions.append({
            "check": {"trigger": roles[w["role"]], "variable": w["var"], "value": w["value"]},
            "changes": changes,
        })
    return conditions


def assemble(bom):
    region = None
    triggers = {}
    subregions = []   # composed into the top-level subRegions[] array (WA-dictated)
    load = None
    roles = {}        # semantic trigger role -> allocated index
    t_index = 0

    for spec in bom["parts"]:
        part = load_part(spec["part"])
        lane = part["lane"]
        filled = apply_fills(part["template"], lane, spec.get("fills", {}))
        if lane == "region":
            if region is not None:
                raise SystemExit("more than one region part in BOM")
            region = filled
        elif lane == "trigger":
            t_index += 1
            triggers[str(t_index)] = filled
            if spec.get("role"):
                roles[spec["role"]] = t_index
        elif lane == "subregion":
            subregions.append(filled)   # order in BOM = position; sub.M is 1-based
        elif lane == "load":
            load = filled
        else:
            raise SystemExit(f"unknown lane {lane!r} on part {spec['part']!r}")

    if region is None:
        raise SystemExit("BOM has no region part")

    data = copy.deepcopy(region)
    data["id"] = bom["name"]                 # name = user-facing identity (stable per slot/item)
    # uid = the stable internal identity WA matches on to REPLACE (not spawn) on
    # re-import. The inventory owns it per slot/item and passes it through here;
    # the assembler never mints it (mint-if-absent is only a first-build fallback,
    # and that value must then be recorded back into the inventory to stay stable).
    data["uid"] = bom.get("uid") or wc.generate_unique_id()
    data["xOffset"] = bom.get("x", 0)   # position out of MVP scope
    data["yOffset"] = bom.get("y", 0)
    data["subRegions"] = subregions                     # composed from subregion parts
    data["conditions"] = build_conditions(bom, roles)   # the JOIN

    triggers["activeTriggerMode"] = -10
    if bom.get("combine"):              # trigger combination: any / all / custom
        triggers["disjunctive"] = bom["combine"]
    # numeric keys become real ints (WA's triggers dict is integer-keyed
    # alongside the string 'activeTriggerMode' - see template_filler's note).
    data["triggers"] = {(int(k) if k.isdigit() else k): v for k, v in triggers.items()}

    if load is not None:
        data["load"] = load

    # authored meta (OURS, never inherited): version + description come from the
    # inventory/BOM, not a harvested pack. Foreign meta (url/wagoID/source/semver)
    # is deliberately absent - WA sets `source` itself on import.
    data["version"] = bom.get("version", 1)
    if bom.get("desc") is not None:
        data["desc"] = bom["desc"]

    return data


# ---- blank-slate completeness check (the positive verifier) -------------------
# Lane-aware, because the index is a complete field enumeration only for some lanes:
#   trigger/load/subregion -> STRICT allowlist (index-complete; where unit/use_never hid)
#   region base            -> PROVENANCE denylist (index omits shared/skinning display
#                             fields, so we can't strict-allowlist; we catch the known
#                             foreign meta instead - the actual leak class there).
_PROVENANCE = {"url", "wagoID", "source", "semver"}   # foreign identity - never ours


def _parts_by_lane(bom, lane):
    return [load_part(s["part"]) for s in bom["parts"] if load_part(s["part"])["lane"] == lane]


def residue_of(data, bom):
    res = set()
    # region base (top-level): denylist
    res |= set(data.keys()) & _PROVENANCE
    # triggers: strict allowlist, matched to their part in BOM order
    tparts = _parts_by_lane(bom, "trigger")
    for i, tk in enumerate(sorted(k for k in data.get("triggers", {}) if isinstance(k, int))):
        core = data["triggers"][tk].get("trigger", {})
        allow = set(tparts[i]["allow"]) if i < len(tparts) else set()
        res |= {f"triggers[{tk}].{k}" for k in core if k not in allow}
    # subRegions: strict allowlist, matched in order
    sparts = _parts_by_lane(bom, "subregion")
    for i, s in enumerate(data.get("subRegions", [])):
        allow = set(sparts[i]["allow"]) if i < len(sparts) else set()
        res |= {f"subRegions[{i}].{k}" for k in s if k not in allow}
    # load: strict allowlist
    lparts = _parts_by_lane(bom, "load")
    if lparts and isinstance(data.get("load"), dict):
        allow = set(lparts[0]["allow"])
        res |= {f"load.{k}" for k in data["load"] if k not in allow}
    return sorted(res)


def _roundtrip_ok(data):
    """encode -> decode -> encode; the two strings must match. Proves the table
    is codec-stable before we ship it."""
    s1 = wc.encode_import_string(data)
    back = wc.decode_import_string(s1)
    s2 = wc.encode_import_string(back)
    return s1, (s1 == s2)


def main():
    if len(sys.argv) < 2:
        raise SystemExit("usage: py assemble.py <bom.json>")
    bom = json.load(open(sys.argv[1], encoding="utf-8"))
    data = assemble(bom)

    residue = residue_of(data, bom)
    import_string, stable = _roundtrip_ok(data)
    print(f"assembled {bom['name']!r}")
    print(f"  blank-slate check: {'CLEAN' if not residue else 'RESIDUE ' + str(residue)}")
    if residue:
        raise SystemExit(f"ABORT: {len(residue)} field(s) outside the index allowlist - "
                         f"residue leak, not shipping: {residue}")
    print(f"  triggers: {sorted(k for k in data['triggers'] if isinstance(k, int))}"
          f"  disjunctive={data['triggers'].get('disjunctive')}"
          f"  load.use_class={data.get('load', {}).get('use_class')}")
    for c in data["conditions"]:
        print(f"  condition: check={c['check']} -> {[(x['property'], x['value']) for x in c['changes']]}")
    print(f"  codec round-trip stable: {stable}")
    if not stable:
        raise SystemExit("ABORT: table is not codec-stable - assembler bug, not shipping")

    os.makedirs(OUT, exist_ok=True)
    base = os.path.splitext(os.path.basename(sys.argv[1]))[0].replace(".bom", "")
    table_path = os.path.join(OUT, base + ".table.json")
    import_path = os.path.join(OUT, base + ".import.txt")
    with open(table_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=1, ensure_ascii=False)
        f.write("\n")
    with open(import_path, "w", encoding="utf-8") as f:
        f.write(import_string + "\n")
    print(f"  wrote {os.path.relpath(table_path, _WEAKAURAS)}")
    print(f"  wrote {os.path.relpath(import_path, _WEAKAURAS)}")


if __name__ == "__main__":
    main()
