-- @ScriptType: LocalScript

local Tool = script.Parent

Tool.Equipped:Connect(function()
	Tool.Equip.Value = true
end)

Tool.Unequipped:Connect(function()
	Tool.Equip.Value = false
end)


local UIS = game:GetService("UserInputService")
local plr = game.Players.LocalPlayer
Mouse = plr:GetMouse()
local Debounce = 1
local speed = 50

local Rp = game.ReplicatedStorage
local char = plr.CharacterAdded:Wait()
local Sound2 = script:WaitForChild("Thrust")
local ic = script:WaitForChild("InstaCast")
local isa =char:WaitForChild("IsAttacking")
UIS.InputBegan:Connect(function(Input,isTyping)
	if Input.KeyCode == Enum.KeyCode.Z and Debounce == 1 and Tool.Equip.Value == true and Tool.Active.Value == "None" then
		if isTyping then return end
		if isa.Value == true then return end
		if plr.Character:FindFirstChild("Stamina").Value < 25 then return end
		if plr.CombatStats:FindFirstChild("Level").Value < 5 then return end
		Debounce = 2
		spawn(function()

			ic = true
			wait(0.41)
			ic = false
		end)

		Tool.Active.Value = "Yes"
		Track1 = plr.Character.Humanoid:LoadAnimation(script.HoldA)
		Track1:Play()
		spawn(function()
			wait(0.3)
			Track1:AdjustSpeed(0)
		end)
		
		if Debounce == 2 then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(0,1e8,0)
			BodyVelocity.Velocity = plr.Character:FindFirstChild("HumanoidRootPart").CFrame.UpVector*0
			BodyVelocity.Parent = plr.Character:FindFirstChild("HumanoidRootPart")
			game.Debris:AddItem(BodyVelocity,0.3)
			local function anchor()
				plr.Character.HumanoidRootPart.Anchored = true
			end
			delay(0.3,anchor)
		end
		
		for i = 1,math.huge do
			if Debounce == 2 then
			
				plr.Character.HumanoidRootPart.CFrame = CFrame.new(plr.Character.HumanoidRootPart.Position, plr.Character.HumanoidRootPart.Position + Vector3.new(Mouse.Hit.lookVector.x, plr.Character.HumanoidRootPart.CFrame.lookVector.y, Mouse.Hit.lookVector.z))
				--plr.Character.HumanoidRootPart.CFrame = CFrame.new(plr.Character.HumanoidRootPart.Position,plr.Character.HumanoidRootPart.Position + Mouse.Hit.p)
			
			else
				
				break
				end
	     wait()
	  end
	end
end)

UIS.InputEnded:Connect(function(Input,isTyping)
	if Input.KeyCode == Enum.KeyCode.Z and Debounce == 2 and Tool.Equip.Value == true then
		if isTyping then return end
		
		repeat wait() until ic == false
		Debounce = 3
		Tool.Active.Value = "None"
	
		Track1:AdjustSpeed(1)
		Sound2:Play()
		
		local mousepos = Mouse.Hit
		script.RemoteEvent:FireServer(mousepos,Mouse.Hit.p)
		local Camera = game:GetService("Workspace").CurrentCamera
		local CameraShaker = require(Rp.Modules.Packages.CameraShaker)
	
		local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value,(function(shakeCFrame)
			Camera.CFrame = Camera.CFrame * shakeCFrame
		end))
		camShake:Shake(CameraShaker.Presets.Explosion)
		camShake:Start()
		wait(0)
		
		wait(1)
	
	
		plr.Character.HumanoidRootPart.Anchored = false
		wait(.5)
		
		wait(5)
		Debounce = 1
	end
end)
