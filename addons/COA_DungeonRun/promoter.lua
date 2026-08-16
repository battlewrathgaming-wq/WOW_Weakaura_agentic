-- COA_DungeonRun promoter.lua - THE THIRD SURFACE.
--
-- Spec: addons/planning/dungeonrun_poc.md §29, §56, §60, §61, §62.
--
-- ---------------------------------------------------------------------------
-- ★ THREE SURFACES, THREE QUESTIONS (Battlewrath, 2026-08-13):
--
--     map         what IS this?          the picture, and point facts on hover
--     curation    what am I LOOKING at?  trimming, filtering, replay, isolation
--     promotion   what does this BECOME? <- this file
--
-- Its own frame for the same build-hygiene reason the curator has one (§34): a bug
-- in here cannot break either of the others, and the dependency runs ONE WAY - we
-- call the map's public API, the map holds no reference to us.
--
-- ★ THE ORDER IS BUTTON PRESSES, NOT A SEQUENCE (Battlewrath, 2026-08-14).
--
-- The open button lives at the bottom of curation, so the layout suggests
-- map -> curation -> promotion. It SUGGESTS. Nothing here checks how you arrived,
-- refuses to open, or requires a loaded run: the map accepts load conditions and
-- does not care which order they came in. His words: *"without opening and loading
-- curation/run, the edit palette of promotion has little meaning"* - that is a
-- statement about VALUE, not a gate, and worst case the walk is *"like opening a
-- briefcase."* A macro hook can skip it for power users precisely because nothing
-- in the chain is load-bearing.
--
-- ★ CREATE THEN EDIT - the house pattern's third appearance. The beacon exists the
-- moment you press the button, carrying only what it inherited (§29 COPIES); cue,
-- note, radii and icon are edited in-field afterwards. Capture then promote · pin
-- then meaning · mint then author. THE MECHANICAL PART IS IMMEDIATE AND THE MEANING
-- WAITS - which is also why none of the three needs a dialog.
--
-- THIS SLICE IS THE MINT. The in-field editors (name · cue · note · stage ·
-- radius listen · radius close · icon pick) and the Manage half (list, renumber,
-- drag, delete, pre-flight walk) are designed in §61 and NOT BUILT - and the pane
-- says so rather than looking broken while it is empty.
-- ---------------------------------------------------------------------------

local ADDON, NS = ...

local Promoter = {}
NS.Promoter = Promoter

local Map, Store, Routes
local f, dd, nameBox, nameLabel, renameBtn, noteBtn, createBtn, inherit, hint, countText
local orderTitle, orderRows, stageBox, stageGhost, gapsText
local ORDER_ROWS = 9

-- ★ §81: *"maybe a show (light, maybe 1,2,3 slots to show) of where the table has
-- gaps."* Three, and LIGHT is the operative word - it is a hint for an author about
-- to place something deliberately, not an audit of the numbering.
local GAPS_SHOWN = 3

local NO_ROUTE = "- no route -"
local NEW_ROUTE = "+ create new"

-- Which mode the NAME control is in. Not inferred from what you typed - the
-- dropdown declared it (§61), which is the whole reason `+ create new` is an entry
-- in the list rather than a separate button beside it.
local creating

-- ★ PROMOTION IS FROM A CAPTURED NODE. A beacon or a personal note is already a
-- promoted object, so minting from one is not promotion - it is duplication, and it
-- would quietly produce beacons whose position came from a thing someone had
-- already dragged. Refused as a fact about the data (that is not a node), the same
-- shape as §61's other two refusals rather than a new rule.
--
-- ⚠ MY call, not his: §61 says "no creation from nothing" and does not name this
-- case. Cheap to reverse - delete the function and its one caller.
local function isPromoted(p) return p and (p.kind == "beacon" or p.kind == "note") end

local function selectedNode()
    local p = Map.Selected and Map.Selected() or nil
    return (not isPromoted(p)) and p or nil
end

-- What is ACTUALLY selected, promoted or not - so the pane can say WHY it refused
-- instead of behaving as though nothing were selected at all.
local function rawSelected() return Map.Selected and Map.Selected() or nil end

-- ★★ ASK THE MAP, NEVER THE CLIENT. This read GetCurrentPlayerPosition, which is
-- where your BODY is - so authoring SFK from a city (§22, which the map explicitly
-- supports) filed the new route under the city. It would have looked entirely
-- normal right up until the route was never offered again.
local function authoringMapID() return Map.AuthoringMapID() end

-- ★ Every control reads from the MAP and the STORE, never from what we last
-- clicked. Same discipline as the curation pane: a control that disagrees with the
-- picture is worse than no control.
local function refresh()
    if not f then return end

    local id = Map.LoadedId("route")
    if dd then
        UIDropDownMenu_SetText(dd, creating and NEW_ROUTE or (id or NO_ROUTE))
    end

    -- §61: the name field stops being dual-purpose. Text entry when creating,
    -- because you must type something; a LABEL with a Rename button when a route is
    -- selected. The field never has to distinguish modes on its own.
    local route = id and Routes.Get(id)
    if creating then
        nameBox:Show(); nameLabel:Hide(); renameBtn:Hide()
    else
        nameBox:Hide(); nameLabel:Show(); renameBtn:Show()
        nameLabel:SetText(route and ((route.name ~= "" and route.name) or id) or "")
        if route then renameBtn:Enable() else renameBtn:Disable() end
    end

    -- §79's running order. Sorted by stage VALUE, so what is drawn is what the
    -- driver will walk - there is no second ordering anywhere to disagree with it.
    if orderRows then
        local order = id and Routes.StageOrder(id) or {}
        orderTitle:SetText(#order > 0 and "running order" or "")

        -- ★ Gaps are the free numbers INSIDE the span. Silent when there are none,
        -- which is the common case - a line that is usually blank is one the author
        -- learns to read, and one that always says "gaps: none" is one they stop
        -- seeing.
        local gaps = id and Routes.Gaps(id, GAPS_SHOWN + 1) or {}
        if #gaps == 0 then
            gapsText:SetText("")
        else
            local show = {}
            for i = 1, math.min(#gaps, GAPS_SHOWN) do show[i] = ("%g"):format(gaps[i]) end
            gapsText:SetText(("|cff808080free: %s%s|r"):format(
                table.concat(show, ", "), #gaps > GAPS_SHOWN and ", ..." or ""))
        end
        for i, row in ipairs(orderRows) do
            local b = order[i]
            if not b then
                row:SetText("")
            else
                local out = Routes.OutcomeOf(b)
                row:SetText(("|cffffd100%-5s|r %s%s"):format(
                    ("%g"):format(b.stage or 0),
                    (b.name and b.name ~= "") and b.name or "|cff808080(unnamed)|r",
                    out and ("  |cff55ff55-> %g|r"):format(out) or ""))
            end
        end
        -- ★ The overflow row REPLACES the last entry rather than being appended after
        -- it, so the count includes the stage it displaced: 12 stages show 8 and
        -- "... 4 more". A truncated list that looks complete is worse than no list.
        if #order > ORDER_ROWS then
            orderRows[ORDER_ROWS]:SetText(("|cff808080... %d more|r")
                :format(#order - ORDER_ROWS + 1))
        end
    end

    -- §80's stage field. The ghost shows what the mint WOULD use, and vanishes the
    -- moment there is real text - so the box reads as "leave me alone" until touched.
    if stageBox then
        if creating or not id then
            stageBox:Hide(); stageGhost:Hide()
        else
            stageBox:Show()
            local typed = stageBox:GetText()
            stageGhost:SetText(("%g"):format(Routes.NextStage(id)))
            if typed == "" then stageGhost:Show() else stageGhost:Hide() end
        end
    end

    local node = selectedNode()
    inherit:SetText(Routes.InheritSummary(node))

    -- ★★ THE BUTTON'S VERB FOLLOWS THE MODE - Battlewrath, 2026-08-14:
    -- *"a route can't be created without minting a beacon, currently, but order of
    -- operations wise that compounds two choices into one only option. Starting a
    -- route is like starting a run. Just enter the name. Collection follows."*
    --
    -- Taken. §61's *"one control instead of two"* is about the PANE not growing a
    -- second button, and it survives: the single control declares what it will do,
    -- exactly as the name field's mode is declared by the dropdown. What does not
    -- survive is minting a route as a SIDE EFFECT of placing a beacon, which forced
    -- a node to exist before a route could.
    --
    -- A route needs a name and nothing else, same as opening a run does.
    local placeable = node and node.mapX ~= nil
    local mapID = authoringMapID()
    if creating then
        createBtn:SetText("Create route")
        -- A route belongs to a MAP, so with nothing loaded there is no dungeon to
        -- create it for. A fact about the data, like every other refusal here.
        if mapID then createBtn:Enable() else createBtn:Disable() end
    else
        createBtn:SetText("Create beacon")
        if placeable and route then createBtn:Enable() else createBtn:Disable() end
    end
    if placeable then noteBtn:Enable() else noteBtn:Disable() end

    local n = id and Routes.Count(id) or 0
    local notes = Routes.NoteCount(authoringMapID())
    countText:SetText(("%d beacon%s  ·  %d personal note%s here"):format(
        n, n == 1 and "" or "s", notes, notes == 1 and "" or "s"))

    -- ★★ §71: NO EDIT SURFACE HERE. §69 put the object's label and its move chip on
    -- this pane and said the in-field editors would follow - which made the creation
    -- tool double as an editor. His ruling: *"All edit options of an object live
    -- within its edit mode interface... Instead of promotion being both a spawning
    -- and editing tool."* Both moved to object.lua. The promoter MINTS AND HANDS OFF.

    if isPromoted(rawSelected()) then
        hint:SetText("|cffff8080that is already a promoted object|r")
    elseif not node then
        hint:SetText("select a point on the map")
    elseif not placeable then
        hint:SetText("|cffff8080that point has no map position|r")
    elseif creating then
        hint:SetText("name it and create - beacons collect afterwards")
    elseif not mapID then
        hint:SetText("load a run - a route belongs to a map")
    elseif not route then
        hint:SetText("pick a route, or |cffffd100+ create new|r")
    else
        hint:SetText("|cff808080cue, note, radii and icon are edited after minting|r")
    end
end
Promoter.Refresh = refresh

-- ★ §61: `+ create new` BELONGS IN THE DROPDOWN, as an entry rather than a button
-- beside it. That makes the mode a SELECTION instead of something inferred from how
-- you typed, and it is the pattern the run selector already set: `- no route -` is a
-- real entry too, because unloading must be as reachable as loading (§36).
local function initDropdown()
    local info = UIDropDownMenu_CreateInfo()
    info.text = NEW_ROUTE
    info.notCheckable = 1
    info.func = function()
        creating = true
        Map.Load("route", nil)
        nameBox:SetText("")
        refresh()
    end
    UIDropDownMenu_AddButton(info)

    local none = UIDropDownMenu_CreateInfo()
    none.text = NO_ROUTE
    none.notCheckable = 1
    none.func = function() creating = nil; Map.Load("route", nil); refresh() end
    UIDropDownMenu_AddButton(none)

    -- Only this map's routes, so there are no groups to draw any more: there is
    -- exactly one dungeon on offer and the map already names it.
    local list = Routes.List(authoringMapID())
    if #list == 0 then
        local h = UIDropDownMenu_CreateInfo()
        h.text = authoringMapID() and "no routes for this map" or "load a run first"
        h.isTitle = 1; h.notCheckable = 1
        UIDropDownMenu_AddButton(h)
        return
    end

    for _, e in ipairs(list) do
        local b = UIDropDownMenu_CreateInfo()
        b.text = e.id
        b.notCheckable = 1
        -- ★ Selection LOADS the route's beacons onto the map (§61), which is the
        -- whole reason §62 gave the map a second slot: you author against the
        -- evidence, so both have to be on screen at once.
        b.func = function() creating = nil; Map.Load("route", e.id); refresh() end
        UIDropDownMenu_AddButton(b)
    end
end

-- Renaming follows the RUN's method, his ruling: the client's own confirm, exactly
-- as a run is renamed. Costs nothing to build and nothing to learn.
local function installPopups()
    StaticPopupDialogs["COA_DR_ROUTE_RENAME"] = {
        text = "Rename route:", button1 = ACCEPT or "Accept", button2 = CANCEL or "Cancel",
        hasEditBox = 1, maxLetters = 60,
        OnShow = function(self)
            local box = self.editBox or _G["StaticPopup1EditBox"]
            local r = Routes.Get(Map.LoadedId("route"))
            if box and r then box:SetText(r.name or "") end
        end,
        OnAccept = function(self)
            local box = self.editBox or _G["StaticPopup1EditBox"]
            local id = Map.LoadedId("route")
            if id and box then Routes.Rename(id, box:GetText()) end
            Map.Load("route", id)
            Promoter.Refresh()
        end,
        timeout = 0, whileDead = 1, hideOnEscape = 1,
    }
end

-- ★ THE MINT. One function for both objects because they differ in exactly two
-- ways - where it goes, and whether it needs a route - and writing it twice would
-- let those two drift apart.
-- ★ A ROUTE IS OPENED, NOT MINTED FROM SOMETHING. No node, no selection, no
-- position - a name and the dungeon you are standing in, exactly as Store.Open
-- takes a run. Collection follows.
local function mintRoute()
    local name = nameBox:GetText()
    if not name or name:match("^%s*$") then
        NS.Say("name the route first")
        return
    end
    local id = Routes.Create(name, authoringMapID())
    if not id then return end
    creating = nil
    Map.Load("route", id)
    NS.Say(("route |cffffd100%s|r started - now collect beacons"):format(id))
    refresh()
    return id
end

local function mintBeacon()
    local node = selectedNode()
    if not node then return end

    local id = Map.LoadedId("route")
    if not id then return end

    -- ★ Typed wins, ghost is only a suggestion. An empty box means "use the default",
    -- which is what makes the field free to ignore - the common path is never typing
    -- in it at all.
    local typed = stageBox and stageBox:GetText()
    local b = Routes.AddBeacon(id, node, typed ~= "" and typed or nil)
    if not b then NS.Say("that point cannot be placed - no map position") return end
    if stageBox then stageBox:SetText(""); stageBox:ClearFocus() end
    -- Load rather than repaint: it is the one entry point, and it puts the route on
    -- screen in the same state the selector would have.
    Map.Load("route", id)
    NS.Say(("beacon |cffffd100%g|r on |cffffd100%s|r"):format(b.stage, id))
    refresh()
end

local function mintNote()
    local node = selectedNode()
    local mapID = authoringMapID()
    if not node or not mapID then return end
    local p = Routes.AddNote(mapID, node)
    if not p then NS.Say("that point cannot be placed - no map position") return end
    -- The note plane is loaded by mapID, so minting one also brings the plane up -
    -- otherwise you would create something you cannot see.
    Map.Load("notes", mapID)
    refresh()
end

function Promoter.Init()
    Map, Store, Routes = NS.Map, NS.Store, NS.Routes

    f = CreateFrame("Frame", "COA_DungeonRunPromoter", UIParent)
    -- ★★ 320, NOT 280 (§104). The route dropdown paints to 252 and the play button
    -- is 52 wide, so 280 could not hold both on one row whatever we did to the
    -- positions. His ruling: *"make the pane bigger. It already takes over the UI.
    -- No point fighting that."* ★ The pane is the free variable; the client's own
    -- control sizes are not.
    f:SetWidth(320); f:SetHeight(400)
    f:SetPoint("CENTER", UIParent, "CENTER", 560, -220)
    -- Same strata as the curation pane: both annotate the map and neither may end
    -- up buried under it.
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, _, x, y = self:GetPoint()
        Store.SetUI("promoterPos", { p = p, x = x, y = y })
    end)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 18, -16)
    title:SetText("Promotion")

    -- ★ ABOVE THE DIVIDER: ALWAYS AVAILABLE (§61). The route selector sits below it
    -- because the selector only gates the second button - a personal note needs no
    -- route, and putting it above says so without a word of explanation.
    noteBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    noteBtn:SetWidth(110); noteBtn:SetHeight(20)
    noteBtn:SetPoint("TOPLEFT", 16, -38)
    noteBtn:SetText("Personal note")
    noteBtn:SetScript("OnClick", mintNote)

    local rule = f:CreateTexture(nil, "ARTWORK")
    rule:SetHeight(1); rule:SetWidth(284)
    rule:SetPoint("TOPLEFT", 18, -66)
    rule:SetTexture(0.4, 0.4, 0.4, 0.6)

    dd = CreateFrame("Frame", "COA_DungeonRunRouteLoad", f, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", 2, -74)
    UIDropDownMenu_Initialize(dd, initDropdown)
    -- ⚠⚠ 200 ASKS FOR 250 OF ART. `UIDropDownMenu_SetWidth` builds a frame
    -- `width + 50` wide - 25 either side (`SharedXML/UIDropDownMenu.lua:962`),
    -- measured live and read in the source. So this paints x=2 to 252.
    --
    -- ★★★ THAT IS WHY THE PLAY BUTTON LOOKED CLIPPED, and it never was. He saw it:
    -- *"the drop down selector is sitting above the button. And that the button
    -- looks to not have content."* At x=208 only its rightmost 8 pixels cleared
    -- the art. ⚠ I blamed the pane edge twice; 208 + 52 = 260 inside a 280 frame
    -- is not a clip. It was the neighbour, and the pane grew instead.
    UIDropDownMenu_SetWidth(dd, 200)
    UIDropDownMenu_JustifyText(dd, "LEFT")
    UIDropDownMenu_SetText(dd, NO_ROUTE)

    nameBox = CreateFrame("EditBox", "COA_DungeonRunRouteName", f, "InputBoxTemplate")
    nameBox:SetWidth(272); nameBox:SetHeight(20)
    nameBox:SetPoint("TOPLEFT", 22, -108)
    nameBox:SetAutoFocus(false)
    nameBox:SetMaxLetters(60)
    nameBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    nameBox:Hide()

    nameLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nameLabel:SetPoint("TOPLEFT", 22, -112)
    nameLabel:SetWidth(160); nameLabel:SetJustifyH("LEFT")

    renameBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    renameBtn:SetWidth(70); renameBtn:SetHeight(20)
    renameBtn:SetPoint("TOPLEFT", 188, -108)
    renameBtn:SetText("Rename")
    renameBtn:SetScript("OnClick", function()
        local id = Map.LoadedId("route")
        if id then StaticPopup_Show("COA_DR_ROUTE_RENAME", id) end
    end)

    -- ★ "WHAT INFORMATION WILL CARRY OVER FROM THE NODE" - doing more work than it
    -- looks. It makes the INHERITANCE VISIBLE BEFORE COMMIT, the same move as the
    -- map strip naming its tile file: a borrow shown rather than assumed. And it
    -- pre-empts the z question - you SAW z come from the node, so a beacon later
    -- dragged to the wrong height reads as the design telling you something (§25.2's
    -- teacher) rather than as a bug.
    local carries = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    carries:SetPoint("TOPLEFT", 18, -140)
    carries:SetText("carries over from the node")

    inherit = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    inherit:SetPoint("TOPLEFT", 18, -156)
    inherit:SetWidth(284); inherit:SetJustifyH("LEFT")

    createBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    createBtn:SetWidth(110); createBtn:SetHeight(20)
    createBtn:SetPoint("TOPLEFT", 16, -178)
    createBtn:SetText("Create beacon")
    createBtn:SetScript("OnClick", function()
        if creating then mintRoute() else mintBeacon() end
    end)

    -- ---------------------------------------------------------------------
    -- ★★ §80: THE STAGE FIELD, and it is GHOSTED rather than pre-filled.
    --
    --   *"It holds what it would be as ghost text, to a round number. And the user
    --   can input their own."*
    --
    -- ★ Ghost text, not a default VALUE, is what keeps the common path free: an empty
    -- box means "use the next number", so the author who does not care never touches
    -- it and never has to clear it either. Pre-filling would make every ordinary mint
    -- an edit of a field.
    --
    -- 3.3.5 has no placeholder attribute, so it is a font string behind the box,
    -- hidden the moment there is anything real to show.
    stageBox = CreateFrame("EditBox", "COA_DungeonRunStage", f, "InputBoxTemplate")
    stageBox:SetWidth(40); stageBox:SetHeight(20)
    stageBox:SetPoint("TOPLEFT", 140, -178)
    stageBox:SetAutoFocus(false)
    stageBox:SetMaxLetters(6)
    -- ⚠ NOT SetNumeric: 4.1 is the whole point of the field existing.
    -- ★ §83 step 2: the same gate as the object pane's stage field, for ONE IDIOM
    -- across the addon rather than two handlers that differ for no stated reason.
    --
    -- ⚠ HONEST: here it fixes NOTHING. refresh() never writes this box, so there was
    -- no loop to break, and the one programmatic write (mintBeacon clearing it) is
    -- followed by an explicit refresh() anyway. This is consistency, and saying so
    -- beats letting a later reader infer a hazard that was never here.
    stageBox:SetScript("OnTextChanged", function(_, userInput)
        if not userInput then return end
        refresh()
    end)
    stageBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    stageBox:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus() end)

    stageGhost = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    stageGhost:SetPoint("LEFT", stageBox, "LEFT", 4, 0)

    local stageLbl = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    stageLbl:SetPoint("TOPLEFT", 186, -183)
    stageLbl:SetText("stage")

    countText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    countText:SetPoint("TOPLEFT", 18, -204)
    countText:SetWidth(284); countText:SetJustifyH("LEFT")

    hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 18, -220)
    hint:SetWidth(284); hint:SetJustifyH("LEFT")

    -- ---------------------------------------------------------------------
    -- ★★ §79: THE RUNNING ORDER, and it SELF-ORGANISES BY VALUE.
    --
    --   *"I imagine we will need a table that sets the final expected order. And it
    --   self organises by number value... 1 2 3 4 4.1 4.2 4.3 5 is still a ranked
    --   order. And a designer building for 1 3 2 5 is bad form."*
    --
    -- ★ THE ORDER IS A CONSEQUENCE OF THE NUMBERS, never a second thing to maintain.
    -- There is no drag-to-reorder here and there should not be: one source of truth,
    -- and inserting a 4.1 renumbers nothing.
    --
    -- ★ AND THIS IS THE ANTI-WARNING. Bad form (1, 3, 2, 5) is not validated or
    -- refused - it is DISPLAYED, sorted, so the author sees their own numbering
    -- disagree with their intent. Informing rather than grading (§75), applied to
    -- authoring: show the truth and let them read it.
    orderTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    orderTitle:SetPoint("TOPLEFT", 18, -240)
    orderTitle:SetText("running order")

    -- Anchored to the RIGHT of the same row, so it reads as a property of the list
    -- rather than as a fourth control.
    gapsText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    gapsText:SetPoint("TOPRIGHT", -18, -240)

    orderRows = {}
    for i = 1, ORDER_ROWS do
        local r = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        r:SetPoint("TOPLEFT", 22, -256 - (i - 1) * 12)
        r:SetWidth(240); r:SetJustifyH("LEFT")
        orderRows[i] = r
    end

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetWidth(60); closeBtn:SetHeight(20)
    closeBtn:SetPoint("BOTTOMRIGHT", -14, 14)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() Promoter.Toggle() end)

    installPopups()

    -- ★★ REGISTER FOR THE SELECTION. Without this the pane refreshes only at Init -
    -- when nothing is selected - so both buttons latch DISABLED and never recover.
    -- §63 added many-listener support to map.lua for exactly this pane and then did
    -- not use it, which is why the smoke now asserts the REGISTRATION and not just
    -- the map's ability to serve one.
    Map.AddOnSelect(refresh)
    local ui = Store.GetUI()
    if ui.promoterPos then
        f:ClearAllPoints()
        f:SetPoint(ui.promoterPos.p, UIParent, ui.promoterPos.p, ui.promoterPos.x, ui.promoterPos.y)
    end

    -- ★★★ EVERY DECLARED CONTROL, REGISTERED (§131) - and the block sits at the END
    -- of the build on purpose. §97.1 lost `promoter.create` to a registration written
    -- forty lines above the button it named; the file-order hazard is structural, so
    -- the answer is structural: ONE block, LAST, where everything above it exists.
    --
    -- ⚠ `set` only where the handler it mirrors was read. A setter that calls SetText
    -- on a box whose OnTextChanged guards on `userInput` commits NOTHING - a control
    -- that lies is worse than one that declines.
    local R = NS.UI and NS.UI.Register
    if R then
        R("promoter.pane", f, { kind = "frame",
            set = function(v) if v == "close" then f:Hide() else f:Show() end end,
            read = function() return f:IsShown() and true or false end })
        R("promoter.note", noteBtn)
        R("promoter.create", createBtn)
        R("promoter.rename", renameBtn)
        -- ⚠⚠ THE ROUTE SELECTOR, AND IT WAS ONCE NOT REGISTERED AT ALL. That is why
        -- the geometry probe read four controls in this pane where there are five,
        -- and why a 44-pixel collision was invisible to a check that never received
        -- one of its two operands. ★ Worse than §97.1's missing `create`: that one
        -- was absent from a COUNT, this one was absent from the QUESTION.
        R("promoter.route", dd, { kind = "dropdown",
            read = function() return UIDropDownMenu_GetText and UIDropDownMenu_GetText(dd) end })
        R("promoter.name", nameBox, { kind = "edit",
            read = function() return nameBox:GetText() end })
        R("promoter.stage", stageBox, { kind = "edit",
            read = function() return stageBox:GetText() end })
        R("promoter.inherit", inherit, { kind = "readout",
            read = function() return inherit:GetText() end })
        R("promoter.count", countText, { kind = "readout",
            read = function() return countText:GetText() end })
        R("promoter.hint", hint, { kind = "readout",
            read = function() return hint:GetText() end })
    end

    refresh()
    return f
end

function Promoter.Toggle()
    if not f then return end
    if f:IsShown() then f:Hide() else f:Show(); refresh() end
end

function Promoter.IsShown() return f and f:IsShown() and true or false end
