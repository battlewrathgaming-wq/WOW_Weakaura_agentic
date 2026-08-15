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

function F.New(name, parent)
    local f = {
        _name = name or ("frame#" .. tostring(#made + 1)),
        _parent = parent,
        _points = {},
        _shown = true,          -- the client's default for a created frame
        _scripts = {},
    }

    setmetatable(f, { __index = function(_, k)
        if type(k) == "string" and k:sub(1, 1) == "_" then return nil end
        unmodelled[tostring(k)] = true
        return function() end
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

    function f:GetWidth() return self._w end
    function f:GetHeight() return self._h end
    function f:GetNumPoints() return #self._points end

    function f:Show() self._shown = true end
    function f:Hide() self._shown = false end
    function f:IsShown() return self._shown end

    function f:SetText(t) self._text = t end
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
    function f:CreateFontString(n)
        return F.New(n or ("%s.fs%d"):format(self._name, #made + 1), self)
    end
    function f:GetParent() return self._parent end

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
