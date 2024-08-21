local Players = game:GetService("Players")
local gunFramework = require(game:GetService("ReplicatedStorage").modules.gunFramework)
local tempData = require(game:GetService("ReplicatedStorage").modules.tempData)
local action = game.ReplicatedStorage.modules.gunFramework.action


Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		for _, tool : Tool in pairs(player.Backpack:GetChildren()) do
			if tool:IsA("Tool") and tool:FindFirstChild("ClientGun") then
				local new = gunFramework.new(tool , player)
				
				tempData[player.Character].tools[tool.Name] = new
			end
		end
	end)
end)


action.OnServerEvent:Connect(function(player, data, pos)
	local name, action = table.unpack(data)
	local data = tempData[player.Character]
	
	if data ~= nil and player.Character:FindFirstChildOfClass("Humanoid").Health ~= 0 then
		if data.tools[name][action] ~= nil then
			data.tools[name][action](pos)
		end
	end
end)