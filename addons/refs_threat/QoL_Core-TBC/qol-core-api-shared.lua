qualityoflife = qualityoflife or {};
local q = qualityoflife;

local oldPartyMembers, oldRaidMembers;
local lastJoinedMember, lastLeftMember;

local currentMembers, currentMemberRoles;
function q:GetCurrentMembers()
    if not currentMembers then
		currentMembers, currentMemberRoles = {}, {};
		if IsInRaid() then
			for i = 1, 40 do
				local unitId = "raid" .. i;
				local unitName, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
				--local unitName = UnitName(unitId);
				if unitName then
					currentMembers[unitName] = unitId;

					-- role
					if role then
						currentMemberRoles[unitName] = role:upper();
					end
				end
			end
		elseif IsInGroup() then
			for i = 1, 5 do
				local unitId = "party" .. i;
				local unitName = UnitName(unitId);
				if unitName then
					currentMembers[unitName] = unitId;
				end
			end
        end
		currentMembers[UnitName("player")] = "player";
    end
    return currentMembers;
end

local currentMemberNamesAlphabetically;
function q:GetCurrentMemberNamesAlphabetically()
	if not currentMemberNamesAlphabetically then
		currentMemberNamesAlphabetically = {};
		for unitName, unitId in pairs(q:GetCurrentMembers()) do
			table.insert(currentMemberNamesAlphabetically, unitName);
		end
		table.sort(currentMemberNamesAlphabetically);
	end
	return currentMemberNamesAlphabetically;
end

function q:GetUnitRole(unitName)
	q:GetCurrentMembers(); -- make sure cache is there
	return currentMemberRoles[unitName];
end

function q:GetRealmName()
	if not q.realmName then
		q.realmName = GetRealmName();
	end
	return q.realmName;
end

function q:GetPlayerName()
	return q:GetCharName();
end

function q:GetCharName()
	if not q.playerName then
		q.playerName = GetUnitName("player");
	end
	return q.playerName;
end

local partyMembers;
function q:GetPartyMembers()
	if not partyMembers then
		partyMembers = {};
		for i = 1, 5 do
			local playerName = UnitName('party' .. i);
			if playerName then
				partyMembers[i] = playerName;
			end
		end
	end
	return partyMembers;
end

local raidMembers;
function q:GetRaidMembers()
	if not raidMembers then
		raidMembers, currentMemberRoles = { [0] = {} }, {};
		local noRaidMembers = GetNumGroupMembers();

		if noRaidMembers then
			for n = 1, noRaidMembers do
				local unitName, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(n);

				-- table of all raid members by id
				raidMembers[0][n] = unitName;

				-- table of all raid members, mapped by subgroups
				if not raidMembers[subgroup] then
					raidMembers[subgroup] = {};
				end
				local subGroupId = table.getn(raidMembers[subgroup]) + 1;
				raidMembers[subgroup][subGroupId] = unitName;

				-- role
				if role then
					currentMemberRoles[unitName] = role:upper();
				end

				n = n + 1;
			end
		end
	end
	return raidMembers;
end

-- /run qualityoflife:DumpCurrentMembers()
function q:DumpCurrentMembers()
	for unitName, unitId in pairs(q:GetCurrentMembers()) do
		print(unitName, unitId);
	end
end

function q:GetUnitIdByName(unitName)
	if UnitExists("target") and UnitName("target") == unitName then
		return "target";
	else
		for id, name in pairs(q:GetCurrentMembers()) do
			if name == unitName then
				return id;
			end
		end
	end
end

function q:ResetMemberInfo()
	oldPartyMembers, oldRaidMembers = q:Deepcopy(q:GetPartyMembers()), q:Deepcopy(q:GetRaidMembers());
	partyMembers, raidMembers = nil, nil;
	lastJoinedMember, lastLeftMember = nil, nil;
	currentMembers, currentMemberRoles = nil, nil;
	currentMemberNamesAlphabetically = nil;
	q:ResetRaidFrameInfo();
end

function q:GetLastJoinedMember()
	if not lastJoinedMember then
		if table.getn(oldPartyMembers) < table.getn(q:GetPartyMembers()) then
			-- party member joined
			for id, name in ipairs(q:GetPartyMembers()) do
				if not q:TableContains(oldPartyMembers, name) then
					lastJoinedMember = name;
					return;
				end
			end
		elseif table.getn(oldRaidMembers[0]) < table.getn(q:GetRaidMembers()[0]) then
			-- raid member joined
			for id, name in ipairs(q:GetRaidMembers()[0]) do
				if not q:TableContains(oldRaidMembers[0], name) then
					lastJoinedMember = name;
					return;
				end
			end
		end
	end
	return lastJoinedMember;
end

function q:GetLastLeftMember()
	if not lastLeftMember then
		if table.getn(oldPartyMembers) > table.getn(q:GetPartyMembers()) then
			-- party member left
			for id, name in ipairs(oldPartyMembers) do
				if not q:TableContains(q:GetPartyMembers(), name) then
					lastLeftMember = name;
					return;
				end
			end
		elseif table.getn(oldRaidMembers[0]) > table.getn(q:GetRaidMembers()[0]) then
			-- raid member left
			for id, name in ipairs(oldRaidMembers[0]) do
				if not q:TableContains(q:GetRaidMembers()[0], name) then
					lastLeftMember = name;
					return;
				end
			end
		end
	end
	return lastLeftMember;
end

local partyStateListeners = {};
local raidStateListeners = {};

function q:AddPartyStateListener(listener)
	tinsert(partyStateListeners, listener);
end

function q:AddRaidStateListener(listener)
	tinsert(raidStateListeners, listener);
end

function q:NotifyPartyStateListeners(value)
	for _, listener in ipairs(partyStateListeners) do
		listener:OnPartyStateChange(value);
	end
end

function q:NotifyRaidStateListeners(value)
	for _, listener in ipairs(raidStateListeners) do
		listener:OnRaidStateChange(value);
	end
end

function q:GetBattleNetTag()
	if BNConnected() then
		local presenceID, toonID, currentBroadcast, bnetAFK, bnetDND = BNGetInfo();
		return toonID;
	end
end

function q:SendAddonMessage(addon, message, channel, target)
	addon = addon or q;
	C_ChatInfo.SendAddonMessage(addon.name, message, channel, target);
end

-- /run qualityoflife:DumpTable(qualityoflife:GetVisibleNamePlates())
function q:GetVisibleNamePlates()
	local namePlates = {}
	for n = 1, 80 do
		local namePlate = _G["NamePlate" .. n];
		if namePlate and namePlate:IsVisible() and namePlate.UnitFrame and UnitIsPlayer(namePlate.UnitFrame.unit) then
			namePlates[namePlate.UnitFrame.unit] = namePlate;
		end
	end
	return namePlates;
end

function q:GetPlayerNamePlate(playerName)
	for n = 1, 80 do
		local namePlate = _G["NamePlate" .. n];
		if namePlate and namePlate:IsVisible() and namePlate.UnitFrame and UnitIsPlayer(namePlate.UnitFrame.unit) then
			if UnitName(namePlate.UnitFrame.unit) == playerName then
				return namePlate;
			end
		end
	end
end

local raidFrameInfo, RAIDFRAME_HEIGHT_FULL, RAIDFRAME_HEIGHT_HALF;
function q:GetRaidFrameInfo()
    if not raidFrameInfo then
        raidFrameInfo = {};

        local function AddFrame(frame, frameName)
            local frameHeight = q:MathRound(frame:GetHeight());
            if not RAIDFRAME_HEIGHT_FULL then
                RAIDFRAME_HEIGHT_FULL = frameHeight;
                RAIDFRAME_HEIGHT_HALF = frameHeight;
            elseif frameHeight < RAIDFRAME_HEIGHT_FULL then
                RAIDFRAME_HEIGHT_HALF = frameHeight;
            elseif frameHeight > RAIDFRAME_HEIGHT_FULL then
                RAIDFRAME_HEIGHT_FULL = frameHeight;
            end

            local targetName = _G[frameName .. "Name"]:GetText();
            if targetName then
                if not raidFrameInfo[targetName] then
                    raidFrameInfo[targetName] = {};
                end
                raidFrameInfo[targetName][frameHeight] = frame;
            end
        end

        for n = 1, 10 do -- pets increase the number of frames (not confirmed)
            local compactPartyFrameName = "CompactPartyFrameMember" .. n;
            local compactPartyFrame = _G[compactPartyFrameName];
            if compactPartyFrame and compactPartyFrame:IsVisible() and
                _G[compactPartyFrameName .. "Name"] then
                AddFrame(compactPartyFrame, compactPartyFrameName);
            end
        end

        for n = 1, 80 do -- pets increase the number of frames
            local compactRaidFrameName = "CompactRaidFrame" .. n;
            local compactRaidFrame = _G[compactRaidFrameName];
            if compactRaidFrame and compactRaidFrame:IsVisible() and
                _G[compactRaidFrameName .. "Name"] then
                AddFrame(compactRaidFrame, compactRaidFrameName);
            end
        end

        for groupId = 1, 8 do
            for subId = 1, 5 do
                local compactRaidGroupFrameName =
                    "CompactRaidGroup" .. groupId .. "Member" .. subId;
                local compactRaidGroupFrame = _G[compactRaidGroupFrameName];
                if compactRaidGroupFrame and compactRaidGroupFrame:IsVisible() and
                    _G[compactRaidGroupFrameName .. "Name"] then
                    AddFrame(compactRaidGroupFrame, compactRaidGroupFrameName);
                end
            end
        end
    end
    -- q:DumpTable(raidFrameInfo)
    return raidFrameInfo;
end

function q:GetRaidFrameHeight_Full()
	return RAIDFRAME_HEIGHT_FULL;
end

function q:GetRaidFrameHeight_Half()
	return RAIDFRAME_HEIGHT_HALF;
end

function q:ResetRaidFrameInfo()
	raidFrameInfo, RAIDFRAME_HEIGHT_FULL, RAIDFRAME_HEIGHT_HALF = nil, nil, nil;
end

local specNames = {
	DRUID = {
		[1] = "Balance",
		[2] = "Feral Combat",
		[3] = "Restoration"
	},
	HUNTER = {
		[1] = "Beast Mastery",
		[2] = "Marksmanship",
		[3] = "Survival"
	},
	MAGE = {
		[1] = "Arcane",
		[2] = "Fire",
		[3] = "Frost"
	},
	PALADIN = {
		[1] = "Holy",
		[2] = "Protection",
		[3] = "Retribution"
	},
	PRIEST = {
		[1] = "Discipline",
		[2] = "Holy",
		[3] = "Shadow"
	},
	ROGUE = {
		[1] = "Assassination",
		[2] = "Combat",
		[3] = "Subtlety"
	},
	SHAMAN = {
		[1] = "Elemental",
		[2] = "Enhancement",
		[3] = "Restoration"
	},
	WARLOCK = {
		[1] = "Affliction",
		[2] = "Demonology",
		[3] = "Destruction"
	},
	WARRIOR = {
		[1] = "Arms",
		[2] = "Fury",
		[3] = "Protection"
	}
};

local specCache = {};
function q:ResetSpecCache()
	specCache = {};
end

--- Returns the main spec of the given unitId (most points spent).
---@param unitId string
---@return string
function q:GetUnitMainSpec(unitId)
	unitId = unitId or "player";
	if unitId and UnitExists(unitId) and UnitIsPlayer(unitId) then
		local unitClass = select(2, UnitClass(unitId));
		if unitClass and specNames[unitClass] then
			local cacheEntry = specCache[unitId];
			if not cacheEntry then
				-- check talents
				local talentsByTree = {};
				for tabIndex, specName in pairs(specNames[unitClass]) do
					talentsByTree[specName] = 0;
					for talentIndex = 1, 100 do
						local name, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tabIndex, talentIndex, unitId);
						if name then
							talentsByTree[specName] = talentsByTree[specName] + currentRank;
						else
							break;
						end
					end
				end

				-- find top tabIndex (main spec)
				local topPoints, topSpec;
				for tabIndex, specName in pairs(specNames[unitClass]) do
					local treePoints = talentsByTree[specName];
					if not topPoints or topPoints < treePoints then
						topPoints = treePoints;
						topSpec = specName;
					end
				end

				cacheEntry = {};
				cacheEntry.topSpec = topSpec;
				cacheEntry.talentsByTree = talentsByTree;
				specCache[unitId] = cacheEntry;
			end

			-- return spec
			return cacheEntry.topSpec, q:GetText(cacheEntry.topSpec), cacheEntry.talentsByTree;
		end
	end
end