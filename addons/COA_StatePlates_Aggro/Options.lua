-- COA_StatePlates_Aggro/Options.lua - the minimal native config page.
--
-- This addon owns NO machinery: the core (COA_GuardianPlates, a hard
-- dependency) carries the whole steering executor, baseline-off. Loading
-- this addon = declaring interest in the aggro surface; this file only
-- builds the Interface > AddOns options page and flips the core's switches
-- through the curated public API (COAStatePlates.Aggro). Immediate-apply:
-- clicking a box takes effect on the spot (no Okay/Apply dance).

local ADDON = ...

local panel = CreateFrame("Frame", "COAStatePlatesAggroOptions", UIParent)
panel.name = "COA State Plates: Aggro"

local function API()
    return COAStatePlates and COAStatePlates.Aggro or nil
end

panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, name)
    if name ~= ADDON then return end
    self:UnregisterEvent("ADDON_LOADED")

    local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("COA State Plates \124cff33ff99Aggro\124r")

    local sub = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(360)
    sub:SetJustifyH("LEFT")
    sub:SetText("Steers the client's OWN nameplate threat visuals (no drawing, no hooks)." ..
        "\nBorders are shown by the game only while you are in a group (native gate)." ..
        "\nTank palette: green = holding aggro, red = losing it. DPS: red = you pulled.")

    local enable = CreateFrame("CheckButton", "COAStatePlatesAggroEnable", self, "InterfaceOptionsCheckButtonTemplate")
    enable:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", -2, -12)
    _G[enable:GetName() .. "Text"]:SetText("Enable native threat borders")
    enable:SetScript("OnClick", function(btn)
        local api = API(); if not api then return end
        api.SetEnabled(btn:GetChecked() and true or false)
    end)

    local hideHl = CreateFrame("CheckButton", "COAStatePlatesAggroHideHl", self, "InterfaceOptionsCheckButtonTemplate")
    hideHl:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -6)
    _G[hideHl:GetName() .. "Text"]:SetText("Hide the game's red aggro highlight (the borders replace it)")
    hideHl:SetScript("OnClick", function(btn)
        local api = API(); if not api then return end
        api.SetHideNativeHighlight(btn:GetChecked() and true or false)
    end)

    local note = self:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    note:SetPoint("TOPLEFT", hideHl, "BOTTOMLEFT", 2, -12)
    note:SetWidth(360)
    note:SetJustifyH("LEFT")
    note:SetText("Shortcut: /coasp aggro on|off|status|hl on|off. Disabling this addon at the" ..
        "\ncharacter select returns the core to baseline (everything off).")

    -- reflect the saved per-character state whenever the panel shows
    self:SetScript("OnShow", function()
        local api = API(); if not api then return end
        local cfg = api.GetConfig()
        enable:SetChecked(cfg.enabled and true or nil)
        hideHl:SetChecked(cfg.hideNativeHighlight and true or nil)
    end)

    InterfaceOptions_AddCategory(self)
end)
