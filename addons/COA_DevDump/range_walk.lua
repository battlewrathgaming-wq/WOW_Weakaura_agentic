-- range_walk.lua - the PLAYER'S FUNCTION, with no player attached.
--
-- ★★★ WHAT IT IS. Battlewrath, 2026-08-24: *"a demo for the test sheet from scratch. With a mock
-- sample for it to walk? (No display, just the function of the player - playing and slicing)"*
-- ⟶ This file is the "no display" half: envelope · breadth · position, and which events a slice
-- holds. **No widget, no texture, no WoW API** - so it loads under plain Lua 5.1 as readily as in
-- the client, and the SAME FILE answers on both sides. A diff between them is then a fact about the
-- two interpreters, not about two implementations.
--
-- ⚠⚠ THE THREE QUANTITIES ARE SEPARATE, ON PURPOSE. `map.lua:670` returns `winPos, winWidth`
-- together and `:765 SetWindow(pos, width)` takes them together; that fusion is why the bar and the
-- handles compete for one surface (design doc §0b). His arrangement - handles above, handles below,
-- the slice body draggable - cannot be built without splitting them, so this demo splits them first
-- and lets the geometry follow.
--
-- ⚠ SEMANTICS MIRRORED FROM `map.lua`, not invented:
--     selection   `rel >= at and rel <= at + breadth`     :795  - INCLUSIVE at both ends
--     skip step   `max(1, floor(breadth / 10))`           :665  - ten presses crosses the frame
--     clamping    a slice never leaves its envelope        ClampWindow
-- ★ Where this file must choose something `map.lua` does not state, the choice is marked CHOICE.

COA_RANGE_WALK = {}
local W = COA_RANGE_WALK

W.MIN_BREADTH = 1

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

-- ★ A slice is clamped to its envelope in BOTH dimensions, and breadth wins over position:
-- a slice too wide for its envelope becomes the envelope, rather than being pushed off one end.
-- ⚠ CHOICE - `map.lua`'s ClampWindow is not read here, so this states the rule rather than
-- inheriting it. If they disagree, `map.lua` is the product and this is the demo.
-- ⚠ RECORDS WHAT WAS ASKED FOR. A step that changed nothing is not one finding but two:
-- an op that requested the state it was ALREADY in (the caller's redundancy) and an op that
-- was CLAMPED (the control refusing at an edge). Only the second is a UX finding, and
-- without `wanted` the reader cannot tell them apart.
function W.Clamp(st)
    st.wantedAt, st.wantedBreadth = st.at, st.breadth
    local room = st.envHi - st.envLo
    if room < W.MIN_BREADTH then room = W.MIN_BREADTH end
    st.breadth = clamp(st.breadth, W.MIN_BREADTH, room)
    st.at = clamp(st.at, st.envLo, st.envHi - st.breadth)
    return st
end

function W.SkipStep(breadth)
    return math.max(W.MIN_BREADTH, math.floor((breadth or W.MIN_BREADTH) / 10))
end

-- Which events the slice holds. ⚠ Inclusive at both ends, mirroring map.lua:795 - so an event
-- exactly on a boundary is IN, and the mock sample carries events at 0 and at 120 to prove it.
function W.Select(sample, st)
    local out, n = {}, 0
    for i = 1, #sample do
        local e = sample[i]
        if e >= st.at and e <= st.at + st.breadth then
            n = n + 1
            out[n] = e
        end
    end
    return out, n
end

function W.Apply(st, op)
    local what = op[1]
    if what == "envelope" then
        st.envLo, st.envHi = op[2], op[3]
    elseif what == "breadth" then
        st.breadth = op[2]
    elseif what == "at" then
        st.at = op[2]
    elseif what == "skip" then
        st.at = st.at + W.SkipStep(st.breadth) * (op[2] or 1)
    elseif what == "wider" then
        st.breadth = st.breadth * 2
    elseif what == "narrower" then
        -- ⚠ CHOICE: floored, so halving 25 gives 12 and never 12.5. A breadth of half a second
        -- is not a thing the readout can say.
        st.breadth = math.floor(st.breadth / 2)
    else
        st.error = "unknown op: " .. tostring(what)
    end
    return W.Clamp(st)
end

-- Run the whole declared walk. Returns one row per step: the state AFTER it, and the selection.
function W.Run(decl)
    local r = decl and decl.range
    if type(r) ~= "table" then return nil, "no range declaration" end
    local sample, span = r.sample or {}, r.span or 0
    local st = { envLo = 0, envHi = span, breadth = span, at = 0 }
    local steps = {}
    for i = 1, #(r.walk or {}) do
        local op = r.walk[i]
        W.Apply(st, op)
        local sel, n = W.Select(sample, st)
        steps[i] = {
            i = i,
            op = op[1] .. (op[2] and (" " .. tostring(op[2])) or "")
                       .. (op[3] and (".." .. tostring(op[3])) or ""),
            envLo = st.envLo, envHi = st.envHi,
            breadth = st.breadth, at = st.at,
            n = n, sel = sel,
            step = W.SkipStep(st.breadth),
            clamped = (st.wantedAt ~= st.at) or (st.wantedBreadth ~= st.breadth),
            error = st.error,
        }
        st.error = nil
    end
    return steps
end

return COA_RANGE_WALK
