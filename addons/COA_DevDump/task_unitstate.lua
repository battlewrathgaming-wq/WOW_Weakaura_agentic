-- task_unitstate.lua - the UNIT STATE PROBE, with a widget test driver.
--
-- ONE session, ONE button. You stand somewhere, you press GET POS, and it records
-- EVERY unit-state read this client will answer, at that instant, with a label you
-- typed. The point is not any single field: it is that the fields ARGUE WITH EACH
-- OTHER, so a wrong reading has somewhere to show up.
--
-- Battlewrath, 2026-08-17: *"a full state profile that can argue/agree against
-- itself."* That is the whole design. `IsSwimming` claims you are swimming and
-- `GetUnitSpeed` says 7.0 - one of them is wrong and the record says which.
--
-- ★★★ WHAT IT IS FOR, and all three are open questions the desk cannot answer:
--
--   1) WHERE IS POSITION `z` MEASURED FROM - the feet, or the model?
--      Emulator source says the base point (ROUTER, and it is quoted there), but
--      our getter is FORK-NATIVE in Extensions.dll and nothing certifies it returns
--      the engine coordinate unmodified.
--      -> stand chest-deep in water, GET POS. Then SWIM ON THE SAME SPOT, GET POS.
--         Swimming rotates the model to horizontal, so a model-referenced z drops
--         by roughly half a height while a base point barely moves. It is the only
--         manoeuvre where the offset CHANGES instead of cancelling.
--
--   2) HOW TALL IS THIS CHARACTER, in game units?
--      No Lua API reports model height (checked: no UnitHeight, no bounding radius,
--      no model scale), and ChrRaces.dbc is MPQ-packed. But water is a FIXED PLANE:
--      -> GET POS with the surface at your ankles, then at your head. The ground has
--         dropped by your height, and the z difference IS that height - whatever the
--         origin is, because a constant offset cancels in a difference.
--      ★ The breath timer is the objective trigger for "head under". Do not eyeball it.
--
--   3) WHAT IS THE JUMP APEX?
--      Three candidates disagree - 1.27002 engine-derived, 1.5 folklore that traces
--      to nothing, ~1.9 ours from runs that were never landed. `IsFalling` makes it
--      measurable rather than inferred: the apex is the z maximum between its edges.
--      -> press JUMP WINDOW, then jump six times on flat ground.
--
-- ⚠ THIS IS OPEN-WORLD WORK AND COA_DungeonRun CANNOT DO IT. Its sampler only runs
-- inside an instance (capture.lua says so in as many words), so every one of the
-- above would break there. This lands through DevDump instead, which is `tracked`
-- and commits to records/ rather than gitignored staging/.
--
--   /coadump st unitstate     spawn the driver
--   ...press GET POS at each place; JUMP WINDOW for the arc...
--   /coadump sp               stop; /reload lands it
--
-- PURE CAPTURE. The self-checks below are arithmetic on captured values, never
-- verdicts - they say "these two disagree", never which one is right.

local ADDON, D = ...

local SAMPLE_EVERY  = 0.2
local MAX_SAMPLES   = 4000        -- ~13 min of window sampling; capped is REPORTED
local WINDOW_SECS   = 45          -- one jump window; long enough for six jumps

local payload, t0, acc, capped, panel, sampling, windowEnds, ticker

-- ★ `try` IS THE EXISTENCE PROBE, not just an error guard. A missing global and a
-- throwing call both come back nil, and BOTH are facts we want recorded. Seven
-- client functions on this fork throw rather than returning nil (ROUTER), so a bare
-- call would take the whole task down.
local function try(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if ok then return a, b, c, d, e end
    return nil
end

-- ⚠⚠ RECORD THE TYPE, NEVER COERCE. This fork returns `1` where retail returns
-- `true` - IsInInstance, UnitExists and GetChecked all do it, and every one of them
-- has cost a silent bug here. Normalising to a boolean at capture time would DESTROY
-- the very characteristic this probe exists to catalogue.
-- ⚠⚠ AND THE SERIALISED SHAPE IS `t`-DISCRIMINATED, NOT `v`-DISCRIMINATED. A Lua
-- table cannot hold `v = nil` - assigning nil REMOVES the key - so a nil reading lands
-- as { t = "nil" } with no `v` at all. That is fine and lossless, but only if the
-- reader knows: ★ ASK `t`, NEVER `v == nil`. My first smoke asserted `.v == nil`,
-- which is true whether the key exists or not - a vacuous assertion that proved nothing
-- and passed. The convention is stated here because the shape cannot state it.
local function raw(fn, ...)
    local v = try(fn, ...)
    return { v = v, t = type(v) }
end

-- ---------------------------------------------------------------------
-- The state profile
-- ---------------------------------------------------------------------

local function profile(label)
    local px, py, pz, pm = try(GetCurrentPlayerPosition)

    -- ★★★ THE HEADLINE CROSS-CHECK, and it settles a row I put in ROUTER wrongly.
    -- I recorded that `UnitPosition` exists here returning y,x,z - inferred from a
    -- call site in a third-party addon that wraps it in pcall. ⚠ A pcall call site
    -- is evidence of an ATTEMPT, not of existence, and the globals census says
    -- absent - though the census cannot prove absence either (the whole supertracker
    -- API is missing from it and demonstrably works). This settles it by ASKING.
    local uy, ux, uz, ui = try(UnitPosition, "player")

    local row = {
        label = label,
        t     = math.floor((GetTime() - t0) * 100) / 100,
        gt    = GetTime(),

        -- position, from both getters
        px = px, py = py, pz = pz, pm = pm,
        up_1 = uy, up_2 = ux, up_3 = uz, up_4 = ui,   -- ⚠ NAMED BY ORDINAL, not by
        -- axis: the whole question is which ordinal is which axis. Calling the first
        -- return `y` here would bake in the answer we are trying to measure.

        facing = try(GetPlayerFacing),
        speed  = try(GetUnitSpeed, "player"),

        -- map layer
        mapX = nil, mapY = nil,
        areaID = try(GetCurrentMapAreaID),
        dungeonLevel = try(GetCurrentMapDungeonLevel),
        mapZone = try(GetCurrentMapZone),
        mapContinent = try(GetCurrentMapContinent),
        mapFile = try(GetMapInfo),
        zone = try(GetRealZoneText),
        subZone = try(GetSubZoneText),

        -- identity: what the height measurement gets LABELLED with, since no API
        -- reports model height and the DBC is packed
        race = select(2, try(UnitRace, "player")),
        raceLocal = try(UnitRace, "player"),
        sex = try(UnitSex, "player"),
        class = select(2, try(UnitClass, "player")),
        level = try(UnitLevel, "player"),
        faction = try(UnitFactionGroup, "player"),

        -- movement state, TYPES PRESERVED
        isSwimming = raw(IsSwimming),
        isFalling  = raw(IsFalling),
        isFlying   = raw(IsFlying),
        isMounted  = raw(IsMounted),
        isStealthed = raw(IsStealthed),
        isIndoors  = raw(IsIndoors),
        isOutdoors = raw(IsOutdoors),
        onTaxi     = raw(UnitOnTaxi, "player"),
        inVehicle  = raw(UnitInVehicle, "player"),
        resting    = raw(IsResting),
        inCombat   = raw(UnitAffectingCombat, "player"),
        deadOrGhost = raw(UnitIsDeadOrGhost, "player"),
    }

    local mx, my = try(GetPlayerMapPosition, "player")
    row.mapX, row.mapY = mx, my

    -- ★ BREATH is the objective "head under the surface" trigger. Mirror timers are
    -- indexed by type; BREATH is the one that matters and it simply returns nothing
    -- when you are not submerged, which is itself the reading.
    local mt, mv, mmax, mscale, mpaused, mlabel = try(GetMirrorTimerInfo, 2)
    row.mirror = { timer = mt, value = mv, max = mmax, scale = mscale,
                   paused = mpaused, label = mlabel }
    row.breathProgress = try(GetMirrorTimerProgress, "BREATH")

    return row
end

-- ---------------------------------------------------------------------
-- The self-arguments
-- ---------------------------------------------------------------------

-- ★★★ THE POINT OF THE WHOLE TASK. Each entry is a pair of readings that must be
-- consistent, expressed so that a DISAGREEMENT is what gets recorded. None of these
-- decides which side is right - that is the desk's job, with the record in hand.
--
-- ⚠ `agree = nil` means the check could not RUN (a field was absent), which is a
-- third state and must not read as agreement. Absent, not defaulted.
local function truthy(r)
    -- this fork returns 1 where retail returns true; both are truthy, nil is not
    return r and r.v ~= nil and r.v ~= false
end

local function arguments(row, prev)
    local out = {}
    local function add(name, agree, note)
        out[#out + 1] = { check = name, agree = agree, note = note }
    end

    -- 1) the two position getters, if the second exists at all
    if row.up_3 ~= nil and row.pz ~= nil then
        local dz = math.abs(row.up_3 - row.pz)
        add("UnitPosition[3] == GetCurrentPlayerPosition z", dz < 0.01,
            ("dz %.4f"):format(dz))
        -- and which ordinal matches which axis - measured, not assumed
        if row.up_1 and row.up_2 and row.px and row.py then
            local swapped = math.abs(row.up_1 - row.py) < 0.01
                            and math.abs(row.up_2 - row.px) < 0.01
            local same = math.abs(row.up_1 - row.px) < 0.01
                         and math.abs(row.up_2 - row.py) < 0.01
            add("UnitPosition axis order", (swapped or same) or nil,
                swapped and "SWAPPED: returns y,x" or (same and "same: returns x,y"
                or "neither - it is not this position at all"))
        end
    else
        add("UnitPosition exists", nil, "ABSENT on this client - the check cannot run")
    end

    -- 2) swimming vs speed. Base swim is 4.722222, base run 7.0 (emulator source).
    if row.speed ~= nil then
        if truthy(row.isSwimming) then
            add("IsSwimming agrees with speed", row.speed < 6.0,
                ("speed %.3f - swim base is 4.722"):format(row.speed))
        elseif row.speed > 0.5 then
            add("not swimming agrees with speed", row.speed >= 6.0 or nil,
                ("speed %.3f"):format(row.speed))
        end
    end

    -- 3) falling vs z actually changing
    if prev and row.pz and prev.pz then
        local moved = math.abs(row.pz - prev.pz) > 0.01
        if truthy(row.isFalling) then
            add("IsFalling agrees that z moves", moved,
                ("dz since last sample %.4f"):format(row.pz - prev.pz))
        end
    end

    -- 4) indoors and outdoors must be exclusive
    local i, o = truthy(row.isIndoors), truthy(row.isOutdoors)
    if row.isIndoors.v ~= nil or row.isOutdoors.v ~= nil then
        add("IsIndoors xor IsOutdoors", (i ~= o), ("indoors=%s outdoors=%s")
            :format(tostring(row.isIndoors.v), tostring(row.isOutdoors.v)))
    end

    -- 5) breath running implies the head is under, which implies swimming
    if row.mirror and row.mirror.value ~= nil then
        add("breath timer implies swimming", truthy(row.isSwimming),
            ("breath %s/%s"):format(tostring(row.mirror.value), tostring(row.mirror.max)))
    end

    -- 6) mounted should beat run speed
    if truthy(row.isMounted) and row.speed ~= nil then
        add("IsMounted agrees with speed", row.speed > 7.0,
            ("speed %.3f vs run 7.0"):format(row.speed))
    end

    -- 7) the 3.3.5-ism catalogue: which flags return 1, which true, which nil
    local kinds = {}
    for _, k in ipairs({ "isSwimming", "isFalling", "isFlying", "isMounted",
                         "isStealthed", "isIndoors", "isOutdoors", "onTaxi",
                         "inVehicle", "resting", "inCombat", "deadOrGhost" }) do
        local r = row[k]
        kinds[k] = ("%s(%s)"):format(tostring(r.v), r.t)
    end
    out.returnKinds = kinds

    return out
end

-- ---------------------------------------------------------------------
-- The widget - the test driver
-- ---------------------------------------------------------------------

local function mark(label)
    if not payload then return end
    local prev = payload.marks[#payload.marks]
    local row = profile(label)
    row.checks = arguments(row, prev)
    payload.marks[#payload.marks + 1] = row

    local dis = 0
    for _, c in ipairs(row.checks) do
        if c.agree == false then dis = dis + 1 end
    end
    local msg = ("%s  z=%.3f  speed=%.2f  swim=%s  %d disagreement(s)"):format(
        label, row.pz or 0, row.speed or 0,
        tostring(row.isSwimming.v), dis)
    D.Print("unitstate: " .. msg)
    if panel and panel.readout then panel.readout:SetText(msg) end
    return row
end

local function buildPanel()
    -- ⚠ NAMED FRAME AND NAMED EDITBOX, both required. InputBoxTemplate anchors its
    -- middle texture relativeTo $parentLeft/$parentRight BY NAME, so a nameless box
    -- renders as two floating end-caps. That has cost a live bug twice here.
    local f = CreateFrame("Frame", "COADevDumpUnitStatePanel", UIParent)
    f:SetWidth(300)
    f:SetHeight(150)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
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
    title:SetPoint("TOP", f, "TOP", 0, -12)
    title:SetText("unit state probe")

    local box = CreateFrame("EditBox", "COADevDumpUnitStateLabel", f, "InputBoxTemplate")
    box:SetWidth(180)
    box:SetHeight(20)
    box:SetPoint("TOP", title, "BOTTOM", 10, -10)
    box:SetAutoFocus(false)
    box:SetText("ankles")
    f.box = box

    local get = CreateFrame("Button", "COADevDumpUnitStateGet", f,
                            "UIPanelButtonTemplate")
    get:SetWidth(120)
    get:SetHeight(24)
    get:SetPoint("TOPLEFT", box, "BOTTOMLEFT", -8, -8)
    get:SetText("GET POS")
    get:SetScript("OnClick", function()
        local lbl = box:GetText()
        if not lbl or lbl == "" then lbl = "unlabelled" end
        mark(lbl)
    end)

    local jump = CreateFrame("Button", "COADevDumpUnitStateJump", f,
                             "UIPanelButtonTemplate")
    jump:SetWidth(140)
    jump:SetHeight(24)
    jump:SetPoint("LEFT", get, "RIGHT", 8, 0)
    jump:SetText("JUMP WINDOW")
    jump:SetScript("OnClick", function()
        sampling = true
        windowEnds = GetTime() + WINDOW_SECS
        payload.windows[#payload.windows + 1] = { started = GetTime(), secs = WINDOW_SECS }
        D.Print(("unitstate: sampling %ds at %.1fs - jump now."):format(
            WINDOW_SECS, SAMPLE_EVERY))
    end)

    local readout = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    readout:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 14, 16)
    readout:SetWidth(270)
    readout:SetJustifyH("LEFT")
    readout:SetText("press GET POS where you stand")
    f.readout = readout

    return f
end

-- ---------------------------------------------------------------------

D.RegisterTask{
    name = "unitstate",
    mode = "session",
    help = "unitstate - full unit-state profile with a GET POS widget; answers z-datum,"
        .. " character height and jump apex (st, press buttons, sp)",

    start = function(args)
        payload = D.Begin("unitstate", args)
        t0, acc, capped, sampling = GetTime(), 0, false, false
        payload.marks = {}
        payload.windows = {}
        payload.rows = {}

        -- ⚠ PRE-FLIGHT, ALL REPORTED. `nil` here means the global is not declared;
        -- the globals census cannot prove absence (the whole supertracker API is
        -- missing from it and works), so ASKING is the only honest instrument.
        local present = {}
        for _, n in ipairs({ "GetCurrentPlayerPosition", "UnitPosition",
                             "GetPlayerMapPosition", "GetPlayerFacing",
                             "GetUnitSpeed", "IsSwimming", "IsFalling", "IsFlying",
                             "IsMounted", "IsIndoors", "IsOutdoors", "IsStealthed",
                             "UnitOnTaxi", "UnitInVehicle", "IsResting",
                             "GetMirrorTimerInfo", "GetMirrorTimerProgress",
                             "UnitRace", "UnitSex", "GetCurrentMapDungeonLevel",
                             "GetCurrentMapAreaID", "GetMapInfo" }) do
            present[n] = type(_G[n])
        end
        payload.declared = present

        local px = try(GetCurrentPlayerPosition)
        if not px then
            payload.abort = "GetCurrentPlayerPosition returned nothing"
            D.Print("unitstate: no player position - stopping.")
            return
        end

        -- ⚠⚠ THE TASK OWNS ITS OWN OnUpdate. There is no harness-level tick - I wrote
        -- one and it would have been called by nothing, which is the silent-failure
        -- shape this codebase keeps producing (a  above its
        -- declaration, SetScript("OnUpdate", nil) being legal). Checked against
        -- task_satnav rather than assumed.
        --
        -- ★ And it is cleared on stop. ROUTER's culture list says ZERO PERSISTENT
        -- OnUpdate - the manners of not taking more than you were given on someone
        -- else's machine. Nothing here needs a frame after the errand.
        ticker = CreateFrame("Frame")
        ticker:SetScript("OnUpdate", function(_, dt)
            if not sampling or not payload then return end
            if GetTime() > windowEnds then
                sampling = false
                -- ★★ THE TICKER RELEASES ITSELF. All three landed runs came back
                -- `status: open` because /coadump sp was never pressed before /reload -
                -- so stop() never ran, the summary is absent AND the OnUpdate stayed
                -- live. ⚠ The smoke asserts clearing happens ON STOP; it cannot assert
                -- that stop gets CALLED. So the frame no longer depends on it: zero
                -- persistent OnUpdate holds even when the errand is abandoned.
                -- ⚠ the CLOSURE'''s frame, not the handler'''s self argument. Relying on
                -- `_` works in game and breaks the moment anything calls the handler
                -- directly - which the smoke does, and which found it.
                if ticker then ticker:SetScript("OnUpdate", nil) end
                D.Print("unitstate: window closed. |cffffd100Press /coadump sp before"
                    .. " /reload|r or the envelope stays open and unsummarised.")
                return
            end
            acc = acc + dt
            if acc < SAMPLE_EVERY then return end
            acc = 0
            if #payload.rows >= MAX_SAMPLES then
                if not capped then
                    capped = true
                    sampling = false
                    D.Print("unitstate: sample cap reached (" .. MAX_SAMPLES .. ").")
                end
                return
            end
            -- pcall INSIDE the handler: an error here would spam every frame
            pcall(function()
                local px, py, pz = try(GetCurrentPlayerPosition)
                payload.rows[#payload.rows + 1] = {
                    t = math.floor((GetTime() - t0) * 100) / 100,
                    x = px, y = py, z = pz,
                    f = try(IsFalling), s = try(GetUnitSpeed, "player"),
                    w = try(IsSwimming),
                }
            end)
        end)

        panel = buildPanel()
        panel:Show()
        D.Print("unitstate: driver up. Type a label, press GET POS. JUMP WINDOW for the arc.")
        D.Print("unitstate: |cffffd100finish with /coadump sp, THEN /reload|r - three runs"
            .. " landed unsummarised without it.")
    end,

    stop = function()
        sampling = false
        if ticker then ticker:SetScript("OnUpdate", nil) end
        if panel then panel:Hide() end
        if not payload then return end

        -- summary is COUNTS and DISAGREEMENTS, never a conclusion
        local dis, ran, absent = 0, 0, 0
        for _, m in ipairs(payload.marks) do
            for _, c in ipairs(m.checks or {}) do
                if c.agree == false then dis = dis + 1
                elseif c.agree == true then ran = ran + 1
                else absent = absent + 1 end
            end
        end
        payload.summary = {
            marks = #payload.marks,
            windows = #payload.windows,
            windowRows = #payload.rows,
            checksAgreed = ran,
            checksDisagreed = dis,
            checksCouldNotRun = absent,
            capped = capped,
        }
        D.Commit(("unitstate: %d mark(s), %d window row(s); checks %d agreed, %d DISAGREED,"
            .. " %d could not run%s"):format(#payload.marks, #payload.rows, ran, dis,
            absent, capped and " [CAPPED]" or ""))
    end,
}
