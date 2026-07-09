qualityoflife = qualityoflife or {};
local q = qualityoflife;

local defaultGravity = 1;
local defaultFriction = 1;
local defaultLifetime = 2;
local defaultSize = 1;
local defaultColor = {
	["r"] = 1,
	["g"] = 1,
	["b"] = 1,
	["a"] = 1
};

local sparks = {};
local function GetSpark(source)
	for id, spark in ipairs(sparks) do
		if not spark.busy then
			return spark;
		end
	end

	local newSpark = CreateFrame("Frame", "QOL_Spark" .. (table.getn(sparks) + 1), UIParent, BackdropTemplateMixin and "BackdropTemplate");
	newSpark:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"});

	tinsert(sparks, newSpark);
	return newSpark;
end

local function SparkBehaviour(spark, elapsed)
	spark.vx = spark.vx / spark.friction;
	spark.vy = spark.vy - (spark.g * elapsed);
	if spark.friction ~= 0 then
		spark.vy = spark.vy / spark.friction;
	end

	local point, relativeTo, relativePoint, xOfs, yOfs = spark:GetPoint();
	spark:ClearAllPoints();
	spark:SetPoint(point, relativeTo, relativePoint, xOfs + spark.vx, yOfs + spark.vy);
	spark:SetAlpha(spark:GetAlpha() - elapsed / spark.lifetime);

	if spark:GetAlpha() <= 0 then
		spark:SetScript("OnUpdate", nil);
		spark:Hide();
		spark.busy = false;
	end
end

function q:AddSpark(source)
	local spark = GetSpark(source);
	spark.source = source;
	spark.busy = true;
	spark.vx = math.random();
	if math.random() > 0.5 then
		spark.vx = -spark.vx;
	end
	spark.vy = math.random();

	local r, g, b, a;
	if source.properties.path[1]["rndColor"] then
		r = math.random();
		g = math.random();
		b = math.random();
		a = math.random();
	else
		r = source.properties.path[1]["r"] or defaultColor["r"];
		g = source.properties.path[1]["g"] or defaultColor["g"];
		b = source.properties.path[1]["b"] or defaultColor["b"];
		a = source.properties.path[1]["a"] or defaultColor["a"];
	end
	spark:SetBackdropColor(r, g, b, a);

	spark.g = source.properties.sparkGravity or defaultGravity;
	spark.friction = source.properties.sparkFriction or defaultFriction;
	spark.lifetime = source.properties.sparkLifetime or defaultLifetime;

	spark:SetWidth(source.properties.sparkSize or defaultSize);
	spark:SetHeight(source.properties.sparkSize or defaultSize);
	spark:SetAlpha(1);

	local point, relativeTo, relativePoint, xOfs, yOfs = source:GetPoint();
	spark:SetParent(source);
	spark:SetPoint("BOTTOMLEFT", relativeTo, "BOTTOMLEFT", xOfs, yOfs);

	spark:SetScript("OnUpdate", function(self, elapsed)
		SparkBehaviour(self, elapsed);
	end);
	spark:Show();
end