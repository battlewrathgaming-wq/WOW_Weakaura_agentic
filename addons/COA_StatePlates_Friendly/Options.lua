-- COA_StatePlates_Friendly/Options.lua - attach + the minimal config page.
--
-- The core (COA_GuardianPlates) carries ALL friendly-plate machinery,
-- INERT until this addon attaches. This file: sets the attach flag and
-- builds the Interface > AddOns page (ported verbatim-in-spirit from the
-- page that used to live inside FriendlyPlates.lua pre-v3.7.0). All writes
-- go through the public API (COAStatePlates.Friendly) or the shared
-- per-character DB (COA_GuardianPlatesDB - a global, core-owned).

local ADDON = ...

local panel = CreateFrame("Frame", "COAStatePlatesFriendlyOptions", UIParent)
panel.name = "COA State Plates: Friendly"

local function API() return COAStatePlates and COAStatePlates.Friendly or nil end

panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, name)
    if name ~= ADDON then return end
    self:UnregisterEvent("ADDON_LOADED")

    local api = API()
    if not api then return end
    api.attached = true -- the declaration of interest: core comes online

    local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("COA State Plates \124cff33ff99Friendly\124r")

    local sub = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(500)
    sub:SetJustifyH("LEFT")
    sub:SetText("Suppresses friendly PLAYER nameplates while leaving friendly guardian/pet/NPC nameplates visible. Healer mode below is its sub-mode.")

    local enable = CreateFrame("CheckButton", "COAStatePlatesFriendlyEnable", self, "InterfaceOptionsCheckButtonTemplate")
    enable:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", -2, -16)
    _G[enable:GetName() .. "Text"]:SetText("Enable suppression")
    enable:SetScript("OnClick", function(btn)
        API().SetEnabled(btn:GetChecked() and true or false)
    end)

    local healer = CreateFrame("CheckButton", "COAStatePlatesFriendlyHealerMode", self, "InterfaceOptionsCheckButtonTemplate")
    healer:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -4)
    _G[healer:GetName() .. "Text"]:SetText("Healer mode: reveal group/raid members on low HP")
    healer:SetScript("OnClick", function(btn)
        API().SetHealerMode(btn:GetChecked() and true or false)
    end)

    -- Color swatch rows (NPC / pet-guardian-totem) - un-set is meaningful
    -- (nil = native color), so right-click CLEARS to native.
    local function CreateColorRow(anchorWidget, labelText, colorKey)
        local rowLabel = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        rowLabel:SetPoint("TOPLEFT", anchorWidget, "BOTTOMLEFT", 2, -20)
        rowLabel:SetText(labelText .. " (right-click swatch to reset):")

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

        local function Refresh()
            local c = COA_GuardianPlatesDB[colorKey]
            if c then fill:SetVertexColor(c.r, c.g, c.b) else fill:SetVertexColor(1, 1, 1) end
        end
        local function SetColor(r, g, b)
            COA_GuardianPlatesDB[colorKey] = { r = r, g = g, b = b }
            Refresh(); API().ReapplyColors()
        end
        local function ClearColor()
            COA_GuardianPlatesDB[colorKey] = nil
            Refresh(); API().ReapplyColors()
        end

        swatch:SetScript("OnClick", function(_, mouseButton)
            if mouseButton == "RightButton" then ClearColor() return end
            if not ColorPickerFrame then return end
            local current = COA_GuardianPlatesDB[colorKey] or { r = 0.2, g = 0.5, b = 1.0 }
            ColorPickerFrame.func = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                SetColor(r, g, b)
            end
            ColorPickerFrame.cancelFunc = function(prev)
                if prev then SetColor(prev.r, prev.g, prev.b) else ClearColor() end
            end
            ColorPickerFrame.hasOpacity = false
            pcall(function()
                ColorPickerFrame:SetColorRGB(current.r, current.g, current.b)
                ShowUIPanel(ColorPickerFrame)
            end)
        end)
        return swatch, Refresh
    end

    local npcSwatch, RefreshNPC = CreateColorRow(healer, "NPC nameplate color", "npcColor")
    local petSwatch, RefreshPet = CreateColorRow(npcSwatch, "Pet / Guardian / Totem nameplate color", "petColor")

    self:SetScript("OnShow", function()
        enable:SetChecked(COA_GuardianPlatesDB.enabled and true or nil)
        healer:SetChecked(COA_GuardianPlatesDB.healerModeEnabled and true or nil)
        RefreshNPC(); RefreshPet()
    end)
    RefreshNPC(); RefreshPet()

    InterfaceOptions_AddCategory(self)
end)
