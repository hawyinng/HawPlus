--------------------------------------------------------------------------------------
--								WoW Enhanced APIs									--
--------------------------------------------------------------------------------------
--	Provide the enhanced APIs														--
--------------------------------------------------------------------------------------
if (msRun) then
	return;
end

--UpValues
local strlower = string.lower;
local strupper = string.upper;
local strlen = string.len;
local strtrim = string.trim;
local strsplit = string.split;
local strfind = string.find;
local format = string.format;
local strsub = string.sub;
local pi = math.pi;
local tan = math.tan;
local abs = math.abs;
local atan = math.atan;
local sqrt = math.sqrt;
local pow = math.pow;
local API = System.WoWAPI;
local L = System.Locale:GetLocaleTable("HawPlus");
local ThrowError = API.ThrowError
local MG = LibStub("LibRangeCheck-2.0")

--对unit施放spell，并建立该spell的一个冷却时间cd秒
----------------------------------------------------------------------------------
local CustomCD = {};
local Face_x, Face_y, Face_z;
function msRun(spell, target, cd, Face)
	if (type(spell) ~= "string") then
		ThrowError("msRun(spell,unit,cd,Face)", L["The parameter %s are invalid."]);
		return nil;
	end
	spell = strtrim(spell);
	if (type(target) == "string") then
		target = strlower(strtrim(target));
		if (target=="") then
			target = nil;
		end
	end
	local isMacro,spelltype, spellname, spellid;
	if (strsub(spell, 1, 1) == "/") then
		isMacro = true;
	else
		spelltype, spellname, spellid = API.GetSpellItem(spell);
		if (spelltype) then
			spell = spellname;
		elseif (not spelltype) then
			if (spellname == "AMBIGUOUS") then
				ThrowError("msRun(spell,unit,cd,Face)", format(L["The spell or item name \"%s\" is ambiguous. Use the prefix to specify it."], spell));
				return nil;
			elseif (spellname == "INVALID") then
				ThrowError("msRun(spell,unit,cd,Face)", format(L["The spell or item name \"%s\" does not exist."], spell));
				return nil;
			else
				return nil;
			end
		else
			return nil;
		end
	end
	CustomCD[spell] = CustomCD[spell] or {};
	local lastcd = CustomCD[spell].Length or 0;
	local lastcasttime = msGetSpellCast("player",spell)
	if (lastcasttime < 0 or lastcasttime > lastcd) then
		if (isMacro) then
			_RunMacroText(spell);
		elseif (spelltype == "SPELL") then
			if not msPC() and msICA() and Face and UnitIsVisible(target) and UnitGUID("Player")~=UnitGUID(target) then
				local Facing = ObjectFacing("Player");
				Face_x, Face_y, Face_z = ObjectPosition(target)
				FaceDirection(GetAnglesBetweenObjects("Player",target))
				CastSpell_ByName(spell,target);
				FaceDirection(Facing);
			else
				CastSpell_ByName(spell,target);
			end
		elseif (spelltype == "ITEM") then
			if not msPC() and msICA() and Face and UnitIsVisible(target) and UnitGUID("Player")~=UnitGUID(target) then
				local Facing = ObjectFacing("Player");
				Face_x, Face_y, Face_z = ObjectPosition(target)
				FaceDirection(GetAnglesBetweenObjects("Player",target))
				_UseItemByName(spell,target);
				FaceDirection(Facing);
			else
				_UseItemByName(spell,target);
			end
		end
	else
		return false, L["The action to be run is not cooled down yet."], lastcd - lastcasttime;
	end
	if (type(cd) == "number" and cd > 0)then
		CustomCD[spell].Length = cd;
	end
	local x, y, z;
	if (msICA() and type(target) == "string" and UnitExists(target)) then
		x, y, z = ObjectPosition(target);
	elseif (type(target) == "table") then
		x, y, z = target[1], target[2], target[3];
	end
	if (type(x) == "number" and type(y) == "number" and type(z) == "number" and msICA() and IsAoEPending()) then
		ClickPosition(x, y, z,true);
		CancelPendingSpell()
	end

	return true, spell, target;
end
msR_ = msRun;

function CastSpell_ByName(spell, target)
  local target = target or "target"
  secured = false
  while not secured do
    RunScript([[
      for index = 1, 500 do
        if not issecure() then
          return
        end
      end
      CastSpellByName("]] .. spell .. [[", "]] .. target .. [[")
      secured = true
    ]])    
  end
end

function _RunMacroText(text)
	secured = false
    while not secured do
	    RunScript([[
		  for index = 1, 500 do
		    if not issecure() then
		      return
		    end
		  end
		  RunMacroText("]] .. text .. [[")
		  secured = true
		]])
	end
end

function _UseItemByName(spell, target)
	local target = target or "target"
	secured = false
	while not secured do
	    RunScript([[
	      for index = 1, 500 do
	        if not issecure() then
	          return
	        end
	      end
	      UseItemByName("]] .. spell .. [[", "]] .. target .. [[")
	      secured = true
	    ]])    
	end
	-- body
end

--------------------------------------------------------------------------------
--获取技能或物品spell是否可以对目标unit施放,是否忽略移动判断
----------------------------------------------------------------------------------
local function Checker1(target)
	local healthPercentage = msGHP(target);
	if (type(healthPercentage) == "number") then
		return healthPercentage > 0 and healthPercentage < 20;
	end
end
local BugSpellsID = {
[88685] = true,	--圣言术：佑
[88625] = true, --圣言术：罚
[88684] = true,	--圣言术：静
[93402] = true,	--阳炎术
[18562] = true,	--迅捷治愈
[24275] = Checker1,	--愤怒之锤(圣骑士)
[163201] = Checker1,--斩杀(战士战斗姿态)
[5308] = Checker1,	--斩杀(战士狂暴\防御姿态)
[53351] = Checker1,	--夺命射击(猎人)
};
local BugSpells = {};
for i, v in pairs(BugSpellsID) do
	spell = GetSpellInfo(i);
	if (spell) then
		BugSpells[spell] = v;
	end
end
function msISC(spell, target, move)
	if (not spell or type(spell) ~= "string") then
		ThrowError("msISC(spell,unit,beforehand,move)", L["The parameters are invalid."]);
		return nil;
	end
	local spelltype, spellname, spellId = API.GetSpellItem(spell);
	if (not spelltype) then
		if (spellname == "AMBIGUOUS") then
			return false, format(L["The spell or item name \"%s\" is ambiguous. Use the prefix to specify it."], spell);
		elseif (spellname == "INVALID") then
			return false, format(L["The spell or item name \"%s\" does not exist."], spell);
		else
			return false;
		end
	end
	spell = spellname;
	if (type(target) == "string") then
		target = strlower(strtrim(target));
		if (target == "") then
			target = nil;
		end
	end
	if (target and not UnitGUID(target)) then
		return false, format(L["The unit(%s) does not exist."], target);
	end
	if (spelltype == "ITEM") then
		if (not IsUsableItem(spell)) then
			return false, format(L["The spell or item name \"%s\" is incapable to be used."], spell);
		end
		local starttime, duration = GetItemCooldown(spellId);
		local nowtime = GetTime();
		if (starttime) then
			if (nowtime - starttime < duration) then
				return false, format(L["The spell or item name \"%s\" is not cooled down yet, %s remaining."], spell, duration - (nowtime - starttime));
			end
		end
		if (ItemHasRange(spell) and target and not IsIteminRange(spell, target)) then
			return false, format(L["SYSTEM_OUTOFRANGE"], spell, target);
		end
	elseif (spelltype == "SPELL") then
		local starttime, duration = GetSpellCooldown(spellId);
		--print(starttime, duration)
		local nowtime = GetTime();
		local casttime = select(4, GetSpellInfo(spellId));
		--print(casttime)
		--if (starttime and nowtime - starttime < (duration-0.01)) then
		if (starttime and (nowtime - starttime < duration)) then
			return false, format(L["The spell or item name \"%s\" is not cooled down yet, %s remaining."], spell, duration - (nowtime - starttime));
		end
		if (casttime > 0 and GetUnitSpeed("player") > 0 and not msGUB("灵狐守护,灵魂行者的恩赐,基尔加丹的狡诈,浮冰","player") and not move) then
			return false, L["The player is moving."];
		end
		if (not IsUsableSpell(spellId)) then
			if (not BugSpells[spell]) then
				return false, format(L["The spell or item name \"%s\" is incapable to be used."], spell);
			elseif (type(BugSpells[spell]) == "function" and not BugSpells[spell](target)) then
				return false, format(L["The spell or item name \"%s\" is incapable to be used."], spell);
			end
		end
		if (IsAutoRepeatSpell(spell)) then
			return false, format(L["The spell or item name \"%s\" is incapable to be used."], spell);
		end
		if (casttime == 0 and IsCurrentSpell(spell)) then
			return false, format(L["The spell or item name \"%s\" is incapable to be used."], spell);
		end
		--IsSpellInRange(index, "type", target)
		local isInRange = IsSpellInRange(spell, target);
		if (isInRange == 0) then
			return false, format(L["SYSTEM_OUTOFRANGE"], spell, target);
		end
		if (target) then
			if (not UnitCanAssist("player", target) and not UnitCanAttack("player", target)) then
				return false, format(L["The spell or item name \"%s\" is incapable to be used to unit (%s)."], spell, target);
			end
			if (not isInRange) then
				local _, _, _, _, minRange, maxRange = GetSpellInfo(spell);
				local lastMinRange, lastMaxRange = MG:GetRange(target);
				if ((minRange and minRange>0 and lastMinRange and lastMinRange < minRange) or (maxRange and maxRange>0 and lastMaxRange and lastMaxRange > maxRange)) then
					return false, format(L["SYSTEM_OUTOFRANGE"], spell, target);
				-- elseif FireHack and (minRange and minRange>0 and msGD(target) < minRange or maxRange and maxRange>0 and msGD(target) > maxRange) then
					-- return false, format(L["SYSTEM_OUTOFRANGE"], spell, target);
				end
			end
		end
	else
		return false, format(L["The spell or item name \"%s\" does not exist."], spell);
	end
	return true,spell,target;
end
----------------------------------------------------------------------------------

--重置自定义冷却
----------------------------------------------------------------------------------
function msRC(spell, target, cd)
	if (type(spell) ~= "string") then
		ThrowError("msRC(spell,unit,cd)", L["The parameters are invalid."]);
		return nil;
	end
	if (type(cd) ~= "number") then
		cd = 0;
	end
	spell = strtrim(spell);
	local isMacro;
	if (strsub(spell, 1, 1) == "/") then
		isMacro = true;
	else
		local spelltype, spellname = API.GetSpellItem(spell);
		if (not spelltype) then
			if (spellname == "AMBIGUOUS") then
				ThrowError("msRC(spell, target, cd)", format(L["The spell or item name \"%s\" is ambiguous. Use the prefix to specify it."], spell));
				return nil;
			elseif (spellname == "INVALID") then
				ThrowError("msRC(spell, target, cd)", format(L["The spell or item name \"%s\" does not exist."], spell));
				return nil;
			else
				return nil;
			end
		end
		if spelltype then
			spell = spellname;
		else
			return nil;
		end
	end
	CustomCD[spell] = CustomCD[spell] or {};
	CustomCD[spell].Length = cd;
	return true;
end
----------------------------------------------------------------------------------

--获取自定义冷却
----------------------------------------------------------------------------------
function msGCC(spell)
	if (type(spell) ~= "string") then
		ThrowError("msGCC(spell,unit)", L["The parameters are invalid."]);
		return nil;
	end
	if (type(cd) ~= "number") then
		cd = 0;
	end
	spell = strtrim(spell);
	local macro;
	if (strsub(spell, 1, 1) == "/") then
		macro = spell;
	else
		local spelltype, spellname = API.GetSpellItem(spell);
		if (not spelltype) then
			if (spellname == "AMBIGUOUS") then
				ThrowError("msGCC(spell)", format(L["The spell or item name \"%s\" is ambiguous. Use the prefix to specify it."], spell));
				return nil;
			elseif (spellname == "INVALID") then
				ThrowError("msGCC(spell)", format(L["The spell or item name \"%s\" does not exist."], spell));
				return nil;
			else
				return nil;
			end
		end
		if spelltype then
			spell = spellname;
		else
			return nil;
		end
	end
	local lastcasttime = msGetSpellCast("player",spell)
	if CustomCD[spell] then
		lastcd = CustomCD[spell].Length or 0;
		if (lastcasttime < lastcd) then
			return lastcd - lastcasttime;
		else
			return 0;
		end
	else
		return 0;
	end
end
----------------------------------------------------------------------------------

--获取WOW客户端是否已经解锁
----------------------------------------------------------------------------------
function msICA()
	if (FireHack) then
		return true;
	else
		return false;
	end
end
----------------------------------------------------------------------------------

--判断目标unit的是否正在读spells法术中的任何一个[，并且可打断性为interruptable]
----------------------------------------------------------------------------------
function msICS(unit, spells, interruptable)
	if (type(unit) ~= "string") then
		unit = "target"
	end
	if (not UnitIsVisible(unit)) then
		return false, format(L["The unit(%s) does not exist."], unit);
	end
	if (type(spells) ~= "string") then
		spells = "*";
	else
		spells = strtrim(spells);
	end
	if (type(interruptable) ~= "boolean") then
		interruptable = nil;
	end
	local spell1, _, displayname1, starttime1, endtime1, _, _, interrupt1, spellId = UnitCastingInfo(unit);
	local spell2, _, displayname2, starttime2, endtime2, _, interrupt2 = UnitChannelInfo(unit);
	if (spells == "*") then
		if (spell1) then
			if (interrupt1 ~= nil and interruptable == interrupt1) then
				return false, format(L["The unit(%s) is casting a spell, but the interrupatability is not \"%s\"."], unit, tostring(interruptable));
			end
			return true, 1, spell1, (endtime1 - starttime1) / 1000, endtime1 / 1000 - GetTime(), GetTime() - starttime1 / 1000;
		elseif (spell2) then
			if (interrupt2 ~= nil and interruptable == interrupt2) then
				return false, format(L["The unit(%s) is casting a spell but the interrupatability is not \"%s\"."], unit, tostring(interruptable));
			end
			return true, 2, spell2, (endtime2 - starttime2) / 1000, endtime2 / 1000 - GetTime(), GetTime() - starttime2 / 1000;
		else
			return false, format(L["The unit(%s) is not casting any spell."], unit);
		end
	end
	local spells_array = {strsplit(",", spells)};
	for i = 1, #spells_array do
		local spell = strtrim(spells_array[i]);
		if (spell ~= "") then
			local spelltype, spellname = API.GetSpellItem(spell);
			if (spell1 and spell == spell1) or (spelltype and spell1 == spellname) then
				if (interrupt1 ~= nil and interruptable == interrupt1) then
					return false, format(L["The unit(%s) is casting a spell, but the interrupatability is not \"%s\"."], unit, tostring(interruptable));
				end
				return true, 1, spell1, (endtime1 - starttime1) / 1000, endtime1 / 1000 - GetTime(), GetTime() - starttime1 / 1000;
			end
			if (spell2 and spell == spell2) or (spelltype and spell2 == spellname) then
				if (interrupt2 ~= nil and interruptable == interrupt2) then
					return false, format(L["The unit(%s) is casting a spell but the interrupatability is not \"%s\"."], unit, tostring(interruptable));
				end
				return true, 2, spell2, (endtime2 - starttime2) / 1000, endtime2 / 1000 - GetTime(), GetTime() - starttime2 / 1000;
			end
		end
	end
	return false, format(L["The unit(%s) is not casting any of the dedicated spells."], unit);
end
----------------------------------------------------------------------------------

--获取目标读条技能的剩余时间及经历时间,msGCST("player")
----------------------------------------------------------------------------------
function msGCST(unit)
	if (type(unit) ~= "string") then
		unit = "target"
	end
	if (not UnitIsVisible(unit)) then
		return -1,-1, format(L["The unit(%s) does not exist."], unit);
	end
	--local spell1, _, _, _, starttime1, endtime1 = UnitCastingInfo(unit);
	--local spell2, _, _, _, starttime2, endtime2 = UnitChannelInfo(unit);
	local spell1, _, displayname1, starttime1, endtime1, _, _, interrupt1, spellId = UnitCastingInfo(unit);
	local spell2, _, displayname2, starttime2, endtime2, _, interrupt2 = UnitChannelInfo(unit);
	if (spell1) then
		return endtime1 / 1000 - GetTime(), GetTime() - starttime1 / 1000;
	elseif (spell2) then
		return endtime2 / 1000 - GetTime(), GetTime() - starttime2 / 1000;
	end
	return -1,-1, format(L["The unit(%s) is not casting any of the dedicated spells."], unit);
end
----------------------------------------------------------------------------------

--在目标group数组中根据过滤条件condition，获取value值最大的目标的GUID
----------------------------------------------------------------------------------
function msGetMax(condition,value,group)
	if type(condition)~="string" then
		condition = "UnitIsVisible(unit)";
	end
	if type(value)~="string" then
		value = "msGHP(unit)"
	end
	local guidtable = {};
	local Members,Unit;
	if type(group) == "string" or type(group) == "nil" then
		if group == "party" or group == "partypet" then
			Members = GetNumSubgroupMembers()+1;
		elseif group == "raid"  or group == "raidpet" then
			Members = GetNumGroupMembers();
		elseif group == "arena" then
			Members = 5;
		elseif group == "arenapet" then
			Members = 5;
		elseif type(group) == "nil" then
			group =  IsInRaid() and "raid" or "party"
			Members = IsInRaid() and GetNumGroupMembers() or (GetNumSubgroupMembers()+1);
		end
		for i=1, Members do
			if i == Members and group == "party" then
				Unit = "player";
			elseif i == Members and group == "partypet" then
				Unit = "pet";
			else
				Unit = group .. i;
			end
			tinsert(guidtable, Unit)
		end
	elseif type(group) == "table" and #group>0 then
		guidtable = group;
	else
		return false, L["The unit does not exist."];
	end
	local str = 'function Get_msmaximum(unit) if ' .. condition .. ' then return ' .. value .. '; else return false; end end';
	RunScript(str);
	local maximum = 0;
	local result;
	for i=1, #guidtable do
		local unit = guidtable[i];
		if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
			local tempval = Get_msmaximum(unit);
			if (type(tempval) == "number" and tempval > maximum) then
				maximum = tempval;
				result = unit;
			end
		end
	end
	return result,maximum;
end
----------------------------------------------------------------------------------

--在目标group数组中根据过滤条件condition，获取value值最小的目标的GUID
----------------------------------------------------------------------------------
function msGetMin(condition,value,group)
	if type(condition)~="string" then
		condition = "UnitIsVisible(unit)";
	end
	if type(value)~="string" then
		value = "msGHP(unit)"
	end
	local guidtable = {};
	local Members,Unit;
	if type(group) == "string" or type(group) == "nil" then
		if group == "party" or group == "partypet" then
			Members = GetNumSubgroupMembers()+1;
		elseif group == "raid"  or group == "raidpet" then
			Members = GetNumGroupMembers();
		elseif group == "arena" then
			Members = 5;
		elseif group == "arenapet" then
			Members = 5;
		elseif type(group) == "nil" then
			group =  IsInRaid() and "raid" or "party"
			Members = IsInRaid() and GetNumGroupMembers() or (GetNumSubgroupMembers()+1);
		end
		for i=1, Members do
			if i == Members and group == "party" then
				Unit = "player";
			elseif i == Members and group == "partypet" then
				Unit = "pet";
			else
				Unit = group .. i;
			end
			tinsert(guidtable, Unit)
		end
	elseif type(group) == "table" and #group>0 then
		guidtable = group;
	else
		return false, L["The unit does not exist."];
	end
	local str = 'function Get_msminimum(unit) if ' .. condition .. ' then return ' .. value .. '; else return false; end end';
	RunScript(str);
	local minimum = 999999999;
	local result;
	for i=1, #guidtable do
		local unit = guidtable[i];
		if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
			local tempval = Get_msminimum(unit);
			if (type(tempval) == "number" and tempval < minimum) then
				minimum = tempval;
				result = unit;
			end
		end
	end
	return result,minimum;
end

function msGetMinS(condition,value,group)
	if (not condition or type(condition)~="string") then
		condition = "UnitIsVisible(unit)";
	end
	if not value or type(value)~="string" then
		value = "msGHP(unit)"
	end
	local guidtable = {};
	local Members,Unit;

	if type(group) == "string" or type(group) == "nil" then
		if group == "party" or group == "partypet" then
			Members = GetNumSubgroupMembers()+1;
		elseif group == "raid"  or group == "raidpet" then
			Members = GetNumGroupMembers();
		elseif group == "arena" then
			Members = 5;
		elseif group == "arenapet" then
			Members = 5;
		elseif type(group) == "nil" then
			group =  IsInRaid() and "raid" or "party"
			Members = IsInRaid() and GetNumGroupMembers() or (GetNumSubgroupMembers()+1);
		end

		for i=1, Members do
			if i == Members and group == "party" then
				Unit = "player";
			elseif i == Members and group == "partypet" then
				Unit = "pet";
			else
				Unit = group .. i;
			end
			local tempval = msGHP(Unit);
			--print("hp = ".. tempval)
			tinsert(guidtable, {unit=Unit,hp=tempval})
		end

	elseif type(group) == "table" and #group>0 then
		for k, v in ipairs(group) do
			--print(k,v)
			local tempval = msGHP(v);
			tinsert(guidtable, {unit=v,hp=tempval})
		end
	else
		return false, L["The unit does not exist."];
	end

 	table.sort(guidtable, function(x,y) return x.hp<y.hp end)

 	local str = 'function Get_msminimum(unit) if ' .. condition .. ' then return ' .. value .. '; else return false; end end';
	RunScript(str);

	local minimum = 999999999;
	local result;
	local unit = guidtable[1].unit
	if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and not LineOfSight(unit) then
		result = guidtable[1].unit;
		minimum = Get_msminimum(result);
	elseif UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and LineOfSight(unit) and guidtable[2].unit~=nil then
		result = guidtable[2].unit;
		minimum = Get_msminimum(result);
	end

	local sndmin = nil;
	if #guidtable>=2 then
		if guidtable[2].unit~=nil then
			local min_s = guidtable[2].unit;
			if UnitIsVisible(min_s) and not UnitIsDeadOrGhost(min_s) then
				sndmin = guidtable[2].unit;
			end
		end
	end

	return result,minimum,sndmin;
end

----------------------------------------------------------------------------------

--在目标group数组中寻找符合条件condition的目标（组）
----------------------------------------------------------------------------------
function msFindUnit(condition,group,issingle)
	if type(condition)~="string" then
		condition = "UnitIsVisible(unit)";
	end
	local guidtable = {};
	local Members,Unit;
	if type(group) == "string" or type(group) == "nil" then
		if group == "party" or group == "partypet" then
			Members = GetNumSubgroupMembers()+1;
		elseif group == "raid" or group == "raidpet" then
			Members = GetNumGroupMembers();
		elseif group == "arena" then
			Members = 5;
		elseif group == "arenapet" then
			Members = 5;
		elseif type(group) == "nil" then
			group =  IsInRaid() and "raid" or "party"
			Members = IsInRaid() and GetNumGroupMembers() or (GetNumSubgroupMembers()+1);
		end
		for i=1, Members do
			if i == Members and group == "party" then
				Unit = "player";
			elseif i == Members and group == "partypet" then
				Unit = "pet";
			else
				Unit = group .. i;
			end
			tinsert(guidtable, Unit)
		end
	elseif type(group) == "table" then
		guidtable = group;
	-- else
		-- return false, L["The unit does not exist."];
	end
	local str = 'function Get_msfindunit(unit) if ' .. condition .. ' then return true; else return false; end end';
	RunScript(str);
	local msfindunit_result = {};
	for i=1, #guidtable do
		local unit = guidtable[i];
		if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
			if (Get_msfindunit(unit)) then
				if (issingle) then
					tinsert(msfindunit_result,unit);
				else
					return unit;
				end
			end
		end
	end
	if (not issingle) then
		return false, L["The unit does not exist."];
	else
		return msfindunit_result;
	end
end
----------------------------------------------------------------------------------

--在目标guidtable数组中寻找最密集的目标(密集程度scale码,默认15码),默认自己身边41码内友方玩家
----------------------------------------------------------------------------------
function msFGC(scale,guidtable)
	if (not msICA()) then
		ThrowError("msFGC(scale,guidtable)", L["The WoW client is not activated."]);
		return nil;
	end
	if (not scale or type(scale)~="number") then
		scale = 10;
	end
	if (not guidtable or type(guidtable)~="table") then
		guidtable = msGetUnits(true,true,41);
	end
	if (#guidtable == 0) then
		return false, L["The unit does not exist."];
	end
	local Node = 0;
	local Gathering = {}
	for _, Target in ipairs(guidtable) do
		local Neighbors = 0;
		for _, Neighbor in ipairs(guidtable) do
			if msGD(Target,Neighbor) <= scale then
				Neighbors = Neighbors + 1;
			end
		end
		if Neighbors >= Node and Neighbors > 0 then
			tinsert(Gathering, Target);
			Node = Neighbors;
		end
	end
	if #Gathering > 0 then
		return Gathering[#Gathering];
	else
		return false, L["The unit does not exist."];
	end
end
----------------------------------------------------------------------------------

--判断unit1是否正在面向目标unit2
----------------------------------------------------------------------------------
function msIF(unit1, unit2, delta)
	if (not msICA()) then
		ThrowError("msIF(unit,unit2,delta)", L["The WoW client is not activated."]);
		return nil;
	end
	if (type(unit1) ~= "string") then
		unit1 = "target"
	end
	if (not UnitGUID(unit1)) then
		return false, format(L["The unit(%s) does not exist."], unit1);
	end
	if (type(unit2) ~= "string") then
		unit2 = "player"
	end
	if (not UnitGUID(unit2)) then
		return false, format(L["The unit(%s) does not exist."], unit2);
	end
	if (type(delta) ~= "number") then
		delta = pi / 2;
	end
	if (delta < 0 or delta > pi / 2) then
		ThrowError("msIF(unit,unit2,delta)", format(L["The parameter %s which must be within %s and %s is invalid."], "delta", "0", "pi/2"));
		return nil;
	end
	if (UnitGUID(unit1) == UnitGUID(unit2)) then
		return true;
	end
	local x2, y2, z2 = ObjectPosition(unit1);
	--local r2 = ObjectFacing(unit1);
	local x1, y1, z1 = ObjectPosition(unit2);
	local r1 = ObjectFacing(unit2);
	if (type(x1) == "number" and type(x2) == "number") then
		local guage = atan((y2 - y1) / (x2 - x1));
		if (guage < 0) then
			guage = guage + pi;
		end
		if (y2 < y1) then
			guage = guage + pi;
		end
		local curdelta = abs(r1 - guage);
		if (curdelta < pi) then
			return curdelta <= delta;
		else
			return pi * 2 - curdelta <= delta;
		end
	else
		return false, format(L["The unit(%s) does have a location coordinate."], unit1);
	end
end
----------------------------------------------------------------------------------

--判断unit1是否正在面向目标unit2的背后
----------------------------------------------------------------------------------
function msIFB(unit1, unit2)
	if (not msICA()) then
		ThrowError("msIF(unit,unit2)", L["The WoW client is not activated."]);
		return nil;
	end
	if (type(unit1) ~= "string") then
		unit1 = "target"
	end
	if (not UnitIsVisible(unit1)) then
		return false, format(L["The unit(%s) does not exist."], unit1);
	end
	if (type(unit2) ~= "string") then
		unit2 = "player"
	end
	if (not UnitIsVisible(unit2)) then
		return false, format(L["The unit(%s) does not exist."], unit2);
	end
	if (UnitGUID(unit1) == UnitGUID(unit2)) then
		return false, L["The parameter unit cannnot be the player."];
	end
	local x, y, z = ObjectPosition(unit2);
	local r = ObjectFacing(unit2);
	local x0, y0, z0 = ObjectPosition(unit1);
	local r0 = ObjectFacing(unit1)
	if (x and x0) then
		local liney = (x0 - x) / tan(r0) + y0;
		local flag1;
		if (r0 >= 0 and r0 < pi) then
			flag1 = (y <= liney);
		else
			flag1 = (y >= liney);
		end
		local flag2 = (abs(r - r0) <= pi * 0.5 or abs(r - r0) >= pi * 1.5);
		return flag1 and flag2 and msIF(unit1, unit2, pi / 3);
	else
		return false, format(L["The unit(%s) does have a location coordinate."], unit1);
	end
end
----------------------------------------------------------------------------------

--判断指定目标是否在视野中
----------------------------------------------------------------------------------
function msII(unit1, unit2)
	if (not msICA()) then
		ThrowError("msII(unit1, unit2)", L["The WoW client is not activated."]);
		return false;
	end
		unit1 = unit1 or "target";
		unit2 = unit2 or "player";
	if (type(unit2) ~= "table" and not UnitIsVisible(unit1)) then
		return false, format(L["The unit(%s) does not exist."], unit1);
	end
	if (type(unit2) ~= "table" and not UnitIsVisible(unit2)) then
		return false, format(L["The unit(%s) does not exist."], unit2);
	end
	local x1, y1, z1, x2, y2, z2;
	if (type(unit1) == "string") then
		x1, y1, z1 = ObjectPosition(unit1);
	elseif (type(unit1) == "table") then
		x1, y1, z1 = unit1[1], unit1[2], unit1[3];
	end
	if (type(unit2) == "string") then
		x2, y2, z2 = ObjectPosition(unit2);
	elseif (type(unit2) == "table") then
		x2, y2, z2 = unit2[1], unit2[2], unit2[3];
	end
	if (type(x1) ~= "number" or type(y1) ~= "number" or type(z1) ~= "number") then
		return false, L["The position given is invalid."];
	end
	if (type(x2) ~= "number" or type(y2) ~= "number" or type(z2) ~= "number") then
		return false, L["The position given is invalid."];
	end
	--local losFlags =  bit.bor(0x10, 0x100)
	if TraceLine(x1, y1, z1 + 2, x2, y2, z2 + 2, 0x10) then
		return false;
	else
		return true;
	end
end
----------------------------------------------------------------------------------

--判断unit是否正在移动
----------------------------------------------------------------------------------
function msIM(unit)
	if (type(unit) ~= "string") then
		unit = "player";
	end
	return GetUnitSpeed(unit) > 0;
end
----------------------------------------------------------------------------------

--判断指定玩家是否正在自动攻击
----------------------------------------------------------------------------------
--Auto Attack
local IsAutoAttacking = false;
local StartAutoAttackingEvent = System.Event("PLAYER_ENTER_COMBAT");
StartAutoAttackingEvent.OnTriggered = function(self)
	IsAutoAttacking = true;
end
local EndAutoAttackingEvent = System.Event("PLAYER_LEAVE_COMBAT");
EndAutoAttackingEvent.OnTriggered = function(self)
	IsAutoAttacking = false;
end
function msIAA()
	return IsAutoAttacking;
end
----------------------------------------------------------------------------------

--获取目标unit的生命值百分比
----------------------------------------------------------------------------------
function msGHP(unit)
	if (type(unit) ~= "string") then
		unit = "player";
	end
	if (not UnitGUID(unit)) then
		return -1, format(L["The unit(%s) does not exist."], unit);
	end
	local health = UnitHealth(unit);
	local healthmax = UnitHealthMax(unit);
	if (type(health) == "number" and type(healthmax) == "number" and healthmax > 0) then
		return health / healthmax * 100;
	else
		return -1, format(L["The unit(%s) does not have health."], unit);
	end
end
----------------------------------------------------------------------------------

--获取目标unit的能量值百分比
----------------------------------------------------------------------------------
function msGPP(unit)
	if (type(unit) ~= "string") then
		unit = "player";
	end
	if (not UnitGUID(unit)) then
		return -1, format(L["The unit(%s) does not exist."], unit);
	end
	local power = UnitPower(unit);
	local powermax = UnitPowerMax(unit);
	if (type(power) == "number" and type(powermax) == "number" and powermax > 0) then
		return power / powermax * 100;
	else
		return -1, format(L["The unit(%s) does not have power."], unit);
	end
end
----------------------------------------------------------------------------------

--通过指定buff名称（可指定多个名称），获取指定unit的指定buff信息
----------------------------------------------------------------------------------
function msGBBN(unit, buffNames, buffCaster, harmful)
	if (type(unit) ~= "string") then
		unit = "player";
	end
	if (not UnitGUID(unit)) then
		return false, format(L["The unit(%s) does not exist."], unit);
	end
	buffNames = buffNames or "*";
	if (type(buffNames) ~= "string" and type(buffNames) ~= "table") then
		ThrowError("msGBBN(unit,buffNames,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffNames", L["string"] .. " or " .. L["table"]));
		return false;
	end
	if (type(buffNames) == "string") then
		buffNames = {strsplit(",", buffNames)};
	elseif (type(buffNames) == "table") then
		for i = 1, #buffNames do
			if (type(buffNames[i]) ~= "string") then
				ThrowError("msGBBN(unit,buffNames,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffNames[" .. tostring(i) .. "]", L["string"]));
				return false;
			end
		end
	end
	buffCaster = buffCaster or "*";
	if (buffCaster ~= nil and type(buffCaster) ~= "string") then
		ThrowError("msGBBN(unit,buffNames,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffCaster", L["string"]));
		return false;
	end
	if (harmful ~= nil and type(harmful) ~= "boolean") then
		ThrowError("msGBBN(unit,buffNames,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "harmful", L["boolean"]));
		return false;
	end
	local curName1, curIcon1, curCount1, curType1, curExpiration1, curCaster1, curId1, curDesc1;
	local curName2, curIcon2, curCount2, curType2, curExpiration2, curCaster2, curId2, curDesc2;
	local resultBuffsByNames = {};
	for i = 1, 40 do
		curName1, _, curIcon1, curCount1, curType1, _, curExpiration1, curCaster1, _, _, curId1 = UnitBuff(unit, i);
		curName2, _, curIcon2, curCount2, curType2, _, curExpiration2, curCaster2, _, _, curId2 = UnitDebuff(unit, i);
		if (curName1 or curName2) then
			if (type(curCount1) == "number" and curCount1 < 1) then
				curCount1 = 1;
			end
			if (type(curCount2) == "number" and curCount2 < 1) then
				curCount2 = 1;
			end
			if (curName1) then
				curType1 = curType1 or "None";
				curDesc1 = API.GetBuffDesc(unit, i);
			end
			if (curName2) then
				curType2 = curType2 or "None";
				curDesc2 = API.GetDebuffDesc(unit, i);
			end
			for j = 1, #buffNames do
				local buffName = strtrim(buffNames[j]);
				local found = false;
				if ((curName1 and (buffName == "*" or buffName == curName1)) and (buffCaster == "*" or buffCaster and curCaster1 and UnitGUID(buffCaster) == UnitGUID(curCaster1)) and (harmful == nil or harmful == false)) then
					local newBuff = {Name = curName1, Icon = curIcon1, Harmful = false, Count = curCount1, Type = curType1, Remaining = (curExpiration1 - GetTime()), Caster = curCaster1, Id = curId1, Desc = curDesc1};
					if (newBuff.Remaining < 0) then
						newBuff.Remaining = 0;
					end
					tinsert(resultBuffsByNames, newBuff);
					found = true;
				end
				if ((curName2 and (buffName == "*" or buffName == curName2)) and (buffCaster == "*" or buffCaster and curCaster2 and UnitGUID(buffCaster) == UnitGUID(curCaster2)) and (harmful == nil or harmful == true)) then
					local newBuff = {Name = curName2, Icon = curIcon2, Harmful = true, Count = curCount2, Type = curType2, Remaining = (curExpiration2 - GetTime()), Caster = curCaster2, Id = curId2, Desc = curDesc2};
					if (newBuff.Remaining < 0) then
						newBuff.Remaining = 0;
					end
					tinsert(resultBuffsByNames, newBuff);
					found = true;
				end
				if (found) then
					break;
				end
			end
		else
			break;
		end
	end
	return resultBuffsByNames;
end
----------------------------------------------------------------------------------

--通过指定buff对应的技能Id（可指定多个Id），获取指定unit的指定buff信息
----------------------------------------------------------------------------------
function msGBBI(unit, buffIds, buffCaster, harmful)
	if (type(unit) ~= "string") then
		ThrowError("msGBBI(unit,buffIds,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "unit", L["string"]));
		return false;
	end
	if (not UnitGUID(unit)) then
		return false, format(L["The unit(%s) does not exist."], unit);
	end
	buffIds = buffIds or "*";
	if (type(buffIds) ~= "string" and type(buffIds) ~= "table" and type(buffIds) ~= "number") then
		ThrowError("msGBBI(unit,buffIds,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffIds", L["string"] .. " or " .. L["table"] .. " or " .. L["number"]));
		return false;
	end
	if (type(buffIds) == "number") then
		buffIds = {buffIds};
	elseif (type(buffIds) == "string") then
		buffIds = strtrim(buffIds);
		buffIds = {strsplit(",", buffIds)};
		for i = 1, #buffIds do
			if (buffIds[i] ~= "*") then
				local buffId = tonumber(buffIds[i]);
				if (type(buffId) == "number") then
					buffIds[i] = buffId;
				else
					ThrowError("msGBBI(unit,buffIds,buffCaster,harmful)", L["The parameter buffIds is invalid."]);
					return false;
				end
			end
		end
	elseif (type(buffIds) == "table") then
		for i = 1, #buffIds do
			local buffId = tonumber(buffIds[i]);
			if (type(buffId) == "number") then
				buffIds[i] = buffId;
			else
				ThrowError("msGBBI(unit,buffIds,buffCaster,harmful)", L["The parameter buffIds is invalid."]);
				return false;
			end
		end
	end
	buffCaster = buffCaster or "*";
	if (buffCaster ~= nil and type(buffCaster) ~= "string") then
		ThrowError("msGBBN(unit,buffNames,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffCaster", L["string"]));
		return false;
	end
	if (harmful ~= nil and type(harmful) ~= "boolean") then
		ThrowError("msGBBN(unit,buffNames,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "harmful", L["boolean"]));
		return false;
	end
	local curName1, curRank1, curIcon1, curCount1, curType1, curExpiration1, curCaster1, curId1;
	local curName2, curRank2, curIcon2, curCount2, curType2, curExpiration2, curCaster2, curId2;
	local resultBuffsByIds = {};
	for i = 1, 40 do
		curName1, curRank1, curIcon1, curCount1, curType1, _, curExpiration1, curCaster1, _, _, curId1 = UnitBuff(unit, i);
		curName2, curRank2, curIcon2, curCount2, curType2, _, curExpiration2, curCaster2, _, _, curId2 = UnitDebuff(unit, i);
		if (curName1 or curName2) then
			if (type(curCount1) == "number" and curCount1 < 1) then
				curCount1 = 1;
			end
			if (type(curCount2) == "number" and curCount2 < 1) then
				curCount2 = 1;
			end
			if (curName1) then
				curType1 = curType1 or "None";
				curDesc1 = API.GetBuffDesc(unit, i);
			end
			if (curName2) then
				curType2 = curType2 or "None";
				curDesc2 = API.GetDebuffDesc(unit, i);
			end
			for j = 1, #buffIds do
				buffId = buffIds[j];
				local found = false;
				if ((curId1 and (buffId == "*" or buffId == curId1)) and (buffCaster == "*" or buffCaster and curCaster1 and UnitGUID(buffCaster) == UnitGUID(curCaster1)) and (harmful == nil or harmful == false)) then
					local newBuff = {Name = curName1, Rank = curRank1, Icon = curIcon1, Harmful = false, Count = curCount1, Type = curType1, Remaining = (curExpiration1 - GetTime()), Caster = curCaster1, Id = curId1, Desc = curDesc1};
					if (newBuff.Remaining < 0) then
						newBuff.Remaining = 0;
					end
					tinsert(resultBuffsByIds, newBuff);
					found = true;
				end
				if ((curId2 and (buffId == "*" or buffId == curId2)) and (buffCaster == "*" or buffCaster and curCaster2 and UnitGUID(buffCaster) == UnitGUID(curCaster2)) and (harmful == nil or harmful == true)) then
					local newBuff = {Name = curName2, Rank = curRank2, Icon = curIcon2, Harmful = true, Count = curCount2, Type = curType2, Remaining = (curExpiration2 - GetTime()), Caster = curCaster2, Id = curId2, Desc = curDesc2};
					if (newBuff.Remaining < 0) then
						newBuff.Remaining = 0;
					end
					tinsert(resultBuffsByIds, newBuff);
					found = true;
				end
				if (found) then
					break;
				end
			end
		else
			break;
		end
	end
	return resultBuffsByIds;
end
----------------------------------------------------------------------------------

--通过指定buff的类型，获取指定unit的指定buff信息
----------------------------------------------------------------------------------
function msGBBT(unit, buffTypes, buffCaster, harmful)
	if (type(unit) ~= "string") then
		unit = "player";
	end
	if (not UnitGUID(unit)) then
		return nil, format(L["The unit(%s) does not exist."], unit);
	end
	buffTypes = buffTypes or "*";
	if (type(buffTypes) ~= "string" and type(buffTypes) ~= "table") then
		ThrowError("msGBBT(unit,buffTypes,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffTypes", L["string"] .. " or " .. L["table"]));
		return false;
	end
	if (type(buffTypes) == "string") then
		buffTypes = {strsplit(",", buffTypes)};
	elseif (type(buffTypes) == "table") then
		for i = 1, #buffTypes do
			if (type(buffTypes[i]) ~= "string") then
				ThrowError("msGBBT(unit,buffTypes,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffTypes[" .. tostring(i) .. "]", L["string"]));
				return false;
			end
		end
	end
	buffCaster = buffCaster or "*";
	if (buffCaster ~= nil and type(buffCaster) ~= "string") then
		ThrowError("msGBBT(unit,buffTypes,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffCaster", L["string"]));
		return false;
	end
	if (harmful ~= nil and type(harmful) ~= "boolean") then
		ThrowError("msGBBT(unit,buffTypes,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "harmful", L["boolean"]));
		return false;
	end
	local curName1, curRank1, curIcon1, curCount1, curType1, curExpiration1, curCaster1, curId1;
	local curName2, curRank2, curIcon2, curCount2, curType2, curExpiration2, curCaster2, curId2;
	local resultBuffsByTypes = {};
	for i = 1, 40 do
		curName1, curRank1, curIcon1, curCount1, curType1, _, curExpiration1, curCaster1, _, _, curId1 = UnitBuff(unit, i);
		curName2, curRank2, curIcon2, curCount2, curType2, _, curExpiration2, curCaster2, _, _, curId2 = UnitDebuff(unit, i);
		if (curName1 or curName2) then
			if (type(curCount1) == "number" and curCount1 < 1) then
				curCount1 = 1;
			end
			if (type(curCount2) == "number" and curCount2 < 1) then
				curCount2 = 1;
			end
			if (curName1) then
				curType1 = curType1 or "None";
				curDesc1 = API.GetBuffDesc(unit, i);
			end
			if (curName2) then
				curType2 = curType2 or "None";
				curDesc2 = API.GetDebuffDesc(unit, i);
			end
			for j = 1, #buffTypes do
				buffType = strtrim(buffTypes[j]);
				local found = false;
				if ((curType1 and (buffType == "*" or buffType == curType1)) and (buffCaster == "*" or buffCaster and curCaster1 and UnitGUID(buffCaster) == UnitGUID(curCaster1)) and(harmful == nil or harmful == false)) then
					local newBuff = {Name = curName1, Rank = curRank1, Icon = curIcon1, Harmful = false, Count = curCount1, Type = curType1, Remaining = (curExpiration1 - GetTime()), Caster = curCaster1, Id = curId1, Desc = curDesc1};
					if (newBuff.Remaining < 0) then
						newBuff.Remaining = 0;
					end
					tinsert(resultBuffsByTypes, newBuff);
					found = true;
				end
				if ((curType2 and (buffType == "*" or buffType == curType2)) and (buffCaster == "*" or buffCaster and curCaster2 and UnitGUID(buffCaster) == UnitGUID(curCaster2)) and (harmful == nil or harmful == true)) then
					local newBuff = {Name = curName2, Rank = curRank2, Icon = curIcon2, Harmful = true, Count = curCount2, Type = curType2, Remaining = (curExpiration2 - GetTime()), Caster = curCaster2, Id = curId2, Desc = curDesc2};
					if (newBuff.Remaining < 0) then
						newBuff.Remaining = 0;
					end
					tinsert(resultBuffsByTypes, newBuff);
					found = true;
				end
				if (found) then
					break;
				end
			end
		else
			break;
		end
	end
	return resultBuffsByTypes;
end
----------------------------------------------------------------------------------

--判断目标是否有指定魔法类型
----------------------------------------------------------------------------------
function msGBType(unit, buffTypes, buffCaster, harmful)
	if (type(unit) ~= "string") then
		unit = "target";
	end
	if (not UnitGUID(unit)) then
		return nil, format(L["The unit(%s) does not exist."], unit);
	end
	buffTypes = buffTypes or "*";
	if (type(buffTypes) ~= "string" and type(buffTypes) ~= "table") then
		ThrowError("msGBType(unit,buffTypes,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffTypes", L["string"] .. " or " .. L["table"]));
		return false;
	end
	if (type(buffTypes) == "string") then
		buffTypes = {strsplit(",", buffTypes)};
	elseif (type(buffTypes) == "table") then
		for i = 1, #buffTypes do
			if (type(buffTypes[i]) ~= "string") then
				ThrowError("msGBBT(unit,buffTypes,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffTypes[" .. tostring(i) .. "]", L["string"]));
				return false;
			end
		end
	end
	buffCaster = buffCaster or "*";
	if (buffCaster ~= nil and type(buffCaster) ~= "string") then
		ThrowError("msGBType(unit,buffTypes,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffCaster", L["string"]));
		return false;
	end
	if (harmful ~= nil and type(harmful) ~= "boolean") then
		ThrowError("msGBType(unit,buffTypes,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "harmful", L["boolean"]));
		return false;
	end
	for i = 1, 40 do
		local curName1, _, _, _, curType1, _, curCaster1 = UnitBuff(unit, i);
		local curName2, _, _, _, curType2, _, curCaster2 = UnitDebuff(unit, i);
		if (curName1) then
			curType1 = curType1 or "None";
		end
		if (curName2) then
			curType2 = curType2 or "None";
		end
		for j = 1, #buffTypes do
			buffType = strtrim(buffTypes[j]);
			if ((curType1 and (buffType == "*" or buffType == curType1)) and (buffCaster == "*" or buffCaster and curCaster1 and UnitGUID(buffCaster) == UnitGUID(curCaster1)) and (harmful == nil or harmful == false)) then
				return true;
			end
			if ((curType2 and (buffType == "*" or buffType == curType2)) and (buffCaster == "*" or buffCaster and curCaster2 and UnitGUID(buffCaster) == UnitGUID(curCaster2)) and (harmful == nil or harmful == true)) then
				return true;
			end
		end
	end
	return false;
end
----------------------------------------------------------------------------------

--获取指定目标unit拥有指定buffs的总数量
----------------------------------------------------------------------------------
function msGUBS(buffs, unit, buffCaster, harmful)
	if (type(buffs) ~= "string" and type(buffs) ~= "table" and type(buffs) ~= "number") then
		ThrowError("msGUB(buffs,unit,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffs", L["string"] .. " or " .. L["table"] .. " or " .. L["number"]));
		return false;
	elseif (type(buffs) ~= "table") then
		buffs = {strsplit(",", buffs)};
	end
	if (type(unit) ~= "string") then
		unit = "player";
	end
	if (not UnitGUID(unit)) then
		return 0, format(L["The unit(%s) does not exist."], unit);
	end
	buffCaster = buffCaster or "*";
	if (buffCaster ~= nil and type(buffCaster) ~= "string") then
		ThrowError("msGUB(buffs,unit,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffCaster", L["string"]));
		return false;
	end
	if (harmful ~= nil and type(harmful) ~= "boolean") then
		ThrowError("msGUB(buffs,unit,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "harmful", L["boolean"]));
		return false;
	end
	local Sum = 0;
	local curName1, curExpiration1, curCaster1, curId1;
	local curName2, curExpiration2, curCaster2, curId2;
	for i = 1, 40 do
		curName1, _, _, _, _, _, _, curCaster1, _, _, curId1 = UnitBuff(unit, i);
		curName2, _, _, _, _, _, _, curCaster2, _, _, curId2 = UnitDebuff(unit, i);
		if (curName1 or curName2) then
			for j = 1, #buffs do
				local buffId = buffs[j]
				if (curId1 and (buffId == strtrim(curId1) or buffId == curName1) and (buffCaster == "*" or buffCaster and curCaster1 and UnitGUID(buffCaster) == UnitGUID(curCaster1)) and (harmful == nil or harmful == false)) then
					Sum = Sum + 1;
				end
				if (curId2 and (buffId == strtrim(curId2) or buffId == curName2) and (buffCaster == "*" or buffCaster and curCaster2 and UnitGUID(buffCaster) == UnitGUID(curCaster2)) and (harmful == nil or harmful == true)) then
					Sum = Sum + 1;
				end
			end
		end
	end
	return Sum;
end
----------------------------------------------------------------------------------

--判断目标unit是否有指定buffs
----------------------------------------------------------------------------------
function msGUB(buffs, unit, buffCaster, harmful)
	if (type(buffs) ~= "string" and type(buffs) ~= "table" and type(buffs) ~= "number") then
		ThrowError("msGUB(buffs,unit,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffs", L["string"] .. " or " .. L["table"] .. " or " .. L["number"]));
		return false;
	elseif (type(buffs) ~= "table") then
		buffs = {strsplit(",", buffs)};
	end
	if (type(unit) ~= "string") then
		unit = "player";
	end
	if (not UnitGUID(unit)) then
		return false, format(L["The unit(%s) does not exist."], unit);
	end
	buffCaster = buffCaster or "*";
	if (buffCaster ~= nil and type(buffCaster) ~= "string") then
		ThrowError("msGUB(buffs,unit,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buffCaster", L["string"]));
		return false;
	end
	if (harmful ~= nil and type(harmful) ~= "boolean") then
		ThrowError("msGUB(buffs,unit,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "harmful", L["boolean"]));
		return false;
	end
		return API.GetbuffsDigital(buffs, unit, buffCaster, harmful);
end
----------------------------------------------------------------------------------

--获取目标unit指定buff的剩余时间
----------------------------------------------------------------------------------
function msGBT(buff, unit, buffCaster, harmful)
	if (type(buff) ~= "string" and type(buff) ~= "table" and type(buff) ~= "number") then
		ThrowError("msGBT(buff,unit,buffCaster,harmful)", format(L["The parameter %s is not a %s."], "buff", L["string"] .. " or " .. L["table"] .. " or " .. L["number"]));
		return -1;
	elseif (type(buff) ~= "table") then
		buff = {strsplit(",", buff)};
	end
	if (type(unit) ~= "string") then
		unit = "player";
	end
	if (not UnitGUID(unit)) then
		return -1, format(L["The unit(%s) does not exist."], unit);
	end
	if (type(buffCaster) ~= "string") then
		buffCaster = "*";
	end
	if (type(harmful) ~= "boolean") then
		harmful = nil;
	end
	local result, remaining = API.GetbuffsDigital(buff, unit, buffCaster, harmful);
	if 	result then
		return remaining;
	else
		return -1;
	end
end
----------------------------------------------------------------------------------

--获取目标unit指定buff的层数
----------------------------------------------------------------------------------
function msGBC(buff, unit, buffCaster, harmful)
	if (type(buff) ~= "string" and type(buff) ~= "table" and type(buff) ~= "number") then
		ThrowError("msGBC(buff, unit, buffCaster, harmful)", format(L["The parameter %s is not a %s."], "buff", L["string"] .. " or " .. L["table"] .. " or " .. L["number"]));
		return false;
	elseif (type(buff) ~= "table") then
		buff = {strsplit(",", buff)};
	end
	if (type(unit) ~= "string") then
		unit = "player";
	end
	if (not UnitGUID(unit)) then
		return -1, format(L["The unit(%s) does not exist."], unit);
	end
	if (type(buffCaster) ~= "string") then
		buffCaster = "*";
	end
	if (type(harmful) ~= "boolean") then
		harmful = nil;
	end
	local result, _, count = API.GetbuffsDigital(buff, unit, buffCaster, harmful);
	if 	result then
		return count;
	else
		return 0;
	end
end
----------------------------------------------------------------------------------

--获取unit指定buff类型的数量.
--[[
参数(可以多个以逗号,分隔):buffTypes
Curse	诅咒
Disease	疾病
Magic	魔法
Poison	毒药

参数:harmful
true	有害
false	有益(默认)
]]--
----------------------------------------------------------------------------------
function msGBS(buffTypes, unit, harmful)
	if (type(unit) ~= "string") then
		unit = "player";
	end
	if (not UnitGUID(unit)) then
		return 0, format(L["The unit(%s) does not exist."], unit);
	end
	if (type(buffTypes) ~= "string" and type(buffTypes) ~= "table") then
		ThrowError("msGBS(unit, buffTypes, harmful)", format(L["The parameter %s is not a %s."], "buffTypes", L["string"] .. " or " .. L["table"]));
		return false;
	end
	if (type(buffTypes) == "string") then
		buffTypes = {strsplit(",", buffTypes)};
	end
	local UnitDebuffORbuff,buffType;
	local number = 0;
	if harmful then
		UnitDebuffORbuff = UnitDebuff;
	else
		UnitDebuffORbuff = UnitBuff;
	end
	for i = 1, 40 do
		local name, _, _, _, dispelType = UnitDebuffORbuff(unit, i);
		for j = 1, #buffTypes do
			buffType = strtrim(buffTypes[j])
			if name and dispelType and buffType == dispelType then
				number = number + 1;
			end
		end
	end
	return number;
end
----------------------------------------------------------------------------------

--获取目标unit指定buff的描述	--msGBB(158300)	UnitBuff("player",158300)
----------------------------------------------------------------------------------
function msGBB(buff, unit)
	if (type(buff) ~= "string" and type(buff) ~= "number") then
		ThrowError("msGBB(buff,unit)", format(L["The parameter %s is not a %s."], "buff", L["string"] .. " or " .. L["number"]));
		return nil;
	end
	if (type(unit) ~= "string") then
		unit = "player";
	end
	if (not UnitGUID(unit)) then
		return nil, format(L["The unit(%s) does not exist."], unit);
	end
	buff = tonumber(buff)
	for i = 1, 40 do
		local curName1, _, _, _, _, _, _, _, _, curId1= UnitBuff(unit, i);
		local curName2, _, _, _, _, _, _, _, _, curId2 = UnitDebuff(unit, i);
		if curId1 and (buff == tonumber(curId1) or buff == curName1) then
			return API.GetBuffDesc(unit, i);
		end
		if curId2 and (buff == tonumber(curId2) or buff == curName2) then
			return API.GetDebuffDesc(unit, i);
		end
	end
end
----------------------------------------------------------------------------------

--获取目标1（或坐标表1）与目标2（或坐标表2）之间的精确距离（码）
----------------------------------------------------------------------------------
function msGD(unit1, unit2)
	if (not msICA()) then
		return 100;
	end
	if (type(unit1) ~= "table" and type(unit1) ~= "string") then
		unit1 = "target";
	end
	if (type(unit2) ~= "table" and type(unit2) ~= "string") then
		unit2 = "player";
	end
	if (type(unit1) == "string" and not UnitIsVisible(unit1)) then
		return 100, format(L["The unit(%s) does not exist."], unit1);
	end
	if (type(unit2) == "string" and not UnitIsVisible(unit2)) then
		return 100, format(L["The unit(%s) does not exist."], unit2);
	end
	local x1, y1, z1, x2, y2, z2;
	if (type(unit1) == "string") then
		x1, y1, z1 = ObjectPosition(unit1);
	elseif (type(unit1) == "table") then
		x1, y1, z1 = unit1[1], unit1[2], unit1[3];
	else
		return 100, format(L["The unit(%s) does not exist."], unit1);
	end
	if (type(unit2) == "string") then
		x2, y2, z2 = ObjectPosition(unit2);
	elseif (type(unit2) == "table") then
		x2, y2, z2 = unit2[1], unit2[2], unit2[3];
	else
		return 100, format(L["The unit(%s) does not exist."], unit2);
	end
	if (type(x1) ~= "number" or type(y1) ~= "number" or type(z1) ~= "number") then
		return 100, L["The position given is invalid."];
	end
	if (type(x2) ~= "number" or type(y2) ~= "number" or type(z2) ~= "number") then
		return 100, L["The position given is invalid."];
	end
	return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2) + pow(z1 - z2, 2));
end
----------------------------------------------------------------------------------

--获取目标与玩家之间的距离（码）范围,更加适用与目标体积更大的目标(如BOSS)
----------------------------------------------------------------------------------
function msGFD(unit)
	if (type(unit) ~= "string") then
		unit = "target";
	end
	local _,MaxRange = MG:GetRange(unit)
	if MaxRange then
		return MaxRange,MaxRange;
	else
		return 100,100;
	end
end
----------------------------------------------------------------------------------

--获取指定中心周围有限范围内的所有单位（包括玩家与NPC,敌对与友善）
----------------------------------------------------------------------------------
function msGetUnits(objType, isFriend, scale, center)
	if (not msICA()) then
		ThrowError("msGetUnits(objType,isFriend,scale,center)", L["The WoW client is not activated."]);
		return nil;
	end
	return API.GetAmbience(objType, isFriend, scale, center);
end
----------------------------------------------------------------------------------

--对通过msGetUnits返回的结果进行筛选
----------------------------------------------------------------------------------
local filterResult = {};
function msFUT(unitsTable, callBackFunc)
	if (not msICA()) then
		ThrowError("msFUT(unitsTable, callBackFunc)", L["The WoW client is not activated."]);
		return false;
	end
	--Check params
	if (type(unitsTable) ~= "table") then
		ThrowError("msFUT(unitsTable, callBackFunc)", format(L["The parameter %s is not a %s."], "unitsTable", L["table"]));
		return nil;
	end
	if (type(callBackFunc) ~= "function") then
		ThrowError("msFUT(unitsTable, callBackFunc)", format(L["The parameter %s is not a %s."], "callBackFunc", L["function"]));
		return nil;
	end
	--Traverse and callback
	wipe(filterResult);
	for i = 1, #unitsTable do
		local unit = unitsTable[i];
		if (UnitGUID(unit)) then
			if (callBackFunc(unit)) then
				tinsert(filterResult, unit);
			end
		end
	end
	return filterResult;
end
----------------------------------------------------------------------------------

--获取玩家的指定图腾的剩余时间(填写图腾中文全称名称)
----------------------------------------------------------------------------------
function msGTCD(totemType)
	return API.GetTotemMushroomsInfo(totemType);
end
----------------------------------------------------------------------------------

--获取玩家的蘑菇剩余时间.index置空返回最快冷却的,否则反回指定位置的:1,2,3
----------------------------------------------------------------------------------
function msGMC(index)
	return API.GetTotemMushroomsInfo(index);
end
----------------------------------------------------------------------------------

--获取玩家蘑菇的数量
----------------------------------------------------------------------------------
function msGMT()
	local v1 = 0;
	for i=1, 4 do
		if GetTotemInfo(i) then
			v1 = v1 + 1;
		end
	end
	return v1;
end
----------------------------------------------------------------------------------

--获取玩家的雕像的剩余时间
----------------------------------------------------------------------------------
function msGSCD()
	return API.GetTotemMushroomsInfo();
end
----------------------------------------------------------------------------------

--判断TellMeWhen插件指定图标是否显示	参数groupN:分组;参数iconN:图标	返回:是否显示,目标,法术,层数,剩余时间
----------------------------------------------------------------------------------
function msTMW(groupN,iconN)
	if not TMW then
		return false,"未加载TellMeWhen插件,请自行下载安装";
	end
	local tmw = _G["TellMeWhen_Group"..tostring(groupN).."_Icon"..tostring(iconN)];
	--print(_G["TellMeWhen_Group"..tostring(groupN).."_Icon"..tostring(iconN)])
	if tmw then
		local shown = tmw.attributes.shown and tmw.attributes.alpha ~= 0 and tmw.attributes.realAlpha ~= 0;
		local unit = tmw.attributes.unit;
		local spell = tmw.attributes.spell;
		local stack = tmw.attributes.stack;
		local start, duration = tmw.attributes.start, tmw.attributes.duration;
		return shown, unit, spell, stack, (duration + start - GetTime());
	else
		return false,"参数错误";
	end
end
----------------------------------------------------------------------------------

--获得指定符文的ID.参数填写符文的中文全称或简称
----------------------------------------------------------------------------------
function msGetRuneid(rune)
	local runeid = 0;
	if string.find(rune,"血") then
		runeid = 1 ;
	elseif string.find(rune,"邪") then
		runeid = 2 ;
	elseif string.find(rune,"冰") then
		runeid = 3 ;
	elseif string.find(rune,"死") then
		runeid = 4 ;
	end
	return runeid;
end
----------------------------------------------------------------------------------

--获得指定符文存在数量（包括可用与不可用的）,参数填写符文的中文全称或中文简称或数字(1:鲜血;2:邪恶;3:冰霜;4:死亡)
----------------------------------------------------------------------------------
function msGetRuneCount(runeid)
	if (type(runeid) ~= "number") then
		runeid = msGetRuneid(runeid)
	end
	local n = 0;
	for i=1, 6 do
		if GetRuneType(i) == runeid then
			n = n + 1;
		end
	end
	return n;
end
----------------------------------------------------------------------------------

--获得指定符文可用数量,参数填写符文的中文全称或中文简称或数字(1:鲜血;2:邪恶;3:冰霜;4:死亡)
----------------------------------------------------------------------------------
function msGetRune(runeid)
	if (type(runeid) ~= "number") then
		runeid = msGetRuneid(runeid)
	end
	local n = 0;
	for i=1, 6 do
		if GetRuneType(i) == runeid and select(3,GetRuneCooldown(i)) then
			n = n + 1;
		end
	end
	return n;
end
----------------------------------------------------------------------------------

--返回指定符文最快的冷却时间,参数填写符文的中文全称或中文简称或数字(1:鲜血;2:邪恶;3:冰霜;4:死亡)
----------------------------------------------------------------------------------
function msRuneCooldown(runeid)
	if (type(runeid) ~= "number") then
		runeid = msGetRuneid(runeid)
	end
	local Cooldown = 100;
	local start, duration, runeReady;
	for i=1, 6 do
		if GetRuneType(i) == runeid then
			start, duration, runeReady = GetRuneCooldown(i);
			cd = duration-(GetTime()-start);
			if cd < 0 then
				cd =0;
			end
			if cd <= Cooldown then
				Cooldown = cd;
			end
		end
	end
	return Cooldown;
end
----------------------------------------------------------------------------------


--返回可用的符文数量,不分类型.配合"符文武器增效"
----------------------------------------------------------------------------------
function msRuneNumber()
	local Cooldown = 0;
	for i=1, 6 do
		if select(3,GetRuneCooldown(i)) then
			Cooldown = Cooldown + 1;
		end
	end
	return Cooldown;
end
----------------------------------------------------------------------------------


--返回主手和副手武器附魔信息(1-主手;2-副手). /run print(GetRuneCooldown(1))
----------------------------------------------------------------------------------
function msGetWEI(n)
	local a1, b1, c1, d1, a2, b2, c2, d2 = GetWeaponEnchantInfo()
	if n == 1 and a1 then
		return b1/1000, a1, c1, d1
	elseif n == 2 and a2 then
		return b2/1000,a1, c2, d2
	end
	return -1;
end
----------------------------------------------------------------------------------

--是否启用了指定天赋(参数直接填写中文天赋名称)
----------------------------------------------------------------------------------
function msTalentInfo(Name)
	for Row = 1, 7 do
		for Column = 1, 3 do
			local talentID, name, texture, selected, available = GetTalentInfo(Row,Column,GetActiveSpecGroup())
			if Name == name then
				return selected
			end
		end
	end
	return false
end
---------------------------------------------------------------------------------

--是否启用了指定雕文(直接填写中文雕文名称)	msIsGlyph("冰冷触摸雕文")
----------------------------------------------------------------------------------
function msIsGlyph(Name)
	for i = 1, GetNumGlyphSockets() do
		local _, _, _, glyphSpellID, _,glyphID = GetGlyphSocketInfo(i)
		if Name == GetSpellInfo(glyphSpellID) or Name == GetSpellInfo(glyphID) then
			return true
		end
	end
	return false
end
---------------------------------------------------------------------------------

--获取技能或物品的冷却时间(spell格式参考msISC的spell)	61304
---------------------------------------------------------------------------------
function msGCD(spell)
	local spelltype, spellname, spellId = API.GetSpellItem(spell);
	local starttime, duration = GetSpellCooldown(61304)
	if (spelltype == "SPELL") then
		starttime, duration = GetSpellCooldown(spellId);
	elseif (spelltype == "ITEM") then
		starttime, duration = GetItemCooldown(spellId);
	end
	if starttime and duration then
		if starttime == 0 then
			return 0;
		else
			return starttime + duration - GetTime();
		end
	end
	return 10000;
end
---------------------------------------------------------------------------------

--获取信息的总值,填写数字(1-强度;2-敏捷;3-耐力;4-智力;5-精神).默认判断自己
---------------------------------------------------------------------------------
function msGetUnitStat(statID,unit)
	if not unit then
		unit = "plaer";
	end
    local stat, effectiveStat, posBuff, negBuff = UnitStat(unit, statID);
    return stat + posBuff + negBuff
end
---------------------------------------------------------------------------------

--设置变量,变量名称:VariableName,变量内容:Value
---------------------------------------------------------------------------------
local VariableWarehouse = {};
function mssv(VariableName,Value)
	VariableWarehouse[VariableName] = Value;
	return VariableWarehouse[VariableName]
end
---------------------------------------------------------------------------------

--读取变量,变量名称:VariableName
---------------------------------------------------------------------------------
function msgv(VariableName)
	if VariableName == nil  then
		return nil;
	end;
	return VariableWarehouse[VariableName]
end
---------------------------------------------------------------------------------

--获取特殊能量
---------------------------------------------------------------------------------
function msGetPower()
	local _, englishClass = UnitClass("player");
	if englishClass == "PALADIN" then
		return UnitPower("player", SPELL_POWER_HOLY_POWER);
	elseif englishClass == "DRUID" then
		return UnitPower("player", SPELL_POWER_ECLIPSE);
	elseif englishClass == "WARLOCK" then
		local tf = GetSpecialization();
		if tf == 2 then
			return UnitPower("player", 7);
		elseif tf == 3 then
			return UnitPower("player", 7);
		else
			return UnitPower("player", 7);
		end
	elseif englishClass == "MONK" then
		return UnitPower("player", 12);
	elseif englishClass == "PRIEST" then
		return UnitPower("player", 13);
	elseif englishClass == "MAGE" then
		return UnitPower("player", 16);
	elseif englishClass == "ROGUE" then
		return UnitPower("player", 4);
	end
	return -1;
end
---------------------------------------------------------------------------------

--技能正在执行时按下鼠标左键
---------------------------------------------------------------------------------
function msICM(Spell)
	if IsCurrentSpell(Spell) or msICA() --[[and IsAoEPending()]] then
		msMouse();
		return true;
	end
	return false;
end
---------------------------------------------------------------------------------

--点击鼠标左键	IsCurrentSpell("英勇飞跃")判断技能是否点亮
---------------------------------------------------------------------------------
local msLastMouseAction = GetTime()
function msMouse()
	if (GetTime() - msLastMouseAction > 0.15) then
		msLastMouseAction = GetTime()
		local leftdown = IsMouseButtonDown(1)
		local Rightdown = IsMouseButtonDown(2)
		if leftdown and Rightdown then
			CameraOrSelectOrMoveStop()
			TurnOrActionStop()
			CameraOrSelectOrMoveStop()
			CameraOrSelectOrMoveStart()
			CameraOrSelectOrMoveStop()
			CameraOrSelectOrMoveStart()
			TurnOrActionStart()
		elseif leftdown and (not Rightdown) then
			CameraOrSelectOrMoveStop()
			CameraOrSelectOrMoveStart()
		elseif (not leftdown) and Rightdown then
			TurnOrActionStop()
			CameraOrSelectOrMoveStart()
			CameraOrSelectOrMoveStop()
			TurnOrActionStart()
		else
			CameraOrSelectOrMoveStart()
			CameraOrSelectOrMoveStop()
		end
	end
end
---------------------------------------------------------------------------------

--获取指定名称的DBM进度条的剩余时间
---------------------------------------------------------------------------------
function msDBM(barname)
    for bar in DBM.Bars:GetBarIterator() do
		local Name = _G[bar.frame:GetName().."BarName"]:GetText()
        if strfind(Name,barname) then
            return bar.timer
        end
        --print(_G[bar.frame:GetName().."BarName"]:GetText())
    end
    return 10000;
end
---------------------------------------------------------------------------------

--判断是否在某姿态中,填数字,从动作条左到右
---------------------------------------------------------------------------------
function msIsStance(index)
	if index <= 0 then
		return false
	end
	local _,_,a = GetShapeshiftFormInfo(index);
	return a;
end
---------------------------------------------------------------------------------

--判断目标是否指定职业,可以填写一个或多个中文名称.如:潜行者
---------------------------------------------------------------------------------
function msIsClass(Class,Unit)
	if type(Class) ~= "string" and type(Class) ~= "table" then
		return false;
	elseif type(Class) ~= "table" then
		Class = strtrim(Class)
		Class = {strsplit(",", Class)};
	end
	if type(Unit) ~= "string" then
		Unit = "target"
	end
	local playerClass, englishClass = UnitClassBase(Unit);
	for i = 1, #Class do
		if playerClass == Class[i] then
			return playerClass;
		end
	end
	return false;
end
---------------------------------------------------------------------------------

--判断自己是否失去控制
---------------------------------------------------------------------------------
--[[
local PLAYERCONTROLFrame = CreateFrame("Frame");
-- PLAYERCONTROLFrame:RegisterEvent("PLAYER_CONTROL_GAINED");
-- PLAYERCONTROLFrame:RegisterEvent("PLAYER_CONTROL_LOST");
PLAYERCONTROLFrame:RegisterEvent("LOSS_OF_CONTROL_ADDED");
--PLAYERCONTROLFrame:RegisterEvent("LOSS_OF_CONTROL_UPDATE");
PLAYERCONTROLFrame:SetScript("OnEvent", function(self, event, ... )
	print(self, event, ... )
	--local eventIndex = C_LossOfControl.GetNumEvents()
	if event == "LOSS_OF_CONTROL_ADDED" then
		local eventIndex = ...;
		local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = C_LossOfControl.GetEventInfo(eventIndex);
		print(C_LossOfControl.GetEventInfo(eventIndex))
		if startTime then
			PLAYERCONTROLFrame.IsControl = false;
			PLAYERCONTROLFrame.startTime = startTime;
			PLAYERCONTROLFrame.duration = duration;
			PLAYERCONTROLFrame.text = text;
			print(text)
		end
	end
end);
]]--
function msPC()
	local eventIndex = C_LossOfControl.GetNumEvents()
	if eventIndex>0 then
		local Eventarg = { C_LossOfControl.GetEventInfo(eventIndex) }
		if Eventarg[9] == 5 then
			return true
		end
	end
	return false;
end
--[[
被定身 ROOT
被冻结 STUN
昏迷 STUN_MECHANIC
]]--
---------------------------------------------------------------------------------

--自动打断敌对读条
---------------------------------------------------------------------------------
function msInterrupt(spell,casttime,spells,objType)
	if (not msICA()) then
		ThrowError("msInterrupt(spell,casttime,spells,objType)", L["The WoW client is not activated."]);
		return nil;
	end
	if (type(spell) ~= "string") then
		ThrowError("msInterrupt(spell,casttime,spells,objType)", L["The parameters are invalid."]);
		return nil;
	end
	if (type(casttime) ~= "number") then
		casttime = 1;
	end
	for i=1,GetObjectCount() do
		local thisUnit = GetObjectWithIndex(i);
		if UnitExists(thisUnit) and UnitCanAttack(thisUnit,"player") and msII(thisUnit) and not UnitIsDeadOrGhost(thisUnit) and (not objType or UnitIsPlayer(thisUnit)) then
			local result, spellType, spellName, _, spellRemaining = msICS(thisUnit,"*",true)
			if result and not spells then
				if msISC(spell,thisUnit) and (spellType == 1 and spellRemaining < casttime or spellType == 2 and spellRemaining > casttime) then
					msRun(spell,thisUnit,0,true)
				end
			elseif result and (type(spells) == "string") then
				spells = {strsplit(",", spells)};
				if tContains(spells,spellName) and msISC(spell,thisUnit) and (spellType == 1 and spellRemaining < casttime or spellType == 2 and spellRemaining > casttime) then
					msRun(spell,thisUnit,0,true)
				end
			end
		end
	end
	return msGCD(spell);
end
---------------------------------------------------------------------------------

--Ovale全职业输出助手插件.参数填写数字,用第几个图标的技能
---------------------------------------------------------------------------------
function msOvale(number)
	if not Ovale then
		print("|cffff0000Ovale全职业输出助手插件没有安装！")
	else
		local spellId = Ovale["frame"]["actions"][number]["spellId"];
		if type(spellId)=="number" and not UnitIsDeadOrGhost("target") and UnitCanAttack("player","target") and UnitChannelInfo("player")~= GetSpellInfo(spellId) then
			if select(2,UnitClassBase("player")) == "HUNTER" and msISC("SPELL" .. spellId,"target",true) then
				msRun("SPELL" .. spellId,"target");
				return true;
			elseif msISC("SPELL" .. spellId,"target") then
				msRun("SPELL" .. spellId,"target");
				return true;
			end
		else
			return false;
		end
	end
end
---------------------------------------------------------------------------------

--Decursive插件一键驱散,参数填是否需要打断当前施法
---------------------------------------------------------------------------------
function msDecursive(Break)
	if not DecursiveRootTable  then
		print("|cffff0000需要安装Decursive插件才能使用msDecursive(Break)");
		return false;
	end
	local n = DecursiveRootTable["Dcr"]["Status"]["UnitNum"]
	local i;
	for i=1, n do
		local unit,Spell,IsCharmed,Debuff1Prio = msDecursive_EX(i)
		if unit then
			if UnitIsVisible(unit) and Spell then
				if msISC(Spell,unit) then
					if Break then
						RunMacroText("/stopcasting");
						msRun(Spell,unit);
					else
						msRun(Spell,unit);
					end
					return true
				end
			end
		end
	end
end
function msDecursive_EX(id)
	local Dcr = DecursiveRootTable["Dcr"];
	local unit = Dcr.Status.Unit_Array[id]
	local f = Dcr["MicroUnitF"]["UnitToMUF"][unit]
	if not f then
		return false;
	end
	local IsDebuffed = f["IsDebuffed"]
	if IsDebuffed then
		local DebuffType = f["FirstDebuffType"]
		local Spell = Dcr.Status.CuringSpells[DebuffType]
		local IsCharmed = f["IsCharmed"]
		local Debuff1Prio = f["Debuff1Prio"]
		return unit,Spell,IsCharmed,Debuff1Prio
	end
end
---------------------------------------------------------------------------------

--获取目标的治疗量,参数:目标,返回值:目标收到的过量治疗量,目标收到我的治疗量,目标收到所有人的治疗量
---------------------------------------------------------------------------------
function msGUH(unit)
	if UnitGUID(unit) then
		local Health = UnitHealth(unit);
		local HealthMax = UnitHealthMax(unit);
		local AllIncomingHeal = UnitGetIncomingHeals(unit);
		local MyIncomingHeal = UnitGetIncomingHeals(unit,"player");
		if type(MyIncomingHeal) == "number" and type(AllIncomingHeal) == "number" then
			local HealthExcess = Health + AllIncomingHeal  - HealthMax;
			return HealthExcess,MyIncomingHeal,AllIncomingHeal;
		end
	end
	return -1, -1, -1;
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
local Spell_Spell, Spell_Target, Last_Spell;
local GetSpellCast = {};
local CastSpellFrame = CreateFrame("Frame");
CastSpellFrame:RegisterEvent("UNIT_SPELLCAST_SENT");--技能释放开始
CastSpellFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
CastSpellFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");--技能释放成功
CastSpellFrame:RegisterEvent("LOADING_SCREEN_ENABLED");--地图刷新
CastSpellFrame:SetScript("OnEvent", function(self, event, ... )
	local Eventarg = { ... }
	--变形记 --技能插入
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and Eventarg[2] == "SPELL_CAST_SUCCESS" and Eventarg[4] == UnitGUID("player") then
		if strfind("熊形态,西瓦尔拉之爪,猎豹形态,旅行形态",Eventarg[13]) then
			mssv("变形记",false)
		end
		if msgv("sv_msInRun_Spell") and msgv("sv_msInRun_Spell") == Eventarg[13] then
			mssv("sv_msInRun_Spell",nil);		
		end
		local spelltype, spellname = API.GetSpellItem(Eventarg[13]);
		if (spelltype == "SPELL") then
			Last_Spell = spellname;
		end
	end
	if event == "UNIT_SPELLCAST_SENT" and Eventarg[1] == "player" and Eventarg[2] and Eventarg[4] then
		--print(Eventarg[1],Eventarg[2],Eventarg[3],Eventarg[4])
		Spell_Target = Eventarg[2] ~= "" and Eventarg[2]
		local name, _, _, castTime = GetSpellInfo(Eventarg[4])
		if name and castTime>0 then
			Spell_Spell = Eventarg[4]
			Spell_Target = Eventarg[2] ~= "" and Eventarg[2] or "player"
		end
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and Eventarg[2] == "SPELL_CAST_SUCCESS" and Eventarg[4] and Eventarg[13] then
		GetSpellCast[Eventarg[4]] = GetSpellCast[Eventarg[4]] or {};
		GetSpellCast[Eventarg[4]][Eventarg[13]] = GetSpellCast[Eventarg[4]][Eventarg[13]] or {};
		GetSpellCast[Eventarg[4]][Eventarg[13]]["time"] = GetTime();
		GetSpellCast[Eventarg[4]][Eventarg[13]]["destGUID"] = Eventarg[8]
		GetSpellCast[Eventarg[4]][Eventarg[13]]["destName"] = Eventarg[9]
		--print(GetSpellCast[Eventarg[4]][Eventarg[13]]["time"])
	end
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		--print(Eventarg[1],Eventarg[2],Eventarg[3])
	end

	if event == "LOADING_SCREEN_ENABLED" then
		--print("LOADING_SCREEN_ENABLED")
		wipe(GetSpellCast)
	end
end);
--[[local UseAction_msInRun = UseAction;
UseAction = function(slot,...)
	local actionType, id = GetActionInfo(slot)
	if actionType == "spell" then
		local spellname = GetSpellInfo(id);
		msInRun(spellname)
	elseif actionType == "item" then
		local spellname = GetItemInfo(id);
		msInRun(spellname)
	end
	UseAction_msInRun(slot,...);
end]]

--目標在視野外
function LineOfSight(target)
	if not tLOS then tLOS={} end
	local updateRate=2

	function fLOSOnEvent(self,event,...)
		if event=="COMBAT_LOG_EVENT_UNFILTERED" then
			local _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, _, _, _, spellFailed  = ...
			--print(spellFailed)
			if subEvent ~= nil then
				if subEvent=="SPELL_CAST_FAILED" then
					local player=UnitGUID("player") or ""
					if sourceGUID ~= nil then
						if sourceGUID==player then
							if spellFailed ~= nil then
								--print(spellFailed)
								if spellFailed==SPELL_FAILED_LINE_OF_SIGHT
									--or spellFailed==SPELL_FAILED_NOT_INFRONT
									--or spellFailed==SPELL_FAILED_OUT_OF_RANGE
									--or spellFailed==SPELL_FAILED_UNIT_NOT_INFRONT
									--or spellFailed==SPELL_FAILED_UNIT_NOT_BEHIND
									--or spellFailed==SPELL_FAILED_NOT_BEHIND
									--or spellFailed==SPELL_FAILED_MOVING
									--or spellFailed==SPELL_FAILED_IMMUNE
									--or spellFailed==SPELL_FAILED_FLEEING
									--or spellFailed==SPELL_FAILED_BAD_TARGETS
									--or spellFailed==SPELL_FAILED_NO_MOUNTS_ALLOWED
									--or spellFailed==SPELL_FAILED_STUNNED
									--or spellFailed==SPELL_FAILED_SILENCED
									--or spellFailed==SPELL_FAILED_NOT_IN_CONTROL
									--or spellFailed==SPELL_FAILED_VISION_OBSCURED
									--or spellFailed==SPELL_FAILED_DAMAGE_IMMUNE
									--or spellFailed==SPELL_FAILED_CHARMED
									then
									print(spellFailed)
									wipe(tLOS)
									tinsert(tLOS,{unit="target",time=GetTime()})
								end
							end
						end
					end
				end
			end
		end
		
		--[[if event == "UI_ERROR_MESSAGE" then
            local msg = ...
            --print(msg)
            -- 50:目標不在視野中
            if msg ~= nil then
                if msg==50 or msg=="你的宠物离目标距离太远了。" or msg=="你没有宠物" or msg=="目标已经死亡" 
                	or msg=="在逃跑状态下无法攻击。" or msg=="没有可以行进的路径" 
                	or msg=="没有可以行进的路径。" or msg == "目标不在视野中" or msg == "你距离太远！" 
                	or msg=="距离太远。" or msg=="目標不在視野中" then
                	wipe(tLOS)
                    tinsert(tLOS,{unit="target",time=GetTime()})
                end
            end
		end]]
	end

	CastSpellFrame:SetScript("OnEvent",fLOSOnEvent);

	--print(#tLOS)

	if #tLOS>0 then
		table.sort(tLOS, function(x,y) return x.time>y.time end)
		if (GetTime()>(tLOS[1].time+updateRate)) then
			wipe(tLOS)
			return false
		end
		if tLOS[1].unit=="target" then
			return true
		end
	end

	return false
end

---------------------------------------------------------------------------------

--技能插入	GetSpellCooldown(61304)	GetSpellInfo(61304)
---------------------------------------------------------------------------------
function msInRun(Spell,Unit,interrupt)
	mssv("sv_msInRun_Spell",Spell)
	mssv("sv_msInRun_Unit",Unit)
	mssv("sv_msInRun_Stop",interrupt)
	mssv("sv_msInRun_Time",GetTime())
	return true;
end
---------------------------------------------------------------------------------

--技能插入,	技能:Spell; 目标:Unit; 是否打断当前施法:Stop; 插入时间:Time;
---------------------------------------------------------------------------------
function msinspell(Spell,Unit,Stop,Time)
	if (type(Time) ~= "number") then
		Time = 2;
	end
	mssv("sv_msinspell_Spell",Spell)
	mssv("sv_msinspell_Unit",Unit)
	mssv("sv_msinspell_Stop",Stop)
	mssv("sv_msinspell_Time",GetTime() + Time)
	return true;
end
---------------------------------------------------------------------------------

--调用技能插入
---------------------------------------------------------------------------------
function msruninspell()
	if msgv("sv_msinspell_Time") and GetTime() > msgv("sv_msinspell_Time") then
		mssv("sv_msinspell_Spell",nil);
		mssv("sv_msinspell_Unit",nil);
		mssv("sv_msinspell_Stop",nil);
		mssv("sv_msinspell_Time",nil);
		return;
	end
	local Spell = msgv("sv_msinspell_Spell");
	local Unit = msgv("sv_msinspell_Unit");
	local Stop = msgv("sv_msinspell_Stop");
	if not Spell then
		return;
	end
	if Stop and msGCD(Spell)==0 then
		--RunMacroText("/stopcasting");
		--RunMacroText("/stopcasting");
	end
	if msISC(Spell,Unit) and (not msICS("player") or not Stop) and msRun(Spell,Unit,0,true) then
		mssv("sv_msinspell_Spell",nil);
		mssv("sv_msinspell_Unit",nil);
		mssv("sv_msinspell_Stop",nil);
		return Spell;
	end
end
---------------------------------------------------------------------------------

--获取玩家当前读条信息,返回当前读条的目标及目标的血量百分比,目标收到的过量治疗量,目标收到我的治疗量,目标收到所有人的治疗量
---------------------------------------------------------------------------------
function msGetCastInf()
	if Spell_Spell and Spell_Target and (Spell_Spell == UnitCastingInfo("player") or Spell_Spell == UnitChannelInfo("player"))then
		local unit;
		if UnitIsVisible(Spell_Target) then
			unit = Spell_Target
		elseif Spell_Target == GetUnitName("focus",true) then
			unit = "focus"
		elseif Spell_Target == GetUnitName("target",true) then
			unit = "target"
		elseif Spell_Target == GetUnitName("player",true) then
			unit = "mouseover"
		end
		if UnitIsVisible(unit) then
			return unit,msGHP(unit),msGUH(unit);
		end
	end
	return false,-1,-1,-1,-1;
end
---------------------------------------------------------------------------------

--获取指定目标成功释放指定技能后经历的时间及该技能命中的目标
---------------------------------------------------------------------------------
function msGetSpellCast(sourceGUID,spellName)
	sourceGUID = UnitGUID(sourceGUID)
	if GetSpellCast[sourceGUID] and GetSpellCast[sourceGUID][spellName] then
		if msICA() and GetSpellCast[sourceGUID][spellName]["destGUID"] then
			local destGUID = GetSpellCast[sourceGUID][spellName]["destGUID"];
			return GetTime() - GetSpellCast[sourceGUID][spellName]["time"],msGOFG(destGUID);
		elseif GetSpellCast[sourceGUID][spellName]["time"] then
			return GetTime() - GetSpellCast[sourceGUID][spellName]["time"],GetSpellCast[sourceGUID][spellName]["destName"];
		end
	end
	return -1,false;
end
---------------------------------------------------------------------------------

--获取自己施放上一个技能的名称
---------------------------------------------------------------------------------
function msLS()
	if Last_Spell then
		return Last_Spell
	end
end
---------------------------------------------------------------------------------

--目标的目标是否自己
---------------------------------------------------------------------------------
function msUTIP(unit)
	if not unit then
		unit = "target"
	end
	if msICA() and ObjectExists(unit) and UnitTarget(unit) == ObjectPointer("player") then
		return true
	end
	if UnitIsVisible(unit) and UnitGUID(unit .. '-target') == UnitGUID("player") then
		return true
	end
	return false
end
---------------------------------------------------------------------------------

--JJC内被集火的目标及集火数量
---------------------------------------------------------------------------------
function msGACA()
	local name = {};
	local Coun = 0;
	local unittarget;
	for i=1, 5 do
		unit = GetUnitName("arena" .. i .. "-target");
		if unit then
			if name[unit] then
				name[unit] = name[unit] + 1;
			else
				name[unit] = 1;
			end
			if name[unit] > Coun then
				Coun = name[unit];
				unittarget = unit;
			end
		end
	end
	return Coun,unittarget;
end
---------------------------------------------------------------------------------

--能量恢复所需时间,Unit目标,MAX回复到的期望值(默认满能量)
---------------------------------------------------------------------------------
function msGTTM(Unit,MAX)
	if not UnitIsVisible(Unit) then
		Unit = "player"
	end
	local curr2;
  	local max = MAX or UnitPowerMax(Unit);
  	local curr = UnitPower(Unit);
  	local regen = select(2, GetPowerRegen(Unit));
  	-- if select(4,GetTalentInfo(4,1,GetActiveSpecGroup())) then
   		-- curr2 = curr + 4*GetComboPoints("player")
  	-- else
   		-- curr2 = curr
  	-- end
	curr2 = (max - curr) * (1.0 / regen);
	if curr2 <= 0 then
		return 0;
	else
		return curr2;
	end
end
---------------------------------------------------------------------------------

--获取目标死亡需要的时间
---------------------------------------------------------------------------------
local thpcurr,thpstart,timestart,currtar,priortar,timecurr,timeToDie
function msGTTD(unit)
	unit = unit or "target";
	if thpcurr == nil then thpcurr = 0; end
	if thpstart == nil then thpstart = 0; end
	if timestart == nil then timestart = 0; end
	if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
		if currtar ~= UnitGUID(unit) then
			priortar = currtar;
			currtar = UnitGUID(unit);
		end
		if thpstart == 0 and timestart == 0 then
			thpstart = UnitHealth(unit);
			timestart = GetTime();
		else
			thpcurr = UnitHealth(unit);
			timecurr = GetTime();
			if thpcurr >= thpstart then
				thpstart = thpcurr;
				timeToDie = 999;
			else
				if ((timecurr - timestart)==0) or ((thpstart - thpcurr)==0) then
					timeToDie = 999;
				else
					timeToDie = round2(thpcurr/((thpstart - thpcurr) / (timecurr - timestart)),2);
				end
			end
		end
	elseif not UnitIsVisible(unit) or currtar ~= UnitGUID(unit) then
		currtar = 0;
		priortar = 0;
		thpstart = 0;
		timestart = 0;
		timeToDie = 0;
	end
	if timeToDie == nil then
		return 999
	else
		return timeToDie
	end
end
function round2(num, idp)
  mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
---------------------------------------------------------------------------------

--获取JJC内指定天赋的目标,参数填一个或多个天赋名称,返回该目标.需要Gladius插件
---------------------------------------------------------------------------------
function msGetArenaTalent(Talent)
	if not Gladius then
		print("|cffff0000请安装Gladius插件！");
		return false;
	end
	if (type(Talent) ~= "string" and type(Talent) ~= "table") then
		return false;
	end
	if (type(Talent) ~= "table") then
		Talent = {strsplit(",", Talent)};
	end
	if Gladius.buttons then
		for i=1, 5 do
			local unit = "arena"..i;
			if Gladius.buttons[unit] and Gladius.buttons[unit].spec then
				for j = 1, #Talent do
					if Talent[j] == Gladius.buttons[unit].spec then
						return unit;
					end
				end
			end
		end
	end
	return false;
end
---------------------------------------------------------------------------------

--通过GUID寻找目标指针
---------------------------------------------------------------------------------
function msGOFG(GUID)
	if not msICA() then
		return nil;
	end
	for i=1,GetObjectCount() do
		local thisUnit = GetObjectWithIndex(i);
		if UnitGUID(thisUnit) == GUID then
			return thisUnit;
		else
			return nil;
		end
	end
end
---------------------------------------------------------------------------------

--是否指定专精,参数直接填专精中文名称
---------------------------------------------------------------------------------
function msITN(name)
	local n = GetSpecialization();
	if n then
		local _, Talent = GetSpecializationInfo(n);
		return Talent == name;
	end
end
---------------------------------------------------------------------------------

--返回目标的坐标及朝向,默认当前目标
---------------------------------------------------------------------------------
function msGUL(unit)
	if (not msICA()) then
		ThrowError("msGUL(unit)", L["The WoW client is not activated."]);
		return nil;
	end
	unit = unit or "target";
	local x ,y, z = ObjectPosition(unit);
	local r = ObjectFacing(unit);
	return x ,y, z, r;
end
---------------------------------------------------------------------------------

--获取目标First的Distance码的位置
---------------------------------------------------------------------------------
function msGPBU(Distance,First,Second)
	if not msICA() then
		return nil;
	end
	First = First or "target";
	Second = Second or "Player";
	if not UnitIsVisible(First) or not UnitIsVisible(Second) then
		return nil;
	end
	local fX,fY,fZ = ObjectPosition(First);
	local sX,sY,sZ = ObjectPosition(Second);
	local Facing = math.atan2(sY-fY,sX-fX)%(math.pi*2);
	local Pitch = math.atan((sZ-fZ)/math.sqrt(((fX-sX)^2)+((fY-sY)^2)))%(math.pi*2);
	return math.cos(Facing)*Distance+fX,math.sin(Facing)*Distance+fY,math.sin(Pitch)*Distance+fZ;
end
---------------------------------------------------------------------------------

--获取充能技能的可用数量及冷却时间,参数可以ID或技能名称
---------------------------------------------------------------------------------
function msGSC(spell)
	local charges, maxCharges, start, duration = GetSpellCharges(spell)
	if charges then
		local cd = duration + start - GetTime();
		if cd >= duration then
			cd = 0
		end
		return charges,cd;
	end
end
---------------------------------------------------------------------------------

--获取技能描述里的数字信息,spell支持中文及数字ID
---------------------------------------------------------------------------------
function msGSN(spell)
	local text = GetSpellDescription(spell);
	local v = {};
	local i = 1;
	if text then
		while true do
			j = string.find(text,"%d,%d")
			if not j then
				break
			end
			local firsthalf = string.sub(text,1,j)
			local lasthalf = string.sub(text,j+2,#text)
			text = firsthalf .. lasthalf
		end
		for k in string.gmatch(text, "%d+") do
			if tonumber(k) >100 then
				v[i] = tonumber(k);
				i = i + 1;
			end
		end
	end
	return v[1] or -1, v[2] or -1, v[3] or -1, v[4] or -1, v[5] or -1, v[6] or -1, v[7] or -1, v[8] or -1;
end
---------------------------------------------------------------------------------

--获取buff描述里的数字信息,buff支持中文及数字ID
---------------------------------------------------------------------------------
function msGBN(buff, unit)
	unit = unit or "target"
	local text = msGBB(buff, unit);
	local v = {};
	local i = 1;
	if text then
		while true do
			j = string.find(text,"%d,%d")
			if not j then
				break
			end
			local firsthalf = string.sub(text,1,j)
			local lasthalf = string.sub(text,j+2,#text)
			text = firsthalf .. lasthalf
		end
		for k in string.gmatch(text, "%d+") do
			if tonumber(k) >100 then
				v[i] = tonumber(k);
				i = i + 1;
			end
		end
	end
   return v[1] or -1, v[2] or -1, v[3] or -1, v[4] or -1, v[5] or -1, v[6] or -1, v[7] or -1, v[8] or -1;
end
---------------------------------------------------------------------------------

--获取JJC敌对相应专精的目标;填写数字specID;http://wowprogramming.com/docs/api_types#specID
---------------------------------------------------------------------------------
function msGAOS(specID)
	if not IsActiveBattlefieldArena() then
		return false;
	end
	if (type(specID) ~= "table") then
		specID = {strsplit(",", specID)};
	end
	for i = 1, 5 do
		local Spec = GetArenaOpponentSpec(i)
		for j = 1, #specID do
			if tonumber(Spec) == tonumber(specID[j]) then
				return "arena" .. i;
			end
		end
	end
end
---------------------------------------------------------------------------------

--目标的目标是否自己
---------------------------------------------------------------------------------
function msUunitTatgetIsPlayer(unit)
	if not unit then
		unit = "target"
	end
	if UnitIsVisible(unit) and UnitGUID(unit .. '-target') == UnitGUID("player") then
		return true
	end
	return false
end
msUTIP = msUunitTatgetIsPlayer;
---------------------------------------------------------------------------------

-- 判断是否在评级战场或者竞技场中
---------------------------------------------------------------------------------
function IsRatedOrIsArena()
	local inInstance, instanceType = IsInInstance()
	if inInstance ~= nil and instanceType == "pvp" then
		return true
	end

	local flag = IsActiveBattlefieldArena()
	if flag == true or IsRatedBattleground() then
		return true;
	end

	return false;
end
---------------------------------------------------------------------------------

function DelayCast(spellid, dtime) -- SpellID of Spell To Check, delay time
	if not CheckCastTime then  CheckCastTime = {} end
	local mtime = dtime + 5 --max expire time
	local spellexist = false
	if dtime > 0 then
		if #CheckCastTime >0 then
			for i=1, #CheckCastTime do
				if CheckCastTime[i].SpellID == spellid then
					spellexist = true
					if ((GetTime() - CheckCastTime[i].CastTime) > mtime) then
						
						CheckCastTime[i].CastTime = GetTime()
						return false
					elseif ((GetTime() - CheckCastTime[i].CastTime) > dtime) then
						
						CheckCastTime[i].CastTime = GetTime()
						return true
					else
						
						return false
					end
				end
			end
			if not spellexist then
				table.insert(CheckCastTime, { SpellID = spellid, CastTime = GetTime() } )	
				return false	
			end
		else
			
			table.insert(CheckCastTime, { SpellID = spellid, CastTime = GetTime() } )	
			return false	
		end
	else
		return true
	end
end

function msStringSplit(str, delimiter)
   if str==nil or str=='' or delimiter==nil then
      return nil
   end
   
   local result = {}
   for match in (str..delimiter):gmatch("(.-)"..delimiter) do
      table.insert(result, match)
   end
   return result
end