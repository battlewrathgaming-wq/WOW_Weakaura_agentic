-- Inspect Build → Necromancer Class + Animation/Death/Rime tree stencil.
-- Uses C_CharacterAdvancement.GetInspectedBuild(unit, spec) → { EntryId, Rank, Locked }.
-- Necromancer only (class file NECROMANCER / classId 25).
Mancer.InspectTreeModule = {}
local InspectTree = Mancer.InspectTreeModule

-- Match CoA SpecTree buttonWidth/Height + spacing (CoATalentFrame.xml).
-- Rings hug the 30px icons (atlas native is 50; CoA forces smaller on the button).
local BUTTON_W = 30
local BUTTON_H = 30
local RING_SIZE = 34
local SHADOW_SIZE = 36
local SPACING_X = 14
local SPACING_Y = 14
local NECRO_CLASS_ID = 25
local NODE_YELLOW = "talents-node-circle-yellow"
local NODE_GRAY = "talents-node-circle-gray"
local NODE_SHADOW = "talents-node-circle-shadow"
local NODE_MASK = "Interface\\TalentFrame\\TalentsMaskNodeCircle"
local NODE_SHEET = "Interface\\TalentFrame\\talents"
local LINE_TEX = "Interface\\Buttons\\WHITE8X8"
local ARROW_HEAD = "Interface\\TalentFrame\\talents-arrow-head-yellow"
-- Gold connectors (taken path) / dim (not both taken) — CoA path gold.
local LINK_GOLD = { 0.65, 0.54, 0.06, 1 }
local LINK_DIM = { 0.28, 0.28, 0.30, 0.70 }

-- Necromancer specialization trees (right pane). Inspect Spec N is a loadout slot;
-- each loadout maps onto one of these CA tabs.
local NECRO_SPECS = {
    { key = "Animation", file = "ANIMATION", label = "ANIMATION" },
    { key = "Death", file = "DEATH", label = "DEATH" },
    { key = "Rime", file = "RIME", label = "RIME" },
}

local function L(key, fallback)
    local loc = Mancer.L
    if loc and loc[key] then
        return loc[key]
    end
    return fallback
end

local function Notify(msg)
    if Mancer.Print then
        Mancer.Print(msg)
    elseif Mancer.Hub and Mancer.Hub.Notify then
        Mancer.Hub:Notify(msg)
    else
        print("|cff7fd4ff" .. (Mancer.DISPLAY_NAME or "Libellus Leti") .. "|r " .. tostring(msg))
    end
end

local function IsNecromancerUnit(unit)
    if not unit or not UnitExists(unit) then
        return false
    end
    local _, classFile, classId = UnitClass(unit)
    if classId and tonumber(classId) == NECRO_CLASS_ID then
        return true
    end
    if classFile then
        local upper = string.upper(tostring(classFile))
        if upper == "NECROMANCER" or upper:find("NECRO", 1, true) then
            return true
        end
    end
    return false
end

local function GetInspectUnit()
    if InspectFrame and InspectFrame.unit and UnitExists(InspectFrame.unit) then
        return InspectFrame.unit
    end
    if UnitExists("target") and UnitIsPlayer("target") then
        return "target"
    end
    return nil
end

function InspectTree:GetPreferredSpecIndex(unit)
    unit = unit or GetInspectUnit()
    local CA = C_CharacterAdvancement
    if unit and CA and CA.GetInspectInfo then
        local ok, a = pcall(CA.GetInspectInfo, unit)
        if ok and type(a) == "number" and a >= 1 and a <= 10 then
            return a
        end
    end
    return self.specIndex or 1
end

function InspectTree:CollectRankMap(unit, specIndex)
    local map = {}
    local CA = C_CharacterAdvancement
    if not CA or not CA.GetInspectedBuild or not unit then
        return map
    end
    if CA.InspectUnit then
        pcall(CA.InspectUnit, unit)
    end
    specIndex = tonumber(specIndex) or self:GetPreferredSpecIndex(unit)
    local ok, build = pcall(CA.GetInspectedBuild, unit, specIndex)
    if not ok or type(build) ~= "table" then
        return map
    end
    for _, row in pairs(build) do
        if type(row) == "table" then
            local id = tonumber(row.EntryId or row.entryId or row.ID or row.id)
            local rank = tonumber(row.Rank or row.rank) or 0
            if id and rank > 0 then
                map[id] = math.max(map[id] or 0, rank)
            end
        end
    end
    return map, specIndex
end

local function ResolveEntry(entryId)
    local CA = C_CharacterAdvancement
    if not CA then
        return nil
    end
    if CA.GetEntryByInternalID then
        local ok, entry = pcall(CA.GetEntryByInternalID, entryId)
        if ok and type(entry) == "table" then
            return entry
        end
    end
    return nil
end

local function EntrySpellIcon(entry, rank)
    if not entry then
        return "Interface\\Icons\\INV_Misc_QuestionMark", nil, "?"
    end
    local name = entry.Name or entry.name or "?"
    local spellId
    local spells = entry.Spells
    if type(spells) == "table" then
        spellId = spells[rank or 1] or spells[1]
        if type(spellId) == "table" then
            spellId = spellId.ID or spellId.id or spellId.SpellID
        end
    elseif type(spells) == "number" then
        spellId = spells
    end
    local icon
    if spellId and GetSpellInfo then
        local sn, _, tex = GetSpellInfo(spellId)
        if sn and (not name or name == "?") then
            name = sn
        end
        icon = tex
    end
    return icon or "Interface\\Icons\\INV_Misc_QuestionMark", spellId, name
end

local function EntryMaxRank(entry)
    if not entry then
        return 1
    end
    local spells = entry.Spells
    if type(spells) == "table" then
        local n = 0
        for k, v in pairs(spells) do
            if type(k) == "number" and v then
                n = math.max(n, k)
            end
        end
        if n > 0 then
            return n
        end
        -- array-style Spells
        return math.max(1, #spells)
    end
    return tonumber(entry.MaxRanks or entry.Ranks or entry.maxRank) or 1
end

local function GridXY(positionX, positionY)
    if GridLayoutUtil and GridLayoutUtil.SimpleGridXY then
        return GridLayoutUtil.SimpleGridXY(positionX, positionY, BUTTON_W, BUTTON_H, 0, 0, SPACING_X, SPACING_Y)
    end
    local x = (tonumber(positionX) or 0) * (BUTTON_W + SPACING_X)
    local y = -((tonumber(positionY) or 0) * (BUTTON_H + SPACING_Y))
    return x, y
end

local function GetEntryPos(entry)
    if not entry then
        return 0, 0
    end
    -- Prefer DBC PositionX/Y (same fields CoA BuildTree feeds SimpleGridXY).
    local px = tonumber(entry.PositionX)
    local py = tonumber(entry.PositionY)
    if px and py then
        return px, py
    end
    if CharacterAdvancementUtil and CharacterAdvancementUtil.GetEntryPosition then
        local ok, x, y = pcall(CharacterAdvancementUtil.GetEntryPosition, entry)
        if ok then
            return tonumber(x) or 0, tonumber(y) or 0
        end
    end
    return tonumber(entry.Column) or 0, tonumber(entry.Row) or 0
end

-- Drop Class left + Animation right SpecTree passive rails (same freebies every Necro).
local function FilterOutPassiveRail(entries)
    if not entries or #entries == 0 then
        return entries or {}
    end
    local uniq, seen = {}, {}
    for i = 1, #entries do
        local px = GetEntryPos(entries[i])
        if not seen[px] then
            seen[px] = true
            uniq[#uniq + 1] = px
        end
    end
    table.sort(uniq)
    if #uniq < 4 then
        return entries
    end

    local minX, maxX = uniq[1], uniq[#uniq]
    -- Left rail: 1–3 columns then a big gap into the main tree.
    for i = 2, #uniq do
        local g = uniq[i] - uniq[i - 1]
        local leftCols = i - 1
        if g >= 2 and leftCols <= 3 and leftCols < (#uniq - leftCols) then
            minX = uniq[i]
            break
        end
    end
    -- Right rail: big gap then 1–3 trailing columns.
    for i = #uniq, 2, -1 do
        local g = uniq[i] - uniq[i - 1]
        local rightCols = #uniq - i + 1
        if g >= 2 and rightCols <= 3 and rightCols < (i - 1) then
            maxX = uniq[i - 1]
            break
        end
    end

    if minX == uniq[1] and maxX == uniq[#uniq] then
        return entries
    end
    local out = {}
    for i = 1, #entries do
        local px = GetEntryPos(entries[i])
        if px >= minX and px <= maxX then
            out[#out + 1] = entries[i]
        end
    end
    if #out >= 8 then
        return out
    end
    return entries
end

local function ForceTexSize(tex, w, h)
    if not tex then
        return
    end
    if Mancer.UI and Mancer.UI.ForceTextureSize then
        Mancer.UI.ForceTextureSize(tex, w, h)
        return
    end
    if tex.SetWidth then
        tex:SetWidth(w)
    end
    if tex.SetHeight then
        tex:SetHeight(h)
    end
    if tex.SetSize then
        tex:SetSize(w, h)
    end
end

local function SetCircleAtlas(tex, atlasName, size)
    if not tex then
        return
    end
    ForceTexSize(tex, size, size)
    local ok = false
    if tex.SetAtlas then
        local ignore = Const and Const.TextureKit and Const.TextureKit.IgnoreAtlasSize
        if ignore == nil then
            ignore = false
        end
        ok = pcall(function()
            tex:SetAtlas(atlasName, ignore)
        end)
        if ok and tex.GetTexture and not tex:GetTexture() then
            ok = false
        end
    end
    if not ok then
        tex:SetTexture(NODE_SHEET)
    end
    ForceTexSize(tex, size, size)
    if tex.SetBlendMode then
        tex:SetBlendMode("BLEND")
    end
end

local function ApplyCircleIcon(tex, iconPath)
    if not tex or not iconPath then
        return
    end
    local applied = false
    if tex.SetMaskedTexture then
        applied = pcall(function()
            tex:SetMaskedTexture(iconPath, NODE_MASK)
        end)
    end
    if not applied then
        tex:SetTexture(iconPath)
        if tex.SetMask then
            pcall(function()
                tex:SetMask(NODE_MASK)
            end)
        end
    end
end

local function NecroClassDBC()
    if CharacterAdvancementUtil and CharacterAdvancementUtil.GetClassDBCByFile then
        return CharacterAdvancementUtil.GetClassDBCByFile("NECROMANCER") or "Necromancer"
    end
    return "Necromancer"
end

local function SpecDBCFromFile(specFile)
    if CharacterAdvancementUtil and CharacterAdvancementUtil.GetSpecDBCByFile then
        return CharacterAdvancementUtil.GetSpecDBCByFile(specFile) or specFile
    end
    -- ANIMATION → Animation
    return tostring(specFile or ""):sub(1, 1) .. string.lower(tostring(specFile or ""):sub(2))
end

local function FindSpecDef(keyOrFile)
    local want = string.upper(tostring(keyOrFile or ""))
    for _, spec in ipairs(NECRO_SPECS) do
        if string.upper(spec.key) == want or spec.file == want or string.upper(spec.label) == want then
            return spec
        end
    end
    return NECRO_SPECS[1]
end

local function SpecBackgroundAtlas(specFile)
    local file = string.lower(tostring(specFile or "animation"))
    local atlas = "talents-background-necromancer-" .. file
    if CharacterAdvancementUtil and CharacterAdvancementUtil.GetBackgroundAtlas then
        local ok, a = pcall(CharacterAdvancementUtil.GetBackgroundAtlas, "Necromancer", file)
        if ok and a and a ~= "" then
            atlas = a
        end
    end
    return atlas
end

-- Sum ranks on a CA tab via entry list membership (fallback).
local function CountPointsOnTab(rankMap, tabDbc)
    local CA = C_CharacterAdvancement
    if not CA or not CA.GetEntriesByClass or not rankMap then
        return 0
    end
    local ok, entries = pcall(CA.GetEntriesByClass, NecroClassDBC(), tabDbc, false)
    if not ok or type(entries) ~= "table" then
        return 0
    end
    local pts = 0
    local function add(entry)
        if type(entry) ~= "table" then
            return
        end
        local id = tonumber(entry.ID or entry.id)
        if id and rankMap[id] then
            pts = pts + (tonumber(rankMap[id]) or 0)
        end
    end
    if entries[1] then
        for i = 1, #entries do
            add(entries[i])
        end
    else
        for _, entry in pairs(entries) do
            add(entry)
        end
    end
    return pts
end

-- Prefer entry.Tab from each inspected talent (CLASS / ANIMATION / DEATH / RIME).
function InspectTree:DetectBestSpecTab(rankMap)
    local scores = {}
    for _, spec in ipairs(NECRO_SPECS) do
        scores[spec.key] = 0
    end
    local scored = 0
    for id, rank in pairs(rankMap or {}) do
        rank = tonumber(rank) or 0
        if rank > 0 then
            local entry = ResolveEntry(tonumber(id) or id)
            local tab = entry and string.upper(tostring(entry.Tab or entry.tab or entry.Spec or "")) or ""
            if tab == "CLASS" or tab == "" then
                -- Class tree points do not decide Animation vs Death vs Rime.
            else
                local matched = false
                for _, spec in ipairs(NECRO_SPECS) do
                    if tab == spec.file or tab == string.upper(spec.key) then
                        scores[spec.key] = scores[spec.key] + rank
                        scored = scored + rank
                        matched = true
                        break
                    end
                end
                if not matched then
                    -- Unknown tab string — try membership fallback per entry once.
                    for _, spec in ipairs(NECRO_SPECS) do
                        local dbc = SpecDBCFromFile(spec.file)
                        if CountPointsOnTab({ [tonumber(id)] = rank }, dbc) > 0 then
                            scores[spec.key] = scores[spec.key] + rank
                            scored = scored + rank
                            break
                        end
                    end
                end
            end
        end
    end

    -- If Tab fields were missing, fall back to full-tab membership counts.
    if scored <= 0 then
        for _, spec in ipairs(NECRO_SPECS) do
            scores[spec.key] = CountPointsOnTab(rankMap, SpecDBCFromFile(spec.file))
        end
    end

    local best = NECRO_SPECS[1]
    local bestPts = -1
    for _, spec in ipairs(NECRO_SPECS) do
        local pts = scores[spec.key] or 0
        if pts > bestPts then
            bestPts = pts
            best = spec
        end
    end
    return best, bestPts, scores
end

local function SyncTreeBuild(tree, classDBC, tab)
    if not tree then
        return false
    end
    tree.class = classDBC
    tree.tab = tab
    if tree.InvalidateCache then
        pcall(function()
            tree:InvalidateCache()
        end)
    elseif tree.BuildTree then
        pcall(function()
            tree:BuildTree()
        end)
    else
        return false
    end
    -- Drain OnUpdate dirty queue (gates + connections) synchronously.
    local guard = 0
    while tree.dirty and next(tree.dirty) and guard < 12 do
        guard = guard + 1
        if tree.Update then
            pcall(function()
                tree:Update()
            end)
        else
            break
        end
    end
    return true
end

local FilterOutPassiveRailRows

-- Visible CoA nodes only (choice parents + ungrouped singles) — exact live positions.
local function HarvestTreeLayout(tree)
    if not tree or not tree.EnumerateNodes then
        return nil
    end
    local rows = {}
    local byId = {}
    for node in tree:EnumerateNodes() do
        if node and node.IsShown and node:IsShown() then
            local isChoice = node.IsChoiceNode and node:IsChoiceNode()
            local grouped = false
            if (not isChoice) and node.entry and tree.IsGroupedEntry then
                grouped = tree:IsGroupedEntry(node.entry)
            end
            if isChoice or (node.entry and not grouped) then
                local x = tonumber(node.positionX)
                local y = tonumber(node.positionY)
                if (not x or not y) and node.GetLeft and tree.GetLeft then
                    -- Fallback: pixel delta vs tree TOPLEFT.
                    x = node:GetLeft() - tree:GetLeft()
                    y = node:GetTop() - tree:GetTop()
                end
                if x and y then
                    local entryIds = {}
                    local entry = node.entry
                    local conns = {}
                    if isChoice and type(node.nodes) == "table" then
                        for _, sub in ipairs(node.nodes) do
                            if sub and sub.entry then
                                local sid = tonumber(sub.entry.ID or sub.entry.id)
                                if sid then
                                    entryIds[#entryIds + 1] = sid
                                    byId[sid] = true
                                end
                                if not entry then
                                    entry = sub.entry
                                end
                                local sc = sub.entry.ConnectedNodes
                                if type(sc) == "table" then
                                    for _, destId in pairs(sc) do
                                        destId = tonumber(destId)
                                        if destId then
                                            conns[#conns + 1] = destId
                                        end
                                    end
                                end
                            end
                        end
                    elseif entry then
                        local id = tonumber(entry.ID or entry.id)
                        if id then
                            entryIds[1] = id
                            byId[id] = true
                        end
                        local sc = entry.ConnectedNodes
                        if type(sc) == "table" then
                            for _, destId in pairs(sc) do
                                destId = tonumber(destId)
                                if destId then
                                    conns[#conns + 1] = destId
                                end
                            end
                        end
                    end
                    if entry and #entryIds > 0 then
                        rows[#rows + 1] = {
                            x = x,
                            y = y,
                            entry = entry,
                            entryIds = entryIds,
                            conns = conns,
                            id = entryIds[1],
                        }
                    end
                end
            end
        end
    end
    if #rows < 4 then
        return nil
    end
    -- Resolve destination IDs that land on a choice parent (any sub id).
    local idToRow = {}
    for _, row in ipairs(rows) do
        for _, eid in ipairs(row.entryIds) do
            idToRow[eid] = row
        end
    end
    for _, row in ipairs(rows) do
        local resolved = {}
        for _, destId in ipairs(row.conns) do
            local dest = idToRow[destId]
            if dest and dest ~= row then
                resolved[#resolved + 1] = dest
            end
        end
        row.destRows = resolved
    end
    return FilterOutPassiveRailRows(rows)
end

-- Passive-rail filter for harvested layout rows (uses .x pixel or .px grid).
FilterOutPassiveRailRows = function(rows)
    if not rows or #rows == 0 then
        return rows or {}
    end
    local uniq, seen = {}, {}
    for i = 1, #rows do
        local px = rows[i].px or rows[i].x
        if px and not seen[px] then
            seen[px] = true
            uniq[#uniq + 1] = px
        end
    end
    table.sort(uniq)
    if #uniq < 4 then
        return rows
    end
    local minX, maxX = uniq[1], uniq[#uniq]
    for i = 2, #uniq do
        local g = uniq[i] - uniq[i - 1]
        local leftCols = i - 1
        if g >= (BUTTON_W + SPACING_X) * 0.75 and leftCols <= 3 and leftCols < (#uniq - leftCols) then
            minX = uniq[i]
            break
        elseif g >= 2 and g < (BUTTON_W) and leftCols <= 3 and leftCols < (#uniq - leftCols) then
            -- Grid units (fallback enum) — gap measured in position cells.
            minX = uniq[i]
            break
        end
    end
    for i = #uniq, 2, -1 do
        local g = uniq[i] - uniq[i - 1]
        local rightCols = #uniq - i + 1
        if g >= (BUTTON_W + SPACING_X) * 0.75 and rightCols <= 3 and rightCols < (i - 1) then
            maxX = uniq[i - 1]
            break
        elseif g >= 2 and rightCols <= 3 and rightCols < (i - 1) then
            maxX = uniq[i - 1]
            break
        end
    end
    if minX == uniq[1] and maxX == uniq[#uniq] then
        return rows
    end
    local out = {}
    for i = 1, #rows do
        local px = rows[i].px or rows[i].x
        if px >= minX and px <= maxX then
            out[#out + 1] = rows[i]
        end
    end
    if #out >= 8 then
        return out
    end
    return rows
end

function InspectTree:HarvestLiveLayouts(specKey)
    self.layoutCache = self.layoutCache or {}
    local spec = FindSpecDef(specKey or self.activeSpecTab or "Animation")
    local specDbc = SpecDBCFromFile(spec.file)
    local cacheKey = spec.key

    if self.layoutCache.class and self.layoutCache[cacheKey] then
        return self.layoutCache.class, self.layoutCache[cacheKey]
    end

    if not IsAddOnLoaded("Ascension_CoATalents") then
        pcall(LoadAddOn, "Ascension_CoATalents")
    end
    local frame = CoATalentFrame
    if not frame or not frame.TreeView then
        return nil, nil
    end
    local tv = frame.TreeView
    local classTree, specTree = tv.ClassTree, tv.SpecTree
    if not classTree or not specTree then
        return nil, nil
    end

    local necro = NecroClassDBC()
    local savedClassC, savedTabC = classTree:GetClassTab()
    local savedClassS, savedTabS = specTree:GetClassTab()
    local savedSpecID = tv.specID
    local wasShown = frame:IsShown()
    local oldAlpha = frame:GetAlpha() or 1
    local p1, p2, p3, p4, p5 = frame:GetPoint(1)

    local function restoreCoA()
        if savedSpecID and tv.SetSpecID then
            tv.specID = nil
            pcall(function()
                tv:SetSpecID(savedSpecID)
            end)
            local guard = 0
            while specTree.dirty and next(specTree.dirty) and guard < 12 do
                guard = guard + 1
                pcall(function()
                    specTree:Update()
                end)
            end
            guard = 0
            while classTree.dirty and next(classTree.dirty) and guard < 12 do
                guard = guard + 1
                pcall(function()
                    classTree:Update()
                end)
            end
        else
            if savedClassC and savedTabC then
                pcall(SyncTreeBuild, classTree, savedClassC, savedTabC)
            end
            if savedClassS and savedTabS then
                pcall(SyncTreeBuild, specTree, savedClassS, savedTabS)
            end
        end
        if not wasShown then
            frame:Hide()
            if p1 then
                frame:ClearAllPoints()
                frame:SetPoint(p1, p2, p3, p4, p5)
            end
        end
        frame:SetAlpha(oldAlpha)
    end

    -- Park invisible so BuildTree can run without a visible flash.
    frame:SetAlpha(0)
    if not wasShown then
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", -5000, -5000)
        frame:Show()
        if frame.ShowTreeView then
            pcall(function()
                frame:ShowTreeView()
            end)
        elseif tv.Show then
            tv:Show()
        end
    end

    local okHarvest, errHarvest = pcall(function()
        if not self.layoutCache.class then
            SyncTreeBuild(classTree, necro, "Class")
            self.layoutCache.class = HarvestTreeLayout(classTree)
        end
        SyncTreeBuild(specTree, necro, SpecDBCFromFile(spec.file))
        self.layoutCache[cacheKey] = HarvestTreeLayout(specTree)
    end)
    restoreCoA()
    if not okHarvest then
        error(errHarvest or "HarvestLiveLayouts failed")
    end

    return self.layoutCache.class, self.layoutCache[cacheKey]
end

local function EnumerateClassTab(tabName)
    local CA = C_CharacterAdvancement
    if not CA or not CA.GetEntriesByClass then
        return {}
    end
    local classDBC = NecroClassDBC()
    local ok, entries = pcall(CA.GetEntriesByClass, classDBC, tabName, false)
    if not ok or type(entries) ~= "table" then
        return {}
    end
    local list = {}
    local groupsSeen = {}
    -- Prefer ipairs — same order CoA TalentTreeBase:BuildTree uses.
    local function consider(entry)
        if type(entry) ~= "table" or not (entry.ID or entry.id) then
            return
        end
        local flags = tonumber(entry.Flags) or 0
        if Enum and Enum.CharacterAdvancementFlag and bit and bit.band then
            local H = Enum.CharacterAdvancementFlag.HiddenClientside
            if H and bit.band(flags, H) ~= 0 then
                return
            end
        end
        -- Collapse choice groups to one display node (CoA shows a single choice button).
        local group = tonumber(entry.Group) or 0
        if group ~= 0 then
            if groupsSeen[group] then
                return
            end
            groupsSeen[group] = true
        end
        list[#list + 1] = entry
    end
    if entries[1] then
        for i = 1, #entries do
            consider(entries[i])
        end
    else
        for _, entry in pairs(entries) do
            consider(entry)
        end
    end
    return FilterOutPassiveRail(list)
end

-- ─── Live CoA inspect mode (exact Character Advancement layout) ─────────────

local function StyleNodeIcon(node, taken)
    if not node then
        return
    end
    local icon = node.Icon
    -- BorderIcon / nested icon textures
    local tex = icon
    if icon and icon.Icon then
        tex = icon.Icon
    elseif icon and icon.icon then
        tex = icon.icon
    end
    if tex and tex.SetDesaturated then
        pcall(function()
            tex:SetDesaturated(not taken)
            if tex.SetVertexColor then
                tex:SetVertexColor(1, 1, 1, 1)
            end
        end)
    end
    if icon and icon.SetDesaturated and icon ~= tex then
        pcall(function()
            icon:SetDesaturated(not taken)
        end)
    end
end

local function EnsureNodeStamp(node)
    if node.mancerInspectStamp and node.mancerInspectStamp.alive then
        return node.mancerInspectStamp
    end
    local stamp = CreateFrame("Frame", nil, node)
    stamp:SetAllPoints(node)
    stamp:EnableMouse(false)
    stamp:SetFrameLevel((node:GetFrameLevel() or 1) + 12)
    stamp.alive = true

    -- Soft darken untaken (no extra ring) — taken keeps CoA chrome + colour icon.
    local veil = stamp:CreateTexture(nil, "ARTWORK")
    veil:SetAllPoints(stamp)
    veil:SetTexture(LINE_TEX)
    veil:SetVertexColor(0, 0, 0, 0.35)
    stamp.veil = veil

    local rank = stamp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rank:SetPoint("BOTTOMRIGHT", stamp, "BOTTOMRIGHT", 2, -1)
    rank:SetTextColor(1, 0.82, 0.2, 1)
    if rank.SetShadowColor then
        rank:SetShadowColor(0, 0, 0, 1)
        rank:SetShadowOffset(1, -1)
    end
    stamp.rankText = rank

    stamp:Hide()
    node.mancerInspectStamp = stamp
    return stamp
end

local function IsPassiveRailNode(tree, node)
    if not tree or not node then
        return false
    end
    local x = tonumber(node.positionX)
    if not x then
        return false
    end
    -- Collect unique X from display nodes once per tree.
    if not tree._mancerInspectXCut then
        local uniq, seen = {}, {}
        for n in tree:EnumerateNodes() do
            if n and n.IsShown and n:IsShown() then
                local isChoice = n.IsChoiceNode and n:IsChoiceNode()
                local grouped = (not isChoice) and n.entry and tree.IsGroupedEntry and tree:IsGroupedEntry(n.entry)
                if isChoice or (n.entry and not grouped) then
                    local px = tonumber(n.positionX)
                    if px and not seen[px] then
                        seen[px] = true
                        uniq[#uniq + 1] = px
                    end
                end
            end
        end
        table.sort(uniq)
        local leftCut, rightCut = nil, nil
        if #uniq >= 4 then
            for i = 2, #uniq do
                local g = uniq[i] - uniq[i - 1]
                local leftCols = i - 1
                if g >= 2 and leftCols <= 3 and leftCols < (#uniq - leftCols) then
                    leftCut = uniq[i]
                    break
                end
            end
            for i = #uniq, 2, -1 do
                local g = uniq[i] - uniq[i - 1]
                local rightCols = #uniq - i + 1
                if g >= 2 and rightCols <= 3 and rightCols < (i - 1) then
                    rightCut = uniq[i - 1]
                    break
                end
            end
        end
        tree._mancerInspectXCut = { left = leftCut, right = rightCut }
    end
    local cut = tree._mancerInspectXCut
    if cut.left and x < cut.left then
        return true
    end
    if cut.right and x > cut.right then
        return true
    end
    return false
end

function InspectTree:ClearCoAStamps()
    for _, stamp in pairs(self.activeStamps or {}) do
        if stamp and stamp.Hide then
            stamp:Hide()
        end
    end
    wipe(self.activeStamps or {})
    self.activeStamps = {}
    if self.coaBanner then
        self.coaBanner:Hide()
    end
    if self.coaTabBar then
        self.coaTabBar:Hide()
    end
end

function InspectTree:SetInspectChromeVisible(inspectMode)
    local frame = CoATalentFrame
    if not frame or not frame.TreeView then
        return
    end
    local tv = frame.TreeView
    if tv.SpecTree and tv.SpecTree.PassivesBackground then
        if inspectMode then
            tv.SpecTree.PassivesBackground:Hide()
        else
            tv.SpecTree.PassivesBackground:Show()
        end
    end
    -- Libellus "Next Node" chrome on the live CA frame.
    local nextBtn = _G.MancerTalentRouteMode or (Mancer.TalentOverlay and Mancer.TalentOverlay.modeBtn)
    if nextBtn and nextBtn.SetShown then
        nextBtn:SetShown(not inspectMode)
    end
    local fullBtn = _G.MancerTalentRouteFull
    if fullBtn and fullBtn.SetShown then
        fullBtn:SetShown(not inspectMode)
    end
end

function InspectTree:StampCoATrees(rankMap, unitName, specIndex, specLabel)
    self:ClearCoAStamps()
    local frame = CoATalentFrame
    if not frame or not frame.TreeView then
        return false
    end
    self.activeStamps = self.activeStamps or {}
    local stamped = 0

    local function stampTree(tree)
        if not tree or not tree.EnumerateNodes then
            return
        end
        tree._mancerInspectXCut = nil -- recompute cuts for this build
        for node in tree:EnumerateNodes() do
            if node and node.IsShown and node:IsShown() then
                local isChoice = node.IsChoiceNode and node:IsChoiceNode()
                local grouped = (not isChoice) and node.entry and tree.IsGroupedEntry and tree:IsGroupedEntry(node.entry)
                if grouped then
                    -- choice children are drawn via parent
                elseif IsPassiveRailNode(tree, node) then
                    node:Hide()
                elseif isChoice or node.entry then
                    local id = node.entry and tonumber(node.entry.ID or node.entry.id)
                    local rank = id and rankMap[id] or 0
                    local maxR = 1
                    if (not rank or rank <= 0) and node.nodes then
                        for _, sub in ipairs(node.nodes) do
                            if sub and sub.entry then
                                local sid = tonumber(sub.entry.ID or sub.entry.id)
                                if sid and rankMap[sid] then
                                    rank = math.max(rank or 0, rankMap[sid])
                                    id = sid
                                    maxR = math.max(maxR, EntryMaxRank(sub.entry))
                                end
                            end
                        end
                    elseif node.entry then
                        maxR = EntryMaxRank(node.entry)
                    end
                    local taken = rank and rank > 0
                    StyleNodeIcon(node, taken)
                    if isChoice and node.nodes then
                        for _, sub in ipairs(node.nodes) do
                            StyleNodeIcon(sub, taken)
                        end
                    end
                    local stamp = EnsureNodeStamp(node)
                    if taken then
                        stamp.veil:Hide()
                        stamp.rankText:SetText(string.format("%d/%d", rank, math.max(rank, maxR)))
                        stamp.rankText:SetTextColor(1, 0.85, 0.25, 1)
                        stamp:Show()
                    else
                        stamp.veil:Show()
                        if maxR > 1 then
                            stamp.rankText:SetText(string.format("0/%d", maxR))
                            stamp.rankText:SetTextColor(0.7, 0.7, 0.72, 1)
                        else
                            stamp.rankText:SetText("")
                        end
                        stamp:Show()
                    end
                    self.activeStamps[stamp] = stamp
                    stamped = stamped + 1
                end
            end
        end
    end

    stampTree(frame.TreeView.ClassTree)
    stampTree(frame.TreeView.SpecTree)

    -- Banner + Animation/Death/Rime tabs on the live CA frame.
    if not self.coaBanner then
        local banner = CreateFrame("Frame", "MancerInspectCoABanner", frame)
        banner:SetPoint("TOP", frame, "TOP", 0, -36)
        banner:SetSize(520, 22)
        banner:EnableMouse(false)
        banner:SetFrameLevel((frame:GetFrameLevel() or 1) + 50)
        local bg = banner:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture(LINE_TEX)
        bg:SetVertexColor(0.05, 0.06, 0.07, 0.88)
        local text = banner:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetTextColor(1, 0.82, 0.2, 1)
        banner.text = text
        self.coaBanner = banner
    end
    self.coaBanner.text:SetText(string.format(
        L("INSPECT_TREE_BANNER", "Inspect build · %s · Spec %s · %s"),
        unitName or "?",
        tostring(specIndex or "?"),
        specLabel or "?"
    ))
    self.coaBanner:Show()

    if not self.coaTabBar then
        local bar = CreateFrame("Frame", "MancerInspectCoATabs", frame)
        bar:SetPoint("TOP", self.coaBanner, "BOTTOM", 0, -4)
        bar:SetSize(360, 22)
        bar:SetFrameLevel((frame:GetFrameLevel() or 1) + 51)
        self.coaTabButtons = {}
        local tabW, gap = 112, 8
        local total = (#NECRO_SPECS * tabW) + ((#NECRO_SPECS - 1) * gap)
        local startX = -total * 0.5
        for i, spec in ipairs(NECRO_SPECS) do
            local btn = CreateFrame("Button", nil, bar, "UIPanelButtonTemplate")
            btn:SetSize(tabW, 20)
            btn:SetPoint("LEFT", bar, "CENTER", startX + (i - 1) * (tabW + gap), 0)
            btn:SetText(spec.label)
            btn.specKey = spec.key
            btn:SetScript("OnClick", function()
                InspectTree:SelectLiveSpecTab(spec.key)
            end)
            self.coaTabButtons[spec.key] = btn
        end
        self.coaTabBar = bar
    end
    self.coaTabBar:Show()
    self:UpdateLiveSpecTabButtons()

    return stamped > 0
end

function InspectTree:UpdateLiveSpecTabButtons()
    local active = self.activeSpecTab or "Animation"
    for key, btn in pairs(self.coaTabButtons or {}) do
        local on = key == active
        if btn.SetText then
            local label = FindSpecDef(key).label
            btn:SetText(on and ("> " .. label) or label)
        end
        if on then
            btn:Disable()
        else
            btn:Enable()
        end
    end
end

function InspectTree:BuildLiveTreesForSpec(specKey)
    local frame = CoATalentFrame
    if not frame or not frame.TreeView then
        return false
    end
    local tv = frame.TreeView
    local spec = FindSpecDef(specKey or self.activeSpecTab or "Animation")
    local necro = NecroClassDBC()
    local specDbc = SpecDBCFromFile(spec.file)
    SyncTreeBuild(tv.ClassTree, necro, "Class")
    SyncTreeBuild(tv.SpecTree, necro, specDbc)
    if tv.SpecTree and tv.SpecTree.Label then
        tv.SpecTree.Label:SetText(spec.label)
    end
    if tv.Background1 and tv.Background1.SetAtlas then
        pcall(function()
            tv.Background1:SetAtlas(SpecBackgroundAtlas(spec.file))
        end)
    end
    self.activeSpecTab = spec.key
    return true
end

function InspectTree:SelectLiveSpecTab(specKey)
    self.activeSpecTab = FindSpecDef(specKey).key
    self:BuildLiveTreesForSpec(self.activeSpecTab)
    self:SetInspectChromeVisible(true)
    self:StampCoATrees(
        self.pendingRankMap,
        self.pendingUnitName,
        self.specIndex,
        FindSpecDef(self.activeSpecTab).label
    )
end

function InspectTree:ShowOnLiveCoA(unit, specIndex, rankMap)
    if not IsAddOnLoaded("Ascension_CoATalents") then
        pcall(LoadAddOn, "Ascension_CoATalents")
    end
    local frame = CoATalentFrame
    if not frame or not frame.TreeView then
        return false
    end

    self.pendingRankMap = rankMap
    self.pendingUnitName = UnitName and UnitName(unit) or unit
    self.specIndex = specIndex
    self.inspectCoAActive = true
    self:HookCoATalentFrame()

    local best = self:DetectBestSpecTab(rankMap)
    self.activeSpecTab = best.key

    -- Remember player CA state so we can restore on close.
    local tv = frame.TreeView
    self._savedCoASpecID = tv.specID
    local cc, ct = tv.ClassTree and tv.ClassTree:GetClassTab()
    local sc, st = tv.SpecTree and tv.SpecTree:GetClassTab()
    self._savedCoAClassTab = { cc, ct }
    self._savedCoASpecTab = { sc, st }

    -- Undo HarvestLiveLayouts parking (alpha 0 / off-screen) if still applied.
    frame:SetAlpha(1)
    if frame.GetNumPoints and frame:GetNumPoints() > 0 then
        local _, _, _, x, y = frame:GetPoint(1)
        if (tonumber(x) or 0) < -1000 or (tonumber(y) or 0) < -1000 then
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
    end

    if frame.ShowTreeView then
        pcall(function()
            frame:ShowTreeView()
        end)
    end
    if ShowUIPanel then
        pcall(ShowUIPanel, frame)
    end
    if frame.Show then
        frame:Show()
    end
    if tv.Show then
        tv:Show()
    end
    frame:Raise()

    self:BuildLiveTreesForSpec(best.key)
    self:SetInspectChromeVisible(true)

    -- Defer stamp one frame so nodes finish anchoring.
    if not self.stampDriver then
        self.stampDriver = CreateFrame("Frame")
    end
    self.pendingStamp = {
        rankMap = rankMap,
        unitName = self.pendingUnitName,
        specIndex = specIndex,
        specLabel = best.label,
        delay = 0.12,
    }
    self.stampDriver:SetScript("OnUpdate", function(_, elapsed)
        local p = InspectTree.pendingStamp
        if not p then
            InspectTree.stampDriver:SetScript("OnUpdate", nil)
            return
        end
        p.delay = (p.delay or 0) - elapsed
        if p.delay > 0 then
            return
        end
        InspectTree.pendingStamp = nil
        InspectTree.stampDriver:SetScript("OnUpdate", nil)
        InspectTree:StampCoATrees(p.rankMap, p.unitName, p.specIndex, p.specLabel)
    end)

    if self.stencilWindow then
        self.stencilWindow:Hide()
    end
    -- Only claim success if the frame is actually on-screen.
    local shown = frame.IsShown and frame:IsShown()
    local visible = (not frame.IsVisible) or frame:IsVisible()
    if not (shown and visible) then
        self.inspectCoAActive = false
        self:SetInspectChromeVisible(false)
        return false
    end
    return true
end

function InspectTree:RestoreLiveCoA()
    if not self.inspectCoAActive then
        self:ClearCoAStamps()
        return
    end
    self.inspectCoAActive = false
    self:ClearCoAStamps()
    self:SetInspectChromeVisible(false)
    local frame = CoATalentFrame
    if not frame or not frame.TreeView then
        return
    end
    local tv = frame.TreeView
    -- Rebuild trees so passive nodes we hid come back with the player's real tabs.
    if self._savedCoASpecID and tv.SetSpecID then
        tv.specID = nil
        pcall(function()
            tv:SetSpecID(self._savedCoASpecID)
        end)
    else
        local c = self._savedCoAClassTab
        local s = self._savedCoASpecTab
        if c and c[1] and c[2] then
            SyncTreeBuild(tv.ClassTree, c[1], c[2])
        end
        if s and s[1] and s[2] then
            SyncTreeBuild(tv.SpecTree, s[1], s[2])
        end
    end
    self._savedCoASpecID = nil
    self._savedCoAClassTab = nil
    self._savedCoASpecTab = nil
end

function InspectTree:TryShowOnCoA(unit, specIndex, rankMap)
    return self:ShowOnLiveCoA(unit, specIndex, rankMap)
end

function InspectTree:HookCoATalentFrame()
    if self._coaHooked then
        return
    end
    local frame = CoATalentFrame
    if not frame or not frame.HookScript then
        return
    end
    self._coaHooked = true
    frame:HookScript("OnHide", function()
        if InspectTree.inspectCoAActive then
            InspectTree:RestoreLiveCoA()
        end
    end)
end

-- ─── Stencil window ───────────────────────────────────────────────────────

local function EnsurePane(parent, name)
    local pane = _G[name] or CreateFrame("Frame", name, parent)
    pane:SetParent(parent)
    pane:EnableMouse(true)
    pane.nodes = {}
    pane.pool = pane.pool or {}
    pane.linkPool = pane.linkPool or {}
    pane.headPool = pane.headPool or {}
    pane.linkFrames = pane.linkFrames or {}
    return pane
end

local function AcquireNodeButton(pane, index)
    local btn = pane.pool[index]
    if btn and btn.usesSpendCircle == 2 then
        return btn
    end
    -- Rebuild if an old square / oversized-ring node is pooled.
    if btn then
        btn:Hide()
        btn:SetParent(nil)
        pane.pool[index] = nil
    end
    btn = CreateFrame("Button", nil, pane)
    btn:SetSize(BUTTON_W, BUTTON_H)
    btn:EnableMouse(true)
    btn.usesSpendCircle = 2

    local shadow = btn:CreateTexture(nil, "BACKGROUND")
    shadow:SetPoint("CENTER", 0, -1)
    SetCircleAtlas(shadow, NODE_SHADOW, SHADOW_SIZE)
    btn.shadow = shadow

    local icon = btn:CreateTexture(nil, "ARTWORK")
    ForceTexSize(icon, BUTTON_W, BUTTON_H)
    icon:SetPoint("CENTER")
    btn.icon = icon

    local ring = btn:CreateTexture(nil, "OVERLAY")
    ring:SetPoint("CENTER")
    SetCircleAtlas(ring, NODE_GRAY, RING_SIZE)
    btn.ring = ring

    -- Rank chip sits on the bottom-right of the ring (CoA placement).
    local rankBg = btn:CreateTexture(nil, "OVERLAY")
    rankBg:SetTexture(LINE_TEX)
    rankBg:SetSize(22, 11)
    rankBg:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 6, -5)
    rankBg:SetVertexColor(0.05, 0.05, 0.06, 0.92)
    btn.rankBg = rankBg

    local rank = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rank:SetPoint("CENTER", rankBg, "CENTER", 0, 0)
    rank:SetTextColor(1, 0.85, 0.25, 1)
    if rank.SetShadowColor then
        rank:SetShadowColor(0, 0, 0, 1)
        rank:SetShadowOffset(1, -1)
    end
    btn.rankText = rank

    btn:SetScript("OnEnter", function(self)
        if not self.spellId and not self.entryName then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        if self.spellId and GameTooltip.SetSpellByID then
            GameTooltip:SetSpellByID(self.spellId)
        else
            GameTooltip:AddLine(self.entryName or "?", 1, 0.82, 0.2)
        end
        if self.inspectRank and self.inspectRank > 0 then
            GameTooltip:AddLine(
                string.format(L("INSPECT_TREE_RANK", "Inspect rank: %d / %d"), self.inspectRank, self.maxRank or self.inspectRank),
                0.75, 0.72, 0.6
            )
        else
            GameTooltip:AddLine(L("INSPECT_TREE_UNTAKEN", "Not taken on this inspect build"), 0.55, 0.55, 0.55)
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    pane.pool[index] = btn
    return btn
end

local LINK_SEG_STEP = 3

-- Proxy node for CALineConnectionMixin (expects TOPLEFT positionX/Y + GetSize).
local function MakeLinkProxy(x, y)
    return {
        positionX = x,
        positionY = y,
        GetSize = function()
            return BUTTON_W, BUTTON_H
        end,
        GetShape = function()
            if TalentButtonUtil and TalentButtonUtil.VisualShape then
                return TalentButtonUtil.VisualShape.Circle
            end
            return nil
        end,
    }
end

local function EnsureCoATemplatesLoaded()
    if not IsAddOnLoaded("Ascension_CoATalents") then
        pcall(LoadAddOn, "Ascension_CoATalents")
    end
end

local function AcquireLinkFrame(pane, index)
    pane.linkFrames = pane.linkFrames or {}
    local frame = pane.linkFrames[index]
    if frame and frame.usesCoALine then
        return frame
    end
    -- Drop segment / solid-stroke leftovers so we can use real CoA connectors.
    if frame then
        frame:Hide()
        frame:SetParent(nil)
        pane.linkFrames[index] = nil
    end

    EnsureCoATemplatesLoaded()
    local ok, created = pcall(function()
        return CreateFrame("Frame", nil, pane, "CALineConnectionTemplate")
    end)
    if ok and created and created.SetStartNode and created.Line2 then
        created.usesCoALine = true
        created:EnableMouse(false)
        pane.linkFrames[index] = created
        return created
    end

    -- Fallback: segmented stroke if CoA template is unavailable.
    frame = CreateFrame("Frame", nil, pane)
    frame:SetAllPoints(pane)
    frame:EnableMouse(false)
    frame.segments = {}
    frame.segCount = 0
    frame.usesCoALine = false
    local arrow = frame:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture(ARROW_HEAD)
    arrow:SetSize(12, 10)
    frame.Arrow = arrow
    pane.linkFrames[index] = frame
    return frame
end

local function HideLinkStroke(frame)
    if not frame then
        return
    end
    if frame.usesCoALine then
        frame:Hide()
        return
    end
    for i = 1, (frame.segCount or 0) do
        local seg = frame.segments and frame.segments[i]
        if seg then
            seg:Hide()
        end
    end
    frame.segCount = 0
    if frame.Arrow then
        frame.Arrow:Hide()
    end
end

local function PlaceLinkSegments(pane, frame, x1, y1, x2, y2, lit, showArrow)
    local cx1, cy1 = x1 + BUTTON_W * 0.5, y1 - BUTTON_H * 0.5
    local cx2, cy2 = x2 + BUTTON_W * 0.5, y2 - BUTTON_H * 0.5
    local dx, dy = cx2 - cx1, cy2 - cy1
    local len = math.sqrt(dx * dx + dy * dy)
    if len < 8 then
        frame:Hide()
        return
    end
    local inset = (BUTTON_W * 0.5) - 1
    local ux, uy = dx / len, dy / len
    local sx, sy = cx1 + ux * inset, cy1 + uy * inset
    local ex, ey = cx2 - ux * inset, cy2 - uy * inset
    dx, dy = ex - sx, ey - sy
    len = math.sqrt(dx * dx + dy * dy)
    if len < 4 then
        frame:Hide()
        return
    end
    local c = lit and LINK_GOLD or LINK_DIM
    local thick = lit and 3 or 2
    local steps = math.max(2, math.floor(len / LINK_SEG_STEP + 0.5))
    frame.segments = frame.segments or {}
    for i = 1, steps do
        local t = (i - 0.5) / steps
        local seg = frame.segments[i]
        if not seg then
            seg = frame:CreateTexture(nil, "BACKGROUND")
            seg:SetTexture(LINE_TEX)
            frame.segments[i] = seg
        end
        seg:ClearAllPoints()
        seg:SetSize(thick, thick)
        seg:SetPoint("CENTER", pane, "TOPLEFT", sx + dx * t, sy + dy * t)
        seg:SetVertexColor(c[1], c[2], c[3], c[4])
        seg:Show()
    end
    frame.segCount = steps
    if showArrow and frame.Arrow then
        frame.Arrow:ClearAllPoints()
        frame.Arrow:SetPoint("CENTER", pane, "TOPLEFT", ex - ux * 2, ey - uy * 2)
        if frame.Arrow.SetRotation then
            pcall(frame.Arrow.SetRotation, frame.Arrow, math.atan2(dy, dx))
        end
        frame.Arrow:SetVertexColor(lit and 1 or 0.55, lit and 1 or 0.55, lit and 1 or 0.58, lit and 1 or 0.85)
        frame.Arrow:Show()
    elseif frame.Arrow then
        frame.Arrow:Hide()
    end
    frame:Show()
end

-- Prefer real CoA CALineConnectionTemplate (LineMixin solid bars). Segment fallback otherwise.
local function PlaceLink(pane, index, x1, y1, x2, y2, lit, showArrow)
    local frame = AcquireLinkFrame(pane, index)
    HideLinkStroke(frame)

    local dx, dy = (x2 - x1), (y2 - y1)
    if (dx * dx + dy * dy) < 64 then
        frame:Hide()
        return
    end

    if frame.usesCoALine then
        local ok = pcall(function()
            frame:SetParent(pane)
            frame:ClearAllPoints()
            -- CoA Build() reads parent height — pane must already be sized.
            frame:SetStartNode(MakeLinkProxy(x1, y1))
            frame:SetEndNode(MakeLinkProxy(x2, y2))
            local state
            if TalentButtonUtil and TalentButtonUtil.ConnectionState then
                state = lit and TalentButtonUtil.ConnectionState.Connected
                    or TalentButtonUtil.ConnectionState.Gated
            end
            if state and frame.UpdateConnectionState then
                frame:UpdateConnectionState(state)
            elseif frame.Line2 and frame.Line2.SetVertexColor then
                local c = lit and LINK_GOLD or LINK_DIM
                frame.Line2:SetVertexColor(c[1], c[2], c[3], c[4])
            end
            if frame.Arrow then
                if showArrow then
                    frame.Arrow:Show()
                else
                    frame.Arrow:Hide()
                end
            end
            frame:Show()
        end)
        if ok and frame:IsShown() then
            return
        end
        -- Template Build failed — use segment frame for this slot only.
        frame:Hide()
        frame:SetParent(nil)
        frame = CreateFrame("Frame", nil, pane)
        frame:SetAllPoints(pane)
        frame.segments = {}
        frame.segCount = 0
        frame.usesCoALine = false
        local arrow = frame:CreateTexture(nil, "OVERLAY")
        arrow:SetTexture(ARROW_HEAD)
        arrow:SetSize(12, 10)
        frame.Arrow = arrow
        pane.linkFrames[index] = frame
    end

    PlaceLinkSegments(pane, frame, x1, y1, x2, y2, lit, showArrow)
end

function InspectTree:BuildPane(pane, tabName, rankMap, layoutRows)
    for _, btn in pairs(pane.pool or {}) do
        btn:Hide()
    end
    for _, tex in pairs(pane.linkPool or {}) do
        tex:Hide()
    end
    for _, tex in pairs(pane.headPool or {}) do
        tex:Hide()
    end
    for _, frame in pairs(pane.linkFrames or {}) do
        HideLinkStroke(frame)
        frame:Hide()
    end

    local coords = {}
    local byId = {}
    local minX, maxX, minY, maxY = nil, nil, nil, nil

    -- Harvest is wiring-only. Always place with DBC PositionX/Y → SimpleGridXY so
    -- Class + Spec share one coordinate system (live CoA pixel origins differ per tree).
    local harvestById = {}
    if layoutRows and #layoutRows > 0 then
        for _, src in ipairs(layoutRows) do
            for _, eid in ipairs(src.entryIds or { src.id }) do
                if eid then
                    harvestById[eid] = src
                end
            end
        end
    end

    local cellSeen = {}
    local function addRow(row)
        coords[#coords + 1] = row
        for _, eid in ipairs(row.entryIds or { row.id }) do
            if eid then
                byId[eid] = row
            end
        end
        minX = minX and math.min(minX, row.x) or row.x
        maxX = maxX and math.max(maxX, row.x + BUTTON_W) or (row.x + BUTTON_W)
        minY = minY and math.min(minY, row.y - BUTTON_H) or (row.y - BUTTON_H)
        maxY = maxY and math.max(maxY, row.y) or row.y
    end

    local entries = EnumerateClassTab(tabName)
    for _, entry in ipairs(entries) do
        local id = tonumber(entry.ID or entry.id)
        local px, py = GetEntryPos(entry)
        local x, y = GridXY(px, py)
        local cellKey = string.format("%d:%d", px or 0, py or 0)
        local existing = cellSeen[cellKey]
        if existing then
            if id then
                existing.entryIds[#existing.entryIds + 1] = id
                byId[id] = existing
            end
        else
            local row = {
                entry = entry,
                id = id,
                entryIds = id and { id } or {},
                x = x,
                y = y,
                px = px,
                py = py,
            }
            local harvested = id and harvestById[id]
            if harvested and harvested.entryIds then
                row.entryIds = {}
                for _, eid in ipairs(harvested.entryIds) do
                    row.entryIds[#row.entryIds + 1] = eid
                    byId[eid] = row
                end
            end
            if harvested and harvested.destRows then
                row._harvestDestIds = {}
                for _, dest in ipairs(harvested.destRows) do
                    if dest and dest.id then
                        row._harvestDestIds[#row._harvestDestIds + 1] = dest.id
                    end
                end
            end
            cellSeen[cellKey] = row
            addRow(row)
        end
    end
    minX, maxX, minY, maxY = minX or 0, maxX or 280, minY or -320, maxY or 0

    -- Same top edge for every pane; center under the column header.
    local pad = 12
    local TREE_TOP = -8 -- both Class and Spec top nodes land on this pane Y
    local host = pane:GetParent()
    local hostW = host and host.GetWidth and host:GetWidth() or 0
    local hostH = host and host.GetHeight and host:GetHeight() or 0
    local contentW = (maxX - minX) + BUTTON_W
    local contentH = (maxY - minY) + BUTTON_H
    local ox = pad - minX
    if hostW > contentW + pad * 2 then
        ox = math.floor((hostW - contentW) * 0.5) - minX
    end
    local oy = TREE_TOP - maxY

    local width = math.max(hostW > 0 and hostW or 300, contentW + pad * 2)
    local height = math.max(contentH + pad * 2 - TREE_TOP, hostH > 0 and hostH or 360)
    -- Size pane BEFORE connectors — LineMixin math needs final height.
    pane:SetSize(width, height)
    if host and host.SetVerticalScroll then
        host:SetVerticalScroll(0)
    end

    local function RankForRow(row)
        local best = 0
        for _, eid in ipairs(row.entryIds or { row.id }) do
            if eid and rankMap[eid] then
                best = math.max(best, rankMap[eid])
            end
        end
        return best
    end

    local function ResolveRow(destId)
        destId = tonumber(destId)
        if not destId then
            return nil
        end
        if byId[destId] then
            return byId[destId]
        end
        local h = harvestById[destId]
        if h then
            for _, eid in ipairs(h.entryIds or { h.id }) do
                if byId[eid] then
                    return byId[eid]
                end
            end
            if h.id and byId[h.id] then
                return byId[h.id]
            end
        end
        return nil
    end

    local linkN = 0
    local seenLinks = {}
    local function rowKey(row)
        if row.px ~= nil and row.py ~= nil then
            return string.format("%s:%s", tostring(row.px), tostring(row.py))
        end
        return string.format("%.1f:%.1f", row.x or 0, row.y or 0)
    end
    local function drawConn(row, dest)
        if not dest or dest == row then
            return
        end
        -- One undirected edge only (ConnectedNodes often create A↔B duplicates → double heads).
        local ka, kb = rowKey(row), rowKey(dest)
        if ka > kb then
            ka, kb = kb, ka
        end
        local key = ka .. "|" .. kb
        if seenLinks[key] then
            return
        end
        seenLinks[key] = true

        -- Draw top → bottom so a single head points down the tree.
        local from, to = row, dest
        if (from.y or 0) < (to.y or 0) then
            from, to = to, from
        end
        local lit = (RankForRow(from) > 0) and (RankForRow(to) > 0)
        linkN = linkN + 1
        -- Arrow heads only on spent paths — untaken edges are line-only (less clutter).
        PlaceLink(pane, linkN, from.x + ox, from.y + oy, to.x + ox, to.y + oy, lit, lit)
    end

    for _, row in ipairs(coords) do
        local drew = false
        if row._harvestDestIds then
            for _, destId in ipairs(row._harvestDestIds) do
                local dest = ResolveRow(destId)
                if dest then
                    drawConn(row, dest)
                    drew = true
                end
            end
        end
        if not drew then
            local conns = row.entry and row.entry.ConnectedNodes
            if type(conns) == "table" then
                for _, destId in pairs(conns) do
                    drawConn(row, ResolveRow(destId))
                end
            end
            for _, eid in ipairs(row.entryIds or {}) do
                local h = harvestById[eid]
                if h and h.conns then
                    for _, destId in ipairs(h.conns) do
                        drawConn(row, ResolveRow(destId))
                    end
                end
            end
        end
    end

    local placed = 0
    local pointsSpent = 0
    for _, row in ipairs(coords) do
        placed = placed + 1
        local btn = AcquireNodeButton(pane, placed)
        local entry = row.entry
        local rank = RankForRow(row)
        local maxRank = EntryMaxRank(entry)
        -- Prefer the taken choice's icon when a cell has multiple entry ids.
        if rank > 0 then
            for _, eid in ipairs(row.entryIds or {}) do
                if rankMap[eid] and rankMap[eid] > 0 then
                    local e = ResolveEntry(eid)
                    if e then
                        entry = e
                        maxRank = EntryMaxRank(e)
                        break
                    end
                end
            end
        end
        local icon, spellId, name = EntrySpellIcon(entry, math.max(1, rank))
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", pane, "TOPLEFT", row.x + ox, row.y + oy)
        btn:SetFrameLevel((pane:GetFrameLevel() or 1) + 8)
        ApplyCircleIcon(btn.icon, icon)
        ForceTexSize(btn.icon, BUTTON_W, BUTTON_H)
        btn.spellId = spellId
        btn.entryName = name
        btn.inspectRank = rank
        btn.maxRank = maxRank
        pointsSpent = pointsSpent + rank

        if rank > 0 then
            btn.icon:SetDesaturated(false)
            btn.icon:SetVertexColor(1, 1, 1, 1)
            SetCircleAtlas(btn.ring, NODE_YELLOW, RING_SIZE)
            btn.rankText:SetText(string.format("%d/%d", rank, math.max(rank, maxRank)))
            btn.rankText:SetTextColor(1, 0.85, 0.25, 1)
            btn.rankBg:SetVertexColor(0.12, 0.09, 0.02, 0.95)
            btn.rankBg:Show()
            btn.rankText:Show()
        else
            btn.icon:SetDesaturated(true)
            btn.icon:SetVertexColor(1, 1, 1, 1)
            SetCircleAtlas(btn.ring, NODE_GRAY, RING_SIZE)
            btn.rankText:SetText(string.format("0/%d", math.max(1, maxRank)))
            btn.rankText:SetTextColor(0.72, 0.72, 0.74, 1)
            btn.rankBg:SetVertexColor(0.05, 0.05, 0.06, 0.92)
            btn.rankBg:Show()
            btn.rankText:Show()
        end
        btn:Show()
    end

    return width, height, pointsSpent
end

function InspectTree:ApplySpecBackground(specFile)
    local frame = self.stencilWindow
    if not frame or not frame.mancerArt then
        return
    end
    local atlas = SpecBackgroundAtlas(specFile)
    local ignore = Const and Const.TextureKit and Const.TextureKit.IgnoreAtlasSize
    if ignore == nil then
        ignore = false
    end
    pcall(function()
        frame.mancerArt:SetAtlas(atlas, ignore)
    end)
end

function InspectTree:UpdateSpecTabButtons()
    local active = self.activeSpecTab or "Animation"
    for _, btn in pairs(self.specTabButtons or {}) do
        local on = btn.specKey == active
        if btn.SetNormalFontObject then
            btn:SetNormalFontObject(on and "GameFontHighlight" or "GameFontNormal")
        end
        if on then
            btn:LockHighlight()
        else
            btn:UnlockHighlight()
        end
        local label = btn.specLabel or btn.specKey
        if btn.SetText then
            btn:SetText(on and ("> " .. label) or label)
        end
    end
end

function InspectTree:RefreshStencilPanes()
    local rankMap = self.pendingRankMap or {}
    local spec = FindSpecDef(self.activeSpecTab or "Animation")
    -- Optional harvest only for choice-node connection wiring; node XY always from DBC.
    local classRows, specRows = nil, nil
    pcall(function()
        classRows, specRows = self:HarvestLiveLayouts(spec.key)
    end)
    local _, _, classPts = self:BuildPane(self.classPane, "Class", rankMap, classRows)
    local _, _, specPts = self:BuildPane(self.specPane, SpecDBCFromFile(spec.file), rankMap, specRows)
    if self.classPoints then
        self.classPoints:SetText(tostring(classPts or 0))
    end
    if self.specPoints then
        self.specPoints:SetText(tostring(specPts or 0))
    end
    if self.specLabel then
        self.specLabel:SetText(spec.label)
    end
    self:ApplySpecBackground(spec.file)
    self:UpdateSpecTabButtons()
end

function InspectTree:SelectSpecTab(specKey)
    local spec = FindSpecDef(specKey)
    self.activeSpecTab = spec.key
    self:RefreshStencilPanes()
end

function InspectTree:EnsureStencilWindow()
    local LAYOUT_VER = 13
    if self.stencilWindow and self.stencilLayoutVersion == LAYOUT_VER then
        return self.stencilWindow
    end
    -- Named frames are reused by CreateFrame — purge prior layout children (old tab buttons, etc.).
    local existing = _G.MancerInspectTreeFrame
    if existing then
        existing:Hide()
        local kids = { existing:GetChildren() }
        for i = 1, #kids do
            local child = kids[i]
            if child then
                child:Hide()
                child:SetParent(nil)
            end
        end
    end
    if self.stencilWindow and self.stencilWindow ~= existing then
        self.stencilWindow:Hide()
        self.stencilWindow:SetParent(nil)
    end
    self.stencilWindow = nil
    self.classPane = nil
    self.specPane = nil
    self.specTabButtons = nil
    self.stencilLayoutVersion = LAYOUT_VER
    local ui = Mancer.UI
    local title = L("INSPECT_TREE_TITLE", "Inspect Talent Tree")
    local frame, content
    -- Content inset clears native title chrome so trees aren't clipped under it.
    if ui and ui.CreateMovableChromeWindow then
        frame, content = ui.CreateMovableChromeWindow("MancerInspectTreeFrame", {
            title = title,
            width = 1294,
            height = 666,
            strata = "DIALOG",
            bg = ui.HUB_ANIMATION_BG,
            artScrub = 0.58,
            insetLeft = 18,
            insetRight = 18,
            insetTop = -72,
            insetBottom = 22,
        })
        if ui.ApplyHubPortraitMark then
            ui.ApplyHubPortraitMark(frame)
        end
    else
        frame = existing or CreateFrame("Frame", "MancerInspectTreeFrame", UIParent)
        frame:SetParent(UIParent)
        frame:SetSize(1294, 666)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("DIALOG")
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:Hide()
        content = frame
    end
    self.stencilWindow = frame
    self.stencilContent = content

    local host = content or frame

    -- Slim banner (spec auto-detected; no Animation/Death/Rime tab buttons).
    local status = host:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    status:SetPoint("TOP", host, "TOP", 0, -4)
    status:SetTextColor(1, 0.82, 0.2, 1)
    self.stencilStatus = status
    self.specTabButtons = nil

    -- Balanced columns; shared header band keeps NECROMANCER / ANIMATION on one baseline.
    local leftCol = CreateFrame("Frame", nil, host)
    leftCol:SetPoint("TOPLEFT", host, "TOPLEFT", 18, -40)
    leftCol:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", 18, 6)
    leftCol:SetPoint("RIGHT", host, "CENTER", -8, 0)

    local rightCol = CreateFrame("Frame", nil, host)
    rightCol:SetPoint("TOPRIGHT", host, "TOPRIGHT", -18, -40)
    rightCol:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -18, 6)
    rightCol:SetPoint("LEFT", host, "CENTER", 8, 0)

    local headerBand = CreateFrame("Frame", nil, host)
    headerBand:SetPoint("TOPLEFT", leftCol, "TOPLEFT", 0, 0)
    headerBand:SetPoint("TOPRIGHT", rightCol, "TOPRIGHT", 0, 0)
    headerBand:SetHeight(36)

    local leftLabel = headerBand:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    leftLabel:SetPoint("TOP", leftCol, "TOP", 0, 0)
    leftLabel:SetText(L("INSPECT_TREE_CLASS", "NECROMANCER"))
    leftLabel:SetTextColor(1, 0.82, 0.2, 1)

    local leftPts = headerBand:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    leftPts:SetPoint("TOP", leftLabel, "BOTTOM", 0, -2)
    leftPts:SetText("0")
    leftPts:SetTextColor(1, 0.82, 0.2, 1)
    self.classPoints = leftPts

    local rightLabel = headerBand:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    rightLabel:SetPoint("TOP", rightCol, "TOP", 0, 0)
    rightLabel:SetText(L("INSPECT_TREE_SPEC", "ANIMATION"))
    rightLabel:SetTextColor(1, 0.82, 0.2, 1)
    self.specLabel = rightLabel

    local rightPts = headerBand:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    rightPts:SetPoint("TOP", rightLabel, "BOTTOM", 0, -2)
    rightPts:SetText("0")
    rightPts:SetTextColor(1, 0.82, 0.2, 1)
    self.specPoints = rightPts

    local scrollL = CreateFrame("ScrollFrame", nil, leftCol)
    scrollL:SetPoint("TOPLEFT", leftCol, "TOPLEFT", 0, -40)
    scrollL:SetPoint("BOTTOMRIGHT", leftCol, "BOTTOMRIGHT", 0, 0)

    local scrollR = CreateFrame("ScrollFrame", nil, rightCol)
    scrollR:SetPoint("TOPLEFT", rightCol, "TOPLEFT", 0, -40)
    scrollR:SetPoint("BOTTOMRIGHT", rightCol, "BOTTOMRIGHT", 0, 0)

    self.classPane = EnsurePane(scrollL, "MancerInspectClassPane")
    self.specPane = EnsurePane(scrollR, "MancerInspectSpecPane")
    scrollL:SetScrollChild(self.classPane)
    scrollR:SetScrollChild(self.specPane)

    return frame
end

function InspectTree:ShowStencilWindow(unit, specIndex, rankMap)
    local frame = self:EnsureStencilWindow()
    local name = UnitName and UnitName(unit) or unit
    self.pendingRankMap = rankMap
    self.layoutCache = {} -- fresh harvest for this inspect

    local best = self:DetectBestSpecTab(rankMap)
    self.activeSpecTab = best.key

    if self.stencilStatus then
        self.stencilStatus:SetText(string.format(
            L("INSPECT_TREE_BANNER", "Inspect build · %s · Spec %s · %s"),
            name or "?",
            tostring(specIndex),
            best.label
        ))
    end
    -- Layout refresh can touch CoATalentFrame; keep stencil show even if harvest fails.
    pcall(function()
        self:RefreshStencilPanes()
    end)
    frame:SetAlpha(1)
    frame:SetFrameStrata("DIALOG")
    frame:Show()
    frame:Raise()
end

-- ─── Public show ───────────────────────────────────────────────────────────

function InspectTree:ShowForUnit(unit, specIndex)
    unit = unit or GetInspectUnit()
    if not unit then
        Notify(L("INSPECT_TREE_NO_UNIT", "Inspect a Necromancer first."))
        return
    end
    if not IsNecromancerUnit(unit) then
        Notify(L("INSPECT_TREE_NOT_NECRO", "Inspect talent tree is Necromancer-only for now."))
        return
    end
    local CA = C_CharacterAdvancement
    if not CA or not CA.GetInspectedBuild then
        Notify(L("INSPECT_TREE_NO_API", "Character Advancement inspect API missing."))
        return
    end

    specIndex = tonumber(specIndex) or self:GetPreferredSpecIndex(unit)
    self.specIndex = specIndex
    local rankMap = self:CollectRankMap(unit, specIndex)
    local taken = 0
    for _ in pairs(rankMap) do
        taken = taken + 1
    end
    -- If preferred spec is empty, probe Specs 1–5 (inspect UI has multiple loadouts).
    if taken == 0 then
        for i = 1, 5 do
            local map = self:CollectRankMap(unit, i)
            local n = 0
            for _ in pairs(map) do
                n = n + 1
            end
            if n > 0 then
                rankMap, taken, specIndex = map, n, i
                self.specIndex = i
                break
            end
        end
    end
    if taken == 0 then
        Notify(L("INSPECT_TREE_EMPTY", "No inspect build data yet — open Build tab, pick a specialization, try again."))
        return
    end

    -- Stencil is the reliable inspect view while Inspect is open (live CoA often
    -- fails to appear / conflicts with the Inspect UIPanel). Live CoA is fallback.
    local okStencil, errStencil = pcall(function()
        self:ShowStencilWindow(unit, specIndex, rankMap)
    end)
    if not (okStencil and self.stencilWindow and self.stencilWindow:IsShown()) then
        local okLive, liveOrErr = pcall(function()
            return self:ShowOnLiveCoA(unit, specIndex, rankMap)
        end)
        if not (okLive and liveOrErr) then
            Notify("Inspect tree error: " .. tostring(errStencil or liveOrErr))
        end
    end
end

function InspectTree:Hide()
    self:RestoreLiveCoA()
    if self.stencilWindow then
        self.stencilWindow:Hide()
    end
end

-- ─── Inspect UI button ─────────────────────────────────────────────────────

local function SafeObjectType(frame)
    if not frame then
        return nil
    end
    local ok, ot = pcall(function()
        if frame.GetObjectType then
            return frame:GetObjectType()
        end
    end)
    if ok then
        return ot
    end
    return nil
end

local function SafeGetText(frame)
    if not frame then
        return nil
    end
    -- Ascension mixins sometimes expose GetText as a table method stub — always pcall.
    local ok, text = pcall(function()
        if frame.GetText then
            return frame:GetText()
        end
    end)
    if ok and text and text ~= "" then
        return tostring(text)
    end
    ok, text = pcall(function()
        local fs = frame.Text or frame.text or frame.Label or frame.label
        if fs and fs.GetText then
            return fs:GetText()
        end
    end)
    if ok and text and text ~= "" then
        return tostring(text)
    end
    -- FontString regions on the button.
    ok, text = pcall(function()
        if not frame.GetRegions then
            return nil
        end
        local regions = { frame:GetRegions() }
        for i = 1, #regions do
            local r = regions[i]
            if r and r.GetObjectType and r:GetObjectType() == "FontString" and r.GetText then
                local t = r:GetText()
                if t and t ~= "" then
                    return t
                end
            end
        end
    end)
    if ok and text and text ~= "" then
        return tostring(text)
    end
    return nil
end

local function SafeGetChildren(frame)
    if not frame or not frame.GetChildren then
        return {}
    end
    local ok, kids = pcall(function()
        return { frame:GetChildren() }
    end)
    if ok and type(kids) == "table" then
        return kids
    end
    return {}
end

local function LooksLikeSpecButton(frame)
    local ot = SafeObjectType(frame)
    if ot ~= "Button" and ot ~= "CheckButton" then
        return false
    end
    local text = SafeGetText(frame)
    if not text then
        return false
    end
    return text:find("Specialization") ~= nil
end

local function FindSpecButtonParent(root)
    if not root then
        return nil
    end
    local found
    local function walk(f, depth)
        if not f or depth > 8 or found then
            return
        end
        if LooksLikeSpecButton(f) then
            local ok, parent = pcall(function()
                return f:GetParent()
            end)
            if ok and parent then
                found = parent
            end
            return
        end
        local kids = SafeGetChildren(f)
        for i = 1, #kids do
            walk(kids[i], depth + 1)
        end
    end
    walk(root, 0)
    return found
end

function InspectTree:EnsureInspectButton(host, root)
    if not host then
        return nil
    end
    -- Parent to Inspect root so scroll/clip on the Spec column can't bury the click.
    local parent = root or host
    if self.inspectBtn and self.inspectBtnHost == host and self.inspectBtn:GetParent() == parent then
        self.inspectBtn:ClearAllPoints()
        self.inspectBtn:SetPoint("BOTTOM", host, "TOP", 0, 10)
        self.inspectBtn:SetFrameLevel((parent:GetFrameLevel() or 1) + 80)
        return self.inspectBtn
    end
    if self.inspectBtn then
        self.inspectBtn:Hide()
        self.inspectBtn:SetParent(nil)
    end
    local btn = CreateFrame("Button", "MancerInspectShowTreeButton", parent, "UIPanelButtonTemplate")
    btn:SetSize(150, 24)
    btn:SetFrameStrata(parent:GetFrameStrata() or "DIALOG")
    btn:SetFrameLevel((parent:GetFrameLevel() or 1) + 80)
    btn:EnableMouse(true)
    btn:SetPoint("BOTTOM", host, "TOP", 0, 10)
    btn:SetText(L("INSPECT_TREE_BUTTON", "Show Talent Tree"))
    btn:SetScript("OnClick", function()
        local unit = GetInspectUnit()
        InspectTree:ShowForUnit(unit, InspectTree:GetPreferredSpecIndex(unit))
    end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(L("INSPECT_TREE_BUTTON", "Show Talent Tree"), 1, 0.82, 0.2)
        GameTooltip:AddLine(L("INSPECT_TREE_TIP", "Opens Class + Animation/Death/Rime with their inspected picks."), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    btn:Hide() -- visibility gated to Build tab only
    self.inspectBtn = btn
    self.inspectBtnHost = host
    return btn
end

-- Visible only while Inspect → Build is up (Specialization list host shown).
function InspectTree:UpdateInspectButtonVisibility()
    local root = InspectFrame or InspectPaperDollFrame
    if not root or not root.IsShown or not root:IsShown() then
        if self.inspectBtn then
            self.inspectBtn:Hide()
        end
        return
    end
    local host = FindSpecButtonParent(root)
    if not host then
        if self.inspectBtn then
            self.inspectBtn:Hide()
        end
        return
    end
    self:EnsureInspectButton(host, root)
    local buildShown = host.IsShown and host:IsShown()
    -- Some Ascension hosts stay "shown" while alpha'd; also require a visible Spec button.
    if buildShown then
        local kids = SafeGetChildren(host)
        local anySpecVisible = false
        for i = 1, #kids do
            if LooksLikeSpecButton(kids[i]) then
                local ok, shown = pcall(function()
                    return kids[i]:IsVisible()
                end)
                if ok and shown then
                    anySpecVisible = true
                    break
                end
            end
        end
        buildShown = anySpecVisible
    end
    if self.inspectBtn then
        if buildShown then
            self.inspectBtn:Show()
        else
            self.inspectBtn:Hide()
        end
    end
end

function InspectTree:TryHookInspectFrame()
    local root = InspectFrame or InspectPaperDollFrame
    if not root then
        return false
    end
    if self.hookedInspect then
        InspectTree:UpdateInspectButtonVisibility()
        return true
    end
    self.hookedInspect = true

    if root.HookScript then
        root:HookScript("OnShow", function()
            InspectTree:UpdateInspectButtonVisibility()
        end)
        root:HookScript("OnHide", function()
            InspectTree:ClearCoAStamps()
            if InspectTree.inspectBtn then
                InspectTree.inspectBtn:Hide()
            end
        end)
    end

    -- Hide/show when Character / PvP / Build tabs are clicked.
    local function hookTabButtons(f, depth)
        if not f or depth > 8 then
            return
        end
        local text = SafeGetText(f)
        if text and f.HookScript then
            local lower = string.lower(text)
            if lower:find("build", 1, true) or lower:find("character", 1, true) or lower:find("pvp", 1, true) then
                pcall(function()
                    f:HookScript("OnClick", function()
                        -- Defer so Ascension finishes swapping panels.
                        if not InspectTree._tabDriver then
                            InspectTree._tabDriver = CreateFrame("Frame")
                        end
                        InspectTree._tabDelay = 0.05
                        InspectTree._tabDriver:SetScript("OnUpdate", function(_, elapsed)
                            InspectTree._tabDelay = (InspectTree._tabDelay or 0) - elapsed
                            if InspectTree._tabDelay > 0 then
                                return
                            end
                            InspectTree._tabDriver:SetScript("OnUpdate", nil)
                            InspectTree:UpdateInspectButtonVisibility()
                        end)
                    end)
                end)
            end
        end
        local kids = SafeGetChildren(f)
        for i = 1, #kids do
            hookTabButtons(kids[i], depth + 1)
        end
    end
    hookTabButtons(root, 0)

    if root.IsShown and root:IsShown() then
        InspectTree:UpdateInspectButtonVisibility()
    end

    -- Spec button clicks → remember index from label "Specialization: N"
    local function hookSpecClicks(f, depth)
        if not f or depth > 8 then
            return
        end
        if LooksLikeSpecButton(f) and f.HookScript then
            pcall(function()
                f:HookScript("OnClick", function(self)
                    local text = SafeGetText(self) or ""
                    local n = tonumber(text:match("(%d+)"))
                    if n then
                        InspectTree.specIndex = n
                    end
                end)
            end)
        end
        local kids = SafeGetChildren(f)
        for i = 1, #kids do
            hookSpecClicks(kids[i], depth + 1)
        end
    end
    hookSpecClicks(root, 0)
    return true
end

function InspectTree:Init()
    if self.initialized then
        return
    end
    self.initialized = true
    self.activeStamps = {}
    self.specIndex = 1

    local driver = CreateFrame("Frame")
    self.driver = driver
    driver:RegisterEvent("PLAYER_LOGIN")
    driver:RegisterEvent("ADDON_LOADED")
    driver:RegisterEvent("PLAYER_TARGET_CHANGED")
    if driver.RegisterEvent then
        pcall(function()
            driver:RegisterEvent("INSPECT_READY")
        end)
        pcall(function()
            driver:RegisterEvent("INSPECT_TALENT_READY")
        end)
    end
    driver:SetScript("OnEvent", function(_, event, arg1)
        if event == "ADDON_LOADED" then
            if arg1 == "Blizzard_InspectUI" or arg1 == "Ascension_InspectUI" then
                InspectTree:TryHookInspectFrame()
            end
            if arg1 == "Ascension_CoATalents" then
                InspectTree:HookCoATalentFrame()
            end
            return
        end
        if event == "PLAYER_LOGIN" then
            InspectTree:TryHookInspectFrame()
            InspectTree:HookCoATalentFrame()
            return
        end
        InspectTree:TryHookInspectFrame()
        InspectTree:UpdateInspectButtonVisibility()
    end)

    -- Poll while Inspect is open so Character/PvP ↔ Build keeps the button gated.
    driver:SetScript("OnUpdate", function(_, elapsed)
        self._poll = (self._poll or 0) + elapsed
        if self._poll < 0.25 then
            return
        end
        self._poll = 0
        local root = InspectFrame or InspectPaperDollFrame
        if root and root.IsShown and root:IsShown() then
            InspectTree:TryHookInspectFrame()
            InspectTree:UpdateInspectButtonVisibility()
        elseif self.inspectBtn then
            self.inspectBtn:Hide()
        end
    end)
end

Mancer.InspectTree = InspectTree
