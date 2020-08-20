if(Number.Float) then
	return;
end

--System upvalues
local type = type;
local floor = math.floor;
local strtrim = strtrim;
local strlen = string.len;

local TypeNumberFloatDef = {
	Name = "Type.Number.Float",
	Bases = {"Type.Number"},
	Functions = {
		ToString = {
			Func = function(value)
				return "Number.Float";
			end,
			Static = true,
		},
	}
};
Number.Float = newclass(TypeNumberFloatDef);