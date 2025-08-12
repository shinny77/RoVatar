-- @ScriptType: ModuleScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXHandler = {}

for _, Module in ipairs(script:GetChildren()) do
	VFXHandler[Module.Name] = require(Module)
end

local remoteEvent = ReplicatedStorage.Events.Remote.CastEffect


function VFXHandler:PlayOnServer(...)
	remoteEvent:FireServer(...)
end

function VFXHandler:PlayOnClient(plr, ...)
	remoteEvent:FireClient(plr, ...)
end



--If Client side
if game:GetService("RunService"):IsClient() then

	function VFXHandler:PlayEffect(plr, typ, ...)
		if VFXHandler[typ] then
			VFXHandler[typ](plr, ...)
		else
			print(typ, "Effect Type not found.")
		end
	end

	remoteEvent.OnClientEvent:Connect(function(typ, ...)
		VFXHandler:PlayEffect(game.Players.LocalPlayer, typ, ...)
	end)
	
else --Else Server side

	function VFXHandler:PlayEffect(plr, typ, ...)
		--print(plr, "Playing effect:",typ)
		if VFXHandler[typ] then
			VFXHandler[typ](plr, ...)
		else
			print(typ, "Effect Type not found.")
		end
	end

	remoteEvent.OnServerEvent:Connect(function(plr, typ, ...)
		VFXHandler:PlayEffect(plr, typ, ...)
	end)
end



return VFXHandler