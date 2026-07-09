-- =========================================================================
-- OptionsUi.lua - Usine à composants d'interface (Version Native Stable)
-- =========================================================================
local addonName, addonTable = ...
addonTable.UI = {}
local UI = addonTable.UI

local sliderCount = 1

function UI.CreateMainPanel(name, titleText, versionText, width, height)
    -- Utilisation de "BasicFrameTemplate" : fond marbre garanti, opaque et sans cadre intérieur vide
    local frame = CreateFrame("Frame", name, UIParent, "BasicFrameTemplate")
    frame:SetSize(width, height)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- On efface proprement le titre par défaut du template de Blizzard
    if frame.TitleText then frame.TitleText:SetText("") end
    
    -- On place ton titre proprement au CENTRE de la barre de titre native (TitleBg)
    frame.header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.header:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 1)
    frame.header:SetText("|cffFFD100" .. titleText .. "|r")
    
    -- Version calée harmonieusement juste en dessous de la barre marbrée
    if versionText then
        frame.version = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        frame.version:SetPoint("TOP", frame.TitleBg, "BOTTOM", 0, -6)
        frame.version:SetText("|cffAAAAAA" .. versionText .. "|r")
    end
    
    frame:Hide()
    return frame
end

function UI.CreateTabSystem(parent, tabsConfig)
    local tabButtons = {}
    local tabWidth = 110
    local spacing = 15
    local totalWidth = (#tabsConfig * tabWidth) + ((#tabsConfig - 1) * spacing)
    local startX = (parent:GetWidth() - totalWidth) / 2

    for i, tabData in ipairs(tabsConfig) do
        local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        btn:SetSize(tabWidth, 25)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", startX + ((i-1) * (tabWidth + spacing)), -45)
        btn:SetText(tabData.name)
        
        btn:SetScript("OnClick", function()
            for j, t in ipairs(tabsConfig) do 
                t.frame:Hide()
                tabButtons[j]:UnlockHighlight()
            end
            tabData.frame:Show()
            btn:LockHighlight()
        end)
        
        tabButtons[i] = btn
        if i == 1 then 
            tabData.frame:Show()
            btn:LockHighlight()
        else 
            tabData.frame:Hide() 
        end
    end
end

function UI.CreatePage(parent)
    local page = CreateFrame("Frame", nil, parent)
    page:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -80)
    page:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 10)
    return page
end

-- AMÉLIORATION : Groupes style "Verre Fumé" intégrés au marbre Blizzard
function UI.CreateGroup(parent, titleText, width, height, x, y)
    local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    box:SetPoint("TOPLEFT", x, y)
    box:SetSize(width, height)
    
    -- Utilisation des textures natives de l'interface WoW pour s'adapter au marbre
    box:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground", -- Fond uni lisse
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",       -- Fine bordure ciselée
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    
    -- Teinte sombre semi-transparente (0.35) : isole les options sans masquer le marbre arrière
    box:SetBackdropColor(0, 0, 0, 0.35)
    box:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.6) -- Bordure grise douce
    
    box.title = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    box.title:SetPoint("TOPLEFT", 12, -10)
    box.title:SetText("|cFFFFD700" .. titleText .. "|r")

    return box
end

function UI.CreateCheckbox(parent, labelText, x, y, isChecked, onClickCallback, tooltipText)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", x, y)
    
    local cbText = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    cbText:SetPoint("LEFT", cb, "RIGHT", 4, 1)
    cbText:SetText(labelText)
    
    cb:SetChecked(isChecked)
    cb:SetScript("OnClick", function(self)
        if onClickCallback then onClickCallback(self:GetChecked()) end
    end)

    if tooltipText then
        cb:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        cb:HookScript("OnLeave", function() GameTooltip:Hide() end)
    end

    return cb
end

function UI.CreateSlider(parent, labelText, x, y, minVal, maxVal, currentVal, onValueChanged, tooltipText)
    local sliderName = addonName .. "SliderGen" .. sliderCount
    sliderCount = sliderCount + 1

    local slider = CreateFrame("Slider", sliderName, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetWidth(120)
    slider:SetHeight(16)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(currentVal)
    
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetColorTexture(0, 0, 0, 0.8)
    track:SetHeight(8)
    track:SetPoint("LEFT", slider, "LEFT", 0, 0)
    track:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
    
    local border = CreateFrame("Frame", nil, slider, "BackdropTemplate")
    border:SetPoint("TOPLEFT", track, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", track, "BOTTOMRIGHT", 1, -1)
    border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
    border:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)

    if _G[sliderName .. "Low"] then _G[sliderName .. "Low"]:SetText("") end
    if _G[sliderName .. "High"] then _G[sliderName .. "High"]:SetText("") end
    
    local separator = labelText:find(":") and " " or " : "
    
    local valText = _G[sliderName .. "Text"]
    if valText then
        valText:SetPoint("BOTTOM", slider, "TOP", 0, 3)
        valText:SetText(labelText .. separator .. "|cFFFFD700" .. currentVal .. "|r")
    end
    
    slider:SetScript("OnValueChanged", function(self, value)
        local v = math.floor(value + 0.5)
        if valText then valText:SetText(labelText .. separator .. "|cFFFFD700" .. v .. "|r") end
        if onValueChanged then onValueChanged(v) end
    end)

    if tooltipText then
        slider:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        slider:HookScript("OnLeave", function() GameTooltip:Hide() end)
    end

    return slider
end

function UI.CreateButton(parent, text, width, height, x, y, onClick, tooltipText)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(width, height)
    btn:SetPoint("TOPLEFT", x, y)
    btn:SetText(text)
    btn:SetScript("OnClick", onClick)

    if tooltipText then
        btn:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        btn:HookScript("OnLeave", function() GameTooltip:Hide() end)
    end

    return btn
end

-- Dropdown simple : labelText au dessus, liste d'items {text, value}, callback(value)
local dropdownCount = 0
function UI.CreateDropdown(parent, labelText, x, y, items, currentValue, onSelect, tooltipText)
    dropdownCount = dropdownCount + 1
    local ddName = addonName .. "Dropdown" .. dropdownCount

    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", x, y)
    label:SetText(labelText)

    local dd = CreateFrame("Frame", ddName, parent, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", x - 15, y - 18)

    UIDropDownMenu_SetWidth(dd, 110)

    local function InitDropdown(self, level)
        for _, item in ipairs(items) do
            local info = UIDropDownMenu_CreateInfo()
            info.text     = item.text
            info.value    = item.value
            info.checked  = (item.value == UIDropDownMenu_GetSelectedValue(self))
            info.func     = function(btn)
                UIDropDownMenu_SetSelectedValue(self, btn.value)
                UIDropDownMenu_SetText(self, btn:GetText())
                if onSelect then onSelect(btn.value) end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(dd, InitDropdown)

    -- Sélectionner la valeur courante
    for _, item in ipairs(items) do
        if item.value == currentValue then
            UIDropDownMenu_SetSelectedValue(dd, item.value)
            UIDropDownMenu_SetText(dd, item.text)
            break
        end
    end

    -- Exposer une méthode pour rafraîchir la sélection depuis l'extérieur
    dd.Refresh = function(newValue)
        for _, item in ipairs(items) do
            if item.value == newValue then
                UIDropDownMenu_SetSelectedValue(dd, item.value)
                UIDropDownMenu_SetText(dd, item.text)
                break
            end
        end
    end

    if tooltipText then
        local ddButton = _G[ddName .. "Button"]
        if ddButton then
            ddButton:HookScript("OnEnter", function(self)
                GameTooltip:SetOwner(dd, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            ddButton:HookScript("OnLeave", function() GameTooltip:Hide() end)
        end
    end

    return dd
end