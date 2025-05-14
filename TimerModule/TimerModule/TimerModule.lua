--!strict
local Timer = {}
local Index = {}
local Meta = {}
Index.__index = Meta
Index.__newindex = function(t, k, v)
	if k == "__SET_TIMER" then
		rawset(t, "Time", v)
	else
		warn("ALL TIMER VARIABLES ARE READ ONLY")
	end
end

local NamelessTimers = 0
local UpdateEvents = {} :: {[string]: BindableEvent}
local EndEvents = {} :: {[string]: BindableEvent}

type TimerStatus = {
	[string]: {
		Running: boolean,
		Paused: boolean,
		Offset: number,
		Speed: number
	}
}

local TimerStatus = {} :: TimerStatus
local Timers = {} :: {[string]: thread}

function Timer.Create(Duration: number, Name: string?)
	local self = {}
	
	if Name == nil then
		Name = "Nameless Timer " .. NamelessTimers
		NamelessTimers += 1
	end
	
	self.StartTime = Duration
	self.Time = Duration
	self.Name = Name :: string 

	EndEvents[self.Name] = Instance.new("BindableEvent")
	UpdateEvents[self.Name] = Instance.new("BindableEvent")

	self.Ended = EndEvents[self.Name].Event
	self.Updated = UpdateEvents[self.Name].Event

	TimerStatus[self.Name] = {
		Running = false,
		Paused = false,
		Offset = 0,
		Speed = 1
	}
	
	return setmetatable(self, Index)
end

function Meta:BindToTimerUpdate(callback: (Time: number?) -> ())
	local Connection = UpdateEvents[self.Name].Event:Connect(callback)
	return Connection
end

function Meta:YieldUntilTimerEnds()
	EndEvents[self.Name].Event:Wait()
end

function Meta:Start()
	if Timers[self.Name] then return warn("timer already running") end
	TimerStatus[self.Name].Running = true

	Timers[self.Name] = coroutine.create(function()
		for i = self.StartTime, 0, -1 do
			if not TimerStatus[self.Name].Running then break end
			
			local timeToSet = i + TimerStatus[self.Name].Offset
			if timeToSet <= 0 then
				break
			end
			
			while TimerStatus[self.Name].Paused and TimerStatus[self.Name].Running do
				task.wait()
			end
			if not TimerStatus[self.Name].Running then break end
			
			self.__SET_TIMER = timeToSet
			UpdateEvents[self.Name]:Fire(timeToSet)
			
			task.wait(1 / TimerStatus[self.Name].Speed)
		end
		
		if not TimerStatus[self.Name].Running then return end
		self:Stop()
	end)
	
	coroutine.resume(Timers[self.Name])
end

function Meta:Pause()
	if not Timers[self.Name] then return warn("no timer running") end
	if TimerStatus[self.Name].Paused then return warn("already paused") end

	TimerStatus[self.Name].Paused = true
end

function Meta:Resume()
	if not Timers[self.Name] then return warn("no timer running") end
	if not TimerStatus[self.Name].Paused then return warn("not paused") end

	TimerStatus[self.Name].Paused = false
end

function Meta:SetSpeed(Speed: number)
	TimerStatus[self.Name].Speed = Speed
end

function Meta:GetSpeed()
	return TimerStatus[self.Name].Speed
end

function Meta:IsTicking()
	return (TimerStatus[self.Name].Running and not TimerStatus[self.Name].Paused)
end

function Meta:IsPaused()
	return TimerStatus[self.Name].Paused
end

function Meta:AddTime(Seconds: number)
	TimerStatus[self.Name].Offset += Seconds
end

function Meta:GetCurrentTime()
	return self.Time
end

function Meta:Convert(Format: "Minutes" | "Seconds" | "MinutesAndSeconds"): (number)
	local CurrentTime = self:GetCurrentTime() :: number
	local Minutes = math.floor(CurrentTime / 60)
	local Seconds = CurrentTime % 60
	
	if Format == "Minutes" then
		return Minutes
	elseif Format == "Seconds" then
		return Seconds
	else
		return Minutes, Seconds
	end
end

function Meta:Unconvert(Minutes: number, Seconds: number)
	return Minutes * 60 + Seconds
end

function Meta:Stop()
	if not Timers[self.Name] then return warn(`no timer for "{self.Name}"`) end
	print(`Stopping "{self.Name}"`)
	
	TimerStatus[self.Name].Running = false
	EndEvents[self.Name]:Fire()

	Timers[self.Name] = nil
end

return Timer