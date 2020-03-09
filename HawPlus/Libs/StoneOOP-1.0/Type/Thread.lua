if (Thread) then
	return;
end

--System upvalues
local type = type;
local floor = math.floor;
local strtrim = strtrim;
local strlen = string.len;

local TypeThreadDef = {
	Name = "Type.Thread",
	Bases = {"Type"},
	Functions = {
		Validate = {
			Func = function(value)
				return type(value)=="thread";
			end,
			Static = true,
		},
		ToString = {
			Func = function(value)
				return "Thread";
			end,
			Static = true,
		},
	},
};
Thread = newclass(TypeThreadDef);