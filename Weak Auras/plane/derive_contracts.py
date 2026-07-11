"""
derive_contracts.py - INDEX-DRIVEN part derivation. The WA index (via index_schema)
is the schema authority: it defines, per namespace, the legitimate stored-field
allowlist and the typed fillable slot surface. A part is a blank slate BY
CONSTRUCTION - residue outside the allowlist never enters, rather than being scrubbed
out after the fact.

Three tiers of field (see also [[blank-slate-parts-and-diff-blindness]]):
  * residue          - not in the index allowlist -> DROPPED (unit, use_never, the
                       foreign wago/author meta, cross-type UI leftovers).
  * content-identity - what the part points AT (spellName/realSpellName/class.single)
                       -> BLANKED; this is the content the class inventory supplies.
  * config default   - how it tracks/displays (genericShowOn/track/use_showgcd) ->
                       KEPT from the modal real instance as a working default, and
                       exposed as a typed slot the inventory may override.

Modal instance supplies byte-real REPRESENTATION for kept fields; the index supplies
the SCHEMA (allowlist + slots). Emits parts/*.json =
  { part_id, lane, namespace, allow:[stored-field allowlist], holes:[typed slots],
    template: <blank-slate instance> }

    py derive_contracts.py
"""
import copy
import json
import os
from collections import Counter

import index_schema as ix

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)
_ROOT = os.path.dirname(_WA)
REF = os.path.join(_WA, "ingest", "reference")
CORPUS = os.path.join(_ROOT, "Outputs", "aura_corpus", "battlewrath_displays.json")
PARTS = os.path.join(_THIS, "parts")

# what a part points AT - blanked so only the inventory supplies content.
_CONTENT = {"spellName", "realSpellName", "spellId", "spellIds", "names", "itemName",
            "itemId", "auranames", "auraspellids"}
# aura skeleton the region BASE legitimately carries (lanes re-added by the assembler
# are stripped separately). Not indexed, but structural - preserved past the meta drop.
_REGION_SKELETON = {"regionType", "internalVersion", "tocversion", "config",
                    "authorOptions", "actions", "animation", "id", "uid"}
_LANE_STRIP = {"triggers", "conditions", "load", "subRegions", "xOffset", "yOffset",
               "parent", "controlledChildren", "sortHybridTable", "preferToUpdate",
               "icon", "displayIcon"}


def pool():
    out = []
    for f in sorted(os.listdir(REF)):
        if not f.endswith(".json") or f.startswith("Retail_"):
            continue
        rec = json.load(open(os.path.join(REF, f), encoding="utf-8"))
        if rec.get("provenance", {}).get("origin") == "retail":
            continue
        out.append(rec.get("root"))
        out += rec.get("children", [])
    if os.path.exists(CORPUS):
        out += list(json.load(open(CORPUS, encoding="utf-8")).values())
    return [n for n in out if isinstance(n, dict)]


def _modal(instances):
    """The most common WHOLE instance - a coherent real config, not a per-field
    frankenstein. Supplies byte-real representation for kept fields."""
    return json.loads(Counter(json.dumps(i, sort_keys=True) for i in instances).most_common(1)[0][0])


def _blank(v):
    return "" if isinstance(v, (str, int, float)) and not isinstance(v, bool) else v


def _apply_allowlist(inst, allow):
    return {k: v for k, v in inst.items() if k in allow}


def _blank_content(core):
    for k in list(core):
        if k in _CONTENT:
            core[k] = _blank(core[k])
    return core


def _triggers_of(node, event):
    trg = node.get("triggers", {})
    tl = list(trg.values()) if isinstance(trg, dict) else (trg or [])
    return [t["trigger"] for t in tl if isinstance(t, dict)
            and isinstance(t.get("trigger"), dict) and t["trigger"].get("event") == event]


def emit(part):
    tf = part.pop("_tf", [])
    with open(os.path.join(PARTS, part["part_id"] + ".json"), "w", encoding="utf-8") as f:
        json.dump(part, f, indent=1, ensure_ascii=False)
        f.write("\n")
    print(f"  {part['part_id']:26} lane={part['lane']:9} allow({len(part['allow'])}) "
          f"slots({len(part['holes'])}) tmpl-fields({len(tf)})")


def main():
    idx = ix.load_index()
    nodes = pool()
    os.makedirs(PARTS, exist_ok=True)

    # --- triggers: index namespace is complete & authoritative -> strict allowlist ---
    for event, pid in (("Cooldown Progress (Spell)", "trigger.cooldown"),
                       ("Action Usable", "trigger.availability"),
                       ("Power", "trigger.power")):
        insts = [tr for a in nodes for tr in _triggers_of(a, event)]
        if not insts:
            continue
        allow, slots = ix.trigger_schema(idx, event)
        core = _blank_content(_apply_allowlist(_modal(insts), allow))
        emit({"part_id": pid, "lane": "trigger", "namespace": event,
              "allow": sorted(allow), "holes": slots,
              "template": {"trigger": core, "untrigger": {}}, "_tf": list(core)})

    # --- subregions ---
    for st in ("subbackground", "subborder", "subtext", "subglow", "subforeground"):
        insts = [s for a in nodes for s in (a.get("subRegions") or [])
                 if isinstance(s, dict) and s.get("type") == st]
        if not insts:
            continue
        # subbackground/subforeground aren't index namespaces; fall back to observed keys
        allow, slots = ix.subregion_schema(idx, st)
        if len(allow) <= 1:                     # not an indexed subregion namespace
            modal = _modal(insts)
            allow = set(modal.keys())
            slots = [{"name": k} for k in modal if k != "type"]
        tmpl = _apply_allowlist(_modal(insts), allow)
        emit({"part_id": f"subregion.{st}", "lane": "subregion", "namespace": st,
              "allow": sorted(allow), "holes": [s for s in slots if s.get("name") != "type"],
              "template": tmpl, "_tf": list(tmpl)})

    # --- load parts: explicit purpose-subset of the load vocabulary ---
    for pid, levers in (("load.by_class", ["class"]),):
        insts = [a["load"] for a in nodes if isinstance(a.get("load"), dict)
                 and all(a["load"].get("use_" + n) for n in levers)]
        if not insts:
            continue
        allow, slots = ix.load_slots(idx, levers)
        tmpl = _apply_allowlist(_modal(insts), allow)
        for n in levers:                        # blank the content (e.g. class.single)
            if isinstance(tmpl.get(n), dict) and "single" in tmpl[n]:
                tmpl[n]["single"] = ""
        emit({"part_id": pid, "lane": "load", "namespace": "load",
              "allow": sorted(allow) + [n for n in levers], "holes": slots,
              "template": tmpl, "_tf": list(tmpl)})

    # --- region bases: keep display fields + skeleton; drop foreign/authored meta ---
    for rt in ("icon", "aurabar"):
        insts = [a for a in nodes if a.get("regionType") == rt]
        if not insts:
            continue
        modal = _modal(insts)
        drop = ix.FOREIGN_META | ix.AUTHORED_META | _LANE_STRIP
        tmpl = {k: v for k, v in modal.items() if k not in drop}
        if "information" in tmpl:
            tmpl["information"] = {}            # reset authoring toggles (opt-in options)
        slots = ix.region_fields(idx, rt)
        field_names = {s["name"] for s in slots}
        allow = field_names | _REGION_SKELETON | {"information", "alpha"} | \
            {k for k in tmpl if k.startswith("use") or k.startswith("BF") or k in ("iconInset",)}
        emit({"part_id": f"region.{rt}", "lane": "region", "namespace": rt,
              "allow": sorted(allow), "holes": slots,
              "change_targets": ix.region_change_targets(idx, rt),
              "template": tmpl, "_tf": list(tmpl)})


if __name__ == "__main__":
    main()
