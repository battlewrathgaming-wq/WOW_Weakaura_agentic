-- task_satnav.lua - the SUPERTRACK PROBE for the landmark/scrapbook arc.
--
-- Three open questions block the design brief, and all three are answered by
-- standing near a pinned point and reading numbers. So this is ONE session
-- with ONE pin, and the manoeuvres are just things you do while it records:
--
--   A) IS `distance` 3D OR 2D?  Law 14's 5yd "Interact with" tier cannot be
--      trusted until we know. 2D says ARRIVED when the vendor is on the floor
--      above you.                          -> walk UPSTAIRS from the pin.
--   B) DOES `distance` SURVIVE THE TARGET GOING OFF-SCREEN?  GetSuperTrackedPosition
--      returns SCREEN x/y and the beacon hides when they are invalid. If the
--      distance dies with them, arrival polling breaks in the exact moment it
--      matters.                            -> stand ON the pin and SPIN the camera.
--   C) DOES THE ENGINE SUPERTRACK CROSS-ZONE?  Gates the whole retrieval design.
--                                          -> travel to a NEIGHBOURING zone.
--
--   /coadump st satnav      pin where you stand + start recording
--   ...A, then B, then C, in any order...
--   /coadump sp             stop (hands the supertrack slot back); /reload lands it
--
-- PURE CAPTURE, NO VERDICTS. Per-row hd/vd are arithmetic on captured ground
-- truth, not inference: comparing them against sd is what answers (A), and that
-- comparison happens in the repo, not here.
--
-- Ledger: addons/planning/satnav_ledger.md - F21-F27, laws 13-15, §7.

local ADDON, D = ...

local SAMPLE_EVERY = 0.2
local MAX_SAMPLES  = 5000        -- ~16 min; capped is REPORTED, never silent

local frames, payload, pin, t0, acc, capped

local function try(fn, ...)
    local ok, a, b, c, d = pcall(fn, ...)
    if ok then return a, b, c, d end
    return nil
end

-- SUPER_TRACKED_POSITION is the client's own global (F24). Reading it tells us
-- whether the client still holds our intent, which is the thing most likely to
-- change quietly on a zone transition.
local function globalPinState()
    local g = _G.SUPER_TRACKED_POSITION
    if type(g) ~= "table" then return -1 end
    if pin and g.mapID == pin.m then return 1 end
    return 0
end

local function sample()
    local px, py, pz, pm = try(GetCurrentPlayerPosition)
    local sx, sy, sd
    if _G.C_SuperTrack then
        sx, sy, sd = try(C_SuperTrack.GetSuperTrackedPosition)
    end

    local row = {
        t  = math.floor((GetTime() - t0) * 100) / 100,
        px = px, py = py, pz = pz, pm = pm,
        sx = sx, sy = sy, sd = sd,
        cd = _G.SuperTracker and _G.SuperTracker.distance or nil,
        f  = try(GetPlayerFacing),
        gp = globalPinState(),
    }

    -- NOT `x and try(f) or nil` for these: they return BOOLEANS, and `false or nil`
    -- collapses to nil - which would erase exactly the samples question (B) is
    -- about. Caught by the smoke; kept explicit so it stays caught.
    if _G.C_SuperTrack then
        row.ts = try(C_SuperTrack.GetTargetState)
        row.tr = try(C_SuperTrack.IsSuperTrackingAnything)
    end
    if _G.SuperTrackerUtil then
        row.vs = try(SuperTrackerUtil.HasValidScreenPosition)
    end

    -- ground truth relative to the pin, so (A) is answerable by comparison:
    --   sd ~= hd            => distance is 2D
    --   sd ~= sqrt(hd^2+vd^2) => distance is 3D
    if px and pin and pm == pin.m then
        local dx, dy = px - pin.x, py - pin.y
        row.hd = math.floor(math.sqrt(dx * dx + dy * dy) * 100) / 100
        row.vd = math.floor((pz - pin.z) * 100) / 100
    end

    return row
end

D.RegisterTask{
    name = "satnav",
    mode = "session",
    help = "satnav - supertrack probe: pins where you stand, records distance/state/screen-validity (st, do A/B/C, sp)",

    start = function(args)
        payload = D.Begin("satnav", args)
        t0, acc, capped = GetTime(), 0, false

        -- pre-flight, all REPORTED rather than assumed
        local env = {}
        env.hasSuperTrack     = _G.C_SuperTrack ~= nil
        env.hasSuperTrackUtil = _G.SuperTrackerUtil ~= nil
        env.hasTrackerFrame   = _G.SuperTracker ~= nil
        env.showInGameNavigation = _G.C_CVar and try(C_CVar.GetBool, "showInGameNavigation")
        env.zone = try(GetRealZoneText)
        env.subZone = try(GetSubZoneText)
        payload.env = env

        local px, py, pz, pm = try(GetCurrentPlayerPosition)
        if not px then
            payload.abort = "GetCurrentPlayerPosition returned nothing"
            D.Print("satnav: no player position - cannot pin. Stopping.")
            return
        end
        pin = { x = px, y = py, z = pz, m = pm }
        payload.pin = { x = px, y = py, z = pz, mapID = pm,
                        zone = env.zone, subZone = env.subZone }

        -- F24: the Util wrapper, NOT C_SuperTrack directly. The direct call
        -- skips the priority ladder and gets silently overwritten.
        if _G.SuperTrackerUtil then
            payload.setterUsed = "SuperTrackerUtil.SetSuperTrackedPosition"
            try(SuperTrackerUtil.SetSuperTrackedPosition, px, py, pz, pm)
        elseif _G.C_SuperTrack then
            payload.setterUsed = "C_SuperTrack.SetSuperTrackedPosition (FALLBACK - ladder bypassed)"
            try(C_SuperTrack.SetSuperTrackedPosition, px, py, pz, pm)
        else
            payload.abort = "no supertrack API present"
            D.Print("satnav: no C_SuperTrack on this client. Stopping.")
            return
        end

        payload.rows = {}
        payload.rows[1] = sample()

        local tick = CreateFrame("Frame")
        tick:SetScript("OnUpdate", function(_, dt)
            acc = acc + dt
            if acc < SAMPLE_EVERY then return end
            acc = 0
            if #payload.rows >= MAX_SAMPLES then
                if not capped then
                    capped = true
                    D.Print("satnav: sample cap reached (" .. MAX_SAMPLES .. ") - stop and reload.")
                end
                return
            end
            local ok = pcall(function() payload.rows[#payload.rows + 1] = sample() end)
            if not ok then payload.tick_errors = (payload.tick_errors or 0) + 1 end
        end)
        frames = { tick = tick }

        if env.showInGameNavigation == false then
            D.Print("satnav: |cffff4444showInGameNavigation is OFF|r - the beacon cannot render. "
                .. "/console showInGameNavigation 1, then restart this task.")
        end
        D.Print(("satnav pinned at map %s (%s). Now: upstairs (A), spin on the spot (B), "
              .. "next zone (C). Then /coadump sp"):format(tostring(pm), tostring(env.zone)))
    end,

    stop = function()
        if frames and frames.tick then frames.tick:SetScript("OnUpdate", nil) end
        if not payload or payload.abort then
            D.Commit("satnav: aborted - " .. tostring(payload and payload.abort or "no payload"))
            return
        end

        payload.capped = capped
        payload.samples = #payload.rows

        -- descriptive only: counts and extents over what was captured.
        local mapIDs, states = {}, {}
        local dMin, dMax
        local nNoScreen, nNoScreenButDist, nNilDist = 0, 0, 0
        local vProbe
        for _, r in ipairs(payload.rows) do
            if r.pm then mapIDs[tostring(r.pm)] = (mapIDs[tostring(r.pm)] or 0) + 1 end
            if r.ts then states[tostring(r.ts)] = (states[tostring(r.ts)] or 0) + 1 end
            if r.sd then
                if not dMin or r.sd < dMin then dMin = r.sd end
                if not dMax or r.sd > dMax then dMax = r.sd end
            else
                nNilDist = nNilDist + 1
            end
            if r.vs == false then
                nNoScreen = nNoScreen + 1
                if r.sd then nNoScreenButDist = nNoScreenButDist + 1 end
            end
            -- most diagnostic row for (A): greatest vertical offset while
            -- horizontally close. Selected mechanically; NOT a conclusion.
            if r.hd and r.vd and r.sd and r.hd < 10 then
                if not vProbe or math.abs(r.vd) > math.abs(vProbe.vd) then vProbe = r end
            end
        end

        payload.summary = {
            mapIDsSeen = mapIDs,
            targetStatesSeen = states,
            distanceMin = dMin, distanceMax = dMax,
            samplesWithNilDistance = nNilDist,
            samplesScreenInvalid = nNoScreen,
            samplesScreenInvalidWithDistance = nNoScreenButDist,
            verticalProbeRow = vProbe,
        }

        -- law 13: hand the slot back. We never hold it beyond the errand.
        if _G.SuperTrackerUtil then try(SuperTrackerUtil.ClearSuperTrackedPosition) end

        local nMaps = 0
        for _ in pairs(mapIDs) do nMaps = nMaps + 1 end
        D.Commit(("satnav: %d samples, %d mapID(s), dist %s..%s, screen-invalid %d (of which %d kept a distance)%s")
            :format(payload.samples, nMaps, tostring(dMin), tostring(dMax),
                    nNoScreen, nNoScreenButDist, capped and " [CAPPED]" or ""))
    end,
}
