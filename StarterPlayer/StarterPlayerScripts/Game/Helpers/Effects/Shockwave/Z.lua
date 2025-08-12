-- @ScriptType: ModuleScript
local debrisFolder = workspace.Debris

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character

local Modules = RS.Modules

local debrisModule = require(Modules.Debris)

return function(projectile, hitPosition)	
	--coroutine.wrap(function()
		--for i, v in pairs(projectile.HitFX:GetChildren()) do
		--	v:Emit(v:GetAttribute("EmitCount"))
		--end
	--end)()

	debrisModule.sphereExp(hitPosition, 25, 40, Color3.fromRGB(255, 255, 255))
	
	local ray = Ray.new(hitPosition, Vector3.new(0, -10, 0))
	local hit, vec2Pos, surfaceNormal = workspace:FindPartOnRayWithIgnoreList(ray, {Character, debrisFolder})
	if hit then
		debrisModule.Shockwave(hitPosition, 30, 55)
		debrisModule.Ground(hitPosition, 15, Vector3.new(2, 1.8, 1.8), nil, math.random(6, 14), false, 5.5)
	end
end
