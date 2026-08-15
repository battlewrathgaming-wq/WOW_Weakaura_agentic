-- check_rects.lua - run the offline checks on the CLIENT'S OWN measured rects.
--
-- ★★★ WHY THIS EXISTS RATHER THAN A SECOND IMPLEMENTATION IN PYTHON. The overlap and
-- overhang arithmetic is six lines, and six lines is exactly the size of thing that
-- gets rewritten on the other side of a language boundary and then quietly disagrees.
-- §63's fault at its smallest: two things that must agree, with nothing to notice
-- when they stop. `frames.lua` owns the checks; this points them at measured numbers
-- instead of predicted ones.
--
-- ★★ AND THAT IS THE WHOLE POINT OF THE PROBE. The same functions that say the
-- wireframe is clean can say whether the LIVE pane is - so a collision on screen and
-- a collision in the model are found by one piece of code, and a disagreement between
-- them is about the numbers rather than about two checkers.
--
--     py addons\tools\read_geom.py                      writes client_rects.lua
--     .tools\lua51\lua5.1.exe addons\tools\smoke\check_rects.lua

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\]]
local F = assert(loadfile(ROOT .. [[addons\tools\smoke\frames.lua]]))()

local path = ROOT .. [[addons\staging\client_rects.lua]]
local chunk, err = loadfile(path)
if not chunk then
    print("no client rects yet - run the probe, /reload, then read_geom.py")
    print("  (" .. tostring(err) .. ")")
    return
end
chunk()

local rects, box = {}, nil
for _, r in ipairs(PaneRects.rects) do
    if r.root then box = r end
    rects[#rects + 1] = r
end

-- ⚠ REPORTED, NOT ASSERTED. This is a measurement of what shipped, so a finding here
-- is news rather than a test failure - the smoke suite is where a claim gets enforced.
local hits = F.Overlaps(rects)
local out = box and F.Outside(rects, box) or {}

print(("client rects: %d control(s) in a %dx%d pane")
    :format(#rects - 1, box and box.w or 0, box and box.h or 0))

if #hits == 0 then
    print("  no overlaps")
else
    print(("  %d OVERLAP(S):"):format(#hits))
    for _, h in ipairs(hits) do
        print(("    %-22s over %-22s by %.0f x %.0f"):format(h.a, h.b, h.x, h.y))
    end
end

if #out == 0 then
    print("  nothing outside the pane")
else
    print(("  %d OUTSIDE the pane:"):format(#out))
    for _, o in ipairs(out) do
        print(("    %-22s %s"):format(o.name, o.over))
    end
end
