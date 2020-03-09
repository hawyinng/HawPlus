--------------------------------------------------------------------------------------
--							Stone Finite State Machine								--
--------------------------------------------------------------------------------------
--	Create and manage finite state machines											--
--------------------------------------------------------------------------------------
if (System.FSM) then
	return;
end

--UpValues
local Timer = System.Timer;
local format = string.format;
local pcall = pcall;
local Error = System.Error;

--FSMs cache
local Machines = {};

--FSM polling handler
local function Poll(self)
	local machine = self.Parent;
	local state, oldstate = machine._States[machine.Current], machine.Current;
	local succ, result;
	if (state.Reversed) then
		if (type(state.Action) == "function") then
			succ, result = pcall(state.Action, machine);
			if (not succ) then
				local _, line, desc = Error.Parse(result);
				machine:OnError(format("Something bad happened in line #%d of the action function of state \"%s\": %s", line, machine.Current, desc));
				machine:Pause();
				return;
			end
		end
		if (type(machine._Public) == "function") then
			local succ2, result2 = pcall(machine._Public, machine);
			if (not succ2) then
				local _, line, desc = Error.Parse(result2);
				machine:OnError(format("Something bad happened in line #%d of the public function: %s", line, desc));
				machine:Pause();
				return;
			elseif (type(result2) == "string") then
				if (not machine._States[result2]) then
					machine:OnError(format("The destination state \"%s\" returned from the public function does not exist.", result2));
					machine:Pause();
					return;
				end
				machine._Current = result2;
			elseif (result2 == 0) then
				machine:Stop();
				return;
			end
		end
		if (type(state.Transition) == "function") then
			succ, result = pcall(state.Transition, machine);
			if (not succ) then
				local _, line, desc = Error.Parse(result);
				machine:OnError(format("Something bad happened in line #%d of the transition function of state \"%s\": %s", line, machine.Current, desc));
				machine:Pause();
				return;
			end
			if (type(result) == "string") then
				if (machine._States[result]) then
					machine._Current = result;
					machine:OnStateChanged(machine._Current, oldstate);
				else
					machine:OnError(format("The destination state \"%s\" returned from the transition function of the state \"%s\" does not exist.", result, machine.Current));
					machine:Pause();
				end
				return;
			elseif (result == 0) then
				machine:Stop();
				return;
			end
		end
	else
		if (type(machine._Public) == "function") then
			local succ2, result2 = pcall(machine._Public, machine);
			if (not succ2) then
				local _, line, desc = Error.Parse(result2);
				machine:OnError(format("Something bad happened in line #%d of the public function: %s", line, desc));
				machine:Pause();
				return;
			elseif (type(result2) == "string") then
				if (not machine._States[result2]) then
					machine:OnError(format("The destination state \"%s\" returned from the public function does not exist.", result2));
					machine:Pause();
					return;
				end
				machine._Current = result2;
			elseif (result2 == 0) then
				machine:Stop();
				return;
			end
		end
		if (type(state.Transition) == "function") then
			succ, result = pcall(state.Transition, machine);
			if (not succ) then
				local _, line, desc = Error.Parse(result);
				machine:OnError(format("Something bad happened in line #%d of the transition function of state \"%s\": %s", line, machine.Current, desc));
				machine:Pause();
				return;
			end
			if (type(result) == "string") then
				if (machine._States[result]) then
					machine._Current = result;
					machine:OnStateChanged(machine._Current, oldstate);
				else
					machine:OnError(format("The destination state \"%s\" returned from the transition function of the state \"%s\" does not exist.", result, machine.Current));
					machine:Pause();
				end
				return;
			elseif (result == 0) then
				machine:Stop();
				return;
			end
		end
		if (type(state.Action) == "function") then
			succ, result = pcall(state.Action, machine);
			if (not succ) then
				local _, line, desc = Error.Parse(result);
				machine:Pause();
				machine:OnError(format("Something bad happened in line #%d of the action function of state \"%s\": %s", line, machine.Current, desc));
				return;
			end
		end
	end
end

--FSM Class
local FSMClassDef = {
	Name = "System.FSM",
	Functions = {
		Start = {
			Desc = [[Start the current FSM machine]],
			Func = function(self)
				self._Timer:Start();
				self._State = "running";
				self:OnRunningStateChanged(self._State);
			end,
		},
		Pause = {
			Desc = [[Pause the current FSM machine]],
			Func = function(self)
				self._Timer:Stop();
				self._State = "suspended";
				self:OnRunningStateChanged(self._State);
			end,
		},
		Reset = {
			Desc = [[reset the current state to default]],
			Func = function(self)
				self._Current = self._Default;
			end,
		},
		Stop = {
			Desc = [[Stop the current FSM machine and reset the current state to default]],
			Func = function(self)
				self._Current = self._Default;
				self._Timer:Stop();
				self._State = "idle";
				self:OnRunningStateChanged(self._State);
			end,
		},
		HasState = {
			Desc = [[Check whether the current FSM machine has the state or not]],
			Func = function(self, state)
				if (type(state) ~= "string") then
					return nil;
				end
				if(self._States[state]) then
					return true;
				else
					return false;
				end
			end,
		},
		GetMachine = {
			Desc = [[Get the existing FSM by name]],
			Static = true,
			Func = function(self, name)
				if (type(name) ~= "string") then
					return nil;
				end
				return Machines[name];
			end,
		},
	},
	Properties = {
		Name = {
			Desc = [[Get the name of the machine]],
			Type = String,
			Get = function(self)
				return self._Name;
			end,
		},
		Current = {
			Desc = [[Get the current state of the machine]],
			Type = String,
			Get = function(self)
				return self._Current;
			end,
			Set = function(self, state)
				self._Current = state;
			end,
		},
		Default = {
			Desc = [[Get/Set the default state when the machine is reset]],
			Type = String,
			Check = function(self,value)
				if (self._States[value]) then
					return true;
				else
					return false;
				end
			end,
			Get = function(self)
				return self._Default;
			end,
			Set = function(self,value)
				self._Default = value;
			end,
		},
		Interval = {
			Desc = [[Get/Set the machine execution interval in milliseconds]],
			Type = Number.UInt,
			Get = function(self)
				return self._Timer.Interval;
			end,
			Set = function(self,value)
				self._Timer.Interval = value;
			end,
		},
		RunningState = {
			Desc = [[Get the machine's running state]],
			Type = String,
			Get = function(self)
				return self._State;
			end,
		},
	},
	Events = {
		OnStateChanged = {
			Desc = [[Triggered when transition is executed among the states]],
		},
		OnRunningStateChanged = {
			Desc = [[Triggered when the running state of the FSM is changed]],
		},
		OnError = {
			Desc = [[Triggered when any execution error occurs]],
		},
	},
	Constructor = function(self, def)
		if (type(def) ~= "table") then
			return true, "The FSM definition is not a table.";
		end
		--Name
		local name = def.Name;
		if (type(name) ~= "string") then
			return true, "The FSM's name is not a string.";
		end
		if (Machines[name]) then
			return true, "The FSM already exists.";
		end
		self._Name = name;
		--States
		if (type(def.States)~="table") then
			return true, "The definition of the states of the FSM does not exist.";
		end
		self._States = {};
		local states = self._States;
		for i = 1, #def.States do
			local state = def.States[i];
			if (type(state) ~= "table") then
				return true, format("The definition of state #%d is not a table.", i);
			end
			--Name of the state
			local name = state.Name;
			if (type(name) ~= "string") then
				return true, format("The definition of state #%d's name is not a string.", i);
			end
			if (states[name]) then
				return true, format("The definition of state #%d's name is duplicated.", i);
			end
			states[name] = {};
			local newstate = states[name];
			--Action function of the state
			local action = state.Action;
			if (action ~= nil and type(action) ~= "function") then
				return true, format("The definition of state #%d's action is not a function.", i);
			end
			newstate.Action = action;
			--Transition function of the state
			local transition = state.Transition;
			if (transition ~= nil and type(transition) ~= "function") then
				return true, format("The definition of state #%d's transition is not a function.", i);
			end
			newstate.Transition = transition;
			--Sequence reversal
			newstate.Reversed = state.Reversed;
		end
		--Public State
		local public = def.States[0];
		if (type(public) == "table") then
			self._Public = public.Transition;
		end
		--Default State
		local default = def.Default;
		if (type(default)~="string") then
			return true, format("The default state is not defined.", i);
		end
		if (not states[default]) then
			return true, format("The default state \"%s\" does not exist.", default);
		end
		self._Default = default;
		self._Current = default;
		--Create a timer
		local interval = def.Interval;
		interval = interval or 200;
		if (not Number.UInt.Validate(interval)) then
			return true, format("The FSM execution interval is invalid.");
		end
		self._Timer = Timer(interval);
		self._Timer.Parent = self;
		self._Timer.Elapsed = Poll;
		self._State = "idle";
		self.Const = {};
		self.Config = {};
		--Insert into cache
		Machines[name] = self;
	end,
};
System.FSM = newclass(FSMClassDef);