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

    # load.by_class - T1 load, class.single blanked to a hole
    load = copy.deepcopy(t1["load"])
    load["class"]["single"] = "{{class}}"
    load_part = {"part_id": "load.by_class", "lane": "load", "holes": ["class"], "template": load}

    os.makedirs(PARTS, exist_ok=True)
    for p in (region_part, trig_part, load_part):
        fn = os.path.join(PARTS, p["part_id"] + ".json")
        with open(fn, "w", encoding="utf-8") as f:
            json.dump(p, f, indent=1, ensure_ascii=False)
            f.write("\n")
        print(f"wrote {os.path.relpath(fn, _WEAKAURAS)}  lane={p['lane']:8s} holes={p['holes']}")


if __name__ == "__main__":
    main()
