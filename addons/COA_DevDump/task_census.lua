-- task_census.lua - the runtime client-surface census: the definitive _G walk.
-- Pass 3 of the census (addons/maps/census/ holds the declared pass): confirms
-- what the shipped code attests AND catches C-side surface no UI file calls.
--
-- Shape: snapshot every string key of _G (one tight pass), then CYCLE the
-- classification across frames (400 keys/frame - no client freeze). Every
-- global lands as name -> kind ("function"/"table"/"widget:<ObjectType>"/
-- "string"/"number"/...); every C_* table additionally gets a one-level
-- member expansion (member -> type). Reduction/diff vs the baseline happens
-- OFFLINE on the landed record - this task stays a dumb, broad capture.

local ADDON, D = ...

local function kindOf(v)
    local t = type(v)
    if t == "table" then
        local ok, ot = pcall(function()
            return v.GetObjectType and v:GetObjectType()
        end)
        if ok and ot then return "widget:" .. tostring(ot) end
        return "table"
    end
    return t
end

D.RegisterTask{
    name = "census",
    mode = "oneshot",
    help = "census - full _G walk (every global's kind + one-level C_* expansion), self-cycling",
    run = function(args)
        local payload = D.Begin("census", args)

        local keys = {}
        for k in pairs(_G) do
            if type(k) == "string" then keys[#keys + 1] = k end
        end
        table.sort(keys) -- deterministic record order

        payload.total = #keys
        payload.kinds = {}
        payload.ns = {}

        D.Cycle(function(i)
            local k = keys[i]
            if not k then return true end
            local ok, v = pcall(function() return _G[k] end)
            if ok and v ~= nil then
                local kind = kindOf(v)
                payload.kinds[k] = kind
                if kind == "table" and k:sub(1, 2) == "C_" then
                    local members = {}
                    pcall(function()
                        for mk, mv in pairs(v) do
                            if type(mk) == "string" then
                                members[mk] = type(mv)
                            end
                        end
                    end)
                    payload.ns[k] = members
                end
            end
            return false
        end, 400, function()
            local fn, tb, wd, nsn = 0, 0, 0, 0
            for _, kind in pairs(payload.kinds) do
                if kind == "function" then fn = fn + 1
                elseif kind == "table" then tb = tb + 1
                elseif kind:sub(1, 7) == "widget:" then wd = wd + 1 end
            end
            for _ in pairs(payload.ns) do nsn = nsn + 1 end
            payload.functions, payload.tables, payload.widgets, payload.namespaces = fn, tb, wd, nsn
            D.Commit(("census: %d globals (%d functions / %d tables / %d widgets), %d C_* namespaces expanded")
                :format(payload.total, fn, tb, wd, nsn))
        end)

        D.Print("census: walking " .. #keys .. " globals (cycled - summary line follows in a few seconds)...")
    end,
}
