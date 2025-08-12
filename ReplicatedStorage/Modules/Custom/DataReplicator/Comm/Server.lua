-- @ScriptType: ModuleScript
local Server = {}
local Common = require(script.Parent.Common)
local Signal = require(script.Parent.Signal)
local ServerComm = require(script.ServerComm)

------>>>> Ref
local ServicesF : Folder = nil


------->>>> Variables
Server.Started = false
modulesName = {}
services = {}

 
-------->>>>>> Type Declarations <<<<<-----
type Service = {
	Name: string,
	[any]: any,
}

type ServiceDef = {
	Name: string,
	[any]: any,
}


--------------------->>>>>>>>> Private Methods <<<<<<<<<<---------------------


--------------------->>>>>>>>> Public Methods <<<<<<<<<<---------------------


------------------<<<<<<< Events / Functions >>>>>>>>>-----------
-->>Create requested Events (Bindable)
function Server.CreateSignal()
	return Signal.new()
end

-->>Create requested Events (Remote)
function Server.CreateEvent(parent, name)
	local RemoteSignal = {}
	RemoteSignal.__index = RemoteSignal


	function RemoteSignal.new(parent: Instance, name: string)
		local self = setmetatable({}, RemoteSignal)
		self._re = Instance.new("RemoteEvent", parent)
		self._re.Name = name

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

	
	return RemoteSignal.new(parent, name)
end

function Server.BindFunction(parent: Instance, funcName: string, tbl): RemoteFunction

	assert(type(tbl.ClientSide[funcName]) == "function", "Value at index " .. funcName .. " must be a function; got " .. type(tbl.ClientSide[funcName]))
	
	local fn = tbl.ClientSide[funcName]
	local function bind(parent: Instance, name: string, func)
		local rf = Instance.new("RemoteFunction", parent)
		rf.Name = name
		local function OnServerInvoke(player, ...)
			return func(player, ...)
		end
		rf.OnServerInvoke = OnServerInvoke
		return rf
	end

	return bind(parent, funcName, function(...) return fn(tbl, ...) end)
end



return Server
