-- task_api.lua - MEASURE THE CLIENT, instead of modelling it and hoping.
--
-- ---------------------------------------------------------------------------
-- ★★ WHY (Battlewrath, 2026-08-14): *"Push a bunch of API calls with a mix of
-- inputs and see how they resolve + grab the error handlers?"*
--
-- COA_DungeonRun §82 built `addons/tools/smoke/harness.lua`, which makes the offline
-- stubs behave like the client - SetText fires OnTextChanged, Show/Hide fire on
-- transitions, SetTexture resets TexCoord. ⚠ EVERY ONE OF THOSE CLAIMS WAS REASONED,
-- NOT MEASURED. The bench has been running its whole test suite against a model
-- nobody ever checked against the thing it models.
--
-- §82's own words: *"an offline smoke is only ever as good as that model, and the
-- failures it cannot see are exactly the places the model and the client disagree."*
-- This is the instrument that finds those places.
--
-- ---------------------------------------------------------------------------
-- ★★★ IT IS READ-ONLY ON THE CLIENT, AND THAT IS A HARD LINE.
--
-- The addon census splits what we touch into PULL and PUSH. Only PULL is probed.
-- PUSH - SetCVar, SuperTrackerUtil.*, SetMapByID, ShowUIPanel, PlaySound - has real
-- side effects on someone's live client: junk inputs there would change settings,
-- move a super-tracker, or repaint the world map, and a diagnostic that damages the
-- machine it is diagnosing is not a diagnostic.
--
-- Probing PUSH is a SEPARATE task nobody has asked for, and it would have to write
-- each call's restore BEFORE the call.
--
-- The frames built here are hidden, parented to UIParent, and torn down at the end.
-- ---------------------------------------------------------------------------

local ADDON, D = ...

-- ---------------------------------------------------------------------
-- ★ SECTION ONE - THE BEHAVIOURS harness.lua ASSERTS.
--
-- Each entry states what the harness CLAIMS and runs an experiment that measures it.
-- The output is BY EXCEPTION: `agrees` is the only column that matters, and a false
-- is a bug we currently cannot see offline.
-- ---------------------------------------------------------------------

local function behaviours(out)
    local host = CreateFrame("Frame", nil, UIParent)
    host:Hide()

    local function record(name, claim, observed, agrees, note)
        out[#out + 1] = {
            name = name, claim = claim, observed = observed,
            agrees = agrees and true or false, note = note,
        }
    end

    -- 1. SetText fires OnTextChanged - INCLUDING on an unchanged value.
    -- This is the one §81's near-freeze rests on. If it is false, harness.lua is
    -- modelling a hazard that does not exist and the guard is dead weight.
    do
        local ok, err = pcall(function()
            local e = CreateFrame("EditBox", nil, host)
            e:Hide()
            local n = 0
            e:SetScript("OnTextChanged", function() n = n + 1 end)
            e:SetText("alpha")
            local first = n
            e:SetText("alpha")            -- same value, deliberately
            record("SetText fires OnTextChanged",
                   "fires on any SetText", ("first=%d same-value=%d"):format(first, n - first),
                   first >= 1 and (n - first) >= 1)
        end)
        if not ok then record("SetText fires OnTextChanged", "fires on any SetText",
                              "ERROR: " .. tostring(err), false) end
    end

    -- 2. Show/Hide fire on a TRANSITION only.
    do
        local ok, err = pcall(function()
            local fr = CreateFrame("Frame", nil, host)
            fr:Hide()
            local shown, hidden = 0, 0
            fr:SetScript("OnShow", function() shown = shown + 1 end)
            fr:SetScript("OnHide", function() hidden = hidden + 1 end)
            fr:Show(); fr:Show()
            fr:Hide(); fr:Hide()
            record("Show/Hide fire on transitions only",
                   "one OnShow, one OnHide",
                   ("OnShow=%d OnHide=%d"):format(shown, hidden),
                   shown == 1 and hidden == 1)
        end)
        if not ok then record("Show/Hide fire on transitions only", "one each",
                              "ERROR: " .. tostring(err), false) end
    end

    -- 3. ★ SetTexture RESETS TexCoord (§19). Believed since v0.4, load-bearing for
    -- every tile the map draws, and never once measured.
    do
        local ok, err = pcall(function()
            local t = host:CreateTexture(nil, "BACKGROUND")
            t:SetTexture("Interface\\Icons\\INV_Misc_Key_03")
            t:SetTexCoord(0.1, 0.9, 0.2, 0.8)
            local before = { t:GetTexCoord() }
            t:SetTexture("Interface\\Icons\\INV_Misc_Key_04")
            local after = { t:GetTexCoord() }
            -- A reset returns the full 0..1 quad; the first coord pair is enough to
            -- tell them apart without depending on the return arity.
            local wasCropped = (before[1] or 0) > 0.05
            local nowFull    = (after[1] or 0) < 0.05
            record("SetTexture resets TexCoord",
                   "the crop is discarded",
                   ("before[1]=%s after[1]=%s"):format(tostring(before[1]), tostring(after[1])),
                   wasCropped and nowFull,
                   (not wasCropped) and "SetTexCoord did not take - result inconclusive" or nil)
        end)
        if not ok then record("SetTexture resets TexCoord", "the crop is discarded",
                              "ERROR: " .. tostring(err), false) end
    end

    -- 4. ⚠ SetChecked does NOT fire OnClick. harness.lua deliberately models the
    -- ABSENCE, and modelling an absence wrongly is the harder error to notice.
    do
        local ok, err = pcall(function()
            local c = CreateFrame("CheckButton", nil, host, "UICheckButtonTemplate")
            c:Hide()
            local clicks = 0
            c:SetScript("OnClick", function() clicks = clicks + 1 end)
            c:SetChecked(true)
            c:SetChecked(false)
            record("SetChecked does NOT fire OnClick",
                   "no OnClick", ("OnClick=%d"):format(clicks), clicks == 0)
        end)
        if not ok then record("SetChecked does NOT fire OnClick", "no OnClick",
                              "ERROR: " .. tostring(err), false) end
    end

    -- 5. SetScript REPLACES rather than adds - the stubs assume it, everything the
    -- addon does with OnUpdate install/clear depends on it, and the census counts
    -- installs and clears as if it were true.
    do
        local ok, err = pcall(function()
            local fr = CreateFrame("Frame", nil, host)
            local a, b = 0, 0
            fr:SetScript("OnShow", function() a = a + 1 end)
            fr:SetScript("OnShow", function() b = b + 1 end)
            fr:Hide(); fr:Show()
            record("SetScript replaces, never adds",
                   "only the second handler runs", ("first=%d second=%d"):format(a, b),
                   a == 0 and b == 1)
        end)
        if not ok then record("SetScript replaces, never adds", "only the second runs",
                              "ERROR: " .. tostring(err), false) end
    end

    host:Hide()
    host:SetParent(nil)
    return out
end

-- ---------------------------------------------------------------------
-- ★ SECTION TWO - THE INPUT MATRIX over what the census lists as PULL.
--
-- The question each row answers: given a bad input, does this RETURN NIL or does it
-- THROW? I have guessed at that more than once while writing guard clauses, and a
-- guard written for the wrong one is a guard that never fires or a crash that never
-- had to happen.
-- ---------------------------------------------------------------------

-- ⚠ PULL ONLY. Sourced from emit_addon_census.py's PULL pattern - the same one
-- authority the census uses, so this list cannot drift away from what we claim to
-- read. Nothing here changes client state.
local PULL = {
    "GetCurrentPlayerPosition", "GetPlayerMapPosition", "GetRealZoneText",
    "GetSubZoneText", "GetCurrentMapContinent", "GetCurrentMapZone", "GetMapInfo",
    "GetCurrentMapDungeonLevel", "GetCurrentMapAreaID", "GetNumDungeonMapLevels",
    "UnitName", "UnitClass", "UnitIsGhost", "GetRealmName", "GetTime",
    "GetAddOnMetadata", "GetLocale", "GetCVar", "IsInInstance", "GetInstanceInfo",
    "GetDifficultyInfo", "debugprofilestop",
}

-- The mix. Each is a named ARGUMENT SET, so a result reads as "this input, this
-- outcome" rather than as a column of anonymous values.
local INPUTS = {
    { name = "no args",      args = {} },
    { name = "nil",          args = { nil }, n = 1 },
    { name = "empty string", args = { "" }, n = 1 },
    { name = "player",       args = { "player" }, n = 1 },
    { name = "zero",         args = { 0 }, n = 1 },
    { name = "negative",     args = { -1 }, n = 1 },
    { name = "huge",         args = { 999999 }, n = 1 },
    { name = "wrong type",   args = { {} }, n = 1 },
}

local function describe(...)
    local n = select("#", ...)
    if n == 0 then return 0, "" end
    local parts = {}
    for i = 1, math.min(n, 6) do
        local v = select(i, ...)
        parts[i] = type(v) .. ":" .. tostring(v)
    end
    return n, table.concat(parts, " | ")
end

local function matrix(out)
    for _, fname in ipairs(PULL) do
        local fn = _G[fname]
        if type(fn) ~= "function" then
            -- ★ A MISSING GLOBAL IS A FINDING, not a skip. Half the point of running
            -- this on THIS fork is learning which of these exist at all.
            out[#out + 1] = { fn = fname, input = "-", ok = false, err = "NOT PRESENT IN _G" }
        else
            for _, inp in ipairs(INPUTS) do
                local res = { pcall(fn, unpack(inp.args, 1, inp.n or #inp.args)) }
                local ok = table.remove(res, 1)
                local row = { fn = fname, input = inp.name, ok = ok }
                if ok then
                    row.rets, row.value = describe(unpack(res, 1, table.maxn(res)))
                else
                    -- The error handler is the point: WHAT it says, not just that it
                    -- fired. A message naming the argument is one we can guard on.
                    row.err = tostring(res[1])
                end
                out[#out + 1] = row
            end
        end
    end
    return out
end

-- ---------------------------------------------------------------------

D.RegisterTask{
    name = "api",
    mode = "oneshot",
    help = "api - measure client behaviours the offline harness MODELS, and matrix "
        .. "the PULL API against bad inputs. Read-only; builds nothing visible.",
    run = function(args)
        local payload = D.Begin("api", args)
        payload.where = {
            zone = GetRealZoneText(),
            subZone = GetSubZoneText(),
            mapID = select(4, GetCurrentPlayerPosition()),
            floor = GetCurrentMapDungeonLevel and GetCurrentMapDungeonLevel() or nil,
            inInstance = IsInInstance and IsInInstance() or false,
        }
        payload.behaviours = behaviours({})
        payload.calls = matrix({})

        local disagree = 0
        for _, b in ipairs(payload.behaviours) do
            if not b.agrees then disagree = disagree + 1 end
        end
        local threw, missing = 0, 0
        for _, c in ipairs(payload.calls) do
            if c.err == "NOT PRESENT IN _G" then missing = missing + 1
            elseif not c.ok then threw = threw + 1 end
        end
        payload.verdict = { disagree = disagree, threw = threw, missing = missing }

        -- ★ BY EXCEPTION, and the count that matters leads. A run where the harness
        -- agrees on everything is a one-line "nothing to see"; a single disagreement
        -- is the whole reason the task exists.
        D.Commit(("api: %d behaviour(s), |cff%s%d disagree|r; %d call(s), %d threw, "
                  .. "%d missing"):format(
            #payload.behaviours, disagree > 0 and "ff5555" or "55ff55", disagree,
            #payload.calls, threw, missing))
    end,
}
