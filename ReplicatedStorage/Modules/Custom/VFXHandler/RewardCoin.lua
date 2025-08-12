-- @ScriptType: ModuleScript
local RSS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local VFXs = RS.Assets.VFXs
local RewardCoin = VFXs.RewardCoin

if(RSS:IsClient()) then
	return function()
		local fr = RewardCoin:Clone()
		fr.Parent = workspace
		fr.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
		game.Debris:AddItem(fr, 2)
		for _, eff in pairs(fr:GetDescendants()) do
			if eff:IsA("ParticleEmitter") then
				eff:Emit(1)
			end
		end
	end
else
	return function(plr:Player)
		local fr = RewardCoin:Clone()
		fr.Parent = workspace
		fr.CFrame = plr.Character.HumanoidRootPart.CFrame
		game.Debris:AddItem(fr, 2)
		for _, eff in pairs(fr:GetDescendants()) do
			if eff:IsA("ParticleEmitter") then
				eff:Emit(1)
			end
		end
	end
end