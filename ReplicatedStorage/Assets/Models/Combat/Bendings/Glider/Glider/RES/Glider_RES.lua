-- @ScriptType: Script

local Tool = script.Parent.Parent.Parent

script.Parent.OnServerEvent:Connect(function(plr)
	Tool.A.Transparency = 0
	Tool.S.Transparency = 0
	Tool.D.Transparency = 0
	Tool.Handle.Transparency = 0
	local char = plr.Character
	local hand = char:WaitForChild("HumanoidRootPart")
	hand:FindFirstChild("Glider"):Destroy()


end)