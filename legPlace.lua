
repeat wait() until game:IsLoaded() 

local runService = game:GetService("RunService")
local character = script.Parent or game.Players.LocalPlayer.CharacterAdded:Wait()
local offsets = {Right = CFrame.new(0.5, -1, 0), Left = CFrame.new(-0.5, -1, 0)}
local IK = require(script:WaitForChild("IKHandler")).New(character)

local legs = {"Left", "Right"}
local lastLeft = Vector3.zero
local lastRight = Vector3.zero

runService.RenderStepped:Connect(function()
	for _, v:BasePart in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Name:match("Leg") or v.Name:match("Arm") then
	
			if character["Left Leg"] == nil or character["Right Leg"] == nil then return end

			for i, direction in pairs(legs) do

				local params = RaycastParams.new()
				local motor:Motor6D = character.Torso[direction .. " Hip"]
				
				params.IgnoreWater = true
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = {character}
				
				local pos = (character.HumanoidRootPart.CFrame*offsets[direction]).Position 
				local ray = workspace:Raycast(pos, Vector3.yAxis*-3, params)
				
				if ray then
					if i == 2 then
						IK:LegIK(direction, lastRight)
						lastRight = lastRight:Lerp(ray.Position, .4)
					else
						IK:LegIK(direction, lastLeft)
						lastLeft = lastLeft:Lerp(ray.Position, .4)
					end
				end
			end
		end
	end
end)

