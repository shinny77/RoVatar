-- @ScriptType: ModuleScript
local debrisFolder = workspace.Debris

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character

local Modules = RS.Modules

local debrisModule = require(Modules.Packages.Debris)

return function(projectile, hitPosition)	


	debrisModule.sphereExp(hitPosition, 60, 90, Color3.fromRGB(42, 145, 255))
	
	local ray = Ray.new(hitPosition, Vector3.new(0, -10, 0))
	local hit, vec2Pos, surfaceNormal = workspace:FindPartOnRayWithIgnoreList(ray, {Character, debrisFolder})
	if hit then
		debrisModule.Shockwave(hitPosition, 60, 90)
		debrisModule.Ground(hitPosition, 30, Vector3.new(2, 2.2, 2.2), nil, math.random(6, 14), false, 5.5)
	end
end
