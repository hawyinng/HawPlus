if (Table) then
	return;
end

--System upvalues
local type = type;
local floor = math.floor;
local strtrim = strtrim;
local strlen = string.len;

-- local functions
local function BubbleSort(tbl, compFunc)
	if (type(tbl) ~= "table" or type(compFunc) ~= "function") then
		return nil;
	end
	for i = 1, #tbl - 1 do
		for j = i + 1, #tbl do
			if (not compFunc(tbl[i], tbl[j])) then
				tbl[i], tbl[j] = tbl[j], tbl[i];
			end
		end
	end
end

local function SplitArray(tbl, size)
	if (type(tbl) ~= "table" or type(size) ~= "number") then
		return nil;
	end
	local results = {};
	local groupCount;
	if (#tbl / size == floor(#tbl / size)) then
		groupCount = floor(#tbl / size);
	else
		groupCount = floor(#tbl / size) + 1;
	end
	for i = 1, groupCount do
		local newGroup = {};
		for j = 1, size do
			tinsert(newGroup, tbl[(i - 1) * size + j]);
		end
		tinsert(results, newGroup);
	end
	return results;
end

local function MergeArray(tbl, compFunc)
	if (type(tbl) ~= "table" or type(compFunc) ~= "function") then
		return nil;
	end
	local result = {};
	local pointers = {};
	for i = 1, #tbl do
		pointers[i] = 1;
	end
	local curIndex = 0;
	local times = 0;
	while(true) do
		local foundIndex = 0;
		local curElem;
		for i = 1, #tbl do
			if (tbl[i][pointers[i]] ~= nil) then
				foundIndex = i;
				local curElem = tbl[i][pointers[i]];
				local insertPos = #result + 1;
				for j = 1, #result do
					if (compFunc(curElem, result[j])) then
						insertPos = j;
						break;
					end
				end
				tinsert(result, insertPos, curElem);
				pointers[i] = pointers[i] + 1;
			end
		end
		if (foundIndex == 0) then
			return result;
		end
	end
end

local TypeTableDef = {
	Name = "Type.Table",
	Bases = {"Type"},
	Functions = {
		Validate = {
			Func = function(value)
				return type(value) == "table";
			end,
			Static = true,
		},
		ToString = {
			Func = function(value)
				return "Table";
			end,
			Static = true,
		},
		IsEmpty = {
			Func = function(value)
				if (value and type(value) == "table") then
					for k,v in pairs(value) do
						if (k) then
							return false;
						end
					end
					return true;
				else
					return nil;
				end
			end,
			Static = true,
			Desc = [[Check whether the table is empty or not]],
		},
		Clone = {
			Func = function(src, dest)
				dest = dest or {};
				if (not src or not dest or type(src)  ~=  "table" or type(dest)  ~=  "table") then
					return nil;
				end
				wipe(dest);
				for k,v in pairs(src) do
					if (type(v) ~= "table") then
						dest[k] = v;
					else
						dest[k] = {};
						Table.Clone(v, dest[k]);
					end
				end
				return dest;
			end,
			Static = true,
			Desc = [[Clone an existing table. (functions,userdatas and threads are just still reference-copied)]],
		},
		FilterArray = {
			Func = function(src, filterFunc)
				if (type(src) ~= "table" or type(filterFunc) ~= "function") then
					return nil;
				end
				local srcCount = #src;
				local index = 1;
				while (index <= srcCount) do
					if (not filterFunc(src[index])) then
						tremove(src, index);
						srcCount = #src;
					else
						index = index + 1;
					end
				end
				return src;
			end,
			Static = true,
			Desc = [[Filter an existing array table according to the given function.]],
		},
		Sort = {
			Func = function(src, compFunc)
				if (type(src) ~= "table" or type(compFunc) ~= "function") then
					return nil;
				end
				local splited = SplitArray(src, 10);
				for i = 1, #splited do
					BubbleSort(splited[i], compFunc);
				end
				local result = MergeArray(splited, compFunc);
				Table.Clone(result, src);
				wipe(result);
				return src;
			end,
			Static = true,
			Desc = [[Sort an existing array table according to the given comparison function.]],
		},
	},
};
Table = newclass(TypeTableDef);