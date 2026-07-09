-- scope stuff
qualityoflife = qualityoflife or {};
local q = qualityoflife;

q.modules = q.modules or {};
q.modules["QoL_ClassicThreat-TBC"] = q.modules["QoL_ClassicThreat-TBC"] or {};
local c = q.modules["QoL_ClassicThreat-TBC"];

-- function c:StartsWith(str, substr, caseInsensitive)
-- 	if caseInsensitive then
-- 		str = string.upper(str);
-- 		substr = string.upper(substr);
-- 	end

--    return string.sub(str, 1, string.len(substr)) == substr;
-- end

function c:Println(str)
    if str then
        q:Println(str, "ClassicThreat");
    end
end

function c:ShowResetDialog()
    local dialogName = c.name .. "_RESETDIALOG";
    StaticPopupDialogs[dialogName] = StaticPopupDialogs[dialogName] or {
        text = q:GetText("This will reset all ClassicThreat settings to defaults.\n\nAre you sure?"),
        button1 = q:GetText("Reset"),
        button2 = q:GetText("Cancel"),
        OnEscapePressed = function()
            self:Hide();
        end,
        OnAccept = function()
            QOL_OPTIONS[c.name] = {};
            c:InitOptions();
            c:ShowOptionsPanel();
            c:SaveSettingsChanges();
            c:ToggleBarFrame(true);
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    };
    StaticPopup_Show(dialogName);
end

function c:GetRaceIconName(unitId)
    local localizedClass, englishClass, classIndex = UnitClass(unitId);
    local raceName, raceFile, raceID = UnitRace(unitId);
    local genderCode, genderFile = UnitSex(unitId);
    if genderCode == 2 then
        genderFile = 1;
    else
        genderFile = 2;
    end
    if not raceFile then
        raceFile = "Human";
    end

    if not unitId or not UnitExists(unitId) then
        return "Interface\\Icons\\Inv_misc_questionmark"
    elseif UnitIsPlayer(unitId) and englishClass then
        if englishClass == "DEATHKNIGHT" then
            return "Interface\\Icons\\Spell_deathknight_classicon";
        end
        return "Interface\\Icons\\Classicon_" .. englishClass;
    else
        return "Interface\\Icons\\Inv_misc_head_" .. strlower(raceFile) .. "_0" .. genderFile;
    end
end
