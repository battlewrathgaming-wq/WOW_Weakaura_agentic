qualityoflife = qualityoflife or {};
local q = qualityoflife;

--- Returns 1 for positive numbers and -1 for negative numbers x.
---@param x number
---@return number
function q:MathSign(x)
    if x < 0 then
        return -1;
    elseif x > 0 then
        return 1;
    else
        return 0;
    end
end

--- Linearly interpolates [perc] between [pos1] and [pos2].
---@param pos1 number
---@param pos2 number
---@param perc number
---@return number
function q:MathLerp(pos1, pos2, perc)
    return (1 - perc) * pos1 + perc * pos2;
end

--- Rounds [x] by [decimals] decimal places using the lua string.format() method.
---@param x number
---@param decimals number
---@return number
function q:StrRound(x, decimals)
    decimals = decimals or 0;
    return tonumber(string.format("%." .. decimals .. "f", x));
end

--- Rounds [x] by [decimals] decimal places mathematically.
---@param x number
---@param decimals number
---@return number
function q:MathRound(x, decimals)
    if decimals and decimals > 0 then
        local mult = 10 ^ decimals
        return math.floor(x * mult + 0.5) / mult
    end
    return math.floor(x + 0.5);
end

--- Clamps [num] betwween [min] and [max].
---@param num number
---@param min number
---@param max number
---@return number
function q:MathClamp(num, min, max)
    if num > max then
        return max;
    elseif num < min then
        return min;
    else
        return num;
    end
end