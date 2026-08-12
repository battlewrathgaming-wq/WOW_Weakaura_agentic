-- task_dump.lua - /dump, but it LANDS ON DISK instead of on the screen.
--
-- Battlewrath, 2026-08-13: "Is there a way to capture /dump and such into COA so
-- it's written to disk rather than hand relayed? ... And it's worse than paste.
-- I have to hand transcribe."
--
-- That is mechanical work a machine should do, and hand transcription is the
-- worst version of it: slow, and it introduces errors into the ONE thing we were
-- reading the value for - accuracy. A contract written from a transcribed dump
-- has no provenance either; one written from a landed record does.
--
-- ---------------------------------------------------------------------------
-- SAME VOCABULARY AS THE CLIENT'S OWN /dump - no creator dialect.
-- ChatFrame.lua:2696 -> DevTools_DumpCommand, which evaluates:
--     local func, err = loadstring("return " .. msg)
--     DevTools_Dump({ func() }, "value")
-- We do exactly that. Anything you would type into /dump goes in here unchanged,
-- including function calls:
--     /coadump r dump AscensionUI.DeathRecap
--     /coadump r dump GetShapeshiftForm(), GetBonusBarOffset()
-- ---------------------------------------------------------------------------
--
-- THREE RULES THE SERIALISER HOLDS, and each exists because the alternative
-- produces a record that LIES:
--   1. NO SILENT CAPS. Depth, width and cycles are all recorded in the payload
--      at the point they bite. A truncated record that looks complete is worse
--      than no record - you would read a bound as a fact.
--   2. NOTHING IS DROPPED. Functions and userdata cannot go into SavedVariables,
--      so they are kept as type TAGS. A dropped key implies the field was not
--      there, which is the same trap as never collecting it.
--   3. NON-STRING KEYS ARE TAGGED, NOT DISCARDED. A table keyed by frames still
--      reports its shape.

local ADDON, D = ...

local MAX_DEPTH = 8      -- deep enough for a nested driver table
local MAX_KEYS  = 200    -- per table

-- Values SavedVariables can actually hold. Everything else becomes a tag so the
-- key survives with its type visible.
local function scalar(v)
    local t = type(v)
    if t == "string" or t == "number" or t == "boolean" then return v, true end
    if t == "function" then return "<function>", true end
    if t == "userdata" then return "<userdata>", true end
    if t == "thread"   then return "<thread>", true end
    if v == nil        then return "<nil>", true end
    return nil, false     -- a table: the caller recurses
end

-- A key that is not a string or number cannot round-trip through the SV writer.
local function keyFor(k)
    local t = type(k)
    if t == "string" or t == "number" then return k, false end
    return ("<%s key: %s>"):format(t, tostring(k)), true
end

local function serialise(v, depth, seen, notes, path)
    local flat, ok = scalar(v)
    if ok then return flat end

    -- Cycles. _G is full of them, and an unguarded walk hangs the client.
    if seen[v] then
        notes[#notes + 1] = ("cycle at %s -> already seen"):format(path)
        return "<cycle>"
    end
    if depth >= MAX_DEPTH then
        notes[#notes + 1] = ("depth cap %d reached at %s"):format(MAX_DEPTH, path)
        return "<max depth>"
    end

    seen[v] = true
    local out, n = {}, 0
    for k, val in pairs(v) do
        n = n + 1
        if n > MAX_KEYS then
            notes[#notes + 1] = ("width cap %d reached at %s - MORE KEYS EXIST"):format(MAX_KEYS, path)
            break
        end
        local key, tagged = keyFor(k)
        if tagged then
            notes[#notes + 1] = ("non-string key at %s: %s"):format(path, tostring(key))
        end
        out[key] = serialise(val, depth + 1, seen, notes, path .. "." .. tostring(key))
    end
    seen[v] = nil     -- siblings may legitimately share a table; only the PATH is a cycle
    return out
end

D.RegisterTask{
    name = "dump",
    mode = "oneshot",
    help = "dump <expression> - evaluate like /dump and land the value as a record",
    run = function(args)
        local expr = (args or ""):match("^%s*(.-)%s*$")
        if expr == "" then
            D.Print("Usage: /coadump r dump <expression>   e.g. AscensionUI.DeathRecap")
            return
        end

        local func, err = loadstring("return " .. expr)
        if not func then
            -- Fails LOUD and lands NOTHING. A record of a syntax error would be
            -- a record that looks like evidence about the game.
            D.Print("|cffff5555dump: cannot compile|r: " .. tostring(err))
            return
        end

        local results = { pcall(func) }
        local okCall = table.remove(results, 1)
        if not okCall then
            D.Print("|cffff5555dump: error while evaluating|r: " .. tostring(results[1]))
            return
        end

        local payload = D.Begin("dump", expr)
        payload.expression = expr
        payload.returnCount = #results
        payload.notes = {}
        payload.values = {}

        for i = 1, #results do
            payload.values[i] = serialise(results[i], 0, {}, payload.notes,
                                          ("value%d"):format(i))
        end

        -- The caps are part of the RESULT, not a log line that scrolls away.
        payload.limits = { maxDepth = MAX_DEPTH, maxKeys = MAX_KEYS }
        payload.truncated = (#payload.notes > 0)

        D.Commit(("dump '%s': %d value(s)%s"):format(
            expr, #results,
            payload.truncated and (", " .. #payload.notes .. " NOTE(S) - read payload.notes") or ""))
    end,
}
