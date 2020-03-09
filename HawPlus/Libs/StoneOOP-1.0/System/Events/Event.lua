--------------------------------------------------------------------------------------
--							WoW <System.Event> Class								--
--------------------------------------------------------------------------------------
--	Mainly used as an interface for registering WoW in-game events handlers	and		--
--	provide a events cache to store the most recent events							--
--------------------------------------------------------------------------------------
if (System.Event) then
	return;
end

--UpValues
local type = type;
local tinsert = table.insert;
local tremove = table.remove;
local wipe = wipe;
local pairs = pairs;

local Events = {};
local EventLifeTime = 30;
local SourceFrame = CreateFrame("Frame");
SourceFrame:RegisterAllEvents();
SourceFrame:SetScript("OnEvent", function(self, eventname, ...)
	local eventClass = System.Event;
	local curEvent = Events[eventname];
	if (type(curEvent) ~= "table" or #curEvent.Pool == 0) then
		return;
	end
	--Cache
	local cache = curEvent.Cache;
	local currentTime = GetTime();
	for k, v in pairs(cache) do
		if (currentTime - k > eventClass.LifeTime) then
			cache[k] = nil;
			wipe(v);
		end
	end
	cache[currentTime] = {...};
	--Pool
	local pool = Events[eventname].Pool;
	for i = 1, #pool do
		pool[i]:OnTriggered(...);
	end
end);

--WoW Event Class
local EventClassDef = {
	Name = "System.Event",
	Functions = {
		GetTriggeredEvents = {
			Desc = [[Get the triggered events in a table]],
			Func = function(self, startTimeSpan, endTimeSpan)
				local startTime, endTime;
				local currentTime = GetTime();
				if (Number.UInt.Validate(startTimeSpan)) then
					startTime = currentTime - startTimeSpan;
				end
				if (Number.UInt.Validate(endTimeSpan)) then
					endTime = currentTime - endTimeSpan;
				end
				startTime = startTime or 0;
				endTime = endTime or 999999;
				if (startTime > endTime) then
					startTime, endTime = endTime, startTime;
				end
				local cache = Events[self.Name].Cache;
				local result = {};
				local count = 0;
				for k, v in pairs(cache) do
					if (k > startTime and k < endTime) then
						result[k] = v;
					end
					count = count + 1;
				end
				return count,result;
			end,
		},
	},
	Properties = {
		Name = {
			Desc = [[Get the current event name]],
			Type = String,
			Get = function(self)
				return self._EventName;
			end,
		},
		LifeTime = {
			Desc = [[Get/Set for how long an event is cached in milliseconds]],
			Type = Number.UInt,
			Get = function(self)
				return self._LifeTime * 1000;
			end,
			Set = function(self, value)
				self._LifeTime = value / 1000;
			end,
			Static = true,
		},
	},
	Events = {
		OnTriggered = {
			Desc = [[Triggered when the current event is fired]],
		},
	},
	Constructor = function(self, eventName)
		if (type(eventName) ~= "string") then
			return true, "Invalid event name is provided";
		end
		self._EventName = eventName;
		Events[eventName] = Events[eventName] or {
			Cache = {},
			Pool = {},
		};
		tinsert(Events[eventName].Pool, self);
	end,
	Destructor = function(self)
		local pool = Events[self.Name].Pool;
		for i = 1, #pool do
			if (pool[i] == self) then
				tremove(pool, i);
				return;
			end
		end
	end,
};
System.Event = newclass(EventClassDef);
System.Event.LifeTime = EventLifeTime;