-- COA_DungeonRun panespec.lua - THE OBJECT PANE, DECLARED (§101).
--
-- ---------------------------------------------------------------------------
-- ★★★ WHAT THIS IS. The object pane as DATA: which zones exist, which subjects each
-- one applies to, and which control sits where. No frames, no behaviour, no
-- refreshing - a declaration `layout.lua` turns into positions and the smoke checks
-- before anything reaches the client.
--
-- ★★ HIS SHAPE, VERBATIM:
--
--     ---------------  divider
--     Header           (to be maintained)
--     { content slot } (dynamic)
--
-- ★★★ THE SPACING IS SOURCED FROM THE CLIENT'S OWN PANELS, not chosen. See
-- `layout.lua`'s constant block for the citations - 6 inside a labelled group, 8
-- between rows, 12 between zones, all read out of the patch-B extraction. ⚠ I had
-- guessed 6 / 6 / 12 and had two of the three relationships collapsed into one.
--
-- ⚠⚠ WHAT IS SOURCED AND WHAT IS MINE, because they are not the same and only one
-- of them is a fact:
--
--   SOURCED   every gap, and every control height (a dropdown is 32, a checkbox 26,
--             an edit box 20 - and a row is now the tallest cell in it)
--   MINE      which zone each control belongs to, and the order of the zones
--
-- ★ So the arrangement below is a PROPOSAL to be cut about. The engine underneath it
-- does not care what the answer is.
--
-- ★★ AND THE ORPHAN CANNOT COME BACK. `behaviour` was a heading at a fixed y that
-- nothing could reach and nothing ever hid. Here a heading exists only as a property
-- of a zone, so there is no way to write one that outlives its content.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Spec = {}
NS.PaneSpec = Spec

-- ⚠ THE FOUR SUBJECT STATES, and the fourth is the one that gets forgotten: NOTHING
-- SELECTED. It is the state the orphaned heading survived into, so it is named here
-- rather than left as "whatever happens when subject is nil".
Spec.SUBJECTS = { "beacon", "child", "note", "none" }

local function only(...)
    local set = {}
    for _, k in ipairs({ ... }) do set[k] = true end
    -- ★ Returns the `hidden` predicate `layout.lua` wants, which is the INVERSE.
    -- Writing it this way round means a zone declares what it is FOR rather than
    -- everything it is not - the list that goes stale when a subject is added.
    return function(subject) return not set[subject] end
end

-- ---------------------------------------------------------------------
-- ★★★ THE PANE
-- ---------------------------------------------------------------------
--
-- A row is a list of cells; a cell is { key, x, kind }. The KIND resolves to the
-- client's own height for that control, so nothing here types a pixel.
Spec.x, Spec.top, Spec.width = 18, -40, 204

-- ★★★ TWO COLUMNS, AND THEY ARE DERIVED FROM THE WIDTH RATHER THAN TYPED. His
-- *"ratio vs content to maintain as a constant"* applies across as well as down:
-- 96 + 12 + 96 = 204 exactly, so the right column ends ON the column edge instead of
-- near it. ⚠ The first cut put the second column at 130 with a 100-wide control and
-- ran 26 past the edge - the clipped-button class again, caught in a second.
local COL2 = 108        -- 204 - 96
local HALF = 96

Spec.zones = {
    -- ★ Always present. Even "none" keeps it, because a pane with nothing in it
    -- reads as broken - it holds the hint instead.
    { name = "identity", header = "identity",
      rows = {
        { { "object.fact",   0, "text" } },
        -- ★ The name takes the width the move chip does not: 170 + 8 + 26 = 204.
        { { "object.name",   0, "edit", 170 }, { "object.move", 178, "check" } },
        { { "object.delete", 0, "button" } },
      },
      rowHidden = {
        -- ⚠ Per-ROW subjects, not just per-zone. With nothing selected the zone
        -- still exists and only the hint survives inside it, which is the difference
        -- between an empty pane and a missing one.
        [2] = only("beacon", "child", "note"),
        [3] = only("beacon", "child", "note"),
      } },

    -- ★★ DETECT: how this child notices the player. His: *"Detect sits above
    -- action"* - so it comes first, and the pane's reading order is the model's.
    { name = "detect", header = "detect", applies = only("child"),
      rows = {
        { { "object.role",  0, "dropdown", HALF }, { "object.match", COL2, "text", HALF } },
        { { "object.shape", 0, "dropdown", HALF }, { "object.reach", COL2, "edit", HALF } },
      } },

    -- ★ ACTION: what it does once it has. Supertrack is the live one.
    { name = "action", header = "action", applies = only("child"),
      rows = {
        { { "object.action", 0, "dropdown", HALF }, { "object.target", COL2, "dropdown", HALF } },
      } },

    -- ★★ STAGE: the ratchet. A beacon and a child both carry one.
    { name = "stage", header = "stage", applies = only("beacon", "child"),
      rows = {
        { { "object.stage",   0, "edit", HALF }, { "object.stagematch", COL2, "text", HALF } },
        { { "object.outcome", 0, "dropdown", HALF } },
      } },

    -- ★★★ THE ON-RAMP, which is a beacon's third answer and the reason §94 exists:
    -- come find me. `unseen` belongs beside it - both are about arrival.
    { name = "arrival", header = "on-ramp", applies = only("beacon", "child"),
      rows = {
        { { "object.ramp",    0, "check" }, { "object.unseen", COL2, "check" } },
        { { "object.answers", 0, "text" } },
      } },

    -- ★ CHILDREN: only a beacon spawns them, so only a beacon shows the spawners.
    { name = "children", header = "children", applies = only("beacon"),
      rows = {
        { { "object.kids", 0, "text" } },
        { { "object.here", 0, "button" }, { "object.pick", COL2, "button" } },
      } },
}

-- ★ DEFAULT WIDTHS, overridable per cell as a 4th field. A `text` cell fills to the
-- right edge of the content column, because that is what a readout does.
Spec.W = { edit = 100, check = 26, button = 80, dropdown = 100 }

-- ⚠⚠ AND THESE ARE OUR PANE'S OWN HEIGHTS, WHICH ARE NOT THE TEMPLATE'S. `Layout.H`
-- holds what the CLIENT declares - the right default for a control nobody sizes. But
-- `object.lua` sizes almost everything itself, and building the wireframe on the
-- template numbers would check a pane we do not have:
--
--   check   20  object.lua:434,719,737  (`moveChip`, `unseenChip`, `rampChip`) - the
--               client's own OptionsBaseCheckButtonTemplate is 26
--   button  20  object.lua:449,579,602  (`delBtn`, `hereBtn`, `pickBtn`)
--   edit    20  object.lua:420,471      - which DOES match InputBoxTemplate
--
-- ★★★ THE DROPDOWN IS THE ONE WE DO NOT SIZE. `object.lua:634` creates it from
-- `UIDropDownMenuTemplate` and calls `UIDropDownMenu_SetWidth(dd, 96)` - which sets
-- the WIDTH only, so the height stays the template's 32. That makes it the tallest
-- thing in the pane by 12, and the row it sits in has to be 32 or the next row is
-- drawn into it.
--
-- ⚠ AND ITS TRUE WIDTH IS AN OPEN QUESTION. The template puts textures either side of
-- the set width, so the frame is wider than 96 - by how much is NOT something I will
-- assert from memory. `UIDropDownMenu_SetWidth` is in the extraction and this is a
-- live-measure item for the same run that measures the fonts.
Spec.H = { edit = 20, check = 20, button = 20 }

-- ---------------------------------------------------------------------
-- ★★★ ONE BUILDER, so the smoke and the pane cannot drift
-- ---------------------------------------------------------------------
--
-- ⚠ THE WHOLE POINT: `object.lua` and `smoke_dungeonrunpromoter.lua` walk the SAME
-- function. A spec the smoke checks and the pane then builds by hand would be two
-- things that must agree with nothing watching them - §63's fault, and this bench
-- has shipped it before.
--
-- `make(key, kind, w, h)` returns a frame already sized; the caller owns widget
-- creation because only it knows whether it is making a real dropdown or a stub.
function Spec.Build(Layout, parent, make)
    local zones = {}
    for _, z in ipairs(Spec.zones) do
        local zone = Layout.NewZone(parent, z.name,
            { header = z.header, hidden = z.applies })
        for i, row in ipairs(z.rows) do
            local cells = {}
            for _, c in ipairs(row) do
                local key, x, kind, w = c[1], c[2], c[3], c[4]
                -- ★ OUR size first, the client's template second. A control this
                -- pane sizes itself must be checked at the size it will actually be.
                local h = Spec.H[kind] or Layout.H[kind] or Layout.ROW_H
                w = w or Spec.W[kind] or (Spec.width - x)   -- text fills the column
                cells[#cells + 1] = { make(key, kind, w, h), x, h }
            end
            Layout.AddRow(zone, cells, { hidden = z.rowHidden and z.rowHidden[i] })
        end
        zones[#zones + 1] = zone
    end
    return zones
end

-- ⚠ THE TEST LINE IS NOT A ZONE. It is the pane's own footer, it applies to every
-- subject including none, and giving it a divider and a heading would say it is a
-- section of the object - which it is not, it is a readout about the last thing you
-- did. Named here so nobody has to wonder why it is missing above.
Spec.footer = { "object.test", 0, "text" }

return Spec
