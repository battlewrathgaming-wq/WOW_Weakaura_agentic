-- COA_DungeonRun store.lua - THE storage module.
--
-- ★★★ RULING: exactly ONE module touches the saved-variables global (DR-20)
--   ★ A rewrite then replaces THIS FILE rather than a search across the addon.
--   Same law as COA_Landmarks AC-53.2, which paid for itself across five rounds
--   of live fixes.
-- DR-20: this is the ONLY file that touches COA_DungeonRunDB. capture.lua,
-- widget.lua and core.lua all go through this API, so a rewrite replaces this
-- file rather than a search across the addon. (Same law as COA_Landmarks
-- AC-53.2, which paid for itself across five rounds of live fixes.)
--
-- Shape:
--   COA_DungeonRunDB = {
--     schemaVersion = 1,
--     nextId        = 2,
--     runs = {
--       ["Ragefire clockwise-1"] = {
--         name = "Ragefire clockwise", character = "Gravekeeper",
--         armedAt = 1755..., closedAt = 1755...,
--         mapFile = "ShadowfangKeep", mapW = 668, mapH = 768,   -- DR-34
--         outside = <point or nil>,   -- where you zoned in FROM (a different map, F38)
--         arrival = <point or nil>,   -- the in-instance origin
--         markers = { <marker>, ... },  -- combat start/end pairs, in order
--         legs    = { <point>, ... },   -- ~1/s travel samples, out of combat only
--       },
--     },
--   }
--
--   <point>  = x,y,z,mapID · mapX,mapY,mapC,mapZ · floor · zone,subZone · t,gt
--   <marker> = <point> + kind="start"|"end" + n=<pull index> [+ dead=true]
--   <leg>    = <point> [+ ghost=true] [+ combat=true + n=<pull index>]   -- DR-35
--
-- Laws in force here (addons/planning/dungeonrun_poc.md):
--   DR-4   BOTH clocks on every point: t=time() joins, gt=GetTime() measures
--   DR-6   record EVERY combat - no filtering at capture, ever
--   DR-9   a point is written as captured; we never clean, merge or dedupe
--   DR-20  one module owns the DB
--   DR-21  schemaVersion; refuse cleanly on a version we do not know

local ADDON, NS = ...

local Store = {}
NS.Store = Store

Store.SCHEMA = 1

Store.locked = nil    -- non-nil = a reason string; every mutator becomes a no-op

-- ---------------------------------------------------------------------
-- Load. DR-21: read what we know, REFUSE what we do not. Never guess.
-- ---------------------------------------------------------------------

function Store.Load()
    if type(COA_DungeonRunDB) ~= "table" then
        COA_DungeonRunDB = { schemaVersion = Store.SCHEMA, nextId = 1, runs = {} }
        return true
    end

    local v = COA_DungeonRunDB.schemaVersion
    if v == nil then
        Store.locked = "saved data has no schemaVersion - refusing to touch it"
    elseif v > Store.SCHEMA then
        Store.locked = ("saved data is schemaVersion %d, this build knows %d - "
            .. "refusing to touch it (downgrade or update the addon)"):format(v, Store.SCHEMA)
    end
    if Store.locked then return false, Store.locked end

    COA_DungeonRunDB.runs = COA_DungeonRunDB.runs or {}
    COA_DungeonRunDB.nextId = COA_DungeonRunDB.nextId or 1
    return true
end

local function db() return COA_DungeonRunDB end

-- ---------------------------------------------------------------------
-- Points
-- ---------------------------------------------------------------------

-- Same guard COA_Landmarks uses: GetPlayerMapPosition returns 0,0 when the
-- world map is showing a DIFFERENT zone. With the map closed we snap it
-- invisibly; with it open we do not fight the user's view and store nil.
-- World coords are the truth either way - the fraction is for drawing.
-- ★ DR-33: the FLOOR comes back from here too, and it is captured under the SAME
-- trust boundary as the fraction, deliberately.
--
-- `GetCurrentMapDungeonLevel()` reports the level the WORLD MAP IS SHOWING, not
-- ★★ FACT: [SILENT] GetCurrentMapDungeonLevel reports the floor the WORLD MAP IS SHOWING,
--   not the player's. They agree only after SetMapToCurrentZone.
-- the one the player stands on. Those agree only after SetMapToCurrentZone, which
-- we call when the map is closed and refuse to call when it is open (we do not
-- fight the user's view). So an untrusted fraction and an untrusted floor arrive
-- together, and both are recorded as nil rather than as a plausible wrong number.
--
-- WHY IT MUST BE CAPTURED AT ALL: 42 of the 43 multi-floor dungeons stack their
-- floors over the same footprint - 6 share one identical box across every floor,
-- 36 overlap - so **the floor cannot be recovered from world x/y afterwards**
-- (addons/maps/worldmap/README.md M6). And `z` cannot rescue it either:
-- ★ CORRECTED 2026-08-14: the client DOES carry per-floor z bounds, in
-- DungeonMapChunk.dbc (maps/worldmap M10) - we had only read DungeonMap.dbc. It
-- stays impossible for US anyway, for a sharper reason: that table is keyed by
-- WMOGroupID and no Lua call reports which WMO group the player is in. Z alone
-- cannot substitute - Shadowfang's floors 1, 2 and 7 all carry the "no bound"
-- sentinel. The data exists; the KEY to it is not exposed.
local function mapFraction()
    local shown = WorldMapFrame and WorldMapFrame:IsShown()
    if not shown and SetMapToCurrentZone then
        pcall(SetMapToCurrentZone)
    end
    local mx, my = GetPlayerMapPosition("player")
    if not mx or (mx == 0 and my == 0) then return nil, nil, nil, nil, nil end
    local c = GetCurrentMapContinent and GetCurrentMapContinent() or nil
    local z = GetCurrentMapZone and GetCurrentMapZone() or nil
    local floor = GetCurrentMapDungeonLevel and GetCurrentMapDungeonLevel() or nil
    return mx, my, c, z, floor
end

-- ★★★ RULING: BOTH clocks on every point, and they are not redundant (DR-4)
--   `time()` is the ONLY thing that can join a run to the client's own /combatlog
--   disk stream, and it is UNRECOVERABLE after the fact. `GetTime()` is monotonic
--   and sub-second, and is the right tool for durations WITHIN a session only.
-- DR-4: BOTH clocks, and they are not redundant.
--   t  = time()     wall-clock. The ONLY thing that can join a run to the
--                   client's own /combatlog disk stream as a second witness.
--                   Not recoverable after the fact - hence DR-4's "must not
--                   get wrong" status.
--   gt = GetTime()  monotonic session timer. Sub-second, and the right tool
--                   for durations WITHIN a session. Meaningless across one.
function Store.Point()
    local x, y, z, mapID = GetCurrentPlayerPosition()
    if not x then return nil end

    local mx, my, mc, mz, floor = mapFraction()
    return {
        x = x, y = y, z = z, mapID = mapID,
        mapX = mx, mapY = my, mapC = mc, mapZ = mz,
        -- DR-33. Without it a multi-floor run is PERMANENTLY unplaceable, which
        -- puts it in the same class as the wall-clock stamp and the travel legs:
        -- addable later only for runs not yet captured.
        floor = floor,
        zone = GetRealZoneText() or "Unknown",
        subZone = GetSubZoneText() or "",
        t = time(), gt = GetTime(),
    }
end

-- ---------------------------------------------------------------------
-- Runs
-- ---------------------------------------------------------------------

-- Composed for LEGIBILITY of the saved file; uniqueness comes from `n` alone,
-- exactly as COA_Landmarks AC-47 does it. The name is stored AS TYPED (DR-9) -
-- the key is a separate concern from the name the user reads.
local function composeId(name, n)
    local base = (name and name:match("^%s*(.-)%s*$")) or ""
    if base == "" then base = GetRealZoneText() or "run" end
    return ("%s-%d"):format(base, n)
end

function Store.Open(name)
    if Store.locked then return nil, Store.locked end

    local n = db().nextId
    db().nextId = n + 1                        -- monotonic; never rewinds

    local id = composeId(name, n)
    db().runs[id] = {
        name      = name or "",
        character = UnitName("player"),
        armedAt   = time(),
        outside   = nil,
        arrival   = nil,
        markers   = {},
        legs      = {},
    }
    return id, db().runs[id]
end

function Store.Get(id)
    if Store.locked or not id then return nil end
    return db().runs[id]
end

function Store.Close(id)
    local r = Store.Get(id)
    if r then r.closedAt = time() end
    return r
end

-- ★ §48's LIMITED MANAGEMENT. "The sample collected is its own source of truth and
-- not governed bar limited management." Rename, comment, delete - all RUN-level.
-- Nothing anywhere removes a single point: if it matters you promote a copy out
-- (§29), and if it does not you hide it (§43).
--
-- Rename is safe BECAUSE id and name were separated at capture: the name is stored
-- as typed, the id is `name-n`, and uniqueness comes from `n` alone. So this moves
-- the label and no handle - nothing that references the run needs rewiring.
function Store.Rename(id, name)
    local r = Store.Get(id)
    if not r or type(name) ~= "string" then return nil end
    r.name = name:match("^%s*(.-)%s*$")
    return r.name
end

-- 40 characters, his number. His own example is the proof it fits: "bad run but
-- good pull around 178" is 32. A descriptor, not a log - and the field is CAPPED
-- rather than silently truncated at the edge, so it cannot grow into one.
Store.COMMENT_MAX = 40

function Store.SetComment(id, text)
    local r = Store.Get(id)
    if not r then return nil end
    text = type(text) == "string" and text:match("^%s*(.-)%s*$") or ""
    if #text > Store.COMMENT_MAX then text = text:sub(1, Store.COMMENT_MAX) end
    r.comment = text ~= "" and text or nil
    return r.comment
end

function Store.Delete(id)
    if Store.locked or not id then return end
    db().runs[id] = nil
end

function Store.Ids()
    local out = {}
    if Store.locked then return out end
    for id in pairs(db().runs) do out[#out + 1] = id end
    table.sort(out)
    return out
end

-- ---------------------------------------------------------------------
-- Appending. DR-6/DR-9: written as captured. No filter, no dedupe, no merge.
-- Every judgement about what a record MEANS happens offline, against the
-- whole set - "better to be rich and find faults, than lean and never find
-- bounds" (Battlewrath).
-- ---------------------------------------------------------------------

-- DR-32: `killedBy` - the distinct attackers from the client's own death recap,
-- attached to a TERMINAL STOP. One consumed field; see DRIVER_CONTRACT.md.
--
-- `unavailable` carries the REASON when attribution could not be read, rather than
-- leaving a silent absence. A missing key would imply nothing killed us.
function Store.AddMarker(id, point, kind, n, dead, killedBy, unavailable)
    local r = Store.Get(id)
    if not r or not point then return nil end
    point.kind, point.n = kind, n
    if killedBy then point.killedBy = killedBy end
    if unavailable then point.killedByUnavailable = unavailable end
    -- Only stamped when TRUE. A `dead` key present on a marker means the pull
    -- ended with the player dead; absent means it did not. Without this field a
    -- wipe and a clean finish are INDISTINGUISHABLE in the record and no later
    -- editor can ever offer the trim (DR-13).
    if dead then point.dead = true end
    r.markers[#r.markers + 1] = point
    return point
end

-- DR-35: `pullIndex` non-nil means the sample was taken DURING that pull.
--
-- Both fields are written, and neither is redundant: `combat` is the qualifier the
-- display keys off (exactly as `ghost` is), and `n` says WHICH pull - the join that
-- lets curation isolate one pull's movement later. The pull index is free, because
-- capture is already counting it.
function Store.AddLeg(id, point, ghost, pullIndex)
    local r = Store.Get(id)
    if not r or not point then return nil end
    if ghost then point.ghost = true end       -- corpse runs stay legible (DR-13)
    if pullIndex then point.combat, point.n = true, pullIndex end
    r.legs[#r.legs + 1] = point
    return point
end

function Store.SetOutside(id, point)
    local r = Store.Get(id)
    if r and not r.outside then r.outside = point end
    return r and r.outside
end

function Store.SetArrival(id, point)
    local r = Store.Get(id)
    if r and not r.arrival then r.arrival = point end
    return r and r.arrival
end

-- DR-30: the instance identity, write-once at arrival. A normal and a heroic pass
-- through the same dungeon are DIFFERENT ROUTES, so difficulty is route identity
-- rather than decoration.
--
-- Signature read from the client, not assumed - `RaidProfiles.lua:540` unpacks all
-- seven: name, instanceType, difficultyIndex, difficultyName, maxPlayers,
-- dynamicDifficulty, isDynamic.
function Store.SetInstance(id, info)
    local r = Store.Get(id)
    if r and not r.instance then r.instance = info end
    return r and r.instance
end

-- DR-34: the tile art identity, write-once. Kept on the RUN rather than on each
-- point because it is constant for the whole run - the floor selects a suffix, not
-- a different file. Without it a run is displayable IN ZONE ONLY.
-- ★ `terrain` rides with the art because it is a fact about the SAME thing and
-- comes from the same moment: M7 - the client subtracts one from the dungeon level
-- when a map uses a terrain base, so the tile name for a given floor differs. Ours
-- did not, which on such a dungeon loads the wrong floor's art under the right
-- points. Stored rather than asked at display time, because DungeonUsesTerrainMap()
-- answers about the map being SHOWN, and §22 edits a route from a city.
--
-- Written only when TRUE, so an absent key means "not a terrain map, or captured
-- before we knew to ask" - and both take today's behaviour.
function Store.SetMapArt(id, file, w, h, terrain)
    local r = Store.Get(id)
    if not r or not file or r.mapFile then return nil end
    r.mapFile, r.mapW, r.mapH = file, w, h
    if terrain then r.mapTerrain = true end
    return r.mapFile
end

-- DR-31: BOSS-TAGGED UNITS per pull (not "bosses" - §58). Every firing is recorded, NOT a distinct set -
-- "better to be rich and find faults, than lean and never find bounds". A boss
-- engaged twice (wipe, then re-pull) is two records, and the distinct set is a
-- one-line fold offline.
--
-- We record only what this route ENGAGED. Never a roster, never a fraction:
-- "2 of 4 bosses" needs a denominator that is CONTENT, and content lives out of
-- our data. The user supplies it - they know the dungeon.
function Store.AddBoss(id, names, pullIndex)
    local r = Store.Get(id)
    if not r or not names or #names == 0 then return nil end
    r.bosses = r.bosses or {}
    local e = { names = names, n = pullIndex, t = time(), gt = GetTime() }
    r.bosses[#r.bosses + 1] = e
    return e
end

-- ---------------------------------------------------------------------
-- Counting, for the widget's live readout
-- ---------------------------------------------------------------------

-- DR-36 adds a third count. Callers that want two still get two - the pin count is
-- appended, so nothing that already unpacks (pulls, legs) has to change.
function Store.Counts(id)
    local r = Store.Get(id)
    if not r then return 0, 0, 0 end
    local pulls, pins = 0, 0
    for _, m in ipairs(r.markers) do
        if m.kind == "start" then pulls = pulls + 1
        elseif m.kind == "pin" then pins = pins + 1 end
    end
    return pulls, #r.legs, pins
end

-- ---------------------------------------------------------------------
-- ★ §61/§62: THE SECOND AND THIRD DATA FORMS live in the same file, and DR-20
-- still holds. This module owns the GLOBAL; routes.lua owns the SHAPE of what
-- lives under these keys. So there is still exactly one file that touches
-- COA_DungeonRunDB, and DR-21's schema refusal covers routes and notes for free
-- rather than needing a second copy of it.
--
-- Kept as separate keys rather than folded into `runs` because they are separate
-- OBJECTS (§61): a run is evidence, a route is authored, a personal note is yours.
-- A route must be exportable without carrying a capture, and a personal note must
-- never travel with a route at all.
-- ---------------------------------------------------------------------

function Store.RouteTable()
    if Store.locked then return nil end
    local d = db()
    d.routes = d.routes or {}
    return d.routes
end

function Store.NoteTable()
    if Store.locked then return nil end
    local d = db()
    d.notes = d.notes or {}
    return d.notes
end

-- The same monotonic counter runs serve, and deliberately the SAME one: ids are
-- `name-n` and n never rewinds, so a route and a run can never collide on a handle
-- even though they live in different tables.
function Store.NextRouteId()
    if Store.locked then return nil end
    local n = db().nextId
    db().nextId = n + 1
    return n
end

-- Session-only UI state, kept apart from `runs` so the records stay data only.
function Store.GetUI()
    if Store.locked then return {} end
    local d = db()
    d.ui = d.ui or {}
    local me = UnitName("player") or "?"
    d.ui[me] = d.ui[me] or {}
    return d.ui[me]
end

function Store.SetUI(key, value)
    if Store.locked then return end
    Store.GetUI()[key] = value
end

-- ★★★ §97: THE UI RUN RECORD, and it lands HERE because DR-20 says exactly one
-- module touches COA_DungeonRunDB. `ui.lua` drives the panes and has no business
-- knowing the shape of the file.
--
-- ⚠ ONE RUN ONLY, overwritten each time. This is a TEST record, not a history:
-- keeping every run would grow the saved variables without anyone asking, and the
-- repo lands the one that matters. ★ By-exception applied to storage rather than to
-- chat.
--
-- ★ The steps go in as they are - expected AND actual on every one, including the
-- ones that matched - because a step recording only "passed" cannot be re-examined
-- when the run as a whole turns out to be wrong.
function Store.SetUIRun(id, steps)
    if Store.locked then return end
    Store.SetUI("uiRun", { id = id, at = time(), steps = steps })
end

function Store.UIRun()
    return Store.GetUI().uiRun
end
