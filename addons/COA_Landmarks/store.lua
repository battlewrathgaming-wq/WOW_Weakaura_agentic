-- COA_Landmarks store.lua - THE storage module.
--
-- AC-53.2: this is the ONLY file that touches COA_LandmarksDB. Everything else
-- (widget, pins, beacon, editor, minimap) goes through this API. A rewrite
-- replaces this file, not a search across the addon.
--
-- Shape (AC-48):
--   COA_LandmarksDB = {
--     schemaVersion = 1,
--     nextId        = 8,
--     landmarks     = {
--       ["Winterspring-Everlook-7"] = {
--         alias = "Everlook 7", owner = "Gravekeeper",
--         what = "", why = "", tags = "vendor, alt",
--         icon = "questbonusobjective-supertracked", tier = "interact",
--         x=, y=, z=, mapID=, mapX=, mapY=, mapC=, mapZ=, zone=, subZone=,
--       },
--     },
--   }
--
-- ★★★ RULING: this file's laws are NUMBERED AND CITED (AC-46..) - a behaviour that
--   cannot name its law does not belong here. ★ The constitution, not a summary.
-- Laws in force here:
--   AC-46  one account-wide SV; `owner` is "global" or a character name
--   AC-47  id = zone-subzone-int, IMMUTABLE and OPAQUE. Lookups read the FIELDS.
--   AC-48  schemaVersion; refuse cleanly on a version we do not know
--   AC-49  data only - no functions, no caches, no derived values
--   AC-50  no index; iterate. Scale is bounded by the product (L11).
--   AC-51  hard delete; nextId NEVER rewinds
--   AC-52  session state is never persisted
--   AC-54  tags stored AS TYPED; we never alter or clean them up

local ADDON, NS = ...

local Store = {}
NS.Store = Store

Store.SCHEMA = 1
Store.DEFAULT_ICON = "questbonusobjective-supertracked"   -- AC-32
Store.DEFAULT_TIER = "interact"                           -- AC-40: match the game, ~5yd
Store.GLOBAL = "global"                                   -- AC-46

-- AC-22: the three tiers. Radii in yards; labels are the UI's words (AC-40).
Store.TIERS = {
    { key = "zone",     label = "Zone area",       yards = 300 },
    { key = "approach", label = "Within approach", yards = 100 },
    { key = "interact", label = "Interact with",   yards = 5   },
}

function Store.TierYards(key)
    for _, t in ipairs(Store.TIERS) do
        if t.key == key then return t.yards end
    end
    return Store.TierYards(Store.DEFAULT_TIER)
end

function Store.TierLabel(key)
    for _, t in ipairs(Store.TIERS) do
        if t.key == key then return t.label end
    end
    return key
end

-- ---------------------------------------------------------------------
-- Load. AC-48: read what we know, REFUSE what we do not. Never guess.
-- ---------------------------------------------------------------------

Store.locked = nil   -- non-nil = a reason string; every mutator is a no-op

function Store.Load()
    if type(COA_LandmarksDB) ~= "table" then
        COA_LandmarksDB = { schemaVersion = Store.SCHEMA, nextId = 1, landmarks = {} }
        return true
    end

    local v = COA_LandmarksDB.schemaVersion
    if v == nil then
        -- Unversioned data cannot be OUR data - v1 stamps from the first write.
        -- Guessing at its shape is the patching-on-patches AC-48 exists to refuse.
        Store.locked = "saved data has no schemaVersion - refusing to touch it"
    elseif v > Store.SCHEMA then
        Store.locked = ("saved data is schemaVersion %d, this build knows %d - "
            .. "refusing to touch it (downgrade or update the addon)"):format(v, Store.SCHEMA)
    end
    if Store.locked then return false, Store.locked end

    COA_LandmarksDB.landmarks = COA_LandmarksDB.landmarks or {}
    COA_LandmarksDB.nextId = COA_LandmarksDB.nextId or 1
    return true
end

local function db()
    return COA_LandmarksDB
end

-- ---------------------------------------------------------------------
-- UI state. AC-16: the widget's position persists PER CHARACTER, which lives
-- in the account file keyed by character - one SV, still (AC-46). This is
-- chrome, deliberately kept apart from `landmarks` so AC-49's "the record is
-- data only" stays literally true of the records themselves.
-- ---------------------------------------------------------------------

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

-- ---------------------------------------------------------------------
-- Identity + naming
-- ---------------------------------------------------------------------

-- AC-47: composed for UNIQUENESS and for LEGIBILITY of the stored file.
-- Uniqueness comes from `n`; the prefix is for a human reading the SV.
-- NOTHING may parse this back apart - the fields are the lookup.
local function composeId(zone, subZone, n)
    if subZone and subZone ~= "" and subZone ~= zone then
        return ("%s-%s-%d"):format(zone, subZone, n)
    end
    return ("%s-%d"):format(zone, n)          -- two parts, not three. Hence: opaque.
end

-- AC-4: the ALIAS carries only what we know - where, and when relative to others.
local function composeAlias(zone, subZone, n)
    local place = (subZone and subZone ~= "") and subZone or zone
    return ("%s %d"):format(place, n)
end

-- ---------------------------------------------------------------------
-- Capture. AC-6/AC-7: born where you stood, asks nothing.
-- ---------------------------------------------------------------------

-- ★★★ FACT: [SILENT] GetPlayerMapPosition returns 0,0 when the world map shows a DIFFERENT
--   zone (pfQuest guards identically). SetMapToCurrentZone fixes it - but is only
--   safe to call while the map is HIDDEN. ⚠ The single most common map-coord bug.
-- GetPlayerMapPosition returns 0,0 when the world map is showing a DIFFERENT
-- zone (pfQuest guards the same way). With the map closed we can snap it
-- invisibly; with it open we do not fight the user's view - we store nil and
-- backfill later (Store.Backfill). World coords are the truth either way (L5).
--
-- A fraction is meaningless without the MAP it was taken against. `mapID` is
-- ★★★ FACT: [SILENT] the mapID from GetCurrentPlayerPosition is the CONTINENT, not the zone
--   the world map draws. ⚠ A stored fraction is valid ONLY against the
--   continent+zone pair it was taken on - matching on mapID alone scatters
--   every pin across the continent.
-- the CONTINENT (F30), not the zone map the world map draws - so we also record
-- the continent/zone indices the fraction belongs to, and a pin only renders
-- when the map is showing that same pair (AC-34). Without this, every Kalimdor
-- landmark would draw on every Kalimdor zone map, at nonsense positions.
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

function Store.Create()
    if Store.locked then return nil, Store.locked end

    local x, y, z, mapID = GetCurrentPlayerPosition()
    if not x then return nil, "no player position available here" end

    local zone    = GetRealZoneText() or "Unknown"
    local subZone = GetSubZoneText() or ""
    local mx, my, mc, mz = mapFraction()

    local n = db().nextId
    db().nextId = n + 1                       -- AC-51: monotonic, never rewinds

    local id = composeId(zone, subZone, n)
    db().landmarks[id] = {
        alias   = composeAlias(zone, subZone, n),
        owner   = UnitName("player"),         -- AC-46: character-owned by default
        what    = "",
        why     = "",
        tags    = "",
        icon    = Store.DEFAULT_ICON,
        tier    = Store.DEFAULT_TIER,
        x = x, y = y, z = z, mapID = mapID,
        mapX = mx, mapY = my, mapC = mc, mapZ = mz,
        zone = zone, subZone = subZone,
    }
    return id, db().landmarks[id]
end

-- Fill in a map fraction we could not take at capture (see mapFraction).
-- Only ever ADDS what was missing; never rewrites a position (AC-2).
function Store.Backfill()
    if Store.locked then return 0 end
    local _, _, _, mapID = GetCurrentPlayerPosition()
    if not mapID then return 0 end
    local mx, my, mc, mz = mapFraction()
    if not mx then return 0 end

    -- We can only backfill a landmark we are standing at, since the fraction is
    -- OURS, not its. Anything else would be inventing a position.
    local n = 0
    for _, lm in pairs(db().landmarks) do
        if lm.mapX == nil and lm.mapID == mapID and lm.zone == GetRealZoneText() then
            local dx, dy = lm.x - select(1, GetCurrentPlayerPosition()),
                           lm.y - select(2, GetCurrentPlayerPosition())
            if math.sqrt(dx * dx + dy * dy) < 10 then
                lm.mapX, lm.mapY, lm.mapC, lm.mapZ = mx, my, mc, mz
                n = n + 1
            end
        end
    end
    return n
end

-- ---------------------------------------------------------------------
-- Read. AC-50: iterate; AC-46: filter on `owner`.
-- ---------------------------------------------------------------------

function Store.Get(id)
    if Store.locked then return nil end
    return db().landmarks[id]
end

-- ★ SHOW-ALL: the recovery path for ORPHANED records.
--
-- Delete a character and its landmarks remain in the file with an `owner` no
-- one will ever match again - present, unreachable, and unrecoverable. We
-- cannot detect this: holding no roster is deliberate (AC-5a), so we never
-- learn a character is gone. The answer is therefore NOT detection, it is a
-- way to STOP FILTERING and let the user see what is there.
--
-- SESSION-ONLY, deliberately: this is a recovery mode, not a view preference.
-- It should be off every login, because "everything on the account" is not the
-- normal way to look at your own landmarks.
Store.showAll = false

local function visibleToMe(lm)
    if Store.showAll then return true end
    return lm.owner == Store.GLOBAL or lm.owner == UnitName("player")
end
Store.VisibleToMe = visibleToMe

-- Is this record reachable in the NORMAL view? Used to mark orphans plainly.
function Store.IsMine(lm)
    return lm.owner == Store.GLOBAL or lm.owner == UnitName("player")
end

-- Sorted by id so the order is stable between calls (the UI must not shuffle).
function Store.Visible()
    local out = {}
    if Store.locked then return out end
    for id, lm in pairs(db().landmarks) do
        if visibleToMe(lm) then out[#out + 1] = { id = id, lm = lm } end
    end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

-- AC-47: matched on the STORED FIELD, never on a substring of the id.
function Store.ForMap(mapID)
    local out = {}
    for _, e in ipairs(Store.Visible()) do
        if e.lm.mapID == mapID then out[#out + 1] = e end
    end
    return out
end

function Store.Count()
    local n = 0
    for _ in pairs(Store.locked and {} or db().landmarks) do n = n + 1 end
    return n
end

-- ---------------------------------------------------------------------
-- Tags. AC-54: stored AS TYPED. Split/trim happens HERE, on read, never on write.
-- ---------------------------------------------------------------------

function Store.SplitTags(s)
    local out = {}
    for tag in tostring(s or ""):gmatch("[^,]+") do
        tag = tag:match("^%s*(.-)%s*$")
        if tag ~= "" then out[#out + 1] = tag end
    end
    return out
end

-- AC-54a: autocomplete's source. We own NO vocabulary - this is a mirror of
-- what the user has already typed, offered back. Never a managed list.
--
-- `exclude` is the landmark being EDITED, and it is not optional in practice.
-- We save on every keystroke (AC-54: as typed), so the half-word in the box is
-- already stored - and without this the suggestion is your own typing handed
-- back. Excluding the edited record also stops us offering a tag it already
-- carries, which would only ever produce a duplicate.
function Store.KnownTags(exclude)
    local seen, out = {}, {}
    for _, e in ipairs(Store.Visible()) do
      if e.id ~= exclude then
        for _, tag in ipairs(Store.SplitTags(e.lm.tags)) do
            local k = tag:lower()             -- de-dup the OFFER only; never the DATA
            if not seen[k] then
                seen[k] = true
                out[#out + 1] = tag           -- offered exactly as they typed it
            end
        end
      end
    end
    table.sort(out, function(a, b) return a:lower() < b:lower() end)
    return out
end

function Store.SuggestTags(prefix, exclude)
    prefix = tostring(prefix or ""):lower()
    if prefix == "" then return {} end
    local out = {}
    for _, tag in ipairs(Store.KnownTags(exclude)) do
        -- prefix match, and never offer back exactly what is already typed
        if tag:lower() ~= prefix and tag:lower():find(prefix, 1, true) == 1 then
            out[#out + 1] = tag
        end
    end
    return out
end

-- ★ AC-5c: owners BUILT FROM THE RECORD, never constructed (Battlewrath).
-- Exactly the rule the tag pool follows (AC-54a): we mirror what is in the data
-- and assemble no list of our own. We still never learn who your characters are
-- - only who OWNS something here, which is a different and smaller claim.
-- Excludes "global" and the current character: neither is a transfer SOURCE.
function Store.KnownOwners()
    local me, seen, out = UnitName("player"), {}, {}
    for _, lm in pairs(Store.locked and {} or db().landmarks) do
        local o = lm.owner
        if o and o ~= Store.GLOBAL and o ~= me and not seen[o] then
            seen[o] = true
            out[#out + 1] = o
        end
    end
    table.sort(out)
    return out
end

-- Reassign EVERY landmark owned by `from`. The target is ME or GLOBAL - the
-- same two forms `owner` has always had (AC-46), so this control wraps up BOTH
-- transfer and delete-recovery without inventing a third state.
--
-- You can only claim for whoever is logged in, or for everyone; there is no
-- "give it to that other character", because that would need the roster we
-- deliberately do not keep (AC-5a).
function Store.TransferOwner(from, toGlobal)
    if Store.locked then return 0, Store.locked end
    if not from or from == "" or from == Store.GLOBAL then return 0, "no source" end
    local to, n = toGlobal and Store.GLOBAL or UnitName("player"), 0
    for _, lm in pairs(db().landmarks) do
        if lm.owner == from then
            lm.owner = to
            n = n + 1
        end
    end
    return n
end

-- ---------------------------------------------------------------------
-- Write. AC-2: everything is editable EXCEPT the position and the id.
-- ---------------------------------------------------------------------

local EDITABLE = { alias = true, what = true, why = true, tags = true,
                   icon = true, tier = true, owner = true }

function Store.Set(id, field, value)
    if Store.locked then return false, Store.locked end
    if not EDITABLE[field] then
        -- AC-2: no edit path may relocate a landmark, and AC-47's id is immutable.
        return false, ("field '%s' is not editable"):format(tostring(field))
    end
    local lm = db().landmarks[id]
    if not lm then return false, "no such landmark" end
    lm[field] = value                          -- AC-54: stored exactly as given
    return true
end

-- AC-5 / AC-46: promotion and demotion are THE SAME OPERATION - write one field.
-- No file movement, so there is no half-completed state to deform the data.
function Store.SetOwner(id, global)
    return Store.Set(id, "owner", global and Store.GLOBAL or UnitName("player"))
end

-- AC-51: hard delete, no tombstone. nextId is untouched, so the deleted id is
-- never handed to a different landmark and AC-4's freshness ordering survives.
function Store.Delete(id)
    if Store.locked then return false, Store.locked end
    if not db().landmarks[id] then return false, "no such landmark" end
    db().landmarks[id] = nil
    return true
end

return Store
