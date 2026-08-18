-- COA_DungeonRun layout.lua - ZONES, ROWS, AND A COMPUTED Y (§99).
--
-- Model: addons/planning/driver_programmatic_model.md   THE TARGET - build against this.
-- Basis: addons/planning/dungeonrun_model.md   how we got here. CITE, never build
--        against it (§317) - where the two disagree, the TARGET wins and this moves.
-- ---------------------------------------------------------------------------
-- ★★★ WHY. Every widget in the object pane was hand-positioned with a magic
-- y-offset, and two bugs followed that were not mistakes in the writing - they are
-- what hand-positioning IS:
--
--   an ORPHANED HEADING   `behaviour` was created once at y=-136, held in a local
--                         nothing else can reach, and never hidden. It survives
--                         every pane state including the empty one, and now sits
--                         beside an unrelated dropdown added three sections later.
--   a CLIPPED BUTTON      the play button placed at x=208 on a 280-wide frame
--
-- ⚠ Neither is fixable by being careful. Being careful is the failure mode.
--
-- ★★★ SO A ZONE DECLARES ITSELF AND THE Y IS COMPUTED. Battlewrath's shape:
--
--     ---------------  divider
--     Header
--     { content slot }
--
-- ★★ AND THE DIVIDER BELONGS TO THE ZONE. That is the whole binding: what orphaned
-- was not chrome-ness, it was being FREE-FLOATING. A zone hides its divider, its
-- header and its rows together, because they are one declaration - so the orphan
-- class becomes unrepresentable rather than caught.
--
-- ★★ TWO CONSTANTS, EVERYTHING DERIVED. His: *"we develop a ratio vs content to
-- maintain as a constant."* Same move WeakAuras makes with `normalWidth = 1.3`, from
-- which every width in their options tree descends.
--
-- ★ THE ASSET IS THE CLIENT'S OWN. `options_horizontaldivider` is the line Blizzard's
-- own options panels draw, chosen by him for that reason: *"it's a coded asset (as in,
-- players know it)"*. Same argument as StaticPopup over a bespoke dialog, and the
-- rect is READ from AtlasInfo rather than transcribed - never `SetAtlas`, which
-- forces native size and fails silently under pcall.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Layout = {}
NS.Layout = Layout

-- ★★★ THE CONSTANTS ARE SOURCED NOW, NOT INVENTED (§101). I guessed these; the
-- client's own panels declare them, and we hold the extraction. Each is cited:
--
--   6   a header to the thing it labels   Ascension_AddonPanel/AddonPanelTemplates.xml
--                                         `Value` <- `$parentHeader` BOTTOMLEFT y=-6
--   8   row to row                        FrameXML/InterfaceOptionsPanels.xml - every
--                                         consecutive checkbox stacks at y=-8. Also
--                                         Ascension's content-to-divider gap
--   12  zone to zone                      AddonPanelTemplates.xml - each info block
--                                         <- the previous block's BOTTOMLEFT y=-12
--
-- ⚠⚠ AND I HAD COLLAPSED TWO OF THEM INTO ONE. `GAP` was doing both "header to its
-- content" and "row to row", which are different relationships: a label and the thing
-- it labels are ONE unit and sit tighter than two neighbouring controls. ★ ZONE_GAP
-- came out at 12 either way, which is the only one of my three guesses that was right.
--
-- ★ 24 also exists in their vocabulary (a bigger break, before `Notes`). Not used
-- here, and recorded rather than adopted - we have no group-of-zones yet.
local GAP      = 6    -- header -> its own content
local ROW_GAP  = 8    -- row -> row
local ZONE_GAP = 12   -- zone -> zone
local HEAD_H   = 14
local RULE_H   = 1    -- the divider art is 630x1 (AtlasInfo.lua:2484, read)

-- ⚠⚠ A FALLBACK, NOT A ROW HEIGHT. Every row used to be 20 tall by decree, and the
-- client's own controls are NOT one height:
--
--   EditBox    20   FrameXML/UIPanelTemplates.xml   InputBoxTemplate
--   Button     22   caller-sized; no Size in the template
--   CheckButton 26  SharedXML/Settings/OptionsPanelTemplates.xml  26x26
--   DropDown   32   SharedXML/UIDropDownMenuTemplates.xml         40x32
--
-- ★★★ SO A DROPDOWN IN A 20-TALL ROW OVERFLOWS ITS SLOT BY TWELVE, and the next row
-- is drawn under it regardless - which is a collision the engine ITSELF would have
-- caused. A row's height is now the tallest cell in it, so the stack cannot be wrong
-- about a control it was told the size of.
--
-- ⚠ SOURCED, NOT PROVEN AGAINST OUR PANE: these are the TEMPLATE sizes. What our own
-- dropdown measures in the client is a live question, and it is NOT a diagnosis of
-- the visible clipping - that is still unproven.
local ROW_H = 20

Layout.H = { edit = 20, button = 22, check = 26, dropdown = 32 }

-- ★★★ A DROPDOWN IS ALWAYS FIFTY WIDER THAN THE WIDTH YOU ASK FOR (§103). Measured
-- live - `SetWidth(96)` gives a 146-wide frame - and sourced in the same breath,
-- `SharedXML/UIDropDownMenu.lua:962`:
--
--     _G[frame:GetName().."Middle"]:SetWidth(width)
--     local defaultPadding = 25
--     frame:SetWidth(width + defaultPadding + defaultPadding)
--
-- ⚠⚠ AND THE THIRD ARGUMENT DOES NOT ESCAPE IT. `SetWidth(dd, w, 0)` makes the FRAME
-- `w` - but Left(25) + Middle(w) + Right(25) is still `w + 50` of ARTWORK, now
-- overflowing a frame that claims to be smaller. That is worse than the honest
-- version: it hides the overflow from exactly the rect check meant to catch it.
--
-- ★ So the visual footprint is `asked + 50`, always, and layout must budget it.
Layout.DROPDOWN_PAD = 50

-- ★★★ AND A DROPDOWN HAS THREE DIFFERENT EXTENTS, not one. His: *"the content field,
-- and the click drop-down art, that reacts, aren't the same thing."* Exactly right,
-- and `UIDropDownMenu_SetWidth` sets all three from one argument:
--
--   FIELD   w        `$parentMiddle` - the sunken area the selection reads in
--   TEXT    w - 25   `$parentText`   - the string inside that field
--   ART     w + 50   the frame: Left(25) + Middle(w) + Right(25), and the arrow
--                    that reacts to a click lives out in that Right texture
--
-- ⚠ WHICH ONE YOU MEAN CHANGES THE ANSWER. Budget the ART or a neighbour gets
-- covered; size a label to the FIELD or the text is clipped inside its own box. The
-- promoter asked for 200, read it as "200 wide", and put a button at 208 - inside
-- the 250 of art. ★ One number, three meanings, and picking the wrong one looks
-- exactly like a pane that clips.
Layout.DROPDOWN_FIELD = function(w) return w end
Layout.DROPDOWN_TEXT  = function(w) return w - 25 end
Layout.DROPDOWN_ART   = function(w) return w + Layout.DROPDOWN_PAD end

-- ⚠⚠ AND THE ART IS TALLER THAN THE FRAME TOO. `UIDropDownMenuTemplate`'s three
-- textures are 64 tall on a frame declared 32, anchored TOPLEFT at y = +17 - so the
-- picture runs about 17 above the rect and 15 below it.
--
-- ★★★ THE RULE THAT FALLS OUT: a rect check UNDER-REPORTS a dropdown by design, and
-- a pane can look wrong exactly where the arithmetic says it is fine. Layout uses the
-- frame; anything asking "what does the eye see" has to use this.
Layout.ART = { dropdown = { dw = 50, h = 64, dy = 17 } }
Layout.GAP, Layout.ROW_GAP, Layout.ZONE_GAP = GAP, ROW_GAP, ZONE_GAP
Layout.ROW_H = ROW_H

-- ⚠ READ, NOT TRANSCRIBED. Same path §83 uses for the beacon's gold: AtlasInfo gives
-- {texture, w, h, left, right, top, bottom}, and a missing entry leaves the divider
-- as a plain coloured line rather than an error.
local DIVIDER = "options_horizontaldivider"

function Layout.SkinDivider(tex)
    local info = _G and _G.AtlasInfo and _G.AtlasInfo[DIVIDER]
    if info and info[1] then
        tex:SetTexture(info[1])
        tex:SetTexCoord(info[4], info[5], info[6], info[7])
        return true
    end
    -- ★ A visible fallback, not an invisible one: a divider that silently fails to
    -- draw looks like a spacing bug and gets chased in the wrong place.
    tex:SetTexture(0.4, 0.4, 0.4, 0.6)
    return false
end

-- ---------------------------------------------------------------------
-- ★★★ A ZONE: divider + header + rows, hidden together
-- ---------------------------------------------------------------------
--
-- ⚠ `hidden` is a FUNCTION of the subject, not a flag someone sets. That is the
-- difference between "this zone does not apply to a note" being declared once beside
-- the zone, and being remembered in every branch of a refresh - which is the bug
-- `behaviour` is.

function Layout.NewZone(parent, name, opts)
    opts = opts or {}
    local z = {
        name = name, parent = parent, rows = {},
        hidden = opts.hidden,           -- function(subject) -> true to omit entirely
        header = opts.header,           -- text, or nil for a zone with no heading
    }

    z.rule = parent:CreateTexture(nil, "ARTWORK")
    z.rule:SetHeight(RULE_H)
    Layout.SkinDivider(z.rule)

    -- ⚠ `what` is a plain field, not a frame NAME. Naming a FontString in the client
    -- creates a GLOBAL, which is the whole thing the registry exists to avoid - but
    -- an unnamed one shows up in the offline audit as `pane.fs3`, and a diagnostic
    -- nobody can read is not a diagnostic. A field costs nothing either side.
    z.rule.what = name .. " rule"

    if z.header then
        z.label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        z.label:SetText(z.header)
        z.label.what = name .. " header"
    end
    return z
end

-- ★ A row is a declaration too: what it is, how tall, and WHEN IT APPLIES. A row
-- whose `hidden` says so is skipped entirely - it does not leave a gap, because the
-- stack is computed from what is present rather than from what was planned.
-- ⚠ EACH WIDGET DECLARES ITS OWN X: `{ { frame, 56 }, { frame, 120 } }`. The first
-- cut read the existing x back with `GetPoint()` and re-applied it, which is fragile
-- twice over - a widget with no point yet has none to read, and the offline stub
-- answers differently from the client. ★ That is precisely the harness's own boundary:
-- a model that disagrees with the client is worse than no model.
-- ⚠⚠ A CELL DECLARES ITS HEIGHT TOO: `{ frame, x, h }`. Same argument as the x - the
-- alternative is `GetHeight()`, and the offline stub answers differently from the
-- client, which is the boundary this bench keeps walking into.
--
-- ★★★ AND THE ROW IS THE TALLEST CELL IN IT. A dropdown is 32 and an edit box is 20;
-- a row that decrees 20 draws the next row twelve pixels INTO the dropdown. Deriving
-- it means the engine cannot cause the collision it exists to prevent.
function Layout.AddRow(z, cells, opts)
    opts = opts or {}
    local list, tallest = {}, 0
    for _, c in ipairs(cells) do
        local cell
        if type(c) == "table" and c[1] then
            cell = { frame = c[1], x = c[2] or 0, h = c[3] }
        else
            cell = { frame = c, x = 0 }
        end
        if cell.h and cell.h > tallest then tallest = cell.h end
        list[#list + 1] = cell
    end
    -- ★ An explicit `opts.h` still wins - a row of plain text has no cell heights to
    -- measure - and ROW_H is only reached when nothing said anything at all.
    local h = opts.h or (tallest > 0 and tallest) or ROW_H
    z.rows[#z.rows + 1] = { cells = list, h = h, hidden = opts.hidden }
    return z
end

local function hide(w)
    if w and w.Hide then w:Hide() end
end

local function show(w)
    if w and w.Show then w:Show() end
end

-- ★★★ ONE PASS COMPUTES EVERY Y, and returns where it finished so the next thing
-- down knows where it is. Nothing in a pane needs to know its own offset.
--
-- ⚠ IT HIDES WHAT IT SKIPS. A zone omitted for this subject hides its rule, its
-- header AND its rows - which is the orphan class handled by construction, in the
-- one place that knows a zone was skipped.
function Layout.Apply(zones, subject, x, top, width)
    local y = top
    for _, z in ipairs(zones) do
        local off = z.hidden and z.hidden(subject)
        if off then
            hide(z.rule); hide(z.label)
            for _, r in ipairs(z.rows) do
                for _, c in ipairs(r.cells) do hide(c.frame) end
            end
        else
            y = y - ZONE_GAP
            z.rule:ClearAllPoints()
            z.rule:SetPoint("TOPLEFT", x, y)
            z.rule:SetWidth(width)
            show(z.rule)
            y = y - RULE_H - GAP

            if z.label then
                z.label:ClearAllPoints()
                z.label:SetPoint("TOPLEFT", x, y)
                show(z.label)
                y = y - HEAD_H - GAP
            end

            for _, r in ipairs(z.rows) do
                if r.hidden and r.hidden(subject) then
                    for _, c in ipairs(r.cells) do hide(c.frame) end
                else
                    -- ★ A row is a BAND: it owns the Y, each cell owns its X. The bug
                    -- this exists to kill is vertical, and widening it to solve
                    -- horizontal placement too would be a second thing to be wrong.
                    for _, c in ipairs(r.cells) do
                        if c.frame and c.frame.SetPoint then
                            c.frame:ClearAllPoints()
                            c.frame:SetPoint("TOPLEFT", z.parent, "TOPLEFT", x + c.x, y)
                        end
                        show(c.frame)
                    end
                    -- ★ ROW_GAP, not GAP: two neighbouring controls sit further
                    -- apart than a header does from the thing it labels. The
                    -- client's own options panel stacks every checkbox at 8.
                    y = y - r.h - ROW_GAP
                end
            end
        end
    end
    return y
end

-- ★★ THE HEIGHT A PANE NEEDS, computed from what is actually present. A pane sized
-- by hand grows a dead strip the first time a zone is hidden, and clips the first
-- time one is added.
function Layout.Height(zones, subject, top, pad)
    local y = Layout.Apply(zones, subject, 0, top, 1)
    return math.abs(y) + (pad or GAP * 2)
end

return Layout
