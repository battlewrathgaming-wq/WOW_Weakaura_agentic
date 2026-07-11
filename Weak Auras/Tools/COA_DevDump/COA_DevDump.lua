-- COA_DevDump
-- Dumps live client data to SavedVariables so it lands in a real text file
-- on /reload or logout, since neither macros nor /devconsole expose file I/O.
--
-- Usage (in-game chat):
--   /coadump talents     -> tries the stock Blizzard talent API two ways.
--                           CONFIRMED to return 0/0 for this server's
--                           custom classes - kept only as a quick sanity
--                           check on other characters/classes if needed.
--   /coadump talentnodes -> the real talent extractor. Walks the two leaf
--                           tree views (SpecTree/ClassTree) and records
--                           every button that carries a real spellID/rank/
--                           maxRank field. Requires the talent panel open,
--                           spec tab visible. Results ACCUMULATE across
--                           calls (keyed by spellID).
--   /coadump talentframe -> generic reconnaissance dump of the talent UI
--                           (walks everything, no filtering).
--   /coadump trainer     -> NEW. Open a class trainer NPC window first.
--                           Tries the stock trainer API (GetNumTrainerServices
--                           / GetTrainerServiceInfo / GetTrainerServiceCost /
--                           GetTrainerServiceDescription) - trainers are
--                           server-driven in stock WotLK, so this may just
--                           work even for a custom class, unlike talents.
--                           Also always runs a generic widget probe of
--                           ClassTrainerFrame as a fallback/cross-check,
--                           since we don't yet know if this server
--                           overrides trainers too. Results ACCUMULATE
--                           across calls (keyed by trainer service index +
--                           NPC name), so you can capture multiple trainer
--                           NPCs across sessions.
--   /coadump frames      -> frame-stack snapshot at the current mouse
--                           position, appended to a running log.
--   /coadump probe <FrameName> [field1,field2,...]
--                        -> NEW. Generalized version of the talentframe/
--                           trainer widget-probe pattern: walks any named
--                           global frame (must exist in _G right now, e.g.
--                           "TotemFrame") recursively, reading off a given
--                           comma-separated field list (or a sensible
--                           default list if omitted) from each widget.
--                           Useful for reconnaissance on any CoA-custom
--                           frame that stashes data as plain Lua table
--                           fields, the way the talent buttons do. NOT the
--                           right tool for stock, API-backed frames (e.g.
--                           TotemFrame itself) where the real data lives
--                           behind a function call (GetTotemInfo) rather
--                           than a widget field - probing those will show
--                           structure only, same as /coadump frames does.
--                           Results ACCUMULATE across calls (a list, one
--                           entry per call, keyed by capturedAt/rootName).
--   /coadump clear       -> wipes ALL saved data (fresh start).
--
-- After running any command, type /reload (or log out) to flush
-- COA_DevDumpDB to disk at:
--   WTF/Account/<ACCOUNT>/SavedVariables/COA_DevDump.lua
-- NOTE: the bash-side tooling used to inspect this file from outside the
-- game has a known stale-cache issue on this sandbox - if a fresh capture
-- doesn't seem to show up, that's very likely just a stale read, not a
-- failed capture. Re-verify via a fresh line-offset read before assuming
-- data is missing.
--
-- Background: confirmed live in-game that GetNumTalentTabs() returns 0
-- via both the bare stock call and the APIDocumentation-documented
-- (inspect, pet) call shape - this server's custom talent system does not
-- go through the stock Blizzard talent API at all. A generic recursive
-- widget dump (`talentframe`) of the real custom frame hierarchy
-- (CoATalentFrame -> CoATalentFrameTreeView -> ...TreeViewSpecTree /
-- ...TreeViewClassTree) found the real data instead: individual talent
-- buttons carry `spellID`, `rank`, and `maxRank` as plain Lua table
-- fields. `talentnodes` targets those fields directly and has been
-- confirmed working live (80 unique spellIDs captured, cross-verified
-- 100% against Input/necromancer_talents.json).

COA_DevDumpDB = COA_DevDumpDB or {}

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[COA_DevDump]|r " .. tostring(msg))
end

-- ---------------------------------------------------------------------
-- Talent tree dump (stock API, two call shapes) - kept as a sanity check
-- ---------------------------------------------------------------------

local dumpTooltip = CreateFrame("GameTooltip", "COA_DevDumpTooltip", UIParent, "GameTooltipTemplate")

local function ScrapeTalentTooltip(tabIndex, talentIndex)
    local lines = {}
    local ok = pcall(function()
        dumpTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        dumpTooltip:SetTalent(tabIndex, talentIndex, false)
        for i = 1, dumpTooltip:NumLines() do
            local left = _G["COA_DevDumpTooltipTextLeft" .. i]
            if left then
                local text = left:GetText()
                if text and text ~= "" then
                    table.insert(lines, text)
                end
            end
        end
        dumpTooltip:Hide()
    end)
    if not ok then
        return { "(tooltip scrape failed for this talent)" }
    end
    return lines
end

local function TryNumTabs(...)
    local args = { ... }
    local ok, result = pcall(function() return GetNumTalentTabs(unpack(args)) end)
    if ok then return result end
    return nil
end

local function DumpTalents()
    local playerClass = select(2, UnitClass("player"))
    local result = {
        capturedAt = date("%Y-%m-%d %H:%M:%S"),
        playerName = UnitName("player"),
        playerClass = playerClass,
        rawAttempts = {},
        tabs = {},
    }

    local numTabsA = TryNumTabs()
    result.rawAttempts.bareCall = numTabsA

    local numTabsB = TryNumTabs(false, false)
    result.rawAttempts.inspectPetCall = numTabsB

    local numTabs = (numTabsA and numTabsA > 0 and numTabsA)
        or (numTabsB and numTabsB > 0 and numTabsB)
        or 0

    local usedInspectPet = not (numTabsA and numTabsA > 0)

    for tabIndex = 1, numTabs do
        local name, iconTexture, pointsSpent
        if usedInspectPet then
            name, iconTexture, pointsSpent = GetTalentTabInfo(tabIndex, false, false)
        else
            name, iconTexture, pointsSpent = GetTalentTabInfo(tabIndex)
        end

        local tabData = {
            index = tabIndex,
            name = name,
            pointsSpent = pointsSpent,
            talents = {},
        }

        local numTalents
        if usedInspectPet then
            numTalents = GetNumTalents(tabIndex, false, false)
        else
            numTalents = GetNumTalents(tabIndex)
        end

        for talentIndex = 1, (numTalents or 0) do
            local tName, tIcon, tier, column, currentRank, maxRank, isExceptional,
                  available, prereqTier, prereqColumn, meetsPrereq

            if usedInspectPet then
                tName, tIcon, tier, column, currentRank, maxRank, isExceptional,
                    available, prereqTier, prereqColumn, meetsPrereq =
                    GetTalentInfo(tabIndex, talentIndex, false, false, 1)
            else
                tName, tIcon, tier, column, currentRank, maxRank, isExceptional,
                    available, prereqTier, prereqColumn, meetsPrereq =
                    GetTalentInfo(tabIndex, talentIndex)
            end

            local link
            if usedInspectPet then
                link = GetTalentLink(tabIndex, talentIndex, false, false, 1)
            else
                link = GetTalentLink(tabIndex, talentIndex)
            end

            table.insert(tabData.talents, {
                index = talentIndex,
                name = tName,
                tier = tier,
                column = column,
                currentRank = currentRank,
                maxRank = maxRank,
                available = available,
                prereqTier = prereqTier,
                prereqColumn = prereqColumn,
                meetsPrereq = meetsPrereq,
                link = link,
                tooltip = ScrapeTalentTooltip(tabIndex, talentIndex),
            })
        end

        table.insert(result.tabs, tabData)
    end

    COA_DevDumpDB.talents = result
    Print(string.format(
        "bareCall=%s inspectPetCall=%s -> using %d tab(s) for %s. /reload to flush.",
        tostring(numTabsA), tostring(numTabsB), numTabs, tostring(playerClass)))
end

-- ---------------------------------------------------------------------
-- Real extractor: targeted spellID/rank/maxRank field walk (talents)
-- ---------------------------------------------------------------------

local TALENTNODE_ROOTS = {
    "CoATalentFrameTreeViewSpecTree",
    "CoATalentFrameTreeViewClassTree",
}

local function FindChildText(widget)
    local ok, result = pcall(function()
        if widget.GetRegions then
            for _, region in ipairs({ widget:GetRegions() }) do
                if region.GetText then
                    local t = region:GetText()
                    if t and t ~= "" then return t end
                end
            end
        end
        if widget.GetChildren then
            for _, child in ipairs({ widget:GetChildren() }) do
                if child.GetRegions then
                    for _, region in ipairs({ child:GetRegions() }) do
                        if region.GetText then
                            local t = region:GetText()
                            if t and t ~= "" then return t end
                        end
                    end
                end
            end
        end
        return nil
    end)
    if ok then return result end
    return nil
end

local function FindChildTexture(widget)
    local ok, result = pcall(function()
        if widget.GetNormalTexture then
            local tex = widget:GetNormalTexture()
            if tex and tex.GetTexture then
                local t = tex:GetTexture()
                if t then return t end
            end
        end
        if widget.GetRegions then
            for _, region in ipairs({ widget:GetRegions() }) do
                if region.GetTexture then
                    local t = region:GetTexture()
                    if t then return t end
                end
            end
        end
        return nil
    end)
    if ok then return result end
    return nil
end

local function WalkForTalentNodes(widget, depth, maxDepth, treeName, nodesBySpellID)
    if depth > maxDepth then return end

    pcall(function()
        local spellID = widget.spellID
        if spellID and type(spellID) == "number" and spellID > 0 then
            local left, top
            pcall(function() left = widget:GetLeft() end)
            pcall(function() top = widget:GetTop() end)

            nodesBySpellID[spellID] = {
                spellID = spellID,
                rank = widget.rank,
                currentRank = widget.currentRank,
                maxRank = widget.maxRank,
                tier = widget.tier,
                column = widget.column,
                tree = treeName,
                widgetName = widget.GetName and widget:GetName() or nil,
                left = left,
                top = top,
                name = FindChildText(widget),
                texture = FindChildTexture(widget),
            }
        end

        if widget.GetChildren then
            for _, child in ipairs({ widget:GetChildren() }) do
                WalkForTalentNodes(child, depth + 1, maxDepth, treeName, nodesBySpellID)
            end
        end
    end)
end

local function DumpTalentNodes()
    COA_DevDumpDB.talentNodes = COA_DevDumpDB.talentNodes or {}
    local nodesBySpellID = COA_DevDumpDB.talentNodes

    local found = {}
    for _, rootName in ipairs(TALENTNODE_ROOTS) do
        local root = _G[rootName]
        if root then
            table.insert(found, rootName)
            WalkForTalentNodes(root, 0, 8, rootName, nodesBySpellID)
        end
    end

    local count = 0
    for _ in pairs(nodesBySpellID) do count = count + 1 end

    if #found == 0 then
        Print("No SpecTree/ClassTree root found - is the talent panel open?")
    else
        Print("Walked " .. table.concat(found, ", ") .. " -> " .. count
            .. " unique spellID(s) captured so far (accumulated). /reload to flush.")
    end
end

-- ---------------------------------------------------------------------
-- Talent frame reconnaissance dump (generic recursive widget walker)
-- ---------------------------------------------------------------------

local TALENTFRAME_ROOTS = {
    "CoATalentFrameTreeViewSpecTree",
    "CoATalentFrameTreeViewClassTree",
    "CoATalentFrameTreeView",
    "CoATalentFrame",
}

local PROBE_FIELDS = {
    "spellID", "spellId", "id", "talentID", "talentIndex", "tabIndex",
    "rank", "currentRank", "maxRank", "abilityID", "nodeID", "tier", "column",
}

local function DescribeWidget(widget)
    local entry = {
        name = (widget.GetName and widget:GetName()) or nil,
        objectType = widget.GetObjectType and widget:GetObjectType() or "?",
    }

    pcall(function() entry.widgetID = widget:GetID() end)
    pcall(function() entry.text = widget.GetText and widget:GetText() or nil end)
    pcall(function() entry.texture = widget.GetTexture and widget:GetTexture() or nil end)

    for _, field in ipairs(PROBE_FIELDS) do
        local ok, val = pcall(function() return widget[field] end)
        if ok and val ~= nil and type(val) ~= "function" and type(val) ~= "table" then
            entry["field_" .. field] = val
        end
    end

    return entry
end

local function WalkFrameTree(widget, depth, maxDepth, out)
    if depth > maxDepth then return end

    local ok = pcall(function()
        local entry = DescribeWidget(widget)
        entry.depth = depth
        table.insert(out, entry)

        if widget.GetChildren then
            local children = { widget:GetChildren() }
            for _, child in ipairs(children) do
                WalkFrameTree(child, depth + 1, maxDepth, out)
            end
        end
        if widget.GetRegions then
            local regions = { widget:GetRegions() }
            for _, region in ipairs(regions) do
                WalkFrameTree(region, depth + 1, maxDepth, out)
            end
        end
    end)

    if not ok then
        table.insert(out, { depth = depth, name = "(error walking this widget)" })
    end
end

local function DumpTalentFrameStructure()
    local found = {}
    local out = {}

    for _, rootName in ipairs(TALENTFRAME_ROOTS) do
        local root = _G[rootName]
        if root then
            table.insert(found, rootName)
            local branch = {}
            WalkFrameTree(root, 0, 6, branch)
            out[rootName] = branch
        end
    end

    COA_DevDumpDB.talentFrameStructure = {
        capturedAt = date("%Y-%m-%d %H:%M:%S"),
        rootsFound = found,
        data = out,
    }

    if #found == 0 then
        Print("No CoATalentFrame roots found in _G - is the talent panel open right now?")
    else
        Print("Walked " .. table.concat(found, ", ") .. ". /reload to flush to disk.")
    end
end

-- ---------------------------------------------------------------------
-- Trainer dump: stock API first, generic widget probe as a fallback
-- ---------------------------------------------------------------------

local function DumpTrainerStockAPI()
    local numServices = 0
    pcall(function() numServices = GetNumTrainerServices() or 0 end)

    local services = {}
    for i = 1, numServices do
        local entry = { index = i }

        pcall(function()
            local a, b, c, d, e, f = GetTrainerServiceInfo(i)
            entry.name = a
            entry.subText = b
            entry.serviceType = c
            entry.raw4 = d
            entry.raw5 = e
            entry.raw6 = f
        end)
        pcall(function() entry.cost = GetTrainerServiceCost(i) end)
        pcall(function() entry.description = GetTrainerServiceDescription(i) end)
        pcall(function()
            local skillLine, skillRank = GetTrainerServiceSkillLine(i)
            entry.skillLine = skillLine
            entry.skillRank = skillRank
        end)
        pcall(function() entry.levelReq = GetTrainerServiceLevelReq(i) end)
        -- The stock trainer API returns NO spellID, but the tooltip does:
        -- SetTrainerService(i) then GetSpell() -> name, rank, spellID. Confirmed live
        -- 2026-07-11 (e.g. "Create Bone Reliquary" Rank 2 = 803768, "Raise: Skeletal
        -- Rogue" = 500969). Reuses the module tooltip; pcall so header rows (which raise
        -- "Invalid trainer service") just skip without an id. This is the metadata that
        -- was missing - it makes the trainer dump a spellID-keyed baseline-ability source.
        pcall(function()
            dumpTooltip:SetOwner(UIParent, "ANCHOR_NONE")
            dumpTooltip:SetTrainerService(i)
            local sName, sRank, sId = dumpTooltip:GetSpell()
            entry.spellName = sName
            entry.spellRank = sRank
            entry.spellId = sId
            dumpTooltip:Hide()
        end)

        table.insert(services, entry)
    end

    return numServices, services
end

-- Generic probe fallback, same technique as the talent node walker - in
-- case this server's trainer ALSO overrides the stock API/frame the way
-- talents do. Only probes fields, does not walk into every region/texture
-- as deeply as talentframe did, to keep this cheap and low-risk.
local TRAINER_PROBE_FIELDS = {
    "spellID", "spellId", "id", "index", "serviceIndex", "skillIndex", "cost",
}

local function WalkTrainerWidgets(widget, depth, maxDepth, out)
    if depth > maxDepth then return end

    pcall(function()
        local hasAny = false
        local entry = {
            name = widget.GetName and widget:GetName() or nil,
            objectType = widget.GetObjectType and widget:GetObjectType() or "?",
        }
        for _, field in ipairs(TRAINER_PROBE_FIELDS) do
            local ok, val = pcall(function() return widget[field] end)
            if ok and val ~= nil and type(val) ~= "function" and type(val) ~= "table" then
                entry["field_" .. field] = val
                hasAny = true
            end
        end
        pcall(function()
            local t = FindChildText(widget)
            if t then
                entry.text = t
                hasAny = true
            end
        end)
        if hasAny or (entry.name and entry.name:find("Skill")) then
            table.insert(out, entry)
        end

        if widget.GetChildren then
            for _, child in ipairs({ widget:GetChildren() }) do
                WalkTrainerWidgets(child, depth + 1, maxDepth, out)
            end
        end
    end)
end

local function DumpTrainer()
    local numServices, services = DumpTrainerStockAPI()

    local widgetProbe = {}
    local trainerFrame = _G["ClassTrainerFrame"]
    local probedRoot = false
    if trainerFrame then
        probedRoot = true
        WalkTrainerWidgets(trainerFrame, 0, 6, widgetProbe)
    end

    COA_DevDumpDB.trainer = COA_DevDumpDB.trainer or {}
    table.insert(COA_DevDumpDB.trainer, {
        capturedAt = date("%Y-%m-%d %H:%M:%S"),
        -- stamp the capture with the player's CLASS so multi-class trainer scrapes
        -- (all against the same universal "Nightmarish Book of Ascension") can be told
        -- apart at consolidation - baseline spells aren't in the talent data, so there's
        -- no way to back-derive the class after the fact.
        playerClass = select(2, UnitClass("player")),
        playerName = UnitName("player"),
        npcTarget = UnitExists("npc") and UnitName("npc") or nil,
        numServicesStockAPI = numServices,
        services = services,
        widgetProbeRan = probedRoot,
        widgetProbe = widgetProbe,
    })

    Print(string.format(
        "Trainer: stock API found %d service(s), widget probe found %d entr%s. /reload to flush.",
        numServices, #widgetProbe, (#widgetProbe == 1) and "y" or "ies"))

    if numServices == 0 and not probedRoot then
        Print("Nothing found at all - is a trainer window actually open right now?")
    end
end

-- ---------------------------------------------------------------------
-- Frame stack dump (snapshot at current cursor position)
-- ---------------------------------------------------------------------

local function DumpFrames()
    local scale = UIParent:GetEffectiveScale()
    local x, y = GetCursorPosition()
    x, y = x / scale, y / scale

    local hits = {}
    local frame = EnumerateFrames()
    while frame do
        local ok = pcall(function()
            if frame.IsVisible and frame:IsVisible() and frame.GetRect then
                local l, b, w, h = frame:GetRect()
                if l and b and w and h and x >= l and x <= l + w and y >= b and y <= b + h then
                    local parent = frame.GetParent and frame:GetParent()
                    table.insert(hits, {
                        name = (frame.GetName and frame:GetName()) or tostring(frame),
                        objectType = frame.GetObjectType and frame:GetObjectType() or "?",
                        strata = frame.GetFrameStrata and frame:GetFrameStrata() or "?",
                        level = frame.GetFrameLevel and frame:GetFrameLevel() or nil,
                        parent = parent and ((parent.GetName and parent:GetName()) or tostring(parent)) or nil,
                    })
                end
            end
        end)
        frame = EnumerateFrames(frame)
    end

    COA_DevDumpDB.frames = COA_DevDumpDB.frames or {}
    table.insert(COA_DevDumpDB.frames, {
        capturedAt = date("%Y-%m-%d %H:%M:%S"),
        cursorX = x,
        cursorY = y,
        hits = hits,
    })

    Print("Captured " .. #hits .. " frame(s) under the cursor (snapshot #"
        .. #COA_DevDumpDB.frames .. "). Type /reload to flush to disk.")
end

-- ---------------------------------------------------------------------
-- Generic named-frame field probe - parameterized version of the
-- talentframe/trainer widget-probe pattern above (same walk-and-
-- describe logic, this time taking the root frame name and field list
-- as arguments instead of hardcoding them). Reusable any time a new
-- CoA-custom frame needs the same reconnaissance treatment the talent
-- UI got, without writing a new one-off Dump<Thing> function each time.
--
-- Deliberately NOT a substitute for calling a real stock API directly
-- when one exists (e.g. GetTotemInfo for TotemFrame) - this only
-- surfaces data that's actually stored as a plain Lua table field on
-- the widget itself, which is how CoA's own custom frames (talent
-- buttons) work, but not how stock Blizzard frames are populated.
-- ---------------------------------------------------------------------

local DEFAULT_PROBE_FIELDS = {
    "spellID", "spellId", "id", "talentID", "talentIndex", "tabIndex",
    "rank", "currentRank", "maxRank", "abilityID", "nodeID", "tier", "column",
    "unit", "slot", "index", "duration", "startTime", "haveTotem",
}

local function DescribeWidgetWithFields(widget, fields)
    local entry = {
        name = (widget.GetName and widget:GetName()) or nil,
        objectType = widget.GetObjectType and widget:GetObjectType() or "?",
    }

    pcall(function() entry.widgetID = widget:GetID() end)
    pcall(function() entry.text = widget.GetText and widget:GetText() or nil end)
    pcall(function() entry.texture = widget.GetTexture and widget:GetTexture() or nil end)

    for _, field in ipairs(fields) do
        local ok, val = pcall(function() return widget[field] end)
        if ok and val ~= nil and type(val) ~= "function" and type(val) ~= "table" then
            entry["field_" .. field] = val
        end
    end

    return entry
end

local function WalkFrameTreeWithFields(widget, depth, maxDepth, out, fields)
    if depth > maxDepth then return end

    local ok = pcall(function()
        local entry = DescribeWidgetWithFields(widget, fields)
        entry.depth = depth
        table.insert(out, entry)

        if widget.GetChildren then
            local children = { widget:GetChildren() }
            for _, child in ipairs(children) do
                WalkFrameTreeWithFields(child, depth + 1, maxDepth, out, fields)
            end
        end
        if widget.GetRegions then
            local regions = { widget:GetRegions() }
            for _, region in ipairs(regions) do
                WalkFrameTreeWithFields(region, depth + 1, maxDepth, out, fields)
            end
        end
    end)

    if not ok then
        table.insert(out, { depth = depth, name = "(error walking this widget)" })
    end
end

local function ParseFieldList(csv)
    if not csv or csv:trim() == "" then
        return DEFAULT_PROBE_FIELDS
    end
    local fields = {}
    for field in csv:gmatch("[^,]+") do
        table.insert(fields, field:trim())
    end
    return fields
end

local function DumpProbe(rootName, fieldsCSV)
    if not rootName or rootName:trim() == "" then
        Print("Usage: /coadump probe <FrameName> [field1,field2,...]")
        return
    end

    local root = _G[rootName]
    if not root then
        Print("No frame named '" .. rootName .. "' found in _G right now - is it on screen/loaded?")
        return
    end

    local fields = ParseFieldList(fieldsCSV)
    local out = {}
    WalkFrameTreeWithFields(root, 0, 8, out, fields)

    COA_DevDumpDB.probes = COA_DevDumpDB.probes or {}
    table.insert(COA_DevDumpDB.probes, {
        capturedAt = date("%Y-%m-%d %H:%M:%S"),
        rootName = rootName,
        fields = fields,
        widgetCount = #out,
        data = out,
    })

    Print(string.format(
        "Probed '%s' -> %d widget(s) captured (fields: %s). /reload to flush.",
        rootName, #out, table.concat(fields, ", ")))
end

-- ---------------------------------------------------------------------
-- Spellbook dump - the LEARNED-abilities half of the ability inventory
-- (complements the trainer scrape, which lists the TRAINABLE half). The
-- spellID is recovered from GetSpellLink's |Hspell:ID| hyperlink, since
-- GetSpellName alone gives no id. Captures every tab (incl. professions/
-- general - filter offline by tabName). Stamped by class like the trainer.
-- Matters for fresh (level 1) chars: they can't yet TRAIN high-level
-- abilities, but their book already holds the starting/base-rank skills.
-- ---------------------------------------------------------------------

local function DumpSpellbook()
    local numTabs = GetNumSpellTabs() or 0
    local tabs = {}
    for tabIndex = 1, numTabs do
        local tabName, _, offset, numSpells = GetSpellTabInfo(tabIndex)
        local spells = {}
        for j = 1, (numSpells or 0) do
            local slot = (offset or 0) + j
            local entry = { slot = slot }
            pcall(function() entry.name = GetSpellName(slot, BOOKTYPE_SPELL) end)
            pcall(function()
                local link = GetSpellLink(slot, BOOKTYPE_SPELL)
                entry.link = link
                if link then entry.spellId = tonumber(link:match("spell:(%d+)")) end
            end)
            table.insert(spells, entry)
        end
        table.insert(tabs, {
            tabIndex = tabIndex, tabName = tabName,
            numSpells = numSpells, spells = spells,
        })
    end

    COA_DevDumpDB.spellbook = COA_DevDumpDB.spellbook or {}
    table.insert(COA_DevDumpDB.spellbook, {
        capturedAt = date("%Y-%m-%d %H:%M:%S"),
        playerClass = select(2, UnitClass("player")),
        playerName = UnitName("player"),
        numTabs = numTabs,
        tabs = tabs,
    })

    local total = 0
    for _, t in ipairs(tabs) do total = total + #t.spells end
    Print(string.format("Spellbook: %d tab(s), %d spell(s) for %s. /reload to flush.",
        numTabs, total, tostring(select(2, UnitClass("player")))))
end

-- ---------------------------------------------------------------------
-- Slash command
-- ---------------------------------------------------------------------

SLASH_COADEVDUMP1 = "/coadump"
SlashCmdList["COADEVDUMP"] = function(msg)
    local trimmed = (msg or ""):trim()
    local cmd, rest = trimmed:match("^(%S*)%s*(.-)$")
    cmd = (cmd or ""):lower()

    if cmd == "talents" then
        DumpTalents()
    elseif cmd == "talentnodes" then
        DumpTalentNodes()
    elseif cmd == "talentframe" then
        DumpTalentFrameStructure()
    elseif cmd == "trainer" then
        DumpTrainer()
    elseif cmd == "spellbook" then
        DumpSpellbook()
    elseif cmd == "frames" then
        DumpFrames()
    elseif cmd == "probe" then
        local rootName, fieldsCSV = rest:match("^(%S*)%s*(.-)$")
        DumpProbe(rootName, fieldsCSV)
    elseif cmd == "clear" then
        COA_DevDumpDB = {}
        Print("Cleared saved data.")
    else
        Print("Usage: /coadump talents | /coadump talentnodes | /coadump talentframe | /coadump trainer | /coadump spellbook | /coadump frames | /coadump probe <FrameName> [fields] | /coadump clear")
    end
end
