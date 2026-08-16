# Map — the drawing surface

_`map.lua` · `COA_DungeonRunMap` · **size is a RULE, not a pair** · content x = `MARGIN + 2` = 18_

★★★ **The factual register.** What exists, or what the code must comply with.

---

## numbers — computed, not declared

    w = ART_W + MARGIN * 2      = 1002 + 32       = 1034
    h = ART_H + STRIP + FOOT    = 668 + 40 + 14   = 722

    ART_W, ART_H          map.lua:57      1002 × 668 — the COORDINATE space
    MARGIN, STRIP, FOOT   map.lua:2128    16, 40, 14
    TILE_COLS/ROWS/PX     map.lua:56      4 × 3 × 256 — the ART grid

★★★ **The coordinate space is NOT the tile grid, and that distinction is load-bearing.** The tiles
are power-of-two art with dead padding. Placing against the tile grid instead of the detail frame
stretches everything **+2.2% horizontally and +15% vertically** — which draws a trail that still
follows corridors and is wrong everywhere, worst furthest from the origin.

⚠ Caught by eye on the first art-bearing draw: *"there is some displacement as a constant across
them."* A wrongness that still looks plausible is the expensive kind.

★ **This is the shape any computed pane needs** — a rule with its constants named, not two numbers
someone typed.

## does

1. **Draws a captured run** onto the client's own dungeon tiles.
2. **Draws a route** — beacons and their children — on a second layer.
3. **Draws personal notes** on a third.
4. **Zooms and pans**, 1× to 4×.
5. **Selects** a point, and right-click opens the Object pane on it.
6. **Opens** the Map controls and Curation.

## refuses

- ⚠ **It never learns a dungeon.** No stored floor plans, no roster, no list of what exists. It
  draws onto the client's own tiles and reads its own captures.
- ⚠ **It takes neither the wheel nor right-drag without being asked.** Mouse-wheel zoom and
  right-click pan are ticks that default **OFF** — the wheel belongs to the world camera and
  right-drag to camera-look.
- ⚠ **Point facts live on the MAP as a tooltip**, not in a pane. Hovering answers; nothing
  announces.

## how

★★ **THE LAYER TABLE IS THE MODEL** (`map.lua:377`). Three rows, and adding the third cost exactly
one row — which is the test that the layering is real rather than two special cases:

    key      timed   art    lists
    run      true    true   RUN_LISTS      a capture, sliced by time
    route    false   false  beacons        an authored route
    notes    false   false  notes          your own plane, keyed by mapID

★ **`run` and `route` load independently.** Authoring a route means looking at the evidence it came
from, so both can be on screen at once.

★ **Notes are keyed by `mapID`, not by route.** They are yours: they need no route, never travel
with one, and there is one plane per dungeon with nothing to choose.

    time      envLo/envHi (envelope) · winPos/winWidth (window) · SkipStep — a tenth of the span
    view      zoom 1–4, anchored on the VIEW CENTRE rather than the cursor
    drawing   Painted(floor) is a QUERY over the loaded slots

⚠⚠ **`Map.Painted` answers the same whether or not anything repainted**, so asserting against it
proves the record and never the picture. **The dots are the picture.**

★ **Zoom anchors on the view centre, not the cursor**, and that is deliberate: the cursor is also
the *pen*, and drawing tools are unusable on the coarser maps where a 5-yard radius is under two
pixels.

## interacts

| you | it |
|---|---|
| left-click a point | selects it — Promotion mints from the selection |
| right-click a beacon, child or note | opens the **Object** pane on it |
| **Controls** | opens the Map controls pane |
| **Curate** | opens Curation |
| **◀ / ▶** | previous / next floor |
| hover a point | a tooltip with that point's facts |
| mouse wheel · right-drag | ⚠ **only if you ticked them on** |

## holds

    envLo/envHi, winPos/winWidth   the time slice — Curation reads and sets these
    zoom, scroll                   view state
    layerOff, hidden               what is drawn
    tracking                       follow the newest node
    moveArmed, pickArmed           the Object pane arms these; the map performs them

★★ **The map owns the selection and the time state; every other pane reads it from here.** That is
the §63 rule — two surfaces each remembering what they are looking at is how they come to disagree.

## relates

    opened by   the Remote
    opens       Map controls · Curation · the Object pane (right-click)
    ⚠ Curation and Promotion (DIALOG) draw OVER this pane (HIGH), and its own "Controls"
      and "Curate" buttons read through their backdrops

## children

☐ **Not declared in `panespec.lua`.** Every number is hand-typed in `map.lua`.

```
map.title       kind readout    forms map.lua:2161, GameFontNormal, at (MARGIN + 2, -16)
map.ref         kind readout    forms map.lua:2163, LEFT of title + 10
map.viewport    kind scroll     forms map.lua:2171, ScrollFrame, COA_DungeonRunViewport
                does  clips and scrolls the canvas
map.canvas      kind frame      forms map.lua:2194, inside the viewport
                does  holds the tile textures and every drawn point
map.tiles       kind texture    forms map.lua:2198, one per tile in a 4 × 3 grid at 256px
                ★ the coordinate space is ART_W × ART_H, NOT the tile grid — see numbers
map.controls    kind button     forms map.lua:2213, "Controls", TOPRIGHT -MARGIN-64, -12
                                numbers w 70 · h 20
map.curate      kind button     forms map.lua:2219, "Curate", TOPRIGHT -MARGIN, -12
                                numbers w 60 · h 20
                ⚠⚠ These two are what read through Curation's backdrop when it is open
map.prev        kind button     forms map.lua:2226   does previous floor
map.floor       kind readout    forms map.lua:2232   does which floor
map.next        kind button     forms map.lua:2235   does next floor
map.readout     kind frame      forms map.lua:2248 + its title at :2261 and its rows below
                does  the point facts panel
```

☐ **Nothing here is registered**, so the geometry probe cannot see any of it — and this is the
largest surface in the addon.

---

## Outstanding

<!-- OUTSTANDING:BEGIN - emitted by emit_outstanding.py, do not edit by hand -->

2 items:

- Not declared in `panespec.lua`. Every number is hand-typed in `map.lua`.
- Nothing here is registered, so the geometry probe cannot see any of it — and this is the largest surface in the addon.

<!-- OUTSTANDING:END -->

---

## Hopes and dreams

_What this surface still needs so **the model** can be realized (`dungeonrun_model.md`). Not technical — the backlog to realize._

_Nothing recorded yet._ ⚠ Empty on purpose — this half is his, and inventing hopes on his
behalf would put fiction in the one place meant to read as direction.
