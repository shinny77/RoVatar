-- @ScriptType: ModuleScript
if game:GetService("RunService"):IsServer() then
	return require(script.DataServer)
else
	local DataServer = script:FindFirstChild("DataServer")
	if DataServer then
		DataServer:Destroy()
	end
	return require(script.DataClient)
end

