-- frames.lua - AN OFFLINE FRAME MODEL THAT KEEPS ITS GEOMETRY (§100).
--
-- ---------------------------------------------------------------------------
-- ★★★ WHY. We already construct every frame offline - the smoke suite loads the
-- pane code and runs it against a stub on every test. But that stub's `__index`
-- hands back `function() end` for everything it does not name, so `SetPoint` and
-- `SetSize` are NO-OPS. ⚠ We build the frames and throw the geometry away.
--
-- So the two bugs that started this could not be caught by anything we own:
--
--   an ORPHANED HEADING   a label at a fixed y that nothing hides
--   a CLIPPED BUTTON      x=208 on a 280-wide frame - the play button
--
-- Both are ARITHMETIC. Both were found by a human looking at a screenshot.
--
-- ★★★ THE PROMPT, and it is the whole design. Battlewrath, on AddOn Studio and the
-- 2010 `WoW UI Designer`: *"If their programming can construct the frames off-line.
-- Then they have the shape of how. And we have the client on access. So we don't
-- have to keep going back and forth."*
--
-- ★★ AND OUR PROBLEM IS THE EASY HALF OF THEIRS. WoW UI Designer had to resolve XML
-- template inheritance, pull textures out of the MPQs, and host an interpreter. We
-- have none of that: `COA_DungeonRun` is fourteen `.lua` files and zero XML, and the
-- interpreter is already the real one (Lua 5.1.5 against the client's 5.1). What is
-- missing is only that nothing was WRITING THE NUMBERS DOWN.
--
-- ★★★ AND THE ONE THING THEY GOT WRONG IS THE ONE THING WE DO NOT HAVE TO GUESS.
-- Their own release notes concede the renderer's font metrics are *"still not exactly
-- like WoWs"* - and a FontString's width comes from its text and its font. They had
-- to be right because their renderer was the only output. ⚠ WE ARE NOT A RENDERER.
-- A size nobody set is recorded as UNKNOWN and is never invented, so the audit
-- names them and that list IS the shopping list for one measuring run in the client.
-- The unknown becomes a MEASURED CONSTANT rather than a simulation.
--
-- ⚠⚠ THIS IS A MODEL, AND A MODEL THAT DISAGREES WITH THE CLIENT IS WORSE THAN NO
-- MODEL - `layout.lua` says so about this exact boundary. What keeps it honest is
-- that it may only ever REPORT, never assume: every rect carries whether it was
-- resolved and why not, and an unresolved anchor is loud rather than zero.
-- ---------------------------------------------------------------------------

local F = {}

-- ★ Every anchor point as a fraction of the rect: how far across from the left,
-- how far DOWN from the top. Nine points, one table, no branching anywhere else.
-- ⚠ WoW's y increases UPWARD, so `down` is subtracted from top - the sign lives
-- here once rather than at every call site.
local PT = {
    TOPLEFT     = { 0.0, 0.0 },
    TOP         = { 0.5, 0.0 },
    TOPRIGHT    = { 1.0, 0.0 },
    LEFT        = { 0.0, 0.5 },
    CENTER      = { 0.5, 0.5 },
    RIGHT       = { 1.0, 0.5 },
    BOTTOMLEFT  = { 0.0, 1.0 },
    BOTTOM      = { 0.5, 1.0 },
    BOTTOMRIGHT = { 1.0, 1.0 },
}

local made = {}

function F.Reset() made = {} end

-- ⚠ A GUESS, DECLARED AS ONE. 0.55em per character is a plausible average for the
-- client's default font and it is not measured. Nothing may depend on its VALUE - only
-- on whether a rect changes when it changes, which is exactly what A10.1c asks for.
--
-- ★★★ FACT: a FontString's width is QUANTISED to hRes/2560 device pixels - equivalently
-- GetScreenWidth()/2560 UI units, equivalently ElvUI's E.mult x hRes/2560, where
-- E.mult = 768/(vRes x scale) is one device pixel in UI units. Measured over nine
-- configurations (5 resolutions, 3 aspect ratios, 4 UI scales), worst disagreement 1.0e-07.
-- ★★ FACT: the per-em constant depends on uiScale ALONE - identical to four decimals across
-- four resolutions and three aspect ratios at one scale - and it is NOT smooth in scale
-- (0.64->0.65 jumps 14.608->15.853), so an unmeasured scale must be MEASURED, never
-- interpolated.
--
-- ⚠⚠ REPLACED 2026-08-24. The guess above is now the FALLBACK only - reached when the metric
-- has not been emitted, when a FontString never recorded its font object, or at a uiScale
-- nobody measured. `F.MetricSource()` says which answered. Measured against 660 client wrap
-- cells: line-count agreement went 69.5% -> 92.8-95.6%, consistent across configurations.
--
-- Home: `addons/planning/dungeonrun_interface_inventory.md` -> Constants, sourced (the
-- addon's own authority, and the line `check_sheet.py` parses). Cross-bench: ROUTER.
-- Re-derived from the captures on every run: `py addons\tools\check_sheet.py`.
-- ★★★ THE MEASURED MODEL, IF IT HAS BEEN EMITTED. `addons/tools/emit_text_metric.py` reads
-- the client's own font files out of `locale-enUS.MPQ` and fits a per-font-object linear
-- correction on the sheet's CALIBRATION strings, scored on SPECIMEN strings it never saw.
-- ⚠ Absent, everything below falls back to the declared guess and `F.MetricSource()` says
-- so - a model that silently degraded to a guess would be the worst of both.
local TM = nil
do
    local ok, data = pcall(require, "text_metric_data")
    if ok and type(data) == "table" and data.adv then TM = data end
end

-- Which model answered, so a caller can report it rather than assume the good one.
function F.MetricSource()
    if not TM then return "guess", "#text x size x 0.55 (declared, never measured)" end
    return "measured", ("client fonts + fitted k/c; q = 3*aspect/(10*uiScale), worst %s")
        :format(tostring(TM.qWorstRelative))
end

-- ★★ THE WIDTH QUANTUM, COMPUTED. Tested at 11 configurations over 4 resolutions, worst
-- relative 1.01e-07. ⟶ `GetScreenWidth()` is not needed offline; resolution and uiScale are.
-- ⚠ `F.aspect` defaults to the NOMINAL 16:9. That is the same number the VERTICAL grid uses
-- (UL-10) and it makes the two quanta agree, which is correct on a 16:9 screen and wrong by
-- 0.0123% on his 3620x2036. Set it when the target resolution is known.
F.aspect = 16.0 / 9.0
function F.SetAspect(a) F.aspect = tonumber(a) or (16.0 / 9.0) end

function F.WidthQuantum()
    return 0.3 * (F.aspect or (16.0 / 9.0)) / (F.uiScale or 1.0)
end

-- ★★★ THE FIT IS PER (FONT, uiScale) AND AN UNMEASURED SCALE GETS NO ANSWER. This file's
-- own header has said so since it was written - *"the per-em constant depends on uiScale
-- ALONE ... and it is NOT smooth in scale (0.64->0.65 jumps 14.608->15.853), so an unmeasured
-- scale must be MEASURED, never interpolated"* - and the first emission ignored it, storing one
-- k per font. ⟶ Measured: 46.7% agreement at one configuration, WORSE than the guess it
-- replaced, beside 85.8% and 92.8% at others. **A model right at three scales and wrong at a
-- fourth is more dangerous than one that is evenly mediocre.**
local function fitFor(fontObject)
    local fo = fontObject and TM and TM.fonts[fontObject]
    if not fo or not fo.byScale then return nil end
    local b = fo.byScale[string.format("%.4f", F.uiScale or 1.0)]
    -- ⚠ NO NEAREST-NEIGHBOUR. Returning the closest scale's constants is interpolation
    -- wearing a lookup's clothes, and it is the thing the header forbids by name.
    if not b then return nil end
    return fo, b
end

-- Which scales the emitted metric can actually answer for - so a caller can say "not measured
-- here" instead of discovering it in a residual.
function F.MetricScales(fontObject)
    local fo = fontObject and TM and TM.fonts[fontObject]
    local out = {}
    for s in pairs((fo and fo.byScale) or (TM and TM.fonts
        and select(2, next(TM.fonts)) or {}).byScale or {}) do out[#out + 1] = s end
    table.sort(out)
    return out
end

function F.TextMetric(text, size, fontObject)
    text = tostring(text or "")
    local fo, fit = fitFor(fontObject)
    if not fo then
        -- ⚠ THE DECLARED GUESS, unchanged and still declared. Reached when the metric has
        -- not been emitted, or when a FontString never recorded which font object it is -
        -- the second is a gap in the MODEL, not in the data, and worth finding.
        return #text * (size or 12) * 0.55
    end
    local adv = TM.adv[fo.file]
    if not adv then return #text * (size or 12) * 0.55 end
    local mean = TM.adv[fo.file .. "#mean"] or 0.5
    local em = 0
    for i = 1, #text do
        em = em + (adv[string.byte(text, i)] or mean)
    end
    -- check_sheet's model, verbatim:  quanta = round(em * k) + c
    local quanta = math.floor(em * fit.k + 0.5) + (fit.c or 0)
    return quanta * F.WidthQuantum()
end

-- ★ THE SWEEP'S HANDLE. Give it a different metric, re-run the layout, diff the rects.
function F.SetTextMetric(fn) F.TextMetric = fn end

-- =====================================================================
-- ★★★ THE VERTICAL METRIC - MEASURED, not guessed, and that is the difference.
--
-- `UI_LOG.md` UL-10, from 660 wrap cells over four uiScales at 3620x2036:
--
--     q_v = 1 / (uiScale x 1.875)          constant to 3.0e-07 across 0.64 · 0.82 · 0.86 · 1.0
--     advance = round(size / q_v) x q_v    11 of 11 fonts, worst relative 1.7e-07,
--                                          across TWO font files and four sizes
--
-- ⚠⚠ THIS IS NOT THE FONT METRIC'S TWIN. `F.TextMetric` above is a DECLARED GUESS
-- (`#text x size x 0.55`); the two numbers below are measured against the client and hold
-- to seven figures. ⟶ So a wrapped height is EXACT GIVEN ITS LINE COUNT, and the line
-- count comes from the guess. **The advance is knowledge; the break point is not.**
-- Anything reading a height offline must carry that split rather than average it away.
--
-- ⚠ ONE RESOLUTION. The sweep spanned uiScale at 3620x2036; whether the ratio holds
-- across resolutions is untested, and `check_sheet.py --wrap` prints that line every time.
F.uiScale = 1.0
F.LINE_RATIO = 1.875          -- UL-10, measured. Home: the inventory's Constants, sourced.

function F.SetUIScale(s) F.uiScale = tonumber(s) or 1.0 end

-- The declared size of a font OBJECT, from the emitted table. nil when unknown - callers
-- fall back rather than invent, and `F.MetricSource()` already says which model is live.
function F.FontSize(name)
    local fo = name and TM and TM.fonts[name]
    return fo and fo.size or nil
end

function F.LineAdvance(size)
    local qv = 1.0 / ((F.uiScale or 1.0) * F.LINE_RATIO)
    -- ★ Half-up, matching `check_sheet.py`. ⚠ UNTESTED at a tie: no client font size
    -- divides q_v exactly, so no tie occurs in any capture and half-up vs banker's agree
    -- on every observed row. Marked rather than asserted.
    return math.floor((size or 12) / qv + 0.5) * qv
end

-- ★★ HOW MANY LINES - greedy at spaces, and a token that cannot fit is BROKEN AT THE
-- WIDTH. That last part is measured, not assumed: `supercalifragilisticexpialidocious`
-- came back 3 / 2 / 2 / 1 / 1 / 1 lines at 60 / 96 / 154 / 204 / 244 / 600 (UL-10).
--
-- ⚠ IT INHERITS `F.TextMetric`'s GUESS, entirely and by construction - every decision
-- below is `does this substring fit`, which is the width model. A line count is therefore
-- exactly as trustworthy as the font metric, and `_metricUsed` marks every consumer.
--
-- ⚠ ONE BEHAVIOUR IS UNMEASURED AND IS CHOSEN, NOT KNOWN: when a too-long token arrives
-- with text already on the line, this FLUSHES the line first rather than filling it. No
-- specimen exercises that case. Named here so it is a candidate for the next sheet run
-- rather than an invisible assumption.
function F.WrapLines(text, width, size, fontObject)
    text = tostring(text or "")
    if text == "" then return 0 end
    if not width or width <= 0 then return 1 end

    local function fits(s) return F.TextMetric(s, size, fontObject) <= width end

    local words = {}
    for w in string.gmatch(text, "%S+") do words[#words + 1] = w end
    if #words == 0 then return 1 end

    local lines, cur = 0, nil
    for i = 1, #words do
        local word = words[i]

        while word ~= "" and not fits(word) do
            if cur then lines = lines + 1; cur = nil end     -- the chosen flush, above
            local n = #word
            while n > 1 and not fits(string.sub(word, 1, n)) do n = n - 1 end
            lines = lines + 1
            word = string.sub(word, n + 1)
        end

        if word ~= "" then
            local try = cur and (cur .. " " .. word) or word
            if fits(try) then
                cur = try
            else
                if cur then lines = lines + 1 end
                cur = word
            end
        end
    end
    if cur then lines = lines + 1 end
    return math.max(lines, 1)
end
function F.All() return made end

-- ---------------------------------------------------------------------
-- THE RECORDER
-- ---------------------------------------------------------------------
--
-- ⚠ THE `__index` NO-OP IS THE TRAP THIS BENCH HAS ALREADY BEEN BITTEN BY: it made
-- three §77 assertions unfailable, because every unknown key answered with a
-- callable that returned nothing. It is kept - a stub that errors on an unmodelled
-- call is useless - but it now RECORDS the name, so `F.Unmodelled()` can say what
-- the model was asked for and does not have. ★ Make the hole loud rather than
-- silent; that is the whole difference between a stub and a lie.
local unmodelled = {}

function F.Unmodelled()
    local out = {}
    for k in pairs(unmodelled) do out[#out + 1] = k end
    table.sort(out)
    return out
end

-- ---------------------------------------------------------------------
-- ★★★ TEMPLATES - THE CLIENT'S OWN, NOT OURS (§351)
-- ---------------------------------------------------------------------
--
-- ⚠⚠ THIS FILE'S OWN HEADER SAID WE DID NOT NEED THIS: *"WoW UI Designer had to
-- resolve XML template inheritance, pull textures out of the MPQs... We have none of
-- that: COA_DungeonRun is fourteen .lua files and zero XML."* ★ TRUE ABOUT OUR FILES
-- AND WRONG ABOUT OUR FRAMES. `object.lua` builds 26 buttons, 12 edit boxes, 8
-- dropdowns and 8 check buttons `CreateFrame(..., TEMPLATE)` - and the template is
-- where their real size lives. We had no XML of our own and were using Blizzard's all
-- along, with the fourth argument dropped on the floor.
--
-- ★★ SO EVERY TEMPLATED CONTROL HAS BEEN MEASURED OFFLINE AS A SIZELESS BOX, and the
-- overlap checker has never seen one at its true size.
--
-- ★ AND THE TEMPLATES ARE READ, NEVER MODELLED. `addons/tools/read_templates.py` pulls
-- them out of the MPQ chain (patch-B, patch-X) into a generated table. A hand-written
-- UIPanelButtonTemplate would be a creator dialect - right until Blizzard's numbers and
-- ours disagree, with nothing to notice when they do.
--
-- ⚠ MISSING IS LOUD, NEVER ZERO. If the generated table is absent, a templated frame
-- records the template name as unresolved and `F.TemplateHoles()` reports it. Same law
-- as an unresolved anchor: this may REPORT, never assume.
local TPL, TPL_STATE = nil, "unread"
local tplHoles = {}

local function templates()
    if TPL ~= nil or TPL_STATE == "absent" then return TPL end
    local path = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\staging\framexml_templates.lua]]
    local chunk = loadfile(path)
    if not chunk then TPL_STATE = "absent"; return nil end
    local ok, t = pcall(chunk)
    if ok and type(t) == "table" then TPL, TPL_STATE = t, "read" else TPL_STATE = "absent" end
    return TPL
end

function F.TemplateHoles()
    local out = {}
    for k, v in pairs(tplHoles) do out[#out + 1] = ("%s (%dx)"):format(k, v) end
    table.sort(out)
    return out, TPL_STATE
end

-- ⚠ INHERITS IS A CHAIN, and the parent's regions come FIRST so a child overriding a
-- size wins. Depth-capped because a malformed chain must not hang the suite.
local function resolve(tname, depth)
    local t = templates()
    if not t or not tname then return nil end
    local def = t[tname]
    if not def then return nil end
    if not def.inherits or (depth or 0) > 8 then return def end
    local base = resolve(def.inherits, (depth or 0) + 1)
    if not base then return def end
    local merged = { w = def.w or base.w, h = def.h or base.h,
                     kind = def.kind or base.kind, regions = {} }
    for _, r in ipairs(base.regions or {}) do merged.regions[#merged.regions + 1] = r end
    for _, r in ipairs(def.regions or {}) do merged.regions[#merged.regions + 1] = r end
    return merged
end

function F.New(name, parent, template)
    local f = {
        _name = name or ("frame#" .. tostring(#made + 1)),
        _parent = parent,
        _points = {},
        _shown = true,          -- the client's default for a created frame
        _scripts = {},
    }

    -- ★★★ A METHOD AND A DATA FIELD ARE NOT THE SAME HOLE (§356).
    --
    -- The catch-all handed back `function() end` for EVERY unknown key. For a method
    -- that is a useful stub. ⚠ For a DATA field it is a lie with teeth: AceGUI reads
    -- `frame.width` and compares it to a number, and a function compares to nothing.
    -- That is exactly what stopped A10.1's frame - `attempt to compare function with
    -- number` inside Blizzard's own TabResize - and I misread it as an argument-order
    -- divergence between r960 and this client. It was neither; it was this line.
    --
    -- ★ THE SPLIT IS THE CLIENT'S OWN CONVENTION: frame METHODS are PascalCase
    -- (`GetWidth`, `SetPoint`), frame DATA is lowercase (`width`, `selected`, `obj`).
    -- So an uppercase-initial key answers with a method stub; anything else answers
    -- `nil`, which is what an unset field IS. Both are still recorded, so neither hole
    -- goes quiet.
    setmetatable(f, { __index = function(_, k)
        if type(k) == "string" and k:sub(1, 1) == "_" then return nil end
        unmodelled[tostring(k)] = true
        if type(k) == "string" and k:match("^%u") then return function() end end
        return nil
    end })

    -- ★★ THE FIVE THAT CARRY GEOMETRY. Everything above is scaffolding; these are
    -- the reason the file exists.
    function f:ClearAllPoints() self._points = {} end

    -- ⚠ THE ARGUMENT FORMS ARE THE CLIENT'S, and they are positional and overloaded:
    --     SetPoint(p)                          -> parent, same point, 0, 0
    --     SetPoint(p, x, y)                    -> parent, same point
    --     SetPoint(p, rel)                     -> same point, 0, 0
    --     SetPoint(p, rel, x, y)               -> same point
    --     SetPoint(p, rel, relPoint, x, y)     -> the full form
    -- Getting this parse wrong would produce confidently wrong rects, which is the
    -- failure mode this whole file must not have - so each form is asserted in
    -- `smoke_frames.lua` against a hand-computed answer.
    function f:SetPoint(point, a2, a3, a4, a5)
        local rel, relPoint, x, y
        if type(a2) == "number" or a2 == nil then
            rel, relPoint, x, y = self._parent, point, a2 or 0, a3 or 0
        elseif type(a2) == "table" then
            rel = a2
            if type(a3) == "string" then
                relPoint, x, y = a3, a4 or 0, a5 or 0
            else
                relPoint, x, y = point, a3 or 0, a4 or 0
            end
        else
            -- ⚠ A STRING relativeTo is a GLOBAL FRAME NAME in the client, and this
            -- side has no global frame table. Recorded as unresolvable WITH ITS
            -- REASON rather than silently anchored to the parent.
            self._points[#self._points + 1] =
                { point = point, byName = tostring(a2) }
            return
        end
        self._points[#self._points + 1] =
            { point = point, rel = rel, relPoint = relPoint, x = x, y = y }
    end

    function f:SetWidth(w) self._w = w end
    function f:SetHeight(h) self._h = h end
    function f:SetSize(w, h) self._w, self._h = w, h end

    -- ⚠⚠ AN UNSIZED FONTSTRING SIZES TO ITS TEXT, and this is not a convenience - it
    -- is what the client does, and Blizzard's own code depends on it:
    --
    --     PanelTemplates_TabResize:  textWidth = tabText:GetWidth()
    --
    -- ★ Note it is `GetWidth`, not `GetStringWidth`. Returning nil here is what stopped
    -- A10.1's frame at UIPanelTemplates.lua:65 - arithmetic on a nil. A model that
    -- returns nil where the client returns a number is not a conservative model; it is
    -- a different one.
    --
    -- ⚠ THE VALUE IS A GUESS AND IS DECLARED AS ONE (`F.TextMetric`). Nothing may depend
    -- on the number - only on whether a rect MOVES when the metric changes, which is
    -- A10.1c's sweep.
    function f:GetWidth()
        if self._w then return self._w end
        if self._isFontString and self._text and self._text ~= "" then
            -- ★★★ MARK THE CONSUMER. A10.1c wants "N verified · M unverifiable BY
            -- NAME", and a before/after diff cannot produce it: the client's own
            -- TabResize does `tabText:SetWidth(w)` on the first layout, so the guessed
            -- width is BAKED and a second pass re-derives nothing. ⚠ A rect frozen from
            -- a guess is not verified - it is a guess that stopped moving.
            -- ★ So the metric records who asked. That is the honest list.
            self._metricUsed = true
            return F.TextMetric(self._text, self:_size(), self._fontobject)
        end
        -- ★★★ AN UNSIZED FRAME ANSWERS 0, BECAUSE THE CLIENT DOES. This file already
        -- argues it one branch up for FontStrings - *"a model that returns nil where the
        -- client returns a number is not a conservative model; it is a DIFFERENT one"* -
        -- and the same sentence is true here. ⚠ Returning nil cost `AceGUIWidget-DropDown`
        -- at :138 (`viewheight < height` → *attempt to compare number with nil*), which took
        -- the whole widget out of the offline render, and dropdowns are what this design is
        -- made of: sense · action · Next.
        --
        -- ⚠⚠ AND IT IS A MODELLED ANSWER, NOT A MEASURED ONE - marked, exactly as the font
        -- metric is. **The client resolves a height from opposing anchors and from content;
        -- this accessor does neither.** So `Ace`'s accumulating layouts
        -- (`CheckBox:94`, `DropDown:243` do arithmetic straight onto this) now produce a
        -- SHAPE rather than a measurement. ⟶ Nothing may depend on the NUMBER - only on
        -- whether a rect MOVES, which is the same rule the font boundary carries.
        --
        -- ★ `_w` / `_h` STAY NIL. The rect builder reads the FIELDS directly and derives a
        -- size from two opposing anchors; answering 0 there would destroy that. Only the
        -- ACCESSOR is client-faithful.
        self._zeroSized = true
        return 0
    end
    function f:GetHeight()
        if self._h then return self._h end
        if self._isFontString and self._text and self._text ~= "" then
            -- ★★★ THIS IS THE ACCESSOR ACEGUI ACTUALLY USES, and finding that out is what
            -- Battlewrath's *"keep checking Ace as it may already express how it handles
            -- your questions"* was for. `grep GetStringHeight Libs/AceGUI-3.0` returns
            -- NOTHING; `AceGUIWidget-Label.lua:52-54` does
            --     label:SetWidth(width)  ->  height = label:GetHeight()  ->  frame:SetHeight(height)
            -- ⟶ Label IS the measured-height cell AL-45 ruled. The library already
            -- expresses the answer; what it lacked offline was a height that respects a
            -- SetWidth. It returned the font SIZE, one line, always - so every wrapping
            -- label was modelled a line tall and F·29's collision was invisible here.
            --
            -- ⚠ TWO NUMBERS OF DIFFERENT STANDING, MULTIPLIED. The advance is MEASURED
            -- (UL-10, 1.7e-07); the line count comes from `F.TextMetric`'s declared guess.
            -- So this is a modelled number and `_metricUsed` marks it, exactly as the
            -- width branch does - nothing may depend on the VALUE, only on whether a rect
            -- MOVES when the metric changes.
            self._metricUsed = true
            local size = self:_size()
            local n = self._w and F.WrapLines(self._text, self._w, size, self._fontobject) or 1
            return n * F.LineAdvance(size)
        end
        self._zeroSized = true
        return 0
    end
    -- ★★ FRAME LEVEL, MODELLED - the client never answers nil here. `AceGUIWidget-
    -- DropDown:458` does `self.frame:GetFrameLevel() + 1`, so a no-op catch-all took the
    -- widget out of the offline render entirely. ⚠ The default is the PARENT'S + 1, which
    -- is what the client does and what `fixlevels` on the next line then walks.
    -- ★ Nothing here draws, so the level is only ever a NUMBER that must exist and order
    -- correctly - modelling more than that would be inventing behaviour we cannot check.
    function f:SetFrameLevel(n) self._level = tonumber(n) or self._level end
    function f:GetFrameLevel()
        if self._level then return self._level end
        local p = self._parent
        if p and p.GetFrameLevel then return p:GetFrameLevel() + 1 end
        return 1
    end

    function f:GetNumPoints() return #self._points end

    function f:Show() self._shown = true end
    function f:Hide() self._shown = false end
    function f:IsShown() return self._shown end

    -- ★★★ THE TEXT METRIC - THE ONE THING WE CANNOT READ FROM THE CLIENT (A10.1c).
    --
    -- Templates gave us Blizzard's explicit sizes; FrameXML gave us Blizzard's code. A
    -- FontString's WIDTH is neither - it comes from the text and a font file rendered by
    -- a renderer we are not. ⚠ And it is not academic: the first thing that stopped
    -- A10.1's frame building was Blizzard's own `PanelTemplates_TabResize` at
    -- UIPanelTemplates.lua:65, arithmetic on a nil `textWidth`.
    --
    -- ★★ WHICH IS THE ARGUMENT FOR RUNNING THE CLIENT'S CODE RATHER THAN STUBBING IT: a
    -- TabResize of our own would have picked a width and the blind spot would be
    -- invisible. Blizzard's own arithmetic ANNOUNCED it, at a named line.
    --
    -- ★ SO THE METRIC IS PLUGGABLE ON PURPOSE. A10.1c's sweep is then one line: change
    -- the metric, re-run, and every rect that MOVED is unverifiable - by name. A rect
    -- that does not move is verified offline no matter what the real font does.
    function f:GetStringWidth()
        return F.TextMetric(self._text or "", self:_size(), self._fontobject)
    end
    -- ★★★ BOTH ACCESSORS, BECAUSE THE TWO ACEGUI COPIES ON THIS CLIENT DISAGREE ABOUT
    -- WHICH ONE TO ASK - and `prior_art_ace_field_2026-08-21.md` had already flagged the
    -- version gap as UNVERIFIED before this was checked:
    --
    --     r33  (ours, COA_DungeonRun/Libs)      Label.lua:54   height = label:GetHeight()
    --     r41  (AI_VoiceOver/Libs)              Label.lua:58   height = label:GetStringHeight()
    --
    -- ⚠⚠ AND r41 IS THE ONE LIKELY TO RUN. LibStub keeps the highest minor; ElvUI renames
    -- its copy so does not contend, but AI_VoiceOver's does NOT rename and wins both AceGUI
    -- (41) and AceConfigDialog (78). ⟶ A model that answered only `GetHeight` would be
    -- calibrated against the copy that does NOT run. Answer both, through one path.
    -- ⚠ NOT a delegation to `GetHeight`, and the difference is the client's. `GetHeight`
    -- answers the REGION's height and short-circuits on an explicitly set one; a
    -- FontString sized by hand still reports its TEXT's height here. Routing one to the
    -- other would make `SetHeight` silently change what the text measures.
    function f:GetStringHeight()
        if not (self._text and self._text ~= "") then return 0 end
        self._metricUsed = true
        local size = self:_size()
        local n = self._w and F.WrapLines(self._text, self._w, size, self._fontobject) or 1
        return n * F.LineAdvance(size)
    end

    -- ★ A BUTTON'S SetText GOES TO ITS TEMPLATE'S ButtonText, which is what the
    -- client does and what `_G[tabName.."Text"]:GetWidth()` then reads. Keeping the
    -- string only on the button would leave the region empty and its width nil - the
    -- second half of the same UIPanelTemplates.lua:65 fault.
    function f:SetText(t)
        self._text = t
        if self._fontstring then self._fontstring._text = t end
    end
    function f:GetText() return self._text end
    function f:GetName() return self._name end

    function f:SetScript(e, fn) self._scripts[e] = fn end
    function f:GetScript(e) return self._scripts[e] end

    -- ⚠ THE AUTO-NAME MUST BE UNIQUE. The first cut named every FontString
    -- `pane.fs`, and the audit's measure-these list came back with the same name
    -- twice - a shopping list that cannot say WHICH label is not a shopping list.
    -- Nameless widgets are the norm in this pane, so the fallback has to carry its
    -- own ordinal rather than assume someone passed a name.
    function f:CreateTexture(n)
        return F.New(n or ("%s.tex%d"):format(self._name, #made + 1), self)
    end
    -- ★★★ RECORD THE FONT OBJECT. It was DISCARDED before - `CreateFontString(n)` took one
    -- argument and dropped the layer and the template - so every FontString in the model was
    -- an anonymous size-12 string and the measured metric had nothing to look up. ⟶ The
    -- per-glyph table is useless without this line; the width model was blind on the wrong
    -- side of the call.
    function f:CreateFontString(n, layer, fontObject)
        local fs = F.New(n or ("%s.fs%d"):format(self._name, #made + 1), self)
        fs._isFontString = true
        fs:SetFontObject(fontObject)
        return fs
    end
    -- ★★★ SetParent WAS A NO-OP, ANSWERED BY THE CATCH-ALL - and the tree walk keys
    -- on `_parent`. So every frame AceGUI re-parented after construction sat in the
    -- WRONG PLACE in our tree, silently, and `F.OverlapsTree` compared it against the
    -- wrong siblings. ⚠ AceGUI re-parents constantly (every widget it recycles from its
    -- pool), so this was not an edge case; it was most of the tree.
    -- ★ Found because seating the map asserted where the map ENDED UP, rather than that
    -- the call had been made.
    function f:SetParent(p) self._parent = p end
    function f:GetParent() return self._parent end

    -- ★ The font object is a NAME here, because that is what the emitted table keys on and
    -- what the client's own `CreateFontString(nil, "OVERLAY", "GameFontNormal")` passes.
    -- ⚠ A table (the client also accepts a Font OBJECT) is accepted and recorded as unknown
    -- rather than coerced - a wrong key would silently pick another font's metrics.
    function f:SetFontObject(fo)
        if type(fo) == "string" then self._fontobject = fo end
        return self
    end
    function f:GetFontObject() return self._fontobject end

    -- The size the metric should use: the emitted table's, else whatever was set, else 12.
    function f:_size()
        local fo = self._fontobject and F.FontSize and F.FontSize(self._fontobject)
        return fo or self._fontsize or 12
    end

    -- ★ APPLY THE TEMPLATE. This runs at CONSTRUCTION, before the caller can size
    -- anything, so the template supplies the DEFAULT and a later SetWidth simply
    -- overwrites it - which is the client's own order of events.
    if template and template ~= "" then
        local names = {}
        for one in tostring(template):gmatch("[^,%s]+") do names[#names + 1] = one end
        local applied = false
        for _, tn in ipairs(names) do
            local def = resolve(tn, 0)
            if def then
                applied = true
                if f._w == nil then f._w = def.w end
                if f._h == nil then f._h = def.h end
                for _, r in ipairs(def.regions or {}) do
                    -- ⚠ `$parent` IS THE CLIENT'S OWN SUBSTITUTION, and it is the whole
                    -- reason a widget can find its parts: AceGUI's Button asks for
                    -- GetFontString(), its DropDown asks for _G[name.."Middle"].
                    local rn = tostring(r.name):gsub("%$parent", f._name or "frame")
                    local child = F.New(rn, f)
                    child._w, child._h = r.w, r.h
                    -- ★ FROM THE TEMPLATE'S OWN `<FontString>` / `<ButtonText>` tag, so
                    -- the flag is read rather than inferred from a naming convention.
                    if r.kind == "fontstring" then child._isFontString = true end
                    for _, a in ipairs(r.anchors or {}) do
                        child:SetPoint(a.point, f, a.relPoint ~= "" and a.relPoint or a.point,
                                       a.x or 0, a.y or 0)
                    end
                    f._regions = f._regions or {}
                    f._regions[#f._regions + 1] = child
                    if r.buttontext then f._fontstring = child end
                    -- ★ AND IT GOES IN _G UNDER ITS RESOLVED NAME, because that is
                    -- exactly where the widget looks: _G[name .. "Middle"].
                    if rn and rn ~= "" then rawset(_G, rn, child) end
                end
            end
        end
        if not applied then
            tplHoles[tostring(template)] = (tplHoles[tostring(template)] or 0) + 1
        end
    end

    function f:GetFontString() return self._fontstring end
    function f:GetRegions() return unpack(self._regions or {}) end

    made[#made + 1] = f
    return f
end

-- ★ A ROOT is a frame whose rect is GIVEN rather than derived - the pane itself, or
-- UIParent. Every resolution walks up until it reaches one, so exactly one frame in
-- any tree has to be told where it is.
function F.SetRoot(f, w, h, left, top)
    f._root = { left = left or 0, top = top or 0, w = w, h = h }
    return f
end

-- ---------------------------------------------------------------------
-- ★★★ THE RESOLVER: an anchor graph in, absolute rects out
-- ---------------------------------------------------------------------
--
-- ⚠ IT RETURNS A REASON, NOT A ZERO. Every path that cannot produce a rect returns
-- `nil, why` - an unanchored frame, a cycle, a name-anchor, a size nobody set. A
-- resolver that quietly answers 0 for those is exactly the confident liar this must
-- not be, and the caller can tell "at the origin" from "no idea" only if we say so.

-- ⚠⚠ AN EDGE CAN BE KNOWN WHILE THE SIZE IS NOT, and missing that CRASHED the first
-- cut. A mutation found it: anchor a control to an unsized FontString and the
-- resolver did arithmetic on a nil width. ★ That is not an exotic case - it is the
-- ordinary WoW idiom, and the exact thing Ascension's own `AddonPanelTemplate` does
-- (`Value` anchored to `$parentHeader`'s BOTTOMLEFT).
--
-- ★★ SO EACH EDGE IS ASKED FOR SEPARATELY. A left edge needs `left`, a right edge
-- needs `right`, and only a CENTRED point needs the size. A label of unknown width
-- still has a known left edge if that is where its own anchor sits - true, not
-- invented - so the common case resolves and only the genuinely unknowable refuses.
local function anchorAbs(rect, relPoint)
    local frac = PT[relPoint]
    if not frac then return nil, "unknown point: " .. tostring(relPoint) end

    local x
    if frac[1] == 0 then x = rect.left
    elseif frac[1] == 1 then x = rect.right
    elseif rect.left and rect.w then x = rect.left + frac[1] * rect.w end

    local y
    if frac[2] == 0 then y = rect.top
    elseif frac[2] == 1 then y = rect.bottom
    elseif rect.top and rect.h then y = rect.top - frac[2] * rect.h end

    if not x then
        return nil, ("%s: no known x for %s"):format(tostring(rect.name), relPoint)
    end
    if not y then
        return nil, ("%s: no known y for %s"):format(tostring(rect.name), relPoint)
    end
    return x, y
end

function F.Rect(f, seen)
    if not f then return nil, "no frame" end
    if f._root then
        local r = f._root
        -- ★ MARKED AS THE CONTAINER, because it is not a row. The first audit run
        -- put the 280x400 pane into the row analysis and produced a -164 "gap"
        -- between the last control and the frame it sits inside - a number that
        -- means nothing and reads like a bug.
        return { left = r.left, top = r.top, w = r.w, h = r.h,
                 right = r.left + r.w, bottom = r.top - r.h,
                 name = f._name, shown = true, root = true }
    end

    seen = seen or {}
    -- ⚠ A CYCLE IS A REAL AUTHORING MISTAKE (a anchored to b, b anchored to a) and
    -- in the client it is a silent layout failure. Here it names both ends.
    if seen[f] then return nil, "anchor cycle at " .. tostring(f._name) end
    seen[f] = true

    local pts = f._points
    if #pts == 0 then return nil, "unanchored: " .. tostring(f._name) end
    for _, p in ipairs(pts) do
        if p.byName then
            return nil, ("anchored by NAME (%s) - no global frame table offline")
                :format(p.byName)
        end
        if not PT[p.point] then
            return nil, "unknown point: " .. tostring(p.point)
        end
    end

    -- Resolve every anchor to an absolute position first; the rect falls out after.
    local abs = {}
    for i, p in ipairs(pts) do
        local rrect, why = F.Rect(p.rel, seen)
        if not rrect then
            return nil, ("%s: anchor %d -> %s"):format(f._name, i, why or "unresolved")
        end
        -- ⚠ The second return is the POSITION on success and the REASON on failure,
        -- so it is named for what it is rather than read as a y that might be a
        -- string - the kind of quiet type slip this file cannot afford.
        local ax, ayOrWhy = anchorAbs(rrect, p.relPoint)
        if not ax then
            return nil, ("%s: anchor %d -> %s"):format(f._name, i, tostring(ayOrWhy))
        end
        abs[i] = { x = ax + p.x, y = ayOrWhy + p.y, frac = PT[p.point] }
    end

    local w, h = f._w, f._h

    -- ★★ TWO OPPOSING ANCHORS DEFINE A SIZE - that is the client's own idiom and
    -- Ascension's `AddonPanelTemplate` uses it (TOPLEFT + BOTTOMRIGHT). ⚠ But only
    -- on the axis where the two points actually DIFFER: TOPLEFT + BOTTOMLEFT fixes
    -- the height and says nothing about the width, so each axis is decided
    -- separately rather than assuming a pair is always a full box.
    if #abs >= 2 then
        local a, b = abs[1], abs[2]
        if a.frac[1] ~= b.frac[1] then
            w = (b.x - a.x) / (b.frac[1] - a.frac[1])
        end
        if a.frac[2] ~= b.frac[2] then
            h = (a.y - b.y) / (b.frac[2] - a.frac[2])
        end
    end

    -- ⚠⚠ THE FONT BOUNDARY, AND IT IS DELIBERATELY A HOLE. A FontString sized by its
    -- text has no width offline and we will not invent one. This is the exact place
    -- WoW UI Designer chose to approximate and got wrong; we have the client on
    -- access, so the honest move is to name it and measure it once.
    local a = abs[1]
    local rect = { anchors = #abs }
    if w then
        rect.left = a.x - a.frac[1] * w
        rect.right = rect.left + w
        rect.w = w
    else
        rect.unknownW = true
        -- ★★ ONE EDGE IS STILL KNOWN, and it is a FACT rather than a fallback: a
        -- label anchored by its TOPLEFT has its left edge exactly there, whatever
        -- its text turns out to measure. Recording it is what lets the ordinary
        -- "next control sits at this label's left" resolve while the width stays
        -- honestly unknown.
        if a.frac[1] == 0 then rect.left = a.x
        elseif a.frac[1] == 1 then rect.right = a.x end
    end
    if h then
        rect.top = a.y + a.frac[2] * h
        rect.bottom = rect.top - h
        rect.h = h
    else
        rect.unknownH = true
        if a.frac[2] == 0 then rect.top = a.y
        elseif a.frac[2] == 1 then rect.bottom = a.y end
    end

    -- ★ An unsized frame still knows WHERE ITS ANCHOR IS, and that is worth keeping:
    -- it is enough to order rows top-to-bottom even when the extent is unknown.
    rect.anchorX, rect.anchorY = a.x, a.y
    -- ★ `what` wins if the caller set one. `layout.lua` tags its rules and headers
    -- that way because it cannot NAME them without creating a global.
    --
    -- ⚠⚠ `rawget`, AND THE PLAIN READ BIT ME IN THIS VERY FILE. `f.what` goes through
    -- the `__index` no-op, which hands back a FUNCTION for every unknown key - so
    -- every unnamed widget was called `function: 0000000000C78100`. That is the same
    -- trap that made three §77 assertions unfailable, and it catches DATA reads just
    -- as happily as method calls. `harness.lua` uses rawget for exactly this reason.
    rect.name = rawget(f, "what") or f._name
    rect.shown = f._shown and true or false
    return rect
end

-- ---------------------------------------------------------------------
-- THE CHECKS - the two bugs, as arithmetic
-- ---------------------------------------------------------------------
--
-- ⚠ HIDDEN FRAMES ARE EXCLUDED, and that is the point rather than an oversight: a
-- zone hidden for this subject is not on screen, so it cannot overlap anything. It
-- is also why the ORPHAN is caught - `behaviour` was never hidden by anything, so
-- it is present in every subject state and collides in the ones it does not belong
-- to.
-- ⚠ AND THE CONTAINER IS NOT A PEER. Marking the root so the audit could exclude it
-- from the row report made it eligible here, and every single child then "overlapped"
-- the pane it lives inside. ★ A frame contains its children BY DEFINITION - that is
-- what `Outside` measures, and treating it as a sibling makes both checks useless at
-- once.
local function usable(r)
    return r and r.shown and not r.root and not r.unknownW and not r.unknownH
        and r.w and r.h and r.w > 0 and r.h > 0
end

function F.Resolve(list)
    local out, holes = {}, {}
    for _, f in ipairs(list) do
        local r, why = F.Rect(f)
        if r then out[#out + 1] = r
        else holes[#holes + 1] = { name = f._name, why = why } end
    end
    return out, holes
end

-- ★★★ THE SHOPPING LIST FOR THE CLIENT, AND IT WRITES ITSELF. Every rect whose size
-- nobody set is a thing only the client can measure - overwhelmingly a FontString
-- sized by its text. ⚠ This is the output that makes the offline pass and the live
-- pass one loop rather than two: the offline run says exactly what to measure, one
-- client run measures it, and the numbers come back as constants.
function F.Unmeasured(rects)
    local out = {}
    for _, r in ipairs(rects) do
        if r.shown and (r.unknownW or r.unknownH) then
            out[#out + 1] = {
                name = r.name,
                need = (r.unknownW and r.unknownH and "width+height")
                    or (r.unknownW and "width") or "height",
            }
        end
    end
    return out
end

-- ★ Strict intersection: sharing an EDGE is not an overlap. Rows that stack flush
-- are ordinary, and flagging them would make the check unusable on its first run.
function F.Overlaps(rects)
    local hits = {}
    for i = 1, #rects do
        for j = i + 1, #rects do
            local a, b = rects[i], rects[j]
            if usable(a) and usable(b) then
                if a.left < b.right and b.left < a.right
                   and a.bottom < b.top and b.bottom < a.top then
                    hits[#hits + 1] = {
                        a = a.name, b = b.name,
                        x = math.min(a.right, b.right) - math.max(a.left, b.left),
                        y = math.min(a.top, b.top) - math.max(a.bottom, b.bottom),
                    }
                end
            end
        end
    end
    return hits
end

-- ★★ THE CLIPPED BUTTON, as a function. `outside` is any edge beyond the container -
-- which is what x=208 + a 52-wide button on a 280-wide frame IS, and nothing we
-- owned could say so.
function F.Outside(rects, box)
    local bad = {}
    for _, r in ipairs(rects) do
        if usable(r) then
            local over = {}
            if r.left < box.left then over[#over + 1] = ("left by %.0f"):format(box.left - r.left) end
            if r.right > box.right then over[#over + 1] = ("right by %.0f"):format(r.right - box.right) end
            if r.top > box.top then over[#over + 1] = ("top by %.0f"):format(r.top - box.top) end
            if r.bottom < box.bottom then over[#over + 1] = ("bottom by %.0f"):format(box.bottom - r.bottom) end
            if #over > 0 then
                bad[#bad + 1] = { name = r.name, over = table.concat(over, ", ") }
            end
        end
    end
    return bad
end

-- ---------------------------------------------------------------------
-- ★ EMIT - the repo half reads this with `lua_table.py`, exactly as it reads
-- SavedVariables. Same parser, no second format to keep in step.
-- ---------------------------------------------------------------------
local function num(v) return v and ("%.2f"):format(v) or "nil" end


-- ---------------------------------------------------------------------
-- ★★★ A NESTED FRAME TREE (A10.1c) - and why the flat check stops being enough
-- ---------------------------------------------------------------------
--
-- `F.Overlaps` compares a flat list all-pairs. That was right while every control was a
-- direct child of one pane. ⚠ Ace nests: frame → TabGroup → group → widget → the
-- widget's own template regions. A CHILD INSIDE ITS CONTAINER IS NOT AN OVERLAP, but
-- all-pairs over a flattened tree calls it one, and the report drowns in them.
--
-- ★ So the acceptance (bench U2, (a)) is SIBLINGS ONLY, RECURSIVELY - compare within
-- each parent, walk down - and the Analyst added the half I had not asked for:
-- CONTAINMENT, every child within its parent's rect, because a CLIPPED widget is a
-- fault and siblings-only alone would never see one.
--
-- ⚠ The tree is built from `made` by grouping on `_parent`, so nothing about frame
-- construction changes to support this. A frame that never got a parent is a root.

function F.Children(f)
    local out = {}
    for _, m in ipairs(made) do
        if m._parent == f then out[#out + 1] = m end
    end
    return out
end

-- ★ Every parent that HAS children, in construction order, so a report reads in the
-- order the pane was built rather than in hash order.
local function eachParent(root, fn, seen)
    seen = seen or {}
    if seen[root] then return end          -- ⚠ a cycle must not hang the suite
    seen[root] = true
    local kids = F.Children(root)
    if #kids > 0 then fn(root, kids) end
    for _, k in ipairs(kids) do eachParent(k, fn, seen) end
end

-- ★ HOW MANY PARENTS THE WALK ACTUALLY REACHES - and it uses `eachParent`, the same
-- walker `F.OverlapsTree` uses. ⚠ My first version of this assertion had its OWN
-- recursive counter in the smoke, so breaking the real walk left it green: a test of a
-- different walker than the one being checked. The mutation caught it as `!! SILENT`.
function F.ParentCount(root)
    local n = 0
    eachParent(root, function() n = n + 1 end)
    return n
end

-- SIBLINGS ONLY, RECURSIVELY. Returns the same shape `F.Overlaps` does, with the
-- parent named on each hit - "two things overlap" is not actionable without knowing
-- which container they were being laid out in.
function F.OverlapsTree(root)
    local hits = {}
    eachParent(root, function(parent, kids)
        local rects = F.Resolve(kids)
        for _, h in ipairs(F.Overlaps(rects)) do
            h.parent = parent._name
            hits[#hits + 1] = h
        end
    end)
    return hits
end

-- ★★ CONTAINMENT - the Analyst's addition, and it catches what siblings-only cannot.
--
-- ⚠ REPORTED WITH ITS OVERHANG, never as a bare boolean. "Clipped" is a spectrum: a
-- widget one pixel out is a rounding artefact and one 200px out is a layout fault, and
-- a check that cannot tell them apart gets muted rather than fixed.
function F.Containment(root)
    local out = {}
    eachParent(root, function(parent, kids)
        local pr = F.Rect(parent)
        if not (pr and pr.w and pr.h and pr.w > 0 and pr.h > 0) then return end
        for _, kid in ipairs(kids) do
            local kr = F.Rect(kid)
            if kr and kr.w and kr.h and kr.shown and kr.w > 0 and kr.h > 0 then
                local dx = math.max(pr.left - kr.left, kr.right - pr.right, 0)
                local dy = math.max(pr.bottom - kr.bottom, kr.top - pr.top, 0)
                if dx > 0 or dy > 0 then
                    out[#out + 1] = { child = kr.name, parent = pr.name, x = dx, y = dy }
                end
            end
        end
    end)
    return out
end

-- ---------------------------------------------------------------------
-- ★★★ THE TEXT-METRIC SWEEP (A10.1c) - a checker that knows its own reach
-- ---------------------------------------------------------------------
--
-- An offline checker cannot compute `GetStringWidth` on a font it does not have. §3 of
-- the UI scope calls that a permanent hole in EVERY option, B and C included - true,
-- and "hole" is the wrong shape. Most regions carry an explicit size from the client's
-- own templates; measurement only decides the ones that AUTO-SIZE.
--
-- ★ So the boundary is measurable rather than argued: build the frame, change the
-- metric, build it again. **A rect that MOVED depends on text measurement and is
-- unverifiable. A rect that did not is verified offline whatever the real font does.**
-- The output is a LIST, by name, instead of a caveat.
--
-- ⚠⚠ IT RE-LAYS OUT, IT DOES NOT REBUILD - and the first cut got that wrong. I called
-- `F.Reset()` between passes and rebuilt the frame, which produced 9 rects and ZERO
-- movement even under a 40px-per-character metric. ★ AceGUI RECYCLES its widget pool:
-- clearing our own list does not make it construct anything new, so the second pass was
-- measuring the first pass's frames. My own "can the sweep see a move" guard caught it.
--
-- ★ And re-laying out is the truer question anyway. We are not asking "would a fresh
-- build differ" - we are asking **does THIS rect depend on text measurement**, and the
-- way to find out is to change the metric under the frame that already exists.
-- ★ WHO CONSUMED A TEXT METRIC. ⚠⚠ DIRECT CONSUMERS ONLY, and that limit is stated
-- rather than hidden: a container sized FROM one of these is also unverifiable and this
-- does not trace it. The list is a floor on the blind spot, never a ceiling.
-- ⚠ THE SECOND HOLE'S OWN LIST. A frame whose size was ANSWERED AS 0 rather than
-- measured - the honest counterpart to `MetricConsumers`, so the ceiling is reportable
-- instead of silent. ★ A10.1c wants *"N verified · M unverifiable BY NAME"*; this is the
-- other M.
function F.ZeroSizedConsumers()
    local out = {}
    for _, m in ipairs(made) do
        if m._zeroSized then out[#out + 1] = m._name or "?" end
    end
    table.sort(out)
    return out
end

function F.MetricConsumers()
    local out = {}
    for _, m in ipairs(made) do
        if m._metricUsed then out[#out + 1] = m._name or "?" end
    end
    table.sort(out)
    return out
end

function F.MetricSweep(build, alt)
    local function snap()
        local by = {}
        for _, m in ipairs(made) do
            local r = F.Rect(m)
            if r and r.name then
                by[r.name] = { r.left, r.top, r.w, r.h }
            end
        end
        return by
    end

    local saved = F.TextMetric
    build()
    local a = snap()

    F.SetTextMetric(alt or function(text, size)
        -- ⚠ A DIFFERENT metric, not a broken one: still monotonic in length, so a rect
        -- that moves does so because it MEASURES text, not because the stub returned
        -- something absurd that would move everything.
        return #tostring(text) * (size or 12) * 0.95
    end)
    build()
    local b = snap()
    F.SetTextMetric(saved)

    local moved, fixed = {}, {}
    for name, ra in pairs(a) do
        local rb = b[name]
        if rb then
            local same = ra[1] == rb[1] and ra[2] == rb[2]
                     and ra[3] == rb[3] and ra[4] == rb[4]
            if same then fixed[#fixed + 1] = name else moved[#moved + 1] = name end
        end
    end
    table.sort(moved); table.sort(fixed)
    return fixed, moved
end

function F.Emit(path, rects, holes)
    local fh, err = io.open(path, "wb")
    if not fh then return nil, err end
    fh:write("PaneRects = {\n")
    fh:write("\t[\"rects\"] = {\n")
    for i, r in ipairs(rects) do
        fh:write(("\t\t[%d] = {\n"):format(i))
        fh:write(("\t\t\t[\"name\"] = \"%s\",\n"):format(tostring(r.name)))
        fh:write(("\t\t\t[\"shown\"] = %s,\n"):format(tostring(r.shown)))
        for _, k in ipairs({ "left", "right", "top", "bottom", "w", "h",
                             "anchorX", "anchorY" }) do
            if r[k] then fh:write(("\t\t\t[\"%s\"] = %s,\n"):format(k, num(r[k]))) end
        end
        if r.unknownW then fh:write("\t\t\t[\"unknownW\"] = true,\n") end
        if r.unknownH then fh:write("\t\t\t[\"unknownH\"] = true,\n") end
        if r.root then fh:write("\t\t\t[\"root\"] = true,\n") end
        fh:write("\t\t},\n")
    end
    fh:write("\t},\n\t[\"holes\"] = {\n")
    for i, hole in ipairs(holes or {}) do
        fh:write(("\t\t[%d] = {\n\t\t\t[\"name\"] = \"%s\",\n\t\t\t[\"why\"] = \"%s\",\n\t\t},\n")
            :format(i, tostring(hole.name), tostring(hole.why):gsub('"', "'")))
    end
    fh:write("\t},\n}\n")
    fh:close()
    return true
end

return F
