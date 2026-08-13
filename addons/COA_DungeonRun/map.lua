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

-- ★ TWO DIFFERENT SIZES, AND CONFUSING THEM IS A SILENT SCALE ERROR.
--
-- The stock layout (WorldMapFrame.xml:528-548):
--     WorldMapDetailFrame   1002 x 668   <- the fraction 0..1 maps across THIS
--     WorldMapDetailTile    256 x 256, laid 4x3 = 1024 x 768  <- OVERHANGS it
--
-- The tile grid is power-of-two art with dead padding; the map's coordinate space
-- is the DETAIL FRAME. Placing across the tile grid instead stretches everything
-- by +2.2% horizontally and +15% VERTICALLY - which draws a trail that still
-- follows corridors and is wrong everywhere, worst furthest from the origin.
-- Caught by eye on the first art-bearing draw: "there is some displacement as a
-- constant across them."
local TILE_COLS, TILE_ROWS, TILE_PX = 4, 3, 256    -- the ART grid
local ART_W, ART_H = 1002, 668                     -- the COORDINATE space
local DOT_PX = 8                                   -- §19: 32 is the CELL size, not the draw size
local MARK_PX = 16                                 -- an EVENT reads larger than a SAMPLE

-- ★ THE MARKER SET (Battlewrath's picks, all verified `claimed: false` in the
-- atlas census, and all four on ONE texture - so the whole display is a single
-- texture load with four crops).
--
--   leg          playerneutral                     white ring, yellow centre
--   start        warfronts...horde-...barracks     crossed swords, RED
--   end (alive)  warfronts...alliance-...barracks  crossed swords, BLUE
--   end (dead)   islands-markedarea                a red CROSS
--
-- His colour language: **red danger, blue safe.** Start is where it began, end is
-- where it was over - and a TERMINAL STOP is neither, so it gets its own mark
-- rather than a tint. That marker is the one carrying route MEANING (`killedBy`
-- hangs off it), so it should not read as a variation of "safe again".
--
-- `w`/`h` are the CELL sizes, and they are not all square: 37x35 for the swords.
-- Draw size preserves that ratio - a squashed glyph reads as a different icon.
local ATLAS = "Interface\\Minimap\\ObjectIconsAtlas"
local ART = {
    leg   = { 0.475586, 0.506836, 0.637695, 0.668945, 32, 32, DOT_PX  },
    start = { 0.299805, 0.335938, 0.585938, 0.620117, 37, 35, MARK_PX },
    done  = { 0.605469, 0.641602, 0.293945, 0.328125, 37, 35, MARK_PX },
    dead  = { 0.541992, 0.573242, 0.438477, 0.469727, 32, 32, MARK_PX },
}

-- Exposed so the smoke can assert the two are not conflated again.
function Map.ArtSize() return ART_W, ART_H end
function Map.TileGrid() return TILE_COLS * TILE_PX, TILE_ROWS * TILE_PX end

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
-- Which map a run belongs to. `instance.mapID` is DR-30's 8th return; runs from
-- before it fall back to the mapID their own points carry.
function Map.MapIDOf(run)
    if not run then return nil end
    if run.instance and run.instance.mapID then return run.instance.mapID end
    local first = (run.markers and run.markers[1]) or (run.legs and run.legs[1]) or run.arrival
    return first and first.mapID or nil
end

function Map.RunsFor(mapID)
    local out = {}
    if not mapID then return out end
    for _, id in ipairs(Store.Ids()) do
        if Map.MapIDOf(Store.Get(id)) == mapID then out[#out + 1] = id end
    end
    return out
end

-- ★ The tile art for a run, with the IN-ZONE FALLBACK §22 promised.
--
-- DR-34 stores `mapFile` at capture, which is what makes a run drawable from
-- anywhere. Runs captured BEFORE it carry none - and the first draw showed the
-- consequence plainly: correct dots on an empty canvas. In zone we can still ask
-- the client, because GetMapInfo() answers for the map you are standing on.
--
-- ★ GUARDED ON IDENTITY, and that guard is the whole point: without it, opening a
-- pre-DR-34 Shadowfang run while standing in Ragefire would draw Shadowfang's
-- route onto RAGEFIRE'S ART - a picture that looks entirely plausible and is
-- completely wrong. Nothing else in the display can produce that failure.
function Map.ArtFor(run, hereMapID, hereFile)
    if run and run.mapFile and run.mapFile ~= "" then return run.mapFile end
    if run and hereFile and hereFile ~= "" and hereMapID
       and Map.MapIDOf(run) == hereMapID then
        return hereFile
    end
    return nil
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

-- ★ Which art a point draws with. Pure, because getting it wrong is SILENT:
-- every wrong answer still renders a legible marker in the right place, and only
-- someone reading the route can tell it lied about what happened there.
--
-- A terminal stop is an END that is `dead` - checked FIRST, because it is the
-- more specific claim and the one that carries meaning.
function Map.ArtKey(point)
    if not point or not point.kind then return "leg" end
    if point.kind == "end" then
        return point.dead and "dead" or "done"
    end
    if point.kind == "start" then return "start" end
    return "leg"
end

-- Returns left, right, top, bottom, drawW, drawH - the draw size preserving the
-- cell's aspect ratio, so a 37x35 glyph is never squashed square.
function Map.ArtForPoint(point)
    local a = ART[Map.ArtKey(point)]
    local px = a[7]
    local w, h = a[5], a[6]
    local dw, dh = px, px * (h / w)
    return a[1], a[2], a[3], a[4], dw, dh
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
        local t = d:CreateTexture(nil, "OVERLAY")
        t:SetAllPoints(d)
        -- §19 trap: SetTexture RESETS TexCoord. The texture is set ONCE here; the
        -- crop is set per point in paint(), which is after it in every path.
        t:SetTexture(ATLAS)
        d.tex = t
        dots[i] = d
    end
end

-- Markers draw ABOVE legs. A pull start sitting under 300 travel samples would be
-- invisible exactly where it matters most - and the pool is drawn in list order,
-- which puts legs last.
local function styleDot(d, point)
    local l, r, t, b, dw, dh = Map.ArtForPoint(point)
    d:SetWidth(dw); d:SetHeight(dh)
    d.tex:SetTexCoord(l, r, t, b)
    d:SetFrameLevel(canvas:GetFrameLevel() + (point.kind and 2 or 1))
end

local function clearDots()
    for _, d in ipairs(dots) do d:Hide() end
end

local function paint(run, floor)
    local _, _, _, hereMapID = GetCurrentPlayerPosition()
    local hereFile = GetMapInfo and GetMapInfo() or nil
    local mapFile = Map.ArtFor(run, hereMapID, hereFile)
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
        styleDot(d, p)
        d:ClearAllPoints()
        d:SetPoint("CENTER", canvas, "TOPLEFT", dx, dy)
        d:Show()
    end

    -- Say WHY the canvas is empty rather than presenting a blank one. A run with
    -- no art and no in-zone fallback is a KNOWN limitation (pre-DR-34), not a
    -- fault, and the readout should not leave that to be guessed at.
    floorText:SetText(("floor %s  |  %d point%s%s")
        :format(tostring(floor), #pts, #pts == 1 and "" or "s",
                mapFile and "" or "  |  no map art (pre-DR-34 run, and not in its zone)"))
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
    local gw, gh = Map.TileGrid()
    frame:SetWidth(gw + 32); frame:SetHeight(gh + 72)
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

    -- The canvas IS the coordinate space (1002x668). The tiles are anchored to its
    -- TOPLEFT and overhang to the right and bottom, which is exactly what the stock
    -- detail frame does - the overhang is the art's padding, not map content.
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
