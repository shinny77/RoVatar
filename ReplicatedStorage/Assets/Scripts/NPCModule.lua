-- @ScriptType: ModuleScript
-- SERVICES --
local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- FOLDERS --
local NPCs = script:WaitForChild("NPCs")
local Remotes = RS.Remotes
local Modules = RS.Modules
local Hitboxes = RS.Hitboxes

-- MODULES --
local zonePlus = require(Modules.Packages.Zone)
local MiscModule = require(Modules.Packages.Misc)
local simplePath = require(script.SimplePath)
local ragdollBuilder = require(script.RagdollBuilder)

-- EVENTS --
local Replicate = Remotes.Replicate

local WeaponTypes = {
	"Melee",
	"Sword",
	"Bow",
	"Staff",
	"Book",
	"Gun"
}

local NPCs = {
	["NPCAI"] = {
		Damage = 7,
		WalkSpeed = 16,
		MaxHealth = 100,
		Weapon = "Combat",
		WeaponType = "Melee",
		EXP = 100,
		FollowRange = 75,
		MaxSpawnRange = 60,
	};
	["TUTORIALAI"] = {
		Damage = 3,
		WalkSpeed = 12,
		MaxHealth = 80,
		Weapon = "Combat",
		WeaponType = "Melee",
		EXP = 100,
		FollowRange = 75,
		MaxSpawnRange = 60,
	};
}

local M1ImmunityTag = "Immunity"
local AirImmunityTag = "AirDown"

local NPCModule = {}

local function GetNPC(NPC)

	---- Type of last NPC
	local Type = NPC:GetAttribute("Type")
	local ModelType = NPC:GetAttribute("ModelType")

	local F = script.NPCs:FindFirstChild(Type)

	-- Getting new NPC of same Type
	for _, child in pairs(F:GetChildren()) do
		local MT = child:GetAttribute("ModelType")
		if MT and MT == ModelType then
			return child
		end
	end
	return nil
end

NPCModule.DeathFX = function(NPC, effectName)
	print('Death ', NPC, effectName)
	if effectName == "Default" then
		for i, v in pairs(NPC:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
				if v.Name ~= "HumanoidRootPart" then
					local bodyPart = v:Clone()
					v.Transparency = 1
					bodyPart.Transparency = 1
					bodyPart.Anchored = true
					bodyPart.Parent = workspace.Scripted_Items.Cache

					game.Debris:AddItem(bodyPart, 1)
				end
			elseif v:IsA("Decal") then
				v.Transparency = 1
			end
		end
	end
end

NPCModule.BloodFX = function(NPC)
	Replicate:FireAllClients("DeathExplosion", NPC.HumanoidRootPart)
end

NPCModule.GetNPCInfo = function(NPCName, Info)
	return NPCs[NPCName][Info]
end

NPCModule.Reward = function(NPC, Player)
	if game.Players:FindFirstChild(Player.Name) then
		warn("Rewarding "..Player.Name.."...")
		local module = require(game.ReplicatedStorage.Modules.Packages.QuestSystem)
		module.UpdatePlayersQuestData(Player,NPC.Name,1)
	end
end

NPCModule.GetNPCCharacter = function(NPCName)
	local NPC = NPCs:FindFirstChild(NPCName)
	if NPC then
		return NPC
	end
end

NPCModule.GetAnimation = function(NPCName, AnimationType, AnimationName)
	local NPC = script.Animations:FindFirstChild(NPCName)
	if NPC then
		local Type = NPC:FindFirstChild(AnimationType)
		if Type then
			local Animation = Type:FindFirstChild(AnimationName)
			if Animation then
				return Animation
			end
		end
	end
end

NPCModule.Chase = function(NPC, Target, spawnPos)
	if not NPC:FindFirstChild("Disabled") then
		local Humanoid = NPC:FindFirstChild("Humanoid")
		local HRP = NPC:FindFirstChild("HumanoidRootPart")

		if Humanoid and HRP and Target then
			Humanoid:MoveTo(Target.Position)
		elseif Humanoid and HRP and not Target and spawnPos then
			Humanoid:MoveTo(spawnPos)
		end
	end
end

NPCModule.SpawnNPC = function(NPCName, Zone)
	local cframeToSpawnAt = Zone.CFrame * CFrame.new(math.random(-Zone.Size.X / 2, Zone.Size.X / 2), 5, math.random(-Zone.Size.Y / 2, Zone.Size.Y / 2))

	local NPC = script.NPCs:FindFirstChild(NPCName)
	if NPC then
		local newNPC = NPC:Clone()
		newNPC.HumanoidRootPart.CFrame = cframeToSpawnAt
		newNPC.Animate.Disabled = false
		newNPC.Parent = Zone
		ragdollBuilder:Setup(newNPC)
		newNPC.NPCHandler.Disabled = false
		newNPC.Idle.Value = false
		newNPC.Humanoid.MaxHealth = NPCs[NPCName].MaxHealth
		newNPC.Humanoid.Health = NPCs[NPCName].MaxHealth
		newNPC.Humanoid.WalkSpeed = NPCs[NPCName].WalkSpeed

		local playerList = {}
		for i, v in ipairs(Players:GetPlayers()) do
			if not playerList[v.Name] then
				table.insert(playerList, v.Name)
			end
		end

		newNPC.Target.Value = playerList[math.random(1, #playerList)]
	end

end

NPCModule.ChangeTarget = function(NPC, Target) 
	local NPCTarget = NPC:FindFirstChild("Target")
	if NPCTarget then
		if NPCTarget.Value ~= Target.Name then
			NPCTarget.Value = Target.Name
		end
	end
end

NPCModule.Block = function(NPC)
	Replicate:FireAllClients("Combat", "HitFX", NPC.HumanoidRootPart, "Block Break")
	MiscModule.InsertDisabled(NPC, 2.7)
end

NPCModule.Attack = function(NPC, Humanoid, Weapon, accuracy:string?, damage :number?)
	local Character = NPC
	local HRP = Character.HumanoidRootPart
	if Weapon == "Combat" then
		local M1 = {
			[1] = Humanoid:LoadAnimation(script.Animations.Fists.Attack.A1),
			[2] = Humanoid:LoadAnimation(script.Animations.Fists.Attack.A2),
			[3] = Humanoid:LoadAnimation(script.Animations.Fists.Attack.A3),
			[4] = Humanoid:LoadAnimation(script.Animations.Fists.Attack.A4),
			[5] = Humanoid:LoadAnimation(script.Animations.Fists.Attack.A5)
		}

		local Idle = Humanoid:LoadAnimation(script.Animations.Fists.Idle.Equipped)

		local blocking = NPC:WaitForChild("isBlocking")
		local canAttack = NPC:WaitForChild("canAttack")

		blocking.Value = false
		canAttack.Value = true

		local m1CDs = {
			[1] = 0.5,
			[2] = 0.37,
			[3] = 0.4,
			[4] = 2
		}

		local m1HT = {
			[1] = 0.55,
			[2] = 0.55,
			[3] = 0.55,
			[4] = 0.55
		}

		local m1HitStartDelay = {
			[1] = 0.17,
			[2] = 0.17,
			[3] = 0.17,
			[4] = 0.17
		}

		local m1HitDuration = {
			[1] = 0.35,
			[2] = 0.35,
			[3] = 0.35,
			[4] = 0.35
		}

		local function createHitbox()
			coroutine.wrap(function()
				local Direction = 0
				local Length = 0.2
				local DashSpeed = 10

				local BV = Instance.new("BodyVelocity")
				BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), (Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(Direction), 0)).lookVector * DashSpeed
				BV.Parent = HRP
				game.Debris:AddItem(BV, Length)
			end)()

			local airChancesTable = {true, false, false, false, false, true, false}

			local airChance = airChancesTable[math.random(1, #airChancesTable)]

			local hitboxTemp = Hitboxes.Combat.M1:Clone()
			hitboxTemp.CFrame = HRP.CFrame
			hitboxTemp.Parent = HRP

			local weld = Instance.new("Weld")
			weld.Part0 = HRP
			weld.Part1 = hitboxTemp
			weld.C1 = require(hitboxTemp.weldCF)
			weld.Parent = hitboxTemp

			local hitboxZone = zonePlus.new(hitboxTemp)
			hitboxZone:setAccuracy(accuracy or "Precise")

			local canHit = Character.canHit
			local Air = Character.Air
			for i, v in pairs(hitboxZone:getParts()) do
				if v.Parent ~= Character then
					if v.Parent:FindFirstChild("Humanoid") and Players:FindFirstChild(v.Parent.Name) then
						if not v.Parent:FindFirstChild("Immune") and 
							--not Character:FindFirstChild("Disabled") and
							not Character:FindFirstChild("Immune") and 
							not blocking.Value and 
							not CS:HasTag(v.Parent, M1ImmunityTag) and 
							not CS:HasTag(v.Parent, AirImmunityTag) then
							
							if canHit.Value then
								canHit.Value = false
								local isPlayer = Players:FindFirstChild(v.Parent.Name)
								local isBlocking

								CS:AddTag(v.Parent, M1ImmunityTag)

								if isPlayer then
									isBlocking = isPlayer:WaitForChild("isBlocking")
								end
								local M1Damage = damage or NPCs[NPC.Name].Damage

								if not CS:HasTag(v.Parent, "Perfect Block") then
									if isBlocking.Value and HRP.CFrame.lookVector:Dot(v.Parent.HumanoidRootPart.CFrame.lookVector) < 0.7 then

										local blockBar = v.Parent:FindFirstChild("BlockBar")
										if blockBar then
											Replicate:FireAllClients("Combat", "HitFX", v.Parent.HumanoidRootPart, "Block Hit")
											blockBar.Value -= M1Damage

											coroutine.wrap(function()
												local BV = Instance.new("BodyVelocity")
												BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Character.HumanoidRootPart.CFrame.lookVector * 10
												BV.Parent = v.Parent.HumanoidRootPart
												game.Debris:AddItem(BV, 0.16)
											end)()
										end
									elseif v.Parent.Humanoid.Health > 0 then
										local eHum = v.Parent.Humanoid

										--local hitAnims = {
										--	[1] = eHum:LoadAnimation(script.Parent.Animations.Hit1),
										--	[2] = eHum:LoadAnimation(script.Parent.Animations.Hit2),
										--	[3] = eHum:LoadAnimation(script.Parent.Animations.Hit1),
										--	[4] = eHum:LoadAnimation(script.Parent.Animations.Hit1),
										--}

										eHum:TakeDamage(M1Damage)
										Replicate:FireAllClients("Combat", "HitFX", v.Parent.HumanoidRootPart, "Basic Hit")
										Replicate:FireAllClients("Combat", "Indicator", M1Damage, v.Parent)
										Replicate:FireClient(isPlayer, "CamShake", v.Parent.HumanoidRootPart.Position, 4, 100)

										if Character.DC.Value < 4 then
											coroutine.wrap(function()
												local BV = Instance.new("BodyVelocity")
												BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Character.HumanoidRootPart.CFrame.lookVector * 10
												BV.Parent = eHum.Parent.HumanoidRootPart
												game.Debris:AddItem(BV, 0.2)
											end)()

											MiscModule.InsertDisabled(v.Parent, 1)
											--hitAnims[Character.DC.Value]:Play(.01, .7, 1.3)
										elseif Character.DC.Value == 4 then
											if not airChance then
												coroutine.wrap(function()
													local BV = Instance.new("BodyVelocity")
													BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Character.HumanoidRootPart.CFrame.lookVector * 10
													BV.Parent = eHum.Parent.HumanoidRootPart
													game.Debris:AddItem(BV, 0.2)
												end)()

												MiscModule.InsertDisabled(v.Parent, 1)
												--hitAnims[Character.DC.Value]:Play(.01, .7, 1.3)
											else
												local AirPos = (HRP.CFrame * CFrame.new(0, 14, 0)).Position
												local enemyAirPos = (HRP.CFrame * CFrame.new(0, 14, -5)).Position

												local BP = Instance.new("BodyPosition")
												BP.Name = "AirUp"
												BP.MaxForce = Vector3.new(4e4,4e4,4e4)
												BP.Position = AirPos
												BP.P = 2e4
												BP.Parent = HRP
												game.Debris:AddItem(BP, 1)

												local EnemyBP = Instance.new("BodyPosition")
												EnemyBP.Name = "AirUp"
												EnemyBP.MaxForce = Vector3.new(4e4,4e4,4e4)
												EnemyBP.Position = enemyAirPos
												EnemyBP.P = 2e4
												EnemyBP.Parent = v.Parent.HumanoidRootPart
												game.Debris:AddItem(EnemyBP, 1)

												MiscModule.InsertDisabled(v.Parent, 1)

												Air.Value = true
												task.delay(1.8, function()
													Air.Value = false
												end)
											end
										elseif Character.DC.Value == 5 then
											if not Air.Value then
												CS:AddTag(v.Parent, AirImmunityTag)
												MiscModule.Ragdoll(v.Parent, 1 + 0.5)
												coroutine.wrap(function()
													local BV = Instance.new("BodyVelocity")
													BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Character.HumanoidRootPart.CFrame.lookVector * 50
													BV.Parent = eHum.Parent.HumanoidRootPart
													game.Debris:AddItem(BV, 0.15)

													task.delay(2, function()
														CS:RemoveTag(v.Parent, AirImmunityTag)
													end)
												end)()
											else
												local Params = RaycastParams.new()
												Params.FilterType = Enum.RaycastFilterType.Exclude
												Params.FilterDescendantsInstances = {Character, v.Parent}

												local raycastOrigin = HRP.Position
												local raycastDirection = (HRP.CFrame * CFrame.Angles(45, 0, 0)).UpVector * -100
												local ray = workspace:Raycast(raycastOrigin, raycastDirection, Params)
												if ray.Instance then
													if (ray.Position - raycastOrigin).Magnitude < 40 then
														CS:AddTag(v.Parent, AirImmunityTag)
														if v.Parent.HumanoidRootPart:FindFirstChild("AirUp") then
															v.Parent.HumanoidRootPart.AirUp:Destroy()
														end
														local EnemyBP = Instance.new("BodyPosition")
														EnemyBP.Name = "AirDown"
														EnemyBP.MaxForce = Vector3.new(4e4,4e4,4e4)
														EnemyBP.Position = ray.Position
														EnemyBP.P = 4e4
														EnemyBP.Parent = v.Parent.HumanoidRootPart
														game.Debris:AddItem(EnemyBP, 1)

														task.delay(.3, function()
															Replicate:FireAllClients("Combat", "AirDown", ray.Position, v.Parent)
															Replicate:FireAllClients("CamShake", ray.Position, 8, 100)
															task.delay(2.3, function()
																CS:RemoveTag(v.Parent, AirImmunityTag)
															end)
														end)
													end
												end
												MiscModule.Ragdoll(v.Parent, 1 + 0.5)
											end
										end
									end
								else
									Replicate:FireAllClients("Combat", "HitFX", v.Parent.HumanoidRootPart, "Perfect Block")
									MiscModule.InsertDisabled(Character, 1.75)
								end


								task.delay(0.25, function()
									canHit.Value = true
									CS:RemoveTag(v.Parent, M1ImmunityTag)
								end)
							end

						end
					end
				end
			end

			game.Debris:AddItem(hitboxTemp, .3)
		end

		task.spawn(function()
			NPC.ChildAdded:Connect(function()
				if NPC:FindFirstChild("Disabled") then
					canAttack.Value = false
				else
					canAttack.Value = true
				end
			end)

			NPC.ChildRemoved:Connect(function()
				if NPC:FindFirstChild("Disabled") then
					canAttack.Value = false
				else
					canAttack.Value = true
				end
			end)
		end)


		if --not NPC:FindFirstChild("Disabled") and 
			not blocking.Value 
			and canAttack.Value then
			
			local DC = NPC.DC
			local Combo = NPC.Combo
			if canAttack.Value then
				if Combo.Value == 1 then
					Combo.Value = 2
					DC.Value = 1

					task.delay(1.5, function()
						if Combo.Value == 2 then
							Combo.Value = 1
						end
					end)
					canAttack.Value = false
					Humanoid.WalkSpeed = NPCs[NPC.Name].WalkSpeed / 2

					M1[DC.Value]:Play(.05, 0.8, 1.4)

					M1[DC.Value]:GetMarkerReachedSignal("Hit"):Connect(function()
						createHitbox()
					end)

					M1[DC.Value]:GetMarkerReachedSignal("DBReset"):Connect(function()
						canAttack.Value = true
						if not NPC:FindFirstChild("Disabled") then
							Humanoid.WalkSpeed = NPCs[NPC.Name].WalkSpeed
						end
					end)
				elseif Combo.Value == 2 then
					Combo.Value = 3
					DC.Value = 2
					task.delay(1.5, function()
						if Combo.Value == 3 then
							Combo.Value = 1
						end
					end)
					canAttack.Value = false
					Humanoid.WalkSpeed = NPCs[NPC.Name].WalkSpeed * 0.5

					M1[DC.Value]:Play(.05, 0.8, 1.4)

					M1[DC.Value]:GetMarkerReachedSignal("Hit"):Connect(function()
						createHitbox()
					end)

					M1[DC.Value]:GetMarkerReachedSignal("DBReset"):Connect(function()
						canAttack.Value = true
						if not NPC:FindFirstChild("Disabled") then
							Humanoid.WalkSpeed = NPCs[NPC.Name].WalkSpeed
						end
					end)
				elseif Combo.Value == 3 then
					Combo.Value = 4
					DC.Value = 3
					task.delay(1.5, function()
						if Combo.Value == 4 then
							Combo.Value = 1
						end
					end)
					canAttack.Value = false
					Humanoid.WalkSpeed = NPCs[NPC.Name].WalkSpeed * 0.5

					M1[DC.Value]:Play(.05, 0.8, 1.4)

					M1[DC.Value]:GetMarkerReachedSignal("Hit"):Connect(function()
						createHitbox()
					end)

					M1[DC.Value]:GetMarkerReachedSignal("DBReset"):Connect(function()
						canAttack.Value = true
						if not NPC:FindFirstChild("Disabled") then
							Humanoid.WalkSpeed = NPCs[NPC.Name].WalkSpeed
						end
					end)
				elseif Combo.Value == 4 then
					Combo.Value = 5
					DC.Value = 4

					task.delay(1.5, function()
						if Combo.Value == 5 then
							Combo.Value = 1
						end
					end)
					canAttack.Value = false
					Humanoid.WalkSpeed = NPCs[NPC.Name].WalkSpeed * 0.5

					M1[DC.Value]:Play(.05, 0.8, 1.4)

					M1[DC.Value]:GetMarkerReachedSignal("Hit"):Connect(function()
						createHitbox()
					end)

					M1[DC.Value]:GetMarkerReachedSignal("DBReset"):Connect(function()
						canAttack.Value = true
						if not NPC:FindFirstChild("Disabled") then
							Humanoid.WalkSpeed = NPCs[NPC.Name].WalkSpeed
						end
					end)
				elseif Combo.Value == 5 then
					Combo.Value = 1
					DC.Value = 5

					canAttack.Value = false
					Humanoid.WalkSpeed = NPCs[NPC.Name].WalkSpeed * 0.5

					task.delay(0.7, function()
						if not NPC:FindFirstChild("Disabled") then
							Humanoid.WalkSpeed = NPCs[NPC.Name].WalkSpeed
						end
					end)

					M1[DC.Value]:Play(.05, 0.8, 1.4)

					M1[DC.Value]:GetMarkerReachedSignal("Hit"):Connect(function()
						createHitbox()
					end)

					M1[DC.Value]:GetMarkerReachedSignal("End"):Connect(function()
						task.delay(2, function()
							Combo.Value = 1
							DC.Value = 0
							canAttack.Value = true
						end)
					end)
				end
			end	
		end
	end
end

NPCModule.Respawn = function(NPC:Model, RespawnTime, SpawnCF)
	local npcToSpawn = GetNPC(NPC)
	if npcToSpawn then
		task.wait(RespawnTime)
		local newNPC = npcToSpawn:Clone()
		newNPC.Name = NPC.Name

		newNPC:FindFirstChild("Area"):Destroy()
		newNPC:FindFirstChild("PathPoints"):Destroy()

		NPC:FindFirstChild("Area"):Clone().Parent = newNPC 
		NPC:FindFirstChild("PathPoints"):Clone().Parent = newNPC

		--newNPC.Animate.Enabled = true

		newNPC.HumanoidRootPart.CFrame = SpawnCF
		newNPC.Parent = NPC.Parent
		
		for att, value in pairs(NPC:GetAttributes()) do
			newNPC:SetAttribute(att, value)
		end
	else
		warn("Same NPC could not found!", NPC)
	end
end

NPCModule.Ragdoll = function(NPC)
	task.spawn(function()
		ragdollBuilder:Ragdoll(NPC)
	end)
end

NPCModule.Setup = function(NPC)
	ragdollBuilder:Setup(NPC)
end

NPCModule.UnRagdoll = function(NPC)
	ragdollBuilder:Unragdoll(NPC)
end

return NPCModule
