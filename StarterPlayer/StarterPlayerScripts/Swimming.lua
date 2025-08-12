-- @ScriptType: LocalScript
local RS = game:GetService("ReplicatedStorage")
local SwimController = require(RS.Modules.Packages.SwimController)

local water = workspace:WaitForChild("Scripted_Items").MapsBuildings.Water

local waterArea = water:WaitForChild("Area")

water.ChildAdded:Connect(function(child)
	if child:IsA("Part") then
		SwimController:AddZone(water)
	end
end)

for _, trigger in pairs(waterArea:GetDescendants()) do
	if trigger:IsA("Part") or trigger:IsA("MeshPart") then
		SwimController:AddZone(trigger)
	end
end

SwimController:Start()
