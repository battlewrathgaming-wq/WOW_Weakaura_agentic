"""
mask_build.py - build the Central_hud mask as a RELATIONAL MATRIX: the whole
layout computed from a handful of declared relationships (a column grid + two
edge-aligned bands), not 37 frozen anchors. Change one primitive (icon gap,
band edge) and every dependent position follows; shared edges hold by
construction and are asserted, not hoped for.

Replaces the Template_shadow derivation (discarded). Authority: geometry-aware
computation via geometry.py primitives; live captures (gravity wells) VALIDATE,
never define.

THE DECLARED RELATIONSHIPS (scheme A, normalized 2026-07 - integers, band edge
on a 5-grid, chosen with Battlewrath over the old .5 values):
  - icon column grid: 6x 40-wide, 2px gap -> ±21/±63/±105 (row_x_offsets).
  - INNER band edge = the icon row's own outer edge = ±125. The resource bars
    and every 40-wide icon row (rotation/power/proc) share it.
  - OUTER band edge = ±185. Accents and buffs/utility share it.
  - resource bars: two columns sharing the INNER band, clearing a 2px center
    divider -> 124x15 @ ±63 (their centre lands ON the inner icon column, by
    construction, not coincidence).
  - accents BRIDGE the two bands: width = OUTER-INNER = 60, centre = midpoint
    = ±155.
  - buffs/utility flank to the OUTER band: 30-wide, outer column @ ±170,
    inner @ ±140.

SIZE-BY-THROUGHPUT (settled with Battlewrath): rotation 40x30 (tall exception,
constant attention), power/proc 40x20 (high frequency), buffs/utility 30x20
(tucked, low throughput). Resource bars 124x15.

Composition: single | subdivide (2D budget-fill; Reaper tiles the primary-
resource budget where Necro/Bloodmage use one bar). Backing plates are an
inventory/strata concern, not here.

    py mask_build.py
"""
import json
import os
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_ROOT = os.path.dirname(_THIS_DIR)
sys.path.insert(0, _THIS_DIR)
import geometry as geo

MASKS_DIR = os.path.join(_THIS_DIR, "masks")
WELLS = os.path.join(_PROJECT_ROOT, "Outputs", "aura_corpus", "gravity_wells.json")

# ============================================================================
# RELATIONAL PRIMITIVES - change these, everything below recomputes.
# ============================================================================
ICON_W, ICON_H_TALL, ICON_H_SHORT = 40, 30, 20
ICON_GAP = 2                                   # scheme A
PLATEAU = 2                                    # divider width = the plateau knob (see below)
BUFF_W, BUFF_H = 30, 20
ACCENT_H = 30
OUTER_BAND = 185                               # declared outer boundary

# derived, by construction
COLS = geo.row_x_offsets(6, ICON_W, ICON_GAP)          # [-105,-63,-21,21,63,105]
INNER_BAND = abs(COLS[-1]) + ICON_W / 2                 # 125 = icon row outer edge

# PLATEAU affordance: the central divider sits at absolute 0; its width IS the
# knob. It displaces the left column (resources) PLATEAU/2 left and the right
# column (cast/swing) PLATEAU/2 right - flat, symmetric by construction. The
# bars keep a fixed width, so a wider plateau pushes the resource shelf PAST the
# ±125 icon band -> a central plateau, the UI's non-rectangular easement.
# PLATEAU must be a whole number (so PLATEAU/2 stays on the 0.5 grid: 5->2.5 ok,
# 2.3->1.15 not). PLATEAU=2 = today's flush divider (shelf flush with icon band).
assert float(PLATEAU).is_integer(), "PLATEAU must be a whole number (÷2 must stay on the 0.5 grid)"
DIVIDER_W = PLATEAU
HALF_P = PLATEAU / 2                                      # per-side offset, on the 0.5 grid
RES_W = INNER_BAND - 1                                    # 124 = width where P=2 is flush
RES_INNER = HALF_P                                        # bar inner edge = divider half-width
RES_CX = HALF_P + RES_W / 2                               # bar centre
RES_OUTER = HALF_P + RES_W                                # bar outer edge
PLATEAU_JUT = RES_OUTER - INNER_BAND                      # how far the shelf juts past the icon band

ACCENT_W = OUTER_BAND - INNER_BAND                       # 60 (bridges the bands)
ACCENT_CX = (INNER_BAND + OUTER_BAND) / 2                # 155
BUFF_OUTER = OUTER_BAND - BUFF_W / 2                      # 170
BUFF_INNER = BUFF_OUTER - BUFF_W                          # 140

# vertical bands (developed design; y-normalization is a separate question)
Y_PROC, Y_ROT, Y_POWER = -105, -130, -190
Y_RES_TOP, Y_RES_BOT, Y_MID = -152.5, -167.5, -160
Y_BUFF, Y_BUFF_R2, Y_BUFF_R3 = -185, -205, -225


def _verify():
    """Shared edges hold BY CONSTRUCTION - assert, don't hope."""
    icon_edge = abs(COLS[-1]) + ICON_W / 2
    assert abs(icon_edge - INNER_BAND) < 1e-9, "icon row != inner band"
    assert abs(RES_INNER - DIVIDER_W / 2) < 1e-9, "resource inner edge != divider half-width"
    assert abs(RES_OUTER - (RES_CX + RES_W / 2)) < 1e-9, "resource outer edge inconsistent"
    accent_edge = ACCENT_CX + ACCENT_W / 2
    buff_edge = BUFF_OUTER + BUFF_W / 2
    assert abs(accent_edge - OUTER_BAND) < 1e-9, "accent != outer band"
    assert abs(buff_edge - OUTER_BAND) < 1e-9, "buff != outer band"
    return {"inner_band": INNER_BAND, "outer_band": OUTER_BAND, "icon_columns": COLS,
            "plateau": PLATEAU, "resource_centre": RES_CX, "resource_outer_edge": RES_OUTER,
            "plateau_juts_past_icon_band_by": PLATEAU_JUT,
            "accent_bridges_bands": [INNER_BAND, OUTER_BAND]}


def fam(anchor, w, h, region, composition, provenance, **extra):
    d = {"anchor": [round(anchor[0], 3), round(anchor[1], 3)],
         "budget": {"w": round(w, 3), "h": h}, "region": region,
         "composition": composition, "provenance": provenance}
    d.update(extra)
    return d


def build_families():
    F = {}
    span = [round(-RES_OUTER, 3), round(-RES_INNER, 3)]  # left resource-column envelope (plateau-aware)
    F["resource.primary"] = fam((-RES_CX, Y_RES_TOP), RES_W, 15, "aurabar",
                                ["single", "subdivide"], "live", subdivide={"axis": "x", "span": span})
    F["resource.secondary"] = fam((-RES_CX, Y_RES_BOT), RES_W, 15, "aurabar",
                                  ["single", "subdivide"], "live", subdivide={"axis": "x", "span": span})
    F["cast_bar"] = fam((RES_CX, Y_RES_TOP), RES_W, 15, "aurabar", ["single"], "live")
    F["swing_timer"] = fam((RES_CX, Y_RES_BOT), RES_W, 15, "aurabar", ["single"], "live")
    F["divider"] = fam((0, Y_MID), DIVIDER_W, 30, "aurabar", ["single"], "live")
    F["accent.left"] = fam((-ACCENT_CX, Y_MID), ACCENT_W, ACCENT_H, "icon", ["single"], "design")
    F["accent.right"] = fam((ACCENT_CX, Y_MID), ACCENT_W, ACCENT_H, "icon", ["single"], "design")

    # 40-wide icon rows on the shared column grid; size by throughput
    for i, x in enumerate(COLS, 1):
        F[f"Tier5_{i}"] = fam((x, Y_PROC), ICON_W, ICON_H_SHORT, "icon", ["single"], "design")   # proc 40x20
    for i, x in enumerate(COLS, 1):
        F[f"Tier1_{i}"] = fam((x, Y_ROT), ICON_W, ICON_H_TALL, "icon", ["single"], "live")        # rotation 40x30
    for i, x in enumerate(COLS, 1):
        F[f"Tier2_{i}"] = fam((x, Y_POWER), ICON_W, ICON_H_SHORT, "icon", ["single", "subdivide"], "design",  # power 40x20
                              subdivide={"axis": "x", "span": [round(x - ICON_W / 2, 3), round(x + ICON_W / 2, 3)]})

    # buffs (left) / utility (right): 30x20, tucked, flanking to the outer band
    buff_cols = (BUFF_OUTER, BUFF_INNER)   # (170, 140) -> Tier*_1 = outer
    for side, sign, prov in (("Tier3", -1, "live"), ("Tier4", 1, "design")):
        F[f"{side}_1"] = fam((sign * buff_cols[0], Y_BUFF), BUFF_W, BUFF_H, "icon", ["single"], prov)
        F[f"{side}_2"] = fam((sign * buff_cols[1], Y_BUFF), BUFF_W, BUFF_H, "icon", ["single"], prov)
        F[f"{side}_3"] = fam((sign * buff_cols[0], Y_BUFF_R2), BUFF_W, BUFF_H, "icon", ["single"], "design", dynamic=True)
        F[f"{side}_4"] = fam((sign * buff_cols[1], Y_BUFF_R2), BUFF_W, BUFF_H, "icon", ["single"], "design", dynamic=True)
        F[f"{side}_5"] = fam((sign * buff_cols[0], Y_BUFF_R3), BUFF_W, BUFF_H, "icon", ["single"], "design", dynamic=True)
        F[f"{side}_6"] = fam((sign * buff_cols[1], Y_BUFF_R3), BUFF_W, BUFF_H, "icon", ["single"], "design", dynamic=True)
    return F


def validate_against_wells(families):
    if not os.path.exists(WELLS):
        return {"note": "no gravity_wells.json - run mask_trends.py to validate"}, []
    wells = json.load(open(WELLS, encoding="utf-8"))["wells"]
    lines, confirmed, drifted, unconfirmed = [], 0, 0, 0
    for fid, f in families.items():
        ax, ay = f["anchor"]
        best, bd = None, None
        for w in wells:
            wx, wy = w["anchor"]
            d = ((wx - ax) ** 2 + (wy - ay) ** 2) ** 0.5
            if bd is None or d < bd:
                best, bd = w, d
        tol = max(4.0, (best["spread"] if best else 0) + 2.0)
        if best is None or bd > 15:
            unconfirmed += 1
            if f["provenance"] == "live":
                lines.append(f"  UNCONFIRMED (live) {fid}: no well within 15px")
        elif bd <= tol:
            confirmed += 1
        else:
            drifted += 1
            lines.append(f"  DRIFTED {fid}: computed {f['anchor']} vs nearest well "
                         f"{best['anchor']} ({bd:.1f}px - group-anchor noise / pending re-import)")
    return {"confirmed": confirmed, "drifted": drifted, "unconfirmed": unconfirmed}, lines


def main():
    relationships = _verify()
    families = build_families()
    summary, lines = validate_against_wells(families)
    mask = {
        "mask_id": "Central_hud",
        "authority": "relational matrix computed via geometry.py; live wells validate, never define",
        "frame": "HUD-centered (0,0); group on-screen placement is WeakAuras' (normalized out)",
        "scheme": "A (2026-07): icon gap 2 -> integer columns, inner band ±125, outer ±185",
        "relationships": relationships,
        "composition_model": "single | subdivide (2D budget-fill). Backing plates are an inventory/strata concern.",
        "family_count": len(families),
        "validation": summary,
        "families": dict(sorted(families.items())),
    }
    os.makedirs(MASKS_DIR, exist_ok=True)
    out = os.path.join(MASKS_DIR, "Central_hud.mask.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(mask, f, indent=2)
        f.write("\n")
    print(f"wrote {out}  ({len(families)} families, relational matrix, scheme A)")
    print(f"  shared edges verified by construction: inner +/-{INNER_BAND}, outer +/-{OUTER_BAND}")
    print(f"  columns {COLS}  resources {RES_W}x15 @ +/-{RES_CX}  divider {DIVIDER_W}")
    print(f"  PLATEAU={PLATEAU}: shelf juts {PLATEAU_JUT} past the icon band "
          f"(inner edge +/-{RES_INNER}, outer +/-{RES_OUTER}); P=2 is flush")
    print(f"  accents {ACCENT_W}x{ACCENT_H} @ +/-{ACCENT_CX}  buffs {BUFF_W}x{BUFF_H} @ +/-{BUFF_INNER}/+/-{BUFF_OUTER}")
    print(f"validation vs live wells: {summary['confirmed']} confirmed, "
          f"{summary['drifted']} drifted, {summary['unconfirmed']} unconfirmed/design")
    for line in lines:
        print(line)


if __name__ == "__main__":
    main()
