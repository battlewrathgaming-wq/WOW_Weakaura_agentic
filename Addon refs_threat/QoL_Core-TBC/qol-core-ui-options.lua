qualityoflife = qualityoflife or {};
local q = qualityoflife;

local margin = 10;
local headerYOffset = 40;
local labelYOffset = 23;
local checkboxYOffset = 30;
local dropdownYOffset = 30;
local editBoxYOffset = 30;
local sliderYOffset = 35;
local spacingYOffset = 10;
local buttonYOffset = 30;

local elementIndex, yOffset = {}, {};
local chShowTargetHealth, chShowCrf;

local TEXTCOLOR_GREY = {
    ["r"] = 149 / 255,
    ["g"] = 149 / 255,
    ["b"] = 149 / 255,
    ["a"] = 1
};

local function SaveChanges()

end

local function RevertChanges()
    QOL_OPTIONS[q.name] = q.optionsPanel.oldValues;
end

local function ShowOptionsPanel()
    q.optionsPanel.oldValues = q:Deepcopy(QOL_OPTIONS[q.name]);

    if not chShowTargetHealth then
        chShowTargetHealth = q:CreateOptionsCheckbox(q.optionsPanel, q:GetText("Show target health as numbers"),
            function(self)
                if q.initFinished then
                    QOL_OPTIONS[q.name][q.OPT_SHOWTARGETHEALTH] = self:GetChecked();
                end
            end);
    end
    chShowTargetHealth:SetChecked(QOL_OPTIONS[q.name][q.OPT_SHOWTARGETHEALTH]);

    -- if not chShowCrf then
    --	chShowCrf = q:CreateOptionsCheckbox(q.optionsPanel, q:GetText("Show Compact Raid Frames"), function(self)
    --		QOL_OPTIONS[q.name][q.OPT_SHOWCRF] = self:GetChecked();
    --		q:SetCrfVisible(QOL_OPTIONS[q.name][q.OPT_SHOWCRF]);
    --	end);
    -- end
    -- chShowCrf:SetChecked(QOL_OPTIONS[q.name][q.OPT_SHOWCRF]);
end

function q:InitOptions()
    q.OPT_SHOWCRF = "OPT_SHOWCRF";
    q.OPT_VISITED = "OPT_VISITED";

    q.OPT_SHOWTARGETHEALTH = "OPT_SHOWTARGETHEALTH";
    if not QOL_OPTIONS[q.name][q.OPT_SHOWTARGETHEALTH] then
        QOL_OPTIONS[q.name][q.OPT_SHOWTARGETHEALTH] = true;
    end

    if not q.optionsPanel then
        q.optionsPanel = CreateFrame("Frame", "QoLOptionsFrame_Core");
        q.optionsPanel.name = "Quality of Life";
        q.optionsPanel.okay = function(self)
            SaveChanges();
        end;
        q.optionsPanel.cancel = function(self)
            RevertChanges();
        end;
        InterfaceOptions_AddCategory(q.optionsPanel);
        q.optionsPanel:SetScript("OnShow", function()
            ShowOptionsPanel();
        end);
        q:HandleElvUi(q.optionsPanel);

        ShowOptionsPanel();
    end
    return true;
end

function q:CreateOptionsHeader(parent, text, yMargin)
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] or 0;
    yOffset[parent:GetName()] = yOffset[parent:GetName()] or -margin;
    yMargin = yMargin or 0;

    local element = CreateFrame("Frame",
        "QoLOptionElement_" .. parent:GetName() .. "_" .. elementIndex[parent:GetName()], parent);

    element:SetPoint("TOPLEFT", margin, yOffset[parent:GetName()] - yMargin);
    element:SetWidth(550);
    element:SetHeight(23);
    element.fontString = element:CreateFontString("QoLOptionElement_" .. parent:GetName() .. "_" ..
                                                      elementIndex[parent:GetName()] .. "_FontString", "ARTWORK",
        "GameFontNormalLarge");
    element.fontString:SetPoint("CENTER");
    element.fontString:SetText(text);

    yOffset[parent:GetName()] = yOffset[parent:GetName()] - headerYOffset - yMargin;
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] + 1;
    return element;
end

function q:CreateOptionsChildFrame(parent, frameMargin, width, height)
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] or 0;
    frameMargin = frameMargin or margin;
    width = width or (623 - frameMargin * 2);
    height = height or (568 + yOffset[parent:GetName()] - frameMargin);

    local element = CreateFrame("Frame",
        "QoLOptionElement_" .. parent:GetName() .. "_" .. elementIndex[parent:GetName()], parent);
    element.frameType = "Frame";
    element:SetPoint("TOPLEFT", frameMargin, yOffset[parent:GetName()]);
    element:SetWidth(width);
    element:SetHeight(height);
    q:HandleElvUi(element);

    yOffset[parent:GetName()] = yOffset[parent:GetName()] - height;
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] + 1;
    return element;
end

function q:CreateOptionsLabel(parent, text, xOffset, inLine)
    xOffset = xOffset or 0;
    yOffset[parent:GetName()] = yOffset[parent:GetName()] or -margin;
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] or 0;

    local element = CreateFrame("Frame",
        "QoLOptionElement_" .. parent:GetName() .. "_" .. elementIndex[parent:GetName()], parent);
    element.frameType = "Frame";
    element:SetPoint("TOPLEFT", margin, yOffset[parent:GetName()]);
    element:SetWidth(1);
    element:SetHeight(23);
    element.fontString = element:CreateFontString("QoLOptionElement_" .. parent:GetName() .. "_" ..
                                                      elementIndex[parent:GetName()] .. "_FontString", "ARTWORK",
        "GameFontNormal");
    element.fontString:SetPoint("LEFT", margin + xOffset, 0);
    element.fontString:SetText(text);
    q:HandleElvUi(element);

    element.SetText = function(self, text)
        self.fontString:SetText(text);
    end

    element.SetXOffset = function(self, xOffset)
        local point, relativeTo, relativePoint, xOfs, yOfs = self.fontString:GetPoint();
        self.fontString:SetPoint(point, xOffset, yOfs);
    end

    element.fontString.defaultColor = {element.fontString:GetTextColor()};
    element.SetDefaultTextColor = function (self)
        self.fontString:SetTextColor(unpack(self.fontString.defaultColor));
    end

    element.SetTextColor = function(self, r, g, b, a)
        self.fontString:SetTextColor(r, g, b, a);
    end

    if not inLine then
        yOffset[parent:GetName()] = yOffset[parent:GetName()] - labelYOffset;
    end
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] + 1;
    return element;
end

function q:CreateOptionsCheckbox(parent, text, func, xOffset, inLine)
    xOffset = xOffset or 0;
    yOffset[parent:GetName()] = yOffset[parent:GetName()] or -margin;
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] or 0;

    local element = CreateFrame("CheckButton",
        "QoLOptionElement_" .. parent:GetName() .. "_" .. elementIndex[parent:GetName()], parent,
        "ChatConfigCheckButtonTemplate");
    element.frameType = "CheckButton";
    element:SetPoint("TOPLEFT", margin + xOffset + 5, yOffset[parent:GetName()] - 2);
    element:SetScript("OnClick", func);
    element.fontString = element:CreateFontString("QoLOptionElement_" .. parent:GetName() .. "_" ..
                                                      elementIndex[parent:GetName()] .. "_FontString", "ARTWORK",
        "GameFontNormal");
    element.fontString:SetPoint("LEFT", 30, 0);
    element.fontString:SetText(text);
    q:HandleElvUi(element);

    element.SetText = function(self, text)
        self.fontString:SetText(text);
    end

    element.fontString.defaultColor = {element.fontString:GetTextColor()};
    element.SetDefaultTextColor = function (self)
        self.fontString:SetTextColor(unpack(self.fontString.defaultColor));
    end

    element.SetTextColor = function(self, r, g, b, a)
        self.fontString:SetTextColor(r, g, b, a);
    end

    if not inLine then
        yOffset[parent:GetName()] = yOffset[parent:GetName()] - checkboxYOffset;
    end
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] + 1;
    return element;
end

function q:CreateOptionsDropdown(parent, initFunc, xOffset, width, inLine)
    xOffset = xOffset or 0;
    width = width or 160;
    yOffset[parent:GetName()] = yOffset[parent:GetName()] or -margin;
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] or 0;

    local element = CreateFrame("Frame",
        "QoLOptionElement_" .. parent:GetName() .. "_" .. elementIndex[parent:GetName()], parent,
        "UIDropDownMenuTemplate");
    element.frameType = "DropDown";
    element.isDropdown = true;
    element:SetPoint("TOPLEFT", margin + xOffset - 10, yOffset[parent:GetName()]);
    UIDropDownMenu_SetWidth(element, width);
    UIDropDownMenu_Initialize(element, initFunc);
    q:HandleElvUi(element, function(self)
        self:ClearAllPoints();
        self:SetPoint("TOPLEFT", margin + xOffset - 11, yOffset[parent:GetName()]);
        UIDropDownMenu_SetWidth(self, width - 10);
    end);

    function element.SetText(self, text)
        UIDropDownMenu_SetText(self, text);
    end

    if not inLine then
        yOffset[parent:GetName()] = yOffset[parent:GetName()] - dropdownYOffset;
    end
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] + 1;
    return element;
end

function q:CreateOptionsSlider(parent, min, max, func, xOffset, inLine, width, valueStep, minText, maxText)
    xOffset = xOffset or 0;
    min = min or 0;
    max = max or 100;
    valueStep = valueStep or 1;
    minText = minText or min;
    maxText = maxText or max;
    width = width or 160;
    yOffset[parent:GetName()] = yOffset[parent:GetName()] or -margin;
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] or 0;

    local element = CreateFrame("Slider",
        "QoLOptionElement_" .. parent:GetName() .. "_" .. elementIndex[parent:GetName()], parent,
        "OptionsSliderTemplate");
    element.frameType = "Slider";
    element:SetPoint("TOPLEFT", margin + xOffset + 10, yOffset[parent:GetName()]);
    element:SetOrientation("HORIZONTAL");
    element:SetWidth(width);
    element:SetHeight(23);
    element:SetScript("OnValueChanged", func);
    element:SetMinMaxValues(min, max);
    element:SetValueStep(valueStep);
    element:SetObeyStepOnDrag(true);

    -- min text
    element.minText = getglobal(element:GetName() .. "Low");
    element.minText.defaultColor = q:GetColorHexFromRGBA( 1, 1, 1, 1 );
    element.minText.color = element.minText.defaultColor;

    element.SetMinText = function (self, text)
        self.minText.text = text;
        self.minText:SetText("|c" .. self.minText.color .. self.minText.text .. "|r");
    end
    element:SetMinText(minText);

    element.SetMinTextColor = function (self, r, g, b, a)
        self.minText.color = q:GetColorHexFromRGBA(r, g, b, a);
        self.minText:SetText("|c" .. self.minText.color .. self.minText.text .. "|r");
    end

    -- max text
    element.maxText = getglobal(element:GetName() .. "High");
    element.maxText.defaultColor = q:GetColorHexFromRGBA( 1, 1, 1, 1 );
    element.maxText.color = element.maxText.defaultColor;

    element.SetMaxText = function (self, text)
        self.maxText.text = text;
        self.maxText:SetText("|c" .. self.maxText.color .. self.maxText.text .. "|r");
    end
    element:SetMaxText(maxText);

    element.SetMaxTextColor = function (self, r, g, b, a)
        self.maxText.color = q:GetColorHexFromRGBA(r, g, b, a);
        self.maxText:SetText("|c" .. self.maxText.color .. self.maxText.text .. "|r");
    end

    -- convenience / compatibility
    element.defaultColor = element.minText.defaultColor;
    element.SetDefaultTextColor = function (self)
        self.minText:SetText("|c" .. self.defaultColor .. self.minText.text .. "|r");
        self.maxText:SetText("|c" .. self.defaultColor .. self.maxText.text .. "|r");
    end

    element.SetTextColor = function (self, r, g, b, a)
        self:SetMinTextColor(r, g, b, a);
        self:SetMaxTextColor(r, g, b, a);
    end

    q:HandleElvUi(element);

    if not inLine then
        yOffset[parent:GetName()] = yOffset[parent:GetName()] - sliderYOffset;
    end
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] + 1;
    return element;
end

function q:CreateOptionsButton(parent, text, func, xOffset)
    xOffset = xOffset or 0;
    yOffset[parent:GetName()] = yOffset[parent:GetName()] or -margin;
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] or 0;

    local element = CreateFrame("Button",
        "QoLOptionElement_" .. parent:GetName() .. "_" .. elementIndex[parent:GetName()], parent,
        "UIPanelButtonTemplate");
    element.frameType = "Button";
    element:SetPoint("TOPLEFT", 5 + margin + xOffset, -margin + yOffset[parent:GetName()] + 8);
    element:SetHeight(23);
    element:SetWidth(180);
    element:SetScript("OnClick", func);
    element.fontString = element:CreateFontString("QoLOptionElement_" .. parent:GetName() .. "_" ..
                                                      elementIndex[parent:GetName()] .. "_FontString", "ARTWORK",
        "GameFontNormal");
    element.fontString:SetPoint("CENTER");
    element.fontString:SetText(text);
    q:HandleElvUi(element);

    function element.SetText(self, text)
        self.fontString:SetText(text);
    end

    function element.SetTextColor(self, red, green, blue, alpha)
        self.fontString:SetTextColor(red, green, blue, alpha);
    end

    yOffset[parent:GetName()] = yOffset[parent:GetName()] - dropdownYOffset;
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] + 1;
    return element;
end

function q:CreateOptionsEditBox(parent, text, xOffset, inLine)
    xOffset = xOffset or 0;
    yOffset[parent:GetName()] = yOffset[parent:GetName()] or -margin;
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] or 0;

    local element = CreateFrame("EditBox",
        "QoLOptionElement_" .. parent:GetName() .. "_" .. elementIndex[parent:GetName()], parent, "InputBoxTemplate");
    element.frameType = "EditBox";
    element:SetPoint("TOPLEFT", 5 + margin + xOffset, -margin + yOffset[parent:GetName()] + 12);
    element:SetHeight(30);
    element:SetWidth(160);
    element:SetAutoFocus(false);
    q:HandleElvUi(element);

    if not inLine then
        yOffset[parent:GetName()] = yOffset[parent:GetName()] - editBoxYOffset;
    end
    elementIndex[parent:GetName()] = elementIndex[parent:GetName()] + 1;
    return element;
end

function q:CreateOptionsSpacing(parent, customYOffset)
    customYOffset = customYOffset or spacingYOffset;
    yOffset[parent:GetName()] = yOffset[parent:GetName()] or -margin;
    yOffset[parent:GetName()] = yOffset[parent:GetName()] - customYOffset;
    return {};
end

local sparkSources = {};
local function ShowFrameSparks(addon, frame)
    if sparkSources[addon.name] then
        q:HideSparkSource(sparkSources[addon.name]);
    end

    if not QOL_OPTIONS[addon.name][q.OPT_VISITED] then
        local path = q:GetFrameOutlinePath(frame, true);
        path[1]["sparks"] = 3;
        path[1]["lifetime"] = 1;
        path[1]["gravity"] = 0.5;
        path[1]["v"] = 60;
        path[3]["v"] = {
            [0] = 60,
            [0.5] = 200,
            [1] = 60
        };
        path[5]["v"] = {
            [0] = 60,
            [0.5] = 200,
            [1] = 60
        };
        -- sparkSources[addon.name] = q:ShowFrameSparkSource(path);
    end
end

local function GetOptionsFrameButton(name)
    local i = 1;
    while _G["InterfaceOptionsFrameAddOnsButton" .. i] do
        if _G["InterfaceOptionsFrameAddOnsButton" .. i]:GetText() == name then
            return _G["InterfaceOptionsFrameAddOnsButton" .. i];
        end
        i = i + 1;
    end
end

function q:HookOptionsSparks(addon)
    if not QOL_OPTIONS[addon.name][q.OPT_VISITED] then
        GameMenuFrame:HookScript("OnShow", function(self)
            ShowFrameSparks(addon, GameMenuButtonUIOptions);
        end);

        InterfaceOptionsFrame:HookScript("OnShow", function(self)
            ShowFrameSparks(addon, InterfaceOptionsFrameTab2);
        end);

        InterfaceOptionsFrameAddOns:HookScript("OnShow", function(self)
            local optionsFrameButton = GetOptionsFrameButton(q.optionsPanel.name);
            if optionsFrameButton then
                ShowFrameSparks(addon, optionsFrameButton);

                _G[optionsFrameButton:GetName() .. "Toggle"]:HookScript("OnClick", function(self)
                    local optionsFrameButton2 = GetOptionsFrameButton(addon.optionsPanel.name);
                    if optionsFrameButton2 then
                        ShowFrameSparks(addon, optionsFrameButton2);

                        optionsFrameButton2:HookScript("OnClick", function(self)
                            q:HideSparkSource(sparkSources[addon.name]);
                            QOL_OPTIONS[addon.name][q.OPT_VISITED] = true;
                            addon.optionsPanel.oldValues[q.OPT_VISITED] = true;
                        end);
                    end
                end);
            end
        end);
    end
end

function q:SetLabelEnabled(label, value)
    if not value then
        local r, g, b, a = label.fontString:GetTextColor();
        label.lastFontColor = {
            ["r"] = r,
            ["g"] = g,
            ["b"] = b,
            ["a"] = a
        };
        label:SetTextColor(q:GetColorRBGA(TEXTCOLOR_GREY));
    else
        label:SetTextColor(q:GetColorRBGA(label.lastFontColor));
    end
end
