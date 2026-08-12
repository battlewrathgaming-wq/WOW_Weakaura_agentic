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

local function line(parent, x, y, w)
    local e = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    e:SetPoint("TOPLEFT", x, y); e:SetWidth(w); e:SetHeight(18)
    e:SetAutoFocus(false)
    e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return e
end

-- ---------------------------------------------------------------------
-- Tag autocomplete. AC-54a: it OFFERS, it never CORRECTS.
-- ---------------------------------------------------------------------

-- The partial tag is whatever follows the last comma - people type
-- "vendor, alt|" and expect the suggestion to be about "alt".
local function partialTag(s)
    return (tostring(s or ""):match("([^,]*)$") or ""):match("^%s*(.-)%s*$")
end

local function applySuggestion(tag)
    local s = f.tags:GetText() or ""
    local head = s:match("^(.*,)%s*[^,]*$")
    f.tags:SetText((head and (head .. " ") or "") .. tag .. ", ")
    f.tags:SetCursorPosition(#f.tags:GetText())
    Store.Set(currentId, "tags", f.tags:GetText())
    Editor:RefreshSuggestions()
end

function Editor:RefreshSuggestions()
    for _, b in ipairs(f.sugg) do b:Hide() end
    if not currentId then return end
    local hits = Store.SuggestTags(partialTag(f.tags:GetText()), currentId)
    for i = 1, math.min(#hits, 4) do
        local b = f.sugg[i]
        b:SetText(hits[i])
        b:SetWidth(b:GetFontString():GetStringWidth() + 16)
        b.tag = hits[i]
        b:Show()
    end
end

-- ---------------------------------------------------------------------

function Editor:Build()
    if f then return end

    f = CreateFrame("Frame", "COA_LandmarksEditor", UIParent)
    f:SetWidth(320); f:SetHeight(330)
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
    f.alias = line(f, 60, -48, 240)
    f.alias:SetScript("OnTextChanged", function(s)
        if currentId then Store.Set(currentId, "alias", s:GetText()) end
        f.title:SetText(s:GetText() or "")
        NS.Widget:Refresh()
    end)

    label(f, "What:", 18, -76)
    f.what = line(f, 60, -74, 240)
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
    f.tags = line(f, 60, -260, 240)
    f.tags:SetScript("OnTextChanged", function(s)
        -- AC-54: stored EXACTLY as typed. No trimming, no case-folding, no
        -- merging. Splitting happens on READ, never here.
        if currentId then Store.Set(currentId, "tags", s:GetText()) end
        Editor:RefreshSuggestions()
    end)

    f.sugg = {}
    for i = 1, 4 do
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetHeight(16)
        b:SetPoint("TOPLEFT", 58 + (i - 1) * 62, -282)
        b:SetScript("OnClick", function(self) applySuggestion(self.tag) end)
        b:Hide()
        f.sugg[i] = b
    end

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
    f.tags:SetText(lm.tags or "")
    self:RefreshTiers()
    self:RefreshSuggestions()
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
