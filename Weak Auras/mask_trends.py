"""
mask_trends.py - read-only "gravity well" analysis of the live aura corpus.

Part of the read-intent -> formalize workflow (settled with Battlewrath). Live
captures are DESIGN INTENT, never authority: each slot has 'gravity' - a target
Battlewrath aims a mouse at in ~0.5px increments - so a captured xOffset is a
noisy sample sitting IN a well, not the true anchor. Because the same slot has
been hand-built across several classes/characters, those independent samples
cluster around the real well: the centroid approximates the anchor, the spread
quantifies the human drag-error to normalize away.

This tool clusters the corpus's leaf items into gravity wells and REPORTS them -
where they are, how tightly they're hit, which classes independently agree, and
composition hints (overlay = a co-located pair like backing+live; subdivide = one
class occupying wells a single-item class leaves empty). It stamps nothing as
truth; it makes the intent visible so the mask can later formalize precise,
geometry-aware anchors to normalize against.

Reads Outputs/aura_corpus/battlewrath_displays.json (from aura_scrape.py).
Writes Outputs/aura_corpus/gravity_wells.json + a printed summary. Read-only.

    py mask_trends.py [radius_px]     # default radius 8
"""
import json
import math
import os
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_ROOT = os.path.dirname(_THIS_DIR)
CORPUS = os.path.join(_PROJECT_ROOT, "Outputs", "aura_corpus", "battlewrath_displays.json")
OUT = os.path.join(_PROJECT_ROOT, "Outputs", "aura_corpus", "gravity_wells.json")
GROUP_REGIONS = {"group", "dynamicgroup"}
SUBDIVIDE_BUDGET = 70.0  # px: two wells one class occupies within this = candidate subdivide


def class_of(group):
    n = (group or "").lower()
    if "reaper" in n:
        return "reaper"
    if "necro" in n or "minion" in n or "buff index" in n or "tier 1" in n:
        return "necro"
    if group == "Resources" or "blood" in n:
        return "bloodmage"
    return group or "?"


def absolute_items(displays):
    """Leaf items in one common frame: group anchor + child offset. Dynamicgroup
    children are auto-laid-out (not hand-placed), so they're excluded from well
    clustering and only counted separately."""
    group_off, group_region = {}, {}
    for did, d in displays.items():
        if d.get("regionType") in GROUP_REGIONS:
            group_off[did] = (d.get("xOffset", 0) or 0, d.get("yOffset", 0) or 0)
            group_region[did] = d.get("regionType")
    items, dynamic = [], 0
    for did, d in displays.items():
        rt = d.get("regionType")
        if rt in GROUP_REGIONS:
            continue
        parent = d.get("parent")
        if group_region.get(parent) == "dynamicgroup":
            dynamic += 1
            continue
        gx, gy = group_off.get(parent, (0, 0))
        items.append({
            "id": did, "group": parent, "class": class_of(parent),
            "x": gx + (d.get("xOffset", 0) or 0), "y": gy + (d.get("yOffset", 0) or 0),
            "w": d.get("width"), "h": d.get("height"), "region": rt,
        })
    return items, dynamic


def cluster(items, radius):
    wells = []
    for it in items:
        best, bestd = None, None
        for w in wells:
            cx = sum(m["x"] for m in w) / len(w)
            cy = sum(m["y"] for m in w) / len(w)
            d = math.hypot(cx - it["x"], cy - it["y"])
            if d <= radius and (bestd is None or d < bestd):
                best, bestd = w, d
        if best is None:
            wells.append([it])
        else:
            best.append(it)
    return wells


def summarize(w):
    cx = round(sum(m["x"] for m in w) / len(w), 3)
    cy = round(sum(m["y"] for m in w) / len(w), 3)
    spread = round(max(math.hypot(m["x"] - cx, m["y"] - cy) for m in w), 3)
    dims = sorted({(m["w"], m["h"]) for m in w})
    regions = sorted({m["region"] for m in w})
    # per-group occupancy: >1 member from one group at the same well = overlay
    by_group = {}
    for m in w:
        by_group.setdefault(m["group"], []).append(m["id"])
    classes = sorted({m["class"] for m in w})
    overlay = {g: ids for g, ids in by_group.items() if len(ids) > 1}
    return {
        "anchor": [cx, cy], "spread": spread,
        "dims": [list(d) for d in dims], "regions": regions,
        "classes": classes, "n_classes": len(classes),
        "members": [{"id": m["id"], "group": m["group"], "pos": [round(m["x"], 2), round(m["y"], 2)]} for m in w],
        "overlay": overlay,
    }


def subdivide_candidates(wells_s):
    """A class occupying two wells within one budget, where a different class has
    only one well nearby, is a candidate subdivide (Reaper-2 / Scarletta-1)."""
    cands = []
    # class -> list of well anchors
    by_class = {}
    for wi, w in enumerate(wells_s):
        for c in w["classes"]:
            by_class.setdefault(c, []).append((wi, tuple(w["anchor"])))
    for c, wl in by_class.items():
        for i in range(len(wl)):
            for j in range(i + 1, len(wl)):
                (ai, pa), (bi, pb) = wl[i], wl[j]
                dist = math.hypot(pa[0] - pb[0], pa[1] - pb[1])
                if dist <= SUBDIVIDE_BUDGET:
                    # is there a class present at exactly one of the two wells?
                    ca, cb = set(wells_s[ai]["classes"]), set(wells_s[bi]["classes"])
                    single_side = (ca - {c}) ^ (cb - {c})
                    if single_side:
                        cands.append({
                            "subdivider": c, "dist": round(dist, 1),
                            "wells": [pa, pb],
                            "single_item_classes": sorted(single_side),
                        })
    return cands


def main():
    radius = float(sys.argv[1]) if len(sys.argv) > 1 else 8.0
    if not os.path.exists(CORPUS):
        raise SystemExit(f"corpus not found: {CORPUS} (run aura_scrape.py first)")
    displays = json.load(open(CORPUS, encoding="utf-8"))
    items, dynamic = absolute_items(displays)
    wells = cluster(items, radius)
    wells_s = sorted((summarize(w) for w in wells), key=lambda s: (-s["anchor"][1], s["anchor"][0]))
    cands = subdivide_candidates(wells_s)

    print(f"gravity wells from {len(items)} hand-placed leaf items "
          f"({dynamic} dynamicgroup items excluded), radius {radius}px\n")
    print(f"{'anchor (x,y)':>18} {'spread':>7} {'dims':>10} {'reg':>8} {'cls':>4}  occupancy")
    for s in wells_s:
        dims = "/".join(f"{int(d[0])}x{int(d[1])}" if d[0] else "?" for d in s["dims"])
        tag = []
        if s["overlay"]:
            tag.append("OVERLAY")
        if s["n_classes"] > 1:
            tag.append(f"{s['n_classes']}-class")
        occ = ", ".join(f"{m['group']}:{m['id']}" for m in s["members"])
        print(f"{str(s['anchor']):>18} {s['spread']:>7} {dims:>10} "
              f"{'/'.join(s['regions']):>8} {s['n_classes']:>4}  {' '.join(tag)} {occ[:70]}")

    print(f"\nspread stats: max {max((s['spread'] for s in wells_s), default=0):.3f}px  "
          f"(if small, hand-drag noise normalizes cleanly to computed anchors)")

    print(f"\nsubdivide candidates ({len(cands)}): one class filling a budget two "
          f"other classes fill with one")
    for c in cands[:20]:
        print(f"  {c['subdivider']} splits {c['wells'][0]} + {c['wells'][1]} "
              f"(gap {c['dist']}px); single-item: {c['single_item_classes']}")

    with open(OUT, "w", encoding="utf-8") as f:
        json.dump({"radius": radius, "n_items": len(items), "dynamic_excluded": dynamic,
                   "wells": wells_s, "subdivide_candidates": cands}, f, indent=1, ensure_ascii=False)
        f.write("\n")
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()
