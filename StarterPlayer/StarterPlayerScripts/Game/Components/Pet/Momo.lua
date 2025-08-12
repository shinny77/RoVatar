-- @ScriptType: ModuleScript
local Momo = {}

local RunS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local PFS = game:GetService("PathfindingService")
local CT = require(RS.Modules.Custom.CustomTypes)
local Constants = require(RS.Modules.Custom.Constants)
local CF = require(RS.Modules.Custom.CommonFunctions)

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = game.Players.LocalPlayer
local Momo = Component.new({Tag = player.UserId.."Momo", Ancestors = {workspace}})

function Momo:UpdateState()
	self.State.Changed:Connect(function(value)
		self.State.ReplicateState:FireServer(value)
	end)
end

function Momo:Setup()
	-- animations
	local Animations = script.Animations
	local walk = Animations.Walk
	local jump = Animations.Jump
	local idle = Animations.Idle

	---- Load Animations
	self.AnimationTrack = {}

	self.AnimationTrack.Walk = self.Hum:LoadAnimation(walk)
	self.AnimationTrack.Jump = self.Hum:LoadAnimation(jump)
	self.AnimationTrack.Idle = self.Hum:LoadAnimation(idle)
end

function Momo:Despawn()
	if self.Body.Transparency == 0 then
		self.Body.Transparency = 1
		self.Smoke:Emit(10)
		self.State.Value = "Hide"
	end
end

function Momo:Spawn()
	if self.Body.Transparency == 1 then
		self.Body.Transparency = 0
		--self.Instance:SetPrimaryPartCFrame(CFrame.new(player.Character.PrimaryPart.Position) * CFrame.new(0, 0, -20))
		self.Smoke:Emit(10)
		self.State.Value = "Show"
	end
end

function Momo:Follow()
	local circleRadius = 10 
	local baseHeight = 2.5
	local offset = 0.3

	local targetCircleRadius = 15 -- Starting target radius
	local minRadius = 10 -- Minimum allowed radius
	local maxRadius = 20 -- Maximum allowed radius
	local radiusChangeSpeed = 0.05 -- How quickly to interpolate towards the target radius
	local radiusChangeInterval = 3 -- Time (in seconds) before a new target radius is picked
	local timeSinceLastChange = 0

	local lastActionTime = 0

	self:Spawn() -- Spawn initially

	local function Lerp(num, goal, i)
		return num + (goal-num)*i
	end

	local lastHide = tick()
	local lastShow = tick()
	
	local Target
	RunS:BindToRenderStep("Follow", Enum.RenderPriority.Character.Value, function(dt)
		if player.Character then
			Target = player.Character.PrimaryPart
		end
		
		if not Target then
			return
		end
		
		timeSinceLastChange = timeSinceLastChange + dt
		lastActionTime = lastActionTime + dt

		-- Smoothly adjust circle radius towards target
		circleRadius = Lerp(circleRadius, targetCircleRadius, radiusChangeSpeed)

		-- Change the target radius at intervals
		if timeSinceLastChange >= radiusChangeInterval then
			targetCircleRadius = math.random(minRadius, maxRadius)
			timeSinceLastChange = 0
		end

		-- Adjust circle offset position
		local offsetPos = CFrame.Angles(0, 8, 0) * Vector3.new(circleRadius, 0, 0)
		local targetPos = Target.Position + offsetPos

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {self.Instance, player.Character}

		-- Ground Raycast to keep pet grounded
		local groundRayResult = workspace:Raycast(targetPos + Vector3.new(0, 5, 0), Vector3.new(0, -30, 0), rayParams)

		if groundRayResult then
			targetPos = Vector3.new(targetPos.X, groundRayResult.Position.Y + baseHeight, targetPos.Z)
		end

		-- Move the pet smoothly to the target position
		self.Body.BodyPosition.Position = targetPos

		-- Rotate the pet to face the player
		local lookVector = (not _G.Flying or _G.Flying == Constants.VehiclesType.Appa) and Target.CFrame.LookVector or Target.CFrame.UpVector
		self.Body.BodyGyro.CFrame = CFrame.lookAlong(self.Body.Position, lookVector)

		------ Spawning and despawning logic based on front raycast
		--local hipRay = Ray.new(self.Body.Position, Vector3.new(0,15,0) + self.Body.CFrame.LookVector * 10)
		--local backRay = Ray.new(self.Body.Position, Vector3.new(0,15,0) + self.Body.CFrame.LookVector * -10)
		--local hipPart = workspace:FindPartOnRay(hipRay, self.Instance)
		--local backPart = workspace:FindPartOnRay(hipRay, self.Instance)
		
		-- Precompute constant values
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {workspace.Scripted_Items.Maps}
		raycastParams.RespectCanCollide = true

		local hipPartResult = workspace:Raycast(self.Body.Position, Vector3.new(0,15,0) + self.Body.CFrame.LookVector * 10, raycastParams)
		local backPartResult = workspace:Raycast(self.Body.Position, Vector3.new(0,15,0) + self.Body.CFrame.LookVector * -10, raycastParams)

		local frontPart = hipPartResult and hipPartResult.Instance or nil
		local backPart = hipPartResult and hipPartResult.Instance or nil
		
		if frontPart or backPart then
			self:Despawn()
		elseif not frontPart and not backPart then
			self:Spawn()
		end
	end)
end

function Momo:Start()
	
	local Pet :MeshPart = self.Instance
	self.Hum = Pet:WaitForChild("Humanoid")
	self.State = Pet.State
	self.Body = Pet.PrimaryPart
	self.Smoke = Pet.PrimaryPart.Smoke
	
	self:Spawn()
	self:Setup()
	self:Follow()
	self:UpdateState()
	
	
	--_G.Flying
	
end

function Momo:Stop()
	RunS:UnbindFromRenderStep("Follow")
end

return Momo