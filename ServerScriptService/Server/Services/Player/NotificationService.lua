-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local Knit = require(RS.Packages.Knit)

local CD = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)

local NotificationService = Knit.CreateService {
	Name = "NotificationService",
	playersFunctionHolder = {},
	Client = {
		ShowMessageEvent = Knit.CreateSignal(),
		OkYesEvent = Knit.CreateSignal(),
		NoEvent = Knit.CreateSignal(),
	}
}

---------------------------------------------------------->  Private Methods  <------------------------------------------------------

---------------->>>>>>>>>>>> Bindings Callbacks <<<<<<<<<<<<--------------------

function OkYesCallback(player:Player, caller)
	local plrFunction = NotificationService.playersFunctionHolder[player.UserId]
	if (plrFunction and plrFunction[caller]) then
		if(plrFunction[caller]["OkYesFunc"] ~= nil) then
			local func = NotificationService.playersFunctionHolder[player.UserId][caller]["OkYesFunc"]
			func(player, caller)
			NotificationService.playersFunctionHolder[player.UserId][caller] = nil
		end
	end
end

function NoCallback(player:Player, caller)
	local plrFunction = NotificationService.playersFunctionHolder[player.UserId]
	if(plrFunction and plrFunction[caller]) then
		if(plrFunction[caller]["NoFunc"] ~= nil) then
			local func = plrFunction[caller]["NoFunc"]
			func(player, caller)
			NotificationService.playersFunctionHolder[player.UserId][caller] = nil
		end
	end
end

---------------------------------------------------------->  Public Methods  <-------------------------------------------------------

function NotificationService:ShowMessageToPlayer(player:Player & number, popupData:CT.PopupDataType, callerId,  OkYesFunc :() -> (), NoFunc :() -> ())
	if(popupData == nil) then
		--warn("MessageData cannot be empty. What to send lol:(")
		return
	end
	
	player = typeof(player) == "number" and game.Players:GetPlayerByUserId(player) or player
	if not player or not game.Players:FindFirstChild(player.Name) then
		print("Player is not available: will use MessageService to send cross server notification : ")
		return
	end
	
	if player then
		--print("Got call to showMessage from caller:", caller)
		self.Client.ShowMessageEvent:Fire(player, popupData, callerId)

		if OkYesFunc or NoFunc then
			if(self.playersFunctionHolder[player.UserId] == nil) then
				self.playersFunctionHolder[player.UserId] = {}
			end
			self.playersFunctionHolder[player.UserId][callerId] = {}
			if(OkYesFunc) then
				self.playersFunctionHolder[player.UserId][callerId]["OkYesFunc"] = OkYesFunc
			end
			if(NoFunc) then
				self.playersFunctionHolder[player.UserId][callerId]["NoFunc"] = NoFunc
				task.delay(10, function() NoCallback(player, callerId) end)
			end
		end
	end
end


function NotificationService:KnitInit()
	self.Client.OkYesEvent:Connect(OkYesCallback)
	self.Client.NoEvent:Connect(NoCallback)
end

function NotificationService:KnitStart()

end

return NotificationService