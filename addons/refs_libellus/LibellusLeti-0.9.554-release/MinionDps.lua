Mancer.MinionDpsModule = {}
local MinionDps = Mancer.MinionDpsModule

local MAX_SAVED_FIGHTS = 10
local SESSION_MIN_FIGHTS = 1

local DAMAGE_EVENTS = {
    SWING_DAMAGE = true,
    RANGE_DAMAGE = true,
    SPELL_DAMAGE = true,
    SPELL_PERIODIC_DAMAGE = true,
    DAMAGE_SPLIT = true,
}

-- Miss / avoid events (no damage). Tracked for hit% on minion melee & spells.
local MISS_EVENTS = {
    SWING_MISSED = true,
    RANGE_MISSED = true,
    SPELL_MISSED = true,
    SPELL_PERIODIC_MISSED = true,
}

local AURA_EVENTS = {
    SPELL_AURA_APPLIED = true,
    SPELL_AURA_REFRESH = true,
    SPELL_AURA_REMOVED = true,
    SPELL_AURA_APPLIED_DOSE = true,
    SPELL_AURA_REMOVED_DOSE = true,
}

-- Player extras: DoT uptime / proc counts (still allowlisted).
-- All other player-sourced damage is captured Details-style by CLEU source GUID.
local PLAYER_TRACKED_SPELLS = {
    {
        id = "blight",
        kind = "dot",
        label = "Blight",
        names = { ["Blight"] = true },
        spellIds = {},
    },
    {
        id = "harvest_plague",
        kind = "dot",
        label = "Harvest Plague",
        names = {
            ["Harvest Plague"] = true,
            ["harvest plague"] = true,
        },
        -- Ranked spell IDs from Ascension Spell.dbc (trainer ranks).
        spellIds = {
            [500968] = true,
            [501890] = true,
            [501891] = true,
            [501892] = true,
            [583255] = true,
            [583256] = true,
            [572842] = true,
            [572843] = true,
            [572844] = true,
            [572845] = true,
        },
    },
}

do
    for _, aura in ipairs(Mancer.PROC_AURAS or {}) do
        local ids = {}
        for _, sid in ipairs(aura.spellIds or {}) do
            ids[sid] = true
        end
        local names = {}
        if aura.label then
            names[aura.label] = true
        end
        table.insert(PLAYER_TRACKED_SPELLS, {
            id = aura.id,
            kind = "proc",
            label = aura.label,
            names = names,
            spellIds = ids,
        })
    end
end

table.insert(PLAYER_TRACKED_SPELLS, {
    -- CA / spell 500267 — Expunge Blight (player damage + cast count).
    id = "expunge_blight",
    kind = "spell",
    label = "Expunge Blight",
    names = {
        ["Expunge Blight"] = true,
        ["Expunge from Blight"] = true,
        ["expunge blight"] = true,
    },
    spellIds = {
        [500267] = true,
    },
})

local OBJECT_TYPE_PET = 0x00001000
local OBJECT_TYPE_GUARDIAN = 0x00002000
local AFFILIATION_MINE = 0x00000001
local REACTION_FRIENDLY = 0x00000010
local CONTROL_PLAYER = 0x00000100

local LF_COMBO_MINIONS = {
    "abomination",
    "crypt_fiend",
    "banshee",
    "skeletal_warrior_lesser",
    "skeletal_warrior_greater",
    "skeletal_rogue",
}

local CD_MINIONS = {
    "bone_wraith",
    "skeletal_archer",
    "tomb_king",
    "plaguefather",
    "frost_wyrm",
}

-- Plain-language ST vs AoE roles for Hub / tooltips (not a second math engine).
-- focus: "st" | "aoe" | "both" | "burst"
local FIGHT_ROLES = {
    ghoul = {
        focus = "st",
        bestFor = "Bosses (one target)",
        oneLiner = "Your main army for boss damage. Fill leftover Life Force with these.",
    },
    abomination = {
        focus = "st",
        bestFor = "Bosses (one target)",
        oneLiner = "About as strong as three ghouls — and unlocks Army of the Dead haste.",
    },
    decaying_colossus = {
        focus = "both",
        bestFor = "Survivability (not AotD)",
        oneLiner = "3 LF damage sponge — shifts damage onto the Colossus. Does not enable Army of the Dead.",
    },
    crypt_fiend = {
        focus = "aoe",
        bestFor = "Packs & AoE",
        oneLiner = "Best Raise when several enemies are stacked. Costs 2 Life Force.",
    },
    banshee = {
        focus = "st",
        bestFor = "Bosses / mana drain",
        oneLiner = "Channels on one target and drains mana. Costs 2 Life Force — strong vs casters.",
    },
    skeletal_warrior_greater = {
        focus = "both",
        bestFor = "Either (usually filler)",
        oneLiner = "Fine either way; ghouls or Crypt Fiend usually beat it for your Life Force.",
    },
    skeletal_warrior_lesser = {
        focus = "both",
        bestFor = "Either (usually filler)",
        oneLiner = "Early option. Swap toward ghouls / Abom / Crypt Fiend as you unlock them.",
    },
    skeletal_rogue = {
        focus = "st",
        bestFor = "Bosses (niche)",
        oneLiner = "Niche single-target Raise. Check Hub → LF Combo before forcing it in.",
    },
    bone_wraith = {
        focus = "burst",
        bestFor = "Boss burst (Animate)",
        oneLiner = "Best Animate for one tough enemy. No Life Force cost — press when ready.",
    },
    tomb_king = {
        focus = "aoe",
        bestFor = "Packs / big army",
        oneLiner = "Short buff for the whole army. Stronger when many minions are already out.",
    },
    skeletal_archer = {
        focus = "both",
        bestFor = "Always (on cooldown)",
        oneLiner = "Free Animate damage. Press whenever it is ready.",
    },
    plaguefather = {
        focus = "both",
        bestFor = "Always (on cooldown)",
        oneLiner = "Cooldown Animate. Use when ready alongside your army.",
    },
    frost_wyrm = {
        focus = "both",
        bestFor = "Always (on cooldown)",
        oneLiner = "Cooldown Animate. Use when ready alongside your army.",
    },
}

local FIGHT_ROLE_ORDER = {
    "abomination",
    "ghoul",
    "crypt_fiend",
    "banshee",
    "skeletal_warrior_greater",
    "skeletal_warrior_lesser",
    "skeletal_rogue",
    "bone_wraith",
    "tomb_king",
    "skeletal_archer",
    "plaguefather",
    "frost_wyrm",
}

local TEMP_DURATION_FALLBACK = {
    bone_wraith = 60,
    skeletal_archer = 18,
    tomb_king = 15,
}

-- Ascension hex GUID creature signatures from /dump UnitGUID("target") on summoned minions.
-- Format: 0xF130<6-char sig><spawn id> e.g. Skeletal Archer = 0xF13000C39C008AFA
-- Creature entry → hex: 50076→00c39c, 50320→00c490, 50115→00c3c3, 50073→00c399
local GUID_CREATURE_SIGS = {
    ["00c39c"] = "skeletal_archer",
    ["00c490"] = "tomb_king",
    ["00c3c3"] = "decaying_colossus",
    ["00c399"] = "ghoul",
    ["07acf7"] = "lesser_zombie",
}

local function GuidCreatureSig(guid)
    if not guid then
        return nil
    end
    return tostring(guid):lower():match("^0x[f]?130(%x%x%x%x%x%x)")
end

-- Details-style per-pet breakdown (one CLEU source GUID = one "Attack" row).
local UNIT_TRACKED_MINIONS = {
    ghoul = true,
    lesser_zombie = true,
    other_owned = true, -- unnamed fallback only
}

-- Catch-all when owned pet has no usable name.
local OTHER_OWNED_ID = "other_owned"
local OWNED_NAME_PREFIX = "owned:"

local function CleanMinionSourceName(sourceName)
    if not sourceName or sourceName == "" then
        return nil
    end
    local cleaned = tostring(sourceName)
        :gsub("|c%x%x%x%x%x%x%x%x", "")
        :gsub("|r", "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
    if cleaned == "" then
        return nil
    end
    return cleaned
end

-- Group unclassified owned pets by creature name (top-level DPS rows).
local function OwnedNameBucketId(sourceName)
    local cleaned = CleanMinionSourceName(sourceName)
    if not cleaned then
        return OTHER_OWNED_ID
    end
    return OWNED_NAME_PREFIX .. string.lower(cleaned)
end

local function IsOwnedNameBucket(minionId)
    return type(minionId) == "string" and minionId:sub(1, #OWNED_NAME_PREFIX) == OWNED_NAME_PREFIX
end

local function OwnedNameDisplayLabel(minionId, bucket)
    if bucket and bucket.displayLabel and bucket.displayLabel ~= "" then
        return bucket.displayLabel
    end
    if IsOwnedNameBucket(minionId) then
        local raw = minionId:sub(#OWNED_NAME_PREFIX + 1)
        return (raw:gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
        end))
    end
    return "Other owned"
end

-- High-level calibration anchors (live Minion DPS overwrites when saved fights exist).
-- NEVER put AoE-dummy DPS into BENCHMARK_DPS — LF Combo / tooltips treat that table as
-- single-target boss placeholders and would overstate boss armies.
--
-- Early Details lvl~30: 1 Abom + 2 Ghoul → Abom ~206, Ghoul ~70 DPS/unit.
-- Mortuus lvl~41 long ST non-tank (~475s, geared+talents): Ghoul ~152 DPS/unit,
--   Command ~78% / Melee ~18% / Claws ~4%. Tomb King ~32% wall uptime.
-- Mortuus lvl~41 melee-only geared: ~16–17 DPS/unit (0.882 Wraith AP inherit over-predicted).
-- Mortuus lvl~41 naked (0 gear SP, INT 78, talents stripped):
--   5-ghoul army melee-only ≈ 6 DPS/unit; single ghoul ≈ 6–7 DPS (430/70s, hit ≈10–12).
--   Floor for AP-inherit A/B — not a 0.882 confirm.
-- Azuregos Pathstalker lvl60 WB: Command ~30% of ghoul package (autos-led).
--
-- Mortuus lvl60 AOE training dummies (2026-07-25, Libellus 0.9.486 export, ~196s fight,
--   NOT hit-capped, multi-dummy pack). DPS/unit from addon export — pack numbers only:
--   Ghoul 411 (Command 83.1% / Melee 16.9%) · Lesser Zombie 255 · Frost Wyrm 1528
--   Skeletal Archer 96 · Bone Wraith 134 · Plaguefather ~3 (2 hits — not a sample).
--   Player: Blight 351 DPS (6 targets) · Harvest Plague 78 · Expunge 23.
--
-- Mortuus lvl60 ST Details "Took damage from" (2026-07-25, NOT hit-capped). Damage shares
--   only — fight duration unknown, so no DPS/unit claimed from this parse:
--   Ghoul Melee 228k (20.6%) · Archer 160k (14.5%) · Frost Wyrm 153k (13.9%)
--   Command: Ghouls 152k (13.7%) · Crypt Swarm 119k (10.8%) · Zombie melee 54.8k (5.0%)
--   Ghoul Command vs Melee (those two only): Command ~40% / Melee ~60% (AoE was ~83/17).
--   Plaguefather melee 15.6k — real ST contribution (unlike the AoE export).
local CALIB_GHOUL_DPS_EARLY = 70
local CALIB_GHOUL_DPS_MID41 = 152
local CALIB_GHOUL_DPS_NAKED41 = 6.5
local CALIB_ABOM_DPS = 206
local CALIB_COMMAND_SHARE_LONG_ST = 0.785
-- Extrapolated early: 3rd ghoul ≈ +70 ST DPS; 3 ghouls (~210) ≈ 1 abom (~206).

-- Pack reference only (see comment block above). Not used by LF Combo scoring.
local CALIB_AOE_L60 = {
    label = "L60 AoE dummies (not hit-capped)",
    fightSec = 196,
    hitCapped = false,
    targetStyle = "aoe_dummies",
    dpsPerUnit = {
        ghoul = 411,
        lesser_zombie = 255,
        frost_wyrm = 1528,
        skeletal_archer = 96,
        bone_wraith = 134,
        -- plaguefather omitted — 2 melee hits, not a real sample
    },
    ghoulCommandShare = 0.831,
    ghoulMeleeShare = 0.169,
    player = {
        blightDps = 351,
        blightTargets = 6,
        harvestPlagueDps = 78,
        expungeBlightDps = 23,
    },
}

-- ST composition from Details (damage on one target). No fightSec → no DPS/unit here.
local CALIB_ST_L60_DETAILS = {
    label = "L60 ST Details (not hit-capped)",
    hitCapped = false,
    targetStyle = "single_target",
    source = "details_took_damage",
    -- Absolute damage (thousands) as shown in Details; shares are of listed total.
    damageK = {
        ghoul_melee = 228,
        skeletal_arrow = 160,
        frost_wyrm_breath = 153,
        command_ghouls = 152,
        crypt_swarm = 119,
        zombie_melee = 54.8,
        zombie_plague_ghoul = 41.4,
        harvest_plague = 37.8,
        lichfrost = 33.9,
        zombie_plague_zombie = 33.5,
        bonestorm = 24.1,
        blight = 19.1,
        plaguefather_melee = 15.6,
        expunge_blight = 11.7,
        zombie_plague_plaguefather = 9.4,
        bone_wraith_melee = 8.0,
        zombie_plague_bone_wraith = 2.1,
    },
    sharePct = {
        ghoul_melee = 20.6,
        skeletal_arrow = 14.5,
        frost_wyrm_breath = 13.9,
        command_ghouls = 13.7,
        crypt_swarm = 10.8,
        zombie_melee = 5.0,
        blight = 1.7,
        plaguefather_melee = 1.4,
        bonestorm = 2.2,
    },
    -- Command vs Melee only (152 / 380) — ST autos-led; AoE Command-led.
    ghoulCommandShare = 0.40,
    ghoulMeleeShare = 0.60,
}

local BENCHMARK_DPS = {
    [30] = {
        ghoul = 9.5,
        abomination = 33,
        crypt_fiend = 60,
        skeletal_rogue = 7.5,
        skeletal_warrior_greater = 11.8,
        skeletal_warrior_lesser = 9.3,
    },
    -- ST placeholder when no live fights yet. Values are mid-41 ST anchors, NOT L60 AoE.
    [60] = {
        ghoul = CALIB_GHOUL_DPS_MID41,
        abomination = CALIB_ABOM_DPS,
    },
}

-- Mortuus lvl~41 non-tank dummy: Command DPS/unit ≈ 152 × 0.785 ≈ 119.
local COMMAND_GHOUL_DPS_PER_UNIT = math.floor(CALIB_GHOUL_DPS_MID41 * CALIB_COMMAND_SHARE_LONG_ST + 0.5)
local COMMAND_GHOUL_MIN_COUNT = 2

local function GetAdvisor()
    return Mancer.NecromancerAdvisorModule
end

local function IsNecromancerPlayer()
    if Mancer.Ascension and Mancer.Ascension.GetPlayerClass then
        return Mancer.Ascension.GetPlayerClass() == "NECROMANCER"
    end
    local Advisor = GetAdvisor()
    return Advisor and Advisor.IsNecromancer and Advisor:IsNecromancer()
end

local function GetTimeNow()
    return GetTime and GetTime() or 0
end

local function BitAnd(a, b)
    if bit and bit.band then
        return bit.band(a, b)
    end
    local result = 0
    for i = 0, 31 do
        local mask = 2 ^ i
        if math.floor(a / mask) % 2 == 1 and math.floor(b / mask) % 2 == 1 then
            result = result + mask
        end
    end
    return result
end

local function EnsureDb()
    MancerDB.minionDps = MancerDB.minionDps or {}
    local db = MancerDB.minionDps
    db.fights = db.fights or {}
    return db
end

local function NewMinionBucket()
    return {
        damage = 0,
        hits = 0,
        misses = 0,
        firstSeen = nil,
        lastSeen = nil,
        -- Sum of per-guid lifetimes (unit-seconds). Used for Animate CD uptime/DPS.
        activeSeconds = 0,
        summonCount = 0,
        spells = {},
    }
end

local function GetTempDuration(minionId)
    local Advisor = GetAdvisor()
    local def = Advisor and Advisor.MINION_TYPES and Advisor.MINION_TYPES[minionId]
    if def and def.duration and def.duration > 0 then
        return def.duration
    end
    return TEMP_DURATION_FALLBACK[minionId]
end

local function IsTemporaryMinion(minionId)
    local Advisor = GetAdvisor()
    if Advisor and Advisor.UsesTemporaryTracking then
        return Advisor:UsesTemporaryTracking(minionId)
    end
    return TEMP_DURATION_FALLBACK[minionId] ~= nil
end

local function ResolveSpellLabel(eventType, spellId, spellName)
    if eventType == "SWING_DAMAGE" or eventType == "SWING_MISSED" then
        return "Melee", spellId or 1
    end
    if spellName and spellName ~= "" then
        return spellName, spellId
    end
    if spellId then
        return "Spell #" .. tostring(spellId), spellId
    end
    if eventType then
        return eventType, nil
    end
    return "Unknown", nil
end

local function GetSpellKey(spellId, spellLabel)
    if spellId then
        return "id:" .. tostring(spellId)
    end
    return "name:" .. tostring(spellLabel or "Unknown")
end

local function GetSpellBucket(bucket, spellKey, spellLabel, spellId)
    bucket.spells = bucket.spells or {}
    if not bucket.spells[spellKey] then
        bucket.spells[spellKey] = {
            label = spellLabel,
            spellId = spellId,
            damage = 0,
            hits = 0,
            misses = 0,
        }
    elseif bucket.spells[spellKey].misses == nil then
        bucket.spells[spellKey].misses = 0
    end
    return bucket.spells[spellKey]
end

local MISS_TYPE_ORDER = {
    "MISS",
    "DODGE",
    "PARRY",
    "BLOCK",
    "RESIST",
    "ABSORB",
    "IMMUNE",
    "DEFLECT",
    "REFLECT",
    "EVADES",
}

local MISS_TYPE_LABEL = {
    MISS = "miss",
    DODGE = "dodge",
    PARRY = "parry",
    BLOCK = "block",
    RESIST = "resist",
    ABSORB = "absorb",
    IMMUNE = "immune",
    DEFLECT = "deflect",
    REFLECT = "reflect",
    EVADES = "evade",
}

local function NormalizeMissType(missType)
    if type(missType) ~= "string" or missType == "" then
        return "MISS"
    end
    return string.upper(missType)
end

local function CopyMissTypes(source)
    if type(source) ~= "table" then
        return nil
    end
    local copy = {}
    local any = false
    for mt, n in pairs(source) do
        n = tonumber(n) or 0
        if n > 0 then
            local key = NormalizeMissType(mt)
            copy[key] = (copy[key] or 0) + n
            any = true
        end
    end
    return any and copy or nil
end

local function MergeMissTypes(dest, source)
    if type(source) ~= "table" then
        return dest
    end
    dest = dest or {}
    for mt, n in pairs(source) do
        n = tonumber(n) or 0
        if n > 0 then
            local key = NormalizeMissType(mt)
            dest[key] = (dest[key] or 0) + n
        end
    end
    return dest
end

local function FormatHitsMisses(hits, misses, missTypes)
    hits = tonumber(hits) or 0
    misses = tonumber(misses) or 0
    local parts = { string.format("%d hits", hits) }

    local typedTotal = 0
    local seen = {}
    if type(missTypes) == "table" then
        for _, key in ipairs(MISS_TYPE_ORDER) do
            local n = tonumber(missTypes[key]) or 0
            if n > 0 then
                parts[#parts + 1] = string.format("%d %s", n, MISS_TYPE_LABEL[key] or string.lower(key))
                typedTotal = typedTotal + n
                seen[key] = true
            end
        end
        for mt, n in pairs(missTypes) do
            n = tonumber(n) or 0
            local key = NormalizeMissType(mt)
            if n > 0 and not seen[key] then
                parts[#parts + 1] = string.format("%d %s", n, MISS_TYPE_LABEL[key] or string.lower(key))
                typedTotal = typedTotal + n
                seen[key] = true
            end
        end
    end

    local untyped = misses - typedTotal
    if untyped > 0 then
        parts[#parts + 1] = string.format("%d miss", untyped)
    elseif misses <= 0 and typedTotal <= 0 then
        parts[#parts + 1] = "0 miss"
    end

    local avoid = math.max(misses, typedTotal)
    local attempts = hits + avoid
    if attempts > 0 and avoid > 0 then
        parts[#parts + 1] = string.format("(%.0f%% hit)", 100 * hits / attempts)
    end
    return table.concat(parts, " · ")
end

function MinionDps:FormatHitsMisses(hits, misses, missTypes)
    return FormatHitsMisses(hits, misses, missTypes)
end

function MinionDps:PrintMissDebug()
    self:Init()
    local function SumFightMisses(fight)
        local total = 0
        if not fight then
            return 0
        end
        for _, bucket in pairs(fight.minions or {}) do
            total = total + (bucket.misses or 0)
        end
        return total
    end
    local fight = self:GetCurrentFight()
    local db = EnsureDb()
    local lastSaved = db.fights and db.fights[#db.fights]
    Mancer.Print(string.format(
        "Miss debug: missEvents=%s combatMiss=%s zeroDmgMiss=%s unresolved=%s currentFightMisses=%s lastSavedMisses=%s pendingMisses=%s cleu=%s",
        tostring(self.debugMissEvents or 0),
        tostring(self.debugCombatMiss or 0),
        tostring(self.debugZeroDmgMiss or 0),
        tostring(self.debugMiss or 0),
        tostring(SumFightMisses(fight)),
        tostring(SumFightMisses(lastSaved)),
        tostring(SumFightMisses(self.pendingFight)),
        tostring(self.lastCleuToken or "?")
    ))
    if self.lastCombatMiss then
        local m = self.lastCombatMiss
        Mancer.Print(string.format(
            "  lastCombatMiss: %s type=%s name=%s spell=%s guid=%s",
            tostring(m.event),
            tostring(m.missType or "?"),
            tostring(m.name or "?"),
            tostring(m.spell or m.spellId or "?"),
            tostring(m.guid or "?")
        ))
    end
    if self.lastMiss then
        local m = self.lastMiss
        Mancer.Print(string.format(
            "  lastIgnored: %s reason=%s name=%s",
            tostring(m.event),
            tostring(m.reason or "?"),
            tostring(m.name or "?")
        ))
    end
end

local function ResolvePlayerTracked(spellId, spellName)
    spellId = tonumber(spellId)
    if spellId then
        for _, def in ipairs(PLAYER_TRACKED_SPELLS) do
            if def.spellIds and def.spellIds[spellId] then
                return def
            end
        end
    end
    if spellName and spellName ~= "" then
        local cleaned = tostring(spellName):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")
        for _, def in ipairs(PLAYER_TRACKED_SPELLS) do
            if def.names and (def.names[spellName] or def.names[cleaned]) then
                return def
            end
        end
        local lower = string.lower(cleaned)
        for _, def in ipairs(PLAYER_TRACKED_SPELLS) do
            if def.names then
                for name in pairs(def.names) do
                    if string.lower(name) == lower then
                        return def
                    end
                end
            end
        end
    end
    return nil
end

local function PlayerSpellKey(def)
    return "track:" .. tostring(def.id or def.label or "unknown")
end

local function NewPlayerSpellBucket(def)
    return {
        id = def.id,
        kind = def.kind or "dot",
        label = def.label,
        spellId = nil,
        damage = 0,
        hits = 0,
        procs = 0,
        casts = 0,
        activeSeconds = 0,
        peakTargets = 0,
        targets = {},
    }
end

local function GetPlayerSpellBucket(fight, def)
    fight.playerSpells = fight.playerSpells or {}
    local key = PlayerSpellKey(def)
    if not fight.playerSpells[key] then
        fight.playerSpells[key] = NewPlayerSpellBucket(def)
    end
    return fight.playerSpells[key], key
end

-- Details-style: any player-sourced CLEU damage, keyed by spell id/name (not allowlist).
local function GetPlayerDamageBucket(fight, spellId, spellName, eventType)
    fight.playerSpells = fight.playerSpells or {}
    local label, resolvedId = ResolveSpellLabel(eventType, spellId, spellName)
    local key = GetSpellKey(resolvedId or spellId, label)
    local bucket = fight.playerSpells[key]
    if not bucket then
        bucket = {
            id = key,
            kind = "damage",
            label = label or "Spell",
            spellId = resolvedId or spellId,
            damage = 0,
            hits = 0,
            procs = 0,
            casts = 0,
            activeSeconds = 0,
            peakTargets = 0,
            targets = {},
        }
        fight.playerSpells[key] = bucket
    else
        if (not bucket.spellId) and (resolvedId or spellId) then
            bucket.spellId = resolvedId or spellId
        end
        if label and label ~= "" and (not bucket.label or bucket.label == "" or bucket.label == "Spell") then
            bucket.label = label
        end
        -- Keep richer kinds (dot/spell/proc) if this key was already opened by tracked defs.
        if bucket.kind == nil then
            bucket.kind = "damage"
        end
    end
    return bucket, key
end

local function GetPlayerTargetBucket(spellBucket, destGuid, destName)
    spellBucket.targets = spellBucket.targets or {}
    if not destGuid then
        destGuid = "unknown"
    end
    local target = spellBucket.targets[destGuid]
    if not target then
        target = {
            guid = destGuid,
            name = destName,
            damage = 0,
            hits = 0,
            firstSeen = nil,
            lastSeen = nil,
            activeSeconds = 0,
            openStart = nil,
        }
        spellBucket.targets[destGuid] = target
    elseif destName and destName ~= "" then
        target.name = destName
    end
    return target
end

local function CountOpenPlayerTargets(spellBucket)
    local n = 0
    for _, target in pairs(spellBucket.targets or {}) do
        if target.openStart then
            n = n + 1
        end
    end
    return n
end

local function CopyPlayerSpellBuckets(source)
    local copy = {}
    for key, row in pairs(source or {}) do
        local targets = {}
        for guid, t in pairs(row.targets or {}) do
            targets[guid] = {
                guid = t.guid,
                name = t.name,
                damage = t.damage or 0,
                hits = t.hits or 0,
                firstSeen = t.firstSeen,
                lastSeen = t.lastSeen,
                activeSeconds = t.activeSeconds or 0,
                -- openStart intentionally dropped on save (flushed at combat end)
            }
        end
        copy[key] = {
            id = row.id,
            kind = row.kind,
            label = row.label,
            spellId = row.spellId,
            damage = row.damage or 0,
            hits = row.hits or 0,
            procs = row.procs or 0,
            casts = row.casts or 0,
            activeSeconds = row.activeSeconds or 0,
            peakTargets = row.peakTargets or 0,
            targets = targets,
        }
    end
    return copy
end

local function PlayerSpellsHaveData(fight)
    for _, row in pairs(fight and fight.playerSpells or {}) do
        if (row.damage or 0) > 0 or (row.hits or 0) > 0 or (row.procs or 0) > 0 then
            return true
        end
        if (row.activeSeconds or 0) > 0 then
            return true
        end
        for _, t in pairs(row.targets or {}) do
            if t.openStart or (t.activeSeconds or 0) > 0 or (t.damage or 0) > 0 then
                return true
            end
        end
    end
    return false
end

local function IsPlayerGuid(guid)
    if not guid then
        return false
    end
    local playerGuid = UnitGUID("player")
    if not playerGuid then
        return false
    end
    if guid == playerGuid then
        return true
    end
    local Advisor = GetAdvisor()
    if Advisor and Advisor.GuidsMatch then
        return Advisor:GuidsMatch(guid, playerGuid)
    end
    return false
end

local function CopyGuidSet(source)
    local copy = {}
    for guid in pairs(source or {}) do
        copy[guid] = true
    end
    return copy
end

local function CopySpellBuckets(sourceSpells)
    local copy = {}
    for key, row in pairs(sourceSpells or {}) do
        copy[key] = {
            label = row.label,
            spellId = row.spellId,
            damage = row.damage or 0,
            hits = row.hits or 0,
            misses = row.misses or 0,
            missTypes = CopyMissTypes(row.missTypes),
        }
    end
    return copy
end

local function CopyUnitBuckets(sourceUnits)
    local copy = {}
    for guid, row in pairs(sourceUnits or {}) do
        copy[guid] = {
            guid = guid,
            label = row.label,
            attackIndex = row.attackIndex,
            damage = row.damage or 0,
            hits = row.hits or 0,
            misses = row.misses or 0,
            missTypes = CopyMissTypes(row.missTypes),
            firstSeen = row.firstSeen,
            lastSeen = row.lastSeen,
            activeSeconds = row.activeSeconds or 0,
            spells = CopySpellBuckets(row.spells),
        }
    end
    return copy
end

local function IsValidPetGuid(guid)
    if guid == nil or guid == "" then
        return false
    end
    local s = tostring(guid)
    -- Standard CLEU form: Creature-0-4218-...
    if s:find("-", 1, true) then
        return true
    end
    -- Ascension client form from UnitGUID / some CLEU sources: 0xF130...
    if s:match("^0[xX]%x+$") then
        return true
    end
    return false
end

local function UsesUnitBreakdown(minionId)
    return UNIT_TRACKED_MINIONS[minionId] == true or IsOwnedNameBucket(minionId)
end

local function GetFightBucket(fight, minionId)
    fight.minions = fight.minions or {}
    if not fight.minions[minionId] then
        fight.minions[minionId] = NewMinionBucket()
    end
    return fight.minions[minionId]
end

local function GetUnitBucket(fight, minionId, sourceGuid, sourceName)
    local bucket = GetFightBucket(fight, minionId)
    bucket.units = bucket.units or {}
    if not bucket.units[sourceGuid] then
        fight.unitCounters = fight.unitCounters or {}
        fight.unitCounters[minionId] = (fight.unitCounters[minionId] or 0) + 1
        bucket.units[sourceGuid] = {
            guid = sourceGuid,
            label = (sourceName and sourceName ~= "") and sourceName or "Attack",
            attackIndex = fight.unitCounters[minionId],
            damage = 0,
            hits = 0,
            misses = 0,
            firstSeen = nil,
            lastSeen = nil,
            spells = {},
        }
    elseif sourceName and sourceName ~= "" and bucket.units[sourceGuid].label == "Attack" then
        bucket.units[sourceGuid].label = sourceName
    end
    return bucket.units[sourceGuid]
end

local function BuildSpellRows(spellMap, parentDamage, uptime, units)
    local spells = {}
    local denom = math.max(1, tonumber(parentDamage) or 0)
    local timeDenom = math.max(1, tonumber(uptime) or 1)
    local unitDenom = math.max(1, tonumber(units) or 1)
    for _, spellRow in pairs(spellMap or {}) do
        local dmg = spellRow.damage or 0
        local hits = spellRow.hits or 0
        local misses = spellRow.misses or 0
        local missTypes = CopyMissTypes(spellRow.missTypes)
        if dmg > 0 or hits > 0 or misses > 0 then
            table.insert(spells, {
                label = spellRow.label or "?",
                spellId = spellRow.spellId,
                damage = dmg,
                hits = hits,
                misses = misses,
                missTypes = missTypes,
                dps = dmg / timeDenom / unitDenom,
                share = dmg / denom,
            })
        end
    end
    table.sort(spells, function(a, b)
        if a.damage ~= b.damage then
            return a.damage > b.damage
        end
        return (a.hits + a.misses) > (b.hits + b.misses)
    end)
    return spells
end

local function IsPlayerOwnedPet(flags)
    if not flags then
        return false
    end

    if BitAnd(flags, AFFILIATION_MINE) == 0 then
        return false
    end

    if BitAnd(flags, OBJECT_TYPE_PET + OBJECT_TYPE_GUARDIAN) ~= 0 then
        return true
    end

    -- Ascension ghouls and other guardians often lack strict pet/guardian type bits.
    if BitAnd(flags, AFFILIATION_MINE + REACTION_FRIENDLY) == (AFFILIATION_MINE + REACTION_FRIENDLY) then
        return true
    end

    return BitAnd(flags, AFFILIATION_MINE + CONTROL_PLAYER) == (AFFILIATION_MINE + CONTROL_PLAYER)
end

-- True only for THIS player's pets/guardians (CLEU flags or GUIDs we already proved ours).
-- Never classify by creature name / signature spell alone — nearby necros share those.
local function IsOurMinionSource(self, sourceGuid, sourceFlags)
    if IsPlayerOwnedPet(sourceFlags) then
        return true
    end
    if not sourceGuid then
        return false
    end
    local fight = self.currentFight
    if fight then
        if fight.guidMap and fight.guidMap[sourceGuid] then
            return true
        end
        if fight.knownGhoulGuids and fight.knownGhoulGuids[sourceGuid] then
            return true
        end
        if fight.knownZombieGuids and fight.knownZombieGuids[sourceGuid] then
            return true
        end
        if fight.openSummons and fight.openSummons[sourceGuid] then
            return true
        end
    end
    local Advisor = GetAdvisor()
    if Advisor and Advisor.HasOwnedGuidProof and Advisor:HasOwnedGuidProof(sourceGuid) then
        return true
    end
    if Advisor and Advisor.activeSummons and Advisor.activeSummons[sourceGuid] then
        local info = Advisor.activeSummons[sourceGuid]
        if info and Advisor.IsTrustedSummonSource and Advisor:IsTrustedSummonSource(info.source) then
            return true
        end
    end
    return false
end

local function CollectGuidMapFromAdvisor()
    local guidMap = {}
    local advisor = GetAdvisor()
    if advisor and advisor.activeSummons then
        for guid, entry in pairs(advisor.activeSummons) do
            if entry and entry.minionId then
                -- DPS map: CLEU/cast summons only. Soft nameplate seeds can be other necros.
                local trusted = advisor.IsTrustedSummonSource and advisor:IsTrustedSummonSource(entry.source)
                local proven = advisor.HasOwnedGuidProof and advisor:HasOwnedGuidProof(guid)
                if trusted or proven then
                    guidMap[guid] = entry.minionId
                end
            end
        end
    end
    return guidMap
end

local function IsValidMinionType(Advisor, minionId)
    return Advisor and minionId and Advisor.MINION_TYPES and Advisor.MINION_TYPES[minionId] ~= nil
end

local function CanTrackMinionType(Advisor, minionId)
    if not IsValidMinionType(Advisor, minionId) then
        return false
    end
    if minionId == "lesser_zombie" then
        return Advisor.HasUnrelentingArmy and Advisor:HasUnrelentingArmy()
    end
    return true
end

function MinionDps:SyncGuidMapFromAdvisor()
    local fight = self:GetCurrentFight()
    fight.guidMap = fight.guidMap or {}
    for guid, minionId in pairs(CollectGuidMapFromAdvisor()) do
        fight.guidMap[guid] = minionId
        if CanTrackMinionType(GetAdvisor(), minionId) then
            self:TagGuidForMinion(guid, minionId)
        end
    end
end

local function AcceptMinionId(Advisor, minionId)
    if CanTrackMinionType(Advisor, minionId) then
        return minionId
    end
    return nil
end

local function CountActiveSummons(Advisor, minionId)
    local count = 0
    if not Advisor or not Advisor.activeSummons then
        return count
    end
    for _, entry in pairs(Advisor.activeSummons) do
        if entry.minionId == minionId then
            count = count + 1
        end
    end
    return count
end

local function IsMinionTypeActive(Advisor, minionId)
    if not Advisor or not minionId then
        return false
    end

    if Advisor.GetCachedAuraCounts then
        local counts = Advisor:GetCachedAuraCounts()
        if counts and (counts[minionId] or 0) > 0 then
            return true
        end
    end

    if Advisor.temporaryActive then
        local now = GetTime and GetTime() or 0
        if (Advisor.temporaryActive[minionId] or 0) > now then
            return true
        end
    end

    if Advisor.activeSummons then
        for _, entry in pairs(Advisor.activeSummons) do
            if entry.minionId == minionId then
                return true
            end
        end
    end

    return false
end

function MinionDps:ResetCurrentFight()
    self.currentFight = {
        startedAt = nil,
        endedAt = nil,
        minions = {},
        playerSpells = {},
        guidMap = {},
        peakCounts = {},
        knownGhoulGuids = {},
        knownZombieGuids = {},
        -- CLEU-registered zombie GUIDs this fight (survives death Unregister).
        seenZombieGuids = {},
        unitCounters = {},
        openSummons = {},
    }
    self.guidTypeCache = {}
end

function MinionDps:FightHasDamage(fight)
    if not fight then
        return false
    end
    for _, bucket in pairs(fight.minions or {}) do
        if bucket.damage and bucket.damage > 0 then
            return true
        end
    end
    return PlayerSpellsHaveData(fight)
end

function MinionDps:CopyFight(fight)
    if not fight then
        return nil
    end
    local copy = {
        startedAt = fight.startedAt,
        endedAt = fight.endedAt,
        minions = {},
        playerSpells = CopyPlayerSpellBuckets(fight.playerSpells),
        guidMap = {},
        peakCounts = {},
        knownGhoulGuids = CopyGuidSet(fight.knownGhoulGuids),
        knownZombieGuids = CopyGuidSet(fight.knownZombieGuids),
        seenZombieGuids = CopyGuidSet(fight.seenZombieGuids),
    }
    for minionId, bucket in pairs(fight.minions or {}) do
        copy.minions[minionId] = {
            damage = bucket.damage or 0,
            hits = bucket.hits or 0,
            misses = bucket.misses or 0,
            missTypes = CopyMissTypes(bucket.missTypes),
            firstSeen = bucket.firstSeen,
            lastSeen = bucket.lastSeen,
            activeSeconds = bucket.activeSeconds or 0,
            summonCount = bucket.summonCount or 0,
            displayLabel = bucket.displayLabel,
            spells = CopySpellBuckets(bucket.spells),
            units = CopyUnitBuckets(bucket.units),
        }
    end
    for guid, minionId in pairs(fight.guidMap or {}) do
        copy.guidMap[guid] = minionId
    end
    for minionId, amount in pairs(fight.peakCounts or {}) do
        copy.peakCounts[minionId] = amount
    end
    return copy
end

function MinionDps:Init()
    EnsureDb()
    if not self.currentFight then
        self:ResetCurrentFight()
    end
    self.inCombat = self.inCombat or false
    self.debugTotal = self.debugTotal or 0
    self.debugHit = self.debugHit or 0
    self.debugMiss = self.debugMiss or 0
    self.debugCleuRaw = self.debugCleuRaw or 0
    self:EnsureCombatLogListener()
end

local CLEU_HANDLER_VERSION = 9

function MinionDps:EnsureCombatLogListener()
    if self.cleuFrame and self.cleuHandlerVersion == CLEU_HANDLER_VERSION then
        return
    end

    if not self.cleuFrame then
        self.cleuFrame = CreateFrame("Frame")
        self.cleuFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end

    self.cleuHandlerVersion = CLEU_HANDLER_VERSION
    self.cleuFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            MinionDps:ProcessCleuEvent(...)
        end
    end)
end

function MinionDps:ProcessCleuEvent(...)
    self:Init()
    self.debugCleuRaw = (self.debugCleuRaw or 0) + 1
    self.lastCleuArgCount = select("#", ...)

    local parsed = Mancer.CombatLog and Mancer.CombatLog.Parse and Mancer.CombatLog.Parse(...)
    if parsed and parsed.eventType then
        self.lastCleuToken = parsed.eventType
        self.lastParseMode = parsed.parseMode
        self.debugParseOk = (self.debugParseOk or 0) + 1
    else
        self.debugParseFail = (self.debugParseFail or 0) + 1
        return
    end

    if not DAMAGE_EVENTS[parsed.eventType] and not MISS_EVENTS[parsed.eventType] then
        if AURA_EVENTS[parsed.eventType] or parsed.eventType == "SPELL_CAST_SUCCESS" then
            self:HandlePlayerTrackedEvent(parsed)
        end
        if parsed.eventType == "SPELL_SUMMON" and parsed.destGUID then
            local playerGuid = UnitGUID("player")
            local Advisor = GetAdvisor()
            local isMySummon = playerGuid and parsed.sourceGUID
                and Advisor and Advisor.GuidsMatch
                and Advisor:GuidsMatch(parsed.sourceGUID, playerGuid)
            if isMySummon and Advisor then
                local minionId = Advisor:ClassifyMinionName(parsed.destName)
                if Advisor.IsLesserZombieSummon
                    and Advisor:IsLesserZombieSummon(parsed.destName, parsed.spellId, parsed.spellName) then
                    minionId = "lesser_zombie"
                end
                if minionId and CanTrackMinionType(Advisor, minionId) then
                    self:RegisterSummonGuid(parsed.destGUID, minionId)
                end
            end
        elseif parsed.eventType == "UNIT_DIED" or parsed.eventType == "UNIT_DESTROYED" or parsed.eventType == "PARTY_KILL" then
            if parsed.destGUID then
                self:CloseSummonGuid(parsed.destGUID, "died")
            end
        end
        return
    end

    self.debugTotal = (self.debugTotal or 0) + 1
    self.lastParsedAmount = parsed.amount
    self.lastParsedSpell = parsed.spellName

    if not IsNecromancerPlayer() then
        return
    end

    self:SyncGuidMapFromAdvisor()

    local function ResolveOwnedMinionFromParsed(parsed)
        local minionId = self:ResolveMinionId(
            parsed.sourceGUID,
            parsed.sourceName,
            parsed.sourceFlags,
            parsed.spellId,
            parsed.spellName,
            parsed.eventType
        )
        if not minionId and IsOurMinionSource(self, parsed.sourceGUID, parsed.sourceFlags) then
            minionId = OwnedNameBucketId(parsed.sourceName)
        end
        -- Miss events sometimes omit useful flags/name — fall back to GUID map only.
        if not minionId and parsed.sourceGUID then
            local fight = self:GetCurrentFight()
            local mapped = fight and fight.guidMap and fight.guidMap[parsed.sourceGUID]
            if mapped then
                minionId = mapped
            elseif fight then
                local Advisor = GetAdvisor()
                if Advisor and Advisor.GuidsMatch then
                    for guid, mid in pairs(fight.guidMap or {}) do
                        if Advisor:GuidsMatch(guid, parsed.sourceGUID) then
                            minionId = mid
                            break
                        end
                    end
                    if not minionId then
                        for guid in pairs(fight.knownGhoulGuids or {}) do
                            if Advisor:GuidsMatch(guid, parsed.sourceGUID) then
                                minionId = "ghoul"
                                break
                            end
                        end
                    end
                    if not minionId then
                        for guid in pairs(fight.knownZombieGuids or {}) do
                            if Advisor:GuidsMatch(guid, parsed.sourceGUID) then
                                minionId = "lesser_zombie"
                                break
                            end
                        end
                    end
                end
            end
        end
        return minionId
    end

    -- Miss / avoid: count attempts with no damage (minions only).
    if MISS_EVENTS[parsed.eventType] then
        self.debugMissEvents = (self.debugMissEvents or 0) + 1
        local minionId = ResolveOwnedMinionFromParsed(parsed)
        if minionId then
            self.debugCombatMiss = (self.debugCombatMiss or 0) + 1
            self.lastCombatMiss = {
                event = parsed.eventType,
                missType = parsed.missType,
                name = parsed.sourceName,
                spell = parsed.spellName,
                spellId = parsed.spellId,
                guid = parsed.sourceGUID and tostring(parsed.sourceGUID) or nil,
            }
            self:RecordMiss(
                minionId,
                parsed.eventType,
                parsed.spellId,
                parsed.spellName,
                parsed.sourceGUID,
                parsed.sourceName,
                parsed.missType
            )
        else
            self.debugMiss = (self.debugMiss or 0) + 1
            self.lastMiss = {
                event = parsed.eventType,
                missType = parsed.missType,
                name = parsed.sourceName,
                flags = parsed.sourceFlags,
                spell = parsed.spellName,
                spellId = parsed.spellId,
                guid = parsed.sourceGUID and tostring(parsed.sourceGUID) or nil,
                reason = "unresolved miss",
            }
        end
        return
    end

    local amount = parsed.amount or 0
    if amount <= 0 then
        -- Some clients emit 0-damage swings instead of SWING_MISSED.
        if parsed.eventType == "SWING_DAMAGE"
            or parsed.eventType == "RANGE_DAMAGE"
            or parsed.eventType == "SPELL_DAMAGE" then
            local minionId = ResolveOwnedMinionFromParsed(parsed)
            if minionId then
                self.debugCombatMiss = (self.debugCombatMiss or 0) + 1
                self.debugZeroDmgMiss = (self.debugZeroDmgMiss or 0) + 1
                self:RecordMiss(
                    minionId,
                    parsed.eventType == "SWING_DAMAGE" and "SWING_MISSED" or parsed.eventType,
                    parsed.spellId,
                    parsed.spellName,
                    parsed.sourceGUID,
                    parsed.sourceName,
                    parsed.missType or "MISS"
                )
                return
            end
        end
        self.debugMiss = (self.debugMiss or 0) + 1
        self.lastMiss = {
            event = parsed.eventType,
            name = parsed.sourceName,
            flags = parsed.sourceFlags,
            spell = parsed.spellName,
            spellId = parsed.spellId,
            amount = amount,
            reason = "zero amount",
        }
        return
    end

    -- Tracked DoTs / Expunge / procs: allowlist still owns uptime + cast extras.
    if self:HandlePlayerTrackedEvent(parsed) then
        self.debugHit = (self.debugHit or 0) + 1
        return
    end

    -- Details-style: all damage from the player counts under Player (by spell).
    if parsed.sourceGUID and IsPlayerGuid(parsed.sourceGUID) then
        self.debugHit = (self.debugHit or 0) + 1
        self:RecordAnyPlayerDamage(
            amount,
            parsed.eventType,
            parsed.spellId,
            parsed.spellName,
            parsed.destGUID,
            parsed.destName
        )
        return
    end

    -- Known player abilities whose CLEU source is not the player GUID — still Player.
    local Advisor = GetAdvisor()
    if Advisor and Advisor.IsPlayerDamageSpell and Advisor:IsPlayerDamageSpell(parsed.spellName, parsed.spellId) then
        self.debugHit = (self.debugHit or 0) + 1
        self:RecordAnyPlayerDamage(
            amount,
            parsed.eventType,
            parsed.spellId,
            parsed.spellName,
            parsed.destGUID,
            parsed.destName
        )
        return
    end

    local minionId = self:ResolveMinionId(
        parsed.sourceGUID,
        parsed.sourceName,
        parsed.sourceFlags,
        parsed.spellId,
        parsed.spellName,
        parsed.eventType
    )
    -- Details-style: owned pets always count. Unknown type → group by CLEU name.
    if not minionId and IsOurMinionSource(self, parsed.sourceGUID, parsed.sourceFlags) then
        minionId = OwnedNameBucketId(parsed.sourceName)
    end
    if minionId then
        self.debugHit = (self.debugHit or 0) + 1
        self.lastParsedSourceGuid = parsed.sourceGUID and tostring(parsed.sourceGUID) or nil
        self:RecordDamage(minionId, amount, parsed.eventType, parsed.spellId, parsed.spellName, parsed.sourceGUID, parsed.sourceName)
    else
        self.debugMiss = (self.debugMiss or 0) + 1
        self.lastMiss = {
            event = parsed.eventType,
            name = parsed.sourceName,
            flags = parsed.sourceFlags,
            spell = parsed.spellName,
            spellId = parsed.spellId,
            amount = amount,
            reason = "unresolved",
        }
    end
end

function MinionDps:GetCurrentFight()
    self:Init()
    return self.currentFight
end

function MinionDps:FightFingerprint(fight)
    if not fight then
        return nil
    end
    local damage = 0
    for _, bucket in pairs(fight.minions or {}) do
        damage = damage + (bucket.damage or 0)
    end
    return string.format(
        "%.3f:%.3f:%.0f",
        tonumber(fight.startedAt) or 0,
        tonumber(fight.endedAt) or 0,
        damage
    )
end

-- Persist a finished pull into the session (Details-style). Dedupes identical commits.
function MinionDps:CommitFight(fight)
    if not fight or not self:FightHasDamage(fight) then
        return false
    end
    self:UpdatePeakCounts(fight)
    fight.endedAt = fight.endedAt or GetTimeNow()
    fight.startedAt = fight.startedAt or fight.endedAt

    local fp = self:FightFingerprint(fight)
    if fp and self.lastCommittedFp == fp then
        return "already_saved"
    end

    self:SaveFight(fight)
    self.lastCommittedFp = fp
    return true
end

function MinionDps:OnCombatStart()
    self:Init()
    self.inCombat = true

    -- New pull: commit any leftover pending segment, then start fresh (like Details).
    if self.pendingFight and self:FightHasDamage(self.pendingFight) then
        self:CommitFight(self.pendingFight)
        self.pendingFight = nil
    end

    local fight = self.currentFight
    local hasDamage = false
    for _, bucket in pairs(fight.minions or {}) do
        if bucket.damage and bucket.damage > 0 then
            hasDamage = true
            break
        end
    end

    local guidMap = CollectGuidMapFromAdvisor()
    if hasDamage and fight.startedAt then
        fight.guidMap = fight.guidMap or {}
        for guid, minionId in pairs(guidMap) do
            fight.guidMap[guid] = minionId
        end
        return
    end

    self:ResetCurrentFight()
    self.currentFight.guidMap = guidMap
    self.currentFight.startedAt = GetTimeNow()
end

function MinionDps:OnCombatEnd()
    self:Init()
    if not self.inCombat and not self.currentFight.startedAt then
        return
    end

    self.inCombat = false
    local fight = self.currentFight
    self:FlushAllOpenSummons(fight)
    fight.endedAt = GetTimeNow()
    if not fight.startedAt then
        fight.startedAt = fight.endedAt
    end

    if self:FightHasDamage(fight) then
        self:UpdatePeakCounts(fight)
        local copy = self:CopyFight(fight)
        self.pendingFight = copy
        -- Auto-save into session — no manual Save Fight needed for normal combat.
        self:CommitFight(copy)
    end

    self:ResetCurrentFight()
end

function MinionDps:SaveCurrentFight()
    self:Init()
    self:SyncGuidMapFromAdvisor()

    local fight = self.currentFight
    if self:FightHasDamage(fight) then
        self:FlushAllOpenSummons(fight)
        fight.startedAt = fight.startedAt or GetTimeNow()
        fight.endedAt = GetTimeNow()
        local result = self:CommitFight(fight)
        self:ResetCurrentFight()
        self.inCombat = false
        self.pendingFight = nil
        return result
    end

    if self.pendingFight and self:FightHasDamage(self.pendingFight) then
        local pending = self.pendingFight
        pending.endedAt = pending.endedAt or GetTimeNow()
        local result = self:CommitFight(pending)
        self.pendingFight = nil
        self:ResetCurrentFight()
        self.inCombat = false
        return result
    end

    local db = EnsureDb()
    local last = db.fights[1]
    if last and self:FightHasDamage(last) then
        local now = GetTimeNow()
        local endedAt = last.endedAt or last.startedAt or 0
        if endedAt > 0 and (now - endedAt) < 120 then
            return "already_saved"
        end
    end

    return false
end

function MinionDps:SaveFight(fight)
    local db = EnsureDb()
    table.insert(db.fights, 1, self:CopyFight(fight))
    while #db.fights > MAX_SAVED_FIGHTS do
        table.remove(db.fights)
    end
end

function MinionDps:ResetSession()
    local db = EnsureDb()
    db.fights = {}
    self:ResetCurrentFight()
    self.pendingFight = nil
    self.lastCommittedFp = nil
    self.inCombat = false
    self.debugTotal = 0
    self.debugHit = 0
    self.debugMiss = 0
    self.debugCombatMiss = 0
    self.debugMissEvents = 0
    self.debugZeroDmgMiss = 0
    self.debugCleuRaw = 0
    self.debugParseOk = 0
    self.debugParseFail = 0
    self.lastMiss = nil
    self.lastCombatMiss = nil
    self.lastCleuToken = nil
    self.lastCleuArgCount = nil
    self.lastParseMode = nil
    self.lastParsedAmount = nil
    self.lastParsedSpell = nil
end

local function EnsureFightGuidSets(fight)
    fight.knownGhoulGuids = fight.knownGhoulGuids or {}
    fight.knownZombieGuids = fight.knownZombieGuids or {}
    fight.seenZombieGuids = fight.seenZombieGuids or {}
end

function MinionDps:TagGuidForMinion(sourceGuid, minionId)
    if not sourceGuid or not minionId then
        return
    end

    local fight = self:GetCurrentFight()
    EnsureFightGuidSets(fight)
    fight.guidMap = fight.guidMap or {}
    fight.guidMap[sourceGuid] = minionId

    if minionId == "lesser_zombie" then
        fight.knownZombieGuids[sourceGuid] = true
        fight.knownGhoulGuids[sourceGuid] = nil
    elseif minionId == "ghoul" then
        fight.knownGhoulGuids[sourceGuid] = true
        -- Re-tagging away from zombie (GUID reuse / wrong first hit).
        fight.knownZombieGuids[sourceGuid] = nil
    else
        -- Bone Wraith / Frost Wyrm / etc. must never stay stuck as zombie.
        fight.knownZombieGuids[sourceGuid] = nil
        fight.knownGhoulGuids[sourceGuid] = nil
    end

    self.guidTypeCache = self.guidTypeCache or {}
    self.guidTypeCache[sourceGuid] = minionId
end

function MinionDps:RegisterSummonGuid(guid, minionId)
    if not guid or not minionId then
        return
    end
    local fight = self:GetCurrentFight()
    self:TagGuidForMinion(guid, minionId)
    if minionId == "lesser_zombie" then
        EnsureFightGuidSets(fight)
        fight.seenZombieGuids[guid] = true
    end
    if not fight.startedAt then
        fight.startedAt = GetTimeNow()
    end

    fight.openSummons = fight.openSummons or {}
    if fight.openSummons[guid] then
        return
    end

    local now = GetTimeNow()
    local duration = GetTempDuration(minionId)
    fight.openSummons[guid] = {
        minionId = minionId,
        start = now,
        expiresAt = duration and (now + duration) or nil,
    }

    local bucket = GetFightBucket(fight, minionId)
    bucket.summonCount = (bucket.summonCount or 0) + 1
end

function MinionDps:CloseSummonGuid(guid, reason)
    if not guid then
        return
    end
    local fight = self:GetCurrentFight()
    if not fight or not fight.openSummons or not fight.openSummons[guid] then
        -- Still clear maps when Advisor reports death.
        self:UnregisterSummonGuid(guid)
        return
    end

    local info = fight.openSummons[guid]
    local now = GetTimeNow()
    local endAt = now
    if info.expiresAt and info.expiresAt < endAt then
        endAt = info.expiresAt
    end
    local lived = math.max(0, endAt - (info.start or now))
    local bucket = GetFightBucket(fight, info.minionId)
    bucket.activeSeconds = (bucket.activeSeconds or 0) + lived
    fight.openSummons[guid] = nil

    self:UnregisterSummonGuid(guid)
end

function MinionDps:FlushExpiredOpenSummons(fight, now)
    fight = fight or self:GetCurrentFight()
    if not fight or not fight.openSummons then
        return
    end
    now = now or GetTimeNow()
    local toClose = {}
    for guid, info in pairs(fight.openSummons) do
        if info.expiresAt and info.expiresAt <= now then
            table.insert(toClose, guid)
        end
    end
    for _, guid in ipairs(toClose) do
        self:CloseSummonGuid(guid, "expired")
    end
end

function MinionDps:FlushAllOpenSummons(fight)
    fight = fight or self:GetCurrentFight()
    if not fight or not fight.openSummons then
        self:FlushAllOpenPlayerAuras(fight)
        return
    end
    self:FlushExpiredOpenSummons(fight)
    local remaining = {}
    for guid in pairs(fight.openSummons) do
        table.insert(remaining, guid)
    end
    for _, guid in ipairs(remaining) do
        self:CloseSummonGuid(guid, "combat_end")
    end
    self:FlushAllOpenPlayerAuras(fight)
end

function MinionDps:OpenPlayerDotAura(def, destGuid, destName, spellId)
    if not def or (def.kind ~= "dot" and def.kind ~= "spell") or not destGuid then
        return
    end
    local fight = self:GetCurrentFight()
    if not fight.startedAt then
        fight.startedAt = GetTimeNow()
    end
    local spellBucket = GetPlayerSpellBucket(fight, def)
    if spellId then
        spellBucket.spellId = spellId
    end
    local target = GetPlayerTargetBucket(spellBucket, destGuid, destName)
    local now = GetTimeNow()
    target.firstSeen = target.firstSeen or now
    target.lastSeen = now
    if not target.openStart then
        target.openStart = now
        local open = CountOpenPlayerTargets(spellBucket)
        if open > (spellBucket.peakTargets or 0) then
            spellBucket.peakTargets = open
        end
    end
end

function MinionDps:ClosePlayerDotAura(def, destGuid, destName)
    if not def or (def.kind ~= "dot" and def.kind ~= "spell") or not destGuid then
        return
    end
    local fight = self:GetCurrentFight()
    local spellBucket = GetPlayerSpellBucket(fight, def)
    local target = spellBucket.targets and spellBucket.targets[destGuid]
    if not target or not target.openStart then
        return
    end
    local now = GetTimeNow()
    local lived = math.max(0, now - target.openStart)
    target.activeSeconds = (target.activeSeconds or 0) + lived
    spellBucket.activeSeconds = (spellBucket.activeSeconds or 0) + lived
    target.openStart = nil
    target.lastSeen = now
    if destName and destName ~= "" then
        target.name = destName
    end
end

function MinionDps:RecordPlayerProc(def, spellId)
    if not def or def.kind ~= "proc" then
        return
    end
    local fight = self:GetCurrentFight()
    if not fight.startedAt then
        fight.startedAt = GetTimeNow()
    end
    local spellBucket = GetPlayerSpellBucket(fight, def)
    if spellId then
        spellBucket.spellId = spellId
    end
    spellBucket.procs = (spellBucket.procs or 0) + 1
end

function MinionDps:RecordPlayerCast(def, spellId)
    if not def or def.kind == "proc" then
        return
    end
    local fight = self:GetCurrentFight()
    if not fight.startedAt then
        fight.startedAt = GetTimeNow()
    end
    local spellBucket = GetPlayerSpellBucket(fight, def)
    if spellId then
        spellBucket.spellId = spellId
    end
    spellBucket.casts = (spellBucket.casts or 0) + 1
end

function MinionDps:RecordPlayerSpellDamage(def, amount, destGuid, destName, spellId)
    if not def or not amount or amount <= 0 then
        return
    end
    local fight = self:GetCurrentFight()
    if not fight.startedAt then
        fight.startedAt = GetTimeNow()
    end
    local spellBucket = GetPlayerSpellBucket(fight, def)
    if spellId then
        spellBucket.spellId = spellId
    end
    spellBucket.damage = (spellBucket.damage or 0) + amount
    spellBucket.hits = (spellBucket.hits or 0) + 1

    if def.kind == "dot" or def.kind == "spell" then
        -- Damage ticks also open the window if CLEU missed APPLIED.
        self:OpenPlayerDotAura(def, destGuid or "unknown", destName, spellId)
        local target = GetPlayerTargetBucket(spellBucket, destGuid or "unknown", destName)
        local now = GetTimeNow()
        target.firstSeen = target.firstSeen or now
        target.lastSeen = now
        target.damage = (target.damage or 0) + amount
        target.hits = (target.hits or 0) + 1
    end
end

-- Capture any player-dealt damage (Details-style). Used when spell is not on the
-- tracked DoT/proc allowlist. Still attributes per-target for accordion expand.
function MinionDps:RecordAnyPlayerDamage(amount, eventType, spellId, spellName, destGuid, destName)
    amount = tonumber(amount) or 0
    if amount <= 0 then
        return
    end
    local fight = self:GetCurrentFight()
    if not fight.startedAt then
        fight.startedAt = GetTimeNow()
    end
    local spellBucket = GetPlayerDamageBucket(fight, spellId, spellName, eventType)
    spellBucket.damage = (spellBucket.damage or 0) + amount
    spellBucket.hits = (spellBucket.hits or 0) + 1

    local target = GetPlayerTargetBucket(spellBucket, destGuid or "unknown", destName)
    local now = GetTimeNow()
    target.firstSeen = target.firstSeen or now
    target.lastSeen = now
    target.damage = (target.damage or 0) + amount
    target.hits = (target.hits or 0) + 1
end

function MinionDps:FlushAllOpenPlayerAuras(fight)
    fight = fight or self:GetCurrentFight()
    if not fight or not fight.playerSpells then
        return
    end
    local now = fight.endedAt or GetTimeNow()
    for _, spellBucket in pairs(fight.playerSpells) do
        for _, target in pairs(spellBucket.targets or {}) do
            if target.openStart then
                local lived = math.max(0, now - target.openStart)
                target.activeSeconds = (target.activeSeconds or 0) + lived
                spellBucket.activeSeconds = (spellBucket.activeSeconds or 0) + lived
                target.openStart = nil
                target.lastSeen = now
            end
        end
    end
end

function MinionDps:HandlePlayerTrackedEvent(parsed)
    if not parsed or not IsNecromancerPlayer() then
        return false
    end

    local def = ResolvePlayerTracked(parsed.spellId, parsed.spellName)
    if not def then
        return false
    end

    local eventType = parsed.eventType
    local fromPlayer = IsPlayerGuid(parsed.sourceGUID)
    local onPlayer = IsPlayerGuid(parsed.destGUID)

    if def.kind == "proc" then
        -- Bone King / Diabolical: count applies (and refreshes) on the player.
        if onPlayer and (eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH") then
            self:RecordPlayerProc(def, parsed.spellId)
            return true
        end
        return false
    end

    -- DoTs / player spells must come from the player onto enemies.
    if not fromPlayer then
        return false
    end

    if eventType == "SPELL_CAST_SUCCESS" then
        self:RecordPlayerCast(def, parsed.spellId)
        -- Cast success often has no dest; open on current target so uptime still counts.
        local destGuid = parsed.destGUID
        local destName = parsed.destName
        if (not destGuid or onPlayer) and UnitExists and UnitExists("target") and UnitCanAttack and UnitCanAttack("player", "target") then
            destGuid = UnitGUID and UnitGUID("target")
            destName = UnitName and UnitName("target")
        end
        if destGuid and not IsPlayerGuid(destGuid) then
            self:OpenPlayerDotAura(def, destGuid, destName, parsed.spellId)
        end
        return true
    end

    if eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH" or eventType == "SPELL_AURA_APPLIED_DOSE" then
        if parsed.destGUID and not onPlayer then
            self:OpenPlayerDotAura(def, parsed.destGUID, parsed.destName, parsed.spellId)
            return true
        end
    elseif eventType == "SPELL_AURA_REMOVED" or eventType == "SPELL_AURA_REMOVED_DOSE" then
        -- Only full REMOVED closes; REMOVED_DOSE still has the aura.
        if eventType == "SPELL_AURA_REMOVED" and parsed.destGUID and not onPlayer then
            self:ClosePlayerDotAura(def, parsed.destGUID, parsed.destName)
            return true
        end
    elseif DAMAGE_EVENTS[eventType] then
        local amount = parsed.amount or 0
        if amount > 0 then
            self:RecordPlayerSpellDamage(def, amount, parsed.destGUID, parsed.destName, parsed.spellId)
            return true
        end
    end

    return false
end

function MinionDps:UnregisterSummonGuid(guid)
    if not guid then
        return
    end
    local fight = self:GetCurrentFight()
    if fight.guidMap then
        fight.guidMap[guid] = nil
    end
    if fight.knownGhoulGuids then
        fight.knownGhoulGuids[guid] = nil
    end
    if fight.knownZombieGuids then
        fight.knownZombieGuids[guid] = nil
    end
end

-- Open a synthetic lifetime when we first see damage from a CD Animate GUID
-- (SPELL_SUMMON can be missing on some Ascension client paths).
-- Lesser Zombies are excluded — summon count comes only from CLEU SPELL_SUMMON.
function MinionDps:EnsureOpenSummonFromDamage(guid, minionId)
    if not guid or not minionId or not IsTemporaryMinion(minionId) then
        return
    end
    if minionId == "lesser_zombie" then
        return
    end
    local fight = self:GetCurrentFight()
    fight.openSummons = fight.openSummons or {}
    if fight.openSummons[guid] then
        return
    end
    local now = GetTimeNow()
    local duration = GetTempDuration(minionId)
    fight.openSummons[guid] = {
        minionId = minionId,
        start = now,
        expiresAt = duration and (now + duration) or nil,
        synthetic = true,
    }
    local bucket = GetFightBucket(fight, minionId)
    bucket.summonCount = (bucket.summonCount or 0) + 1
end

-- Attribute minion damage from CLEU identity only (source name / GUID / summon map).
-- Never force a spell name into a bucket (Zombie Plague, Chomp, Command, etc.).
function MinionDps:ResolveMinionId(sourceGuid, sourceName, sourceFlags, spellId, spellName, eventType)
    local Advisor = GetAdvisor()
    if not Advisor then
        return nil
    end

    local playerGuid = UnitGUID("player")

    if sourceGuid and playerGuid and sourceGuid == playerGuid then
        return nil
    end
    if IsPlayerGuid(sourceGuid) then
        return nil
    end

    -- Hard gate: only THIS player's pets/guardians (flags or GUIDs we already proved).
    if not IsOurMinionSource(self, sourceGuid, sourceFlags) then
        return nil
    end

    self:SyncGuidMapFromAdvisor()

    local fight = self:GetCurrentFight()
    EnsureFightGuidSets(fight)

    -- 1) CLEU source name — combat log truth for this event.
    if sourceName then
        local fromName = Advisor:ClassifyMinionName(sourceName)
        local accepted = fromName and AcceptMinionId(Advisor, fromName)
        if accepted then
            if sourceGuid then
                self:TagGuidForMinion(sourceGuid, accepted)
            end
            return accepted
        end
    end

    -- 2) GUID already bound this fight from a prior CLEU name or SPELL_SUMMON.
    if sourceGuid and fight.guidMap and fight.guidMap[sourceGuid] then
        local mapped = AcceptMinionId(Advisor, fight.guidMap[sourceGuid])
        if mapped then
            return mapped
        end
    end

    -- 3) Advisor summon table (filled from SPELL_SUMMON / trusted CLEU).
    if Advisor.activeSummons and sourceGuid and Advisor.activeSummons[sourceGuid] then
        local minionId = AcceptMinionId(Advisor, Advisor.activeSummons[sourceGuid].minionId)
        if minionId then
            self:TagGuidForMinion(sourceGuid, minionId)
            return minionId
        end
    end

    -- 4) Creature type bits inside the GUID (observational — not spell forcing).
    if sourceGuid then
        local sig = GuidCreatureSig(sourceGuid)
        local fromSig = sig and GUID_CREATURE_SIGS[sig]
        if fromSig then
            local accepted = AcceptMinionId(Advisor, fromSig)
            if accepted then
                self:TagGuidForMinion(sourceGuid, accepted)
                return accepted
            end
        end
    end

    -- 5) Sticky GUID sets only if we tagged them earlier via (1)–(4) this fight.
    if sourceGuid and fight.knownGhoulGuids[sourceGuid] then
        return AcceptMinionId(Advisor, "ghoul")
    end
    if sourceGuid and fight.knownZombieGuids[sourceGuid] then
        return AcceptMinionId(Advisor, "lesser_zombie")
    end

    return nil
end

function MinionDps:UpdatePeakCounts(fight)
    local Advisor = GetAdvisor()
    if not Advisor or not Advisor.GetCachedAuraCounts then
        return
    end

    fight.peakCounts = fight.peakCounts or {}
    local counts = Advisor:GetCachedAuraCounts()
    for minionId, amount in pairs(counts) do
        if amount > (fight.peakCounts[minionId] or 0) then
            fight.peakCounts[minionId] = amount
        end
    end

    local summonPeaks = {}
    for _, entry in pairs(Advisor.activeSummons or {}) do
        if entry.minionId then
            summonPeaks[entry.minionId] = (summonPeaks[entry.minionId] or 0) + 1
        end
    end
    for minionId, amount in pairs(summonPeaks) do
        if amount > (fight.peakCounts[minionId] or 0) then
            fight.peakCounts[minionId] = amount
        end
    end
end

function MinionDps:RecordDamage(minionId, amount, eventType, spellId, spellName, sourceGuid, sourceName)
    if not minionId or not amount or amount <= 0 then
        return
    end

    local fight = self:GetCurrentFight()
    -- Do not open a fight from CLEU while the player is out of combat (nearby noise).
    if not fight.startedAt then
        if not self.inCombat and not (UnitAffectingCombat and UnitAffectingCombat("player")) then
            return
        end
        fight.startedAt = GetTimeNow()
    end

    local now = GetTimeNow()
    self:FlushExpiredOpenSummons(fight, now)
    if sourceGuid then
        self:EnsureOpenSummonFromDamage(sourceGuid, minionId)
    end

    local bucket = GetFightBucket(fight, minionId)
    if bucket.misses == nil then
        bucket.misses = 0
    end
    if (IsOwnedNameBucket(minionId) or minionId == OTHER_OWNED_ID) then
        local cleaned = CleanMinionSourceName(sourceName)
        if cleaned and (not bucket.displayLabel or bucket.displayLabel == "") then
            bucket.displayLabel = cleaned
        end
    end
    bucket.damage = bucket.damage + amount
    bucket.hits = bucket.hits + 1
    bucket.firstSeen = bucket.firstSeen or now
    bucket.lastSeen = now

    local label, resolvedSpellId = ResolveSpellLabel(eventType, spellId, spellName)
    local spellKey = GetSpellKey(resolvedSpellId, label)
    local spellBucket = GetSpellBucket(bucket, spellKey, label, resolvedSpellId)
    spellBucket.damage = spellBucket.damage + amount
    spellBucket.hits = spellBucket.hits + 1

    if UsesUnitBreakdown(minionId) and IsValidPetGuid(sourceGuid) then
        self.debugUnitHits = (self.debugUnitHits or 0) + 1
        self.lastRecordGuid = tostring(sourceGuid)
        local unitBucket = GetUnitBucket(fight, minionId, sourceGuid, sourceName)
        if unitBucket.misses == nil then
            unitBucket.misses = 0
        end
        unitBucket.damage = unitBucket.damage + amount
        unitBucket.hits = unitBucket.hits + 1
        unitBucket.firstSeen = unitBucket.firstSeen or now
        unitBucket.lastSeen = now
        local unitSpellBucket = GetSpellBucket(unitBucket, spellKey, label, resolvedSpellId)
        unitSpellBucket.damage = unitSpellBucket.damage + amount
        unitSpellBucket.hits = unitSpellBucket.hits + 1

        local unitCount = 0
        for _ in pairs(bucket.units or {}) do
            unitCount = unitCount + 1
        end
        fight.peakCounts[minionId] = math.max(fight.peakCounts[minionId] or 0, unitCount)
    elseif UsesUnitBreakdown(minionId) then
        self.debugNoGuidHits = (self.debugNoGuidHits or 0) + 1
    end

    fight.peakCounts = fight.peakCounts or {}
    fight.peakCounts[minionId] = math.max(fight.peakCounts[minionId] or 0, 1)
end

-- Count miss / dodge / parry / resist / immune / etc. (no damage).
function MinionDps:RecordMiss(minionId, eventType, spellId, spellName, sourceGuid, sourceName, missType)
    if not minionId then
        return
    end

    local fight = self:GetCurrentFight()
    if not fight.startedAt then
        if not self.inCombat and not (UnitAffectingCombat and UnitAffectingCombat("player")) then
            return
        end
        fight.startedAt = GetTimeNow()
    end

    local now = GetTimeNow()
    self:FlushExpiredOpenSummons(fight, now)
    if sourceGuid then
        self:EnsureOpenSummonFromDamage(sourceGuid, minionId)
    end

    local bucket = GetFightBucket(fight, minionId)
    bucket.misses = (bucket.misses or 0) + 1
    bucket.firstSeen = bucket.firstSeen or now
    bucket.lastSeen = now
    if (IsOwnedNameBucket(minionId) or minionId == OTHER_OWNED_ID) then
        local cleaned = CleanMinionSourceName(sourceName)
        if cleaned and (not bucket.displayLabel or bucket.displayLabel == "") then
            bucket.displayLabel = cleaned
        end
    end

    local label, resolvedSpellId = ResolveSpellLabel(eventType, spellId, spellName)
    local spellKey = GetSpellKey(resolvedSpellId, label)
    local spellBucket = GetSpellBucket(bucket, spellKey, label, resolvedSpellId)
    spellBucket.misses = (spellBucket.misses or 0) + 1
    local mt = NormalizeMissType(missType)
    spellBucket.missTypes = spellBucket.missTypes or {}
    spellBucket.missTypes[mt] = (spellBucket.missTypes[mt] or 0) + 1
    bucket.missTypes = bucket.missTypes or {}
    bucket.missTypes[mt] = (bucket.missTypes[mt] or 0) + 1

    if UsesUnitBreakdown(minionId) and IsValidPetGuid(sourceGuid) then
        local unitBucket = GetUnitBucket(fight, minionId, sourceGuid, sourceName)
        unitBucket.misses = (unitBucket.misses or 0) + 1
        unitBucket.missTypes = unitBucket.missTypes or {}
        unitBucket.missTypes[mt] = (unitBucket.missTypes[mt] or 0) + 1
        unitBucket.firstSeen = unitBucket.firstSeen or now
        unitBucket.lastSeen = now
        local unitSpellBucket = GetSpellBucket(unitBucket, spellKey, label, resolvedSpellId)
        unitSpellBucket.misses = (unitSpellBucket.misses or 0) + 1
        unitSpellBucket.missTypes = unitSpellBucket.missTypes or {}
        unitSpellBucket.missTypes[mt] = (unitSpellBucket.missTypes[mt] or 0) + 1

        local unitCount = 0
        for _ in pairs(bucket.units or {}) do
            unitCount = unitCount + 1
        end
        fight.peakCounts = fight.peakCounts or {}
        fight.peakCounts[minionId] = math.max(fight.peakCounts[minionId] or 0, unitCount)
    end

    fight.peakCounts = fight.peakCounts or {}
    fight.peakCounts[minionId] = math.max(fight.peakCounts[minionId] or 0, 1)
end

function MinionDps:GetFightDuration(fight)
    if not fight then
        return 0
    end
    local startAt = fight.startedAt or 0
    local endAt = fight.endedAt or GetTimeNow()
    return math.max(1, endAt - startAt)
end

function MinionDps:GetMinionUptime(bucket, fightDuration)
    if not bucket then
        return fightDuration
    end
    -- Prefer accumulated summon lifetimes (unit-seconds) for Animate CD pets.
    if bucket.activeSeconds and bucket.activeSeconds > 0 then
        return math.max(1, bucket.activeSeconds)
    end
    if bucket.firstSeen and bucket.lastSeen then
        return math.max(1, bucket.lastSeen - bucket.firstSeen)
    end
    return fightDuration
end

function MinionDps:AggregateFightStats(fight)
    local stats = {}
    if fight then
        self:FlushExpiredOpenSummons(fight, fight.endedAt or GetTimeNow())
        -- Credit still-open summons against fight end without mutating mid-combat state
        -- only when fight has ended (endedAt set).
        if fight.endedAt and fight.openSummons then
            for guid, info in pairs(fight.openSummons) do
                local endAt = fight.endedAt
                if info.expiresAt and info.expiresAt < endAt then
                    endAt = info.expiresAt
                end
                local lived = math.max(0, endAt - (info.start or fight.endedAt))
                local bucket = GetFightBucket(fight, info.minionId)
                bucket.activeSeconds = (bucket.activeSeconds or 0) + lived
            end
            fight.openSummons = {}
        end
        if fight.endedAt then
            self:FlushAllOpenPlayerAuras(fight)
        end
    end
    local duration = self:GetFightDuration(fight)

    for minionId, bucket in pairs(fight.minions or {}) do
        local hasDamage = bucket.damage and bucket.damage > 0
        local hasMisses = (bucket.misses or 0) > 0
        if hasDamage or hasMisses then
            local activeSeconds = bucket.activeSeconds or 0
            local uptime = self:GetMinionUptime(bucket, duration)
            local units = 1
            if fight.peakCounts and fight.peakCounts[minionId] and fight.peakCounts[minionId] > 0 then
                units = fight.peakCounts[minionId]
            end
            -- Temporary (zombies / Animates): damage / unit-seconds.
            -- Permanent Raises: damage / fightDuration / peakCount.
            -- Tiny leftover activeSeconds on permanents caused 87k DPS/unit.
            local temporary = IsTemporaryMinion(minionId)
            local useActiveSeconds = temporary and activeSeconds > 0
            local dmg = bucket.damage or 0
            local dpsPerUnit
            local spellDenomTime
            local spellDenomUnits
            if dmg <= 0 then
                dpsPerUnit = 0
                spellDenomTime = useActiveSeconds and activeSeconds or duration
                spellDenomUnits = useActiveSeconds and 1 or units
            elseif useActiveSeconds then
                dpsPerUnit = dmg / activeSeconds
                spellDenomTime = activeSeconds
                spellDenomUnits = 1
            else
                dpsPerUnit = dmg / duration / units
                spellDenomTime = duration
                spellDenomUnits = units
            end
            local spells = BuildSpellRows(bucket.spells, dmg, spellDenomTime, spellDenomUnits)
            local attacks = nil
            if UsesUnitBreakdown(minionId) and bucket.units then
                attacks = {}
                for _, unitBucket in pairs(bucket.units) do
                    local unitDmg = unitBucket.damage or 0
                    local unitMisses = unitBucket.misses or 0
                    if unitDmg > 0 or unitMisses > 0 then
                        local unitUptime = self:GetMinionUptime(unitBucket, duration)
                        if not temporary then
                            unitUptime = duration
                        elseif (unitBucket.activeSeconds or 0) > 0 then
                            unitUptime = unitBucket.activeSeconds
                        end
                        table.insert(attacks, {
                            guid = unitBucket.guid,
                            label = unitBucket.label,
                            attackIndex = unitBucket.attackIndex or 0,
                            damage = unitDmg,
                            hits = unitBucket.hits or 0,
                            misses = unitMisses,
                            missTypes = CopyMissTypes(unitBucket.missTypes),
                            dps = unitDmg / math.max(1, unitUptime),
                            spells = BuildSpellRows(unitBucket.spells, unitDmg, math.max(1, unitUptime), 1),
                        })
                    end
                end
                table.sort(attacks, function(a, b)
                    if a.attackIndex ~= b.attackIndex then
                        return a.attackIndex < b.attackIndex
                    end
                    return a.damage > b.damage
                end)
                if #attacks == 0 then
                    attacks = nil
                end
            end
            stats[minionId] = {
                damage = dmg,
                hits = bucket.hits or 0,
                misses = bucket.misses or 0,
                missTypes = CopyMissTypes(bucket.missTypes),
                uptime = uptime,
                activeSeconds = activeSeconds,
                summonCount = bucket.summonCount or 0,
                displayLabel = bucket.displayLabel,
                units = units,
                dps = dpsPerUnit,
                spells = spells,
                attacks = attacks,
                temporary = temporary,
            }
        end
    end

    return stats, duration
end

function MinionDps:AggregateSessionStats()
    local db = EnsureDb()
    local totals = {}
    local fightCount = 0

    for _, fight in ipairs(db.fights) do
        local fightStats = self:AggregateFightStats(fight)
        local hasData = false
        for minionId, row in pairs(fightStats) do
            hasData = true
            totals[minionId] = totals[minionId] or {
                dpsTotal = 0,
                damage = 0,
                hits = 0,
                misses = 0,
                missTypes = {},
                samples = 0,
                spells = {},
                displayLabel = nil,
            }
            totals[minionId].dpsTotal = totals[minionId].dpsTotal + row.dps
            totals[minionId].damage = totals[minionId].damage + row.damage
            totals[minionId].hits = totals[minionId].hits + row.hits
            totals[minionId].misses = (totals[minionId].misses or 0) + (row.misses or 0)
            totals[minionId].missTypes = MergeMissTypes(totals[minionId].missTypes, row.missTypes)
            totals[minionId].samples = totals[minionId].samples + 1
            if row.displayLabel and not totals[minionId].displayLabel then
                totals[minionId].displayLabel = row.displayLabel
            end
            for _, spellRow in ipairs(row.spells or {}) do
                local spellKey = GetSpellKey(spellRow.spellId, spellRow.label)
                local bucket = totals[minionId].spells[spellKey]
                if not bucket then
                    bucket = {
                        label = spellRow.label,
                        spellId = spellRow.spellId,
                        damage = 0,
                        hits = 0,
                        misses = 0,
                        missTypes = {},
                    }
                    totals[minionId].spells[spellKey] = bucket
                end
                bucket.damage = bucket.damage + spellRow.damage
                bucket.hits = bucket.hits + spellRow.hits
                bucket.misses = (bucket.misses or 0) + (spellRow.misses or 0)
                bucket.missTypes = MergeMissTypes(bucket.missTypes, spellRow.missTypes)
            end
        end
        if hasData then
            fightCount = fightCount + 1
        end
    end

    local averages = {}
    for minionId, row in pairs(totals) do
        local spells = {}
        for _, spellRow in pairs(row.spells or {}) do
            local dmg = spellRow.damage or 0
            local hits = spellRow.hits or 0
            local misses = spellRow.misses or 0
            if dmg > 0 or hits > 0 or misses > 0 then
                table.insert(spells, {
                    label = spellRow.label,
                    spellId = spellRow.spellId,
                    damage = dmg,
                    hits = hits,
                    misses = misses,
                    missTypes = CopyMissTypes(spellRow.missTypes),
                    share = dmg / math.max(1, row.damage),
                })
            end
        end
        table.sort(spells, function(a, b)
            if a.damage ~= b.damage then
                return a.damage > b.damage
            end
            return ((a.hits or 0) + (a.misses or 0)) > ((b.hits or 0) + (b.misses or 0))
        end)
        averages[minionId] = {
            damage = row.damage,
            hits = row.hits,
            misses = row.misses or 0,
            missTypes = CopyMissTypes(row.missTypes),
            fights = row.samples,
            dps = row.dpsTotal / math.max(1, row.samples),
            displayLabel = row.displayLabel,
            spells = spells,
        }
    end

    return averages, fightCount
end

function MinionDps:GetBenchmarkEstimates()
    local level = UnitLevel and UnitLevel("player") or 30
    local tier = BENCHMARK_DPS[level]
    if not tier then
        -- Prefer high-level calibration once past early levels (more LF → more ghouls).
        if level >= 40 then
            tier = BENCHMARK_DPS[60]
        else
            tier = BENCHMARK_DPS[30]
        end
    end
    if not tier then
        return nil
    end

    local estimates = {}
    for minionId, dps in pairs(tier) do
        estimates[minionId] = {
            damage = 0,
            hits = 0,
            fights = 0,
            dps = dps,
            -- Honesty: placeholders are ST-shaped, never the L60 AoE dummy parse.
            context = "st_placeholder",
        }
    end
    return estimates
end

-- Pack reference from measured L60 AoE dummies — UI/docs only, never LF Combo scoring.
function MinionDps:GetAoeCalibration()
    return CALIB_AOE_L60
end

-- ST composition from Details (shares only). Never invent DPS/unit without fight time.
function MinionDps:GetStCalibration()
    return CALIB_ST_L60_DETAILS
end

function MinionDps:GetBenchmarkContextLabel()
    local level = UnitLevel and UnitLevel("player") or 30
    if level >= 40 then
        return "Built-in ST placeholder (mid-41 anchors) — not AoE/pack DPS"
    end
    return "Built-in ST placeholder (early-level anchors) — not AoE/pack DPS"
end

-- True when a fight's player dots clearly hit multiple distinct targets.
function MinionDps:FightLooksLikeMultiTarget(fight)
    if not fight or not fight.playerSpells then
        return false
    end
    local maxTargets = 0
    for _, row in pairs(fight.playerSpells) do
        local n = 0
        for _ in pairs(row.targets or {}) do
            n = n + 1
        end
        if (row.peakTargets or 0) > n then
            n = row.peakTargets
        end
        if n > maxTargets then
            maxTargets = n
        end
    end
    return maxTargets >= 3
end

function MinionDps:RecentFightLooksLikeMultiTarget(source)
    local db = EnsureDb()
    if source == "current" and self.currentFight then
        return self:FightLooksLikeMultiTarget(self.currentFight)
    end
    if source == "last" and db.fights and db.fights[1] then
        return self:FightLooksLikeMultiTarget(db.fights[1])
    end
    if source == "session" and db.fights then
        local any = false
        local multi = 0
        local total = 0
        for i = 1, math.min(8, #db.fights) do
            total = total + 1
            if self:FightLooksLikeMultiTarget(db.fights[i]) then
                multi = multi + 1
                any = true
            end
        end
        return any and multi >= math.max(1, math.floor(total / 2))
    end
    return false
end

function MinionDps:GetDpsEstimates()
    local session, fightCount = self:AggregateSessionStats()
    if fightCount >= SESSION_MIN_FIGHTS then
        return session, fightCount, "session"
    end

    local fight = self.currentFight
    if fight and fight.startedAt then
        local current = self:AggregateFightStats(fight)
        if next(current) then
            return current, 1, "current"
        end
    end

    local db = EnsureDb()
    if db.fights[1] then
        local last = self:AggregateFightStats(db.fights[1])
        if next(last) then
            return last, 1, "last"
        end
    end

    local benchmark = self:GetBenchmarkEstimates()
    if benchmark and next(benchmark) then
        return benchmark, 0, "benchmark"
    end

    return nil, 0, nil
end

function MinionDps:FormatNumber(value)
    if value >= 1000000 then
        return string.format("%.1fm", value / 1000000)
    end
    if value >= 1000 then
        return string.format("%.1fk", value / 1000)
    end
    return string.format("%.0f", value)
end

function MinionDps:GetMinionLabel(minionId, bucket)
    if IsOwnedNameBucket(minionId) or minionId == OTHER_OWNED_ID or minionId == "other_owned" then
        return OwnedNameDisplayLabel(minionId, bucket)
    end
    local Advisor = GetAdvisor()
    local def = Advisor and Advisor.MINION_TYPES and Advisor.MINION_TYPES[minionId]
    if minionId == "lesser_zombie" then
        return (def and def.label or "Lesser Zombie") .. " (proc)"
    end
    return (def and def.label) or minionId
end

function MinionDps:PrintSpellBreakdown(minionDamage, spells, duration, units, indent)
    if not spells or #spells == 0 then
        return
    end

    indent = indent or "    "
    units = units or 1
    duration = math.max(1, duration or 1)
    for _, spellRow in ipairs(spells) do
        local share = spellRow.share
        if not share and minionDamage and minionDamage > 0 then
            share = spellRow.damage / minionDamage
        end
        local spellDps = spellRow.dps
        if not spellDps then
            spellDps = spellRow.damage / duration / units
        end
        Mancer.Print(string.format(
            "%s- %s: %s dmg | %.1f%% | %s | %.0f DPS",
            indent,
            spellRow.label or "?",
            self:FormatNumber(spellRow.damage),
            (share or 0) * 100,
            FormatHitsMisses(spellRow.hits, spellRow.misses, spellRow.missTypes),
            spellDps
        ))
    end
end

function MinionDps:PrintPlayerSpellStats(fight, duration, opts)
    opts = opts or {}
    local printFn = opts.printFn or function(msg)
        Mancer.Print(msg)
    end
    if not fight or not fight.playerSpells then
        return
    end
    duration = math.max(1, duration or self:GetFightDuration(fight))

    local rows = {}
    for _, row in pairs(fight.playerSpells) do
        local targetCount = 0
        local openExtra = 0
        local now = fight.endedAt or GetTimeNow()
        for _, t in pairs(row.targets or {}) do
            targetCount = targetCount + 1
            if t.openStart then
                openExtra = openExtra + math.max(0, now - t.openStart)
            end
        end
        local unitSec = (row.activeSeconds or 0) + openExtra
        local hasData = (row.damage or 0) > 0
            or (row.procs or 0) > 0
            or (row.casts or 0) > 0
            or unitSec > 0
            or targetCount > 0
        if hasData then
            table.insert(rows, { row = row, targetCount = targetCount, unitSec = unitSec })
        end
    end
    if #rows == 0 then
        return
    end

    table.sort(rows, function(a, b)
        local ad = a.row.damage or 0
        local bd = b.row.damage or 0
        if ad ~= bd then
            return ad > bd
        end
        return (a.row.procs or 0) > (b.row.procs or 0)
    end)

    printFn("Player spells:")
    for _, entry in ipairs(rows) do
        local row = entry.row
        if row.kind == "proc" then
            printFn(string.format(
                "  %s: %d procs",
                row.label or "?",
                row.procs or 0
            ))
        else
            local parts = {
                string.format("%s: %s dmg", row.label or "?", self:FormatNumber(row.damage or 0)),
            }
            if (row.casts or 0) > 0 then
                table.insert(parts, string.format("%d cast%s", row.casts, row.casts == 1 and "" or "s"))
            end
            if (row.damage or 0) > 0 then
                table.insert(parts, string.format("%.0f DPS", (row.damage or 0) / duration))
            end
            if entry.targetCount > 0 then
                table.insert(parts, string.format("%d target%s", entry.targetCount, entry.targetCount == 1 and "" or "s"))
            end
            if (entry.unitSec or 0) > 0 then
                table.insert(parts, string.format("%.1fs unit-sec", entry.unitSec))
            end
            if (row.peakTargets or 0) > 1 then
                table.insert(parts, string.format("peak %d", row.peakTargets))
            end
            if (row.hits or 0) > 0 then
                table.insert(parts, string.format("%d hits", row.hits))
            end
            printFn("  " .. table.concat(parts, " | "))

            -- Per-target breakdown (top 6 by damage, then uptime).
            local targets = {}
            for _, t in pairs(row.targets or {}) do
                table.insert(targets, t)
            end
            table.sort(targets, function(a, b)
                local ad = a.damage or 0
                local bd = b.damage or 0
                if ad ~= bd then
                    return ad > bd
                end
                return (a.activeSeconds or 0) > (b.activeSeconds or 0)
            end)
            local shown = 0
            for _, t in ipairs(targets) do
                if shown >= 20 then
                    local left = #targets - shown
                    if left > 0 then
                        printFn(string.format("    … +%d more targets", left))
                    end
                    break
                end
                local name = t.name
                if not name or name == "" then
                    name = "Target"
                end
                local up = t.activeSeconds or 0
                if t.openStart then
                    up = up + math.max(0, (fight.endedAt or GetTimeNow()) - t.openStart)
                end
                printFn(string.format(
                    "    %s: %s dmg | %.1fs up | %d ticks",
                    name,
                    self:FormatNumber(t.damage or 0),
                    up,
                    t.hits or 0
                ))
                shown = shown + 1
            end
        end
    end
end

function MinionDps:GetHarvestPlagueSummary(fight)
    if not fight or not fight.playerSpells then
        return nil
    end
    local bucket = fight.playerSpells["track:harvest_plague"]
    if not bucket then
        return nil
    end
    local targetCount = 0
    local openExtra = 0
    local now = fight.endedAt or GetTimeNow()
    for _, t in pairs(bucket.targets or {}) do
        targetCount = targetCount + 1
        if t.openStart then
            openExtra = openExtra + math.max(0, now - t.openStart)
        end
    end
    local unitSec = (bucket.activeSeconds or 0) + openExtra
    if unitSec <= 0 and (bucket.damage or 0) <= 0 and targetCount <= 0 and (bucket.hits or 0) <= 0 then
        return nil
    end
    return {
        unitSec = unitSec,
        targets = targetCount,
        damage = bucket.damage or 0,
        ticks = bucket.hits or 0,
        peak = bucket.peakTargets or 0,
    }
end

function MinionDps:GetHarvestPlagueSummaryFromFights(fights)
    local unitSec, targets, damage, ticks, peak = 0, 0, 0, 0, 0
    local any = false
    for _, fight in ipairs(fights or {}) do
        local s = self:GetHarvestPlagueSummary(fight)
        if s then
            any = true
            unitSec = unitSec + (s.unitSec or 0)
            targets = targets + (s.targets or 0)
            damage = damage + (s.damage or 0)
            ticks = ticks + (s.ticks or 0)
            if (s.peak or 0) > peak then
                peak = s.peak
            end
        end
    end
    if not any then
        return nil
    end
    return {
        unitSec = unitSec,
        targets = targets,
        damage = damage,
        ticks = ticks,
        peak = peak,
    }
end

function MinionDps:FormatHarvestPlagueLine(plague, zombieSpawns, duration)
    if (not zombieSpawns or zombieSpawns <= 0) and not plague then
        return nil
    end
    local parts = {}
    if zombieSpawns and zombieSpawns > 0 then
        table.insert(parts, string.format("%d zombies spawned", zombieSpawns))
    end
    if plague then
        if (plague.unitSec or 0) > 0 then
            table.insert(parts, string.format("%.0fs DoT unit-time", plague.unitSec))
        end
        if (plague.targets or 0) > 0 then
            table.insert(parts, string.format("%d target%s", plague.targets, plague.targets == 1 and "" or "s"))
        end
        if (plague.peak or 0) > 1 then
            table.insert(parts, string.format("peak %d", plague.peak))
        end
        if duration and duration > 0 and (plague.unitSec or 0) > 0 and (plague.targets or 0) <= 1 then
            local cover = math.min(100, 100 * plague.unitSec / duration)
            table.insert(parts, string.format("%.0f%% of fight", cover))
        end
    end
    if #parts == 0 then
        return nil
    end
    return "  Harvest Plague: " .. table.concat(parts, " · ")
end

function MinionDps:PrintFightStats(label, stats, duration, fight, opts)
    opts = opts or {}
    local includePlayer = opts.includePlayer ~= false
    local printFn = opts.printFn or function(msg)
        Mancer.Print(msg)
    end

    printFn(label .. string.format(" (%.1fs)", duration))

    local rows = {}
    for minionId, row in pairs(stats or {}) do
        table.insert(rows, { minionId = minionId, row = row })
    end
    table.sort(rows, function(a, b)
        return a.row.damage > b.row.damage
    end)

    if #rows == 0 then
        printFn("  No minion damage recorded.")
    else
        local Advisor = GetAdvisor()
        local zombieSpawns = 0
        for _, entry in ipairs(rows) do
            if entry.minionId == "lesser_zombie" then
                zombieSpawns = entry.row.summonCount or 0
                break
            end
        end
        local plague = opts.plagueSummary
        if plague == nil then
            plague = self:GetHarvestPlagueSummary(fight)
        end
        if plague == nil and opts.sessionFights then
            plague = self:GetHarvestPlagueSummaryFromFights(opts.sessionFights)
        end
        local plagueLine = self:FormatHarvestPlagueLine(plague, zombieSpawns, duration)
        if plagueLine then
            printFn(plagueLine)
        end

        for _, entry in ipairs(rows) do
            local minionId = entry.minionId
            local row = entry.row
            local lfCost = Advisor and Advisor:GetMinionLifeForceCost(minionId) or 0
            local dpsLf = (lfCost and lfCost > 0) and (row.dps / lfCost) or nil
            local suffix = dpsLf and string.format(" | %.0f DPS/LF", dpsLf) or ""
            printFn(string.format(
                "  %s: %s dmg | %.0f DPS/unit | %s%s",
                self:GetMinionLabel(minionId, row),
                self:FormatNumber(row.damage),
                row.dps,
                FormatHitsMisses(row.hits, row.misses, row.missTypes),
                suffix
            ))
            if row.attacks and (minionId == OTHER_OWNED_ID or minionId == "other_owned") then
                for _, atk in ipairs(row.attacks) do
                    printFn(string.format(
                        "    %s: %s dmg | %s | %.0f DPS",
                        atk.label or "Minion",
                        self:FormatNumber(atk.damage or 0),
                        FormatHitsMisses(atk.hits, atk.misses, atk.missTypes),
                        atk.dps or 0
                    ))
                end
            end
            if row.temporary or (row.activeSeconds and row.activeSeconds > 0) or (row.summonCount and row.summonCount > 0) then
                local active = row.activeSeconds or row.uptime or 0
                local summons = row.summonCount or 0
                if summons > 1 then
                    local mult = duration > 0 and (active / duration) or 0
                    printFn(string.format(
                        "    %d summons · %.0fs unit-time total (fight %.0fs%s)",
                        summons,
                        active,
                        duration,
                        mult > 1.05 and string.format(" · %.1f× overlapping unit-time", mult) or ""
                    ))
                elseif summons == 1 or active > 0 then
                    local pct = duration > 0 and math.min(100, 100 * active / duration) or 0
                    printFn(string.format(
                        "    Out %.0fs (%.0f%% of fight)%s",
                        active,
                        pct,
                        summons > 0 and " · 1 summon" or ""
                    ))
                end
            end
            -- Spell breakdown still uses Mancer.Print; route via temporary sink if needed.
            if opts.printFn then
                local prevSink = Mancer.reportSink
                local lines = {}
                Mancer.reportSink = lines
                self:PrintSpellBreakdown(row.damage, row.spells, duration, row.units)
                Mancer.reportSink = prevSink
                for _, line in ipairs(lines) do
                    printFn(line)
                end
            else
                self:PrintSpellBreakdown(row.damage, row.spells, duration, row.units)
            end
        end
    end

    if includePlayer then
        self:PrintPlayerSpellStats(fight, duration, opts.printFn and { printFn = opts.printFn } or nil)
    end
end

function MinionDps:PrintSessionPlayerSpells(fights, opts)
    opts = opts or {}
    local printFn = opts.printFn or function(msg)
        Mancer.Print(msg)
    end
    local totals = {}
    for _, fight in ipairs(fights or {}) do
        for key, row in pairs(fight.playerSpells or {}) do
            local t = totals[key]
            if not t then
                t = {
                    id = row.id,
                    kind = row.kind,
                    label = row.label,
                    damage = 0,
                    hits = 0,
                    procs = 0,
                    activeSeconds = 0,
                    peakTargets = 0,
                    targetSightings = 0,
                }
                totals[key] = t
            end
            t.damage = t.damage + (row.damage or 0)
            t.hits = t.hits + (row.hits or 0)
            t.procs = t.procs + (row.procs or 0)
            t.activeSeconds = t.activeSeconds + (row.activeSeconds or 0)
            if (row.peakTargets or 0) > t.peakTargets then
                t.peakTargets = row.peakTargets
            end
            for _ in pairs(row.targets or {}) do
                t.targetSightings = t.targetSightings + 1
            end
        end
    end

    local rows = {}
    for _, row in pairs(totals) do
        if (row.damage or 0) > 0 or (row.procs or 0) > 0 or (row.activeSeconds or 0) > 0 then
            table.insert(rows, row)
        end
    end
    if #rows == 0 then
        return
    end
    table.sort(rows, function(a, b)
        if (a.damage or 0) ~= (b.damage or 0) then
            return (a.damage or 0) > (b.damage or 0)
        end
        return (a.procs or 0) > (b.procs or 0)
    end)

    printFn("Player spells (session totals):")
    for _, row in ipairs(rows) do
        if row.kind == "proc" then
            printFn(string.format("  %s: %d procs", row.label or "?", row.procs or 0))
        else
            printFn(string.format(
                "  %s: %s dmg | %.1fs unit-sec | peak %d | %d target-sightings | %d ticks",
                row.label or "?",
                self:FormatNumber(row.damage or 0),
                row.activeSeconds or 0,
                row.peakTargets or 0,
                row.targetSightings or 0,
                row.hits or 0
            ))
        end
    end
end

function MinionDps:GetMinionIconSpellId(minionId)
    local Advisor = GetAdvisor()
    local def = Advisor and Advisor.MINION_TYPES and Advisor.MINION_TYPES[minionId]
    if not def then
        return nil
    end
    if def.alertSpellId then
        return def.alertSpellId
    end
    if def.summonSpellIds then
        -- Prefer Ascension-range IDs when present.
        local best
        for spellId in pairs(def.summonSpellIds) do
            local id = tonumber(spellId)
            if id and (not best or id > best) then
                best = id
            end
        end
        return best
    end
    if def.buffSpellIds then
        local best
        for spellId in pairs(def.buffSpellIds) do
            local id = tonumber(spellId)
            if id and (not best or id > best) then
                best = id
            end
        end
        return best
    end
    return nil
end

function MinionDps:ResolveMinionIconTexture(minionId, spellId)
    local Advisor = GetAdvisor()
    if Advisor and Advisor.GetAnimateAlertIcon then
        local _, texture = Advisor:GetAnimateAlertIcon(minionId)
        if type(texture) == "string" and texture ~= "" then
            return texture
        end
    end
    spellId = tonumber(spellId) or self:GetMinionIconSpellId(minionId)
    if spellId and GetSpellInfo then
        local tex = select(3, GetSpellInfo(spellId))
        if type(tex) == "string" and tex ~= "" then
            return tex
        end
    end
    local label = self:GetMinionLabel(minionId)
    if label and GetSpellInfo then
        local tex = select(3, GetSpellInfo(label))
        if type(tex) == "string" and tex ~= "" then
            return tex
        end
    end
    if IsOwnedNameBucket(minionId) or minionId == OTHER_OWNED_ID or minionId == "other_owned" then
        return "Interface\\Icons\\Spell_Shadow_RaiseDead"
    end
    return nil
end

function MinionDps:GetPlayerSpellIconSpellId(row)
    if row and row.spellId then
        return row.spellId
    end
    for _, def in ipairs(PLAYER_TRACKED_SPELLS) do
        if row and (def.id == row.id or def.label == row.label) then
            if def.spellIds then
                local best
                for spellId in pairs(def.spellIds) do
                    local id = tonumber(spellId)
                    if id and (not best or id > best) then
                        best = id
                    end
                end
                return best
            end
        end
    end
    return nil
end

function MinionDps:ResolvePlayerIconTexture(row, spellId)
    spellId = tonumber(spellId) or self:GetPlayerSpellIconSpellId(row)
    local Advisor = GetAdvisor()
    if Advisor and Advisor.PROC_AURAS and row then
        for _, def in ipairs(Advisor.PROC_AURAS) do
            if def.id == row.id or def.label == row.label then
                if def.fallbackIcon then
                    -- Prefer live spell texture when it's a path string.
                    if spellId and GetSpellInfo then
                        local tex = select(3, GetSpellInfo(spellId))
                        if type(tex) == "string" and tex ~= "" then
                            return tex
                        end
                    end
                    return def.fallbackIcon
                end
            end
        end
    end
    if spellId and GetSpellInfo then
        local tex = select(3, GetSpellInfo(spellId))
        if type(tex) == "string" and tex ~= "" then
            return tex
        end
    end
    if row and row.label and GetSpellInfo then
        local tex = select(3, GetSpellInfo(row.label))
        if type(tex) == "string" and tex ~= "" then
            return tex
        end
    end
    return nil
end

function MinionDps:BuildMinionAccordionRows(stats, duration, fight, opts)
    opts = opts or {}
    duration = math.max(1, duration or 1)
    local rows = {}
    for minionId, row in pairs(stats or {}) do
        table.insert(rows, { minionId = minionId, row = row })
    end
    table.sort(rows, function(a, b)
        return a.row.damage > b.row.damage
    end)

    local out = {}
    local Advisor = GetAdvisor()
    for _, entry in ipairs(rows) do
        local minionId = entry.minionId
        local row = entry.row
        local lfCost = Advisor and Advisor:GetMinionLifeForceCost(minionId) or 0
        local dpsLf = (lfCost and lfCost > 0) and (row.dps / lfCost) or nil
        local active = row.activeSeconds or row.uptime or 0
        local uptimePct = duration > 0 and math.min(100, 100 * active / duration) or 0
        local iconSpellId = self:GetMinionIconSpellId(minionId)
        local iconTexture = self:ResolveMinionIconTexture(minionId, iconSpellId)
        local spells = {}
        for _, spellRow in ipairs(row.spells or {}) do
            local spellId = spellRow.spellId
            local spellLabel = spellRow.label or "?"
            local spellTex
            if spellId and GetSpellInfo then
                local tex = select(3, GetSpellInfo(spellId))
                if type(tex) == "string" and tex ~= "" then
                    spellTex = tex
                end
            end
            if not spellTex and spellLabel and GetSpellInfo then
                local tex = select(3, GetSpellInfo(spellLabel))
                if type(tex) == "string" and tex ~= "" then
                    spellTex = tex
                end
            end
            table.insert(spells, {
                label = spellLabel,
                spellId = spellId,
                iconTexture = spellTex,
                damage = spellRow.damage or 0,
                sharePct = (spellRow.share or 0) * 100,
                hits = spellRow.hits or 0,
                misses = spellRow.misses or 0,
                missTypes = CopyMissTypes(spellRow.missTypes),
                dps = spellRow.dps or 0,
            })
        end
        local actors = nil
        -- Legacy unnamed other_owned only — named owned:* rows are top-level by name.
        if (minionId == OTHER_OWNED_ID or minionId == "other_owned") and row.attacks then
            actors = {}
            for _, atk in ipairs(row.attacks) do
                table.insert(actors, {
                    label = atk.label or "Minion",
                    damage = atk.damage or 0,
                    hits = atk.hits or 0,
                    misses = atk.misses or 0,
                    missTypes = CopyMissTypes(atk.missTypes),
                    dps = atk.dps or 0,
                })
            end
        end
        table.insert(out, {
            minionId = minionId,
            label = self:GetMinionLabel(minionId, row),
            iconSpellId = iconSpellId,
            iconTexture = iconTexture,
            damage = row.damage or 0,
            dps = row.dps or 0,
            hits = row.hits or 0,
            misses = row.misses or 0,
            missTypes = CopyMissTypes(row.missTypes),
            dpsLf = dpsLf,
            uptimePct = uptimePct,
            activeSeconds = active,
            summonCount = row.summonCount or 0,
            spells = spells,
            actors = actors,
        })
    end

    local harvest = nil
    if opts.plagueSummary == nil then
        opts.plagueSummary = self:GetHarvestPlagueSummary(fight)
    end
    if opts.plagueSummary == nil and opts.sessionFights then
        opts.plagueSummary = self:GetHarvestPlagueSummaryFromFights(opts.sessionFights)
    end
    local zombieSpawns = 0
    for _, entry in ipairs(rows) do
        if entry.minionId == "lesser_zombie" then
            zombieSpawns = entry.row.summonCount or 0
            break
        end
    end
    local plagueLine = self:FormatHarvestPlagueLine(opts.plagueSummary, zombieSpawns, duration)
    if plagueLine then
        harvest = plagueLine:gsub("^%s+", "")
    end

    return out, harvest
end

function MinionDps:BuildPlayerAccordionRows(fight, duration, opts)
    opts = opts or {}
    if not fight or not fight.playerSpells then
        return {}
    end
    duration = math.max(1, duration or self:GetFightDuration(fight))

    local entries = {}
    for _, row in pairs(fight.playerSpells) do
        local targetCount = 0
        local openExtra = 0
        local now = fight.endedAt or GetTimeNow()
        for _, t in pairs(row.targets or {}) do
            targetCount = targetCount + 1
            if t.openStart then
                openExtra = openExtra + math.max(0, now - t.openStart)
            end
        end
        local unitSec = (row.activeSeconds or 0) + openExtra
        local hasData = (row.damage or 0) > 0
            or (row.procs or 0) > 0
            or (row.casts or 0) > 0
            or unitSec > 0
            or targetCount > 0
        if hasData then
            table.insert(entries, { row = row, targetCount = targetCount, unitSec = unitSec })
        end
    end
    if #entries == 0 then
        return {}
    end

    table.sort(entries, function(a, b)
        local ad = a.row.damage or 0
        local bd = b.row.damage or 0
        if ad ~= bd then
            return ad > bd
        end
        local ac = a.row.casts or 0
        local bc = b.row.casts or 0
        if ac ~= bc then
            return ac > bc
        end
        return (a.row.procs or 0) > (b.row.procs or 0)
    end)

    local out = {}
    for _, entry in ipairs(entries) do
        local row = entry.row
        local uptimePct = nil
        if entry.targetCount <= 1 and entry.unitSec > 0 and duration > 0 then
            uptimePct = math.min(100, 100 * entry.unitSec / duration)
        end
        local item = {
            id = row.id,
            label = row.label or "?",
            kind = row.kind or "dot",
            iconSpellId = self:GetPlayerSpellIconSpellId(row),
            iconTexture = nil,
            damage = row.damage or 0,
            procs = row.procs or 0,
            casts = row.casts or 0,
            dps = (row.damage or 0) / duration,
            unitSec = entry.unitSec,
            targetCount = entry.targetCount,
            uptimePct = uptimePct,
            hits = row.hits or 0,
            targets = {},
        }
        item.iconTexture = self:ResolvePlayerIconTexture(item, item.iconSpellId)
        if row.kind ~= "proc" then
            local targets = {}
            for _, t in pairs(row.targets or {}) do
                table.insert(targets, t)
            end
            table.sort(targets, function(a, b)
                local ad = a.damage or 0
                local bd = b.damage or 0
                if ad ~= bd then
                    return ad > bd
                end
                return (a.activeSeconds or 0) > (b.activeSeconds or 0)
            end)
            for _, t in ipairs(targets) do
                local name = t.name
                if not name or name == "" then
                    name = "Target"
                end
                table.insert(item.targets, {
                    name = name,
                    damage = t.damage or 0,
                })
            end
        end
        table.insert(out, item)
    end
    return out
end

function MinionDps:BuildSessionPlayerAccordionRows(fights)
    local totals = {}
    for _, fight in ipairs(fights or {}) do
        for key, row in pairs(fight.playerSpells or {}) do
            local t = totals[key]
            if not t then
                t = {
                    id = row.id,
                    kind = row.kind,
                    label = row.label,
                    spellId = row.spellId,
                    damage = 0,
                    hits = 0,
                    procs = 0,
                    casts = 0,
                    activeSeconds = 0,
                    peakTargets = 0,
                    targetSightings = 0,
                }
                totals[key] = t
            end
            if row.spellId and not t.spellId then
                t.spellId = row.spellId
            end
            if row.kind and (not t.kind or t.kind == "damage") then
                t.kind = row.kind
            end
            t.damage = t.damage + (row.damage or 0)
            t.hits = t.hits + (row.hits or 0)
            t.procs = t.procs + (row.procs or 0)
            t.casts = t.casts + (row.casts or 0)
            t.activeSeconds = t.activeSeconds + (row.activeSeconds or 0)
            if (row.peakTargets or 0) > t.peakTargets then
                t.peakTargets = row.peakTargets
            end
            for _ in pairs(row.targets or {}) do
                t.targetSightings = t.targetSightings + 1
            end
        end
    end

    local rows = {}
    for _, row in pairs(totals) do
        if (row.damage or 0) > 0 or (row.procs or 0) > 0 or (row.casts or 0) > 0 or (row.activeSeconds or 0) > 0 then
            table.insert(rows, row)
        end
    end
    table.sort(rows, function(a, b)
        if (a.damage or 0) ~= (b.damage or 0) then
            return (a.damage or 0) > (b.damage or 0)
        end
        if (a.casts or 0) ~= (b.casts or 0) then
            return (a.casts or 0) > (b.casts or 0)
        end
        return (a.procs or 0) > (b.procs or 0)
    end)

    local out = {}
    for _, row in ipairs(rows) do
        local sessionNote
        if row.kind == "proc" then
            sessionNote = string.format("%d procs (session total)", row.procs or 0)
        elseif row.kind == "damage" then
            sessionNote = string.format(
                "%s dmg | %d hits",
                self:FormatNumber(row.damage or 0),
                row.hits or 0
            )
        elseif row.kind == "spell" or (row.casts or 0) > 0 then
            sessionNote = string.format(
                "%s dmg | %d casts | %d hits | %.1fs unit-sec | %d target-sightings",
                self:FormatNumber(row.damage or 0),
                row.casts or 0,
                row.hits or 0,
                row.activeSeconds or 0,
                row.targetSightings or 0
            )
        else
            sessionNote = string.format(
                "%s dmg | %.1fs unit-sec | peak %d | %d target-sightings | %d ticks",
                self:FormatNumber(row.damage or 0),
                row.activeSeconds or 0,
                row.peakTargets or 0,
                row.targetSightings or 0,
                row.hits or 0
            )
        end
        local item = {
            id = row.id,
            label = row.label or "?",
            kind = row.kind or "dot",
            iconSpellId = self:GetPlayerSpellIconSpellId(row),
            damage = row.damage or 0,
            procs = row.procs or 0,
            casts = row.casts or 0,
            unitSec = row.activeSeconds or 0,
            targetCount = row.targetSightings or 0,
            uptimePct = nil,
            hits = row.hits or 0,
            targets = {},
            sessionNote = sessionNote,
        }
        item.iconTexture = self:ResolvePlayerIconTexture(item, item.iconSpellId)
        table.insert(out, item)
    end
    return out
end

function MinionDps:GetDpsReportData(mode)
    self:Init()
    mode = mode or "auto"

    if mode == "benchmark" then
        return {
            title = "Minion DPS (Benchmark)",
            duration = 0,
            mode = "benchmark",
            minions = {},
            players = {},
            minionTextFallback = nil,
            playerTextFallback = "(ST placeholders only — pack reference is under Hub → ST vs AOE / Benchmark print)",
        }
    end

    local resolved = self:ResolveDpsFight(mode)
    if not resolved then
        return nil
    end

    local minions, harvest = self:BuildMinionAccordionRows(
        resolved.stats,
        resolved.duration,
        resolved.fight,
        { sessionFights = resolved.sessionFights }
    )

    local players = {}
    if resolved.mode == "session" then
        players = self:BuildSessionPlayerAccordionRows(resolved.sessionFights)
    elseif resolved.fight then
        players = self:BuildPlayerAccordionRows(resolved.fight, resolved.duration)
    end

    return {
        title = resolved.title,
        duration = resolved.duration,
        mode = resolved.mode,
        harvestPlague = harvest,
        minions = minions,
        players = players,
    }
end

function MinionDps:FormatDpsReportText(data)
    if not data then
        return "", ""
    end
    if data.mode == "benchmark" then
        local lines = {}
        local prev = Mancer.reportSink
        Mancer.reportSink = lines
        self:PrintDpsReport("benchmark")
        Mancer.reportSink = prev
        return table.concat(lines, "\n"), data.playerTextFallback or ""
    end

    local minionLines = {}
    if data.harvestPlague and data.harvestPlague ~= "" then
        table.insert(minionLines, data.harvestPlague)
    end
    for _, row in ipairs(data.minions or {}) do
        local suffix = row.dpsLf and string.format(" | %.0f DPS/LF", row.dpsLf) or ""
        table.insert(minionLines, string.format(
            "  %s: %s dmg | %.0f DPS/unit | %s%s",
            row.label,
            self:FormatNumber(row.damage),
            row.dps,
            FormatHitsMisses(row.hits, row.misses, row.missTypes),
            suffix
        ))
        if row.actors then
            for _, actor in ipairs(row.actors) do
                table.insert(minionLines, string.format(
                    "    %s: %s dmg | %s | %.0f DPS",
                    actor.label or "Minion",
                    self:FormatNumber(actor.damage or 0),
                    FormatHitsMisses(actor.hits, actor.misses, actor.missTypes),
                    actor.dps or 0
                ))
            end
        end
        for _, spell in ipairs(row.spells or {}) do
            table.insert(minionLines, string.format(
                "    - %s: %s dmg | %.1f%% | %s | %.0f DPS",
                spell.label,
                self:FormatNumber(spell.damage),
                spell.sharePct,
                FormatHitsMisses(spell.hits, spell.misses, spell.missTypes),
                spell.dps
            ))
        end
    end

    local playerLines = {}
    for _, row in ipairs(data.players or {}) do
        if row.kind == "proc" then
            table.insert(playerLines, string.format("  %s: %d procs", row.label, row.procs or 0))
        elseif row.sessionNote then
            table.insert(playerLines, string.format("  %s: %s", row.label, row.sessionNote))
        else
            local parts = {
                string.format("%s: %s dmg", row.label, self:FormatNumber(row.damage or 0)),
            }
            if (row.casts or 0) > 0 then
                table.insert(parts, string.format("%d cast%s", row.casts, row.casts == 1 and "" or "s"))
            end
            if (row.dps or 0) > 0 or (row.damage or 0) > 0 then
                table.insert(parts, string.format("%.0f DPS", row.dps or 0))
            end
            if (row.targetCount or 0) > 0 then
                table.insert(parts, string.format("%d target%s", row.targetCount, row.targetCount == 1 and "" or "s"))
            end
            if (row.unitSec or 0) > 0 then
                table.insert(parts, string.format("%.1fs unit-sec", row.unitSec))
            end
            if row.uptimePct then
                table.insert(parts, string.format("%.0f%% of fight", row.uptimePct))
            end
            if (row.hits or 0) > 0 then
                table.insert(parts, string.format("%d hits", row.hits))
            end
            table.insert(playerLines, "  " .. table.concat(parts, " | "))
            for _, t in ipairs(row.targets or {}) do
                table.insert(playerLines, string.format(
                    "    %s: %s dmg",
                    t.name,
                    self:FormatNumber(t.damage or 0)
                ))
            end
        end
    end

    return table.concat(minionLines, "\n"), table.concat(playerLines, "\n")
end

function MinionDps:ResolveDpsFight(mode)
    self:Init()
    mode = mode or "auto"
    if mode == "session" then
        local stats, fightCount = self:AggregateSessionStats()
        if fightCount <= 0 then
            return nil
        end
        local totalDuration = 0
        local db = EnsureDb()
        for _, fight in ipairs(db.fights) do
            totalDuration = totalDuration + self:GetFightDuration(fight)
        end
        return {
            mode = "session",
            title = string.format("Minion DPS session (%d fights)", fightCount),
            stats = stats,
            duration = totalDuration,
            fight = nil,
            sessionFights = db.fights,
        }
    end

    if self.currentFight and (self.currentFight.startedAt or PlayerSpellsHaveData(self.currentFight)) then
        local stats, duration = self:AggregateFightStats(self.currentFight)
        if next(stats) or PlayerSpellsHaveData(self.currentFight) then
            return {
                mode = "current",
                title = "DPS (current fight)",
                stats = stats,
                duration = duration,
                fight = self.currentFight,
            }
        end
    end

    if self.pendingFight and self:FightHasDamage(self.pendingFight) then
        local stats, duration = self:AggregateFightStats(self.pendingFight)
        if next(stats) or PlayerSpellsHaveData(self.pendingFight) then
            return {
                mode = "last",
                title = "DPS (last fight)",
                stats = stats,
                duration = duration,
                fight = self.pendingFight,
            }
        end
    end

    local db = EnsureDb()
    if db.fights[1] then
        local stats, duration = self:AggregateFightStats(db.fights[1])
        return {
            mode = "saved",
            title = "DPS (last fight)",
            stats = stats,
            duration = duration,
            fight = db.fights[1],
        }
    end
    return nil
end

function MinionDps:GetDpsReportColumns(mode)
    self:Init()
    mode = mode or "auto"

    if mode == "benchmark" then
        local data = self:GetDpsReportData("benchmark")
        local minionText, playerText = self:FormatDpsReportText(data)
        return {
            title = data.title,
            minionText = minionText,
            playerText = playerText,
        }
    end

    local data = self:GetDpsReportData(mode)
    if not data then
        local lines = {}
        local prev = Mancer.reportSink
        Mancer.reportSink = lines
        if mode == "session" then
            Mancer.Print("No saved minion DPS fights yet. Enter combat with your army — fights auto-save when combat ends.")
        else
            Mancer.Print("No live DPS data yet.")
        end
        self:PrintCalibrationHelp()
        Mancer.reportSink = prev
        return {
            title = mode == "session" and "Minion DPS (Session)" or "Minion DPS",
            minionText = table.concat(lines, "\n"),
            playerText = "(no player spell data yet)",
        }
    end

    local minionText, playerText = self:FormatDpsReportText(data)
    if playerText == "" then
        playerText = "(no player DoTs / procs this fight)"
    end

    return {
        title = data.title,
        minionText = minionText,
        playerText = playerText,
        data = data,
    }
end

function MinionDps:BuildDpsExportText(mode)
    local cols = self:GetDpsReportColumns(mode or "auto")
    if not cols then
        return nil
    end
    local playerName = (UnitName and UnitName("player")) or "?"
    local stamp = date and date("%Y-%m-%d %H:%M:%S") or "?"
    local lines = {
        "Libellus Leti Minion DPS Export",
        "Version: " .. tostring(Mancer.VERSION or "?"),
        "Character: " .. tostring(playerName),
        "Exported: " .. tostring(stamp),
        "",
        cols.title or "Minion DPS",
        "",
        "=== Minions ===",
        cols.minionText or "(none)",
        "",
        "=== Player ===",
        cols.playerText or "(none)",
        "",
    }
    return table.concat(lines, "\n")
end

function MinionDps:PrintDpsReport(mode)
    self:Init()
    mode = mode or "auto"

    if mode == "benchmark" then
        local stats = self:GetBenchmarkEstimates()
        if not stats or not next(stats) then
            Mancer.Print("No benchmark data available.")
            return
        end
        Mancer.Print("Reference DPS per minion (single-target placeholders — used until you record a fight):")
        Mancer.Print("  " .. (self:GetBenchmarkContextLabel() or ""))
        local Advisor = GetAdvisor()
        for _, minionId in ipairs({ "crypt_fiend", "banshee", "abomination", "skeletal_warrior_greater", "ghoul", "skeletal_rogue", "skeletal_warrior_lesser" }) do
            local row = stats[minionId]
            if row then
                local lfCost = Advisor and Advisor:GetMinionLifeForceCost(minionId) or 0
                local dpsLf = (lfCost and lfCost > 0) and (row.dps / lfCost) or nil
                local suffix = dpsLf and string.format(" | %.0f DPS per Life Force", dpsLf) or ""
                Mancer.Print(string.format("  %s: %.1f DPS each%s", self:GetMinionLabel(minionId), row.dps, suffix))
            end
        end
        local aoe = self:GetAoeCalibration()
        if aoe and aoe.dpsPerUnit then
            Mancer.Print("")
            Mancer.Print(string.format("Pack reference (%s) — do not use for boss ST:", aoe.label))
            local order = { "ghoul", "lesser_zombie", "frost_wyrm", "skeletal_archer", "bone_wraith" }
            for _, minionId in ipairs(order) do
                local dps = aoe.dpsPerUnit[minionId]
                if dps then
                    Mancer.Print(string.format("  %s: ~%.0f DPS/unit", self:GetMinionLabel(minionId), dps))
                end
            end
            if aoe.ghoulCommandShare then
                Mancer.Print(string.format(
                    "  Ghoul split: Command ~%.0f%% / Melee ~%.0f%%",
                    aoe.ghoulCommandShare * 100,
                    (aoe.ghoulMeleeShare or 0) * 100
                ))
            end
        end
        local st = self.GetStCalibration and self:GetStCalibration()
        if st and st.damageK then
            Mancer.Print("")
            Mancer.Print(string.format("ST composition (%s) — shares only, no DPS/unit:", st.label))
            Mancer.Print(string.format(
                "  Ghoul Melee %.0fk (%.0f%%) · Command %.0fk (%.0f%%) · split Melee/Command ~%.0f/%.0f",
                st.damageK.ghoul_melee, st.sharePct.ghoul_melee,
                st.damageK.command_ghouls, st.sharePct.command_ghouls,
                st.ghoulMeleeShare * 100, st.ghoulCommandShare * 100
            ))
            Mancer.Print(string.format(
                "  Archer %.0fk · Wyrm %.0fk · Crypt Swarm %.0fk · Plaguefather melee %.0fk",
                st.damageK.skeletal_arrow, st.damageK.frost_wyrm_breath,
                st.damageK.crypt_swarm, st.damageK.plaguefather_melee
            ))
        end
        Mancer.Print("")
        Mancer.Print("  Placeholders are boss/single-target shaped. For packs, open Hub → ST vs AOE.")
        return
    end

    local cols = self:GetDpsReportColumns(mode)
    for line in string.gmatch((cols.minionText or "") .. "\n", "(.-)\n") do
        Mancer.Print(line)
    end
    Mancer.Print("")
    for line in string.gmatch((cols.playerText or "") .. "\n", "(.-)\n") do
        Mancer.Print(line)
    end
end

function MinionDps:GetFightRole(minionId)
    return FIGHT_ROLES[minionId]
end

function MinionDps:PrintCalibrationHelp()
    Mancer.Print("How to measure your minion DPS (easy steps)")
    Mancer.Print("")
    Mancer.Print("  1. Raise your army and fight — recording starts when you enter combat")
    Mancer.Print("  2. When combat ends, the fight is saved automatically")
    Mancer.Print("  3. Open Hub → Combat → DPS after a pull")
    Mancer.Print("  4. Training dummies: Hub → Save DPS (exports report + saves for LF Combo)")
    Mancer.Print("  5. Hub → Save DPS copies the report so you can paste into a .txt file")
    Mancer.Print("  6. Hub → LF Combo uses your recent fight data to pick a boss army")
    Mancer.Print("")
    Mancer.Print("  Good starter: 1 Abomination + as many Ghouls as you can.")
    Mancer.Print("  For packs vs bosses, open Hub → ST vs AOE.")
    Mancer.Print("  Tip: save both a single-target pull and a pack pull — LF Combo is for bosses.")
end

function MinionDps:GetStVsAoeColumns()
    local aoe = CALIB_AOE_L60
    local st = CALIB_ST_L60_DETAILS
    local aoeMeasured = {
        "Packs / AoE",
        "Goal: hit MANY enemies (trash packs, cleave).",
        "",
        "Raise first",
        "  • Crypt Fiend — best Raise for packs (no L60 pack sample yet)",
        "  • Keep 1 Abomination if you can (Army of the Dead haste)",
        "  • Fill the rest with Ghouls — Command cleaves hard on packs",
        "",
        "Animates",
        "  • Tomb King — short buff for the whole army",
        "  • Frost Wyrm — strong pack Animate when it is up",
        "  • Archer / Plaguefather — still press on cooldown",
        "  • Bone Wraith — still fine; Tomb King can win with a big army",
        "",
        string.format("Measured (%s):", aoe.label),
        string.format("  • Ghoul ~%d DPS/unit (Command ~%.0f%% of ghoul dmg)", aoe.dpsPerUnit.ghoul, aoe.ghoulCommandShare * 100),
        string.format("  • Frost Wyrm ~%d · Zombies ~%d · Archer ~%d · Wraith ~%d DPS/unit",
            aoe.dpsPerUnit.frost_wyrm,
            aoe.dpsPerUnit.lesser_zombie,
            aoe.dpsPerUnit.skeletal_archer,
            aoe.dpsPerUnit.bone_wraith),
        "  • Pack numbers only — not boss ST. Not hit-capped on that parse.",
    }
    return {
        intro = "Simple answer — what to raise for each fight type.\n(No heavy maths — pick the column that matches your pull.)",
        stText = table.concat({
            "Boss / one target",
            "Goal: kill ONE enemy (boss, dummy, priority kill).",
            "",
            "Raise first",
            "  • Abomination, then fill leftover Life Force with Ghouls",
            "  • Pure Ghouls are fine early if you do not have Abom yet",
            "",
            "Animates (no Life Force)",
            "  • Bone Wraith — best boss Animate",
            "  • Archer / Frost Wyrm / Plaguefather — press when ready",
            "",
            "Leave for packs",
            "  • Crypt Fiend — usually worse than Ghouls on one target",
            "  • Tomb King — better when many minions are hitting",
            "",
            string.format("Measured (%s) — damage share on one target:", st.label),
            string.format("  • Ghoul Melee %.0fk (%.0f%%) · Command %.0fk (%.0f%%)",
                st.damageK.ghoul_melee, st.sharePct.ghoul_melee,
                st.damageK.command_ghouls, st.sharePct.command_ghouls),
            string.format("  • Ghoul split: Melee ~%.0f%% / Command ~%.0f%% (AoE was Command-heavy)",
                st.ghoulMeleeShare * 100, st.ghoulCommandShare * 100),
            string.format("  • Archer %.0fk · Frost Wyrm %.0fk · Crypt Swarm %.0fk · Plaguefather melee %.0fk",
                st.damageK.skeletal_arrow, st.damageK.frost_wyrm_breath,
                st.damageK.crypt_swarm, st.damageK.plaguefather_melee),
            "  • Shares only (Details) — no DPS/unit without fight time. Not hit-capped.",
            "  • LF Combo placeholders still use mid-41 ST (~152 ghoul DPS/unit) until you save a fight.",
        }, "\n"),
        aoeText = table.concat(aoeMeasured, "\n"),
        cheatText = table.concat({
            "Quick cheat sheet",
            "  Boss  → Abom + Ghouls + Bone Wraith",
            "  Trash → Crypt Fiend + Ghouls + Tomb King",
            "",
            "  Hub → LF Combo = best Life Force army for bosses (uses your fights).",
            "  If your last fight was multi-target, LF Combo will warn — save a ST pull too.",
            "  Fights auto-save when combat ends (Save DPS for dummies / .txt export).",
        }, "\n"),
    }
end

function MinionDps:BuildComboLabel(counts)
    local parts = {}
    local Advisor = GetAdvisor()
    if not Advisor then
        return "?"
    end

    local order = { "abomination", "crypt_fiend", "banshee", "skeletal_warrior_greater", "skeletal_warrior_lesser", "skeletal_rogue", "ghoul" }
    for _, minionId in ipairs(order) do
        local count = counts[minionId] or 0
        if count > 0 then
            local label = self:GetMinionLabel(minionId)
            if count > 1 then
                table.insert(parts, string.format("%dx %s", count, label))
            else
                table.insert(parts, label)
            end
        end
    end

    if #parts == 0 then
        return "empty"
    end
    return table.concat(parts, " + ")
end

function MinionDps:GetCommandGhoulBonus(ghoulCount)
    ghoulCount = tonumber(ghoulCount) or 0
    if ghoulCount < COMMAND_GHOUL_MIN_COUNT then
        return 0
    end

    local Advisor = GetAdvisor()
    if not Advisor or not Advisor.IsMinionAvailable or not Advisor:IsMinionAvailable("ghoul") then
        return 0
    end

    return ghoulCount * COMMAND_GHOUL_DPS_PER_UNIT
end

function MinionDps:ScoreCombo(counts, dpsEstimates)
    local Advisor = GetAdvisor()
    if not Advisor then
        return 0
    end

    local total = 0
    for minionId, count in pairs(counts) do
        local dps = dpsEstimates[minionId] and dpsEstimates[minionId].dps or 0
        total = total + (count * dps)
    end

    total = total + self:GetCommandGhoulBonus(counts.ghoul or 0)
    return total
end

function MinionDps:GetLifeForceUsed(counts)
    local Advisor = GetAdvisor()
    if not Advisor then
        return 0
    end

    local used = 0
    for minionId, count in pairs(counts) do
        used = used + (count * Advisor:GetMinionLifeForceCost(minionId))
    end
    return used
end

function MinionDps:EnumerateComboCandidates(lfMax, dpsEstimates)
    local Advisor = GetAdvisor()
    if not Advisor then
        return {}
    end

    local optional = {}
    for _, minionId in ipairs(LF_COMBO_MINIONS) do
        if Advisor:IsMinionAvailable(minionId) and dpsEstimates[minionId] then
            table.insert(optional, {
                id = minionId,
                cost = math.max(1, Advisor:GetMinionLifeForceCost(minionId)),
                maxCount = Advisor:GetMinionMax(minionId) or 1,
            })
        end
    end

    local hasGhoul = Advisor:IsMinionAvailable("ghoul") and dpsEstimates.ghoul
    local results = {}

    local function finalize(counts, lfUsed)
        local final = {}
        for minionId, count in pairs(counts) do
            if count and count > 0 then
                final[minionId] = count
            end
        end

        local ghoulSlots = lfMax - lfUsed
        if hasGhoul and ghoulSlots > 0 then
            local ghoulMax = Advisor:GetMinionMax("ghoul") or lfMax
            final.ghoul = math.min(ghoulSlots, ghoulMax)
        end

        if next(final) then
            table.insert(results, {
                counts = final,
                score = self:ScoreCombo(final, dpsEstimates),
                lfUsed = self:GetLifeForceUsed(final),
            })
        elseif hasGhoul then
            local fallback = { ghoul = math.min(lfMax, Advisor:GetMinionMax("ghoul") or lfMax) }
            table.insert(results, {
                counts = fallback,
                score = self:ScoreCombo(fallback, dpsEstimates),
                lfUsed = self:GetLifeForceUsed(fallback),
            })
        end
    end

    local function search(index, lfUsed, counts)
        if index > #optional then
            finalize(counts, lfUsed)
            return
        end

        local entry = optional[index]
        local maxByLf = math.floor((lfMax - lfUsed) / entry.cost)
        local maxCount = math.min(entry.maxCount, maxByLf)
        for count = 0, maxCount do
            if count > 0 then
                counts[entry.id] = count
            else
                counts[entry.id] = nil
            end
            search(index + 1, lfUsed + (count * entry.cost), counts)
        end
    end

    if #optional == 0 then
        finalize({}, 0)
    else
        search(1, 0, {})
    end

    return results
end

function MinionDps:FindBestCombo(dpsEstimates, lfMax)
    local Advisor = GetAdvisor()
    if not Advisor then
        return nil
    end

    local bestScore = -1
    local bestCounts = nil
    local bestLfUsed = -1

    for _, candidate in ipairs(self:EnumerateComboCandidates(lfMax, dpsEstimates)) do
        local score = candidate.score
        local lfUsed = candidate.lfUsed
        if score > bestScore or (score == bestScore and lfUsed > bestLfUsed) then
            bestScore = score
            bestCounts = candidate.counts
            bestLfUsed = lfUsed
        end
    end

    return bestCounts, bestScore, bestLfUsed
end

function MinionDps:FindRunnerUpCombo(dpsEstimates, lfMax, bestCounts)
    if not bestCounts then
        return nil, 0
    end

    local bestLabel = self:BuildComboLabel(bestCounts)
    local runnerCounts = nil
    local runnerScore = -1

    for _, candidate in ipairs(self:EnumerateComboCandidates(lfMax, dpsEstimates)) do
        local label = self:BuildComboLabel(candidate.counts)
        if label ~= bestLabel and candidate.score > runnerScore then
            runnerScore = candidate.score
            runnerCounts = candidate.counts
        end
    end

    return runnerCounts, runnerScore
end

function MinionDps:PrintComboRecommendation()
    local Advisor = GetAdvisor()
    if not Advisor then
        Mancer.Print("Minion advisor not loaded.")
        return
    end

    if not Advisor:IsMinionAdvisorEnabled() then
        Mancer.Print("Minion combo planner requires Animation Necromancer.")
        return
    end

    local dpsEstimates, fightCount, source = self:GetDpsEstimates()
    if not dpsEstimates or not next(dpsEstimates) then
        Mancer.Print("Need minion DPS data before recommending combos.")
        self:PrintCalibrationHelp()
        return
    end

    local lfMax = Advisor:GetLifeForceMax()
    local bestCounts, bestScore, lfUsed = self:FindBestCombo(dpsEstimates, lfMax)
    if not bestCounts then
        Mancer.Print("Could not build a life force combo for your talents.")
        return
    end

    local sourceLabel = "your measured fights"
    if source == "benchmark" then
        sourceLabel = "built-in single-target placeholders (not AoE)"
    elseif source == "session" then
        sourceLabel = "your session averages"
    elseif source == "current" or source == "last" then
        sourceLabel = "your recent fight"
    elseif source then
        sourceLabel = tostring(source)
    end

    Mancer.Print("Best army for bosses (one target)")
    Mancer.Print(string.format("  Based on: %s", sourceLabel))
    if source ~= "benchmark" and self:RecentFightLooksLikeMultiTarget(source) then
        Mancer.Print("  Caution: that data looks multi-target (3+ blight/DoT targets).")
        Mancer.Print("  Pack DPS will overstate a boss army — save a single-target pull too.")
    end
    Mancer.Print("")
    Mancer.Print("  Raise this:")
    Mancer.Print("    " .. self:BuildComboLabel(bestCounts))
    Mancer.Print(string.format(
        "  About %.0f minion DPS  |  Life Force %d / %d",
        bestScore,
        lfUsed,
        lfMax
    ))
    if source == "benchmark" then
        Mancer.Print("  (Placeholder DPS — record a fight for your real numbers.)")
    end

    local ghoulCount = bestCounts.ghoul or 0
    local commandBonus = self:GetCommandGhoulBonus(ghoulCount)
    if commandBonus > 0 then
        Mancer.Print(string.format(
            "  (Includes Command: Undead bonus from %d ghouls)",
            ghoulCount
        ))
    end

    local runnerCounts, runnerScore = self:FindRunnerUpCombo(dpsEstimates, lfMax, bestCounts)
    if runnerCounts and runnerScore > 0 and bestScore > 0 then
        local delta = ((bestScore - runnerScore) / runnerScore) * 100
        Mancer.Print("")
        Mancer.Print(string.format(
            "  Next best: %s (about %.0f%% weaker)",
            self:BuildComboLabel(runnerCounts),
            delta
        ))
    end

    local cdNotes = {}
    for _, minionId in ipairs(CD_MINIONS) do
        if Advisor:IsMinionAvailable(minionId) then
            table.insert(cdNotes, self:GetMinionLabel(minionId))
        end
    end
    if #cdNotes > 0 then
        Mancer.Print("")
        Mancer.Print("  Animates (no Life Force) — press when ready:")
        Mancer.Print("    " .. table.concat(cdNotes, ", "))
    end

    Mancer.Print("")
    Mancer.Print("  For packs / AoE, open Hub → ST vs AOE.")
    if source == "benchmark" then
        Mancer.Print("  Tip: Fight anything with your army — DPS auto-saves when combat ends (Save DPS for dummies / export).")
    end
end
