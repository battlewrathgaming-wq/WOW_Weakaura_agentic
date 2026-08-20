-- Model: addons/planning/DRIVER_BASIS.md
--
-- ★★★ A11.1 · THE ROW SHAPE AS A DECLARED CONTRACT (P2).
--
-- Grades `contract.lua` (the declaration) and `fixtures_route.lua` (the hand-written
-- list V1 is measured against). ⚠ It grades no PRODUCER, because none exists - A11.1a's
-- Q1 read was accepted as *"build to the shape; the flattener arrives with a consumer
-- to satisfy"*, and this is the shape standing on its own until then.

local ROOT = (...) and "" or ""
local here = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""

local Contract = assert(dofile(here .. "../../COA_DungeonRun/contract.lua"),
                        "contract.lua did not return its table")
local FIX = assert(dofile(here .. "fixtures_route.lua"),
                   "fixtures_route.lua did not return its table")

local function fail(msg) error(msg, 2) end

-- =====================================================================
-- ★ A11.1a - THE CONTRACT IS DECLARED, AND IT DECLARES THE THINGS THE ROW SAYS.
-- =====================================================================

assert(Contract.SPACE == "WORLD",
       "THE COORDINATE SPACE IS NOT DECLARED AS WORLD: `map.lua:46` carries two sizes "
       .. "and MAP xy is wrong by +2.2% across and +15% down - a trail that follows "
       .. "corridors and is wrong everywhere. Getting this wrong is SILENT, which is "
       .. "why A11.1a makes the contract state it")

assert(type(Contract.VERSION) == "number",
       "NO CONTENT VERSION: §A4 17a puts a version prefix on the transport, and RI-21 "
       .. "D5 records why the CONTENT version is a separate question from the ENCODE "
       .. "version - they rev at different rates")

-- ⚠ A11.1's own mutation: "drop `ordinal` from the contract -> the contract check
-- fails (a field added later is a format change)". `step` IS the ordinal on the record.
local names = {}
for _, f in ipairs(Contract.Fields()) do names[f.name] = f end
for _, want in ipairs({ "mapID", "rid", "bid", "cid", "stage", "step",
                        "posX", "posY", "posZ", "r", "band", "nextType" }) do
    assert(names[want],
           "THE CONTRACT LOST A FIELD: `" .. want .. "` is gone from the "
           .. "characteristic record. A field added or removed later is a FORMAT "
           .. "CHANGE, and the contract is the one place that can say so")
end

-- ⚠ BAND IS ONE FIELD, not a pair. RI-22 retired the downward half; a contract that
-- still declared `bandDown` would put it back into every producer written against it.
assert(names.bandDown == nil and names.bandUp == nil,
       "THE CONTRACT STILL SPLITS THE BAND: RI-22 made it UPWARD ONLY, one value - a "
       .. "captured sample IS the floor (ROUTER 280), so a downward half measures "
       .. "nothing that exists")

-- =====================================================================
-- ★★★ A11.1c - NO FREE TEXT ANYWHERE. The isolation property made CHECKABLE.
--
-- ⚠ Checked on TWO levels, because either alone is weak: the contract's VOCABULARY
-- (there is no "text" type to declare) and every fixture VALUE (a string must be a
-- member of a closed vocabulary, never an arbitrary label).
-- =====================================================================

assert(Contract.TYPES.text == nil and Contract.TYPES.string == nil,
       "THE CONTRACT DECLARES A FREE-TEXT TYPE: RI-18 is `identifiers and numbers "
       .. "only`, and the vocabulary itself has to lack the word - otherwise adding a "
       .. "label is a quiet field somewhere rather than a visible act in one file")

for _, f in ipairs(Contract.Fields()) do
    assert(Contract.TYPES[f.type],
           "FIELD `" .. f.name .. "` HAS AN UNDECLARED TYPE `" .. tostring(f.type)
           .. "`: every field must be an id or a number, and a type nobody declared "
           .. "is how a third kind arrives")
end
for _, f in ipairs(Contract.Fields("behaviour")) do
    assert(Contract.TYPES[f.type],
           "BEHAVIOUR FIELD `" .. f.name .. "` HAS AN UNDECLARED TYPE")
end

-- ★ AND THE FIXTURES OBEY IT. A string value is only legal if a vocabulary holds it.
local checked = 0
local function scan(kind, rows)
    for i, rec in ipairs(rows) do
        for _, f in ipairs(Contract.Fields(kind)) do
            local v = rec[f.name]
            if v ~= nil then
                checked = checked + 1
                if type(v) == "string" then
                    local vocab = FIX.vocabulary[f.name]
                    if not (vocab and vocab[v]) then
                        fail(("FREE TEXT IN A RECORD: %s[%d].%s = %q is a string that "
                              .. "no vocabulary holds. RI-18 is identifiers and numbers "
                              .. "ONLY - a boss NAME belongs in the names table with an "
                              .. "ID on the record, so there is nothing to escape and no "
                              .. "reserved character to defend")
                             :format(kind, i, f.name, v))
                    end
                elseif type(v) ~= "number" then
                    fail(("NEITHER AN ID NOR A NUMBER: %s[%d].%s is a %s")
                         :format(kind, i, f.name, type(v)))
                end
            elseif not f.optional then
                fail(("A REQUIRED FIELD IS ABSENT: %s[%d].%s. The contract says it is "
                      .. "not optional, and a producer omitting it shifts every "
                      .. "position after it"):format(kind, i, f.name))
            end
        end
    end
end
scan("characteristic", FIX.characteristic)
scan("behaviour", FIX.behaviour)

-- =====================================================================
-- ★ THE FIXTURE LIST COVERS THE CASES THE RULES SAY CAN HAPPEN.
--
-- ⚠ Asserted rather than eyeballed: a fixture list that quietly lost its stageless
-- node would still pass every row above, and P3's port would then be graded against a
-- world where recovery beacons do not exist.
-- =====================================================================

local seen = { stageless = false, unordinalled = false, setN = false,
               beaconNoCid = false, twoTabs = 0, secondRoute = false }
for _, r in ipairs(FIX.characteristic) do
    if r.stage == 0 then seen.stageless = true end
    if r.cid ~= nil and r.step == 0 then seen.unordinalled = true end
    if r.nextType == "set" and r.nextArg ~= nil then seen.setN = true end
    if r.cid == nil then seen.beaconNoCid = true end
    if r.rid ~= 7 then seen.secondRoute = true end
end
local tabs = {}
for _, r in ipairs(FIX.behaviour) do
    local k = ("%d:%d:%s"):format(r.rid, r.bid, tostring(r.cid))
    tabs[k] = (tabs[k] or 0) + 1
    if tabs[k] > 1 then seen.twoTabs = seen.twoTabs + 1 end
end

assert(seen.stageless, "NO STAGELESS NODE IN THE FIXTURES: stage 0 is `permission to "
       .. "read it`, and a list without one grades a world where recovery cannot happen")
assert(seen.unordinalled, "NO UN-ORDINALLED CHILD: §311's update type is listened to at "
       .. "any time, and step 0 on a child is the case that makes 0-not-blank matter")
assert(seen.setN, "NO Set(N) NODE: `nextArg` is present ONLY there, so without one the "
       .. "two-slot rule (RI-18 Q3) is never exercised")
assert(seen.beaconNoCid, "NO BEACON WITH AN ABSENT cid: a beacon carries its own reach "
       .. "(G2), so the address stops at BID and that is the optional case")
assert(seen.twoTabs > 0, "NO NODE WITH TWO TABS: A2.7 completes a step when ALL its "
       .. "tabs complete, which cannot be graded against a list where every node has one")
assert(seen.secondRoute, "ONLY ONE ROUTE: `rid` is part of the key precisely because "
       .. "two routes can share a bid, and one route never proves it")

-- ★★ AND EVERY BEHAVIOUR RECORD ADDRESSES A NODE THAT EXISTS. A tab pointing at no
-- node is a record the driver would arm and never satisfy.
local nodes = {}
for _, r in ipairs(FIX.characteristic) do
    nodes[("%d:%d:%d:%s"):format(r.mapID, r.rid, r.bid, tostring(r.cid))] = true
end
for i, r in ipairs(FIX.behaviour) do
    local k = ("%d:%d:%d:%s"):format(r.mapID, r.rid, r.bid, tostring(r.cid))
    assert(nodes[k],
           ("BEHAVIOUR RECORD %d ADDRESSES NO NODE (%s): ownership IS the address "
            .. "(§A1.2), so a tab whose address matches nothing is a tab that can "
            .. "never complete - and nothing else would notice"):format(i, k))
end

print(("smoke_contract: OK - %d field value(s) checked across %d characteristic and "
       .. "%d behaviour record(s); space=%s version=%d")
      :format(checked, #FIX.characteristic, #FIX.behaviour,
              Contract.SPACE, Contract.VERSION))
