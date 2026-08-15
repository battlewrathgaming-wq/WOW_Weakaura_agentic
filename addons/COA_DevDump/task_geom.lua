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

-- ★★ THE CALIBRATION SET. Not our strings - a set that yields a NORM. The empty
-- string gives the fixed overhead, the repeats give per-character width for a wide
-- and a narrow glyph, and the pangram gives a realistic mixed-case average. From
-- those, any string's width can be estimated without measuring it.
local CALIBRATION = {
    "", "M", "MMMMMMMMMM", "i", "iiiiiiiiii", " ",
    "The quick brown fox jumps over the lazy dog",
}

-- ★ And the strings the panes ACTUALLY draw, so the common cases are exact rather
-- than estimated. ⚠ Kept beside the calibration set on purpose: an estimate that is
-- never checked against a real measurement is a second guess wearing a number.
local OURS = {
    "identity", "detect", "action", "stage", "on-ramp", "children",
    "behaviour", "role", "shape", "reach", "target", "outcome",
    "move", "delete", "here", "pick", "ramp", "unseen",
    "right-click a beacon, a child or a note on the map",
}

local FONTS = {
    "GameFontNormal", "GameFontNormalSmall", "GameFontNormalLarge",
    "GameFontHighlight", "GameFontHighlightSmall",
    "GameFontDisable", "GameFontDisableSmall", "GameFontRed",
    "ChatFontNormal", "ChatFontSmall", "NumberFontNormal",
}

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

local function rectOf(w)
    local out = {}
    pcall(function()
        if w.GetRect then
            local l, b, ww, hh = w:GetRect()
            out.left, out.bottom, out.w, out.h = l, b, ww, hh
        end
    end)
    pcall(function() out.shown = w:IsShown() and true or false end)
    pcall(function() out.visible = w:IsVisible() and true or false end)
    return out
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
            for _, key in ipairs(UI.Keys()) do
                local c = UI.Get and UI.Get(key)
                if c and c.frame then
                    local e = rectOf(c.frame)
                    e.key, e.kind = key, c.kind
                    payload.ours[#payload.ours + 1] = e
                else
                    payload.oursMissing[#payload.oursMissing + 1] = key
                end
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
