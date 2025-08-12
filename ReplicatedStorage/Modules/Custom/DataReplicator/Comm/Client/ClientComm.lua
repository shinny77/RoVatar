-- @ScriptType: ModuleScript
ClientComm = {}
ClientComm.__index = ClientComm

local ClientRemoteSignal = require(script.Parent.ClientRemoteSignal)


--RemoteFunctions
function ClientComm:GetFunctionBind(rf:RemoteFunction)
	assert(rf ~= nil, "Failed to find RemoteFunction: " .. rf.Name)
	return function(...)
		return rf:InvokeServer(...)
	end
end

--RemoteEvents
function ClientComm:GetSignalBind(re:RemoteEvent)
	assert(re ~= nil, "Failed to find RemoteEvent: " .. re.Name)
	return ClientRemoteSignal.new(re)
end

-----

function ClientComm.new(folder: Instance)
	assert((folder), "Parent can't be nil to setup the server module")
	assert(typeof(folder) == "Instance", "Parent must be of type Instance")
	
	assert(folder ~= nil, "Could not find namespace for ClientComm in parent: " .. folder.Name)
	local self = setmetatable({}, ClientComm)
	self._instancesFolder = folder
	
	return self:BuildObject()
end


function ClientComm:BuildObject()
	local obj = {}
	local rfFolder = self._instancesFolder:FindFirstChild("RF")
	local reFolder = self._instancesFolder:FindFirstChild("RE")

	--Setup RemoteFunctions
	if rfFolder then
		for _,rf in ipairs(rfFolder:GetChildren()) do
			if not rf:IsA("RemoteFunction") then continue end
			local f = self:GetFunctionBind(rf)
			obj[rf.Name] = function(_self, ...)
				return f(...)
			end
		end
	end

	--Setup RemoteEvents
	if reFolder then
		for _,re in ipairs(reFolder:GetChildren()) do
			if not re:IsA("RemoteEvent") then continue end
			obj[re.Name] = self:GetSignalBind(re)
		end
	end
	return obj
end





return ClientComm