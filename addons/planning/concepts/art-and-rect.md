# CONCEPT HOME · `art and rect` — the picture is not the box

_A HOME is an INDEX, never a second copy (AL-26, Battlewrath 2026-08-22: "a home is better than a
run-time cost — it's greppable and inspectable"). It says what the concept IS in a few lines, its
closed list, and POINTS at every place that rules or grades it. The pointed-at documents stay
authoritative; if this page and one of them disagree, the document is right and this page has
drifted. Opened 2026-08-23 by the UI specialist on Battlewrath's steer: *"reasoning comes from
collating and collecting to stable surfaces."*_

## WHAT IT IS
A control has **two extents** and they are not the same. The **rect** is what `GetRect` /
`GetWidth` answer and what every layout, every anchor and every check this bench owns operates on.
The **art** is the union of the textures it actually draws, and it may sit outside the rect on any
edge. ⚠ Neither is wrong; asking the wrong one is.

> ★★★ **a rect check UNDER-REPORTS a dropdown by design, and a pane can look wrong exactly where
> the arithmetic says it is fine** — `layout.lua:127`

## THE CLOSED LIST — the three widths, and the fourth thing they hide
    FIELD   w        `$parentMiddle`, the sunken area the selection reads in
    TEXT    w - 25   `$parentText`, the string inside that field
    ART     w + 50   Left(25) + Middle(w) + Right(25) — and the ARROW that reacts to a click
                     lives out in that Right texture, entirely outside the frame you sized
    HEIGHT           the template's three textures are 64 tall on a frame declared 32, anchored
                     TOPLEFT at y = +17: ~17 above the rect, ~15 below

★ **One number, three meanings, and picking the wrong one looks exactly like a pane that clips.**
Budget the ART or a neighbour gets covered; size a label to the FIELD and the text is clipped
inside its own box.

## THE CASE THAT PAID FOR IT — §103, "the neighbour, not the edge"
The promoter asked for 200, read it as *200 wide*, and put a button at 208 — **inside the 250 of
art**. The geometry run then measured that button as comfortably inside its pane, so the cause read
as unknown: every instrument we had compares rects. ⟶ It was never the button overflowing its
edge. It was the neighbour's picture covering it.

⚠⚠ **AND THE RUN CARD STILL SAYS UNKNOWN.** `geom_probe_runsheet.md` was written at §102.1 and
solved at §103 — one commit later, same day. It even lists *"art beyond the frame edge"* as one of
three candidates, so the candidate was right and the resolution landed somewhere else. That page is
what someone reads **before spending a run**, which is the worst place for a dead question to sit.

## WHERE IT IS RULED (read these; this page only points)
    COA_DungeonRun/layout.lua      :108-119 the three widths, and `Layout.DROPDOWN_FIELD/TEXT/ART`
                                   :124-131 the height overhang and `Layout.ART`; the rule itself
    dungeonrun_interface_inventory.md  `Constants, sourced` — the three widths as an inventory fact,
                                   cited to `SharedXML/UIDropDownMenu.lua:962`
    geom_probe_runsheet.md         Run 1 — the dropdown settled from both directions at once
                                   (+50 measured AND sourced); ⚠ and the stale play-button block
    addons/COA_DevDump/sheet_decl.lua  kind `art` — what is measured, and why per EDGE
    addons/COA_DevDump/task_sheet.lua  the region union; only VISIBLE regions, hidden ones counted
    addons/tools/check_sheet.py    `--art` — the table; positive means the picture runs past the rect
    addons/tools/smoke/frames.lua  ⚠ THE GAP: the offline resolver reports overlaps and overhangs
                                   in RECTS only, so this whole class is invisible to it
    §103                           the commit that solved it; §102.1 is the one that could not

## WHY IT IS A CONCEPT AND NOT A CONSTANT
`Layout.ART = { dropdown = { dw = 50, h = 64, dy = 17 } }` is **one entry, hand-measured, for one
template**. The concept is that EVERY control has an art extent and ours is a table of size one.
★ A constant would have gone in the inventory beside the text grid; this needed a home because the
thing to remember is the QUESTION — *which extent am I asking for* — not the number.

## WHAT IS OWED — derive it; never read it here
    py addons\tools\check_sheet.py --art

As of 2026-08-23 by hand: 13 subjects DECLARED (6 stock templates + 7 AceGUI widgets), **none
captured** — the kind landed the same day and needs one `/coadump r sheet`. ⚠ A hand line; it rots,
and the tool is the truth.

Two things this page deliberately does NOT settle, so nobody reads a decision into it:
- whether `frames.lua` should carry art at all, or whether art stays a client-measured table the
  offline resolver merely cites. **Not decided.**
- whether the run card gets corrected in place or only pointed at the concept. Pointed at, for now.

Related: `concepts/next.md` (the shape this follows) · `UI_LOG.md` UL-4 · `ui_sheet_spec.md`.
