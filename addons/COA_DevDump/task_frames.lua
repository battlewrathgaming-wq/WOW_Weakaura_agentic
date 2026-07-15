-- task_frames.lua - one-shot frame-stack snapshot at the mouse cursor.
-- The v1 `/coadump frames` rebuilt on the v2 envelope: one snapshot per run
-- (the mailbox rule), not an appended running log.

local ADDON, D = ...

D.RegisterTask{
    name = "frames",
    mode = "oneshot",
    help = "frames - snapshot every visible frame under the mouse cursor",
    run = function(args)
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        x, y = x / scale, y / scale

        local payload = D.Begin("frames", args)
        payload.cursorX, payload.cursorY = x, y
        payload.hits = {}

        local frame = EnumerateFrames()
        while frame do
            pcall(function()
                if frame.IsVisible and frame:IsVisible() and frame.GetRect then
                    local l, b, w, h = frame:GetRect()
                    if l and b and w and h and x >= l and x <= l + w and y >= b and y <= b + h then
                        local parent = frame.GetParent and frame:GetParent()
                        payload.hits[#payload.hits + 1] = {
                            name = (frame.GetName and frame:GetName()) or tostring(frame),
                            objectType = (frame.GetObjectType and frame:GetObjectType()) or "?",
                            strata = (frame.GetFrameStrata and frame:GetFrameStrata()) or "?",
                            level = frame.GetFrameLevel and frame:GetFrameLevel() or nil,
                            parent = parent and ((parent.GetName and parent:GetName()) or tostring(parent)) or nil,
                        }
                    end
                end
            end)
            frame = EnumerateFrames(frame)
        end

        D.Commit(("frames: %d frame(s) under the cursor"):format(#payload.hits))
    end,
}
