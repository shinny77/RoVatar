-- @ScriptType: ModuleScript
local MarketplaceService = game:GetService("MarketplaceService")
local RS = game:GetService("ReplicatedStorage")
local Knit = require(RS.Packages.Knit)
local Signal = require(RS.Packages.Signal)

local Custom = RS.Modules.Custom
local CD = require(Custom.Constants)
local CT = require(Custom.CustomTypes)

local IAPService = Knit.CreateService {
	Name = "IAPService",
	OnPurchaseCompleted = Signal.new(),
	inProcessPurchases = {},
	Client = {
		OnPurchaseCompleted = Knit.CreateSignal(),
		OnPromptClosed = Knit.CreateSignal(),
	}
}

------>>Other Scripts
--local MessageGuiService
--local LoadingScreenService


--MarketplaceService:GetUserSubscriptionStatusAsync()
-------------------===========Constants==========------------------------
--["Card_02"] = {1773107960, function(receipt, player)
--	warn("Card Purchase Successful, receipt:", receipt)
--	IAPService.OnPurchaseCompleted:Fire(player, "Card_02", CD.IapProductCategory.Card)
--	IAPService.Client.OnPurchaseCompleted:Fire(player, "Card_02", CD.IapProductCategory.Card)
--end},

-------------------===========Constants==========------------------------

--------------------------------------------------------------->  Private Methods  <------------------------------------------------------
function GetProductFunction(playerId, productId)
	return IAPService.inProcessPurchases[playerId][productId]
end

function PromptPurchase(player, productId, iapType)
	--LoadingScreenService:ToggleLoadingScreen(player, true, "Processing Purchase Request", true)
	print(player, productId, iapType)
	if(iapType == Enum.InfoType.Product) then
		MarketplaceService:PromptProductPurchase(player, productId)
		
	elseif(iapType == Enum.InfoType.GamePass) then
		MarketplaceService:PromptGamePassPurchase(player, productId)
		
	elseif(iapType == Enum.InfoType.Subscription) then
		MarketplaceService:PromptSubscriptionPurchase(player, productId)
		
	elseif(iapType == Enum.InfoType.Asset) then
		MarketplaceService:PromptPurchase(player, productId)
		
	elseif(iapType == Enum.InfoType.Bundle) then
		MarketplaceService:PromptBundlePurchase(player, productId)
	end
	
end

function ResetInProcessPlayer(player:Player, Id)
	IAPService.Client.OnPromptClosed:Fire(player)
	IAPService.inProcessPurchases[player.UserId] = nil
end


----------------->>>>>>>>> Purchase History <<<<<<<<<<<----------------
function ManagePurchaseHistory(player, productID, productData:CT.ItemDataType)
	if(IAPService.purchaseHistory[player.UserId] == nil) then
		IAPService.purchaseHistory[player.UserId] = {}
	end

	IAPService.purchaseHistory[player.UserId][productID] = productData
end

----------------->>>>>>>>> Purchase History <<<<<<<<<<<----------------



----------------->>>>>>>>> MarketPlace Callbacks <<<<<<<<<<<----------------
---->>> For Consumable, Non-Consumables Products
function PurchaseReceiptCallback(receiptInfo)
	print("PurchaseReceiptCallback called.......",receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId

	local player = game.Players:GetPlayerByUserId(userId)
	if player then
		-- Get the handler function associated with the developer product ID and attempt to run it
		local handler = GetProductFunction(userId, productId)
		local success, result = pcall(handler, receiptInfo, player)
		if success then
			-- The user has received their benefits!
			-- return PurchaseGranted to confirm the transaction.
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			warn("Failed to process receipt:", receiptInfo, result)
		end
	end

	-- the user's benefits couldn't be awarded.
	-- return NotProcessedYet to try again next time the user joins.
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function OnPurchasePromptClosed(playerId, productId, isPurchased)
	print("OnPurchasePromptClosed ")
	local plr = game.Players:GetPlayerByUserId(playerId)
	ResetInProcessPlayer(plr, productId)
end

---->>> For Passes Products
function PromptGamePassPurchaseFinished(player, purchasedPassID, purchaseSuccess,...)
	print("PromptGamePassPurchaseFinished  closed.....", player, purchasedPassID, purchaseSuccess, ...)
	if purchaseSuccess  then
		print(player.Name .. " purchased the Pass with ID",purchasedPassID)
		local fun = GetProductFunction(player.UserId, purchasedPassID)
		fun(player, purchasedPassID)
	else
		warn("Player didn't purchased Pass with ID;",purchasedPassID)
	end
	ResetInProcessPlayer(player, purchasedPassID)
end

function OnSubscriptionFinished(player, purchasedPassID, purchaseSuccess)
	print("OnSubscriptionFinished .....")
	if purchaseSuccess then
		print(player.Name .. " purchased the Pass with ID",purchasedPassID)
		local fun = GetProductFunction(player.UserId, purchasedPassID)
		fun(player, purchasedPassID)
	else
		warn("Player didn't purchased Pass with ID;",purchasedPassID)
	end
	ResetInProcessPlayer(player, purchasedPassID)
end

local function onPromptPurchaseFinished(player, assetId, isPurchased)
	print("onPromptPurchaseFinished .....",assetId, isPurchased)
	if isPurchased then
		print(player.Name, "bought an item with AssetID:", assetId)
		local fun = GetProductFunction(player.UserId, assetId)
		fun(player, assetId)
	else
		print(player.Name, "didn't buy an item with AssetID:", assetId)
	end
	ResetInProcessPlayer(player, assetId)
end
----------------->>>>>>>>> MarketPlace Callbacks <<<<<<<<<<<----------------


---------------------------------------------------------------->  Public Methods  <------------------------------------------------------

-------- server
function IsSubscriptionActive(player:Player, productId)
	
	local subStatus = {}
	local IsSubs = nil
	
	local success, message = pcall(function()
		subStatus = MarketplaceService:GetUserSubscriptionStatusAsync(player, productId)
	end)
	
	if not success then
		warn("Error while checking if player has subscription: " .. tostring(message))
		return IsSubs
	end

	if subStatus["IsSubscribed"] then
		print(player.Name .. " is subscribed with " .. productId)
		IsSubs = true
	end
		
	return IsSubs
	
end

function IsGamePassPurchased(player:Player, productId)
	
	local hasPass = nil
	
	local success, message = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, productId)
	end)
	
	if not success then
		warn("Error while checking if player has pass: " .. tostring(message))
		return hasPass
	end

	if hasPass then
		print(player.Name .. " owns the Pass with ID " .. productId)
	end
		
	return hasPass
	
end

function IAPService:RefreshPurchaseDataUpdates(player: Player, playerData : CT.PlayerDataModel)
	
	local PurchaseData : CT.GamePurchasesDataType = playerData.GamePurchases
	
	for i, data :CT.ItemDataType in pairs(CD.IAPItems) do
		
		if(data.ProductType == Enum.InfoType.GamePass) then
			PurchaseData.Passes[data.Id] = IsGamePassPurchased(player, data.ProductId)
			
		elseif(data.ProductType == Enum.InfoType.Subscription) then
			PurchaseData.Subscriptions[data.Id] = IsSubscriptionActive(player, data.ProductId)
		end
	end
		
	return PurchaseData
end

-------- Client
function IAPService.Client:PurchaseItem(player, productData: CT.ItemDataType)
	print("[IAP Manager] Received request for item purchase:", productData)
	assert(productData or productData.Id, "Require full productData to initiate the IAP.")
	--if(productData == nil or productData.Id == nil) then
	--	warn("Require full productData to initiate the IAP.")
	--	return
	--end
	
	local OnSuccessFun = function(reciept, Plr)
		print(" Reciept on purchase completed : ", reciept, Plr)
		IAPService.OnPurchaseCompleted:Fire(player, productData)
		IAPService.Client.OnPurchaseCompleted:Fire(player, productData)
	end
	
	--Update processing table
	if(self.Server.inProcessPurchases[player.UserId] == nil) then
		self.Server.inProcessPurchases[player.UserId] = {}
	end
	if(self.Server.inProcessPurchases[player.UserId][productData.ProductId] == nil) then
		self.Server.inProcessPurchases[player.UserId][productData.ProductId] = OnSuccessFun
	else
		warn("Purchase is already in processing, cannot accept another request for same Product.")
		return
	end
	
	PromptPurchase(player, productData.ProductId, productData.ProductType)
		
end

function IAPService.Client:GetProductInfo(player:Player, productId:number, pType:Enum.InfoType)
	print("[IAPService] Received request to fetch product info:", productId)
	
	local succ, err = pcall(function()
		return MarketplaceService:GetProductInfo(productId, pType)
	end)
	
	print("Fetching result:", succ, err)
	
	return err
end



function IAPService:KnitInit()

	-- Set the callback; this can only be done once by one script on the server!
	MarketplaceService.ProcessReceipt = PurchaseReceiptCallback
	MarketplaceService.PromptProductPurchaseFinished:Connect(OnPurchasePromptClosed)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(PromptGamePassPurchaseFinished)
	MarketplaceService.PromptSubscriptionPurchaseFinished:Connect(OnSubscriptionFinished)
	
	MarketplaceService.PromptPurchaseFinished:Connect(onPromptPurchaseFinished)
	
	MarketplaceService.PromptBundlePurchaseFinished:Connect(onPromptPurchaseFinished)
	
end

function IAPService:KnitStart()
end

return IAPService