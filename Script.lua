local gunHandler = require(game:GetService("ReplicatedStorage").gunHandler)
local tempData = require(game:GetService("ReplicatedStorage").tempData)
local gunPacket = game.ReplicatedStorage.gunHandler.action
local handler = require(game.ReplicatedStorage.gunHandler)

export type actionData = {toolName : string; actionName : string}


game.Players.PlayerAdded:Connect(function(player : Player)
	player.CharacterAdded:Connect(function()
		for _, tool in pairs(player.Backpack:GetChildren())  do
			print(tool:FindFirstChild("ClientGun"))
			if tool:IsA("Tool") and tool:FindFirstChild("ClientGun")~= nil then
				local new = gunHandler.new(tool, require(tool:FindFirstChild("ClientGun").config), player)
				print(new, 13)
				table.insert(tempData[player.Character].tools, new)
			end
		end
	end)

	player.Backpack.ChildAdded:Connect(function(tool)
		print(2)
		if tool:IsA("Tool") and tool:WaitForChild("ClientGun") ~= nil then
			local player = tool.Parent.Parent
			local new = gunHandler.new(tool, require(tool:FindFirstChild("ClientGun").config), player)
			print(new)
			table.insert(tempData[player.Character].tools, new)
		end
	end)
end)

gunPacket.OnServerEvent:Connect(function(player : Player,data : actionData)
	
end)