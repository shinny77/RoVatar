-- @ScriptType: ModuleScript
local ServerComm = {}
ServerComm.__index = ServerComm
local RemoteSignal = require(script.Parent.RemoteSignal)


----------->>>Other side code <<<<<-----------
function ServerComm.BindFunction(parent: Instance, tbl: {}, name: string): RemoteFunction
	
	local fn = tbl[name]
	assert(type(fn) == "function", "Value at index " .. name .. " must be a function; got " .. type(fn))
	
	local function bind(parent: Instance, name: string, func)
		local folder = parent.RF
		local rf = Instance.new("RemoteFunction")
		rf.Name = name
		local function OnServerInvoke(player, ...)
			return func(player, ...)
		end
		rf.OnServerInvoke = OnServerInvoke
		rf.Parent = folder
		return rf
	end
	
	return bind(parent, name, function(...) return fn(tbl, ...) end)
end


function ServerComm.new(parent, serviceName)
	assert(not parent:FindFirstChild(serviceName), "Parent already has another ServerComm bound to namespace " .. serviceName)
	local self = setmetatable({}, ServerComm)
	self._instancesFolder = Instance.new("Folder")
	self._instancesFolder.Name = serviceName
	self._instancesFolder.Parent = parent
	 
	local re = Instance.new("Folder")
	re.Name = "RE" --RemoteEvents
	re.Parent = self._instancesFolder

	local rf = Instance.new("Folder")
	rf.Name = "RF" --RemoteFunctions
	rf.Parent = self._instancesFolder
	
	return self
end

--For RemoteFunctions
function ServerComm:WrapMethod(tbl: {}, name: string): RemoteFunction
	return self.BindFunction(self._instancesFolder, tbl, name)
end

---RemoteEvents
function ServerComm:CreateSignal(name: string)
	local re = RemoteSignal.new(self._instancesFolder, name)
	return re
end


return ServerComm
