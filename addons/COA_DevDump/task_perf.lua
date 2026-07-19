-- task_perf.lua - FPS / render-cost capture session (built for the SignalFire
-- collapse investigation, generic for any addon).
--
--   /coadump st perf [AddonName[,Addon2...]] [interval]
--   /coadump sp
--
-- Samples every `interval` seconds (default 1.0) while you play:
--   { t, fps, chatMsgsSinceLast, cpuMs-per-watched-addon..., memKB-per-watched-addon..., latencyHome, latencyWorld }
-- Chat volume rides along so FPS dips correlate against traffic bursts -
-- the exact axis of the SignalFire pain trace. Landed RAW; analysis offline.
--
-- CPU NUMBERS NEED THE PROFILER: `/console scriptProfile 1` + /reload BEFORE
-- starting, else GetAddOnCPUUsage returns 0 (the envelope stamps the cvar so
-- a zero column is never misread). Turn it off after (`scriptProfile 0`) -
-- profiling itself costs frames.
--
-- Default watched addon: SignalFire. Sample cap 2400 (~40min @ 1s).

local ADDON, D = ...

local ticker, collector, chatCount, payload, watched, interval

D.RegisterTask{
    name = "perf",
    mode = "session",
    help = "perf [Addon1,Addon2] [secs] - sample fps/cpu/mem/chat-rate per interval; needs scriptProfile 1 for cpu",
    start = function(args)
        local names, secs = (args or ""):match("^(%S*)%s*(%S*)")
        watched = {}
        for n in (names ~= "" and names or "SignalFire"):gmatch("[^,]+") do
            watched[#watched + 1] = n
        end
        interval = tonumber(secs) or 1.0

        payload = D.Begin("perf", args)
        payload.scriptProfile = GetCVar and GetCVar("scriptProfile") or "?"
        payload.watched = watched
        payload.interval = interval
        payload.samples = {}

        chatCount = 0
        collector = D.NewCollector(
            { "CHAT_MSG_CHANNEL", "CHAT_MSG_SAY", "CHAT_MSG_YELL" },
            function() chatCount = chatCount + 1 end)
        collector:Start()

        local acc = 0
        ticker = CreateFrame("Frame")
        ticker:SetScript("OnUpdate", function(_, dt)
            acc = acc + dt
            if acc < interval then return end
            acc = 0
            if #payload.samples >= 2400 then return end
            local row = { GetTime(), GetFramerate(), chatCount }
            chatCount = 0
            pcall(UpdateAddOnCPUUsage)
            pcall(UpdateAddOnMemoryUsage)
            for _, n in ipairs(watched) do
                local okC, c = pcall(GetAddOnCPUUsage, n)
                local okM, m = pcall(GetAddOnMemoryUsage, n)
                row[#row + 1] = okC and c or -1
                row[#row + 1] = okM and m or -1
            end
            local _, _, home, world = GetNetStats()
            row[#row + 1] = home
            row[#row + 1] = world
            payload.samples[#payload.samples + 1] = row
        end)
    end,
    stop = function()
        if ticker then ticker:SetScript("OnUpdate", nil) end
        if collector then collector:Stop() end
        local n = #payload.samples
        local minF, sumF = 9999, 0
        for _, r in ipairs(payload.samples) do
            if r[2] < minF then minF = r[2] end
            sumF = sumF + r[2]
        end
        D.Commit(("perf: %d samples @ %.1fs, fps min %.0f avg %.0f, profiler=%s")
            :format(n, interval, n > 0 and minF or 0, n > 0 and sumF / n or 0,
                    tostring(payload.scriptProfile)))
    end,
}
