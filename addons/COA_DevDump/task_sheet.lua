-- task_sheet.lua - spawn the UI test sheet, measure every declared cell, record it.
--
--     /coadump r sheet        spawn it, measure it, record it
--     /reload                 flush the mailbox (the watcher lands it)
--
-- ★★★ ONE COMMAND, NO ARGUMENTS, EVERY TIME (Battlewrath, 2026-08-23: *"I get lost writing the
-- test commands manually"*). A resolution sweep is the SAME command at every setting - the run
-- reads the configuration off the client itself rather than being told it. There is nothing to
-- remember and nothing to type differently, which is the only form a sweep survives.
--
-- ★★ THE SHEET IS SHOWN WHILE IT IS MEASURED, AND THAT IS CORRECTNESS, NOT PRESENTATION.
-- `check_sheet.py` measured it: across seven geom captures every SHOWN FontString width sits on
-- the client's integer grid and the never-shown control width is the ONLY value off it - 1.7%
-- different, which is the worst kind of wrong because nothing downstream would flag it. So the
-- host is parented, positioned and left visible, and the record says so.
--
-- ★ AND BEING VISIBLE IS ALSO THE POINT. The measured cells are checked by machine; the swatch
-- rows exist to be LOOKED at, because whether a face reads right is not a measurable question.
-- `ui_sheet_spec.md` keeps those two natures apart on purpose.
--
-- ⚠ THE DECLARATION IS THE SOURCE. Specimens come from `sheet_decl.lua` (COA_UI_SHEET) and this
-- file invents none of them. If the global is missing the run REFUSES rather than measuring a
-- default it made up - a sheet whose specimens came from the measuring tool is not a standard.

local ADDON, D = ...

-- The host is created once and reused, so a sweep does not stack eleven panes.
local sheet

local function buildSheet()
    if sheet then return sheet end

    sheet = CreateFrame("Frame", "COA_UISheet", UIParent)
    sheet:SetWidth(560)
    sheet:SetHeight(360)
    sheet:SetPoint("CENTER")
    sheet:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    sheet:SetMovable(true)
    sheet:EnableMouse(true)
    sheet:RegisterForDrag("LeftButton")
    sheet:SetScript("OnDragStart", function(self) self:StartMoving() end)
    sheet:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local close = CreateFrame("Button", nil, sheet, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", sheet, "TOPRIGHT", -6, -6)

    sheet.title = sheet:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sheet.title:SetPoint("TOPLEFT", sheet, "TOPLEFT", 18, -18)

    sheet.config = sheet:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sheet.config:SetPoint("TOPLEFT", sheet.title, "BOTTOMLEFT", 0, -6)

    -- The measuring host. Parented to the sheet so it inherits the same effective
    -- scale as everything on it, and never hidden.
    sheet.host = CreateFrame("Frame", nil, sheet)
    sheet.host:SetPoint("TOPLEFT", sheet, "TOPLEFT", 18, -70)
    sheet.host:SetWidth(520)
    sheet.host:SetHeight(270)

    sheet.rows = {}
    return sheet
end

-- One visible row per font object: the face rendered in itself. Eleven rows is a
-- swatch board a person can read; 286 strings on screen is a wall.
local function swatchRow(host, index, fontName)
    local fs = sheet.rows[index]
    if not fs then
        fs = host:CreateFontString(nil, "OVERLAY", fontName)
        fs:SetPoint("TOPLEFT", host, "TOPLEFT", 0, -((index - 1) * 24))
        sheet.rows[index] = fs
    end
    fs:SetText(fontName .. "  -  The quick brown fox")
    return fs
end

D.RegisterTask{
    name = "sheet",
    mode = "oneshot",
    help = "sheet - spawn the UI test sheet, measure every declared cell, record it",
    run = function(args)
        if type(COA_UI_SHEET) ~= "table" or type(COA_UI_SHEET.text) ~= "table" then
            D.Print("sheet: COA_UI_SHEET is not loaded - sheet_decl.lua missing from the .toc. "
                .. "Nothing measured; a standard the measuring tool invented is not a standard.")
            return
        end

        local decl = COA_UI_SHEET
        local payload = D.Begin("sheet", args)
        payload.declVersion = decl.version

        buildSheet()
        sheet:Show()

        -- =============================================================
        -- ★★ THE CONFIGURATION, READ OFF THE CLIENT. The sweep varies this and
        -- nothing else; the run must never be TOLD what it is.
        -- ★★★ `screenWidth`/`screenHeight` are here because they are the numbers
        -- most likely to settle the open question: the returned unit is
        -- 1/0.6275280733 = 1.5936 device px, while uiScale x screenH/768 is
        -- 2.2534, so the obvious mapping is wrong and the client's own idea of
        -- its UI extent is the missing term.
        -- =============================================================
        -- ★★★ THE APPARATUS GATE FOR SHEET TWO. A control measurement is a measurement
        -- of whichever AceGUI copy LibStub resolved, and that is NOT ours to decide: we
        -- ship AceGUI 33 / AceConfigDialog 49, this client carries 41 / 54 inside other
        -- addons, and LibStub keeps the highest minor LOADED - so the enabled addon set
        -- picks the code. ⚠ Without these numbers a control row is not reproducible, and
        -- a run that cannot be reproduced is an anecdote.
        local libs = {}
        if LibStub then
            for _, name in ipairs({ "AceGUI-3.0", "AceConfig-3.0", "AceConfigDialog-3.0",
                                    "AceConfigRegistry-3.0" }) do
                local lib, minor = LibStub(name, true)
                -- ⚠⚠ tostring() IS THE WHOLE FIX, and it cost a run. On this fork every
                -- Ace minor is INFINITY, and SavedVariables cannot serialise a non-finite
                -- number: the mailbox wrote `["AceGUI-3.0"] = nil --[[ inf ]]`, so all
                -- four gate values arrived in the repo as null. The client KNEW - the
                -- summary line printed `AceGUI 1.#INF` because it was built before the
                -- flush - and the fact was destroyed on the way out.
                -- ★ The general rule for anything crossing the mailbox: a number that
                -- could be inf or nan must be a STRING before it is stored, or a nil and
                -- an infinity become indistinguishable in the file.
                libs[name] = lib and tostring(minor or "loaded, minor unknown")
                    or "not loaded"
            end
        else
            libs.LibStub = "not present"
        end

        payload.config = {
            libs = libs,
            uiScaleCVar = GetCVar and GetCVar("uiScale") or nil,
            resolution = GetCVar and GetCVar("gxResolution") or nil,
            useUiScale = GetCVar and GetCVar("useUiScale") or nil,
            uiParentScale = UIParent:GetScale(),
            uiParentEffectiveScale = UIParent:GetEffectiveScale(),
            hostEffectiveScale = sheet.host:GetEffectiveScale(),
            screenWidth = GetScreenWidth and GetScreenWidth() or nil,
            screenHeight = GetScreenHeight and GetScreenHeight() or nil,
            uiParentWidth = UIParent:GetWidth(),
            uiParentHeight = UIParent:GetHeight(),
        }
        -- ★ Kept at the old key too, so `check_sheet.py` reads a sheet record and a
        -- geom record through one path rather than growing a second reader.
        payload.scale = payload.config.uiParentEffectiveScale
        payload.resolution = payload.config.resolution

        -- =============================================================
        -- ★★★ THE CONTROL, FIRST AND ALWAYS - task_geom's rule, kept because it
        -- earned itself: a zero and a measurement that never happened look
        -- identical in a file.
        -- =============================================================
        local probe = sheet.host:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        probe:SetText("MMMMMMMMMM")
        local shownW = probe:GetStringWidth()
        payload.control = { shownWidth = shownW, shown = sheet:IsShown() and true or false }
        probe:SetText("")

        if not shownW or shownW <= 0 then
            payload.apparatus = "dead"
            D.Commit("sheet: APPARATUS DEAD - a known string measured " .. tostring(shownW)
                .. ". Nothing else was recorded.")
            return
        end
        payload.apparatus = "live"

        -- =============================================================
        -- KIND `text` - every declared font object x every declared string.
        -- Both string roles are measured; the fit/hold-out split is the
        -- READER's business, not the instrument's.
        -- =============================================================
        payload.cells = {}
        payload.fonts = {}
        payload.fontsMissing = {}

        local fonts = decl.text.fonts or {}
        local measured, missing = 0, 0

        for i = 1, #fonts do
            local fontName = fonts[i]
            local row = { strings = {} }
            local ok = pcall(function()
                local fs = swatchRow(sheet.host, i, fontName)
                local f, size, flags = fs:GetFont()
                row.file, row.size, row.flags = f, size, flags
                -- ⚠ The geom runsheet left this owed: GetHeight() answered 0 on every
                -- font there. Read after a SetText on a SHOWN frame, which is what
                -- this run is.
                row.height = fs.GetStringHeight and fs:GetStringHeight() or nil
                row.lineHeight = fs:GetHeight()

                for _, roleName in ipairs({ "calibration", "specimen" }) do
                    local list = decl.text[roleName] or {}
                    for j = 1, #list do
                        local s = list[j]
                        fs:SetText(s)
                        local w = fs:GetStringWidth()
                        row.strings[s == "" and "(empty)" or s] = w
                        payload.cells[#payload.cells + 1] = {
                            kind = "text", font = fontName, role = roleName,
                            text = s, width = w,
                        }
                        measured = measured + 1
                    end
                end
                -- leave the row legible rather than holding the last specimen
                swatchRow(sheet.host, i, fontName)
            end)
            if not ok then
                row.error = "could not create or measure"
                payload.fontsMissing[#payload.fontsMissing + 1] = fontName
                missing = missing + 1
            end
            payload.fonts[fontName] = row
        end

        -- =============================================================
        -- KIND `control` (sheet two) - what an AceGUI widget BECOMES when asked
        -- for a width. ⚠ We measure the LIVE AceGUI, never a copy we loaded
        -- ourselves: the whole point is what the user's addon set resolved to.
        -- =============================================================
        local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
        payload.controls = {}
        payload.controlsMissing = {}
        local controlCount = 0

        if not decl.control then
            payload.controlSkipped = "the declaration carries no `control` section"
        elseif not AceGUI then
            -- ⚠ LOUD, not silent. DevDump embeds no Ace; it borrows whatever is
            -- loaded. If nothing is, that is a fact about the run, not a zero.
            payload.controlSkipped =
                "AceGUI-3.0 is not loaded - COA_DevDump embeds none and borrows the "
                .. "client's. Enable an addon that ships Ace3 (COA_DungeonRun does) and "
                .. "run again. Nothing was measured; a control row without a library is "
                .. "not a zero, it is an absence."
        else
            local C = decl.control
            local mult = C.widthMultiplier or 170
            local hostW = C.hostWidth or 400

            -- The container every measured widget is laid out inside, so `full`
            -- resolves against a KNOWN width rather than the screen.
            local group = AceGUI:Create("SimpleGroup")
            if group then
                group:SetLayout("Flow")
                group:SetWidth(hostW)
                group.frame:SetParent(sheet.host)
                group.frame:ClearAllPoints()
                group.frame:SetPoint("TOPLEFT", sheet.host, "TOPLEFT", 0, -280)
                group.frame:Show()
            end

            for _, wname in ipairs(C.widgets or {}) do
                local probe = AceGUI:Create(wname)
                if not probe then
                    payload.controlsMissing[#payload.controlsMissing + 1] = wname
                else
                    probe:Release()
                    for _, w in ipairs(C.widths or {}) do
                        local row = { widget = wname, how = w.how, asked = w.value }
                        local ok = pcall(function()
                            local c = AceGUI:Create(wname)
                            if c.SetLabel then c:SetLabel(wname) end
                            if c.SetText then c:SetText(wname) end
                            if group then group:AddChild(c) end

                            -- ★ AceConfigDialog's own branch, replicated - see
                            -- AceConfigDialog-3.0.lua:1218-1225. The `number` rows fall
                            -- through to the bare multiplier, which is the point.
                            if w.how == "absent" then
                                row.applied = "nothing"
                            elseif w.value == "full" then
                                c.width = "fill"; row.applied = "width=fill"
                            elseif w.value == "double" then
                                c:SetWidth(mult * 2); row.applied = mult * 2
                            elseif w.value == "half" then
                                c:SetWidth(mult / 2); row.applied = mult / 2
                            else
                                c:SetWidth(mult); row.applied = mult
                            end

                            if group then group:DoLayout() end
                            row.width = c.frame and c.frame:GetWidth() or nil
                            row.height = c.frame and c.frame:GetHeight() or nil
                            row.widthProp = c.width
                            controlCount = controlCount + 1
                        end)
                        -- ⚠⚠ RELEASE THROUGH THE CONTAINER, ALWAYS, AND NEVER THE CHILD
                        -- ITSELF. `c:Release()` while it was still parented put the widget
                        -- back in AceGUI's pool WITHOUT removing it from `group.children`;
                        -- the next Create handed the SAME object back, AddChild listed it
                        -- twice, and Flow then ran `frame:SetPoint("TOPLEFT",
                        -- children[i-1].frame, ...)` with i-1 pointing at the same frame -
                        -- "trying to anchor to itself", AceGUI-3.0.lua:767. ★ ReleaseChildren
                        -- releases AND clears the list, so the pool can never hand back a
                        -- widget the container still lists.
                        -- ⚠ Outside the pcall: an error must not leak a parented child into
                        -- the next iteration, which is how one bad widget would poison the
                        -- rest of the sheet.
                        if group then group:ReleaseChildren() end
                        if not ok then row.error = "could not create or measure" end
                        payload.controls[#payload.controls + 1] = row
                    end
                end
            end

            payload.containers = {}
            for _, cname in ipairs(C.containers or {}) do
                local ok = pcall(function()
                    local c = AceGUI:Create(cname)
                    if not c then
                        payload.controlsMissing[#payload.controlsMissing + 1] = cname
                        return
                    end
                    c:SetLayout("Flow")
                    c:SetWidth(hostW)
                    c.frame:SetParent(sheet.host)
                    c.frame:ClearAllPoints()
                    c.frame:SetPoint("TOPLEFT", sheet.host, "TOPLEFT", 0, -320)
                    c.frame:Show()
                    c:DoLayout()
                    payload.containers[cname] = {
                        askedWidth = hostW,
                        width = c.frame:GetWidth(),
                        height = c.frame:GetHeight(),
                        -- the usable content area every child's width resolves against
                        contentWidth = c.content and c.content:GetWidth() or nil,
                        contentHeight = c.content and c.content:GetHeight() or nil,
                    }
                    c:Release()
                end)
                if not ok then
                    payload.containers[cname] = { error = "could not create or measure" }
                end
            end

            if group then group:Release() end
            payload.controlInputs = { widthMultiplier = mult, hostWidth = hostW }
        end

        sheet.title:SetText("COA UI test sheet - declaration v" .. tostring(decl.version))
        sheet.config:SetText((payload.config.resolution or "?") .. "  at uiScale "
            .. string.format("%.4f", payload.config.uiParentEffectiveScale or 0)
            .. "   -   " .. measured .. " cells measured")

        D.Commit("sheet: " .. measured .. " text cell(s) over " .. (#fonts - missing)
            .. " font object(s)"
            .. (missing > 0 and (", " .. missing .. " unmeasurable") or "")
            .. " · " .. (payload.controlSkipped and ("controls SKIPPED - "
                .. payload.controlSkipped:sub(1, 48))
                or (controlCount .. " control cell(s), AceGUI "
                    .. tostring((payload.config.libs or {})["AceGUI-3.0"])))
            .. " · " .. tostring(payload.config.resolution)
            .. " uiScale " .. string.format("%.4f", payload.config.uiParentEffectiveScale or 0))
    end,
}
