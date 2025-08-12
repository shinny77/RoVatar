-- @ScriptType: ModuleScript
--[[ Services ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
--[[ Dependencies ]]
local Maid = require(script.Maid)
--

--[[ Util functions ]]
local function InPart(part, pos, heightOffset)
	local rel = part.CFrame:PointToObjectSpace(pos)
	local size = part.Size
	if math.abs(rel.x) <= size.x/2 and math.abs(rel.y) <= size.y/2 + (heightOffset or 0) and math.abs(rel.z) <= size.z/2 then
		return true
	end
	return false
end
--


local MaterialDensities = {}

for _,mat in ipairs(Enum.Material:GetEnumItems()) do
	MaterialDensities[mat] = PhysicalProperties.new(mat).Density
end

local Player = Players.LocalPlayer

local SwimController = {
	Zones = {},
	Swimming = false,

	--[[ Config ]]
	InvalidStartStates = { -- Can't start swimming if character is in one of these states
		Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.PlatformStanding,
		Enum.HumanoidStateType.Dead, Enum.HumanoidStateType.Physics,
		Enum.HumanoidStateType.Swimming
	},
	DisabledStates = { -- These states are disabled when swimming
		Enum.HumanoidStateType.GettingUp,
		Enum.HumanoidStateType.Jumping
	},

	ClampSurfaceMovement = true, -- clamps move direction to the surface of the water
	ProcessWeldedParts = true, -- calculate buoyancy forces for parts welded to the character

	DragForceMultiplier = 9.85, -- magic number that determines strength of drag

	SurfaceDepth = 0.35, -- offsets surface from the top of the part
	MaxJumpDepth = 2, -- determines how close to the surface you need to be to jump
}



--[[ Add a part zone to treat as water ]]
function SwimController:AddZone(part)
	if not table.find(self.Zones, part) then
		table.insert(self.Zones, part)
	end
end
--

function SwimController:Start()
	self._maid = Maid.new()
	self._stateMaid = Maid.new()
	self._recalcMaid = Maid.new()

	--[[ Update character ]]
	Player:GetPropertyChangedSignal("Character"):Connect(function()
		self:_setCharacter(Player.Character)
	end)
	if Player.Character then
		task.defer(self._setCharacter, self, Player.Character)
	end
	--

	RunService.Heartbeat:connect(function(dt)
		if not self.Character then
			return
		end

		debug.profilebegin("PartSwimming")

		--[[ Determine if I'm in a swimming zone
			Simply looks to see if your rootparts position is in any zones
			You could add a more accurate method for this
		]]

		local humanState = self.Humanoid:GetState()
		local rootPos = self.RootPart.Position
		local currentZone

		for i,part in pairs(self.Zones) do
			if InPart(part, rootPos, self._didJump and -self.SurfaceDepth - self.MaxJumpDepth or 0) then
				currentZone = part
				break
			end
		end

		--[[ Start/Stop swimming when you enter or leave a zone]]
		if self.LastInZone ~= currentZone then
			self.LastInZone = currentZone

			if currentZone then
				self:_startSwimming(currentZone)
			else
				self:_stopSwimming()
			end
		end
		--

		if self.Swimming then
			if (self.Swimming and humanState == Enum.HumanoidStateType.Swimming) or not table.find(self.InvalidStartStates, humanState) then
				if not self._inSwimmingState then
					self._inSwimmingState = true

					--[[ Change humanoid state to swimming and disable other states ]]
					self.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

					for _,state in ipairs(self.DisabledStates) do
						self.Humanoid:SetStateEnabled(state, false)
					end

					self._stateMaid:Add(function()
						--[[ On stopped swimming, enable humanoid states again]]
						for _,state in ipairs(self.DisabledStates) do
							self.Humanoid:SetStateEnabled(state, true)
						end
					end)

					self._stateMaid:Add(game:GetService("UserInputService").JumpRequest:Connect(function()
						self._didJump = true
					end))

					if self.ClampSurfaceMovement then
						self._stateMaid:Add(self.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
							local moveDir = self.Humanoid.MoveDirection

							if self._nearSurface and moveDir.Y > 0.1 then
								local camCFrame = workspace.CurrentCamera.CFrame
								local inputDir = camCFrame:VectorToObjectSpace(moveDir)

								if math.abs(inputDir.Y) < 1e-2 then
									local from = camCFrame.LookVector
									local to = Vector3.new(from.X, 0, from.Z)

									local newMoveDir = CFrame.fromAxisAngle(
										from:Cross(to),
										math.acos(math.clamp(from:Dot(to), -1, 1))
									) * moveDir

									self.Humanoid:Move(newMoveDir)
								end
							end
						end))
					end
				end
			else
				if self._inSwimmingState then
					self._inSwimmingState = false
					self._stateMaid:Cleanup()
				end
			end
		end
		--

		--
		if self.Swimming then
			local velocity = self.RootPart.AssemblyLinearVelocity

			if self._shouldRecalculateForces or self._assemblyMass ~= self.RootPart.AssemblyMass then
				self:_recalculateForces()
			end

			local drag = velocity * self._dragMultiplier
			local upForce = self._antigravForce

			local offsetToSurface = (self.SurfaceY - self.SurfaceDepth) - rootPos.Y

			self._didJump = false
			self._nearSurface = offsetToSurface < 2

			if self._nearSurface then
				upForce += math.clamp(math.min(1, offsetToSurface) * 12 - velocity.y, -10, 100) * 5 * self._assemblyMass
			else
				upForce += self._buoyancyForce
			end

			self._vectorForce.Force = Vector3.yAxis * upForce - drag
		end
		--

		debug.profileend()
	end)
end

function SwimController:_recalculateForces()
	if not self.Character or not self.Swimming then
		return
	end

	self._recalcMaid:Cleanup()
	self._shouldRecalculateForces = false

	local assemblyMass = self.RootPart.AssemblyMass
	local gravity = workspace.Gravity

	local buoyancyForce = -assemblyMass * gravity
	local totalVolume = 0

	for i,v in ipairs(self.RootPart:GetConnectedParts(true)) do
		local isLimb = v.Parent == self.Character and (
			self.Humanoid:GetBodyPartR15(v) ~= Enum.BodyPartR15.Unknown or
				self.Humanoid:GetLimb(v) ~= Enum.Limb.Unknown
		)

		if not isLimb and not self.ProcessWeldedParts then
			continue
		end

		self._recalcMaid:Add(v:GetPropertyChangedSignal("CanCollide"):Connect(function()
			self._shouldRecalculateForces = true
		end))

		if not v.CanCollide then
			continue
		end

		local mass = v.Mass

		if mass == 0 and v.Massless then
			-- Massless parts are still buoyant for some reason /shrug
			v.Massless = false
			mass = v.Mass
			v.Massless = true
		end

		if mass ~= 0 then
			local physicalProperties = v.CustomPhysicalProperties
			local density = if physicalProperties then physicalProperties.Density else MaterialDensities[v.Material] or 1
			local volume = mass / density
			buoyancyForce += volume * gravity
			totalVolume += volume
		end
	end

	self._recalcMaid:Add(workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
		self._shouldRecalculateForces = true
	end))

	self._assemblyMass = assemblyMass
	self._dragMultiplier = totalVolume * self.DragForceMultiplier
	self._antigravForce = assemblyMass * gravity
	self._buoyancyForce = buoyancyForce
end




function SwimController:_setCharacter(char)
	if char == self.Character then
		return
	end

	self:_stopSwimming()

	self.Character = nil
	self.RootPart = nil
	self.Humanoid = nil

	if char then
		local rootPart = char:WaitForChild("HumanoidRootPart", 60)
		local humanoid = char:WaitForChild("Humanoid", 60)

		if rootPart and humanoid and char == Player.Character then
			self.Character = char
			self.RootPart = rootPart
			self.Humanoid = humanoid
		end
	end
end

function SwimController:_stopSwimming()
	if not self.Swimming then
		return
	end

	self.Swimming = false
	self._inSwimmingState = false
	self._nearSurface = false
	self._didJump = false

	self._maid:Cleanup()
	self._stateMaid:Cleanup()
	self._recalcMaid:Cleanup()
end

function SwimController:_startSwimming(zone)
	self.SurfaceY = zone.Position.y + zone.Size.y/2

	if self.Swimming then
		return
	end

	self.Swimming = true

	--[[ Insert VectorForce for emulating voxel-water buoyancy and drag ]]
	local attachment = Instance.new("Attachment", self.RootPart)
	attachment.Name = "SwimAttachment"

	local vectorForce = Instance.new("VectorForce", attachment)
	vectorForce.Attachment0 = attachment
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Force = Vector3.zero
	self._vectorForce = vectorForce

	self._maid:Add(vectorForce, attachment)
	--

	self._shouldRecalculateForces = true

	self._maid:Add(self.Humanoid.StateChanged:Connect(function()
		-- Humanoids can change cancollide silently when changing state
		RunService.Stepped:Wait()
		self._shouldRecalculateForces = true
	end))
	--
end


return SwimController