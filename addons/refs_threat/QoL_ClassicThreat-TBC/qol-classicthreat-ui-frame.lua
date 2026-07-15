-- scope stuff
qualityoflife = qualityoflife or {};
local q = qualityoflife;

q.modules = q.modules or {};
q.modules["QoL_ClassicThreat-TBC"] = q.modules["QoL_ClassicThreat-TBC"] or {};
local c = q.modules["QoL_ClassicThreat-TBC"];

local barFrames = {};

local barFrameDefaultBottom, barFrameDefaultLeft = 500, 500;
local barFrameDefaultWidth, barFrameDefaultHeight = 200, 100;

local minWidth, minHeight = 100, 50;
local minLeft, maxLeft, minBottom, maxBottom = 0, 1517, 0, 855;

local barHeight, barMarginX, barMarginY = 13, 4, 2;

local DYNAMIC_UNIT_IDS = {"target"}; -- currently "boss mode"

function c:GetBarFrameMinWidth()
    return minWidth;
end

function c:GetBarFrameMinHeight()
    return minHeight;
end

local function ConvertColor(colorTable)
    local colors = {};
    if colorTable.r and colorTable.g and colorTable.b then
        -- named properties
        colors = colorTable;
    else
        -- simple array
        colors.r = colorTable[1];
        colors.g = colorTable[2];
        colors.b = colorTable[3];
        colors.a = colorTable[4];
    end
    return colors.r, colors.g, colors.b, colors.a;
end

local function IsDynamicUnitId(unitId)
    for _, dynamicUnitId in ipairs(DYNAMIC_UNIT_IDS) do
        if dynamicUnitId == unitId then
            return true;
        end
    end
end

local function GetNextUnitId(barFrame)
    local members, nextId = {unpack(DYNAMIC_UNIT_IDS), unpack(q:GetCurrentMemberNamesAlphabetically())};
    local isDynamicId = IsDynamicUnitId(barFrame:GetUnitId());

    for index, unitIdOrName in ipairs(members) do
        if (isDynamicId and unitIdOrName == barFrame:GetUnitId()) or
            (not isDynamicId and unitIdOrName == barFrame:GetUnitName()) then
            if table.getn(members) > index then
                nextId = members[index + 1];
            end
            break
        end
    end

    nextId = nextId or members[1];
    if IsDynamicUnitId(nextId) then
        return nextId;
    else
        return q:GetCurrentMembers()[nextId];
    end
end

local function GetUnitName(unitId, ignoreTarget)
    local unitName, raidTargetIndex = UnitName(unitId), GetRaidTargetIndex(unitId);

    if unitName then
        if UnitIsPlayer(unitId) then
            local unitRole = q:GetUnitRole(unitName);
            if unitRole == "MAINTANK" then
                unitName = "|TInterface\\GROUPFRAME\\UI-GROUP-MAINTANKICON:14:14:0:0|t " .. unitName;
            end
        elseif not ignoreTarget and UnitGUID("target") and UnitGUID("target") == UnitGUID(unitId) then
            unitName = "|TInterface\\LFGFrame\\LFGRole:14:14:0:0:64:16:16:32:0:16|t" .. unitName;
        end
        if raidTargetIndex then
            unitName = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. raidTargetIndex .. ":0|t " .. unitName;
        end
    end
    return unitName;
end

local function Header_OnClick(barFrame, button)
    if button == "LeftButton" then
        -- cycle team members
        barFrame:SetUnitId(GetNextUnitId(barFrame), true);
    elseif button == "RightButton" then
        -- context menu
        ToggleDropDownMenu(1, nil, barFrame.header.dropdown, barFrame.header, 3, -3);
    end
end

local function Data_OnScroll(barFrame, offset)
    if barFrame.slider:IsVisible() then
        local current, min, max = barFrame.slider:GetValue(), barFrame.slider:GetMinMaxValues();
        if offset < 0 and current < max then
            barFrame.slider:SetValue(current + max / 10);
        elseif (offset > 0) and (current > 1) then
            barFrame.slider:SetValue(current - max / 10);
        end
    end
end

function c:AddBarFrame(id)
    -- try show inactive/hidden if available
    for id, barFrame in pairs(barFrames) do
        if not barFrame:IsVisible() then
            barFrame:Show();
            return;
        end
    end

    -- try get existing inactive frame
    id = id or c:GetLatestUsedInactiveBarFrameId();

    -- create new frame
    local newFrame =
        CreateFrame("Frame", "ClassicThreat_" .. id, UIParent, BackdropTemplateMixin and "BackdropTemplate");
    newFrame.id = id;
    barFrames[id] = newFrame;

    newFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", barFrameDefaultLeft, barFrameDefaultBottom);
    newFrame:SetSize(barFrameDefaultWidth, barFrameDefaultHeight);
    newFrame:SetFrameLevel(3);
    q:SetMinResize(newFrame, minWidth, minHeight);
    newFrame.bars = {};
    newFrame.locked = false;
    newFrame.active = true;
    newFrame.clicks = 0;

    newFrame:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 10,
        edgeSize = 10,
        insets = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2
        }
    });
    newFrame:SetBackdropColor(0, 0, 0, 0.4);

    newFrame:SetClipsChildren(true);
    newFrame:SetClampedToScreen(true);
    newFrame:SetResizable(true);
    newFrame:SetMovable(true);
    newFrame:EnableMouse(true);
    newFrame:RegisterForDrag("LeftButton");
    newFrame:SetScript("OnDragStart", function(self)
        if not self:IsLocked() then
            self:StartMoving();
        end
    end);
    newFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing();
        c:SaveBarFrame(self);
    end);
    newFrame:SetUserPlaced(true);
    q:RegisterDoubleClick(newFrame, function()
        newFrame:SetLocked(not newFrame:IsLocked());
        c:SaveBarFrame(newFrame);
    end, "LeftButton");
    newFrame:HookScript("OnShow", function(self)
        self.active = true;
    end);

    newFrame.Move = function(self, targetLeft, targetBottom)
        self:ClearAllPoints();
        self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", targetLeft, targetBottom);
    end

    -- header
    newFrame.header = CreateFrame("Frame", newFrame:GetName() .. "_Header", newFrame,
        BackdropTemplateMixin and "BackdropTemplate");
    newFrame.header:SetPoint("TOPLEFT", 2, -2);
    newFrame.header:SetPoint("TOPRIGHT", -2, -2);
    newFrame.header:SetHeight(16);

    newFrame.header:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        tile = true,
        tileSize = 10
    });
    newFrame.header:SetBackdropColor(1, 1, 1, 0.4);

    newFrame.header:SetScript("OnMouseDown", function(self, button)
        Header_OnClick(newFrame, button);
    end);
    newFrame.header:SetScript('OnEnter', function(self)
        q:TransitionMove(self.text, 30, 0);
    end);
    newFrame.header:SetScript('OnLeave', function(self)
        q:TransitionMove(self.text, 17, 0);
    end);

    newFrame.header.icon = CreateFrame("Frame", newFrame.header:GetName() .. "_Icon", newFrame.header,
        BackdropTemplateMixin and "BackdropTemplate");
    newFrame.header.icon:SetSize(15, 15);
    newFrame.header.icon:SetPoint("TOPLEFT", 0, 0);

    newFrame.header.icon.backdrop = {
        bgFile = [[Interface\Buttons\WHITE8x8]],
        edgeFile = [[Interface\Buttons\WHITE8x8]],
        edgeSize = 1
    };

    newFrame.header.icon.texture = newFrame.header.icon:CreateTexture(newFrame.header.icon:GetName() .. "_Texture", "ARTWORK");
    newFrame.header.icon.texture:SetSize(15, 15);
    newFrame.header.icon.texture:SetPoint("TOPLEFT", 0.5, -0.5);
    -- newFrame.header.icon.texture:SetTexture(c:GetRaceIconName(self:GetUnitId()));

    newFrame.header.text = newFrame.header:CreateFontString(newFrame.header:GetName() .. "_Text", "ARTWORK",
        "GameFontNormalSmall");
    newFrame.header.text:SetTextColor(1, 1, 1, 1);
    newFrame.header.text:SetPoint("TOPLEFT", newFrame.header, 17, 0);
    newFrame.header.text:SetPoint("BOTTOMLEFT", newFrame.header, 17, 0);

    newFrame.header.text_hidden = newFrame.header:CreateFontString(newFrame.header:GetName() .. "_Text_Hidden",
        "ARTWORK", "GameFontNormalSmall");
    newFrame.header.text_hidden:SetTextColor(1, 1, 1, 1);
    newFrame.header.text_hidden:SetPoint("TOPLEFT", self.header, -100, 0);
    newFrame.header.text_hidden:SetPoint("BOTTOMLEFT", self.header, -100, 0);

    -- data (scroll parent)
    newFrame.data = CreateFrame("ScrollFrame", newFrame:GetName() .. "_Data", newFrame); -- , "FauxScrollFrameTemplate");
    newFrame.data:SetPoint("TOPLEFT", 0, -newFrame.header:GetHeight());
    newFrame.data:SetPoint("TOPRIGHT", 0, -newFrame.header:GetHeight());
    newFrame.data:SetHeight(1000);
    newFrame.data:SetScript("OnMouseWheel", function(self, offset)
        Data_OnScroll(newFrame, offset);
    end);

    -- data (scroll child)
    newFrame.data.scrollchild = CreateFrame("Frame", newFrame:GetName() .. "_Data_ScrollChild", newFrame.data);
    newFrame.data.scrollchild:SetPoint("TOPLEFT", newFrame.data);
    newFrame.data:SetScrollChild(newFrame.data.scrollchild);

    -- slider
    newFrame.slider = CreateFrame("Slider", newFrame:GetName() .. "_Slider", newFrame, "OptionsSliderTemplate");
    newFrame.slider:SetOrientation('VERTICAL');
    newFrame.slider:SetPoint("TOPRIGHT", -4, -19);
    newFrame.slider:SetPoint("BOTTOMRIGHT", -4, 3);
    newFrame.slider:SetWidth(10);
    newFrame.slider.Low = _G[newFrame.slider:GetName() .. 'Low'];
    newFrame.slider.Low:SetText("");
    newFrame.slider.Text = _G[newFrame.slider:GetName() .. 'Text'];
    newFrame.slider.Text:SetText("");
    newFrame.slider.High = _G[newFrame.slider:GetName() .. 'High'];
    newFrame.slider.High:SetText("");
    newFrame.slider:SetValueStep(2);
    newFrame.slider:SetScript("OnValueChanged", function(self, value)
        newFrame.data:SetVerticalScroll(value);
    end);
    newFrame.slider:SetScript("OnMouseWheel", function(self, offset)
        Data_OnScroll(newFrame, offset);
    end)

    newFrame.slider:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 4,
        edgeSize = 4,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    });
    newFrame.slider:SetBackdropColor(1, 1, 1, 0.3);

    newFrame.slider.thumbtexture = newFrame.slider:CreateTexture(newFrame.slider:GetName() .. "_Thumb_Texture", "ARTWORK");
    newFrame.slider.thumbtexture:SetPoint("TOPLEFT", 1, 4);
    newFrame.slider.thumbtexture:SetSize(8, 2);
    newFrame.slider.thumbtexture:SetTexture([[Interface\Buttons\WHITE8x8]]);
    newFrame.slider.thumbtexture:SetVertexColor(1, 1, 1, 0.6);
    newFrame.slider:SetThumbTexture(newFrame.slider.thumbtexture);

    -- close button
    newFrame.closeButton = CreateFrame("Button", newFrame:GetName() .. "_CloseButton", newFrame, "UIPanelCloseButton");
    newFrame.closeButton:SetSize(20, 20);
    newFrame.closeButton:SetPoint("TOPRIGHT");
    newFrame.closeButton:SetFrameLevel(100);
    newFrame.closeButton:SetScript("OnClick", function(self)
        newFrame:Hide();
        if not c:IsBarFrameAutoOpenCloseEnabled() or (IsInGroup() or IsInRaid()) then
            newFrame:SetActive(false);
            c:SaveBarFrame(newFrame);
        end
    end);

    -- resize button
    newFrame.resizeButton = CreateFrame("Button", newFrame:GetName() .. "_ResizeButton", newFrame);
    newFrame.resizeButton:SetSize(19, 15);
    newFrame.resizeButton:SetPoint("BOTTOMRIGHT");
    newFrame.resizeButton:SetScript("OnMouseDown", function(self)
        if not newFrame:IsLocked() then
            newFrame:StartSizing();
        end
    end);
    newFrame.resizeButton:SetScript("OnMouseUp", function(self)
        newFrame:StopMovingOrSizing();
        newFrame.data.scrollchild:SetSize(newFrame:GetWidth(), newFrame:GetHeight() - newFrame.header:GetHeight());
        newFrame:Update(c:GetThreatCache());
        c:SaveBarFrame(newFrame);
    end)
    newFrame.resizeButton:SetFrameLevel(newFrame.slider:GetFrameLevel() + 1);

    newFrame.resizeButton.text = newFrame.resizeButton:CreateFontString(newFrame.resizeButton:GetName() .. "_Text",
        "ARTWORK", "GameFontNormalSmall");
    newFrame.resizeButton.text:SetTextColor(1, 1, 1, 1);
    newFrame.resizeButton.text:SetPoint("TOPLEFT", 1, 0);
    newFrame.resizeButton.text:SetPoint("BOTTOMRIGHT", 1, 0);

    -- functions
    newFrame.GetId = function(self)
        return self.id;
    end

    newFrame.GetUnitId = function(self)
        return self.unitId;
    end

    newFrame.GetUnitName = function(self)
        return self.unitName;
    end

    newFrame.SetLocked = function(self, value)
        self.locked = value;
        if value then
            newFrame.resizeButton.text:SetText();
        else
            newFrame.resizeButton.text:SetText("...");
        end
    end

    newFrame.IsLocked = function(self)
        return self.locked;
    end

    newFrame.IsActive = function(self)
        return self.active;
    end

    newFrame.SetActive = function(self, value)
        self.active = value;
    end

    newFrame.Update = function(self, threatCache)
        -- set all bars as inactive (some will be set back to active in this process)
        for _, bar in ipairs(self.bars) do
            bar:SetPending(true);
            bar:SetTextLeft("");
        end

        local unitId = self:GetUnitId();
        local activeBars = {};
        local unitGuid = UnitGUID(unitId);

        if threatCache and unitGuid then
            local reaction = UnitReaction("player", unitId);
            if IsDynamicUnitId(unitId) and (not reaction or reaction <= 4) then
                for memberGuid, memberThreatInfo in pairs(threatCache) do
                    if memberGuid and memberThreatInfo then
                        local threatInfo = memberThreatInfo[unitGuid];
                        if threatInfo and threatInfo.threat > 0 then
                            -- get bar and set data
                            local bar = self:GetBar(threatInfo.testedUnitGuid);
                            bar:Update(threatInfo, GetUnitName(threatInfo.testedUnitId) or threatInfo.testedUnitName,
                                threatInfo.testedUnitGuid);

                            -- prepare bar sorting
                            activeBars[threatInfo.threat] = activeBars[threatInfo.threat] or {};
                            tinsert(activeBars[threatInfo.threat], bar);
                        end
                    end
                end
            elseif threatCache[unitGuid] then
                for targetUnitGuid, threatInfo in pairs(threatCache[unitGuid]) do
                    if threatInfo and threatInfo.threat > 0 then
                        -- get bar and set data
                        local bar = self:GetBar(targetUnitGuid);
                        bar:Update(threatInfo, GetUnitName(threatInfo.targetUnitId) or threatInfo.targetName,
                            threatInfo.targetUnitGuid);

                        -- prepare bar sorting
                        activeBars[threatInfo.threat] = activeBars[threatInfo.threat] or {};
                        tinsert(activeBars[threatInfo.threat], bar);
                    end
                end
            end
        else
            -- reset slider to 0 after combat
            self.slider:SetValue(0);
        end

        -- update scroll info
        self.data.scrollchild:SetSize(self:GetWidth(), self:GetHeight() - self.header:GetHeight());
        self.data:SetVerticalScroll(self.slider:GetValue());

        -- precalculate values
        local i, sortedBarKeys = 0, q:GetSortedTableKeys(activeBars, true);
        local noBars = table.getn(sortedBarKeys);
        local deltaH = noBars * (barHeight + barMarginY) - self.data.scrollchild:GetHeight();
        local isSliderVisible = deltaH >= 0;
        local sliderWidth = 0;
        if isSliderVisible then
            sliderWidth = self.slider:GetWidth() + 2;
        end
        local maxBarWidth = self.data:GetWidth() - 2 * barMarginX - sliderWidth;

        -- sort and align bars
        for _, key in ipairs(sortedBarKeys) do
            for _, bar in ipairs(activeBars[key]) do
                local top = 2 * barMarginY + i * (barHeight + barMarginY);
                local width = bar:GetThreatInfo().threat * maxBarWidth / 100;
                if width > maxBarWidth then
                    width = maxBarWidth;
                end

                if c:IsBarFrameAnimationsEnabled() then
                    q:TransitionResize(bar, width, barHeight, 10);
                    q:TransitionMove(bar, barMarginX, -top, 30);
                else
                    bar:Move(top, width);
                end

                i = i + 1;
            end
        end

        -- reset/hide inactive bars
        for _, bar in ipairs(self.bars) do
            if bar:IsPending() then
                -- print("reset:", bar:GetThreatInfo().targetName);
                bar:Reset();
            end
        end

        -- update slider
        if isSliderVisible then
            if self.slider:GetValue() > deltaH then
                self.slider:SetValue(deltaH);
            end
            self.slider:SetMinMaxValues(0, deltaH);
            self.slider:Show();
            self.slider.thumbtexture:Show();
            self.slider:SetValue(self.slider:GetValue());
        else
            self.slider:Hide();
        end
    end

    newFrame.SetUnitId = function(self, unitId, isMouseOver)
        if not unitId or (unitId ~= "target" and not UnitExists(unitId)) then
            unitId = "player";
        end

        -- old name transition
        self.header.text_hidden:Show();
        self.header.text_hidden:ClearAllPoints();
        self.header.text_hidden:SetPoint("TOPLEFT", self.header, 30, 0);
        self.header.text_hidden:SetPoint("BOTTOMLEFT", self.header, 30, 0);
        self.header.text_hidden:SetText(self.header.text:GetText());
        q:TransitionMove(self.header.text_hidden, self:GetWidth() + 50, 0, 10, function()
            self.header.text_hidden:Hide();
        end);

        -- new name transition
        self.header.text:ClearAllPoints();
        self.header.text:SetPoint("TOPLEFT", self.header, -100, 0);
        self.header.text:SetPoint("BOTTOMLEFT", self.header, -100, 0);
        if isMouseOver then
            q:TransitionMove(self.header.text, 30, 0, 10);
        else
            q:TransitionMove(self.header.text, 20, 0, 10);
        end

        -- new data
        self.unitId = unitId;
        self.unitName = GetUnitName(unitId, true) or q:GetText("Target");
        self.header.text:SetText(self.unitName);

        -- header background color
        if unitId == "target" then
            if UnitExists("target") then
                local r, g, b = UnitSelectionColor("target");
                self.header:SetBackdropColor(r, g, b, 0.4);
            else
                self.header:SetBackdropColor(1, 1, 1, 0.4);
            end
        else
            local r, g, b, a = q:GetClassColorRGB(unitId);
            self.header:SetBackdropColor(r, g, b, 0.4);
        end

        -- slider thumb color
        -- self.slider.thumbtexture:SetVertexColor(self.header:GetBackdropColor());

        -- update icon
        local iconTexture = c:GetRaceIconName(self:GetUnitId());
        if iconTexture then
            self.header.icon.texture:SetTexture(iconTexture);
            self.header.icon:Show();
        else
            self.header.icon:Hide();
        end

        -- save new state
        c:SaveBarFrame(self);

        -- update/reset bars
        self:Update();
    end
    newFrame:SetUnitId("player");

    newFrame.GetBar = function(self, guid)
        -- get existing, active by guid
        for _, bar in ipairs(self.bars) do
            if bar:GetGuid() == guid then
                return bar;
            end
        end

        -- if failed: get inactive
        for _, bar in ipairs(self.bars) do
            if not bar:IsActive() then
                return bar;
            end
        end

        -- create new bar if needed
        local index = table.getn(self.bars);
        local bar = CreateFrame("Frame", newFrame:GetName() .. "_Bar" .. index, newFrame.data.scrollchild,
            BackdropTemplateMixin and "BackdropTemplate");
        bar.frame = newFrame;
        bar:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface\Buttons\WHITE8x8]],
            edgeSize = 0.5
        });
        bar:SetScript("OnMouseWheel", function(self, offset)
            Data_OnScroll(newFrame, offset);
        end);
        bar:SetPoint("TOPLEFT", barMarginX, barMarginY);
        bar:SetHeight(barHeight);

        bar.textleft = bar:CreateFontString(bar:GetName() .. "_FontString", "ARTWORK", "GameFontNormalSmall");
        bar.textleft:SetTextColor(1, 1, 1, 1);
        bar.textleft:SetPoint("TOPLEFT", bar, 4, 0);
        bar.textleft:SetPoint("BOTTOMLEFT", bar, 4, 0);

        bar.textright = bar:CreateFontString(bar:GetName() .. "_FontString_Right", "ARTWORK", "GameFontNormalSmall");
        bar.textright:SetTextColor(1, 1, 1, 1);
        bar.textright:SetPoint("TOPRIGHT", bar, -4, 0);
        bar.textright:SetPoint("BOTTOMRIGHT", bar, -4, 0);

        bar.GetFrame = function(self)
            return self.frame;
        end

        bar.SetThreatInfo = function(self, threatInfo)
            self.threatInfo = threatInfo;
        end

        bar.GetThreatInfo = function(self)
            return self.threatInfo;
        end

        bar.SetGuid = function(self, guid)
            self.guid = guid;
        end

        bar.GetGuid = function(self)
            return self.guid;
        end

        bar.SetColor = function(self, colorTable)
            self:SetBackdropColor(ConvertColor(colorTable));
        end

        bar.SetBorderColor = function(self, colorTable)
            self:SetBackdropBorderColor(ConvertColor(colorTable));
        end

        bar.GetTextLeft = function(self)
            return self.textleft:GetText();
        end

        bar.SetTextLeftColor = function(self, r, g, b, a)
            self.textleft:SetTextColor(r, g, b, a);
        end

        bar.SetTextLeft = function(self, text)
            self.textleft:SetText(text);
        end

        bar.GetTextRight = function(self)
            return self.textright:GetText();
        end

        bar.SetTextRightColor = function(self, r, g, b, a)
            self.textright:SetTextColor(r, g, b, a);
        end

        bar.SetTextRight = function(self, text)
            self.textright:SetText(text);
        end

        bar.SetActive = function(self, value)
            self.active = value;
        end

        bar.IsActive = function(self)
            return self.active;
        end

        bar.SetPending = function(self, value)
            self.isPending = value;
        end

        bar.IsPending = function(self)
            return self.isPending;
        end

        bar.Move = function(self, targetTop, targetWidth)
            self:ClearAllPoints();
            self:SetPoint("TOPLEFT", barMarginX, -targetTop);
            self:SetSize(targetWidth, barHeight);
        end

        bar.Update = function(self, threatInfo, text, guid)
            self:SetActive(true);
            self:SetPending(false);

            if IsDynamicUnitId(self:GetFrame():GetUnitId()) and not UnitIsFriend("player", self:GetFrame():GetUnitId()) then
                -- target mode -> shows players
                self:SetTextLeft(q:FormatTextWithColor(text, q:GetClassColorHex(threatInfo.testedUnitId)));
            else
                -- fixed player mode -> shows npcs
                self:SetTextLeft(text);
            end

            if threatInfo.customStatus then
                -- self:SetTextLeft(threatInfo.customStatus .. " - " .. q:FormatTextWithColor(text, q:GetClassColorHex(threatInfo.testedUnitId)));
                self:SetTextRight(threatInfo.customStatus);
            else
                -- self:SetTextLeft(q:MathRound(threatInfo.threat, 0) .. "% - " .. q:FormatTextWithColor(text, q:GetClassColorHex(threatInfo.testedUnitId)));
                self:SetTextRight(q:MathRound(threatInfo.threat, 0) .. "%");
            end

            local textAlpha = threatInfo.threat / 100;
            if textAlpha < 0.5 then
                textAlpha = 0;
            end
            self:SetTextRightColor(1, 1, 1, textAlpha);

            self:SetThreatInfo(threatInfo);
            self:SetGuid(guid);

            self.textleft:SetTextColor(1, 1, 1, 1);
            if threatInfo.status > 0 then
                self:SetColor(c:GetThreatStatusColors(threatInfo.status, 0.4));
            elseif guid and guid == UnitGUID("player") then
                self:SetColor({
                    r = 1,
                    g = 1,
                    b = 1,
                    a = 0.3
                });
            else
                self:SetColor({
                    r = 0,
                    g = 0,
                    b = 0,
                    a = 0
                });
            end
            self:SetBorderColor(c:GetThreatStatusColors(0));

            if not self:IsVisible() then
                self:Show();
            end
        end

        bar.Reset = function(self)
            self:SetPending(false);
            self:SetActive(false);
            self:SetTextLeft("");
            self:SetTextRight("");
            self:SetColor({
                r = 1,
                g = 1,
                b = 1,
                a = 0
            });
            self:SetBorderColor({
                r = 1,
                g = 1,
                b = 1,
                a = 0
            });
            self:SetThreatInfo(nil);
            self:SetGuid(nil);
            self:SetSize(0, 0);
            self:Move(0, 0);
            self:Hide();
        end

        tinsert(self.bars, bar);
        bar:SetGuid(guid);
        return bar;
    end

    -- header context menu
    newFrame.header.dropdown = CreateFrame("Frame", newFrame.header:GetName() .. "_Dropdown", newFrame.header,
        "UIDropDownMenuTemplate");

    UIDropDownMenu_Initialize(newFrame.header.dropdown, function(self, level, menuList)
        if (level or 1) == 1 then
            -- boss mode
            local info = UIDropDownMenu_CreateInfo();
            info.isTitle = true;
            info.notCheckable = true;
            info.text = q:GetText("Dynamic");
            UIDropDownMenu_AddButton(info);

            -- target
            info = UIDropDownMenu_CreateInfo();
            info.func = function(self)
                newFrame:SetUnitId(self.value);
                c:SaveBarFrame(newFrame);
                CloseDropDownMenus();
            end;
            info.text = "|cffffffff" .. q:GetText("Target");
            info.value = "target";
            info.checked = (info.value == newFrame:GetUnitId());
            UIDropDownMenu_AddButton(info);

            -- member mode
            info = UIDropDownMenu_CreateInfo();
            info.isTitle = true;
            info.notCheckable = true;
            info.text = q:GetText("Static");
            UIDropDownMenu_AddButton(info);

            for _, unitName in ipairs(q:GetCurrentMemberNamesAlphabetically()) do
                info = UIDropDownMenu_CreateInfo();
                info.func = function(self)
                    if self.value ~= newFrame:GetUnitId() then
                        newFrame:SetUnitId(self.value);
                        c:SaveBarFrame(newFrame);
                    end
                    CloseDropDownMenus();
                end;

                local unitRole, text = q:GetUnitRole(unitName), "|cffffffff" .. unitName;
                if unitName then
                    if unitRole == "MAINTANK" then
                        text = "|TInterface\\GROUPFRAME\\UI-GROUP-MAINTANKICON:14:14:0:0|t " .. text;
                    end
                end

                info.text = text;
                info.value = q:GetCurrentMembers()[unitName];
                info.checked = (info.value == newFrame:GetUnitId());
                UIDropDownMenu_AddButton(info);
            end
        end
    end, "MENU");

    -- additional
    q:HandleElvUi(newFrame, function()
    end);

    -- restore last state from closed frames if available
    c:TryRestoreInactiveBarFrame(newFrame);
    if not newFrame:IsLocked() then
        newFrame.resizeButton.text:SetText("...");
    end
    newFrame:Show();

    -- save frame and return
    c:SaveBarFrame(newFrame);

    return newFrame;
end

function c:UpdateBarFrames(threatCache, unitId)
    for id, barFrame in pairs(barFrames) do
        if barFrame:IsVisible() and (unitId == nil or barFrame:GetUnitId() == unitId) then
            barFrame:Update(threatCache);
        end
    end
end

function c:UpdateBarFrameTargets()
    for id, barFrame in pairs(barFrames) do
        if barFrame:IsVisible() then
            if IsDynamicUnitId(barFrame:GetUnitId()) then
                barFrame:SetUnitId(barFrame:GetUnitId()); -- triggers update
            else
                local unitId = q:GetCurrentMembers()[barFrame:GetUnitName()]; -- or "player";
                if unitId and unitId ~= barFrame:GetUnitId() then
                    barFrame:SetUnitId(unitId); -- triggers update
                end
            end
        end
    end
end

function c:ToggleActiveFrames(value)
    for id, barFrame in pairs(barFrames) do
        if barFrame:IsActive() then
            if value and not barFrame:IsVisible() then
                barFrame:Show();
            elseif not value and barFrame:IsVisible() then
                barFrame:Hide();
            end
        end
    end
end
