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
nobody has ever run, and **verified against 1,462 real captured points across four runs and two
dungeons with a worst error of `0.000000`**. The emitter re-runs that proof on every emit and
prints it — a claim that re-checks itself is worth more than one written down.

---

## ★ What this is FOR — and what it must never become

**Verification and design infrastructure. Not a runtime dependency.** Ruled 2026-08-13
(`ARCHIVE__dungeonrun_poc.md` §17): *"we don't want to create a system that needs per dungeon tracking
first."*

**Nothing in any addon reads this census.** Lua cannot read DBCs, so shipping these boxes inside
an addon would mean carrying a data table that **goes stale the moment the fork adds a dungeon**
— per-dungeon tracking wearing a principled hat. Runtime placement uses the fraction the client
itself computed at capture time; this census is how **we** proved that fraction is trustworthy
(zero residual on 1,462 points across two dungeons and nine floor groups), and how we reason about maps
at the desk.

Use it for analysis, proofs and traps. Do not ship it.

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
Verified zero-residual across 1,462 points spanning four runs.

⚠ **The proof was weaker than its number until 2026-08-14.** `verify()` picked *the first floor box
that contained the point* rather than the floor the point was captured on — fine on Ragefire, which
is why it read `0.000000` for months, and wrong the moment Shadowfang's seven overlapping floors
landed (M6: 42 of 43 multi-floor dungeons overlap). It reported `0.544307`, and the transform was
never at fault: it was comparing the right fraction against the wrong box. **DR-33 captures the floor
precisely so nobody has to guess it** — keyed on that, the residual is zero again, over four times
the evidence. A proof that passes for the wrong reason is worth less than its number suggests.

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

**M10 — ★ THE CLIENT DOES CARRY PER-FLOOR Z BOUNDS, in a table we had not read.**
`DungeonMapChunk.dbc` — 2,696 rows, in `patch-M.MPQ`:

```
id | mapID | WMOGroupID | dungeonMapID | minZ (float)
```

Confirmed against Shadowfang: 79 chunk rows resolving to exactly the seven `dungeonMapID`s
`DungeonMap.dbc` gives it, with `-10000` as a "no lower bound" sentinel and real layer heights
(100 / 127 / 137 / 150) on the middle floors.

★ **This corrects a statement of ours and does not change the conclusion.** We had written that
floor-from-height was impossible because *"DungeonMap.dbc carries no z bounds"* — true of that file,
incomplete about the client. It stays impossible **at runtime** for a sharper reason: the join key is
`WMOGroupID`, and no Lua call reports which WMO group the player is in. Nor does z alone substitute —
Shadowfang's floors 1, 2 and 7 all carry the sentinel and would be indistinguishable. **The data
exists; the key to it is not exposed.** DR-33 stands.

**M11 — `DungeonUsesTerrainMap()` shifts the tile level by one, and three maps are marked.**
`WorldMapFrame.lua:463` subtracts 1 from the dungeon level when the map uses a terrain base. Exactly
three floored maps carry `defaultDungeonFloor = -1` where the other 70 carry `0`: **595
`CoTStratholme` · 603 `Ulduar` · 904 `OrgrimmarDepths`** — each an outdoor approach with interior
floors layered on. Mount Hyjal and the Caverns of Time instances have **no floors at all**, so
nothing shifts there.

⚠ That the `-1` *marks* the terrain case is an inference from a three-map correlation, not a proof:
`DungeonUsesTerrainMap()` is C-side and `defaultDungeonFloor` is a different column. `/dr probe`
settles it in one reading.

⚠ **`defaultDungeonFloor` is NOT a pointer into `DungeonMap.dbc`** — `dungeonMapID` runs 5..3003
across 200 distinct values while the field only ever carries `0` or `-1`. And **`parentWorldMapID` is
not a discriminator either**: every dungeon floor carries one naming its containing outdoor zone
(Shadowfang's point at 21, Silverpine). Both recorded so nobody spends the hour again.

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
