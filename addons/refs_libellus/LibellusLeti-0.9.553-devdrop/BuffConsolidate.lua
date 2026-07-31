-- Stack duplicate auras on the default buff bar (same spell ID → one icon + count).
--
-- Runs inside BuffFrame_UpdateAllBuffAnchors (same timing as Ascension consolidated/vanity).
-- BuffButton ClearAllPoints is required for a clean strip — without it, leftover Blizzard
-- anchors + our SetPoint produce overlapping icons. That taint was on the HUD/Animate
-- chain, not on BuffFrame buttons.
--
-- Flicker rule (0.9.498): Ascension calls UpdateAllBuffAnchors very often (duration ticks).
-- Only ClearAllPoints/SetPoint when the visible strip membership changes. Dupes stay at
-- alpha 0 (never Hide/Show fight) so AuraButton_Update re-Shows don't flash.

Mancer.BuffConsolidateModule = {}
local Mod = Mancer.BuffConsolidateModule

local MAX_BUFF_BUTTONS = 40
local applying = false
local lastLayoutSig = nil

local function IsEnabled()
    return MancerDB and MancerDB.consolidateBuffs == true
end

local function EnsureContainer()
    if Mod.container then
        return Mod.container
    end
    local frame = CreateFrame("Frame", "MancerRaiseBuffsContainer", UIParent)
    frame:Hide()
    frame:SetSize(1, 1)
    Mod.container = frame
    return frame
end

local function ReadAura(index)
    if not index or index < 1 then
        return nil
    end
    local name, _, _, count, _, _, _, _, _, _, spellId
    if UnitAura then
        name, _, _, count, _, _, _, _, _, _, spellId = UnitAura("player", index, "HELPFUL")
    elseif UnitBuff then
        name, _, _, count, _, _, _, _, _, _, spellId = UnitBuff("player", index)
    else
        return nil
    end
    if not name then
        return nil
    end
    return name, tonumber(spellId), math.max(1, tonumber(count) or 1)
end

local function AuraIndexForButton(button, fallbackIndex)
    if button and button.GetID then
        local id = button:GetID()
        if id and id > 0 then
            local name = ReadAura(id)
            if name then
                return id
            end
        end
    end
    return fallbackIndex
end

local function GroupKey(name, spellId)
    if spellId and spellId > 0 then
        return "id:" .. tostring(spellId)
    end
    if name and name ~= "" then
        return "nm:" .. name
    end
    return nil
end

local function ClearMarks(button)
    if not button then
        return
    end
    button.mancerRaiseDup = nil
    button.mancerRaiseKeeper = nil
    button.mancerRaiseTotal = nil
end

local function RestoreToBuffFrame(button)
    if not button then
        return
    end
    ClearMarks(button)
    if BuffFrame and button.parent ~= BuffFrame then
        button:SetParent(BuffFrame)
        button.parent = BuffFrame
    end
    if button.SetAlpha then
        button:SetAlpha(1)
    end
end

-- Keep dups invisible without Hide() — Ascension AuraButton_Update Show() + our Hide()
-- is what made the strip flash with a full bar.
local function SoftHideDup(button, container)
    if not button then
        return
    end
    button.mancerRaiseDup = true
    button.mancerRaiseKeeper = nil
    button.mancerRaiseTotal = nil
    if container and button.parent ~= container then
        button:SetParent(container)
        button.parent = container
    end
    if button.SetAlpha then
        button:SetAlpha(0)
    end
end

local function ShowKeeper(button, total)
    if not button then
        return
    end
    local already = button.mancerRaiseKeeper and button.mancerRaiseTotal == total
        and button.parent == BuffFrame
        and (not button.GetAlpha or button:GetAlpha() >= 0.99)
    button.mancerRaiseDup = nil
    button.mancerRaiseKeeper = true
    button.mancerRaiseTotal = total
    if already then
        return
    end
    if button.SetAlpha then
        button:SetAlpha(1)
    end
    if BuffFrame and button.parent ~= BuffFrame then
        button:SetParent(BuffFrame)
        button.parent = BuffFrame
    end
    local countFS = button.count or _G[button:GetName() .. "Count"]
    if countFS then
        countFS:SetText(tostring(total))
        countFS:Show()
    end
    if not button:IsShown() then
        button:Show()
    end
end

local function SoftReaffirmDups()
    local actual = BUFF_ACTUAL_DISPLAY or 0
    for i = 1, actual do
        local buff = _G["BuffButton" .. i]
        if buff and buff.mancerRaiseDup then
            SoftHideDup(buff, EnsureContainer())
        end
    end
end

local function MarkDuplicates()
    local container = EnsureContainer()
    local groups = {}
    local order = {}
    local seen = {}
    local actual = BUFF_ACTUAL_DISPLAY or 0
    local sigParts = {}

    -- Slack / row geometry belongs in the sig so enchant/consolidate chrome changes reflow.
    local slack = BuffFrame and (BuffFrame.numEnchants or 0) or 0
    if BuffFrame and ((BuffFrame.numConsolidated or 0) > 0 or (BuffFrame.numVanity or 0) > 0) then
        slack = slack + 1
    end
    sigParts[#sigParts + 1] = "n" .. tostring(actual) .. ":s" .. tostring(slack)

    for i = 1, actual do
        local button = _G["BuffButton" .. i]
        if button and not button.consolidated and not button.vanity then
            local auraIndex = AuraIndexForButton(button, i)
            local name, spellId, count = ReadAura(auraIndex)
            if not name and auraIndex ~= i then
                name, spellId, count = ReadAura(i)
            end
            local key = name and GroupKey(name, spellId)
            if key then
                local group = groups[key]
                if not group then
                    group = { buttons = {}, total = 0 }
                    groups[key] = group
                    table.insert(order, key)
                end
                group.total = group.total + (count or 1)
                table.insert(group.buttons, button)
                seen[button] = true
            end
        end
    end

    for _, key in ipairs(order) do
        local group = groups[key]
        if group then
            local keeperName = group.buttons[1] and group.buttons[1]:GetName() or "?"
            sigParts[#sigParts + 1] = key .. ":" .. group.total .. ":" .. #group.buttons .. ":" .. keeperName
            if #group.buttons > 1 then
                for idx, button in ipairs(group.buttons) do
                    if idx == 1 then
                        ShowKeeper(button, group.total)
                    else
                        SoftHideDup(button, container)
                    end
                end
            else
                local button = group.buttons[1]
                if button.mancerRaiseDup or button.mancerRaiseKeeper then
                    ClearMarks(button)
                    if button.SetAlpha then
                        button:SetAlpha(1)
                    end
                    if BuffFrame and button.parent ~= BuffFrame then
                        button:SetParent(BuffFrame)
                        button.parent = BuffFrame
                    end
                end
            end
        end
    end

    for i = 1, MAX_BUFF_BUTTONS do
        local button = _G["BuffButton" .. i]
        if button and not seen[button] and (button.mancerRaiseDup or button.mancerRaiseKeeper) then
            RestoreToBuffFrame(button)
        end
    end

    return table.concat(sigParts, "|")
end

local function SafeBuffClearAndSet(buff, ...)
    if not buff then
        return
    end
    -- BuffButtons are not secure. ClearAllPoints is required so we don't stack
    -- anchors on top of Ascension/Blizzard points (that was the overlapping mess).
    if buff.ClearAllPoints then
        buff:ClearAllPoints()
    end
    buff:SetPoint(...)
end

local function LayoutMainStrip()
    local buff, previousBuff, aboveBuff
    local numBuffs = 0
    local slack = BuffFrame.numEnchants or 0
    if (BuffFrame.numConsolidated or 0) > 0 or (BuffFrame.numVanity or 0) > 0 then
        slack = slack + 1
    end

    local actual = BUFF_ACTUAL_DISPLAY or 0
    local rowSpacing = BUFF_ROW_SPACING or 5
    local perRow = BUFFS_PER_ROW or 8

    for i = 1, actual do
        buff = _G["BuffButton" .. i]
        if not buff then
            -- skip
        elseif buff.consolidated then
            if ConsolidatedBuffsContainer and buff.parent ~= ConsolidatedBuffsContainer then
                buff:SetParent(ConsolidatedBuffsContainer)
                buff.parent = ConsolidatedBuffsContainer
            end
        elseif buff.vanity then
            if VanityBuffsContainer and buff.parent ~= VanityBuffsContainer then
                buff:SetParent(VanityBuffsContainer)
                buff.parent = VanityBuffsContainer
            end
        elseif buff.mancerRaiseDup then
            SoftHideDup(buff, EnsureContainer())
        else
            numBuffs = numBuffs + 1
            local index = numBuffs + slack
            if buff.parent ~= BuffFrame then
                if buff.count and buff.count.SetFontObject then
                    buff.count:SetFontObject(NumberFontNormal)
                end
                buff:SetParent(BuffFrame)
                buff.parent = BuffFrame
            end
            if buff.SetAlpha then
                buff:SetAlpha(1)
            end
            if not buff:IsShown() then
                buff:Show()
            end

            if (index > 1) and (mod(index, perRow) == 1) then
                if index == perRow + 1 and ConsolidatedBuffs then
                    SafeBuffClearAndSet(buff, "TOP", ConsolidatedBuffs, "BOTTOM", 0, -rowSpacing)
                elseif aboveBuff then
                    SafeBuffClearAndSet(buff, "TOP", aboveBuff, "BOTTOM", 0, -rowSpacing)
                else
                    SafeBuffClearAndSet(buff, "TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
                end
                aboveBuff = buff
            elseif index == 1 then
                SafeBuffClearAndSet(buff, "TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
            else
                if numBuffs == 1 then
                    if (BuffFrame.numEnchants or 0) > 0 and TemporaryEnchantFrame then
                        SafeBuffClearAndSet(buff, "TOPRIGHT", TemporaryEnchantFrame, "TOPLEFT", -5, 0)
                    elseif (BuffFrame.numVanity or 0) > 0 and VanityBuffs then
                        SafeBuffClearAndSet(buff, "TOPRIGHT", VanityBuffs, "TOPLEFT", -5, 0)
                    elseif (BuffFrame.numConsolidated or 0) > 0 and ConsolidatedBuffs then
                        SafeBuffClearAndSet(buff, "TOPRIGHT", ConsolidatedBuffs, "TOPLEFT", -5, 0)
                    elseif ConsolidatedBuffs then
                        SafeBuffClearAndSet(buff, "TOPRIGHT", ConsolidatedBuffs, "TOPRIGHT", 0, 0)
                    else
                        SafeBuffClearAndSet(buff, "TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
                    end
                elseif previousBuff then
                    SafeBuffClearAndSet(buff, "RIGHT", previousBuff, "LEFT", -5, 0)
                end
            end
            previousBuff = buff
        end
    end

    if ConsolidatedBuffsTooltip and ConsolidatedBuffsTooltip:IsShown() and ConsolidatedBuffs_UpdateAllAnchors then
        ConsolidatedBuffs_UpdateAllAnchors()
    end
    if VanityBuffsTooltip and VanityBuffsTooltip:IsShown() and VanityBuffs_UpdateAllAnchors then
        VanityBuffs_UpdateAllAnchors()
    end
end

local function RestoreAllAndOrig(orig)
    lastLayoutSig = nil
    for i = 1, MAX_BUFF_BUTTONS do
        local button = _G["BuffButton" .. i]
        if button and (button.mancerRaiseDup or button.mancerRaiseKeeper) then
            RestoreToBuffFrame(button)
            if button.Show then
                button:Show()
            end
        else
            ClearMarks(button)
        end
    end
    if orig then
        orig()
    end
end

function Mod:OnUpdateAllBuffAnchors(orig)
    if applying then
        return
    end
    applying = true

    if not IsEnabled() then
        -- Only unwind our marks when we previously laid out; otherwise just run Ascension.
        if lastLayoutSig ~= nil then
            RestoreAllAndOrig(orig)
        elseif orig then
            orig()
        end
        applying = false
        return
    end

    local sig = MarkDuplicates()
    if sig == lastLayoutSig then
        -- Duration ticks hit this path constantly — only re-assert dup invisibility.
        SoftReaffirmDups()
        applying = false
        return
    end

    lastLayoutSig = sig
    LayoutMainStrip()

    applying = false
end

function Mod:ApplyConsolidation()
    if not IsEnabled() then
        return
    end
    lastLayoutSig = nil
    if BuffFrame_UpdateAllBuffAnchors then
        BuffFrame_UpdateAllBuffAnchors()
    end
end

function Mod:Refresh()
    self:ApplyConsolidation()
end

function Mod:Init()
    if self.ready then
        return
    end
    self.ready = true

    if MancerDB then
        if MancerDB.consolidateBuffsFix320 == nil then
            MancerDB.consolidateBuffs = false
            MancerDB.consolidateBuffsFix320 = true
        elseif MancerDB.consolidateBuffs == nil then
            MancerDB.consolidateBuffs = false
        end
    end

    EnsureContainer()

    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
    end
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:SetScript("OnUpdate", nil)
    self.eventFrame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_ENTERING_WORLD" then
            lastLayoutSig = nil
            if BuffFrame_Update then
                BuffFrame_Update()
            end
        end
    end)

    if type(hooksecurefunc) == "function" and AuraButton_Update and not Mod._auraHooked then
        Mod._auraHooked = true
        hooksecurefunc("AuraButton_Update", function(buttonName, index, filter)
            if filter ~= "HELPFUL" or not IsEnabled() then
                return
            end
            local buff = _G[buttonName .. index]
            if buff and buff.mancerRaiseDup then
                -- Alpha only — Hide() here fought Ascension's Show and flashed the strip.
                if buff.SetAlpha then
                    buff:SetAlpha(0)
                end
            elseif buff and buff.mancerRaiseKeeper and buff.mancerRaiseTotal then
                local countFS = buff.count or _G[buff:GetName() .. "Count"]
                if countFS then
                    local want = tostring(buff.mancerRaiseTotal)
                    if countFS:GetText() ~= want then
                        countFS:SetText(want)
                    end
                    countFS:Show()
                end
            end
        end)
    end

    if type(BuffFrame_UpdateAllBuffAnchors) == "function" and not Mod._wrapped then
        Mod._wrapped = true
        local orig = BuffFrame_UpdateAllBuffAnchors
        Mod._origLayout = orig
        BuffFrame_UpdateAllBuffAnchors = function()
            Mod:OnUpdateAllBuffAnchors(orig)
        end
    end
end
