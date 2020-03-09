--------------------------------------------------------------------------------------
--							WoW <System.Timer> Class								--
--------------------------------------------------------------------------------------
--	Provide a timer class to create timers											--
--------------------------------------------------------------------------------------
if(System.Timer) then
	return;
end

local timersFrame = CreateFrame("Frame");
local timers = {};

local SystemTimerClassDef = {
	Name = "System.Timer",
	Functions = {
		Start = {
			Desc = [[Starts raising the System.Timer.Elapsed event by setting System.Timers.Timer.Enabled to true.]],
			Func = function(self)
				self.Enabled = true;
			end,
		},
		Stop = {
			Desc = [[Stops raising the System.Timer.Elapsed event by setting System.Timer.Enabled to false.]],
			Func = function(self)
				self.Enabled = false;
			end,
		},
		Close = {
			Desc = [[Releases the System.Timer object.]],
			Func = function(self)
				delobject(self);
			end,
		},
	},
	Properties = {
		AutoReset = {
			Get = function(self)
				return self._AutoReset;
			end,
			Set = function(self,value)
				self._AutoReset = value;
			end,
			Type = Bool,
			Desc = [[Gets/Sets a value indicating whether the System.Timer should raise the System.Timer.Elapsed event each time the specified interval elapses or only after the first time it elapses.]],
		},
		Enabled = {
			Get = function(self)
				return self._Enabled;
			end,
			Set = function(self,value)
				self._Enabled = value;
				if(not value) then
					timers[self].Total = 0;
				end
			end,
			Type = Bool,
			Desc = [[Gets/Sets a value indicating whether the System.Timer should raise the System.Timers.Timer.Elapsed event.]],
		},
		Interval = {
			Get = function(self)
				return self._Interval;
			end,
			Set = function(self,value)
				self._Interval = value;
			end,
			Type = Number.UInt,
			Desc = [[Gets/sets the interval at which to raise the System.Timer.Elapsed event.]],
		},
	},
	Events = {
		Elapsed = {
			Desc = [[Occurs when the interval elapses.]],
		},
	},
	Constructor = function(self,interval)
		if(Number.UInt.Validate(interval)) then
			self._Interval = interval;
		else
			self._Interval = 0;
		end
		self._Enabled = false;
		self._AutoReset = false;
		timers[self] = timers[self] or {};
		timers[self].Total = 0;
	end,
	Destructor = function(self)
		wipe(timers[self]);
		timers[self] = nil;
	end,
};
System.Timer = newclass(SystemTimerClassDef);

timersFrame:SetScript("OnUpdate",function(self,elapsed)
	for k,v in pairs(timers) do
		if (k.Enabled and k.Interval > 0) then
			if (timers[k].Total >= k.Interval) then
				k:Elapsed();
				timers[k].Total = 0;
				if (k.AutoReset) then
					k.Enabled = false;
				end
			end
			timers[k].Total = timers[k].Total + elapsed * 1000;
		end
	end
end);