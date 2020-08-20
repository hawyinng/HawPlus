if (UserData) then
	return;
end

--System upvalues
local type = type;

local TypeUserDataDef = {
	Name = "Type.UserData",
	Bases = {"Type"},
	Functions = {
		Validate = {
			Func = function(value)
				return type(value)=="userdata";
			end,
			Static = true,
		},
		ToString = {
			Func = function(value)
				return "UserData";
			end,
			Static = true,
		},
	},
};
UserData = newclass(TypeUserDataDef);