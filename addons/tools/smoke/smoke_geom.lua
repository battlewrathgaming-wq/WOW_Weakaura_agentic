-- Offline smoke for COA_DevDump task_geom.lua - THE MEASURING RUN.
--
-- ★★★ THE FAILURE MODE THIS EXISTS FOR IS SPECIFIC AND HAS ALREADY HAPPENED ONCE.
-- Run 1 of `/coadump r api` reported four disagreements about the client and ALL FOUR
-- WERE FALSE - the experiments never ran, and a claim of absence passes trivially
-- when nothing fires. ⚠ A measurement of zero and a measurement that did not happen
-- are indistinguishable in a file.
--
-- So the assertions below are almost entirely about the APPARATUS rather than the
-- numbers: that it proves itself before believing anything, that it stops when the
-- proof fails, and that every absence is NAMED rather than left as a gap.
--
-- ⚠ What this canNOT check is the only thing the run is for: whether the client's
-- numbers are right. That is the point of running it.

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }
local function said(pat)
    for _, m in ipairs(chat) do if m:find(pat, 1, true) then return true end end
    return false
end

function UnitName() return "Gravekeeper" end
function UnitClass() return "Necromancer", "NECROMANCER" end
function GetRealmName() return "Area 52" end
function date() return "20260815_120000" end
function GetCVar() return "1920x1080" end
COA_DevDumpDB = nil

-- ★ THE MEASURING CLIENT, MODELLED. Width is proportional to the text so a wrong
-- string reaching a wrong measurement is visible: 7 per character, plus 3 of fixed
-- overhead. Nothing here claims to be the client's metrics - it is a MODEL whose only
-- job is to make the task's arithmetic checkable.
local PER_CHAR, OVERHEAD = 7, 3
local hiddenMeasures = true       -- flipped by a case below

local function newWidget(parent)
    local w = { _shown = true, _text = "", _parent = parent }
    function w:SetPoint() end
    function w:SetWidth(v) self._w = v end
    function w:SetHeight(v) self._h = v end
    function w:GetWidth() return self._w end
    function w:GetHeight() return self._h end
    function w:Show() self._shown = true end
    function w:Hide() self._shown = false end
    function w:IsShown() return self._shown end
    function w:IsVisible()
        local p = self._parent
        return self._shown and (not p or p:IsVisible())
    end
    function w:SetText(t) self._text = t end
    function w:GetText() return self._text end
    function w:GetName() return self._name end
    function w:GetObjectType() return self._kind or "Frame" end
    function w:GetRect() return 10, 20, self._w or 0, self._h or 0 end
    function w:GetFont() return "Fonts\\FRIZQT__.TTF", 12, "" end
    function w:GetStringHeight() return 12 end
    function w:GetStringWidth()
        -- ⚠ THE WHOLE QUESTION, MODELLED AS A SWITCH: does a never-shown frame
        -- measure? We do not know, so the smoke drives BOTH answers rather than
        -- picking one and testing our own guess.
        if not self:IsVisible() and not hiddenMeasures then return 0 end
        return #self._text * PER_CHAR + (#self._text > 0 and OVERHEAD or 0)
    end
    function w:CreateFontString(_, _, font)
        local fs = newWidget(self)
        fs._font, fs._kind = font, "FontString"
        return fs
    end
    -- ⚠ Frames carry these; FontStrings and Textures do NOT, which is why the task
    -- reads them inside a pcall. Modelled here on everything because the stub has one
    -- widget type - the pcall is what handles the real distinction.
    function w:GetFrameStrata() return self._strata or "MEDIUM" end
    function w:GetFrameLevel() return self._level or 1 end
    function w:GetChildren() return end
    function w:GetRegions() return end
    return w
end

UIParent = newWidget(nil)
function UIParent:GetEffectiveScale() return 1.0 end

function CreateFrame(kind, name, parent, template)
    -- ⚠ A TEMPLATE THAT DOES NOT EXIST MUST THROW, the way the client's does. If the
    -- stub silently made one, `templatesMissing` could never be exercised and the
    -- absence-is-a-finding claim would be untested.
    if template == "InterfaceOptionsCheckButtonTemplate" then
        error("Unknown template: " .. template, 0)
    end
    local f = newWidget(parent)
    f._name, f._kind = name, kind
    if template == "UIDropDownMenuTemplate" then f._w, f._h = 40, 32 end
    return f
end

function UIDropDownMenu_SetWidth(dd, w)
    -- ★ The client's own quirk, modelled because the task exists to measure it: the
    -- template adds side textures, so the frame is WIDER than the width you ask for.
    -- ⚠ 25 is this stub's invention and is NOT a claim about the client - it is here
    -- so the task's "measure it twice" path is exercised, and the live run replaces it.
    dd._w = w + 25
end

local D = { VERSION = "test", tasks = {} }
function D.Print(m) DEFAULT_CHAT_FRAME:AddMessage(m) end
function D.RegisterTask(t) D.tasks[t.name] = t end
function D.Begin(task, args)
    COA_DevDumpDB = { header = { task = task, args = args, status = "open" }, payload = {} }
    return COA_DevDumpDB.payload
end
function D.Commit(summary)
    COA_DevDumpDB.header.status = "complete"
    COA_DevDumpDB.header.summary = summary
    D.Print(summary)
end
function D.WalkFrameTree(root, depth, fields, out)
    out[#out + 1] = { depth = 0, name = root.GetName and root:GetName() or nil }
    return out
end

assert(loadfile([[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\COA_DevDump\task_geom.lua]]))("COA_DevDump", D)
local geom = assert(D.tasks.geom, "the task registered itself").run

for _, leaked in ipairs({"CALIBRATION", "FONTS", "TEMPLATES", "REFERENCE", "OURS",
                         "rectOf"}) do
    assert(_G[leaked] == nil, "LEAKED GLOBAL: " .. leaked)
end

-- =====================================================================
-- ★★★ THE APPARATUS PROVES ITSELF BEFORE ANYTHING IS BELIEVED
-- =====================================================================
geom("")
local p = COA_DevDumpDB.payload
assert(p.apparatus == "live", "a working measure reports the apparatus LIVE")
assert(p.control.shownWidth > 0, "and the control is a real non-zero measurement")

-- ★★ THE QUESTION WE HAD NOT ASKED, and it lands as a ROW rather than an assumption.
assert(p.control.hiddenMeasures == true,
       "with the model measuring hidden frames, the record must SAY it does - this "
       .. "is the finding, not a precondition")

-- ⚠⚠ AND THE OTHER ANSWER TOO. The stub carries a switch for whether a never-shown
-- frame measures, precisely because WE DO NOT KNOW which the client does - and the
-- first cut never flipped it, so hardcoding `hiddenMeasures = true` in the task went
-- SILENT through the whole suite. ★ A capability the test never drives is not
-- coverage; it is a comment.
hiddenMeasures = false
chat = {}
geom("")
assert(COA_DevDumpDB.payload.control.hiddenMeasures == false,
       "THE HIDDEN-FRAME ANSWER WAS ASSUMED RATHER THAN MEASURED: it has to be read "
       .. "off the widget, because which way the client answers is the whole "
       .. "question this run exists to settle")
assert(COA_DevDumpDB.payload.apparatus == "live",
       "and a hidden frame that cannot measure must NOT kill the run - the SHOWN "
       .. "control is what proves the apparatus")
hiddenMeasures = true

-- =====================================================================
-- ★★★ AND IT STOPS WHEN THE PROOF FAILS. This is the §70 lesson made mechanical:
-- four false disagreements were filed because nothing checked the apparatus first.
-- =====================================================================
do
    -- Break measurement at the source - every FontString reads zero - and re-run.
    local saveCreate = CreateFrame
    CreateFrame = function(kind, name, parent, template)
        local f = saveCreate(kind, name, parent, template)
        f.CreateFontString = function(self) local fs = newWidget(self); fs.GetStringWidth = function() return 0 end; return fs end
        return f
    end
    chat = {}
    geom("")
    CreateFrame = saveCreate
    local q = COA_DevDumpDB.payload
    -- ⚠ THIS ONE FIRST, and the order is load-bearing. Dropping the early `return`
    -- breaks BOTH claims - the run keeps going AND the later `apparatus = "live"`
    -- overwrites the verdict - so with the vaguer assertion first the mutation
    -- reported the right failure for the wrong cause.
    assert(q.fonts == nil and q.templates == nil,
           "IT KEPT GOING AFTER THE APPARATUS FAILED: everything after a dead "
           .. "control is a page of zeros wearing the clothes of measurements")
    assert(q.apparatus == "dead",
           "A ZERO MEASUREMENT WAS FILED AS A FACT: a zero and a measurement that "
           .. "never happened are identical in a record, and this is exactly how "
           .. "four false disagreements got written")
    assert(said("APPARATUS DEAD"), "and it SAYS so in chat, on the one summary line")
end

-- =====================================================================
-- ★★ THE NORM IS DERIVED, not just collected. Ten Ms minus one M over nine is a
-- per-character width, and that is what lets a string be PREDICTED instead of
-- re-measured for the rest of the project.
-- =====================================================================
chat = {}
geom("")
p = COA_DevDumpDB.payload
local gfn = p.fonts.GameFontNormal
assert(gfn and gfn.perM, "the per-character norm is computed, not left to the reader")
assert(math.abs(gfn.perM - PER_CHAR) < 0.001,
       ("THE NORM IS WRONG: 10 M's minus 1 M over 9 must be the per-character width; "
        .. "expected %d, got %s"):format(PER_CHAR, tostring(gfn.perM)))
assert(gfn.strings["identity"] == #("identity") * PER_CHAR + OVERHEAD,
       "and our OWN strings are measured exactly rather than estimated from the norm")

-- =====================================================================
-- ★★★ EVERY ABSENCE IS NAMED. A gap in a record cannot say whether the thing was
-- missing or the probe never looked - which is the whole reason the census exists.
-- =====================================================================
-- ⚠ ONE ASSERTION, NOT TWO. The precise claim used to sit BEHIND a `#list > 0`
-- check, so breaking the append fired the vague one first and the mutation reported
-- the right failure for the wrong reason. Order the precise assertion first - or, as
-- here, make it the only one.
local sawMissing = false
for _, n in ipairs(p.templatesMissing) do
    if n == "InterfaceOptionsCheckButtonTemplate" then sawMissing = true end
end
assert(sawMissing,
       "A TEMPLATE THAT DOES NOT EXIST WENT UNNAMED: absence is a finding on this "
       .. "bench, and a count cannot be looked up")

assert(#p.referenceMissing > 0 and p.referenceMissing[1],
       "reference panels that are not loaded are named, not skipped")

assert(p.oursMissing[1] and p.oursMissing[1]:find("COA_DungeonRunUIProbe"),
       "WITH THE BRIDGE ABSENT THE RECORD MUST SAY SO: 'the addon was not loaded' "
       .. "and 'the pane was empty' are different answers and a gap cannot tell them "
       .. "apart")

-- =====================================================================
-- ★★★ THE REGISTRY NAMES; THE PANE ENUMERATES.
--
-- ⚠⚠ THIS IS §103, AND IT COST A REAL BUG. The promoter's route dropdown was never
-- registered, so the probe read four controls in a pane that has five - and a 44x20
-- collision was invisible to a check that never received one of its two operands.
-- ★ A completeness check built on a hand-maintained list is not a completeness check.
-- =====================================================================
local paneFrame = newWidget(UIParent)
paneFrame._w, paneFrame._h = 280, 400
paneFrame._kind = "Frame"

local knownBtn = newWidget(paneFrame)
knownBtn._w, knownBtn._h, knownBtn._kind = 52, 20, "Button"

-- ★ The one nobody registered - the shape of the bug.
local ghostDD = newWidget(paneFrame)
ghostDD._w, ghostDD._h, ghostDD._kind = 250, 32, "Frame"
ghostDD._name = "COA_DungeonRunRouteLoad"

function paneFrame:GetChildren() return knownBtn, ghostDD end

_G.COA_DungeonRunUIProbe = {
    Keys = function() return { "promoter.pane", "promoter.play", "promoter.gone" } end,
    Get = function(k)
        if k == "promoter.pane" then return { frame = paneFrame, kind = "frame" } end
        if k == "promoter.play" then return { frame = knownBtn, kind = "button" } end
        return nil
    end,
}
chat = {}
geom("")
p = COA_DevDumpDB.payload

local byKey = {}
for _, e in ipairs(p.ours) do byKey[e.key] = e end

assert(byKey["promoter.pane"] and byKey["promoter.pane"].isPane,
       "the pane itself must be recorded, and marked as the pane - everything else "
       .. "is measured in ITS frame of reference")
assert(byKey["promoter.play"] and byKey["promoter.play"].h == 20,
       "a REGISTERED child comes back under its own key, with its real rect")
assert(byKey["promoter.play"].registered == true, "and says it was registered")

-- ★★★ THE CLAIM THIS WHOLE CHANGE EXISTS FOR.
local ghost = nil
for _, e in ipairs(p.ours) do
    if e.registered == false then ghost = e end
end
assert(ghost,
       "AN UNREGISTERED CHILD WAS NOT MEASURED: that is exactly how the route "
       .. "dropdown hid a 44-pixel collision from a check that only walked the "
       .. "registry")
assert(ghost.w == 250 and ghost.h == 32,
       "and it is measured, not merely counted - the rect IS the finding")
assert(ghost.key:find("unregistered"),
       "IT MUST SAY it was unregistered in its own name, because that name is what "
       .. "someone reads in a report and goes looking for")
assert(ghost.frameName == "COA_DungeonRunRouteLoad",
       "and its GetName is kept when it has one - a global name is how a human finds "
       .. "the line in the source")

-- ⚠ STRATA AND LEVEL, the other half of his question. The first run recorded rects
-- and nothing else, so "is it drawn OVER" was unanswerable from the capture.
assert(byKey["promoter.play"].strata ~= nil and byKey["promoter.play"].level ~= nil,
       "STRATA AND LEVEL WENT UNRECORDED: a rect cannot say which of two overlapping "
       .. "controls the eye sees, and task_frames had been capturing both all along")

local goneNamed = false
for _, n in ipairs(p.oursMissing) do if n == "promoter.gone" then goneNamed = true end end
assert(goneNamed,
       "A REGISTERED KEY WITH NO FRAME WENT UNREPORTED: that is the §97.1 miss "
       .. "class, and it was found last time only because a COUNT moved")

-- =====================================================================
-- ★★ THE DROPDOWN IS MEASURED TWICE, because `object.lua` calls SetWidth and the
-- template puts textures either side of what you asked for. How much wider is the
-- thing we refused to assert from memory - so the record must carry BOTH.
-- =====================================================================
local dd = p.templates["UIDropDownMenuTemplate"]
assert(dd and dd.declaredW == 40, "as the template creates it")
assert(dd.afterSetWidth96 and dd.afterSetWidth96.getWidth,
       "AND AFTER SetWidth(96) - one number without the other cannot show the "
       .. "difference, which IS the measurement")
assert(dd.afterSetWidth96.getWidth ~= 96,
       "the stub deliberately makes them differ, so a task that recorded only the "
       .. "asked-for width would pass and tell us nothing")

-- ★ One summary line, and it carries the finding rather than just a count.
assert(said("Hidden frames measure:"),
       "the summary states the hidden-measurement answer, because it is the fact "
       .. "that decides whether the whole approach works")

print("smoke_geom: OK")
