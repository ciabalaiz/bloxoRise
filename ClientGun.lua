local UserInputService = game:GetService("UserInputService")
local gunPacket = game.ReplicatedStorage.modules.gunFramework.action
local mouse = game.Players.LocalPlayer:GetMouse()
local tool = script.Parent

--Values--

tool.Equipped:Connect(function()
	gunPacket:FireServer({tool.Name;"equip"})
end)

tool.Unequipped:Connect(function()
	gunPacket:FireServer({tool.Name;"unequip"})
end)

tool.Activated:Connect(function()
	gunPacket:FireServer({tool.Name;"Shoot"}, mouse.Hit)
end)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.R then
		gunPacket:FireServer({tool.Name;"Reload"})
	end
end)