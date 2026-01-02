-- Coin Collector Script
-- This script gives players 10 coins when they touch a coin object

-- Step 1: Reference the coin in the game
local coin = script.Parent  -- the coin object/part this script is attached to

-- Step 2: Function to give coins
local function onTouch(player)
    -- Make sure a player touched it
    if player and player:FindFirstChild("leaderstats") then
        local coins = player.leaderstats:FindFirstChild("Coins")
        if coins then
            coins.Value = coins.Value + 10  -- add 10 coins, when collected
        end
    end
    coin:Destroy()  -- remove the coin so it can't be collected again
end

-- Step3 Connect the function to the touch event
coin.Touched:Connect(function(hit)
    local player = game.Players:GetPlayerFromCharacter(hit.Parent)
    onTouch(player)
end)
