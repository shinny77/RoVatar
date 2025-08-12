-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local TS = game:GetService("TeleportService")

local Signal = require(RS.Packages.Signal)
local Knit = require(RS.Packages.Knit)

local Constants = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)
local CF = require(RS.Modules.Custom.CommonFunctions)

local MultiplaceHandlerService = Knit.CreateService {
	Name = "MultiplaceHandlerService",
	
	Client = {
		Teleport = Knit.CreateSignal(),
	}
}

-- Workspace Assets Ref 
local SC_Items = workspace:WaitForChild("Scripted_Items")
local NPCs = SC_Items:WaitForChild("NPCs")

--- Things handled:
--[[
1. Guru Pathik placement and stop walking,
2. Spawn player to kioshi island only,
3. Disable cantouch of all the map triggers,
4. Place Only one NPC In Kioshi island,
5. Arrangements in Guru Pathik(Quest Guy), QuestController, QuestGui.
]]

local function SetupSceneState()
	-- Destroy NPCs and QuestGuys
	do
		if _G.IsHub then
			NPCs.Attacking.Tutorial:Destroy()
			NPCs.QuestGuys.Tutorial:Destroy()
		else
			NPCs.Attacking.Hub:Destroy()
			NPCs.QuestGuys.Hub:Destroy()
		end
	end
	
	-- Stop CanTouch for all maps triggers
	do
		-- Handled in UpdateMap Client Controller
	end
	
	
	
end

---------------------->>>>>>>>>>>>>>>
local function TeleportRequest(_player, _placeId, _reserveServer)
	if _reserveServer then
		local accessCode = TS:ReserveServer(_placeId)
		TS:TeleportToPrivateServer(_placeId, accessCode, {_player})
	else
		TS:Teleport(_placeId, _player)
	end
end

--------------------------------------------->>>>>>>>>>>> Public Methods <<<<<<<<<<<<----------------------------------------------

function MultiplaceHandlerService:KnitInit()
	self.Client.Teleport:Connect(TeleportRequest)
end

function MultiplaceHandlerService:KnitStart()
	SetupSceneState()
end

return MultiplaceHandlerService