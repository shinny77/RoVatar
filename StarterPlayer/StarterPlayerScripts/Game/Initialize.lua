-- @ScriptType: LocalScript
_G.IsHub = workspace:WaitForChild("IsHub").Value

local Knit = require(game:GetService("ReplicatedStorage").Packages:WaitForChild("Knit"))
Knit.AddControllersDeep(script.Parent:WaitForChild("Controllers", 5))
Knit.Start():andThen(function()

end):catch(warn)
for _,component in pairs(script.Parent.Components:GetDescendants()) do
	if (not component:IsA("ModuleScript")) then continue end;
	require(component)
end