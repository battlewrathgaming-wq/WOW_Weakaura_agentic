---
name: layout
description: Check a pane layout with the machine before building it - overlaps, overhangs and containment across a declared frame, its pages and its boards. STANDING PRACTICE on any UI test sheet work, and whenever you place, move, resize or add a frame, board, panel or pane, hand-type an x/y or a SetPoint offset, grow or shrink a window, or ship a UI arrangement.
---

# Layout — the machine contradicts you, before the client does

**The failure this exists for is not a missing checker. It is REACH.**
`addons/tools/smoke/frames.lua` has published `F.Overlaps`, `F.Outside`, `F.Containment` and
`F.OverlapsTree` since the smoke harness landed. ⚠⚠ **Nothing called any of them.** Five boards were
placed on the UI test sheet by hand across three turns, the frame was grown and shrunk twice, and the
tool was never asked — because a function you have to remember exists is a function you don't reach for
at the moment you're typing an x.

★ Battlewrath, 2026-08-25: *"I'd wrap it into a single tool you use in the creation process. Callable
in skills so you see it."*

## ★★★ STANDING PRACTICE — sheet work invokes this

Battlewrath, 2026-08-25: *"Standing practice is to envoke that skill on sheet work."*
⟶ Any work on the UI test sheet — a new kind in `sheet_decl.lua`, a board, a page, a size change in
`task_sheet.lua` — **invokes this skill.** Not "may". ⚠ The reason it is standing rather than advisory:
the check existed **three times** already and was reached for **zero** times. A practice that depends on
noticing the moment is the practice that failed.

## Run it

```bash
py addons/tools/check_layout.py
```

```bash
py addons/tools/check_layout.py --json my_layout.json
```

| | |
|---|---|
| *(no argument)* | the UI test sheet's `pane` kind in `addons/COA_DevDump/sheet_decl.lua` |
| `--json FILE` | any layout in the same shape |
| `--quiet` | exit code only — **0 clean, 1 findings** — for a guard in another script |

**Exit 1 means findings.** It prints the pair, the axis and the size of every collision.

## ⟶ Run it AFTER you type the number, not before you ship

The moment is: you just wrote an `x`, a `y`, a `SetWidth` or a `SetPoint` offset. That is when it costs
nothing and catches everything. ★ Waiting until review means the wrong arrangement is already on
someone's screen — which is exactly how the `rangeBoard` × `collapseBoard` overlap shipped.

## What it does NOT do, deliberately

- **It does not argue a size.** `UL-16`: *a measurement is of TODAY and never a constraint on the
  design.* A machine that picks a pane size promotes a fits-today number into a rule.
- **It does not lay out.** AceGUI publishes Flow / List / Fill / Table; ours would be a coat by
  `concepts/type-or-feature.md`.

⟶ **It declares nothing and decides nothing. It contradicts a declaration, or it stays quiet.**

## The declaration shape

```
sheet  { w, h }
title  { x, y }                        optional
strip  { x, y, w, h, gap, n }          optional - a row of n boxes
page   { x, y, w, h }                  the box every board must sit inside
boards [ { page, name, x, y, w, h } ]  y is NEGATIVE-DOWN, as SetPoint takes it
```

⚠ **The builder must READ this table, not mirror it.** `task_sheet.lua`'s `buildSheet` consumes the
`pane` kind and keeps none of its own numbers. A declaration the builder ignores is the second copy
that drifts — the fault the `tools` skill's own page is written about.

## ★★ Two things its first run found, and one of them was itself

1. **`collapseBoard × rangeBoard, by 88 × 96`** — a real overlap, shipped, on screen, invisible to
   five hand placements across three turns.
2. **A sign error in the tool.** It reported the page *"leaving the sheet top by 70"* when the page
   sits 70 **below** the top: `SetPoint`'s negative-down y is already maths-y, and `rect()` was
   negating it under a docstring congratulating itself for converting once at the edge.
   ⟶ **A checker that cannot be wrong is a checker nobody can check.** This one was wrong loudly, on
   its first output, about boxes whose real positions were three lines away.

## What it does not see

**Inside a board.** It checks boards against each other and against their page; it has no view of a
FontString wider than the board it sits in. ⚠ That is the next overlap, one level down — and it bit
immediately: the range's readout was 480 wide inside a board narrowed to 420.

Related: `tools` skill (what already exists before you build) · `UL-16` (a measurement is of today) ·
`concepts/type-or-feature.md` (why we don't write a layout engine).
