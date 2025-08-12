-- @ScriptType: ModuleScript
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TAG_NAME = "Ragdoll"

local buildRagdoll = require(ReplicatedStorage:WaitForChild("buildRagdoll"))

local connections = {}

function setRagdollEnabled(character, isEnabled)
	local ragdollConstraints = character:WaitForChild("RagdollConstraints")
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.PlatformStand = isEnabled -- remove this line if you want ragdolls to be able to move
		humanoid:ChangeState(isEnabled and Enum.HumanoidStateType.Physics or Enum.HumanoidStateType.GettingUp)
	end
	-- the animations have to be disabled during ragdoll state otherwise they jitter
	if character:FindFirstChild("Animate") then
		character.Animate.Disabled = isEnabled
	end
	
	if isEnabled then
		for _,v in pairs(humanoid:GetPlayingAnimationTracks()) do
			v:Stop(0)
		end
		-- if you were walking when ragdoll was called, the sounds will keep playing, so stop them
		-- the delay was added because sometimes it wouldn't stop the sounds 
		task.delay(.1, function()
		local head = character:FindFirstChild("Head")
		if head then
			for _, v in pairs(head:GetChildren()) do
				if v:IsA("Sound") then
					v:Stop()
				end
			end
		end end)
	end
	
	for _,constraint in pairs(ragdollConstraints:GetChildren()) do
		if constraint:IsA("Constraint") then
			local rigidJoint = constraint.RigidJoint.Value
			local expectedValue = (not isEnabled) and constraint.Attachment1.Parent or nil
			if rigidJoint and (rigidJoint.Part1 ~= expectedValue) then
				rigidJoint.Part1 = expectedValue 
			end
		end
	end
end


function ragdollAdded(character)
	-- only build a ragdoll on the server; it'll be replicated to the client and use that one
	-- also, only build a ragdoll when it's first needed
	if not character:FindFirstChild("RagdollConstraints") and RunService:IsServer() then
		buildRagdoll(character)
	end
	setRagdollEnabled(character, true)
end

function ragdollRemoved(character)
	setRagdollEnabled(character, false)
end

CollectionService:GetInstanceAddedSignal(TAG_NAME):Connect(ragdollAdded)
CollectionService:GetInstanceRemovedSignal(TAG_NAME):Connect(ragdollRemoved)
for _, character in pairs(CollectionService:GetTagged(TAG_NAME)) do
	ragdollAdded(character)
end

return nil