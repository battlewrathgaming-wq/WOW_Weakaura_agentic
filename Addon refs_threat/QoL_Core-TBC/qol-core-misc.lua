qualityoflife = qualityoflife or {};
local q = qualityoflife;

-- table functions

function q:GetTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end

function q:GetSortedTableKeys(t, descending)
    if t then
        local keys = {};
        for k, _ in pairs(t) do
            local num = tonumber(k);
            if num then
                table.insert(keys, num);
            else
                table.insert(keys, k);
            end
        end
        if descending then
            table.sort(keys, function(a, b)
                return a > b
            end); -- descending
        else
            table.sort(keys);
        end
        return keys;
    end
end

-- /run qualityoflife:DumpTable()
function q:DumpTable(t, key)
    -- trivial debug function
    if t then
        if type(t) == "table" then
            for k, v in pairs(t) do
                q:DumpTable(v, k);
            end
        elseif key then
            print(key .. "->", t);
        else
            print(t);
        end
    end
end

function q:TableIsArray(t)
    return t[1] and q:GetTableSize(t) == table.getn(t);
end

function q:IsNumeric(value)
    if not value then
        return false;
    end
    local t = type(value);
    if t == "number" then
        return true;
    elseif t ~= "string" then
        return false;
    end
    return value == tostring(tonumber(value));
end

function q:TableContains(t, value, caseInsensitive)
    if caseInsensitive then
        value = string.upper(value);
    end

    if q:TableIsArray(t) then
        for k, v in ipairs(t) do
            if (not caseInsensitive and v == value) or (caseInsensitive and string.upper(v) == value) then
                return v;
            end
        end
    else
        for k, v in pairs(t) do
            if (not caseInsensitive and v == value) or (caseInsensitive and string.upper(v) == value) then
                return v;
            end
        end
    end
end

function q:GetTableEntryByIndex(t, index)
    if q:TableIsArray(t) then
        return t[index];
    else
        local i = 0;
        for k, v in pairs(t) do
            if (i == index) then
                return v;
            end
            i = i + 1;
        end
    end
end

-- other/general functions

--- Creates and returns a deep copy of the given [orig] object. Beware: Don't use second parameter [copies] - it is for recursion only.
---@param orig any
---@param copies nil
---@return any
function q:Deepcopy(orig, copies)
    copies = copies or {};
    local orig_type, copy = type(orig);
    if orig_type == "table" then
        if copies[orig] then
            copy = copies[orig];
        else
            copy = {};
            copies[orig] = copy;
            setmetatable(copy, q:Deepcopy(getmetatable(orig), copies));
            for orig_key, orig_value in next, orig, nil do
                copy[q:Deepcopy(orig_key, copies)] = q:Deepcopy(orig_value, copies);
            end
        end
    else
        copy = orig;
    end
    return copy;
end

--- Returns r, g, b, a values for given colorTable.
---@param colorTable table
---@return number @four consecutive numbers
function q:GetColorRBGA(colorTable)
    if colorTable then
        return colorTable["r"], colorTable["g"], colorTable["b"], colorTable["a"];
    end
end

--- Returns hex RGBA color for given [colorTable] or r=[colorTable], [g], [b], [a].
---@param colorTable table|number
---@param g number
---@param b number
---@param a number
---@return string
function q:GetColorHexFromRGBA(colorTable, g, b, a)
    local r;
    if g and b then
        r = colorTable;
    else
        r, g, b = q:GetColorRBGA(colorTable);
    end
    a = a or 1;

    -- hint: alpha is ignored by blizzards "|c"
    return string.format("%02x", a * 255) .. string.format("%02x", r * 255) .. string.format("%02x", g * 255) ..
               string.format("%02x", b * 255);
end

--- Converts and returns [hex] ARGB to RGBA.
---@param hex string
---@return string
function q:HexARGBtoRGBA(hex)
    return strsub(hex, 3) .. strsub(hex, 1, 2);
end

--- Returns r, g, b (0-1) color for given [unitId]s class.
---@param unitId string
---@return number @three consecutive numbers
function q:GetClassColorRGB(unitId)
    local r, g, b, hex = GetClassColor(select(2, UnitClass(unitId)));
    return r, g, b;
end

--- Returns hex RGB color for given [unitId]s class.
---@param unitId string
---@return string
function q:GetClassColorHex(unitId)
    local r, g, b, hex = GetClassColor(select(2, UnitClass(unitId)));
    return strsub(hex, 3);
end

--- Returns a coloured [text] using Blizzards |c operator. Provide [colorHex] as RGB or RGBA hex value. Alpha channel will be omitted.
---@param text string
---@param colorHex string
---@return string
function q:FormatTextWithColor(text, colorHex)
    return string.format("|cff%s%s|r", colorHex, text);
end

function q:HandleElvUi(frame, additionalActions)
    if ElvUI and frame and frame.frameType then
        local E, L, V, P, G = unpack(ElvUI);
        local elv = E:GetModule('Skins');

        if frame.frameType == "Frame" then
            elv:HandleFrame(frame);
        elseif frame.frameType == "DropDown" then
            elv:HandleDropDownBox(frame);
        elseif frame.frameType == "Button" then
            elv:HandleButton(frame);
        elseif frame.frameType == "CheckButton" then
            elv:HandleCheckBox(frame);
        elseif frame.frameType == "Slider" then
            elv:HandleSliderFrame(frame);
        elseif frame.frameType == "EditBox" then
            elv:HandleEditBox(frame);
        else
            return;
        end

        if additionalActions then
            additionalActions(frame);
        end
    end
end

function q:RemoveRealmFromName(name)
    if name then
        local dashPos = strfind(name, "-");
        if dashPos then
            name = strsub(name, 1, dashPos - 1);
        end

        local spacePos = strfind(name, " ");
        if spacePos then
            name = strsub(name, 1, spacePos - 1);
        end

        return name;
    end
end

function q:RegisterDoubleClick(frame, func, button)
    frame.clicks = 0;
    frame:SetScript("OnMouseDown", function(self, btn)
        if not button or button == btn then
            self.clicks = self.clicks + 1;
            C_Timer.After(0.35, function()
                self.clicks = 0;
            end);
            if self.clicks == 2 then
                func();
                self.clicks = 0;
            end
        end
    end);
end

function q:DumpFrames(containsTextInName)
    local frame = EnumerateFrames();
    while frame do
        if frame:IsVisible() and (not containsTextInName or c:StringContains(frame:GetName(), containsTextInName, true)) then
            DEFAULT_CHAT_FRAME:AddMessage(frame:GetName());
        end
        frame = EnumerateFrames(frame);
    end
end
