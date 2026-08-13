-- COA_DungeonRun map.lua - display STAGE ONE: one run, drawn on our own map frame.
--
-- Spec: addons/planning/dungeonrun_poc.md §17 §19 §20.1 §20.2 §21.
-- NOT in this stage: comparison/A:B, tinting, the colour picker, filtering, editing,
-- and anything for the live "guide me now" case. Those are §20.3/20.4 and later.
--
-- ---------------------------------------------------------------------------
-- ★ THE PLACEMENT RULE (§17): THE ADDON NEVER LEARNS DUNGEONS.
--
-- A point is placed from what the CLIENT told us at capture time:
--     (mapX, mapY)  the client's own fraction, computed against the right floor
--     floor         DR-33
--     mapFile       DR-34, the tile art name
-- No bounding box, no DBC, no shipped table, no per-dungeon anything. The addon
-- stores what the client said and draws it back onto the client's own art, so it
-- can never be behind on a dungeon it has not seen.
--
-- (addons/maps/worldmap/ proves the fractions are exactly what the DBC boxes give -
-- zero residual on 706 points across two dungeons and eight floors - but that is
-- DESK-side verification. Nothing here reads it.)
--
-- ★ AND WE COMPOSE OUR OWN FRAME rather than touching WorldMapFrame. The map is
-- twelve tiled textures at a predictable path (M1), so rebuilding it costs a loop
-- and buys: no conflict with any addon that hooks the stock map, pan/zoom that the
-- stock map does not have at all, and the ability to show a dungeon you are not
-- standing in - which the stock UI cannot do (its START POSITION is locked to the
-- player, though the art is addressable from anywhere).
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Map = {}
NS.Map = Map

local Store

local TILE_COLS, TILE_ROWS, TILE_PX = 4, 3, 256    -- stock layout: 12 tiles, 4x3
local ART_W, ART_H = TILE_COLS * TILE_PX, TILE_ROWS * TILE_PX
local DOT_PX = 8                                   -- §19: 32 is the CELL size, not the draw size

local frame, canvas, tiles, dots, title, floorText, prevBtn, nextBtn
local shownRunId, shownFloor

-- ---------------------------------------------------------------------
-- PURE SELECTION + PLACEMENT. Deliberately free of frames so the smoke can
-- assert the arithmetic and the filtering without a UI at all - the parts that
-- can be wrong silently are the parts that must be testable.
-- ---------------------------------------------------------------------

-- Which runs belong to this map?
--
-- ★ We match on the mapID the RUN's own points carry, which came from
-- GetCurrentPlayerPosition() at capture. Display reads it from the SAME call, so
-- capture and display cannot disagree about identity.
--
-- Deliberately NOT GetCurrentMapAreaID(): it is off by one from the internal id
-- (M8 - the client's own code subtracts it) AND it indexes WorldMapArea rows,
-- which is a different id space from the one our points carry. Two ways to be
-- wrong, for no gain.
function Map.RunsFor(mapID)
    local out = {}
    if not mapID then return out end
    for _, id in ipairs(Store.Ids()) do
        local r = Store.Get(id)
        local m = r and (r.instance and r.instance.mapID)
        if not m and r then
            local first = (r.markers and r.markers[1]) or (r.legs and r.legs[1]) or r.arrival
            m = first and first.mapID
        end
        if m == mapID then out[#out + 1] = id end
    end
    return out
end

-- Every point of a run that sits on one floor.
--
-- A run captured before DR-33 has no floor at all. Those are NOT discarded: a
-- single-floor dungeon has nothing to be ambiguous about, so a nil floor matches
-- whatever floor is being shown. On a multi-floor map such a run simply predates
-- the field, and drawing it on every floor would be a lie - so it is only ever
-- offered where there is one floor to be on (the caller decides that).
function Map.PointsOn(run, floor)
    local out = {}
    if not run then return out end
    for _, list in ipairs({ run.legs or {}, run.markers or {} }) do
        for _, p in ipairs(list) do
            if p.mapX and (p.floor == floor or p.floor == nil) then
                out[#out + 1] = p
            end
        end
    end
    return out
end

-- Fraction -> pixel offset from the canvas TOPLEFT.
--
-- mapY runs DOWNWARD (fraction 0 is the top edge), which is why y is negated:
-- SetPoint from TOPLEFT takes a negative y to move down.
function Map.Offset(point, w, h)
    if not point or not point.mapX then return nil end
    return point.mapX * w, -(point.mapY * h)
end

-- M7: the floor selects a SUFFIX, not a different file, and only when > 0.
function Map.TilePath(mapFile, floor, i)
    if not mapFile or mapFile == "" then return nil end
    local base = mapFile
    if floor and floor > 0 then base = mapFile .. floor .. "_" end
    return ("Interface\\WorldMap\\%s\\%s%d"):format(mapFile, base, i)
end

-- ---------------------------------------------------------------------
-- Frame
-- ---------------------------------------------------------------------

local function ensureDots(n)
    for i = #dots + 1, n do
        local d = CreateFrame("Button", nil, canvas)
        if Mixin and WorldMapPOIMixin then Mixin(d, WorldMapPOIMixin) end
        d:SetWidth(DOT_PX); d:SetHeight(DOT_PX)
        local t = d:CreateTexture(nil, "OVERLAY")
        t:SetAllPoints(d)
        t:SetTexture("Interface\\Minimap\\ObjectIconsAtlas")
        -- §19 trap: SetTexture RESETS TexCoord, so the crop goes AFTER it, never
        -- before, or the whole 1024-square sheet draws as one dot.
        t:SetTexCoord(0.475586, 0.506836, 0.637695, 0.668945)   -- playerneutral
        d.tex = t
        dots[i] = d
    end
end

local function clearDots()
    for _, d in ipairs(dots) do d:Hide() end
end

local function paint(run, floor)
    local mapFile = run and run.mapFile
    for i = 1, TILE_COLS * TILE_ROWS do
        local path = Map.TilePath(mapFile, floor, i)
        tiles[i]:SetTexture(path)
    end

    local pts = Map.PointsOn(run, floor)
    clearDots()
    ensureDots(#pts)
    for i, p in ipairs(pts) do
        local dx, dy = Map.Offset(p, ART_W, ART_H)
        local d = dots[i]
        d:ClearAllPoints()
        d:SetPoint("CENTER", canvas, "TOPLEFT", dx, dy)
        d:Show()
    end

    floorText:SetText(("floor %s  |  %d point%s")
        :format(tostring(floor), #pts, #pts == 1 and "" or "s"))
    title:SetText(run and run.name or "no run")
end

-- ★ §20.2: LOCATION SEEDS THE VIEW. Read from the same calls capture used, so
-- the two cannot disagree. Not a constraint - a selected run overrides it (§22),
-- which is stage two's dropdown; stage one only needs the default.
local function context()
    local _, _, _, mapID = GetCurrentPlayerPosition()
    local floor = GetCurrentMapDungeonLevel and GetCurrentMapDungeonLevel() or nil
    return mapID, floor
end

function Map.Show(runId)
    if not frame then return end
    local mapID, floor = context()

    if not runId then
        local ids = Map.RunsFor(mapID)
        runId = ids[#ids]                      -- most recent for where you are
    end
    local run = runId and Store.Get(runId)
    if not run then
        NS.Say("no run recorded for this map yet.")
        return
    end

    shownRunId = runId
    shownFloor = floor or (run.arrival and run.arrival.floor) or 0
    paint(run, shownFloor)
    frame:Show()
end

function Map.Toggle()
    if not frame then return end
    if frame:IsShown() then frame:Hide() else Map.Show() end
end

local function step(delta)
    if not shownRunId then return end
    shownFloor = (shownFloor or 0) + delta
    if shownFloor < 0 then shownFloor = 0 end
    paint(Store.Get(shownRunId), shownFloor)
end

function Map.Init()
    Store = NS.Store
    tiles, dots = {}, {}

    frame = CreateFrame("Frame", "COA_DungeonRunMap", UIParent)
    frame:SetWidth(ART_W + 32); frame:SetHeight(ART_H + 72)
    frame:SetPoint("CENTER")
    frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    frame:Hide()

    title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 18, -16)
    floorText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    floorText:SetPoint("BOTTOMLEFT", 18, 16)

    canvas = CreateFrame("Frame", nil, frame)
    canvas:SetWidth(ART_W); canvas:SetHeight(ART_H)
    canvas:SetPoint("TOPLEFT", 16, -40)
    for i = 1, TILE_COLS * TILE_ROWS do
        local t = canvas:CreateTexture(nil, "BACKGROUND")
        t:SetWidth(TILE_PX); t:SetHeight(TILE_PX)
        local col, row = (i - 1) % TILE_COLS, math.floor((i - 1) / TILE_COLS)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", col * TILE_PX, -row * TILE_PX)
        tiles[i] = t
    end

    prevBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    prevBtn:SetWidth(52); prevBtn:SetHeight(20)
    prevBtn:SetPoint("BOTTOMRIGHT", -74, 14)
    prevBtn:SetText("< floor")
    prevBtn:SetScript("OnClick", function() step(-1) end)

    nextBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    nextBtn:SetWidth(52); nextBtn:SetHeight(20)
    nextBtn:SetPoint("BOTTOMRIGHT", -16, 14)
    nextBtn:SetText("floor >")
    nextBtn:SetScript("OnClick", function() step(1) end)

    -- No OnUpdate anywhere: the display is redrawn on demand, never per frame.
    return frame
end
