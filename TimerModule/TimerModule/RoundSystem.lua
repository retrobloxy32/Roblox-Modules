-- Let's get the services we need!
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")

-- Require the Module
local TimerModule = require(Modules:FindFirstChild("Timer"))

-- Let's create the timers we need!
local IntermissionTime = 15 -- How long the Intermission is going to last
local GameTime = 30 -- How long the Game is going to last

local IntermissionTimer = TimerModule.Create(IntermissionTime, "Intermission Timer") -- Our Intermission Timer
local GameTimer = TimerModule.Create(GameTime, "Game Timer") -- Our Game Timer

-- Let's get our sword the players are gonna fight with!
local Tools = ReplicatedStorage:WaitForChild("Tools") -- The Tools Folder
local Sword = Tools:FindFirstChild("Sword") -- The sword everyone is going to fight with!

-- Let's get our teleport part! It's the part to teleport the players to when the game starts!
local TeleportPart = workspace:WaitForChild("TeleportPart") -- The Teleport Part

-- Intermission
function Intermission()
	-- Loading back all players back to spawn
	for _, Player in Players:GetPlayers() do
		Player:LoadCharacter() -- Loads back player's character
	end
	
	local Update = IntermissionTimer:BindToTimerUpdate(function(Time) -- Binding to Timer
		print(`{Time} seconds left!`)
	end)
	
	--[[The code above is replacable with:
		local Update = IntermissionTimer.Updated:Connect(function(Time)
			print(`{Time} seconds left!`)
		end)
	]]
	IntermissionTimer:Start() -- Starting the timer!
	IntermissionTimer:YieldUntilTimerEnds() -- Yields the function until the timer ends
	
	--[[Timer:YieldUntilTimerEnds()
		is replacable with Timer.Ended:Wait() 
	]]
	
	Update:Disconnect() -- Let's unbind our function since we're using one timer and starting it many times!
end

function StartGame()
	local PlayersInGame = {}
	
	-- Let's teleport everyone to the Teleport Part!
	for _, Player in Players do
		if Player.Character then -- Only teleport if the player has a character
			if Player.Character.Humanoid.Health <= 0 then continue end -- if the player is dead, do not teleport!
			
			Player.Character:PivotTo(TeleportPart.CFrame) -- Teleport the player
			table.insert(PlayersInGame, Player) -- Let the game know that he's in the round!
			
			Player.Character.Died:Connect(function()
				table.remove(PlayersInGame, table.find(PlayersInGame, Player)) -- If he dies, he gets teleported back to the lobby, so he isn't in the game anymore!
			end)
		end
	end
	
	-- Let's give everyone 5 seconds before they fight!
	local BreakTimer = TimerModule.Create(5) -- The name is optional, you don't use it when it's a short, or not-so-special timer to use!
	BreakTimer.Updated:Connect(function(Time)
		print(`Players can fight in {Time} seconds!`)
	end)
	
	--[[Code above can be replaced with
		BreakTimer:BindToTimerUpdate(function(Time)
			print(`Players can fight in {Time} seconds!`)
		end)
	]]
	BreakTimer.Ended:Wait() -- BreakTimer:YieldUntilTimerEnds()
	
	-- Timer ended, so we'll give the sword to everyone in the game!
	for _, Player in PlayersInGame do
		local Character = Player.Character -- Get the Player's Character
		local NewSword = Sword:Clone() -- Get a new sword
		
		NewSword.Parent = Character -- Give the sword to the player!
	end
	
	GameTimer:Start() -- Start the GameTimer
	GameTimer:BindToTimerUpdate(function(Time)
		print(`Time left: {Time}`)
		
		if #PlayersInGame <= 1 then
			-- Game Over
			GameTimer:Stop() -- Stops the timer, fires the Ended event too!
		end
	end)
	
	GameTimer:YieldUntilTimerEnds()
	print("Game over!")
	
	task.wait(2) -- Waits 2 seconds until next intermission
end

-- Finally, loop forever an intermission, and a game!
while true do
	Intermission()
	StartGame()
end

-- And that's it, that's how you can make a round system with my module, Enjoy!!