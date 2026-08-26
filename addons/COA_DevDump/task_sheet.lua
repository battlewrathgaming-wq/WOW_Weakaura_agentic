-- task_sheet.lua - spawn the UI test sheet, measure every declared cell, record it.
--
--     /coadump r sheet        spawn it, measure it, record it
--     /reload                 flush the mailbox (the watcher lands it)
--
-- ★★★ ONE COMMAND, NO ARGUMENTS, EVERY TIME (Battlewrath, 2026-08-23: *"I get lost writing the
-- test commands manually"*). A resolution sweep is the SAME command at every setting - the run
-- reads the configuration off the client itself rather than being told it. There is nothing to
-- remember and nothing to type differently, which is the only form a sweep survives.
--
-- ★★ THE SHEET IS SHOWN WHILE IT IS MEASURED, AND THAT IS CORRECTNESS, NOT PRESENTATION.
-- `check_sheet.py` measured it: across seven geom captures every SHOWN FontString width sits on
-- the client's integer grid and the never-shown control width is the ONLY value off it - 1.7%
-- different, which is the worst kind of wrong because nothing downstream would flag it. So the
-- host is parented, positioned and left visible, and the record says so.
--
-- ★ AND BEING VISIBLE IS ALSO THE POINT. The measured cells are checked by machine; the swatch
-- rows exist to be LOOKED at, because whether a face reads right is not a measurable question.
-- `ui_sheet_spec.md` keeps those two natures apart on purpose.
--
-- ⚠ THE DECLARATION IS THE SOURCE. Specimens come from `sheet_decl.lua` (COA_UI_SHEET) and this
-- file invents none of them. If the global is missing the run REFUSES rather than measuring a
-- default it made up - a sheet whose specimens came from the measuring tool is not a standard.

local ADDON, D = ...

-- The host is created once and reused, so a sweep does not stack eleven panes.
local sheet

local function buildSheet()
    if sheet then return sheet end

    -- ★★★ THE LAYOUT IS READ, NOT CARRIED. `sheet_decl.lua`'s `pane` kind holds every
    -- number below, and `addons/tools/check_layout.py` contradicts that same table offline.
    -- ⚠⚠ A declaration the builder ignores is the SECOND COPY THAT DRIFTS - so this file
    -- keeps none of its own. The fallbacks exist only so a missing `pane` cannot brick the
    -- sheet; they are not a copy to maintain, and `check_layout` reports a missing kind.
    local L = (type(COA_UI_SHEET) == "table" and COA_UI_SHEET.pane) or {}
    local Lsheet = L.sheet or { w = 1010, h = 612 }
    local Lpage  = L.page  or { x = 18, y = -70, w = 974, h = 524 }
    local Lstrip = L.strip or { x = 470, y = -16, w = 120, h = 22, gap = 124, n = 3 }
    local Ltitle = L.title or { x = 18, y = -18 }
    local LB = {}
    for _, b in ipairs(L.boards or {}) do LB[b.name] = b end
    -- ⚠ A board the declaration does not name gets NO fallback geometry: it would be placed
    -- at the page origin, on top of whatever is there, and look like a layout bug rather than
    -- a missing declaration. Better it is visibly at 0,0 than plausibly somewhere.
    local function place(f, parent, name)
        local b = LB[name]
        if not b then return false end
        f:SetPoint("TOPLEFT", parent, "TOPLEFT", b.x, b.y)
        f:SetWidth(b.w); f:SetHeight(b.h)
        return true
    end

    sheet = CreateFrame("Frame", "COA_UISheet", UIParent)
    sheet:SetWidth(Lsheet.w)
    sheet:SetHeight(Lsheet.h)
    sheet:SetPoint("CENTER")
    -- ★★★ TOP STRATA, on his ask: *"make the pane sit on the highest strata so my UI
    -- doesn't eclipse it for clean feedback"*. TOOLTIP is the highest 3.3.5 offers, and a
    -- dev instrument wanting to be ABOVE a tooltip is the one case where that is right.
    -- ⚠ Strata does not touch geometry - `GetLeft` and `GetWidth` answer the same - so no
    -- measurement in this file changes because of it.
    sheet:SetFrameStrata("TOOLTIP")
    sheet:SetFrameLevel(100)

    -- ★★★ AN OPAQUE, FLAT GROUND - and it is CORRECTNESS for this instrument, not taste.
    -- His: *"maybe construct a background that is more machine readable if needed?"*
    -- The dialog backdrop is a translucent parchment tile, so the dungeon shows THROUGH the
    -- sheet: every screenshot carries torchlight, a wall and a mob behind the numbers.
    -- ⟶ This pane's whole job is that a SCREENSHOT IS THE EVIDENCE. A ground that varies
    -- with where the player is standing makes two runs of the same sheet unlike each other,
    -- which is the same fault as an unstable specimen.
    -- ★ Flat near-black, one colour, full alpha: maximum contrast against every text colour
    -- the sheet draws (gold, white, grey, red) and nothing behind it to read as content.
    sheet:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8X8",
        edgeFile = "Interface/Buttons/WHITE8X8",
        tile = false, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    sheet:SetBackdropColor(0.04, 0.04, 0.05, 1)
    sheet:SetBackdropBorderColor(0.45, 0.38, 0.14, 1)
    sheet:SetMovable(true)
    sheet:EnableMouse(true)
    sheet:RegisterForDrag("LeftButton")
    sheet:SetScript("OnDragStart", function(self) self:StartMoving() end)
    sheet:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local close = CreateFrame("Button", nil, sheet, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", sheet, "TOPRIGHT", -6, -6)

    sheet.title = sheet:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sheet.title:SetPoint("TOPLEFT", sheet, "TOPLEFT", Ltitle.x, Ltitle.y)

    sheet.config = sheet:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sheet.config:SetPoint("TOPLEFT", sheet.title, "BOTTOMLEFT", 0, -6)

    -- ★★★ THREE PAGES, and the sheet is finally EATING ITS OWN COOKING.
    -- His, 2026-08-24: *"Maybe time to add a tab 2 for the test sheet. Or 2 panes."*
    -- ⟶ TABS, not two panes, and the deciding reason is the REGISTRATION PINS: eight pins
    -- plus the centre ring are anchored to ONE frame and `check_sheet` rectifies a screenshot
    -- against them. Two panes would be two coordinate systems and the rectification would
    -- have to be done twice. One frame, one set of pins, unchanged.
    --
    -- ★★ AND THE POINTED PART: this pane PROVED tabs (UL-13), collapse (UL-14) and scroll
    -- (UL-21), and was the one surface on the project that used none of them - it just grew,
    -- 700 -> 880 -> 1010. Paging it is the feedback loop AP-13's test asks for, not a tidy-up.
    -- ⟶ 1010 tall becomes **660**, and it is now SHORTER than before sheets nine and its
    -- prototype were added, because the tallest page sets the height instead of the sum.
    --
    -- ⚠ ONE PAGE IS MEASURED PER RUN - his ruling: *"It should measure the page of interest.
    -- And we can bake tab opening into the command. /coadump r sheet1 or sheet2 or sheet3"*.
    -- ★ Which is better than reading the page off whatever was clicked: the page is DECLARED
    -- BY THE COMMAND, so the record and the intent agree by construction and a run repeats
    -- exactly. A block whose page was not shown reports **not measured**, never 0.
    sheet.pages = {}
    sheet.pageStrips = {}
    local PAGE_NAMES = { "1 specimens", "2 devices", "3 prototypes" }
    for i = 1, 3 do
        local pg = CreateFrame("Frame", nil, sheet)
        pg:SetPoint("TOPLEFT", sheet, "TOPLEFT", Lpage.x, Lpage.y)
        pg:SetWidth(Lpage.w); pg:SetHeight(Lpage.h)
        if i > 1 then pg:Hide() end
        sheet.pages[i] = pg

        -- ⚠ The strip is built the way sheet six MEASURED one, not a fresh invention:
        -- a text-sized button in a row, 37px of strip, its own click target.
        local s = CreateFrame("Button", nil, sheet)
        s:SetHeight(Lstrip.h); s:SetWidth(Lstrip.w)
        -- ★ IN THE TITLE'S BAND, his ask 2026-08-25: *"move the tabs into the same heading
        -- space as the title on a page that big."* The strip was on its own row at -84,
        -- which spent 44px of height on a frame whose whole point this week was to stop
        -- growing. ⟶ Beside the title, and the pages come up to -70: **660 -> 612**.
        s:SetPoint("TOPLEFT", sheet, "TOPLEFT",
                   Lstrip.x + (i - 1) * Lstrip.gap, Lstrip.y)
        local bg = s:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(s)
        local fs = s:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("CENTER", s, "CENTER", 0, 0)
        fs:SetText(PAGE_NAMES[i])
        s:SetScript("OnClick", function() sheet.SetPage(i) end)
        sheet.pageStrips[i] = { f = s, bg = bg, fs = fs }
    end

    -- ★ SetPage is the ONE place the shown page changes, so `sheet.page` can never disagree
    -- with what is on screen - the same reason the range's three quantities are three calls.
    function sheet.SetPage(n)
        n = tonumber(n) or 1
        if n < 1 or n > 3 then n = 1 end
        sheet.page = n
        for i = 1, 3 do
            if i == n then sheet.pages[i]:Show() else sheet.pages[i]:Hide() end
            local st = sheet.pageStrips[i]
            st.bg:SetTexture(i == n and 0.30 or 0.12, i == n and 0.26 or 0.12,
                             i == n and 0.10 or 0.14, 1)
            st.fs:SetTextColor(i == n and 1 or 0.55, i == n and 0.82 or 0.55,
                               i == n and 0 or 0.55)
        end
    end
    sheet.page = 1

    -- The measuring host. Parented to the sheet so it inherits the same effective
    -- scale as everything on it, and never hidden.
    sheet.host = CreateFrame("Frame", nil, sheet.pages[1])
    place(sheet.host, sheet.pages[1], "host")

    -- ★★★ THE BOARD - the half of the original ask I had not built. His words on the
    -- day the sheet was proposed: *"Where we preload input types as one pane. Then say
    -- input fields. Textures. Basically swatch boards."* Sheets two and three created
    -- their widgets, measured them and released them, so nothing was ever ON the pane -
    -- I built the measured nature and none of the taste one. `ui_sheet_spec.md` names
    -- them as two natures and I shipped one.
    --
    -- ★★ AND IT IS NOT DECORATION - IT IS WHAT ART IS MEASURED FROM. A frame created,
    -- shown and read in the same tick has no resolved rect: the first `art` run came
    -- back with 6 of 6 dropdown regions "unplaced" and zeros everywhere. The board is
    -- PERSISTENT and laid out, so a measurement a frame later reads real numbers -
    -- the same argument as measuring text on a SHOWN frame rather than a hidden one.
    sheet.board = CreateFrame("Frame", nil, sheet.pages[1])
    place(sheet.board, sheet.pages[1], "board")

    sheet.boardTitle = sheet.pages[1]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sheet.boardTitle:SetPoint("BOTTOMLEFT", sheet.board, "TOPLEFT", 0, 4)
    sheet.boardTitle:SetText("input types, as built   -   NAMED  vs  anonymous")

    -- ★★★ THE TAB BOARD - PERSISTENT, and its absence is the whole of *"No tabs seen"*.
    -- Sheet six measured 45 strips and released every one of them, so the run was correct
    -- and the pane was empty. ⚠⚠ THAT IS THE SAME FAULT THIS FILE ALREADY DOCUMENTS forty
    -- lines above, in a comment I wrote: *"Sheets two and three created their widgets,
    -- measured them and released them, so nothing was ever ON the pane."*
    -- ⟶ A measured nature and a LOOKED-AT nature; `ui_sheet_spec.md` names them as two and
    -- sheet six shipped one. These three stay, and they are clickable.
    sheet.tabBoard = CreateFrame("Frame", nil, sheet.pages[2])
    place(sheet.tabBoard, sheet.pages[2], "tabBoard")

    sheet.tabBoardTitle = sheet.pages[2]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sheet.tabBoardTitle:SetPoint("BOTTOMLEFT", sheet.tabBoard, "TOPLEFT", 0, 4)
    sheet.tabBoardTitle:SetText("tab strips, at 240   -   click them   (labels are DELIBERATELY meaningless)")

    -- ★★ THE COLLAPSE BOARD - sheet seven's looked-at half, in its own column so nothing
    -- above it moves. Collapsing is a BEHAVIOUR: whether a shut header still tells you what
    -- is inside is not a measurable question, and it is the whole point of WA's
    -- `1. Desaturate: OFF`.
    sheet.collapseBoard = CreateFrame("Frame", nil, sheet.pages[2])
    place(sheet.collapseBoard, sheet.pages[2], "collapseBoard")

    sheet.collapseTitle = sheet.pages[2]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sheet.collapseTitle:SetPoint("BOTTOMLEFT", sheet.collapseBoard, "TOPLEFT", 0, 4)
    sheet.collapseTitle:SetText("collapsing sections, at 240   -   click a header")

    -- ★ Sheet eight's control, in its own band under the A:B board.
    sheet.rangeBoard = CreateFrame("Frame", nil, sheet.pages[2])
    place(sheet.rangeBoard, sheet.pages[2], "rangeBoard")

    sheet.rangeTitle = sheet.pages[2]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sheet.rangeTitle:SetPoint("BOTTOMLEFT", sheet.rangeBoard, "TOPLEFT", 20, 2)
    sheet.rangeTitle:SetText("the range, from scratch   -   gold = envelope, blue = slice")

    -- ★ Sheet nine's looked-at half. The sheet grew 700 -> 880 for it; the registration
    -- pins read `sheet:GetHeight()` so they follow, and no existing board moved.
    sheet.scrollBoard = CreateFrame("Frame", nil, sheet.pages[2])
    place(sheet.scrollBoard, sheet.pages[2], "scrollBoard")

    sheet.scrollTitle = sheet.pages[2]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sheet.scrollTitle:SetPoint("BOTTOMLEFT", sheet.scrollBoard, "TOPLEFT", 0, 4)
    sheet.scrollTitle:SetText("scroll, at 204   -   744 of content in a 200 viewport")

    -- ★★ SHEET TEN'S BOARD, on page 3 because it is a PROTOTYPE and because four arms
    -- never fitted under `scrollBoard`.
    -- ⚠⚠ IT WAS DECLARED AND NEVER BUILT until v13, and TWO CAPTURES DID NOT NOTICE: every
    -- arm parented to a nil `sheet.hostBoard`, which defaults to UIParent, so they drew
    -- loose on screen. ★ The NUMBERS were still true - real widgets, real layout - which is
    -- precisely why nothing caught it. `check_layout` checks a DECLARED board against its
    -- page; a board nobody built is not a board that overflows.
    sheet.hostBoard = CreateFrame("Frame", nil, sheet.pages[3])
    place(sheet.hostBoard, sheet.pages[3], "hostBoard")

    -- ★★★ THE PROTOTYPE BAND - sheet nine's finding turned into a CHOICE he can look at.
    -- Two containers, same declared width, same content, differing in ONE rule.
    sheet.protoBoard = CreateFrame("Frame", nil, sheet.pages[3])
    place(sheet.protoBoard, sheet.pages[3], "protoBoard")

    sheet.protoTitle = sheet.pages[3]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sheet.protoTitle:SetPoint("BOTTOMLEFT", sheet.protoBoard, "TOPLEFT", 0, 4)
    sheet.protoTitle:SetText(
        "PROTOTYPE - the gutter, at 204:  A FLIPS (upstream)   vs   B RESERVES (ours)"
        .. "   -   click ADD/REMOVE and watch which one moves")

    sheet.rows = {}
    return sheet
end

-- ⚠ Built ONCE, and REBUILT on every toggle - which is WA's own model. `CommonOptions.lua`
-- flips a stored flag and re-feeds the dialog; nothing hides children in place. Rebuilding
-- here is faithful to that rather than convenient.
local function buildCollapseBoard(decl, AceGUI)
    if sheet.collapseRoot or not AceGUI then return end
    local cdecl = decl.collapse
    if type(cdecl) ~= "table" then return end
    local secs = cdecl.sections or {}

    local open = {}
    for i = 1, #secs do open[i] = (i == 1) end     -- one-open, the state a person sees

    local root = AceGUI:Create("SimpleGroup")
    root:SetLayout("List")
    root:SetWidth(240)
    root:SetHeight(520)
    root.frame:SetParent(sheet.collapseBoard)
    root.frame:ClearAllPoints()
    root.frame:SetPoint("TOPLEFT", sheet.collapseBoard, "TOPLEFT", 0, 0)
    root.frame:Show()
    sheet.collapseRoot = root

    local function redraw()
        root:ReleaseChildren()
        for i = 1, #secs do
            local s = secs[i]
            local hdr = AceGUI:Create("Button")
            -- ★ WA's header is a BUTTON (`type = "execute"`) and its text carries the
            -- STATE. A header that only said its name would make collapse into hiding.
            hdr:SetText((open[i] and "-  " or "+  ") .. (s.summary or s.name))
            hdr:SetFullWidth(true)
            hdr:SetCallback("OnClick", function()
                open[i] = not open[i]
                redraw()
            end)
            root:AddChild(hdr)
            if open[i] then
                for f = 1, (s.fields or 0) do
                    local w = AceGUI:Create(cdecl.fieldWidget or "EditBox")
                    w:SetFullWidth(true)
                    w:SetLabel(nil)
                    -- ⚠ §589: a specimen must never hold the keyboard.
                    if w.editbox and w.editbox.SetAutoFocus then
                        pcall(function() w.editbox:SetAutoFocus(false) end)
                    end
                    root:AddChild(w)
                end
            end
        end
        root:DoLayout()
    end

    pcall(redraw)
end



-- ★★★ REGISTRATION PINS - his ask: *"some anchors that locate the central read and the edges?
-- 8 pins. Corners and a square center, each a different color key?"*
--
-- ★★ WHAT THEY ARE FOR, and it is not decoration. A screenshot of this sheet is EVIDENCE
-- (§621), but an image has no coordinates: nothing in it says where sheet-x 460 is. Eight
-- pins at KNOWN sheet positions in KNOWN colours make the image RECTIFIABLE - find two pins,
-- derive scale and offset, and every other pixel in that screenshot becomes a sheet
-- coordinate. ⟶ The picture stops being something to look at and becomes something to measure.
--
-- ⚠⚠ AND THE PINS ARE EMITTED WITH THEIR RECTS AND COLOURS. A mark nobody can look up is a
-- mark nobody can use: the record carries name -> {r,g,b} and the exact rect, so a reader
-- searches the image for a colour it was TOLD to expect rather than one it guessed.
--
-- ★ COLOUR CHOICE, deliberately: full-saturation hues the sheet's own content never draws.
-- The sheet uses gold (1,.82,0), white, grey, red (1,0,0) and blue (.55,.8,1), so the keys
-- avoid that neighbourhood - no pure red, and nothing gold-adjacent.
local REG_PINS = {
    { "tl",     0, 0,   1, 0, 1 },      -- magenta
    { "top",  0.5, 0,   0, 1, 1 },      -- cyan
    { "tr",     1, 0,   0, 1, 0 },      -- green
    { "left",   0, 0.5, 1, 0.4, 0 },    -- orange
    { "right",  1, 0.5, 0.6, 0, 1 },    -- violet
    { "bl",     0, 1,   1, 0.2, 0.6 },  -- pink
    { "bottom", 0.5, 1, 0, 1, 0.5 },    -- spring
    { "br",     1, 1,   0, 0.4, 1 },    -- azure
}
local PIN, CENTRE = 8, 18

local function buildRegistration()
    if sheet.regPins then return end
    sheet.regPins = {}
    local W, H = sheet:GetWidth(), sheet:GetHeight()
    for i = 1, #REG_PINS do
        local name, fx, fy, r, g, b = unpack(REG_PINS[i])
        local f = CreateFrame("Frame", nil, sheet)
        f:SetWidth(PIN); f:SetHeight(PIN)
        f:SetFrameStrata("TOOLTIP")
        f:SetFrameLevel(sheet:GetFrameLevel() + 20)
        -- ⚠ Inset by ONE pin so a pin is never clipped by the border, and so its own rect is
        -- wholly inside the sheet - a half-visible mark cannot be located.
        f:SetPoint("TOPLEFT", sheet, "TOPLEFT",
                   2 + fx * (W - PIN - 4), -(2 + fy * (H - PIN - 4)))
        local tex = f:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints(f); tex:SetTexture(r, g, b, 1)
        sheet.regPins[name] = { f = f, r = r, g = g, b = b }
    end
    -- ★ THE CENTRE IS BIGGER AND NOT ON AN EDGE, so "which mark is the middle" needs no
    -- colour lookup at all.
    --
    -- ★★★ AND IT IS A RING, NOT A SQUARE - because a solid one COVERED THE DROPDOWN.
    -- Battlewrath saw it and offered two fixes: hollow it, or reserve the space and step the
    -- content down. ⟶ HOLLOW, and the reason is not convenience:
    -- **a registration mark is METADATA ABOUT THE IMAGE, not content.** If it reserved
    -- space the sheet's layout would start expressing the INSTRUMENT's needs rather than the
    -- specimens', and every future mark would have to be budgeted into the arrangement.
    -- Nothing that describes the picture should push the picture around.
    --
    -- ⚠ AND A RING IS NOT HARDER TO FIND - it is easier. An outline gives EDGES to detect,
    -- and a closed 3px square of one colour is a shape no glyph makes: the sheet draws white
    -- TEXT everywhere, which is thin open strokes, so a closed ring cannot be confused for it.
    local c = CreateFrame("Frame", nil, sheet)
    c:SetWidth(CENTRE); c:SetHeight(CENTRE)
    c:SetFrameStrata("TOOLTIP")
    c:SetFrameLevel(sheet:GetFrameLevel() + 20)
    c:SetPoint("CENTER", sheet, "CENTER", 0, 0)
    local STROKE = 3
    for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local bar = c:CreateTexture(nil, "OVERLAY")
        bar:SetTexture(1, 1, 1, 1)
        if side == "TOP" or side == "BOTTOM" then
            bar:SetWidth(CENTRE); bar:SetHeight(STROKE)
        else
            bar:SetWidth(STROKE); bar:SetHeight(CENTRE)
        end
        bar:SetPoint(side, c, side, 0, 0)
    end
    -- ⚠ The RECT is unchanged, so the emitted key and any rectification built on it still
    -- point at the same place. Only what is drawn inside it changed.
    sheet.regPins.centre = { f = c, r = 1, g = 1, b = 1 }
end

-- ★★★ THE RANGE DEMO - his arrangement (design doc §0c), built from scratch over the mock
-- sample. ONE BAR; envelope handles ABOVE it; slice handles BELOW; the slice body draggable;
-- steppers under that.
--
-- ⚠ "NO DISPLAY" MEANT NO MAP, and §615 read it as "no widget" before he corrected it:
-- *"Display wise I meant display of it actually filtering content on a map."* ⟶ The control
-- is built; what it does NOT do is draw filtered nodes. Its selection shows as a LIST.
--
-- ★★ THE THREE QUANTITIES ARE THREE CALLS. `map.lua:765 SetWindow(pos, width)` fuses breadth
-- and position, which is why the product's bar and handles compete for one surface. Here
-- envelope · breadth · position are set independently, and the geometry follows: every grab
-- target gets its own y band, so NO TWO OVERLAP and no precedence rule is needed.
local function buildRangeBoard(decl, AceGUI)
    if sheet.rangeItems or not COA_RANGE_WALK then return end
    local R = decl.range
    if type(R) ~= "table" then return end
    sheet.rangeItems = {}

    local W = COA_RANGE_WALK
    local BAR_W, BAR_H, GRAB = 204, 10, 14
    -- ★★★ THE OFFSET IS ARITHMETIC, NOT A GUESS, and §619's overlap check found it 2px
    -- short on the first run. A handle is anchored by its CENTRE to the bar's CENTRE, so it
    -- must clear half the bar AND half of itself: BAR_H/2 + GRAB/2. Using BAR_H put every
    -- handle 2px inside the bar band and produced three overlapping pairs - the one thing
    -- the arrangement exists to avoid.
    -- ⚠ +1 so they TOUCH rather than abut exactly; the test allows a shared edge, but a
    -- visible hairline is what tells the eye they are separate objects.
    local OFF = BAR_H / 2 + GRAB / 2 + 1
    local span = R.span or 120
    local st = { envLo = 0, envHi = span, breadth = 20, at = 0 }
    W.Clamp(st)

    local host = sheet.rangeBoard
    local bar = CreateFrame("Frame", nil, host)
    bar:SetWidth(BAR_W); bar:SetHeight(BAR_H)
    bar:SetPoint("TOPLEFT", host, "TOPLEFT", 20, -26)

    local track = bar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints(bar); track:SetTexture(0.18, 0.18, 0.20, 1)
    local envFill = bar:CreateTexture(nil, "ARTWORK")
    envFill:SetHeight(BAR_H)
    local sliceFill = bar:CreateTexture(nil, "OVERLAY")
    sliceFill:SetHeight(BAR_H); sliceFill:SetTexture(0.55, 0.80, 1.00, 0.9)

    local readout = host:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    readout:SetPoint("TOPLEFT", host, "TOPLEFT", 20, -6)
    local selText = host:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    selText:SetPoint("TOPLEFT", host, "TOPLEFT", 20, -62)
    -- ⚠ 400, not 480: the rangeBoard is 420 wide since `check_layout` found it
    -- crossing collapseBoard at 530. A readout wider than its board is the next
    -- overlap, one level down, and the checker does not see inside a board.
    selText:SetWidth(400); selText:SetJustifyH("LEFT")

    local function x(sec) return (sec / span) * BAR_W end

    local refresh
    local function makeHandle(role, above)
        local h = CreateFrame("Button", nil, host)
        h:SetWidth(GRAB); h:SetHeight(GRAB)
        h:SetFrameLevel(bar:GetFrameLevel() + 5)
        local t = h:CreateTexture(nil, "OVERLAY")
        t:SetWidth(3); t:SetHeight(GRAB - 2)
        t:SetPoint("CENTER")
        -- ★ Envelope gold, slice blue - so which pair you are holding is legible without
        -- reading a label, which is the whole reason they are on opposite sides.
        if above then t:SetTexture(1, 0.82, 0, 1) else t:SetTexture(0.55, 0.80, 1, 1) end
        local function drag(self)
            local cx = (GetCursorPosition() / bar:GetEffectiveScale()) - bar:GetLeft()
            cx = math.max(0, math.min(BAR_W, cx))
            local sec = math.floor((cx / BAR_W) * span + 0.5)
            if role == "envLo" then st.envLo = math.min(sec, st.envHi - 1)
            elseif role == "envHi" then st.envHi = math.max(sec, st.envLo + 1)
            elseif role == "sliceLo" then
                local hi = st.at + st.breadth
                st.at = math.min(sec, hi - 1); st.breadth = hi - st.at
            elseif role == "sliceHi" then
                st.breadth = math.max(1, sec - st.at)
            end
            W.Clamp(st); refresh()
        end
        h:SetScript("OnMouseDown", function(self) self:SetScript("OnUpdate", drag) end)
        h:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
        h:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)
        sheet.rangeItems[role] = h
        return h
    end

    local envLoH, envHiH = makeHandle("envLo", true), makeHandle("envHi", true)
    local slLoH, slHiH = makeHandle("sliceLo", false), makeHandle("sliceHi", false)

    -- ★ THE SLICE BODY - press-to-grab, the handles' own idiom, so all three quantities
    -- share one interaction model. This is the target the product does not have: today a
    -- bar click JUMPS (editor.lua:438) and cannot scrub.
    local body = CreateFrame("Frame", nil, host)
    body:SetHeight(BAR_H)
    body:SetFrameLevel(bar:GetFrameLevel() + 2)
    body:EnableMouse(true)
    local grabAt, grabX
    body:SetScript("OnMouseDown", function(self)
        grabAt = st.at
        grabX = (GetCursorPosition() / bar:GetEffectiveScale()) - bar:GetLeft()
        self:SetScript("OnUpdate", function()
            local cx = (GetCursorPosition() / bar:GetEffectiveScale()) - bar:GetLeft()
            st.at = grabAt + math.floor(((cx - grabX) / BAR_W) * span + 0.5)
            W.Clamp(st); refresh()
        end)
    end)
    body:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
    body:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)
    sheet.rangeItems.sliceBody = body

    local function btn(label, dx, fn)
        local b = CreateFrame("Button", nil, host, "UIPanelButtonTemplate")
        b:SetWidth(30); b:SetHeight(18)
        b:SetPoint("TOPLEFT", host, "TOPLEFT", 20 + dx, -78)
        b:SetText(label)
        b:SetScript("OnClick", function() fn(); W.Clamp(st); refresh() end)
        return b
    end
    local bPrev = btn("<", 0,   function() st.at = st.at - W.SkipStep(st.breadth) end)
    local bNext = btn(">", 34,  function() st.at = st.at + W.SkipStep(st.breadth) end)
    local bNarr = btn("-", 76,  function() st.breadth = math.floor(st.breadth / 2) end)
    local bWide = btn("+", 110, function() st.breadth = st.breadth * 2 end)

    local function clock(s) return string.format("%d:%02d", math.floor(s / 60), s % 60) end

    refresh = function()
        envFill:ClearAllPoints()
        envFill:SetPoint("LEFT", bar, "LEFT", x(st.envLo), 0)
        envFill:SetWidth(math.max(1, x(st.envHi) - x(st.envLo)))
        envFill:SetTexture(0.40, 0.34, 0.10, 1)
        sliceFill:ClearAllPoints()
        sliceFill:SetPoint("LEFT", bar, "LEFT", x(st.at), 0)
        sliceFill:SetWidth(math.max(1, x(st.at + st.breadth) - x(st.at)))
        body:ClearAllPoints()
        body:SetPoint("LEFT", bar, "LEFT", x(st.at), 0)
        body:SetWidth(math.max(4, x(st.at + st.breadth) - x(st.at)))

        envLoH:SetPoint("CENTER", bar, "LEFT", x(st.envLo), OFF)
        envHiH:SetPoint("CENTER", bar, "LEFT", x(st.envHi), OFF)
        slLoH:SetPoint("CENTER", bar, "LEFT", x(st.at), -OFF)
        slHiH:SetPoint("CENTER", bar, "LEFT", x(st.at + st.breadth), -OFF)

        -- ★ TIME IS THE ANCHOR (his ruling): the readout stays in time. The selection is
        -- shown because this demo has no map to show it ON - it is the function's output,
        -- not a count the user selects for.
        readout:SetText(("envelope %s - %s   ·   slice %s wide at %s   ·   step %ds")
            :format(clock(st.envLo), clock(st.envHi), clock(st.breadth), clock(st.at),
                    W.SkipStep(st.breadth)))
        local sel = W.Select(R.sample or {}, st)
        selText:SetText("in slice: " .. (table.concat(sel, ", ")))

        -- ⚠ A CLAMPED CONTROL IS DISABLED, NOT SILENT - sheet eight's own finding
        -- (`--range`: four steps clamped to nothing). AceGUI tints a disabled widget and so
        -- does UIPanelButtonTemplate; without this the press is a genuine no-op with no sign.
        if st.at <= st.envLo then bPrev:Disable() else bPrev:Enable() end
        if st.at + st.breadth >= st.envHi then bNext:Disable() else bNext:Enable() end
        if st.breadth <= W.MIN_BREADTH then bNarr:Disable() else bNarr:Enable() end
        if st.breadth >= (st.envHi - st.envLo) then bWide:Disable() else bWide:Enable() end
    end
    refresh()
end

-- ⚠ Built ONCE. Three strips at the width the unified pane and the remote both are, left
-- on the sheet so a person can click them - which is the only way to answer "does the page
-- move", a question no measurement asks.

-- ★★★ SHEET NINE - and what it builds is deliberately NOT an AceGUI container.
-- `prior_art_ace_field` §6a: we ship 13 of AceConfigDialog's 17 widget types and
-- **ScrollFrame is missing**. The container exists upstream and landing it is the Addon
-- creator's (`audit/ace3_gap_2026-08-24.md:210`).
--
-- ⟶ So this builds the CLIENT PRIMITIVES that any wrapper is built on - `ScrollFrame` plus
-- `UIPanelScrollBarTemplate` - anchored exactly as upstream anchors them (bar 16 wide, its
-- TOPLEFT at the viewport's TOPRIGHT +4). ★ The point is not to reimplement the container.
-- It is that upstream's arithmetic - "the viewport gives up 20" - is a claim about how these
-- two primitives compose, and **this fork customises at the CALLER layer**, so the claim is
-- worth measuring here rather than trusting there.
--
-- ⚠ THE MEASUREMENT IS A DIFFERENCE, NOT A READING. One viewport with a bar and one without,
-- same declared width: the gap between their usable widths IS the cost. A single frame's
-- width tells you nothing, because nothing says what it would have been.
-- ★★★ SHEET TEN - THE HOSTED STATE, MEASURED (2026-08-26).
--
-- His question: *"Does ace still handle the position on the hosted frame, or do we hand
-- place that range?"* ⚠ It cannot be answered from our own code - `options.lua`'s
-- `SeatMap` sets `mapSeat:SetLayout(nil)`, which turns the layout OFF, and has no caller
-- in the addon at all. ⟶ So it is asked of the client, here.
--
-- ★★ TWO ARRANGEMENTS AND A CONTROL. `direct` is what a builder tries first; `wrapped`
-- gives the frame a widget of its own to sit in. The CONTROL is a real AceGUI Label in the
-- same container under the same layout - without it, *"Ace positioned nothing"* and *"the
-- layout never ran"* are the same reading, which is this bench's most-repeated fault.
--
-- ★ AND THE HEIGHT IS THE MEASURE THAT BITES. Even if the child is never positioned, the
-- container's height has to ACCOUNT for it - or a pane sizes itself as though the control
-- is not there, which is `DR_Pane_8`'s reserved space with the sign flipped.
local function buildHostBoard(decl, AceGUI)
    if sheet.hostItems or not AceGUI then return end
    local H = decl.host
    if type(H) ~= "table" then return end
    -- ⚠⚠ NO BOARD, NO ARMS. Parenting to a nil silently defaults to UIParent and the
    -- whole sheet renders loose - which is what happened for two captures. Refusing is the
    -- only honest branch: a measurement drawn somewhere nobody declared is not this
    -- sheet's measurement.
    if not sheet.hostBoard then return end
    sheet.hostItems = {}

    local CW = (H.child and H.child.w) or 120
    local CH = (H.child and H.child.h) or 40
    local SEATW = (H.widths and H.widths[1]) or 204

    -- ⚠ A FRESH SEAT PER ARRANGEMENT. One container reused would carry the first
    -- arrangement's children into the second, and the second would measure both.
    local function seat(y)
        local g = AceGUI:Create("SimpleGroup")
        g:SetLayout("Flow")
        g:SetWidth(SEATW)
        g:SetHeight(110)
        g.frame:SetParent(sheet.hostBoard)
        g.frame:ClearAllPoints()
        g.frame:SetPoint("TOPLEFT", sheet.hostBoard, "TOPLEFT", 0, y)
        g.frame:Show()
        return g
    end

    -- ★ THE CONTROL FIRST, in every seat: a widget Ace made, so the layout is known to
    -- have run before anything is concluded from the raw child not moving.
    local function witness(g)
        local lbl = AceGUI:Create(H.control or "Label")
        lbl:SetText("witness")
        lbl:SetFullWidth(true)
        g:AddChild(lbl)
        return lbl
    end

    -- ⚠ THE BEFORE-POSITION IS TAKEN AT A KNOWN OFFSET, never at 0,0. A child that was
    -- never placed and one placed at the origin read identically from a rect.
    local function rawChild(parent)
        local f = CreateFrame("Frame", nil, parent)
        f:SetWidth(CW); f:SetHeight(CH)
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", parent, "TOPLEFT", 7, -7)
        local t = f:CreateTexture(nil, "BACKGROUND")
        t:SetAllPoints(f); t:SetTexture(0.8, 0.6, 0.1, 0.8)
        f:Show()
        return f
    end

    local function snap(f)
        local _, _, _, x, y = f:GetPoint()
        return { x = x, y = y, w = f:GetWidth(), h = f:GetHeight() }
    end

    -- ---- DIRECT: the raw frame straight into the container's content
    local gA = seat(-18)
    local wA = witness(gA)
    local cA = rawChild(gA.content or gA.frame)
    local beforeA = snap(cA)
    gA:DoLayout()
    sheet.hostItems.direct = {
        before = beforeA, after = snap(cA),
        contentH = gA.frame and gA.frame:GetHeight() or nil,
        witnessY = select(5, wA.frame:GetPoint()),
    }

    -- ---- WRAPPED: a SimpleGroup Ace made, holding the raw frame
    local gB = seat(-138)
    local wB = witness(gB)
    local inner = AceGUI:Create("SimpleGroup")
    inner:SetLayout(nil)
    inner:SetWidth(CW); inner:SetHeight(CH)
    gB:AddChild(inner)
    local cB = rawChild(inner.content or inner.frame)
    local beforeB = snap(cB)
    gB:DoLayout()
    sheet.hostItems.wrapped = {
        before = beforeB, after = snap(cB),
        innerY = select(5, inner.frame:GetPoint()),
        contentH = gB.frame and gB.frame:GetHeight() or nil,
        witnessY = select(5, wB.frame:GetPoint()),
    }

    -- ---- SEATED: the same question through ACECONFIGDIALOG, which is the layer the
    -- unified pane actually uses. An option table cannot `AddChild`, so the only route to a
    -- widget we wrote is `dialogControl` (`AceConfigDialog-3.0.lua:1119`).
    -- ⚠ WRAPPED IN pcall AND RECORDED AS A NOTE ON FAILURE. The Registry and the Dialog are
    -- separate libraries from AceGUI and either may be absent on a client; a sheet arm that
    -- takes the whole run down would cost the other two arms their measurement.
    local Reg = LibStub and LibStub("AceConfigRegistry-3.0", true)
    local Dlg = LibStub and LibStub("AceConfigDialog-3.0", true)
    if not (Reg and Dlg) then
        sheet.hostItems.seatedNote = "AceConfig is not loaded - the seated arm needs the "
            .. "Registry and the Dialog, not just AceGUI"
    else
        local ok, err = pcall(function()
            local seatType = H.seatType or "COASheetSeat"
            local made, seatW = 0, nil
            AceGUI:RegisterWidgetType(seatType, function()
                made = made + 1
                local w = AceGUI:Create("SimpleGroup")
                w.type = seatType
                -- ⚠ NO LAYOUT. Sheet ten measured that Ace does not reach inside a seat
                -- anyway; a layout here would be the mechanism that RESIZES a composite,
                -- which `options.lua`'s header names as the one that breaks a canvas.
                w:SetLayout(nil)
                w:SetWidth(CW); w:SetHeight(CH)
                -- The Dialog calls these on whatever it creates; a seat must tolerate them
                -- rather than error, or it is a widget only in name.
                w.SetLabel = function() end
                w.SetText = function() end
                w.SetDisabled = function() end
                return w
            end, 1)

            local probe = {
                type = "group", name = "seat probe",
                args = {
                    -- ★ `input` because `dialogControl` is read there. The control is not an
                    -- input and never behaves as one - the type is the DOOR, the widget is
                    -- the thing. Declared rather than implied so a reader is not misled.
                    seat = { type = "input", order = 1, name = "seat",
                             dialogControl = seatType,
                             get = function() return "" end, set = function() end },
                    after = { type = "description", order = 2, name = "after the seat" },
                },
            }
            Reg:RegisterOptionsTable("COA_SheetSeatProbe", probe)

            local holder = AceGUI:Create("SimpleGroup")
            holder:SetLayout("Fill")
            holder:SetWidth(SEATW); holder:SetHeight(96)
            holder.frame:SetParent(sheet.hostBoard)
            holder.frame:ClearAllPoints()
            holder.frame:SetPoint("TOPLEFT", sheet.hostBoard, "TOPLEFT", 0, -258)
            holder.frame:Show()
            Dlg:Open("COA_SheetSeatProbe", holder)

            sheet.hostItems.seated = {
                built = made,
                holderH = holder.frame and holder.frame:GetHeight() or nil,
                holder = holder,
            }
        end)
        if not ok then
            sheet.hostItems.seatedNote = "the seated arm errored: " .. tostring(err)
        end
    end

    -- ---- RECYCLE: DR_Pane_2 at the seat. A tab change is a TEARDOWN, and AceGUI POOLS.
    -- ★★★ THE TWO QUESTIONS, and neither is answerable from the source alone:
    --   1. does a RE-ACQUIRED seat carry the last one's raw content? `ReleaseChildren`
    --      releases child WIDGETS, and a raw frame is not one.
    --   2. what LAYOUT does it come back with? `AceGUI:Create` sets "List" after
    --      `OnAcquire`, which would overwrite a `SetLayout(nil)` set in the constructor.
    do
        local ok, err = pcall(function()
            local RT = "COASheetRecycle"
            local ctor = 0
            local acquires = 0
            AceGUI:RegisterWidgetType(RT, function()
                ctor = ctor + 1
                local w = AceGUI:Create("SimpleGroup")
                w.type = RT
                -- ⚠ THE HOOK IS `OnAcquire`, NOT THE CONSTRUCTOR. A pooled widget skips the
                -- constructor entirely, so anything written there holds for instance one
                -- and no other. This counts so the capture can say which ran.
                local baseAcquire = w.OnAcquire
                w.OnAcquire = function(self)
                    acquires = acquires + 1
                    if baseAcquire then baseAcquire(self) end
                end
                w.SetLabel = function() end
                w.SetText = function() end
                w.SetDisabled = function() end
                return w
            end, 1)

            -- FIRST acquisition: fill it with a raw frame, exactly as a hosted composite.
            local a = AceGUI:Create(RT)
            a.frame:SetParent(sheet.hostBoard)
            a.frame:ClearAllPoints()
            a.frame:SetPoint("TOPLEFT", sheet.hostBoard, "TOPLEFT", 0, -380)
            local mark = CreateFrame("Frame", nil, a.content or a.frame)
            mark:SetWidth(20); mark:SetHeight(20)
            mark:SetPoint("TOPLEFT", a.content or a.frame, "TOPLEFT", 2, -2)
            local mt = mark:CreateTexture(nil, "BACKGROUND")
            mt:SetAllPoints(mark); mt:SetTexture(1, 0.2, 0.2, 0.9)
            local firstContent = a.content or a.frame
            local layoutA = a.layout ~= nil

            -- THE TEARDOWN, and then the reconstruction a tab change asks for.
            AceGUI:Release(a)
            local b = AceGUI:Create(RT)

            -- ★★ THE FINDING: is `mark` still parented into the seat we just got back?
            -- Counting CHILDREN would be a weaker question - this asks whether THE SAME
            -- frame is still there, which is what a stale composite actually looks like.
            local sameSeat = (b == a)
            local stillThere = (mark:GetParent() == (b.content or b.frame))

            sheet.hostItems.recycle = {
                ctor = ctor,
                acquires = acquires,
                sameSeat = sameSeat,
                stillThere = stillThere,
                -- ⚠ THE LAYOUT ON THE WAY BACK IN. `AceGUI:Create` sets "List" AFTER
                -- OnAcquire, so a constructor's `SetLayout(nil)` cannot survive a recycle.
                layoutAfter = b.LayoutFunc ~= nil or b.layout ~= nil,
                widget = b,
            }
            b.frame:SetParent(sheet.hostBoard)
            b.frame:ClearAllPoints()
            b.frame:SetPoint("TOPLEFT", sheet.hostBoard, "TOPLEFT", 0, -380)
        end)
        if not ok then
            sheet.hostItems.recycleNote = "the recycle arm errored: " .. tostring(err)
        end
    end

    -- ⚠ GUARDED. The board is built in the sheet's own construction; if that has not run,
    -- this arm must say nothing rather than error on a nil - the same reason every other
    -- board builder returns early rather than assuming its host.
    if sheet.hostBoard then
        local title = sheet.hostBoard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("BOTTOMLEFT", sheet.hostBoard, "TOPLEFT", 0, 2)
        title:SetText("hosted: seat · placement · recycle   -   gold = the raw child")
    end
    return sheet.hostItems
end

local function buildScrollBoard(decl, AceGUI)
    if sheet.scrollItems then return end
    local S = decl.scroll
    if type(S) ~= "table" then return end
    sheet.scrollItems = {}

    local up = S.upstream or {}
    local BARW = up.barWidth or 16
    local host = sheet.scrollBoard
    local PANE, VIEW, CONTENT = 204, 200, 744

    -- ---- a viewport that DOES overflow, so the bar shows
    local view = CreateFrame("ScrollFrame", nil, host)
    view:SetWidth(PANE - (up.widthCost or 20))
    view:SetHeight(VIEW)
    view:SetPoint("TOPLEFT", host, "TOPLEFT", 0, -4)

    local bg = view:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(view); bg:SetTexture(0.12, 0.12, 0.14, 1)

    local child = CreateFrame("Frame", nil, view)
    child:SetWidth(PANE - (up.widthCost or 20))
    child:SetHeight(CONTENT)
    view:SetScrollChild(child)

    -- ⚠ Numbered rows every 40px, so TRAVEL is visible in a screenshot. A blank scroll child
    -- moves and looks identical, which is the same fault as a pane that reports nothing.
    for i = 0, math.floor(CONTENT / 40) - 1 do
        local fs = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", child, "TOPLEFT", 4, -(i * 40) - 2)
        fs:SetText(string.format("row %2d   y = %d", i + 1, i * 40))
    end

    local bar = CreateFrame("Slider", nil, view, "UIPanelScrollBarTemplate")
    bar:SetWidth(BARW)
    bar:SetPoint("TOPLEFT", view, "TOPRIGHT", 4, -16)
    bar:SetPoint("BOTTOMLEFT", view, "BOTTOMRIGHT", 4, 16)
    bar:SetMinMaxValues(0, math.max(0, CONTENT - VIEW))
    bar:SetValueStep(1)
    bar:SetValue(0)
    bar:SetScript("OnValueChanged", function(self, v) view:SetVerticalScroll(v) end)

    -- ★ The wheel is the ADDON's, not the client's (upstream :173-174), which is exactly why
    -- a "wheel step" is a value we settle rather than a constant we measure. 40 = one row.
    view:EnableMouseWheel(true)
    view:SetScript("OnMouseWheel", function(self, d)
        local lo, hi = bar:GetMinMaxValues()
        local v = bar:GetValue() - d * 40
        if v < lo then v = lo elseif v > hi then v = hi end
        bar:SetValue(v)
    end)

    -- ---- the CONTROL: same declared pane width, content that does NOT overflow, no bar
    local ref = CreateFrame("ScrollFrame", nil, host)
    ref:SetWidth(PANE)
    ref:SetHeight(28)
    ref:SetPoint("TOPLEFT", view, "BOTTOMLEFT", 0, -8)
    local rbg = ref:CreateTexture(nil, "BACKGROUND")
    rbg:SetAllPoints(ref); rbg:SetTexture(0.20, 0.16, 0.06, 1)
    local rchild = CreateFrame("Frame", nil, ref)
    rchild:SetWidth(PANE); rchild:SetHeight(20)
    ref:SetScrollChild(rchild)
    local rfs = rchild:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    rfs:SetPoint("LEFT", rchild, "LEFT", 4, 0)
    rfs:SetText("no overflow -> no bar -> full width")

    sheet.scrollItems = {
        view = view, child = child, bar = bar, ref = ref,
        pane = PANE, viewport = VIEW, content = CONTENT,
    }
end


-- ★★★ THE GUTTER PROTOTYPE - sheet nine (`UL-21`) found that usable width flips by 20 at
-- `content >= viewport + 2`, and that ~1 text cell in 7 wraps TALLER when it does. This makes
-- the consequence LOOKABLE-AT rather than a number in a table, which is the sheet's two
-- natures: the measured half and the looked-at half.
--
-- ⚠⚠ AND IT EXISTS BECAUSE THE FIELD DOES NOT ANSWER IT. Checked, and one read was WRONG
-- before it was checked again:
--   AceGUIContainer-ScrollFrame  :102 :114 :117 :154   FLIPS the content width by 20
--   AceGUIContainer-TreeGroup    :497-509 ShowScroll   FLIPS the button inset by 22
--                                :518  `width - treewidth - 20` is the GAP BETWEEN ITS TWO
--                                      PANES, ⚠ NOT a reserved scrollbar gutter - it was
--                                      read as one for a minute, which is `a name is not a
--                                      use` arriving as a NUMBER instead of a name.
-- ⟶ Both AceGUI scrolling containers FLIP. **None reserves.** A citable absence, bounded to
-- what was actually read: three widgets in one library, not "nobody does this".
--
-- ★ SO THE CHOICE IS OURS, and it is his to make because it is a COST, not a correctness bug:
--   A  FLIPS     upstream. Full width while short; loses 20 the moment it overflows, and
--                the narrower content can wrap taller and never settle back.
--   B  RESERVES  the 20 is spent ALWAYS. Width is a constant, wrap never changes, no loop -
--                and 20px of a 204 pane is ~10% given up even when nothing scrolls.
local function buildGutterProto(decl, AceGUI)
    if sheet.protoItems then return end
    local S = decl.scroll
    if type(S) ~= "table" then return end
    local up = S.upstream or {}
    local COST, MARGIN = up.widthCost or 20, up.margin or 2
    local PANE, VIEW, ROW = 204, 120, 20

    local host = sheet.protoBoard
    sheet.protoItems = { rows = 6 }
    local P = sheet.protoItems

    -- ⚠ ONE string, and it is a specimen `check_sheet --scroll` already flags as gaining a
    -- line at 204 -> 184. A demo whose text does NOT re-wrap would prove the opposite point
    -- while looking identical.
    local TEXT = "satisfying this promotes the index to 4"

    local function makeColumn(label, x, reserves)
        local col = CreateFrame("Frame", nil, host)
        col:SetWidth(PANE + 40); col:SetHeight(150)
        col:SetPoint("TOPLEFT", host, "TOPLEFT", x, 0)

        local cap = col:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        cap:SetPoint("TOPLEFT", col, "TOPLEFT", 0, 0)
        cap:SetText(label)

        local view = CreateFrame("ScrollFrame", nil, col)
        view:SetHeight(VIEW)
        view:SetPoint("TOPLEFT", col, "TOPLEFT", 0, -16)
        local bg = view:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(view); bg:SetTexture(0.12, 0.12, 0.14, 1)

        local child = CreateFrame("Frame", nil, view)
        view:SetScrollChild(child)

        local bar = CreateFrame("Slider", nil, view, "UIPanelScrollBarTemplate")
        bar:SetWidth(up.barWidth or 16)
        bar:SetPoint("TOPLEFT", view, "TOPRIGHT", 4, -16)
        bar:SetPoint("BOTTOMLEFT", view, "BOTTOMRIGHT", 4, 16)
        bar:SetScript("OnValueChanged", function(self, v) view:SetVerticalScroll(v) end)

        local wide = col:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        wide:SetPoint("TOPLEFT", view, "BOTTOMLEFT", 0, -4)

        local fs = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", child, "TOPLEFT", 2, -2)
        fs:SetJustifyH("LEFT")
        fs:SetText(TEXT)

        return { col = col, view = view, child = child, bar = bar,
                 wide = wide, fs = fs, reserves = reserves }
    end

    P.a = makeColumn("A  FLIPS  (upstream: -20 only when the bar shows)", 0, false)
    P.b = makeColumn("B  RESERVES  (ours: -20 always, width never moves)", 300, true)

    local function refresh()
        for _, c in ipairs({ P.a, P.b }) do
            local content = P.rows * ROW
            local overflow = content >= VIEW + MARGIN
            -- ★ THE ONE RULE THAT DIFFERS. Everything else in this function is identical.
            local usable = (c.reserves or overflow) and (PANE - COST) or PANE
            c.view:SetWidth(usable)
            c.child:SetWidth(usable)
            c.child:SetHeight(content)
            c.fs:SetWidth(usable - 4)
            if overflow then
                c.bar:Show(); c.bar:SetMinMaxValues(0, content - VIEW); c.bar:SetValue(0)
            else
                c.bar:Hide(); c.view:SetVerticalScroll(0)
            end
            -- ⚠ The TEXT HEIGHT is reported, not just the width: the width is the cause and
            -- the height is the consequence, and only the second one changes the layout.
            c.wide:SetText(string.format("usable %d   content %d   text %d high   %s",
                usable, content, math.floor((c.fs:GetHeight() or 0) + 0.5),
                overflow and "|cffffd100BAR|r" or "no bar"))
        end
    end
    P.refresh = refresh

    local function stepper(text, x, d)
        local b = CreateFrame("Button", nil, host, "UIPanelButtonTemplate")
        b:SetWidth(90); b:SetHeight(22)
        b:SetPoint("TOPLEFT", host, "TOPLEFT", x, -128)
        b:SetText(text)
        b:SetScript("OnClick", function()
            P.rows = math.max(1, math.min(40, P.rows + d))
            refresh()
        end)
        return b
    end
    stepper("REMOVE row", 610, -1)
    stepper("ADD row", 706, 1)

    local hint = host:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", host, "TOPLEFT", 610, -20)
    hint:SetWidth(340); hint:SetJustifyH("LEFT")
    hint:SetText("Cross " .. (VIEW + MARGIN) .. "px of content and watch A's text re-wrap"
        .. " while B's does not. B spends " .. COST .. "px of 204 (~10%) at all times to buy that."
        .. "\n\nUL-21: ~1 text cell in 7 gains a line at 204 -> 184.")

    refresh()
end

local function buildTabBoard(decl, AceGUI)
    if sheet.tabItems or not AceGUI then return end
    sheet.tabItems = {}
    local tdecl = decl.tab
    if type(tdecl) ~= "table" then return end

    -- ★★★ NEUTRAL ON THE BOARD, REAL IN THE CELLS - his ask, 2026-08-24: *"Strip meaning
    -- out of our tabs. Easy to conflate implimentation from example."*
    --
    -- ⚠⚠ AND IT IS A CUT, NOT A DELETION, because the two halves want opposite things:
    --   THE CELLS (45, measured, in the record)  KEEP the real strings. Their WIDTH is the
    --       whole question - `Face · Children · What they are doing` needs two rows at 240
    --       and nothing but that exact string could have told us.
    --   THE BOARD (3 strips, clickable, on screen)  NEUTRAL. It answers *does the page
    --       move*, which no label affects - and a demo wearing the product's names reads as
    --       the product, which is exactly the conflation he names.
    -- ⟶ Measure the real strings; display anonymous ones. The same two-natures split this
    -- file already draws between what is checked and what is looked at.
    local NEUTRAL = {
        { "one", "two", "three" },        -- a three-tab strip, like the unified pane's
        { "one", "two" },                 -- a two-tab strip, like the remote's
        { "one", "two", "three" },        -- the outer of the nest
    }
    local NEUTRAL_INNER = { "a", "b", "c" }
    local want = { { "unified", nil }, { "remote", nil },
                   { tdecl.nest and tdecl.nest.outer or "unified", tdecl.nest } }
    local y = 0
    for wi = 1, #want do
        local setName, nest = want[wi][1], want[wi][2]
        -- ⚠ The board draws NEUTRAL labels; the declared set is used only to decide HOW MANY
        -- tabs this strip has, so the shape still mirrors the product without wearing its name.
        local labels
        for _, s in ipairs(tdecl.specimen or {}) do
            if s.name == setName then labels = s.tabs end
        end
        if labels then
            local n = math.min(#labels, #(NEUTRAL[wi] or {}))
            local neutral = {}
            for i = 1, n do neutral[i] = NEUTRAL[wi][i] end
            labels = neutral
        end
        if labels then
            local ok = pcall(function()
                local box = AceGUI:Create("SimpleGroup")
                box:SetLayout("Fill")
                box:SetWidth(240)
                -- ⚠⚠ A NESTED PAIR NEEDS 94px OF STRIP BEFORE ANY CONTENT - `UL-13` measured
                -- exactly that at 240, and this board built it at 76. The inner TabGroup
                -- had ~2px of content area left, so its border drew half into the parent:
                -- *"a stale contruction element on the tabs. Second row or tabs in curation,
                -- dropping their bottom context box half into the parent"* (Battlewrath).
                -- ★ The sheet had already measured the number its own board then ignored.
                -- ⚠ The MEASUREMENT half was never wrong - it probes at 220 (`probeHeight`)
                -- and its data stands. Only the LOOKED-AT half was built too short.
                box:SetHeight(nest and 140 or 76)
                box.frame:SetParent(sheet.tabBoard)
                box.frame:ClearAllPoints()
                box.frame:SetPoint("TOPLEFT", sheet.tabBoard, "TOPLEFT", 0, -y)
                box.frame:Show()

                -- ★ WA's pattern exactly (`OptionsFrame.lua:1197-1231`): Fill host,
                -- AddChild, SetTitle(""), and a child that holds the page.
                local grp = AceGUI:Create("TabGroup")
                grp:SetLayout("Fill")
                local list = {}
                for i = 1, #labels do
                    list[i] = { value = tostring(i), text = labels[i] }
                end
                grp:SetTabs(list)
                grp:SelectTab("1")
                box:AddChild(grp)
                grp:SetTitle("")

                local page = AceGUI:Create("SimpleGroup")
                page:SetLayout("Fill")
                grp:AddChild(page)

                if nest then
                    local sub = AceGUI:Create("TabGroup")
                    sub:SetLayout("Fill")
                    local sl = {}
                    for i = 1, math.min(#(nest.inner or {}), #NEUTRAL_INNER) do
                        sl[i] = { value = tostring(i), text = NEUTRAL_INNER[i] }
                    end
                    sub:SetTabs(sl)
                    sub:SelectTab("1")
                    page:AddChild(sub)
                    sub:SetTitle("")
                else
                    local lb = AceGUI:Create("Label")
                    lb:SetText("page")
                    page:AddChild(lb)
                    -- ⚠ The label is what MOVES when a tab is clicked. Without something
                    -- that changes, a strip that does nothing looks identical to one that
                    -- works - the failure this whole sheet exists to make visible.
                    grp:SetCallback("OnGroupSelected", function(_, _, v)
                        lb:SetText("page  ->  tab " .. tostring(v))
                    end)
                end
                box:DoLayout()
                sheet.tabItems[#sheet.tabItems + 1] = box
            end)
            if ok then y = y + (nest and 146 or 82) end
        end
    end
end

-- ⚠ Built ONCE and never released. Sheet two's widgets are transient on purpose (each
-- cell asks a different width); these are the opposite - they persist so they can be
-- looked at, and so their rects are resolved by the time anything measures them.
local function buildBoard(decl, AceGUI)
    if sheet.boardItems then return sheet.boardItems end
    sheet.boardItems = {}

    local A = decl.art or {}
    local pw, ph = A.probeWidth or 170, A.probeHeight or 32
    local y, GAP, MIN_ROW = 0, 8, 22

    -- ★★★ A ROW IS AS TALL AS ITS TALLEST CELL - and I ignored a rule this bench already
    -- had. §101 states it; the board used a fixed 38px pitch against controls measured
    -- between 9.9 and 44 tall, so the EditBox (44) overran its row and the Label beneath
    -- it rendered inside the same space. Battlewrath, seeing it: *"Label rides high on
    -- its position, clipping / in the same space as Edit box. Not center line like the
    -- rest."* ⚠ The sheet exists to catch exactly this class, and its own board had it.
    local function rowPitch(...)
        local tallest = MIN_ROW
        for i = 1, select("#", ...) do
            local f = select(i, ...)
            local h = f and f.GetHeight and f:GetHeight() or 0
            if h and h > tallest then tallest = h end
        end
        return tallest + GAP
    end

    local function label(text)
        local fs = sheet.board:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", sheet.board, "TOPLEFT", 0, -y - 2)
        fs:SetWidth(118)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
        return fs
    end

    -- ★★★ THE A:B TEST (Battlewrath, 2026-08-23: *"Insert the A:B test on the sheet."*).
    -- Every template is built TWICE on one row - NAMED on the left, ANONYMOUS on the
    -- right - and both are measured. The difference is the finding.
    --
    -- ⚠⚠ WHY IT IS WORTH A CELL RATHER THAN A NOTE. `InputBoxTemplate`'s `$parentMiddle`
    -- anchors LEFT to `$parentLeft` and RIGHT to `$parentRight` - BY NAME
    -- (`FrameXML/UIPanelTemplates.xml:167-176`). An anonymous instance cannot resolve
    -- `$parent`, both anchors fail, and only the two 8px end caps draw. **Nothing errors.**
    -- COA_Landmarks found it live and wrote it down - *"(Found live: No mid texture.)"*,
    -- `editor.lua:33` - and the dropdown's version of the same fault is in the geom
    -- runsheet as "a forced global". One cause, two symptoms, three places, indexed nowhere.
    --
    -- ★ So the sheet PROVES the list instead of carrying folklore: which templates on this
    -- fork actually need a name, re-derived every run.
    local function buildOne(tname, ftype, named, x)
        local f
        local fname = named and ("COA_UISheet_" .. tname) or nil
        -- ⚠⚠ THE TYPE COMES FROM THE DECLARATION, WHICH SOURCED IT FROM THE XML. Creating
        -- a Button template as a "Frame" produces a frame that draws NOTHING: a Button's
        -- art is <NormalTexture>/<PushedTexture>/<HighlightTexture>, elements a Frame does
        -- not have. v2 did exactly that and three templates came back blank in BOTH
        -- columns - and `InputBoxTemplate` hid it by rendering anyway, because its
        -- textures are plain <Layers> regions that any frame type carries.
        local made = pcall(function()
            f = CreateFrame(ftype or "Frame", fname, sheet.board, tname)
        end)
        if not (made and f) then return nil end
        -- ★★ AN EDIT BOX ON A SWATCH BOARD MUST NOT HOLD THE KEYBOARD. Battlewrath,
        -- 2026-08-24: *"One of the text boxes is pervasive, controlling / locking expected
        -- input. (Not new, just not reported before.)"* ⟶ `InputBoxTemplate` autofocuses, so
        -- a specimen built to be LOOKED at silently took every keystroke in the game.
        -- ⚠ It is a swatch, not a field: it should never take focus at all, and escape must
        -- always release it.
        if f.SetAutoFocus then
            pcall(function()
                f:SetAutoFocus(false)
                f:ClearFocus()
                f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
            end)
        end
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", sheet.board, "TOPLEFT", x, -y)
        if tname == "UIDropDownMenuTemplate" and UIDropDownMenu_SetWidth then
            -- ★ INITIALISED so the board can be POKED - a swatch board exists to be
            -- clicked, and opening the menu is how you see whether the menu art works.
            -- ⚠ Only the NAMED one: ToggleDropDownMenu builds an anchor name out of
            -- GetName(), so an anonymous dropdown errors on click. Hence EnableMouse(false)
            -- on every anonymous specimen below - it is there to be LOOKED at, and a
            -- specimen that errors when someone pokes it is a trap on a board built for poking.
            if named and UIDropDownMenu_Initialize and UIDropDownMenu_AddButton then
                pcall(function()
                    UIDropDownMenu_Initialize(f, function()
                        for i = 1, 2 do
                            local info = UIDropDownMenu_CreateInfo and
                                UIDropDownMenu_CreateInfo() or {}
                            info.text = "specimen " .. i
                            info.notCheckable = true
                            UIDropDownMenu_AddButton(info)
                        end
                    end)
                end)
            end
            pcall(function() UIDropDownMenu_SetWidth(f, pw) end)
            if named and UIDropDownMenu_SetText then
                pcall(function() UIDropDownMenu_SetText(f, "specimen 1") end)
            end
        else
            -- ★ Only size what declares no size of its own. Three of eight templates
            -- declare none (geom Run 1); forcing a size onto one that DOES would
            -- overwrite the very fact we came to read.
            if (f:GetWidth() or 0) <= 0 then f:SetWidth(pw) end
            if (f:GetHeight() or 0) <= 0 then f:SetHeight(ph) end
        end
        if not named and f.EnableMouse then pcall(function() f:EnableMouse(false) end) end
        f:Show()
        return f
    end

    for _, entry in ipairs(A.templates or {}) do
        -- ⚠ v2 listed templates as bare strings; v3 lists { name, type }. Both are read so
        -- an older declaration still builds rather than erroring on a nil index.
        local tname = type(entry) == "table" and entry.name or entry
        local ftype = type(entry) == "table" and entry.type or "Frame"
        local a = buildOne(tname, ftype, true, 125)
        local b = buildOne(tname, ftype, false, 320)
        if a or b then
            label(tname)
            if a then
                sheet.boardItems[#sheet.boardItems + 1] =
                    { subject = tname, frame = a, source = "template", variant = "named" }
            end
            if b then
                sheet.boardItems[#sheet.boardItems + 1] =
                    { subject = tname, frame = b, source = "template", variant = "anon" }
            end
            y = y + rowPitch(a, b)
        end
    end

    if AceGUI then
        for _, wname in ipairs(A.widgets or {}) do
            local c
            local made = pcall(function() c = AceGUI:Create(wname) end)
            if made and c and c.frame then
                pcall(function()
                    if c.SetLabel then c:SetLabel(wname) end
                    if c.SetText then c:SetText(wname) end
                    c:SetWidth(pw)
                    c.frame:SetParent(sheet.board)
                    c.frame:ClearAllPoints()
                    c.frame:SetPoint("TOPLEFT", sheet.board, "TOPLEFT", 125, -y)
                    c.frame:Show()
                end)
                label(wname)
                sheet.boardItems[#sheet.boardItems + 1] =
                    { subject = wname, frame = c.frame, source = "acegui", widget = c }
                y = y + rowPitch(c.frame)
            end
        end
    end

    return sheet.boardItems
end

-- One visible row per font object: the face rendered in itself. Eleven rows is a
-- swatch board a person can read; 286 strings on screen is a wall.
local function swatchRow(host, index, fontName)
    local fs = sheet.rows[index]
    if not fs then
        fs = host:CreateFontString(nil, "OVERLAY", fontName)
        fs:SetPoint("TOPLEFT", host, "TOPLEFT", 0, -((index - 1) * 24))
        sheet.rows[index] = fs
    end
    fs:SetText(fontName .. "  -  The quick brown fox")
    return fs
end

-- ★★★ FOUR NAMES, ONE RUN - his: *"we can bake tab opening into the command. /coadump r
-- sheet1 or sheet2 or sheet3"*. The dispatcher looks tasks up by exact name, so each page is
-- its own registered task closing over its number; `sheet` stays as page 1 so nothing that
-- already types it breaks.
-- ⚠ The page is DECLARED BY THE COMMAND rather than read off whatever was last clicked, which
-- is what lets a run be repeated exactly and the record agree with the image by construction.
local function runSheet(pageArg, args)
        if type(COA_UI_SHEET) ~= "table" or type(COA_UI_SHEET.text) ~= "table" then
            D.Print("sheet: COA_UI_SHEET is not loaded - sheet_decl.lua missing from the .toc. "
                .. "Nothing measured; a standard the measuring tool invented is not a standard.")
            return
        end

        local decl = COA_UI_SHEET
        local payload = D.Begin("sheet", args)
        payload.declVersion = decl.version

        buildSheet()
        -- ★★★ ONE PAGE PER RUN, DECLARED BY THE COMMAND (his ruling, 2026-08-24).
        -- ⚠ A block whose page was not shown records **NOT MEASURED**, never 0 - a zero that
        -- means "nobody looked" is indistinguishable in a file from a zero that was measured,
        -- and `check_sheet` unions runs, so a sheet1 run supplies text and a sheet2 run
        -- supplies the devices. The corpus is the union; no single run is expected to be whole.
        local PAGE = tonumber(pageArg) or 1
        sheet.SetPage(PAGE)
        payload.page = PAGE
        payload.pageName = ({ "specimens", "devices", "prototypes" })[PAGE]
        sheet:Show()

        -- =============================================================
        -- ★★ THE CONFIGURATION, READ OFF THE CLIENT. The sweep varies this and
        -- nothing else; the run must never be TOLD what it is.
        -- ★★★ `screenWidth`/`screenHeight` are here because they are the numbers
        -- most likely to settle the open question: the returned unit is
        -- 1/0.6275280733 = 1.5936 device px, while uiScale x screenH/768 is
        -- 2.2534, so the obvious mapping is wrong and the client's own idea of
        -- its UI extent is the missing term.
        -- =============================================================
        -- ★★★ THE APPARATUS GATE FOR SHEET TWO. A control measurement is a measurement
        -- of whichever AceGUI copy LibStub resolved, and that is NOT ours to decide: we
        -- ship AceGUI 33 / AceConfigDialog 49, this client carries 41 / 54 inside other
        -- addons, and LibStub keeps the highest minor LOADED - so the enabled addon set
        -- picks the code. ⚠ Without these numbers a control row is not reproducible, and
        -- a run that cannot be reproduced is an anecdote.
        local libs = {}
        if LibStub then
            for _, name in ipairs({ "AceGUI-3.0", "AceConfig-3.0", "AceConfigDialog-3.0",
                                    "AceConfigRegistry-3.0" }) do
                local lib, minor = LibStub(name, true)
                -- ⚠⚠ tostring() IS THE WHOLE FIX, and it cost a run. On this fork every
                -- Ace minor is INFINITY, and SavedVariables cannot serialise a non-finite
                -- number: the mailbox wrote `["AceGUI-3.0"] = nil --[[ inf ]]`, so all
                -- four gate values arrived in the repo as null. The client KNEW - the
                -- summary line printed `AceGUI 1.#INF` because it was built before the
                -- flush - and the fact was destroyed on the way out.
                -- ★ The general rule for anything crossing the mailbox: a number that
                -- could be inf or nan must be a STRING before it is stored, or a nil and
                -- an infinity become indistinguishable in the file.
                libs[name] = lib and tostring(minor or "loaded, minor unknown")
                    or "not loaded"
            end
        else
            libs.LibStub = "not present"
        end

        payload.config = {
            libs = libs,
            uiScaleCVar = GetCVar and GetCVar("uiScale") or nil,
            resolution = GetCVar and GetCVar("gxResolution") or nil,
            useUiScale = GetCVar and GetCVar("useUiScale") or nil,
            uiParentScale = UIParent:GetScale(),
            uiParentEffectiveScale = UIParent:GetEffectiveScale(),
            hostEffectiveScale = sheet.host:GetEffectiveScale(),
            screenWidth = GetScreenWidth and GetScreenWidth() or nil,
            screenHeight = GetScreenHeight and GetScreenHeight() or nil,
            uiParentWidth = UIParent:GetWidth(),
            uiParentHeight = UIParent:GetHeight(),
        }
        -- ★ Kept at the old key too, so `check_sheet.py` reads a sheet record and a
        -- geom record through one path rather than growing a second reader.
        payload.scale = payload.config.uiParentEffectiveScale
        payload.resolution = payload.config.resolution

        -- =============================================================
        -- ★★★ THE CONTROL, FIRST AND ALWAYS - task_geom's rule, kept because it
        -- earned itself: a zero and a measurement that never happened look
        -- identical in a file.
        -- =============================================================
        local probe = sheet.host:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        probe:SetText("MMMMMMMMMM")
        local shownW = probe:GetStringWidth()
        payload.control = { shownWidth = shownW, shown = sheet:IsShown() and true or false }
        probe:SetText("")

        if not shownW or shownW <= 0 then
            payload.apparatus = "dead"
            D.Commit("sheet: APPARATUS DEAD - a known string measured " .. tostring(shownW)
                .. ". Nothing else was recorded.")
            return
        end
        payload.apparatus = "live"

        -- =============================================================
        -- KIND `text` - every declared font object x every declared string.
        -- Both string roles are measured; the fit/hold-out split is the
        -- READER's business, not the instrument's.
        -- =============================================================
        payload.cells = {}
        payload.fonts = {}
        payload.fontsMissing = {}

        -- ⚠ Emptied rather than looped-and-skipped, so the record carries NO cells at all
        -- for a page that was not shown - a partial list would read as a partial measurement.
        local fonts = (PAGE == 1) and (decl.text.fonts or {}) or {}
        if PAGE ~= 1 then
            payload.textSkipped = string.format("page %d was not the page of interest - NOT MEASURED. /coadump r sheet%d", 1, 1)
        end
        local measured, missing = 0, 0

        for i = 1, #fonts do
            local fontName = fonts[i]
            local row = { strings = {} }
            local ok = pcall(function()
                local fs = swatchRow(sheet.host, i, fontName)
                local f, size, flags = fs:GetFont()
                row.file, row.size, row.flags = f, size, flags
                -- ⚠ The geom runsheet left this owed: GetHeight() answered 0 on every
                -- font there. Read after a SetText on a SHOWN frame, which is what
                -- this run is.
                row.height = fs.GetStringHeight and fs:GetStringHeight() or nil
                row.lineHeight = fs:GetHeight()

                for _, roleName in ipairs({ "calibration", "specimen" }) do
                    local list = decl.text[roleName] or {}
                    for j = 1, #list do
                        local s = list[j]
                        fs:SetText(s)
                        local w = fs:GetStringWidth()
                        row.strings[s == "" and "(empty)" or s] = w
                        payload.cells[#payload.cells + 1] = {
                            kind = "text", font = fontName, role = roleName,
                            text = s, width = w,
                        }
                        measured = measured + 1
                    end
                end
                -- leave the row legible rather than holding the last specimen
                swatchRow(sheet.host, i, fontName)
            end)
            if not ok then
                row.error = "could not create or measure"
                payload.fontsMissing[#payload.fontsMissing + 1] = fontName
                missing = missing + 1
            end
            payload.fonts[fontName] = row
        end

        -- =============================================================
        -- KIND `wrap` (sheet five) - a string's HEIGHT once it has a width.
        --
        -- ★★★ AL-45's offline half needs one thing this bench has never measured:
        -- WHERE THE CLIENT BREAKS A LINE. UL-1 settled how far a string reaches;
        -- nothing settled where it stops. So every number here is read from the
        -- client and none is derived - the point is to have something to derive
        -- FROM.
        --
        -- ⚠ Measured on `sheet.host`, which is SHOWN, and inside the deferred pass
        -- like everything else here: a FontString created and read in one tick has
        -- no resolved extent, which cost this task three runs to learn once.
        -- =============================================================
        payload.wrap = { cells = {}, methods = {}, fonts = {}, note = nil }

        local wdecl = decl.wrap
        if PAGE ~= 1 then
            payload.wrap.note = string.format("page %d was not the page of interest - NOT MEASURED. /coadump r sheet%d", 1, 1)
        elseif type(wdecl) ~= "table" then
            payload.wrap.note = "no wrap declaration in COA_UI_SHEET (v" ..
                tostring(decl.version) .. ") - sheet five did not run"
        else
            local wfonts, widths = wdecl.fonts or {}, wdecl.widths or {}
            local wrapProbe = sheet.host:CreateFontString(nil, "OVERLAY",
                wfonts[1] or "GameFontNormal")
            wrapProbe:SetPoint("TOPLEFT", sheet.host, "TOPLEFT", 0, 0)
            wrapProbe:SetJustifyH("LEFT")

            -- ⚠⚠ NAMED, NEVER CALLED BLIND. `SetWordWrap` / `GetNumLines` are later
            -- client API; `SetNonSpaceWrap` is EXPECTED on 3.3.5 and expectation is
            -- not evidence on this fork. Record presence; call none of them.
            -- ★ An absent method is a FACT about the client, not a gap in the run.
            for _, m in ipairs(wdecl.probeMethods or {}) do
                payload.wrap.methods[m] = (type(wrapProbe[m]) == "function")
            end

            local haveH = payload.wrap.methods["GetStringHeight"]
            if not haveH then
                -- The one method the whole kind rests on. Say so BY NAME rather than
                -- emitting a table of nils that reads like zero heights.
                payload.wrap.note =
                    "GetStringHeight is ABSENT on this client - wrapped height cannot " ..
                    "be measured, and AL-45's in-client half does not hold here"
            else
                local wrapped = 0
                for fi = 1, #wfonts do
                    local fontName = wfonts[fi]
                    local frow = {}
                    local okFont = pcall(function()
                        wrapProbe:SetFontObject(_G[fontName])

                        -- ★ The single-line height, MEASURED rather than taken from the
                        -- font size. Everything downstream divides by this number, so
                        -- deriving it would put a guess under every line count.
                        wrapProbe:SetWidth(600)
                        wrapProbe:SetText("M")
                        frow.oneLine = wrapProbe:GetStringHeight()
                        local f, size, flags = wrapProbe:GetFont()
                        frow.file, frow.size, frow.flags = f, size, flags

                        for _, roleName in ipairs({ "calibration", "specimen" }) do
                            local list = wdecl[roleName] or {}
                            for si = 1, #list do
                                local s = list[si]
                                for wi = 1, #widths do
                                    local w = widths[wi]
                                    wrapProbe:SetWidth(w)
                                    wrapProbe:SetText(s)
                                    payload.wrap.cells[#payload.wrap.cells + 1] = {
                                        kind = "wrap", font = fontName, role = roleName,
                                        text = s, width = w,
                                        height = wrapProbe:GetStringHeight(),
                                        -- ⚠ WHAT THIS ANSWERS AFTER SetWidth IS THE
                                        -- QUESTION, not a known. Stored, not
                                        -- interpreted.
                                        stringWidth = wrapProbe:GetStringWidth(),
                                        -- The FontString's own height, which the geom
                                        -- runsheet saw answer 0. Kept so a zero here is
                                        -- distinguishable from a zero there.
                                        frameHeight = wrapProbe:GetHeight(),
                                    }
                                    wrapped = wrapped + 1
                                end
                            end
                        end
                    end)
                    if not okFont then
                        frow.error = "could not set or measure this font object"
                    end
                    payload.wrap.fonts[fontName] = frow
                end
                payload.wrap.measured = wrapped
            end

            wrapProbe:SetText("")
            wrapProbe:Hide()
        end

        -- =============================================================
        -- KIND `tab` (sheet six) - does a strip WRAP, and where does content start?
        --
        -- ★★★ THIS IS THE TEXT METRIC'S CONSUMER TEST. `AceGUIContainer-TabGroup.lua`
        -- sizes every tab from its TEXT (`PanelTemplates_TabResize`, :42) and then
        -- WRAPS the strip into rows when they do not fit (:207). ⟶ The row count is a
        -- function of the font metric, so a model 5% out on a string can be a whole
        -- ROW out on a strip - and a row is 20-odd px off the top of every control
        -- below it, on a pane 240 wide.
        --
        -- ⚠ ROWS ARE COUNTED FROM GEOMETRY, not from an internal. Distinct rounded
        -- `GetTop()` values across the tab frames is what a person would count by
        -- looking, and it survives AceGUI changing how it stores them.
        -- ⚠ `grp.tabs` IS an internal and is used only to REACH the frames. Named here
        -- rather than hidden: if a future AceGUI renames it, this kind reports
        -- "unreachable" instead of quietly measuring nothing.
        -- =============================================================
        payload.tab = { cells = {}, note = nil }
        local tabSkip = (PAGE ~= 2) and string.format("page %d was not the page of interest - NOT MEASURED. /coadump r sheet%d", 2, 2) or nil

        local tdecl = decl.tab
        -- ⚠ RESOLVED HERE, not borrowed. Sheet two declares its own `AceGUI` local BELOW
        -- this block; referencing that name from here reads the GLOBAL, which is nil, and
        -- every run would have reported "AceGUI not resolvable" while AceGUI was present.
        -- ★ Caught by parsing rather than by a capture, which is the cheap end.
        local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
        if tabSkip then
            payload.tab.note = tabSkip
        elseif type(tdecl) ~= "table" then
            payload.tab.note = "no tab declaration in COA_UI_SHEET (v"
                .. tostring(decl.version) .. ") - sheet six did not run"
        elseif not AceGUI then
            payload.tab.note = "AceGUI not resolvable - sheet six cannot run"
        else
            local widths = tdecl.widths or {}
            local made2 = {}

            -- ★★★ WA'S PATTERN, AND THE FIRST RUN DID NOT USE IT (`WeakAurasOptions/
            -- OptionsFrames/OptionsFrame.lua:1197-1231`). Battlewrath, seeing the result:
            -- *"No tabs seen. Maybe check out how WA implements it?"*
            --
            --     container:SetLayout("Fill")        -- a Fill HOST
            --     tabsWidget = AceGUI:Create("TabGroup")
            --     tabsWidget:SetTabs(tabs); tabsWidget:SelectTab(...)
            --     tabsWidget:SetLayout("Fill")
            --     container:AddChild(tabsWidget)     -- ★ AddChild, NEVER SetParent
            --     tabsWidget:AddChild(group)         -- one child holds the page
            --     tabsWidget:SetTitle("")            -- ★ it draws a title unless blanked
            --
            -- ⚠⚠ The first cut did `grp.frame:SetParent(host)` + `SetPoint`, which reaches
            -- PAST AceGUI's own layout: a container positions its children, and a widget
            -- whose frame was parented by hand is not a child of anything. Nothing was
            -- laid out and nothing was seen. ★ Same class as `a name is not a use` -
            -- the call existed, the PATH was wrong.
            local function measureStrip(host, w, labels)
                local out = { width = w, asked = w, n = #labels, labels = labels }
                local ok, err = pcall(function()
                    local box = AceGUI:Create("SimpleGroup")
                    made2[#made2 + 1] = box
                    box:SetLayout("Fill")
                    box:SetWidth(w)
                    box:SetHeight(tdecl.probeHeight or 220)
                    box.frame:SetParent(host)
                    box.frame:ClearAllPoints()
                    box.frame:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
                    box.frame:Show()

                    local grp = AceGUI:Create("TabGroup")
                    grp:SetLayout("Fill")
                    local list = {}
                    for i = 1, #labels do
                        list[i] = { value = tostring(i), text = labels[i] }
                    end
                    grp:SetTabs(list)
                    grp:SelectTab("1")
                    box:AddChild(grp)
                    grp:SetTitle("")
                    box:DoLayout()

                    if type(grp.tabs) ~= "table" then
                        out.error = "grp.tabs is not a table - the strip is unreachable"
                        return
                    end
                    local tops, rows, tabw = {}, 0, {}
                    for i = 1, #grp.tabs do
                        local tb = grp.tabs[i]
                        if tb and tb:IsShown() then
                            local top = math.floor((tb:GetTop() or 0) + 0.5)
                            if not tops[top] then tops[top] = true; rows = rows + 1 end
                            tabw[#tabw + 1] = tb:GetWidth()
                        end
                    end
                    out.rows = rows
                    out.tabWidths = tabw
                    out.shown = #tabw
                    -- ★ THE NUMBER THE PANE ACTUALLY CARES ABOUT: how much vertical room
                    -- the strip took before any content could start.
                    if grp.content and grp.frame then
                        out.stripCost = (grp.frame:GetTop() or 0) - (grp.content:GetTop() or 0)
                        out.contentW = grp.content:GetWidth()
                    end
                    out.groupW = grp.frame:GetWidth()
                end)
                if not ok then out.error = tostring(err):sub(1, 120) end
                return out
            end

            for _, role in ipairs({ "calibration", "specimen" }) do
                local sets = tdecl[role] or {}
                for si = 1, #sets do
                    local set = sets[si]
                    for wi = 1, #widths do
                        local c = measureStrip(sheet.host, widths[wi], set.tabs or {})
                        c.kind, c.role, c.set = "tab", role, set.name
                        payload.tab.cells[#payload.tab.cells + 1] = c
                    end
                end
            end

            -- ★★ SUB-TABS - his second half. A TabGroup inside a TabGroup's content:
            -- *"one to move the page, one to move sub-page content."* Measured for
            -- whether the inner strip renders at all, its own row count, and what
            -- vertical room is left underneath BOTH strips.
            local nest = tdecl.nest
            if type(nest) == "table" then
                payload.tab.nest = {}
                for wi = 1, #widths do
                    local rec = { asked = widths[wi], outer = nest.outer,
                                  inner = nest.inner }
                    local ok, err = pcall(function()
                        local outer = AceGUI:Create("TabGroup")
                        outer:SetLayout("Fill")


                        local ol = {}
                        for _, s in ipairs(tdecl.specimen or {}) do
                            if s.name == nest.outer then
                                for i = 1, #s.tabs do
                                    ol[i] = { value = tostring(i), text = s.tabs[i] }
                                end
                            end
                        end
                        outer:SetTabs(ol)
                        outer:SelectTab("1")
                        local obox = AceGUI:Create("SimpleGroup")
                        made2[#made2 + 1] = obox
                        obox:SetLayout("Fill")
                        obox:SetWidth(widths[wi])
                        obox:SetHeight(tdecl.probeHeight or 220)
                        obox.frame:SetParent(sheet.host)
                        obox.frame:ClearAllPoints()
                        obox.frame:SetPoint("TOPLEFT", sheet.host, "TOPLEFT", 0, 0)
                        obox.frame:Show()
                        obox:AddChild(outer)
                        outer:SetTitle("")
                        obox:DoLayout()




                        local inner = AceGUI:Create("TabGroup")
                        inner:SetLayout("Fill")
                        local il = {}
                        for i = 1, #(nest.inner or {}) do
                            il[i] = { value = tostring(i), text = nest.inner[i] }
                        end
                        inner:SetTabs(il)
                        inner:SelectTab("1")
                        -- ⚠ AddChild, not SetParent: the container's own path is what a
                        -- pane would use, and reaching past it would prove something
                        -- only this task can reach.
                        outer:AddChild(inner)
                        inner:SetTitle("")
                        outer:DoLayout()

                        local function rowsOf(g)
                            if type(g.tabs) ~= "table" then return nil end
                            local tops, n = {}, 0
                            for i = 1, #g.tabs do
                                local tb = g.tabs[i]
                                if tb and tb:IsShown() then
                                    local top = math.floor((tb:GetTop() or 0) + 0.5)
                                    if not tops[top] then tops[top] = true; n = n + 1 end
                                end
                            end
                            return n
                        end
                        rec.outerRows = rowsOf(outer)
                        rec.innerRows = rowsOf(inner)
                        rec.innerRendered = inner.frame and inner.frame:IsShown() or false
                        rec.innerW = inner.frame and inner.frame:GetWidth()
                        if outer.content and inner.content then
                            rec.totalStripCost = (outer.frame:GetTop() or 0)
                                - (inner.content:GetTop() or 0)
                            rec.contentLeft = (inner.content:GetHeight() or 0)
                        end
                    end)
                    if not ok then rec.error = tostring(err):sub(1, 120) end
                    payload.tab.nest[#payload.tab.nest + 1] = rec
                end
            end

            -- ⚠⚠ RELEASE OUTSIDE THE pcall AND AFTER EVERYTHING IS READ. §? cost a run:
            -- releasing a child while it is still parented threw `anchor to itself` from
            -- AceGUI-3.0.lua:767 and took the whole task out.
            -- ⚠⚠ TOP-LEVEL CONTAINERS ONLY, AND NILLED AS THEY GO. The first cut collected
            -- BOTH the outer TabGroup and the SimpleGroup that owned it, so releasing the
            -- box released the group and the loop then released it again -
            -- `AceGUI-3.0.lua:154 Attempt to Release Widget that is already released`.
            -- ★ A container releases its children; anything a container owns must never be
            -- collected beside it.
            -- ⚠ WHAT THIS DOES NOT ESTABLISH: that this produced the popup Battlewrath saw.
            -- `:154` raises with `error(msg, 2)`, which `pcall` DOES catch, so a path outside
            -- a pcall may remain. The double-collect was provably wrong and is gone; the
            -- attribution is not claimed.
            for i = 1, #made2 do
                local w = made2[i]
                made2[i] = nil
                if w then pcall(function() w:Release() end) end
            end
            payload.tab.measured = #payload.tab.cells
        end

        -- =============================================================
        -- KIND `collapse` (sheet seven) - what a section WEIGHS open and shut.
        --
        -- ★★★ THE PANE'S OWN QUESTION. F·29..F·30 measured the object pane over half
        -- empty; UL-13 measured two tab strips at 94 of 220. Collapse is the only lever
        -- left that does not remove a control, and the number that decides it is what a
        -- SHUT section weighs.
        --
        -- ⚠ WA's mechanism is an option table with `hidden = collapsedFunc`
        -- (`CommonOptions.lua:293`), which we do not have. This measures the ACEGUI form -
        -- a Button header and children added or not - and the declaration records WA's as
        -- the cited original. The SHAPE is borrowed; the mechanism is not the same.
        -- =============================================================
        payload.collapse = { cells = {}, note = nil }

        local cdecl = decl.collapse
        local AceGUI2 = LibStub and LibStub("AceGUI-3.0", true)
        if PAGE ~= 2 then
            payload.collapse.note = string.format("page %d was not the page of interest - NOT MEASURED. /coadump r sheet%d", 2, 2)
        elseif type(cdecl) ~= "table" then
            payload.collapse.note = "no collapse declaration in COA_UI_SHEET (v"
                .. tostring(decl.version) .. ") - sheet seven did not run"
        elseif not AceGUI2 then
            payload.collapse.note = "AceGUI not resolvable - sheet seven cannot run"
        else
            local made3 = {}
            local secs = cdecl.sections or {}

            -- ★ Is a given section OPEN in this state? The three states are the whole
            -- point: `shut` is the floor, `open` is the ceiling, and `one-open` is what a
            -- person actually looks at.
            local function isOpen(state, i)
                if state == "open" then return true end
                if state == "shut" then return false end
                return i == 1                      -- one-open
            end

            local function measureState(w, state)
                local out = { width = w, state = state, sections = {} }
                local ok, err = pcall(function()
                    local box = AceGUI2:Create("SimpleGroup")
                    made3[#made3 + 1] = box
                    box:SetLayout("List")
                    box:SetWidth(w)
                    box:SetHeight(600)
                    box.frame:SetParent(sheet.host)
                    box.frame:ClearAllPoints()
                    box.frame:SetPoint("TOPLEFT", sheet.host, "TOPLEFT", 0, 0)
                    box.frame:Show()

                    local first, last = nil, nil
                    for i = 1, #secs do
                        local s = secs[i]
                        local hdr = AceGUI2:Create("Button")
                        -- ⚠ WA's header is `type = "execute"` - a BUTTON - and its text
                        -- carries the STATE (`1. Desaturate: OFF`). A header that only
                        -- says its name turns collapse into hiding, so the summary is
                        -- what is drawn.
                        hdr:SetText((isOpen(state, i) and "-  " or "+  ") .. (s.summary or s.name))
                        hdr:SetFullWidth(true)
                        box:AddChild(hdr)
                        first = first or hdr
                        last = hdr

                        local rec = { name = s.name, open = isOpen(state, i),
                                      fields = s.fields or 0 }
                        rec.headerH = nil
                        if isOpen(state, i) then
                            for _ = 1, (s.fields or 0) do
                                local f = AceGUI2:Create(cdecl.fieldWidget or "EditBox")
                                f:SetFullWidth(true)
                                box:AddChild(f)
                                last = f
                            end
                        end
                        out.sections[#out.sections + 1] = rec
                        rec._hdr = hdr
                    end

                    box:DoLayout()

                    -- ⚠ MEASURED FROM GEOMETRY, not from a container's own height field.
                    -- A SimpleGroup keeps the height it was ASKED for; what the pane needs
                    -- is how far the stack actually reached.
                    for i = 1, #out.sections do
                        local rec = out.sections[i]
                        local h = rec._hdr and rec._hdr.frame
                        rec.headerH = h and h:GetHeight() or nil
                        rec.headerTop = h and h:GetTop() or nil
                        rec._hdr = nil
                    end
                    if first and last then
                        out.stackH = (first.frame:GetTop() or 0) - (last.frame:GetBottom() or 0)
                    end
                    out.contentW = box.content and box.content:GetWidth() or nil
                end)
                if not ok then out.error = tostring(err):sub(1, 120) end
                return out
            end

            for _, w in ipairs(cdecl.widths or {}) do
                for _, state in ipairs(cdecl.states or {}) do
                    payload.collapse.cells[#payload.collapse.cells + 1] = measureState(w, state)
                end
            end

            -- Top-level containers only, nilled as they go (§589's rule).
            for i = 1, #made3 do
                local wgt = made3[i]
                made3[i] = nil
                if wgt then pcall(function() wgt:Release() end) end
            end
            payload.collapse.measured = #payload.collapse.cells
        end

        -- =============================================================
        -- KIND `control` (sheet two) - what an AceGUI widget BECOMES when asked
        -- for a width. ⚠ We measure the LIVE AceGUI, never a copy we loaded
        -- ourselves: the whole point is what the user's addon set resolved to.
        -- =============================================================
        local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
        payload.controls = {}
        payload.controlsMissing = {}
        local controlCount = 0

        if PAGE ~= 1 then
            payload.controlSkipped = string.format("page %d was not the page of interest - NOT MEASURED. /coadump r sheet%d", 1, 1)
        elseif not decl.control then
            payload.controlSkipped = "the declaration carries no `control` section"
        elseif not AceGUI then
            -- ⚠ LOUD, not silent. DevDump embeds no Ace; it borrows whatever is
            -- loaded. If nothing is, that is a fact about the run, not a zero.
            payload.controlSkipped =
                "AceGUI-3.0 is not loaded - COA_DevDump embeds none and borrows the "
                .. "client's. Enable an addon that ships Ace3 (COA_DungeonRun does) and "
                .. "run again. Nothing was measured; a control row without a library is "
                .. "not a zero, it is an absence."
        else
            local C = decl.control
            local mult = C.widthMultiplier or 170
            local hostW = C.hostWidth or 400

            -- The container every measured widget is laid out inside, so `full`
            -- resolves against a KNOWN width rather than the screen.
            local group = AceGUI:Create("SimpleGroup")
            if group then
                group:SetLayout("Flow")
                group:SetWidth(hostW)
                group.frame:SetParent(sheet.host)
                group.frame:ClearAllPoints()
                group.frame:SetPoint("TOPLEFT", sheet.host, "TOPLEFT", 0, -280)
                group.frame:Show()
            end

            for _, wname in ipairs(C.widgets or {}) do
                local probe = AceGUI:Create(wname)
                if not probe then
                    payload.controlsMissing[#payload.controlsMissing + 1] = wname
                else
                    probe:Release()
                    for _, w in ipairs(C.widths or {}) do
                        local row = { widget = wname, how = w.how, asked = w.value }
                        local ok = pcall(function()
                            local c = AceGUI:Create(wname)
                            if c.SetLabel then c:SetLabel(wname) end
                            if c.SetText then c:SetText(wname) end
                            if group then group:AddChild(c) end

                            -- ★ AceConfigDialog's own branch, replicated - see
                            -- AceConfigDialog-3.0.lua:1218-1225. The `number` rows fall
                            -- through to the bare multiplier, which is the point.
                            if w.how == "absent" then
                                row.applied = "nothing"
                            elseif w.value == "full" then
                                c.width = "fill"; row.applied = "width=fill"
                            elseif w.value == "double" then
                                c:SetWidth(mult * 2); row.applied = mult * 2
                            elseif w.value == "half" then
                                c:SetWidth(mult / 2); row.applied = mult / 2
                            else
                                c:SetWidth(mult); row.applied = mult
                            end

                            if group then group:DoLayout() end
                            row.width = c.frame and c.frame:GetWidth() or nil
                            row.height = c.frame and c.frame:GetHeight() or nil
                            row.widthProp = c.width
                            controlCount = controlCount + 1
                        end)
                        -- ⚠⚠ RELEASE THROUGH THE CONTAINER, ALWAYS, AND NEVER THE CHILD
                        -- ITSELF. `c:Release()` while it was still parented put the widget
                        -- back in AceGUI's pool WITHOUT removing it from `group.children`;
                        -- the next Create handed the SAME object back, AddChild listed it
                        -- twice, and Flow then ran `frame:SetPoint("TOPLEFT",
                        -- children[i-1].frame, ...)` with i-1 pointing at the same frame -
                        -- "trying to anchor to itself", AceGUI-3.0.lua:767. ★ ReleaseChildren
                        -- releases AND clears the list, so the pool can never hand back a
                        -- widget the container still lists.
                        -- ⚠ Outside the pcall: an error must not leak a parented child into
                        -- the next iteration, which is how one bad widget would poison the
                        -- rest of the sheet.
                        if group then group:ReleaseChildren() end
                        if not ok then row.error = "could not create or measure" end
                        payload.controls[#payload.controls + 1] = row
                    end
                end
            end

            payload.containers = {}
            for _, cname in ipairs(C.containers or {}) do
                local ok = pcall(function()
                    local c = AceGUI:Create(cname)
                    if not c then
                        payload.controlsMissing[#payload.controlsMissing + 1] = cname
                        return
                    end
                    c:SetLayout("Flow")
                    c:SetWidth(hostW)
                    c.frame:SetParent(sheet.host)
                    c.frame:ClearAllPoints()
                    c.frame:SetPoint("TOPLEFT", sheet.host, "TOPLEFT", 0, -320)
                    c.frame:Show()
                    c:DoLayout()
                    payload.containers[cname] = {
                        askedWidth = hostW,
                        width = c.frame:GetWidth(),
                        height = c.frame:GetHeight(),
                        -- the usable content area every child's width resolves against
                        contentWidth = c.content and c.content:GetWidth() or nil,
                        contentHeight = c.content and c.content:GetHeight() or nil,
                    }
                    c:Release()
                end)
                if not ok then
                    payload.containers[cname] = { error = "could not create or measure" }
                end
            end

            if group then group:Release() end
            payload.controlInputs = { widthMultiplier = mult, hostWidth = hostW }
        end

        -- =============================================================
        -- KIND `art` (sheet three) - how far the PICTURE runs past the RECT.
        -- ★ Every check we own compares rects, and §103 proved that under-reports a
        -- dropdown by design. This measures the difference instead of assuming it.
        -- =============================================================
        local A = decl.art
        payload.art = {}
        payload.artMissing = {}
        local artCount = 0
        -- ⚠ ART MEASURES ON PAGE 1's HOST. Without this it would run against a hidden frame
        -- and record zeros - and a zero here reads as "no overhang", which is a FINDING.
        -- The one guard that had to exist before a sheet2 run, not after one.
        local artSkip = (PAGE ~= 1)
            and "page 1 was not the page of interest - NOT MEASURED. /coadump r sheet1" or nil
        if artSkip then payload.artSkipped = artSkip end

        -- Union every VISIBLE region under a frame, to a bounded depth.
        -- ⚠ Hidden regions are skipped and COUNTED: a texture that draws nothing must
        -- not invent an overhang, but "none were hidden" and "we did not look" are
        -- different facts and the record keeps both.
        local function unionRegions(frame, depth, acc, maxDepth)
            if not frame or depth > (maxDepth or 4) then return end
            if frame.GetRegions then
                local regions = { frame:GetRegions() }
                for i = 1, #regions do
                    local r = regions[i]
                    local shown = r and r.IsVisible and r:IsVisible()
                    if r and r.GetLeft then
                        if shown then
                            local l, b, w, h = r:GetRect()
                            if l and b and w and h then
                                acc.n = acc.n + 1
                                acc.left = acc.left and math.min(acc.left, l) or l
                                acc.bottom = acc.bottom and math.min(acc.bottom, b) or b
                                acc.right = acc.right and math.max(acc.right, l + w) or (l + w)
                                acc.top = acc.top and math.max(acc.top, b + h) or (b + h)
                            else
                                acc.unplaced = acc.unplaced + 1
                            end
                        else
                            acc.hidden = acc.hidden + 1
                        end
                    end
                end
            end
            if frame.GetChildren then
                local kids = { frame:GetChildren() }
                for i = 1, #kids do
                    unionRegions(kids[i], depth + 1, acc, maxDepth)
                end
            end
        end

        local function measureArt(label, frame, source, variant)
            local row = { subject = label, source = source, variant = variant }
            local ok = pcall(function()
                local fl, fb, fw, fh = frame:GetRect()
                if not fl then row.error = "frame has no rect"; return end
                row.frame = { left = fl, bottom = fb, width = fw, height = fh }
                local acc = { n = 0, hidden = 0, unplaced = 0 }
                unionRegions(frame, 1, acc, A and A.maxDepth or 4)
                row.regions = acc.n
                row.hiddenRegions = acc.hidden
                row.unplacedRegions = acc.unplaced
                if acc.n > 0 and acc.left then
                    row.art = { left = acc.left, bottom = acc.bottom,
                                width = acc.right - acc.left, height = acc.top - acc.bottom }
                    -- ★ POSITIVE MEANS THE PICTURE RUNS PAST THE RECT ON THAT EDGE.
                    -- One number per edge, because the dropdown is asymmetric: its art
                    -- is 25 wider on each side but +17 above and only ~15 below.
                    row.over = {
                        left = fl - acc.left,
                        right = acc.right - (fl + fw),
                        top = acc.top - (fb + fh),
                        bottom = fb - acc.bottom,
                    }
                end
            end)
            if not ok then row.error = row.error or "could not measure" end
            payload.art[#payload.art + 1] = row
            artCount = artCount + 1
        end

        local items = {}
        if not A then
            payload.artSkipped = "the declaration carries no `art` section"
        else
            -- ★★ ART IS MEASURED OFF THE BOARD, not off throwaway frames. The first run
            -- created each subject, showed it and read it in the SAME tick, and came back
            -- with 6 of 6 dropdown regions "unplaced" - a frame's rect is not resolved
            -- until it has been through a draw. The board persists, so a read a frame
            -- later gets real numbers. Same argument as measuring text on a SHOWN frame.
            items = buildBoard(decl, AceGUI) or {}
            -- ★ The looked-at half of sheet six, built once and left on the sheet.
            pcall(buildTabBoard, decl, AceGUI)
            pcall(buildCollapseBoard, decl, AceGUI)
            pcall(buildRangeBoard, decl, AceGUI)
            pcall(buildScrollBoard, decl, AceGUI)
            pcall(buildHostBoard, decl, AceGUI)
            pcall(buildGutterProto, decl, AceGUI)
            pcall(buildRegistration)
            -- ★★★ THE BOARDS BUILD ON EVERY PAGE - only the MEASUREMENT is page-scoped.
            -- ⚠ Skipping this whole branch to "skip art" would have left every persistent
            -- board unbuilt on a sheet2 run, which is the exact fault this file documents
            -- twice: a correct run and an empty pane. The builds are above this line for
            -- that reason; the art READ is below it and is what the page gates.
            if artSkip then items = {} end
            local built = {}
            for _, it in ipairs(items) do built[it.subject] = true end
            for _, entry in ipairs(A.templates or {}) do
                -- ⚠ NAMED, never counted as zero overhang - which would read as
                -- "measured, and it is fine".
                -- ⚠⚠ v3 made templates `{ name, type }` and THIS loop still read them as
                -- strings, so it pushed whole tables into artMissing and the reader choked
                -- on them. One shape change, two loops, and only one was updated - the
                -- second was three lines away.
                local name = type(entry) == "table" and entry.name or entry
                if not built[name] then payload.artMissing[#payload.artMissing + 1] = name end
            end
            if not AceGUI then
                payload.artWidgetsSkipped = "AceGUI-3.0 not loaded - templates only"
            else
                for _, name in ipairs(A.widgets or {}) do
                    if not built[name] then
                        payload.artMissing[#payload.artMissing + 1] = name
                    end
                end
            end
        end

        -- =============================================================
        -- KIND `behaviour` (sheet four) - does the widget OBEY the grammar?
        -- ★ Same shape as `/coadump r api`: claim vs observed vs agrees. A line of
        -- `concepts/input-commit.md` that nothing drives is a reading of source, not
        -- a fact about this client.
        -- =============================================================
        local B = decl.behaviour
        payload.behaviour = {}
        local behaviourCount = 0

        local function check(subject, id, claim, observed, how, note)
            payload.behaviour[#payload.behaviour + 1] = {
                subject = subject, id = id, claim = claim, observed = observed,
                -- ⚠ tostring: a boolean survives the mailbox, but an observed value
                -- that could be nil would vanish and read as "not checked".
                agrees = (tostring(claim) == tostring(observed)),
                how = how, note = note,
            }
            behaviourCount = behaviourCount + 1
        end

        if not B then
            payload.behaviourSkipped = "the declaration carries no `behaviour` section"
        elseif not AceGUI then
            payload.behaviourSkipped = "AceGUI-3.0 is not loaded - nothing to drive"
        else
            for _, wname in ipairs(B.subjects or {}) do
                local ok = pcall(function()
                    local c = AceGUI:Create(wname)
                    if not c then
                        check(wname, "widget.exists", true, false, "api",
                            "the live AceGUI does not register it")
                        return
                    end
                    c.frame:SetParent(sheet.host)
                    c.frame:ClearAllPoints()
                    c.frame:SetPoint("TOPLEFT", sheet.host, "TOPLEFT", 0, -240)
                    c:SetWidth(170)
                    c.frame:Show()

                    -- what the widget told us, per stimulus
                    local fired, lastUserInput, committed = 0, nil, false
                    c:SetCallback("OnTextChanged", function() fired = fired + 1 end)
                    c:SetCallback("OnEnterPressed", function() committed = true end)
                    if c.editbox then
                        c.editbox:HookScript("OnTextChanged", function(_, userInput)
                            lastUserInput = userInput
                        end)
                    end

                    local button = c.button
                    check(wname, "button.onByDefault", true,
                        (button and not c.disablebutton) and true or false, "api",
                        "OnAcquire calls DisableButton(false)")

                    -- 1. programmatic SetText -------------------------------------
                    c:SetText("")
                    fired = 0
                    c:SetText(B.probeText or "pending specimen")
                    check(wname, "settext.firesTextChanged", true, fired > 0, "api")
                    check(wname, "settext.userInputFalse", false,
                        lastUserInput and true or false, "api",
                        "the client's second arg; false for a programmatic write")

                    -- ⚠⚠ SetText HIDES the button (EditBox.lua:146), so a differing
                    -- text alone does NOT leave it showing. The dirty state comes from
                    -- a KEYSTROKE, which no script can produce. Driving the widget's
                    -- own ShowButton path is the closest honest approximation, and it
                    -- is marked `handler` so nobody reads it as the client's dispatch.
                    check(wname, "settext.hidesButton", false,
                        button and button:IsShown() or false, "api",
                        "programmatic writes are not dirty - by design")

                    -- 2. the pending state, driven through the widget's own script --
                    if c.editbox then
                        local h = c.editbox:GetScript("OnTextChanged")
                        if h then pcall(h, c.editbox, true) end
                    end
                    local dirty = button and button:IsShown() or false
                    check(wname, "dirty.showsButton", true, dirty, "handler",
                        "OnTextChanged invoked directly - a real keystroke cannot be scripted")

                    -- 3. ★ HIS RULING: pending survives focus loss ------------------
                    if dirty then
                        c.editbox:ClearFocus()
                        check(wname, "focusloss.staysPending", true,
                            button and button:IsShown() or false, "api",
                            "commit partial NO, discard NO, stay pending YES")

                        -- 4. Escape - AceGUI clears focus, never reverts -------------
                        local esc = c.editbox:GetScript("OnEscapePressed")
                        if esc then pcall(esc, c.editbox) end
                        check(wname, "escape.staysPending", true,
                            button and button:IsShown() or false, "handler",
                            "AceGUI:ClearFocus() only - no revert, no commit")

                        -- 5. the accept button commits ------------------------------
                        -- ★ Click() is synchronous and fires on hidden frames on this
                        -- fork (ROUTER, measured), so the commit path is drivable.
                        committed = false
                        if button then pcall(function() button:Click() end) end
                        check(wname, "accept.commits", true, committed, "api",
                            "button -> ClearFocus -> the Enter path")
                        check(wname, "accept.hidesButton", false,
                            button and button:IsShown() or false, "api",
                            "a committed field is no longer dirty")
                    else
                        check(wname, "focusloss.staysPending", true, "not driven", "none",
                            "the button never showed, so pending could not be entered")
                    end

                    c:Release()
                end)
                if not ok then
                    check(wname, "probe.ran", true, false, "none", "the probe errored")
                end
            end

            -- ⚠ NAMED, not silently absent. The half of the grammar no script reaches.
            payload.behaviourUnmeasurable = {
                ["type freely (userInput = true)"] =
                    "only a real keystroke sets it; SetText is always programmatic",
                ["Enter as a key press"] =
                    "the handler can be invoked, the key press cannot be produced",
            }
        end

        sheet.title:SetText("COA UI test sheet - declaration v" .. tostring(decl.version))
        sheet.config:SetText((payload.config.resolution or "?") .. "  at uiScale "
            .. string.format("%.4f", payload.config.uiParentEffectiveScale or 0)
            .. "   -   " .. measured .. " text cells measured")

        -- ★★★ MEASURE AND COMMIT ON THE NEXT FRAME. Everything above BUILT; nothing above
        -- read a rect off the board, because a frame created and shown in this tick has
        -- none yet - the first art run returned 6 of 6 dropdown regions "unplaced" and a
        -- table of dashes. ⚠ C_Timer.After is frame-driven and quantises to the next frame
        -- (ROUTER, measured 2026-08-16), so a zero delay is exactly "after a draw" and
        -- nothing more. The envelope is already open; Commit simply happens later.
        local function finish()
            for _, it in ipairs(items) do
                measureArt(it.subject, it.frame, it.source, it.variant)
            end

            -- ★★★ SHEET EIGHT'S GEOMETRY HALF - and it checks ONE claim, his:
            -- *"no two targets share a pixel"*. The whole reason for putting the envelope
            -- handles ABOVE the bar and the slice handles BELOW is that Z-order then decides
            -- nothing, because nothing overlaps. ⟶ A pairwise overlap test is the proof, and
            -- if it ever finds one the arrangement has stopped doing its job.
            -- ⚠ MEASURED IN THE DEFERRED PASS. A frame built and read in one tick has no
            -- resolved rect - the same lesson the art kind paid for.
            -- ★★ EMITTED WITH THEIR RECTS AND COLOURS, so a screenshot can be
            -- rectified against the record rather than against a guess.
            payload.registration = { pins = {}, sheet = nil }
            if sheet.regPins then
                local sl, sb = sheet:GetLeft(), sheet:GetBottom()
                if sl and sb then
                    payload.registration.sheet = string.format(
                        "x %.0f..%.0f   y %.0f..%.0f", sl, sl + sheet:GetWidth(),
                        sb, sb + sheet:GetHeight())
                end
                for name, pin in pairs(sheet.regPins) do
                    local ok = pcall(function()
                        local l, b = pin.f:GetLeft(), pin.f:GetBottom()
                        payload.registration.pins[name] = string.format(
                            "rgb %.2f %.2f %.2f   x %.0f..%.0f   y %.0f..%.0f",
                            pin.r, pin.g, pin.b, l, l + pin.f:GetWidth(),
                            b, b + pin.f:GetHeight())
                    end)
                    if not ok then
                        payload.registration.pins[name] = "unmeasurable"
                    end
                end
            end

            -- ★★★ THE PROTOTYPE PAGE'S RECORD - and its absence was the finding.
            -- `buildGutterProto` landed in §644 and NO payload block was ever written for it, so
            -- `/coadump r sheet3` ran, skipped all seven other blocks by page, and recorded
            -- **nothing at all**. ⚠⚠ Worse: the migration-progress line counted that run as a
            -- page re-captured and printed *"migration complete"*. ⟶ A progress indicator that can
            -- be satisfied without the underlying work happening is worse than none - it converts
            -- an open question into a closed one.
            --
            -- ★ WHAT IT RECORDS is the A/B itself, so the choice stops being screenshot-only:
            -- both columns' usable width at the same content height, and the TEXT HEIGHT in each,
            -- because the width is the cause and the height is the consequence (`UL-21`).
            payload.proto = { note = nil }
            local P = sheet.protoItems
            if PAGE ~= 3 then
                payload.proto.note = string.format(
                    "page %d was not the page of interest - NOT MEASURED. /coadump r sheet%d", 3, 3)
            elseif type(P) ~= "table" or not P.a then
                payload.proto.note = "the gutter prototype did not build"
            else
                payload.proto.rows = P.rows
                for _, side in ipairs({ "a", "b" }) do
                    local c = P[side]
                    local rec = { reserves = c.reserves and true or false }
                    pcall(function()
                        rec.usable = c.view:GetWidth()
                        rec.childW = c.child:GetWidth()
                        rec.textH = c.fs:GetHeight()
                        rec.barShown = c.bar:IsShown() and true or false
                    end)
                    payload.proto[side] = rec
                end
                -- ⟶ THE COMPARISON, computed here so a reader of the record does not redo it.
                -- ⚠ Rounded, not `==`: these are scaled floats on the quantum grid, which is the
                -- fault `UL-24` caught one day ago in this same file.
                local a, b = payload.proto.a, payload.proto.b
                if a.usable and b.usable then
                    payload.proto.widthGap = a.usable - b.usable
                    payload.proto.sameWidth =
                        math.floor((a.usable or 0) + 0.5) == math.floor((b.usable or 0) + 0.5)
                end
                if a.textH and b.textH then
                    payload.proto.heightGap = a.textH - b.textH
                end
            end

            -- ★★★ SHEET NINE - and this block CHECKS four numbers rather than finding them.
            -- Upstream declares them (`AceGUIContainer-ScrollFrame.lua` :102 :114 :117 :183)
            -- and `check_sheet --scroll` already computes every consequence offline. What a
            -- client run adds is whether the primitives behave that way ON THIS FORK, which
            -- customises at the CALLER layer.
            --
            -- ⚠ THE COST IS A DIFFERENCE. `view` gave up its width to a bar; `ref` did not.
            -- Reading one frame's width proves nothing, because nothing says what it would
            -- otherwise have been.
            -- ★★★ SHEET TEN. His question, 2026-08-26: *"Does ace still handle the
            -- position on the hosted frame, or do we hand place that range?"*
            -- ⚠ NOT ANSWERABLE FROM OUR OWN CODE - `options.lua`'s `SeatMap` sets
            -- `mapSeat:SetLayout(nil)`, turning the layout off, and has NO caller in the
            -- addon. And no landed capture holds one either: every `.content` use in this
            -- file READS a container to measure it; none has ever parented a raw frame in.
            payload.host = { measured = {}, note = nil }
            local hi = sheet.hostItems
            local Hd = decl.host
            -- ⚠ PAGE 3 SINCE v13, not 2. The board moved because four arms did not fit
            -- under `scrollBoard`; the run command moved with it, and this message is the
            -- only place a person finds that out.
            if PAGE ~= 3 then
                payload.host.note = string.format(
                    "page %d was not the page of interest - NOT MEASURED. /coadump r sheet3", PAGE)
            elseif type(Hd) ~= "table" then
                payload.host.note = "no host declaration in COA_UI_SHEET (v"
                    .. tostring(decl.version) .. ")"
            elseif type(hi) ~= "table" or not hi.direct then
                payload.host.note = "the host demo did not build"
            else
                local m = payload.host.measured
                pcall(function()
                    for _, arr in ipairs({ "direct", "wrapped" }) do
                        local r = hi[arr]
                        if r then
                            -- ★ MOVED is a DIFFERENCE, never a position. A child at 7,-7
                            -- that was never touched and one placed there by a layout read
                            -- identically from a rect - which is why the before-point is
                            -- taken at a known offset rather than at the origin.
                            local movedX = (r.after.x or 0) - (r.before.x or 0)
                            local movedY = (r.after.y or 0) - (r.before.y or 0)
                            m[arr] = {
                                movedX = movedX,
                                movedY = movedY,
                                positioned = (movedX ~= 0 or movedY ~= 0),
                                -- ⚠ A LAYOUT THAT RESIZES IS WORSE THAN ONE THAT IGNORES,
                                -- for a composite with its own scale: `options.lua`'s
                                -- header names that as the mechanism that would break the
                                -- map canvas.
                                childW = r.after.w, childH = r.after.h,
                                -- ⚠⚠ COMPARED WITH TOLERANCE, and a first cut did not.
                                -- `DR_Pane_7`: geometry lands on a QUANTUM GRID, so
                                -- `~=` against a declared integer is always true - the
                                -- client returned 120.0000016412453 for a 120 nobody
                                -- touched, and the capture read RESIZED on both
                                -- arrangements. ★ The law names three prior instances in
                                -- its own text; this was the fourth, in code written the
                                -- same day it was cited.
                                resized = math.abs((r.after.w or 0)
                                              - ((Hd.child and Hd.child.w) or 0)) > 0.5
                                       or math.abs((r.after.h or 0)
                                              - ((Hd.child and Hd.child.h) or 0)) > 0.5,
                                contentH = r.contentH,
                                -- ★★ THE WITNESS. A real AceGUI widget in the same seat
                                -- under the same layout. Without it, *"Ace positioned
                                -- nothing"* and *"the layout never ran"* are one reading.
                                witnessY = r.witnessY,
                                innerY = r.innerY,
                            }
                        end
                    end
                    -- ★★ THE SEATED ARM. `built` is the count of times the Dialog called
                    -- our constructor - the offline smoke proves it is called at all; what
                    -- only a client can say is what the widget is GIVEN once a real Dialog
                    -- lays out a real table.
                    if hi.seatedNote then
                        m.seatedNote = hi.seatedNote
                    elseif hi.seated then
                        local s = hi.seated
                        local seatFrame = s.holder and s.holder.frame
                        m.seated = {
                            built = s.built,
                            holderH = s.holderH,
                            seatTop = seatFrame and seatFrame:GetTop() or nil,
                            -- ⚠ A COUNT, not a boolean: the Dialog may build a widget more
                            -- than once across a refresh, and *"it ran twice"* is a
                            -- different finding from *"it ran"*.
                            reachable = (s.built or 0) > 0,
                        }
                    end

                    -- ★★★ THE RECYCLE ARM - DR_Pane_2 at the seat.
                    if hi.recycleNote then
                        m.recycleNote = hi.recycleNote
                    elseif hi.recycle then
                        local r = hi.recycle
                        m.recycle = {
                            ctor = r.ctor, acquires = r.acquires,
                            sameSeat = r.sameSeat,
                            -- ⚠ THE ONE THAT MATTERS. TRUE means a re-acquired seat came
                            -- back holding the LAST tab's content - the stale-state fault
                            -- DR_Pane_2 exists to prevent, arriving through Ace's pool
                            -- where `ReleaseChildren` cannot see a raw frame.
                            stillThere = r.stillThere,
                            layoutAfter = r.layoutAfter,
                        }
                    end

                    -- ★★★ THE ONE SENTENCE THE CAPTURE IS FOR, written where it is
                    -- measured rather than derived later by a reader who was not here.
                    local d, w = m.direct, m.wrapped
                    m.verdict =
                        (d and d.positioned) and "DIRECT: Ace places a raw child"
                        or ((w and w.positioned) and "WRAPPED ONLY: a raw frame needs a "
                            .. "widget seat; Ace places the SEAT, we place inside it")
                        or "NEITHER: a hosted composite carries its own placement"
                end)
            end

            payload.scroll = { upstream = {}, measured = {}, note = nil }
            local si = sheet.scrollItems
            local Sd = decl.scroll
            if PAGE ~= 2 then
                payload.scroll.note = string.format("page %d was not the page of interest - NOT MEASURED. /coadump r sheet%d", 2, 2)
            elseif type(Sd) ~= "table" then
                payload.scroll.note = "no scroll declaration in COA_UI_SHEET (v"
                    .. tostring(decl.version) .. ")"
            elseif type(si) ~= "table" or not si.view then
                payload.scroll.note = "the scroll demo did not build"
            else
                for k, v in pairs(Sd.upstream or {}) do payload.scroll.upstream[k] = v end
                local m = payload.scroll.measured
                pcall(function()
                    m.paneDeclared = si.pane
                    m.viewportW    = si.view:GetWidth()
                    m.refW         = si.ref:GetWidth()
                    -- ⟶ THE ONE NUMBER: what a shown bar takes off the usable width.
                    m.costMeasured = (si.ref:GetWidth() or 0) - (si.view:GetWidth() or 0)
                    m.barW         = si.bar:GetWidth()
                    -- the bar sits +4 right of the viewport, so its RIGHT edge minus the
                    -- viewport's right edge is the full gutter the pane loses.
                    local vr = (si.view:GetLeft() or 0) + (si.view:GetWidth() or 0)
                    local br = (si.bar:GetLeft() or 0) + (si.bar:GetWidth() or 0)
                    m.gutter       = br - vr
                    m.contentH     = si.child:GetHeight()
                    m.viewportH    = si.view:GetHeight()
                    si.view:UpdateScrollChildRect()
                    m.rangeReported = si.view:GetVerticalScrollRange()
                    -- ★ MEASURED AGAIN A FRAME LATER, because the first read is 0 and the
                    -- guard below correctly called it DEFERRED rather than a finding. The art
                    -- block already does exactly this (`C_Timer.After(0, finish)`) for the same
                    -- reason - a rect is not resolved until it has been through a draw. ⟶ The
                    -- guard was right and the fix is to ASK AGAIN, not to loosen the guard.
                    if C_Timer and C_Timer.After then
                        C_Timer.After(0, function()
                            if not si.view then return end
                            si.view:UpdateScrollChildRect()
                            payload.scroll.measured.rangeDeferred =
                                si.view:GetVerticalScrollRange()
                        end)
                    else
                        payload.scroll.scrollDeferred =
                            "C_Timer.After unavailable - the range could not be re-read"
                    end
                    m.rangeExpected = math.max(0, (si.child:GetHeight() or 0)
                                                  - (si.view:GetHeight() or 0))
                end)
                -- ⚠ A range of zero when the child is TALLER than the viewport is not a
                -- measurement, it is a layout that has not happened yet. Say which it is
                -- rather than emitting a 0 that reads as a finding.
                if (m.rangeReported or 0) == 0 and (m.rangeExpected or 0) > 0 then
                    payload.scroll.note =
                        "scroll range read 0 with " .. tostring(m.rangeExpected)
                        .. " expected - DEFERRED layout, not a zero"
                end
                -- ★ The verdict, computed here so a reader of the record does not have to.
                --
                -- ⚠⚠ THE THIRD INSTANCE OF ONE FAULT, and this file is where it was caught.
                -- The first version compared with `==`:  costMeasured == 20. The run came back
                -- **19.99999589688684** and the verdict read FALSE while every number agreed.
                -- ⟶ Client geometry lands on a quantum grid (q = 0.5334 at this config) - the
                -- entire premise of this sheet - so a measurement is NEVER exactly integral.
                -- ★ Its two ancestors: §578's absolute tolerance in `--wrap` (3/11 and 6/11
                -- reported as failures), and `derive_quantum`'s absolute tolerance right after
                -- (UI-1's "no common grid"). **Same fault, three shapes, one file each.**
                -- ⟶ The declared constants are INTEGERS and the measurement is a float on a
                -- grid, so ROUND the measurement and say so - and keep the residual, because
                -- "agrees" without a distance is a verdict you cannot check.
                local up = Sd.upstream or {}
                local function near(measured, declared)
                    return math.floor((measured or 0) + 0.5) == declared
                end
                m.costResidual = (m.costMeasured or 0) - (up.widthCost or 20)
                m.barResidual = (m.barW or 0) - (up.barWidth or 16)
                payload.scroll.agrees =
                    near(m.costMeasured, up.widthCost or 20) and
                    near(m.barW, up.barWidth or 16)
            end

            payload.range = { targets = {}, overlaps = {} }
            local ri = sheet.rangeItems
            if PAGE ~= 2 then
                payload.range.note = string.format("page %d was not the page of interest - NOT MEASURED. /coadump r sheet%d", 2, 2)
            elseif type(ri) ~= "table" then
                payload.range.note = "the range demo did not build"
            else
                local names, rects = {}, {}
                for name, f in pairs(ri) do
                    local ok = pcall(function()
                        local l, b, w, h = f:GetLeft(), f:GetBottom(), f:GetWidth(), f:GetHeight()
                        if l and b and w and h then
                            rects[name] = { l = l, b = b, r = l + w, t = b + h, w = w, h = h }
                            names[#names + 1] = name
                            payload.range.targets[name] =
                                string.format("x %.0f..%.0f   y %.0f..%.0f   (%.0f x %.0f)",
                                              l, l + w, b, b + h, w, h)
                        end
                    end)
                    if not ok then payload.range.targets[name] = "unmeasurable" end
                end
                table.sort(names)
                for i = 1, #names do
                    for j = i + 1, #names do
                        local a, c = rects[names[i]], rects[names[j]]
                        -- ⚠ Touching is not overlapping: a shared EDGE is fine, a shared
                        -- PIXEL is not. Hence strict inequality on both axes.
                        if a.l < c.r and c.l < a.r and a.b < c.t and c.b < a.t then
                            payload.range.overlaps[#payload.range.overlaps + 1] =
                                names[i] .. " x " .. names[j]
                        end
                    end
                end
                payload.range.n = #names
            end
            -- ★★★ REQUEST A SHOT, and the discipline is NOT invented here - it is
            -- `COA_DungeonRun/ui.lua:36-42`'s, reused:
            --   *"ADDON LUA CANNOT READ FILES FROM DISK. So the client can never verify a
            --    screenshot landed - it records `requested a shot at T labelled L` and the
            --    JOIN HAPPENS REPO-SIDE."*
            --   *"ONE screenshot survives per SECOND ... a faster shot yields NO extra
            --    file, silently."*
            -- ⟶ There is NO naming a screenshot on this client. Asking for one is all the
            -- client can do; pairing it is `check_sheet`'s job, with the same ±1s window
            -- `ui_run.py` already uses.
            --
            -- ⚠ IT IS THE REQUEST TIME, NOT THE CAPTURE TIME - the client names the file
            -- when the frame ENDS, so a request on a second boundary can produce a name one
            -- second later. Stated here so a near-miss is a tolerance rather than a mystery.
            -- ★ Taken LAST, after every measurement, so the sheet in the image is the sheet
            -- the record describes.
            payload.shot = {
                label = "sheet",
                requestedAt = (date and date("%m%d%y_%H%M%S")) or nil,
                note = "pair repo-side; the client cannot confirm the file landed",
            }
            if Screenshot then Screenshot() end

            D.Commit("sheet: " .. measured .. " text cell(s) over " .. (#fonts - missing)
                .. " font object(s)"
                .. (missing > 0 and (", " .. missing .. " unmeasurable") or "")
                .. " · " .. (payload.controlSkipped and ("controls SKIPPED - "
                    .. payload.controlSkipped:sub(1, 48))
                    or (controlCount .. " control cell(s), AceGUI "
                        .. tostring((payload.config.libs or {})["AceGUI-3.0"])))
                .. " · " .. (payload.behaviourSkipped and "behaviour SKIPPED"
                or (behaviourCount .. " behaviour check(s)"))
            .. " · " .. (payload.artSkipped and "art SKIPPED"
                    or (artCount .. " art subject(s) measured off the board"))
                .. " · " .. ((payload.range and #(payload.range.overlaps or {}) or 0)
                    .. " target overlap(s)")
                .. " · " .. (payload.collapse.note and ("collapse NOT MEASURED")
                    or ((payload.collapse.measured or 0) .. " collapse state(s)"))
                .. " · " .. (payload.tab.note and ("tabs NOT MEASURED - "
                        .. payload.tab.note:sub(1, 40))
                    or ((payload.tab.measured or 0) .. " tab strip(s)"))
                .. " · " .. (payload.wrap.note and ("wrap NOT MEASURED - "
                        .. payload.wrap.note:sub(1, 44))
                    or ((payload.wrap.measured or 0) .. " wrap cell(s)"))
                .. " · " .. tostring(payload.config.resolution)
                .. " uiScale " .. string.format("%.4f", payload.config.uiParentEffectiveScale or 0))
        end

        if C_Timer and C_Timer.After then
            C_Timer.After(0, finish)
        else
            -- ⚠ NOT SILENT. Without a frame of delay the art numbers are unreliable rather
            -- than absent, which is the worse failure - so the record says so instead of
            -- carrying dashes that look like "no overhang".
            payload.artDeferred = "C_Timer.After unavailable - art measured in the build "
                .. "tick, so its rects may be unresolved. Treat this run's art as suspect."
            finish()
        end
end

D.RegisterTask{ name = "sheet",  mode = "oneshot",
    help = "sheet - the UI test sheet, page 1 (specimens). Measures the page of interest ONLY",
    run = function(args) runSheet(1, args) end }
D.RegisterTask{ name = "sheet1", mode = "oneshot",
    help = "sheet1 - page 1: text specimens, wrap, controls, art",
    run = function(args) runSheet(1, args) end }
D.RegisterTask{ name = "sheet2", mode = "oneshot",
    help = "sheet2 - page 2: tabs, collapse, range, scroll",
    run = function(args) runSheet(2, args) end }
D.RegisterTask{ name = "sheet3", mode = "oneshot",
    help = "sheet3 - page 3: prototypes (the gutter A/B)",
    run = function(args) runSheet(3, args) end }
