-- COA_DungeonRun calibrate.lua - FRACTION -> WORLD, from our own records.
--
-- Spec: addons/planning/dungeonrun_poc.md §17, §65.
--
-- ---------------------------------------------------------------------------
-- ★ WHAT THIS IS FOR. A point captured in a dungeon carries BOTH a map fraction
-- (mapX, mapY) and a world position (x, y, z). A point AUTHORED by dragging a
-- beacon carries only a fraction - a drag gives us screen position and nothing
-- else. Anything that needs a metric distance (a listen radius, a satisfied
-- radius) needs world units, because a fraction is not one: the same fractional
-- delta is a different number of yards on every map.
--
-- So we need to convert. And the transform is exactly linear - proven at the desk
-- against the client's own DBC boxes, worst error 0.000000 across 389 points
-- (addons/maps/worldmap/README.md). Not assumed here; measured there.
--
-- ---------------------------------------------------------------------------
-- ★★ AND IT IS A CONSTANT OF THE MAP, NOT OF A RUN (Battlewrath, 2026-08-14).
--
-- The mapping comes from the client's map box, so every run of Shadowfang yields
-- the same one. Fitting per-run would be refitting one constant over and over from
-- whichever slice of evidence happened to be loaded - and would fail outright on a
-- corridor run with no spread, when another run of that dungeon had already
-- answered it.
--
-- ★ WHICH IS WHY THE RUNS ARE THE SAMPLES. Nothing new is stored. We walk every
-- run we hold for that mapID, take the pairs it already carries, and fit. His
-- framing, and it is the whole justification:
--
--   *"That way it's not learning a DB of maps. It's 'What does the current data
--   tell me on how to offer the fit'."*
--
-- ★ SO §17 HOLDS, and this is worth being precise about rather than waving past.
-- §17 forbids the addon LEARNING dungeons - no shipped box, no DBC, no per-dungeon
-- table - and its reason is *"so it can never be behind on a dungeon it has not
-- seen."* Nothing here is shipped or authored. A dungeon nobody has run has no
-- calibration: ABSENT, not wrong, which is the degradation §17 wants. And the
-- cache is a computation over records we already hold, recomputed each session, so
-- it is never a second source of truth that could disagree with them.
--
-- (addons/maps/worldmap/ has the real boxes and would be a lookup - but it is
-- desk-only by ruling: *"Do not ship it."* Lua cannot read DBCs, so shipping those
-- boxes means carrying a table that goes stale the moment the fork adds a dungeon.
-- That is exactly the per-dungeon tracking §17 refuses. Fitting from captures is
-- the runtime path precisely because it cannot go stale - it has no contents.)
-- ---------------------------------------------------------------------------

-- FACT: the fraction->world fit is a MAP constant, not a run constant (0.000203 yd worst, measured)
local ADDON, NS = ...

local Calibrate = {}
NS.Calibrate = Calibrate

local Store

function Calibrate.Init() Store = NS.Store end

-- Session cache: mapID -> { name, floors = { [floor] = fit } }. Reconstructed on
-- session (or first ask), never written to the DB - see the header.
local cache = {}

function Calibrate.Clear() cache = {} end

-- ★ A FULL AFFINE FIT, not two independent scales.
--
--     x = a1*mapX + b1*mapY + c1
--     y = a2*mapX + b2*mapY + c2
--
-- Six parameters rather than four, because the client's map axes are not simply
-- scaled copies of the world axes - they are swapped and negated, and the exact
-- convention differs by map. Fitting the full form means we never have to ASSUME
-- which world axis pairs with which fraction or in which direction: the data says
-- it. Assuming would be inventing a rule for a mapping we have never seen (§17's
-- own words about floor-from-z).
--
-- Least squares over every sample, not two points, because it costs nothing and
-- one bad capture cannot then define the map.

-- Solves the 3x3 normal equations by Gaussian elimination with partial pivoting.
-- Local, small and exact enough: the system is 3x3 and the data is well scaled.
local function solve3(A, b)
    local m = {
        { A[1][1], A[1][2], A[1][3], b[1] },
        { A[2][1], A[2][2], A[2][3], b[2] },
        { A[3][1], A[3][2], A[3][3], b[3] },
    }
    for col = 1, 3 do
        local piv, best = col, math.abs(m[col][col])
        for r = col + 1, 3 do
            if math.abs(m[r][col]) > best then piv, best = r, math.abs(m[r][col]) end
        end
        if best == 0 then return nil end            -- singular; the caller reports why
        m[col], m[piv] = m[piv], m[col]
        for r = 1, 3 do
            if r ~= col then
                local f = m[r][col] / m[col][col]
                for c = col, 4 do m[r][c] = m[r][c] - f * m[col][c] end
            end
        end
    end
    return { m[1][4] / m[1][1], m[2][4] / m[2][2], m[3][4] / m[3][3] }
end

-- ★ CONDITIONING, AND IT REFUSES RATHER THAN GUESSES.
--
-- Three samples are not enough if they sit in a line, and a hundred are not enough
-- if the run only ever moved along one axis - a corridor. Either way the fit is
-- underdetermined in one direction and least squares will still return numbers:
-- plausible, confident, and wrong in a way nothing downstream could detect.
--
-- So the spread is tested BEFORE the fit and the answer is `nil` plus a reason.
-- The same discipline as the rest of the addon: a hole made loud beats a number
-- made up.
local MIN_SPREAD = 0.02        -- 2% of the map's width; a real walk clears this easily
local MIN_AREA   = 1e-4        -- the covariance determinant; catches collinearity

local function spread(samples)
    local n = #samples
    if n < 3 then return nil, ("only %d sample%s; 3 is the minimum for a plane")
        :format(n, n == 1 and "" or "s") end
    local mx, my = 0, 0
    for _, s in ipairs(samples) do mx = mx + s.mapX; my = my + s.mapY end
    mx, my = mx / n, my / n
    local sxx, syy, sxy = 0, 0, 0
    for _, s in ipairs(samples) do
        local dx, dy = s.mapX - mx, s.mapY - my
        sxx = sxx + dx * dx; syy = syy + dy * dy; sxy = sxy + dx * dy
    end
    sxx, syy, sxy = sxx / n, syy / n, sxy / n
    if math.sqrt(sxx) < MIN_SPREAD then return nil, "no spread across the map's width" end
    if math.sqrt(syy) < MIN_SPREAD then return nil, "no spread down the map's height" end
    if (sxx * syy - sxy * sxy) < MIN_AREA * sxx * syy then
        return nil, "samples are collinear - one direction is undetermined"
    end
    return true
end

-- Returns a fit table, or nil + why. The fit reports its own error so a caller can
-- see how much to trust it rather than taking the six numbers on faith.
function Calibrate.Fit(samples)
    local ok, why = spread(samples)
    if not ok then return nil, why end

    local A = { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } }
    local bx, by = { 0, 0, 0 }, { 0, 0, 0 }
    for _, s in ipairs(samples) do
        local v = { s.mapX, s.mapY, 1 }
        for i = 1, 3 do
            for j = 1, 3 do A[i][j] = A[i][j] + v[i] * v[j] end
            bx[i] = bx[i] + v[i] * s.x
            by[i] = by[i] + v[i] * s.y
        end
    end

    local px, py = solve3(A, bx), solve3(A, by)
    if not px or not py then return nil, "the normal equations are singular" end

    local fit = { a1 = px[1], b1 = px[2], c1 = px[3],
                  a2 = py[1], b2 = py[2], c2 = py[3],
                  n = #samples }

    -- Residual in WORLD units - yards, which is a number a person can judge. Max
    -- as well as RMS: an average hides the one point that went somewhere else.
    local sum, worst = 0, 0
    for _, s in ipairs(samples) do
        local ex, ey = Calibrate.Apply(fit, s.mapX, s.mapY)
        local d = math.sqrt((ex - s.x) ^ 2 + (ey - s.y) ^ 2)
        sum = sum + d * d
        if d > worst then worst = d end
    end
    fit.rms, fit.worst = math.sqrt(sum / #samples), worst
    return fit
end

function Calibrate.Apply(fit, mapX, mapY)
    if not fit or not mapX or not mapY then return nil end
    return fit.a1 * mapX + fit.b1 * mapY + fit.c1,
           fit.a2 * mapX + fit.b2 * mapY + fit.c2
end

-- ---------------------------------------------------------------------
-- The cache - keyed by mapID, walked per floor
-- ---------------------------------------------------------------------
--
-- Per FLOOR, because floors stack over the same footprint but each has its own box
-- (addons/maps/worldmap/: 42 of 43 multi-floor dungeons overlap, 6 share one
-- identical box). One fit for the whole dungeon would be right on the floor it
-- happened to be dominated by and quietly wrong on the others.

-- ONE PASS, grouping as it goes. An earlier draft discovered floors as it walked
-- and then harvested per floor - which quietly dropped every earlier run's points
-- for a floor only a later run happened to introduce. The count would still look
-- healthy.
--
-- A sample needs BOTH halves of the pair. A point captured with the world map open
-- has no fraction (store.lua's guard), so it teaches nothing and is skipped rather
-- than counted.
local function build(mapID)
    local entry = { mapID = mapID, floors = {}, runs = 0 }
    if not Store then return entry end

    local Map = NS.Map
    local byFloor = {}
    for _, id in ipairs(Store.Ids()) do
        local run = Store.Get(id)
        if run and Map and Map.MapIDOf(run) == mapID then
            entry.runs = entry.runs + 1
            -- Name resolution, so an inspected cache says WHICH dungeon rather than
            -- a bare number. DR-34's tile file if the run carries one, else its zone.
            entry.name = entry.name or run.mapFile or run.zone
            for _, list in ipairs({ run.legs or {}, run.markers or {} }) do
                for _, p in ipairs(list) do
                    if p.mapX and p.mapY and p.x and p.y then
                        local f = p.floor or 0
                        byFloor[f] = byFloor[f] or {}
                        byFloor[f][#byFloor[f] + 1] = p
                    end
                end
            end
        end
    end

    for f, samples in pairs(byFloor) do
        local fit, why = Calibrate.Fit(samples)
        entry.floors[f] = fit or { ok = false, why = why, n = #samples }
    end
    return entry
end

-- ★ Lazy and per session. Built on the first ask for a map and held until the
-- session ends - which is also the only invalidation it needs, because the runs it
-- reads from only ever grow, and a fit from more samples is what the next session
-- gets for free.
function Calibrate.For(mapID)
    if not mapID then return nil end
    cache[mapID] = cache[mapID] or build(mapID)
    return cache[mapID]
end

-- ★ EVERY `nil` CARRIES A REASON. A silent nil here reads as "no world position
-- exists", when the truth is one of three different things - nobody has run this
-- dungeon, nobody has been on this floor, or the samples cannot determine a plane.
-- Only the last is about the fit; the first two are about the evidence, and the
-- caller can act on that difference.
function Calibrate.Floor(mapID, floor)
    local e = Calibrate.For(mapID)
    if not e or e.runs == 0 then
        return nil, "no runs recorded for this dungeon yet"
    end
    local fit = e.floors[floor or 0]
    if not fit then
        return nil, ("no paired samples on floor %s"):format(tostring(floor or 0))
    end
    if fit.ok == false then return nil, fit.why end
    return fit
end

-- The one call the rest of the addon needs: a fraction becomes world units, or it
-- does not and says why. Never a number we could not stand behind.
function Calibrate.ToWorld(mapID, floor, mapX, mapY)
    local fit, why = Calibrate.Floor(mapID, floor)
    if not fit then return nil, why end
    return Calibrate.Apply(fit, mapX, mapY)
end

-- For the readout: what the current data can and cannot tell us, per floor.
function Calibrate.Report(mapID)
    local e = Calibrate.For(mapID)
    if not e then return {} end
    local out = {}
    for f, fit in pairs(e.floors) do
        out[#out + 1] = {
            floor = f, n = fit.n,
            ok = fit.ok ~= false,
            why = fit.why,
            rms = fit.rms, worst = fit.worst,
        }
    end
    table.sort(out, function(a, b) return a.floor < b.floor end)
    return out, e.name, e.runs
end
