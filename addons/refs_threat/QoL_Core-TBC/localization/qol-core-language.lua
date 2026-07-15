qualityoflife = qualityoflife or {};
qualityoflife.localizations = qualityoflife.localizations or {};

-- locales
local LOCALE_GERMAN = "deDE";
local currentLocale = GetLocale();

function qualityoflife:GetText(key, ...)
	if qualityoflife.localizations[currentLocale] and qualityoflife.localizations[currentLocale][key] then
		return string.format(qualityoflife.localizations[currentLocale][key], ...);
	end
	return string.format(key, ...);
end