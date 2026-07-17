-- COA_StatePlates_Enemy/Options.lua - attach + the minimal config page.
--
-- The core (COA_GuardianPlates) carries ALL enemy-plate machinery, INERT
-- until this addon attaches. Ported from the page that lived inside
-- EnemyPlates.lua pre-v3.7.0. Threat swatches reset to DEFAULT on
-- right-click (a threat state has no native fallback), unlike Friendly's
-- clear-to-native swatches - the semantic difference is deliberate.

local ADDON = ...

local panel = CreateFrame("Frame", "COAStatePlatesEnemyOptions", UIParent)
panel.name = "COA State Plates: Enemy"

local function API() return COAStatePlates and COAStatePlates.Enemy or nil end

panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, name)
    if name ~= ADDON then return end
    self:UnregisterEvent("ADDON_LOADED")

    local api = API()
    if not api then return end
    api.attached = true -- the declaration of interest: core comes online

    local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("COA State Plates \124cffff5533Enemy\124r")

    local sub = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(500)
    sub:SetJustifyH("LEFT")
    sub:SetText("Signal/behaviour only against hostile plates. Threat coloring below is its current sub-mode.")

    local enable = CreateFrame("CheckButton", "COAStatePlatesEnemyThreatEnable", self, "InterfaceOptionsCheckButtonTemplate")
    enable:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", -2, -16)
    _G[enable:GetName() .. "Text"]:SetText("Enable threat coloring")
    enable:SetScript("OnClick", function(btn)
        API().SetThreatMode(btn:GetChecked() and 1 or 0)
    end)

    local tanking = CreateFrame("CheckButton", "COAStatePlatesEnemyTanking", self, "InterfaceOptionsCheckButtonTemplate")
    tanking:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -4)
    _G[tanking:GetName() .. "Text"]:SetText("Tanking (unchecked = DPS view) - used only when the game has no LFG/LFR role")
    tanking:SetScript("OnClick", function(btn)
        API().SetTanking(btn:GetChecked() and true or false)
    end)

    -- Threat color rows: right-click resets to the state's DEFAULT (never nil).
    local function CreateThreatColorRow(anchorWidget, labelText, colorKey)
        local rowLabel = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        rowLabel:SetPoint("TOPLEFT", anchorWidget, "BOTTOMLEFT", 2, -20)
        rowLabel:SetText(labelText .. " (right-click swatch to reset to default):")

        local swatch = CreateFrame("Button", nil, self)
        swatch:SetPoint("TOPLEFT", rowLabel, "BOTTOMLEFT", 4, -6)
        swatch:SetWidth(24)
        swatch:SetHeight(24)
        swatch:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        local border = swatch:CreateTexture(nil, "BACKGROUND")
        border:SetAllPoints()
        border:SetTexture(0, 0, 0, 1)
        local fill = swatch:CreateTexture(nil, "ARTWORK")
        fill:SetPoint("TOPLEFT", 2, -2)
        fill:SetPoint("BOTTOMRIGHT", -2, 2)
        fill:SetTexture(1, 1, 1, 1)

        local function Default() return API().defaults[colorKey] end
        local function Refresh()
            local c = COA_GuardianPlatesDB[colorKey] or Default()
            fill:SetVertexColor(c.r, c.g, c.b)
        end
        local function SetColor(r, g, b)
            COA_GuardianPlatesDB[colorKey] = { r = r, g = g, b = b }
            Refresh(); API().Reapply()
        end
        local function ResetColor()
            local d = Default()
            SetColor(d.r, d.g, d.b)
        end

        swatch:SetScript("OnClick", function(_, mouseButton)
            if mouseButton == "RightButton" then ResetColor() return end
            if not ColorPickerFrame then return end
            local current = COA_GuardianPlatesDB[colorKey] or Default()
            ColorPickerFrame.func = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                SetColor(r, g, b)
            end
            ColorPickerFrame.cancelFunc = function(prev)
                if prev then SetColor(prev.r, prev.g, prev.b) else ResetColor() end
            end
            ColorPickerFrame.hasOpacity = false
            pcall(function()
                ColorPickerFrame:SetColorRGB(current.r, current.g, current.b)
                ShowUIPanel(ColorPickerFrame)
            end)
        end)
        return swatch, Refresh
    end

    local secureSwatch, RefreshSecure = CreateThreatColorRow(tanking, "Threat color - secure", "threatColorSecure")
    local warningSwatch, RefreshWarning = CreateThreatColorRow(secureSwatch, "Threat color - warning", "threatColorWarning")
    local dangerSwatch, RefreshDanger = CreateThreatColorRow(warningSwatch, "Threat color - danger", "threatColorDanger")

    local instFill = CreateFrame("CheckButton", "COAStatePlatesEnemyInstanceFill", self, "InterfaceOptionsCheckButtonTemplate")
    instFill:SetPoint("TOPLEFT", dangerSwatch, "BOTTOMLEFT", -6, -20)
    _G[instFill:GetName() .. "Text"]:SetText("Instance fill: also color the bar fill in dungeons/raids")
    instFill:SetScript("OnClick", function(btn)
        API().SetInstanceFill(btn:GetChecked() and true or false)
    end)

    self:SetScript("OnShow", function()
        enable:SetChecked(((COA_GuardianPlatesDB.threatMode or 0) > 0) and true or nil)
        tanking:SetChecked(COA_GuardianPlatesDB.threatTanking and true or nil)
        instFill:SetChecked(COA_GuardianPlatesDB.threatInstanceFillEnabled and true or nil)
        RefreshSecure(); RefreshWarning(); RefreshDanger()
    end)
    RefreshSecure(); RefreshWarning(); RefreshDanger()

    InterfaceOptions_AddCategory(self)
end)
