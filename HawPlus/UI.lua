StaticPopupDialogs["NoFireHack"] = {text = "|cFFFF4500HawPlus提示：|r\n客户端未解锁或解锁失败!\n解锁后重载插件或小退.\n如需不解锁进行游戏,请禁用本插件.",	button1 = "OK",	timeout = 0, exclusive = 1,	whileDead = 1, hideOnEscape = nil};
HawPlusLuaList = {};
HawPlushelper = {Queuingtime = 5, Queuingchecked = false, Loadscript = true, wowlua = true, Insert = false};

function GetWoWDirectory() 
	return ""
end

local luaScript = {};
local wowluaScript = {};
local firstone = true;
local ResetEditbox = function()
	if firstone then
		local page, entry = WowLua:GetCurrentPage()
		WowLuaFrameEditBox:SetText(entry.content)
		WowLuaFrameEditBox:SetWidth(WowLuaFrameEditScrollFrame:GetWidth())
		--WowLua:UpdateButtons();
		--WowLua:SetTitle(false);
		firstone = false
		for name, _ in pairs(HawPlusLuaList) do
			if not tContains(luaScript,name) then
				HawPlusLuaList[name] = nil
			end
		end
	end
end
local HawPlusList = {}
local menu = HawPlusScriptMenu("MSSM")
menu:SetMenuRequestFunc(HawPlusList, "OnMenuRequest")
function HawPlusList:OnMenuRequest(level, value, menu)
	HawPlusLoadscript()
	if level == 1 then
		menu:AddLine("text", "|cff00ffffHawPlus脚本文件列表|r", "ToggleButton",1,"ToggleState",not HawPlushelper.Loadscript, "isTitle",1,
		"ToggleButtonFun",function()
			HawPlushelper.Loadscript = not HawPlushelper.Loadscript;
			menu:Refresh(level);
		end,
		"tooltipTitle","HawPlus脚本说明", "tooltipText","本列表自动实时识别文件内所有.lua脚本文件。文件夹目录:\n" .. GetWoWDirectory() .. "\\HawPlus脚本\\\n特点：\n1.脚本在游戏外编写。\n2.所有角色共用脚本。\n3.脚本与插件及游戏独立储存。")
		if HawPlushelper.Loadscript then
			menu:AddLine("line",1, "LineBrightness",1, "LineHeight",10);
			if #luaScript >0 then
				for page, name in ipairs(luaScript) do
					menu:AddLine("text",name, "arg1",name, "value",name, "checked",HawPlusLuaList[name].checked, "hasArrow",1,
					"func", function(arg1)
						if HawPlusLuaList[name].checked then
							HawPlusLuaList[name].checked = false;
						else
							HawPlusLuaList[name].checked = true;
						end
						menu:Refresh(level);
					end);
					if page < #luaScript then
						menu:AddLine("line",1, "LineBrightness",0.3, "LineHeight",6)
					end
				end
			end
		end
		menu:AddLine("line",1, "LineBrightness",1, "LineHeight",10);
		menu:AddLine("text", "|cff00ffff游戏内脚本编辑器列表|r", "ToggleButton",1,"ToggleState",not HawPlushelper.wowlua, "isTitle",1,
		"ToggleButtonFun",function()
			HawPlushelper.wowlua = not HawPlushelper.wowlua;
			menu:Refresh(level);
		end,
		"tooltipTitle","编辑器说明", "tooltipText","本列表需要在游戏内自行新建编写。\n特点：\n1.脚本在游戏内编写。\n2.所有角色独立脚本。\n3.脚本储存于客户端的人物配置文件内:\n" .. GetWoWDirectory() .. "\\WTF\\")
		menu:AddLine("line",1, "LineBrightness",1, "LineHeight",10);
		if HawPlushelper.wowlua then
			menu:AddLine("text","|cFF00FF00新建脚本|r","icon","Interface\\Icons\\INV_Scroll_11",
			"func", function()
				ResetEditbox()
				WowLuaFrame:Show()
				WowLua:Button_New()
				menu:Refresh(level)
			end);
			menu:AddLine("line",1, "LineBrightness",0.3, "LineHeight",6)
			for page, entry in ipairs(WowLua_DB.pages) do
				menu:AddLine("text",entry.name, "arg1",entry, "value",page, "checked",entry.checked, "hasArrow",1,
				"func", function(arg1)
					if arg1.checked then
						arg1.checked = false;
					else
						arg1.checked = true;
					end
					msScriptList();
					menu:Refresh(level);
				end);
				menu:AddLine("line",1, "LineBrightness",0.3, "LineHeight",6);
			end

		end
	elseif level == 2 then
		if HawPlushelper.Loadscript and type(value) == "string" then
			menu:AddLine("text","|cffff7700" .. value, "isTitle",1, "text_X",-20);
			menu:AddLine("line",1, "LineBrightness",1, "LineHeight",10);
			menu:AddLine("text","脚本调试", "icon","Interface\\ICONS\\INV_Scroll_05", "arg1",value, "func",function(name)
				RunScript(ReadFile(GetWoWDirectory() .. "\\HawPlus脚本\\" .. name));
			end);
			menu:AddLine("line",1, "LineBrightness",0.3, "LineHeight",6)
			menu:AddLine("text","脚本延时", "icon","Interface\\ICONS\\INV_Elemental_SpiritofHarmony_2", "hasEditBox", 1, "editBoxText", HawPlusLuaList[value].runtime, "editBoxArg1", HawPlusLuaList[value],"editBoxArg2", self.text,
			"editBoxFunc", function(editBoxArg1,text)
				local text = tonumber(text)
				if type(text) == "number" then
					editBoxArg1.runtime = text;
					menu:Refresh(1);
				end
			end);
		end
		if HawPlushelper.wowlua and type(value) == "number" then
			menu:AddLine("text","|cffff7700" .. WowLua_DB.pages[value].name, "isTitle",1, "text_X",-20);
			menu:AddLine("line",1, "LineBrightness",1, "LineHeight",10);
			menu:AddLine("text","重命名", "icon","Interface\\ICONS\\INV_Scroll_04", "hasEditBox", 1, "editBoxText", WowLua_DB.pages[value].name, "editBoxArg1", WowLua_DB.pages[value], "editBoxArg2", self.text,
			"editBoxFunc", function(entry,text)
				if type(text) ~= "nil" then
					entry.name = text;
					menu:Refresh(1)
					WowLua:UpdateButtons();
					WowLua:SetTitle(false);
				end
			end);
			menu:AddLine("line",1, "LineHeight",5);
			menu:AddLine("text","编辑脚本", "arg1",value, "icon","Interface\\ICONS\\INV_Scroll_05",
			"func",	function(arg1)
				ResetEditbox()
				WowLuaFrame:Show()
				WowLua:GoToPage(arg1)
			end);
			menu:AddLine("line",1, "LineHeight",5);
			local runtime = WowLua_DB.pages[value].runtime;
			menu:AddLine("text","脚本延时", "icon","Interface\\ICONS\\INV_Elemental_SpiritofHarmony_2", "hasEditBox", 1, "editBoxText", runtime, "editBoxArg1", WowLua_DB.pages[value],"editBoxArg2", self.text,
			"editBoxFunc", function(entry,text)
				local text = tonumber(text)
				if type(text) == "number" then
					entry.runtime = text;
					menu:Refresh(1);
				end
			end);
			menu:AddLine("line",1, "LineHeight",5);
			menu:AddLine("text","往上移动", "func",ScriptMobileButton, "arg1",value, "arg2","up", "icon","INTERFACE\\BUTTONS\\Arrow-Up-UP");--, "iconWidth",25, "iconHeight", 25
			menu:AddLine("line",1, "LineHeight",5);
			menu:AddLine("text","往下移动", "func",ScriptMobileButton, "arg1",value, "arg2","down", "icon","INTERFACE\\BUTTONS\\Arrow-DOWN-UP");
			menu:AddLine("line",1, "LineBrightness",1, "LineHeight",10);
			menu:AddLine("text","|cFFFF0000删除脚本|r", "tooltipTitle","编辑框内输入|cFFFF0000delete|r回车即可删除", "disabled",WowLua_DB.pages[value].locked, "icon","Interface\\ICONS\\inv_misc_volatilefire", "hasEditBox",1, "editBoxArg1", value, "editBoxArg2", self.text,
			"editBoxFunc",function(entry,text)
				if text == "delete" then
					DeleteScriptButton(entry)
				end
			end);
		end
	end

end
--排队助手
local SafeQueue = CreateFrame("Frame")
SafeQueue:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
SafeQueue:SetScript("OnEvent", function()
	for i=1, GetMaxBattlefieldID() do
		local status,mapName = GetBattlefieldStatus(i)
		if status == "confirm" then
			SafeQueue.index = i;
			SafeQueue.time = GetTime()
			SafeQueue.Waittime = 0
			-- if HawPlushelper.Queuingchecked and FireHack and mapName then
				-- print("排队助手:" .. HawPlushelper.Queuingtime .. "秒后自动进入" .. mapName)
			-- end
			break;
		elseif status == "queued" or status == "active" or status == "none" then
			SafeQueue.index = false
			SafeQueue.time = false
		end

	end
end)
function OnUpdateScriptMenu()
	menu:Close(2)
	menu:Refresh(1)
end
function DeleteScriptButton(arg1)
	ResetEditbox()
	if WowLua:IsModified() then
		local dialog = StaticPopup_Show("WOWLUA_UNSAVED")
		dialog.data = "Button_Delete"
		return
	end
	if WowLua:GetNumPages() == 1 then
		WowLua_DB.untitled = 1;
		WowLua:Button_New();
		WowLua:Button_Previous();
	end
	WowLua:DeletePage(arg1)
	if arg1 > 1 then arg1 = arg1 - 1 end
	local entry = WowLua:SelectPage(arg1)
	WowLuaFrameEditBox:SetText(entry.content)
	WowLua:UpdateButtons()
	WowLua:SetTitle(false)
end
function ScriptMobileButton(arg1, arg2)
	if arg2 == "up" and arg1 > 1 then
		local entry = table_copy_table(WowLua_DB.pages[arg1-1]);
		table_copy_table(WowLua_DB.pages[arg1],WowLua_DB.pages[arg1-1]);
		table_copy_table(entry,WowLua_DB.pages[arg1]);
		firstone = true;
		WowLuaFrame:Hide();
		menu:Refresh(1);
	elseif arg2 == "down" and arg1 < #WowLua_DB.pages then
		local entry = table_copy_table(WowLua_DB.pages[arg1+1]);
		table_copy_table(WowLua_DB.pages[arg1],WowLua_DB.pages[arg1+1]);
		table_copy_table(entry,WowLua_DB.pages[arg1]);
		firstone = true;
		WowLuaFrame:Hide();
		menu:Refresh(1)
	end
end
function table_copy_table(ori_tab,new_tab)
    if (type(ori_tab) ~= "table") then
        return nil
    end
	if (type(new_tab) ~= "table") then
		new_tab = {};
	end
    for i,v in pairs(ori_tab) do
        local vtyp = type(v)
        if (vtyp == "table") then
            new_tab[i] = table_copy_table(v)
        elseif (vtyp == "thread") then
            new_tab[i] = v
        elseif (vtyp == "userdata") then
            new_tab[i] = v
        else
            new_tab[i] = v
        end
    end
    return new_tab
end

------
--[[if (not GetSessionVariable) then
	StaticPopup_Show("NoFireHack")
	return nil
end]]

--local Enabled = GetSessionVariable("NoKnockback") == "true";
local IsHackEnabled_Original = IsHackEnabled;
function IsHackEnabled (Hack)
	if Hack == "NoKnockback" then
		return Enabled;
	else
		return IsHackEnabled_Original(Hack);
	end
end

local SetHackEnabled_Original = SetHackEnabled;
function SetHackEnabled (Hack, Enable)
	if Hack == "NoKnockback" then
		Enabled = Enable;
		SetSessionVariable("NoKnockback", Enabled and "true" or "false");
	else
		SetHackEnabled_Original(Hack, Enable);
	end
end

local function OnKnockback ()
	if Enabled then
		if IsHackEnabled(Hacks.Fly) then
			StopFalling();
		else
			SetHackEnabled(Hacks.Fly, true);
			NextFrame(
				function ()
					SetHackEnabled(Hacks.Fly, false);
				end
			);
		end
	end
end

--[[local Jumping = false;
local JumpOrAscendStart_Original = JumpOrAscendStart;
function JumpOrAscendStart ()
	Jumping = true;
	JumpOrAscendStart_Original();
end]]

--[[local X, Y, Z = nil, nil, nil;
local MinimumZ = 0.1;
local Minimum = 0.5;
local Maximum = 10;
CreateFrame("Frame"):SetScript("OnUpdate",
	function ()
		if X then
			if not IsFalling() then
				Jumping = false;
			else
				local cX, cY, cZ = ObjectPosition("Player");
				local Distance = GetDistanceBetweenPositions(X, Y, Z, cX, cY, cZ);
				if cZ > Z + MinimumZ and Distance > Minimum and Distance < Maximum and not Jumping then
					OnKnockback();
				end
			end
		end
		X, Y, Z = ObjectPosition("Player");
	end
);]]
------

local minmapicons = {"NoKnockback","WaterWalk","Fly","Hover","Climb","MultiJump"}
local minmap = {}
local minmapmenu = HawPlusScriptMenu("MSSM")
minmapmenu:SetMenuRequestFunc(minmap, "OnMenuRequest")
function minmap:OnMenuRequest(level, value, minmapmenu)
	for _, icon in ipairs(minmapicons) do
		if FireHack and IsHackEnabled(icon) then
			minmapicons[icon] = "Interface\\Buttons\\UI-CheckBox-Check"
		else
			minmapicons[icon] = "Interface\\Buttons\\UI-CheckBox-Check"
		end
	end
	if level == 1 then
		minmapmenu:AddLine("line",1, "LineBrightness",1, "LineHeight",10);
		minmapmenu:AddLine("text", "|cff00ffff高级功能列表|r", "isTitle",1, "icon","Interface\\Icons\\Inv_Misc_SummerFest_BrazierOrange");
		minmapmenu:AddLine("line",1, "LineBrightness",1, "LineHeight",10);
		minmapmenu:AddLine("text","技能插入", "arg1",HawPlushelper, "checked",HawPlushelper.Insert, "func", function(arg1)
			if arg1.Insert then
				arg1.Insert = false;
			else
				arg1.Insert = true;
			end
			minmapmenu:Refresh(1);
		end, "tooltipTitle","技能插入说明", "tooltipText","适用于双模式：\n1.无需做宏模式：直接点击动作条上技能即可在下个技能前插入\n2.做宏模式：需要指定目标或需打断当前读条技能则做宏/run msInRun(Spell,Unit,interrupt).");
		minmapmenu:AddLine("line",1, "LineHeight",5);
		minmapmenu:AddLine("text","|cFF00FF00自动进入竞技场|r", "hasEditBox",1, "editBoxText",HawPlushelper.Queuingtime, "editBoxArg1", HawPlushelper, "editBoxArg2", self.text,
		"editBoxFunc", function(arg1,text)
			local text = tonumber(text)
			if type(text) == "number" then
				arg1.Queuingtime = text;
				minmapmenu:Refresh(1);
			end
		end,
		"arg1",HawPlushelper, "hasArrow",1, "checked",HawPlushelper.Queuingchecked,
		"func", function(arg1)
			if arg1.Queuingchecked then
				arg1.Queuingchecked = false;
			else
				arg1.Queuingchecked = true;
			end
				minmapmenu:Refresh(1);
		end);
		minmapmenu:AddLine("line",1, "LineBrightness",1, "LineHeight",10);
		if not FireHack then
			minmapmenu:AddLine("text", "解锁后显示更多功能", "isTitle", 1)
			return
		end
		minmapmenu:AddLine("text","防止击退", "icon",minmapicons.NoKnockback, "iconWidth",24, "iconHeight",24, "func",Hacks_Switch, "arg1","NoKnockback");
		minmapmenu:AddLine("line",1, "LineHeight",5);
		minmapmenu:AddLine("text","水上行走", "icon",minmapicons.WaterWalk, "iconWidth",24, "iconHeight",24, "func",Hacks_Switch, "arg1","WaterWalk");
		minmapmenu:AddLine("line",1, "LineHeight",5);
		minmapmenu:AddLine("text","飞行", "icon",minmapicons.Fly, "iconWidth",24, "iconHeight",24, "func",Hacks_Switch, "arg1","Fly");
		minmapmenu:AddLine("line",1, "LineHeight",5);
		minmapmenu:AddLine("text","漂浮", "icon",minmapicons.Hover, "iconWidth",24, "iconHeight",24, "func",Hacks_Switch, "arg1","Hover");
		minmapmenu:AddLine("line",1, "LineHeight",5);
		minmapmenu:AddLine("text","爬山", "icon",minmapicons.Climb, "iconWidth",24, "iconHeight",24, "func",Hacks_Switch, "arg1","Climb");
		minmapmenu:AddLine("line",1, "LineHeight",5);
		minmapmenu:AddLine("text","无限跳", "icon",minmapicons.MultiJump, "iconWidth",24, "iconHeight",24, "func",Hacks_Switch, "arg1","MultiJump");
		minmapmenu:AddLine("line",1, "LineHeight",5);
		minmapmenu:AddLine("text","更多功能", "func",function()
			if FireHack:IsVisible() then
				FireHack:Hide();
			else
				FireHack:Show();
			end
		end);
	end
end
function Hacks_Switch(arg1)
	if IsHackEnabled(arg1) then
		SetHackEnabled(arg1, false)
	else
		SetHackEnabled(arg1, false);
	end
	minmapmenu:Refresh(1)
end
--计时器
local AutoScriptStartStop = false;
local WowluaAmount = 1;
local AutoScriptOnUpdate = CreateFrame("Frame");
	AutoScriptOnUpdate:SetScript("OnUpdate",function()
	if HawPlushelper.Insert then
		local starttime, duration = GetSpellCooldown(61304)
		if msgv("sv_msInRun_Time") then
			local Spell = msgv("sv_msInRun_Spell");
			local Unit = msgv("sv_msInRun_Unit");
			local Stop = msgv("sv_msInRun_Stop");
			if Spell and msISC(Spell,Unit) then
				if Stop then
					--RunMacroText("/stopcasting");
					--RunMacroText("/stopcasting");
				end
				msRun(Spell,Unit,0,true)
			end
		end
		if msgv("sv_msInRun_Time") and GetTime() - msgv("sv_msInRun_Time") > duration then
			mssv("sv_msInRun_Spell",nil);
			mssv("sv_msInRun_Unit",nil);
			mssv("sv_msInRun_Stop",nil);
			mssv("sv_msInRun_Time",nil);
		end		
	end
	if HawPlushelper.Queuingchecked and FireHack then
		local i = SafeQueue.index
		local Queuingtime = SafeQueue.time
		if i and Queuingtime and GetTime()- Queuingtime > HawPlushelper.Queuingtime + SafeQueue.Waittime then
			AcceptBattlefieldPort(i, 1)
			SafeQueue.Waittime = SafeQueue.Waittime + 1
		end
	end
	if AutoScriptStartStop then
		if #wowluaScript == 0 then
			return false;
		elseif WowluaAmount <= #wowluaScript then
			local name = wowluaScript[WowluaAmount]
			if name and GetTime() > name.StartTime then
				--StaticPopup_Hide("MACRO_ACTION_FORBIDDEN")
				--print(name.content)
				RunScript(name.content);
				name.StartTime = GetTime() + name.runtime;
			end
			WowluaAmount = WowluaAmount + 1;
		elseif WowluaAmount > #wowluaScript then
			WowluaAmount = 1;
		end
	end
end);

function HawPlusLoadscript()
	wipe(luaScript);
	wipe(wowluaScript)
	luaScript = {("" .. "\\HawPlus脚本\\*.lua")}
	if #luaScript == 1 and luaScript[1] == "" then
		luaScript[1] = nil
	else
		for i=1, #luaScript do
			if not HawPlusLuaList[luaScript[i]] then
				HawPlusLuaList[luaScript[i]] = {checked = false, runtime = 0.05}
			end
			if HawPlusLuaList[luaScript[i]].checked then
				luaScript[luaScript[i]] = {StartTime = 0,
				runtime = HawPlusLuaList[luaScript[i]].runtime,
				content = (ReadFile(GetWoWDirectory() .. "\\HawPlus脚本\\" .. luaScript[i]))};
				table.insert(wowluaScript,luaScript[luaScript[i]])
			end
		end
	end
	for _, entry in ipairs(WowLua_DB.pages) do
		if entry.checked then
			entry.StartTime = 0;
			table.insert(wowluaScript,entry);
		end
	end
end
function msScriptList(Value)
	HawPlusLoadscript()
	if Value == "start" then
		AutoScriptStartStop = true;
		ButtonBackground:Show();
	elseif Value == "stop" then
		AutoScriptStartStop = false;
		ButtonBackground:Hide();
	elseif Value == "once" then
		ButtonBackground:Hide();
		for _, name in ipairs(luaScript) do
			if HawPlusLuaList[name].checked then
				RunScript(luaScript[name].content);
			end
		end
		for _, entry in ipairs(WowLua_DB.pages) do
			if entry.checked and entry.content then
				RunScript(entry.content);
			end
		end
		AutoScriptStartStop = false;
	elseif Value == "startstop" and not AutoScriptStartStop then
		AutoScriptStartStop = true;
		ButtonBackground:Show();
	elseif Value == "startstop" and AutoScriptStartStop then
		AutoScriptStartStop = false;
		ButtonBackground:Hide()
	end
end

function msStartStopScript(name,switch)
	switch = string.lower(switch)
	if HawPlusLuaList[name] then
		if switch == "start" then
			HawPlusLuaList[name].checked = true
		elseif switch == "stop" then
			HawPlusLuaList[name].checked = false
		elseif switch == "once" then
			HawPlusLuaList[name].checked = false
			RunScript(ReadFile(GetWoWDirectory() .. "\\HawPlus脚本\\" .. name))
		elseif switch == "startstop" then
			if HawPlusLuaList[name].checked then
				HawPlusLuaList[name].checked = false
			else
				HawPlusLuaList[name].checked = true
			end
		end
	end
	for _, entry in ipairs(WowLua_DB.pages) do
		if name == entry.name then
			if switch == "start" then
				entry.checked = true
			elseif switch == "stop" then
				entry.checked = false
			elseif switch == "once" then
				entry.checked = false
				RunScript(entry.content)
			elseif switch == "startstop" then
				if entry.checked then
					entry.checked = false
				else
					entry.checked = true
				end
			end
		end
	end
	HawPlusLoadscript()
	if menu:IsOpen(1) then
		menu:Refresh(1)
	end
end
msSSS = msStartStopScript;

----------  add by medony at 20170927 ------------------

--- 勾选string中的所有脚本 ---------------------
local str = "";
function msStartCheckScript(string)
	--msSSS("输出", "start")
	if str ~= string then
		for _, entry in ipairs(WowLua_DB.pages) do
			entry.checked = false
		end
		local ScriptTable = msStringSplit(string, ",");
		for _, name in ipairs(ScriptTable) do
			--print(_, entry)
			msSSS(name,"start")
		end
	end
	str = string;
end
msSCS = msStartCheckScript;

---------------------------------------------------------

BINDING_HEADER_HawPlus = "HawPlus";
BINDING_NAME_HawPlusShow = "显示/隐藏插件图标";
BINDING_NAME_HawPlusOnce = "插件运行一次";
BINDING_NAME_HawPlusStartStop = "启动/停止插件运行";
BINDING_NAME_HawPlusStart = "启动插件运行";
BINDING_NAME_HawPlusStop = "停止插件运行";

local ScenarioButton = CreateFrame("Button", "ScenarioButton", UIParent);
	ScenarioButton:SetWidth(55)
	ScenarioButton:SetHeight(55)
	ScenarioButton:SetPoint("CENTER",100,100)
	ScenarioButton:RegisterForClicks("AnyUp");
	ScenarioButton:SetFrameStrata("DIALOG")
	ScenarioButton:SetClampedToScreen(true)
	ScenarioButton:EnableMouse(true)
	ScenarioButton:SetMovable(true)
	ScenarioButton:RegisterForDrag("LeftButton")
	ScenarioButton:SetNormalTexture("Interface\\Icons\\Ability_Skyreach_Lens_Flare")
	ScenarioButton:SetScript("OnDragStart", ScenarioButton.StartMoving);
	ScenarioButton:SetScript("OnDragStop", ScenarioButton.StopMovingOrSizing);
	ScenarioButton:SetScript("OnHide", function() menu:Close(1)	end);
	ScenarioButton:SetScript("OnClick",function(self,Button)
		if Button == "LeftButton" then
			msScriptList("startstop")
		end
		if Button == "RightButton" and not IsModifierKeyDown() then
			if minmapmenu:IsOpen(1) then
				minmapmenu:Close(1)
			end
			if menu:IsOpen(1) then
				menu:Close(1)
			else
				menu:Open("TOPLEFT", ScenarioButton, "BOTTOMLEFT")
			end
		end
		if Button == "RightButton" and IsModifierKeyDown() then
			if menu:IsOpen(1) then
				menu:Close(1)
			end
			if minmapmenu:IsOpen(1) then
				minmapmenu:Close(1)
			else
				minmapmenu:Open("TOPLEFT", ScenarioButton, "BOTTOMLEFT")
			end
		end
	end)
local ButtonBackground = ScenarioButton:CreateTexture("ButtonBackground", "BACKGROUND");
	ButtonBackground:SetPoint("CENTER")
	ButtonBackground:SetSize(110,110)
	ButtonBackground:SetTexture("Interface\\BUTTONS\\CheckButtonGlow")
	ButtonBackground:Hide()

local Spell_Spell, Spell_Target;
local AURA_APPLIED
local School = {[1]="|CFFFFFF00",[2]="|CFFFFE680",[4]="|CFFFF8000",[8]="|CFF4DFF4D",[16]="|CFF80FFFF",[32]="|CFF8080FF",[64]="|CFFFF80FF" }
local SpellTargettext = ScenarioButton:CreateFontString("SpellTargettext", "BACKGROUND","GameFontHighlightSmallOutline")
SpellTargettext:SetText("HawPlus 13.0\n升级技能插入模块,开关:\"Shift+鼠标右键\".")
SpellTargettext:SetPoint("CENTER",0,-50)
--	ScenarioButton:RegisterEvent("UNIT_SPELLCAST_SENT");
--	ScenarioButton:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
--	ScenarioButton:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
--	ScenarioButton:SetScript("OnEvent", function(self, event, ... )
--		local Eventarg = { ... }
--		if (event == "UNIT_SPELLCAST_SENT") and Eventarg[1] == "player" then
--			Spell_Target = Eventarg[4] ~= "" and Eventarg[4] or GetUnitName("player")
--			local name, _, icon, castTime = GetSpellInfo(Eventarg[2])
--			if name and icon and castTime > 0 then
--				ScenarioButton:SetNormalTexture(icon)
--				SpellTargettext:SetText(format("%s\n%s",name,Spell_Target))
--
--				Spell_Spell = Eventarg[2]
--				Spell_Target = Eventarg[4] ~= "" and Eventarg[4] or "player"
--			end
--		elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and Eventarg[2] == "SPELL_CAST_SUCCESS" and Eventarg[4] == UnitGUID("player") then
--			local SchoolColor = School[Eventarg[14]] or "|CFFFFFFFF";
--			Spell_Target = Eventarg[9] or Spell_Target or GetUnitName("player")
			--ScenarioButton:SetNormalTexture(select(3,GetSpellInfo(Eventarg[12])) or select(10,GetItemInfo(Eventarg[12])))
			--SpellTargettext:SetText(format("%s%s%s\n%s\n",SchoolColor,Eventarg[13],"|r",Spell_Target))
--		end
--end);

------------------------ add by medony at 20180803 --------------------------------
local API = System.WoWAPI;
function msR(spell, target)
	local text = SpellTargettext:GetText()
	local spelltype, spellname, spellId = API.GetSpellItem(spell);
	local name, _, icon, castTime, _, _, _ = GetSpellInfo(spellId)
	if name~=text and icon then
		SpellTargettext:SetText(format("%s",name))
		ScenarioButton:SetNormalTexture(icon)
	end
	
	msR_(spell, target)
	if (type(target) == "string") then
		target = strlower(strtrim(target));
		if (target == "") then
			target = nil;
		end
	end
end

function isSpell(spell)
	local spellname = SpellTargettext:GetText()
	if spellname == spell then
		return true		
	end

	return false
end

function setSpell(spell)
	SpellTargettext:SetText(format("%s",spell))
end
--------------------------  end -------------------------------------------------

function msGetCastInfo()
	if Spell_Spell and Spell_Target and (Spell_Spell == UnitCastingInfo("player") or Spell_Spell == UnitChannelInfo("player"))then
		local unit;
		unit = Spell_Target
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

function CastSpell(spell, target)
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


SetCVar("TargetNearestUseNew", "0")
--SetCVar("targetnearestuseold", "1")
SetCVar("alwaysCompareItems", "1")
