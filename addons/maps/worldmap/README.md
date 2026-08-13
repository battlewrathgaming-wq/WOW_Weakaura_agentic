# World map — the fact basis

_The client's own map manifest, decoded from the DBCs it ships. **Emitted, never hand-edited** —
regenerate with `py addons/tools/emit_worldmap_census.py`, check staleness with `--check`._

**Scope (Battlewrath, 2026-08-13): a bench asset, not a Dungeon_run extract.** *"Sounds like it
could have things for Maps, outside of our use. Enrich the whole."* Everything here is keyed by
`mapID` and answers *"what does the client offer"*, the same way `maps/census/` does for the API
and `maps/atlas/` does for art.

## ★ What this retires

`satnav_ledger.md` carried a standing cost: *"calibration cost per dungeon — two captured points
with decent map separation."*

**That is dead. The world↔map transform is a LOOKUP**, correct on the first visit to a dungeon
nobody has ever run, and **verified against 389 real captured points with a worst error of
`0.000000`** (the two pinned Ragefire runs). The emitter re-runs that proof on every emit and
prints it — a claim that re-checks itself is worth more than one written down.

---

## The facts

**M1 — A map is twelve tiled textures at a predictable path.**
`WorldMapFrame.lua:473-476`:
```lua
for i = 1, NUM_WORLDMAP_DETAIL_TILES do        -- 12, Constants.lua:744
    texName = "Interface\\WorldMap\\"..mapFileName.."\\"..completeMapFileName..i
end
```
There is **no virtual template for the map surface** — `WorldMapDetailFrame` and its tiles are
concrete singletons. A custom map frame therefore *composes the same art*; it does not
instantiate a stock component. (The POI/unit templates in `WorldMapFrameTemplates.xml` **are**
virtual and reusable — the surface is yours, the markers can be theirs.)

**M2 — `mapFileName` is `WorldMapArea.dbc`'s name column, and it is what `GetMapInfo()` returns.**
For mapID 389 that is `Ragefire`, matching the live read in `satnav_ledger.md` F7.

**M3 — ★ THE TRANSFORM.** Per floor, from `DungeonMap.dbc`:
```
mapX = (maxX - worldY) / (maxX - minX)
mapY = (maxY - worldX) / (maxY - minY)
```
Verified zero-residual across 389 points spanning two runs.

**M4 — ★ THE AXIS TRAP: the fields named X bound world Y, and vice versa.**
This is the single most expensive thing to get wrong here, and it is invisible — a swapped pair
still produces plausible-looking fractions in 0..1. Ragefire, `DungeonMap` row 54:

| field | value | what it actually bounds |
|---|---|---|
| `minX` | -285.99 | world **Y** at mapX = 1 |
| `maxX` | 452.87 | world **Y** at mapX = 0 |
| `minY` | -452.95 | world **X** at mapY = 1 |
| `maxY` | 39.62 | world **X** at mapY = 0 |

**Both axes also run backwards** (fraction 0 is the *maximum* world value). This layout was not
assumed — it was **solved from the captured data first** by least-squares fit, and the four
derived edge values then matched the DBC to three decimals.

**M5 — `WorldMapArea.dbc`'s box is ROUNDED; `DungeonMap.dbc`'s is precise.**
Ragefire: WorldMapArea gives `453.0 / -286.0 / 40.0 / -453.0`, DungeonMap gives
`452.871 / -285.993 / 39.623 / -452.953`. **For any instance, use DungeonMap.** WorldMapArea is
the right table outdoors, where it is the only box there is.

**M6 — ★ 43 of 73 mapped dungeons bundle multiple FLOORS under one `mapID`** — the "wings".
Deepest is **mapID 532 with 17 floors**. Each floor has its **own box and its own tile art**, so
**a world position is not placeable from `mapID` alone.** Full table: `dungeon_floors.md`.

**M7 — The floor selects the tile name, with an off-by-one for terrain maps.**
`WorldMapFrame.lua:463-472`:
```lua
local dungeonLevel = GetCurrentMapDungeonLevel()
if DungeonUsesTerrainMap() then dungeonLevel = dungeonLevel - 1 end
completeMapFileName = dungeonLevel > 0 and (mapFileName..dungeonLevel.."_") or mapFileName
```
So `Ragefire1..12` for a floorless map, `Ragefire1_1..12` for floor 1 of a terrain map.
API surface: `GetNumDungeonMapLevels()` · `GetCurrentMapDungeonLevel()` ·
`SetDungeonMapLevel(n)` · `DungeonUsesTerrainMap()`.

**M8 — ★ `GetCurrentMapAreaID()` is off by one from the internal map id.**
`WorldMapFrame.lua:1583`: `local mapID = GetCurrentMapAreaID() - 1`. The client's own code
subtracts it. Anything that compares the two raw will be silently wrong by one map.

**M9 — ★ Inside an instance the continent/zone pair is a SENTINEL, not an identity.**
Live-captured on 389/389 points: `GetCurrentMapContinent() = -1`, `GetCurrentMapZone() = 0`.
**Every dungeon reports `(-1, 0)`.** A pin layer that matches on that pair — as
`COA_Landmarks` AC-34 does for outdoor zones — **would draw one dungeon's pins on another's
map**. Indoors, match on `mapID`.

---

## The files

| | |
|---|---|
| `worldmap.census.json` | machine copy keyed by `mapID` — tile art, area box, every floor box, directory, instance type |
| `dungeon_floors.md` | every multi-floor map, and each floor's bounding box |

## Sources

All four tables live in **`patch-M.MPQ`**, read with `mpyq` (the same path
`read_spell_dbc.py` and `extract_interface.py` use):

| table | rows × fields |
|---|---|
| `DungeonMap.dbc` | 200 × 8 |
| `WorldMapArea.dbc` | 307 × 11 |
| `Map.dbc` | 374 × 66 |
| `WorldMapContinent.dbc` | 4 × 14 |

**Field counts are asserted, not assumed** — a fork that reshapes one of these makes the emitter
exit loudly rather than emit a census that is quietly wrong. Same rule `read_spell_dbc.py`
follows, for the same reason.

**Staleness:** the fingerprint is a content hash of all four source DBCs, so it moves when the
client's data moves, not when the emitter runs. **This fork ships changes in days** — re-run
`--check` before trusting a number here.
