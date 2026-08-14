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
--
-- ★★★ EVERY EXPERIMENT CARRIES A CONTROL, and the first run is why.
--
-- v1 parented everything to a HIDDEN host for safety. A child of a hidden parent can
-- never become visible, so Show() never transitioned, OnShow never fired, and three
-- experiments returned zero - which the task reported as THREE DISAGREEMENTS about
-- the client, in red. It could not tell "the client disagrees" from "my experiment
-- never ran".
--
-- ⚠ AND THE ONE THAT "AGREED" WAS THE WORST OF THEM. `SetChecked does not fire
-- OnClick` measured zero in a run where EVERYTHING measured zero, so it passed for
-- entirely the wrong reason. ★ A CLAIM OF ABSENCE IS UNFALSIFIABLE UNTIL THE
-- DETECTOR IS PROVEN TO WORK - so that one now CLICKS the button first, and only
-- then checks that SetChecked does not.
--
-- So each experiment returns a `control`: a measurement that must succeed whatever
-- the claim turns out to be. Control false -> the row is INCONCLUSIVE, never
-- `disagree`. **A dead apparatus is loud about being dead.**
--
-- ★ The shape is §70's completeness walk: you can only ask "is anything missing?"
-- if the whole set can be enumerated and each member interrogated the same way.
-- ---------------------------------------------------------------------

-- ⚠ NAMES ARE THE JOIN to harness.lua, checked desk-side by
-- addons/tools/check_harness.py. Two hand-maintained lists that must agree, with
-- nothing to notice when they stop - which is exactly the §63 fault §70 was written
-- for. Rename here, rename there.
local BEHAVIOURS = {

    -- ★ The one §81's near-freeze rests on. Control: it must fire on a CHANGED
    -- value, or we have no detector and the unchanged-value question is unanswerable.
    {
        name = "SetText fires OnTextChanged",
        claim = "fires on any SetText, changed or not",
        -- ⚠ v2 came back INCONCLUSIVE here - changed=0, so the handler did not fire
        -- even on a real change. Two candidate causes, and v3 addresses both rather
        -- than guessing which: the box had no SIZE or ANCHOR (a zero-area EditBox may
        -- never process text), and the read was SYNCHRONOUS (the fire may be
        -- deferred to the next frame).
        --
        -- ★ THE DEFERRED RE-READ IS THE DISCRIMINATOR, and it matters beyond this
        -- row: if OnTextChanged is deferred rather than synchronous, §81's freeze
        -- does not recurse the way the harness models it, and the depth guard is
        -- guarding the wrong shape.
        run = function(host)
            local e = CreateFrame("EditBox", nil, host, "InputBoxTemplate")
            e:SetWidth(80); e:SetHeight(20)
            e:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
            e:SetAutoFocus(false)
            e:SetFontObject("GameFontHighlightSmall")
            local n = 0
            e:SetScript("OnTextChanged", function() n = n + 1 end)
            e:SetText("alpha")
            local changed = n
            e:SetText("alpha")                      -- same value, deliberately
            local same = n - changed
            return ("sync changed=%d same-value=%d"):format(changed, same),
                   changed >= 1 and same >= 1,
                   changed >= 1,                     -- CONTROL: fired synchronously
                   -- LATER: re-read after a frame. Control widens to "did it fire at
                   -- ALL", so "never fires" and "fires late" stop being one answer.
                   function()
                       local total = n
                       return ("sync changed=%d same=%d | after 1 frame total=%d")
                              :format(changed, same, total),
                              total >= 2,
                              total >= 1
                   end
        end,
    },

    {
        name = "Show/Hide fire on transitions only",
        claim = "one OnShow and one OnHide across two calls each",
        run = function(host)
            local fr = CreateFrame("Frame", nil, host)
            fr:Hide()
            local shown, hidden = 0, 0
            fr:SetScript("OnShow", function() shown = shown + 1 end)
            fr:SetScript("OnHide", function() hidden = hidden + 1 end)
            fr:Show(); fr:Show()
            fr:Hide(); fr:Hide()
            return ("OnShow=%d OnHide=%d"):format(shown, hidden),
                   shown == 1 and hidden == 1,
                   (shown + hidden) > 0              -- CONTROL: visibility events reach us
        end,
    },

    -- ★ §19, load-bearing for every tile the map draws, believed since v0.4 and
    -- never measured. ⚠ Control has TWO parts, because v1 had neither: the crop must
    -- have taken, AND the texture must actually have changed. Without the second,
    -- "the crop survived" and "SetTexture did nothing" are the same reading.
    {
        name = "Texture:SetTexture preserves TexCoord",
        claim = "the crop SURVIVES a new texture (raw texture API)",
        run = function(host)
            local t = host:CreateTexture(nil, "BACKGROUND")
            t:SetTexture("Interface\\Icons\\INV_Misc_Key_03")
            local texA = t:GetTexture()
            t:SetTexCoord(0.1, 0.9, 0.2, 0.8)
            local cropped = ({ t:GetTexCoord() })[1]
            t:SetTexture("Interface\\Icons\\INV_Misc_Key_04")
            local texB = t:GetTexture()
            local after = ({ t:GetTexCoord() })[1]
            local cropTook = cropped ~= nil and cropped > 0.05
            local texChanged = texA ~= nil and texB ~= nil and texA ~= texB
            -- ★ MEASURED 2026-08-14 (SFK): the crop SURVIVES. §19's reset lives in a
            -- stock Lua wrapper (`GetNormalTexture():SetTexCoord(0,1,0,1)` inside the
            -- POI mixin path), NOT in the raw C SetTexture - and the harness had
            -- generalised it to every texture. ⚠ Bound: two icons of the SAME
            -- dimensions. Differing dimensions is untested.
            return ("crop=%s after=%s texA=%s texB=%s"):format(
                       tostring(cropped), tostring(after), tostring(texA), tostring(texB)),
                   after ~= nil and after > 0.05,
                   cropTook and texChanged           -- CONTROL: both halves must be real
        end,
    },

    -- ⚠ A CLAIM OF ABSENCE. Click() first to prove the handler is live; only then is
    -- "SetChecked did not fire it" a measurement rather than a coincidence.
    {
        name = "SetChecked does NOT fire OnClick",
        claim = "no OnClick from SetChecked",
        run = function(host)
            local c = CreateFrame("CheckButton", nil, host, "UICheckButtonTemplate")
            local clicks = 0
            c:SetScript("OnClick", function() clicks = clicks + 1 end)
            c:Click()                                 -- CONTROL: prove the detector works
            local viaClick = clicks
            c:SetChecked(true)
            c:SetChecked(false)
            local viaSet = clicks - viaClick
            return ("viaClick=%d viaSetChecked=%d"):format(viaClick, viaSet),
                   viaSet == 0,
                   viaClick >= 1
        end,
    },

    -- The census counts OnUpdate installs and clears as if this were true, and every
    -- transient-handler claim in the addon rests on it.
    {
        name = "SetScript replaces, never adds",
        claim = "only the second handler runs",
        run = function(host)
            local fr = CreateFrame("Frame", nil, host)
            fr:Hide()
            local a, b = 0, 0
            fr:SetScript("OnShow", function() a = a + 1 end)
            fr:SetScript("OnShow", function() b = b + 1 end)
            fr:Show()
            return ("first=%d second=%d"):format(a, b),
                   a == 0 and b == 1,
                   (a + b) > 0                       -- CONTROL: the event arrived at all
        end,
    },
}

-- Applies a row's verdict from (observed, agrees, control). One place, so the
-- deferred re-read and the synchronous first pass cannot drift apart on what
-- `inconclusive` means.
local function verdictOf(row, observed, agrees, control)
    row.observed = observed
    row.agrees = agrees and true or false
    row.control = control and true or false
    -- ★ CONTROL DECIDES. A row whose apparatus did not demonstrably work reports
    -- INCONCLUSIVE, never disagree - the whole lesson of run 1 in one line.
    row.verdict = (not control) and "inconclusive"
                  or (agrees and "agrees" or "DISAGREES")
    return row
end

local function behaviours(out, pending)
    -- ★★ PARENTED TO UIParent AND NEVER HIDDEN. v1 hid the host for safety and paid
    -- for it with three false findings. A frame with no size, no anchor and no
    -- textures renders nothing whether or not it is "shown", so the safety was
    -- costing the measurement and buying nothing.
    local host = CreateFrame("Frame", nil, UIParent)
    host:SetWidth(1); host:SetHeight(1)
    host:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -500, 500)   -- off-screen, still shown

    for _, spec in ipairs(BEHAVIOURS) do
        local row = { name = spec.name, claim = spec.claim }
        out[#out + 1] = row
        local ok, observed, agrees, control, later = pcall(spec.run, host)
        if not ok then
            verdictOf(row, "ERROR: " .. tostring(observed), false, false)
        else
            verdictOf(row, observed, agrees, control)
            -- ★ A DEFERRED RE-READ, if the experiment offers one. The row is written
            -- twice: once synchronously so a crash mid-cycle still leaves a readable
            -- sheet, and again after a frame with the fuller answer.
            if later and pending then
                pending[#pending + 1] = function()
                    local ok2, o2, a2, c2 = pcall(later)
                    if ok2 then
                        verdictOf(row, o2, a2, c2)
                        row.deferred = true
                    end
                end
            end
        end
    end

    -- ⚠ The host is NOT torn down here any more: a deferred re-read runs a frame
    -- later and its EditBox must still have a parent. Cleared by the caller once
    -- everything has reported.
    return out, host
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
-- ★★★ THE CATCH-ALL, and it is the whole lesson of run 1.
--
-- Count the VERDICTS rather than the disagreements, and count how many experiments
-- had a WORKING APPARATUS. If not one control fired, nothing was measured at all -
-- and the run must SAY SO rather than present a column of zeros as findings about
-- the client, which is exactly what run 1 did, in red, four times.
-- ---------------------------------------------------------------------

local function summarise(payload)
    local agree, disagree, inconclusive, live = 0, 0, 0, 0
    for _, b in ipairs(payload.behaviours) do
        if b.control then live = live + 1 end
        if b.verdict == "agrees" then agree = agree + 1
        elseif b.verdict == "DISAGREES" then disagree = disagree + 1
        else inconclusive = inconclusive + 1 end
    end
    local threw, missing = 0, 0
    for _, c in ipairs(payload.calls) do
        if c.err == "NOT PRESENT IN _G" then missing = missing + 1
        elseif not c.ok then threw = threw + 1 end
    end

    -- ★ DEAD is a property of the RUN, not of a row. One experiment with a dead
    -- control is a broken experiment; ALL of them dead is a broken apparatus, and
    -- those want different reactions from whoever reads this.
    local dead = live == 0
    payload.verdict = {
        agree = agree, disagree = disagree, inconclusive = inconclusive,
        live = live, dead = dead, threw = threw, missing = missing,
    }

    -- BY EXCEPTION, and the thing most worth knowing leads. A dead apparatus
    -- outranks a disagreement, because a disagreement measured by a dead apparatus
    -- is not a disagreement at all.
    local lead
    if dead then
        lead = "|cffff5555APPARATUS DEAD|r - no control fired; nothing was measured"
    elseif disagree > 0 then
        lead = ("|cffff5555%d disagree|r"):format(disagree)
    elseif inconclusive > 0 then
        lead = ("|cffffd100%d inconclusive|r"):format(inconclusive)
    else
        lead = "|cff55ff55all agree|r"
    end
    D.Commit(("api: %d behaviour(s), %s (%d live); %d call(s), %d threw, %d missing")
        :format(#payload.behaviours, lead, live, #payload.calls, threw, missing))
end

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
        local pending = {}
        local host
        payload.behaviours, host = behaviours({}, pending)
        payload.calls = matrix({})

        -- ★ THE FINISH IS DEFERRED when any experiment asked for a second look.
        -- D.Cycle with perFrame=1 gives exactly one frame of separation, which is
        -- what separates "never fires" from "fires on the next frame".
        local function finish()
            if host then host:Hide(); host:SetParent(nil) end
            summarise(payload)
        end

        if #pending > 0 then
            D.Cycle(function(i)
                if i < 2 then return false end       -- let one full frame elapse
                for _, apply in ipairs(pending) do pcall(apply) end
                return true
            end, 1, finish)
        else
            finish()
        end
    end,
}
