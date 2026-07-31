-- feed_demo.lua - the chassis-proving fake feed (pass 2, kept as a feed).
-- Every visual state the real grid needs, on a timer: HP jiggle, the 3-state
-- cycle (live -> stale grey -> gone -> back), TTL windows draining, counts
-- breathing. /petgrid demo toggles it against the live feed.

local ADDON, NS = ...

local demoRaise = {
    { kind = "raise", name = "Abomination", lf = 3, hpFrac = 1.0, dmg = "1.2k", crit = "14%", miss = "5%", state = "live" },
    { kind = "raise", name = "Banshee",     lf = 2, hpFrac = 0.8, dmg = "640",  crit = "9%",  miss = "3%", state = "live" },
    { kind = "raise", name = "Ghoul",       lf = 1, hpFrac = 0.6, dmg = "410",  crit = "16%", miss = "6%", state = "live" },
}
local demoFamily = {
    { kind = "family", name = "Zombies", count = 6, ttl = 15, ttlMax = 15, crit = "11%", miss = "4%" },
    { kind = "family", name = "Archers", count = 3, ttl = 9,  ttlMax = 18, crit = "13%", miss = "2%" },
}

local clock, phase, lastRaiseN = 0, 0, -1

local function tickDemo()
    phase = phase + 1

    for _, d in ipairs(demoRaise) do
        if d.state == "live" then
            d.hpFrac = d.hpFrac - 0.07
            if d.hpFrac < 0.15 then d.hpFrac = 1.0 end
        end
    end
    demoFamily[1].count = 4 + math.fmod(phase, 5)
    for _, d in ipairs(demoFamily) do
        d.ttl = d.ttl - 0.5
        if d.ttl <= 0 then d.ttl = d.ttlMax end
    end

    -- the Ghoul cycles the 3-state machine every ~12s
    local ghoul = demoRaise[3]
    local step = math.fmod(phase, 24)
    local wantGone = (step >= 16 and step < 20)
    ghoul.state = (step >= 8 and step < 16) and "stale" or "live"

    local raiseSet = {}
    for _, d in ipairs(demoRaise) do
        if not (d == ghoul and wantGone) then raiseSet[#raiseSet + 1] = d end
    end
    if #raiseSet ~= lastRaiseN then
        lastRaiseN = #raiseSet
        NS.layout(raiseSet, demoFamily)
    end
    NS.writeRows()
end

NS.feeds.demo = {
    start = function()
        lastRaiseN = -1
        NS.layout(demoRaise, demoFamily)
        NS.writeRows()
        NS.root:Show()
    end,
    stop = function()
        NS.layout({}, {})
        NS.root:Hide()
    end,
    update = function(dt) tickDemo() end,
}
