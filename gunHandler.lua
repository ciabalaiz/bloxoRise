local Players = game:GetService("Players")
local tempData = require(script.Parent:WaitForChild("tempData"))

local otsCamera = require(script.OTSCamera)
local FCW = require(script.FastCastWrap)

local function loadDir(a, player)
	local t = {}
	for _, v in pairs(a) do
		if v:IsA("Animation") then
			local track = player.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(v)
			track.Name = v.Name
			t[v.Name] = track
		end
	end
	return t
end

local gunHandler = {}

gunHandler.__index = gunHandler

export type gun = {camera : {aX : number; aY : number; alpha : number; camOffset : Vector3}; reloading : boolean; currentAmmo : number}
export type data = {animations : {}}

function gunHandler.new(t : Tool, config : ModuleScript?, player : Player)
	if player == nil then return end
	if player.Character:FindFirstChild("Humanoid").Health == 0 then return end
	local playerData  : data = tempData[player:WaitForChild("Character")]
	local animations = playerData.animations[t.Name]	
	if playerData == nil or animations == nil then return end
	
	local new  : gun = setmetatable({}, gunHandler)
	
	new.camera = otsCamera.new()
	new.cooldown = false
	new.reloading = false
	new.tool = t
	
	new.settings = config or {
		damage = 50;
		headshot = 100;
		firing = 1.1;
		rpm = 700;
		magCapacity = 30;
		maxAmmo = 20;
		velocity = 50;
		fireRate = .1;
		range = 5000;
		animations= {};
	}	
	
	new.currentAmmo = new.settings.maxAmmo
	
	function new:Shoot()
		if new.cooldown then return end
		if new.currentAmmo == 0 then new:Reload() return end
		
		new.cooldown = true
		new.currentAmmo -= 1
		animations["Fire"]:Play()
		
		FCW:fire(new.tool.Handle.Position, player:GetMouse().Hit,	new.settings, true, new.tool.Parent)
		
		task.delay(new.settings.fireRate, function()
			new.cooldown = false
		end)
	end
	
	function new:SetSettings(s)
		new.settings = s
	end
	
	function new:Reload()
		if animations["Reload"] ~= nil and new.reloading == false then
			animations["Reload"]:Play()
			new.reloading = true
			
			animations["Reload"].Ended:Connect(function()
				new.currentAmmo = new.settings.maxAmmo
				new.reloading = false
			end)
		end
	end
	
	function new:ToolEquipped()
		new.camera:Start()
		new.reloading = false
		
		if animations["Equip"] ~= nil then
			animations["Equip"]:Play()
		end
	end
	
	function new:ToolUnequipped()
		new.camera:Stop()
		new.reloading = false
		
		if animations["Unequip"] ~= nil then
			for _, v in pairs(new._at) do
				v:Stop()
			end
			animations["Unequip"]:Play()
		end
	end	
	
	return new
end

return gunHandler
