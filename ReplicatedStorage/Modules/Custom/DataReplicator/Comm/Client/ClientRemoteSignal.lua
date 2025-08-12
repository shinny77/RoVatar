-- @ScriptType: ModuleScript
local ClientRemoteSignal = {}
ClientRemoteSignal.__index = ClientRemoteSignal

function ClientRemoteSignal.new(re: RemoteEvent)
	local self = setmetatable({}, ClientRemoteSignal)
	self._re = re
	
	return self
end

function ClientRemoteSignal:Connect(fn: (...any) -> ())
	self._reConn = self._re.OnClientEvent:Connect(fn)
	return self._reConn
end

function ClientRemoteSignal:Fire(...: any)
	self._re:FireServer(...)
end

function ClientRemoteSignal:Destroy()
	if self._reConn then
		self._reConn:Disconnect()
	end
end

return ClientRemoteSignal
