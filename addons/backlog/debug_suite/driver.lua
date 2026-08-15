-- COA_DungeonRun driver.lua - THE ROUTE DRIVER, prototype.
--
-- Spec: addons/planning/dungeonrun_poc.md §60, §71, §73, §74.
--
-- ---------------------------------------------------------------------------
-- ★★ WHY THIS EXISTS BEFORE THE BEHAVIOURS DO (Battlewrath, 2026-08-14):
--
--   *"I think we should focus on the prototype consumer of the beacons and
--   tracking. I can't forecast the behaviours we need to define blind."*
--
-- Same shape as capture: build the thing that CONSUMES, and the behaviours declare
-- themselves. §60 sketched a mini-map, note planes, cue text and progression gates
-- - building any of that now would turn a sketch into a spec by accident.
--
-- So this is the smallest thing that can be WALKED: arm a route, scan for the
-- current stage, say when you reach it, advance. *"For now we just need to see the
-- system have legs."*
--
-- ---------------------------------------------------------------------------
-- ★ THE RUNTIME IS LOCATION-DRIVEN, AND THIS IS THE FIRST PLACE THAT BITES.
--
-- §64 drew the line: authoring is driven by what is LOADED, the in-route consumer
-- by where the PLAYER is. The promoter asks Map.AuthoringMapID(); this asks the
-- client where you are standing, and offers only routes for that dungeon. His
-- ruling, from the other direction: *"They can not start in-route content of
-- another map out of zone."*
--
-- ---------------------------------------------------------------------------
-- ★ THE BASELINE IS COA_Landmarks' INTERACT TIER - 5 yards, his call: *"for first
-- test we'll do a baseline of interact that landmark uses. So I want on the point."*
--
-- Landmarks already carries the tiered vocabulary §60 sketched for beacons
-- (store.lua:43-45): zone 300 · approach 100 · interact 5. Starting at the tightest
-- tier means a satisfied stage is unambiguous - you were THERE, not near - which is
-- what a first walk needs to prove the loop at all.
--
-- Height uses §73's ruled default of ±2.5 yd. The one measured stack (a walkway
-- 9.71 yd above its floor, 3.12 yd apart planar) is excluded by it with room to
-- spare, and same-surface reads agree to 0.00-0.09.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Driver = {}
NS.Driver = Driver

local Map, Store, Routes
local frame, widget, title, dd, armBtn, readout

local route, routeId, index, armed
local INTERACT = 5.0        -- yards, planar. COA_Landmarks store.lua:45
local Z_BAND   = 2.5        -- yards, +/-. §73's ruled default

-- ★★ §79: THE RATCHET, and it is the whole of "assertion".
--
--   *"Baseline self+1 ratchet. Select dropdown for custom, and you just provide a
--   number... All the same mechanism."*
--
-- One expression covers both a plain advance and a checkpoint, and because the max
-- is IN it rather than beside it, nothing can walk the index backwards - a loop that
-- re-crosses a checkpoint, or one touched on the way back, is inert. That is what
-- makes checkpoints safe to scatter without reasoning about traversal order.
function Driver.Promote(current, outcome)
    if not outcome then return current end
    return math.max(current or 0, outcome)
end

-- ★ SELF-MEASURED, because this is the FIRST per-frame thing in the addon and the
-- CLEU work refused to accept "almost certainly free" as an answer. Reported on
-- stop, so a walk tells us what headroom a real driver has.
local scans, spent = 0, 0

function Driver.Cost()
    if scans == 0 then return 0, 0 end
    return scans, spent / scans
end

-- Where the player is, in the same world units a beacon carries. One call, and the
-- 4th return is the internal mapID (NOT GetCurrentMapAreaID - maps/worldmap M8).
local function here()
    local x, y, z, mapID = GetCurrentPlayerPosition()
    return x, y, z, mapID
end

local function inInstance()
    if not IsInInstance then return false end
    local inside = IsInInstance()
    return inside and true or false
end

-- ★★ FACT: a walkway 9.71 yd above its floor sits only 3.12 yd away on the map (measured)
-- ★★ RULING: [CULTURE] the driver INFORMS, it never grades - no completion count, no "you missed"
-- ★ THE TEST, and it is PLANAR AND VERTICAL - never one alone.
--
-- §73 proved why with a case built for it: a walkway 9.71 yd above its floor sits
-- 3.12 yd away on the map. Any range worth having spans that, so a planar-only test
-- fires the wrong beacon every time you walk underneath. Nothing but z separates
-- them.
--
-- Pure, so the geometry can be asserted without a player.
-- ★★★ §85: THE BAND IS ASYMMETRIC, and that is a different question rather than a
-- tuning of the old one. Battlewrath: *"Our current height manner is below/above
-- (-/+). really it is the above we care about. As now we can select ledges
-- specifically."*
--
-- A symmetric band can only WIDEN until it catches the floor AND the ledge above it.
-- An asymmetric one can say *the ledge, not the floor under it* - which is the
-- distinction §73 measured and could not previously express: a walkway 9.71 yd up
-- sits 3.12 yd away on the map, so planar range alone always spans both.
--
-- ⚠ `up` IS THE ONE THAT MATTERS and `down` is usually small. A beacon on a walkway
-- wants a generous reach upward for the player standing on it and almost none
-- downward, or it fires for everyone walking beneath.
--
-- ★ COMPATIBLE BY CONSTRUCTION: called with one band it behaves exactly as it did,
-- symmetric, so every existing caller and every stored radius is untouched. The
-- asymmetry is opt-in by passing the second value.
function Driver.Reached(px, py, pz, bx, by, bz, radius, band, down)
    if not (px and bx) then return false end
    local dx, dy = px - bx, py - by
    if dx * dx + dy * dy > radius * radius then return false end
    -- No height requirement is a legitimate option (§73's `None`), and it means a
    -- SPHERE rather than an infinite cylinder - so the planar test above already
    -- did the work and z is simply not consulted.
    if not band then return true end
    -- ⚠ SIGNED, NOT ABSOLUTE. `dz > 0` means the PLAYER IS ABOVE the beacon, which is
    -- the ledge case - so it is measured against `band`. Below the beacon is measured
    -- against `down`, which defaults to `band` and keeps the old behaviour.
    local dz = (pz or 0) - (bz or 0)
    if dz >= 0 then return dz <= band end
    return -dz <= (down or band)
end

-- The beacon's position: PLACED if it was dragged, else where it was born (§68's
-- new-else-original). A dragged beacon carries world coordinates only when the
-- calibration could produce them, so this can legitimately answer nil - and a stage
-- we cannot place is one we cannot satisfy, which the scan has to survive rather
-- than error on.
local function beaconAt(b)
    if not b then return nil end
    local wx, wy = Routes.WorldOf(b)
    return wx, wy, b.z
end

local function say(msg) NS.Say(msg) end

-- ★ Stages print with %g, not %d: a stage is a LABEL and 4.1 is an ordinary one.
local function label(n) return ("%g"):format(n or 0) end

local function report()
    if not readout then return end
    if not armed then readout:SetText("") return end
    local b = Routes.BeaconAt(routeId, index)
    if not b then readout:SetText("route complete") return end
    local n = Routes.Count(routeId)
    local px, py, pz = here()
    local bx, by, bz = beaconAt(b)
    if not bx then
        readout:SetText(("stage %s of %d  |cffff8080no world position|r")
            :format(label(b.stage), n))
        return
    end
    local d = math.sqrt((px - bx) ^ 2 + (py - by) ^ 2)
    readout:SetText(("stage %s of %d   %.0f yd   dz %.1f")
        :format(label(b.stage), n, d, math.abs((pz or 0) - (bz or 0))))
end

-- ★ ONE STAGE UNDER TEST, never the route. §73: retry-until-match makes the scan
-- cheap, because a stage that cannot be satisfied by proximity alone stays under
-- test until it is - and once satisfied, stops being tested at all.
local function scan()
    if not armed or not route then return end
    local t0 = debugprofilestop and debugprofilestop() or 0

    local b = Routes.BeaconAt(routeId, index)
    if b then
        local px, py, pz = here()
        local bx, by, bz = beaconAt(b)
        if Driver.Reached(px, py, pz, bx, by, bz, INTERACT, Z_BAND) then
            local name = Routes.NameOf(b)
            say(("|cff55ff55stage %s|r reached%s")
                :format(label(b.stage),
                        (name and name ~= "") and (" - " .. name) or ""))
            -- ★ The ONE promotion. A plain beacon resolves to self+1; a checkpoint
            -- to the number its author typed. Neither can move the index backwards.
            index = Driver.Promote(index, Routes.Outcome(b))
            if not Routes.BeaconAt(routeId, index) then
                say(("|cffffd100route complete|r - %d stage(s)"):format(Routes.Count(routeId)))
                Driver.Stop()
                return
            end
        end
    end

    if debugprofilestop then
        scans = scans + 1
        spent = spent + (debugprofilestop() - t0)
    end
    report()
end

-- ⚠ The parameter is `id`, NOT `routeId`: naming it routeId shadowed the file-local
-- of the same name, so every consumer below would have read a nil route id while
-- Arm itself worked perfectly. Caught by the census pass, not by a test.
function Driver.Arm(id)
    local r = Routes.Get(id)
    if not r then say("no route named |cffffd100" .. tostring(id) .. "|r") return end
    if #(r.beacons or {}) == 0 then say("that route has no beacons") return end
    local _, _, _, mapID = here()
    -- Location-driven (§64). A route for another dungeon cannot be started here,
    -- and saying so beats silently scanning for something 400 yards underground.
    if r.mapID and mapID and r.mapID ~= mapID then
        say("that route is for another dungeon - you must be in it")
        return
    end
    -- ★ Start at the FIRST BEACON'S OWN STAGE, not at 1. Stage is a label and
    -- DeleteBeacon leaves gaps, so a route whose first beacon is stage 2 is ordinary
    -- - and starting at a hardcoded 1 would arm it pointing at nothing.
    routeId = id
    local first = Routes.StageOrder(routeId)[1]
    route, index, armed = r, (first and first.stage) or 1, true
    scans, spent = 0, 0
    frame:SetScript("OnUpdate", scan)
    say(("driving |cffffd100%s|r - %d stage(s), interact %g yd, height ±%g")
        :format(r.name ~= "" and r.name or id, #r.beacons, INTERACT, Z_BAND))
    report()
    return true
end

function Driver.Stop()
    if not armed then return end
    armed, route, routeId, index = nil, nil, nil, nil
    frame:SetScript("OnUpdate", nil)
    local n, per = Driver.Cost()
    if n > 0 then
        say(("stopped - %d scan(s), %.4f ms each (%.1f%% of a 60fps frame)")
            :format(n, per, per / 16.67 * 100))
    else
        say("stopped")
    end
    report()
end

function Driver.Armed() return armed and true or false end
function Driver.Stage() return index end
function Driver.Route() return route end

-- ★ IN-DUNGEON ONLY, and offered from where you STAND rather than what is loaded.
local function initDropdown()
    local _, _, _, mapID = here()
    local list = (inInstance() and mapID) and Routes.List(mapID) or {}
    if #list == 0 then
        local h = UIDropDownMenu_CreateInfo()
        h.text = inInstance() and "no routes for this dungeon" or "not in a dungeon"
        h.isTitle = 1; h.notCheckable = 1
        UIDropDownMenu_AddButton(h)
        return
    end
    for _, e in ipairs(list) do
        local b = UIDropDownMenu_CreateInfo()
        b.text = e.id
        b.notCheckable = 1
        b.func = function() UIDropDownMenu_SetText(dd, e.id); Driver.Arm(e.id) end
        UIDropDownMenu_AddButton(b)
    end
end

function Driver.Init()
    Map, Store, Routes = NS.Map, NS.Store, NS.Routes

    frame = CreateFrame("Frame")

    widget = CreateFrame("Frame", "COA_DungeonRunDriver", UIParent)
    widget:SetWidth(240); widget:SetHeight(110)
    widget:SetPoint("CENTER", UIParent, "CENTER", -420, 200)
    widget:SetFrameStrata("DIALOG")
    widget:SetMovable(true); widget:EnableMouse(true); widget:RegisterForDrag("LeftButton")
    widget:SetScript("OnDragStart", function(self) self:StartMoving() end)
    widget:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, _, x, y = self:GetPoint()
        Store.SetUI("driverPos", { p = p, x = x, y = y })
    end)
    widget:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    widget:Hide()

    title = widget:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 18, -16)
    title:SetText("Route")

    dd = CreateFrame("Frame", "COA_DungeonRunDriverLoad", widget, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", 2, -32)
    UIDropDownMenu_Initialize(dd, initDropdown)
    UIDropDownMenu_SetWidth(dd, 160)
    UIDropDownMenu_JustifyText(dd, "LEFT")
    UIDropDownMenu_SetText(dd, "- pick a route -")

    armBtn = CreateFrame("Button", nil, widget, "UIPanelButtonTemplate")
    armBtn:SetWidth(60); armBtn:SetHeight(20)
    armBtn:SetPoint("TOPRIGHT", -14, -36)
    armBtn:SetText("Stop")
    armBtn:SetScript("OnClick", function() Driver.Stop() end)

    readout = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    readout:SetPoint("TOPLEFT", 18, -68)
    readout:SetWidth(204); readout:SetJustifyH("LEFT")

    local ui = Store.GetUI()
    if ui.driverPos then
        widget:ClearAllPoints()
        widget:SetPoint(ui.driverPos.p, UIParent, ui.driverPos.p, ui.driverPos.x, ui.driverPos.y)
    end

    -- No OnUpdate here: it is installed by Arm and cleared by Stop, so the census
    -- keeps reporting zero persistent.
    return widget
end

function Driver.Toggle()
    if not widget then return end
    if widget:IsShown() then widget:Hide() else widget:Show(); report() end
end
