if(Number.UFloat) then
	return;
end

--System upvalues
local type = type;
local floor = math.floor;
local strtrim = strtrim;
local strlen = string.len;

local TypeNumberUFloatDef = {
	Name = "Type.Number.UFloat",
	Bases = {"Type.Number"},
	Functions = {
		Validate = {
			Func = function(value)
				return type(value)=="number" and value>=0;
			end,
			Static = true,
		},
		Parse = {
			Func = function(value)
				local result = tonumber(value);
				if(type(result)=="number" and result<0) then
					result = -result;
				end
				return result;
			end,
			Static = true,
		},
		ToString = {
			Func = function(value)
				return "Number.UFloat";
			end,
			Static = true,
		},
	},
};
Number.UFloat = newclass(TypeNumberUFloatDef);