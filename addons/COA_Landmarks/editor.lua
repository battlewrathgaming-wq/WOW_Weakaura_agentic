-- COA_Landmarks editor.lua - the landmark edit form (AC-40a, AC-42, AC-54).
--
--   Name          the ALIAS. The id never changes (AC-47).
--   What:         a LINE - a label.
--   Why:          a PAGE - the free-hand space. This is the product's core
--                 field; it is what a player actually loses (L18).
--   Beacon hide:  the three tiers (AC-22). No custom radius (AC-40b).
--   Tags:         stored AS TYPED, never cleaned up (AC-54), with autocomplete
--                 offered from what the user has already written (AC-54a).
--
-- AC-36a: opening this form CLEARS live tracking. You cannot be travelling to
-- something you are organising - different modes (L17) - and opening the form
-- is itself the user act that makes the clear legitimate (L13).
--
-- Deferred from v1 per §12: the icon palette, the owner promote/demote toggle,
-- and the CVar tick. The FIELDS all exist; only these inputs wait.

local ADDON, NS = ...
local Store = NS.Store

local Editor = {}
NS.Editor = Editor

local f, currentId

local function label(parent, text, x, y)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("TOPLEFT", x, y)
    fs:SetText(text)
    return fs
end

-- InputBoxTemplate's MIDDLE texture is anchored `relativeTo="$parentLeft"` and
-- `"$parentRight"` - BY NAME. A nameless EditBox cannot resolve $parent, those
-- anchors fail, and only the two 8px end caps draw. Every box here must have a
-- name. (Found live: "No mid texture".)
local function line(parent, name, x, y, w)
    local e = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    e:SetPoint("TOPLEFT", x, y); e:SetWidth(w); e:SetHeight(18)
    e:SetAutoFocus(false)
    e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return e
end

-- ---------------------------------------------------------------------
-- Tag autocomplete - INLINE, the way the client's own Add Friend and mailbox
-- "To:" boxes do it (Battlewrath): type "ven", the box becomes "vendor" with
-- "dor" highlighted; keep typing and the proposal is replaced; leave it and it
-- is accepted. No chips, no dropdown, no extra surface.
--
-- The stock mechanism (AutoComplete_Update / GetAutoCompleteResults) cannot be
-- reused - it is a C API that only returns PLAYER NAMES. So the behaviour is
-- replicated, not borrowed.
--
-- AC-54a: it still OFFERS and never CORRECTS. The highlighted tail is a
-- proposal living in the box; typing over it removes it, and nothing is ever
-- rewritten behind the user's back.
-- ---------------------------------------------------------------------

-- The partial tag is whatever follows the last comma - people type
-- "vendor, alt|" and expect the completion to be about "alt".
local function splitAtCursor(text)
    local head, partial = text:match("^(.*,)%s*([^,]*)$")
    if not head then return "", text end
    return head .. " ", partial
end

local function tryComplete(box)
    if not currentId then return end
    local text = box:GetText() or ""
    local prefix, partial = splitAtCursor(text)
    if partial == "" then return end

    local hits = Store.SuggestTags(partial, currentId)
    if #hits == 0 then return end

    local full = prefix .. hits[1]
    box.suppress = true
    box:SetText(full)
    -- highlight ONLY the part we added, so the next keystroke replaces it
    box:HighlightText(#prefix + #partial, #full)
    box.suppress = false
    Store.Set(currentId, "tags", full)
end

-- ---------------------------------------------------------------------

function Editor:Build()
    if f then return end

    f = CreateFrame("Frame", "COA_LandmarksEditor", UIParent)
    f:SetWidth(320); f:SetHeight(348)
    f:SetPoint("CENTER", 200, 0)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(s) s:StartMoving() end)
    f:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() end)
    f:SetFrameStrata("DIALOG")
    f:Hide()

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOP", 0, -14)

    -- the id, shown small and unselectable-looking: it is what the file is
    -- keyed by, and seeing it makes the stored data legible (AC-47).
    f.id = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.id:SetPoint("TOP", 0, -30)

    label(f, "Name", 18, -50)
    f.alias = line(f, "COA_LandmarksEditorAlias", 60, -48, 240)
    f.alias:SetScript("OnTextChanged", function(s)
        if currentId then Store.Set(currentId, "alias", s:GetText()) end
        f.title:SetText(s:GetText() or "")
        NS.Widget:Refresh()
    end)

    label(f, "What:", 18, -76)
    f.what = line(f, "COA_LandmarksEditorWhat", 60, -74, 240)
    f.what:SetScript("OnTextChanged", function(s)
        if currentId then Store.Set(currentId, "what", s:GetText()) end
    end)

    label(f, "Why:", 18, -102)
    -- a PAGE, not a line. The space is not rationed once you are writing.
    f.whyBox = CreateFrame("Frame", nil, f)
    f.whyBox:SetPoint("TOPLEFT", 60, -100); f.whyBox:SetWidth(244); f.whyBox:SetHeight(74)
    f.whyBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f.whyBox:SetBackdropColor(0, 0, 0, 0.5)
    f.why = CreateFrame("EditBox", nil, f.whyBox)
    f.why:SetPoint("TOPLEFT", 6, -6); f.why:SetPoint("BOTTOMRIGHT", -6, 6)
    f.why:SetMultiLine(true)
    f.why:SetAutoFocus(false)
    f.why:SetFontObject(GameFontHighlightSmall)
    f.why:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
    f.why:SetScript("OnTextChanged", function(s)
        if currentId then Store.Set(currentId, "why", s:GetText()) end
    end)

    label(f, "Beacon hide:", 18, -184)
    f.tiers = {}
    for i, t in ipairs(Store.TIERS) do
        local r = CreateFrame("CheckButton", "COA_LandmarksTier" .. i, f, "UIRadioButtonTemplate")
        r:SetPoint("TOPLEFT", 24, -200 - (i - 1) * 18)
        local fs = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("LEFT", r, "RIGHT", 4, 0)
        fs:SetText(("%s   |cff888888%d yd|r"):format(t.label, t.yards))
        r.tierKey = t.key
        r:SetScript("OnClick", function(self)
            if currentId then Store.Set(currentId, "tier", self.tierKey) end
            Editor:RefreshTiers()
        end)
        f.tiers[i] = r
    end

    label(f, "Tags:", 18, -262)
    f.tags = line(f, "COA_LandmarksEditorTags", 60, -260, 240)

    -- GHOST TEXT (Battlewrath): "I can see a case where users write `vendors pvp
    -- get 50k honor` and not know how to use the tags… Maybe as ghost text on
    -- the tag field until they input content. Seeing this across land marks will
    -- engrain it."
    --
    -- ★ This is the ONE place instruction is right, and the boundary is worth
    -- stating: L18 asks whether we can DO the thing instead of TELLING - and here
    -- we cannot. Inserting commas at spaces would be altering their input, which
    -- AC-54 forbids outright. With no behavioural fix available and a SILENT
    -- failure on the other side (one long tag, a filter that never groups, and
    -- nothing ever saying why), a label at the point of use is the honest answer.
    --
    -- The bar it has to clear, and does: in situ, self-erasing on first keystroke,
    -- zero persistent noise, and taught by repetition rather than by a tutorial.
    -- It is a field label, not a lesson.
    f.tagsGhost = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.tagsGhost:SetPoint("LEFT", f.tags, "LEFT", 2, 0)
    f.tagsGhost:SetText("separate with ,  or press enter / tab")
    f.tagsGhost:SetJustifyH("LEFT")
    -- AC-54a: Tab and Enter ACCEPT the proposal, and BOTH leave a trailing
    -- separator. Battlewrath: "both end in , - so the user can't be caught out.
    -- We have to assume they don't know how tags work. And it should be - type
    -- away, not learn our system."
    --
    -- That is the rule, and it is why the two keys do the SAME thing here: a
    -- difference between them would be a rule that exists only inside this
    -- addon, and the user would have to learn it to avoid being surprised. The
    -- only thing Enter adds is dropping focus, which is what Enter means
    -- everywhere else. (L18 applied to an input.)
    local function accept(box, keepFocus)
        box:HighlightText(0, 0)                  -- the proposal becomes plain text
        local text = box:GetText() or ""
        if text ~= "" and not text:match(",%s*$") then
            box.suppress = true
            box:SetText(text .. ", ")
            box.suppress = false
            text = box:GetText()
        end
        box:SetCursorPosition(#text)
        box.lastLen = #text
        if currentId then Store.Set(currentId, "tags", text) end
        Editor:RefreshGhost()
        if not keepFocus then box:ClearFocus() end
    end

    f.tags:SetScript("OnTabPressed",   function(s) accept(s, true)  end)
    f.tags:SetScript("OnEnterPressed", function(s) accept(s, false) end)

    f.tags:SetScript("OnTextChanged", function(s, userInput)
        -- AC-54: stored EXACTLY as typed. No trimming, no case-folding, no
        -- merging. Splitting happens on READ, never here.
        if s.suppress then return end
        local text = s:GetText() or ""
        if currentId then Store.Set(currentId, "tags", text) end
        Editor:RefreshGhost()

        -- Complete only when the user ADDED characters. Completing on a delete
        -- makes the box fight you: backspace, get the letter back, forever.
        local grew = #text > (s.lastLen or 0)
        s.lastLen = #text
        if userInput and grew then tryComplete(s) end
    end)

    -- AC-5 / AC-46: the OWNER control. Promotion and demotion are the same
    -- operation - write one field - so this is a two-option dropdown and
    -- nothing more. Same stock UIDropDownMenu the client's own bug-report
    -- selector uses (BugReportFrameMixin.lua:69).
    label(f, "Visible to:", 18, -290)
    f.owner = CreateFrame("Frame", "COA_LandmarksEditorOwner", f, "UIDropDownMenuTemplate")
    f.owner:SetPoint("TOPLEFT", 68, -286)
    UIDropDownMenu_SetWidth(f.owner, 180)
    UIDropDownMenu_Initialize(f.owner, function()
        local lm = currentId and Store.Get(currentId)
        local me = UnitName("player")

        local info = UIDropDownMenu_CreateInfo()
        info.text = "All characters"
        info.value = Store.GLOBAL
        info.checked = lm and lm.owner == Store.GLOBAL
        info.func = function()
            Store.SetOwner(currentId, true)
            Editor:RefreshOwner(); NS.Pins:Refresh()
        end
        UIDropDownMenu_AddButton(info)

        -- Named, not "this character": demoting a global CLAIMS it for whoever
        -- is standing here (AC-46), and the label should say so rather than
        -- leave it to be discovered.
        info = UIDropDownMenu_CreateInfo()
        info.text = "Only " .. me
        info.value = me
        info.checked = lm and lm.owner ~= Store.GLOBAL
        info.func = function()
            Store.SetOwner(currentId, false)
            Editor:RefreshOwner(); NS.Pins:Refresh()
        end
        UIDropDownMenu_AddButton(info)
    end)

    f.delete = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.delete:SetWidth(80); f.delete:SetHeight(20)
    f.delete:SetPoint("BOTTOMLEFT", 16, 14)
    f.delete:SetText("Delete")
    f.delete:SetScript("OnClick", function()
        if not currentId then return end
        local lm = Store.Get(currentId)
        StaticPopupDialogs["COA_LANDMARKS_DELETE"] = {
            text = "Delete |cffffd100" .. (lm and lm.alias or "?") .. "|r?",
            button1 = YES, button2 = NO, timeout = 0, whileDead = 1, hideOnEscape = 1,
            OnAccept = function()
                Store.Delete(currentId)          -- AC-51: hard delete, no tombstone
                if NS.Widget:Held() == currentId then NS.Widget:Hold(nil) end
                Editor:Close(); NS.Pins:Refresh()
            end,
        }
        StaticPopup_Show("COA_LANDMARKS_DELETE")
    end)

    f.close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.close:SetWidth(80); f.close:SetHeight(20)
    f.close:SetPoint("BOTTOMRIGHT", -16, 14)
    f.close:SetText("Close")
    f.close:SetScript("OnClick", function() Editor:Close() end)
end

-- Shown only while the field is EMPTY - including while focused, which is
-- exactly when someone about to type needs to see the format.
function Editor:RefreshGhost()
    if not f then return end
    if (f.tags:GetText() or "") == "" then f.tagsGhost:Show() else f.tagsGhost:Hide() end
end

function Editor:RefreshOwner()
    local lm = currentId and Store.Get(currentId)
    if not lm then return end
    UIDropDownMenu_SetText(f.owner,
        lm.owner == Store.GLOBAL and "All characters" or ("Only " .. tostring(lm.owner)))
    UIDropDownMenu_SetSelectedValue(f.owner, lm.owner)
end

function Editor:RefreshTiers()
    local lm = currentId and Store.Get(currentId)
    for _, r in ipairs(f.tiers) do
        r:SetChecked(lm and lm.tier == r.tierKey)
    end
end

function Editor:Open(id)
    self:Build()
    local lm = Store.Get(id); if not lm then return end
    currentId = id

    -- AC-36a: organising is not travelling.
    NS.Beacon.Clear()
    NS.Widget:Refresh()

    f.title:SetText(lm.alias or "?")
    f.id:SetText(id)
    f.alias:SetText(lm.alias or "")
    f.what:SetText(lm.what or "")
    f.why:SetText(lm.why or "")
    f.tags.suppress = true
    f.tags:SetText(lm.tags or "")
    f.tags.suppress = false
    self:RefreshTiers()
    self:RefreshOwner()
    self:RefreshGhost()
    f.tags.lastLen = #(lm.tags or "")
    f:Show()
end

function Editor:Close()
    if not f then return end
    currentId = nil
    f:Hide()
    NS.Pins:Refresh()
    NS.Widget:Refresh()
end

return Editor
