-- CoA talent-tree route overlay: toggleable, click-through highlights.
-- Modes: "next" (yellow NEXT marker only) or "full" (remaining path + joining arrows).
-- Highlights stay up while you spend — no need to dismiss between picks.
-- Visual language matches CoA chrome: gold arrows + yellow node rings (not addon neon).
Mancer.TalentOverlayModule = {}
local Overlay = Mancer.TalentOverlayModule

-- Same family as CoA SpendCircle / path arrows (UI.HUB_NODE_CIRCLE / HUB_NODE_ARROW).
local NODE_YELLOW_ATLAS = "talents-node-circle-yellow"
local NODE_YELLOW_PATH = "Interface\\TalentFrame\\talents"
local ARROW_HEAD = "Interface\\TalentFrame\\talents-arrow-head-yellow"
-- Gold / amber — same family as CoA talents-arrow-head-yellow.
local ACCENT = { 1.00, 0.82, 0.20, 1 }
local NEXT = { 1.00, 0.85, 0.25, 1 }
local FREE = { 0.45, 0.85, 1.00, 1 } -- free passives: cool ice (distinct from spend gold)
local SOON = { 1.00, 0.82, 0.20, 0.45 }
local BLOCKED = { 0.95, 0.45, 0.20, 0.95 }
-- Full-path tint on native CoA connection lines (arrow head stays yellow texture).
local PATH_CLASS = { 1.00, 0.82, 0.20, 1 }
local PATH_SPEC = { 1.00, 0.88, 0.35, 1 }
local PATH_FREE = { 0.45, 0.85, 1.00, 1 }
local PATH_ARROW_WHITE = { 1, 1, 1, 1 }

local function DB()
    MancerDB = MancerDB or {}
    MancerDB.talentOverlay = MancerDB.talentOverlay or {}
    if MancerDB.talentOverlay.show == nil then
        -- Off by default so the tree stays clean until you ask for it.
        MancerDB.talentOverlay.show = false
    end
    if MancerDB.talentOverlay.mode ~= "full" and MancerDB.talentOverlay.mode ~= "next" then
        MancerDB.talentOverlay.mode = "next"
    end
    return MancerDB.talentOverlay
end

local function GetRoute()
    return Mancer.TalentRouteModule
end

local function StripName(name)
    if not name then
        return nil
    end
    name = tostring(name)
    name = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    if CoACharacterAdvancementUtil and CoACharacterAdvancementUtil.StripArchitectTag then
        name = CoACharacterAdvancementUtil.StripArchitectTag(name) or name
    end
    return name:gsub("^%s+", ""):gsub("%s+$", "")
end

local function EntryName(entry)
    if not entry then
        return nil
    end
    return StripName(entry.Name or entry.name)
end

function Overlay:IsEnabled()
    return DB().show and true or false
end

function Overlay:GetMode()
    local mode = DB().mode
    if mode == "full" then
        return "full"
    end
    return "next"
end

function Overlay:SetMode(mode)
    DB().mode = (mode == "full") and "full" or "next"
    self:UpdateModeLabel()
    self:Refresh()
end

function Overlay:ToggleMode()
    self:SetMode(self:GetMode() == "full" and "next" or "full")
end

function Overlay:SetEnabled(enabled)
    DB().show = enabled and true or false
    self:ApplyVisibility()
    self:Refresh()
end

function Overlay:Toggle()
    self:SetEnabled(not self:IsEnabled())
end

local function ForceTexSize(tex, w, h)
    if not tex or not w or not h then
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

local function SetCoAYellowRing(tex, size)
    if not tex then
        return
    end
    ForceTexSize(tex, size, size)
    local ok = false
    if tex.SetAtlas then
        -- Ascension: 2nd arg IgnoreAtlasSize (or Blizzard useAtlasSize=false).
        local ignore = (Const and Const.TextureKit and Const.TextureKit.IgnoreAtlasSize)
        if ignore == nil then
            ignore = false
        end
        ok = pcall(function()
            tex:SetAtlas(NODE_YELLOW_ATLAS, ignore)
        end)
        if ok and tex.GetTexture and not tex:GetTexture() then
            ok = false
        end
    end
    if not ok then
        tex:SetTexture(NODE_YELLOW_PATH)
    end
    ForceTexSize(tex, size, size)
    -- Normal blend — ADD made ActionButton borders read as neon green wash.
    if tex.SetBlendMode then
        tex:SetBlendMode("BLEND")
    end
end

local function EnsureHighlight(node)
    if node.mancerRouteGlow and node.mancerRouteGlow.ringTight then
        return node.mancerRouteGlow
    end
    if node.mancerRouteGlow then
        node.mancerRouteGlow:Hide()
        node.mancerRouteGlow = nil
    end
    -- Parent to the talent button; mouse OFF so clicks still hit the talent.
    local glow = CreateFrame("Frame", nil, node)
    glow:SetAllPoints(node)
    glow:EnableMouse(false)
    glow:SetFrameLevel((node:GetFrameLevel() or 1) + 8)
    glow.usesCoARing = true
    glow.ringTight = true

    local isChoice = node.IsChoiceNode and node:IsChoiceNode()
    local nw = node.GetWidth and node:GetWidth() or 36
    local nh = node.GetHeight and node:GetHeight() or 36
    -- Snug over the node chrome (full CoA 50/30 ≈ 1.67 reads too chunky on the tree).
    local ringSize = math.max(nw, nh) * (isChoice and 1.40 or 1.28)

    -- Native yellow SpendCircle ring — same chrome as path gold, not ActionButton neon.
    local border = glow:CreateTexture(nil, "OVERLAY")
    border:SetPoint("CENTER", glow, "CENTER", 0, 0)
    SetCoAYellowRing(border, ringSize)
    border:SetVertexColor(1, 1, 1, 1)
    glow.border = border
    glow.edges = { border }

    -- Gold arrow head pointing at the pick (same atlas as path tips).
    local arrow = glow:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture(ARROW_HEAD)
    ForceTexSize(arrow, 12, 10)
    arrow:SetPoint("BOTTOM", glow, "TOP", 0, -1)
    arrow:SetVertexColor(1, 1, 1, 1)
    -- Texture points along connections; rotate so tip faces the node.
    if arrow.SetRotation then
        pcall(arrow.SetRotation, arrow, math.pi)
    end
    glow.arrow = arrow

    local label = glow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("BOTTOM", arrow, "TOP", 0, 0)
    label:SetText("")
    label:SetTextColor(NEXT[1], NEXT[2], NEXT[3], 1)
    if label.SetShadowColor then
        label:SetShadowColor(0, 0, 0, 1)
        label:SetShadowOffset(1, -1)
    end
    glow.label = label

    glow:Hide()
    node.mancerRouteGlow = glow
    return glow
end

local function SetGlowStyle(glow, style, labelText)
    if not glow then
        return
    end
    local c = NEXT
    local showChrome = true -- ring + arrow; path step numbers are label-only
    if style == "free" then
        c = FREE
    elseif style == "soon" then
        c = SOON
        showChrome = false
    elseif style == "blocked" then
        c = BLOCKED
    elseif style == "class" or style == "spec" then
        c = NEXT
    end

    if glow.border then
        if showChrome then
            glow.border:Show()
            -- Keep yellow atlas readable; only tint free/blocked off-gold.
            if style == "free" or style == "blocked" then
                glow.border:SetVertexColor(c[1], c[2], c[3], c[4] or 1)
            else
                glow.border:SetVertexColor(1, 1, 1, 1)
            end
        else
            glow.border:Hide()
        end
    end
    if glow.arrow then
        if showChrome then
            glow.arrow:Show()
            if style == "free" or style == "blocked" then
                glow.arrow:SetVertexColor(c[1], c[2], c[3], 1)
            else
                glow.arrow:SetVertexColor(1, 1, 1, 1)
            end
        else
            glow.arrow:Hide()
        end
    end
    if glow.label then
        glow.label:SetText(labelText or "")
        glow.label:SetTextColor(c[1], c[2], c[3], 1)
        if showChrome then
            glow.label:SetPoint("BOTTOM", glow.arrow or glow, "TOP", 0, 0)
        else
            -- Step numbers sit tight above the node (no arrow gap).
            glow.label:SetPoint("BOTTOM", glow, "TOP", 0, 1)
        end
    end
    glow.style = style
    glow:Show()
end

function Overlay:ClearGlows()
    for _, glow in pairs(self.activeGlows or {}) do
        if glow and glow.Hide then
            glow:Hide()
            if glow.label then
                glow.label:SetText("")
            end
        end
    end
    wipe(self.activeGlows)
end

function Overlay:ClearPathLinks()
    for _, tex in ipairs(self.pathLinkPool or {}) do
        if tex and tex.Hide then
            tex:Hide()
            if tex.SetRotation then
                pcall(tex.SetRotation, tex, 0)
            end
        end
    end
    self.pathLinkUsed = 0

    -- Restore native CoA connection art we tinted for Full Path.
    for conn, info in pairs(self.pathConnectionRestore or {}) do
        if conn then
            if info.thickness and conn.Line2 and conn.Line2.SetThickness then
                pcall(conn.Line2.SetThickness, conn.Line2, info.thickness)
            end
            local owner = info.owner
            if owner and owner.UpdateConnectionVisual then
                pcall(owner.UpdateConnectionVisual, owner, owner.visualState)
            elseif conn.UpdateConnectionState and TalentButtonUtil and TalentButtonUtil.ConnectionState then
                pcall(conn.UpdateConnectionState, conn, TalentButtonUtil.ConnectionState.Connected)
            end
        end
    end
    if self.pathConnectionRestore then
        wipe(self.pathConnectionRestore)
    end
end

local function FindNativeConnection(a, b)
    if not a or not b then
        return nil, nil
    end
    if a.connectionBranches and a.connectionBranches[b] then
        return a.connectionBranches[b], a
    end
    if b.connectionBranches and b.connectionBranches[a] then
        return b.connectionBranches[a], b
    end
    return nil, nil
end

local function CollectTreeNeighbors(tree)
    local adj = {}
    if not tree or not tree.EnumerateNodes then
        return adj
    end
    local function ensure(n)
        if not adj[n] then
            adj[n] = {}
        end
        return adj[n]
    end
    local function link(a, b)
        if not a or not b or a == b then
            return
        end
        ensure(a)[b] = true
        ensure(b)[a] = true
    end
    for node in tree:EnumerateNodes() do
        if node and node.connectionBranches then
            for target in pairs(node.connectionBranches) do
                link(node, target)
            end
        end
        -- Choice parents may hold branches; also walk sub-node branches.
        if node and node.nodes then
            for _, sub in ipairs(node.nodes) do
                if sub and sub.connectionBranches then
                    for target in pairs(sub.connectionBranches) do
                        link(sub, target)
                        link(node, target)
                    end
                end
            end
        end
    end
    return adj
end

function Overlay:BuildConnectionGraph()
    local adj = {}
    local frame = self.talentFrame
    if not frame or not frame.TreeView then
        return adj
    end
    local function merge(src)
        for node, neighbors in pairs(src) do
            adj[node] = adj[node] or {}
            for other in pairs(neighbors) do
                adj[node][other] = true
            end
        end
    end
    merge(CollectTreeNeighbors(frame.TreeView.ClassTree))
    merge(CollectTreeNeighbors(frame.TreeView.SpecTree))
    return adj
end

-- Shortest walk along the tree's native arrows between two talent buttons.
local function BfsTreePath(adj, startNode, goalNode)
    if not startNode or not goalNode then
        return nil
    end
    if startNode == goalNode then
        return { startNode }
    end
    if not adj[startNode] or not adj[goalNode] then
        return nil
    end
    local queue = { startNode }
    local head = 1
    local prev = { [startNode] = false }
    while queue[head] do
        local cur = queue[head]
        head = head + 1
        for nxt in pairs(adj[cur] or {}) do
            if prev[nxt] == nil then
                prev[nxt] = cur
                if nxt == goalNode then
                    local path = { goalNode }
                    local p = cur
                    while p do
                        table.insert(path, 1, p)
                        p = prev[p]
                        if p == false then
                            break
                        end
                    end
                    return path
                end
                table.insert(queue, nxt)
            end
        end
    end
    return nil
end

function Overlay:HighlightNativeEdge(a, b, color)
    local conn, owner = FindNativeConnection(a, b)
    if not conn or not color then
        return false
    end
    self.pathConnectionRestore = self.pathConnectionRestore or {}
    if not self.pathConnectionRestore[conn] then
        local thickness
        if conn.Line2 and conn.Line2.GetThickness then
            local ok, t = pcall(conn.Line2.GetThickness, conn.Line2)
            if ok then
                thickness = t
            end
        end
        self.pathConnectionRestore[conn] = { owner = owner, thickness = thickness }
    end
    if conn.Line2 then
        if conn.Line2.SetThickness then
            -- Slightly above native; keep it looking like CoA art, not a neon beam.
            pcall(conn.Line2.SetThickness, conn.Line2, 3)
        end
        if conn.Line2.SetVertexColor then
            conn.Line2:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
        end
    end
    if conn.Arrow and conn.Arrow.Texture then
        local tex = conn.Arrow.Texture
        if tex.SetTexture then
            pcall(tex.SetTexture, tex, "Interface\\TalentFrame\\talents-arrow-head-yellow")
        end
        -- Leave head untinted so the yellow atlas reads as CoA gold, not cyan.
        if tex.SetVertexColor then
            tex:SetVertexColor(PATH_ARROW_WHITE[1], PATH_ARROW_WHITE[2], PATH_ARROW_WHITE[3], 1)
        end
        if conn.arrowAngle and tex.SetRotation then
            pcall(tex.SetRotation, tex, conn.arrowAngle)
        end
    end
    return true
end

function Overlay:HighlightTreeWalk(nodePath, color)
    if not nodePath or #nodePath < 2 then
        return
    end
    for i = 1, #nodePath - 1 do
        self:HighlightNativeEdge(nodePath[i], nodePath[i + 1], color)
    end
end

function Overlay:CollectRankMap()
    local ranks = {}
    local frame = self.talentFrame
    if not frame or not frame.TreeView then
        return ranks
    end

    local function note(name, rank, entryId)
        rank = tonumber(rank) or 0
        -- Only record positive ranks. Emitting 0 for every unlearned node wiped the
        -- GetKnownTalents baseline in BuildTakenRankMap and left name-only route
        -- picks (e.g. Depravity) stuck as NEXT after they were already 1/1.
        if rank <= 0 then
            return
        end
        if name and name ~= "" then
            ranks[name] = math.max(ranks[name] or 0, rank)
        end
        entryId = tonumber(entryId)
        if entryId then
            local idKey = "#" .. tostring(entryId)
            ranks[idKey] = math.max(ranks[idKey] or 0, rank)
        end
    end

    local function effectiveRank(nodeRank, entryId)
        local rank = tonumber(nodeRank) or 0
        if not entryId or not C_CharacterAdvancement or not C_CharacterAdvancement.GetPendingRankByEntryID then
            return rank
        end
        local ok, pending = pcall(C_CharacterAdvancement.GetPendingRankByEntryID, entryId)
        -- pending can be 0 after an unlearn — must not use `if pending then` (0 is falsy).
        if ok and pending ~= nil then
            local p = tonumber(pending) or 0
            -- max(): pending learn (0→1) still applies; a stale pending=0 must not
            -- wipe an already-updated node.rank of 1 (NEXT-on-taken bug).
            return math.max(rank, p)
        end
        return rank
    end

    local function scanNode(node)
        if not node or not node.entry then
            return
        end
        local entryId = node.entry.ID or node.entry.id
        note(EntryName(node.entry), effectiveRank(node.rank, entryId), entryId)
        if node.nodes then
            for _, sub in ipairs(node.nodes) do
                if sub and sub.entry then
                    local subId = sub.entry.ID or sub.entry.id
                    note(EntryName(sub.entry), effectiveRank(sub.rank, subId), subId)
                end
            end
        end
    end

    local function scanTree(tree)
        if not tree or not tree.EnumerateNodes then
            return
        end
        for node in tree:EnumerateNodes() do
            scanNode(node)
        end
    end
    scanTree(frame.TreeView.ClassTree)
    scanTree(frame.TreeView.SpecTree)
    return ranks
end

-- Legacy name list for anything still calling CollectPendingNames.
function Overlay:CollectPendingNames()
    local names = {}
    for name, rank in pairs(self:CollectRankMap()) do
        if type(name) == "string" and name:sub(1, 1) ~= "#" and rank and rank > 0 then
            table.insert(names, name)
        end
    end
    return names
end

function Overlay:FindNodesByPick(wantName, entryId)
    local found = {}
    local seen = {}
    local route = GetRoute()
    if not self.talentFrame or not self.talentFrame.TreeView then
        return found
    end
    entryId = tonumber(entryId)

    local function add(node)
        if not node or seen[node] then
            return
        end
        seen[node] = true
        table.insert(found, node)
    end

    -- Map choice option → visible diamond/hex parent (subs live on SelectionFrame).
    local choiceParentOf = {}
    local function indexTree(tree)
        if not tree or not tree.EnumerateNodes then
            return
        end
        for node in tree:EnumerateNodes() do
            if node and node.nodes then
                for _, sub in ipairs(node.nodes) do
                    if sub then
                        choiceParentOf[sub] = node
                    end
                end
            end
        end
    end
    indexTree(self.talentFrame.TreeView.ClassTree)
    indexTree(self.talentFrame.TreeView.SpecTree)

    local function addMatched(node)
        add(node)
        local parent = choiceParentOf[node]
        if parent then
            add(parent)
        end
    end

    local function consider(node)
        if not node or not node:IsShown() then
            return
        end
        -- Unselected choice parents often have nil entry — still walk their options.
        local hasSubs = node.nodes and #node.nodes > 0
        if not node.entry and not hasSubs then
            return
        end

        if entryId then
            if node.entry then
                local id = tonumber(node.entry.ID or node.entry.id)
                if id == entryId then
                    addMatched(node)
                end
            end
            if hasSubs then
                for _, sub in ipairs(node.nodes) do
                    if sub and sub.entry then
                        local subId = tonumber(sub.entry.ID or sub.entry.id)
                        if subId == entryId then
                            add(node)
                            addMatched(sub)
                        end
                    end
                end
            end
            return
        end

        if node.entry then
            local name = EntryName(node.entry)
            if name and route and route.NamesEqual and route:NamesEqual(name, wantName) then
                addMatched(node)
                return
            end
        end
        if hasSubs then
            for _, sub in ipairs(node.nodes) do
                if sub and sub.entry then
                    local subName = EntryName(sub.entry)
                    if subName and route and route.NamesEqual and route:NamesEqual(subName, wantName) then
                        add(node)
                        addMatched(sub)
                    end
                end
            end
        end
    end

    local function scanTree(tree)
        if not tree or not tree.EnumerateNodes then
            return
        end
        for node in tree:EnumerateNodes() do
            consider(node)
        end
    end
    scanTree(self.talentFrame.TreeView.ClassTree)
    scanTree(self.talentFrame.TreeView.SpecTree)

    -- Wrong/stale entryId must not blank the highlight — fall back to exact name.
    if #found == 0 and wantName and entryId and route and route.NamesEqual then
        local function considerByName(node)
            if not node or not node:IsShown() then
                return
            end
            local hasSubs = node.nodes and #node.nodes > 0
            if not node.entry and not hasSubs then
                return
            end
            if node.entry then
                local name = EntryName(node.entry)
                if name and route:NamesEqual(name, wantName) then
                    addMatched(node)
                    return
                end
            end
            if hasSubs then
                for _, sub in ipairs(node.nodes) do
                    if sub and sub.entry then
                        local subName = EntryName(sub.entry)
                        if subName and route:NamesEqual(subName, wantName) then
                            add(node)
                            addMatched(sub)
                        end
                    end
                end
            end
        end
        local function scanByName(tree)
            if not tree or not tree.EnumerateNodes then
                return
            end
            for node in tree:EnumerateNodes() do
                considerByName(node)
            end
        end
        scanByName(self.talentFrame.TreeView.ClassTree)
        scanByName(self.talentFrame.TreeView.SpecTree)
    end

    -- Fallback: fuzzy name only when no entryId and no exact hits.
    if #found == 0 and wantName and not entryId and route and route.NamesMatch then
        local function considerFuzzy(node)
            if not node or not node:IsShown() then
                return
            end
            local hasSubs = node.nodes and #node.nodes > 0
            if node.entry then
                local name = EntryName(node.entry)
                if name and route:NamesMatch(name, wantName) then
                    addMatched(node)
                    return
                end
            end
            if hasSubs then
                for _, sub in ipairs(node.nodes) do
                    if sub and sub.entry then
                        local subName = EntryName(sub.entry)
                        if subName and route:NamesMatch(subName, wantName) then
                            add(node)
                            addMatched(sub)
                        end
                    end
                end
            end
        end
        scanTree = function(tree)
            if not tree or not tree.EnumerateNodes then
                return
            end
            for node in tree:EnumerateNodes() do
                considerFuzzy(node)
            end
        end
        scanTree(self.talentFrame.TreeView.ClassTree)
        scanTree(self.talentFrame.TreeView.SpecTree)
    end

    return found
end

function Overlay:FindNodesByName(wantName)
    return self:FindNodesByPick(wantName, nil)
end

function Overlay:HighlightPick(name, entryId, style, labelText)
    if not name and not entryId then
        return
    end
    for _, node in ipairs(self:FindNodesByPick(name, entryId)) do
        local glow = EnsureHighlight(node)
        -- Prefer the NEXT label on the visible choice diamond, not only the popup option.
        local showLabel = labelText
        if showLabel and node.IsChoiceNode and node:IsChoiceNode() then
            showLabel = labelText
        elseif showLabel and node.isSubNode then
            -- Sub-option still gets a ring; keep label only if no choice parent was highlighted.
            local hasChoiceGlow = false
            for g in pairs(self.activeGlows or {}) do
                local p = g:GetParent()
                if p and p.IsChoiceNode and p:IsChoiceNode() then
                    hasChoiceGlow = true
                    break
                end
            end
            if hasChoiceGlow then
                showLabel = ""
            end
        end
        SetGlowStyle(glow, style, showLabel)
        self.activeGlows[glow] = glow
    end
end

function Overlay:HighlightName(name, style, labelText)
    self:HighlightPick(name, nil, style, labelText)
end

-- Live rank on the open CoA tree (node.rank / choice subs). Used so NEXT never
-- sticks on a talent that already shows 1/1 when the rank map missed it.
function Overlay:GetVisibleRankForPick(name, entryId)
    local best = 0
    local route = GetRoute()
    entryId = tonumber(entryId)
    for _, node in ipairs(self:FindNodesByPick(name, entryId)) do
        if node.entry then
            best = math.max(best, tonumber(node.rank) or 0)
        end
        if node.nodes then
            for _, sub in ipairs(node.nodes) do
                if sub and sub.entry then
                    local sid = tonumber(sub.entry.ID or sub.entry.id)
                    local sname = EntryName(sub.entry)
                    local match = (entryId and sid == entryId)
                        or (name and route and route.NamesEqual and route:NamesEqual(sname, name))
                    if match then
                        best = math.max(best, tonumber(sub.rank) or 0)
                    end
                end
            end
        end
    end
    return best
end

-- First route entry still short of need. When the pick is on the open tree,
-- trust node.rank only — the known-talent map must not skip an unlearned
-- visible node (Master Animator 7117 was skipped → NEXT jumped to Underking).
function Overlay:ResolveLiveNextPick(order, rankMap, kind)
    local route = GetRoute()
    if not route or not order then
        return nil
    end
    for _, entry in ipairs(order) do
        local name, need, entryId
        if type(entry) == "table" then
            name = entry.name
            need = math.max(1, tonumber(entry.ranks) or 1)
            entryId = tonumber(entry.entryId)
        else
            name, need, entryId = entry, 1, nil
        end
        if not name then
            -- skip
        else
            local nodes = self:FindNodesByPick(name, entryId)
            if #nodes > 0 then
                if self:GetVisibleRankForPick(name, entryId) < need then
                    return { name = name, entryId = entryId, kind = kind, need = need }
                end
            elseif not route:HasAtLeastRank(name, rankMap, need, entryId) then
                return { name = name, entryId = entryId, kind = kind, need = need }
            end
        end
    end
    return nil
end

local function PickMatches(route, pick, nextPick)
    if not pick or not nextPick then
        return false
    end
    local aId, bId = tonumber(pick.entryId), tonumber(nextPick.entryId)
    if aId and bId and aId == bId then
        return true
    end
    if pick.name and nextPick.name and route and route.NamesEqual then
        return route:NamesEqual(pick.name, nextPick.name)
    end
    return false
end

function Overlay:DrawRemainingPath(path, color, nextPick, nextStyle, nextLabel)
    local route = GetRoute()
    if not path then
        return
    end
    local adj = self:BuildConnectionGraph()
    local routeNodes = {}
    local markedNext = false
    for i, pick in ipairs(path) do
        local nodes = self:FindNodesByPick(pick.name, pick.entryId)
        local node = nodes[1]
        local isNext = (not markedNext) and PickMatches(route, pick, nextPick)
        if isNext then
            markedNext = true
        end
        if node then
            if isNext then
                self:HighlightPick(pick.name, pick.entryId, nextStyle or "class", nextLabel or "NEXT")
            else
                self:HighlightPick(pick.name, pick.entryId, "soon", tostring(i))
            end
            local last = routeNodes[#routeNodes]
            if last ~= node then
                table.insert(routeNodes, node)
            end
        end
    end
    -- Walk native tree arrows between consecutive route stops (BFS through junctions).
    for i = 1, #routeNodes - 1 do
        local walk = BfsTreePath(adj, routeNodes[i], routeNodes[i + 1])
        if walk and #walk >= 2 then
            self:HighlightTreeWalk(walk, color)
        end
    end
end

function Overlay:UpdateStatusText(picks)
    if not self.statusText then
        return
    end
    local lines = {}
    if picks.free then
        table.insert(lines, string.format("FREE L%d: %s", picks.free.level or 0, picks.free.name))
    end
    if picks.class then
        table.insert(lines, "Class: " .. picks.class.name)
    end
    if picks.spec then
        local specLine = "Spec: " .. picks.spec.name
        if picks.spec.blocked and picks.spec.blockReason then
            specLine = specLine .. " (" .. picks.spec.blockReason .. ")"
        end
        table.insert(lines, specLine)
    end
    if #lines == 0 then
        table.insert(lines, "Route complete (or nodes not on this tree)")
    end
    if self:GetMode() == "full" then
        table.insert(lines, "Full path · click-through")
    else
        table.insert(lines, "Next node · click-through")
    end
    self.statusText:SetText(table.concat(lines, "  ·  "))
end

function Overlay:Refresh()
    if not self.hooked or not self.talentFrame then
        return
    end
    self:ClearGlows()
    self:ClearPathLinks()
    if not self:IsEnabled() or not self.talentFrame:IsShown() then
        if self.overlayLayer then
            self.overlayLayer:Hide()
        end
        self:UpdateToggleLabel()
        self:UpdateModeLabel()
        return
    end

    if self.overlayLayer then
        self.overlayLayer:Show()
    end

    local route = GetRoute()
    if not route then
        return
    end

    local pending = self:CollectRankMap()
    local picks = route.GetNextOverlayPicks and route:GetNextOverlayPicks(pending) or {}
    local ranks = picks.taken or route:BuildTakenRankMap(pending)

    -- Prefer live node ranks so a finished tree never NEXT-highlights 1/1 picks
    -- the rank map still thinks are missing (Depravity after early route).
    local level = UnitLevel and UnitLevel("player") or 0
    picks.free = nil
    for _, entry in ipairs(route.FREE_PASSIVES or {}) do
        if (entry.level or 0) <= level then
            local nodes = self:FindNodesByPick(entry.name)
            local stillNeeded
            if #nodes > 0 then
                stillNeeded = self:GetVisibleRankForPick(entry.name) < 1
            else
                stillNeeded = not route:HasAtLeastRank(entry.name, ranks, 1)
            end
            if stillNeeded then
                picks.free = {
                    name = entry.name,
                    level = entry.level,
                    why = entry.why,
                    kind = "free",
                }
                break
            end
        end
    end
    picks.class = self:ResolveLiveNextPick(route.OVERLAY_CLASS_ORDER, ranks, "class")
    picks.spec = self:ResolveLiveNextPick(route.OVERLAY_SPEC_ORDER, ranks, "spec")

    local function applyAotDGate()
        if not picks.spec or picks.spec.name ~= "Army of the Dead" then
            return
        end
        if route:HasAtLeastRank("Raise: Abomination", ranks, 1, 29364)
            or self:GetVisibleRankForPick("Raise: Abomination", 29364) >= 1 then
            return
        end
        picks.spec.blocked = true
        picks.spec.blockReason = "Take Raise: Abomination (Class) first"
        if not picks.class or picks.class.name ~= "Raise: Abomination" then
            picks.class = {
                name = "Raise: Abomination",
                entryId = 29364,
                kind = "class",
                why = "Required for Army of the Dead",
            }
        end
    end
    applyAotDGate()

    if self:GetMode() == "full" and route.GetOverlayPaths then
        local paths = route:GetOverlayPaths(pending)
        local function filterInvested(path)
            local out = {}
            for _, pick in ipairs(path or {}) do
                local need = pick.need or 1
                local nodes = self:FindNodesByPick(pick.name, pick.entryId)
                local stillNeeded
                if #nodes > 0 then
                    stillNeeded = self:GetVisibleRankForPick(pick.name, pick.entryId) < need
                else
                    stillNeeded = not route:HasAtLeastRank(pick.name, ranks, need, pick.entryId)
                end
                if stillNeeded then
                    table.insert(out, pick)
                end
            end
            return out
        end
        paths.free = filterInvested(paths.free)
        paths.class = filterInvested(paths.class)
        paths.spec = filterInvested(paths.spec)
        if paths.free and #paths.free > 0 then
            self:DrawRemainingPath(paths.free, PATH_FREE, picks.free, "free", "FREE")
        end
        if paths.class and #paths.class > 0 then
            self:DrawRemainingPath(paths.class, PATH_CLASS, picks.class, "class", "NEXT")
        end
        if paths.spec and #paths.spec > 0 then
            local style = (picks.spec and picks.spec.blocked) and "blocked" or "spec"
            local label = (picks.spec and picks.spec.blocked) and "NEED ABOM" or "NEXT"
            self:DrawRemainingPath(paths.spec, PATH_SPEC, picks.spec, style, label)
        end
        -- Re-assert immediate next (covers AotD→Abom injection not in the class queue).
        if picks.free then
            self:HighlightPick(picks.free.name, picks.free.entryId, "free", "FREE")
        end
        if picks.class then
            self:HighlightPick(picks.class.name, picks.class.entryId, "class", "NEXT")
        end
        if picks.spec then
            local style = picks.spec.blocked and "blocked" or "spec"
            local label = picks.spec.blocked and "NEED ABOM" or "NEXT"
            self:HighlightPick(picks.spec.name, picks.spec.entryId, style, label)
        end
    else
        if picks.free then
            self:HighlightPick(picks.free.name, picks.free.entryId, "free", "FREE")
        end
        if picks.class then
            self:HighlightPick(picks.class.name, picks.class.entryId, "class", "NEXT")
        end
        if picks.spec then
            local style = picks.spec.blocked and "blocked" or "spec"
            local label = picks.spec.blocked and "NEED ABOM" or "NEXT"
            self:HighlightPick(picks.spec.name, picks.spec.entryId, style, label)
        end
    end

    self:UpdateStatusText(picks)
    self:UpdateToggleLabel()
    self:UpdateModeLabel()
end

function Overlay:UpdateToggleLabel()
    if not self.toggleBtn then
        return
    end
    if self:IsEnabled() then
        self.toggleBtn:SetText("Hide Route")
    else
        self.toggleBtn:SetText("Show Route")
    end
end

function Overlay:UpdateModeLabel()
    if not self.modeBtn then
        return
    end
    if self:GetMode() == "full" then
        self.modeBtn:SetText("Full Path")
    else
        self.modeBtn:SetText("Next Node")
    end
end

function Overlay:ApplyVisibility()
    if self.overlayLayer then
        if self:IsEnabled() and self.talentFrame and self.talentFrame:IsShown() then
            self.overlayLayer:Show()
        else
            self.overlayLayer:Hide()
        end
    end
    self:UpdateToggleLabel()
    self:UpdateModeLabel()
end

local function MakeChromeButton(name, parent, width, labelText)
    -- Native panel button art — same family as CoA footer / Blizzard dialogs.
    local btn = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    btn:SetSize(width, 24)
    btn:SetFrameStrata(parent:GetFrameStrata() or "DIALOG")
    btn:SetFrameLevel((parent:GetFrameLevel() or 1) + 50)
    btn:EnableMouse(true)
    btn:RegisterForClicks("AnyUp")
    btn:SetText(labelText or "")
    return btn
end

function Overlay:HookTalentFrame(frame)
    if not frame or self.hooked then
        return
    end
    self.talentFrame = frame
    self.hooked = true
    self.activeGlows = {}
    self.pathLinkPool = {}
    self.pathLinkUsed = 0

    -- Toggle button: mouse-enabled. Always available on the talent frame.
    local btn = MakeChromeButton("MancerTalentRouteToggle", frame, 100, "Show Route")
    btn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -36, -28)
    btn:SetScript("OnClick", function()
        Overlay:Toggle()
    end)
    btn:SetScript("OnEnter", function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine((Mancer.DISPLAY_NAME or "Libellus Leti") .. " talent route", 1, 0.82, 0.2)
            GameTooltip:AddLine("Toggle route highlights on the tree.", 1, 1, 1, true)
            GameTooltip:AddLine("Highlights are click-through — keep spending with the overlay on.", 0.75, 0.72, 0.60, true)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    self.toggleBtn = btn

    -- Mode: Next Node (gold NEXT) vs Full Path (remaining queue + CoA arrows).
    local modeBtn = MakeChromeButton("MancerTalentRouteMode", frame, 92, "Next Node")
    modeBtn:SetPoint("RIGHT", btn, "LEFT", -6, 0)
    modeBtn:SetScript("OnClick", function()
        Overlay:ToggleMode()
    end)
    modeBtn:SetScript("OnEnter", function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine("Route display mode", 1, 0.82, 0.2)
            GameTooltip:AddLine("Next Node — only the gold NEXT highlight.", 1, 1, 1, true)
            GameTooltip:AddLine("Full Path — remaining picks; lights the tree's own gold arrows between them.", 0.75, 0.72, 0.60, true)
            GameTooltip:Show()
        end
    end)
    modeBtn:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    self.modeBtn = modeBtn

    -- Overlay chrome: mouse DISABLED so you never have to dismiss it to click talents.
    local layer = CreateFrame("Frame", "MancerTalentRouteOverlay", frame)
    layer:SetAllPoints(frame)
    layer:EnableMouse(false)
    layer:SetFrameLevel((frame:GetFrameLevel() or 1) + 20)
    layer:Hide()
    self.overlayLayer = layer

    local linkLayer = CreateFrame("Frame", "MancerTalentRouteLinks", layer)
    linkLayer:SetAllPoints(layer)
    linkLayer:EnableMouse(false)
    linkLayer:SetFrameLevel((layer:GetFrameLevel() or 1) + 1)
    self.pathLinkLayer = linkLayer

    local status = layer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    status:SetPoint("TOPLEFT", layer, "TOPLEFT", 140, -32)
    status:SetPoint("TOPRIGHT", layer, "TOPRIGHT", -230, -32)
    status:SetJustifyH("LEFT")
    status:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    if status.SetShadowColor then
        status:SetShadowColor(0, 0, 0, 1)
        status:SetShadowOffset(1, -1)
    end
    status:SetText("")
    self.statusText = status

    local function onShow()
        Overlay:ApplyVisibility()
        Overlay:Refresh()
    end
    local function onHide()
        Overlay:ClearGlows()
        Overlay:ClearPathLinks()
        if Overlay.overlayLayer then
            Overlay.overlayLayer:Hide()
        end
    end

    frame:HookScript("OnShow", onShow)
    frame:HookScript("OnHide", onHide)

    if frame:IsShown() then
        onShow()
    else
        self:UpdateToggleLabel()
        self:UpdateModeLabel()
    end
end

function Overlay:TryHook()
    if self.hooked then
        return true
    end
    if CoATalentFrame then
        self:HookTalentFrame(CoATalentFrame)
        return true
    end
    return false
end

function Overlay:Init()
    if self.initialized then
        return
    end
    self.initialized = true
    self.activeGlows = {}

    local driver = CreateFrame("Frame")
    self.driver = driver
    driver:RegisterEvent("PLAYER_LOGIN")
    driver:RegisterEvent("ADDON_LOADED")
    driver:RegisterEvent("PLAYER_LEVEL_UP")
    if C_CharacterAdvancement then
        driver:RegisterEvent("CHARACTER_ADVANCEMENT_PENDING_BUILD_UPDATED")
        pcall(function()
            driver:RegisterEvent("CHARACTER_ADVANCEMENT_UPDATE_ENTRIES_RESULT")
        end)
        pcall(function()
            driver:RegisterEvent("CHARACTER_ADVANCEMENT_KNOWN_ENTRIES_CHANGED")
        end)
        pcall(function()
            driver:RegisterEvent("CHARACTER_ADVANCEMENT_LEARN_RESULT")
        end)
        pcall(function()
            driver:RegisterEvent("CHARACTER_ADVANCEMENT_UNLEARN_RESULT")
        end)
    end

    driver:SetScript("OnEvent", function(_, event, arg1)
        if event == "ADDON_LOADED" then
            if arg1 == "Ascension_CoATalents" or arg1 == "Ascension_TalentUI" then
                Overlay:TryHook()
            end
            return
        end
        if event == "PLAYER_LOGIN" then
            Overlay:TryHook()
            return
        end
        if Overlay.hooked and Overlay:IsEnabled() then
            if Mancer.Ascension and Mancer.Ascension.InvalidateTalentCache then
                Mancer.Ascension.InvalidateTalentCache()
            end
            -- Defer so CoA nodes finish UpdateDisplay after spend / unlearn.
            Overlay.pendingRefresh = true
            Overlay.refreshDelay = 0
        end
    end)

    driver:SetScript("OnUpdate", function(_, elapsed)
        if not Overlay.pendingRefresh then
            return
        end
        Overlay.refreshDelay = (Overlay.refreshDelay or 0) + elapsed
        -- Unlearn pending ranks often settle slightly later than spends.
        if Overlay.refreshDelay < 0.12 then
            return
        end
        Overlay.pendingRefresh = false
        Overlay.refreshDelay = 0
        Overlay:Refresh()
    end)

    -- CoA may already be loaded before Mancer.
    self:TryHook()
end
