-- @ScriptType: LocalScript
-- SERVICES --
local TS = game:GetService("TweenService")
local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("PhysicsService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- FOLDERS --
local Modules = RS:WaitForChild("Modules")
local Remotes = RS:WaitForChild("Remotes")
local Hitboxes = RS:WaitForChild("Hitboxes")
local Sounds = RS:WaitForChild("Assets").SFXs.Sounds
local RunService = game:GetService("RunService")
-- VARIABLES --
local Player = Players.LocalPlayer
local Character
local Humanoid
local HRP
local Tool = script.Parent

local attackRemote = script:WaitForChild("Attack")
local Equipped = script:WaitForChild("Equipped")

-- MODULES --

-- ANIMATIONS --
local equippedIdle
local val = Player.Character:WaitForChild("isBlocking")
local humanoid = Player.Character.Humanoid

local debs = false
local equiped = false
-- FUNCTIONS --
Tool.Equipped:Connect(function()
	Character = Tool.Parent
	equiped = true




	HRP = Character:WaitForChild("HumanoidRootPart")
	Humanoid = Character:WaitForChild("Humanoid")




	attackRemote:FireServer("Equip")
	attackRemote:FireServer("Unblock")
	val.Value = false

end)

Tool.Unequipped:Connect(function()

	equiped = false

	attackRemote:FireServer("Unequip")

	attackRemote:FireServer("Unblock")
	val.Value = false	

end)

UIS.InputBegan:Connect(function(Input, isTyping)
	if isTyping then return end

	if Player.Character:FindFirstChild("PBSTUN") then return end
	if Player.Character:FindFirstChild("Stamina").Value < 6 then return end

	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		if not Humanoid then return end
		if Humanoid.Health > 0 then
			local Disabled = Character:FindFirstChild("Disabled")
			if not Disabled then

				if UIS:IsKeyDown(Enum.KeyCode.Space) then
					attackRemote:FireServer("Attack", true)
				else
					attackRemote:FireServer("Attack", false)
				end

				coroutine.wrap(function()
					local noJumpValue = Instance.new("BoolValue")
					noJumpValue.Name = "noJump"
					noJumpValue.Parent = Character
					game.Debris:AddItem(noJumpValue, 1.4)
				end)()
			end
		end
	elseif Input.KeyCode == Enum.KeyCode.F then
		if not Humanoid then return end
		if Humanoid.Health > 0 then
			local Disabled = Character:FindFirstChild("Disabled")
			if not Disabled then
				val.Value = true

				attackRemote:FireServer("Block")
			end
		end

	end
end)

UIS.InputEnded:Connect(function(Input, isTyping)
	if isTyping then return end

	if Input.KeyCode == Enum.KeyCode.F then
		attackRemote:FireServer("Unblock")
		val.Value = false

	end
end)