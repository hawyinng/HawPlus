if(Bool) then
	return;
end

--System upvalues
local type = type;
local floor = math.floor;
local strtrim = strtrim;
local strlen = string.len;

local TypeBoolDef = {
	Name = "Type.Bool",
	Bases = {"Type"},
	Functions = {
		Validate = {
			Func = function(value)
				return type(value) == "boolean";
			end,
			Static = true,
		},
		Parse = {
			Func = function(value)
				if (type(value) == "string") then
					value = strtrim(value);
					if (strlower(value) == "true") then
						return true;
					elseif (strlower(value) == "false") then
						return false;
					else
						return nil;
					end
				else
					return value;
				end
			end,
			Static = true,
		},
		ToString = {
			Func = function(value)
				return "Bool";
			end,
			Static = true,
		},
	},
};
Bool = newclass(TypeBoolDef);