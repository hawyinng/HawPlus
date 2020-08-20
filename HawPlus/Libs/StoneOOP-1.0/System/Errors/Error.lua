--------------------------------------------------------------------------------------
--							WoW <System.Error> Class								--
--------------------------------------------------------------------------------------
--	Mainly used as an interface for registering WoW in-game events handlers	and		--
--	provide a events cache to store the most recent events							--
--------------------------------------------------------------------------------------
if (System.Error) then
	return;
end

--UpValues
local type = type;
local strfind = string.find;
local GetTime = GetTime;
local tonumber = tonumber;

--WoW Error Class
local EventClassDef = {
	Name = "System.Error",
	Functions = {
		Parse = {
			Desc = [[Parse the error message into seperated information: (line, desc)]],
			Func = function(err)
				if (type(err) ~= "string") then
					return nil;
				end
				local _, _, src, line, desc = strfind(err, [[^(.+):(%d+):(.*)$]]);
				if (not line) then
					src = "";
					line = 0;
					desc = err;
				end
				return src, tonumber(line), desc;
			end,
			Static = true,
		},
		ToString = {
			Desc = [[Parse the error message into seperated information: (line, desc)]],
			Func = function(self)
				return self._Desc;
			end,
		},
	},
	--/run print(System.Error.Parse(pcall(function() a = a + 1 end)))
	Properties = {
		Desc = {
			Desc = [[Get/Set the description of the error]],
			Type = String,
			Get = function(self)
				return self._Desc;
			end,
			Set = function(self, value)
				self._Desc = value;
			end,
		},
		Line = {
			Desc = [[Get/Set the line of the error]],
			Type = Number.UInt,
			Get = function(self)
				return self._Line;
			end,
			Set = function(self, value)
				self._Line = value;
			end,
		},
		Source = {
			Desc = [[Get/Set the source of the error]],
			Type = String,
			Get = function(self)
				return self._Source;
			end,
			Set = function(self, value)
				self._Source = value;
			end,
		},
		Time = {
			Desc = [[Get/Set the time of the error]],
			Type = Number.UInt,
			Get = function(self)
				return self._Time;
			end,
			Set = function(self, value)
				self._Time = value;
			end,
		},
	},
	Constructor = function(self, msg)
		local errorClass = System.Error;
		local src, line, desc = errorClass.Parse(msg);
		if (not line) then
			return true, "Invalid error message.";
		end
		self._Message = msg;
		self._Source = src;
		self._Line = line;
		self._Desc = desc;
		self._Time = GetTime();
	end,
};
System.Error = newclass(EventClassDef);
