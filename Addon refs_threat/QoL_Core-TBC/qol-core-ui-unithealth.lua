qualityoflife = qualityoflife or {};
local q = qualityoflife;

-- from Vexis, https://us.forums.blizzard.com/en/wow/t/targetfocus-frames-force-percentage-text/969507/2
local function ShouldKnowUnitHealth(unit)
    --	Note: Totems/Guardians/Etc are considered NPCs when it comes to health obfuscation
    local guid=UnitGUID(unit);
    local unittype=guid and guid:match("^(.-)%-");

    return	(unittype~="Player" and unittype~="Pet")--	Is NPC? (incl. totem/guardian/etc)
    or	(UnitIsUnit(unit,"player") or UnitIsUnit(unit,"pet"))--	Is player or player's pet?
    or	(UnitPlayerOrPetInRaid(unit) or UnitPlayerOrPetInParty(unit));--	Is in party/raid?
end

hooksecurefunc("UnitFrameHealthBar_Update",function(statusbar,unit)
	if QOL_OPTIONS[q.name][q.OPT_SHOWTARGETHEALTH]
        and statusbar
        and not statusbar.lockValues
        and unit == statusbar.unit
        and statusbar.showPercentage
        and ShouldKnowUnitHealth(unit) then
        statusbar.showPercentage = false;
        TextStatusBar_UpdateTextString(statusbar);
	end
end);