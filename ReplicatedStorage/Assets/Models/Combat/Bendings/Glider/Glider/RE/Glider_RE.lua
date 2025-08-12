-- @ScriptType: Script

local Tool = script.Parent.Parent.Parent

script.Parent.OnServerEvent:Connect(function(plr)
	
	Tool.A.Transparency = 1
	Tool.S.Transparency = 1
	Tool.D.Transparency = 1
	Tool.Handle.Transparency = 1
	local char = plr.Character
	local hand = char:WaitForChild("HumanoidRootPart")
	local twoss = game.ReplicatedStorage.Assets.Models.Vehicles.Glider:Clone()
	twoss.Parent = hand
	twoss.PrimaryPart.CFrame = hand.CFrame * CFrame.new(0,0,0)
	twoss:SetPrimaryPartCFrame(twoss:GetPrimaryPartCFrame() * CFrame.Angles(0, math.rad(90), 0))

	local Weld = Instance.new("WeldConstraint")
	Weld.Parent = hand
	Weld.Part0 = hand
	
	Weld.Part1 = twoss.PrimaryPart


end)