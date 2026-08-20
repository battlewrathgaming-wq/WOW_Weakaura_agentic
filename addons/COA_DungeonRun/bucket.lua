-- Model: addons/planning/DRIVER_BASIS.md · construction is `driver_data_model.md` §A5b
--
-- ★★★ BUCKET (rows 23-27) — how a stored route becomes a thing the driver can run.
--
-- Battlewrath's direction, quoted in §A5b: *"stage the material that fit within the current
-- gate… by the time it's sampling it should have a target in mind."*
--
--     BUCKET   once per run.   Read the offered store WHOLE, keep this MAP for relevance,
--                              pick the RID, lay the route out as `bucket[stage][step]`.
--     STAGE    per advance.    Hand the current stage's bucket, WITH stage 0, to the sensor.
--
-- ⚠⚠⚠ ROW 24 IS THE ONE THAT SHAPES THIS FILE: **BUCKET MAY FAIL, AND SHOULD FAIL LOUDLY.
-- STAGE MAY NOT FAIL.** A stage advance happens MID-RUN, MID-COMBAT, and is raised by the
-- sensor's own output — there is no good answer available at that moment. ★ So every check
-- this file can perform, it performs HERE, and it names what was missing rather than
-- returning an empty list. *"If STAGE can fail, BUCKET did not do its job."*

local NS = select(2, ...)
NS = NS or _G.COA_DungeonRun_NS or {}
if select(2, ...) == nil then _G.COA_DungeonRun_NS = NS end

local Bucket = {}
NS.Bucket = Bucket

-- ★ Row 27's per-field defaults, named once. ⚠ NOT one sweep: `nil` means "no constraint"
-- in both cases and the two land on OPPOSITE ends of the number line.
--
--     stage / step   nil → 0      a gate you must MATCH relaxes to 0 (always eligible)
--     band           nil → 2.5    the author did not pick; 2.5 is the picker's FLOOR and
--                                 DEFAULT at once (RI-35)
--
-- ⚠⚠ A blanket `nil → 0` would give every unpicked band a tolerance of ZERO — `dz` exactly 0
-- — the most restrictive value producible from an absence that means "unset".
Bucket.ALWAYS = 0
Bucket.BAND_DEFAULT = 2.5

-- ⚠⚠ A DECLARED SEAM, not an omission. Row 25 says BUCKET resolves every `action` id to
-- *"the function the runtime holds"*. ★ THE RUNTIME HOLDS NO SUCH FUNCTIONS: `adaptor.lua`
-- carries a VOCABULARY (`Word` / `Has` / `Codes`) and there are no handlers anywhere, and
-- the sensor brief's own fence puts the action's HANDLING outside this lane —
-- *"we generate the input contract, never the consumer's handling."*
-- ⟶ So what is resolved here is the id against the KNOWN VOCABULARY, and an unknown one is
-- a BUCKET failure. That satisfies row 25's stated rule — **nothing authored is ever
-- interpreted on the hot path** — which is the part that is ours. Binding a callable is a
-- later step, and it goes through this seam rather than around it.
Bucket.Resolve = nil

local function known(code)
    if Bucket.Resolve then return Bucket.Resolve(code) end
    local Adaptor = NS.Adaptor
    if not Adaptor or not Adaptor.Has then return nil, "no vocabulary is loaded" end
    if not Adaptor.Has(code) then return nil, "unknown action" end
    return code
end

local function num(v)
    return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge
end

-- ★ Row 9: BEACON STAGES ARE WHOLE NUMBERS ONLY. ⚠ The row itself records that the rule has
-- no enforcement — the mint cannot produce a fraction but three other doors accept one, and
-- *"the guard arrives with the pickers (A10.3e)"*. ⟶ BUCKET is a door those three feed, and
-- row 24 says a failure belongs here rather than mid-run, so it refuses one.
local function wholeStage(v)
    return num(v) and v >= 0 and math.floor(v) == v
end

-- =====================================================================
-- ★★★ BUILD — one route, one map, laid out as bucket[stage][step].
--
-- Returns `bucket, nil` or `nil, reason`. ⚠ NEVER an empty bucket standing in for a
-- failure: row 24's whole point is that the caller learns WHAT was missing, and "no
-- beacons" and "the route is for another map" must not arrive looking alike.
-- =====================================================================
function Bucket.Build(mapID, rid, routes)
    local Routes = routes or NS.Routes
    if not Routes then return nil, "no route store" end
    if mapID == nil then return nil, "no mapID" end
    if rid == nil then return nil, "no route id" end

    local r = Routes.Get(rid)
    if not r then return nil, ("no such route: %s"):format(tostring(rid)) end

    -- ★ RELEVANCE IS THE MAP, and the check is here because it cannot be anywhere later.
    -- `Routes.List(mapID)` is the shipped precedent (`routes.lua:335-341`) — the editor
    -- already offers an authored route against a map by exactly this test.
    if r.mapID ~= mapID then
        return nil, ("route %s is for map %s, not %s")
            :format(tostring(rid), tostring(r.mapID), tostring(mapID))
    end

    local out = { mapID = mapID, rid = rid, stages = {}, count = 0 }
    local beacons = r.beacons or {}
    if #beacons == 0 then
        return nil, ("route %s has no beacons"):format(tostring(rid))
    end

    for _, b in ipairs(beacons) do
        -- ⚠ Row 10 / row 27: the STORE holds `nil` and the RECORD holds `0`. The conversion
        -- happens HERE and only here. ★ The store keeps nil because absence must stay LOUD —
        -- `nil + 1` throws where `0 + 1` silently returns 1, which is A2.10a's defect.
        local stage = b.stage
        if stage == nil then
            stage = Bucket.ALWAYS
        elseif not wholeStage(stage) then
            return nil, ("beacon %s has a fractional stage (%s); stages are whole numbers")
                :format(tostring(b.id), tostring(stage))
        end

        -- ★★★ A CHILDLESS BEACON IS THE NODE. ⚠⚠ §433 REFUSED ONE — *"beacon %s has no
        -- children to sample"* — and that was a DEFECT, not a strictness. `A1.2` is a
        -- governing acceptance row: **"A childless beacon is RUNNABLE"**, and `A2.5` says
        -- why in the store's own terms: when the last child is deleted *"its tabs RETURN to
        -- the parent, which is childless again and behaves as its own single child."*
        -- `A2.6` closes it — an ordinal child is *"the same object as a childless beacon"*.
        -- ⟶ So the beacon carries its own position, its own reach and its own rows, and the
        -- shipped `Routes.AcceptanceOf` already encodes exactly this: *"the anchor is its
        -- own satisfier when it has no children."*
        --
        -- ⚠ THE BENCH BUILT AGAINST `ChildrenOf` BECAUSE THAT IS THE ACCESSOR IT KNEW,
        -- rather than against the row that governs. Battlewrath asked the question that
        -- found it: *"or sense the childless beacon (A bucket with one item)"* — which is
        -- precisely what this now produces, one node under its beacon's stage.
        local kids = Routes.ChildrenOf(b)
        local lone = #kids == 0
        if lone then kids = { b } end

        for _, c in ipairs(kids) do
            -- ★ THE ORDINAL IS THE STEP, and an ordinalless child is the no-step bucket for
            -- its stage — A11.3d's ALWAYS-OPEN set, *"ordinalless children within their
            -- stage"*, and A11.1a's *"the no-step bucket always read"*.
            local step = c.ordinal
            if step == nil then
                step = Bucket.ALWAYS
            elseif not num(step) or step < 0 then
                return nil, ("child %s of beacon %s has an unusable ordinal (%s)")
                    :format(tostring(c.id), tostring(b.id), tostring(c.ordinal))
            end

            local radius, bandUp = Routes.ReachOf(c)
            if not num(radius) or radius <= 0 then
                return nil, ("child %s of beacon %s has no radius")
                    :format(tostring(c.id), tostring(b.id))
            end
            -- ⚠⚠ ROW 27's BAND CONVERSION, AND IT IS THE ONLY PLACE IT MAY HAPPEN (A11.2h).
            -- `rule.lua` REFUSES a nil band rather than defaulting one — `Rule.OPEN` was
            -- deleted because *"no infinity living in code to ever reach that"*. ★ So an
            -- unresolved node fires NOWHERE, and this line is what stops that being the
            -- normal case rather than a fault.
            -- ⚠ VALIDATED BEFORE DEFAULTED, and the order matters. Written the other way
            -- round the negative check ran on the ALREADY-DEFAULTED value, so it could
            -- never see a bad one — and it compared a possible `nil`. ★ Mutation found it:
            -- dropping the default crashed on `band < 0` instead of reaching a named
            -- refusal, which is row 24's failure mode exactly (a fault that does not say
            -- what it is). ⟶ An AUTHORED band is checked; only ABSENCE gets the default.
            if bandUp ~= nil and (not num(bandUp) or bandUp < 0) then
                return nil, ("child %s of beacon %s has a negative or unusable band (%s)")
                    :format(tostring(c.id), tostring(b.id), tostring(bandUp))
            end
            local band = num(bandUp) and bandUp or Bucket.BAND_DEFAULT

            if not (num(c.x) and num(c.y) and num(c.z)) then
                return nil, ("child %s of beacon %s is unplaceable")
                    :format(tostring(c.id), tostring(b.id))
            end

            -- ★ ROW 25's SHARE: every authored id is checked against the vocabulary NOW, so
            -- the 1 Hz pass never meets a word it has to look up or wonder about.
            local rows = {}
            for i, row in ipairs(Routes.RowsOf(c)) do
                local action, why = known(row.action)
                if not action then
                    return nil, ("child %s of beacon %s, row %d: %s (%s)")
                        :format(tostring(c.id), tostring(b.id), i,
                                why or "unknown action", tostring(row.action))
                end
                local sense = known(row.sense)
                if not sense then
                    return nil, ("child %s of beacon %s, row %d: unknown sense (%s)")
                        :format(tostring(c.id), tostring(b.id), i, tostring(row.sense))
                end
                rows[i] = { sense = sense, action = action, arg = row.arg }
            end

            out.stages[stage] = out.stages[stage] or {}
            local steps = out.stages[stage]
            steps[step] = steps[step] or {}
            local slot = steps[step]
            slot[#slot + 1] = {
                x = c.x, y = c.y, z = c.z, mapID = c.mapID or mapID,
                r = radius, band = band,
                stage = stage, step = step,
                -- ★★ A CHILDLESS BEACON'S NODE HAS NO CID, and the contract says so:
                -- `cid` is `optional = true` (`contract.lua:63`). ⚠ The first cut formatted
                -- all four parts unconditionally, so a lone beacon addressed itself as
                -- `mapID:rid:solo:solo` — **inventing a child id by duplicating the
                -- beacon's.** An address is the whole ancestry (row 2, *"ownership IS the
                -- address"*); a repeated segment claims a child that does not exist.
                -- ★ Mutation found it: swapping the lone node for a fabricated child
                -- SURVIVED, because the beacon id appeared either way.
                address = lone
                    and ("%s:%s:%s"):format(tostring(mapID), tostring(rid), tostring(b.id))
                    or ("%s:%s:%s:%s"):format(tostring(mapID), tostring(rid),
                                              tostring(b.id), tostring(c.id)),
                rows = rows,
            }
            out.count = out.count + 1
        end
    end

    return out, nil
end

-- =====================================================================
-- ★★ STAGE (row 23's second phase) — hand the current stage's bucket, WITH stage 0.
--
-- ⚠⚠ IT CANNOT FAIL, AND THAT IS ROW 24 RATHER THAN AN OVERSIGHT. Every check lives in
-- `Build`; this walks two already-formed tables and concatenates them. ★ Row 26: the swap
-- re-evaluates nothing, because all stage buckets were formed at BUCKET time.
-- =====================================================================
-- ★★★ THE FIRST STAGE, DERIVED FROM THE DATA — and it is derived precisely so it does not
-- have to take a side in a disagreement the bench must not resolve.
--
-- ⚠⚠ `A11.5a` says *"V1 has no stage"*. `Routes.AddBeacon` MINTS one for every beacon
-- (`b.stage = want or Routes.NextStage(id)`) and only an explicit `0` request stores nil.
-- ⟶ Both cannot be true of the same route, and *"don't mutate code from doc disagreement"*.
--
-- ★ So this answers *"where does a run start?"* from what is actually in the bucket, and is
-- correct under EITHER reading:
--     a route with no stages   → every node converted to 0 → first stage is 0, all of it
--     a route with stages 1..N → first stage is 1, plus stage 0 (row 23)
-- ⚠ Stage 0 is *"always eligible"*, NOT "the first stage" — a recovery beacon is not where a
-- run begins. So the lowest POSITIVE stage wins when one exists.
function Bucket.FirstStage(bucket)
    if type(bucket) ~= "table" or not bucket.stages then return Bucket.ALWAYS end
    local first
    for stage in pairs(bucket.stages) do
        if stage > Bucket.ALWAYS and (not first or stage < first) then first = stage end
    end
    return first or Bucket.ALWAYS
end

function Bucket.Stage(bucket, stage)
    local out = {}
    if type(bucket) ~= "table" or not bucket.stages then return out end
    local want = num(stage) and stage or Bucket.ALWAYS

    local function take(byStep)
        if not byStep then return end
        -- ⚠ THE NO-STEP SLOT IS ALWAYS READ (A11.1a). It is `Bucket.ALWAYS`, and it is taken
        -- for every stage handed out rather than only for stage 0 — A11.3d: *"ordinalless
        -- children WITHIN THEIR STAGE"*.
        for _, list in pairs(byStep) do
            for _, node in ipairs(list) do out[#out + 1] = node end
        end
    end

    take(bucket.stages[Bucket.ALWAYS])
    if want ~= Bucket.ALWAYS then take(bucket.stages[want]) end
    return out
end

return Bucket
