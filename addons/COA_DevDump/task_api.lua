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
-- ★★★ v5: INVISIBILITY BY ALPHA, NOT BY POSITION - and this is the same mistake
-- twice in a new costume.
--
--   v1  hid the host              -> three false findings; a hidden parent means a
--                                    child can never become visible
--   v2-v4 put the host OFF-SCREEN -> Show/Hide, Click and textures all worked there,
--                                    but the EditBox experiments were UNSTABLE: run 3
--                                    saw a fire, run 4 saw none from identical code.
--
-- ⚠ Both times I bought invisibility by TAKING THE FRAME OUT OF THE LAYOUT, and both
-- times it cost the measurement. An EditBox may need to be genuinely on-screen and
-- laid out to process text at all.
--
-- ★ SetAlpha(0) is the correct way to be unobtrusive: on-screen, laid out, fully
-- processed by the client, invisible to whoever is running it.
--
-- ★ And each box gets its OWN offset. Four boxes stacked on one point was a variable
-- nobody needed.
local BOX_N = 0
local function newBox(host)
    BOX_N = BOX_N + 1
    local e = CreateFrame("EditBox", nil, host, "InputBoxTemplate")
    e:SetWidth(80); e:SetHeight(20)
    e:SetPoint("TOPLEFT", host, "TOPLEFT", 0, -24 * (BOX_N - 1))
    e:SetAutoFocus(false)
    e:SetFontObject("GameFontHighlightSmall")
    e:SetAlpha(0)
    return e
end

-- ★ A BOX-LEVEL CONTROL, distinct from the handler-level one. Right now "the box is
-- inert" and "the handler is not firing" read identically; this separates them.
local function boxReadsBack(e)
    e:SetText("probe-readback")
    return e:GetText() == "probe-readback"
end

local BEHAVIOURS = {

    -- ★ The one §81's near-freeze rests on. Control: it must fire on a CHANGED
    -- value, or we have no detector and the unchanged-value question is unanswerable.
    {
        name = "SetText fires OnTextChanged only on a CHANGE",
        claim = "two sets of the same value produce ONE fire, deferred",
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
            local readback = boxReadsBack(e)
            return ("sync changed=%d same-value=%d"):format(changed, same),
                   changed >= 1 and same >= 1,
                   readback,
                   -- ★ A LONG WINDOW instead of one frame. Runs 3 and 4 disagreed on
                   -- this exact experiment because both asked "had it fired by frame
                   -- 1?" - a question whose answer depends on where the frame
                   -- boundary fell. Bank the count at spread points instead.
                   --
                   -- ★★ AND THE CONTROL IS NOW THE BOX, NOT THE HANDLER. If the text
                   -- reads back, the widget works - so a silent handler becomes a
                   -- FINDING rather than a dead rig, which is the distinction runs 3
                   -- and 4 could not make.
                   { frames = 180,
                     [30]  = function() at30 = n end,
                     [90]  = function() at90 = n end,
                     [180] = function()
                        -- ★ MEASURED run 5: sync=0, f30=1, stable at 1. Deferred,
                        -- coalesced, and the second (same-value) set added nothing.
                        return ("readback=%s | sync=%d f30=%d f90=%d f180=%d")
                               :format(tostring(readback), changed + same,
                                       at30 or -1, at90 or -1, n),
                               changed + same == 0 and n == 1, readback
                     end }
        end,
    },

    -- ---------------------------------------------------------------------
    -- ★★★ v4: WHAT KIND OF DEFERRAL IS IT? Run 3 measured `sync=0, after 1 frame
    -- total=1` for TWO SetText calls - deferred, but `1` is ambiguous between
    -- COALESCING (both merged) and CHANGE-ONLY (only the real change fired).
    --
    -- ⚠ WHICH ONE IS TRUE DECIDES WHETHER §81's FREEZE WAS EVER REAL, and whether
    -- harness.lua's depth guard is guarding a shape the client can produce.
    -- Exploratory: the harness models NONE of this yet, because until it is measured
    -- there is nothing honest to model.
    -- ---------------------------------------------------------------------

    -- His: *"Walk the alphabet and see how it handles it."* 26 distinct changes in
    -- one frame. 1 fire = coalesced regardless of count; 26 = queued and delivered;
    -- anything between is the interesting answer.
    {
        name = "OnTextChanged coalesces many sets in one frame",
        claim = "one fire per SetText",
        run = function(host)
            local e = newBox(host)
            local fires, seen, arg1 = 0, {}, "(none)"
            e:SetScript("OnTextChanged", function(self, a)
                fires = fires + 1
                -- Cap the sample: 26 fires would make an unreadable row, and the
                -- first few answer the question.
                if fires <= 4 then seen[#seen + 1] = tostring(self:GetText()) end
                if fires == 1 then arg1 = tostring(a) end
            end)
            local readback = boxReadsBack(e)
            for i = 1, 26 do e:SetText(string.char(96 + i)) end      -- a..z
            local sync, at30 = fires
            return ("sync fires=%d after 26 sets"):format(sync), sync == 26, readback,
                { frames = 180,
                  [30] = function() at30 = fires end,
                  [180] = function()
                    -- ★ arg#2 is the userInput flag question: the client MAY pass a
                    -- second argument distinguishing typed input from SetText. If it
                    -- does, that is the clean way to break every refresh loop -
                    -- ignore programmatic changes - and nothing here has ever used it.
                    return ("26 sets: sync=%d f30=%d f180=%d | first-seen=[%s] arg#2=%s")
                           :format(sync, at30 or -1, fires,
                                   table.concat(seen, ","), arg1),
                           fires == 26,
                           readback
                  end }
        end,
    },

    -- ★★ THE DISCRIMINATOR. Set a CHANGED value, let a frame pass, then set the SAME
    -- value again and let another pass. If the second frame adds a fire, unchanged
    -- values DO fire and coalescing explained run 3. If it does not, it is
    -- change-only - and §81's loop could never have run.
    {
        name = "OnTextChanged fires on an UNCHANGED value",
        claim = "a SetText with the same value still fires",
        run = function(host)
            local e = newBox(host)
            local readback = boxReadsBack(e)
            local fires, a, b, c = 0
            e:SetScript("OnTextChanged", function() fires = fires + 1 end)
            e:SetText("alpha")                                   -- f1: a real CHANGE
            -- ★★ 60 FRAMES APART, which is the whole point of the long window: no
            -- fire can be mistaken for another's, so the attribution needs no
            -- argument. a = the change, b-a = the same-value set, c-b = the change
            -- again, which proves the rig was still alive at the end.
            return "watching 3 sets, 60 frames apart", false, readback, {
                frames = 180,
                [50]  = function() a = fires end,
                [60]  = function() e:SetText("alpha") end,       -- the SAME value
                [110] = function() b = fires end,
                [120] = function() e:SetText("beta") end,        -- changed again
                [180] = function()
                    c = fires
                    return ("change->%d | same-value->%d | change-again->%d")
                           :format(a or -1, (b or 0) - (a or 0), (c or 0) - (b or 0)),
                           ((b or 0) - (a or 0)) > 0,
                           -- CONTROL: the box works AND a real change did fire, or
                           -- the same-value reading means nothing.
                           readback and (a or 0) > 0
                end,
            }
        end,
    },

    -- ★★★ HIS RACE QUESTION - staleness/freshness. If the fire is deferred AND
    -- coalesced, a handler reading GetText() sees the FINAL value, not the one that
    -- triggered it. Any code treating OnTextChanged as "tell me about this change"
    -- is then wrong, and would be wrong invisibly.
    {
        name = "OnTextChanged sees the text that TRIGGERED it",
        claim = "the handler reads the triggering value, not the latest",
        run = function(host)
            local e = newBox(host)
            local readback = boxReadsBack(e)
            local seen, raced = {}, 0
            e:SetScript("OnTextChanged", function(self)
                seen[#seen + 1] = tostring(self:GetText())
            end)
            e:SetText("first")
            e:SetText("second")                                  -- racing, same frame
            return "watching a raced pair, then a lone set", false, readback, {
                frames = 180,
                [50]  = function() raced = #seen end,
                -- ★ THE LONE SET IS THE CONTROL. Nothing races it, so the handler
                -- MUST see its own value - and if it does not, nothing the raced pair
                -- showed can be read at all.
                [60]  = function() e:SetText("lone") end,
                [180] = function()
                    local lone = seen[#seen]
                    return ("raced=%d seen=[%s] | lone-set saw %s")
                           :format(raced, table.concat(seen, ","), tostring(lone)),
                           seen[1] == "first",
                           readback and lone == "lone"
                end,
            }
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
        local ok, observed, agrees, control, plan = pcall(spec.run, host)
        if not ok then
            verdictOf(row, "ERROR: " .. tostring(observed), false, false)
        else
            verdictOf(row, observed, agrees, control)
            row.exploratory = spec.exploratory and true or nil
            -- ★★ A PLAN IS ONE FUNCTION PER FRAME, and it is what makes a deferred
            -- or coalesced client behaviour measurable at all. The row is written
            -- synchronously FIRST so a crash mid-plan still leaves a readable sheet,
            -- then overwritten by each step that returns a verdict.
            --
            -- A step returning nil means "not yet" - it acted (set some text, banked
            -- a count) and the answer comes later.
            if plan and pending then
                pending[#pending + 1] = { row = row, steps = plan }
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
            -- Run for as many frames as the longest plan needs. Every pending row
            -- advances one step per frame, in step with each other.
            -- ★ A plan may be SPARSE and keyed by frame - `{ frames = 180, [60] = fn }`
            -- - which is what lets an experiment space its actions far enough apart
            -- that the timeline attributes each result unambiguously. `frames` says
            -- how long to watch; without it a dense array still works as before.
            local frames = 0
            for _, p in ipairs(pending) do
                local want = p.steps.frames or #p.steps
                if want > frames then frames = want end
            end
            D.Cycle(function(i)
                for _, p in ipairs(pending) do
                    local step = p.steps[i]
                    if step then
                        local ok2, o2, a2, c2 = pcall(step)
                        -- nil observed = the step acted but has no answer yet
                        if ok2 and o2 then
                            verdictOf(p.row, o2, a2, c2)
                            p.row.deferred = true
                        elseif not ok2 then
                            verdictOf(p.row, "ERROR in plan: " .. tostring(o2), false, false)
                        end
                    end
                end
                return i >= frames
            end, 1, finish)
        else
            finish()
        end
    end,
}
