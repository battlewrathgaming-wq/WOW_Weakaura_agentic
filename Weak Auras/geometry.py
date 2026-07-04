#!/usr/bin/env python3
"""
geometry.py - reusable positional-layout math for WeakAuras element rows.

WHY THIS EXISTS
---------------
Building `Template_shadow.py`'s v0.1-v0.3 revisions, the same row-layout
and mirroring math got rederived from scratch in a throwaway script each
time - and once (v0.2->v0.3) that ad hoc rederivation produced a real,
visible bug: growing icons from 25x25 to 40x30 without recomputing
vertical spacing left two rows overlapping by ~5 units, only caught by
chance during the rebuild. This module extracts that math into a single,
tested, reusable tool - the same reasoning that turned WeakAuras' own
encode/decode logic into `weakaura_codec.py` instead of hand-rolling it
per aura.

THE MODEL
---------
Every element gets described the same way, regardless of tier:
  - an **index** (its position within its row, 0-based)
  - its own **position requirements** (width/height, and the row's gap
    rule - see HUD_DESIGN.md's "Compactness and cohesive spacing" rule:
    default gap is small and fixed, 2-4px, NOT a percentage of size)
  - a **center line at x=0**, which every centered row solves around, and
    which every mirrored flanking pair is built as an exact reflection
    of - never two independently-eyeballed halves (this is exactly the
    mistake `Template_shadow.py` v0.2's hand-tweak made: Tier 3/Tier 4
    ended up at different distances from center because they were placed
    independently rather than mirrored by construction)

Three functions cover every case seen so far:
  - `row_x_offsets` - a single row of N identical slots, centered at 0.
  - `mirror_flanks` - two flanking groups (e.g. Buffs/Utility) built as
    an exact left/right mirror around 0, clearing a shared row's own
    footprint by a group gap.
  - `stack_rows_y` - vertical stacking of rows top-to-bottom, each
    separated from its neighbor by a consistent gap, so growing one
    row's height doesn't silently overlap the next (the actual v0.2->
    v0.3 bug).

USAGE
-----
    import geometry as geo

    # Six 40x30 icons, 10px gap, centered at x=0:
    xs = geo.row_x_offsets(n=6, width=40, gap=10)
    # -> [-125, -75, -25, 25, 75, 125]

    # A flanking pair (Buffs left / Utility right), 2 slots each,
    # clearing a 6-slot 40-wide combat row (whose own outer edge is at
    # 145) by a 10px group gap:
    buffs_x, utility_x = geo.mirror_flanks(
        n=2, width=30, gap=8, inner_edge=145, group_gap=10
    )
    # -> buffs_x = [-208, -170] (outer, inner), utility_x = [170, 208]

    # Vertical stack, 10px gap between every row's edges:
    ys = geo.stack_rows_y(heights=[30, 30, 15, 15, 30], gap=10, top=-95)
    # -> one (top, center, bottom) tuple per row

Run this file directly to execute self-tests (including a reproduction
of Template_shadow.py v0.3's actual numbers, as a regression check):

    python3 geometry.py
"""

from __future__ import annotations

from typing import List, Tuple


def row_x_offsets(n: int, width: float, gap: float, center: float = 0.0) -> List[float]:
    """
    N identical slots of `width`, spaced edge-to-edge by `gap`, centered
    as a block at `center` (default 0 - see module docstring on why 0 is
    the default rather than an inherited/eyeballed position).

    Returns slot CENTERS, left to right, index 0 first.
    """
    if n <= 0:
        return []
    delta = width + gap
    mid = (n - 1) / 2
    return [center + (i - mid) * delta for i in range(n)]


def mirror_flanks(
    n: int,
    width: float,
    gap: float,
    inner_edge: float,
    group_gap: float,
) -> Tuple[List[float], List[float]]:
    """
    Build two flanking groups of `n` slots each, as an exact left/right
    mirror around x=0, clearing a shared row's own footprint.

    `inner_edge`: the absolute distance from center (always positive)
    that the central row (e.g. a 6-icon Power-button row) already
    occupies out to - i.e. its own outer edge's distance from 0. The
    flanking groups start `group_gap` further out than this.
    `group_gap`: clearance between the central row's outer edge and the
    flanking group's nearest slot edge (a separate concept from the
    within-row `gap` between the flanking group's own slots).

    Returns (left_x, right_x), each a list of `n` slot centers ordered
    innermost-first (closest to center first). `right_x` is guaranteed
    to be the exact negation of `left_x`, element for element - this is
    what makes it a mirror BY CONSTRUCTION rather than by careful manual
    placement (the actual v0.2 hand-tweak bug: Tier 3/Tier 4 drifted to
    different distances from center because each side was placed
    independently).
    """
    delta = width + gap
    left_x = []
    edge = -(inner_edge + group_gap)  # outer edge of the innermost slot
    for i in range(n):
        center_i = edge - width / 2
        left_x.append(center_i)
        edge = center_i - width / 2 - gap
    right_x = [-x for x in left_x]
    return left_x, right_x


def stack_rows_y(
    heights: List[float],
    gap,
    top: float,
) -> List[Tuple[float, float, float]]:
    """
    Stack rows vertically, top to bottom. `gap` is either a single
    number applied between every consecutive row, or a list of
    `len(heights) - 1` numbers for the gap after each row individually -
    real layouts aren't always uniform (Template_shadow.py's resource
    bars are deliberately stacked with 0 gap between them - touching -
    while every other row-to-row transition uses the standard fixed gap
    from HUD_DESIGN.md's spacing rule, so a single scalar doesn't always
    fit; don't silently assume uniform spacing where the real design
    doesn't have it).

    `top`: the topmost row's own top edge (y-coordinate). Everything
    else is derived - this is the one number the caller has to choose;
    everything else falls out of `heights`/`gap`.

    Returns one (top, center, bottom) tuple per row, in the same order
    as `heights`. y decreases downward (matches this project's real
    captured data - see Template_shadow.py, where tiers further from
    screen-center have more negative yOffset).
    """
    n = len(heights)
    if isinstance(gap, (int, float)):
        gaps = [gap] * (n - 1)
    else:
        gaps = list(gap)
        if len(gaps) != n - 1:
            raise ValueError(f"Expected {n - 1} gaps for {n} rows, got {len(gaps)}")

    rows = []
    current_top = top
    for i, h in enumerate(heights):
        center = current_top - h / 2
        bottom = current_top - h
        rows.append((current_top, center, bottom))
        if i < len(gaps):
            current_top = bottom - gaps[i]
    return rows


# ============================================================================
# Self-tests
# ============================================================================


def _assert_close(actual: float, expected: float, label: str, tol: float = 1e-6) -> None:
    if abs(actual - expected) > tol:
        raise AssertionError(f"{label}: expected {expected}, got {actual}")


def _self_test() -> None:
    print("geometry.py self-tests\n")

    # --- row_x_offsets ---
    xs = row_x_offsets(n=6, width=40, gap=10)
    expected = [-125, -75, -25, 25, 75, 125]
    for a, e in zip(xs, expected):
        _assert_close(a, e, "row_x_offsets(6, 40, 10)")
    print(f"  OK  row_x_offsets(6, 40, 10) = {xs}")

    xs2 = row_x_offsets(n=2, width=30, gap=8)
    _assert_close(xs2[0], -19, "row_x_offsets(2,30,8)[0]")
    _assert_close(xs2[1], 19, "row_x_offsets(2,30,8)[1]")
    print(f"  OK  row_x_offsets(2, 30, 8) = {xs2}")

    # --- mirror_flanks (reproduces Template_shadow.py v0.3's real numbers) ---
    # Power row: 6x 40-wide icons, 10px gap, centered at 0 -> outer edge
    # at 125 + 20 (half-width) = 145 from center.
    left_x, right_x = mirror_flanks(n=2, width=30, gap=8, inner_edge=145, group_gap=10)
    _assert_close(left_x[0], -170, "mirror_flanks left[0] (innermost)")
    _assert_close(left_x[1], -208, "mirror_flanks left[1] (outermost)")
    _assert_close(right_x[0], 170, "mirror_flanks right[0]")
    _assert_close(right_x[1], 208, "mirror_flanks right[1]")
    for l, r in zip(left_x, right_x):
        _assert_close(r, -l, "mirror_flanks exact-mirror property")
    print(f"  OK  mirror_flanks(2, 30, 8, inner_edge=145, group_gap=10):")
    print(f"      left={left_x}  right={right_x}  (matches Template_shadow.py v0.3)")

    # --- stack_rows_y (reproduces Template_shadow.py v0.3's vertical stack) ---
    # Gaps are NOT uniform in the real layout: standard 10px between most
    # rows, but 0 between the two resource bars (Mana/Placeholder), which
    # Battlewrath deliberately built touching - a list of per-transition
    # gaps, not a single scalar, is required to reproduce this correctly.
    rows = stack_rows_y(heights=[30, 30, 15, 15, 30], gap=[10, 10, 0, 10], top=-95)
    proc_top, proc_center, proc_bottom = rows[0]
    rot_top, rot_center, rot_bottom = rows[1]
    mana_top, mana_center, mana_bottom = rows[2]
    ph_top, ph_center, ph_bottom = rows[3]
    pow_top, pow_center, pow_bottom = rows[4]
    _assert_close(proc_center, -110, "stack_rows_y Proc center")
    _assert_close(rot_center, -150, "stack_rows_y Rotation center")
    _assert_close(mana_center, -182.5, "stack_rows_y Mana center")
    _assert_close(ph_center, -197.5, "stack_rows_y Placeholder center")
    _assert_close(pow_center, -230, "stack_rows_y Power center")
    # resource bars (rows 2,3) should touch with zero gap between them,
    # matching Battlewrath's own hand-built stacking
    _assert_close(mana_bottom, ph_top, "resource bars touch with 0 gap")
    print("  OK  stack_rows_y([30,30,15,15,30], gap=[10,10,0,10], top=-95):")
    print(f"      centers = Proc {proc_center}, Rotation {rot_center}, "
          f"Mana {mana_center}, Placeholder {ph_center}, Power {pow_center}")
    print("      (matches Template_shadow.py v0.3's real vertical stack)")

    print("\nAll self-tests passed - matches Template_shadow.py v0.3's real,")
    print("live-tested numbers exactly, confirming this module is a faithful")
    print("extraction of the ad hoc math used to build it, not a rewrite.")


if __name__ == "__main__":
    _self_test()
