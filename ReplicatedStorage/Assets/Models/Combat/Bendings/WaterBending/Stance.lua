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
local char = plr.CharacterAdded:Wait()
local Rp = game.ReplicatedStorage
local isa = char:WaitForChild("IsAttacking")
local ic = script:WaitForChild("InstaCast")
UIS.InputBegan:Connect(function(Input,isTyping)
	if Input.KeyCode == Enum.KeyCode.Z and Debounce == 1 and Tool.Equip.Value == true and Tool.Active.Value == "None" then
		if isTyping then return end
		if isa.Value == true then return end
		if plr.Character:FindFirstChild("Stamina").Value < 25 then return end
		if plr.CombatStats:FindFirstChild("Level").Value < 5 then return end
		Debounce = 2
		spawn(function()

			ic = true
			wait(1.6)
			ic = false
		end)

		Tool.Active.Value = "Yes"
		
		Track1 = plr.Character.Humanoid:LoadAnimation(script.HoldA)
		Track1:Play()
		spawn(function()
			wait(1
			)
			
			script.RemoteEventS:FireServer()
			script.Stand:Play()
		end)
		
		spawn(function()
			wait(1.55
			)

			script["Ground-Slam"]:Play()
			script.Stand:Play()
			
		end)
		
		spawn(function()
			wait(1.6)
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
	
		Track1:AdjustSpeed(1)
		script.Stand:Stop()
	
		wait(0.25)
		
		local mousepos = Mouse.Hit
		script.RemoteEvent:FireServer(mousepos,Mouse.Hit.p)
	
		wait(0)
		
		wait(1)
		
	
		plr.Character.HumanoidRootPart.Anchored = false
		wait(.5)
		Tool.Active.Value = "None"
		wait(7)
		Debounce = 1
	end
end)
