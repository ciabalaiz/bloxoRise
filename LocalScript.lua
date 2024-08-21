


local Player = game.Players.LocalPlayer
local PlayerMouse = Player:GetMouse()

local Camera = workspace.CurrentCamera

local Character = Player.Character or Player.CharacterAdded:Wait()

local Head = Character:WaitForChild("Head")
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Torso = Character:WaitForChild("Torso")
local Neck = Torso:WaitForChild("Neck")

local Waist = HumanoidRootPart:WaitForChild("RootJoint")

local RHip = Torso:WaitForChild("Right Hip")
local LHip = Torso:WaitForChild("Left Hip")

local LHipOriginC0 = LHip.C0
local RHipOriginC0 = RHip.C0

local NeckOriginC0 = Neck.C0
local WaistOriginC0 = Waist.C0

Neck.MaxVelocity = 1/3

RunService.RenderStepped:Connect(function() 
	local CameraCFrame = Camera.CoordinateFrame

	if Character:FindFirstChild("Torso") and Character:FindFirstChild("Head") then
		local TorsoLookVector = Torso.CFrame.lookVector
		local HeadPosition = Head.CFrame.p

		if Neck and Waist then
			if Camera.CameraSubject:IsDescendantOf(Character) or Camera.CameraSubject:IsDescendantOf(Player) then
				local Point = Camera.CFrame.p + Camera.CFrame.LookVector * 50
				local Distance = (Head.CFrame.p - Point).magnitude
				local Difference = Head.CFrame.Y - Point.Y

				local goalNeckCFrame = CFrame.Angles(-(math.atan(Difference / Distance) * 0.5), (((HeadPosition - Point).Unit):Cross(TorsoLookVector)).Y * 1, 0)
				Neck.C0 = Neck.C0:lerp(goalNeckCFrame*NeckOriginC0, 0.5 / 2).Rotation + NeckOriginC0.Position

				local xAxisWaistRotation = -(math.atan(Difference / Distance) * 0.2)
				local yAxisWaistRotation = (((HeadPosition - Point).Unit):Cross(TorsoLookVector)).Y * 0.5
				local rotationWaistCFrame = CFrame.Angles(xAxisWaistRotation, yAxisWaistRotation, 0)
				local goalWaistCFrame = rotationWaistCFrame*WaistOriginC0
				Waist.C0 = Waist.C0:lerp(goalWaistCFrame, 0.5 / 2).Rotation + WaistOriginC0.Position


				local currentLegCounterCFrame = Waist.C0*WaistOriginC0:Inverse()

				local legsCounterCFrame = currentLegCounterCFrame:Inverse()

				RHip.C0 =  legsCounterCFrame*RHipOriginC0
				LHip.C0 = legsCounterCFrame*LHipOriginC0
			end
		end
	end	
end)