-- @ScriptType: LocalScript
local UserInputService = game:GetService("UserInputService")
local tween = game:GetService("TweenService")

local localPlayer = game.Players.LocalPlayer
local character
local humanoid

local canDoubleJump = false
local hasDoubleJumped = true
local oldPowerlocal TIME_BETWEEN_JUMPS = 0.1
local DOUBLE_JUMP_POWER_MULTIPLIER = 1.5

local anim :AnimationTrack 

local function JumpEffect(jumpingChar)
	local platform = Instance.new("Part", workspace)
	platform.Size = Vector3.new(0.2, 2.755, 2.755)
	
	platform.Transparency = .5
	platform.CanTouch = false
	platform.CanCollide = false
	platform.Shape = Enum.PartType.Cylinder
	platform.Material = Enum.Material.ForceField
	platform.Color = Color3.fromRGB(163, 162, 165)
	
	local decal = Instance.new("Decal", platform)
	decal.Transparency = .8
	decal.Face = Enum.NormalId.Right
	decal.Texture = "rbxassetid://5471020732"
	
	platform.CFrame = (jumpingChar.PrimaryPart.CFrame-Vector3.new(0,humanoid.HipHeight/2,0))*CFrame.Angles(0,0,math.rad(90))
	platform.Anchored = true
	
	tween:Create(platform, TweenInfo.new(0.5), {Size = Vector3.new(0.2, 10, 10)}):Play()
	tween:Create(platform, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Transparency = 1}):Play()
	tween:Create(platform.Decal, TweenInfo.new(0.5), {Transparency = 1}):Play()
	
	wait(0.8)
	platform:Destroy()
end

function onJumpRequest()
	if not character or not humanoid or not character:IsDescendantOf(workspace) or
		humanoid:GetState() == Enum.HumanoidStateType.Dead then
		return
	end

	if canDoubleJump and not hasDoubleJumped and not _G.Flying then
		anim:AdjustSpeed(2)
		anim:Play()
		hasDoubleJumped = true
		humanoid.JumpPower = oldPower * DOUBLE_JUMP_POWER_MULTIPLIER		
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		JumpEffect(character)
	end
end

local function characterAdded(newCharacter)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid")
	hasDoubleJumped = true
	canDoubleJump = false
	oldPower = humanoid.JumpPower 
	
	anim = humanoid.Animator:LoadAnimation(script:WaitForChild("Jump_Animation"))
	
	local firstTime = true	
	
	humanoid.StateChanged:connect(function(old, new)
		if new == Enum.HumanoidStateType.Landed then
			
			if firstTime == false then
				canDoubleJump = false
				hasDoubleJumped = false
				humanoid.JumpPower = oldPower
			end

			firstTime = false
			
		elseif new == Enum.HumanoidStateType.Freefall then
			wait(TIME_BETWEEN_JUMPS)			
			canDoubleJump = true
		end
	end)
end

if localPlayer.Character then
	characterAdded(localPlayer.Character)
end

localPlayer.CharacterAdded:connect(characterAdded)
UserInputService.JumpRequest:connect(onJumpRequest)