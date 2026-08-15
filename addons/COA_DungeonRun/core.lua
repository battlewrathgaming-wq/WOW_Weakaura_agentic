-- COA_DungeonRun core.lua - init and the slash surface.
--
-- ---------------------------------------------------------------------------
-- ★★★ RULING: THE DRIVER'S PRODUCT IS BEHAVIOUR. THE EDITOR'S PRODUCT IS
-- COMPREHENSION. (Battlewrath, 2026-08-15)
--
--     "This then leads into making the editor tell visual stories to make sense of
--      what is codified. Which is a editor's job. Communication."
--
-- Same data, two entirely different deliverables - and that is WHY the halves can be
-- so unequal. §85: the driver is light, so the editor can afford to be expensive,
-- maintaining tables, identities and derived graphs that never reach the export.
--
-- ★★★ AND IT RAISES THE STAKES ON DERIVE-DON'T-STORE. If the editor's product IS the
-- picture, a stored ordinal is not a drift risk - it is a picture that can LIE, and
-- the picture is the whole thing being shipped. ⚠ A wrong readout in a communication
-- tool is not a cosmetic bug; it is a defective product.
--
-- ★★ IT ALSO NAMES A THROUGH-LINE THAT WAS ALREADY RUNNING. The gaps line, the match
-- count beside the stage box, "satisfying this promotes the index to 5", the running
-- order sorted by value, /dr walk's unrunnable-stages report - every one was built as
-- a local answer to DON'T REFUSE, INFORM. Called communication they stop being five
-- features and become one job done five times.
--
-- ★ THE TEST FOR ANYTHING PROPOSED LATER: does it make something codified LEGIBLE?
-- Yes -> the editor's. Does it change what happens? -> the driver's. Neither ->
-- decoration.
-- ---------------------------------------------------------------------------

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
        local pulls, legs, pins = Store.Counts(id)
        NS.Say(("recording |cffffd100%s|r - %d pull(s), %d leg(s), %d pin(s)")
            :format(id, pulls, legs, pins))
    else
        NS.Say("not recording. |cffffd100/dr arm <name>|r to start.")
    end
end

-- ★ THE MAP PROBE. One line, on demand, reporting what the client says about the
-- map you are standing on - because §66 left one question open that only the client
-- can answer.
--
-- ★★ OPEN: does DungeonUsesTerrainMap() agree with the DBC floor mark?
--   ⚠ NOT A FACT. The census figures below are real and the reasoning is sound, and
--   it is still an INFERENCE - the block says so itself in its own last paragraph,
--   which is exactly how a claim gets quoted forward past its evidence (§19).
--   SETTLED BY: standing in CoTStratholme, Ulduar or OrgrimmarDepths and running
--   `/dr probe`. Backlogged because Ulduar is unreleased on this fork and Culling
--   takes hoops - OrgrimmarDepths may be the only reachable one.
-- `DungeonUsesTerrainMap()` is C-side and the DBCs carry no column for it. The
-- census says exactly three floored maps are structurally marked (CoTStratholme,
-- Ulduar, OrgrimmarDepths carry defaultDungeonFloor = -1 where the other 70 carry
-- 0), and that the Caverns of Time instances and Mount Hyjal have NO floors at all
-- so nothing shifts there. Whether the mark and the function agree is an inference
-- until someone stands in one and looks.
--
-- Reports rather than judges: five raw readings, no verdict. If the flag is true
-- anywhere with floors, §66's shift is load-bearing and we will have proof instead
-- of a correlation.
local function probe()
    local file, w, h = "-", nil, nil
    if GetMapInfo then file, w, h = GetMapInfo() end
    local _, _, _, hereID = GetCurrentPlayerPosition()
    local shown = GetCurrentMapAreaID and (GetCurrentMapAreaID() - 1) or nil
    local terrain = DungeonUsesTerrainMap and DungeonUsesTerrainMap()
    NS.Say(("map |cffffd100%s|r  mapID %s (shown %s)  level %s of %s  terrain %s  art %sx%s")
        :format(tostring(file), tostring(hereID), tostring(shown),
                tostring(GetCurrentMapDungeonLevel and GetCurrentMapDungeonLevel()),
                tostring(GetNumDungeonMapLevels and GetNumDungeonMapLevels()),
                terrain and "|cff55ff55YES|r" or "no",
                tostring(w), tostring(h)))
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
    elseif cmd == "pin" then
        -- DR-36: ARGUMENT-FREE, like /dr map, so the macro string is stable and the
        -- keybind stays the user's. This is the path that is actually usable
        -- mid-pull; the widget button is how you discover it.
        Widget.Pin()
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
    elseif cmd == "edit" then
        -- §34: the COMPANION. Separate frame on purpose - a bug in it cannot break
        -- the map, and either can be worked on without touching the other.
        NS.Editor.Toggle()
    elseif cmd == "list" then
        list()
    elseif cmd == "status" then
        status()
    elseif cmd == "probe" then
        probe()
    elseif cmd == "drive" then
        NS.Driver.Toggle()
    -- ★★ §85: THE TEST DRIVER, and it lives on the EDITOR's slash surface on
    -- purpose. His: *"Runs in editing, but not from the driver."* A consumer that
    -- needs the editor loaded cannot be mistaken for the thing it is testing.
    elseif cmd == "walk" then
        local W = NS.Walk
        if rest == "" or rest == "stop" then
            W.Stop()
            NS.Say("walk stopped")
        else
            -- ★ §95: the report lives in Walk, because the promoter's play says the
            -- same thing and two copies would be two things that must agree.
            local lines, err = W.StartLines(rest)
            if not lines then
                NS.Say("could not walk: " .. tostring(err))
            else
                for _, l in ipairs(lines) do NS.Say(l) end
            end
        end
    elseif cmd == "delete" then
        if Store.Get(rest) then
            Store.Delete(rest)
            NS.Say(("deleted |cffffd100%s|r"):format(rest))
        else
            NS.Say(("no run named |cffffd100%s|r - /dr list"):format(tostring(rest)))
        end
    else
        NS.Say("/dr - widget  |  map  |  edit  |  arm <name>  |  pin  |  stop  |  list  |  status  |  probe  |  drive  |  delete <id>")
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
    NS.Routes.Init()
    NS.Calibrate.Init()
    NS.Map.Init()
    NS.Editor.Init()
    NS.Promoter.Init()
    NS.Object.Init()
    NS.Driver.Init()
    NS.Walk.Init()
    NS.Widget.Init()

    SLASH_COADUNGEONRUN1 = "/dr"
    SLASH_COADUNGEONRUN2 = "/dungeonrun"
    SlashCmdList["COADUNGEONRUN"] = slash
end)
