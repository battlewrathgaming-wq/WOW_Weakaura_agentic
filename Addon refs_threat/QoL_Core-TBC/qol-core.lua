qualityoflife = qualityoflife or {};
local q = qualityoflife;
q.modules = q.modules or {};
q.name = "QoL_Core-TBC";
q.version = 15; -- check for toc

q.META_LASTVERSION = "META_LASTVERSION";
q.VALUE_NONE = "NONE";

local lastPartyState, lastRaidState = IsInGroup(), IsInRaid();

-- init
local function UpdateAddon()
    if not QOL_OPTIONS[q.name][q.META_LASTVERSION] then
        QOL_OPTIONS[q.name][q.META_LASTVERSION] = 0;
    end

    if QOL_OPTIONS[q.name][q.META_LASTVERSION] < q.version then
        -- updates here

        QOL_OPTIONS[q.name][q.META_LASTVERSION] = q.version;
    end
    return true;
end
-- /run qualityoflife:DumpTable(qualityoflife:GetPartyMembers())
local function LoadModules()
    for id = 1, GetNumAddOns() do
        local name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(id);
        if q:StartsWith(name, "QoL") and q:EndsWith(name, "-TBC") and name ~= q.name then
            if reason == "DEMAND_LOADED" then
                local loaded, reason = LoadAddOn(id);
                if not loaded then
                    q:Println(q:GetText("Failed to load module \"%s\": %s", name, reason));
                end
            elseif reason == "INTERFACE_VERSION" then
                q:Println(q:GetText("Failed to load module \"%s\": %s", name, "Addon is outdated."));
            elseif reason ~= "DISABLED" then
                q:Println(q:GetText("Failed to load module \"%s\": %s", name, reason));
            end
        end
    end
end

function q:Init()
    if not q.initFailed and not q.initFinished then
        QOL_OPTIONS = QOL_OPTIONS or {};
        QOL_OPTIONS[q.name] = QOL_OPTIONS[q.name] or {};

        if UpdateAddon() and q:InitOptions() then
            q.initFinished = true;
            q:Println(q:GetText("AddOn loaded. Type /qol for help."));

            LoadModules();
            return true;
        end
    end

    q.initFailed = true;
    q:Println(q:GetText("Error: Initialization failed. Try resetting the QoL database using \"/qol reset\"."));
end

-- command handling
local function ResolveModule(moduleName)
    -- just eliminating some user typos/weirdness
    moduleName = string.upper(moduleName);
    moduleName = moduleName:gsub(" ", "");
    moduleName = moduleName:gsub("QOL_", "");
    moduleName = moduleName:gsub("QOL-", "");

    for name in pairs(q.modules) do
        if string.upper(name) == "QOL_" .. moduleName then
            return name;
        end
    end
end

SLASH_QOL1 = "/qol";
local CMD_RESET = "reset";
SlashCmdList["QOL"] = function(msg)
    if msg and (msg == CMD_RESET or q:StartsWith(msg, CMD_RESET .. " ")) then
        local moduleName = q:Trim(msg:gsub(CMD_RESET, ""));
        if moduleName and strlen(moduleName) > 0 then
            local resolvedModuleName = ResolveModule(moduleName);
            if resolvedModuleName then
                q:ShowResetDialog(resolvedModuleName);
            else
                q:Println(q:GetText("Could not resolve QoL module \"%s\".", moduleName));
            end
            return;
        end

        q:ShowResetDialog();
        return;
    end

    q:Println(q:GetText("Unknown command. Valid commands are:"));
    q:Println(q:GetText("/qol reset [optional: module name] -> resets qol or a qol module to defaults"));
end

local function CheckPartyOrRaidStateChange()
    local raidState, partyState = IsInRaid(), IsInGroup();
    if lastPartyState ~= partyState then
        q:NotifyPartyStateListeners(partyState);
    end
    if lastRaidState ~= raidState then
        q:NotifyRaidStateListeners(raidState);
    end
    lastRaidState, lastPartyState = raidState, partyState;
end

-- event handling
local eventFrame;
function q:GetEventFrame()
    if not eventFrame then
        eventFrame = CreateFrame("Frame", "QolEventFrame");
        eventFrame:RegisterEvent("CHAT_MSG_ADDON");
        eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
        eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
        eventFrame:RegisterEvent("RAID_ROSTER_UPDATE");
        eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
        eventFrame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
            if event then
                if event == "ADDON_LOADED" and arg1 == q.name then
                    q:Init();
                elseif event == "CHAT_MSG_ADDON" and q:StartsWith(arg1, "QoL") then
                    q:ProcessAddonMessage(arg1, arg2, arg3, arg4);
                elseif event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" then
                    q:ResetMemberInfo();
                    CheckPartyOrRaidStateChange();
                elseif event == "PLAYER_ENTERING_WORLD" then
                    q:ResetSpecCache();
                    -- q:ResetMemberInfo();
                    -- q:SetCrfVisible(QOL_OPTIONS[q.name][q.OPT_SHOWCRF]);
                    C_Timer.After(1000, function()
                        CheckPartyOrRaidStateChange();
                    end);
                end
            end
        end);
    end
    return eventFrame;
end
q:GetEventFrame():RegisterEvent("ADDON_LOADED");

function q:ProcessAddonMessage(addonName, message, channel, sender)
    if addonName == q.name then
        -- for future use
    elseif q.modules[addonName] and q.modules[addonName].ProcessAddonMessage then
        q.modules[addonName]:ProcessAddonMessage(message, channel, sender);
    end
end

function q:Reset(resolvedModuleName)
    local errors = false;

    if not resolvedModuleName or resolvedModuleName == q.name then
        -- qol global reset (all modules)
        QOL_OPTIONS = {};
        q:Println(q:GetText("%s has been resetted to defaults.", q.name));

        q.initFinished = false;
        q.initFailed = false;
        errors = not q:Init();

        for name, addon in pairs(q.modules) do
            if not q:ResetModule(name) then
                errors = true;
            end
        end
    else
        -- single module reset
        errors = not q:ResetModule(resolvedModuleName);
    end

    if errors then
        q:Println(q:GetText("You might need to relog in order to finish the process."));
    end
end

function q:ResetModule(resolvedModuleName)
    if resolvedModuleName and q.modules[resolvedModuleName] then
        QOL_OPTIONS[resolvedModuleName] = {};
        q:Println(q:GetText("%s has been resetted to defaults.", resolvedModuleName));

        q.modules[resolvedModuleName].initFinished = false;
        q.modules[resolvedModuleName].initFailed = false;
        return q.modules[resolvedModuleName]:Init();
    end
end

function q:ShowResetDialog(moduleName)
    StaticPopupDialogs["QOL_DIALOG_RESET"] = StaticPopupDialogs["QOL_DIALOG_RESET"] or {
        text = q:GetText("This will reset %s to defaults.\n\nAre you sure?", "%s"),
        button1 = q:GetText("Reset"),
        button2 = q:GetText("Cancel"),
        OnEscapePressed = function()
            self:Hide();
        end,
        OnAccept = function(self, data)
            q:Reset(data);
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    };

    moduleName = moduleName or q.name;
    local dialog = StaticPopup_Show("QOL_DIALOG_RESET", moduleName);
    if dialog then
        dialog.data = moduleName;
    end
end

-- core functions
function q:SetCrfVisible(value)
    if _G["CompactRaidFrameContainer"] and _G["CompactRaidFrameContainer"]:IsVisible() ~= value then
        if value then
            _G["CompactRaidFrameContainer"]:Show();
        else
            _G["CompactRaidFrameContainer"]:Hide();
        end
    end
end

function q:IsClassic()
    return WOW_PROJECT_CLASSIC and WOW_PROJECT_ID == WOW_PROJECT_CLASSIC;
end

function q:IsTbcClassic()
    return WOW_PROJECT_BURNING_CRUSADE_CLASSIC and WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC;
end

function q:IsWotlkClassic()
    -- ProjectId to be defined by Blizzard
    return q:IsTbcClassic();
end

function q:GetHomeLatency(addFixed)
    -- Home sends/receives data about your chat, guild info, item tooltips, auction house.
    -- from blue post https://us.forums.blizzard.com/en/wow/t/question-world-vs-home-latency/820575/5
    local down, up, lagHome, lagWorld = GetNetStats();
    addFixed = addFixed or 0;
    return lagHome + addFixed;
end

function q:GetWorldLatency(addFixed)
    -- World sends/receives data about your spells, abilities, character/NPC movement, combat mechanics.
    -- from blue post https://us.forums.blizzard.com/en/wow/t/question-world-vs-home-latency/820575/5
    local down, up, lagHome, lagWorld = GetNetStats();
    addFixed = addFixed or 0;
    return lagWorld + addFixed;
end

function q:GetLatency(addFixed)
    local homeLatency, worldLatency = q:GetHomeLatency(addFixed), q:GetWorldLatency(addFixed);
    if homeLatency > worldLatency then
        return homeLatency;
    else
        return worldLatency;
    end
end
