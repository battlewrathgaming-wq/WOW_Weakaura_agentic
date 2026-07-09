qualityoflife = qualityoflife or {};
local q = qualityoflife;

local frameCache = {};
local FRAME_REF = "FRAME_REF";
local FRAME_ORIGINAL_POINTS = "FRAME_ORIGINAL_POINTS";

local TRANSITION_IN_PROGRESS = "TRANSITION_IN_PROGRESS"
local TRANSITION_CANCELLED = "TRANSITION_CANCELLED"
local TRANSITION_FINISH_FUNC = "TRANSITION_FINISH_FUNC";

local TRANSITION_MOVE_TARGET_X = "TRANSITION_MOVE_TARGET_X";
local TRANSITION_MOVE_TARGET_Y = "TRANSITION_MOVE_TARGET_Y";
local TRANSITION_MOVE_SPEED = "TRANSITION_MOVE_SPEED";

local TRANSITION_RESIZE_TARGET_WIDTH = "TRANSITION_RESIZE_TARGET_WIDTH";
local TRANSITION_RESIZE_TARGET_HEIGHT = "TRANSITION_RESIZE_TARGET_HEIGHT";
local TRANSITION_RESIZE_SPEED = "TRANSITION_RESIZE_SPEED";

local maxD, defaultSpeed = 0.25, 10;

local function CheckFrameName(frame)
    return frame:GetName() and frame:GetName() ~= "";
end

local function AddFrame(frame)
    if not frameCache[frame:GetName()] then
        frameCache[frame:GetName()] = {};
        frameCache[frame:GetName()][FRAME_REF] = frame;
        frameCache[frame:GetName()][TRANSITION_CANCELLED] = false;
        frameCache[frame:GetName()][FRAME_ORIGINAL_POINTS] = {};
        for i = 1, frame:GetNumPoints() do
            local point, relativeTo, relativePoint, ox, oy = frame:GetPoint(i);
            tinsert(frameCache[frame:GetName()][FRAME_ORIGINAL_POINTS], { point, relativeTo, relativePoint, ox, oy });
        end
    end
    return frameCache[frame:GetName()];
end

function q:ResetFrame(frame)
    if frameCache[frame:GetName()] then
        frame:ClearAllPoints();
        for i, point in ipairs(frameCache[frame:GetName()][FRAME_ORIGINAL_POINTS]) do
            frame:SetPoint(unpack(point));
        end
        frameCache[frame:GetName()] = nil;
    end
end

function q:CancelTransition(frame)
    if frameCache[frame:GetName()] then
        frameCache[frame:GetName()][TRANSITION_CANCELLED] = true;
    end
end

local function Iterate(frame)
    local frameCacheRef = frameCache[frame:GetName()];
    if frameCacheRef[TRANSITION_CANCELLED] then
        q:ResetFrame(frame);
        return;
    elseif not frameCacheRef[TRANSITION_IN_PROGRESS] then
        return;
    end

    -- get current position
    local numPoints, currentPoints = frame:GetNumPoints(), {};
    for i = 1, numPoints do
        local point, relativeTo, relativePoint, ox, oy = frame:GetPoint(i);
        tinsert(currentPoints, { point, relativeTo, relativePoint, ox, oy });
    end

    local done = true;

    -- resize
    local targetWidth = frameCacheRef[TRANSITION_RESIZE_TARGET_WIDTH];
    local targetHeight = frameCacheRef[TRANSITION_RESIZE_TARGET_HEIGHT];
    local resizeSpeed = frameCacheRef[TRANSITION_RESIZE_SPEED];

    if targetWidth and targetHeight then
        local cw, ch = frame:GetWidth(), frame:GetHeight();
        local dw, dh = targetWidth - cw, targetHeight - ch;

        -- if difference is above threshold, then resize ...
        if math.abs(dw) > maxD then
            done = false;
            local tw = cw + dw * (resizeSpeed / 100);
            frame:SetWidth(tw);
        end
        if math.abs(dh) > maxD then
            done = false;
            local th = ch + dh * (resizeSpeed / 100);
            frame:SetHeight(th);
        end
    end

    -- move
    local targetX = frameCacheRef[TRANSITION_MOVE_TARGET_X];
    local targetY = frameCacheRef[TRANSITION_MOVE_TARGET_Y];
    local moveSpeed = frameCacheRef[TRANSITION_MOVE_SPEED];

    if targetX and targetY then
        frame:ClearAllPoints();
        for i = 1, numPoints do
            -- calculate distance
            local point, relativeTo, relativePoint, ox, oy = unpack(currentPoints[i]);
            local dx, dy = targetX - ox, targetY - oy;

            -- if difference is above threshold, then move ...
            if math.abs(dx) > maxD or math.abs(dy) > maxD then
                done = false;
                local tx = ox + dx * (moveSpeed / 100);
                local ty = oy + dy * (moveSpeed / 100);
                frame:SetPoint(point, relativeTo, relativePoint, tx, ty);
            else
                frame:SetPoint(point, relativeTo, relativePoint, ox, oy);
            end
        end
    end
    -- ... and continue recursively
    if done then
        frameCacheRef[TRANSITION_IN_PROGRESS] = false;
        if frameCacheRef[TRANSITION_FINISH_FUNC] then
            frameCacheRef[TRANSITION_FINISH_FUNC]();
        end
    else
        C_Timer.After(0.01, function ()
            Iterate(frame);
        end);
    end
end

function q:TransitionMove(frame, targetX, targetY, speed, finishFunc)
    if not CheckFrameName(frame) then
        error("Attempt to transition-move anonymous frame cancelled.");
    end

    local frameCacheRef = AddFrame(frame);
    frameCacheRef[TRANSITION_MOVE_TARGET_X] = targetX;
    frameCacheRef[TRANSITION_MOVE_TARGET_Y] = targetY;
    frameCacheRef[TRANSITION_MOVE_SPEED] = speed or defaultSpeed;
    frameCacheRef[TRANSITION_FINISH_FUNC] = finishFunc;

    if not frameCacheRef[TRANSITION_IN_PROGRESS] then
        frameCacheRef[TRANSITION_IN_PROGRESS] = true;
        Iterate(frame);
    end
end

function q:TransitionResize(frame, targetWidth, targetHeight, speed, finishFunc)
    if not CheckFrameName(frame) then
        error("Attempt to transition-size anonymous frame cancelled.");
    end

    local frameCacheRef = AddFrame(frame);
    frameCacheRef[TRANSITION_RESIZE_TARGET_WIDTH] = targetWidth;
    frameCacheRef[TRANSITION_RESIZE_TARGET_HEIGHT] = targetHeight;
    frameCacheRef[TRANSITION_RESIZE_SPEED] = speed or defaultSpeed;
    frameCacheRef[TRANSITION_FINISH_FUNC] = finishFunc;

    if not frameCacheRef[TRANSITION_IN_PROGRESS] then
        frameCacheRef[TRANSITION_IN_PROGRESS] = true;
        Iterate(frame);
    end
end