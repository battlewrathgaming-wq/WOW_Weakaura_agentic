-- COA_Landmarks pins.lua - world-map pins (AC-31 .. AC-36).
--
--   hover  -> the note readout, via WorldMapTooltip (AC-33, F15)
--   click  -> GO: hold it and pin the beacon (AC-36)
--   right  -> EDIT, which also clears live tracking (AC-36a)
--
-- Hover already covers reading, so a click is a COMMITMENT gesture rather than
-- a browsing one - which is why it may take the slot without breaching L13.
--
-- AC-35: nothing happens while the world map is hidden, and we rebuild on
-- EVENT, not on a timer. No pooling and no per-frame reposition loop - frame
-- lifecycle machinery is out of bounds; we hold a small fixed set and hide the
-- spares.

local ADDON, NS = ...
local Store = NS.Store

local Pins = {}
NS.Pins = Pins

local PIN_SIZE = 20          -- AC-32: ONE size for every landmark pin, whatever
                             -- an atlas entry's native dimensions are.
local pins = {}

-- ---------------------------------------------------------------------

-- ★★ FACT: AtlasInfo[name] = {texture,w,h,left,right,top,bottom,flipH,flipV} - and
--   SetAtlas additionally FORCES the atlas's native size and FAILS SILENTLY under
--   pcall. ⚠ Texture + SetTexCoord read straight off AtlasInfo is deterministic.
-- Read the atlas registry DIRECTLY rather than going through SetAtlas.
--   AtlasInfo[name] = { texture, w, h, left, right, top, bottom, flipH, flipV }
-- SetAtlas also applies the atlas's NATIVE size unless passed a flag whose
-- constant lives somewhere we cannot see from here - and a pcall around it
-- fails silently, which is exactly how a pin ends up wrong-sized or blank with
-- nothing said. Texture + tex-coords is deterministic and needs no API we have
-- not verified. AC-32: one size for every pin, whatever the entry declares.
local function setIcon(tex, atlas)
    local info = _G.AtlasInfo and AtlasInfo[atlas]
    if info then
        tex:SetTexture(info[1])
        tex:SetTexCoord(info[4], info[5], info[6], info[7])
        return true
    end
    -- AC-43: no silent anything. If the registry has no such entry we say so
    -- once, rather than drawing nothing and leaving it to be noticed.
    if not NS.warnedAtlas then
        NS.warnedAtlas = true
        NS.Print(("|cffff4444atlas '%s' is not in AtlasInfo|r - pins will not draw"):format(
            tostring(atlas)))
    end
    return false
end

local function showNote(self)
    local lm = Store.Get(self.lmId); if not lm then return end
    WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT")
    WorldMapTooltip:SetText(lm.alias or "?", 1, 0.82, 0)

    -- ★★★ RULING: the note is PULLED on hover - NOTHING announces itself on approach
    --   ★ The core anti-nag law. A proximity popup is the thing this addon exists
    --   not to be.
    -- AC-33 / L12: the note is PULLED. Nothing announces itself on approach;
    -- you read it because you asked.
    if lm.what ~= "" then WorldMapTooltip:AddLine(lm.what, 1, 1, 1, true) end
    if lm.why ~= "" then
        WorldMapTooltip:AddLine(" ")
        WorldMapTooltip:AddLine(lm.why, 0.8, 0.8, 0.8, true)
    end
    local tags = Store.SplitTags(lm.tags)
    if #tags > 0 then
        WorldMapTooltip:AddLine(" ")
        WorldMapTooltip:AddLine(table.concat(tags, "  ·  "), 0.4, 0.7, 1, true)
    end
    if lm.owner == Store.GLOBAL then
        WorldMapTooltip:AddLine("all characters", 0.5, 0.5, 0.5)
    elseif not Store.IsMine(lm) then
        -- only visible in the show-all recovery view; say WHOSE it is, since
        -- that is the whole reason you are looking at it.
        WorldMapTooltip:AddLine(tostring(lm.owner), 1, 0.53, 0)
    end
    WorldMapTooltip:AddLine(" ")
    WorldMapTooltip:AddLine("Click to go  ·  Right-click to edit", 0, 1, 0)
    WorldMapTooltip:Show()
end

local function onClick(self, button)
    local id = self.lmId
    if button == "RightButton" then
        -- AC-36a: you cannot be travelling to something you are organising.
        -- Different modes (L17), and opening the form is the user act that
        -- makes the clear legitimate (L13).
        NS.Beacon.Clear()
        NS.Widget:Hold(id)
        NS.Editor:Open(id)
    else
        -- AC-36: click = GO.
        NS.Widget:Hold(id)
        NS.Widget:Show()
        local ok, err = NS.Beacon.Pin(id)
        if not ok then NS.Print("could not pin - " .. tostring(err)) end
    end
    NS.Widget:Refresh()
end

local function acquire(i)
    if pins[i] then return pins[i] end
    local p = CreateFrame("Button", "COA_LandmarksPin" .. i, WorldMapButton)
    p:SetWidth(PIN_SIZE); p:SetHeight(PIN_SIZE)
    p:SetFrameLevel(WorldMapButton:GetFrameLevel() + 10)
    p.icon = p:CreateTexture(nil, "OVERLAY")
    p.icon:SetAllPoints(p)
    p:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    p:SetScript("OnEnter", showNote)
    p:SetScript("OnLeave", function() WorldMapTooltip:Hide() end)
    p:SetScript("OnClick", onClick)
    p:Hide()
    pins[i] = p
    return p
end

-- ---------------------------------------------------------------------

function Pins:Refresh()
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end   -- AC-35
    if Store.locked then return end

    local c = GetCurrentMapContinent and GetCurrentMapContinent() or nil
    local z = GetCurrentMapZone and GetCurrentMapZone() or nil
    local w, h = WorldMapButton:GetWidth(), WorldMapButton:GetHeight()

    local n = 0
    -- AC-50: iterate. The scale is bounded by the product (L11) - regions of
    -- activity, not per-node tracking.
    for _, e in ipairs(Store.Visible()) do
        local lm = e.lm
        -- AC-34: only the map actually being displayed. A fraction belongs to
        -- the map it was taken on, so BOTH indices must match - `mapID` alone
        -- is the continent and would scatter pins across every zone in it.
        if lm.mapX and lm.mapC == c and lm.mapZ == z then
            n = n + 1
            local p = acquire(n)
            p.lmId = e.id
            setIcon(p.icon, lm.icon or Store.DEFAULT_ICON)
            -- AC-31: pixel offsets from WorldMapButton's TOPLEFT - our stored
            -- fraction times the frame size lands directly (F15).
            p:ClearAllPoints()
            p:SetPoint("CENTER", WorldMapButton, "TOPLEFT", lm.mapX * w, -(lm.mapY * h))
            p:Show()
        end
    end

    for i = n + 1, #pins do pins[i]:Hide() end
end

function Pins:Init()
    -- ★★ FACT: WORLD_MAP_UPDATE fires whenever the DISPLAYED map changes - the correct
    --   rebuild trigger, and no timer is needed.
    -- AC-35: rebuild on EVENT, not on a timer. WORLD_MAP_UPDATE fires whenever
    -- the displayed map changes, which is exactly when our answer changes.
    local f = CreateFrame("Frame")
    f:RegisterEvent("WORLD_MAP_UPDATE")
    f:SetScript("OnEvent", function() Pins:Refresh() end)

    if WorldMapFrame then
        WorldMapFrame:HookScript("OnShow", function() Pins:Refresh() end)
    end
end

return Pins
