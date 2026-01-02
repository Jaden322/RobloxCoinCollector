-- Coin system script
-- I made this to handle coin spawning, collection, and tracking player coins
-- Focused on making it smooth, fair (no double-collect), and visually satisfying

local coinSpawnsFolder = workspace:WaitForChild("CoinSpawners") 
-- Folder that holds all possible coin spawn locations

local gameInProgress = game.ReplicatedStorage:WaitForChild("GameInProgress") 
-- BoolValue used to control when coins should spawn

local coinTemplate = game.ReplicatedStorage:WaitForChild("CoinTemplate") 
-- Template coin that gets cloned when spawning

local playerFolder = game.ReplicatedStorage:WaitForChild("PlayerData") 
-- Stores server-side player data like coin counts

local coinUpdateEvent = game.ReplicatedStorage:WaitForChild("CoinUpdate") 
-- RemoteEvent to update the client UI when coins change


-- Handles what happens when a player collects a coin
local function onCoinCollected(coin, player)
	-- Prevents the same coin from being collected multiple times
	-- This also protects against lag or multiple touch events
	if not coin.Parent or coin:GetAttribute("Collected") then return end

	-- Mark coin as collected immediately (debounce)
	coin:SetAttribute("Collected", true)

	-- Play a coin sound for feedback
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://3125624765" 
	sound.Parent = coin
	sound:Play()

	-- Tween effects to make collecting coins feel more rewarding
	local tweenService = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Spin the coin 360 degrees
	local rotationGoal = {
		Orientation = coin.Orientation + Vector3.new(0, 360, 0)
	}

	-- Move the coin upward and fade it out
	local moveGoal = {
		Position = coin.Position + Vector3.new(0, 3, 0),
		Transparency = 1
	}

	local rotationTween = tweenService:Create(coin, tweenInfo, rotationGoal)
	local moveTween = tweenService:Create(coin, tweenInfo, moveGoal)

	rotationTween:Play()
	moveTween:Play()

	-- Once the animation finishes, update player data and remove the coin
	moveTween.Completed:Connect(function()
		coin:Destroy()

		-- Create player data if it doesn’t exist yet
		local playerData = playerFolder:FindFirstChild(player.UserId)
		if not playerData then
			playerData = Instance.new("Folder")
			playerData.Name = player.UserId
			playerData.Parent = playerFolder

			local coinCount = Instance.new("IntValue")
			coinCount.Name = "CoinCount"
			coinCount.Value = 0
			coinCount.Parent = playerData
		end

		-- Increment the player’s coin count
		local coinCount = playerData:FindFirstChild("CoinCount")
		if coinCount then
			coinCount.Value += 1

			-- Send updated coin count to the client
			coinUpdateEvent:FireClient(player, coinCount.Value)
		end
	end)
end


-- Spawns a coin at a random spawner
local function spawnCoin()
	local spawners = coinSpawnsFolder:GetChildren()

	-- Safety check in case no spawners exist
	if #spawners == 0 then
		warn("No CoinSpawners found!")
		return
	end

	-- Choose a random spawn location
	local randomSpawner = spawners[math.random(1, #spawners)]

	local newCoin = coinTemplate:Clone()
	newCoin.Position = randomSpawner.Position + Vector3.new(0, 3.5, 0)
	newCoin.Parent = workspace

	-- Reset collected state in case the template was reused
	newCoin:SetAttribute("Collected", false)

	-- Detect when a player touches the coin
	newCoin.Touched:Connect(function(hit)
		local player = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
		if player then
			onCoinCollected(newCoin, player)
		end
	end)
end


-- Main loop that controls coin spawning during gameplay
while true do
	if gameInProgress.Value then
		spawnCoin()
		wait(3) -- Controls how frequently coins spawn
	else
		wait(1)
	end
end
