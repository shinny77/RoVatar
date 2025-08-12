-- @ScriptType: ModuleScript
local Tween = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")

local Modules = RS.Modules

local VFXs = RS.Assets.VFXs
local Meditation = VFXs.Meditation

return function(player, enable)
	local Char = player.Character
	local HRP = Char.HumanoidRootPart
	if enable then
		local fr = Meditation:Clone()
		fr.Parent = HRP
		fr.CFrame = HRP.CFrame
		
		local weld = Instance.new("WeldConstraint", fr)
		weld.Part0 = HRP
		weld.Part1 = fr	
	else
		local eff = HRP:FindFirstChild("Meditation")
		if eff then
			eff:Destroy()
		end
	end
end