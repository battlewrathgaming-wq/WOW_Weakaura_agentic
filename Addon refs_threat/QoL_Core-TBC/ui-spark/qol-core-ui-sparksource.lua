qualityoflife = qualityoflife or {};
local q = qualityoflife;

local sparkSources = {};
function q:GetSparkSource()
	for id, source in ipairs(sparkSources) do
		if not source.busy then
			return source;
		end
	end

	local newSource = CreateFrame("Frame", "QoL_SparkSource" .. (table.getn(sparkSources) + 1), UIParent);
	newSource:SetWidth(1);
	newSource:SetHeight(1);
	newSource:Show();

	tinsert(sparkSources, newSource);
	return newSource;
end

function q:HideAllSparkSources()
	q:HideSparkSources(sparkSources);
end

function q:HideSparkSources(t)
	for _, source in ipairs(t) do
		q:HideSparkSource(source);
	end
end

function q:HideSparkSource(source)
	source:SetScript("OnUpdate", nil);
	source:Hide();
	source.busy = false;
	source.properties = nil;
	source.propertiesCopy = nil;
end

-- parent

-- restTime
-- delayTime
-- repeatAll
-- repeatWaypoint

-- x
-- y

-- tx
-- ty
