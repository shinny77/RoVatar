-- @ScriptType: LocalScript
local Tool = script.Parent
local xeq = false
Tool.Equipped:Connect(function()
	xeq = true
end)

Tool.Unequipped:Connect(function()
	xeq	 = false
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

-- Get player character
local player = Players.LocalPlayer
local character = player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local primaryPart = character.PrimaryPart

-- Set up variables for flight controls
local gravityVector = Vector3.new(0, game.Workspace.Gravity, 0)
local yAxis = Vector3.new(0, 1, 0)
local force = 400
local drag = 1

-- Set up flight attachments and animations
local vectorForce = script:WaitForChild("VectorForce")
vectorForce.Attachment0 = primaryPart.RootRigAttachment

local alignOrientation = script:WaitForChild("AlignOrientation")
alignOrientation.Attachment0 = primaryPart.RootRigAttachment

local animation = script:WaitForChild("Animation")
local animationTrack = humanoid.Animator:LoadAnimation(animation)
animationTrack.Priority = Enum.AnimationPriority.Movement

-- Set up function for flying
local connection = nil

local function FlyAction(actionName, inputState, inputObject)
if xeq == false then return end
	if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
	if connection == true then return Enum.ContextActionResult.Pass end

	-- Start flying
	if connection == nil then
		connection = true

		-- Change state to jumping if not in air
		if humanoid.FloorMaterial ~= Enum.Material.Air then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
			humanoid.AnimationPlayed:Connect(function(track) if track.Animation.Name == "JumpAnim" and connection == true then track:Stop(0) end end)
			task.wait(.1)
		end

		vectorForce.Enabled = true
		alignOrientation.CFrame = primaryPart.CFrame
		alignOrientation.Enabled = true
		animationTrack:Play()
script.Parent.Wind:Play()
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)

		connection = RunService.Heartbeat:Connect(function(deltaTime)
			-- Apply gravity
			vectorForce.Force = gravityVector * primaryPart.AssemblyMass

			-- Apply movement force
			local moveVector = Vector3.new(character.Humanoid.MoveDirection.X, yAxis,character.Humanoid.MoveDirection.Z)
			if moveVector.Magnitude > 0  then
				moveVector = moveVector.Unit
				vectorForce.Force += moveVector * force * primaryPart.AssemblyMass

				if math.abs(moveVector.Y) > 0 then
					alignOrientation.CFrame = CFrame.lookAt(Vector3.new(0,0,0), moveVector, -primaryPart.CFrame.LookVector) * CFrame.fromOrientation(-math.pi / 2 , 0, 0)

				else
					alignOrientation.CFrame = CFrame.lookAt(Vector3.new(0,0,0), moveVector) * CFrame.fromOrientation(-math.pi / 2 , 0, 0)
				end
			end

			-- Apply drag
			if primaryPart.AssemblyLinearVelocity.Magnitude > 0 then
				local dragVector =- primaryPart.AssemblyLinearVelocity.Unit * primaryPart.AssemblyLinearVelocity.Magnitude ^ 1.2
				vectorForce.Force += dragVector * drag * primaryPart.AssemblyMass
			end
		end)
		-- Stop flying
	else
		script.Parent.Wind:Stop()
		vectorForce.Enabled = false
		alignOrientation.Enabled = false
		animationTrack:Stop()
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		connection:Disconnect()
		connection = nil 
	end

	return Enum.ContextActionResult.Pass
end

-- Set up functions for vertical movement

local function UpAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then yAxis = 1 else yAxis = 0 end; return Enum.ContextActionResult.Pass
end

function DownAction(actionName,inputState,inputObject)
	if inputState == Enum.UserInputState.Begin then yAxis = -1 else yAxis = 0 end; return Enum.ContextActionResult.Pass
end


ContextActionService:BindAction("Fly", FlyAction, true, Enum.KeyCode.F)
ContextActionService:SetTitle("Fly", "Fly")
ContextActionService:SetPosition("Fly", UDim2.new(1, -150, 1, -80))

ContextActionService:BindAction("Up", UpAction, true, Enum.KeyCode.E)
ContextActionService:SetTitle("Up", "↑")
ContextActionService:SetPosition("Up", UDim2.new(1, -55, 1, -55))

ContextActionService:BindAction("Down", DownAction, true, Enum.KeyCode.Q)
ContextActionService:SetTitle("Down", "↓")
ContextActionService:SetPosition("Down", UDim2.new(1, -105, 1, -145))

---------------------------------
-- You can customize any values here
-- Made by Vuuk Studios

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")






local count  = 0
UIS.InputBegan:Connect(function(Input, isTyping)
	if isTyping then return end


if Input.KeyCode == Enum.KeyCode.F then
		if not humanoid then return end
		if humanoid.Health > 0 then
			if xeq == false then return end
			if count == 1 then
				script.RES:FireServer()
				spawn(function()
					wait(0.05)
					count = 0
				end)
			end
			if count == 0 then
				script.RE:FireServer()
				count = 1
			end
		
			
			
			
			
		end
end
end)

