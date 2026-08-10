-- Layout import/export — compact !Leti share strings (WA-style, not human-readable).
-- !Leti:1! = geometry only; !Leti:2! = geometry + bar/font/colors.
-- Payload: tight binary (i24 offsets, u8 scales/alphas, u16 bar size) + base64.
-- Hyphens are display-only; copied string is one compact line.
Mancer.LayoutExportModule = {}
local LayoutExport = Mancer.LayoutExportModule

LayoutExport.VERSION_LAYOUT = 1
LayoutExport.VERSION_FULL = 2
LayoutExport.MAGIC = "!Leti:"
LayoutExport.CHUNK_SIZE = 8

local bit = bit or bit32

local OFFSET_KEYS = {
    "anchorX", "anchorY",
    "advisorX", "advisorY",
    "animateX", "animateY",
    "zombieX", "zombieY",
    "procX", "procY",
    "minionHpX", "minionHpY",
    "helpX", "helpY",
}

local SCALE_U8_KEYS = {
    "scale", "animateScale", "zombieScale", "procScale", "advisorScale",
}

local ALPHA_U8_KEYS = {
    "arcAlpha", "animateAlpha", "zombieAlpha", "procAlpha", "minionHpAlpha",
}

local APPEARANCE_FIELDS = {
    "barTex", "minionBarTex", "fontIdx", "fontSize",
    "manaR", "manaG", "manaB", "healthR", "healthG", "healthB",
    "runicR", "runicG", "runicB",
}

-- layout-only 60 bytes; full look 73 bytes → ~88 / ~106 chars copied (+8 prefix).
LayoutExport.BINARY_LAYOUT_SIZE = 60
LayoutExport.BINARY_FULL_SIZE = 73

local MIN_SCALE = 0.5
local MAX_SCALE = 2.0
local MIN_BAR_DIM = 0.25
local MAX_BAR_DIM = 6.0
local MAX_BAR_OFFSET = 2000
local MAX_ELEMENT_OFFSET = 4000
local MIN_FONT = 12
local MAX_FONT = 48

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function Notify(msg)
    if Mancer and Mancer.Hub and Mancer.Hub.Notify then
        Mancer.Hub:Notify(msg)
    elseif Mancer and Mancer.Print then
        Mancer.Print(msg)
    end
end

local function Clamp(n, lo, hi)
    n = tonumber(n) or lo
    if n < lo then
        return lo
    end
    if n > hi then
        return hi
    end
    return n
end

local function Round100(value)
    local n = tonumber(value) or 0
    if n >= 0 then
        return math.floor(n * 100 + 0.5)
    end
    return math.ceil(n * 100 - 0.5)
end

local function OffsetTable(x, y)
    return { x = tonumber(x) or 0, y = tonumber(y) or 0 }
end

local function ColorFromBytes(r, g, b)
    return {
        Clamp(r, 0, 255) / 255,
        Clamp(g, 0, 255) / 255,
        Clamp(b, 0, 255) / 255,
    }
end

local function ColorToBytes(color)
    color = color or {}
    return
        Clamp((color[1] or 0) * 255, 0, 255),
        Clamp((color[2] or 0) * 255, 0, 255),
        Clamp((color[3] or 0) * 255, 0, 255)
end

local function GetBarTextureIndex()
    local path = Mancer.NormalizeBarTexturePath(MancerDB.barTexture or Mancer.BAR_TEXTURES[1].path)
    for i, entry in ipairs(Mancer.BAR_TEXTURES or {}) do
        if entry.path == path then
            return i
        end
    end
    return 1
end

local function GetFontIndex()
    local path = Mancer.ResolveFontFile(MancerDB.fontFile)
    for i, font in ipairs(Mancer.FONTS or {}) do
        if font.path == path then
            return i
        end
    end
    return 1
end

local function FlattenImportString(text)
    if type(text) ~= "string" then
        return ""
    end
    return text:gsub("%s+", ""):gsub("-", "")
end

local function FlattenCopyString(text)
    if type(text) ~= "string" then
        return ""
    end
    return text:gsub("%s+", "")
end

local function PackU8(n)
    return string.char(Clamp(n, 0, 255))
end

local function UnpackU8(data, pos)
    return string.byte(data, pos) or 0, pos + 1
end

local function PackI24(n)
    n = math.floor(tonumber(n) or 0)
    if n > 8388607 then
        n = 8388607
    elseif n < -8388608 then
        n = -8388608
    end
    if bit and bit.band and bit.rshift then
        if n < 0 then
            n = n + 16777216
        end
        return string.char(
            bit.band(n, 0xFF),
            bit.band(bit.rshift(n, 8), 0xFF),
            bit.band(bit.rshift(n, 16), 0xFF)
        )
    end
    if n < 0 then
        n = n + 16777216
    end
    return string.char(n % 256, math.floor(n / 256) % 256, math.floor(n / 65536) % 256)
end

local function UnpackI24(data, pos)
    local b1, b2, b3 = string.byte(data, pos, pos + 2)
    b1, b2, b3 = b1 or 0, b2 or 0, b3 or 0
    local n = b1 + b2 * 256 + b3 * 65536
    if n >= 8388608 then
        n = n - 16777216
    end
    return n, pos + 3
end

local function PackU16(n)
    n = Clamp(math.floor(tonumber(n) or 0), 0, 65535)
    return string.char(n % 256, math.floor(n / 256) % 256)
end

local function UnpackU16(data, pos)
    local b1, b2 = string.byte(data, pos, pos + 1)
    b1, b2 = b1 or 0, b2 or 0
    return b1 + b2 * 256, pos + 2
end

local function PackI16(n)
    n = math.floor(tonumber(n) or 0)
    if n > 32767 then
        n = 32767
    elseif n < -32768 then
        n = -32768
    end
    if n < 0 then
        n = n + 65536
    end
    return string.char(n % 256, math.floor(n / 256) % 256)
end

local function UnpackI16(data, pos)
    local b1, b2 = string.byte(data, pos, pos + 1)
    b1, b2 = b1 or 0, b2 or 0
    local n = b1 + b2 * 256
    if n >= 32768 then
        n = n - 65536
    end
    return n, pos + 2
end

local function Base64Encode(data)
    local out = {}
    local i = 1
    local len = #data
    while i <= len do
        local a = string.byte(data, i) or 0
        local b = string.byte(data, i + 1) or 0
        local c = string.byte(data, i + 2) or 0
        local n = a * 65536 + b * 256 + c
        local c1 = math.floor(n / 262144) % 64 + 1
        local c2 = math.floor(n / 4096) % 64 + 1
        local c3 = math.floor(n / 64) % 64 + 1
        local c4 = n % 64 + 1
        out[#out + 1] = B64:sub(c1, c1)
        out[#out + 1] = B64:sub(c2, c2)
        if i + 1 <= len then
            out[#out + 1] = B64:sub(c3, c3)
        else
            out[#out + 1] = "="
        end
        if i + 2 <= len then
            out[#out + 1] = B64:sub(c4, c4)
        else
            out[#out + 1] = "="
        end
        i = i + 3
    end
    return table.concat(out)
end

local function Base64Decode(str)
    str = str:gsub("=", "")
    local pad = (4 - (#str % 4)) % 4
    str = str .. string.rep("=", pad)
    local map = {}
    for i = 1, #B64 do
        map[B64:sub(i, i)] = i - 1
    end
    local out = {}
    local i = 1
    while i <= #str do
        local c1 = map[str:sub(i, i)]
        local c2 = map[str:sub(i + 1, i + 1)]
        local c3 = map[str:sub(i + 2, i + 2)]
        local c4 = map[str:sub(i + 3, i + 3)]
        if not c1 or not c2 then
            break
        end
        c3 = c3 or 0
        c4 = c4 or 0
        local n = c1 * 262144 + c2 * 4096 + c3 * 64 + c4
        out[#out + 1] = string.char(math.floor(n / 65536) % 256)
        if str:sub(i + 2, i + 2) ~= "" and map[str:sub(i + 2, i + 2)] then
            out[#out + 1] = string.char(math.floor(n / 256) % 256)
        end
        if str:sub(i + 3, i + 3) ~= "" and map[str:sub(i + 3, i + 3)] then
            out[#out + 1] = string.char(n % 256)
        end
        i = i + 4
    end
    return table.concat(out)
end

local function ChunkBody(body, chunkSize)
    chunkSize = chunkSize or LayoutExport.CHUNK_SIZE
    local parts = {}
    for i = 1, #body, chunkSize do
        parts[#parts + 1] = body:sub(i, i + chunkSize - 1)
    end
    return table.concat(parts, "-")
end

local function FormatForDisplay(code)
    local head, body = code:match("^(!Leti:%d!)(.+)$")
    if not head or not body then
        return code
    end
    body = ChunkBody(body, LayoutExport.CHUNK_SIZE)
    local lines = { head }
    local width = (LayoutExport.CHUNK_SIZE * 4) + 3
    for i = 1, #body, width do
        lines[#lines + 1] = body:sub(i, i + width - 1)
    end
    return table.concat(lines, "\n")
end

function LayoutExport:CollectPayload(includeAppearance)
    local db = MancerDB or {}
    local bt = db.barTransform and db.barTransform.unified or {}
    local adv = db.advisorTextOffset or {}
    local anim = db.animateBarOffset or {}
    local zom = db.zombieCounterOffset or {}
    local proc = db.procBarOffset or {}
    local minHp = db.minionHpListOffset or {}
    local help = db.moveHelpOffset or {}

    local payload = {
        anchorX = db.anchorX or 0,
        anchorY = db.anchorY or 80,
        scale = db.scale or 1.25,
        advisorX = adv.x or 0,
        advisorY = adv.y or 28,
        animateX = anim.x or 0,
        animateY = anim.y or -40,
        zombieX = zom.x or 56,
        zombieY = zom.y or -40,
        procX = proc.x or -56,
        procY = proc.y or -40,
        minionHpX = minHp.x or 90,
        minionHpY = minHp.y or 20,
        helpX = help.x or 0,
        helpY = help.y or -160,
        animateScale = db.animateIconScale or 1.25,
        zombieScale = db.zombieIconScale or 1.15,
        procScale = db.procIconScale or 1.15,
        advisorScale = db.advisorTextScale or 1.0,
        barWidth = bt.width or 1.0,
        barHeight = bt.height or 1.0,
        barOffX = bt.offsetX or 0,
        barOffY = bt.offsetY or 0,
        arcAlpha = db.arcBarAlpha or 1.0,
        animateAlpha = db.animateBarAlpha or 1.0,
        zombieAlpha = db.zombieCounterAlpha or 1.0,
        procAlpha = db.procBarAlpha or 1.0,
        minionHpAlpha = db.minionHpListAlpha or 1.0,
    }

    if includeAppearance then
        local mR, mG, mB = ColorToBytes(db.manaColor)
        local hR, hG, hB = ColorToBytes(db.healthColor)
        local rR, rG, rB = ColorToBytes(db.runicColor)
        payload.barTex = GetBarTextureIndex()
        payload.minionBarTex = Clamp(db.minionHpBarTextureIndex or 1, 1, 4)
        payload.fontIdx = GetFontIndex()
        payload.fontSize = Clamp(db.fontSize or 22, MIN_FONT, MAX_FONT)
        payload.manaR, payload.manaG, payload.manaB = mR, mG, mB
        payload.healthR, payload.healthG, payload.healthB = hR, hG, hB
        payload.runicR, payload.runicG, payload.runicB = rR, rG, rB
    end

    return payload
end

function LayoutExport:PackBinary(payload, version)
    local chunks = {}
    for _, key in ipairs(OFFSET_KEYS) do
        chunks[#chunks + 1] = PackI24(Round100(payload[key]))
    end
    for _, key in ipairs(SCALE_U8_KEYS) do
        chunks[#chunks + 1] = PackU8(Round100(payload[key]))
    end
    chunks[#chunks + 1] = PackU16(Round100(payload.barWidth))
    chunks[#chunks + 1] = PackU16(Round100(payload.barHeight))
    chunks[#chunks + 1] = PackI16(Round100(payload.barOffX))
    chunks[#chunks + 1] = PackI16(Round100(payload.barOffY))
    for _, key in ipairs(ALPHA_U8_KEYS) do
        chunks[#chunks + 1] = PackU8(Round100(payload[key]))
    end
    if version >= self.VERSION_FULL then
        for _, key in ipairs(APPEARANCE_FIELDS) do
            chunks[#chunks + 1] = PackU8(payload[key])
        end
    end
    return table.concat(chunks)
end

function LayoutExport:UnpackBinary(data, version)
    local expected = self.BINARY_LAYOUT_SIZE
    if version >= self.VERSION_FULL then
        expected = self.BINARY_FULL_SIZE
    end
    if #data < expected then
        return nil, "Layout data is truncated."
    end

    local pos = 1
    local payload = { version = version }
    local n

    for _, key in ipairs(OFFSET_KEYS) do
        n, pos = UnpackI24(data, pos)
        payload[key] = n / 100
    end
    for _, key in ipairs(SCALE_U8_KEYS) do
        n, pos = UnpackU8(data, pos)
        payload[key] = n / 100
    end
    n, pos = UnpackU16(data, pos)
    payload.barWidth = n / 100
    n, pos = UnpackU16(data, pos)
    payload.barHeight = n / 100
    n, pos = UnpackI16(data, pos)
    payload.barOffX = n / 100
    n, pos = UnpackI16(data, pos)
    payload.barOffY = n / 100
    for _, key in ipairs(ALPHA_U8_KEYS) do
        n, pos = UnpackU8(data, pos)
        payload[key] = n / 100
    end

    if version >= self.VERSION_FULL then
        for _, key in ipairs(APPEARANCE_FIELDS) do
            n, pos = UnpackU8(data, pos)
            payload[key] = n
        end
    end

    return payload
end

function LayoutExport:EncodePayload(payload, version)
    version = tonumber(version) or self.VERSION_LAYOUT
    local binary = self:PackBinary(payload, version)
    local b64 = Base64Encode(binary):gsub("=+$", "")
    return self.MAGIC .. tostring(version) .. "!" .. b64
end

function LayoutExport:ExportString(includeAppearance, opts)
    opts = opts or {}
    local version = includeAppearance and self.VERSION_FULL or self.VERSION_LAYOUT
    local payload = self:CollectPayload(includeAppearance)
    local code = self:EncodePayload(payload, version)
    if opts.pretty then
        return FormatForDisplay(code)
    end
    return code
end

function LayoutExport:ExportCopyString(includeAppearance)
    return self:ExportString(includeAppearance, { pretty = false })
end

function LayoutExport:DecodeString(text)
    if type(text) ~= "string" or text == "" then
        return nil, "Empty layout string."
    end

    text = FlattenImportString(text)
    local version, body = text:match("^" .. self.MAGIC .. "(%d)!(.+)$")
    version = tonumber(version)
    if not version or not body then
        return nil, "Not a Libellus Leti layout string (expected !Leti:1! or !Leti:2!)."
    end
    if version ~= self.VERSION_LAYOUT and version ~= self.VERSION_FULL then
        return nil, "Unsupported layout version: " .. tostring(version)
    end

    local binary = Base64Decode(body)
    if not binary or binary == "" then
        return nil, "Layout string could not be decoded."
    end

    return self:UnpackBinary(binary, version)
end

function LayoutExport:ApplyPayload(payload)
    if type(payload) ~= "table" then
        return false, "Invalid layout data."
    end

    MancerDB = MancerDB or {}
    local db = MancerDB

    db.anchorX = Clamp(payload.anchorX, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET)
    db.anchorY = Clamp(payload.anchorY, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET)
    db.scale = Clamp(payload.scale, MIN_SCALE, MAX_SCALE)

    db.advisorTextOffset = OffsetTable(
        Clamp(payload.advisorX, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET),
        Clamp(payload.advisorY, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET)
    )
    db.animateBarOffset = OffsetTable(
        Clamp(payload.animateX, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET),
        Clamp(payload.animateY, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET)
    )
    db.zombieCounterOffset = OffsetTable(
        Clamp(payload.zombieX, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET),
        Clamp(payload.zombieY, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET)
    )
    db.procBarOffset = OffsetTable(
        Clamp(payload.procX, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET),
        Clamp(payload.procY, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET)
    )
    db.minionHpListOffset = OffsetTable(
        Clamp(payload.minionHpX, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET),
        Clamp(payload.minionHpY, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET)
    )
    db.moveHelpOffset = OffsetTable(
        Clamp(payload.helpX, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET),
        Clamp(payload.helpY, -MAX_ELEMENT_OFFSET, MAX_ELEMENT_OFFSET)
    )

    db.animateIconScale = Clamp(payload.animateScale, MIN_SCALE, MAX_SCALE)
    db.zombieIconScale = Clamp(payload.zombieScale, MIN_SCALE, MAX_SCALE)
    db.procIconScale = Clamp(payload.procScale, MIN_SCALE, MAX_SCALE)
    db.advisorTextScale = Clamp(payload.advisorScale, MIN_SCALE, MAX_SCALE)

    db.barTransform = db.barTransform or {}
    local barW = Clamp(payload.barWidth, MIN_BAR_DIM, MAX_BAR_DIM)
    local barH = Clamp(payload.barHeight, MIN_BAR_DIM, MAX_BAR_DIM)
    db.barTransform.unified = {
        scale = (barW + barH) * 0.5,
        width = barW,
        height = barH,
        offsetX = Clamp(payload.barOffX, -MAX_BAR_OFFSET, MAX_BAR_OFFSET),
        offsetY = Clamp(payload.barOffY, -MAX_BAR_OFFSET, MAX_BAR_OFFSET),
    }

    db.arcBarAlpha = Clamp(payload.arcAlpha, 0, 1)
    db.animateBarAlpha = Clamp(payload.animateAlpha, 0, 1)
    db.zombieCounterAlpha = Clamp(payload.zombieAlpha, 0, 1)
    db.procBarAlpha = Clamp(payload.procAlpha, 0, 1)
    db.minionHpListAlpha = Clamp(payload.minionHpAlpha, 0, 1)

    if payload.version and payload.version >= self.VERSION_FULL then
        local barIdx = Clamp(payload.barTex or 1, 1, #(Mancer.BAR_TEXTURES or {}))
        if Mancer.BAR_TEXTURES and Mancer.BAR_TEXTURES[barIdx] then
            db.barTexture = Mancer.NormalizeBarTexturePath(Mancer.BAR_TEXTURES[barIdx].path)
        end
        db.minionHpBarTextureIndex = Clamp(payload.minionBarTex or 1, 1, 4)
        local fontIdx = Clamp(payload.fontIdx or 1, 1, #(Mancer.FONTS or {}))
        if Mancer.FONTS and Mancer.FONTS[fontIdx] then
            db.fontFile = Mancer.FONTS[fontIdx].path
        end
        db.fontSize = Clamp(payload.fontSize or 22, MIN_FONT, MAX_FONT)
        db.manaColor = ColorFromBytes(payload.manaR, payload.manaG, payload.manaB)
        db.healthColor = ColorFromBytes(payload.healthR, payload.healthG, payload.healthB)
        db.runicColor = ColorFromBytes(payload.runicR, payload.runicG, payload.runicB)
    end

    if Mancer.Refresh then
        Mancer:Refresh()
    end
    if Mancer.FloatingText and Mancer.FloatingText.ApplyConfig then
        Mancer.FloatingText:ApplyConfig()
    end
    if Mancer.Options and Mancer.Options.SyncControls then
        Mancer.Options:SyncControls()
    end

    return true
end

function LayoutExport:ImportString(text)
    local payload, err = self:DecodeString(text)
    if not payload then
        return false, err
    end
    return self:ApplyPayload(payload)
end

function LayoutExport:CopyToClipboard(text)
    text = FlattenCopyString(text)
    if Internal_CopyToClipboard then
        return pcall(Internal_CopyToClipboard, text)
    end
    return false
end

local function MakeCodeEditBox(parent, width, height)
    local box = CreateFrame("EditBox", nil, parent)
    box:SetAutoFocus(false)
    box:SetFontObject(GameFontHighlightSmall)
    box:SetMultiLine(true)
    box:SetWidth(width)
    box:SetHeight(height)
    box:SetTextInsets(4, 4, 4, 4)
    if box.SetBackdrop then
        box:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 12,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        box:SetBackdropColor(0.05, 0.05, 0.06, 0.95)
        box:SetBackdropBorderColor(0.3, 0.35, 0.38, 1)
    end
    box:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    return box
end

-- Mount share UI into Settings (same window as a tab). Replaces the old floating panel.
function LayoutExport:MountShareUI(host)
    if not host then
        return nil
    end
    if self.shareHost == host and self.exportBox then
        return host
    end

    -- Drop a leftover floating share window from older builds.
    local legacy = _G.MancerLayoutShareFrame
    if legacy then
        legacy:Hide()
        if legacy.SetParent then
            legacy:SetParent(nil)
        end
    end

    self.shareHost = host
    self.sharePanel = host

    local ui = Mancer.UI
    local L = Mancer.L or {}
    local boxW = 520

    local title = host:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
    title:SetWidth(boxW)
    title:SetJustifyH("LEFT")
    title:SetText(L["LAYOUT_SHARE_DESC"] or "Copy your layout code to share, or paste someone else's code below.")
    if ui and ui.StyleMuted then
        ui.StyleMuted(title)
    end
    host.desc = title

    local exportLabel = host:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    exportLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    exportLabel:SetText(L["LAYOUT_SHARE_EXPORT"] or "Your layout code")
    host.exportLabel = exportLabel

    local exportBox = MakeCodeEditBox(host, boxW, 72)
    exportBox:SetPoint("TOPLEFT", exportLabel, "BOTTOMLEFT", 0, -4)
    host.exportBox = exportBox
    self.exportBox = exportBox

    local fullCheck = CreateFrame("CheckButton", nil, host, "UICheckButtonTemplate")
    fullCheck:SetPoint("TOPLEFT", exportBox, "BOTTOMLEFT", -4, -6)
    fullCheck.text = fullCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fullCheck.text:SetPoint("LEFT", fullCheck, "RIGHT", 2, 0)
    fullCheck.text:SetText(L["LAYOUT_SHARE_INCLUDE_LOOK"] or "Include fonts, textures & colors (!Leti:2!)")
    host.fullCheck = fullCheck
    self.fullCheck = fullCheck

    local copyBtn = CreateFrame("Button", nil, host, "UIPanelButtonTemplate")
    copyBtn:SetSize(120, 22)
    copyBtn:SetPoint("TOPLEFT", fullCheck, "BOTTOMLEFT", 4, -8)
    copyBtn:SetText(L["LAYOUT_SHARE_COPY"] or "Copy Code")
    copyBtn:SetScript("OnClick", function()
        LayoutExport:RefreshShareExport()
        local includeLook = host.fullCheck and host.fullCheck:GetChecked()
        local text = LayoutExport:ExportCopyString(includeLook)
        if text == "" then
            Notify(L["LAYOUT_SHARE_EMPTY"] or "Nothing to copy yet.")
            return
        end
        if LayoutExport:CopyToClipboard(text) then
            Notify(L["LAYOUT_SHARE_COPIED"] or "Layout code copied — paste it in Discord or chat.")
        else
            exportBox:SetFocus()
            exportBox:HighlightText()
            Notify(L["LAYOUT_SHARE_SELECT"] or "Select the code above and press Ctrl+C.")
        end
    end)
    host.copyBtn = copyBtn

    local importLabel = host:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    importLabel:SetPoint("TOPLEFT", copyBtn, "BOTTOMLEFT", -4, -14)
    importLabel:SetText(L["LAYOUT_SHARE_IMPORT"] or "Paste layout code")
    host.importLabel = importLabel

    local importBox = MakeCodeEditBox(host, boxW, 72)
    importBox:SetPoint("TOPLEFT", importLabel, "BOTTOMLEFT", 0, -4)
    host.importBox = importBox

    local applyBtn = CreateFrame("Button", nil, host, "UIPanelButtonTemplate")
    applyBtn:SetSize(120, 22)
    applyBtn:SetPoint("TOPLEFT", importBox, "BOTTOMLEFT", 0, -8)
    applyBtn:SetText(L["LAYOUT_SHARE_APPLY"] or "Apply Layout")
    applyBtn:SetScript("OnClick", function()
        local ok, err = LayoutExport:ImportString(importBox:GetText() or "")
        if ok then
            Notify(L["LAYOUT_SHARE_APPLIED"] or "Layout applied.")
            LayoutExport:RefreshShareExport()
        else
            Notify(err or (L["LAYOUT_SHARE_FAILED"] or "Could not import layout."))
        end
    end)
    host.applyBtn = applyBtn

    local backBtn = CreateFrame("Button", nil, host, "UIPanelButtonTemplate")
    backBtn:SetSize(110, 22)
    backBtn:SetPoint("LEFT", applyBtn, "RIGHT", 8, 0)
    backBtn:SetText(L["LAYOUT_SHARE_BACK"] or "Back")
    backBtn:SetScript("OnClick", function()
        if Mancer.Options and Mancer.Options.SelectSettingsTab then
            Mancer.Options:SelectSettingsTab("display")
        end
    end)
    host.backBtn = backBtn

    fullCheck:SetScript("OnClick", function()
        LayoutExport:RefreshShareExport()
    end)

    return host
end

-- Back-compat for callers that still ask for a "panel".
function LayoutExport:EnsureSharePanel()
    if self.sharePanel and self.exportBox then
        return self.sharePanel
    end
    if Mancer.Options and Mancer.Options.tabPages and Mancer.Options.tabPages.share then
        return self:MountShareUI(Mancer.Options.tabPages.share)
    end
    return self.sharePanel
end

function LayoutExport:RefreshShareExport()
    local panel = self.sharePanel
    if not panel or not panel.exportBox then
        panel = self:EnsureSharePanel()
    end
    if not panel or not panel.exportBox then
        return ""
    end
    local includeLook = panel.fullCheck and panel.fullCheck:GetChecked()
    local code = self:ExportString(includeLook and true or false, { pretty = true })
    panel.exportBox:SetText(code)
    local lines = 1
    for _ in string.gmatch(code, "\n") do
        lines = lines + 1
    end
    panel.exportBox:SetHeight(math.min(120, math.max(56, lines * 14 + 12)))
    return code
end

function LayoutExport:ShowSharePanel()
    local Options = Mancer.Options
    if Options then
        Options:Initialize()
        if Options.Open then
            Options:Open()
        elseif Options.window then
            Options.window:Show()
        end
        if Options.SelectSettingsTab then
            Options:SelectSettingsTab("share")
        end
    end

    local panel = self:EnsureSharePanel()
    if not panel then
        return
    end
    if panel.fullCheck then
        panel.fullCheck:SetChecked(true)
    end
    self:RefreshShareExport()
    if panel.exportBox then
        panel.exportBox:SetFocus()
        panel.exportBox:HighlightText()
    end
end

Mancer.LayoutExport = LayoutExport
