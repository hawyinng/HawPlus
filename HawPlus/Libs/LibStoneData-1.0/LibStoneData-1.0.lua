-----------------------------------------I N T R O  T O  T H E  L I B---------------------------------------
-- **LibStoneData** provides a high speed cache to store all information about the items and spells
-- that is stored in the client DBC with which an API is also designed to retrive info from it. "Massive Memory"
-- (more than 20MB) is allocated estimately for the cache in order to exchange for speed.
------------------------------------------------------------------------------------------------------------

--Lib initialization
local MAJOR,MINOR = "LibStoneData-1.0", 1;
local StoneData, oldminor = LibStub:NewLibrary(MAJOR, MINOR);
if(not StoneData) then return end

--Upvalues
local coroutine = coroutine;
local floor = math.ceil;
local GetItemInfo = GetItemInfo;
local GetSpellInfo = GetSpellInfo;
local GetSpellLink = GetSpellLink;
local tinsert = table.insert;
local _G = _G;

--System local vars
local TimeFrame = CreateFrame("Frame");
local Tooltip = CreateFrame("GameTooltip","StoneDataTooltip",UIParent,"GameTooltipTemplate");
local IsDataLoaded = false;
local CheckItemID = 6948;
local LoadingThread = false;
local Interval = 250;
local MaxID = 99999;
local Items,Spells,ItemsList,SpellsList;
local TooltipDesc;
local LibBabbleInventory = LibStub("LibBabble-Inventory-3.0");
local ItemTypes = {
	["Armor"] = {
		["Miscellaneous"] = {},
		["Cloth"] = {},
		["Leather"] = {},
		["Mail"] = {},
		["Plate"] = {},
		["Shields"] = {},
		["Librams"] = {},
		["Idols"] = {},
		["Totems"] = {},
		["Sigils"] = {},
	},
	["Consumable"] = {
		["Food & Drink"] = {},
		["Potion"] = {},
		["Elixir"] = {},
		["Flask"] = {},
		["Bandage"] = {},
		["Item Enhancement"] = {},
		["Scroll"] = {},
		["Other"] = {},
		["Consumable"] = {},
	},
	["Container"] = {
		["Bag"] = {},
		["Enchanting Bag"] = {},
		["Engineering Bag"] = {},
		["Gem Bag"] = {},
		["Herb Bag"] = {},
		["Mining Bag"] = {},
		["Soul Bag"] = {},
		["Leatherworking Bag"] = {},
	},
	["Gem"] = {
		["Blue"] = {},
		["Green"] = {},
		["Orange"] = {},
		["Meta"] = {},
		["Prismatic"] = {},
		["Purple"] = {},
		["Red"] = {},
		["Simple"] = {},
		["Yellow"] = {},
	},
	["Key"] = {
		["Key"] = {},
	},
	["Miscellaneous"] = {
		["Junk"] = {},
		["Reagent"] = {},
		["Pet"] = {},
		["Holiday"] = {},
		["Mount"] = {},
		["Other"] = {},
	},
	["Reagent"] = {
		["Reagent"] = {},
	},
	["Recipe"] = {
		["Alchemy"] = {},
		["Blacksmithing"] = {},
		["Book"] = {},
		["Cooking"] = {},
		["Enchanting"] = {},
		["Engineering"] = {},
		["First Aid"] = {},
		["Leatherworking"] = {},
		["Tailoring"] = {},
	},
	["Projectile"] = {	
		["Arrow"] = {},
		["Bullet"] = {},
	},
	["Quest"] = {
		["Quest"] = {},
	},
	["Quiver"] = {
		["Ammo Pouch"] = {},
		["Quiver"] = {},
	},
	["Trade Goods"] = {
		["Armor Enchantment"] = {},
		["Cloth"] = {},
		["Devices"] = {},
		["Elemental"] = {},
		["Enchanting"] = {},
		["Explosives"] = {},
		["Herb"] = {},
		["Jewelcrafting"] = {},
		["Leather"] = {},
		["Materials"] = {},
		["Meat"] = {},
		["Metal & Stone"] = {},
		["Other"] = {},
		["Parts"] = {},
		["Trade Goods"] = {},
		["Weapon Enchantment"] = {},
	},
	["Weapon"] = {
		["Bows"] = {},
		["Crossbows"] = {},
		["Daggers"] = {},
		["Guns"] = {},
		["Fishing Poles"] = {},
		["Fist Weapons"] = {},
		["Miscellaneous"] = {},
		["One-Handed Axes"] = {},
		["One-Handed Maces"] = {},
		["One-Handed Swords"] = {},
		["Polearms"] = {},
		["Staves"] = {},
		["Thrown"] = {},
		["Two-Handed Axes"] = {},
		["Two-Handed Maces"] = {},
		["Two-Handed Swords"] = {},
		["Wands"] = {},
	},
};
local ItemEquipLocs = {
	"INVTYPE_AMMO",
	"INVTYPE_HEAD",
	"INVTYPE_NECK",
	"INVTYPE_SHOULDER",
	"INVTYPE_BODY",
	"INVTYPE_CHEST",
	"INVTYPE_ROBE",
	"INVTYPE_WAIST",
	"INVTYPE_LEGS",
	"INVTYPE_FEET",
	"INVTYPE_WRIST",
	"INVTYPE_HAND",
	"INVTYPE_FINGER",
	"INVTYPE_TRINKET",
	"INVTYPE_CLOAK",
	"INVTYPE_WEAPON",
	"INVTYPE_SHIELD",
	"INVTYPE_2HWEAPON",
	"INVTYPE_WEAPONMAINHAND",
	"INVTYPE_WEAPONOFFHAND",
	"INVTYPE_HOLDABLE", 
	"INVTYPE_RANGED",
	"INVTYPE_THROWN",
	"INVTYPE_RANGEDRIGHT",
	"INVTYPE_RELIC",
	"INVTYPE_TABARD",
	"INVTYPE_BAG",
	"INVTYPE_QUIVER",
};

--Aux functions
local function GetHyperlinkDesc(link)
	if(type(link)~="string") then
		return nil;
	end
	Tooltip:ClearLines();
	Tooltip:SetOwner(UIParent, 'ANCHOR_NONE');
	Tooltip:SetHyperlink(link);
	local i = 1;
	local result = "";
	local textobject = getglobal("StoneDataTooltipTextLeft1");
	while(textobject) do
		local text = textobject:GetText();
		if(type(text)=="string") then
			result = result .. textobject:GetText();
		end
		i = i + 1;
		textobject = getglobal("StoneDataTooltipTextLeft" .. i);
		if(type(text)=="string" and strtrim(text)~="") then
			result = result .. "\n";
		end
	end
	return strtrim(result);
end
local function GetSpellDesc(id)
	local link = GetSpellLink(id);
	return GetHyperlinkDesc(link);
end
local function GetItemDesc(id)
	local _,link = GetItemInfo(id);
	return GetHyperlinkDesc(link);
end
local function GetIDFromLink(link)
	if(type(link)~="string") then
		return nil;
	end
	local _,_,result = strfind(link,[[item:([%d]+)]]);
	result = tonumber(result);
	if(type(result)=="number") then
		return result;
	end
	_,_,result = strfind(link,[[spell:([%d]+)]]);
	result = tonumber(result);
	if(type(result)=="number") then
		return result;
	end
	return nil;
end
local function SelectItemType(...)
	local curtype = ItemTypes;
	local typename;
	for i=1, select("#",...) do
		local curtype2;
		typename = select(i,...);
		curtype2 = curtype[typename];
		if(type(curtype2)~="table") then
			for k in pairs(curtype) do
				local tempname = StoneData:GetLocalizedItemTypeName(k);
				if(tempname==typename) then
					curtype2 = curtype[k];
				end
			end
			if(type(curtype2)~="table") then
				return nil;
			end
		end
		curtype = curtype2;
	end
	return typename,curtype;
end

--Events: OnLoadingStart,OnLoadingProgress,OnLoadingComplete
local function LoadData()
	--Load items data
	coroutine.yield("OnLoadingStart");
	Items = Items or {};
	wipe(Items);
	ItemsList = ItemsList or {};
	wipe(ItemsList);
	Items.Name = {};
	Items.Icon = {};
	Items.Link = {};
	Items.Rarity = {};
	Items.Level = {};
	Items.MinLevel = {};
	Items.Type = {};
	Items.SubType = {};
	Items.StackCount = {};
	Items.EquipLoc = {};
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon;
	Spells = Spells or {};
	wipe(Spells);
	SpellsList = SpellsList or {};
	wipe(SpellsList);
	Spells.Name = {};
	Spells.Icon = {};
	Spells.Link = {};
	Spells.Rank = {};
	Spells.Cost = {};
	Spells.CostType = {};
	Spells.CastTime = {};
	Spells.MinRange = {};
	Spells.MaxRange = {};
	local spellName, spellRank, spellLink, spellIcon, spellCost, spellCostType, spellCastTime, spellMinRange, spellMaxRange;
	local itemsCount = 0;
	local spellsCount = 0;
	local yieldCount = 0;
	for i=1, MaxID do
		itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(i);
		if(itemName) then
			Items.Name[itemName] = Items.Name[itemName] or {};
			tinsert(Items.Name[itemName],i);
			if(itemLink~=nil) then
				Items.Link[itemLink] = Items.Link[itemLink] or {};
				tinsert(Items.Link[itemLink],i);
			end
			if(itemRarity~=nil) then
				Items.Rarity[itemRarity] = Items.Rarity[itemRarity] or {};
				tinsert(Items.Rarity[itemRarity],i);
			end
			if(itemLevel~=nil) then
				Items.Level[itemLevel] = Items.Level[itemLevel] or {};
				tinsert(Items.Level[itemLevel],i);
			end
			if(itemMinLevel~=nil) then
				Items.MinLevel[itemMinLevel] = Items.MinLevel[itemMinLevel] or {};
				tinsert(Items.MinLevel[itemMinLevel],i);
			end
			if(itemType~=nil) then
				Items.Type[itemType] = Items.Type[itemType] or {};
				tinsert(Items.Type[itemType],i);
			end
			if(itemSubType~=nil) then
				Items.SubType[itemSubType] = Items.SubType[itemSubType] or {};
				tinsert(Items.SubType[itemSubType],i);
			end
			if(itemStackCount~=nil) then
				Items.StackCount[itemStackCount] = Items.StackCount[itemStackCount] or {};
				tinsert(Items.StackCount[itemStackCount],i);
			end
			if(itemEquipLoc~=nil) then
				Items.EquipLoc[itemEquipLoc] = Items.EquipLoc[itemEquipLoc] or {};
				tinsert(Items.EquipLoc[itemEquipLoc],i);
			end
			if(itemIcon~=nil) then
				Items.Icon[itemIcon] = Items.Icon[itemIcon] or {};
				tinsert(Items.Icon[itemIcon],i);
			end
			itemsCount = itemsCount + 1;
			yieldCount = yieldCount + 1;
			local item = {Text = itemLink or itemName, Icon = itemIcon, ID = i};
			if(itemLink) then
				item.Tooltip = function(self)
					GameTooltip:SetOwner(self.__Bliz);
					GameTooltip:ClearLines();
					GameTooltip:SetHyperlink(self.Item.Text);
					GameTooltip:Show();
				end;
			end
			tinsert(ItemsList,item);
			if(floor(yieldCount/Interval)==yieldCount/Interval) then
				coroutine.yield("OnLoadingProgress",floor(i/MaxID*100));
			end
		end
		spellName, spellRank, spellIcon, spellCost, _, spellCostType, spellCastTime, spellMinRange, spellMaxRange = GetSpellInfo(i);
		if(spellName) then
			Spells.Name[spellName] = Spells.Name[spellName] or {};
			tinsert(Spells.Name[spellName],i);
			spellLink = GetSpellLink(i);
			if(spellLink~=nil) then
				Spells.Link[spellLink] = Spells.Link[spellLink] or {};
				tinsert(Spells.Link[spellLink],i);
			end
			if(spellRank~=nil) then
				local fullName = spellName .. "(" .. spellRank .. ")";
				Spells.Name[fullName] = Spells.Name[fullName] or {};
				tinsert(Spells.Name[fullName],i);
				Spells.Rank[spellRank] = Spells.Rank[spellRank] or {};
				tinsert(Spells.Rank[spellRank],i);
			end
			if(spellIcon~=nil) then
				Spells.Icon[spellIcon] = Spells.Icon[spellIcon] or {};
				tinsert(Spells.Icon[spellIcon],i);
			end
			if(spellCost~=nil) then
				Spells.Cost[spellCost] = Spells.Cost[spellCost] or {};
				tinsert(Spells.Cost[spellCost],i);
			end
			if(spellCostType~=nil) then
				Spells.CostType[spellCostType] = Spells.CostType[spellCostType] or {};
				tinsert(Spells.CostType[spellCostType],i);
			end
			if(spellCastTime~=nil) then
				Spells.CastTime[spellCastTime] = Spells.CastTime[spellCastTime] or {};
				tinsert(Spells.CastTime[spellCastTime],i);
			end
			if(spellMinRange~=nil) then
				Spells.MinRange[spellMinRange] = Spells.MinRange[spellMinRange] or {};
				tinsert(Spells.MinRange[spellMinRange],i);
			end
			if(spellMaxRange~=nil) then
				Spells.MaxRange[spellMaxRange] = Spells.MaxRange[spellMaxRange] or {};
				tinsert(Spells.MaxRange[spellMaxRange],i);
			end
			spellsCount = spellsCount + 1;
			yieldCount = yieldCount + 1;
			local spell = {Text = spellLink or spellName, Icon = spellIcon, ID = i};
			if(spellLink) then
				spell.Tooltip = function(self)
					GameTooltip:SetOwner(self);
					GameTooltip:ClearLines();
					GameTooltip:SetHyperlink(spellLink);
					GameTooltip:Show();
				end;
			end
			tinsert(SpellsList,spell);
			if(floor(yieldCount/Interval)==yieldCount/Interval) then
				coroutine.yield("OnLoadingProgress",floor(i/MaxID*100));
			end
		end
	end
	coroutine.yield("OnLoadingComplete",itemsCount,spellsCount);
	return true;
end
local function OnTick()
	if(not IsDataLoaded and GetItemInfo(6948)) then
		if(type(LoadingThread)~="thread") then
			LoadingThread = coroutine.create(LoadData);
		else
			local succ,result,param1,param2 = coroutine.resume(LoadingThread);
			if(succ) then
				if(result==true) then
					LoadingThread = false;
					IsDataLoaded = true;
					return;
				elseif(result and type(StoneData[result])=="function") then
					StoneData[result](param1,param2);
				end
			else
				error("An error occured while the data is being initialized:" .. tostring(result));
				LoadingThread = false;
			end
		end
	end
end

--Find ID data
local Name = {};
local values = {};
local mergecounter = {};
local function GetDataID(src,...)
	local condition;
	wipe(Name);
	wipe(values);
	wipe(mergecounter);
	src.MergeResult = src.MergeResult or {};
	local mergeresult = src.MergeResult;
	wipe(mergeresult);
	for i=1, select("#",...) do
		condition = select(i,...);
		condition = strtrim(condition);
		local name,value = strsplit("=",condition);
		if(name and value) then
			tinsert(Name,strtrim(name));
			value = strtrim(value);
			if(tonumber(value)) then
				tinsert(values,tonumber(value));
			else
				tinsert(values,value);
			end
		end
	end
	for i=1, #Name do
		if(type(src[Name[i]])~="table") then
			return mergeresult;
		end
		local target = src[Name[i]][values[i]];
		if(type(target)~="table") then
			return mergeresult;
		end
		for j=1, #target do
			mergecounter[target[j]] = mergecounter[target[j]] or 0;
			mergecounter[target[j]] = mergecounter[target[j]] + 1;
		end
	end
	for i,v in pairs(mergecounter) do
		if(v==#Name) then
			tinsert(mergeresult,i);
		end
	end
	return mergeresult;
end

--Initialize data cache
function StoneData:Initialize()
	if(IsDataLoaded) then
		return nil,"StoneData has already been initialized";
	end
	TimeFrame:SetScript("OnUpdate",OnTick);
	TimeFrame:Show();
	return true;
end

--Get the item info
function StoneData:GetItemInfoEx(item)
	local itemName,itemLink,itemRarity,itemLevel,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,itemIcon,itemPrice = GetItemInfo(item);
	if(not itemName) then
		return nil;
	end
	local itemDesc = GetItemDesc(item);
	local itemID = GetIDFromLink(itemLink);
	return itemID,itemLink,itemName,itemIcon,itemDesc,itemLevel,itemMinLevel,itemRarity,itemType,itemSubType,itemStackCount,itemEquipLoc,itemPrice;
end

--Get the spell info
function StoneData:GetSpellInfoEx(spell)
	local spellName,spellRank,spellIcon,spellCost,_,spellCostType,spellCastTime,spellMinRange,spellMaxRange = GetSpellInfo(spell);
	if(not spellName) then
		return nil;
	end
	local spellDesc = GetSpellDesc(spell);
	local spellLink = GetSpellLink(spell);
	local spellID = GetIDFromLink(spellLink);
	return spellID,spellLink,spellName,spellIcon,spellDesc,spellRank,spellCastTime,spellCost,spellCostType,spellMinRange,spellMaxRange;
end

function StoneData:GetItemsList()
	if(not IsDataLoaded) then
		return nil,"StoneData has not been initialized";
	end
	return ItemsList;
end

function StoneData:GetItemsID(...)
	if(not IsDataLoaded) then
		return nil,"StoneData has not been initialized";
	end
	return GetDataID(Items,...);
end

function StoneData:GetLocalizedItemTypes(...)
	if(not LibBabbleInventory) then
		return nil,"LibBabble-Inventory-3.0 is not loaded.";
	end
	itemtypes = {};
	local _,subtypes = SelectItemType(...);
	if(type(subtypes)~="table") then
		return nil,"No such type is found.";
	end
	for k in pairs(subtypes) do
		k = LibBabbleInventory:GetLookupTable()[k];
		tinsert(itemtypes,k);
	end
	return itemtypes;
end

function StoneData:GetCommonItemTypes(...)
	if(not LibBabbleInventory) then
		return nil,"LibBabble-Inventory-3.0 is not loaded.";
	end
	itemtypes = {};
	local _,subtypes = SelectItemType(...);
	if(type(subtypes)~="table") then
		return nil,"No such type is found.";
	end
	for k in pairs(subtypes) do
		tinsert(itemtypes,k);
	end
	return itemtypes;
end

function StoneData:GetLocalizedItemTypeName(name)
	if(not LibBabbleInventory) then
		return nil,"LibBabble-Inventory-3.0 is not loaded.";
	end
	if(type(name)~="string") then
		return nil,"Invalid parameter.";
	end
	return LibBabbleInventory:GetLookupTable()[name];
end

function StoneData:GetCommonItemTypeName(name)
	if(not LibBabbleInventory) then
		return nil,"LibBabble-Inventory-3.0 is not loaded.";
	end
	if(type(name)~="string") then
		return nil,"Invalid parameter.";
	end
	return LibBabbleInventory:GetReverseLookupTable()[name];
end

function StoneData:GetLocalizedItemEquipLocs()
	local result = {};
	for i=1, #ItemEquipLocs do
		tinsert(result,_G[ItemEquipLocs[i]]);
	end
	return result;
end

function StoneData:GetCommonItemEquipLocs()
	local result = {};
	for i=1, #ItemEquipLocs do
		tinsert(result,ItemEquipLocs[i]);
	end
	return result;
end

function StoneData:GetItemEquipLocIndex(loc)
	for i=1, #ItemEquipLocs do
		if(ItemEquipLocs[i]==loc) then
			return i;
		end
	end
	return nil;
end

function StoneData:GetSpellsList()
	if(not IsDataLoaded) then
		return nil,"StoneData has not been initialized";
	end
	return SpellsList;
end

function StoneData:GetSpellsID(...)
	if(not IsDataLoaded) then
		return nil,"StoneData has not been initialized";
	end
	return GetDataID(Spells,...);
end

