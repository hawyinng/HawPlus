if (newclass) then
	return;
end

--System upvalues
local type = type;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local rawset = rawset;
local rawget = rawget;
local setfenv = setfenv;
local tinsert = table.insert;
local tremove = table.remove;
local format = string.format;
--Classes with defs, entities and baseinfo
local Classes = {};
local function GetClassMember(classname,membertype,membername,static)
	if (type(classname) ~= "string" or type(membertype) ~= "string" or type(membername) ~= "string") then
		return false;
	end
	local def = Classes[classname];
	if (type(def) == "table" and type(def.Definition) == "table") then
		def = def.Definition[membertype][membername];
	else
		return false;
	end
	if (type(def) ~= "table") then
		return false;
	end
	if ((static and def.Static) or (not static and not def.Static)) then
		return true,def;
	else
		return false;
	end
end
--Every object's environment table, events handlers cache & etc.
local ObjectsInfo = {};
--Add an event handler
local function AddHandler(self,event,func)
	if (type(event) ~= "string") then
		return;
	end
	local handlers = ObjectsInfo[self].EventHandlers[event];
	if (type(func) ~= "function") then
		if (func == nil) then
			for i=1, getn(handlers) do
				handlers[i] = nil;
			end
		end
		return;
	end
	for i=1, getn(handlers) do
		if (handlers[i] == func) then
			return;
		end
	end
	tinsert(handlers,func);
	return handlers;
end
--Remove an event handler
local function RemoveHandler(self,event,func)
	if (type(event) ~= "string" or type(func) ~= "function") then
		return;
	end
	local handlers = ObjectsInfo[self].EventHandlers[event];
	for i=1, getn(handlers) do
		if (handlers[i] == func) then
			tremove(handlers,i);
			return handlers;
		end
	end
end
--Fire an event
local function FireEvent(self,event,...)
	if (type(event) ~= "string") then
		return;
	end
	local handlers = ObjectsInfo[self].EventHandlers[event];
	for i=1, getn(handlers) do
		handlers[i](...);
	end
end
--Events handlers' metatable
local EventMeta = {
	__index = function(self,k)
		return nil;
	end,
	__add = function(self,func)
		local handlers = AddHandler(self._Parent,self._Name,func);
		if (not handlers) then
			error("Invalid event handler:" .. tostring(func),2);
		end
		return handlers;
	end,
	__sub = function(self,func)
		local handlers = RemoveHandler(self._Parent,self._Name,func);
		if (not handlers) then
			error("Invalid event handler:" .. tostring(func),2);
		end
		return handlers;
	end,
	__call = function(self,...)
		FireEvent(self._Parent,self._Name,...);
	end,
};

--Get member
local GetDepth = 0;
local function GetClassMemberInherited(self,classname,membername,static)
	local def = Classes[classname].Definition;
	GetDepth = GetDepth + 1;
	if (type(def) ~= "table") then
		GetDepth = GetDepth - 1;
		return false;
	end
	local succ,member = GetClassMember(classname,"Functions",membername,static);
	if (succ) then
		GetDepth = GetDepth - 1;
		return true,"function",member.Func,member.Func;
	end
	succ,member = GetClassMember(classname,"Properties",membername,static);
	if (succ) then
		local get = rawget(self,"Get" .. membername);
		if (type(get) ~= "function") then
			get = member.Get;
			rawset(self,"Get" .. membername,get);
		end
		if (type(get) == "function") then
			GetDepth = GetDepth - 1;
			return true,"property",get,get(self);
		else
			curdepth = GetDepth;
			GetDepth = 0;
			error(format("Unable to get property \"%s\"'s value which is not allowed to be GET.",membername),2+curdepth);
		end
	end
	succ,member = GetClassMember(classname,"Events",membername,static);
	if (succ) then
		if (type(ObjectsInfo[self].EventHandlers[membername]) ~= "table") then
			local handler = {};
			handler._Parent = self;
			handler._Name = membername;
			setmetatable(handler,EventMeta);
			ObjectsInfo[self].EventHandlers[membername] = handler;
		end
		GetDepth = GetDepth - 1;
		return true,"event",ObjectsInfo[self].EventHandlers[membername],ObjectsInfo[self].EventHandlers[membername];
	end
	for i=1, getn(def.Bases) do
		local basedef = def.Bases[i];
		basedef = Classes[basedef];
		if (type(basedef) == "table") then
			basedef = basedef.Definition;
		end
		if (type(basedef) == "table" and basedef.Name ~= classname) then
			local succ,membertype,member,result = GetClassMemberInherited(self,basedef.Name,membername,static);
			if (succ) then
				GetDepth = GetDepth - 1;
				return succ,membertype,member,result;
			end
		end
	end
	GetDepth = GetDepth - 1;
	return false;
end
--Set member
local SetDepth = 0;
local function SetClassMemberInherited(self,classname,membername,value,static)
	local def = Classes[classname].Definition;
	local curdepth;
	SetDepth = SetDepth + 1;
	if (type(def) ~= "table") then
		SetDepth = SetDepth - 1;
		return false;
	end
	local succ,member = GetClassMember(classname,"Properties",membername,static);
	if (succ) then
		local set = rawget(self,"Set" .. membername);
		if (type(set) ~= "function") then
			set = member.Set;
			rawset(self,"Set" .. membername,set);
		end
		if (type(set) == "function") then
			local parsed = member.Type.Parse(value);
			if (member.Type.Validate(parsed) and (member.Nullable or not member.Nullable and parsed ~= nil)) then
				local check = member.Check;
				if (type(check) ~= "function" or type(check) == "function" and check(self,parsed)) then
					SetDepth = SetDepth - 1;
					return true,"property",set,set(self,parsed);
				end
			end
			curdepth = SetDepth;
			SetDepth = 0;
			if (type(value) == "string") then
				value = "\"" .. value .. "\"";
			end
			error(format("Unable to set property \"%s\"'s value to: %s, which is not of or cannot be parsed to type \"%s\".",membername,tostring(value),member.Type.ToString()),2+curdepth);
		else
			curdepth = SetDepth;
			SetDepth = 0;
			error(format("Unable to set property \"%s\"'s value which is not allowed to be SET.",membername),2+curdepth);
		end
		SetDepth = SetDepth - 1;
		return false;
	end
	succ,member = GetClassMember(classname,"Events",membername,static);
	if (succ) then
		SetDepth = SetDepth - 1;
		return true,"event",AddHandler(self,membername,value),AddHandler(self,membername,value);
	end
	for i=1, getn(def.Bases) do
		local basedef = def.Bases[i];
		basedef = Classes[basedef];
		if (type(basedef) == "table") then
			basedef = basedef.Definition;
		end
		if (type(basedef) == "table" and basedef.Name ~= classname) then
			local succ,membertype,member,result = SetClassMemberInherited(self,basedef.Name,membername,value,static);
			if (succ) then
				SetDepth = SetDepth - 1;
				return succ,membertype,member,result;
			end
		end
	end
	SetDepth = SetDepth - 1;
	return nil;
end
--Keyword "base" and "this" metatable
local KeywordMeta = {
	__call = function(self,...)
		return self._Constructor(...);
	end,

};
--Class entity's metatable
local ClassEntityMeta = {
	__call = function(self,...)
		return newobject(self,...);
	end,
	__index = function(self,k)
		if (k == "Name") then
			return self._Name;
		end
		local succ,membertype,member,result = GetClassMemberInherited(self,self._Name,k,true);
		if (succ) then
			if (membertype == "function") then
				rawset(self,k,member);
			elseif (membertype == "property") then
				rawset(self,"Get" .. k,member);
			end
		end
		return result;
	end,
	__newindex = function(self,k,v)
		local succ,membertype,member,result = SetClassMemberInherited(self,self._Name,k,v,true);
		if (succ) then
			if (membertype == "property") then
				rawset(self,"Set" .. k,member);
			end
			return result;
		else
			rawset(self,k,v);
		end
	end,
};
--Object's metatable
local ObjectMeta = {
	__call = function(self,...)
		local def = Classes[self._ClassName].Definition;
		return def.Constructor(self,...);
	end,
	__index = function(self,k)
		local succ,membertype,member,result = GetClassMemberInherited(self,self._ClassName,k,false);
		if (succ) then
			if (membertype == "function") then
				rawset(self,k,member);
			elseif (membertype == "property") then
				rawset(self,"Get" .. k,member);
			end
		end
		return result;
	end,
	__newindex = function(self,k,v)
		local succ,membertype,member,result = SetClassMemberInherited(self,self._ClassName,k,v,false);
		if (succ) then
			if (membertype == "property") then
				rawset(self,"Set" .. k,member);
			end
			return result;
		else
			rawset(self,k,v);
		end
	end,
};

--Create a new class
function newclass(def)
	--Verify def
	local newdef = {};
	if (type(def) ~= "table") then
		return nil,"Class definition must be a table.";
	end
	--Verify Name
	local name = def.Name;
	if (type(name) ~= "string" or Classes[name]) then
		return nil,"Invalid class name which may be existed.";
	end
	newdef.Name = name;
	--Verify Bases
	local bases = def.Bases;
	bases = bases or {};
	if (type(bases) ~= "table") then
		return nil,"Invalid class bases definition which must be a table.";
	end
	local foundobject = false;
	newdef.Bases = {};
	for i=1, getn(bases) do
		if (type(bases[i]) ~= "string") then
			return nil,format("Invalid class bases definition. The %dth base is not a string",i);
		end
		if (bases[i] == "Object") then
			foundobject = true;
		end
		newdef.Bases[i] = bases[i];
	end
	if (not foundobject) then
		tinsert(newdef.Bases,"Object");
	end
	--Verify Constructor
	local constructor = def.Constructor;
	constructor = constructor or function() end;
	if (type(constructor) ~= "function") then
		return nil,"Invalid class constructor which is must be a function.";
	end
	newdef.Constructor = constructor;
	--Verify Destructor
	local destructor = def.Destructor;
	destructor = destructor or function() end;
	if (type(destructor) ~= "function") then
		return nil,"Invalid class destructor which is must be a function.";
	end
	newdef.Destructor = destructor;
	--Verify Functions
	local funcs = def.Functions;
	funcs = funcs or {};
	if (type(funcs) ~= "table") then
		return nil,"Invalid class functions definition which is must be a table.";
	end
	newdef.Functions = {};
	for k,func in pairs(funcs) do
		if (type(func) ~= "table") then
			return nil,format("Invalid class functions definition. The function \"%s\" is not a table",k);
		end
		newdef.Functions[k] = {};
		if (type(func.Func) ~= "function") then
			return nil,format("Invalid class functions definition. The function \"%s\"'s Value is not a function",k);
		end
		newdef.Functions[k].Func = func.Func;
		newdef.Functions[k].Desc = func.Desc;
		newdef.Functions[k].Static = func.Static;
	end
	--Verify Properties
	local props = def.Properties;
	props = props or {};
	if (type(props) ~= "table") then
		return nil,"Invalid class properties definition which is must be a table.";
	end
	newdef.Properties = {};
	for k,prop in pairs(props) do
		if (type(prop) ~= "table") then
			return nil,format("Invalid class properties definition. The property \"%s\" is not a table",k);
		end
		newdef.Properties[k] = {};
		if (prop.Get ~= nil and type(prop.Get) ~= "function") then
			return nil,format("Invalid class properties definition. The property \"%s\"'s Get function is not a function",k);
		end
		newdef.Properties[k].Get = prop.Get;
		if (prop.Set ~= nil and type(prop.Set) ~= "function") then
			return nil,format("Invalid class properties definition. The property \"%s\"'s Set function is not a function",k);
		end
		newdef.Properties[k].Set = prop.Set;
		local typeentity;
		local curtype = prop.Type;
		if (type(curtype) == "string") then
			typeentity = getclass("Type." .. curtype);
		elseif (type(curtype) == "table" and curtype:HasBaseClass("Type")) then
			typeentity = curtype;
		else
			typeentity = getclass("Type.var");
		end
		newdef.Properties[k].Type = typeentity;
		newdef.Properties[k].Check = prop.Check;
		newdef.Properties[k].Static = prop.Static;
		newdef.Properties[k].Desc = prop.Desc;
	end
	--Verify Events
	local events = def.Events;
	events = events or {};
	if (type(events) ~= "table") then
		return nil,"Invalid class events definition which is must be a table.";
	end
	newdef.Events = {};
	for k,event in pairs(events) do
		if (type(event) ~= "table") then
			return nil,format("Invalid class events definition. The event \"%s\" is not a table",k);
		end
		newdef.Events[k] = {};
		newdef.Events[k].Desc = event.Desc;
		newdef.Events[k].Static = event.Static;
	end
	Classes[name] = {};
	Classes[name].Definition = newdef;
	--Create entity
	local entity = {};
	Classes[name].Entity = entity;
	ObjectsInfo[entity] = {};
	ObjectsInfo[entity].EventHandlers = {};
	local handlers = ObjectsInfo[entity].EventHandlers;
	for k,event in pairs(newdef.Events) do
		local handler = {};
		handler._Parent = entity;
		handler._Name = k;
		setmetatable(handler,EventMeta);
		handlers[k] = handler;
	end
	entity._Name = name;
	setmetatable(entity,ClassEntityMeta);
	--Create query
	local query = {};
	Classes[name].Query = query;
	query._Constructor = constructor;
	setmetatable(query,KeywordMeta);
	--Return
	return entity;
end

--Get an existing class by name
function getclass(classname)
	if (type(classname) ~= "string") then
		return nil;
	end
	if (Classes[classname]) then
		return Classes[classname].Entity;
	else
		return nil;
	end
end

--Create a new object of class
function newobject(class,...)
	local object = {};
	local classname;
	if (type(class) == "string" and getclass(class)) then
		classname = class;
	elseif (type(class) == "table" and type(class.Name) == "string") then
		classname = class.Name;
	end
	if (classname) then
		object._ClassName = classname;
	else
		return nil,"Invalid class or classname";
	end
	setmetatable(object,ObjectMeta);
	ObjectsInfo[object] = {};
	ObjectsInfo[object].EventHandlers = {};
	local handlers = ObjectsInfo[object].EventHandlers;
	local def = Classes[classname].Definition;
	--Base
	rawset(object,"Base",{});
	for i=1, getn(def.Bases) do
		local baseclass = Classes[def.Bases[i]];
		if (baseclass) then
			object.Base[def.Bases[i]] = baseclass.Query;
		end
	end
	--Events
	for k,event in pairs(def.Events) do
		local handler = {};
		handler._Parent = object;
		handler._Name = k;
		setmetatable(handler,EventMeta);
		handlers[k] = handler;
	end
	local conResult = {object(...)};
	if(conResult[1]==true) then
		wipe(object);
		return nil,select(2,unpack(conResult));
	else
		return object;
	end
end

--Delete an existing object
function delobject(obj)
	if (type(obj) ~= "table") then
		return;
	end
	local classname = obj:GetClass().Name;
	Classes[classname].Definition.Destructor(obj);
	setmetatable(obj,nil);
	wipe(obj);
end

local function HasBase(classname,basename)
	if (type(classname) ~= "string" or type(basename) ~= "string") then
		return false;
	end
	local class = Classes[classname];
	local base = Classes[basename];
	if (type(class) ~= "table" or type(base) ~= "table") then
		return false;
	end
	local def = class.Definition;
	for i=1, getn(def.Bases) do
		local curbase = def.Bases[i];
		if (curbase == basename and type(Classes[curbase]) == "table") then
			return true;
		else
			if (HasBase(curbase,basename)) then
				return true;
			end
		end
	end
	return false;
end
local ObjectDef = {
	Name = "Object",
	Functions = {
		GetClass = {
			Desc = [[Get the class table to which the object belongs]],
			Func = function(self)
				return getclass(self._ClassName);
			end,
		},
		ToString = {
			Desc = [[Get the string representation of the object]],
			Func = function(self)
				return tostring(self);
			end,
		},
		HasBaseClass = {
			Desc = [[Get whether the object's class is inherited from the dedicated class]],
			Func = function(self,baseclass)
				if (type(baseclass) == "string" and type(Classes[baseclass]) == "table") then
				elseif (type(baseclass) == "table" and type(baseclass.Name) == "string") then
					baseclass = baseclass.Name;
				else
					return false;
				end
				return HasBase(self.Name,baseclass);
			end,
			Static = true;
		},
	},
};
local versionType, buildType = GetBuildInfo();
StaticPopupDialogs["MS_VERSION_EXPIRED"] = {
	text = versionType .. " " .. buildType .. "\n Ma" .. "gi" .. "cSto" .. "en is Disa" .. "ble！\n Updat" .. "e Link" .. "： www." .. "lua" .. "cn.net",
	button1 = "OK",
	OnAccept = function(self, data) end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = nil
};
if tonumber(buildType)>50000 then
	StaticPopup_Show("MS_VERSION_EXPIRED")
	newclass = {}
	System = ""
else
	newclass(ObjectDef)
end