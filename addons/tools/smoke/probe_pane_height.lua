-- ★ READ-ONLY PROBE (A10.9f): what vertical extent does the declared pane DEMAND?
--
-- A10.9f: *"the sizing question becomes **which group is tallest**, and it is answered by
-- MEASURING rather than by choosing. Nothing here is taste."* ⟶ This is that measurement,
-- as far as the declarations go.
--
-- ⚠ A PROBE, NOT A SMOKE, and named outside the `smoke_*` glob: it asserts nothing and
-- prints. The column's size is an open architecture question (AI-3), and a green row would
-- answer it by default.
--
-- ⚠⚠ AND IT MEASURES ONE GROUP, because only one is declared. `panespec.lua` declares the
-- OBJECT pane; `curation` · `promotion` · `remote` have interface files and no `Spec`.
--
-- ✅ AI-3 ANSWERED WHAT A GROUP IS (AL-13 blank 1, §449): **one interface surface, with the
-- MAP EXCLUDED** — the map and its controls are ONE surface that never docks — so the
-- dockable groups are the other four and a LANE is a GROUP.
-- ★ And the declarations are owed **AS EACH PANE FOLDS**, one at a time, not all at once:
-- so three undeclared groups is the expected state and not a gap to clear before sizing.
-- ⚠ This header said the opposite until §451 - it named `map_controls` among the missing
-- and called it "AI-3's first blank" after AI-3 had been resolved. **My own comment claiming
-- a state that had moved**, which is the fault this session caught three times elsewhere.
--
--     .tools/lua51/lua5.1.exe addons/tools/smoke/probe_pane_height.lua

local here = debug.getinfo(1, "S").source:match("@(.*[/\\])") or ""
-- ⚠ THE ADDON FILES TAKE `("COA_DungeonRun", NS)` AS VARARGS - `select(2, ...)` is the
-- namespace. A bare `dofile` passes nothing and `layout.lua` dies indexing a nil `NS`.
local FR = dofile(here .. "frames.lua")
local NS = {}
local function load(f)
    return assert(loadfile(here .. "../../COA_DungeonRun/" .. f))("COA_DungeonRun", NS)
end
local Layout = load("layout.lua")
local Spec = load("panespec.lua")

local PANE_W = 240
local OBJECT_PANE_H = 600          -- object.lua's own frame height, TODAY

-- ★ THE COLUMN'S BUDGET, which is what the declaration must actually fit (A10.9f): the
-- bolt-on has the MAP SURFACE'S vertical extent. Derived from the two files that own the
-- numbers rather than typed, because a typed 722 rots the day either moves - which is
-- precisely how 600 became the wrong ceiling with nothing noticing.
local ART_H = 668                      -- map.lua:61, the COORDINATE space
local MAP_STRIP, MAP_FOOT = 40, 14     -- options.lua:57
local COLUMN_H = ART_H + MAP_STRIP + MAP_FOOT

local function heightFor(subject)
    FR.Reset()
    local p = FR.New("pane")
    FR.SetRoot(p, PANE_W, OBJECT_PANE_H, 0, 0)
    local zones = Spec.Build(Layout, p, function(key, kind, w, h)
        local fr = FR.New(key, p)
        if w then fr:SetWidth(w) end
        if h then fr:SetHeight(h) end
        return fr
    end)
    return Layout.Height(zones, subject, Spec.top), zones
end

print(("  DECLARED HEIGHT PER SUBJECT - the OBJECT group only")
      :format())
print(("  pane today %d   ·   COLUMN budget %d (map art %d + strip %d + foot %d)")
      :format(OBJECT_PANE_H, COLUMN_H, ART_H, MAP_STRIP, MAP_FOOT))
local tallest, tallestAt = 0, nil
for _, subject in ipairs(Spec.SUBJECTS) do
    local h = heightFor(subject)
    if h > tallest then tallest, tallestAt = h, subject end
    print(("    %-8s %4d   %-22s %s"):format(subject, h,
          h > OBJECT_PANE_H and ("over the " .. OBJECT_PANE_H .. " pane by "
                                 .. (h - OBJECT_PANE_H)) or "fits the pane",
          h > COLUMN_H and ("OVER the column by " .. (h - COLUMN_H))
                        or ("fits the column, " .. (COLUMN_H - h) .. " to spare")))
end
print(("    ---> tallest subject: %s at %d"):format(tostring(tallestAt), tallest))

-- ★★ AND WHAT FOLDING BUYS, measured rather than assumed. A10.3f's fold is built (§444);
-- this says how much room it frees if every foldable zone starts closed.
local h, zones = heightFor(tallestAt)
local foldable = 0
for _, z in ipairs(zones) do
    if Layout.Foldable(z) then
        foldable = foldable + 1
        Layout.SetFolded(z, true)
    end
end
print("")
print(("  FOLD, measured: %d foldable zone(s) on the tallest subject"):format(foldable))
print(("    all open   %4d"):format(h))
print(("    all folded %4d"):format(Layout.Height(zones, tallestAt, Spec.top)))
