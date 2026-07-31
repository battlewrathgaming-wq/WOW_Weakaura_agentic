-- task_cvarlog.lua - the nameplate-CVar FLIGHT RECORDER (Mancer x TurboPlates
-- interaction debug, 2026-07-31: changing a Mancer setting turns plates off;
-- their restore likely replays a stale-zero backup; only a live trace proves
-- which CVar flips when, and what the backup tables held at that moment).
--
--   /coadump st cvarlog     start (baseline row lands immediately)
--   ...open Mancer's window, toggle settings, watch plates...
--   /coadump sp             stop; /reload lands the record
--
-- Every 0.5s: re-read the family; ONLY changes are logged (t, key, from, to),
-- and each change also snapshots Mancer's in-memory backup tables (HpHud +
-- Sheet nameplateCvarBackup) plus its persisted backup in MancerDB - the
-- suspects. Pure capture, no verdicts.

local ADDON, D = ...

local CVARS = {
    "nameplateShowEnemies", "nameplateShowEnemyPets", "nameplateShowEnemyGuardians",
    "nameplateShowEnemyTotems",
    "nameplateShowFriends", "nameplateShowFriendlyPets", "nameplateShowFriendlyGuardians",
    "nameplateShowFriendlyTotems",
    "nameplateShowPersonal",
}

local frames, payload, last

local function readAll()
    local out = {}
    for _, key in ipairs(CVARS) do
        local ok, v = pcall(GetCVar, key)
        out[key] = ok and v or "ERR"
    end
    return out
end

local function copyShallow(t)
    if type(t) ~= "table" then return t end
    local out = {}
    for k, v in pairs(t) do out[k] = v end
    return out
end

local function mancerBackups()
    local M = _G.Mancer
    local out = {}
    pcall(function()
        if M and M.MinionHpHudModule then
            out.hpHud = copyShallow(M.MinionHpHudModule.nameplateCvarBackup)
        end
    end)
    pcall(function()
        if M and M.MinionSheetModule then
            out.sheet = copyShallow(M.MinionSheetModule.nameplateCvarBackup)
        end
    end)
    pcall(function()
        local mdb = _G.MancerDB
        if mdb then
            -- persisted backup key unknown-stable: sweep top-level for it
            for k, v in pairs(mdb) do
                if type(k) == "string" and k:lower():find("cvar") then
                    out["MancerDB." .. k] = copyShallow(v)
                end
            end
            if mdb.minionDps then
                for k, v in pairs(mdb.minionDps) do
                    if type(k) == "string" and k:lower():find("cvar") then
                        out["MancerDB.minionDps." .. k] = copyShallow(v)
                    end
                end
            end
        end
    end)
    return out
end

D.RegisterTask{
    name = "cvarlog",
    mode = "session",
    help = "cvarlog - nameplate CVar flight recorder: baseline + every change w/ Mancer backup snapshots (st, repro, sp)",
    start = function(args)
        payload = D.Begin("cvarlog", args)
        last = readAll()
        payload.baseline = { t = GetTime(), values = copyShallow(last),
                             backups = mancerBackups() }
        payload.changes = {}

        local tick = CreateFrame("Frame")
        local acc = 0
        tick:SetScript("OnUpdate", function(_, dt)
            acc = acc + dt
            if acc < 0.5 then return end
            acc = 0
            if #payload.changes >= 500 then return end
            local ok = pcall(function()
                local now = readAll()
                for key, v in pairs(now) do
                    if v ~= last[key] then
                        payload.changes[#payload.changes + 1] = {
                            t = GetTime(), key = key, from = last[key], to = v,
                            backups = mancerBackups(),
                        }
                    end
                end
                last = now
            end)
            if not ok then payload.tick_errors = (payload.tick_errors or 0) + 1 end
        end)
        frames = { tick = tick }
        D.Print("cvarlog rolling - baseline captured; repro now, then /coadump sp")
    end,
    stop = function()
        if frames and frames.tick then frames.tick:SetScript("OnUpdate", nil) end
        payload.final = { t = GetTime(), values = readAll(), backups = mancerBackups() }
        D.Commit(("cvarlog: %d change(s) recorded, errors=%s")
            :format(#payload.changes, tostring(payload.tick_errors or 0)))
    end,
}
