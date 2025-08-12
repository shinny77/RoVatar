-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Knit = require(RS.Packages.Knit)

local DataReplicator = require(RS.Modules.Custom.DataReplicator)



---------> Other scripts references
local DevService = Knit.CreateService {
	Name = "DevService",
	Client = {
		UpdateLiveDevMode = Knit.CreateSignal(),
		ExecuteCode = Knit.CreateSignal(),
	}
}

----------------------------------------------------------->  Private Methods And Fields  <------------------------------------------------------


function UpdatePlayerLiveDevMode(plr:Player, devMode:boolean)
	if(devMode ~= nil) then
		plr:SetAttribute("LiveDevMode", devMode)
		
		--SSS.LoadStringEnabled = devMode
	end
end

function CodeExecuteRequest(plr, code)
	local response = loadstring(code)()
end

---------------------------------------------------------------->  Public Methods  <------------------------------------------------------

local logsOn = false
function DevService.Client:ToggleServerLogs()
	logsOn = not logsOn

	return logsOn
end

function DevService.Client:ResetPlayerInfoClick(player, playerId)
	print("DevScript--> ResetPlayerInfo clicked:", playerId)
	_G.PlayerDataStore:RemovePlrData(player, playerId)
	if(not playerId) then
		_G.PlayerDataStore:Save(player)
	end
	
	--_G.QuestStore:RemovePlrData(player, playerId)
	--if not playerId then
	--	_G.QuestStore:Save(player)
	--end
end





function DevService:KnitInit()
	self.Client.UpdateLiveDevMode:Connect(UpdatePlayerLiveDevMode)
	self.Client.ExecuteCode:Connect(CodeExecuteRequest)
end

function DevService:KnitStart()
	print("DevScript Knit Started......")
end

return DevService