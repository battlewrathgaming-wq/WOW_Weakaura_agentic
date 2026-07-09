"""
aura_blocks.py - decompose the live corpus onto WeakAuras' NATIVE stack
(Layer 0) and emit an ID'd block inventory: every region / trigger / subregion /
condition / load primitive actually in use, with a stable block-ID, its
field-shape, and a usage count.

Foundation for the content-addressable build system (settled with Battlewrath):
an aura IS a stack of ID'd blocks; meaning is the stack's shape; the assembler
addresses blocks by ID and allocates WA's own indices (triggers[1/2], condition
order) - that allocation is the joining layer, so no block hardcodes an index.

Layer 0 is WeakAuras' OWN ontology, not our meaning - "backing plate" is a
Layer-1 composition, not a native block. Two sources of truth agree: the WA
addon source (the SPEC of what's possible) and this corpus (what's actually
USED). This pass does the corpus/usage side; reconcile with
CAPABILITY_INVENTORY.md (the source spec) as the next step.

Read-only. Reads the corpus, writes Outputs/aura_corpus/native_blocks.json.
    py aura_blocks.py
"""
import json
import os
import re
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_ROOT = os.path.dirname(_THIS_DIR)
CORPUS = os.path.join(_PROJECT_ROOT, "Outputs", "aura_corpus", "battlewrath_displays.json")
OUT = os.path.join(_PROJECT_ROOT, "Outputs", "aura_corpus", "native_blocks.json")


def _slug(s):
    return re.sub(r"[^a-z0-9]+", "_", str(s).lower()).strip("_")


def _bump(table, block_id, fields=None):
    e = table.setdefault(block_id, {"count": 0, "fields": set()})
    e["count"] += 1
    if fields:
        e["fields"].update(fields)


def _trigger_slots(trg):
    """Return ([(key, trigger_entry), ...], meta) from triggers stored as either
    a list (single trigger) or a dict (multi + disjunctive/activeTriggerMode)."""
    slots, meta = [], {}
    if isinstance(trg, list):
        for i, v in enumerate(trg, 1):
            if isinstance(v, dict) and "trigger" in v:
                slots.append((str(i), v))
    elif isinstance(trg, dict):
        for k, v in trg.items():
            if isinstance(v, dict) and "trigger" in v:
                slots.append((str(k), v))
            elif k in ("disjunctive", "activeTriggerMode"):
                meta[k] = v
    return slots, meta


def decompose(displays):
    regions, triggers, subregions, conditions, load = {}, {}, {}, {}, {}
    trig_count_hist, disjunctive, active_mode = {}, {}, {}

    for a in displays.values():
        rt = a.get("regionType", "?")
        _bump(regions, f"region.{_slug(rt)}")

        # triggers is a plain list for a single trigger, or a dict (with
        # disjunctive/activeTriggerMode meta) for multi-trigger.
        slots, meta = _trigger_slots(a.get("triggers"))
        for _, v in slots:
            t = v.get("trigger", {})
            bid = f"trigger.{_slug(t.get('type', '?'))}.{_slug(t.get('event', '?'))}"
            _bump(triggers, bid, fields=[k for k in t.keys() if k not in ("type", "event")])
        trig_count_hist[len(slots)] = trig_count_hist.get(len(slots), 0) + 1
        if "disjunctive" in meta:
            disjunctive[meta["disjunctive"]] = disjunctive.get(meta["disjunctive"], 0) + 1
        if "activeTriggerMode" in meta:
            m = meta["activeTriggerMode"]
            active_mode[m] = active_mode.get(m, 0) + 1

        for s in (a.get("subRegions") or []):
            if isinstance(s, dict):
                _bump(subregions, f"subregion.{_slug(s.get('type', '?'))}")

        for c in (a.get("conditions") or []):
            if not isinstance(c, dict):
                continue
            for ch in (c.get("changes") or []):
                if isinstance(ch, dict) and ch.get("property"):
                    _bump(conditions, f"condition.{_slug(ch['property'])}")

        for key in (a.get("load") or {}):
            if not key.startswith("use_"):  # companion gate keys, not primitives
                _bump(load, f"load.{_slug(key)}")

    return {"regions": regions, "triggers": triggers, "subregions": subregions,
            "conditions": conditions, "load": load,
            "composition_meta": {
                "trigger_count_distribution": dict(sorted(trig_count_hist.items())),
                "disjunctive": disjunctive, "activeTriggerMode": active_mode}}


def _finalize(table):
    """sets -> sorted lists, sorted by descending usage."""
    out = {}
    for bid in sorted(table, key=lambda b: (-table[b]["count"], b)):
        e = table[bid]
        out[bid] = {"count": e["count"], "fields": sorted(e["fields"])}
    return out


def main():
    if not os.path.exists(CORPUS):
        raise SystemExit(f"corpus not found: {CORPUS} (run aura_scrape.py first)")
    displays = json.load(open(CORPUS, encoding="utf-8"))
    d = decompose(displays)

    print(f"Layer-0 native block inventory (from {len(displays)} live auras)\n")
    for kind in ("regions", "triggers", "subregions", "conditions", "load"):
        tbl = _finalize(d[kind])
        d[kind] = tbl
        print(f"== {kind} ({len(tbl)} distinct blocks) ==")
        for bid, e in tbl.items():
            fld = f"  fields: {e['fields'][:6]}{'…' if len(e['fields']) > 6 else ''}" if e["fields"] else ""
            print(f"  {bid:34s} x{e['count']}{fld}")
        print()
    print("== composition meta ==")
    print(f"  trigger-count per aura: {d['composition_meta']['trigger_count_distribution']}")
    print(f"  disjunctive: {d['composition_meta']['disjunctive']}  "
          f"activeTriggerMode: {d['composition_meta']['activeTriggerMode']}")

    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(d, f, indent=1, ensure_ascii=False)
        f.write("\n")
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()
