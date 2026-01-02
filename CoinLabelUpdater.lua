-- LocalScript Inside the TextLabel object.
local player = game.Players.LocalPlayer
local playerDataFolder = game.ReplicatedStorage:WaitForChild("PlayerData")
local coinCountLabel = script.Parent -- Label where the coins will be displayed.
local coinUpdateEvent = game.ReplicatedStorage:WaitForChild("CoinUpdate") 


local function updateCoinCount(coinCountValue)
	
	coinCountLabel.Text = "Coins: " .. coinCountValue
end


coinUpdateEvent.OnClientEvent:Connect(updateCoinCount)

-- Initial update (when the player first joins)
local playerData = playerDataFolder:FindFirstChild(player.UserId)
if playerData then
	local coinCount = playerData:FindFirstChild("CoinCount")
	if coinCount then
		updateCoinCount(coinCount.Value)
	end
end
