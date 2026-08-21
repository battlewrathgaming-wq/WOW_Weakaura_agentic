-- Ten steps in one bucket: what is BUILT vs what is EVALUATED at each step.
-- ★ READ-ONLY PROBE - what a bucket BUILDS versus what it EVALUATES (RI-42).
--
-- Battlewrath, 2026-08-21: *"In a bucket, 10 steps, so that 1/10 or 1/10 + step 0 continue to
-- be evaluated. Did step N's make it into the rows?"*
--
-- ⚠ A PROBE, NOT A SMOKE - outside the `smoke_*` glob because it asserts nothing and prints.
-- The RATIO is the answer, and a number is more use than a green row here.
--
--     .tools/lua51/lua5.1.exe addons/tools/smoke/probe_steps.lua

local here = debug.getinfo(1, "S").source:match("@(.*[/\])") or ""
local function load(f)
    return assert(loadfile(here .. "../../COA_DungeonRun/" .. f))("COA_DungeonRun",
                                                                 _G.COA_DungeonRun_NS)
end
local Rule = dofile(here .. "../../COA_DungeonRun/rule.lua")
local Routes
Routes = {
    _r = nil,
    Get = function(id) return Routes._r and Routes._r.id == id and Routes._r or nil end,
    ChildrenOf = function(b) return b.children or {} end,
    ReachOf = function(x) return x.radius, x.bandUp end,
    RowsOf = function(c) return c.rows or {} end,
}
_G.COA_DungeonRun_NS = { Rule = Rule, Routes = Routes,
                         Adaptor = { Has = function() return true end } }
local Bucket = load("bucket.lua")

local kids = {}
-- step 0: the pass-through, no ordinal
kids[1] = { id = "pass", x = 0, y = 0, z = 0, radius = 5,
            rows = { { sense = "whenOn", action = "boss" } } }
for n = 1, 10 do
    kids[n + 1] = { id = "s" .. n, ordinal = n, x = n * 100, y = 0, z = 0, radius = 5,
                    rows = { { sense = "whenOn", action = "boss" },
                             { sense = "seen",   action = "boss" } } }
end
Routes._r = { id = "R1", mapID = 33, beacons = {
    { id = "b1", stage = 1, kind = "beacon", x = 0, y = 0, z = 0, radius = 5,
      children = kids },
} }

local bk, why = Bucket.Build(33, "R1")
if not bk then print("REFUSED: " .. tostring(why)) return end

print(("  BUILT: %d node(s) in the route; bucket 1 holds %d row(s)")
      :format(bk.count, #bk.stages[1]))

local rowsIn, stepsSeen = 0, {}
for _, n in ipairs(bk.stages[1]) do
    rowsIn = rowsIn + #(n.rows or {})
    stepsSeen[#stepsSeen + 1] = n.step
end
table.sort(stepsSeen)
print(("  steps present : %s"):format(table.concat(stepsSeen, " ")))
print(("  behaviour rows carried in the bucket: %d"):format(rowsIn))
print("")
print("  EVALUATED per step (what Stage hands the sensor):")
for step = 1, 10 do
    local out = Bucket.Stage(bk, 1, step)
    local names, r = {}, 0
    for _, n in ipairs(out) do
        names[#names + 1] = n.address:gsub("^33:R1:b1:", "")
        r = r + #(n.rows or {})
    end
    print(("    step %-3d %d node(s), %d row(s) : %s")
          :format(step, #out, r, table.concat(names, " ")))
end
