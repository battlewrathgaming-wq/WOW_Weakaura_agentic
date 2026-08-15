-- COA_Landmarks core.lua - namespace, init order, slash surface.
--
-- A self-authored scrapbook of places on the world map. You mark somewhere that
-- matters to you, write why, and get back to it later.
--
-- ★★★ RULING: meaning, exactly-where and which-zone are OURS; HOW TO TRAVEL is NOT
--   ★ Keeps the addon out of routing territory permanently - a scope refusal,
--   not a backlog item.
-- What it restores (L18) - three things, and the fourth is not ours:
--   meaning, why this place matters   -> the note, pulled on hover
--   exactly where                     -> the beacon, inside ~1,500 yd
--   which zone, roughly where         -> the map pin and the widget's Zone line
--   how to travel there               -> NOT OURS. Players already know.
--
-- It is not a gathering database, a quest helper, a travel aid or a routing
-- tool. "How I play, not what exists" (L11).
--
-- Spec: addons/planning/landmark_design.md. Every behaviour here cites its
-- ★★★ RULING: if the CODE and the BRIEF disagree, the BRIEF is right and the code is
--   the bug. ★ The authority order, stated once and binding on every behaviour.
-- criterion; if code and brief disagree, the brief is right and this is a bug.

local ADDON, NS = ...
NS.VERSION = (GetAddOnMetadata and GetAddOnMetadata(ADDON, "Version")) or "0.1.0"

local PREFIX = "|cff7fbfff[Landmarks]|r "

function NS.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. msg)
end

-- AC-43: no silent anything. If the store refused to load, say so once, loudly,
-- and keep saying so on any command - a quiet no-op would look like a lost
-- scrapbook. (Same lockout-latch posture as MancerLedger.)
local function lockedComplaint()
    if not NS.Store.locked then return false end
    NS.Print("|cffff4444LOCKED|r - " .. NS.Store.locked)
    NS.Print("Nothing has been changed or deleted. Your saved data is untouched.")
    return true
end
NS.LockedComplaint = lockedComplaint

-- ---------------------------------------------------------------------
-- Capture. AC-7: asks nothing. AC-9a: what you made becomes what you hold.
-- ---------------------------------------------------------------------

function NS.CaptureHere()
    if lockedComplaint() then return end
    local id, lm = NS.Store.Create()
    if not id then
        NS.Print("could not mark here - " .. tostring(lm))
        return
    end
    -- AC-9a: capture selects what it captured, so `repin` is immediately
    -- meaningful and renaming in flight is one click on a surface already open.
    NS.Widget:Hold(id)
    NS.Widget:Show()
    NS.Print(("marked |cffffd100%s|r"):format(lm.alias))
    if NS.Pins then NS.Pins:Refresh() end
end

-- ---------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        local ok, err = NS.Store.Load()
        if not ok then
            NS.Print("|cffff4444LOCKED|r - " .. tostring(err))
            NS.Print("Refusing to touch saved data it does not understand. "
                .. "Nothing has been lost; update or downgrade the addon.")
        end
        NS.Beacon.Init()
        NS.Widget:Init()
        NS.Pins:Init()
        NS.Minimap:Init()

    elseif event == "PLAYER_ENTERING_WORLD" then
        -- AC-15: nothing about the beacon survives login. We do not restore it -
        -- last session's goal is not necessarily this session's pursuit (L13).
        -- Only fill in map fractions we could not take at capture time.
        if not NS.Store.locked then NS.Store.Backfill() end
        NS.Widget:Refresh()
    end
end)

-- ---------------------------------------------------------------------
-- Slash surface. AC-8: `/<abbrev> here` is one of three capture affordances,
-- and the one a user can bind into their own macro.
-- ---------------------------------------------------------------------

SLASH_COALANDMARKS1 = "/lm"
SLASH_COALANDMARKS2 = "/landmarks"

local USAGE = {
    "|cffffd100/lm|r            show or hide the widget",
    "|cffffd100/lm here|r       mark where you are standing (macro-safe)",
    "|cffffd100/lm list|r       list what this character can see",
    "|cffffd100/lm all|r        show EVERY character's landmarks (recovery; off at login)",
    "|cffffd100/lm help|r       this",
}

SlashCmdList["COALANDMARKS"] = function(msg)
    local cmd = (msg or ""):match("^%s*(%S*)"):lower()

    if cmd == "here" then
        NS.CaptureHere()

    elseif cmd == "list" then
        if lockedComplaint() then return end
        local all = NS.Store.Visible()
        if #all == 0 then
            NS.Print("no landmarks yet - stand somewhere that matters and /lm here")
            return
        end
        NS.Print(("%d landmark(s)%s:"):format(#all,
            NS.Store.showAll and " |cffff8800[showing ALL characters]|r" or ""))
        for _, e in ipairs(all) do
            local where = e.lm.subZone ~= "" and e.lm.subZone or e.lm.zone
            local tag = ""
            if e.lm.owner == NS.Store.GLOBAL then
                tag = "  |cff888888(all characters)|r"
            elseif not NS.Store.IsMine(e.lm) then
                -- only reachable in show-all: name the owner so an orphan is
                -- recognisable as one.
                tag = ("  |cffff8800(%s)|r"):format(tostring(e.lm.owner))
            end
            NS.Print(("  |cffffd100%s|r  %s%s"):format(e.lm.alias, where, tag))
        end

    elseif cmd == "all" then
        if lockedComplaint() then return end
        NS.Store.showAll = not NS.Store.showAll
        local n = #NS.Store.Visible()
        if NS.Store.showAll then
            NS.Print(("showing |cffff8800ALL|r characters' landmarks - %d visible. "
                .. "To rescue one from a deleted character, edit it and set "
                .. "|cffffd100Visible to|r."):format(n))
            NS.Print("This is a recovery view and resets at login. |cffffd100/lm all|r again to leave it.")
        else
            NS.Print(("back to this character's view - %d visible."):format(n))
        end
        if NS.Pins then NS.Pins:Refresh() end
        NS.Widget:Refresh()

    elseif cmd == "help" then
        for _, line in ipairs(USAGE) do NS.Print(line) end

    elseif cmd == "" then
        NS.Widget:Toggle()

    else
        NS.Print("unknown - try |cffffd100/lm help|r")
    end
end
