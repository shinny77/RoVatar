-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local CharacterAnims = RS.Assets.Animations.Characters


local Constants = require(script.Parent.Constants)
local CustomTypes = require(script.Parent.CustomTypes)


--[[
This "class" based script handles the animations on individual human character.
]]
local Animator = {}
Animator.__index = Animator






-------------------------- Setup  ---------------------------------

--Setup the new Animator class for new Human Character Model.
function Animator.new(char:Model, characterType:string)
	local component = {}
	component.__index = component
	component.__tostring = function()
		return "Component<" .. char.Name .. "> Animator :)"
	end

	component.isReady = false

	component.Instance = char
	component.Root = char.PrimaryPart
	component.Humanoid = char.Humanoid
	component.AnimatorC = char.Humanoid:FindFirstChild("Animator") or Instance.new("Animator", char.Humanoid) --Roblox "Animator" object inside the character.
	component.LoadedTracks = {} --key = "Anim Name", value = AnimationTrack
	component.LoadedAnims = {} --Array of successfull loaded animations.

	component.DirectLoadedTracks = {} --key = "Anim Name", value = AnimationTrack
	component.DirectLoadedAnims = {}

	setmetatable(component, Animator)
	component:LoadAnimations(CharacterAnims[Constants.CharacterTypes.Default])
	component:LoadAnimations(CharacterAnims[characterType or Constants.CharacterTypes.Default])

	return component
end

--#Loads and stores the animations of the given Character.
function Animator:LoadAnimations(parent:Folder)
	--"Animations" folder must be present under the character model.
	for i, anim in pairs(parent:GetChildren()) do
		if(anim:IsA("Animation")) then
			self:LoadAnim(anim)
		end
	end

	self.isReady = true
end

function Animator:LoadAnim(anim:Animation)
	local s, r = pcall(function()
		self.LoadedTracks[anim.Name] = self.AnimatorC:LoadAnimation(anim)
	end)

	if(not s) then
		warn("loading animation problem: ", r)
	else
		if(not table.find(self.LoadedAnims, anim.Name)) then
			table.insert(self.LoadedAnims, anim.Name)
		end
	end
end


-------------------------- Match runtime Play / Stop  ---------------------------------

--#Plays the given animation on Instance with provided attributes.
function Animator:Play(animData :CustomTypes.AnimationDataType)
	if(not self.isReady) then
		warn(self.Instance,"Animator is not ready!!")
		return
	end
	if(not table.find(self.LoadedAnims, (animData.AnimState or animData.Anim.Name))) then
		warn("Given animation is not present in the target NPC model.")
		print(self.Instance, " NPC model, animData:",animData)
		return
	end

	local AnimToPlay :AnimationTrack = self.LoadedTracks[animData.AnimState or animData.Anim.Name]
	local alreadyPlaying = AnimToPlay.IsPlaying

	if AnimToPlay and not alreadyPlaying then

		--self:StopAll()

		AnimToPlay.Priority = animData.Priority or Enum.AnimationPriority.Action

		AnimToPlay:Play()

		local eventsConns = {}
		if(animData.EventsName ~= nil and animData.EventCallback) then
			for i, eventN in pairs(animData.EventsName) do
				eventsConns[eventN] = AnimToPlay:GetMarkerReachedSignal(eventN):Connect(function(param)

					animData.EventCallback(eventN, param)
				end)
			end
		end

		if(AnimToPlay.Looped == false) then
			local conn = nil
			conn = AnimToPlay.Stopped:Connect(function()
				conn:Disconnect()
				for i, conns in pairs(eventsConns) do
					conns:Disconnect()
				end
				if(animData.onComplete) then
					animData.onComplete()
				end
			end)
		end
	end
	
	return AnimToPlay, alreadyPlaying
end

--#Plays the Animation with assets Id
function Animator:PlayDirect(animData :CustomTypes.ItemInfoType, moveDist:number)

	if(not table.find(self.DirectLoadedAnims, animData.Name)) then

		local animation = Instance.new('Animation')
		animation.Name = animData.Name
		animation.AnimationId = animData.AssetId

		local s, r = pcall(function()
			self.DirectLoadedTracks[animData.Name] = self.AnimatorC:LoadAnimation(animation)
		end)

		if(not s) then
			warn("loading animation problem: ", r)
		else
			table.insert(self.DirectLoadedAnims, animData.Name)
		end

	end

	local AnimToPlay :AnimationTrack = self.DirectLoadedTracks[animData.Name]
	assert(AnimToPlay, "Not found animation to play..")

	if AnimToPlay and not AnimToPlay.IsPlaying then
		self:StopAllDirectAnimations()

		if(moveDist) then
			--print('Play anim with moveDist:', self.Root.CFrame.LookVector)

			local dir = (self.Root.CFrame.LookVector).Unit

			local walkPoint = self.Root.CFrame.Position + (dir * moveDist)

			--print("Walkpint",walkPoint)
			self.Humanoid:MoveTo(walkPoint)
			--self.Humanoid.MoveToFinished:Wait()
		end


		AnimToPlay.Priority = Enum.AnimationPriority.Action
		AnimToPlay:Play()
	end

end

--#Stops the all animation that are played directly.
function Animator:StopAllDirectAnimations()

	for _, animationTrack in pairs(self.DirectLoadedTracks) do
		if animationTrack ~= nil then
			animationTrack:Stop()
		end
	end

end

--#Stops the given animation on the Instance.
function Animator:Stop(animData :CustomTypes.AnimationDataType)

	local Anim = self.LoadedTracks[(animData.AnimState or animData.Anim.Name)]
	--print(Anim)

	if Anim then
		--print("Stoppomjbcjkbc ")
		Anim:Stop()
	end

end

--# Stops the all custom animations currently playing on the Instance.
function Animator:StopAll()
	for _, animationTrack in pairs(self.LoadedTracks) do
		if animationTrack ~= nil then
			animationTrack:Stop()
		end
	end
end

--# If animation was not playing then Play it else Stop it.
function Animator:ToggleAnimation(animData:CustomTypes.AnimationDataType)
	local track, alreadyPlaying = self:Play(animData)
	if(alreadyPlaying) then
		self:Stop(animData)
	end
	return (not alreadyPlaying)
end

--# Toggles the given "Animation" on character.
function Animator:ToggleAnim(anim:Animation)
	if(not anim.AnimationId) then
		return
	end
	
	if(not table.find(self.LoadedAnims, anim.Name)) then
		self:LoadAnim(anim)
	end
	
	local animData :CustomTypes.AnimationDataType = {}
	animData.Anim = anim
	return self:ToggleAnimation(animData)
end

-------------------------- Match runtime Play / Stop  ---------------------------------

function Animator:GetTrack(animName :string)
	if(self.LoadedTracks[animName]) then
		return self.LoadedTracks[animName]
		
	elseif(self.DirectLoadedTracks[animName]) then
		return self.DirectLoadedTracks[animName]
	end
	
	return nil
end




function Animator:Destroy()
	warn("[Animator] Destorying for instance:",self.Instance)
	self:StopAll()

	self.Instance = nil
	self.isReady = false
end

return Animator