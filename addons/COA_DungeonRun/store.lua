-- COA_DungeonRun store.lua - THE storage module.
--
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
--         outside = <point or nil>,   -- where you zoned in FROM (a different map, F38)
--         arrival = <point or nil>,   -- the in-instance origin
--         markers = { <marker>, ... },  -- combat start/end pairs, in order
--         legs    = { <point>, ... },   -- ~1/s travel samples, out of combat only
--       },
--     },
--   }
--
--   <point>  = x,y,z,mapID · mapX,mapY,mapC,mapZ · zone,subZone · t,gt
--   <marker> = <point> + kind="start"|"end" + n=<pull index> [+ dead=true]
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
local function mapFraction()
    local shown = WorldMapFrame and WorldMapFrame:IsShown()
    if not shown and SetMapToCurrentZone then
        pcall(SetMapToCurrentZone)
    end
    local mx, my = GetPlayerMapPosition("player")
    if not mx or (mx == 0 and my == 0) then return nil, nil, nil, nil end
    local c = GetCurrentMapContinent and GetCurrentMapContinent() or nil
    local z = GetCurrentMapZone and GetCurrentMapZone() or nil
    return mx, my, c, z
end

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

    local mx, my, mc, mz = mapFraction()
    return {
        x = x, y = y, z = z, mapID = mapID,
        mapX = mx, mapY = my, mapC = mc, mapZ = mz,
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

function Store.AddLeg(id, point, ghost)
    local r = Store.Get(id)
    if not r or not point then return nil end
    if ghost then point.ghost = true end       -- corpse runs stay legible (DR-13)
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

-- DR-31: boss engagements. Every engagement is recorded, NOT a distinct set -
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

function Store.Counts(id)
    local r = Store.Get(id)
    if not r then return 0, 0 end
    local pulls = 0
    for _, m in ipairs(r.markers) do
        if m.kind == "start" then pulls = pulls + 1 end
    end
    return pulls, #r.legs
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
