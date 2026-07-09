-- scope stuff
qualityoflife = qualityoflife or {};
local q = qualityoflife;

q.modules = q.modules or {};
q.modules["QoL_ClassicThreat-TBC"] = q.modules["QoL_ClassicThreat-TBC"] or {};
local c = q.modules["QoL_ClassicThreat-TBC"];

local labelWidth, sliderWidth = 180, 170;

local btnResetAll;

local lblHeaderGeneral, lblHeaderUnitFrames;

local chShowBarFrame;

local lblPlayerAccuracy, sldPlayerAccuracy, lblPlayerAccuracyHint;
local chShowPlayer, chShowPlayerTankMode, chShowPlayerPet;
local chShowTarget, chShowTargetTarget;
local chShowParty;
local lblPartyAccuracy, sldPartyAccuracy, lblPartyAccuracyHint;
local chShowRaid, chShowRaidOutline;
local lblRaidAccuracy, sldRaidAccuracy, lblRaidAccuracyHint;

local lblHeaderNamePlates;
local chShowNamePlates;

local btnAddBarFrame;
local lblBarFrameAnimations, chBarFrameAnimations;
local lblBarFrameAutoOpenClose, chBarFrameAutoOpenClose;

local spacings, spacingIndex = {};

local BARFRAMES = "BARFRAMES";
local ACTIVE = "ACTIVE";
local UNITID = "UNITID";
local BOTTOM = "BOTTOM";
local LEFT = "LEFT";
local WIDTH = "WIDTH";
local HEIGHT = "HEIGHT";
local LOCKED = "LOCKED";
local LASTUSED = "LASTUSED";

local function SetDefaultValues()
    QOL_OPTIONS = QOL_OPTIONS or {};
    QOL_OPTIONS[c.name] = QOL_OPTIONS[c.name] or {};

    -- -- global options
    -- player
    QOL_OPTIONS[c.name][c.FRAME_PLAYER] = QOL_OPTIONS[c.name][c.FRAME_PLAYER] or {};
    if QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ENABLED] == nil then
        QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ENABLED] = true;
    end
    if QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ACCURACY] == nil then
        QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ACCURACY] = 8;
    end

    -- player pet
    QOL_OPTIONS[c.name][c.FRAME_PLAYER_PET] = QOL_OPTIONS[c.name][c.FRAME_PLAYER_PET] or {};
    if QOL_OPTIONS[c.name][c.FRAME_PLAYER_PET][c.OPT_ENABLED] == nil then
        QOL_OPTIONS[c.name][c.FRAME_PLAYER_PET][c.OPT_ENABLED] = true;
    end

    -- target
    QOL_OPTIONS[c.name][c.FRAME_TARGET] = QOL_OPTIONS[c.name][c.FRAME_TARGET] or {};
    if QOL_OPTIONS[c.name][c.FRAME_TARGET][c.OPT_ENABLED] == nil then
        QOL_OPTIONS[c.name][c.FRAME_TARGET][c.OPT_ENABLED] = true;
    end

    -- targettarget
    QOL_OPTIONS[c.name][c.FRAME_TARGET_TARGET] = QOL_OPTIONS[c.name][c.FRAME_TARGET_TARGET] or {};
    if QOL_OPTIONS[c.name][c.FRAME_TARGET_TARGET][c.OPT_ENABLED] == nil then
        QOL_OPTIONS[c.name][c.FRAME_TARGET_TARGET][c.OPT_ENABLED] = true;
    end

    -- party
    QOL_OPTIONS[c.name][c.FRAME_PARTY] = QOL_OPTIONS[c.name][c.FRAME_PARTY] or {};
    if QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ENABLED] == nil then
        QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ENABLED] = true;
    end
    if QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ACCURACY] == nil then
        QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ACCURACY] = 8;
    end

    -- raid compact
    QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT] = QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT] or {};
    if QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ENABLED] == nil then
        QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ENABLED] = true;
    end
    if QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ACCURACY] == nil then
        QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ACCURACY] = 4;
    end
    if QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_OUTLINE] == nil then
        QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_OUTLINE] = false;
    end

    -- nameplate (experimental)
    QOL_OPTIONS[c.name][c.FRAME_NAMEPLATE] = QOL_OPTIONS[c.name][c.FRAME_NAMEPLATE] or {};
    if QOL_OPTIONS[c.name][c.FRAME_NAMEPLATE][c.OPT_ENABLED] == nil then
        QOL_OPTIONS[c.name][c.FRAME_NAMEPLATE][c.OPT_ENABLED] = false;
    end

    -- -- character based options
    QOL_OPTIONS[c.name][q:GetRealmName()] = QOL_OPTIONS[c.name][q:GetRealmName()] or {};
    QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()] = QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()] or {};

    if QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][c.OPT_TANK_MODE] == nil then
        QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][c.OPT_TANK_MODE] = false;
    end

    -- barframes
    QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES] = QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES] or {};

    if QOL_OPTIONS[c.name][c.OPT_BARFRAME_ANIMATIONS] == nil then
        QOL_OPTIONS[c.name][c.OPT_BARFRAME_ANIMATIONS] = true;
    end
    if QOL_OPTIONS[c.name][c.OPT_BARFRAME_AUTO_OPENCLOSE] == nil then
        QOL_OPTIONS[c.name][c.OPT_BARFRAME_AUTO_OPENCLOSE] = true;
    end
end

function c:InitOptions()
    -- options
    c.OPT_VISITED = "OPT_VISITED";

    -- frames
    c.FRAME_PLAYER = "FRAME_PLAYER";
    c.FRAME_PLAYER_PET = "FRAME_PLAYER_PET";
    c.FRAME_TARGET = "FRAME_TARGET";
    c.FRAME_TARGET_TARGET = "FRAME_TARGET_TARGET";
    c.FRAME_PARTY = "FRAME_PARTY";
    c.FRAME_RAID_COMPACT = "FRAME_RAID_COMPACT";
    c.FRAME_NAMEPLATE = "FRAME_NAMEPLATE";

    -- options
    c.OPT_ENABLED = "OPT_ENABLED";
    c.OPT_ACCURACY = "OPT_ACCURACY";
    c.OPT_OUTLINE = "OPT_OUTLINE";
    c.OPT_TANK_MODE = "OPT_TANK_MODE";

    c.OPT_BARFRAME_ANIMATIONS = "OPT_BARFRAME_ANIMATIONS";
    c.OPT_BARFRAME_AUTO_OPENCLOSE = "OPT_BARFRAME_AUTO_OPENCLOSE";

    SetDefaultValues();

    -- optionsPanel init
    if not c.optionsPanel then
        c.optionsPanel = CreateFrame("Frame", "QoLOptionsFrame_ClassicThreat", q.optionsPanel);
        c.optionsPanel.name = "ClassicThreat";
        c.optionsPanel.parent = q.optionsPanel.name;
        c.optionsPanel.okay = function()
            c:SaveSettingsChanges();
        end;
        c.optionsPanel.cancel = function()
            c:RevertSettingsChanges();
        end;
        InterfaceOptions_AddCategory(c.optionsPanel);
        c.optionsPanel:SetScript("OnShow", function()
            if c.initFinished then
                c:ShowOptionsPanel();
                QOL_OPTIONS[c.name][c.OPT_VISITED] = true;
                c.optionsPanel.oldValues[c.OPT_VISITED] = true;
            end
        end);
        c.optionsPanel:SetScript("OnHide", function()
            if c.initFinished then
                c:HideFrames(); -- reset frames in case frames were visible at this point
            end
        end);
        q:HandleElvUi(c.optionsPanel);

        -- workaround for lazy profile loading (addon loading timing problem)
        _G["InterfaceOptionsFrameTab2"]:HookScript("OnClick", function()
            c:ShowOptionsPanel();
        end);

        c:ShowOptionsPanel();
    end

    return true;
end

function c:UpdateDatabase_Version16()
    --/run qualityoflife.modules["QoL_ClassicThreat-TBC"]:UpdateDatabase_Version16()

    for realmName, realmData in pairs(QOL_OPTIONS[c.name]) do
        if type(realmData) == "table" then
            for charName, charData in pairs(realmData) do
                if type(charData) == "table" and charData[BARFRAMES] then
                    -- add LASTUSED to barframes
                    for id, barFrame in pairs(charData[BARFRAMES]) do
                        if not barFrame[LASTUSED] then
                            QOL_OPTIONS[c.name][realmName][charName][BARFRAMES][id][LASTUSED] = time();
                        end
                    end

                    -- remove inactive list
                    QOL_OPTIONS[c.name][realmName][charName]["BARFRAMES_INACTIVE_IDS"] = nil;
                end
            end
        end
    end
end

local function SetOptionsEnabled(value, ...)
    for _, element in ipairs({...}) do
        if element.SetEnabled then
            element:SetEnabled(value);
        end
        if value then
            element:SetDefaultTextColor();
        else
            element:SetTextColor(0.7, 0.7, 0.7, 1);
        end
    end
end

function c:ShowOptionsPanel()
    spacingIndex, c.optionsPanel.oldValues = 1, q:Deepcopy(QOL_OPTIONS[c.name]);

    -- player enabled
    if not chShowPlayer then
        chShowPlayer = q:CreateOptionsCheckbox(c.optionsPanel, q:GetText("Show my threat (\"player\")"), function(self)
            QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ENABLED] = self:GetChecked();
            SetOptionsEnabled(QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ENABLED], chShowPlayerTankMode);
            SetOptionsEnabled(QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ENABLED] or
                                  QOL_OPTIONS[c.name][c.FRAME_PLAYER_PET][c.OPT_ENABLED], lblPlayerAccuracy,
                sldPlayerAccuracy, lblPlayerAccuracyHint);
        end);
    end
    chShowPlayer:SetChecked(QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ENABLED]);

    -- player tank mode
    if not chShowPlayerTankMode then
        chShowPlayerTankMode = q:CreateOptionsCheckbox(c.optionsPanel, q:GetText(
            "Tank Mode (shows lowest threat except target instead of highest threat)"), function(self)
            QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][c.OPT_TANK_MODE] = self:GetChecked();
        end, 24);
    end
    chShowPlayerTankMode:SetChecked(QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][c.OPT_TANK_MODE]);
    SetOptionsEnabled(QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ENABLED], chShowPlayerTankMode);

    -- player pet enabled
    if not chShowPlayerPet then
        chShowPlayerPet = q:CreateOptionsCheckbox(c.optionsPanel, q:GetText("Show my pets threat (\"playerpet\")"),
            function(self)
                QOL_OPTIONS[c.name][c.FRAME_PLAYER_PET][c.OPT_ENABLED] = self:GetChecked();
                SetOptionsEnabled(QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ENABLED] or
                                      QOL_OPTIONS[c.name][c.FRAME_PLAYER_PET][c.OPT_ENABLED], lblPlayerAccuracy,
                    sldPlayerAccuracy, lblPlayerAccuracyHint);
            end);
    end
    chShowPlayerPet:SetChecked(QOL_OPTIONS[c.name][c.FRAME_PLAYER_PET][c.OPT_ENABLED]);

    -- player accuracy
    if not lblPlayerAccuracy then
        lblPlayerAccuracy = q:CreateOptionsLabel(c.optionsPanel, q:GetText("Accuracy: %s / 8",
            QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ACCURACY]), 0, true);
    end
    if not sldPlayerAccuracy then
        sldPlayerAccuracy = q:CreateOptionsSlider(c.optionsPanel, 1, 8, function(self)
            if c.initFinished then
                QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ACCURACY] = self:GetValue();
                lblPlayerAccuracy:SetText(q:GetText("Accuracy: %s / 8",
                    QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ACCURACY]));
            end
        end, 120, true, sliderWidth, 1, q:GetText("min"), q:GetText("max"));
    end
    sldPlayerAccuracy:SetValue(QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ACCURACY]);
    if not lblPlayerAccuracyHint then
        lblPlayerAccuracyHint = q:CreateOptionsLabel(c.optionsPanel,
            q:GetText("(Decrease if you notice lag during combat)"), 320);
    end

    c:InsertSpacing();
    c:InsertSpacing();

    -- target enabled
    if not chShowTarget then
        chShowTarget = q:CreateOptionsCheckbox(c.optionsPanel, q:GetText("Show my threat on target (\"target\")"),
            function(self)
                QOL_OPTIONS[c.name][c.FRAME_TARGET][c.OPT_ENABLED] = self:GetChecked();
            end);
    end
    chShowTarget:SetChecked(QOL_OPTIONS[c.name][c.FRAME_TARGET][c.OPT_ENABLED]);

    -- target target enabled
    if not chShowTargetTarget then
        chShowTargetTarget = q:CreateOptionsCheckbox(c.optionsPanel,
            q:GetText("Show target-target threat (\"targettarget\")"), function(self)
                QOL_OPTIONS[c.name][c.FRAME_TARGET_TARGET][c.OPT_ENABLED] = self:GetChecked();
            end);
    end
    chShowTargetTarget:SetChecked(QOL_OPTIONS[c.name][c.FRAME_TARGET_TARGET][c.OPT_ENABLED]);

    c:InsertSpacing();
    c:InsertSpacing();

    -- party enabled
    if not chShowParty then
        chShowParty = q:CreateOptionsCheckbox(c.optionsPanel, q:GetText("Show threat for party members (\"partyN\")"),
            function(self)
                QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ENABLED] = self:GetChecked();
                SetOptionsEnabled(QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ENABLED], lblPartyAccuracy, sldPartyAccuracy,
                    lblPartyAccuracyHint);
            end);
    end
    chShowParty:SetChecked(QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ENABLED]);

    -- party accuracy
    if not lblPartyAccuracy then
        lblPartyAccuracy = q:CreateOptionsLabel(c.optionsPanel, q:GetText("Accuracy: %s / 8",
            QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ACCURACY]), 0, true);
    end

    if not sldPartyAccuracy then
        sldPartyAccuracy = q:CreateOptionsSlider(c.optionsPanel, 1, 8, function(self)
            if c.initFinished then
                QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ACCURACY] = self:GetValue();
                lblPartyAccuracy:SetText(q:GetText("Accuracy: %s / 8",
                    QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ACCURACY]));
            end
        end, 120, true, sliderWidth, 1, q:GetText("min"), q:GetText("max"));
    end
    sldPartyAccuracy:SetValue(QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ACCURACY]);

    if not lblPartyAccuracyHint then
        lblPartyAccuracyHint = q:CreateOptionsLabel(c.optionsPanel,
            q:GetText("(Decrease if you notice lag during combat)"), 320);
    end

    SetOptionsEnabled(QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ENABLED], lblPartyAccuracy, sldPartyAccuracy,
        lblPartyAccuracyHint);

    c:InsertSpacing();
    c:InsertSpacing();

    -- raid enabled
    if not chShowRaid then
        chShowRaid = q:CreateOptionsCheckbox(c.optionsPanel, q:GetText("Show threat for raid members (\"raidN\")"),
            function(self)
                QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ENABLED] = self:GetChecked();
                SetOptionsEnabled(QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ENABLED], chShowRaidOutline,
                    lblRaidAccuracy, sldRaidAccuracy, lblRaidAccuracyHint);
            end);
    end
    chShowRaid:SetChecked(QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ENABLED]);

    -- raid outline
    if not chShowRaidOutline then
        chShowRaidOutline = q:CreateOptionsCheckbox(c.optionsPanel,
            q:GetText("Outline for raid numbers (improves readability)"), function(self)
                QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_OUTLINE] = self:GetChecked();
            end, 24);
    end
    chShowRaidOutline:SetChecked(QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_OUTLINE]);

    -- raid accuracy
    if not lblRaidAccuracy then
        lblRaidAccuracy = q:CreateOptionsLabel(c.optionsPanel, q:GetText("Accuracy: %s / 8",
            QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ACCURACY]), 0, true);
    end

    if not sldRaidAccuracy then
        sldRaidAccuracy = q:CreateOptionsSlider(c.optionsPanel, 1, 8, function(self)
            if c.initFinished then
                QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ACCURACY] = self:GetValue();
                lblRaidAccuracy:SetText(q:GetText("Accuracy: %s / 8",
                    QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ACCURACY]));
            end
        end, 120, true, sliderWidth, 1, q:GetText("min"), q:GetText("max"));
    end
    sldRaidAccuracy:SetValue(QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ACCURACY]);

    if not lblRaidAccuracyHint then
        lblRaidAccuracyHint = q:CreateOptionsLabel(c.optionsPanel,
            q:GetText("(Decrease if you notice lag during combat)"), 320);
    end

    SetOptionsEnabled(QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ENABLED], chShowRaidOutline, lblRaidAccuracy,
        sldRaidAccuracy, lblRaidAccuracyHint);

    c:InsertSpacing();
    c:InsertSpacing();

    if not btnAddBarFrame then
        btnAddBarFrame = q:CreateOptionsButton(c.optionsPanel, q:GetText("Add Threat Barframe"), function()
            c:AddBarFrame();
        end);
    end

    -- barframe animations
    if not chBarFrameAnimations then
        chBarFrameAnimations = q:CreateOptionsCheckbox(c.optionsPanel,
            q:GetText("Barframe animations"), function(self)
                QOL_OPTIONS[c.name][c.OPT_BARFRAME_ANIMATIONS] = self:GetChecked();
            end);
    end
    chBarFrameAnimations:SetChecked(QOL_OPTIONS[c.name][c.OPT_BARFRAME_ANIMATIONS]);

    -- barframe open close
    if not chBarFrameAutoOpenClose then
        chBarFrameAutoOpenClose = q:CreateOptionsCheckbox(c.optionsPanel,
            q:GetText("Automatically show/hide barframes when joining/leaving party or raid"), function(self)
                QOL_OPTIONS[c.name][c.OPT_BARFRAME_AUTO_OPENCLOSE] = self:GetChecked();
            end);
    end
    chBarFrameAutoOpenClose:SetChecked(QOL_OPTIONS[c.name][c.OPT_BARFRAME_AUTO_OPENCLOSE]);

    -- name plates header
    -- if not lblHeaderNamePlates then
    --    lblHeaderNamePlates = q:CreateOptionsHeader(c.optionsPanel, q:GetText("Name Plates (experimental)"));
    -- end

    -- name plates enabled
    -- if not chShowNamePlates then
    --    chShowNamePlates = q:CreateOptionsCheckbox(c.optionsPanel, q:GetText("Show threat on name plates (\"nameplateN\")"),
    --        function(self)
    --            QOL_OPTIONS[c.name][c.FRAME_NAMEPLATE][c.OPT_ENABLED] = self:GetChecked();
    --        end);
    -- end
    -- chShowNamePlates:SetChecked(QOL_OPTIONS[c.name][c.FRAME_NAMEPLATE][c.OPT_ENABLED]);

    -- reset all
    if not btnResetAll then
        btnResetAll = q:CreateOptionsButton(c.optionsPanel, q:GetText("Reset all"), function()
            c:ShowResetDialog();
        end);
        btnResetAll:ClearAllPoints();
        btnResetAll:SetPoint("BOTTOMLEFT", 15, 15);
    end
end

function c:InsertSpacing()
    if not spacings[spacingIndex] then
        spacings[spacingIndex] = q:CreateOptionsSpacing(c.optionsPanel);
    end
    spacingIndex = spacingIndex + 1;
end

function c:RevertSettingsChanges()
    QOL_OPTIONS[c.name] = c.optionsPanel.oldValues;
end

function c:SaveSettingsChanges()
    c.optionsPanel.oldValues = q:Deepcopy(QOL_OPTIONS[c.name]);
    -- c:ToggleBarFrame(QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][c.BARFRAMES][c.OPT_ENABLED]);
end

function c:IsTankModeEnabled()
    return QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][c.OPT_TANK_MODE];
end

function c:IsBarFrameAnimationsEnabled()
    return QOL_OPTIONS[c.name][c.OPT_BARFRAME_ANIMATIONS];
end

function c:IsBarFrameAutoOpenCloseEnabled()
    return QOL_OPTIONS[c.name][c.OPT_BARFRAME_AUTO_OPENCLOSE];
end

function c:ToggleTankMode()
    local newVal, text = not QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][c.OPT_TANK_MODE];
    QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][c.OPT_TANK_MODE] = newVal;

    if newVal then
        text = q:GetText("enabled");
        c:GetPlayerThreatFrame().tankModeFrame.text:SetText("|TInterface\\GROUPFRAME\\UI-GROUP-MAINTANKICON:14:14:0:0|t");
    else
        text = q:GetText("disabled");
        c:GetPlayerThreatFrame().tankModeFrame.text:SetText("");
    end
    c:GetPlayerThreatFrame():Hide();
    c:Println(q:GetText("Tank mode %s.", text));

    return newVal;
end

function c:GetLatestUsedInactiveBarFrameId()
    -- try get last unused id
    local latestId, lastUsed;
    for id, barFrame in pairs(QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES]) do
        if not barFrame[ACTIVE] and barFrame[LASTUSED] and (not latestId or lastUsed < barFrame[LASTUSED]) then
            latestId, lastUsed = id, barFrame[LASTUSED];
        end
    end
    if latestId then
        return latestId;
    end

    -- if none: create new one
    local i = 1;
    while QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES]["BF" .. i] do
        i = i + 1;
    end
    return "BF" .. i;
end

function c:TryRestoreInactiveBarFrame(barFrame)
    local id = barFrame:GetId();
    local data = QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES][id];
    if data then
        -- dimension
        local width, height = data[WIDTH], data[HEIGHT];
        if width < c:GetBarFrameMinWidth() then
            width = c:GetBarFrameMinWidth();
        end
        if height < c:GetBarFrameMinHeight() then
            height = c:GetBarFrameMinHeight();
        end
        barFrame:SetSize(width, height);

        -- position
        barFrame:Move(data[LEFT], data[BOTTOM]);

        -- state
        barFrame:SetLocked(data[LOCKED]);

        -- user data
        barFrame:SetUnitId(data[UNITID]);
    end
end

function c:SaveBarFrame(barFrame)
    if c.initFinished and barFrame then
        local id = barFrame:GetId();

        -- make sure db entry exists
        QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES] = QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES] or {};
        QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES][id] = QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES][id] or {};

        -- dimension
        QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES][id][WIDTH] = barFrame:GetWidth();
        QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES][id][HEIGHT] = barFrame:GetHeight();

        -- position
        QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES][id][LEFT] = barFrame:GetLeft();
        QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES][id][BOTTOM] = barFrame:GetBottom();

        -- state
        QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES][id][ACTIVE] = barFrame:IsActive();
        QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES][id][LOCKED] = barFrame:IsLocked();

        -- user data
        QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES][id][UNITID] = barFrame:GetUnitId();

        -- last used
        QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES][id][LASTUSED] = time();
    end
end

function c:GetActiveBarFrameIds()
    local ids, totalFrames = {}, 0;
    for id, data in pairs(QOL_OPTIONS[c.name][q:GetRealmName()][q:GetPlayerName()][BARFRAMES]) do
        if data[ACTIVE] then
            tinsert(ids, id);
        end
        totalFrames = totalFrames + 1;
    end
    return ids, totalFrames;
end
