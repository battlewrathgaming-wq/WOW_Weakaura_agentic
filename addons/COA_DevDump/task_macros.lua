-- task_macros.lua - land the macro-conditional probe (macros/probe/ASK.md) RAW.
--
-- The payload is the MACROS bench's (probe_core.lua, wrapped verbatim by
-- addons/tools/wrap_payload.py -> payload_macros.lua). This task only runs it
-- and lands what it returns - no reshaping, no summarising, NO VERDICTS
-- (the ask's one request: verdicts derive offline in a map, so a wrong matrix
-- costs a re-derivation, never another client session).
--
-- Envelope layout: payload.record = the probe's return VERBATIM
-- (schema macros.probe.raw/1); payload.harness = the wrapper's provenance
-- (source path + sha256), kept OUTSIDE the record so the raw stays raw.
--
-- Two passes in different contexts (idle vs in-combat/mounted/form) separate
-- "false here" from "always false" - each run is its own envelope; /reload
-- between them (the mailbox holds ONE run).

local ADDON, D = ...

D.RegisterTask{
    name = "macros",
    mode = "oneshot",
    help = "macros - the macro-conditional probe (pure reads, ~200 calls, lands RAW; /reload between passes)",
    run = function(args)
        local probe = D.payloads and D.payloads["macros"]
        if not probe then
            D.Print("payload_macros.lua not loaded - regenerate via wrap_payload.py and redeploy.")
            return
        end

        local payload = D.Begin("macros", args)
        local ok, record = pcall(probe)
        if not ok then
            payload.harness = D.payloadMeta["macros"]
            payload.error = tostring(record)
            D.Commit("macros probe ERRORED (raw error landed): " .. tostring(record))
            return
        end

        payload.record = record
        payload.harness = D.payloadMeta["macros"]

        local nf, nt = 0, 0
        for _ in pairs(record.flags or {}) do nf = nf + 1 end
        for _ in pairs(record.targets or {}) do nt = nt + 1 end
        D.Commit(("macros probe: %s | %d flag pairs, %d targets, control target=%s | inCombat=%s")
            :format(tostring(record.schema), nf, nt,
                    tostring(record.control and record.control.target),
                    tostring(record.context and record.context.inCombat)))
    end,
}
