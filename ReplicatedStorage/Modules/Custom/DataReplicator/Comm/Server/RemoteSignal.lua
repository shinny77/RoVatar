-- @ScriptType: ModuleScript
local RemoteSignal = {}
RemoteSignal.__index = RemoteSignal


function RemoteSignal.new(parent: Instance, name: string)
	local self = setmetatable({}, RemoteSignal)
	self._re = Instance.new("RemoteEvent")
	self._re.Name = name
	self._re.Parent = parent.RE
	
	return self
end

function RemoteSignal:Connect(fn)
	return self._re.OnServerEvent:Connect(fn)
end

function RemoteSignal:Fire(player: Player, ...: any)
	self._re:FireClient(player, ...)
end

function RemoteSignal:FireAll(...: any)
	self._re:FireAllClients(...)
end

function RemoteSignal:Destroy()
	self._re:Destroy()
end


return RemoteSignal
