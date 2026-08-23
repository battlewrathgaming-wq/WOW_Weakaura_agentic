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
        payload.config = {
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

        sheet.title:SetText("COA UI test sheet - declaration v" .. tostring(decl.version))
        sheet.config:SetText((payload.config.resolution or "?") .. "  at uiScale "
            .. string.format("%.4f", payload.config.uiParentEffectiveScale or 0)
            .. "   -   " .. measured .. " cells measured")

        D.Commit("sheet: " .. measured .. " cell(s) over " .. (#fonts - missing) .. " font object(s)"
            .. (missing > 0 and (", " .. missing .. " unmeasurable") or "")
            .. " at " .. tostring(payload.config.resolution)
            .. " uiScale " .. string.format("%.4f", payload.config.uiParentEffectiveScale or 0))
    end,
}
