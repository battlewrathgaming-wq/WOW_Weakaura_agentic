-- task_geom.lua - THE MEASUREMENTS ONLY THE CLIENT CAN GIVE (§102).
--
-- ---------------------------------------------------------------------------
-- ★★★ WHY. §100 built an offline resolver that computes every position in the
-- object pane and refuses to invent the one thing it cannot know: a FontString's
-- extent, which is text x font. The 2010 `WoW UI Designer` approximated it and its
-- own release notes concede the result was *"not exactly like WoWs"* - it had to
-- guess, because its renderer was the only output. We do not. This is the run that
-- turns the unknowns into constants.
--
-- ★★ AND IT CAPTURES WIDER THAN THE ASK, on his instruction: *"capture broader than
-- the ask. That exposes trends and norms."* The ask was nine strings. What is
-- recorded is:
--
--   FONTS       every font object the panes use, x a calibration set - so any
--               future string can be PREDICTED rather than re-measured
--   TEMPLATES   the real rect of each stock control template, which is the
--               difference between what XML declares and what the client builds
--   NORMS       the client's OWN shipped panels, walked and measured - the spacing
--               as BUILT rather than as declared. §101 sourced 6/8/12 from their
--               XML; this is the check on whether their panels actually do that
--   OURS        the live object pane, every widget's rect - which is the DRIFT
--               check the offline resolver must not ship without
--
-- ⚠ THE APPARATUS PROVES ITSELF FIRST. Run 1 of `/coadump r api` reported four
-- disagreements about the client and all four were false, because the experiments
-- never ran. ★★★ A measurement of zero and a measurement that did not happen look
-- identical in a record. So a known string is measured before anything is believed,
-- and if it comes back zero this writes `apparatus = "dead"` and says so rather
-- than filing a page of zeros as facts.
--
-- ⚠ AND IT ANSWERS A QUESTION WE HAVE NOT ASKED: does a frame that was NEVER SHOWN
-- report a real width? `Click()` fires on hidden frames - measured - which is
-- suggestive and is NOT the same question. Both are measured here, side by side, so
-- the answer is a row rather than an assumption.
--
-- ★ Read-only in the sense that matters: nothing on the census's PUSH list is
-- called. It creates ITS OWN scratch widgets and reads them; no client state moves.
-- ---------------------------------------------------------------------------

local ADDON, D = ...

-- ★★★ THE SPECIMENS ARE READ, NOT HELD (RI-81 item 3, 2026-08-26).
--
-- This file used to carry its own `CALIBRATION`, `OURS` and `FONTS`, and `sheet_decl.lua`
-- carried a TRANSCRIPTION of all three - deliberately, so the offline loop could be closed
-- against captures already on disk with no client run. Its own note named the debt: *"that
-- leaves TWO copies of the specimen list … the second is to be deleted when `task_geom`
-- reads this file instead."* This is that.
--
-- ⚠ THE `.toc` COMMENT THERE IS STALE and was the reason it had not been done: it reads
-- *"NOT IN THE .toc YET"*, and `sheet_decl.lua` is in `COA_DevDump.toc` today. It loads
-- AFTER this file, which does not matter - these are read when the TASK RUNS, never at load.
--
-- ★★ AND IT REFUSES RATHER THAN FALLING BACK. A fallback copy would be the second copy
-- again, wearing a safety net's clothes: a run that quietly measured a different specimen
-- set would produce a calibration standard that is not the standard, and every offline
-- reader would trust it. `sheet_decl.lua`'s own discipline is the argument - *"APPEND-ONLY.
-- A calibration standard whose specimens change is not a standard."*
local function specimens()
    local decl = _G.COA_UI_SHEET and _G.COA_UI_SHEET.text
    if not decl then return nil end
    return decl.fonts, decl.calibration, decl.specimen
end

-- ⚠ EACH IS A CANDIDATE, NOT A PROMISE. A template that does not exist on this fork
-- is recorded as missing BY NAME - the census exists because absence is a finding.
local TEMPLATES = {
    { "UIPanelButtonTemplate", "Button" },
    { "UIPanelCloseButton", "Button" },
    { "InputBoxTemplate", "EditBox" },
    { "UICheckButtonTemplate", "CheckButton" },
    { "OptionsBaseCheckButtonTemplate", "CheckButton" },
    { "InterfaceOptionsCheckButtonTemplate", "CheckButton" },
    { "UIDropDownMenuTemplate", "Frame" },
    { "UIPanelScrollFrameTemplate", "ScrollFrame" },
}

-- ★ The client's own panels, for the NORMS pass. Walked if they exist, named if not.
local REFERENCE = {
    "InterfaceOptionsFrame", "InterfaceOptionsDisplayPanel",
    "InterfaceOptionsControlsPanel", "GameMenuFrame",
    "AddonList", "VideoOptionsFrame",
}

-- ⚠⚠ STRATA AND LEVEL COME TOO (§103). The first run recorded rects and nothing
-- else, so when he asked whether a control was being drawn OVER rather than
-- mispositioned, the capture could not answer - and `task_frames` had been recording
-- both all along. ★ A capture that is broad in one dimension and thin in another is
-- still thin.
-- ⚠⚠ §133: AN UNANCHORED FRAME MUST SAY SO. `GetRect` returns NOTHING for a frame
-- that has never been positioned, so its row came back with no left, no bottom, no
-- width and no height - identical to a frame the probe could not read at all. Two
-- envelope handles landed that way in §132 and were read as a SIZING bug; they are
-- sized (SetWidth(GRAB_PX)) and simply had no anchor yet, because no run was loaded.
--
-- ★★★ This file's own header already carried the law: "A measurement of zero and a
-- measurement that did not happen look identical in a record." An ABSENT measurement
-- and an UNANCHORED one look identical too, and the fix is the same - state it.
local function rectOf(w)
    local out = {}
    pcall(function()
        if w.GetRect then
            local l, b, ww, hh = w:GetRect()
            out.left, out.bottom, out.w, out.h = l, b, ww, hh
        end
    end)
    pcall(function() out.points = w:GetNumPoints() end)
    pcall(function() out.shown = w:IsShown() and true or false end)
    pcall(function() out.visible = w:IsVisible() and true or false end)
    pcall(function() out.strata = w:GetFrameStrata() end)
    pcall(function() out.level = w:GetFrameLevel() end)
    pcall(function() out.objectType = w:GetObjectType() end)

    -- ★★★ §238: CAPTURE EVERYTHING, FILTER AT THE DESK. His: *"Can you make a stable
    -- test that captures everything? And then a reader to filter to the slice of
    -- interest. That way we have a profile as we develop."*
    --
    -- ★★ THE CAPTURE IS THE STABLE HALF. It does not learn a new question each time we
    -- have one - the READER does. Which is this project's own law arriving at the probe:
    -- *"the learner does not yet know what will matter, so filtering at capture decides
    -- for them before they have had the run that would have taught them."*
    --
    -- ⚠ EVERY LINE IS ITS OWN `pcall`, so a widget without a method loses that FIELD and
    -- not the row. A FontString has no `IsEnabled` and a Button has no `GetTextColor`;
    -- one guard around the block would have thrown the whole record away for a question
    -- it was never asked.
    pcall(function() out.alpha = w:GetAlpha() end)
    pcall(function() out.scale = w:GetScale() end)
    pcall(function() out.enabled = w:IsEnabled() and true or false end)
    pcall(function() out.checked = w:GetChecked() and true or false end)
    pcall(function() out.text = w:GetText() end)
    -- ★ THE COLOUR, and it is the one field with a question already waiting on it: the
    -- consequence register needs a fourth tone and a colour cannot be judged alone. This
    -- is what puts the pane's whole palette on one page beside it.
    pcall(function()
        local r, g, b, a = w:GetTextColor()
        if r then out.color = { r, g, b, a } end
    end)
    pcall(function()
        local p = w:GetParent()
        out.parentName = p and p.GetName and p:GetName() or nil
    end)
    return out
end

-- ★★ §238: THE REGISTRY'S HALF. `rectOf` reports what the CLIENT says; this reports what
-- WE declared and what the control currently answers. Both on one row, because a drift
-- between them is only visible when they sit together.
--
-- ⚠ `read` is called, and that is safe BY CONTRACT rather than by luck: a registration's
-- `read` is declared as a getter (`function() return f:IsShown() end`). It is pcall'd
-- anyway - a probe that can break the thing it measures is not a probe.
local function attach(row, UI, key)
    if not key or not UI or not UI.Get then return row end
    local c = UI.Get(key)
    if not c then return row end
    row.declaredKind = c.kind
    if c.read then pcall(function() row.value = c.read() end) end
    return row
end

D.RegisterTask{
    name = "geom",
    mode = "oneshot",
    help = "geom - measure fonts, control templates, the client's own panels and our object pane",
    run = function(args)
        local payload = D.Begin("geom", args)
        payload.scale = UIParent:GetEffectiveScale()
        payload.resolution = GetCVar and GetCVar("gxResolution") or nil

        -- =============================================================
        -- ★★★ THE CONTROL, FIRST AND ALWAYS. Nothing below is believable until a
        -- string of known non-zero length measures non-zero.
        -- =============================================================
        local host = CreateFrame("Frame", nil, UIParent)
        host:SetPoint("CENTER")
        host:SetWidth(400); host:SetHeight(400)

        local hiddenHost = CreateFrame("Frame", nil, UIParent)
        hiddenHost:SetPoint("CENTER")
        hiddenHost:SetWidth(400); hiddenHost:SetHeight(400)
        hiddenHost:Hide()

        local probe = host:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        probe:SetText("MMMMMMMMMM")
        local shownW = probe:GetStringWidth()

        local hidden = hiddenHost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        hidden:SetText("MMMMMMMMMM")
        local hiddenW = hidden:GetStringWidth()

        payload.control = {
            shownWidth = shownW,
            hiddenWidth = hiddenW,
            -- ★★ THE QUESTION WE HAD NOT ASKED, answered as a row rather than
            -- assumed. `Click()` fires on hidden frames; whether MEASUREMENT works
            -- on them is a different question and this is it.
            hiddenMeasures = (hiddenW and hiddenW > 0) and true or false,
            hiddenAgreesWithShown = (hiddenW and shownW and hiddenW == shownW) or false,
        }

        if not shownW or shownW <= 0 then
            payload.apparatus = "dead"
            D.Commit("geom: APPARATUS DEAD - a known string measured "
                .. tostring(shownW) .. ". Nothing else was recorded, because a zero "
                .. "and a measurement that never happened look identical in a file.")
            return
        end
        payload.apparatus = "live"

        -- ⚠⚠ THE DECLARATION OR NOTHING. Read here rather than at load: `sheet_decl.lua`
        -- comes after this file in the .toc, and a capture that measured a DIFFERENT set
        -- than the standard declares is worse than no capture - it is a standard that
        -- disagrees with itself and nothing downstream can tell.
        local FONTS, CALIBRATION, OURS = specimens()
        if not (FONTS and CALIBRATION and OURS) then
            payload.apparatus = "no declaration"
            D.Commit("geom: NO SPECIMEN DECLARATION - `COA_UI_SHEET.text` is absent, so "
                .. "the specimens this run would measure are unknown. Nothing was "
                .. "recorded: a capture against a guessed set reads exactly like a "
                .. "capture against the standard.")
            return
        end
        payload.specimenSource = "COA_UI_SHEET.text (sheet_decl.lua) v"
            .. tostring(_G.COA_UI_SHEET.version or "?")

        -- =============================================================
        -- ★★ FONTS x CALIBRATION. The norm, not just our strings.
        -- =============================================================
        payload.fonts = {}
        for _, fontName in ipairs(FONTS) do
            local row = { strings = {} }
            local ok = pcall(function()
                local fs = host:CreateFontString(nil, "OVERLAY", fontName)
                -- ⚠ `fs.GetStringHeight`, not `fs:GetStringHeight` - the colon is
                -- call syntax and cannot be used as a value. It is a parse error
                -- rather than a silent one, which is the good kind.
                row.height = fs.GetStringHeight and fs:GetStringHeight() or nil
                pcall(function()
                    local f, size, flags = fs:GetFont()
                    row.file, row.size, row.flags = f, size, flags
                end)
                pcall(function() row.lineHeight = fs:GetHeight() end)
                for _, s in ipairs(CALIBRATION) do
                    fs:SetText(s)
                    row.strings[s == "" and "(empty)" or s] = fs:GetStringWidth()
                end
                for _, s in ipairs(OURS) do
                    fs:SetText(s)
                    row.strings[s] = fs:GetStringWidth()
                end
                -- ★ The derived norm, computed HERE where both numbers are in hand:
                -- ten Ms minus one M, over nine. A per-character width for the widest
                -- glyph is what bounds a label rather than estimating it.
                local one, ten = row.strings["M"], row.strings["MMMMMMMMMM"]
                if one and ten and ten > one then row.perM = (ten - one) / 9 end
                local i1, i10 = row.strings["i"], row.strings["iiiiiiiiii"]
                if i1 and i10 and i10 > i1 then row.perI = (i10 - i1) / 9 end
            end)
            if not ok then row.error = "could not create or measure" end
            payload.fonts[fontName] = row
        end

        -- =============================================================
        -- ★★ TEMPLATES. What the client BUILDS, not what the XML declares.
        -- ⚠ The dropdown is measured twice - as created, and after
        -- UIDropDownMenu_SetWidth(96) - because `object.lua` calls that and the
        -- template puts textures either side of the width you ask for. How much
        -- wider it ends up is exactly what we refused to assert from memory.
        -- =============================================================
        payload.templates = {}
        payload.templatesMissing = {}
        for _, t in ipairs(TEMPLATES) do
            local name, kind = t[1], t[2]
            local made = nil
            local ok = pcall(function()
                made = CreateFrame(kind, nil, host, name)
            end)
            if ok and made then
                local row = rectOf(made)
                row.objectType = made.GetObjectType and made:GetObjectType() or nil
                pcall(function() row.declaredW = made:GetWidth() end)
                pcall(function() row.declaredH = made:GetHeight() end)
                if name == "UIDropDownMenuTemplate" and UIDropDownMenu_SetWidth then
                    pcall(function()
                        UIDropDownMenu_SetWidth(made, 96)
                        row.afterSetWidth96 = rectOf(made)
                        row.afterSetWidth96.getWidth = made:GetWidth()
                        row.afterSetWidth96.getHeight = made:GetHeight()
                    end)
                end
                payload.templates[name] = row
            else
                payload.templatesMissing[#payload.templatesMissing + 1] = name
            end
        end

        -- =============================================================
        -- ★★★ THE NORMS PASS: the client's own panels, walked and MEASURED.
        -- §101 sourced 6 / 8 / 12 out of their XML. This is whether their shipped
        -- panels actually measure that - a declaration and a build are two things.
        -- =============================================================
        payload.reference = {}
        payload.referenceMissing = {}
        for _, name in ipairs(REFERENCE) do
            local frame = _G[name]
            if frame then
                local rows = {}
                D.WalkFrameTree(frame, 3, {}, rows)
                -- ★ The walker gives identity; the rect gives geometry. Joined here
                -- rather than teaching the walker a second job.
                local kids = {}
                pcall(function()
                    for _, child in ipairs({ frame:GetChildren() }) do
                        local e = rectOf(child)
                        e.name = child.GetName and child:GetName() or nil
                        e.objectType = child.GetObjectType and child:GetObjectType() or nil
                        kids[#kids + 1] = e
                    end
                    for _, region in ipairs({ frame:GetRegions() }) do
                        local e = rectOf(region)
                        e.name = region.GetName and region:GetName() or nil
                        e.objectType = region.GetObjectType and region:GetObjectType() or nil
                        pcall(function() e.text = region.GetText and region:GetText() or nil end)
                        kids[#kids + 1] = e
                    end
                end)
                payload.reference[name] = { self = rectOf(frame), tree = #rows, parts = kids }
            else
                payload.referenceMissing[#payload.referenceMissing + 1] = name
            end
        end

        -- =============================================================
        -- ★★★ OURS: the object pane, every widget, for the DRIFT CHECK.
        -- ⚠ The resolver predicts these. A model that disagrees with the client is
        -- worse than no model, so the client's own numbers have to come back or the
        -- offline pass is unaudited.
        -- =============================================================
        payload.ours = {}
        payload.oursMissing = {}
        local UI = _G.COA_DungeonRunUIProbe    -- set by COA_DungeonRun if present
        if UI and UI.Keys then
            -- ★★★ THE REGISTRY NAMES; THE PANE ENUMERATES. §103's lesson, and it cost
            -- a real bug: the promoter's route dropdown was never registered, so a
            -- 44-pixel collision was invisible to a check that only ever saw four of
            -- the five controls in that pane. ⚠ A completeness check built on a
            -- hand-maintained list is not a completeness check.
            --
            -- So the registry is used for NAMING and the pane's own children are
            -- what get measured. An unregistered widget still lands - as
            -- `(Frame #3)` - and collides loudly instead of hiding.
            local named = {}
            local panes = {}
            for _, key in ipairs(UI.Keys()) do
                local c = UI.Get and UI.Get(key)
                if c and c.frame then
                    named[c.frame] = key
                    if key:find("%.pane$") then panes[#panes + 1] = { key, c.frame } end
                else
                    payload.oursMissing[#payload.oursMissing + 1] = key
                end
            end

            for _, pane in ipairs(panes) do
                local key, frame = pane[1], pane[2]
                local e = rectOf(frame)
                e.key, e.kind, e.isPane = key, "frame", true
                payload.ours[#payload.ours + 1] = e

                local owner = key:match("^([^.]+)")
                local n = 0
                pcall(function()
                    for _, child in ipairs({ frame:GetChildren() }) do
                        n = n + 1
                        local c = rectOf(child)
                        c.key = named[child]
                            or ("%s.(unregistered %s #%d)"):format(
                                   owner, c.objectType or "Frame", n)
                        c.registered = named[child] ~= nil
                        -- ★ §238: what the REGISTRY says it is, beside what the client
                        -- says it looks like. The declared kind and the live value are
                        -- the two halves nothing else in the record carries.
                        attach(c, UI, named[child])
                        -- ⚠ A named frame is worth recording BY name too: the
                        -- dropdown that hid needed one, and `GetName` is how a
                        -- human finds it in the source.
                        pcall(function() c.frameName = child:GetName() end)
                        payload.ours[#payload.ours + 1] = c
                    end
                end)

                -- ★★★ §133: AND THE REGIONS, WHICH IS A QUARTER OF THE INVENTORY.
                --
                -- `GetChildren` returns FRAMES. A FontString is a REGION, so every
                -- readout we own - 21 of them - was registered, reachable by a typed
                -- line, and had NEVER BEEN MEASURED by this probe. §132 walked six
                -- panes and reported 67 children without them.
                --
                -- ⚠ The reference walk above has had both loops from the start. The
                -- gap was only ever in OUR half, which is the half nobody was
                -- comparing against a second source.
                local rn = 0
                pcall(function()
                    for _, region in ipairs({ frame:GetRegions() }) do
                        rn = rn + 1
                        local e = rectOf(region)
                        e.key = named[region]
                            or ("%s.(unregistered %s #%d)"):format(
                                   owner, e.objectType or "Region", rn)
                        e.registered = named[region] ~= nil
                        e.isRegion = true
                        attach(e, UI, named[region])
                        -- The text IS the readout's measurement - a FontString's
                        -- width is a consequence of it.
                        pcall(function() e.text = region:GetText() end)
                        payload.ours[#payload.ours + 1] = e
                    end
                end)
            end
        else
            -- ⚠ NAMED, not skipped. "COA_DungeonRun was not loaded" and "the pane
            -- had nothing in it" are different answers and a gap cannot say which.
            payload.oursMissing[#payload.oursMissing + 1] =
                "COA_DungeonRunUIProbe absent - is COA_DungeonRun loaded?"
        end

        local nf = 0
        for _ in pairs(payload.fonts) do nf = nf + 1 end
        local nt = 0
        for _ in pairs(payload.templates) do nt = nt + 1 end
        local nr = 0
        for _ in pairs(payload.reference) do nr = nr + 1 end

        D.Commit(("geom: %d font(s), %d template(s) (%d missing), %d reference panel(s), "
            .. "%d of our controls. Hidden frames measure: %s")
            :format(nf, nt, #payload.templatesMissing, nr, #payload.ours,
                    tostring(payload.control.hiddenMeasures)))
    end,
}
