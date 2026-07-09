-- scope stuff
qualityoflife = qualityoflife or {};
local q = qualityoflife;

q.modules = q.modules or {};
q.modules["QoL_ClassicThreat-TBC"] = q.modules["QoL_ClassicThreat-TBC"] or {};
local c = q.modules["QoL_ClassicThreat-TBC"];
c.name = "QoL_ClassicThreat-TBC";
c.version = 22; -- check for toc
c.minCoreVersion = 15;

local FRAMETYPE_PLAYER = "FRAMETYPE_PLAYER";
local FRAMETYPE_COMPACT_RAID = "FRAMETYPE_COMPACT_RAID";

local threatListeners = {};

-- main threat cache: memberGuid -> targetUnitGuid -> threatInfo
local threatCache = {};
-- allow maximum queries per second
local queriesLastSecond = 0;

function c:GetThreatCache()
    return threatCache;
end

-- available target unitIds (depends on accuracy settings)
local availableTargetUnitIds = {
    [1] = "target",
    [2] = "targettarget",
    [3] = "pettarget",
    [4] = "pettargettarget",
    [5] = "targettargettarget",
    [6] = "pettargettargettarget",
    [7] = "targettargettargettarget",
    [8] = "pettargettargettargettarget"
};

local threatStatusColors = {
    [0] = {0.69, 0.69, 0.69},
    [1] = {1, 1, 0.47},
    [2] = {1, 0.6, 0},
    [3] = {1, 0, 0}
};

function c:GetThreatStatusColors(index, alpha)
    local r, g, b = unpack(threatStatusColors[index]);
    local a = alpha or 1;
    return {r, g, b, a};
end

local function GetThreatAccuracy()
    if IsInRaid() then
        return QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ACCURACY];
    elseif IsInGroup() then
        return QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ACCURACY];
    end
    return QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ACCURACY];
end

-- init
local function UpdateAddon()
    if not QOL_OPTIONS[c.name][q.META_LASTVERSION] then
        QOL_OPTIONS[c.name][q.META_LASTVERSION] = 0;
    end

    if QOL_OPTIONS[c.name][q.META_LASTVERSION] < c.version then

        if QOL_OPTIONS[c.name][q.META_LASTVERSION] < 16 then
            c:UpdateDatabase_Version16();
        end

        QOL_OPTIONS[c.name][q.META_LASTVERSION] = c.version;
    end
    return true;
end

local function ShowDropDown(self, level, target, name, userData)
    if c.initFinished and target == "player" and UIDROPDOWNMENU_MENU_LEVEL == 1 then
        -- separator and default values
        local info = UIDropDownMenu_CreateInfo();
        info.notCheckable = true;
        info.notClickable = true;
        info.disabled = true;
        UIDropDownMenu_AddButton(info);

        -- title
        local info = UIDropDownMenu_CreateInfo();
        info.notCheckable = true;
        info.notClickable = true;
        info.hasArrow = false;
        info.disabled = false;
        info.isTitle = true;
        info.text = q:GetText("Classic Threat");
        UIDropDownMenu_AddButton(info);

        -- toggle tank mode
        info.notClickable = false;
        info.notCheckable = false;
        info.disabled = false;
        info.isTitle = false;
        info.checked = c:IsTankModeEnabled();
        info.text = q:GetText("Tank Mode");
        info.func = function()
            c:ToggleTankMode()
        end
        UIDropDownMenu_AddButton(info);
    end
end

local function LoadActiveBarFrames()
    local activeBarFrames, totalFrames = c:GetActiveBarFrameIds();
    if totalFrames == 0 then
        -- first time addon loaded -> add single bar frame
        c:AddBarFrame();
    else
        for _, id in ipairs(activeBarFrames) do
            c:AddBarFrame(id);
        end
    end

    if c:IsBarFrameAutoOpenCloseEnabled() then
        c:ToggleActiveFrames(IsInGroup() or IsInRaid());
    end
end

function c:Init()
    if q.initFinished and not c.initFinished and not c.initFailed then

        if q.version >= c.minCoreVersion then
            if c:InitOptions() and UpdateAddon() then

                hooksecurefunc("UnitPopup_ShowMenu", function(...)
                    ShowDropDown(...)
                end);

                QOL_OPTIONS[c.name]["version"] = c.version;

                -- load barframes
                LoadActiveBarFrames();

                c.initFinished = true;
                c:Println(q:GetText("Module loaded. Type '/classicthreat' for more information."));
                return true;
            end
        else
            c:Println(q:GetText(
                "Error while initialization: QoL Core is outdated (version %s)! Minimum required version: %s",
                q.version, c.minCoreVersion));
            c:Println(q:GetText(
                "Maybe another of your QoL addon comes with an older version. Please use the latest QoL_Core folder or download the latest version from CurseForge."));
        end
        c.initFailed = true;
    end
end

local function NotifyThreatListeners(unitId, status, threatPct)
    for name, callback in pairs(threatListeners) do
        if callback then
            pcall(callback, status, threatPct);
        end
    end
end

local function GetThreat(testedUnitId, targetUnitId)
    local isTanking, status, threatpct, rawthreatpct, threatvalue, percentOfLead = UnitDetailedThreatSituation(
        testedUnitId, targetUnitId);
    local customStatus;
    if isTanking then
        -- show percentages above 100 if tanking
        percentOfLead = UnitThreatPercentageOfLead(testedUnitId, targetUnitId);
    elseif status == 1 and rawthreatpct == 250 and percentOfLead == nil then
        -- undefined state (e.g. taunted)
        rawthreatpct = 100;
        customStatus = q:GetText("taunted");
    end
    return isTanking, status, threatpct, rawthreatpct, threatvalue, percentOfLead, customStatus;
end

local function RemoveMemberFromCache(guid)
    threatCache[guid] = nil;
end

local function RemoveEnemyFromCache(guid)
    for unitGuid, enemyUnitIds in pairs(threatCache) do
        threatCache[unitGuid][guid] = nil;
    end
end

local function GetUnitThreatSituation(testedUnitId, memberUnitIds)
    local testedUnitGuid = UnitGUID(testedUnitId);
    -- add cache for the tested unitId
    local testedUnitCombinations = {};
    if not threatCache[testedUnitGuid] then
        threatCache[testedUnitGuid] = {};
    end

    -- loop through member unitIds
    for memberUnitId, _ in pairs(memberUnitIds) do
        if UnitExists(memberUnitId) then

            -- add or remove cache entry for this member unitId
            local memberGuid = UnitGUID(memberUnitId);
            if UnitIsDead(memberUnitId) then
                RemoveMemberFromCache(memberGuid);
            else

                -- add memberunitid to combination cache
                testedUnitCombinations[memberGuid] = testedUnitCombinations[memberGuid] or {};

                -- create set of potential enemy unitIds based on the member unitId and chosen accuracy
                local targetUnitIds = {};
                for acc = 1, GetThreatAccuracy() do
                    tinsert(targetUnitIds, memberUnitId .. availableTargetUnitIds[acc]);
                end

                -- loop through potential enemy unitIds
                for _, targetUnitId in ipairs(targetUnitIds) do
                    if UnitExists(targetUnitId) and not UnitIsPlayer(targetUnitId) and
                        not UnitIsFriend(testedUnitId, targetUnitId) then
                        local targetUnitGuid = UnitGUID(targetUnitId);

                        -- check if this member-enemy combination has already been tested. if not: go on
                        if UnitIsDead(targetUnitId) or not UnitAffectingCombat(targetUnitId) then
                            RemoveEnemyFromCache(targetUnitGuid);
                        elseif testedUnitGuid ~= targetUnitGuid then

                            -- only test memberunitid-targetunitid-combination if not tested before
                            if not testedUnitCombinations[memberGuid][targetUnitId] then
                                testedUnitCombinations[memberGuid][targetUnitId] = true;

                                -- add threat information to main threat cache
                                local isTanking, status, threatpct, rawthreatpct, threatvalue, percentOfLead,
                                    customStatus = GetThreat(testedUnitId, targetUnitId);

                                if rawthreatpct or percentOfLead then
                                    local threatInfo = {};
                                    threatInfo.testedUnitId = testedUnitId;
                                    threatInfo.testedUnitGuid = UnitGUID(testedUnitId);
                                    threatInfo.testedUnitName = UnitName(testedUnitId);
                                    threatInfo.testedUnitRaidTarget = GetRaidTargetIndex(testedUnitId);

                                    threatInfo.targetUnitId = targetUnitId;
                                    threatInfo.targetUnitGuid = targetUnitGuid;
                                    threatInfo.targetName = UnitName(targetUnitId);
                                    threatInfo.targetUnitRaidTarget = GetRaidTargetIndex(targetUnitId);

                                    threatInfo.isTanking = isTanking;
                                    threatInfo.status = status or 0;
                                    threatInfo.threatpct = threatpct;
                                    threatInfo.rawthreatpct = rawthreatpct;
                                    threatInfo.threatvalue = threatvalue;
                                    threatInfo.percent = percentOfLead;

                                    threatInfo.customStatus = customStatus;

                                    if percentOfLead and percentOfLead > 0 then
                                        threatInfo.threat = percentOfLead;
                                    elseif rawthreatpct == 255 then
                                        threatInfo.threat = threatpct; -- solo workaround
                                    else
                                        threatInfo.threat = rawthreatpct;
                                    end

                                    if threatCache[testedUnitGuid] then
                                        -- entry might have been deleted in the mean time due to player death
                                        threatCache[testedUnitGuid][targetUnitGuid] = threatInfo;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- get highest value from all checked combinations for the tested unitId and return
    -- extra tables for alternating display on PlayerFrame
    local highestStatusThreatInfo, highestThreatPctThreatInfo, highestStatusThreatInfoPlayerFrame,
        highestThreatPctThreatInfoPlayerFrame;
    if threatCache[testedUnitGuid] then
        for targetUnitGuid, threatInfo in pairs(threatCache[testedUnitGuid]) do
            if not highestStatusThreatInfo or threatInfo.status > highestStatusThreatInfo.status then
                highestStatusThreatInfo = threatInfo;
            end
            if not highestThreatPctThreatInfo or threatInfo.threat > highestThreatPctThreatInfo.threat then
                highestThreatPctThreatInfo = threatInfo;
            end

            -- player frame info
            if not (testedUnitId == "player" and UnitGUID("target") == targetUnitGuid) then
                if c:IsTankModeEnabled() then
                    -- tank mode
                    if not highestStatusThreatInfoPlayerFrame or threatInfo.status <
                        highestStatusThreatInfoPlayerFrame.status then
                        highestStatusThreatInfoPlayerFrame = threatInfo;
                    end
                    if not highestThreatPctThreatInfoPlayerFrame or threatInfo.threat <
                        highestThreatPctThreatInfoPlayerFrame.threat then
                        highestThreatPctThreatInfoPlayerFrame = threatInfo;
                    end
                else
                    -- normal mode
                    if not highestStatusThreatInfoPlayerFrame or threatInfo.status >
                        highestStatusThreatInfoPlayerFrame.status then
                        highestStatusThreatInfoPlayerFrame = threatInfo;
                    end
                    if not highestThreatPctThreatInfoPlayerFrame or threatInfo.threat >
                        highestThreatPctThreatInfoPlayerFrame.threat then
                        highestThreatPctThreatInfoPlayerFrame = threatInfo;
                    end
                end
            end
        end
    end

    return highestStatusThreatInfo, highestThreatPctThreatInfo, highestStatusThreatInfoPlayerFrame,
        highestThreatPctThreatInfoPlayerFrame;
end

local function ShowTargetThreat()
    if TargetFrame:IsVisible() then

        local frame = c:GetTargetThreatFrame();
        if UnitExists("target") and not UnitIsPlayer("target") and not UnitIsFriend("player", "target") then
            local isTanking, status, threatpct, rawthreatpct, threatvalue, percentOfLead, customStatus = GetThreat("player", "target");
            status = status or 0;
            rawthreatpct = rawthreatpct or 0;
            if percentOfLead then
                rawthreatpct = percentOfLead;
            end

            if status and rawthreatpct > 0 then
                if customStatus then
                    frame:GetTextField():SetText(customStatus);
                else
                    frame:GetTextField():SetText(q:MathRound(rawthreatpct, 0) .. "%");
                end

                if status > 0 then
                    frame:GetBackground():SetVertexColor(unpack(threatStatusColors[status]));
                    frame:GetBackground():Show();
                    frame:GetGlow():SetVertexColor(unpack(threatStatusColors[status]));
                    frame:GetGlow():Show();
                else
                    frame:GetBackground():Hide();
                    frame:GetGlow():Hide();
                end

                frame:Show();
                NotifyThreatListeners("target", status, rawthreatpct);
                return;
            end
        end
        if frame:IsVisible() then
            frame:Hide();
        end
    end
end

local function ShowThreat(unitId, frame, highestStatusThreatInfo, highestThreatPctThreatInfo, frameType)
    if frame then
        if UnitExists(unitId) and not UnitIsDead(unitId) and not UnitIsDead("player") then
            local status, threat, customStatus = 0, 0;
            if highestStatusThreatInfo then
                status = highestStatusThreatInfo.status or status;
                customStatus = highestStatusThreatInfo.customStatus;
            end
            if highestThreatPctThreatInfo then
                threat = highestThreatPctThreatInfo.threat or threat;
                customStatus = customStatus or highestStatusThreatInfo.customStatus;
            end

            if status and threat > 0 then
                -- target button (experimental)
                if frame.targetButton then
                    if highestStatusThreatInfo then
                        frame.targetButton:SetAttribute("unit", highestStatusThreatInfo.targetUnitId);
                    elseif highestThreatPctThreatInfo then
                        frame.targetButton:SetAttribute("unit", highestThreatPctThreatInfo.targetUnitId);
                    end
                end

                -- display data
                if customStatus then
                    frame:GetTextField():SetText(customStatus);
                else
                    frame:GetTextField():SetText(q:MathRound(threat, 0) .. "%");
                end

                -- styling
                if status > 0 then
                    if frameType == FRAMETYPE_COMPACT_RAID then
                        frame:GetTextField():SetFontObject(nil);
                        if status > 1 then
                            frame:GetTextField():SetFontObject("GameFontNormalLarge");
                        else
                            frame:GetTextField():SetFontObject("GameFontNormal");
                        end
                        frame:GetTextField():SetTextColor(unpack(threatStatusColors[status]));
                        frame:GetBackground():Hide();
                    else
                        frame:GetBackground():SetVertexColor(unpack(threatStatusColors[status]));
                        frame:GetBackground():Show();
                    end
                else
                    frame:GetTextField():SetFontObject(nil);
                    if frameType == FRAMETYPE_PLAYER then
                        frame:GetTextField():SetFontObject("GameFontNormal");
                    else
                        frame:GetTextField():SetFontObject("GameFontNormalSmall");
                    end
                    frame:GetTextField():SetTextColor(1, 1, 1);
                    frame:GetBackground():Hide();
                end

                -- set outline if enabled
                if frameType == FRAMETYPE_COMPACT_RAID then
                    local fontName, fontHeight, fontFlags = frame:GetTextField():GetFont();
                    -- frame:GetTextField():SetFont(fontName, fontHeight);
                    if QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_OUTLINE] then
                        frame:GetTextField():SetFont(fontName, fontHeight, "OUTLINE");
                    end
                end

                frame:Show();
                NotifyThreatListeners(unitId, status, threat);
                return;
            end
        end

        frame:Hide();
    end
end

local function GetMemberUnitIds()
    local memberUnitIds = {};
    if QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ENABLED] then
        memberUnitIds["player"] = "player";
    end
    if QOL_OPTIONS[c.name][c.FRAME_PLAYER_PET][c.OPT_ENABLED] then
        memberUnitIds["playerpet"] = "playerpet";
    end
    if QOL_OPTIONS[c.name][c.FRAME_TARGET_TARGET][c.OPT_ENABLED] then
        if UnitIsFriend("player", "target") then
            memberUnitIds["target"] = "target"; -- in case targettarget is enemy
        elseif UnitIsFriend("player", "targettarget") then
            memberUnitIds["targettarget"] = "targettarget"; -- in case targettarget is ally
        end
    end
    if IsInRaid() and QOL_OPTIONS[c.name][c.FRAME_RAID_COMPACT][c.OPT_ENABLED] then
        for playerRaidId, playerName in ipairs(q:GetRaidMembers()[0]) do
            memberUnitIds["raid" .. playerRaidId] = playerRaidId;
        end
    elseif IsInGroup() and QOL_OPTIONS[c.name][c.FRAME_PARTY][c.OPT_ENABLED] then
        for playerPartyId, playerName in pairs(q:GetPartyMembers()) do
            memberUnitIds["party" .. playerPartyId] = playerPartyId;
        end
    end
    if QOL_OPTIONS[c.name][c.FRAME_NAMEPLATE][c.OPT_ENABLED] then
        for unitId, namePlate in pairs(q:GetVisibleNamePlates()) do
            -- print(unitId)
            memberUnitIds[unitId] = namePlate;
        end
    end
    return memberUnitIds;
end

local function UpdateThreat()
    -- target threat
    if QOL_OPTIONS[c.name][c.FRAME_TARGET][c.OPT_ENABLED] then
        ShowTargetThreat();
    end

    -- create set of member unitIds (self, allies in party or raid and their pets etc.)
    local memberUnitIds = GetMemberUnitIds();

    -- get threat info and display
    for memberUnitId, arg in pairs(memberUnitIds) do
        if UnitExists(memberUnitId) then
            local highestStatusThreatInfo, highestThreatPctThreatInfo, highestStatusThreatInfoPlayerFrame,
                highestThreatPctThreatInfoPlayerFrame = GetUnitThreatSituation(memberUnitId, memberUnitIds);

            if memberUnitId == "player" then
                ShowThreat(memberUnitId, c:GetPlayerThreatFrame(), highestStatusThreatInfoPlayerFrame,
                    highestThreatPctThreatInfoPlayerFrame, FRAMETYPE_PLAYER);
                ShowThreat(memberUnitId, c:GetCompactRaidThreatFrame(arg, memberUnitId), highestStatusThreatInfo,
                    highestThreatPctThreatInfo, FRAMETYPE_COMPACT_RAID);
            elseif memberUnitId == "playerpet" then
                ShowThreat(memberUnitId, c:GetPlayerPetThreatFrame(), highestStatusThreatInfo,
                    highestThreatPctThreatInfo);
            elseif memberUnitId == "target" or memberUnitId == "targettarget" then
                ShowThreat(memberUnitId, c:GetTargetTargetThreatFrame(), highestStatusThreatInfo,
                    highestThreatPctThreatInfo);
            elseif q:StartsWith(memberUnitId, "party") then
                local frame = c:GetCompactRaidThreatFrame(arg, memberUnitId);
                if frame then
                    ShowThreat(memberUnitId, frame, highestStatusThreatInfo, highestThreatPctThreatInfo,
                        FRAMETYPE_COMPACT_RAID);
                else
                    ShowThreat(memberUnitId, c:GetPartyThreatFrame(arg, memberUnitId), highestStatusThreatInfo,
                        highestThreatPctThreatInfo);
                end
            elseif q:StartsWith(memberUnitId, "raid") then
                ShowThreat(memberUnitId, c:GetCompactRaidThreatFrame(arg, memberUnitId), highestStatusThreatInfo,
                    highestThreatPctThreatInfo, FRAMETYPE_COMPACT_RAID);
            elseif q:StartsWith(memberUnitId, "nameplate") then
                ShowThreat(memberUnitId, c:GetNamePlateThreatFrame(arg), highestStatusThreatInfo,
                    highestThreatPctThreatInfo);
            end
        end
    end

    c:UpdateBarFrames(threatCache);
end

local function Reset()
    threatCache = {};
    queriesLastSecond = 0;
    c:UpdateBarFrames();
    c:HideFrames();
end

local function OnCombatEvent(event, ...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags,
        destRaidFlags = ...;
    if subevent == "UNIT_DIED" and threatCache then
        -- timer functions are neccessary because async(?) threat methods have noticable delay
        if destGUID == UnitGUID("player") then
            -- player dies
            Reset();
            C_Timer.After(2, function()
                Reset();
            end);
        elseif q:StartsWith(destGUID, "Player") then
            -- might have been a member who died
            if IsInGroup() or IsInRaid() then
                RemoveMemberFromCache(destGUID);
                UpdateThreat();
                C_Timer.After(1, function()
                    RemoveMemberFromCache(destGUID);
                    --UpdateThreat();
                end);
            end
        else
            -- enemy died: remove from cache
            RemoveEnemyFromCache(destGUID);
            UpdateThreat();
            C_Timer.After(1, function()
                RemoveEnemyFromCache(destGUID);
                --UpdateThreat();
            end);
        end
    end
end

-- command handling
SLASH_CLASSICTHREAT1 = "/classicthreat";
local CMD_RESET = "reset";
local CMD_ADDBARFRAME = "addbarframe";
local CMD_ADDFRAME = "addframe";
local CMD_TANKMODE = "tankmode";

SlashCmdList["CLASSICTHREAT"] = function(msg)
    if msg then
        if c.initFinished then
            msg = q:Trim(msg);

            if msg == CMD_RESET then
                c:ShowResetDialog();
            elseif msg == CMD_ADDBARFRAME or msg == CMD_ADDFRAME then
                c:AddBarFrame();
            elseif msg == CMD_TANKMODE then
                c:ToggleTankMode();
            else
                c:Println(q:GetText("Unknown command. Possible parameters are: /classicthreat ..."));
                c:Println(q:GetText("addframe -> Shows an additional a threat bar frame."));
                c:Println(q:GetText("tankmode -> Toggles player tank mode."));
            end
        else
            c:Println(q:GetText("The AddOn has not been initialized due to an error. Please relog and try again."));
        end
    end
end

local eventFrame;
local function HookEvents()
    if not eventFrame then
        eventFrame = q:GetEventFrame();
        eventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE");
        eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
        eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
        eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
        eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
        eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
        eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
        eventFrame:RegisterEvent("RAID_ROSTER_UPDATE");
        -- eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED");
        -- eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
        eventFrame:HookScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
            if event then
                if event == "ADDON_LOADED" and arg1 == c.name then
                    c:Init();
                elseif c.initFinished then
                    if event == "PLAYER_ENTERING_WORLD" then
                        Reset();
                    elseif event == "PLAYER_REGEN_ENABLED" then
                        Reset();
                    elseif event == "PLAYER_REGEN_DISABLED" then
                        Reset();
                    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
                        OnCombatEvent(event, CombatLogGetCurrentEventInfo());
                    elseif event == "UNIT_THREAT_LIST_UPDATE" or event == "UNIT_THREAT_SITUATION_UPDATE" then
                        if queriesLastSecond < q:MathRound(GetThreatAccuracy() / 2, 0) then
                            queriesLastSecond = queriesLastSecond + 1;
                            UpdateThreat();
                            C_Timer.After(1, function()
                                if queriesLastSecond > 0 then
                                    queriesLastSecond = queriesLastSecond - 1;
                                end
                            end);
                        end
                    elseif event == "PLAYER_TARGET_CHANGED" then
                        if QOL_OPTIONS[c.name][c.FRAME_PLAYER][c.OPT_ENABLED] then
                            ShowThreat("player", c:GetPlayerThreatFrame());
                        end
                        if QOL_OPTIONS[c.name][c.FRAME_TARGET][c.OPT_ENABLED] or
                            QOL_OPTIONS[c.name][c.FRAME_TARGET_TARGET][c.OPT_ENABLED] then
                            ShowTargetThreat();
                        end
                        c:UpdateBarFrames(c:GetThreatCache(), "player");
                        c:UpdateBarFrameTargets();
                        _G["TargetFrame"].showThreat = false; -- TEST
                    elseif event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" then
                        c:UpdateBarFrameTargets();
                    end
                end
            end
        end);

        q:AddPartyStateListener(c);
        q:AddRaidStateListener(c);
    end
end
HookEvents();

function c:OnPartyStateChange(isInParty)
    c:OnRosterStateChanged();
end

function c:OnRaidStateChange(isInRaid)
    c:OnRosterStateChanged();
end

function c:OnRosterStateChanged()
    local isInRoster = IsInRaid() or IsInGroup();
    if c:IsBarFrameAutoOpenCloseEnabled() then
        c:ToggleActiveFrames(isInRoster);
    end
end

function c:GetUnitIdForGuid(guid)
    for _, memberUnitId in pairs(GetMemberUnitIds()) do
        local memberGuid = UnitGUID(memberUnitId);
        for _, targetUnitId in ipairs(availableTargetUnitIds) do
            local combinedId = memberUnitId .. targetUnitId;
            local targetUnitGuid, combinedGuid = UnitGUID(targetUnitId), UnitGUID(combinedId);
            if memberGuid == guid then
                return memberUnitId;
            elseif combinedId == guid then
                return targetUnitId;
            elseif combinedGuid == guid then
                return combinedId;
            end
        end
    end
end

function c:targetUnitGuid(guid)
    local unitId = c:GetUnitIdForGuid(guid);
    if unitId then
        -- todo -- seucre button
        -- frame:SetAttribute("unit", "player")
        -- frame:SetAttribute("type", "target")
    end
end

function c:AddThreatListener(name, callback, notify)
    if name and callback then
        threatListeners[name] = callback;
        if notify == true then
            c:Println(q:GetText("Listener added/replaced: " .. name));
        end
    end
end

function c:RemoveThreatListener(name, notify)
    if name then
        threatListeners[name] = nil;
        if notify == true then
            c:Println(q:GetText("Listener removed: " .. name));
        end
    end
end
