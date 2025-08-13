-- @ScriptType: ModuleScript
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Signal = require(RS.Packages.Signal)
local Knit = require(RS.Packages.Knit)

local CF = require(RS.Modules.Custom.CommonFunctions)
local Constants = require(RS.Modules.Custom.Constants)
local VFXHandler = require(RS.Modules.Custom.VFXHandler)
local SFXHandler = require(RS.Modules.Custom.SFXHandler)
local CustomTypes = require(RS.Modules.Custom.CustomTypes)
local DataReplicator = require(RS.Modules.Custom.DataReplicator)
local NotificationData = require(RS.Modules.Custom.NotificationData)

local Costs = require(RS.Modules.Custom.Costs)

local DEBUG = false

---Other scripts
local IAPService
local CharacterService
local QuestDataService
local NotificationService

-------------- Data Store ##
_G.PlayerDataStore = DataReplicator.SetupStore(Constants.DataStores.PlayerData, true, CF:GetPlayerDataModel())
-------------- Data Store ##

---
local PlayerDataService = Knit.CreateService {
	Name = "PlayerDataService",
	Client = {
	}
}

----Global Variables


--------------- Helper ------------------
local function val(typ:string, parent:Instance, name:string, default:any)
	if(parent:FindFirstChild(name)) then
		return
	end

	local v = Instance.new(typ, parent)
	v.Name = name
	if(typ ~= "Folder") then
		v.Value = default
	end
	
	return v
end

local function getTableLength(t)
	local l = 0
	for i,v in pairs(t) do
		l += 1
	end
	return l
end

function CheckDataStoreVersion(playerData :CustomTypes.PlayerDataModel)

	local activeDataStoreVersion = CF:GetActiveDataStoreVersion()
	if(playerData.LoginData.MyDataStoreVersion == nil or 
		playerData.LoginData.MyDataStoreVersion.GameDataStoreVersion ~= activeDataStoreVersion.GameDataStoreVersion) then

		playerData = CF:CheckAndUpdatePlayerData(playerData)
		
		if DEBUG then
			print(playerData.LoginData.MyDataStoreVersion.GameDataStoreVersion,"checking active:",activeDataStoreVersion)
		end
	end
	if DEBUG then
		print("Active Data :", playerData, activeDataStoreVersion, CF:GetActiveDataStoreVersion())
	end
	playerData.LoginData.MyDataStoreVersion = CF:GetActiveDataStoreVersion()
	
	return playerData
end

--------------- Helper ------------------

function onPlayerAdded(player:Player)
	
	--Check joining and data
	_G.PlayerDataStore:GetData(player, function(playerData:CustomTypes.PlayerDataModel, isFirstTime:boolean)
		if (isFirstTime) or (playerData.LoginData == nil) then
			--First time user :)
			
			playerData = CF:GetPlayerDataModel()
			
			CF:UpdateInventory(playerData, Constants.GameInventory.Maps.KioshiIsland, true)
			--CF:CreateNewSlot(playerData)
		else
			--not first time
		end

		-- Data Store Version
		playerData = CheckDataStoreVersion(playerData)
		-- Data Store Version

		-- Quest Data
		QuestDataService:OnPlayerAdded(player, playerData)
		-- Quest Data
		
		--Karna: Task_Id :1086
		playerData.AllProfiles[playerData.ActiveProfile].Data.CombatStats.Stamina = 100
		playerData.AllProfiles[playerData.ActiveProfile].Data.CombatStats.Strength = 100
		-----

		-- Profile Data
		CF:RefreshCombatControls(player, playerData.AllProfiles[playerData.ActiveProfile].Data.CombatStats)
		
		player.Progression.EXP.Value = playerData.AllProfiles[playerData.ActiveProfile].XP
		player.Progression.LEVEL.Value = playerData.AllProfiles[playerData.ActiveProfile].PlayerLevel
		-- Profile Data
		
		local GamePurchases = IAPService:RefreshPurchaseDataUpdates(player, playerData)
		playerData.GamePurchases = GamePurchases
		
		-- Refresh Inventory for Gamepass Items
		CF:UpdateInventory(playerData, Constants.GameInventory.Transports.BlueGlider, 
			playerData.GamePurchases.Passes[Constants.GameInventory.Transports.BlueGlider.Id])
		
		playerData.LoginData.LastLogin = workspace.ServerTime.Value --workspace:GetServerTimeNow()
		
		_G.PlayerDataStore:UpdateData(player, playerData)
	end)
	
	--Level upgrade event
	_G.PlayerDataStore:ListenSpecChange(player, "AllProfiles", function(newVal, oldVal, FullData:CustomTypes.PlayerDataModel)
		local oldActiveProfile :CustomTypes.ProfileSlotDataType = oldVal[FullData.ActiveProfile]
		local newActiveProfile :CustomTypes.ProfileSlotDataType = newVal[FullData.ActiveProfile]
		
		if (oldActiveProfile) and (newActiveProfile.PlayerLevel == oldActiveProfile.PlayerLevel) then
			return
		end
		
		if newActiveProfile.PlayerLevel ~= player.Progression.LEVEL.Value then
			VFXHandler:PlayEffect(player, Constants.VFXs.LevelUp)
		end
		
		do --check unlocked abilities
			local Level = newActiveProfile.PlayerLevel
			player.Progression.LEVEL.Value = Level
		end
	end)
	
	--Update Gamepass Items
	_G.PlayerDataStore:ListenSpecChange(player, "GamePurchases.Passes", function(newData)

		if newData then

			CharacterService:OnGamePassStatusChange(player, newData)
		end
	end)
	
	local OldEXP = player.Progression.EXP.Value
	player.Progression.EXP:GetPropertyChangedSignal("Value"):Connect(function()
		local CurrentEXP = player.Progression.EXP
		if OldEXP < CurrentEXP.Value then
			local XPTOADD = CurrentEXP.Value - OldEXP

			_G.PlayerDataStore:GetData(player, function(playerData:CustomTypes.PlayerDataModel)
				CF:UpdateXpInPlayerData(playerData, XPTOADD)
				local activeProfile = CF:GetPlayerActiveProfile(playerData)
				CurrentEXP.Value = activeProfile.XP
				player.Progression.LEVEL.Value = activeProfile.PlayerLevel
				
				_G.PlayerDataStore:UpdateData(player, playerData)
			end)
			OldEXP = CurrentEXP.Value
		else
			
		end
	end)
end

function onPlayerRemoved(player)
	
end

-------------------------------------------- Public Methods -----------------------------

---->>>... update combat stats
function PlayerDataService:UpdateDeath(Player : Player)
	_G.PlayerDataStore:GetData(Player, function(playerData :CT.PlayerDataModel)
		if playerData then
			local activeProfile = CF:GetPlayerActiveProfile(playerData)

			local Deaths = activeProfile.Data.PlayerStats.Deaths
			local U = {
				["Data.PlayerStats.Deaths"] = Deaths + 1
			}
			CF:UpdateActiveProfile(playerData, U)
			
			_G.PlayerDataStore:UpdateData(Player, playerData)
			
			if Deaths == 1 then
				NotificationService:ShowMessageToPlayer(Player, NotificationData.FirstDeath, "1")
			end
		else
			warn("[Error] Player Data not found!", Player, Player.Character)
		end
	end)
end

function PlayerDataService:UpdateKills(Player)
	_G.PlayerDataStore:GetData(Player, function(playerData :CT.PlayerDataModel)
		if playerData then

			local Kills = CF:GetPlayerActiveProfile(playerData).Data.PlayerStats.Kills
			local U = {
				["Data.PlayerStats.Kills"] = Kills + 1
			}
			CF:UpdateActiveProfile(playerData, U)
			
			if (Kills+1) == 1 then
				CF:UpdateGoldInPlayerData(playerData, 100)		
				VFXHandler:PlayOnClient(Player, Constants.VFXs.RewardCoin)
				SFXHandler.Client.PlayAlong(Player, Constants.SFXs.Reward, Player.Character)
			elseif (Kills+1) == 2 then
				CF:UpdateXpInPlayerData(playerData, 50)
				VFXHandler:PlayOnClient(Player, Constants.VFXs.RewardXP)
				SFXHandler.Client.PlayAlong(Player, Constants.SFXs.Reward, Player.Character)
			elseif (Kills+1) == 3 then
				CF:UpdateGoldInPlayerData(playerData, 100)
				VFXHandler:PlayOnClient(Player, Constants.VFXs.RewardCoin)
				SFXHandler.Client.PlayAlong(Player, Constants.SFXs.Reward, Player.Character)
			end
			
			_G.PlayerDataStore:UpdateData(Player, playerData)
			
			local notificationName = "Kills"..Kills+1
			if NotificationData[notificationName] then
				NotificationService:ShowMessageToPlayer(Player, NotificationData[notificationName], "1")
			end
		else
			warn("[Error] Player Data not found to update kills!", Player)
		end
	end)
end

function PlayerDataService:KnitInit()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoved)
end

function PlayerDataService:KnitStart()
	IAPService = Knit.GetService("IAPService")
	CharacterService = Knit.GetService("CharacterService")
	QuestDataService = Knit.GetService("QuestDataService")
	NotificationService = Knit.GetService("NotificationService")
end

game:BindToClose(function()
	for _,plr in pairs(game.Players:GetPlayers()) do
		if plr then
			onPlayerRemoved(plr)
		end
	end
end)

return PlayerDataService
