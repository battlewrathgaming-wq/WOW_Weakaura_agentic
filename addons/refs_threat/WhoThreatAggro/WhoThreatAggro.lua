-- WhoThreatAggro.lua (Version 1.3.0)
local addonName, addonTable = ...

-- =========================================================================
-- 1. LOCALISATION & VARIABLES GLOBALES
-- =========================================================================
local L = {}

local POS_ANCHORS = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}

if GetLocale() == "frFR" then
    L.READY         = "|cff00FF00v1.3.1|r, Addon chargé. /wta options"
    L.TITLE         = "WhoThreatAggro"
    L.VERSION       = "Version 1.3.1"
    L.BtnTEST_ON    = "ARRÊTER LE TEST"
    L.BtnTEST_OFF   = "TEST VISUEL"
    L.SectionGLOW   = "Lueurs (Glow)"
    L.SectionTEXT   = "Textes (% Aggro)"
    L.SectionGEN    = "Général"
    L.PLAYER        = "Lueur Joueur"
    L.PARTY         = "Lueur Groupe"
    L.RAID          = "Lueur Raid"
    L.TXT_PLAYER    = "Texte Joueur"
    L.TXT_PARTY     = "Texte Groupe"
    L.TXT_RAID      = "Texte Raid"
    L.SIZE          = "Taille"
    L.COMBAT        = "Combat Uniquement"
    L.CLOSE         = "Fermer"
    L.RESET         = "Réinitialiser"
    L.GLOW_ALPHA    = "Intensité lueur"
    L.FLASH_ENABLE  = "Clignotement aggro"
    L.FLASH_SPEED   = "Vitesse clignotement"
    L.POS           = {"Haut Gauche", "Haut Centre", "Haut Droite", "Gauche", "Centre", "Droite", "Bas Gauche", "Bas Centre", "Bas Droite"}
    L.SectionALERT  = "Alertes"
    L.THRESHOLD     = "Seuil d'alerte (%)"
    L.TXT_COLOR     = "Couleur texte"
    L.TXT_COLOR_AUTO= "Auto (lueur)"
    L.GLOW_COLOR    = "Couleur lueur"
    L.AGGRO_ALERT   = "Frame 'Aggro de'"
    L.AGGRO_ALERT_LABEL = "Aggro de :"
    L.BORDER        = "Bordure"
    L.BG            = "Fond"
    L.OPACITY       = "Opacité fond"
    L.EDGE_SIZE     = "Épaisseur bordure"
    -- Tooltips
    L.TT_PLAYER      = "Affiche une lueur colorée sur votre portrait selon votre niveau de menace."
    L.TT_PARTY       = "Affiche une lueur colorée sur les cadres de groupe selon leur niveau de menace."
    L.TT_RAID        = "Affiche une lueur colorée sur les cadres de raid selon leur niveau de menace."
    L.TT_TXT_PLAYER  = "Affiche le pourcentage de menace en texte sur votre portrait."
    L.TT_TXT_PARTY   = "Affiche le pourcentage de menace en texte sur les cadres de groupe."
    L.TT_TXT_RAID    = "Affiche le pourcentage de menace en texte sur les cadres de raid."
    L.TT_SIZE        = "Taille du texte, en pixels."
    L.TT_POS         = "Clic pour changer l'ancrage du texte (9 positions)."
    L.TT_TXT_COLOR   = "Couleur du texte de pourcentage. 'Auto' suit la couleur de la lueur."
    L.TT_GLOW_COLOR  = "Couleur de la lueur. 'Auto' suit le statut de menace (Jaune/Orange/Rouge)."
    L.TT_COMBAT      = "L'addon reste totalement silencieux hors combat."
    L.TT_GLOW_ALPHA  = "Intensité maximale de la lueur (opacité)."
    L.TT_FLASH_ENABLE= "Fait clignoter la lueur en cas d'aggro ou d'alerte."
    L.TT_FLASH_SPEED = "Vitesse du clignotement de la lueur."
    L.TT_THRESHOLD   = "En dessous de 100%, force la couleur rouge et le clignotement dès que ce seuil de menace est atteint."
    L.TT_AGGRO_ALERT = "Affiche un cadre déplaçable indiquant sur quelle cible vous avez l'aggro."
    L.TT_MERGE_AGGRO_TEXT = "Affiche le pourcentage directement dans la frame 'Aggro de' et masque le texte % séparé sur le portrait."
    L.MERGE_AGGRO_TEXT = "Fusionner avec le texte %"
    L.SectionTARGET  = "Cible"
    L.TARGET_GLOW    = "Lueur cible (aggro)"
    L.TT_TARGET_GLOW = "Allume une lueur rouge sur le cadre de la cible quand vous avez l'aggro dessus."
    L.TT_BORDER      = "Affiche une bordure autour du cadre 'Aggro de'."
    L.TT_EDGE_SIZE   = "Épaisseur de la bordure du cadre 'Aggro de'."
    L.TT_BG          = "Affiche un fond derrière le cadre 'Aggro de'."
    L.TT_OPACITY     = "Opacité du fond du cadre 'Aggro de'."
    L.TT_RESET       = "Réinitialise toutes les options aux valeurs par défaut."
    L.TT_TEST        = "Simule l'aggro sur tous les cadres pour prévisualiser le rendu sans être en combat."
    L.MINIMAP_TT_LEFT  = "Clic gauche : ouvrir les options"
    L.MINIMAP_TT_RIGHT = "Clic droit : mode test"
else
    L.READY         = "|cff00FF00v1.3.1|r, Addon loaded. /wta options"
    L.TITLE         = "WhoThreatAggro"
    L.VERSION       = "Version 1.3.1"
    L.BtnTEST_ON    = "STOP TEST"
    L.BtnTEST_OFF   = "VISUAL TEST"
    L.SectionGLOW   = "Glow Settings"
    L.SectionTEXT   = "Text Settings"
    L.SectionGEN    = "General"
    L.PLAYER        = "Player Glow"
    L.PARTY         = "Party Glow"
    L.RAID          = "Raid Glow"
    L.TXT_PLAYER    = "Player Text %"
    L.TXT_PARTY     = "Party Text %"
    L.TXT_RAID      = "Raid Text %"
    L.SIZE          = "Size"
    L.COMBAT        = "Combat Only"
    L.CLOSE         = "Close"
    L.RESET         = "Reset"
    L.GLOW_ALPHA    = "Glow intensity"
    L.FLASH_ENABLE  = "Aggro flash"
    L.FLASH_SPEED   = "Flash speed"
    L.POS           = {"Top Left", "Top Center", "Top Right", "Left", "Center", "Right", "Bottom Left", "Bottom Center", "Bottom Right"}
    L.SectionALERT  = "Alerts"
    L.THRESHOLD     = "Alert threshold (%)"
    L.TXT_COLOR     = "Text color"
    L.TXT_COLOR_AUTO= "Auto (glow)"
    L.GLOW_COLOR    = "Glow color"
    L.AGGRO_ALERT   = "'Aggro from' frame"
    L.AGGRO_ALERT_LABEL = "Aggro from:"
    L.BORDER        = "Border"
    L.BG            = "Background"
    L.OPACITY       = "Bg opacity"
    L.EDGE_SIZE     = "Border thickness"
    -- Tooltips
    L.TT_PLAYER      = "Shows a colored glow on your player portrait based on your threat level."
    L.TT_PARTY       = "Shows a colored glow on party frames based on their threat level."
    L.TT_RAID        = "Shows a colored glow on raid frames based on their threat level."
    L.TT_TXT_PLAYER  = "Shows the threat percentage as text on your player portrait."
    L.TT_TXT_PARTY   = "Shows the threat percentage as text on party frames."
    L.TT_TXT_RAID    = "Shows the threat percentage as text on raid frames."
    L.TT_SIZE        = "Text size, in pixels."
    L.TT_POS         = "Click to cycle the text anchor point (9 positions)."
    L.TT_TXT_COLOR   = "Color of the percentage text. 'Auto' follows the glow color."
    L.TT_GLOW_COLOR  = "Color of the glow. 'Auto' follows the threat status (Yellow/Orange/Red)."
    L.TT_COMBAT      = "The addon stays completely silent outside of combat."
    L.TT_GLOW_ALPHA  = "Maximum glow intensity (opacity)."
    L.TT_FLASH_ENABLE= "Makes the glow flash on aggro or alert."
    L.TT_FLASH_SPEED = "Speed of the glow flash."
    L.TT_THRESHOLD   = "Below 100%, forces red color and flashing as soon as this threat threshold is reached."
    L.TT_AGGRO_ALERT = "Shows a movable frame indicating which target you have aggro on."
    L.TT_MERGE_AGGRO_TEXT = "Shows the percentage directly in the 'Aggro from' frame and hides the separate % text on the portrait."
    L.MERGE_AGGRO_TEXT = "Merge with % text"
    L.SectionTARGET  = "Target"
    L.TARGET_GLOW    = "Target glow (aggro)"
    L.TT_TARGET_GLOW = "Lights up a red glow on the target frame when you have aggro on it."
    L.TT_BORDER      = "Shows a border around the 'Aggro from' frame."
    L.TT_EDGE_SIZE   = "Border thickness of the 'Aggro from' frame."
    L.TT_BG          = "Shows a background behind the 'Aggro from' frame."
    L.TT_OPACITY     = "Background opacity of the 'Aggro from' frame."
    L.TT_RESET       = "Resets all options to their default values."
    L.TT_TEST        = "Simulates aggro on all frames to preview the visuals without being in combat."
    L.MINIMAP_TT_LEFT  = "Left-click: open options"
    L.MINIMAP_TT_RIGHT = "Right-click: test mode"
end

-- =========================================================================
-- 2. CONFIG & VARIABLES
-- =========================================================================
local isTestMode = false
local isInCombat = false
local updateRate = 0.016
local isOptimizedMode = false
local threatTicker = nil

local GEOMETRY = {
    PLAYER = { w = 242, h = 93, x = -3, y = -2 },
    PARTY  = { w = 128, h = 64, x = -4, y = 2 },
    RAID   = { padding = -1 },
    -- TargetFrame = miroir horizontal de PlayerFrame (portrait à droite) :
    -- même taille, ancré depuis TOPRIGHT avec offset symétrique (x inversé).
    TARGET = { w = 242, h = 93, x = 3, y = -2 }
}

local DEFAULTS = {
    EnablePlayer = true,
    EnableParty  = true,
    EnableRaid   = true,
    TextPlayer   = true,
    TextParty    = true,
    TextRaid     = false,
    SizePlayer   = 16,
    SizeParty    = 12,
    SizeRaid     = 10,
    OnlyInCombat = true,
    PosPlayer    = "CENTER",
    PosParty     = "CENTER",
    PosRaid      = "CENTER",
    -- Nouveaux
    GlowAlphaPlayer    = 10,   -- 1-10, divisé par 10 → 0.1 à 1.0
    GlowAlphaParty     = 10,
    GlowAlphaRaid      = 10,
    GlowAlphaTarget    = 10,
    FlashEnabledPlayer = true,
    FlashEnabledParty  = true,
    FlashEnabledRaid   = true,
    FlashEnabledTarget = true,
    FlashSpeedPlayer   = 8,    -- 1-20, valeur passée à math.sin
    FlashSpeedParty    = 8,
    FlashSpeedRaid     = 8,
    FlashSpeedTarget   = 8,
    -- Seuil d'alerte
    AlertThreshold  = 100,  -- 0-100 : si percent >= seuil → force rouge+flash
    -- Couleurs texte indépendantes (nil = suit la lueur)
    TextColorPlayer = "AUTO",
    TextColorParty  = "AUTO",
    TextColorRaid   = "AUTO",
    -- Couleurs de lueur indépendantes ("AUTO" = suit le statut de menace Jaune/Orange/Rouge)
    GlowColorPlayer = "AUTO",
    GlowColorParty  = "AUTO",
    GlowColorRaid   = "AUTO",
    -- Frame aggro alert
    EnableAggroAlert = false,
    MergeAggroPercent = false,
    EnableTargetGlow = false,
    AggroAlertX      = 0,
    AggroAlertY      = 150,
    AggroAlertSize   = 14,
    AggroAlertBorder = true,
    AggroAlertBg     = true,
    AggroAlertOpacity = 7,  -- /10 → 0.7
    AggroAlertEdge   = 12,
}

-- Couleurs de texte prédéfinies
local TEXT_COLORS = {
    { key="AUTO",   r=nil, g=nil, b=nil },
    { key="WHITE",  r=1,   g=1,   b=1   },
    { key="YELLOW", r=1,   g=1,   b=0   },
    { key="ORANGE", r=1,   g=0.5, b=0   },
    { key="RED",    r=1,   g=0,   b=0   },
    { key="GREEN",  r=0,   g=1,   b=0   },
    { key="CYAN",   r=0,   g=1,   b=1   },
}
local TEXT_COLOR_MAP = {}
for _, c in ipairs(TEXT_COLORS) do TEXT_COLOR_MAP[c.key] = c end

local TEXT_COLOR_ITEMS_FR = {
    {text="Auto (lueur)", value="AUTO"},
    {text="Blanc",        value="WHITE"},
    {text="Jaune",        value="YELLOW"},
    {text="Orange",       value="ORANGE"},
    {text="Rouge",        value="RED"},
    {text="Vert",         value="GREEN"},
    {text="Cyan",         value="CYAN"},
}
local TEXT_COLOR_ITEMS_EN = {
    {text="Auto (glow)", value="AUTO"},
    {text="White",       value="WHITE"},
    {text="Yellow",      value="YELLOW"},
    {text="Orange",      value="ORANGE"},
    {text="Red",         value="RED"},
    {text="Green",       value="GREEN"},
    {text="Cyan",        value="CYAN"},
}
local TEXT_COLOR_ITEMS = GetLocale() == "frFR" and TEXT_COLOR_ITEMS_FR or TEXT_COLOR_ITEMS_EN

-- Même palette que TEXT_COLOR_MAP, mais libellé "Auto" différent (suit le statut de menace,
-- pas le texte)
local GLOW_COLOR_ITEMS_FR = {
    {text="Auto (menace)", value="AUTO"},
    {text="Blanc",         value="WHITE"},
    {text="Jaune",         value="YELLOW"},
    {text="Orange",        value="ORANGE"},
    {text="Rouge",         value="RED"},
    {text="Vert",          value="GREEN"},
    {text="Cyan",          value="CYAN"},
}
local GLOW_COLOR_ITEMS_EN = {
    {text="Auto (threat)", value="AUTO"},
    {text="White",         value="WHITE"},
    {text="Yellow",        value="YELLOW"},
    {text="Orange",        value="ORANGE"},
    {text="Red",           value="RED"},
    {text="Green",         value="GREEN"},
    {text="Cyan",          value="CYAN"},
}
local GLOW_COLOR_ITEMS = GetLocale() == "frFR" and GLOW_COLOR_ITEMS_FR or GLOW_COLOR_ITEMS_EN

-- Variante pour le Joueur uniquement : ajoute "Couleur de classe" (n'a de sens
-- que pour le portrait du joueur, pas pour Groupe/Raid qui mélangent les classes)
local GLOW_COLOR_ITEMS_PLAYER_FR = {
    {text="Auto (menace)",     value="AUTO"},
    {text="Couleur de classe", value="CLASS"},
    {text="Blanc",             value="WHITE"},
    {text="Jaune",             value="YELLOW"},
    {text="Orange",            value="ORANGE"},
    {text="Rouge",             value="RED"},
    {text="Vert",              value="GREEN"},
    {text="Cyan",              value="CYAN"},
}
local GLOW_COLOR_ITEMS_PLAYER_EN = {
    {text="Auto (threat)", value="AUTO"},
    {text="Class color",   value="CLASS"},
    {text="White",         value="WHITE"},
    {text="Yellow",        value="YELLOW"},
    {text="Orange",        value="ORANGE"},
    {text="Red",           value="RED"},
    {text="Green",         value="GREEN"},
    {text="Cyan",          value="CYAN"},
}
local GLOW_COLOR_ITEMS_PLAYER = GetLocale() == "frFR" and GLOW_COLOR_ITEMS_PLAYER_FR or GLOW_COLOR_ITEMS_PLAYER_EN

local TEXT_COLOR_KEY = { PLAYER="TextColorPlayer", PARTY="TextColorParty", RAID="TextColorRaid" }

local function GetTextColor(category, fallbackColor)
    local key = WTA_Config[TEXT_COLOR_KEY[category]] or "AUTO"
    if key == "AUTO" or not TEXT_COLOR_MAP[key] or not TEXT_COLOR_MAP[key].r then
        if fallbackColor then return fallbackColor[1], fallbackColor[2], fallbackColor[3] end
        return 1, 1, 1
    end
    local c = TEXT_COLOR_MAP[key]
    return c.r, c.g, c.b
end

local GLOW_COLOR_KEY = { PLAYER="GlowColorPlayer", PARTY="GlowColorParty", RAID="GlowColorRaid" }

-- Couleur de la lueur elle-même. "AUTO" = comportement d'origine (Jaune/Orange/Rouge
-- selon le statut de menace, passé dans fallbackColor). "CLASS" = couleur de classe
-- (Joueur uniquement, n'a pas de sens pour Groupe/Raid qui mélangent les classes).
-- Sinon, couleur fixe choisie.
local function GetGlowColor(category, fallbackColor)
    local key = WTA_Config[GLOW_COLOR_KEY[category]] or "AUTO"
    if key == "CLASS" and category == "PLAYER" then
        local classFile = select(2, UnitClass("player"))
        local c = classFile and RAID_CLASS_COLORS[classFile]
        if c then return c.r, c.g, c.b, 1 end
    end
    if key == "AUTO" or not TEXT_COLOR_MAP[key] or not TEXT_COLOR_MAP[key].r then
        return fallbackColor[1], fallbackColor[2], fallbackColor[3], fallbackColor[4] or 1
    end
    local c = TEXT_COLOR_MAP[key]
    return c.r, c.g, c.b, 1
end

-- Réglages FX (intensité lueur / clignotement) indépendants par catégorie
local GLOW_ALPHA_KEY    = { PLAYER="GlowAlphaPlayer",    PARTY="GlowAlphaParty",    RAID="GlowAlphaRaid",    TARGET="GlowAlphaTarget" }
local FLASH_ENABLED_KEY = { PLAYER="FlashEnabledPlayer", PARTY="FlashEnabledParty", RAID="FlashEnabledRaid", TARGET="FlashEnabledTarget" }
local FLASH_SPEED_KEY   = { PLAYER="FlashSpeedPlayer",   PARTY="FlashSpeedParty",   RAID="FlashSpeedRaid",   TARGET="FlashSpeedTarget" }

local function GetFXAlpha(category)
    return (WTA_Config[GLOW_ALPHA_KEY[category]] or 10) / 10
end
local function GetFXFlashOn(category)
    return WTA_Config[FLASH_ENABLED_KEY[category]] ~= false
end
local function GetFXFlashSpeed(category)
    return WTA_Config[FLASH_SPEED_KEY[category]] or 8
end

local COLORS = {
    YELLOW  = {1, 1, 0, 1},
    ORANGE  = {1, 0.5, 0, 1},
    RED     = {1, 0, 0, 1}
}

local TEXTURE_PATHS = {
    PLAYER = "Interface\\TargetingFrame\\UI-TargetingFrame-Flash",
    PARTY  = "Interface\\TargetingFrame\\UI-PartyFrame-Flash",
    TARGET = "Interface\\TargetingFrame\\UI-TargetingFrame-Flash"
}

local TEX_COORDS = {
    PLAYER = {0.945, 0, 0, 0.72},
    PARTY  = {0, 1, 0, 1},
    -- Miroir horizontal des coords Joueur (gauche/droite inversés)
    TARGET = {0, 0.945, 0, 0.72}
}

local TrackedFrames = {}
local TestFrames = {}
local AddonReady = false
local AggroAlertFrame = nil

-- =========================================================================
-- 3. FONCTIONS GRAPHIQUES ET C_TIMER
-- =========================================================================
local ThreatLoop

local function StartTicker()
    if threatTicker then return end
    threatTicker = C_Timer.NewTicker(updateRate, ThreatLoop)
end

local function StopTicker()
    if threatTicker then threatTicker:Cancel(); threatTicker = nil end
end

local function UpdateTickerRate()
    -- Ne redémarre que si le ticker tournait déjà : ne force pas un démarrage
    -- hors combat quand OnlyInCombat est actif.
    if threatTicker then
        StopTicker()
        threatTicker = C_Timer.NewTicker(updateRate, ThreatLoop)
    end
end

-- Le ticker doit tourner : en mode test, en combat, ou si "Combat Uniquement" est désactivé.
local function SyncTickerState()
    if isTestMode or isInCombat or not (WTA_Config and WTA_Config.OnlyInCombat) then
        StartTicker()
    else
        StopTicker()
    end
end

-- Ajuste la taille du cadre 'Aggro de' au contenu réel du texte (marge fixe).
-- Appelé à chaque changement de police/réglage ET à chaque mise à jour du texte,
-- car la longueur du nom affiché varie.
local function AutoSizeAggroAlertFrame(f)
    local padX, padY = 24, 14
    local w = math.max(f.label:GetStringWidth() + padX, 80)
    local h = math.max(f.label:GetStringHeight() + padY, 20)
    f:SetSize(w, h)
end

local function RefreshAggroAlertFrame()
    if not AggroAlertFrame then return end
    local f = AggroAlertFrame

    -- Taille du texte
    local fontName = GameFontNormal:GetFont()
    f.label:SetFont(fontName, WTA_Config.AggroAlertSize or 14, "OUTLINE")

    local showBg     = WTA_Config.AggroAlertBg     ~= false
    local showBorder = WTA_Config.AggroAlertBorder ~= false

    if showBg or showBorder then
        f:SetBackdrop({
            bgFile   = showBg     and "Interface\\ChatFrame\\ChatFrameBackground" or nil,
            edgeFile = showBorder and "Interface\\Tooltips\\UI-Tooltip-Border"    or nil,
            edgeSize = showBorder and (WTA_Config.AggroAlertEdge or 12) or 0,
            insets   = { left=3, right=3, top=3, bottom=3 }
        })
        if showBg then
            local opacity = (WTA_Config.AggroAlertOpacity or 7) / 10
            f:SetBackdropColor(0, 0, 0, opacity)
        end
        if showBorder then f:SetBackdropBorderColor(0.8, 0.1, 0.1, 0.9) end
    else
        f:SetBackdrop(nil)
    end

    AutoSizeAggroAlertFrame(f)
end

local function GetOrCreateAggroAlertFrame()
    if AggroAlertFrame then return AggroAlertFrame end

    local f = CreateFrame("Frame", "WTA_AggroAlert", UIParent, "BackdropTemplate")
    f:SetSize(220, 36)
    f:SetPoint("CENTER", UIParent, "CENTER", WTA_Config.AggroAlertX or 0, WTA_Config.AggroAlertY or 150)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local _, _, _, x, y = self:GetPoint()
        WTA_Config.AggroAlertX = math.floor(x + 0.5)
        WTA_Config.AggroAlertY = math.floor(y + 0.5)
    end)

    local t = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    t:SetPoint("CENTER", f, "CENTER", 0, 0)
    t:SetTextColor(1, 0.2, 0.2, 1)
    f.label = t
    f:Hide()

    AggroAlertFrame = f
    RefreshAggroAlertFrame()
    return f
end

local TargetGlow = nil

local function GetOrCreateTargetGlow()
    if TargetGlow then return TargetGlow end
    if not TargetFrame then return nil end

    local status, glow = pcall(function() return TargetFrame:CreateTexture(nil, "OVERLAY", nil, 7) end)
    if not status or not glow then return nil end

    local cfg = GEOMETRY.TARGET
    glow:SetBlendMode("ADD")
    glow:SetTexture(TEXTURE_PATHS.TARGET)
    glow:SetTexCoord(unpack(TEX_COORDS.TARGET))
    -- Même texture façonnée que la lueur Joueur, ancrée en miroir (TOPRIGHT)
    -- pour épouser la forme réelle de TargetFrame au lieu d'un rectangle générique.
    -- Géométrie non testée en jeu : ajuster cfg.x/y si décalage visuel.
    glow:SetPoint("TOPRIGHT", TargetFrame, "TOPRIGHT", cfg.x, cfg.y)
    glow:SetWidth(cfg.w)
    glow:SetHeight(cfg.h)
    glow:Hide()

    TargetGlow = glow
    return glow
end

local function UpdateGlowGeometry(glow, glowType)
    local cfg = GEOMETRY[glowType]
    if not cfg then return end

    glow:ClearAllPoints()
    if glowType == "RAID" then
        local pad = cfg.padding or 0
        glow:SetPoint("TOPLEFT", glow:GetParent(), "TOPLEFT", -pad, pad)
        glow:SetPoint("BOTTOMRIGHT", glow:GetParent(), "BOTTOMRIGHT", pad, -pad)
    else
        glow:SetPoint("TOPLEFT", glow:GetParent(), "TOPLEFT", cfg.x, cfg.y)
        glow:SetWidth(cfg.w); glow:SetHeight(cfg.h)
    end
end

local function GetOrCreateGlow(frame, glowType)
    if not frame then return nil end
    if frame.WTA_Glow then return frame.WTA_Glow end

    local status, glow = pcall(function() return frame:CreateTexture(nil, "OVERLAY", nil, 7) end)
    if not status or not glow then return nil end

    glow:SetBlendMode("ADD")
    if glowType == "RAID" then
        glow:SetTexture("Interface\\Buttons\\WHITE8x8")
    else
        local path = TEXTURE_PATHS[glowType]
        if path then
            glow:SetTexture(path)
            local c = TEX_COORDS[glowType]
            if c then glow:SetTexCoord(unpack(c)) end
        end
    end

    frame.WTA_Glow = glow
    table.insert(TestFrames, glow)
    UpdateGlowGeometry(glow, glowType)

    return glow
end

local function UpdateTextFont(text, category)
    if not text or not WTA_Config then return end
    local fontName, _, _ = GameFontNormal:GetFont()
    local size = 12

    if category == "PLAYER" then size = WTA_Config.SizePlayer or 16
    elseif category == "PARTY" then size = WTA_Config.SizeParty or 12
    elseif category == "RAID"  then size = WTA_Config.SizeRaid  or 10 end

    text:SetFont(fontName, size, "OUTLINE")
end

local function GetOrCreateTextFrame(parentFrame, category)
    if not parentFrame then return nil end
    if parentFrame.WTA_TextFrame then
        UpdateTextFont(parentFrame.WTA_TextFrame.text, category)
        return parentFrame.WTA_TextFrame
    end

    local f = CreateFrame("Frame", nil, parentFrame)
    f:SetAllPoints(parentFrame)

    local t = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    t:SetShadowOffset(1, -1)
    f.text = t

    UpdateTextFont(t, category)

    -- Positionner le texte dès la création pour qu'il soit visible au premier tick
    local posKey = category == "PLAYER" and "PosPlayer" or (category == "PARTY" and "PosParty" or "PosRaid")
    local anchor = (WTA_Config and WTA_Config[posKey]) or "CENTER"
    t:SetPoint(anchor, f, anchor, 0, 0)

    parentFrame.WTA_TextFrame = f
    return f
end

-- =========================================================================
-- 4. LOGIQUE
-- =========================================================================

-- Sur BC 2.5.5 (client moderne) la signature est :
--   isTanking(bool), status(0-3), scaledPercent, rawPercent
-- "status" est donc le 2ème retour, pas le 1er.
-- `(p or fallback)` garantit que percent n'est jamais 0 quand on a l'aggro.
local function GetThreatData(unit)
    if not UnitExists(unit) then return nil, false, 0 end

    local threshold = WTA_Config.AlertThreshold or 100

    local isTanking, status, p = UnitDetailedThreatSituation(unit, "target")
    if status ~= nil then
        -- Seuil d'alerte : si percent >= seuil, forcer rouge+flash
        if p and threshold < 100 and p >= threshold then
            return COLORS.RED, true, p
        end
        if status >= 3 then return COLORS.RED,    true,  (p or 100) end
        if status == 2 then return COLORS.ORANGE, false, (p or 90)  end
        if status == 1 then return COLORS.YELLOW, false, (p or 80)  end
        -- status == 0 : en combat mais sous les seuils visuels
        if p and p >= 95 then return COLORS.ORANGE, false, p end
        if p and p >= 80 then return COLORS.YELLOW, false, p end
        return nil, false, (p or 0)
    end

    -- Fallback si UnitDetailedThreatSituation ne répond pas
    local s = UnitThreatSituation(unit)
    if not s then return nil, false, 0 end
    if s >= 3 then return COLORS.RED,    true,  100 end
    if s == 2 then return COLORS.ORANGE, false, 90  end
    if s == 1 then return COLORS.YELLOW, false, 80  end
    return nil, false, 0
end

local function HideAllOverlays()
    for _, data in ipairs(TrackedFrames) do
        if data.frame.WTA_Glow      then data.frame.WTA_Glow:Hide()      end
        if data.frame.WTA_TextFrame then data.frame.WTA_TextFrame:Hide()  end
    end
    if AggroAlertFrame then AggroAlertFrame:Hide() end
    if TargetGlow then TargetGlow:Hide() end
end

local function RebuildFrameCache()
    if not AddonReady or not WTA_Config then return end
    local cfg = WTA_Config

    -- Masquer les overlays de l'ancienne liste AVANT de la vider : sinon une catégorie
    -- désactivée (ex. décocher "Lueur Joueur") laisse sa lueur/texte orphelins et figés,
    -- car ils ne sont plus jamais itérés une fois retirés de TrackedFrames.
    for _, data in ipairs(TrackedFrames) do
        if data.frame.WTA_Glow      then data.frame.WTA_Glow:Hide()      end
        if data.frame.WTA_TextFrame then data.frame.WTA_TextFrame:Hide() end
    end

    wipe(TrackedFrames)

    local numMembers = GetNumGroupMembers()
    if IsInRaid() and numMembers >= 25 then
        if not isOptimizedMode then
            isOptimizedMode = true
            updateRate = 0.033
            UpdateTickerRate()
            print("|cffFFD700[WTA]|r Format 25+ détecté : Optimisation à 30 FPS activée.")
        end
    else
        if isOptimizedMode then
            isOptimizedMode = false
            updateRate = 0.016
            UpdateTickerRate()
            print("|cffFFD700[WTA]|r Format standard : Retour à 60 FPS.")
        end
    end

    -- Joueur
    if cfg.EnablePlayer and PlayerFrame then
        table.insert(TrackedFrames, { frame=PlayerFrame, unit="player", category="PLAYER", glowType="PLAYER", showText=cfg.TextPlayer })
    end

    -- Groupe
    if cfg.EnableParty then
        local seenFrames = {}

        -- Frames de groupe classiques
        for i = 1, 4 do
            local f = _G["PartyMemberFrame"..i] or (PartyFrame and PartyFrame["MemberFrame"..i])
            if f and not seenFrames[f] then
                seenFrames[f] = true
                table.insert(TrackedFrames, { frame=f, unit="party"..i, category="PARTY", glowType="PARTY", showText=cfg.TextParty })
            end
        end

        -- Frames Compact de groupe (BC moderne)
        -- Nommage "CompactPartyFrameMember" ET fallback via CompactRaidFrame si en groupe sans raid
        for i = 1, 5 do
            local f = _G["CompactPartyFrameMember"..i]
            if f and f:IsVisible() and f.unit and not seenFrames[f] then
                seenFrames[f] = true
                table.insert(TrackedFrames, { frame=f, unit=f.unit, category="PARTY", glowType="RAID", showText=cfg.TextParty })
            end
        end

        -- Certains clients BC moderne utilisent CompactRaidFrame1-5 même en groupe
        if not IsInRaid() then
            for i = 1, 5 do
                local f = _G["CompactRaidFrame"..i]
                if f and f:IsVisible() and f.unit and not seenFrames[f] then
                    seenFrames[f] = true
                    table.insert(TrackedFrames, { frame=f, unit=f.unit, category="PARTY", glowType="RAID", showText=cfg.TextParty })
                end
            end
        end
    end

    -- Raid
    if cfg.EnableRaid then
        local showRaidText = cfg.TextRaid
        local seenRaid = {}

        -- Frames plates CompactRaidFrame1-40
        for i = 1, 40 do
            local f = _G["CompactRaidFrame"..i]
            if f and f:IsVisible() and not seenRaid[f] then
                seenRaid[f] = true
                table.insert(TrackedFrames, { frame=f, unit=f.unit or "raid"..i, category="RAID", glowType="RAID", showText=showRaidText })
            end
        end

        -- Frames groupées CompactRaidGroupXMemberY
        for g = 1, 8 do
            for m = 1, 5 do
                local f = _G["CompactRaidGroup"..g.."Member"..m]
                if f and f:IsVisible() and not seenRaid[f] then
                    seenRaid[f] = true
                    table.insert(TrackedFrames, { frame=f, unit=f.unit or "raid"..((g-1)*5+m), category="RAID", glowType="RAID", showText=showRaidText })
                end
            end
        end
    end

    -- Mise à jour des positions et fontes des TextFrames existants
    for _, data in ipairs(TrackedFrames) do
        local tf = data.frame.WTA_TextFrame
        if tf then
            local posKey = data.category == "PLAYER" and "PosPlayer" or (data.category == "PARTY" and "PosParty" or "PosRaid")
            local anchor = WTA_Config[posKey] or "CENTER"
            tf.text:ClearAllPoints()
            tf.text:SetPoint(anchor, tf, anchor, 0, 0)
            UpdateTextFont(tf.text, data.category)
        end
    end

    -- Reconstruction de TestFrames depuis les glows existants
    wipe(TestFrames)
    for _, data in ipairs(TrackedFrames) do
        if data.frame.WTA_Glow then
            table.insert(TestFrames, data.frame.WTA_Glow)
        end
    end

    -- Masquage initial propre
    for _, glow in ipairs(TestFrames) do glow:Hide() end
    for _, data in ipairs(TrackedFrames) do
        if data.frame.WTA_TextFrame then data.frame.WTA_TextFrame:Hide() end
    end
end

-- =========================================================================
-- 5. OPTIONS (Générées via OptionsUi.lua)
-- =========================================================================
local UI = addonTable.UI
local OptionsPanel = nil
local btnTestMode = nil
local sliderDebounce = nil
local RefreshOptionsPanel = nil

local function RebuildDebounced()
    if sliderDebounce then sliderDebounce:Cancel() end
    sliderDebounce = C_Timer.NewTicker(0.2, RebuildFrameCache, 1)
end

-- Bascule le mode test, utilisée par le bouton du panneau ET par /wta test.
local function ToggleTestMode()
    isTestMode = not isTestMode
    if btnTestMode then btnTestMode:SetText(isTestMode and L.BtnTEST_ON or L.BtnTEST_OFF) end
    if not isTestMode then HideAllOverlays() end
    SyncTickerState()
    RebuildFrameCache()
end

local function CreateOptionsPanel()
    if OptionsPanel then OptionsPanel:Show(); return end

    -- Panel agrandi pour la 3e page
    OptionsPanel = UI.CreateMainPanel("WTA_Options", L.TITLE, L.VERSION, 440, 580)
    tinsert(UISpecialFrames, "WTA_Options")

    OptionsPanel:SetScript("OnHide", function()
        if isTestMode then ToggleTestMode() end
    end)

    local pageApparence = UI.CreatePage(OptionsPanel)
    local pageGeneral   = UI.CreatePage(OptionsPanel)
    local pageAlertes   = UI.CreatePage(OptionsPanel)

    UI.CreateTabSystem(OptionsPanel, {
        {name = "Apparence", frame = pageApparence},
        {name = "Général",   frame = pageGeneral},
        {name = "Alertes",   frame = pageAlertes},
    })

    -- ================= PAGE 1 : APPARENCE =================
    -- Un groupe par catégorie (Joueur / Groupe / Raid), avec tous ses réglages
    -- ensemble : lueur, couleur lueur, texte, taille, position, couleur texte.
    local grpPlayer = UI.CreateGroup(pageApparence, L.PLAYER, 400, 150, 10, -10)
    UI.CreateCheckbox(grpPlayer, L.PLAYER, 15, -30, WTA_Config.EnablePlayer, function(val)
        WTA_Config.EnablePlayer = val; RebuildFrameCache()
    end, L.TT_PLAYER)
    local ddGlowColorPlayer = UI.CreateDropdown(grpPlayer, L.GLOW_COLOR, 220, -25, GLOW_COLOR_ITEMS_PLAYER, WTA_Config.GlowColorPlayer or "AUTO", function(val)
        WTA_Config.GlowColorPlayer = val
    end, L.TT_GLOW_COLOR)
    UI.CreateCheckbox(grpPlayer, L.TXT_PLAYER, 15, -80, WTA_Config.TextPlayer, function(val)
        WTA_Config.TextPlayer = val; RebuildFrameCache()
    end, L.TT_TXT_PLAYER)
    local ddColorPlayer = UI.CreateDropdown(grpPlayer, L.TXT_COLOR, 220, -75, TEXT_COLOR_ITEMS, WTA_Config.TextColorPlayer or "AUTO", function(val)
        WTA_Config.TextColorPlayer = val
    end, L.TT_TXT_COLOR)
    local sldSizePlayer = UI.CreateSlider(grpPlayer, L.SIZE, 15, -125, 8, 30, WTA_Config.SizePlayer or 16, function(val)
        WTA_Config.SizePlayer = val; RebuildDebounced()
    end, L.TT_SIZE)
    local btnPosPlayer = UI.CreateButton(grpPlayer, "", 100, 22, 270, -123, function(self)
        local current = WTA_Config.PosPlayer or "CENTER"
        local idx = 5; for i, v in ipairs(POS_ANCHORS) do if v == current then idx = i; break end end
        idx = (idx % 9) + 1; WTA_Config.PosPlayer = POS_ANCHORS[idx]; self:SetText(L.POS[idx]); RebuildFrameCache()
    end, L.TT_POS)

    local grpParty = UI.CreateGroup(pageApparence, L.PARTY, 400, 150, 10, -165)
    UI.CreateCheckbox(grpParty, L.PARTY, 15, -30, WTA_Config.EnableParty, function(val)
        WTA_Config.EnableParty = val; RebuildFrameCache()
    end, L.TT_PARTY)
    local ddGlowColorParty = UI.CreateDropdown(grpParty, L.GLOW_COLOR, 220, -25, GLOW_COLOR_ITEMS, WTA_Config.GlowColorParty or "AUTO", function(val)
        WTA_Config.GlowColorParty = val
    end, L.TT_GLOW_COLOR)
    UI.CreateCheckbox(grpParty, L.TXT_PARTY, 15, -80, WTA_Config.TextParty, function(val)
        WTA_Config.TextParty = val; RebuildFrameCache()
    end, L.TT_TXT_PARTY)
    local ddColorParty = UI.CreateDropdown(grpParty, L.TXT_COLOR, 220, -75, TEXT_COLOR_ITEMS, WTA_Config.TextColorParty or "AUTO", function(val)
        WTA_Config.TextColorParty = val
    end, L.TT_TXT_COLOR)
    local sldSizeParty = UI.CreateSlider(grpParty, L.SIZE, 15, -125, 8, 20, WTA_Config.SizeParty or 12, function(val)
        WTA_Config.SizeParty = val; RebuildDebounced()
    end, L.TT_SIZE)
    local btnPosParty = UI.CreateButton(grpParty, "", 100, 22, 270, -123, function(self)
        local current = WTA_Config.PosParty or "CENTER"
        local idx = 5; for i, v in ipairs(POS_ANCHORS) do if v == current then idx = i; break end end
        idx = (idx % 9) + 1; WTA_Config.PosParty = POS_ANCHORS[idx]; self:SetText(L.POS[idx]); RebuildFrameCache()
    end, L.TT_POS)

    local grpRaid = UI.CreateGroup(pageApparence, L.RAID, 400, 150, 10, -320)
    UI.CreateCheckbox(grpRaid, L.RAID, 15, -30, WTA_Config.EnableRaid, function(val)
        WTA_Config.EnableRaid = val; RebuildFrameCache()
    end, L.TT_RAID)
    local ddGlowColorRaid = UI.CreateDropdown(grpRaid, L.GLOW_COLOR, 220, -25, GLOW_COLOR_ITEMS, WTA_Config.GlowColorRaid or "AUTO", function(val)
        WTA_Config.GlowColorRaid = val
    end, L.TT_GLOW_COLOR)
    UI.CreateCheckbox(grpRaid, L.TXT_RAID, 15, -80, WTA_Config.TextRaid, function(val)
        WTA_Config.TextRaid = val; RebuildFrameCache()
    end, L.TT_TXT_RAID)
    local ddColorRaid = UI.CreateDropdown(grpRaid, L.TXT_COLOR, 220, -75, TEXT_COLOR_ITEMS, WTA_Config.TextColorRaid or "AUTO", function(val)
        WTA_Config.TextColorRaid = val
    end, L.TT_TXT_COLOR)
    local sldSizeRaid = UI.CreateSlider(grpRaid, L.SIZE, 15, -125, 8, 20, WTA_Config.SizeRaid or 10, function(val)
        WTA_Config.SizeRaid = val; RebuildDebounced()
    end, L.TT_SIZE)
    local btnPosRaid = UI.CreateButton(grpRaid, "", 100, 22, 270, -123, function(self)
        local current = WTA_Config.PosRaid or "CENTER"
        local idx = 5; for i, v in ipairs(POS_ANCHORS) do if v == current then idx = i; break end end
        idx = (idx % 9) + 1; WTA_Config.PosRaid = POS_ANCHORS[idx]; self:SetText(L.POS[idx]); RebuildFrameCache()
    end, L.TT_POS)

    -- ================= PAGE 2 : GÉNÉRAL =================
    local grpGeneral = UI.CreateGroup(pageGeneral, L.SectionGEN, 400, 65, 10, -10)
    UI.CreateCheckbox(grpGeneral, L.COMBAT, 15, -35, WTA_Config.OnlyInCombat, function(val)
        WTA_Config.OnlyInCombat = val; RebuildFrameCache(); SyncTickerState()
    end, L.TT_COMBAT)

    local grpFXPlayer = UI.CreateGroup(pageGeneral, L.PLAYER, 195, 170, 10, -85)
    local sldGlowAlphaPlayer = UI.CreateSlider(grpFXPlayer, L.GLOW_ALPHA, 38, -40, 1, 10, WTA_Config.GlowAlphaPlayer or 10, function(val)
        WTA_Config.GlowAlphaPlayer = val
    end, L.TT_GLOW_ALPHA)
    UI.CreateCheckbox(grpFXPlayer, L.FLASH_ENABLE, 15, -85, WTA_Config.FlashEnabledPlayer, function(val)
        WTA_Config.FlashEnabledPlayer = val
    end, L.TT_FLASH_ENABLE)
    local sldFlashSpeedPlayer = UI.CreateSlider(grpFXPlayer, L.FLASH_SPEED, 38, -130, 1, 20, WTA_Config.FlashSpeedPlayer or 8, function(val)
        WTA_Config.FlashSpeedPlayer = val
    end, L.TT_FLASH_SPEED)

    local grpFXParty = UI.CreateGroup(pageGeneral, L.PARTY, 195, 170, 215, -85)
    local sldGlowAlphaParty = UI.CreateSlider(grpFXParty, L.GLOW_ALPHA, 38, -40, 1, 10, WTA_Config.GlowAlphaParty or 10, function(val)
        WTA_Config.GlowAlphaParty = val
    end, L.TT_GLOW_ALPHA)
    UI.CreateCheckbox(grpFXParty, L.FLASH_ENABLE, 15, -85, WTA_Config.FlashEnabledParty, function(val)
        WTA_Config.FlashEnabledParty = val
    end, L.TT_FLASH_ENABLE)
    local sldFlashSpeedParty = UI.CreateSlider(grpFXParty, L.FLASH_SPEED, 38, -130, 1, 20, WTA_Config.FlashSpeedParty or 8, function(val)
        WTA_Config.FlashSpeedParty = val
    end, L.TT_FLASH_SPEED)

    local grpFXRaid = UI.CreateGroup(pageGeneral, L.RAID, 195, 170, 10, -265)
    local sldGlowAlphaRaid = UI.CreateSlider(grpFXRaid, L.GLOW_ALPHA, 38, -40, 1, 10, WTA_Config.GlowAlphaRaid or 10, function(val)
        WTA_Config.GlowAlphaRaid = val
    end, L.TT_GLOW_ALPHA)
    UI.CreateCheckbox(grpFXRaid, L.FLASH_ENABLE, 15, -85, WTA_Config.FlashEnabledRaid, function(val)
        WTA_Config.FlashEnabledRaid = val
    end, L.TT_FLASH_ENABLE)
    local sldFlashSpeedRaid = UI.CreateSlider(grpFXRaid, L.FLASH_SPEED, 38, -130, 1, 20, WTA_Config.FlashSpeedRaid or 8, function(val)
        WTA_Config.FlashSpeedRaid = val
    end, L.TT_FLASH_SPEED)

    local grpFXTarget = UI.CreateGroup(pageGeneral, L.SectionTARGET, 195, 170, 215, -265)
    local sldGlowAlphaTarget = UI.CreateSlider(grpFXTarget, L.GLOW_ALPHA, 38, -40, 1, 10, WTA_Config.GlowAlphaTarget or 10, function(val)
        WTA_Config.GlowAlphaTarget = val
    end, L.TT_GLOW_ALPHA)
    UI.CreateCheckbox(grpFXTarget, L.FLASH_ENABLE, 15, -85, WTA_Config.FlashEnabledTarget, function(val)
        WTA_Config.FlashEnabledTarget = val
    end, L.TT_FLASH_ENABLE)
    local sldFlashSpeedTarget = UI.CreateSlider(grpFXTarget, L.FLASH_SPEED, 38, -130, 1, 20, WTA_Config.FlashSpeedTarget or 8, function(val)
        WTA_Config.FlashSpeedTarget = val
    end, L.TT_FLASH_SPEED)

    -- ================= PAGE 3 : ALERTES =================
    local grpThreshold = UI.CreateGroup(pageAlertes, L.SectionALERT, 400, 90, 10, -10)
    local sldThreshold = UI.CreateSlider(grpThreshold, L.THRESHOLD, 15, -45, 50, 100, WTA_Config.AlertThreshold or 100, function(val)
        WTA_Config.AlertThreshold = val
    end, L.TT_THRESHOLD)

    local grpAggroAlert = UI.CreateGroup(pageAlertes, L.AGGRO_ALERT, 400, 230, 10, -115)
    UI.CreateCheckbox(grpAggroAlert, L.AGGRO_ALERT, 15, -30, WTA_Config.EnableAggroAlert, function(val)
        WTA_Config.EnableAggroAlert = val
        if not val and AggroAlertFrame then AggroAlertFrame:Hide() end
        RebuildFrameCache()
    end, L.TT_AGGRO_ALERT)
    local sldAggroSize = UI.CreateSlider(grpAggroAlert, L.SIZE, 15, -65, 8, 24, WTA_Config.AggroAlertSize or 14, function(val)
        WTA_Config.AggroAlertSize = val
        RefreshAggroAlertFrame()
    end, L.TT_SIZE)
    UI.CreateCheckbox(grpAggroAlert, L.MERGE_AGGRO_TEXT, 15, -95, WTA_Config.MergeAggroPercent, function(val)
        WTA_Config.MergeAggroPercent = val
        RebuildFrameCache()
    end, L.TT_MERGE_AGGRO_TEXT)
    UI.CreateCheckbox(grpAggroAlert, L.BORDER, 15, -150, WTA_Config.AggroAlertBorder ~= false, function(val)
        WTA_Config.AggroAlertBorder = val
        RefreshAggroAlertFrame()
    end, L.TT_BORDER)
    local sldAggroEdge = UI.CreateSlider(grpAggroAlert, L.EDGE_SIZE, 180, -155, 4, 20, WTA_Config.AggroAlertEdge or 12, function(val)
        WTA_Config.AggroAlertEdge = val
        RefreshAggroAlertFrame()
    end, L.TT_EDGE_SIZE)
    UI.CreateCheckbox(grpAggroAlert, L.BG, 15, -190, WTA_Config.AggroAlertBg ~= false, function(val)
        WTA_Config.AggroAlertBg = val
        RefreshAggroAlertFrame()
    end, L.TT_BG)
    local sldAggroOpacity = UI.CreateSlider(grpAggroAlert, L.OPACITY, 180, -195, 0, 10, WTA_Config.AggroAlertOpacity or 7, function(val)
        WTA_Config.AggroAlertOpacity = val
        RefreshAggroAlertFrame()
    end, L.TT_OPACITY)

    local grpTargetGlow = UI.CreateGroup(pageAlertes, L.SectionTARGET, 400, 70, 10, -355)
    UI.CreateCheckbox(grpTargetGlow, L.TARGET_GLOW, 15, -30, WTA_Config.EnableTargetGlow, function(val)
        WTA_Config.EnableTargetGlow = val
        if not val and TargetGlow then TargetGlow:Hide() end
    end, L.TT_TARGET_GLOW)

    -- Fonction interne pour rafraîchir les boutons de positions après un reset
    local function UpdatePositionButtonTexts()
        for _, btnData in ipairs({ {btnPosPlayer, "PosPlayer"}, {btnPosParty, "PosParty"}, {btnPosRaid, "PosRaid"} }) do
            local current = WTA_Config[btnData[2]] or "CENTER"
            local idx = 5
            for i, v in ipairs(POS_ANCHORS) do if v == current then idx = i; break end end
            btnData[1]:SetText(L.POS[idx])
        end
    end

    local function UpdateDropdownColors()
        ddColorPlayer:Refresh(WTA_Config.TextColorPlayer or "AUTO")
        ddColorParty:Refresh(WTA_Config.TextColorParty   or "AUTO")
        ddColorRaid:Refresh(WTA_Config.TextColorRaid     or "AUTO")
        ddGlowColorPlayer:Refresh(WTA_Config.GlowColorPlayer or "AUTO")
        ddGlowColorParty:Refresh(WTA_Config.GlowColorParty   or "AUTO")
        ddGlowColorRaid:Refresh(WTA_Config.GlowColorRaid     or "AUTO")
    end

    RefreshOptionsPanel = function()
        UpdatePositionButtonTexts()
        UpdateDropdownColors()
        sldSizePlayer:SetValue(WTA_Config.SizePlayer)
        sldSizeParty:SetValue(WTA_Config.SizeParty)
        sldSizeRaid:SetValue(WTA_Config.SizeRaid)
        sldGlowAlphaPlayer:SetValue(WTA_Config.GlowAlphaPlayer)
        sldFlashSpeedPlayer:SetValue(WTA_Config.FlashSpeedPlayer)
        sldGlowAlphaParty:SetValue(WTA_Config.GlowAlphaParty)
        sldFlashSpeedParty:SetValue(WTA_Config.FlashSpeedParty)
        sldGlowAlphaRaid:SetValue(WTA_Config.GlowAlphaRaid)
        sldFlashSpeedRaid:SetValue(WTA_Config.FlashSpeedRaid)
        sldGlowAlphaTarget:SetValue(WTA_Config.GlowAlphaTarget)
        sldFlashSpeedTarget:SetValue(WTA_Config.FlashSpeedTarget)
        sldThreshold:SetValue(WTA_Config.AlertThreshold)
        sldAggroSize:SetValue(WTA_Config.AggroAlertSize)
        sldAggroEdge:SetValue(WTA_Config.AggroAlertEdge)
        sldAggroOpacity:SetValue(WTA_Config.AggroAlertOpacity)
    end

    -- ================= BOUTONS INFÉRIEURS GLOBAUX =================
    -- [Réinitialiser]  [Test Visuel]  [Fermer] sur une ligne
    UI.CreateButton(OptionsPanel, L.RESET, 120, 24, 30, -545, function()
        for k, v in pairs(DEFAULTS) do WTA_Config[k] = v end
        if AggroAlertFrame then AggroAlertFrame:Hide() end
        if TargetGlow then TargetGlow:Hide() end
        RebuildFrameCache()
        SyncTickerState()
        RefreshOptionsPanel()
        OptionsPanel:Hide(); OptionsPanel:Show()
    end, L.TT_RESET)

    btnTestMode = UI.CreateButton(OptionsPanel, L.BtnTEST_OFF, 140, 24, 152, -545, ToggleTestMode, L.TT_TEST)

    UI.CreateButton(OptionsPanel, L.CLOSE, 120, 24, 295, -545, function() OptionsPanel:Hide() end)

    UpdatePositionButtonTexts()
end

-- =========================================================================
-- 5b. BOUTON MINIMAP (natif, sans lib externe)
-- =========================================================================
local minimapButton = nil

local function UpdateMinimapButtonPosition()
    if not minimapButton then return end
    local angle = math.rad(WTA_Config.MinimapAngle or 225)
    local radius = 80
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function CreateMinimapButton()
    if minimapButton then return end
    if WTA_Config.MinimapAngle == nil then WTA_Config.MinimapAngle = 225 end

    local btn = CreateFrame("Button", "WTA_MinimapButton", Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")

    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetTexture("Interface\\AddOns\\WhoThreatAggro\\WTA-icon")
    icon:SetPoint("CENTER", 0, 1)

    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetSize(30, 30)
    highlight:SetPoint("CENTER")
    highlight:SetBlendMode("ADD")

    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            WTA_Config.MinimapAngle = math.deg(math.atan2(py - my, px - mx))
            UpdateMinimapButtonPosition()
        end)
    end)
    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    btn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            CreateOptionsPanel()
            if OptionsPanel:IsShown() then
                OptionsPanel:Hide()
            else
                OptionsPanel:Show()
            end
        elseif button == "RightButton" then
            ToggleTestMode()
        end
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(L.TITLE)
        GameTooltip:AddLine(L.MINIMAP_TT_LEFT, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_TT_RIGHT, 1, 1, 1)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    minimapButton = btn
    UpdateMinimapButtonPosition()
end

-- =========================================================================
-- 6. ENGINE (C_Timer.NewTicker)
-- =========================================================================
ThreatLoop = function()
    if not AddonReady or not WTA_Config then return end

    if isTestMode then
        for _, data in ipairs(TrackedFrames) do
            if data.frame:IsVisible() then
                local glow = GetOrCreateGlow(data.frame, data.glowType)
                if glow then
                    local baseAlpha  = GetFXAlpha(data.category)
                    local flashOn    = GetFXFlashOn(data.category)
                    local flashSpeed = GetFXFlashSpeed(data.category)
                    local alpha = flashOn and (baseAlpha * (0.3 + 0.7 * math.abs(math.sin(GetTime() * flashSpeed)))) or baseAlpha
                    glow:Show()
                    local gr, gg, gb = GetGlowColor(data.category, COLORS.RED)
                    glow:SetVertexColor(gr, gg, gb, alpha)
                end
                if data.showText then
                    if data.category == "PLAYER" and WTA_Config.MergeAggroPercent and WTA_Config.EnableAggroAlert then
                        if data.frame.WTA_TextFrame then data.frame.WTA_TextFrame:Hide() end
                    else
                        local tf = GetOrCreateTextFrame(data.frame, data.category)
                        if tf then
                            local tr, tg, tb = GetTextColor(data.category, COLORS.RED)
                            tf.text:SetText("100%")
                            tf.text:SetTextColor(tr, tg, tb, 1)
                            tf:Show()
                        end
                    end
                end
            else
                if data.frame.WTA_Glow      then data.frame.WTA_Glow:Hide()     end
                if data.frame.WTA_TextFrame then data.frame.WTA_TextFrame:Hide() end
            end
        end
        -- AggroAlert en test mode
        if WTA_Config.EnableAggroAlert then
            local af = GetOrCreateAggroAlertFrame()
            local label = L.AGGRO_ALERT_LABEL .. " |cffFF3333Test|r"
            if WTA_Config.MergeAggroPercent then label = label .. " - 100%" end
            af.label:SetText(label)
            AutoSizeAggroAlertFrame(af)
            af:Show()
        end

        -- Lueur cible en test mode
        if WTA_Config.EnableTargetGlow then
            local tg = GetOrCreateTargetGlow()
            if tg then
                local baseAlpha  = GetFXAlpha("TARGET")
                local flashOn    = GetFXFlashOn("TARGET")
                local flashSpeed = GetFXFlashSpeed("TARGET")
                local alpha = flashOn and (baseAlpha * (0.3 + 0.7 * math.abs(math.sin(GetTime() * flashSpeed)))) or baseAlpha
                tg:SetVertexColor(1, 0, 0, 1)
                tg:SetAlpha(alpha)
                tg:Show()
            end
        end
        return
    end

    if WTA_Config.OnlyInCombat and not isInCombat then
        HideAllOverlays()
        return
    end

    for _, data in ipairs(TrackedFrames) do
        local frame = data.frame
        if frame and frame:IsVisible() then
            local color, flash, percent = GetThreatData(data.unit)
            local glow = GetOrCreateGlow(frame, data.glowType)
            local tf   = data.showText and GetOrCreateTextFrame(frame, data.category) or nil

            if color and glow then
                local gr, gg, gb, ga = GetGlowColor(data.category, color)
                glow:SetVertexColor(gr, gg, gb, ga)
                glow:Show()
                local baseAlpha  = GetFXAlpha(data.category)
                local flashOn    = GetFXFlashOn(data.category)
                local flashSpeed = GetFXFlashSpeed(data.category)
                if flash and flashOn then
                    glow:SetAlpha(baseAlpha * (0.3 + 0.7 * math.abs(math.sin(GetTime() * flashSpeed))))
                else
                    glow:SetAlpha(baseAlpha)
                end
            elseif glow then
                glow:Hide()
            end

            if tf then
                if data.category == "PLAYER" and WTA_Config.MergeAggroPercent and WTA_Config.EnableAggroAlert then
                    tf:Hide()
                elseif percent > 0 then
                    tf.text:SetText(math.floor(percent).."%")
                    local tr, tg, tb = GetTextColor(data.category, color)
                    tf.text:SetTextColor(tr, tg, tb, 1)
                    tf:Show()
                else
                    tf:Hide()
                end
            elseif frame.WTA_TextFrame then
                frame.WTA_TextFrame:Hide()
            end
        end
    end

    -- Calcul partagé : le joueur a-t-il l'aggro sur sa cible actuelle ?
    -- Utilisé par la Frame Aggro ET la Lueur Cible, qui sont deux options indépendantes.
    local hasAggro, playerPercent = false, 0
    if WTA_Config.EnableAggroAlert or WTA_Config.EnableTargetGlow then
        local playerColor
        playerColor, _, playerPercent = GetThreatData("player")
        hasAggro = playerColor == COLORS.RED
    end

    if WTA_Config.EnableAggroAlert then
        local af = GetOrCreateAggroAlertFrame()
        if hasAggro then
            local label = L.AGGRO_ALERT_LABEL .. " |cffFF3333" .. (UnitName("target") or "?") .. "|r"
            if WTA_Config.MergeAggroPercent then
                label = label .. " - " .. math.floor(playerPercent or 100) .. "%"
            end
            af.label:SetText(label)
            AutoSizeAggroAlertFrame(af)
            af:Show()
        else
            af:Hide()
        end
    elseif AggroAlertFrame then
        AggroAlertFrame:Hide()
    end

    if WTA_Config.EnableTargetGlow then
        local tg = GetOrCreateTargetGlow()
        if tg then
            if hasAggro then
                tg:SetVertexColor(unpack(COLORS.RED))
                local baseAlpha  = GetFXAlpha("TARGET")
                local flashOn    = GetFXFlashOn("TARGET")
                local flashSpeed = GetFXFlashSpeed("TARGET")
                if flashOn then
                    tg:SetAlpha(baseAlpha * (0.3 + 0.7 * math.abs(math.sin(GetTime() * flashSpeed))))
                else
                    tg:SetAlpha(baseAlpha)
                end
                tg:Show()
            else
                tg:Hide()
            end
        end
    elseif TargetGlow then
        TargetGlow:Hide()
    end
end

-- =========================================================================
-- 7. EVENTS
-- =========================================================================
local addonInitialized = false
local threatUpdatePending = false

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
-- Réaction immédiate aux changements de menace sans attendre le prochain tick
eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "WhoThreatAggro" then
        if not WTA_Config then WTA_Config = {} end
        for k, v in pairs(DEFAULTS) do
            if WTA_Config[k] == nil then WTA_Config[k] = v end
        end
        CreateMinimapButton()

    elseif event == "PLAYER_ENTERING_WORLD" then
        isOptimizedMode = false
        isInCombat = UnitAffectingCombat("player") == true
        C_Timer.After(2, function()
            if not addonInitialized then
                addonInitialized = true
                AddonReady = true
                -- Démarre le ticker si nécessaire (combat, mode test, ou OnlyInCombat désactivé)
                SyncTickerState()
                print("|cffFFD700[WTA]|r " .. L.READY)
            end
            RebuildFrameCache()
        end)

    elseif event == "GROUP_ROSTER_UPDATE" then
        if AddonReady then RebuildFrameCache() end

    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Début de combat
        isInCombat = true
        if AddonReady then SyncTickerState() end

    elseif event == "PLAYER_DEAD" then
        -- Mort : plus d'aggro possible
        isInCombat = false
        HideAllOverlays()
        if not isTestMode then StopTicker() end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Fin de combat : on cache seulement si OnlyInCombat est actif
        -- (sinon le ticker continue et ThreatLoop réévalue l'affichage lui-même)
        isInCombat = false
        if WTA_Config and WTA_Config.OnlyInCombat then HideAllOverlays() end
        SyncTickerState()

    elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
        -- Déclenchement quasi-immédiat du loop sur changement de menace
        -- (sans reconstruire le cache, juste re-évaluer).
        -- Regroupé sur 1 frame : en gros raid, plusieurs membres peuvent changer
        -- de statut au même instant, ce qui déclencherait sinon N ThreatLoop()
        -- redondants pour un seul instant de jeu.
        if AddonReady and not isTestMode and not threatUpdatePending then
            threatUpdatePending = true
            C_Timer.After(0, function()
                threatUpdatePending = false
                if AddonReady and not isTestMode then ThreatLoop() end
            end)
        end

    elseif event == "PLAYER_TARGET_CHANGED" then
        -- Rebuild pour recalculer la menace sur la nouvelle cible
        if AddonReady then RebuildFrameCache() end
    end
end)

-- =========================================================================
-- 8. SLASH COMMANDS
-- =========================================================================
SLASH_WTA1 = "/wta"
SlashCmdList["WTA"] = function(msg)
    local cmd = (msg or ""):match("^%s*(.-)%s*$"):lower()

    if cmd == "test" then
        ToggleTestMode()
    elseif cmd == "reset" then
        for k, v in pairs(DEFAULTS) do WTA_Config[k] = v end
        if AggroAlertFrame then AggroAlertFrame:Hide() end
        if TargetGlow then TargetGlow:Hide() end
        RebuildFrameCache()
        SyncTickerState()
        if RefreshOptionsPanel then RefreshOptionsPanel() end
        print("|cffFFD700[WTA]|r Configuration réinitialisée.")
    else
        CreateOptionsPanel()
        OptionsPanel:Show()
    end
end
