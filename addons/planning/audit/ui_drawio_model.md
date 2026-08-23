# Battlewrath's UI model — read from `Dungeon_run_UI_model.drawio.xml` (2026-08-18)

_Source: `D:\Downloads\Dungeon_run_UI_model.drawio.xml` (draw.io, deflate+base64 body); decoded
copy beside this file: `ui_drawio_model_decoded.xml`. Read by the Analyst as INPUT to the UI scope
— his shape, not a design of mine. Three inventories on one page._

## A. Dungeon Run — interface inventory, FIXED PANES
    MAP SURFACE          600x400, "scaled to current frame/map coalesce" — the render space for
                         run and route data; EDITING HAPPENS ON IT (legend node)
    COMMAND STRIP        across the top: display map context · open chips · close map
    MAP CONTROL          locked to the map: pan, zoom, map-specific options; knock-out-able
    UNIFIED INPUT PANE   a right-hand column (160x420) holding three groups STACKED:
      run options        load run · filters against run data · play controls (time) / replay
      promoter options   select a run node for beacon promotion · readout
      node editor        beacon : child : options
                         each "with knock out options"; NOTE: the column COLLAPSES when all
                         are knocked out
    KNOCKED-OUT forms    below the map: node editor (160x200), promoter (160x90), run options
                         (160x90), map control (120x60) as free-floating widgets
    REMOTES              run controls + map-open widget ("run remote / arm / doorway") ·
                         route test drive control widget ("route test arm") · PROMOTE NODE
                         LITE ("right-click a run node to spawn that node's promoter")

## B. Dungeon Run — interface inventory, TABS
    Same surfaces; the unified input pane is a NARROW TABBED COLUMN (99 wide): run / promoter /
    node editor as tabs; the remotes carry tabs too. Two chrome strategies over one surface set.

## C. Dungeon Routes
    ROUTE CONTROLS       share chips · collapse to a strip
    ROUTE MANAGER        profile a single run of that route session (grade / clear) · delete
                         routes from storage · options tab

## ★ `coalesce` — DEFINED 2026-08-23, and this file only ever quoted it
> *"Coalesce is the correction for positional data, frame scaling and map tile scaling. A correction
> already on the map."* — Battlewrath, 2026-08-23, asked directly.

⟶ The phrase `scaled to current frame/map coalesce` above is **one claim, not two**: the surface can
be given any frame size only BECAUSE the correction holds. It is BUILT — `map.lua:44-61` (the
[SILENT] 1002x668 vs 1024x768 fact), `:1224-1250` (the fraction round trip), `:1317-1322` (the tile
crop). Home: `concepts/coalesce.md`.

## New to the record (not in the model before this)
- **KNOCK-OUT**: dock/undock a pane group into a floating widget; the column collapses when
  empty. WA has no equivalent. Fits "isolate like with like" — a group is a unit either way.
- **The map as the EDITING render space** with a command strip — the model's "map is the primary
  storytelling space" now has chrome named.
- **"grade" in the route manager** — flag: the never-grade bound is about THE ROUTE; a reader
  profiling THEIR OWN RUN is different, but the word wants a definition before it reaches a
  pane (Analyst, one flag, not an objection).

## How it reads against his short scope (§0 of the UI scope, same day)
    WA-like presentation        the tabbed variant B is that; A is the stacked alternative
    drop-downs + tabs            B; the node editor's three items (sense · what I do · if seen)
                                 would be the tabs/drop-downs inside "node editor"
    UI = intended data flow      the column reads top-down as the pipeline: run → promote → edit
    like options isolated        the three groups ARE that isolation; knock-out keeps it under
                                 rearrangement
