if(Number.UInt) then
	return;
end

--System upvalues
local type = type;
local floor = math.floor;
local strtrim = strtrim;
local strlen = string.len;

local TypeNumberUIntDef = {
	Name = "Type.Number.UInt",
	Bases = {"Type.Number"},
	Functions = {
		Validate = {
			Func = function(value)
				local int = getclass("Type.Number.Int");
				return int.Validate(value) and value>=0;
			end,
			Static = true,
		},
		Parse = {
			Func = function(value,way)
				local int = getclass("Type.Number.Int");
				local result = int.Parse(value,way);
				if (type(result) == "number" and result<0) then
					result = -result;
				end
				return result;
			end,
			Static = true,
		},
		ToString = {
			Func = function(value)
				return "Number.UInt";
			end,
			Static = true,
		},
	},
};
Number.UInt = newclass(TypeNumberUIntDef);