-- ★ READ-ONLY PROBE (RI-41): two beacons sharing a POSITIVE stage, each with its own steps.
--
-- ⚠ A PROBE, NOT A SMOKE, and named so it is outside the `smoke_*` glob. It asserts nothing
-- and grades nothing - it PRINTS what the shipped bucket does, because RI-41 is an open
-- question and a green row would answer it by default. ★ It exists so the measurement in that
-- item is reproducible in one run rather than trusted from a paste.
--
--     .tools/lua51/lua5.1.exe addons/tools/smoke/probe_bid.lua
local here = debug.getinfo(1, "S").source:match("@(.*[/\])") or ""
local Rule = dofile(here .. "../../COA_DungeonRun/rule.lua")

local Routes
Routes = {
    _r = nil,
    Get = function(id) return Routes._r and Routes._r.id == id and Routes._r or nil end,
    ChildrenOf = function(b) return b.children or {} end,
    ReachOf = function(x) return x.radius, x.bandUp end,
    RowsOf = function(c) return c.rows or {} end,
}
local Vocab = assert(dofile(here .. "_vocab.lua"))
Routes.SENSE_WORDS, Routes.ROW_ACTIONS, Routes.ROW_ARG =
    Vocab.SENSE_WORDS, Vocab.ROW_ACTIONS, Vocab.ROW_ARG
_G.COA_DungeonRun_NS = { Rule = Rule, Routes = Routes }
local Bucket = dofile(here .. "../../COA_DungeonRun/bucket.lua")

local function kid(id, ord, x)
    return { id = id, ordinal = ord, x = x, y = 0, z = 0, radius = 5,
             rows = { { sense = "whenOn", action = "boss", arg = "Ragnaros" } } }
end

-- ★ BOTH AT STAGE 1. §90 S4 rules duplicate stages TELL-AND-TRUST, so this is authorable.
Routes._r = { id = "R1", mapID = 33, beacons = {
    { id = "left", stage = 1, kind = "beacon", x = 0, y = 0, z = 0, radius = 5,
      children = { kid("l1", 1, 10), kid("l2", 2, 20) } },
    { id = "right", stage = 1, kind = "beacon", x = 0, y = 0, z = 0, radius = 5,
      children = { kid("r1", 1, 510), kid("r2", 2, 520) } },
} }

-- ✅✅ RI-41's SHAPE IS NOW UNBUILDABLE, and that is the outcome rather than a broken
-- probe. §440 measured two beacons at one stage running in LOCKSTEP on a shared cursor;
-- §448's bare rows removed the shared SLOT, and A12.2b (built §451) refuses the shape
-- outright. ★ The probe is kept and run: it now demonstrates the REFUSAL, which is the
-- claim A12's guarantee stands on - *"the manager MAY assume one beacon per stage"*.
local bk, why = Bucket.Build(33, "R1")
if not bk then
    print("REFUSED: " .. tostring(why))
    print("  ★ EXPECTED since §451 (A12.2b). RI-41's fixture cannot be built, so the")
    print("    lockstep it measured is unreachable rather than merely dissolved.")
    return
end
print(("loaded %d, bounced %d"):format(bk.count, bk.bounced))

for _, step in ipairs({ 1, 2 }) do
    local names = {}
    for _, n in ipairs(Bucket.Stage(bk, 1, step)) do
        names[#names + 1] = n.address:gsub("^33:R1:", "")
    end
    table.sort(names)
    print(("  stage 1 step %d : %s"):format(step, table.concat(names, " ")))
end

print("")
print("slot occupancy under stage 1:")
-- ⚠ ONE LEVEL NOW (model row 23): the bucket IS the stage, so this counts ROWS BY THEIR
-- `step` FIELD rather than reading a second index that no longer exists.
local byStep = {}
for _, row in ipairs(bk.stages[1]) do
    local s = row.step or 0
    byStep[s] = (byStep[s] or 0) + 1
end
for s = 0, 4 do
    if byStep[s] then print(("  step %-3d carried by %d row(s)"):format(s, byStep[s])) end
end
print("")
print("FirstStep(stage 1) = " .. tostring(Bucket.FirstStep(bk, 1)))
