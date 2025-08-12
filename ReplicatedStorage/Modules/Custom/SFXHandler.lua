-- @ScriptType: ModuleScript
local SoundService = game:GetService("SoundService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local RnS = game:GetService("RunService")

local SFXHandler = {}

local SFXs = require(script.SFXs) --The data of all SFX clips.

local RemoteHolder = RS:WaitForChild("Events").Remote
local CastSoundSignal :RemoteEvent = nil
--local Global_SFX_Sound = SoundService.SFXGroup.Sound
--local Global_MUSIC_Sound = SoundService.MusicGroup.Sound



------------------------>>>>> ******* SFX ******<<<<<------------------------
--[[
Play the SFX clip under the given parent instance. It would work like 3D spatial sound.
]]
function SFXHandler:PlayAlong(sfxType, parent:Instance, forceReplay:boolean?, tween:boolean?)
	--print("PlayAlong:", sfxType, parent, forceReplay, tween)
	if(parent:IsA("Model")) then
		local p = parent
		parent = parent:FindFirstChildOfClass("BasePart") or parent:FindFirstChildOfClass("Part") --Switch the parent (Model) to parent (BasePart)

		--If parent don't contains any "BasePart" child then revert back the original parent 
		if(not parent) then 
			print("[SFXHandler]", p, "parent does not contain any BasePart/Part child!")
			parent = p
		end
	end

	local sound = parent:FindFirstChildOfClass("Sound") or Instance.new("Sound", parent)

	local sfxData :SFXs.Type = SFXs[sfxType]
	if(not sfxData) then
		warn("Given sfxType not found in data. sfxType:", sfxType, " **Parent:", parent)
		return nil
	end

	--If given sfxType is already playing in target Sound then return
	if(not forceReplay and sound.Name == sfxType and sound.Looped) then
		return
	end

	sound:Stop()
	sound.Name = sfxType
	sound.SoundId = sfxData.ID
	sound.Looped = sfxData.Loop or false
	sound.TimePosition = sfxData.TimePosition or 0
	sound.Volume = sfxData.Volume or 1
	sound.PlaybackSpeed = sfxData.PlaybackSpeed or 1

	if(sfxData.RollEmitter) then
		sound.RollOffMode = sfxData.RollEmitter.RollOffMode or Enum.RollOffMode.Inverse
		sound.RollOffMaxDistance = sfxData.RollEmitter.RollMaxDist or 1000
		sound.RollOffMinDistance = sfxData.RollEmitter.RollMinDist or 10
	end

	if(sfxData.Effects) then
		for class, props in pairs(sfxData.Effects) do
			local v = Instance.new(class, sound)
			--Fill properties
			for prop, val in pairs(props) do
				v[prop] = val
			end
		end
	end
	
	local s_grp = sfxData.SoundGroup and SoundService[sfxData.SoundGroup] or SoundService.SFXGroup
	sound.SoundGroup = s_grp

	if tween then
		local targetSound = sound.Volume
		sound.Volume = 0
		TS:Create(sound, TweenInfo.new(.2), {Volume = targetSound}):Play()
	end

	sound:Play()
	--print("[PlayAlong] sfx played :", sfxData)
	return sound
end

--[[
Play the SFX clip as individual (will not be affected by any other SFX).
If parent is passed then It will work is 3D spatial sound ELSE it will be linear (Hearable to all players).
]]
function SFXHandler:PlayIndividual(sfxType)
	local sfxData :SFXs.Type = SFXs[sfxType]
	if(not sfxData) then
		warn("Given sfxType not found in data. sfxType:", sfxType)
		return nil
	end

	local s_grp = sfxData.SoundGroup and SoundService[sfxData.SoundGroup] or SoundService.SFXGroup

	local sound = Instance.new("Sound", s_grp)
	sound.Name = sfxData.Name
	sound.SoundId = sfxData.ID
	sound.Looped = sfxData.Loop
	sound.Volume = sfxData.Volume or 1
	sound.TimePosition = sfxData.TimePosition or 0
	sound.PlaybackSpeed = sfxData.PlaybackSpeed or 1

	sound.SoundGroup = s_grp

	if(sfxData.RollEmitter) then
		sound.RollOffMode = sfxData.RollEmitter.RollOffMode or Enum.RollOffMode.Inverse
		sound.RollOffMaxDistance = sfxData.RollEmitter.RollMaxDist or 1000
		sound.RollOffMinDistance = sfxData.RollEmitter.RollMinDist or 10
	end

	if(sfxData.Effects) then
		for class, props in pairs(sfxData.Effects) do
			local v = Instance.new(class, sound)
			--Fill properties
			for prop, val in pairs(props) do
				v[prop] = val
			end
		end
	end

	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
		sound = nil
	end)

	return sound
end

--[[
Play the SFX clip as loud/announcement. It will be heared by all player irrespective of distance (Linear).
]]
function SFXHandler:Play(sfxType, playIndividual: boolean?)
	local sfxData :SFXs.Type = SFXs[sfxType]
	if(not sfxData) then
		warn("Given sfxType not found in data. sfxType:", sfxType)
		return nil
	end

	local s_grp = sfxData.SoundGroup and SoundService[sfxData.SoundGroup] or SoundService.SFXGroup

	if(playIndividual) then
		local sound = Instance.new("Sound", s_grp)
		sound.Name = sfxData.Name
		sound.SoundId = sfxData.ID
		sound.SoundGroup = s_grp
		sound.Looped = sfxData.Loop
		sound.Volume = sfxData.Volume or 1
		sound.PlaybackSpeed = sfxData.PlaybackSpeed or 1
		sound.TimePosition = sfxData.TimePosition or 0

		if(sfxData.RollEmitter) then
			sound.RollOffMode = sfxData.RollEmitter.RollOffMode or Enum.RollOffMode.Inverse
			sound.RollOffMaxDistance = sfxData.RollEmitter.RollMaxDist or 1000
			sound.RollOffMinDistance = sfxData.RollEmitter.RollMinDist or 10
		end

		if(sfxData.Effects) then
			for class, props in pairs(sfxData.Effects) do
				local v = Instance.new(class, sound)
				--Fill properties
				for prop, val in pairs(props) do
					v[prop] = val
				end
			end
		end

		sound:Play()
		sound.Ended:Once(function()
			sound:Destroy()
			sound = nil
		end)
		return sound
	end


	local SFX_Sound = s_grp.Sound
	SFX_Sound.SoundId = sfxData.ID
	SFX_Sound.Looped = sfxData.Loop
	SFX_Sound.Volume = sfxData.Volume or 1
	SFX_Sound.PlaybackSpeed = sfxData.PlaybackSpeed or 1
	SFX_Sound.TimePosition = sfxData.TimePosition or 0
	SFX_Sound.SoundGroup = s_grp

	if(sfxData.RollEmitter) then
		SFX_Sound.RollOffMode = sfxData.RollEmitter.RollOffMode or Enum.RollOffMode.Inverse
		SFX_Sound.RollOffMaxDistance = sfxData.RollEmitter.RollMaxDist or 1000
		SFX_Sound.RollOffMinDistance = sfxData.RollEmitter.RollMinDist or 10
	end

	if(sfxData.Effects) then
		for class, props in pairs(sfxData.Effects) do
			local v = Instance.new(class, SFX_Sound)
			--Fill properties
			for prop, val in pairs(props) do
				v[prop] = val
			end
		end
	end

	SFX_Sound:Play()
	return SFX_Sound
end

--[[
Stops the given sfxType if it was playing in the Global_SFX_Sound.
]]
function SFXHandler:Stop(sfxType, parent: Instance)
	local sfxData :SFXs.Type = SFXs[sfxType]
	if(not sfxData) then
		warn("Given sfxType not found in data. sfxType:", sfxType)
		return nil
	end
	
	--print("Stop SFX:", sfxType, parent)
	if(parent) then
		local sound = parent:FindFirstChild(sfxType)

		if(sound and sfxData.ID == sound.SoundId) then
			sound:Stop()
			sound:Destroy()
			sound = nil
		end

	else
		if(sfxData.SoundGroup) then
			local grp = SoundService:FindFirstChild(sfxData.SoundGroup)
			if(grp) then
				local sound = grp:FindFirstChild(sfxType)
				if(sound and sound.SoundId == sfxData.ID) then
					sound:Stop()
					sound:Destroy()
				else
					warn("Sound not found:", sfxType, sfxData)
				end
			else
				warn("Sound group not found:", sfxData.SoundGroup, sfxData)
			end
		else
			local sound = SoundService.SFXGroup:FindFirstChild(sfxType)
			if(sound and sound.SoundId == sfxData.ID) then
				sound:Stop()
				sound:Destroy()
			end
		end
	end
end


------------------------>>>>> ******* MUSIC ******<<<<<------------------------

--[[
Play the Music clip as loud/announcement. It will be heared by all player irrespective of distance (Linear).
]]
function SFXHandler:PlayMusic(musicType, playIndividual: boolean?)
	local sfxData :SFXs.Type = SFXs[musicType]

	if(not sfxData) then
		warn("Given musicType not found in data. musicType:", musicType)
		return nil
	end

	local s_grp = sfxData.SoundGroup and SoundService[sfxData.SoundGroup] or SoundService.MusicGroup

	if(playIndividual) then
		local sound = Instance.new("Sound", s_grp)
		sound.Name = sfxData.Name
		sound.SoundId = sfxData.ID
		sound.SoundGroup = s_grp or SoundService.MusicGroup
		sound.Looped = sfxData.Loop
		sound.Volume = sfxData.Volume or 1
		sound.PlaybackSpeed = sfxData.PlaybackSpeed or 1
		sound.TimePosition = sfxData.TimePosition or 0

		if(sfxData.RollEmitter) then
			sound.RollOffMode = sfxData.RollEmitter.RollOffMode or Enum.RollOffMode.Inverse
			sound.RollOffMaxDistance = sfxData.RollEmitter.RollMaxDist or 1000
			sound.RollOffMinDistance = sfxData.RollEmitter.RollMinDist or 10
		end

		if(sfxData.Effects) then
			for class, props in pairs(sfxData.Effects) do
				local v = Instance.new(class, sound)
				--Fill properties
				for prop, val in pairs(props) do
					v[prop] = val
				end
			end
		end

		sound:Play()
		sound.Ended:Once(function()
			sound:Destroy()
			sound = nil
		end)
		return sound
	end

	local MUSIC_Sound = s_grp.Sound

	MUSIC_Sound.SoundId = sfxData.ID
	MUSIC_Sound.Looped = sfxData.Loop
	MUSIC_Sound.Volume = sfxData.Volume or 1
	MUSIC_Sound.PlaybackSpeed = sfxData.PlaybackSpeed or 1
	MUSIC_Sound.TimePosition = sfxData.TimePosition or 0

	if(sfxData.RollEmitter) then
		MUSIC_Sound.RollOffMode = sfxData.RollEmitter.RollOffMode or Enum.RollOffMode.Inverse
		MUSIC_Sound.RollOffMaxDistance = sfxData.RollEmitter.RollMaxDist or 1000
		MUSIC_Sound.RollOffMinDistance = sfxData.RollEmitter.RollMinDist or 10
	end

	if(sfxData.Effects) then
		for class, props in pairs(sfxData.Effects) do
			local v = Instance.new(class, MUSIC_Sound)
			--Fill properties
			for prop, val in pairs(props) do
				v[prop] = val
			end
		end
	end

	MUSIC_Sound:Play()
	return MUSIC_Sound
end

--[[
Stops the given musicType if it was playing in the Global_MUSIC_Sound.
]]
function SFXHandler:StopMusic(musicType, wasIndividual: boolean)
	local sfxData :SFXs.Type = SFXs[musicType]
	if(not sfxData) then
		warn("Given sfxType not found in data. sfxType:", musicType)
		return nil
	end

	if(wasIndividual) then
		local sound = SoundService.MusicGroup:FindFirstChild(musicType)

		if(sound and sfxData.ID == sound.SoundId) then
			sound:Stop()
			sound:Destroy()
			sound = nil
		end

	else
		local s_grp = sfxData.SoundGroup and SoundService[sfxData.SoundGroup]
		local SFX_Sound = s_grp or SoundService.MusicGroup

		if(sfxData.ID == SFX_Sound.Sound.SoundId) then
			SFX_Sound.Sound:Stop()
		end
	end


end







if(RnS:IsServer()) then
	CastSoundSignal = RemoteHolder:FindFirstChild("CastSound") or Instance.new("RemoteEvent", RemoteHolder)
	CastSoundSignal.Name = "CastSound"
	
	
	SFXHandler.Client = {
		PlayAlong = function(plr, ...)
			--print("PlayAlong FIre on client:", plr, ...)
			CastSoundSignal:FireClient(plr, "PlayAlong", ...)
		end,
		PlayIndividual = function(plr, ...)
			CastSoundSignal:FireClient(plr, "PlayIndividual", ...)
		end,
		Play = function(plr, ...)
			CastSoundSignal:FireClient(plr, "Play", ...)
		end,
		Stop = function(plr, ...)
			CastSoundSignal:FireClient(plr, "Stop", ...)
		end,
		
		PlayMusic = function(plr, ...)
			CastSoundSignal:FireClient(plr, "PlayMusic", ...)
		end,
		StopMusic = function(plr, ...)
			CastSoundSignal:FireClient(plr, "StopMusic", ...)
		end,
	}
	
	CastSoundSignal.OnServerEvent:Connect(function(plr, fName, ...)
		local fn = SFXHandler[fName]
		if(fn) then
			fn(SFXHandler, ...)
		end
	end)
	
elseif(RnS:IsClient()) then
	CastSoundSignal = RemoteHolder:FindFirstChild("CastSound")

	SFXHandler.Server = {
		PlayAlong = function(...)
			CastSoundSignal:FireServer("PlayAlong", ...)
		end,
		PlayIndividual = function(...)
			CastSoundSignal:FireServer("PlayIndividual", ...)
		end,
		Play = function(...)
			CastSoundSignal:FireServer("Play", ...)
		end,
		Stop = function(...)
			CastSoundSignal:FireServer("Stop", ...)
		end,

		PlayMusic = function(...)
			CastSoundSignal:FireServer("PlayMusic", ...)
		end,
		StopMusic = function(...)
			CastSoundSignal:FireServer("StopMusic", ...)
		end,
	}

	CastSoundSignal.OnClientEvent:Connect(function(fName:string, ...)
		local fn = SFXHandler[fName]
		if(fn) then
			fn(SFXHandler, ...)
		end
	end)
end


return SFXHandler