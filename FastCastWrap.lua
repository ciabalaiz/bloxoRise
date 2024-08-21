local fastcastHandler = {}

local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local fastcast = require(script.Parent.FastCastRedux)
local random = Random.new()

local mainCaster = fastcast.new()
local bullets = {}
local RNG = Random.new()

local Behavior = fastcast.newBehavior()

Behavior.RaycastParams = RaycastParams.new()

function OnRayUpdated(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
	local bulletLength = cosmeticBulletObject.Size.Z / 2
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

function OnRayTerminated(cast)

	local cosmeticBullet = cast.RayInfo.CosmeticBulletObject
	if cosmeticBullet ~= nil then
		cosmeticBullet:Destroy()
	end
end

function fastcastHandler:fire(origin, direction, properties, isReplicated, repCharacter)
	local rawOrigin	= origin
	local rawDirection = direction

	if type(properties) ~= "table" then 
		properties = require(properties)
	end

	local directionalCFrame = CFrame.new(Vector3.new(), direction.LookVector)			
	direction = (directionalCFrame * CFrame.fromOrientation(0, 0, random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector			

	local bullet = Instance.new("Part")
	bullet.Material = Enum.Material.Neon
	bullet.Color = Color3.fromRGB(255, 255, 0)
	bullet.CanCollide = false
	bullet.Anchored = true
	bullet.Size = Vector3.new(0.2, 0.2, 2.4)

	Behavior.CosmeticBulletTemplate = bullet
	Behavior.CosmeticBulletContainer = workspace
	Behavior.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	Behavior.RaycastParams.FilterDescendantsInstances = {repCharacter}
	Behavior.Acceleration = Vector3.new(0,-20,0)
	
	local directionalCF = CFrame.new(Vector3.new(), (direction-origin).Unit)
	local newDirection = (directionalCF * CFrame.fromOrientation(0, 0, RNG:NextNumber(0, (math.pi*2))) * CFrame.fromOrientation(math.rad(RNG:NextNumber(1, 2)), 0, 0)).LookVector

	mainCaster:Fire(origin, newDirection, (direction*properties.velocity), Behavior)					
end 

mainCaster.CastTerminating:Connect(OnRayTerminated)
mainCaster.LengthChanged:Connect(OnRayUpdated)

return fastcastHandler