-- COA_DungeonRun core.lua - init and the slash surface.
--
-- Model: addons/planning/DRIVER_BASIS.md   READ FIRST. It names what governs NOW, in
--        precedence order, and it MOVES when a ruling moves - so this line never
--        goes stale. Lower number wins; a disagreement is reported, not resolved here.
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

-- ★★★ THE TRACKER ADAPTER (AL-25) — the ten lines the manager's seam hands to the
-- client, and **the only part of the driver a smoke cannot prove.**
--
-- AI-11 asked how a client-only seam is accepted when §7 says the bench proves on
-- synthetic rows. Battlewrath's answer was a method: an in-game DEBUG LOG, and
-- **acceptance by the log of a NAMED TEST RUN** showing the adapter did what the manager
-- decided. ⟶ The smoke proves everything up to this door; `debuglog.lua` proves the door.
--
-- ★★ SO IT IS WRITTEN TO BE **READ**, not tested: no branching, no derivation, no
-- decision of its own. Every choice - which node, whether a tray-0 item may lure, when to
-- park - was made by the manager and graded there. This hands over coordinates.
--
-- ⚠ THE GUARD AND THE `pcall` ARE `capture.lua`'s, deliberately: it has called
-- `SuperTrackerUtil` since §249 under exactly this shape - a `_G` existence test because
-- the util is a FORK global that a client may not have, and `pcall` because taking the
-- arrow is not worth an error that stops a pull.
--
-- ⚠⚠ IT TAKES THE PLAYER'S QUEST ARROW. `capture.lua` records the same cost and the
-- same mitigation: nothing in the client's flow hands it back, so the PARK is the whole
-- of our contract - A11.9's escapement, and A12.8a makes the manager call it at terminal.
NS.Tracker = {
    Point = function(node)
        if not node or not _G.SuperTrackerUtil then return end
        pcall(SuperTrackerUtil.SetSuperTrackedPosition,
              node.x, node.y, node.z, node.mapID)
    end,
    Park = function()
        if not _G.SuperTrackerUtil then return end
        pcall(SuperTrackerUtil.ClearSuperTrackedPosition)
    end,
}

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
    elseif cmd == "armdev" then
        -- ★ §264. Any name. The dev profile comes from the VERB, so `/dr arm <anything>`
        -- stays the product path no matter what it is called.
        local id, err = Capture.ArmDev(rest)
        NS.Say(id and ("recording |cffffd100%s|r"):format(id)
                  or ("could not start: " .. tostring(err)))
        Widget.Refresh()
    elseif cmd == "testpin" then
        -- ★ §249. `/dr testpin` pins here and prints the numbers; `/dr testpin x y z`
        -- pins at a known place; `/dr testpin clear` releases it.
        if rest == "clear" then
            Capture.ClearTestPin()
            NS.Say("test pin cleared")
        else
            local a, b, c, d = rest:match("^(%-?[%d.]+)%s+(%-?[%d.]+)%s+(%-?[%d.]+)%s*(%d*)$")
            local p, ok = Capture.TestPin(tonumber(a), tonumber(b), tonumber(c), tonumber(d))
            if not p then
                NS.Say(tostring(ok))
            else
                -- ⚠ THE COORDINATES ARE THE PRODUCT of this command, not a courtesy. They
                -- are what makes the location "already known" on the next run.
                NS.Say(("test pin %s |cffffd100%.2f %.2f %.2f %s|r"):format(
                    ok and "set" or "|cffff8080NOT set|r - stored anyway",
                    p.x, p.y, p.z or 0, tostring(p.mapID)))
                NS.Say("reuse it with: |cffffd100/dr testpin "
                    .. ("%.2f %.2f %.2f %s"):format(p.x, p.y, p.z or 0, tostring(p.mapID)) .. "|r")
            end
        end
    elseif cmd == "list" then
        list()
    elseif cmd == "status" then
        status()
    elseif cmd == "probe" then
        probe()
    elseif cmd == "ui" then
        local U = NS.UI
        local sub, arg = rest:match("^(%S*)%s*(.-)$")
        if sub == "list" then
            for _, l in ipairs(U.List()) do NS.Say(l) end
            NS.Say(("%d control(s)"):format(#U.List()))
        elseif sub == "click" then
            local ok, err = U.Click(arg)
            NS.Say(ok and ("clicked " .. arg) or tostring(err))
        elseif sub == "set" then
            local k, v = arg:match("^(%S+)%s+(.*)$")
            local ok, err = U.Set(k, v)
            NS.Say(ok and ("%s = %s"):format(k, v) or tostring(err))
        elseif sub == "read" then
            local v, err = U.Read(arg)
            NS.Say(err or ("%s is %s"):format(arg, tostring(v)))
        elseif sub == "shot" then
            if Screenshot then Screenshot() end
            NS.Say("shot requested: " .. (arg ~= "" and arg or "(no label)"))
        elseif sub == "add" then
            -- ★★ THREE FORMS, NO PUNCTUATION. The first cut used `value|expect|label`
            -- and the key pattern swallowed the pipes on a shot, which takes no key -
            -- a syntax that fails on its own commonest line. ⚠ Caught by writing the
            -- plan out before typing it, which is the cheapest review there is.
            --
            --   add shot <label>          a shot carries only a label
            --   add wait                  spacing, nothing else
            --   add set <key> <value>
            --   add read <key> <expect>
            local v, tail = arg:match("^(%S+)%s*(.-)$")
            if v == "shot" or v == "wait" then
                U.PlanAdd(v, nil, nil, nil, tail ~= "" and tail or nil)
                NS.Say(("step %d: %s %s"):format(U.PlanSize(), v, tail))
            else
                local k, val = tail:match("^(%S*)%s*(.-)$")
                U.PlanAdd(v, k ~= "" and k or nil,
                          (v == "set") and (val ~= "" and val or nil) or nil,
                          (v == "read") and (val ~= "" and val or nil) or nil, nil)
                NS.Say(("step %d: %s %s %s"):format(U.PlanSize(), v, k, val))
            end
        elseif sub == "run" then
            local ok, err = U.RunPlan()
            NS.Say(ok and ("running %d step(s)"):format(U.PlanSize()) or tostring(err))
        elseif sub == "clear" then
            U.PlanClear(); NS.Say("plan cleared")
        else
            -- ⚠ The status is by-exception: it names the failures and says nothing
            -- about the steps that matched.
            local s = U.Summary()
            NS.Say(("plan %d step(s) · %d shot(s) requested · run %s")
                :format(U.PlanSize(), s.shotsRequested, tostring(s.runId)))
            for _, f in ipairs(s.failed) do NS.Say("|cffff8080" .. f .. "|r") end
            if #s.failed == 0 and s.runId then NS.Say("every step matched") end
        end
    -- ★★★ `drive` HAS BEEN IN THE HELP LINE SINCE BEFORE THE DRIVER EXISTED, with no
    -- branch - it fell through to the help text. ⚠ An advertised command that silently does
    -- nothing is worse than an absent one: the user reads it as "I typed it wrong".
    --
    -- ⚠⚠ IT REPORTS BUCKET'S REASON UNCHANGED (model row 24: BUCKET may fail and should
    -- fail LOUDLY). ★ This is the surface where that row pays off - "route R1 is for map 33,
    -- not 542" is a sentence the author can act on, and it is the whole reason `Build`
    -- returns a string instead of `false`.
    elseif cmd == "drive" then
        if rest == "stop" then
            NS.Driver.Stop()
            NS.Say("driver stopped")
        elseif rest == "" then
            local s = NS.Driver.Status()
            if not s then
                NS.Say("not driving - /dr drive <route id>")
            else
                NS.Say(("driving |cffffd100%s|r on map %s - stage %s - %d loaded, %d armed")
                    :format(tostring(s.rid), tostring(s.mapID), tostring(s.stage),
                            s.loaded, s.armed))
            end
        else
            local mapID = select(4, GetCurrentPlayerPosition())
            local ok, why = NS.Driver.Start(mapID, rest)
            if ok then
                local s = NS.Driver.Status()
                NS.Say(("driving |cffffd100%s|r - stage %s, %d node(s) armed")
                    :format(tostring(rest), tostring(s.stage), s.armed))
            else
                NS.Say("|cffff8080" .. tostring(why) .. "|r")
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
        NS.Say("/dr - widget  |  map  |  edit  |  arm <name>  |  pin  |  stop  |  list  |  status  |  probe  |  drive <id> | drive stop  |  delete <id>")
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
    NS.Options.Init()
    NS.Editor.Init()
    NS.Promoter.Init()
    NS.Object.Init()

    -- ★★ THE SEAM IS FILLED HERE, at load, and nowhere else. ⚠ `manager.lua` declares
    -- `Manager.Tracker = nil` and is GRADED against a double that records which node it
    -- was handed - that is what keeps the manager provable offline (§7). This line is the
    -- only place the real client body is attached, so a smoke never meets it and the
    -- client never meets the double.
    if NS.Manager then NS.Manager.Tracker = NS.Tracker end
    NS.UI.Init()
    NS.Widget.Init()

    SLASH_COADUNGEONRUN1 = "/dr"
    SLASH_COADUNGEONRUN2 = "/dungeonrun"
    SlashCmdList["COADUNGEONRUN"] = slash
end)
