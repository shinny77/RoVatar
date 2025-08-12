-- @ScriptType: ModuleScript
local Client = {}

local Signal = require(script.Parent.Signal)

local Common = require(script.Parent.Common)

local ClientComm = require(script.ClientComm)


------------>>> Variables

--------------------->>>>>>>>> Public Methods <<<<<<<<<<---------------------

function Client.BuildServerModule(parent:Instance)
	return ClientComm.new(parent)
end


-->>Create requested Events (Remote/Bindable)
function Client.CreateSignal()
	return Signal.new()
end



return Client
