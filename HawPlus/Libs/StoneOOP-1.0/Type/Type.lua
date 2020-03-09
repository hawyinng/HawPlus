if (getclass("Type")) then
	return;
end

--System upvalues
local type = type;
local floor = math.floor;
local strtrim = strtrim;
local strlen = string.len;

local TypeDef = {
	Name = "Type",
	Functions = {
		Validate = {
			Func = function(value)
				return true;
			end,
			Static = true,
		},
		Parse = {
			Func = function(value)
				return value;
			end,
			Static = true,
		},
		ToString = {
			Func = function(value)
				return "Type";
			end,
			Static = true,
		},
	},
};
newclass(TypeDef);
