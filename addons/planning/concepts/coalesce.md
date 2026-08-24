# CONCEPT HOME · `coalesce` — the map's correction, named

_A HOME is an INDEX, never a second copy (AL-26, Battlewrath 2026-08-22: "a home is better than a
run-time cost — it's greppable and inspectable"). It says what the concept IS in a few lines, its
closed list, and POINTS at every place that rules or grades it. The pointed-at documents stay
authoritative; if this page and one of them disagree, the document is right and this page has
drifted. Opened 2026-08-23 by the UI specialist._

## WHAT IT IS

> **"Coalesce is the correction for positional data, frame scaling and map tile scaling. A
> correction already on the map."** — Battlewrath, 2026-08-23

⚠ **This page names something already BUILT.** `audit/ui_drawio_model.md:8` has carried his phrase
*"scaled to current frame/map coalesce"* since 2026-08-18 as a quotation, with no definition; the
mechanism it refers to has been in `map.lua` the whole time under no name at all. **The word is the
new thing here, not the behaviour**, and one word over a mechanism spread across six call sites is
worth a page.

★ Three scalings sit between a stored point and a pixel, and coalesce is the reconciliation of all
three into ONE coordinate space. Get any of them wrong and **it still renders** — a trail that still
follows corridors and is wrong everywhere, worst furthest from the origin.

## THE CLOSED LIST — the three corrections, and where each lives

    POSITIONAL DATA     a point is stored as a FRACTION (0..1), never as a pixel.
                        `Map.Offset` (map.lua:1224-1233) -> `mx * w, -(my * h)`
                        `Map.FractionAt` (map.lua:1245-1250) is the inverse, and the only new
                        arithmetic dragging needs
    FRAME SCALING       the cursor arrives in SCREEN units and the frame may be scaled:
                        `(cursorX / scale - left) / ART_W`  (map.lua:1249)
                        zoom is `canvas:SetScale` — UNIFORM, so 3x covers 3x the ground for free
                        (map.lua:289-295), and the pan clamp works in scaled units
                        (`ART_W * z - viewW`, map.lua:344-345)
    MAP TILE SCALING    the art grid OVERHANGS the coordinate space and must be cropped, not
                        stretched: `min(TILE_PX, ART_W - x)` with texcoords `w / TILE_PX`
                        (map.lua:1317-1322)

## ★★★ THE FACT THE WHOLE CORRECTION EXISTS FOR — `map.lua:44-61`, marked [SILENT]

    WorldMapDetailFrame   1002 x 668     <- the fraction 0..1 maps across THIS
    WorldMapDetailTile    4 x 3 x 256    <- 1024 x 768, and it OVERHANGS

**Two different sizes, and confusing them is a silent scale error**: +2.2% horizontally and **+15%
vertically**. ⚠ It was caught **by eye on the first art-bearing draw** — *"there is some displacement
as a constant across them"* — by nothing mechanical. That is why the correction is load-bearing and
why naming it matters: nothing in the code will tell you when it is missing.

## WHY THE NAME EARNS ITS PLACE — the layout consequence

`options.lua:21-40` rules **the map is the floor**: *"The map sizing stays a constant and defines the
parent container size. Can already be greater than, can never be lesser than, the map frame."*
⟶ A container that **RESIZES** the canvas re-introduces the silent error; a container that **SCALES**
it uniformly does not. **So "scaled to current frame" is only safe BECAUSE coalesce holds**, and the
sketch's two words are one claim, not two.

## WHERE IT IS RULED AND GRADED
    addons/COA_DungeonRun/map.lua:44-61          the [SILENT] fact and the two constants
    addons/COA_DungeonRun/map.lua:1224-1250      Offset / FractionAt — the fraction round trip
    addons/COA_DungeonRun/map.lua:1317-1322      the tile crop and its texcoords
    addons/COA_DungeonRun/options.lua:21-40      the map-is-the-floor invariant this protects
    addons/planning/audit/ui_drawio_model.md     where his phrase entered the record (2026-08-18)
    addons/planning/interface/map.md             the map surface's factual register

## WHAT THIS PAGE DOES NOT CLAIM
That the correction is complete, or that it survives every container. It names three scalings the
code reconciles today and points at them. ⚠ Whether a container that changes the map region's size
at runtime keeps them reconciled is **untested here** — `options.lua` argues it must SCALE rather
than RESIZE, and that argument has not been walked against a live resize.

---

## ★★★ A THIRD SCALE, FOUND 2026-08-24 — the SCREENSHOT is not the client's pixels
Sheet eight's registration pins were used to rectify a real screenshot against its record, and the
attempt turned up a scale nobody had named:

    the record says       3620 x 2036     the client's own reported resolution
    the FILE is           2560 x 1440     the screenshot on disk
    ratio                 0.7072

⟶ **A screenshot pixel is NOT a client device pixel on this setup.** Anything mapping a captured
coordinate onto an image by assuming they are the same is **41% out**, and — exactly like the
1002×668 / 1024×768 fault this page exists for — **it still renders. It is just wrong.**

★★ **AND THE PINS MAKE IT NOT MATTER.** Two marks at known UI coordinates give scale and offset
directly, so no assumption about the ratio is needed at all:

    from the record (UI)   tl (165, 791)   tr (1423, 791)   bl (165, 103)
    found in the image     tl (207, 127)   tr (1790, 127)   bl (207, 995)
    scale   x: 1583/1258 = 1.258     y: 868/688 = 1.262     ✓ agree, and y is FLIPPED

Verified on two things the record describes that were NOT used to derive the transform: the centre
ring (predicted 998,560 — found ~998,562) and the range's slice body (predicted x 803..846 — found
~803..848).

⚠ **The lesson is this page's own, one level out:** a coordinate is meaningless without the space it
is in, and *"resolution"* named three different things here — the render size, the window size, and
the file size. ⟶ **Measure the transform; never assume it.**
