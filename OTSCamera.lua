local ots = {}

local ls = require(script.Parent.loopSchedule).new()
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local function camMain(self)
	local plr = game:GetService("Players").LocalPlayer
	local cam = game:GetService("Workspace").CurrentCamera
	
	local c = plr.Character or plr.CharacterAdded:Wait()
	local rootPart = c:FindFirstChild("HumanoidRootPart")

	cam.CameraType = Enum.CameraType.Scriptable	
	game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.LockCenter
	
	if c and rootPart then
		local startCFrame = CFrame.new((rootPart.CFrame.p + Vector3.new(0,2,0)))*CFrame.Angles(0, math.rad(self.aX), 0)*CFrame.Angles(math.rad(self.aY), 0, 0)

		local cameraCFrame = startCFrame + startCFrame:VectorToWorldSpace(Vector3.new(self.camOffset.X,self.camOffset.Y,self.camOffset.Z))
		local cameraFocus = startCFrame + startCFrame:VectorToWorldSpace(Vector3.new(self.camOffset.X,self.camOffset.Y,-50000))
		
		if game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton2) == false then
			task.delay(.11, function()
				self.alpha = 1
			end)
			self.camOffset = Vector3.new(2,0,8.5)
		else
			self.camOffset = Vector3.new(3,0,7)
			self.alpha = .4
		end
		
		
		cam.CFrame = cam.CFrame:Lerp(CFrame.new(cameraCFrame.p,cameraFocus.p), self.alpha)
		rootPart.CFrame = CFrame.new(rootPart.CFrame.p, rootPart.CFrame.p + Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z))
	end
end

function ots.new()
	local new = setmetatable({}, ots)
	
	new.aX = 0
	new.alpha = 1
	new.aY = 0
	new.camOffset = Vector3.new(3,0,7)

	function new:Start(plr)
		if RS:IsClient() == false then return end

		ls[1] = RS.Heartbeat:Connect(function(dt)
			camMain(self)
		end)
		ls[4] = game:GetService("ContextActionService"):BindAction("CameraMovement", function(_,_,input)
			self.aX = self.aX - input.Delta.x*0.4
			self.aY = math.clamp(self.aY - input.Delta.y*0.4,-80,80)
		end, false, Enum.UserInputType.MouseMovement)
	end

	function new:Stop()
		if RS:IsClient() == false then return end

		ls:DoCleaning()
		UIS.MouseBehavior = Enum.MouseBehavior.Default	
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
	
	return new
end


return ots
