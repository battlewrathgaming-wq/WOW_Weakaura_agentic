-- task_frames.lua - one-shot frame-stack snapshot at the mouse cursor.
-- The v1 `/coadump frames` rebuilt on the v2 envelope: one snapshot per run
-- (the mailbox rule), not an appended running log.
--
-- v2.1: grew a FIELD LIST (`frames [field1,field2,...]`, default =
-- core's DEFAULT_FIELDS) - every hit is described with the walker's field
-- reader, so mouse-over-and-fire doubles as the ANONYMOUS-frame probe.
-- Motivating case: this fork's backported nameplates carry no GetName
-- (probe can't root on them), but their UnitFrame children stash `unit`/
-- `displayedUnit` as plain fields - a cursor hit + field read hands over
-- the plate's unit token directly (record 20260715_190433_704 staged it).

local ADDON, D = ...

D.RegisterTask{
    name = "frames",
    mode = "oneshot",
    help = "frames [field1,field2,...] - snapshot every visible frame under the cursor, reading fields off each hit",
    run = function(args)
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        x, y = x / scale, y / scale

        local fields = D.ParseFieldList(args, D.DEFAULT_FIELDS)
        local payload = D.Begin("frames", args)
        payload.cursorX, payload.cursorY = x, y
        payload.fields = fields
        payload.hits = {}

        local frame = EnumerateFrames()
        while frame do
            pcall(function()
                if frame.IsVisible and frame:IsVisible() and frame.GetRect then
                    local l, b, w, h = frame:GetRect()
                    if l and b and w and h and x >= l and x <= l + w and y >= b and y <= b + h then
                        local entry = D.DescribeWidget(frame, fields)
                        -- anonymous frames (this fork's nameplates) have no name;
                        -- keep the table address so hits stay distinguishable
                        entry.addr = tostring(frame)
                        entry.strata = (frame.GetFrameStrata and frame:GetFrameStrata()) or "?"
                        entry.level = frame.GetFrameLevel and frame:GetFrameLevel() or nil
                        local parent = frame.GetParent and frame:GetParent()
                        entry.parent = parent and ((parent.GetName and parent:GetName()) or tostring(parent)) or nil
                        payload.hits[#payload.hits + 1] = entry
                    end
                end
            end)
            frame = EnumerateFrames(frame)
        end

        D.Commit(("frames: %d frame(s) under the cursor (fields: %s)")
            :format(#payload.hits, table.concat(fields, ",")))
    end,
}
