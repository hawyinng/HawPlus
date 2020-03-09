--------------------------------------------------------------------------------------
--							  WoW <System.WTF> Class								--
--------------------------------------------------------------------------------------
--	Provide a WTF class to manage the WTF info for addons							--
--------------------------------------------------------------------------------------
if(System.WTF) then
	return;
end

local function GetCharName()
	local playerName = UnitName("player");
	local realmName = GetRealmName();
	if (type(playerName) == "string" and type(realmName) == "string") then
		return playerName .. "(" .. realmName .. ")";
	else
		return nil;
	end
end

local isWTFLoaded = false;
local WTFArchivesList = {};
local function GetWTF(name)
	if (not isWTFLoaded) then
		return nil;
	end
	WTFArchives = WTFArchives or {};
	if (type(name) == "string") then
		if (type(WTFArchives[name]) ~= "table") then
			WTFArchives[name] = {};
			WTFArchives[name].GLOBAL = {};
			WTFArchives[name].CHARS = {};
		end
		return WTFArchives[name];
	else
		return nil;
	end
end

local WTFLoadedEvent = System.Event("VARIABLES_LOADED");
WTFLoadedEvent.OnTriggered = function(self)
	isWTFLoaded = true;
	WTFArchives = WTFArchives or {};
	for k, v in pairs(WTFArchives) do
		if (type(v) == "table" and v.GLOBAL and v.CHARS) then
			WTFArchivesList[k] = true;
		end
	end
	System.WTF:OnLoad();
end;

local SystemWTFClassDef = {
	Name = "System.WTF",
	Functions = {
		DeleteArchive = {
			Static = true,
			Desc = [[Delete the dedicated WTF Archive]],
			Func = function(self, name)
				if (not self:ArchiveExists(name)) then
					return false, "NOT EXIST";
				end
				local rawData = GetWTF(name);
				wipe(rawData);
				WTFArchives[name] = nil;
				WTFArchivesList[name] = nil;
				return true;
			end,
		},
		EnumerateArchives = {
			Static = true,
			Desc = [[Enumerate all registered WTF Archives]],
			Func = function(self, callback)
				if (type(callback) == "function") then
					for k, v in pairs(WTFArchivesList) do
						if (v) then
							callback(k);
						end
					end
				end
			end,
		},
		ArchiveExists = {
			Static = true,
			Desc = [[Check whether the dedicated archive exists]],
			Func = function(self, name)
				if (type(name) == "string") then
					return WTFArchivesList[name] == true;
				end
			end,
		},
	},
	Properties = {
		IsLoaded = {
			Static = true,
			Get = function(self)
				return isWTFLoaded;
			end,
			Type = Boolean,
			Desc = [[Get whether the WTF archives are already loaded]],
		},
		Global = {
			Desc = [[Get the global part of the archive]],
			Type = Table,
			Get = function(self)
				return self._Global;
			end,
		},
		Character = {
			Desc = [[Get the global part of the archive]],
			Type = Table,
			Get = function(self)
				return self._Character;
			end,
		},
	},
	Events = {
		OnLoad = {
			Static = true,
			Desc = [[Triggered when the WTF variables are all loaded]],
		},
	},
	Constructor = function(self, name)
		if (type(name) == "string") then
			self._Name = name;
			self._Global = {};
			setmetatable(self._Global, {
				__index = function(t, k)
					local archive = GetWTF(self._Name);
					if (type(archive) == "table") then
						return archive.GLOBAL[k];
					else
						return nil;
					end
				end,
				__newindex = function(t, k, v)
					local archive = GetWTF(self._Name);
					if (type(archive) == "table") then
						archive.GLOBAL[k] = v;
					end
				end,
			});
			self._Character = {};
			setmetatable(self._Character, {
				__index = function(t, k)
					local archive = GetWTF(self._Name);
					if (type(archive) == "table") then
						if (type(archive.CHARS[GetCharName()]) ~= "table") then
							archive.CHARS[GetCharName()] = {};
						end
						return archive.CHARS[GetCharName()][k];
					else
						return nil;
					end
				end,
				__newindex = function(t, k, v)
					local archive = GetWTF(self._Name);
					if (type(archive) == "table") then
						if (type(archive.CHARS[GetCharName()]) ~= "table") then
							archive.CHARS[GetCharName()] = {};
						end
						archive.CHARS[GetCharName()][k] = v;
					else
						return nil;
					end
				end,
			});
			WTFArchivesList[name] = true;
		else
			return true;
		end
	end,
};
System.WTF = newclass(SystemWTFClassDef);