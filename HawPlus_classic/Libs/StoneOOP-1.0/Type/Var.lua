if (Var) then
	return;
end

--System upvalues
local type = type;
local floor = math.floor;
local strtrim = strtrim;
local strlen = string.len;

local TypeVarDef = {
	Name = "Type.Var",
	Bases = {"Type"},
	Functions = {
		ToString = {
			Func = function(value)
				return "Var";
			end,
			Static = true,
		},
	}
};
Var = newclass(TypeVarDef);