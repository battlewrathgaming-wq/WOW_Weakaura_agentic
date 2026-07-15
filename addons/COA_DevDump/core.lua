-- COA_DevDump v2 - core: the capture spine.
--
-- The addon is a TASK RUNNER, not a collection of one-off dump commands.
-- Core owns the envelope, the SavedVariables mailbox, the walker/collector/
-- cycler libraries and the slash dispatcher; task files (task_*.lua) register
-- themselves against it and never touch each other or this file.
--
-- Driving it (shorthand spine - the things you type mid-session stay short):
--   /coadump r  <task> [args]   run a one-shot task
--   /coadump st <task> [args]   start a session task (listeners collect while you play)
--   /coadump sp                 stop the open session task
--   /coadump list               installed tasks + help lines
--   /coadump clear              wipe the mailbox
--
-- The mailbox rule: COA_DevDumpDB holds ONE envelope - the latest run only.
-- Every run REPLACES it. History and cross-run merging live in the repo
-- landing zone (addons/landing/), pulled off the flushed WTF file; the
-- header's runId is what the puller dedupes on. Accumulate in-game = baggage.
--
-- Chat is by-exception: a task prints ONE summary line on commit (plus its
-- own errors). Nothing streams to the chat window; the record is read
-- offline where it's greppable and permanent.
--
-- v1 (the talent/trainer/spellbook campaign tool that built coa_spells.json)
-- is deleted, not archived - git history keeps it; its proven patterns
-- (recursive widget walker, pcall-everything, tooltip GetSpell id-recovery)
-- live on as the libraries below.

local ADDON, D = ...

COA_DevDumpDB = COA_DevDumpDB or {}

D.VERSION = (GetAddOnMetadata and GetAddOnMetadata(ADDON, "Version")) or "2.0.0"

-- ---------------------------------------------------------------------
-- Small shared helpers
-- ---------------------------------------------------------------------

function D.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[COA_DevDump]|r " .. tostring(msg))
end

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end
D.Trim = trim

function D.ParseFieldList(csv, default)
    if not csv or trim(csv) == "" then return default end
    local fields = {}
    for field in csv:gmatch("[^,]+") do
        fields[#fields + 1] = trim(field)
    end
    return fields
end

-- ---------------------------------------------------------------------
-- The envelope (one run = one self-describing record)
-- ---------------------------------------------------------------------

-- Begin() replaces the whole mailbox with a fresh envelope and returns its
-- payload table for the task to fill. Commit() stamps it complete and prints
-- the task's one summary line.
function D.Begin(taskName, args)
    COA_DevDumpDB = {
        header = {
            tool = ADDON,
            version = D.VERSION,
            interface = 30300,
            task = taskName,
            args = args or "",
            runId = date("%Y%m%d_%H%M%S") .. "_" .. math.random(100, 999),
            char = UnitName("player"),
            class = select(2, UnitClass("player")),
            realm = GetRealmName(),
            startedAt = date("%Y-%m-%d %H:%M:%S"),
            status = "open",
        },
        payload = {},
    }
    return COA_DevDumpDB.payload
end

function D.Commit(summary)
    local h = COA_DevDumpDB.header
    if not h then
        D.Print("Commit with no open envelope - task bug, nothing written.")
        return
    end
    h.status = "complete"
    h.completedAt = date("%Y-%m-%d %H:%M:%S")
    h.summary = summary
    D.Print(summary .. " - /reload to flush.")
end

-- ---------------------------------------------------------------------
-- Task registry (task files call D.RegisterTask at load time)
-- ---------------------------------------------------------------------

D.tasks = {}

-- t = { name, help, mode = "oneshot"|"session",
--       run = fn(args)            (oneshot)
--       start = fn(args), stop = fn()   (session) }
function D.RegisterTask(t)
    D.tasks[t.name] = t
end

D.activeSession = nil -- name of the open session task, if any

-- ---------------------------------------------------------------------
-- Walker library - the v1 recursive widget walker, pcall-everything.
-- Reads plain Lua table fields off widgets (how CoA's custom frames stash
-- data); NOT a substitute for a real stock API where one exists.
-- ---------------------------------------------------------------------

D.DEFAULT_FIELDS = {
    "spellID", "spellId", "id", "talentID", "talentIndex", "tabIndex",
    "rank", "currentRank", "maxRank", "abilityID", "nodeID", "tier", "column",
    "unit", "slot", "index", "duration", "startTime",
}

function D.DescribeWidget(widget, fields)
    local entry = {
        name = (widget.GetName and widget:GetName()) or nil,
        objectType = (widget.GetObjectType and widget:GetObjectType()) or "?",
    }
    pcall(function() entry.widgetID = widget:GetID() end)
    pcall(function() entry.text = widget.GetText and widget:GetText() or nil end)
    pcall(function() entry.texture = widget.GetTexture and widget:GetTexture() or nil end)
    for _, field in ipairs(fields) do
        local ok, val = pcall(function() return widget[field] end)
        if ok and val ~= nil and type(val) ~= "function" and type(val) ~= "table" then
            entry["field_" .. field] = val
        end
    end
    return entry
end

local function walk(widget, depth, maxDepth, fields, out)
    if depth > maxDepth then return end
    local ok = pcall(function()
        local entry = D.DescribeWidget(widget, fields)
        entry.depth = depth
        out[#out + 1] = entry
        if widget.GetChildren then
            for _, child in ipairs({ widget:GetChildren() }) do
                walk(child, depth + 1, maxDepth, fields, out)
            end
        end
        if widget.GetRegions then
            for _, region in ipairs({ widget:GetRegions() }) do
                walk(region, depth + 1, maxDepth, fields, out)
            end
        end
    end)
    if not ok then
        out[#out + 1] = { depth = depth, name = "(error walking this widget)" }
    end
end

function D.WalkFrameTree(root, maxDepth, fields, out)
    walk(root, 0, maxDepth or 8, fields or D.DEFAULT_FIELDS, out)
    return out
end

-- ---------------------------------------------------------------------
-- Event collector - the session-task workhorse. Registers listeners,
-- hands every firing to the task's handler (pcall'd), counts rows.
-- The task just plays back what the game pushed; you keep playing.
-- ---------------------------------------------------------------------

function D.NewCollector(events, handler)
    local c = { frame = CreateFrame("Frame"), fired = 0, errors = 0 }
    c.frame:SetScript("OnEvent", function(self, event, ...)
        c.fired = c.fired + 1
        local ok = pcall(handler, event, ...)
        if not ok then c.errors = c.errors + 1 end
    end)
    function c:Start()
        for _, ev in ipairs(events) do
            pcall(function() c.frame:RegisterEvent(ev) end)
        end
    end
    function c:Stop()
        c.frame:UnregisterAllEvents()
    end
    return c
end

-- ---------------------------------------------------------------------
-- Cycler - chunked work across frames, so a big walk (the census) paces
-- itself instead of freezing the client. step(i) does one unit of work and
-- returns true when everything is done; perFrame units run per OnUpdate.
-- ---------------------------------------------------------------------

function D.Cycle(step, perFrame, onDone)
    local frame = CreateFrame("Frame")
    local i = 0
    frame:SetScript("OnUpdate", function(self)
        for _ = 1, (perFrame or 50) do
            i = i + 1
            local ok, done = pcall(step, i)
            if not ok or done then
                self:SetScript("OnUpdate", nil)
                if onDone then pcall(onDone, i, not ok) end
                return
            end
        end
    end)
    return frame
end

-- ---------------------------------------------------------------------
-- Slash dispatcher
-- ---------------------------------------------------------------------

local USAGE = "r <task> [args] | st <task> [args] | sp | list | clear"

local function taskNames()
    local names = {}
    for name in pairs(D.tasks) do names[#names + 1] = name end
    table.sort(names)
    return names
end

SLASH_COADEVDUMP1 = "/coadump"
SlashCmdList["COADEVDUMP"] = function(msg)
    local trimmed = trim(msg or "")
    local verb, rest = trimmed:match("^(%S*)%s*(.-)$")
    verb = (verb or ""):lower()

    if verb == "r" or verb == "run" then
        local name, args = rest:match("^(%S*)%s*(.-)$")
        local t = D.tasks[name]
        if not t or t.mode ~= "oneshot" then
            D.Print("No one-shot task '" .. tostring(name) .. "'. /coadump list")
            return
        end
        if D.activeSession then
            D.Print("Session '" .. D.activeSession .. "' is open (one envelope at a time) - /coadump sp first.")
            return
        end
        t.run(args)

    elseif verb == "st" or verb == "start" then
        local name, args = rest:match("^(%S*)%s*(.-)$")
        local t = D.tasks[name]
        if not t or t.mode ~= "session" then
            D.Print("No session task '" .. tostring(name) .. "'. /coadump list")
            return
        end
        if D.activeSession then
            D.Print("Session '" .. D.activeSession .. "' already open - /coadump sp first.")
            return
        end
        D.activeSession = name
        t.start(args)
        D.Print("Session '" .. name .. "' open - collecting. /coadump sp to stop.")

    elseif verb == "sp" or verb == "stop" then
        if not D.activeSession then
            D.Print("No session open.")
            return
        end
        local t = D.tasks[D.activeSession]
        D.activeSession = nil
        t.stop() -- the task commits; Commit prints the one summary line

    elseif verb == "list" then
        D.Print("Installed tasks (v" .. D.VERSION .. "):")
        for _, name in ipairs(taskNames()) do
            local t = D.tasks[name]
            D.Print("  " .. name .. " (" .. t.mode .. ") - " .. (t.help or ""))
        end

    elseif verb == "clear" then
        COA_DevDumpDB = {}
        D.Print("Mailbox cleared.")

    else
        D.Print("Usage: /coadump " .. USAGE)
    end
end
