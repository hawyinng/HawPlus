if (PrintTable) then
	return;
end

--Hook the tostring function
local tostring = function(arg)
	if (type(arg) == "table" and type(arg.ToString) == "function") then
		return arg:ToString();
	else
		return _G["tostring"](arg);
	end
end;

--Hook the print function
local print = print;
function PrintTable(tbl)
	local name = nil;
	if (type(tbl) == "table") then
		local space1,space2;
		depth = depth or 0;
		space1 = strrep(" ",depth*2);
		space2 = strrep(" ",(depth+1)*2);
		print(space1 .. "{");
		for k,v in pairs(tbl) do
			if (type(k) == "string") then
				k = "\"" .. k .. "\"";
			end
			local result = space2 .. "[" .. tostring(k) .. "]=";
			if (type(v) == "table") then
				print(result);
				local fullname = "";
				if (not name) then
					name = tostring(tbl);
				end
				fullname = fullname .. name;
				fullname = fullname .. "[" .. tostring(k) .. "]";
				PrintTable(v,fullname,depth+1);
			else
				if (type(v) == "string") then
					v = "\"" .. v .. "\"";
				end
				result = result .. tostring(v) .. ",";
				print(result);
			end
		end
		if (not name) then
			name = tostring(tbl);
		end
		print(space1 .. "}, |cff00ff00--" .. name .. "|r");
	end
end