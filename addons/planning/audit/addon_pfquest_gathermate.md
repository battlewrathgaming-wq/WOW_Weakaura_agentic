# Audit: pfQuest + pfQuest-ascension (and GatherMate2 / GatherMate2_Data as a second data-at-scale neighbour) — markers, data points, sequencing, detection

Independent read-only audit, from files only. Targets under `F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\`:

- `pfQuest` — TOC `## Interface: 30300`, `## Version: 6.9.5`, title `pfQuest [BETA]` (`pfQuest.toc:1,5`); `gitrev.txt` = `6.9.5`. Loads `init\data.xml` + 8 locale xmls, then `init\data-tbc.xml` + 8 locale-tbc xmls, then `init\addon.xml` (`pfQuest.toc:12-32`). Code files: `compat\pfUI.lua`, `compat\client.lua`, `overwrites.lua`, `locales.lua`, `config.lua`, `slashcmd.lua`, `database.lua`, `map.lua`, `quest.lua`, `route.lua`, `tracker.lua`, `browser.lua`, `journal.lua`, `updatenotify.lua` (`init/addon.xml:2-15`).
- `pfQuest-ascension` — TOC `## Version: 1.01`, `## Dependencies: pfQuest`, loads `init\data-ascension.xml`, `init\enUS-ascension.xml`, `patchtable.lua`, `pfQuest-ascension.lua` (`pfQuest-ascension.toc:1-10`).
- `GatherMate2` — TOC `## Version: asc-1.0.7 (v1.0.3 base)`, `## Author: kagaro, xinhuan, nevcairiel, Ascension Compat by Xan` (`GatherMate2.toc:11,20`).
- `GatherMate2_Data` — TOC `## Version: asc-1.0.2 (v1.4.0 base)`, `## LoadOnDemand: 1`, `## X-Generated-Version: $Revision: 6 $`, `## Dependencies: GatherMate2` (`GatherMate2_Data.toc:11-14`).
- `Asc_Gathermate2` — a container folder holding `GatherHud/`, `GatherMate2/`, `GatherMate2_Data/`. Its `GatherMate2/` and `GatherMate2_Data/` are byte-identical to the top-level copies except `GatherMate2/Libs/Libs.xml` (top-level adds `AceBucket-3.0`; the Asc_ copy lacks that folder). Only `GatherHud` is unique to it (`GatherHud.toc:2-4`: `GatherHud 1.1.7 ... for GatherMate2 with Routes support`). Noted where relevant; not separately audited.

Cite convention: `pfQ:<file>:NNN`, `pfA:<file>:NNN` (pfQuest-ascension), `GM2:<file>:NNN`, `GMD:<file>:NNN` (GatherMate2_Data), `Hud:GatherHud.lua:NNN`.

Headline: **pfQuest is a shipped, all-at-once-loaded position database (~75 MB on disk) keyed by vanilla AreaTable zone ID with `{x%, y%, zoneID, respawnSecs}` tuples, no floors, no instance coordinates at all; markers are drawn from that database and removed only when the quest log says so; "routing" is a greedy nearest-neighbour chain in map-percent units with a self-drawn arrow, and there is no proximity/arrival logic anywhere.** GatherMate2, by contrast, packs one node into one integer `x*1e10 + y*1e6 + floor` keyed by `GetCurrentMapAreaID()`, derives zone yard sizes at runtime from an Ascension `C_WorldMap` API, and its data pack does carry per-dungeon-floor authored nodes.

---

## 1. DATA FORMAT

### pfQuest core database (`pfQuest/db/`)

- Root table declared `pfDB = { ["areatrigger"]={}, ["items"]={}, ["meta"]={}, ["meta-tbc"]={}, ["minimap"]={}, ["minimap-tbc"]={}, ["objects"]={}, ["professions"]={}, ["quests"]={}, ["quests-itemreq"]={}, ["refloot"]={}, ["units"]={}, ["zones"]={} }` (`pfQ:db/init.lua:1-15`).
- **Units** (`pfQ:db/units.lua:1`, single-line file): `pfDB["units"]["data"]={[1]={["coords"]={},["fac"]="AH",["lvl"]="63",},[2]={["coords"]={[1]={46.2,9.3,14,25},[2]={51.8,84.7,1637,25},},["fac"]="AH",["lvl"]="63",},...`. Key = creature entry ID. `coords` is an array of 4-tuples; the reader unpacks them as `local x, y, zone, respawn = unpack(data)` (`pfQ:database.lua:707`) and shows `SecondsToTime(respawn)` (`:722`). So: **x,y in map-percent (0..100, one decimal), zone = AreaTable ID (vanilla numbering: 12 Elwynn, 14 Durotar, 1519 Stormwind…), 4th = respawn seconds.**
- **Objects** same shape (`pfQ:db/objects.lua:1`: `[31]={["coords"]={[1]={84.5,46.8,44,10},},["fac"]="A",}`), unpacked identically at `pfQ:database.lua:873`.
- **Areatriggers** are 3-tuples `{x, y, zone}` (`pfQ:db/areatrigger.lua:2-6`), unpacked `local x, y, zone = unpack(data)` (`pfQ:database.lua:671`).
- **Quests** (`pfQ:db/quests.lua:1`): `[2]={["end"]={["U"]={12696},},["lvl"]=30,["min"]=20,["pre"]={6383},["race"]=178,["start"]={["I"]={16305,16305},},}`; objectives live under `["obj"]` with sub-keys `U` (units), `O` (objects), `I` (items), `A` (areatriggers), `Z` (zones), `IR` (item-requirement) — consumed at `pfQ:database.lua:1168-1281`.
- **Items** (`pfQ:db/items.lua:1`): `[117]={["O"]={[2843]=19,},["U"]={[38]=0.02,...}}` — drop chance per source; `V` = vendors, `R` = refloot refs (`pfQ:database.lua:930-988`).
- **Zones** (`pfQ:db/zones.lua:2`): `[9] = { 12, 17.47, 27.69, 51.15, 42.29 }` → `zone, width, height, x, y, ex, ey = unpack(zones[id])` (`pfQ:database.lua:809`) — sub-zone → parent map + bounding box in percent.
- **Minimap yard sizes** (`pfQ:db/minimap.lua:1`): `pfDB["minimap"]={[0]={35199.9,23466.6},[1]={4925.0,3283.34},[3]={2487.5,1658.34},...,[1519]={1344.2694,896.36},...}` — 51 zones; `minimap-tbc.lua` adds 17 Outland/BE/Draenei zones. Read as `minimap_sizes[mapID][1|2]` (`pfQ:map.lua:40,897-898`).
- **Locale strings** are separate per-language tables: `pfDB["units"]["enUS"]={[3]="Flesh Eater",...}` (`pfQ:db/enUS/units.lua:1`), quests as `{["D"]=…,["O"]=…,["T"]=…}` (`pfQ:db/enUS/quests.lua:1`), zones `[1519]="Stormwind City"`, and instance names exist there (`[1581]="The Deadmines"`, `[718]="Wailing Caverns"`, `[2557]="Dire Maul"`) even though no coordinate uses them.
- **Floors / levels: none.** No 5th tuple field (grep for `{x,y,z,r,…}` finds 0); `GetCurrentMapDungeonLevel`/`GetCurrentMapAreaID` never appear in any pfQuest file (grep: none).
- **Per-zone keys, not per-map:** the tuple's zone slot is used directly as the map bucket `pfMap.nodes[addon][map]` (`pfQ:map.lua:435,451`); the world map is matched to it by name (`pfMap:GetMapID` → `GetMapZones(cid)[mid]` → `pfDB.zones.loc` reverse lookup, `pfQ:map.lua:408-425`).
- **Scale (this install):** `db/` = 75,158 KB on disk (`du`), largest files `items.lua` 2.97 MB, `items-tbc.lua` 2.97 MB, `units-tbc.lua` 2.39 MB, `units.lua` 2.09 MB, `objects-tbc.lua` 2.01 MB, `objects.lua` 1.30 MB. Vanilla `units.lua` has 10,417 entries carrying `coords` and 69,241 coordinate tuples; `objects.lua` 9,198 / 44,726; TBC layers 12,452 / 76,139 (units) and 6,506 / 76,595 (objects). ~4.3k quests (vanilla) / ~5.3k (tbc); ~17.7k items. Coordinates reference **52 zone IDs, all outdoor** (`1 10 11 12 130 1377 139 14 141 148 1497 15 1519 1537 16 1637 1638 1657 17 215 2597 267 28 3 3277 33 331 3358 357 36 361 38 4 40 400 405 406 41 42 44 440 45 46 47 490 493 51 618 8 85`); grep for instance IDs 719/721/1581/2100/1337/2437/3456/2557 in `units.lua` → 0 each. README: "ships an entire database … huge database (~80 MB incl. all locales) that gets loaded into memory on game launch" (`pfQ:README.md:79`).
- **Loading: everything at once, at login, no lazy load.** All db files are plain Lua `<Include>`s in the TOC-referenced XMLs (`pfQ:init/data.xml:2-12`, `data-tbc.xml:2-11`); the only "layering" is `patchtable(pfDB[db]["data"], pfDB[db]["data"..exp])` for `-tbc`/`-wotlk` at `pfQ:database.lua:130-150` (shallow: `"_"` deletes a key, otherwise overwrite, `:22-30`), then `pfDatabase.Reload()` caches locals (`:300-312`).

### pfQuest-ascension data pack (`pfQuest-ascension/db/`)

- Ten `data-ascension` files are declared (`pfA:init/data-ascension.xml:2-11`), but **eight are empty tables** (`items-ascension.lua`, `objects-ascension.lua`, `quests-ascension.lua`, `quests-itemreq-ascension.lua`, `refloot-ascension.lua`, `areatrigger-ascension.lua`, `meta-ascension.lua` are 29–47 bytes each, e.g. `pfDB["quests"]["data-ascension"] = {\n}`), and all six `db/enUS/*-ascension.lua` are empty tables. `zones-ascension.lua:1` writes `pfDB["zones"]["data-turtle"] = {}` — a key the patch loop never reads (`pfA:patchtable.lua:121` looks for `"data-ascension"`), so it is a no-op leftover.
- The two real payloads: **`units-ascension.lua`** (50 KB, 280 top-level entries, bracketed by `-- Stormwind NPC Locations / -- Please do not make additions below this line.` at `:2-3` and `:2401-2402`) — same tuple shape, e.g. `[68] = { ["coords"] = { [1] = { 32.1, 49.9, 12, 900 }, ... [3] = { 66.1, 77.7, 1519, 900 } }, ["fac"] = "A", ["lvl"] = "55" }` (`pfA:db/units-ascension.lua:11-22`); 316 of its tuples are on zone 1519 (Stormwind), the rest on 1537/141/1657/10/405/… — and **`minimap-ascension.lua`** (219 lines) `pfDB["minimap-ascension"] = { [1] = { 4924, 3283 }, ... [718] = { 937, 624 }, [718] = { 570, 380 }, ... [1581] = { 499.26, 332.83 }, ... [11430] = { 500.01, 333.43 } }` — yard sizes for ~210 map IDs **including instance/dungeon IDs**, with duplicate keys (718, 796, 1337, 1977, 2100, 3277, 3358 — Lua keeps the last), and WotLK zone IDs 65/66/67 whose names in the vanilla zones locale are `"***On Map Dungeon***"` (a key-space collision the addon does not resolve).
- Merge (`pfA:patchtable.lua`): recursive `patchtable` (`:75-85`, recurses when both sides are tables — unlike core's shallow one), preceded by a hard-coded Stormwind offset: `if tbl[3] == 1519 then tbl[1] = tbl[1] + 6.8; tbl[2] = tbl[2] + 10.1` applied to every objects/units/areatrigger coordinate (`:86-118`), then `pfDatabase:Reload()` (`:141`).

### GatherMate2 / GatherMate2_Data (comparison)

- Live DB shape: `db[zone][id] = nodeid` where `id = self.mapData:EncodeLoc(x,y,level)` (`GM2:GatherMate2.lua:166-178`); one SavedVariable per node type (`GatherMate2HerbDB`, `…MineDB`, `…FishDB`, `…GasDB`, `…TreasureDB`, `…TreeDB`, `GM2:GatherMate2.toc:14`, `GM2:GatherMate2.lua:85-99`).
- **Packing: one integer per node** — `return floor( x * 10000 + 0.5 ) * 1000000 + floor( y * 10000  + 0.5 ) * 100 + level` (`GM2:LibMapDataExtract.lua:48-57`, x,y clamped ≤ 0.9999); decode `floor(id/1000000)/10000, floor(id % 1000000 / 100)/10000, id % 100` (`:59-61`). So x,y in 0..1 at 4-decimal precision, floor 0–99 in the low two digits.
- Zone key = `GetCurrentMapAreaID()`, floor = `GetCurrentMapDungeonLevel()` (`GM2:Collector.lua:236-237,652-653`).
- Data pack shape is the **inverse** of the live shape: `GatherMateData2MineDB = { [28] = { [201] = { 710973000,840981000,... }, [202] = {...} }, ... }` = `[zone][nodeID] = { coordInt, ... }` (`GMD:MiningData.lua:3-6`); merged by `for zoneID, node_table in pairs(sourcevar) do for nodeID, nodes in pairs(node_table) do for _, coord in ipairs(nodes) do GatherMate:InjectNode(zoneID, coord, ntype, nodeID)` (`GMD:GatherMateData.lua:69-75`). Header comment: `-- This data is collected from db.ascension.com` (`GMD:MiningData.lua:1`); `WorldforgeData.lua:1` cites `https://github.com/CoinThrow/BronzebeardMaps/tree/main/data`.
- Scale: Mining 11,017 nodes, Herbalism 13,901, Tree 11,284, Treasure 2,424, Fish 1,804, Worldforge 1,968, Gas 417; whole addon 540 KB. **Non-zero floors are present** — e.g. Mining zones `697:39 705:26 750:11 1201:11 728:10 …`, Herbalism `530:28 700:29 750:20 1201:20 …` (count of nodes with `id % 100 ~= 0` per zone key) — i.e. the pack ships per-dungeon-floor authored nodes for map IDs in the 5xx–12xx range.
- Loading: **lazy** — `## LoadOnDemand: 1`; loaded only by `LoadAddOn("GatherMate2_Data")` from the config "Import" button (`GM2:Config.lua:1360`) or auto-import (`:1740`), merged, then `CleanupImportData()` nils every `GatherMateData2*DB` global (`GMD:GatherMateData.lua:81-89`).

**REUSABLE MECHANISM**
- The GatherMate integer packing (`GM2:LibMapDataExtract.lua:48-61`) — one number per node, floor in the low digits, table-key-able, cheap to serialise and diff.
- Bucketing nodes by map/zone key first, then by coordinate key (`pfMap.nodes[addon][map]["x|y"]`, `pfQ:map.lua:451-452`; `db[zone][coordInt]`, `GM2:GatherMate2.lua:173-175`) so a per-map redraw touches only that bucket.
- The layered `base + diff` patch with a sentinel delete value (`"_"`, `pfQ:database.lua:22-30`; recursive variant `pfA:patchtable.lua:75-85`) — a shipped correction pack over a base without editing the base.
- LoadOnDemand + import-then-free (`GMD:GatherMateData.lua:81-89`) so a large data addon does not stay resident.

**POSTURE NOT TO INHERIT**
- Shipping ~75 MB of Lua that is loaded wholesale at login (`pfQ:README.md:79`, `pfQ:init/data.xml`) with no lazy path.
- Zone keys as vanilla AreaTable IDs matched to the world map by **localised zone name** (`pfQ:map.lua:362-368,408-425`), and yard sizes as a hand-shipped table with duplicate keys and cross-expansion key collisions (`pfA:db/minimap-ascension.lua`).
- A hard-coded per-map coordinate offset baked into the merge (`pfA:patchtable.lua:86-118`).
- GatherMate2_Data's per-dungeon, per-floor node lists (`GMD:MiningData.lua`, `HerbalismData.lua`) — this is exactly "shipping per-dungeon authored data" and is product-specific gathering content.

---

## 2. POSITION + DISTANCE

- Player position everywhere is `GetPlayerMapPosition("player")` (0..1 fractions of the current map): `pfQ:map.lua:879`, `pfQ:route.lua:57,177,334`. Multiplied by 100 to percent (`pfQ:map.lua:886`, `route.lua:58,193`).
- The map is kept on the player's zone by calling `SetMapToCurrentZone()` on `ZONE_CHANGED`/`MINIMAP_ZONE_CHANGED`/`ZONE_CHANGED_NEW_AREA` when the world map is closed (`pfQ:map.lua:975-988`) and once after the map closes (`:1035-1041`).
- **Minimap projection** (`pfQ:map.lua:895-904`): `mapID = pfMap:GetMapIDByName(GetRealZoneText())`; `mapZoom = Minimap:GetViewRadius() * 2` (yards); `mapWidth/Height = minimap_sizes[mapID][1|2]` (yards); `xScale = mapZoom / mapWidth`; `xDraw = pfMap.drawlayer:GetWidth() / xScale / 100` (pixels per map-percent); pin offset `xPos = (x - xPlayer) * xDraw`, `yPos = (y - yPlayer) * yDraw` (`:922-923`). Round-minimap cull `sqrt(xPos*xPos + yPos*yPos) + 8 < width/2`, square cull if `pfUI.minimap` (`:936-941`). Rotating minimap branch is marked `-- TODO: this part is broken and does not work yet.` (`:925-933`).
- **Routing distance is NOT yards.** `local x, y = (xplayer*100 - data[1])*1.5, yplayer*100 - data[2]; this.coords[id][4] = ceil(math.sqrt(x*x+y*y)*100)/100` (`pfQ:route.lua:193-194`) — Euclidean in map-percent with a fixed 1.5 x-scale for the 3:2 map aspect; the arrow's `Distance: %.1f` shows that number (`:430-432`). `GetNearest` (`:13-33`) is the same formula without the 1.5. No per-zone yard scaling is applied to distance anywhere in pfQuest; the yard table (`db/minimap*.lua`) is used only to size minimap pixels.
- **Arrow bearing** (`pfQ:route.lua:354-362`, comment `-- arrow positioning stolen from TomTomVanilla.` `:351`): `xDelta = (target[1] - xplayer*100)*1.5; yDelta = (target[2] - yplayer*100); dir = atan2(xDelta, -(yDelta)); ... angle = math.rad(dir) - pfQuestCompat.GetPlayerFacing()`. Facing comes from `GetPlayerFacing` if present, else the minimap arrow model's `:GetFacing()` (`pfQ:compat/client.lua:58-76`).
- 2-D only; no Z, no `UnitPosition`, no `CheckInteractDistance`, no GUID/target logic (grep: none of `UnitGUID`, `CheckInteractDistance`, `PLAYER_TARGET_CHANGED` in pfQuest).

**REUSABLE MECHANISM**
- The minimap pixel-per-percent derivation from `Minimap:GetViewRadius()` and a zone yard size (`pfQ:map.lua:896-904`), with distance-from-centre culling.
- The `GetPlayerMapPosition == 0,0` test as "no usable map here" (`pfQ:map.lua:880-883`, `route.lua:178`).
- Facing fallback chain (`pfQ:compat/client.lua:58-76`).

**POSTURE NOT TO INHERIT**
- Reporting and sorting on a map-percent pseudo-distance with a hard-coded 1.5 aspect factor (`pfQ:route.lua:193,354`) — meaningless across maps of different yard size, and unusable as a proximity threshold.
- Zone identity via `GetRealZoneText()` string round-trip (`pfQ:map.lua:895`) rather than a numeric map/area ID.

---

## 3. MARKERS / PINS

- **Node registry** (`pfMap:AddNode`, `pfQ:map.lua:427-514`): `pfMap.nodes[addon][map]["x|y"][title] = meta` (`:436-452`); identical-meta nodes share one table via `similar_nodes[sindex]` where `sindex = addon:map:coords:title:layer:spawn:item` (`:442-443,475-482`); duplicates by title at the same coordinate are dropped unless higher layer (`:455-472`); untextured spawn nodes are also appended to `unifiedcache[title][map][spawnOrItem].coords` (`:485-504`), from which one **cluster** pin per (quest, map, spawn) is later placed at the point with the most neighbours in a ±5% window (`getcluster`, `pfQ:database.lua:36-67`, cached by `name:count`). Any change sets `pfMap.queue_update = GetTime()` (`:513`).
- **World-map pins** (`pfMap:UpdateNodes`, `pfQ:map.lua:792-858`): iterates every node bucket for the current map, lazily creates `pfMap.pins[i] = pfMap:BuildNode("pfMapPin"..i, WorldMapButton)` (`:809-811`; a 16-px `Button` with a texture and a `hl` ring, `:647-675`), places at `x/100*WorldMapButton:GetWidth()` (`:840-844`), hides surplus pins (`:855-857`). **No pin cap, no distance cull on the world map**; every coordinate in the bucket becomes a pin. Redraw triggers: `queue_update` older than 0.25 s (`:1030-1033`) and `WORLD_MAP_UPDATE` when the viewed zone changed (`:991-994`).
- **Minimap pins** (`pfMap:UpdateMinimap`, `pfQ:map.lua:861-972`): called from `pfMap`'s `OnUpdate` throttled to every 0.05 s (`:1027,:1044`); early-outs for `minimapnodes == "0"`, Ctrl-held-over-minimap (hides all, `:867-876`), `0,0` position (hides all, `:878-883`), and unchanged position+zoom → at most once per second (`:889-891`). Pool `pfMap.mpins[i]` named `pfMiniMapPin<i>` (or `GatherNoteCompatFake<i>` if a minimap-button collector addon is present, `:6-25`). Draws only if `data[mapID] and minimap_sizes[mapID] and pfMap:HasMinimap(mapID)` (`:911`). Coordinate strings parsed once and cached (`coord_cache`, `:914-920`). Distance cull as in §2. Frame level `(minimap and 4 or 112) + layer` (`:767`).
- **Layering** by texture: `available`=1, `available_c`=2, `complete`=3, `complete_c`=4, `icon_vendor`=5, `fav`=6, cluster textures=9 (`:56-72`), clusters boosted by `10 - min(priority,10)` (`:446-448,:696-699`); per-pin the highest-layer meta wins (`pfMap:UpdateNode`, `:678-790`).
- **Animation** (`NodeAnimate`, `:99-138`): size/alpha eased per frame, step scaled by `fps = max(.2, GetFramerate()/30)` (`:1002`), driven from the OnUpdate loop over `pfMap.highlightdb` (`:1000-1024`) — runs only while `queue_update`, a transition, or a highlight state change is pending.
- Cost posture: no spatial index; each minimap pass walks all nodes of the current map (`:909-966`); each world-map pass walks all buckets; string keys `"x|y"` are split with `strfind` per pin (`:816`).
- Colours for untextured nodes hashed from the title (`str2rgb`, `:78-96`), user-overridable via `pfQuest_colors[title]` (`:80`, set by click `:591`).

**REUSABLE MECHANISM**
- Lazy pin pool + "hide the tail" (`pfQ:map.lua:809-811,855-857,944-945,969-971`).
- Two-stage refresh: dirty flag → debounced (0.25 s) full rebuild (`:513,:1030-1033`); minimap re-project only on position/zoom change with a 1 s floor (`:889-891`).
- Coordinate-keyed dedupe of overlapping markers with a layer priority (`:455-472`).
- The neighbour-count cluster pick (`pfQ:database.lua:36-67`) as a cheap "one representative point" for a spawn cloud.

**POSTURE NOT TO INHERIT**
- Uncapped world-map pin count driven by database volume (`:806-852`).
- Full-table minimap sweep at 20 Hz with string coordinate keys (`:909-966`).
- Broken/unused rotate-minimap branch shipped live (`:925-933`).

---

## 4. SEQUENCING / ROUTING

- **What enters the route:** in `pfMap:UpdateNodes` each drawn pin is added to the route plan if it is a cluster (`layer >= 9`, config `routecluster`), a quest ender (`layer == 4`, `routeender`), a starter (`layer 1/2`, `routestarter`), or `pin.arrow == true` (`pfQ:map.lua:818-826`; `pfQuest.route:AddPoint({ x, y, pin })`). Defaults: `routes=1, routecluster=1, routeender=1, routestarter=0, routeminimap=0, arrow=1` (`pfQ:config.lua:136-147`). Route and tracker are reset at the top of every `UpdateNodes` (`:800-803`).
- **Ordering** (`pfQ:route.lua:176-295`, `pfQuest.route` OnUpdate): distances to all points recomputed when the player moved or every 1 s (`:182`), never faster than 0.05 s (`:185`); `table.sort(this.coords, sortfunc)` by distance once per second (`:199-200`) — **nearest-first**; a user-picked target (Shift-free left-click on a routable pin → `pfQuest.route.SetTarget`, `pfQ:map.lua:580-588`; `SetTarget/IsTarget` `pfQ:route.lua:146-172`) is moved to index 1 (`:203-227`). When the first node changes, the objective path is rebuilt as a **greedy nearest-neighbour chain** starting from `coords[1]` (`:250-267`, `GetNearest` `:13-33`), with a rule that once one item-requirement object of a kind is in the chain, others of the same `itemreq` are blacklisted (`:258-266`). Lines are drawn as dotted 4-px `route` textures on `WorldMapButton.routes` and optionally the minimap (`DrawLine`, `:49-129`; player→first segment `:288-293`).
- **Arrow** (`pfQuest.route.arrow`, `pfQ:route.lua:304-470`): its own frame under `UIParent`, texture atlas cell = `modulo(floor(angle/(2π)*108 + 0.5), 108)` → 9 columns × 42-px rows (`:365-371`); alpha fades as `target[4] - area` where `area` is guessed from cluster `priority` (`:373-388`); title/description/distance texts (`:418-433`); shown only when a route exists, map is valid, `arrow == "1"`, and 1 s after last route recompute (`:233-235`).
- **Hand-off to TomTom: none in pfQuest.** The only TomTom reference is the credit comment (`pfQ:route.lua:351-353`); no `TomTom:` call, no `AddWaypoint`, no `SetCrazyArrow` (grep). The neighbour does have one: GatherMate2 world-map pin right-click → `TomTom:AddZWaypoint(GetCurrentMapContinent(), pin.zone, x*100, y*100, pin.title, nil, true, true)` guarded by `if TomTom then` (`GM2:Display.lua:160-165,193-199`).
- No cluster-then-order, no TSP, no "next objective" concept beyond "the nearest routable pin on the currently displayed map"; the tracker (`pfQ:tracker.lua`) lists quests and on click opens the log / toggles expand / colours (`:252-292`) — it does not select a route target.

**REUSABLE MECHANISM**
- The dirty-flag route rebuild keyed on "first node changed" (`pfQ:route.lua:246-278`) so re-sorting by distance is cheap and the chain is only recomputed when the head moves.
- Sticky user override of the head of the queue (`:146-172,:203-227`).
- Arrow atlas math and facing subtraction (`:354-371`) — self-contained, no library.
- Guarded optional TomTom export exactly as GatherMate2 does it (`GM2:Display.lua:160-165`).

**POSTURE NOT TO INHERIT**
- Greedy nearest-neighbour as the "route" (`pfQ:route.lua:250-267`) — order is emergent from position, not authored, and re-flips as the player moves.
- Route membership decided by pin texture/layer (`pfQ:map.lua:819-823`) rather than an explicit step list.
- Route contents wiped and rebuilt on every map redraw (`:800-803`).

---

## 5. DETECTION / COMPLETION

- **Events** (`pfQ:quest.lua:81-87`): `QUEST_WATCH_UPDATE`, `QUEST_LOG_UPDATE`, `QUEST_FINISHED`, `PLAYER_LEVEL_UP`, `PLAYER_ENTERING_WORLD`, `SKILL_LINES_CHANGED`, `ADDON_LOADED`. All handlers only set flags (`updateQuestLog` / `updateQuestGivers`, `:97-113`); an initial 10 s lock is extended 1.5 s per `QUEST_LOG_UPDATE` (`:93,:115-120`).
- **Poll:** the `pfQuest` OnUpdate ticks every 0.05 s and re-scans the quest log every 1 s regardless of events (`:127-135`), then drains a queue (`:154-223`).
- **Quest-log diff** (`pfQuest:UpdateQuestlog`, `:226-310`): iterates slots 1..40, gets `questid` via `pfDatabase:GetQuestIDs(qlogid)` — first `GetQuestLink` parse `|Hquest:(%d+):` (`pfQ:database.lua:1475-1481`), else title+level+race/class scoring with Levenshtein on objective/description text, cached in `pfQuest_questcache` (`:1483-1584`) — and builds a state string from `IsQuestWatched` + each `GetQuestLogLeaderBoard(i, qlogid)` `done` flag (`pfQ:quest.lua:243-252`). New/changed/removed → queue entries `NEW`/`RELOAD`/`REMOVE` (`:255-292`).
- **Objective done** (`pfDatabase:SearchQuestID`, `pfQ:database.lua:1134-1165`): if `complete` → return with only ender pins (`:1137-1138`; ender texture `complete_c` vs `complete`, `:1086-1096`); else each leaderboard line is parsed with `strfind(text, SanitizePattern(QUEST_MONSTERS_KILLED))` / `QUEST_OBJECTS_FOUND` to get name and `objNum/objNeeded`, mapped back to IDs by name (`GetIDByName`), and marked `"DONE"` or `"PROG"` (`:1145-1162`); `DONE` objectives are skipped when adding nodes (`:1218,:1232,:1247`).
- **Stop tracking a marker:** on `RELOAD`/`REMOVE` the addon deletes all nodes for that quest by title (and by DB title, for renamed servers) — `pfMap:DeleteNode("PFQUEST", entry[1])` (`pfQ:quest.lua:172-176,:191-196`) — then re-searches. Hooks: `RemoveQuestWatch` → delete nodes (`:567-580`), `AddQuestWatch` → flags (`:583-589`), `AbandonQuest` → remembers the name so history is not written (`:592-596`, `:164-168`). Manual: Shift-click a pin marks quest done + deletes (`pfQ:map.lua:568-579`); quest-log buttons Show/Hide/Clean/Reset (`pfQ:quest.lua:436-482`).
- **Item-requirement objectives** are re-evaluated on `BAG_UPDATE` (0.5 s debounce), comparing bag/equipment item names to a registry and forcing a quest reload (`pfQ:database.lua:166-235`).
- **Server-side history:** `/db query` → `QueryQuestsCompleted()` + `QUEST_QUERY_COMPLETE` → `GetQuestsCompleted()` fills `pfQuest_history` (`pfQ:database.lua:1766-1801`).
- **Proximity / "you are here": none.** No `UNIT_DIED`, no `COMBAT_LOG_EVENT_UNFILTERED`, no target/mouseover, no distance threshold anywhere (grep of all pfQuest Lua: none). The route arrow never "arrives"; the head of the queue only changes when the sort or the quest log changes.

**REUSABLE MECHANISM**
- Event → flag → throttled OnUpdate drain with a queue of typed changes (`pfQ:quest.lua:88-223`) — cheap and reload-safe.
- Quest-log slot diff with a compact per-quest state string (`:238-252`) to detect objective progress without parsing everything each tick.
- Deleting all markers by an owner key + title (`pfMap:DeleteNode`, `pfQ:map.lua:532-565`) so "stop tracking X" is one call.
- Debounced `BAG_UPDATE` item-presence registry (`pfQ:database.lua:166-235`).

**POSTURE NOT TO INHERIT**
- Locale-pattern parsing of leaderboard text (`QUEST_MONSTERS_KILLED`, `pfQ:database.lua:1146,:1158`) and name→ID reverse lookups as the completion signal.
- Levenshtein quest-ID guessing (`pfQ:database.lua:1513-1583`) — a consequence of a title-keyed shipped DB.
- Complete absence of any position-based completion — not something to copy, but the gap to note.

---

## 6. DUNGEON / INSTANCE HANDLING

- pfQuest has no instance branch. Its whole dungeon behaviour is the comment `-- hide nodes and skip further processing in dungeons` followed by `if xPlayer == 0 and yPlayer == 0 then … pin:Hide() … return end` (`pfQ:map.lua:878-883`); route arrow likewise hides on `wrongmap` (`pfQ:route.lua:178,:335-346`). Minimap drawing additionally requires a `minimap_sizes[mapID]` entry (`pfQ:map.lua:911`).
- Data: no coordinate references an instance area ID (see §1); no floor field; `GetCurrentMapDungeonLevel` unused (grep). Instance zone names do exist in the locale table (`[1581]="The Deadmines"`, `pfQ:db/enUS/zones.lua`) so `SearchZoneID` could name them, but `zones.lua` data has no bounding entry for them (grep `^  \[1581\]` in `db/zones.lua` → none).
- One custom map-name override: `local customids = { ["AlteracValley"] = 2597 }` used when the zone-name lookup fails (`pfQ:map.lua:403-405,:422`).
- **-ascension differences from stock:** (a) Stormwind NPC positions on map 1519 plus a blanket +6.8/+10.1 offset for that map (`pfA:patchtable.lua:86-118`, `pfA:db/units-ascension.lua`); (b) an expanded minimap yard-size table that *does* list instance map IDs (718, 719, 721, 796, 1337, 1581, 2100, 2557, 3456, 3457, 4100, 10007–10146, 11220/11221/11430 …) (`pfA:db/minimap-ascension.lua`) — but with no instance coordinates in any data table and no name→ID entry for many of those IDs, those rows are inert; (c) empty stubs for everything else. No custom zones or custom mapIDs are added to `zones` data (`zones-ascension.lua` is a no-op, §1).
- Ascension-specific edits inside pfQuest core itself: `Enum.ClassMask.*` for the custom class list incl. `HERO`, `NECROMANCER`, `REAPER`, `TINKER` … (`pfQ:database.lua:334-367`); `GetQuestLink` questID parse (`:1475-1481`); `QueryQuestsCompleted`/`GetQuestsCompleted` (`:1766-1801`); a 3.3.5 `WorldMapQuestFrame_OnMouseUp` hook that hides Blizzard quest blobs and highlights the selected quest's pins (`pfQ:map.lua:1055-1083`); `WorldMapPOIFrame.allowBlobTooltip` toggling (`:597-600,:637-640`).
- GatherMate2 for contrast **does** carry floors: `GetCurrentMapDungeonLevel()` at collect time (`GM2:Collector.lua:237`), world-map draw filtered `if nlevel == mapLevel` (`GM2:Display.lua:771-773`), minimap nearby-iterator requires `level2 == mLevel` (`GM2:GatherMate2.lua:239`); GatherHud hides in instances if configured (`Hud:GatherHud.lua:136-141`, `IsInInstance()`).

**REUSABLE MECHANISM**
- The `0,0` guard as a hard "no map data here, hide everything" fence (`pfQ:map.lua:878-883`).
- GatherMate2's floor-equality filter on both draw paths (`GM2:Display.lua:772`, `GM2:GatherMate2.lua:239`) as the minimal correct handling of multi-level maps.

**POSTURE NOT TO INHERIT**
- Treating instances as "outside the product" while still shipping instance yard sizes (`pfA:db/minimap-ascension.lua`) — dead data.
- Any per-instance NPC/object coordinate list (`pfA:db/units-ascension.lua` is the outdoor-city version of this) — this is authored per-map content.
- Baked map offsets (`pfA:patchtable.lua:86-118`).

---

## 7. SHARING / VERSIONING

- **Addon version broadcast:** `updatenotify.lua` computes `major*10000 + minor*100 + fix` from the TOC and sends `SendAddonMessage("pfQuest", "VERSION:"..version, chan)` to `BATTLEGROUND`/`RAID`/`GUILD` on `PLAYER_ENTERING_WORLD`/`PARTY_MEMBERS_CHANGED`; higher remote → `pfQuest_config.latest` and a chat notice (`pfQ:updatenotify.lua:9-56`). pfQuest-ascension repeats the scheme with prefix `"pfqe"` (`pfA:pfQuest-ascension.lua:9-69`), adds `PING?`/`PONG!` (`:37-42`, comment: `--This is a little check that I can use to see if people are actually using the addon.`).
- **Data pack vs addon:** no schema/version check between `pfQuest-ascension` and `pfQuest`; only `## Dependencies: pfQuest` (`pfA:pfQuest-ascension.toc:7`) and the merge runs blindly (`pfA:patchtable.lua:120-141`). Core sanity check is limited to "quests locale table empty → wrong language pack" (`pfQ:database.lua:286-296`) and a Hearthstone-tooltip locale probe (`:237-284`).
- **SavedVariables** (`pfQ:pfQuest.toc:8-9`): global `pfQuest_questcache` (title-signature → questIDs, `pfQ:database.lua:1492-1497,:1582`); per-character `pfQuest_config`, `pfBrowser_fav` (`{units={},objects={},items={},quests={}}` of id→name, `pfQ:browser.lua:5,:171-175`), `pfQuest_history` (`[questid] = { time(), UnitLevel("player") }`, `pfQ:quest.lua:167`; migration of legacy string keys `pfQ:config.lua:274-296`; wiped for fresh level-1 characters `:191-194`), `pfQuest_colors`, `pfQuest_server` (`items` from `/db scan`, `pfQ:database.lua:1665-1764`).
- **User-added markers: there are none.** All `pfMap:AddNode` callers are DB searches (`pfDatabase:Search*`, `pfQ:database.lua`), slash commands (`pfQ:slashcmd.lua:7` `meta = { ["addon"] = "PFDB" }`) or the browser (`pfQ:browser.lua:132,195`). Persistence of "what to show" is via favourites re-searched on login when `favonlogin == "1"` (`pfQ:browser.lua:634-655`). No import/export UI or string format exists in pfQuest.
- **GatherMate2:** data-pack import gated on `X-Generated-Version` (`GM2:Config.lua:1363-1372`; auto-import if newer than `db.importers[k].lastImport`, `:1734-1753`); merge styles `Merge` vs replace (`GMD:GatherMateData.lua:50-56,:63-78`), collision resolution `while db[zone][coords] do … coords = coords + 1000100 end` (`GM2:GatherMate2.lua:204-207`); per-type `dbLocks` (`GM2:GatherMate2.lua:51-58`); live guild/party/raid **node sharing** over AceComm prefix `"GatherMate2"` as `"%d:%s:%s:%d"` = zone:coordInt:type:nodeid (`GM2:DataShare.lua:24-35`, receive `:39-60`); user DBs are plain SavedVariables (`GM2:GatherMate2.toc:14`).

**REUSABLE MECHANISM**
- Numeric version encoded in one integer and gossiped over an addon channel (`pfQ:updatenotify.lua:22-24,:33-36`).
- Data-pack import keyed to a TOC metadata revision and remembered per profile (`GM2:Config.lua:1363-1372,:1736-1751`).
- One-line node wire format (`GM2:DataShare.lua:25`) — trivially serialisable because a node is an integer.
- Per-type DB locks (`GM2:GatherMate2.lua:51-58,:169-172`).

**POSTURE NOT TO INHERIT**
- Blind merge with no schema/version handshake between core and pack (`pfA:patchtable.lua`).
- Usage-census pings (`pfA:pfQuest-ascension.lua:37-42`).
- Title-keyed history/cache that then needs migration and Levenshtein repair (`pfQ:config.lua:274-296`, `pfQ:database.lua:1513-1583`).

---

## 8. GATHERMATE2 BRIEFLY

- **Storage/packing:** §1 — `db[zone][EncodeLoc(x,y,level)] = nodeID`; `EncodeLoc = floor(x*10000+.5)*1e6 + floor(y*10000+.5)*100 + level` (`GM2:LibMapDataExtract.lua:48-57`); zone = `GetCurrentMapAreaID()`; node names ↔ IDs via `GatherMate.nodeIDs` / `reverseNodeIDs` (`GM2:Constants.lua:15-260`).
- **Zone yard size:** derived at load, not shipped — `for i=0,9999 do local x1,y1 = C_WorldMap.GetWorldPosition(i, 0, 0) … x2,y2 = C_WorldMap.GetWorldPosition(i, 1, 1); dx,dy = abs(x1-x2), abs(y1-y2)` (`GM2:LibMapDataExtract.lua:15-33`), exposed as `MapArea(id)` (`:71-80`; note it ignores `level`). `C_WorldMap.*` is an Ascension client API (also used by `TomTom/TomTom.lua:897`).
- **Minimap cadence** (`GM2:Display.lua:233-243`): one OnUpdate frame; every 2 s (or on force) a full `UpdateMiniMap(true)` — re-queries `zone`, `level`, `GetPlayerMapPosition`, zoom, facing, and rebuilds the pin set from `FindNearbyNode(zone, x, y, level, db_type, mapRadius*nodeRange)` with `nodeRange = 2` and `mapRadius = Minimap:GetViewRadius()` (`:656-741`, `:44,:702,:722`); every other frame `UpdateIconPositions` re-places existing pins only if `x ~= lastX or y ~= lastY or facing ~= lastFacing or level ~= lastLevel or refresh` (`:591-650`). Zoom change → full update (`:596-601`, `MINIMAP_UPDATE_ZOOM` `:263`). Pins pooled/recycled (`recyclePin`, `:58-77`), keyed `(i * 1e14) + coord` (`:723`).
- **Distance-to-node math:** in the hot iterator, inline decode + `x = (x2 - xLocal) * yw; y = (y2 - yLocal) * yh; if x*x + y*y <= radiusSquared and level2 == mLevel` — i.e. yards² using the zone's yard width/height (`GM2:GatherMate2.lua:226-247`). Pin placement and per-pin distance defer to `Astrolabe:ComputeDistance(lastC, zone, lastX, lastY, GetCurrentMapContinent(), pin.zone, pin.x, pin.y)` and `Astrolabe:PlaceIconOnMinimap(...)` (`GM2:Display.lua:519,:550`) obtained via `DongleStub("Astrolabe-0.4")` (`:5`). **No Astrolabe file exists under any AddOns folder** (search of all `.lua/.xml/.toc`: only consumers — GatherMate2, TomTom); it resolves at runtime from something outside the addon tree, so its yard math is not auditable from files.
- **"Arrived at node" / tracking:** no arrival event. Within `db.trackDistance` (default 100 yd, `GM2:GatherMate2.lua:40`) a pin swaps to the coloured `track_circle` texture (`GM2:Display.lua:522-529`) and back beyond it (`:531-538`); beyond the view radius it fades `1-(dist/(radius*1.5))` and is dropped under 0.05 (`:542-547`). Node *creation/dedupe* is event-driven: `GAMEOBJECT_USED` with an object entry ID (`GM2:Collector.lua:83`, handler `:643-720`, mapping tables `mining/herbs/treasure/trees` `:316-641`) — an Ascension-only event — plus `UNIT_SPELLCAST_SENT/STOP/FAILED/INTERRUPTED`, `CURSOR_UPDATE`, `LOOT_CLOSED`, `COMBAT_LOG_EVENT_UNFILTERED` (gas), `CHAT_MSG_LOOT` (`:84-92`); a new node removes same-type nodes within `cleanupRange` (15 yd default) via `FindNearbyNode(zone,x,y,level,node_type,range,true)` (`:243,:266-276`); fishing/gas nodes are projected 20 yd ahead using the minimap arrow facing (`:292-300`); a repeat at the same packed coord+id is ignored (`:259`).
- **World map:** `UpdateWorldMap` iterates the zone bucket, keeps `nlevel == mapLevel` (`GM2:Display.lua:768-777`), places via `Astrolabe:PlaceIconOnWorldMap` (`:480`); redraw skipped if same zone+level and not forced (`:759`).
- **GatherHud** (Asc_Gathermate2 only): each update reads `GetPlayerMapPosition`, `GetCurrentMapAreaID`, `GetCurrentMapDungeonLevel`, `GatherMate:GetZoneSize(zoneID)` and iterates `FindNearbyNode(... settings.radius+settings.look_ahead)` (`Hud:GatherHud.lua:158-163,:254`); hides on `IsInInstance()`/resting/combat per settings (`:136-141`).

**REUSABLE MECHANISM**
- Integer node key + inline squared-yard radius test with floor equality (`GM2:GatherMate2.lua:226-247`) — the cheapest "what is near me on this floor" scan seen in either addon.
- Two-rate minimap loop: heavy rebuild at 2 s, light re-place per frame gated on movement (`GM2:Display.lua:233-243,:636`).
- Runtime-derived zone yard sizes from `C_WorldMap.GetWorldPosition` (`GM2:LibMapDataExtract.lua:15-33`) instead of a shipped table.
- Distance-banded pin state (icon → circle → fade → drop) (`GM2:Display.lua:522-547`).
- Guarded TomTom hand-off (`GM2:Display.lua:160-165`).

**POSTURE NOT TO INHERIT**
- Dependence on an unshipped positioning library resolved by name at runtime (`DongleStub("Astrolabe-0.4")`, `GM2:Display.lua:5`).
- The data pack's per-dungeon-floor node lists (`GMD:*Data.lua`, §1) and its collector's ~330-line hard-coded object-entry → node-ID tables (`GM2:Collector.lua:316-641`) — authored content, product-specific.
- Node identity by localised name in the live DB path (`GatherMate:GetIDForNode(type, name)`, `GM2:Collector.lua:250`).
