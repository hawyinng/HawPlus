--------------------------------------------------------------------------------------
--								WoW <System> Class									--
--------------------------------------------------------------------------------------
--	Mainly used as a container for sub classes except for a few info properties and --
--	enhanced Lua functions.															--
--------------------------------------------------------------------------------------
if (System) then
	return;
end

--UpValues
local tsort = table.sort;

local version = GetAddOnMetadata("HawPlus_classic", "Version");
local ipairsPool = {};
local isSystemLoaded = false;
local isVariablesLoaded = false;
local systemFrame = CreateFrame("Frame");
systemFrame:RegisterEvent("VARIABLES_LOADED");
systemFrame:SetScript("OnUpdate", function(self)
	if (isVariablesLoaded) then
		isSystemLoaded = true;
		systemFrame:Hide();
		System:OnLoad();
	end
end);
systemFrame:SetScript("OnEvent", function(self, event)
	isVariablesLoaded = true;
end);

local SystemClassDef = {
	Name = "System",
	Functions = {
		IPairs = {
			Desc = [[The emurator in place of "ipairs" with index sort]],
			Static = true,
			Func = function(tbl)
				if (type(tbl) ~= "table") then
					return nil;
				end
				wipe(ipairsPool);
				local i = 0;
				for i in pairs(tbl) do
					if (type(i) == "number") then
						tinsert(ipairsPool, i);
					end
				end
				tsort(ipairsPool);
				local poolCount = #ipairsPool;
				i = 0;
				return function()
					i = i + 1;
					if (i <= poolCount) then
						return ipairsPool[i], tbl[ipairsPool[i]];
					else
						return nil;
					end
				end;
			end,
		},
	},
	Properties = {
		Version = {
			Desc = [[Get the current version of the OOP System]],
			Get = function()
				return version;
			end,
			Type = String,
			Static = true,
		},
		IsLoaded = {
			Desc = [[Get the current version of the OOP System]],
			Get = function()
				return isSystemLoaded;
			end,
			Type = Boolean,
			Static = true,
		},
	},
	Events = {
		OnLoad = {
			Desc = [[Triggered when all addons finish loading]],
			Static = true,
		},
	},
};
System = newclass(SystemClassDef);
