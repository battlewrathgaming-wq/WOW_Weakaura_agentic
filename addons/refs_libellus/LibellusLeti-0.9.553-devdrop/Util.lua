Mancer.Util = Mancer.Util or {}

local MANA_POWER_TYPE = 0

function Mancer.Util.GetPlayerMana()
    if UnitPower and UnitPowerMax then
        local max = UnitPowerMax("player", MANA_POWER_TYPE)
        if max and max > 0 then
            return UnitPower("player", MANA_POWER_TYPE) or 0, max
        end
    end

    local current = UnitMana and UnitMana("player") or 0
    local max = UnitManaMax and UnitManaMax("player") or 0
    return current or 0, max or 0
end

function Mancer.Util.HasManaBar()
    local _, max = Mancer.Util.GetPlayerMana()
    return max > 0
end

-- WotLK / Ascension: SPELL_POWER_RUNIC_POWER = 6
local RUNIC_POWER_TYPE = 6

function Mancer.Util.GetPlayerRunicPower()
    if UnitPower and UnitPowerMax then
        local max = UnitPowerMax("player", RUNIC_POWER_TYPE)
        if max and max > 0 then
            return UnitPower("player", RUNIC_POWER_TYPE) or 0, max
        end
    end
    return 0, 0
end

function Mancer.Util.HasRunicPowerBar()
    local _, max = Mancer.Util.GetPlayerRunicPower()
    return max > 0
end

function Mancer.Util.GetPlayerHealth()
    return UnitHealth("player") or 0, UnitHealthMax("player") or 0
end

function Mancer.Util.GetArcOffset(progress, side, radius)
    local angle

    if side == "health" then
        angle = math.rad(-20 + (80 * progress))
    else
        angle = math.rad(200 - (80 * progress))
    end

    return math.cos(angle) * radius, math.sin(angle) * radius
end

function Mancer.Util.GetArcAngle(progress, side)
    if side == "health" then
        return math.rad(-20 + (80 * progress))
    end
    return math.rad(200 - (80 * progress))
end

function Mancer.Util.GetArcRotation(progress, side)
    return Mancer.Util.GetArcAngle(progress, side) + (math.pi / 2)
end

function Mancer.Util.GetArcBounds(side, radius)
    local x0, y0 = Mancer.Util.GetArcOffset(0, side, radius)
    local x1, y1 = Mancer.Util.GetArcOffset(1, side, radius)
    local cx = (x0 + x1) * 0.5
    local cy = (y0 + y1) * 0.5
    local arcLength = radius * math.rad(80)
    local width = math.max(18, radius * 0.38)
    local rotation = math.deg(Mancer.Util.GetArcRotation(0.5, side))

    return cx, cy, arcLength, width, rotation
end

-- Ultrawide (e.g. 32:9 / 5120×1440): Vert+ / wide HFOV makes the character look
-- smaller in the center while UIParent still sizes from screen height, so fixed
-- arcRadius looks oversized vs 16:9. Soft-shrink toward a 16:9 reference.
function Mancer.Util.GetAspectHudScale()
    local w = UIParent and UIParent:GetWidth()
    local h = UIParent and UIParent:GetHeight()
    if not w or not h or h < 1 then
        return 1
    end
    local aspect = w / h
    local ref = 16 / 9
    if aspect <= ref * 1.08 then
        return 1
    end
    local scale = math.sqrt(ref / aspect)
    if scale < 0.65 then
        scale = 0.65
    elseif scale > 1 then
        scale = 1
    end
    return scale
end

function Mancer.Util.GetFontFile()
    local path = MancerDB.fontFile or "Fonts\\FRIZQT__.TTF"
    if Mancer.ResolveFontFile then
        path = Mancer.ResolveFontFile(path)
    end
    return path
end

-- Ascension/3.3.5 SetFont visually caps around ~22; larger sizes need SetTextHeight.
local FONT_GLYPH_CAP = 18

function Mancer.Util.ApplyFont(fontString, size)
    if not fontString or not fontString.SetFont then
        return
    end
    size = tonumber(size) or 14
    if size < 8 then
        size = 8
    end
    local path = Mancer.Util.GetFontFile()
    local glyph = size
    if glyph > FONT_GLYPH_CAP then
        glyph = FONT_GLYPH_CAP
    end
    local ok = fontString:SetFont(path, glyph, "OUTLINE")
    if not ok then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", glyph, "OUTLINE")
    end
    if fontString.SetTextHeight then
        fontString:SetTextHeight(size)
    end
end

-- Shared player proc auras (HUD strip + MinionDps tracking). Single source of spell IDs.
-- Bone King: user ID 707176; tips/CA also reference 707175 — accept both.
-- Frost Runes: talent/ability 705750; live buff aura reported as 705751.
Mancer.PROC_AURAS = {
    {
        id = "diabolical",
        label = "Diabolical",
        spellIds = { 707133 },
        fallbackIcon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
    },
    {
        id = "bone_king",
        label = "Bone King",
        spellIds = { 707176, 707175 },
        fallbackIcon = "Interface\\Icons\\Ability_Creature_Cursed_05",
    },
    {
        id = "frost_runes",
        label = "Frost Runes",
        spellIds = { 705751, 705750 },
        fallbackIcon = "Interface\\Icons\\Spell_Deathknight_EmpowerRuneBlade2",
    },
}
