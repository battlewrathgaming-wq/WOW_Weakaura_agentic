#!/usr/bin/env python3
"""
space_audit.py - numeric gap/space inventory for a decoded Template_shadow
version, built for the agent's own reasoning, not as a user-facing report.

WHY THIS EXISTS
---------------
Every version this session, gap questions got answered one at a time, by
hand, whenever a specific comparison came up (Proc's span, the footer's
span, the bar's width). That ad hoc approach is exactly why the same
mismatch (bar vs. footer, bar vs. Proc/Rotation) kept resurfacing as a
"surprise" each version instead of being visible up front. This tool
produces the full inventory once, for any version, so every gap can be
checked against HUD_DESIGN.md's compactness rule in one pass instead of
being rediscovered piecemeal.

WHAT IT COMPUTES
----------------
1. Per-element inventory: id, tier, center x/y, width/height, and the four
   edges (left/right/top/bottom) derived from those.
2. Rows: elements grouped by shared y (same row), sorted left to right.
3. Within-row gaps: edge-to-edge gap between adjacent elements in the same
   row.
4. Row-to-row vertical gaps: edge-to-edge gap between one row's nearest
   edge and the next row's nearest edge, in y-order.
5. Row spans: each row's own total left/right extent (its own outer
   edges), so cross-row comparisons (e.g. "does this row's width match
   that one") are explicit rather than re-derived by hand each time.
6. Flags: any within-row or row-to-row gap that exceeds ~10% of the
   smaller adjacent element's relevant dimension - HUD_DESIGN.md's own
   stated red-flag threshold from the "Compactness and cohesive spacing"
   rule - gets flagged for review rather than silently accepted.

USAGE
-----
    import space_audit as audit
    report = audit.build_report(children)   # children = decoded child list
    audit.print_report(report)
"""

from __future__ import annotations

from typing import Dict, List


def _tier_of(element_id: str) -> str:
    for prefix in ("Tier 1", "Tier 2", "Tier 3", "Tier 4", "Tier 5"):
        if element_id.startswith(prefix):
            return prefix
    return "Resource"  # Mana / Placeholder resouce


def build_inventory(children: List[dict]) -> List[dict]:
    inventory = []
    for c in children:
        w = c.get("width", 0)
        h = c.get("height", 0)
        x = c.get("xOffset", 0)
        y = c.get("yOffset", 0)
        inventory.append({
            "id": c["id"],
            "tier": _tier_of(c["id"]),
            "x": x, "y": y, "width": w, "height": h,
            "left": x - w / 2, "right": x + w / 2,
            "top": y + h / 2, "bottom": y - h / 2,  # y decreases downward
        })
    return inventory


def group_rows(inventory: List[dict]) -> Dict[float, List[dict]]:
    rows: Dict[float, List[dict]] = {}
    for el in inventory:
        rows.setdefault(el["y"], []).append(el)
    for y in rows:
        rows[y].sort(key=lambda e: e["x"])
    return rows


def within_row_gaps(rows: Dict[float, List[dict]]) -> List[dict]:
    gaps = []
    for y, row in sorted(rows.items(), reverse=True):
        for a, b in zip(row, row[1:]):
            gap = b["left"] - a["right"]
            gaps.append({
                "row_y": y, "between": (a["id"], b["id"]), "gap": gap,
                "ref_size": min(a["width"], b["width"]),
            })
    return gaps


def row_to_row_gaps(rows: Dict[float, List[dict]]) -> List[dict]:
    ys = sorted(rows.keys(), reverse=True)  # top to bottom (most positive y first)
    results = []
    for y_top, y_bot in zip(ys, ys[1:]):
        top_row = rows[y_top]
        bot_row = rows[y_bot]
        top_bottom_edge = max(e["bottom"] for e in top_row)  # least-negative bottom
        bot_top_edge = max(e["top"] for e in bot_row)
        gap = top_bottom_edge - bot_top_edge
        ref_size = min(
            min(e["height"] for e in top_row),
            min(e["height"] for e in bot_row),
        )
        results.append({
            "between_y": (y_top, y_bot), "gap": gap, "ref_size": ref_size,
        })
    return results


def row_spans(rows: Dict[float, List[dict]]) -> List[dict]:
    spans = []
    for y, row in sorted(rows.items(), reverse=True):
        left = min(e["left"] for e in row)
        right = max(e["right"] for e in row)
        spans.append({
            "row_y": y, "tiers": sorted(set(e["tier"] for e in row)),
            "left": left, "right": right, "span": right - left,
        })
    return spans


FLAG_THRESHOLD_PCT = 0.10  # HUD_DESIGN.md: >10% of element size is a red flag


def build_report(children: List[dict]) -> dict:
    inventory = build_inventory(children)
    rows = group_rows(inventory)
    wgaps = within_row_gaps(rows)
    rgaps = row_to_row_gaps(rows)
    spans = row_spans(rows)

    flagged = []
    for g in wgaps:
        if g["ref_size"] and g["gap"] / g["ref_size"] > FLAG_THRESHOLD_PCT:
            flagged.append(("within-row", g["between"], g["gap"], g["ref_size"]))
    for g in rgaps:
        if g["ref_size"] and g["gap"] / g["ref_size"] > FLAG_THRESHOLD_PCT:
            flagged.append(("row-to-row", g["between_y"], g["gap"], g["ref_size"]))

    return {
        "inventory": inventory, "rows": rows,
        "within_row_gaps": wgaps, "row_to_row_gaps": rgaps,
        "row_spans": spans, "flagged": flagged,
    }


def print_report(report: dict) -> None:
    print("=== Row spans (widest left/right extent per row) ===")
    for s in report["row_spans"]:
        print(f"  y={s['row_y']:8.2f}  tiers={s['tiers']}  "
              f"left={s['left']:8.2f} right={s['right']:8.2f} span={s['span']:7.2f}")

    print("\n=== Within-row gaps (icon-to-icon, edge-to-edge) ===")
    for g in report["within_row_gaps"]:
        pct = (g["gap"] / g["ref_size"] * 100) if g["ref_size"] else 0
        flag = "  <-- FLAG (>10%)" if pct > FLAG_THRESHOLD_PCT * 100 else ""
        print(f"  y={g['row_y']:8.2f}  {g['between'][0]!r:32s} -> {g['between'][1]!r:32s} "
              f"gap={g['gap']:6.2f} ({pct:5.1f}% of {g['ref_size']:.0f}px){flag}")

    print("\n=== Row-to-row vertical gaps ===")
    for g in report["row_to_row_gaps"]:
        pct = (g["gap"] / g["ref_size"] * 100) if g["ref_size"] else 0
        flag = "  <-- FLAG (>10%)" if pct > FLAG_THRESHOLD_PCT * 100 else ""
        print(f"  y {g['between_y'][0]:8.2f} -> {g['between_y'][1]:8.2f}  "
              f"gap={g['gap']:6.2f} ({pct:5.1f}% of {g['ref_size']:.0f}px){flag}")

    print("\n=== Cross-row span comparison (the actual dead-air source) ===")
    spans = report["row_spans"]
    widest = max(s["span"] for s in spans)
    for s in spans:
        slack = widest - s["span"]
        print(f"  y={s['row_y']:8.2f}  span={s['span']:7.2f}  "
              f"slack-vs-widest-row={slack:7.2f}")

    if report["flagged"]:
        print(f"\n{len(report['flagged'])} gap(s) exceed the 10%-of-size threshold - "
              f"these are the ones to look at first for tightening.")
    else:
        print("\nNo within-row or row-to-row gaps exceed the 10% threshold.")
