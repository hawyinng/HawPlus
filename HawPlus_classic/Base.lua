--------------------------------------------------------------------------------------
--							WoW <System.API> Class									--
--------------------------------------------------------------------------------------
--	Provide a series of base functions for new API designing						--
--------------------------------------------------------------------------------------
if (System.WoWAPI) then
	return;
end
--if GetSetting("isLogin") ~= "true" then return end
--UpValues
local StoneData = LibStub("LibStoneData-1.0");
StoneData.OnLoadingStart = function()
	print("Now loading enhanced WoW API ...");
end
StoneData.OnLoadingComplete = function()
	print("Enhanced WoW API has been loaded.");
end
StoneData.OnLoadingProgress = function(percentage)
	print(percentage);
end
--StoneData:Initialize();

local wipe = table.wipe;
local tinsert = table.insert;
local strsplit = string.split;
local sqrt = math.sqrt;
local pow = math.pow;
local tan = math.tan;
local atan = math.atan;
local pi = math.pi;
local L = System.Locale:GetLocaleTable("HawPlus_classic");
local Timer = System.Timer;
local Tooltip = CreateFrame("GameTooltip","StoneDataTooltip",UIParent,"GameTooltipTemplate");
local ItemsResult = {};
local SpellsResult = {};

local function GetSpellID(name)
	if (not name or type(name) ~= "string") then
		return nil;
	end
	name = strtrim(name);
	local result = StoneData:GetSpellInfoEx(name);
	if (result) then
		wipe(SpellsResult);
		tinsert(SpellsResult, result);
		return SpellsResult;
	end
	return nil;
end;

local function GetItemID(name)
	if (not name or type(name) ~= "string") then
		return nil;
	end
	name = strtrim(name);
	local result = StoneData:GetItemInfoEx(name);
	if (result) then
		wipe(ItemsResult);
		tinsert(ItemsResult, result);
		return ItemsResult;
	end
	return nil;
end;


--API Class
local WoWAPIClassDef = {
	Name = "System.WoWAPI",
	Functions = {
		GetSpellItem = {
			Desc = [[Get the spell or item info]],
			Static = true,
			Func = function(spell)
				if (type(spell) ~= "string") then
					return nil;
				end
				local spelltype, spellid, spellname, spellicon;
				local name;
				spell = strtrim(spell);
				spelltype = string.sub(spell, 1, 5);
				name = string.sub(spell, 6, -1);
				spellid = tonumber(name);
				if (spelltype == "SPELL") then
					if (type(spellid) == "number") then
						spellname, _, spellicon = GetSpellInfo(spellid);
						if (spellname) then
							spelllink = GetSpellLink(spellid);
						else
							return nil, "INVALID";
						end
						return spelltype, spellname, spellid, spelllink, spellicon;
					else
						spellname, _, spellicon = GetSpellInfo(name);
						if (type(spellname) == "string" and spellname ~= "") then
							spellid = GetSpellID(spellname)[1];
							spelllink = GetSpellLink(name);
							return spelltype, spellname, spellid, spelllink, spellicon;
						else
							return nil, "INVALID";
						end
					end
				else
					spelltype = nil;
				end
				if (not spelltype) then
					spelltype = string.sub(spell, 1, 4);
					name = string.sub(spell, 5, -1);
					spellid = tonumber(name);
					if (spelltype == "ITEM") then
						if (type(spellid) == "number") then
							spellname, spelllink, _, _, _, _, _, _, _, spellicon = GetItemInfo(spellid);
							if (not spellname) then
								return nil,"INVALID";
							end
							return spelltype, spellname, spellid, spelllink, spellicon;
						else
							spellname, spelllink, _, _, _, _, _, _, _, spellicon = GetItemInfo(name);
							if (type(spellname) == "string" and spellname ~= "") then
								spellid = GetItemID(spellname)[1];
								return spelltype, spellname, spellid, spelllink, spellicon;
							else
								return nil, "INVALID";
							end
						end
					else
						spelltype = nil;
					end
				end
				spell = spellname or spell;
				local isspell, isitem;
				if (spelltype == "SPELL") then
					isspell = true;
				elseif (spelltype == "ITEM") then
					isitem = true;
				end
				if (not isspell and not isitem) then
					local tempId;
					tempId = GetSpellID(spell);
					if (type(tempId) == "table" and #tempId > 0) then
						spellid = tempId[1];
						spelltype = "SPELL";
						isspell = true;
						spellname, _, spellicon = GetSpellInfo(spellid);
						spelllink = GetSpellLink(spellid);
					end
					tempId = GetItemID(spell);
					if (type(tempId) == "table" and #tempId > 0) then
						spellid = tempId[1];
						spelltype = "ITEM";
						isitem = true;
						spellname, spelllink, _, _, _, _, _, _, _, spellicon = GetItemInfo(spellid);
					end
				end
				if (isspell and isitem) then
					return nil, "AMBIGUOUS";
				elseif (isspell or isitem) then
					return spelltype, spellname, spellid, spelllink, spellicon;
				end
				return nil,"INVALID";
			end,
		},
		GetTotemMushroomsInfo = {
			Desc = [[Get Totem Mushrooms Statue]],
			Static = true,
			Func = function(index)
				local v1;
				if (type(index) == "string") then
					for i=1, 4 do
						local haveTotem, name, startTime, duration, icon = GetTotemInfo(i);
						if haveTotem and index == name then
							local v = duration - (GetTime()-startTime);
							if v < 0 then
								v = 0;
							end
							if not v1 then
								v1 = v;
							elseif v < v1 then
								v1 = v;
							end
						end
					end
					return v1 or -1;
				elseif (type(index) == "nil") then
					for i=1, 4 do
						local haveTotem, name, startTime, duration, icon = GetTotemInfo(i);
						if haveTotem then
							local v = duration - (GetTime()-startTime);
							if v < 0 then
								v = 0;
							end
							if not v1 then
								v1 = v;
							elseif v < v1 then
								v1 = v;
							end
						end
					end
					return v1 or -1;
				elseif (type(index) == "number") then
					local haveTotem, name, startTime, duration, icon = GetTotemInfo(index);
					if not haveTotem then
						return -1;
					end
					local cd = duration - (GetTime()-startTime) ;
					if cd < 0 then
						cd = 0;
					end
					return cd;				
				end
			end,
		},
		GetAmbience = {
			Desc = [[Get the ambience units]],
			Static = true,
			Func = function(objType, isFriend, scale, center)
				local AllUnit;
				if (type(objType) == "boolean") then
					AllUnit = UnitIsPlayer;
				elseif (objType == nil) then
					AllUnit = UnitExists;
					objType = true;
				end
				if (isFriend == true) then
					isFriend = UnitCanCooperate;
				elseif (isFriend == false) then
					isFriend = UnitCanAttack;
				elseif (isFriend == nil) then
					isFriend = UnitExists;
				end
				if (type(scale) ~= "number") then
					scale = 100;
				end
				if (type(center) ~= "string") then
					center = "player";
				end
				local resultTable = {};
					for i=1,GetObjectCount() do
						local thisUnit = GetObjectWithIndex(i);
						if ObjectExists(thisUnit) and bit.band(ObjectType(thisUnit), ObjectTypes.Unit)>0 then
							if AllUnit(thisUnit) == objType and isFriend(thisUnit,center) and not UnitIsDeadOrGhost(thisUnit) then
								if msGD(thisUnit, center) < scale then
									tinsert(resultTable,thisUnit);
								end
							end
						end
					end
				return resultTable;
			end,
		},
		-- CheckAutoAttacking = {
			-- Desc = [[Check whether the player is auto attacking]],
			-- Static = true,
			-- Func = function()
				-- return IsAutoAttacking;
			-- end,
		-- },
		GetBuffDesc = {
			Desc = [[Get the dedicated buff's description]],
			Static = true,
			Func = function(unit, index)
				if (type(unit) ~= "string" or type(index) ~= "number") then
					return nil;
				end
				local buffName = UnitBuff(unit, index);
				if (type(buffName) ~= "string" or buffName == "") then
					return nil;
				end
				Tooltip:ClearLines();
				Tooltip:SetOwner(UIParent, 'ANCHOR_NONE');
				Tooltip:SetUnitBuff(unit, index);
				local i = 1;
				local result = "";
				local textobject = getglobal("StoneDataTooltipTextLeft1");
				while(textobject) do
					local text = textobject:GetText();
					if (type(text) == "string" and text ~= buffName) then
						result = result .. textobject:GetText();
						if (strtrim(text) ~= "") then
							result = result .. "\n";
						end
					end
					i = i + 1;
					textobject = getglobal("StoneDataTooltipTextLeft" .. i);
				end
				return strtrim(result);
			end,
		},
		GetDebuffDesc = {
			Desc = [[Get the dedicated debuff's description]],
			Static = true,
			Func = function(unit, index)
				if (type(unit) ~= "string" or type(index) ~= "number") then
					return nil;
				end
				local buffName = UnitDebuff(unit, index);
				if (type(buffName) ~= "string" or buffName == "") then
					return nil;
				end
				Tooltip:ClearLines();
				Tooltip:SetOwner(UIParent, 'ANCHOR_NONE');
				Tooltip:SetUnitDebuff(unit, index);
				local i = 1;
				local result = "";
				local textobject = getglobal("StoneDataTooltipTextLeft1");
				while(textobject) do
					local text = textobject:GetText();
					if (type(text) == "string" and text ~= buffName) then
						result = result .. textobject:GetText();
						if (strtrim(text) ~= "") then
							result = result .. "\n";
						end
					end
					i = i + 1;
					textobject = getglobal("StoneDataTooltipTextLeft" .. i);
				end
				return strtrim(result);
			end,
		},
		GetbuffsDigital = {
			Desc = [[Get the dedicated buff's digital]],
			Static = true,
			Func = function(buffs, unit, buffCaster, harmful)
				if type(buffs) ~= "table" then
					return false;
				end
				local curName1, curCount1, curExpiration1, curCaster1, curId1;
				local curName2, curCount2, curExpiration2, curCaster2, curId2;
				local Remaining, Count;
				for i = 1, 40 do
					curName1, _, curCount1, _, _, curExpiration1, curCaster1, _, _, curId1 = UnitBuff(unit, i);
					curName2, _, curCount2, _, _, curExpiration2, curCaster2, _, _, curId2 = UnitDebuff(unit, i);
					if (curName1 or curName2) then
						if (type(curCount1) == "number" and curCount1 < 1) then
							curCount1 = 1;
						end
						if (type(curCount2) == "number" and curCount2 < 1) then
							curCount2 = 1;
						end
						for j = 1, #buffs do
							local buffId = buffs[j]
							if (curId1 and (buffId == strtrim(curId1) or buffId == curName1) and (buffCaster == "*" or buffCaster and curCaster1 and UnitGUID(buffCaster) == UnitGUID(curCaster1)) and (harmful == nil or harmful == false)) then
								Count = curCount1;
								Remaining = (curExpiration1 - GetTime());
								if (Remaining < 0) then
									Remaining = 0;
								end
								return true, Remaining, Count;
							end
							if (curId2 and (buffId == strtrim(curId2) or buffId == curName2) and (buffCaster == "*" or buffCaster and curCaster2 and UnitGUID(buffCaster) == UnitGUID(curCaster2)) and (harmful == nil or harmful == true)) then
								Count = curCount2;
								Remaining = (curExpiration2 - GetTime());
								if (Remaining < 0) then
									Remaining = 0;
								end
								return true, Remaining, Count;
							end
						end
					else
						return false;
					end
				end
				return false;
			end,
		},
		ThrowError = {
			Desc = [[Throw an API error]],
			Static = true,
			Func = function(title, err)
				if (type(title) ~= "string" or type(err) ~= "string") then
					return false, "The parameters are invalid";
				end
				error(title .. ": " .. err, 3);
			end,
		},		
	},
};

System.WoWAPI = newclass(WoWAPIClassDef);
print("感谢使用HawPlus_classic.交流论坛： http://www.luacn.net/forum.php");

--------------------------------------------------------------------------------------
--							WoW <System.Config> Class								--
--------------------------------------------------------------------------------------
local function msrlUI()
	ReloadUI();
end
SlashCmdList["msrl"] = msrlUI;
SLASH_msrl1 = "/msrl";
SLASH_msrl2 = "/rl";


if (System.Config) then
	return;
end

local dewDrop = AceLibrary("Dewdrop-2.0");
local L = System.Locale:GetLocaleTable("HawPlus_classic");
local minimapIcon;

local function CreateMinimapIcon(name, iconPath, saveDB, tooltips, onLeftClick, onRightClick)
	local MinimapIcon = {};
	MinimapIcon.Name = name;
	if (not MinimapIcon.Name or not saveDB) then
		return nil;
	end
	MinimapIcon.IconPath = iconPath;
	MinimapIcon.SaveDB = saveDB;
	MinimapIcon.Tooltips = tooltips;
	MinimapIcon.OnLeftClick = onLeftClick;
	MinimapIcon.OnRightClick = onRightClick;
	MinimapIcon.DBIcon = LibStub("LibDBIcon-1.0", true);
	MinimapIcon.MinimapLDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(MinimapIcon.Name, {
		type = "data source",
		text = MinimapIcon.Name,
		icon = MinimapIcon.IconPath or "",
	});
	MinimapIcon.MinimapLDB.OnClick = function(self, button)
		if (button == "LeftButton") then
			if type(ScenarioButton) == "table" then
				if ScenarioButton:IsShown() then
					ScenarioButton:Hide()
				else
					ScenarioButton:Show()
				end
			end
			if (type(MinimapIcon.OnLeftClick) == "function") then
				MinimapIcon.OnLeftClick(self);
			end
		elseif (button == "RightButton") then
			if (type(MinimapIcon.OnLeftClick) == "function") then
				MinimapIcon.OnRightClick(self);
			end
		end
	end;
	MinimapIcon.MinimapLDB.OnTooltipShow = function(tt)
		tt:ClearLines();
		if (type(MinimapIcon.Tooltips) == "table") then
			local i;
			for i = 1, #MinimapIcon.Tooltips do
				tt:AddLine(MinimapIcon.Tooltips[i].text, MinimapIcon.Tooltips[i].r or 1, MinimapIcon.Tooltips[i].g or 1, MinimapIcon.Tooltips[i].b or 1);
			end
		end
	end
	MinimapIcon.Show = function(self)
		self.DBIcon:Show(self.Name);
	end
	MinimapIcon.Hide = function(self)
		self.DBIcon:Hide(self.Name);
	end
	if (MinimapIcon.DBIcon) then
		MinimapIcon.DBIcon:Register(MinimapIcon.Name, MinimapIcon.MinimapLDB, MinimapIcon.SaveDB);
		MinimapIcon.DBIcon:Show(MinimapIcon.Name);
		return MinimapIcon;
	else
		return nil;
	end
end
local SubMenus = {};
local function GenerateDropdownMenu()
	local menuInfo = {
		type = "group",
		handler = menuInfo,
		args = {},
	};
	for i = 1, #SubMenus do
		local menu = SubMenus[i];
		menuInfo.args[menu.Name] = {
			type = "group",
			name = menu.Name,
			desc = menu.Desc,
			args = menu.Args,
			order = menu.Order,
		};
	end
	return menuInfo;
end

System.OnLoad = function(self)
	local StoneAPIArchive = System.WTF("HawPlus_classic");
	StoneAPIArchive.Global.MinimapIcon = StoneAPIArchive.Global.MinimapIcon or {};
	minimapIcon = CreateMinimapIcon(
		"HawPlus_classic",
		[[INTERFACE\ICONS\inv_misc_orb_05]],
		StoneAPIArchive.Global.MinimapIcon,
		{{text = "|cFFFF7700" .. L["Intelligent Addons"]}},
		function(this)
			dewDrop:Open(
				this,
				"children",
				function()
					dewDrop:FeedAceOptionsTable(GenerateDropdownMenu());
				end
			);
		end,
		function(this)
			dewDrop:Open(
				this,
				"children",
				function()
					dewDrop:FeedAceOptionsTable(GenerateDropdownMenu());
				end
			);
		end
	);
end;

local SystemConfigClassDef = {
	Name = "System.Config",
	Functions = {
		AddMenu = {
			Desc = [[Add a config sub menu]],
			Static = true,
			Func = function(self, name, desc, order, value)
				if (type(name) ~= "string" or type(value) ~= "table") then
					return false, "Invalid param";
				end
				for i = 1, #SubMenus do
					if (SubMenus[i] == name) then
						return false, "Already exists.";
					end
				end
				local newMenu = {
					Name = name,
					Desc = desc,
					Order = order,
					Args = value,
				};
				tinsert(SubMenus, newMenu);
				return true;
			end,
		},
		RemoveMenu = {
			Desc = [[Remove an existing config sub menu]],
			Static = true,
			Func = function(self, name)
				if (type(name) ~= "string") then
					return false, "Invalid param";
				end
				for i = 1, #SubMenus do
					if (SubMenus[i] == name) then
						tremove(SubMenus, i);
						return true;
					end
				end
				return false, "Not found";
			end,
		},
	},
};

System.Config = newclass(SystemConfigClassDef);

hooksecurefunc(GameTooltip, "SetUnitBuff", function(self,...)
	local id = select(10,UnitBuff(...))
	if id then
		self:AddDoubleLine("|cFFFF7700MS|r|cFF00FF00BuffID:","|cFF00FF00" .. id)
		self:Show()
	end
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
	local id = select(10,UnitDebuff(...))
	if id then
		self:AddDoubleLine("|cFFFF7700MS|r|cFF00FF00BuffID:","|cFF00FF00" .. id)
		self:Show()
	end
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
	local id = select(10,UnitAura(...))
	if id then
		self:AddDoubleLine("|cFFFF7700MS|r|cFF00FF00BuffID:","|cFF00FF00" .. id)
		self:Show()
	end
end)

hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
	if string.find(link,"^spell:") then
		local id = string.sub(link,7)
		ItemRefTooltip:AddDoubleLine("SpellID:",id)
		ItemRefTooltip:Show()
	end
end)

--禁止弹出暴雪UI窗口
hooksecurefunc("StaticPopup_Show",function(self, ...)
	--print("StaticPopup:",...)
	--self:Hide()
	StaticPopup_Hide("ADDON_ACTION_FORBIDDEN")
	StaticPopup_Hide("MACRO_ACTION_FORBIDDEN")
end)

--[[
hooksecurefunc(StaticPopupDialogs["MACRO_ACTION_FORBIDDEN"],function(self,...)
	self:Close()
	self:Hide()
end)

hooksecurefunc(StaticPopupDialogs,"OnUpdate",function(self,...)
	self:Close()
	self:Hide()
end)]]

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local id = select(3,self:GetSpell())
	if id then
		self:AddDoubleLine("|cFFFF7700MS|r|cFF00FF00SPELLID:","|cFF00FF00" .. id)
		self:Show()
	end
end)

--[[GameTooltip:HookScript("OnTooltipSetItem", function(self)
	local name = self:GetItem()
	local ItemsResult = LibStub("LibStoneData-1.0"):GetItemInfoEx(name)
	print(ItemsResult)
	if ItemsResult then
		GameTooltip:AddDoubleLine("|cFFFF7700MS|r|cFF00FF00ITEMID:","|cFF00FF00" .. ItemsResult)
		GameTooltip:Show()
	end
end)]]
