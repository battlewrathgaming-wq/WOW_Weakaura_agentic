-- framexml.lua - RUN the client's own FrameXML Lua in the offline harness (A10.1c, P1).
--
-- ★★★ WHY RUN IT RATHER THAN STUB IT. `AceConfigDialog:Open` reaches TabGroup and calls
-- `PanelTemplates_TabResize`. We could write our own. Ours would be right until
-- Blizzard's arithmetic and ours disagree, with nothing to notice when they do - the
-- creator-dialect trap, and the harness exists to be MORE trustworthy than the code it
-- checks, not less.
--
-- ★★ SO THIS IS THE SAME MOVE AS THE TEMPLATES, ONE LAYER UP. `read_templates.py` gave
-- the harness Blizzard's frame DEFINITIONS; this gives it Blizzard's frame CODE. Both
-- are read from the MPQ chain by `addons/tools/read_framexml_lua.py`, in the client's
-- own load order, taken from the client's own `FrameXML.toc`.
--
-- ⚠⚠ IT REPORTS EVERY FILE THAT DID NOT RUN, AND WHY (A10.1c / bench U6 (c)): loaded
-- whole, stubs only where a file will not run, and **every function a failed file would
-- have provided is named**. A blind spot from a stubbed Blizzard function is the same
-- class as a blind spot from a text metric, and belongs in the same list.
--
-- ★ IT NEVER ASSERTS. A red here is news about the harness's reach.
--
--   local FX = assert(loadfile("framexml.lua"))()
--   local stats = FX.Load()          -- after CreateFrame/UIParent exist
--   FX.Report(stats)

local FX = {}

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\addons\staging\]]
local MANIFEST = ROOT .. "framexml_lua_manifest.txt"
local BASE = ROOT .. "framexml_lua\\"

local function firstline(e) return (tostring(e):gsub("[\r\n].*", "")) end

-- ⚠ The names a file would have PROVIDED, so a failure says what is now missing rather
-- than only that something failed. Source-scanned, deliberately crude: this is a
-- shopping list for the miss recorder to confirm, never a claim that all of them matter.
local function provides(text)
    local out = {}
    for name in text:gmatch("\nfunction%s+([%w_]+)%s*%(") do out[#out + 1] = name end
    return out
end

-- ★★★ THE DECLARED STUBS - named, reported, and each one a MODELLING CHOICE stated out
-- loud rather than a convenience.
--
-- ⚠⚠ THIS CLIENT'S LibStub IS FORK-NATIVE: `Interface\FrameXML\LibStub.lua`, marked
-- *"Version 3 = Ascension Exclusive"*. It is not upstream's. `NewLibrary` and
-- `GetLibrary` both call `LoadLibrary(major)` when `IsLibraryLoaded(major)` is false -
-- so THE CLIENT CAN SERVE A LIBRARY FROM ITS OWN STORE - and `NewAscensionLibrary`
-- sets `minors[major] = math.huge`, after which an addon's own copy of that library is
-- refused forever. Both globals are real here (our `_G` census) and are called by
-- nothing but this file.
--
-- ★ THE STUB BELOW MODELS "ASCENSION SERVES NOTHING", which makes the client's LibStub
-- behave like upstream's. That is the OPTIMISTIC case and it is a choice, not a
-- neutral default: if Ascension does serve `AceGUI-3.0`, our shipped copy is the one
-- that gets refused, and the offline harness would never see it. **Only the client can
-- answer that.**
local STUBS = {
    IsLibraryLoaded = { fn = function() return false end,
        why = "Ascension-native; false models 'the client serves nothing' - the "
           .. "OPTIMISTIC case, and the one the client must confirm" },
    LoadLibrary = { fn = function() return nil end,
        why = "Ascension-native; a no-op follows from IsLibraryLoaded being false" },
}

function FX.Stubs()
    local out = {}
    for k, v in pairs(STUBS) do out[#out + 1] = { k, v.why } end
    table.sort(out, function(a, b) return a[1] < b[1] end)
    return out
end

function FX.Load()
    local stats = { ran = 0, files = 0, failed = {}, unprovided = {}, absent = 0 }

    -- ⚠ Installed only where the harness has nothing. A stub that overwrote a real
    -- implementation would be the harness lying to itself.
    for name, s in pairs(STUBS) do
        if rawget(_G, name) == nil then rawset(_G, name, s.fn) end
    end

    local mf = io.open(MANIFEST, "r")
    if not mf then
        stats.manifest = "absent"
        return stats
    end
    stats.manifest = "read"

    for line in mf:lines() do
        local path = line:match("^%s*(.-)%s*$")
        if path ~= "" and path:sub(1, 1) ~= "#" then
            stats.files = stats.files + 1
            local full = BASE .. path
            local fh = io.open(full, "r")
            if not fh then
                stats.absent = stats.absent + 1
            else
                local text = fh:read("*a"); fh:close()
                local chunk, err = loadstring(text, "@" .. path)
                if not chunk then
                    stats.failed[#stats.failed + 1] = { path, "PARSE: " .. firstline(err) }
                    for _, n in ipairs(provides(text)) do
                        stats.unprovided[#stats.unprovided + 1] = n
                    end
                else
                    -- ⚠ pcall, and the run CONTINUES. One file that dies must not take the
                    -- 139 after it - the client itself carries files it cannot load
                    -- (`FrameXML.log`: "Error loading Interface\SharedXML\Logging.lua"),
                    -- so a chain that stops at the first casualty would model a client
                    -- that does not exist.
                    local ok, rerr = pcall(chunk)
                    if ok then
                        stats.ran = stats.ran + 1
                    else
                        stats.failed[#stats.failed + 1] = { path, "RUN: " .. firstline(rerr) }
                        for _, n in ipairs(provides(text)) do
                            stats.unprovided[#stats.unprovided + 1] = n
                        end
                    end
                end
            end
        end
    end
    mf:close()
    table.sort(stats.unprovided)
    return stats
end

-- ★ WHICH OF THE UNPROVIDED NAMES ARE ACTUALLY ABSENT FROM `_G`. A file can fail after
-- defining the function we wanted, and another file may define the same name. So the
-- shopping list is filtered against reality rather than reported raw.
function FX.StillMissing(stats)
    local out, seen = {}, {}
    for _, n in ipairs(stats.unprovided or {}) do
        if not seen[n] and rawget(_G, n) == nil then
            seen[n] = true
            out[#out + 1] = n
        end
    end
    table.sort(out)
    return out
end

function FX.Report(stats, verbose)
    if stats.manifest == "absent" then
        print("  framexml: no manifest - run addons/tools/read_framexml_lua.py")
        return
    end
    print(("  framexml: %d/%d ran, %d failed, %d absent")
          :format(stats.ran, stats.files, #stats.failed, stats.absent))
    local stubs = FX.Stubs()
    print(("    %d Blizzard/Ascension function(s) STUBBED - each is a blind spot of the "
           .. "same class as a text metric (A10.1c)"):format(#stubs))
    for _, s in ipairs(stubs) do print(("      %-18s %s"):format(s[1], s[2])) end
    if verbose then
        for _, f in ipairs(stats.failed) do
            print(("    x %-46s %s"):format(f[1], f[2]))
        end
    end
    local missing = FX.StillMissing(stats)
    print(("    %d function(s) a failed file would have provided are still absent from _G")
          :format(#missing))
    if verbose and #missing > 0 then
        local line = "      "
        for i, m in ipairs(missing) do
            line = line .. m .. (i < #missing and ", " or "")
            if #line > 84 then print(line); line = "      " end
        end
        if line ~= "      " then print(line) end
    end
end

return FX
