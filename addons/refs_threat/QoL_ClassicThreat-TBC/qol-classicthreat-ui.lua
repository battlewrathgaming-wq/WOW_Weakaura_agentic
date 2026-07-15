-- scope stuff
qualityoflife = qualityoflife or {};
local q = qualityoflife;

q.modules = q.modules or {};
q.modules["QoL_ClassicThreat-TBC"] = q.modules["QoL_ClassicThreat-TBC"] or {};
local c = q.modules["QoL_ClassicThreat-TBC"];

local frames = {}; -- threatframes by parentframename

function c:GetPartyThreatFrame(partyId)
    local parentFrameName = "PartyMemberFrame" .. partyId;
    local frame = frames[parentFrameName];

    if not frame then
        frame = CreateFrame("Frame", "PartyThreatFrame_" .. partyId, _G[parentFrameName],
            BackdropTemplateMixin and "BackdropTemplate");
        frames[parentFrameName] = frame;

        frame:SetPoint("TOPLEFT", _G[parentFrameName], "TOPRIGHT", -14, -10);
        frame:SetSize(42, 21);

        frame.background = frame:CreateTexture(nil, "BACKGROUND");
        frame.background:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
        frame.background:SetPoint("TOPLEFT", 2, -2);
        frame.background:SetPoint("BOTTOMRIGHT", -2, 2);

        frame.text = frame:CreateFontString("PartyThreatFrame_" .. partyId .. "FontString", "ARTWORK",
            "GameFontNormalSmall");
        frame.text:SetTextColor(1, 1, 1, 1);
        frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, 0);
        frame.text:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0);

        -- frame.targetButton = CreateFrame("Button", "PartyThreatFrame_" .. partyId .. "TargetButton", frame, "SecureActionButtonTemplate");
        -- frame.targetButton:SetAttribute("type", "target");
        -- frame.targetButton:SetAllPoints();

        frame:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 10,
            edgeSize = 10,
            insets = {
                left = 4,
                right = 4,
                top = 4,
                bottom = 4
            }
        });

        frame.GetTextField = function()
            return frame.text;
        end

        frame.GetBackground = function()
            return frame.background;
        end

        q:HandleElvUi(frame, function()
        end);
    end
    return frame;
end

function c:GetCompactRaidThreatFrame(playerPartyId, unitId)
    if unitId and UnitExists(unitId) then
        local frameInfo = q:GetRaidFrameInfo();

        if frameInfo then
            local targetName = UnitName(unitId);

            if q:GetRaidFrameInfo()[targetName] then
                local parentFrame = q:GetRaidFrameInfo()[targetName][q:GetRaidFrameHeight_Full()];

                if parentFrame then
                    local parentFrameName = parentFrame:GetName();
                    local frame = frames[parentFrameName];

                    if not frame then
                        frame = CreateFrame("Frame", "CompactRaidThreatFrame_" .. playerPartyId, parentFrame,
                            BackdropTemplateMixin and "BackdropTemplate");
                        frames[parentFrameName] = frame;

                        frame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, 0);
                        frame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", 0, 0);

                        frame.background = frame:CreateTexture(nil, "BACKGROUND");
                        frame.background:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
                        frame.background:SetPoint("TOPLEFT", 2, -2);
                        frame.background:SetPoint("BOTTOMRIGHT", -2, 2);

                        frame.text = frame:CreateFontString("CompactRaidThreatFrame_" .. playerPartyId .. "FontString",
                            "ARTWORK", "GameFontNormalSmall");
                        frame.text:SetTextColor(1, 1, 1, 1);
                        frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, 0);
                        frame.text:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0);

                        -- frame:SetBackdrop({
                        --	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                        --	tile = true, tileSize = 10, edgeSize = 10,
                        --
                        --	insets = { left = 4, right = 4, top = 4, bottom = 4 }});

                        frame.GetTextField = function()
                            return frame.text;
                        end

                        frame.GetBackground = function()
                            return frame.background;
                        end

                        q:HandleElvUi(frame, function()
                        end);
                    end
                    return frame;
                end
            end
        end
    end
end

function c:GetNamePlateThreatFrame(namePlate)
    if namePlate then
        local namePlateName = namePlate:GetName();
        local frame = frames[namePlateName];
        if not frame then
            frame = CreateFrame("Frame", namePlateName .. "ThreadFrame", namePlate,
                BackdropTemplateMixin and "BackdropTemplate");
            frames[namePlateName] = frame;

            frame:SetPoint("TOPLEFT", namePlate, "TOPLEFT", -36, -15);
            frame:SetPoint("BOTTOMRIGHT", namePlate, "BOTTOMRIGHT", -120, 2);
            frame:SetBackdrop({
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                tile = true,
                tileSize = 10,
                edgeSize = 10,
                insets = {
                    left = 4,
                    right = 4,
                    top = 4,
                    bottom = 4
                }
            });

            frame.text = frame:CreateFontString(namePlateName .. "ThreadFrameFontString", "ARTWORK",
                "GameFontNormalSmall");
            frame.text:SetTextColor(1, 1, 1, 1);
            frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 0);
            frame.text:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0);

            frame.GetTextField = function()
                return frame.text;
            end

            frame.GetBackground = function()
                return frame.background;
            end

            q:HandleElvUi(frame, function()
            end);
            frame:Show();
        end
        return frame;
    end
end

function c:GetTargetThreatFrame()
    local frame = frames["TargetFrame"];
    if not frame then
        frame = CreateFrame("Frame", "TargetThreatFrame", TargetFrame, BackdropTemplateMixin and "BackdropTemplate");
        frames["TargetFrame"] = frame;

        frame:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", -8, 8);
        frame:SetFrameStrata("BACKGROUND");
        frame:SetSize(175, 60);
        frame:SetClipsChildren(true);
        frame:SetFrameLevel(100);

        local innerFrame = CreateFrame("Frame", "TargetThreatInnerFrame", frame,
            BackdropTemplateMixin and "BackdropTemplate");
        -- innerFrame:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", 2, -2);
        -- innerFrame:SetFrameStrata("BACKGROUND");
        -- innerFrame:SetSize(155, 40);
        innerFrame:SetPoint("TOPLEFT", 10, -10);
        innerFrame:SetPoint("BOTTOMRIGHT", -10, 10);

        innerFrame.text = innerFrame:CreateFontString("TargetThreatFrameFontString", "ARTWORK", "GameFontNormal");
        innerFrame.text:SetTextColor(1, 1, 1, 1);
        innerFrame.text:SetPoint("TOPLEFT", innerFrame, "TOPLEFT", 0, -7);
        innerFrame.text:SetPoint("TOPRIGHT", innerFrame, "TOPRIGHT", 0, -7);

        innerFrame.background = innerFrame:CreateTexture(nil, "BACKGROUND");
        innerFrame.background:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
        innerFrame.background:SetPoint("TOP", 0, -3);
        innerFrame.background:SetSize(152, 16);

        innerFrame.glow = innerFrame:CreateTexture(nil, "BACKGROUND");
        innerFrame.glow:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash");
        innerFrame.glow:SetPoint("TOPLEFT", -11, 369);
        innerFrame.glow:SetTexCoord(0, 0.955, 0, 0.755);
        innerFrame.glow:SetWidth(300);
        innerFrame.glow:Hide();

        innerFrame:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = {
                left = 8,
                right = 8,
                top = 8,
                bottom = 8
            }
        });

        innerFrame.GetTextField = function()
            return innerFrame.text;
        end

        innerFrame.GetBackground = function()
            return innerFrame.background;
        end

        innerFrame.GetGlow = function()
            return innerFrame.glow;
        end

        frame.GetTextField = function()
            return innerFrame:GetTextField();
        end

        frame.GetBackground = function()
            return innerFrame:GetBackground();
        end

        frame.GetGlow = function()
            return innerFrame:GetGlow();
        end

        q:HandleElvUi(frame, function()
        end);
    end
    return frame;
end

function c:GetTargetTargetThreatFrame()
    local frame = frames["TargetFrameToT"];
    if not frame then
        frame = CreateFrame("Frame", "TargetTargetThreatFrame", TargetFrameToT,
            BackdropTemplateMixin and "BackdropTemplate");
        frames["TargetFrameToT"] = frame;

        frame:SetPoint("TOPLEFT", TargetFrameToT, "TOPLEFT", 1, -27);
        frame:SetFrameStrata("BACKGROUND");
        frame:SetSize(41, 30);

        frame.background = frame:CreateTexture(nil, "BACKGROUND");
        frame.background:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
        frame.background:SetPoint("TOPLEFT", 2, -2);
        frame.background:SetPoint("BOTTOMRIGHT", -2, 2);

        frame.text = frame:CreateFontString("TargetToTThreatFrameFontString", "ARTWORK", "GameFontNormalSmall");
        frame.text:SetTextColor(1, 1, 1, 1);
        frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -17);
        frame.text:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -17);

        frame:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = {
                left = 8,
                right = 8,
                top = 8,
                bottom = 8
            }
        });

        frame.GetTextField = function()
            return frame.text;
        end

        frame.GetBackground = function()
            return frame.background;
        end

        q:HandleElvUi(frame, function()
        end);
    end
    return frame;
end

local function SetPlayerThreatFrameTextLocation(frame)
    if IsInRaid() then
        local groupIndicator = _G["PlayerFrameGroupIndicator"];
        if groupIndicator and groupIndicator:IsVisible() then
            frame:GetTextField():SetPoint("TOPLEFT", frame, "TOPLEFT", 42, -7);
            frame:GetTextField():SetPoint("TOPRIGHT", frame, "TOPRIGHT", 42, -7);
            return;
        end
    end
    frame:GetTextField():SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -7);
    frame:GetTextField():SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -7);
end

function c:GetPlayerThreatFrame()
    local frame = frames["PlayerFrame"];
    if not frame then
        frame = CreateFrame("Frame", "PlayerThreatFrame", PlayerFrame, BackdropTemplateMixin and "BackdropTemplate");
        frames["PlayerFrame"] = frame;

        frame:SetPoint("TOPLEFT", PlayerFrame, "TOPRIGHT", -157, -2);
        frame:SetFrameStrata("BACKGROUND");
        frame:SetSize(155, 40);

        frame.text = frame:CreateFontString("PlayerThreatFrameFontString", "ARTWORK", "GameFontNormal");
        frame.text:SetTextColor(1, 1, 1, 1);

        frame.background = frame:CreateTexture(nil, "BACKGROUND");
        frame.background:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
        frame.background:SetPoint("TOP", 0, -3);
        frame.background:SetSize(152, 16);

        frame:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = {
                left = 8,
                right = 8,
                top = 8,
                bottom = 8
            }
        });

        frame.GetTextField = function()
            return frame.text;
        end

        frame.GetBackground = function()
            return frame.background;
        end

        frame:SetScript("OnMouseDown", function(self, button)
            if button == 'LeftButton' then
                c:ToggleTankMode();
            end
        end);

        local tankModeFrame = CreateFrame("Frame", "PlayerThreatFrame_TankModeFrame", frame);
        frame.tankModeFrame = tankModeFrame;
        tankModeFrame:SetFrameStrata("DIALOG");
        tankModeFrame:SetSize(50, 22);
        tankModeFrame:SetPoint("TOPLEFT", frame)
        tankModeFrame.text = tankModeFrame:CreateFontString("PlayerThreatFrame_TankModeFrameFontString", "ARTWORK",
            "GameFontNormal");
        tankModeFrame.text:SetAllPoints();

        if c:IsTankModeEnabled() then
            tankModeFrame.text:SetText("|TInterface\\GROUPFRAME\\UI-GROUP-MAINTANKICON:14:14:0:0|t");
        end

        tankModeFrame.GetTextField = function()
            return tankModeFrame.text;
        end

        tankModeFrame.GetBackground = function()
            return tankModeFrame.background;
        end

        q:HandleElvUi(frame, function()
        end);
    end

    SetPlayerThreatFrameTextLocation(frame);
    return frame;
end

function c:GetPlayerPetThreatFrame()
    local frame = frames["PetFrame"];
    if not frame then
        frame = CreateFrame("Frame", "PlayerPetThreatFrame", PetFrame, BackdropTemplateMixin and "BackdropTemplate");
        frames["PetFrame"] = frame;

        frame:SetPoint("TOPLEFT", PetFrame, "TOPLEFT", -40, -17);
        frame:SetFrameStrata("BACKGROUND");
        frame:SetSize(54, 26);

        frame.background = frame:CreateTexture(nil, "BACKGROUND");
        frame.background:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
        frame.background:SetPoint("TOPLEFT", 2, -2);
        frame.background:SetPoint("BOTTOMRIGHT", -2, 2);

        frame.text = frame:CreateFontString("PlayerPetThreatFrameFontString", "ARTWORK", "GameFontNormalSmall");
        frame.text:SetTextColor(1, 1, 1, 1);
        frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -7);
        frame.text:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -7);

        frame:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = {
                left = 8,
                right = 8,
                top = 8,
                bottom = 8
            }
        });

        frame.GetTextField = function()
            return frame.text;
        end

        frame.GetBackground = function()
            return frame.background;
        end

        q:HandleElvUi(frame, function()
        end);
    end
    return frame;
end

function c:HideFrames()
    for unitId, frame in pairs(frames) do
        frame:Hide();
    end
    q:ResetRaidFrameInfo();
end
