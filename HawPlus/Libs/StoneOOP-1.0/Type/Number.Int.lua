if(Number.Int) then
	return;
end

--System upvalues
local type = type;
local floor = math.floor;
local ceil = math.ceil;
local strtrim = strtrim;
local strlen = string.len;

local TypeNumberIntDef = {
	Name = "Type.Number.Int",
	Bases = {"Type.Number"},
	Functions = {
		Validate = {
			Func = function(value)
				if (type(value) == "number") then
					return value == floor(value);
				else
					return false;
				end
			end,
			Static = true,
		},
		Parse = {
			Func = function(value, way)
				if (type(value) == "string") then
					value = strtrim(value);
				end
				local num = tonumber(value);
				if (type(num) == "number") then
					value = strsplit(".",value);
					if (value == "") then
						value = 0;
					elseif (way == 1) then		--floor
						value = floor(num);
					elseif (way == 2) then		--ceil
						value = ceil(num);
					elseif (way == 3) then		--round
						local floorValue = floor(num);
						local ceilValue = ceil(num);
						if (num - floorValue >= ceilValue - num) then
							value = ceilValue;
						else
							value = floorValue;
						end
					else
						value = tonumber(value);
					end
					return value;
				else
					return nil;
				end
			end,
			Static = true,
		},
		ToString = {
			Func = function(value)
				return "Number.Int";
			end,
			Static = true,
		},
	},
};
Number.Int = newclass(TypeNumberIntDef);