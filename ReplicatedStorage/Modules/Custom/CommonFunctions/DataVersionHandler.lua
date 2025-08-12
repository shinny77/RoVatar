-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local DSS = game:GetService("DataStoreService")


local CD = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)




local options = Instance.new("DataStoreOptions")
options.AllScopes = true
local PlayerDataStore = DSS:GetDataStore(CD.DataStores.PlayerData.Name, "", options)

local listSuccess, pages = pcall(function()
	return PlayerDataStore:ListKeysAsync()
end)


local dataDictionary = {}
--[[If the pcall succeeds without error, then this will run.]]
--[[The loop will go on until all key values have been read through.]]
if listSuccess then
	while true do
		local items = pages:GetCurrentPage()
		
		for _, v in ipairs(items) do
			--[[Take current key + its associated value and write it into the dictionary.]]
			local value = PlayerDataStore:GetAsync(v.KeyName)
			dataDictionary[v.KeyName] = value
		end
		
		if pages.IsFinished then
			break
		end
		
		pages:AdvanceToNextPageAsync()
	end
end

--print("All keys data:", dataDictionary)


