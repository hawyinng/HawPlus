if (Function) then
	return;
end

--System upvalues
local type = type;

local TypeFunctionDef = {
	Name = "Type.Function",
	Bases = {"Type"},
	Functions = {
		Validate = {
			Func = function(value)
				return type(value)=="function";
			end,
			Static = true,
		},
		ToString = {
			Func = function(value)
				return "Function";
			end,
			Static = true,
		},
	},
};
Function = newclass(TypeFunctionDef);