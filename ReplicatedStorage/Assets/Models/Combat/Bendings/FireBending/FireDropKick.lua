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

local Rp = game.ReplicatedStorage
local char = plr.CharacterAdded:Wait()
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
			wait(0.41)
			ic = false
		end)

		Tool.Active.Value = "Yes"
		
		 Track1 = plr.Character.Humanoid:LoadAnimation(script.HoldA)
		Track1:Play()
		Track1:AdjustSpeed(0)
	
		
	
	
		if Debounce == 2 then
		
			local function anchor()
				plr.Character.HumanoidRootPart.Anchored = true
			end
			delay(0.1,anchor)
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
		spawn(function()
			wait(2.2)
			Tool.Active.Value = "None"
		end)
		Track1:AdjustSpeed(1)
		wait(0.2)
		spawn(function()

			plr.Character.HumanoidRootPart.Anchored = false
		end)
		local slide = Instance.new("BodyVelocity")
		slide.MaxForce = Vector3.new(1,0,1) *30000	
		slide.Name = "Sld"
		slide.Parent = char.HumanoidRootPart
		slide.Velocity = char.HumanoidRootPart.CFrame.lookVector * 62
		game.Debris:AddItem(slide,0.6)
		local slide3 = Instance.new("BodyVelocity")
		slide3.MaxForce = Vector3.new(1,0,1) *30000	
		slide3.Name = "Sld3"
		slide3.Parent = char.HumanoidRootPart
		slide3.Velocity = char.HumanoidRootPart.CFrame.upVector * 123
		game.Debris:AddItem(slide3,0.6)
		
		spawn(function()
			script.Launch:Play()
		end)
		
		wait(0.5)
		
		local mousepos = Mouse.Hit
		script.RemoteEvent:FireServer(mousepos,Mouse.Hit.p)
	
		wait(0)

		wait(1)
		
	
		wait(.5)
		spawn(function()
			wait(3)
			script.Launch:Stop()
		end)
		Tool.Active.Value = "None"
		wait(2)
		Debounce = 1
	end
end)
