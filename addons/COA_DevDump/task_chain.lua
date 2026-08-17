-- task_chain.lua - W6: WALK A REAL ROUTE WITH CLEARS AND SETS.
--
-- Battlewrath, 2026-08-17: *"We have the data. Pick a dungeon. Pick a run. Load a
-- sequence of the X,Y,Z. Walk through them with clears and sets."*
--
-- ★★★ THIS IS THE ONE THING THE DESK CANNOT PROVE. Every fixture we hold sets ONE
-- pin and holds it for the whole run. A driver re-points at EVERY STAGE, so the
-- product depends on a handover that has never appeared in a record. Replaying
-- single-pin captures could not tell us, however many we had.
--
-- ★★ AND IT CLOSES W6.2 BY CONSTRUCTION. The gap was that `capture.lua` writes
-- `testPin` once at arm, so a driver re-pointing per stage would leave NO TRACE of
-- what it pointed at when. Here every SET, ARRIVE, SKIP and CLEAR is an event row
-- with the position and both distances at that instant - so the walk can replay a
-- multi-stage run's pointing for the first time.
--
-- ⚠ WHAT THIS IS NOT. It is not the driver and it does not decide anything: no
-- ratchet, no K-window, no band, no stage program. It answers one question -
-- does set / arrive / clear / set again work, in the client, repeatedly - and
-- records what happened. The rule lives in walk.py and ships to Lua later (W7).
--
-- ★ DETECTION USES OUR OWN POSITIONS (R-a). The tracker's `sd` is READ and recorded
-- beside our own distance, so the run also re-validates the calibration pair at
-- every stage - but it never decides arrival. That is the whole point of R-a: the
-- 0.00-on-Invalid channel cannot exist if detection never reads a tracker distance.
--
--   py addons/tools/emit_chain_route.py rfc_combat      generate the route
--   /coadump st chain                                   walk it
--   /coadump sp                                         stop; /reload lands it
--
-- ⚠ The route is GENERATED (route_chain.lua). Re-emit rather than edit it.

local ADDON, D = ...

local SAMPLE_EVERY = 0.2
local ARRIVE_R     = 5.0     -- the interact tier. One number, stated, not tuned.
local MAX_SAMPLES  = 6000

local payload, t0, acc, capped, panel, ticker, idx, armed

local function try(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d = pcall(fn, ...)
    if ok then return a, b, c, d end
    return nil
end

local function pos()
    return try(GetCurrentPlayerPosition)
end

local function dist3(x, y, z, b)
    if not x or not b then return nil end
    local dx, dy, dz = x - b.x, y - b.y, z - b.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- ★ Both distances at one instant: OURS (which decides) and the ENGINE'S (which is
-- only recorded). Their agreement is the calibration pair; their DISAGREEMENT is the
-- declined-state signal, and neither is inferred later.
local function readings(b)
    local px, py, pz, pm = pos()
    local sd
    if _G.C_SuperTrack then _, _, sd = try(C_SuperTrack.GetSuperTrackedPosition) end
    return {
        x = px, y = py, z = pz, mapID = pm,
        od = dist3(px, py, pz, b),
        sd = sd,
        ts = _G.C_SuperTrack and try(C_SuperTrack.GetTargetState) or nil,
        gt = GetTime(),
        t = math.floor((GetTime() - t0) * 100) / 100,
    }
end

local function event(kind, n, note)
    if not payload then return end
    local b = payload.route.beacons[n]
    local r = readings(b)
    r.event, r.beacon, r.note = kind, n, note
    payload.events[#payload.events + 1] = r
    return r
end

-- ---------------------------------------------------------------------

local function setBeacon(n)
    local b = payload.route.beacons[n]
    if not b then return false end
    -- F24: the Util wrapper, never C_SuperTrack directly - the direct setter skips
    -- the priority ladder and is silently overwritten.
    if not _G.SuperTrackerUtil then
        payload.abort = "no SuperTrackerUtil - cannot set"
        return false
    end
    try(SuperTrackerUtil.SetSuperTrackedPosition, b.x, b.y, b.z, b.mapID)
    armed = true
    event("set", n)
    if panel and panel.readout then
        panel.readout:SetText(("beacon %d of %d"):format(n, #payload.route.beacons))
    end
    return true
end

local function clearBeacon(n, why)
    -- ⚠⚠ THE CLEAR IS NOT MANNERS, IT IS CORRECTNESS. The marker never releases
    -- itself and nothing in the client's flow clears it (F24), so in the terminal
    -- case WE are the only actor that can. A finished route left set points
    -- indefinitely at a spent target - silently, and looking live.
    if _G.SuperTrackerUtil then try(SuperTrackerUtil.ClearSuperTrackedPosition) end
    armed = false
    event("clear", n, why)
end

local function advance(why)
    clearBeacon(idx, why)
    idx = idx + 1
    if idx > #payload.route.beacons then
        payload.finished = true
        if panel and panel.readout then panel.readout:SetText("route complete - /coadump sp") end
        D.Print("chain: route complete. |cffffd100/coadump sp then /reload|r.")
        return
    end
    setBeacon(idx)
end

-- ---------------------------------------------------------------------

local function buildPanel()
    -- ⚠ NAMED. InputBoxTemplate anchors by name and the house rule is that every
    -- frame carries one; a nameless frame also cannot be inspected from a smoke.
    local f = CreateFrame("Frame", "COADevDumpChainPanel", UIParent)
    f:SetWidth(260)
    f:SetHeight(96)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 160)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", f, "TOP", 0, -10)
    title:SetText("chain")

    local readout = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    readout:SetPoint("TOP", title, "BOTTOM", 0, -8)
    readout:SetWidth(230)
    readout:SetJustifyH("CENTER")
    f.readout = readout

    -- ★ SKIP exists so one unreachable beacon cannot strand the whole run, and it is
    -- RECORDED as a skip rather than silently treated as an arrival.
    local skip = CreateFrame("Button", "COADevDumpChainSkip", f, "UIPanelButtonTemplate")
    skip:SetWidth(100)
    skip:SetHeight(22)
    skip:SetPoint("BOTTOM", f, "BOTTOM", 0, 12)
    skip:SetText("SKIP")
    skip:SetScript("OnClick", function()
        if payload and not payload.finished then
            event("skip", idx)
            advance("skipped")
        end
    end)
    return f
end

-- ---------------------------------------------------------------------

D.RegisterTask{
    name = "chain",
    mode = "session",
    help = "chain - W6: walks the generated route_chain, setting and clearing each beacon"
        .. " and recording every switch (st, walk it, sp)",

    start = function(args)
        if not D.routeChain or not D.routeChain.beacons or #D.routeChain.beacons == 0 then
            D.Print("chain: no route. Run |cffffd100py addons/tools/emit_chain_route.py"
                .. " <fixture>|r, add route_chain.lua to the toc, and RESTART the client.")
            return
        end
        payload = D.Begin("chain", args)
        t0, acc, capped, idx, armed = GetTime(), 0, false, 1, false
        payload.route = D.routeChain
        payload.events = {}
        payload.rows = {}
        payload.arriveR = ARRIVE_R
        payload.finished = false

        local px, py, pz, pm = pos()
        if not px then
            payload.abort = "GetCurrentPlayerPosition returned nothing"
            D.Print("chain: no player position - stopping.")
            return
        end
        -- ⚠ REPORTED, NOT REFUSED. A route for another map still runs; the record
        -- says so and the desk decides. Refusing here would lose the evidence that
        -- a cross-map set behaves exactly as F38 describes.
        payload.startedOnMap = pm
        payload.mapMatches = (pm == D.routeChain.mapID)
        if not payload.mapMatches then
            D.Print(("chain: |cffff8080you are on map %s, the route is map %s|r - running"
                .. " anyway, the record will show what happens."):format(
                tostring(pm), tostring(D.routeChain.mapID)))
        end

        panel = buildPanel()
        panel:Show()

        ticker = CreateFrame("Frame")
        ticker:SetScript("OnUpdate", function(_, dt)
            if not payload or payload.finished then return end
            acc = acc + dt
            if acc < SAMPLE_EVERY then return end
            acc = 0
            if #payload.rows >= MAX_SAMPLES then
                if not capped then
                    capped = true
                    D.Print("chain: sample cap reached - stop and reload.")
                end
                return
            end
            pcall(function()
                local b = payload.route.beacons[idx]
                local r = readings(b)
                payload.rows[#payload.rows + 1] = r
                -- ★ OUR OWN distance decides. The tracker's sd rides along recorded.
                if r.od and r.od <= ARRIVE_R then
                    event("arrive", idx)
                    advance("arrived")
                end
                if panel and panel.readout and not payload.finished then
                    panel.readout:SetText(("beacon %d of %d   %.1f yd"):format(
                        idx, #payload.route.beacons, r.od or -1))
                end
            end)
        end)

        setBeacon(1)
        D.Print(("chain: %d beacons from %s (%s). Walk to each; it sets the next."):format(
            #D.routeChain.beacons, D.routeChain.run, D.routeChain.kind))
        D.Print("chain: |cffffd100finish with /coadump sp, THEN /reload|r.")
    end,

    stop = function()
        if ticker then ticker:SetScript("OnUpdate", nil) end
        if panel then panel:Hide() end
        if not payload then return end
        -- the terminal release, whether the route finished or not
        if armed then clearBeacon(idx, "stopped") end

        local sets, clears, arrives, skips = 0, 0, 0, 0
        for _, e in ipairs(payload.events) do
            if e.event == "set" then sets = sets + 1
            elseif e.event == "clear" then clears = clears + 1
            elseif e.event == "arrive" then arrives = arrives + 1
            elseif e.event == "skip" then skips = skips + 1 end
        end
        -- ★ The calibration pair, re-validated across every stage of a MULTI-PIN run -
        -- something no fixture has ever contained.
        local worst, pairs_ = nil, 0
        for _, r in ipairs(payload.rows) do
            if r.od and r.sd and r.sd > 0 then
                pairs_ = pairs_ + 1
                local d = math.abs(r.od - r.sd)
                if not worst or d > worst then worst = d end
            end
        end
        payload.summary = {
            beacons = #payload.route.beacons,
            reached = idx - 1,
            sets = sets, clears = clears, arrives = arrives, skips = skips,
            rows = #payload.rows,
            finished = payload.finished,
            mapMatches = payload.mapMatches,
            calibrationPairs = pairs_,
            worstAbsSdOd = worst,
            capped = capped,
        }
        D.Commit(("chain: %d/%d beacons, %d set / %d clear / %d arrive / %d skip,"
            .. " %d rows, worst |sd-od| %s%s"):format(
            idx - 1, #payload.route.beacons, sets, clears, arrives, skips,
            #payload.rows, tostring(worst), capped and " [CAPPED]" or ""))
    end,
}
