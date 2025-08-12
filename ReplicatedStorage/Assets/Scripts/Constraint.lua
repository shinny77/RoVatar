-- @ScriptType: Script
-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local cs = game:GetService("CollectionService")

-- FOLDERS --
local Remotes = RS:WaitForChild("Remotes")
local Modules = RS:WaitForChild("Modules")

-- EVENTS --
local Replicate = Remotes.Replicate

-- MODULES --
local Misc = require(Modules.Packages.Misc)

local char = script.Parent
local hum = char:WaitForChild("Humanoid")
local player = Players[char.Name]

local spawnSFX = RS.Assets.SFXs.Sounds.Spawn:Clone()
spawnSFX.Parent = char:WaitForChild("HumanoidRootPart")
spawnSFX:Play()
game.Debris:AddItem(spawnSFX, 1)

--local pStatus = player:WaitForChild("Status")
--local pDefense = pStatus:WaitForChild("Defense")
local isBlocking = player:WaitForChild("isBlocking")
--local canRun = player:WaitForChild("canRun")
--local canDash = player:WaitForChild("canDash")

local isBlockBroken = false

---- BLOCKING HANDLER --
local blockingIdle
local preblock

isBlocking.Changed:Connect(function()
	if isBlocking.Value then
		blockingIdle = hum:LoadAnimation(script.BlockingIdle)
		preblock = hum:LoadAnimation(script.PreBlock)
		if not isBlockBroken then --and not char:FindFirstChild("Disabled") then --:TODO: (TASK_ID) : 1018
			preblock:Play()
			blockingIdle:Play()
			
			local blockBar = Instance.new("IntValue")
			blockBar.Name = "BlockBar"
			
			blockBar.Value = hum.MaxHealth/2
			blockBar.Parent = char
			
			hum.WalkSpeed = 8
			hum.JumpPower = 20
			
			cs:AddTag(char, "Perfect Block")
			task.delay(0.2, function()
				cs:RemoveTag(char, "Perfect Block")
			end)
			
			blockBar.Changed:Connect(function(newValue)
				if newValue <= 0 and not isBlockBroken then
					isBlockBroken = true
					Replicate:FireAllClients("Combat", "HitFX", char.HumanoidRootPart, "Block Break")
					Misc.InsertDisabled(char, 2.7)
					blockBar:Destroy()
					preblock:Stop()		
					blockingIdle:Stop()
				
					task.delay(1.5, function()
						isBlockBroken = false
						--canDash.Value = true
						--canRun.Value = true
						hum.WalkSpeed = 16
						hum.JumpPower = 50
					end)
				elseif newValue > 0 and not isBlockBroken then
				
				end
			end)
		end
	else
		preblock:Stop()
		blockingIdle:Stop()
	
		local blockBar = char:FindFirstChild("BlockBar")
		if blockBar then
			blockBar:Destroy()
		end
		if not isBlockBroken then
			--canDash.Value = true
			--canRun.Value = true
			hum.WalkSpeed = 16
			hum.JumpPower = 50
		end
	end
end)
