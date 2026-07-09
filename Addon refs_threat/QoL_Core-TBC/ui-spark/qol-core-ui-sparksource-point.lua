qualityoflife = qualityoflife or {};
local q = qualityoflife;

local defaultSpeed = 160;
local defaultSparkAmount = 5;
local defaultSparkFrequency = 0.01;

local function PreparePointSparkSourceSpeeds(source)
	source.properties.v = source.properties.path[1]["v"] or source.properties.v or defaultSpeed;
	if type(source.properties.v) == "table" and not source.properties.v["keys"] then
		local values, keys = q:Deepcopy(source.properties.v), {};
		for key in pairs(source.properties.v) do
			tinsert(keys, key);
		end
		table.sort(keys);

		source.properties.v = {
			["values"] = values,
			["keys"] = keys
		};
	end
end

local function SetPointSparkSourcePosition(source, parent, x, y)
	parent = parent or UIParent;
	x, y = x or 0, y or 0;
	source:ClearAllPoints();
	source:SetParent(parent);
	source:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", x, y);
end

local function NextPointSparkSourceWaypoint(source, initial)
	if not initial then
		if source.properties.path[1]["repeatAll"] then
			source.properties.path = q:Deepcopy(source.properties.pathCopy);
		elseif not source.properties.path[1]["repeat"] then
			table.remove(source.properties.path, 1);
		end
	end

	if table.getn(source.properties.path) > 0 then
		local point, relativeTo, relativePoint, xOfs, yOfs = source:GetPoint();

		if source.properties.path[1]["parent"] and _G[source.properties.path[1]["parent"]] then
			relativeTo = _G[source.properties.path[1]["parent"]];
		end
		xOfs = source.properties.path[1]["x"] or xOfs or GetScreenWidth() / 2;
		yOfs = source.properties.path[1]["y"] or yOfs or GetScreenHeight() / 2;
		SetPointSparkSourcePosition(source, relativeTo, xOfs, yOfs)

		local dx = source.properties.path[1]["tx"] or xOfs;
		local dy = source.properties.path[1]["ty"] or yOfs;
		local r = source.properties.path[1]["r"] or 0;
		local phi1 = source.properties.path[1]["phi1"] or 0;
		local phi2 = source.properties.path[1]["phi2"] or 0;
		source.properties.phi = phi2 - phi1;

		local txDist = q:MathRound(dx - xOfs, 2);
		local tyDist = q:MathRound(dy - yOfs, 2);
		local rDist = q:MathRound(r * source.properties.phi, 2);
		local maxDist = math.max(math.abs(txDist), math.abs(tyDist), math.abs(rDist));

		source.properties.distRatioX = txDist / maxDist;
		source.properties.distRatioY  = tyDist / maxDist;
		source.properties.distRatioW = rDist / maxDist;
		source.properties.maxDist = maxDist;
		source.properties.currentPhi = phi1 + math.pi / 2;
		source.properties.x, source.properties.y, source.properties.w = 0, 0, 0;
		source.properties.delayTime = 0;
		PreparePointSparkSourceSpeeds(source);

		source.properties.sparkFriction = source.properties.path[1]["sparkFriction"] or source.properties.sparkFriction;
		source.properties.sparkGravity = source.properties.path[1]["sparkGravity"] or source.properties.sparkGravity;
		source.properties.sparkFrequency = source.properties.path[1]["sparkFrequency"] or source.properties.sparkFrequency or defaultSparkFrequency;
		source.properties.sparkLifetime = source.properties.path[1]["sparkLifetime"] or source.properties.sparkLifetime;
		source.properties.sparkAmount = source.properties.path[1]["sparkAmount"] or source.properties.sparkAmount or defaultSparkAmount;
		source.properties.sparkSize = source.properties.path[1]["sparkSize"] or source.properties.sparkSize;

		if maxDist == math.abs(txDist) then
			source.properties.refDist = "x";
		elseif maxDist == math.abs(tyDist) then
			source.properties.refDist = "y";
		else
			source.properties.refDist = "w";
		end
	else
		q:HideSparkSource(source);
	end
end

local function GetPointSparkSourceSpeed(source)
	if type(source.properties.v) == "table" then
		local waypointPerc = source.properties[source.properties.refDist] / source.properties.maxDist;
		local lowPerc, highPerc;

		for _, key in ipairs(source.properties.v["keys"]) do
			if waypointPerc >= key then
				lowPerc = key;
			else
				highPerc = key;
				break;
			end
		end

		if lowPerc and highPerc then
			local stepDist, stepProgress = highPerc - lowPerc, waypointPerc - lowPerc;
			return q:MathLerp(source.properties.v["values"][lowPerc], source.properties.v["values"][highPerc], stepProgress / stepDist);
		elseif lowPerc then
			return source.properties.v["values"][lowPerc];
		end
	else
		return source.properties.v;
	end
end

local deviation = 0.01;
local function PointSparkSourceBehaviour(source, elapsed)
	if source.properties.path[1]["delayTime"] and (not source.properties.delayTime or source.properties.delayTime < source.properties.path[1]["delayTime"]) then
		source.properties.delayTime = source.properties.delayTime or 0;
		source.properties.delayTime = source.properties.delayTime + elapsed;
	else
		if (source.properties[source.properties.refDist] < source.properties.maxDist) then
			local point, relativeTo, relativePoint, xOfs, yOfs = source:GetPoint();
			local v = GetPointSparkSourceSpeed(source);
			local dx = v * source.properties.distRatioX * elapsed;
			local dy = v * source.properties.distRatioY * elapsed;
			local dr = v * source.properties.distRatioW * elapsed;
			local drX = dr * math.cos(source.properties.currentPhi);
			local drY = dr * math.sin(source.properties.currentPhi);
			SetPointSparkSourcePosition(source, relativeTo, xOfs + dx + drX, yOfs + dy + drY);

			source.properties.x = source.properties.x + math.abs(dx);
			source.properties.y = source.properties.y + math.abs(dy);
			if source.properties.phi ~= 0 then
				local adr = math.abs(dr);
				source.properties.x = source.properties.w + adr;
				source.currentPhi = source.currentPhi + source.properties.phi * (adr / source.properties.maxDist);
			end
		elseif source.properties.path[1]["restTime"] and (not source.properties.restTime or source.properties.restTime < source.properties.path[1]["restTime"]) then
			source.properties.restTime = source.properties.restTime or 0;
			source.properties.restTime = source.properties.restTime + elapsed;
		else
			NextPointSparkSourceWaypoint(source);
			return;
		end

		-- sparks
		source.properties.lastSpark = source.properties.lastSpark + elapsed
		if source.properties.lastSpark >= source.properties.sparkFrequency then
			for i = 1, source.properties.sparkAmount do
				q:AddSpark(source);
			end
			source.properties.lastSpark = 0;
		end
	end
end

function q:ShowPointSparkSource(path)
	if path and type(path) == "table" and table.getn(path) > 1 then
		local source = q:GetSparkSource();
		source.busy = true;
		source.propertiesCopy = q:Deepcopy(path);
		source.properties = source.properties or {};
		source.properties.path = q:Deepcopy(path);
		source.properties.lastSpark = 0;

		NextPointSparkSourceWaypoint(source, true);
		source:SetScript("OnUpdate", function(self, elapsed)
			PointSparkSourceBehaviour(self, elapsed);
		end);
		source:Show();

		return source;
	end
end

--qualityoflife:ShowPointSparkSource(qualityoflife:GetFrameOutlinePath(TargetFrame), true)
function q:GetFrameOutlinePath(frame, repeatSequence)
	return {
		{
			["parent"] = frame:GetName(),
			["x"] = 0,
			["y"] = 0,
		},
		{
			["tx"] = 0,
			["ty"] = frame:GetHeight()
		},
		{
			["tx"] = frame:GetWidth(),
			["ty"] = frame:GetHeight()
		},
		{
			["tx"] = frame:GetWidth(),
			["ty"] = 0
		},
		{
			["tx"] = 0,
			["ty"] = 0,
			["repeatAll"] = repeatSequence
		}
	};
end