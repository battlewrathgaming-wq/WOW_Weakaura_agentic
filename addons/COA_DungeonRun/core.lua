-- COA_DungeonRun core.lua - init and the slash surface.

local ADDON, NS = ...

function NS.Say(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66bbffCOA DungeonRun|r: " .. tostring(msg))
end

local function status()
    local Store, Capture = NS.Store, NS.Capture
    if Store.locked then
        NS.Say("|cffff5555STORAGE LOCKED|r: " .. Store.locked)
        return
    end
    local id = Capture.RunId()
    if id then
        local pulls, legs = Store.Counts(id)
        NS.Say(("recording |cffffd100%s|r - %d pull(s), %d leg(s)"):format(id, pulls, legs))
    else
        NS.Say("not recording. |cffffd100/dr arm <name>|r to start.")
    end
end

local function list()
    local Store = NS.Store
    local ids = Store.Ids()
    if #ids == 0 then NS.Say("no runs recorded yet.") return end
    NS.Say(("%d run(s):"):format(#ids))
    for _, id in ipairs(ids) do
        local r = Store.Get(id)
        local pulls, legs = Store.Counts(id)
        NS.Say(("  |cffffd100%s|r - %d pull(s), %d leg(s)%s")
            :format(id, pulls, legs, r.closedAt and "" or "  |cffff9900(open)|r"))
    end
end

local function slash(msg)
    local Store, Capture, Widget = NS.Store, NS.Capture, NS.Widget
    local cmd, rest = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = (cmd or ""):lower()

    if cmd == "" then
        Widget.Toggle()
    elseif cmd == "arm" then
        local id, err = Capture.Arm(rest)
        NS.Say(id and ("recording |cffffd100%s|r"):format(id)
                  or ("could not start: " .. tostring(err)))
        Widget.Refresh()
    elseif cmd == "stop" then
        local id = Capture.Stop()
        NS.Say(id and ("stopped |cffffd100%s|r"):format(id) or "not recording.")
        Widget.Refresh()
    elseif cmd == "map" then
        -- §20.1: ARGUMENT-FREE on purpose. The macro string has to be stable
        -- forever, and §20.2's location-driven model is what makes that possible -
        -- there is no run to name. Keybinding stays the user's, through the normal
        -- macro path; we do not own their bindings.
        NS.Map.Toggle()
    elseif cmd == "list" then
        list()
    elseif cmd == "status" then
        status()
    elseif cmd == "delete" then
        if Store.Get(rest) then
            Store.Delete(rest)
            NS.Say(("deleted |cffffd100%s|r"):format(rest))
        else
            NS.Say(("no run named |cffffd100%s|r - /dr list"):format(tostring(rest)))
        end
    else
        NS.Say("/dr - widget  |  map  |  arm <name>  |  stop  |  list  |  status  |  delete <id>")
    end
end

local boot = CreateFrame("Frame")
boot:RegisterEvent("ADDON_LOADED")
boot:SetScript("OnEvent", function(self, _, which)
    if which ~= ADDON then return end
    self:UnregisterEvent("ADDON_LOADED")

    local ok, err = NS.Store.Load()
    if not ok then
        -- Fails LOUD. A storage refusal that only whispers is the shape of a
        -- bug that gets discovered by missing data three sessions later.
        NS.Say("|cffff5555" .. tostring(err) .. "|r")
    end

    NS.Capture.Init()
    NS.Map.Init()
    NS.Widget.Init()

    SLASH_COADUNGEONRUN1 = "/dr"
    SLASH_COADUNGEONRUN2 = "/dungeonrun"
    SlashCmdList["COADUNGEONRUN"] = slash
end)
