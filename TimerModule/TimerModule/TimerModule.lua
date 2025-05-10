--!strict
local Timer = {}
local Index = {}
local Meta = {}
Index.__index = Meta

local NamelessTimers = 0
local UpdateEvents = {}
local EndEvents = {}

local TimerStatus = {}
local Timers = {}

function Timer.Create(Duration: number, Name: string?)
	local self = setmetatable({}, Index)
	self.StartTime = Duration
	self.Time = Duration
	self.Name = Name or function()
		local TimerName = "Nameless Timer" .. NamelessTimers
		NamelessTimers += 1

		return TimerName
	end

	EndEvents[self.Name] = Instance.new("BindableEvent")
	UpdateEvents[self.Name] = Instance.new("BindableEvent")

	self.Ended = EndEvents[self.Name].Event
	self.Updated = UpdateEvents[self.Name].Event

	TimerStatus[self.Name] = {
		Running = false,
		Paused = false
	}

	return self
end

function Meta:BindToTimerUpdate(callback: (Time: number?) -> ())
	local Connection = UpdateEvents[self.Name].Event:Connect(callback)
	return Connection
end

function Meta:Start()
	if Timers[self.Name] then return warn("timer already running") end
	Timer[self.Name].Running = true

	Timers[self.Name] = coroutine.create(function()
		for i = self.StartTime, 0, -1 do
			if not Timer[self.Name].Running then break end

			while Timer[self.Name].Paused and Timer[self.Name].Running do
				task.wait()
			end

			if not Timer[self.Name].Running then break end

			self.Time = i
			UpdateEvents[self.Name]:Fire(i)
			task.wait(1)
		end

		self:Stop()
	end)

	coroutine.resume(Timers[self.Name])
end

function Meta:Pause()
	if not Timers[self.Name] then return warn("no timer running") end
	if Timer[self.Name].Paused then return warn("already paused") end

	Timer[self.Name].Paused = true
end

function Meta:Resume()
	if not Timers[self.Name] then return warn("no timer running") end
	if not Timer[self.Name].Paused then return warn("not paused") end

	Timer[self.Name].Paused = false
end


function Meta:IsTicking()
	return (Timer[self.Name].Running and not Timer[self.Name].Paused)
end

function Meta:IsPaused()
	return Timer[self.Name].Paused
end

function Meta:GetCurrentTime()
	return self.Time
end

function Meta:Stop()
	if not Timers[self.Name] then return warn(`no timer for "{self.Name}"`) end

	print(`Stopping "{self.Name}"`)

	Timer[self.Name].Running = false
	EndEvents[self.Name]:Fire()

	Timers[self.Name] = nil
end

return Timer