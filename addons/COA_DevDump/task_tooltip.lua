-- task_tooltip.lua - the tooltip gap-fill micro-scan (addons/backlog.md #2).
--
-- Renders the game's OWN resolved tooltip for a bounded, caller-supplied spell
-- id list and lands the lines RAW. The render is the ARBITER: a $-variable
-- description resolves here, a NULL description shows whatever the game truly
-- has (accept-empty only on the game's verdict). The ~13-id list derives
-- OFFLINE from the inventory's description holes - this task stays generic.
--
-- Two render methods, both pcall'd per id, first success recorded:
--   SetSpellByID  (if this backported client carries it)
--   SetHyperlink("spell:<id>")  (3.3.5-native fallback, equivalent render)

local ADDON, D = ...

local tip -- lazy: one hidden tooltip, created on first run

local function renderLines(id)
    if not tip then
        tip = CreateFrame("GameTooltip", "COA_DevDumpTip", UIParent, "GameTooltipTemplate")
    end
    tip:SetOwner(UIParent, "ANCHOR_NONE")

    local method
    if tip.SetSpellByID then
        local ok = pcall(tip.SetSpellByID, tip, id)
        if ok then method = "SetSpellByID" end
    end
    if not method then
        local ok = pcall(tip.SetHyperlink, tip, "spell:" .. id)
        if ok then method = "SetHyperlink" end
    end
    if not method then
        tip:Hide()
        return { error = "no render method succeeded" }
    end

    local lines = {}
    for i = 1, tip:NumLines() do
        local left = _G["COA_DevDumpTipTextLeft" .. i]
        local right = _G["COA_DevDumpTipTextRight" .. i]
        lines[i] = {
            left = left and left:GetText() or nil,
            right = right and right:GetText() or nil,
        }
    end
    tip:Hide()
    return { method = method, numLines = #lines, lines = lines }
end

D.RegisterTask{
    name = "tooltip",
    mode = "oneshot",
    help = "tooltip <id1,id2,...> - render the game's resolved tooltip per spell id, land lines RAW",
    run = function(args)
        local ids = {}
        if D.Trim(args or "") == "holes" then
            -- the baked description-hole list (payload_tooltipids.lua, derived by
            -- addons/tools/derive_tooltip_holes.py - too long for the chat box)
            for _, id in ipairs((D.payloads and D.payloads["tooltip_holes"]) or {}) do
                ids[#ids + 1] = id
            end
        else
            for id in (args or ""):gmatch("%d+") do
                ids[#ids + 1] = tonumber(id)
            end
        end
        if #ids == 0 then
            D.Print("Usage: /coadump r tooltip <id1,id2,...>  (or: /coadump r tooltip holes)")
            return
        end

        local payload = D.Begin("tooltip", args)
        payload.ids = ids
        payload.tips = {}
        local rendered = 0
        for _, id in ipairs(ids) do
            local r = renderLines(id)
            payload.tips[tostring(id)] = r
            if r.lines then rendered = rendered + 1 end
        end
        D.Commit(("tooltip: %d/%d ids rendered"):format(rendered, #ids))
    end,
}
