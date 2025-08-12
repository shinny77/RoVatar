-- @ScriptType: Script
local function getServerType()
	if game.PrivateServerId ~= "" then
		if game.PrivateServerOwnerId ~= 0 then
			return "VIPServer"
		else
			return "ReservedServer"
		end
	else
		return "StandardServer"
	end
end

_G.IsHub = getServerType() ~= "ReservedServer"
workspace:WaitForChild("IsHub").Value = _G.IsHub 

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

Knit.AddServicesDeep(script.Parent.Parent.Services)

Knit.Start():andThen(function()
end):catch(warn)

for _,component in pairs(script.Parent.Parent.Components:GetDescendants()) do
	if (not component:IsA("ModuleScript")) then continue end;
	require(component)
end
