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

    sheet = CreateFrame("Frame", "COA_UISheet", UIParent)
    sheet:SetWidth(1010)
    sheet:SetHeight(620)
    sheet:SetPoint("CENTER")
    sheet:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    sheet:SetMovable(true)
    sheet:EnableMouse(true)
    sheet:RegisterForDrag("LeftButton")
    sheet:SetScript("OnDragStart", function(self) self:StartMoving() end)
    sheet:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local close = CreateFrame("Button", nil, sheet, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", sheet, "TOPRIGHT", -6, -6)

    sheet.title = sheet:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sheet.title:SetPoint("TOPLEFT", sheet, "TOPLEFT", 18, -18)

    sheet.config = sheet:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sheet.config:SetPoint("TOPLEFT", sheet.title, "BOTTOMLEFT", 0, -6)

    -- The measuring host. Parented to the sheet so it inherits the same effective
    -- scale as everything on it, and never hidden.
    sheet.host = CreateFrame("Frame", nil, sheet)
    sheet.host:SetPoint("TOPLEFT", sheet, "TOPLEFT", 18, -70)
    sheet.host:SetWidth(420)
    sheet.host:SetHeight(270)

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
    sheet.board = CreateFrame("Frame", nil, sheet)
    sheet.board:SetPoint("TOPLEFT", sheet, "TOPLEFT", 460, -70)
    sheet.board:SetWidth(530)
    sheet.board:SetHeight(520)

    sheet.boardTitle = sheet:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sheet.boardTitle:SetPoint("BOTTOMLEFT", sheet.board, "TOPLEFT", 0, 4)
    sheet.boardTitle:SetText("input types, as built   -   NAMED  vs  anonymous")

    sheet.rows = {}
    return sheet
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

D.RegisterTask{
    name = "sheet",
    mode = "oneshot",
    help = "sheet - spawn the UI test sheet, measure every declared cell, record it",
    run = function(args)
        if type(COA_UI_SHEET) ~= "table" or type(COA_UI_SHEET.text) ~= "table" then
            D.Print("sheet: COA_UI_SHEET is not loaded - sheet_decl.lua missing from the .toc. "
                .. "Nothing measured; a standard the measuring tool invented is not a standard.")
            return
        end

        local decl = COA_UI_SHEET
        local payload = D.Begin("sheet", args)
        payload.declVersion = decl.version

        buildSheet()
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

        local fonts = decl.text.fonts or {}
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
        -- KIND `control` (sheet two) - what an AceGUI widget BECOMES when asked
        -- for a width. ⚠ We measure the LIVE AceGUI, never a copy we loaded
        -- ourselves: the whole point is what the user's addon set resolved to.
        -- =============================================================
        local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
        payload.controls = {}
        payload.controlsMissing = {}
        local controlCount = 0

        if not decl.control then
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
            local built = {}
            for _, it in ipairs(items) do built[it.subject] = true end
            for _, name in ipairs(A.templates or {}) do
                -- ⚠ NAMED, never counted as zero overhang - which would read as
                -- "measured, and it is fine".
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
            D.Commit("sheet: " .. measured .. " text cell(s) over " .. (#fonts - missing)
                .. " font object(s)"
                .. (missing > 0 and (", " .. missing .. " unmeasurable") or "")
                .. " · " .. (payload.controlSkipped and ("controls SKIPPED - "
                    .. payload.controlSkipped:sub(1, 48))
                    or (controlCount .. " control cell(s), AceGUI "
                        .. tostring((payload.config.libs or {})["AceGUI-3.0"])))
                .. " · " .. (payload.artSkipped and "art SKIPPED"
                    or (artCount .. " art subject(s) measured off the board"))
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
    end,
}
