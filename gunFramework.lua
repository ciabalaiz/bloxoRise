local tempData = require(script.Parent:WaitForChild("tempData"))
local FastCastWrap = require(script:WaitForChild("FastCastWrap"))
local OTSCamera = require(script:WaitForChild("OTSCamera"))
local gunFramework = {}

gunFramework.__index = gunFramework

--bloxo save


export type gun = {onCooldown : boolean, camera : {}, currentAmmo : number; reloading : boolean; object : Tool, Shoot : "function"; settings : {}; currentMag : number}

function gunFramework.new(tool : Tool, player : Player)
	local gun : gun = setmetatable({}, gunFramework)
	local animations = tempData[player.Character].animations[tool.Name]
	
	gun.camera = OTSCamera.new()
	gun.cooldown = false
	gun.reloading = false
	gun.object = tool
	gun.settings = require(tool:FindFirstChild("ClientGun").config) or {
		damage = 50;
		headshot = 100;
		firing = 1.1;
		rpm = 700;
		magCapacity = 30;
		maxAmmo = 20;
		velocity = 500;
		fireRate = .1;
		range = 50000;
		animations= {};
	}	
	gun.currentAmmo = gun.settings.maxAmmo
	gun.currentMag = gun.settings.magCapacity
	gun.Shoot= function(position : CFrame)
		if gun.cooldown then return end
		if gun.reloading then return end
		if gun.currentAmmo == 0 then gun.Reload() return end
		if gun.currentMag == 0 then return end

		gun.cooldown = true
		gun.currentAmmo -= 1
		animations["Fire"]:Play()

		FastCastWrap:fire(gun.object.Handle.Position, position,	gun.settings, true, gun.object.Parent)

		task.delay(gun.settings.fireRate, function()
			gun.cooldown = false
		end)
	end
	
	gun.Reload = function()
		if gun.reloading then return end
		if gun.currentAmmo == gun.settings.maxAmmo then return end
		if gun.onCooldown then return end
		if gun.currentMag == 0 then return end
		
		gun.reloading = true
		animations["Reload"]:Play()
		
		animations["Reload"].Ended:Connect(function()
			gun.reloading = false
			gun.currentAmmo = gun.settings.maxAmmo
			gun.currentMag -= 1
		end)
	end
	
	return gun 
end

return gunFramework
