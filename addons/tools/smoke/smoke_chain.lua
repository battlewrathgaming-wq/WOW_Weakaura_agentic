-- Offline smoke for task_chain: drives a whole route past a stubbed client and asserts
-- the thing W6 exists to prove - that SET / ARRIVE / CLEAR / SET AGAIN works repeatedly
-- and that every switch lands in the record.
--
-- ★ The assertions are built so they can FAIL. The stub counts real setter and clearer
-- calls, so a task that forgot to clear between beacons, or that advanced without
-- pointing at the next one, is caught by arithmetic rather than by reading the log.
--
-- ⚠ And the terminal clear is asserted separately, because it is the one that has no
-- successor to mask it: the marker never releases itself, so a route that ends still
-- armed leaves the player a stale arrow that looks live.
local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
date = os.date
local now = 500.0
function GetTime() return now end
function GetAddOnMetadata() return "2.2.0" end
function GetRealmName() return "Vol'jin" end
function UnitName() return "Gravereaper" end
function UnitClass() return "Necromancer", "NECROMANCER" end

local P = { x = 0, y = 0, z = 0, m = 389 }
function GetCurrentPlayerPosition() return P.x, P.y, P.z, P.m end

-- the tracker, counting what the task actually does to it
local T = { set = 0, cleared = 0, at = nil, state = 2 }
SuperTrackerUtil = {
    SetSuperTrackedPosition = function(x, y, z, m)
        T.set = T.set + 1
        T.at = { x = x, y = y, z = z, m = m }
    end,
    ClearSuperTrackedPosition = function()
        T.cleared = T.cleared + 1
        T.at = nil
    end,
}
C_SuperTrack = {
    -- the engine's distance, from wherever the pin actually is - so od and sd only
    -- agree if the task pointed where it thinks it did
    GetSuperTrackedPosition = function()
        if not T.at then return nil, nil, nil end
        local dx, dy, dz = P.x - T.at.x, P.y - T.at.y, P.z - T.at.z
        return 100, 100, math.sqrt(dx * dx + dy * dy + dz * dz)
    end,
    GetTargetState = function() return T.state end,
    SetSuperTrackedPosition = function() error("direct C_ setter must not be used - F24") end,
}

local named, ticker, released = {}, nil, false
function CreateFrame(kind, name)
    local f = { scripts = {}, kind = kind, name = name }
    if name then named[name] = f end
    function f:SetScript(ev, fn)
        self.scripts[ev] = fn
        if ev == "OnUpdate" then
            if fn then ticker = fn else released = true end
        end
    end
    function f:Fire(ev, ...) if self.scripts[ev] then self.scripts[ev](self, ...) end end
    local noop = function() end
    for _, m in ipairs({ "SetWidth", "SetHeight", "SetPoint", "SetBackdrop", "SetMovable",
                         "EnableMouse", "RegisterForDrag", "Show", "Hide",
                         "StartMoving", "StopMovingOrSizing" }) do
        f[m] = noop
    end
    f.SetText = function(self, t) self.text = t end
    f.CreateFontString = function()
        local fs = { SetPoint = noop, SetWidth = noop, SetJustifyH = noop }
        fs.SetText = function(s, t) s.text = t end
        return fs
    end
    return f
end
UIParent = CreateFrame("Frame", "UIParent")
SlashCmdList = {}

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DevDump\]]
local ns = {}
local function loadaddon(f)
    local chunk, err = loadfile(ROOT .. f)
    assert(chunk, "load " .. f .. ": " .. tostring(err))
    chunk("COA_DevDump", ns)
end
loadaddon("core.lua")
loadaddon("route_chain.lua")
loadaddon("task_chain.lua")

-- the generated route must have arrived, and be internally coherent
assert(ns.routeChain, "route_chain.lua did not install D.routeChain")
local R = ns.routeChain
assert(#R.beacons >= 2, "a chain test needs at least two beacons")
assert(R.sha and R.sha ~= "", "the route must carry its capture's sha - it is generated")
for _, b in ipairs(R.beacons) do
    assert(b.mapID == R.mapID, "every beacon must share the route's mapID")
end

local T2 = ns.tasks and ns.tasks.chain
assert(T2, "chain task did not register")

-- start ON the first beacon's map but far from it
P.x, P.y, P.z, P.m = R.beacons[1].x + 400, R.beacons[1].y, R.beacons[1].z, R.mapID
T2.start("")
local pay = COA_DevDumpDB.payload
assert(pay, "no payload")
assert(pay.mapMatches == true, "map should match")
assert(T.set == 1, "the first beacon must be SET on start, got " .. T.set)
assert(named["COADevDumpChainPanel"], "the panel must be NAMED")
assert(ticker, "no OnUpdate installed - the chain would never advance")

-- ---------------------------------------------------------------- walk it
-- teleport onto each beacon in turn; one tick each
for i, b in ipairs(R.beacons) do
    P.x, P.y, P.z = b.x, b.y, b.z
    now = now + 0.2
    ticker(nil, 0.2)
end

assert(pay.finished, "the route did not complete")
-- ★★ THE ARITHMETIC THAT MATTERS: every beacon set once, every one cleared once.
assert(T.set == #R.beacons,
       ("every beacon must be SET exactly once: %d sets for %d beacons")
       :format(T.set, #R.beacons))
assert(T.cleared == #R.beacons,
       ("every beacon must be CLEARED exactly once: %d clears for %d beacons")
       :format(T.cleared, #R.beacons))
-- ⚠ the terminal one: nothing follows it, so nothing would mask its absence
assert(T.at == nil, "the tracker must be CLEAR at the end - a spent target left set")

-- every switch is in the record, which is W6.2
local sets, clears, arrives = 0, 0, 0
for _, e in ipairs(pay.events) do
    if e.event == "set" then sets = sets + 1
    elseif e.event == "clear" then clears = clears + 1
    elseif e.event == "arrive" then arrives = arrives + 1 end
    assert(e.beacon, "every event must name its beacon")
    assert(e.gt, "every event must carry a timestamp")
end
assert(sets == #R.beacons and clears == #R.beacons and arrives == #R.beacons,
       ("the record must carry every switch: %d set / %d clear / %d arrive")
       :format(sets, clears, arrives))

-- ★ od decided, sd only rode along - and they must agree, because the task pointed
-- where it thought it did. A disagreement here means it set the WRONG beacon.
for _, r in ipairs(pay.rows) do
    if r.od and r.sd then
        assert(math.abs(r.od - r.sd) < 1e-6,
               "od and sd disagree - the task pointed somewhere other than it measured")
    end
end

T2.stop()
assert(COA_DevDumpDB.header.status == "complete", "envelope not closed")
assert(pay.summary.reached == #R.beacons, "summary reached count is wrong")
assert(released, "the OnUpdate was not released on stop")

-- ---------------------------------------------------------------- skip
-- a beacon that cannot be reached must not strand the run, and must be RECORDED
T.set, T.cleared = 0, 0
now = now + 10
P.x, P.y, P.z = R.beacons[1].x + 900, R.beacons[1].y, R.beacons[1].z
T2.start("")
pay = COA_DevDumpDB.payload
named["COADevDumpChainSkip"]:Fire("OnClick")
local skipped = 0
for _, e in ipairs(pay.events) do
    if e.event == "skip" then skipped = skipped + 1 end
end
assert(skipped == 1, "the skip must be RECORDED, not silent")
assert(T.set == 2, "skipping must SET the next beacon, got " .. T.set)
T2.stop()
assert(T.at == nil, "stop must clear even mid-route")

print(("smoke_chain: OK - %d beacons set and cleared exactly once each, every switch in "
    .. "the record, terminal clear asserted, skip recorded, OnUpdate released")
    :format(#R.beacons))
