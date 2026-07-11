"""
harvest_parts.py - extract byte-real Layer-0 parts from the scraped corpus into
plane/parts/*.json. The parts are NOT hand-typed: each is pulled verbatim from a
real decoded target aura (the "Target items" set, spell 805040), with only its
hole leaves blanked to '{{...}}'. This keeps the pipeline honest - even the parts
come from real captured auras, not invention.

Sources (all from ../../Outputs/aura_corpus/battlewrath_displays.json):
  region.icon         <- Target 2 body (minus triggers/load/conditions/id/uid/position/storage)
  trigger.availability<- Target 2 trigger 1 (spellName -> {{spell_id}})
  load.by_class       <- Target 1 load block (class.single -> {{class}})

    py harvest_parts.py
"""
import copy
import json
import os

_THIS = os.path.dirname(os.path.abspath(__file__))
_WEAKAURAS = os.path.dirname(_THIS)
_ROOT = os.path.dirname(_WEAKAURAS)
CORPUS = os.path.join(_ROOT, "Outputs", "aura_corpus", "battlewrath_displays.json")
PARTS = os.path.join(_THIS, "parts")

# Fields that are NOT part of an authored icon region: the join-lanes
# (triggers/load/conditions), identity (id/uid), position (out of MVP scope,
# set by the assembler), and WeakAuras storage-only fields (WA re-derives these
# on store - see aura_scrape.py's _WA_STORAGE_ONLY).
_REGION_SKIP = {
    "triggers", "conditions", "load", "id", "uid",
    "xOffset", "yOffset",
    "subRegions",   # WA-dictated: a separate top-level array, NOT a region field -
                    # composed from separate subregion parts, not baked into the region base
    "parent", "icon", "displayIcon", "preferToUpdate",
    "controlledChildren", "sortHybridTable",
}


def _find(displays, prefix):
    ks = [k for k in displays if k.startswith(prefix)]
    if not ks:
        raise SystemExit(f"no display starting with {prefix!r}")
    return displays[ks[0]]


def main():
    displays = json.load(open(CORPUS, encoding="utf-8"))
    t2 = _find(displays, "Target 2")
    t1 = _find(displays, "Target 1")

    # region.icon - T2 body, verbatim, minus the skip set
    region = {k: v for k, v in t2.items() if k not in _REGION_SKIP}
    region_part = {"part_id": "region.icon", "lane": "region", "holes": [], "template": region}

    # trigger.availability - T2 trigger 1, spellName blanked to a hole
    trig = copy.deepcopy(t2["triggers"]["1"])
    trig["trigger"]["spellName"] = "{{spell_id}}"
    trig_part = {"part_id": "trigger.availability", "lane": "trigger", "holes": ["spell_id"], "template": trig}

    # trigger.cooldown - the "Cooldown Progress (Spell)" Target-3 aura's trigger
    # (inverse / showOnCooldown = the on-cooldown state), spellName -> hole.
    t3cd = next(v for k, v in displays.items()
                if k.startswith("Target 3") and "cooldown/charges" in k)
    trig_cd = copy.deepcopy(t3cd["triggers"]["1"])
    trig_cd["trigger"]["spellName"] = "{{spell_id}}"
    trigcd_part = {"part_id": "trigger.cooldown", "lane": "trigger", "holes": ["spell_id"], "template": trig_cd}

    # load.by_class - T1 load, class.single blanked to a hole
    load = copy.deepcopy(t1["load"])
    load["class"]["single"] = "{{class}}"
    load_part = {"part_id": "load.by_class", "lane": "load", "holes": ["class"], "template": load}

    # subregion parts - the first real instance of each recurring subregion type,
    # byte-real (no holes blanked yet; the inventory parameterizes fills later).
    # These are the SEPARATE parts the assembler distributes into subRegions[].
    seen_sub = {}
    for node in displays.values():
        for s in (node.get("subRegions") or []):
            if isinstance(s, dict) and s.get("type") and s["type"] not in seen_sub:
                seen_sub[s["type"]] = s
    sub_parts = []
    for t in ("subbackground", "subborder", "subtext", "subglow", "subforeground"):
        if t in seen_sub:
            sub_parts.append({"part_id": f"subregion.{t}", "lane": "subregion",
                              "holes": [], "template": copy.deepcopy(seen_sub[t])})

    # --- resource-bar family (palette expansion; SAME assembler) ---
    # region.aurabar - first corpus aurabar's scalar fields (base, no subRegions)
    extra = []
    bar = next((v for v in displays.values() if v.get("regionType") == "aurabar"), None)
    if bar:
        reg_bar = {k: v for k, v in bar.items() if k not in _REGION_SKIP}
        extra.append({"part_id": "region.aurabar", "lane": "region", "holes": [], "template": reg_bar})
    # trigger.power - first Power trigger; powertype blanked to a hole (Mana=0 / Runic=6 / ...)
    for node in displays.values():
        trg = node.get("triggers", {})
        tl = list(trg.values()) if isinstance(trg, dict) else (trg or [])
        pt = next((t for t in tl if isinstance(t, dict)
                   and isinstance(t.get("trigger"), dict) and t["trigger"].get("event") == "Power"), None)
        if pt:
            pt = copy.deepcopy(pt)
            pt["trigger"]["powertype"] = "{{powertype}}"
            extra.append({"part_id": "trigger.power", "lane": "trigger", "holes": ["powertype"], "template": pt})
            break

    os.makedirs(PARTS, exist_ok=True)
    for p in (region_part, trig_part, trigcd_part, load_part, *sub_parts, *extra):
        fn = os.path.join(PARTS, p["part_id"] + ".json")
        with open(fn, "w", encoding="utf-8") as f:
            json.dump(p, f, indent=1, ensure_ascii=False)
            f.write("\n")
        print(f"wrote {os.path.relpath(fn, _WEAKAURAS)}  lane={p['lane']:8s} holes={p['holes']}")


if __name__ == "__main__":
    main()
