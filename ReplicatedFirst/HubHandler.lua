-- @ScriptType: Script
local function getServerType()
	if game.PrivateServerId ~= "" then
		if game.PrivateServerOwnerId ~= 0 then
			return "VIPServer"
		else
			return "ReservedServer"
		end
	else
		return "StandardServer"
	end
end

_G.IsHub = getServerType() ~= "ReservedServer"

workspace:WaitForChild("IsHub").Value = _G.IsHub 