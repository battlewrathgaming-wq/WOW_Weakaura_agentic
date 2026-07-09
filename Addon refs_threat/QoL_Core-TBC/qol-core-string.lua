qualityoflife = qualityoflife or {};
local q = qualityoflife;

function q:Println(str, moduleName)
    if str then
        if moduleName then
            print("[QoL] [" .. moduleName .. "] " .. str);
        else
            print("[QoL] " .. str);
        end
    end
end

function q:StartsWith(str, substr, caseInsensitive)
    if str then
        if substr and caseInsensitive then
            str = string.upper(str);
            substr = string.upper(substr);
        end

        return string.sub(str, 1, string.len(substr)) == substr;
    end
end

function q:EndsWith(str, substr, caseInsensitive)
    if str then
        if substr and caseInsensitive then
            str = string.upper(str);
            substr = string.upper(substr);
        end

        return substr == "" or str:sub(-#substr) == substr;
    end
end

function q:StringContains(str, match, caseInsensitive)
    if str then
        if match and caseInsensitive then
            str = string.upper(str);
            match = string.upper(match);
        end

        return string.find(str, "%" .. match);
    end
end

function q:Trim(str)
    if str then
        return str:gsub("^%s*(.-)%s*$", "%1");
    end
    return "";
end

function q:BoolToText(value, trueText, falseText)
    trueText = trueText or q:GetText(YES);
    falseText = falseText or q:GetText(NO);

    if value then
        return trueText;
    end
    return falseText;
end

function q:StringHash(text)
    if text then
        local counter = 1
        local len = string.len(text)
        for i = 1, len, 3 do
            counter = math.fmod(counter * 8161, 4294967279) + -- 2^32 - 17: Prime!
            (string.byte(text, i) * 16776193) + ((string.byte(text, i + 1) or (len - i + 256)) * 8372226) +
                          ((string.byte(text, i + 2) or (len - i + 256)) * 3932164)
        end
        return math.fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
    end
end
