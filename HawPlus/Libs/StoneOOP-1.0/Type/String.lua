if (String) then
	return;
end

--System upvalues
local type = type;
local floor = math.floor;
local strtrim = strtrim;
local strlen = string.len;
local strsub = string.sub;

local TypeStringDef = {
	Name = "Type.String",
	Bases = {"Type"},
	Functions = {
		Validate = {
			Func = function(value)
				return type(value) == "string";
			end,
			Static = true,
		},
		Parse = {
			Func = function(value)
				return tostring(value);
			end,
			Static = true,
		},
		ToString = {
			Func = function(value)
				return "String";
			end,
			Static = true,
		},
		Len = {
			Func = function(value)
				if (type(value) ~= "string") then
					return nil;
				end
				local currentIndex = 1;
				local numChars = 0;
				while (currentIndex<=strlen(value)) do
					local char = string.byte(value,currentIndex);
					if (char > 240) then
						currentIndex = currentIndex+4;
					elseif (char > 225) then
						currentIndex = currentIndex+3;
					elseif (char > 192) then
						currentIndex = currentIndex+2;
					else
						currentIndex = currentIndex+1;
					end
					numChars = numChars+1;
				end
				return numChars;
			end,
			Static = true,
		},
		Insert = {
			Func = function(value,i,newstr)
				if (type(value) ~= "string" or type(newstr) ~= "string") then
					return nil;
				end
				if (type(i) ~= "number") then
					return value .. newstr;
				end
				local len = String.Len(value);
				if (i < 0) then
					i = len + i + 2;
				end
				if (i <= 0 or i > len + 1) then
					return nil;
				end
				local prePart = String.Sub(value, 1, i - 1);
				local postPart = String.Sub(value, i, -1);
				local result = "";
				if(type(prePart) == "string") then
					result = result .. prePart;
				end
				result = result .. newstr;
				if(type(postPart) == "string") then
					result = result .. postPart;
				end
				return result;
			end,
			Static = true,
		},
		Sub = {
			Func = function(value,startPos,endPos)
				if (type(value) == "string" and type(startPos) == "number" and type(endPos) == "number") then
					local len = String.Len(value);
					if (startPos < 0) then
						startPos = len + startPos + 1;
					end
					if (endPos < 0) then
						endPos = len + endPos + 1;
					end
					if (startPos <= 0 or endPos <= 0 or startPos > len or endPos > len or startPos > endPos) then
						return nil;
					end
					local currentIndex = 1;
					local currentSpan, currentChar;
					local currentPos = 1;
					local result = "";
					while currentIndex <= strlen(value) do
						local char = string.byte(value, currentIndex);
						if (char > 240) then
							currentSpan = 4;
						elseif (char > 225) then
							currentSpan = 3;
						elseif (char > 192) then
							currentSpan = 2;
						else
							currentSpan = 1;
						end
						if (currentPos >= startPos and currentPos <= endPos) then
							currentChar = strsub(value, currentIndex, currentIndex+currentSpan-1);
							if (type(currentChar) == "string") then
								result = result .. currentChar;
							end
						end
						currentIndex = currentIndex+currentSpan;
						currentPos = currentPos+1;
					end
					return result;
				else
					return nil;
				end
			end,
			Static = true,
		},
	},
};
String = newclass(TypeStringDef);