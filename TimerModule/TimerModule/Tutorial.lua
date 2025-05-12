--!strict

-- THIS IS A TUTORIAL ON HOW TO USE THE MODULE!
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

-- Start by requiring the module!
local TimerService = require(Modules:FindFirstChild("Timer"))

-- Get a duration for your timer!
local Duration = 10 -- It's in seconds

-- Create your Timer!
local Timer = TimerService.Create(Duration, "My Timer")
-- The second parameter (Timer Name) is optional! but you can add it for debugging

-- Start the timer!
Timer:Start() -- Your timer is ticking, without yielding the script!

-- You can know whenever your timer updates!
Timer.Updated:Connect(function(Time) -- Time is the current Timer's Time (number)
	print("The timer is at", Time, "seconds!")
end)

-- Or you can bind your function with Timer:BindToTimerUpdate()!
local Update = Timer:BindToTimerUpdate(function(Time)
	print("The timer is at", Time, "seconds!")
end)

-- To Unbind, just do Update:Disconnect()
Update:Disconnect()

-- Or you can know whenever your timer ends!
Timer.Ended:Connect(function()
	print("Timer ended!")
end)

--You can also get the timer's time with Timer.Time
print("The timer is at", Timer.Time)

-- or Timer:GetCurrentTime()
print("The timer is at", Timer:GetCurrentTime())

--// !! IMPORTANT: ALL VARIABLES OF TIMER ARE READ-ONLY !! \\
--// !! IMPORTANT: ALL VARIABLES OF TIMER ARE READ-ONLY !! \\
--// !! IMPORTANT: ALL VARIABLES OF TIMER ARE READ-ONLY !! \\

Timer:Pause() -- You can Pause the Timer
print(Timer:IsPaused()) -- And know if it's paused!

Timer:Resume() -- You can also Resume the Timer
print(Timer:IsTicking()) -- And also know if it's ticking (running)!

-- You can add/remove time from the timer
Timer:AddTime(3) -- Adding 3 seconds
print(Timer:GetCurrentTime()) -- will be atleast 3

Timer:AddTime(-3) -- Removing 3 seconds
print(Timer:GetCurrentTime()) -- will be the time it was before

-- You can also change the timer's speed
Timer:SetSpeed(2) -- Will be twice as fast
Timer:SetSpeed(1) -- Sets back to default speed

-- There are 2 ways to yield the script until the timer ends
Timer.Ended:Wait() -- Just wait until the Ended event fires
Timer:YieldUntilTimerEnds() -- It does it...

-- If you don't want your timer to continue anymore, you can Stop it!
Timer:Stop() -- This will fire the Ended event tho!

-- You can also restart it btw!
Timer:Start()

-- Enjoy the Timer Module!