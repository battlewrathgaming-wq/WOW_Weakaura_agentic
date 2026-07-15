-- task_probe.lua - one-shot reconnaissance walk of any named global frame.
-- The v1 `/coadump probe` rebuilt on the v2 envelope: same walker, same
-- field-list semantics, but the result is a single self-describing record
-- in the mailbox instead of an accumulating probes[] list.

local ADDON, D = ...

D.RegisterTask{
    name = "probe",
    mode = "oneshot",
    help = "probe <FrameName> [field1,field2,...] - walk a frame in _G, read table fields off every widget",
    run = function(args)
        local rootName, csv = (args or ""):match("^(%S*)%s*(.-)$")
        if not rootName or rootName == "" then
            D.Print("Usage: /coadump r probe <FrameName> [field1,field2,...]")
            return
        end
        local root = _G[rootName]
        if not root then
            D.Print("No frame named '" .. rootName .. "' in _G right now - is it on screen/loaded?")
            return
        end

        local fields = D.ParseFieldList(csv, D.DEFAULT_FIELDS)
        local payload = D.Begin("probe", args)
        payload.rootName = rootName
        payload.fields = fields
        payload.widgets = D.WalkFrameTree(root, 8, fields, {})
        D.Commit(("probe '%s': %d widget(s), fields: %s"):format(
            rootName, #payload.widgets, table.concat(fields, ",")))
    end,
}
