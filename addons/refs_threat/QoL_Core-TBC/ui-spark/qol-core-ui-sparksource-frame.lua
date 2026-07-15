qualityoflife = qualityoflife or {};
local q = qualityoflife;

local defaultSparks = 1;
local defaultSparkFrequency = 0.01;

local function SetFrameSparkSourcePosition(source, parent, x, y)
	parent = parent or UIParent;
	x, y = x or 0, y or 0;
	source:ClearAllPoints();
	source:SetParent(parent);
	source:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", x, y);
end

local deviation = 0.01;
local function FrameSparkSourceBehaviour(source, elapsed)
	if source.path[1]["delay"] and (not source.delay or source.delay < source.path[1]["delay"]) then
		source.delay = source.delay or 0;
		source.delay = source.delay + elapsed;
	else
		if (source[source.refDist] < source.maxDist) then
			local point, relativeTo, relativePoint, xOfs, yOfs = source:GetPoint();
			local v = GetPointSparkSourceSpeed(source);
			local dx = v * source.distRatioX * elapsed;
			local dy = v * source.distRatioY * elapsed;
			local dr = v * source.distRatioW * elapsed;
			local drX = dr * math.cos(source.currentPhi);
			local drY = dr * math.sin(source.currentPhi);
			SetPointSparkSourcePosition(source, relativeTo, xOfs + dx + drX, yOfs + dy + drY);

			source["X"] = source["X"] + math.abs(dx);
			source["Y"] = source["Y"] + math.abs(dy);
			if source.phi ~= 0 then
				local adr = math.abs(dr);
				source["W"] = source["W"] + adr;
				source.currentPhi = source.currentPhi + source.phi * (adr / source.maxDist);
			end
		elseif source.path[1]["rest"] and (not source.rest or source.rest < source.path[1]["rest"]) then
			source.rest = source.rest or 0;
			source.rest = source.rest + elapsed;
		else
			NextPointSparkSourceWaypoint(source);
			return;
		end

		-- sparks
		source.lastSpark = source.lastSpark + elapsed
		if source.lastSpark >= source.frequency then
			for i = 1, source.sparks do
				q:AddSpark(source);
			end
			source.lastSpark = 0;
		end
	end
end

function q:ShowFrameSparkSource(frame, properties)
	if frame and properties and type(properties) == "table" then
		local source = q:GetSparkSource();
		source.busy = true;
		source.pathCopy = q:Deepcopy(path);
		source.path = q:Deepcopy(path);

		source.lastSpark = 0;
		source.friction = nil;
		source.gravity = nil;
		source.frequency = nil;
		source.lifetime = nil;
		source.sparks = nil;
		source.size = nil;

		NextPointSparkSourceWaypoint(source, true);

		source:SetScript("OnUpdate", function(self, elapsed)
			PointSparkSourceBehaviour(self, elapsed);
		end);
		source:Show();

		return source;
	end
end