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


def substitute(node, fills):
    """Replace any leaf that is entirely '{{key}}' with fills[key]; recurse."""
    if isinstance(node, dict):
        return {k: substitute(v, fills) for k, v in node.items()}
    if isinstance(node, list):
        return [substitute(v, fills) for v in node]
    if isinstance(node, str):
        m = _PLACEHOLDER.match(node)
        if m:
            key = m.group(1)
            if key not in fills:
                raise SystemExit(f"unfilled hole {{{{{key}}}}} - BOM provided no value")
            return fills[key]
    return node


def assemble(bom):
    region = None
    triggers = {}
    load = None
    t_index = 0

    for spec in bom["parts"]:
        part = load_part(spec["part"])
        filled = substitute(copy.deepcopy(part["template"]), spec.get("fills", {}))
        lane = part["lane"]
        if lane == "region":
            if region is not None:
                raise SystemExit("more than one region part in BOM")
            region = filled
        elif lane == "trigger":
            t_index += 1
            triggers[str(t_index)] = filled
        elif lane == "load":
            load = filled
        else:
            raise SystemExit(f"unknown lane {lane!r} on part {spec['part']!r}")

    if region is None:
        raise SystemExit("BOM has no region part")

    data = copy.deepcopy(region)
    data["id"] = bom["name"]
    data["uid"] = wc.generate_unique_id()
    data["xOffset"] = bom.get("x", 0)   # position out of MVP scope
    data["yOffset"] = bom.get("y", 0)
    data["conditions"] = []             # none for this target; codec treats []=={}

    triggers["activeTriggerMode"] = -10
    # numeric keys become real ints (WA's triggers dict is integer-keyed
    # alongside the string 'activeTriggerMode' - see template_filler's note).
    data["triggers"] = {(int(k) if k.isdigit() else k): v for k, v in triggers.items()}

    if load is not None:
        data["load"] = load

    return data


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

    import_string, stable = _roundtrip_ok(data)
    print(f"assembled {bom['name']!r}")
    print(f"  triggers: {sorted(k for k in data['triggers'] if isinstance(k, int))}"
          f"  load.use_class={data.get('load', {}).get('use_class')}"
          f"  conditions={data['conditions']}")
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
