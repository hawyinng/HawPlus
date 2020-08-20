if(Number) then
	return;
end

--System upvalues
local type = type;
local floor = math.floor;
local strtrim = strtrim;
local strlen = string.len;

local TypeNumberDef = {
	Name = "Type.Number",
	Bases = {"Type"},
	Functions = {
		Validate = {
			Func = function(value)
				return type(value)=="number";
			end,
			Static = true,
		},
		Parse = {
			Func = function(value)
				return tonumber(value);
			end,
			Static = true,
		},
		ToString = {
			Func = function(value)
				return "Number";
			end,
			Static = true,
		},
	},
};
Number = newclass(TypeNumberDef);