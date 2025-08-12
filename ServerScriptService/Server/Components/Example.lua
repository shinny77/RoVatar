-- @ScriptType: ModuleScript
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage.Packages

local Component = require(Packages.Component)

local Example = Component.new({Tag = "Example"})


function Example:Construct()
	
end

function Example:Start()
    
end

return Example