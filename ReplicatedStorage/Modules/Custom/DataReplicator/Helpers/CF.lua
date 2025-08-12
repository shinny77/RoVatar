-- @ScriptType: ModuleScript
local CF = {}
local HS = game:GetService("HttpService")

local Signal = require(script.Parent.Parent.Comm.Signal)


local function StringPathToArray(path)
	local path_array = {}
	if path ~= "" then
		for s in string.gmatch(path, "[^%.]+") do
			table.insert(path_array, s)
		end
	end
	return path_array
end

function CompareTables(t1, t2)
	if t1 == t2 then return true end 
	if type(t1) ~= "table" or type(t2) ~= "table" then return false end

	for key in pairs(t2) do
		if t1[key] == nil then
			return false
		end
	end

	for key, value in pairs(t1) do
		if type(value) == "table" then

			if not CompareTables(value, t2[key]) then
				return false
			end

		elseif t2[key] ~= value then
			return false
		end
	end

	return true
end


function CF:ValidatePath(data, DataPath)
	local SPath = DataPath:split(".")
	local ReF = table.clone(data)

	for i, Key in ipairs(SPath) do
		if i == #SPath then
			if ReF[Key] then
				return ReF[Key]
			else
				return false
			end
		else
			if ReF[Key] == nil then
				return false
			end
			ReF = ReF[Key]
		end
	end
	return false
end

function CF:UpdatePathData(fullData:any, path:string, dataToUpdate:any)
	
	local path_array = (type(path) == "string") and StringPathToArray(path) or path
	
	local index = 1
	local function checkPath(tab, key)
		if(tab[key]) then
			if(index < #path_array and typeof(tab[key]) == "table") then
				index += 1
				return checkPath(tab[key], index)
				
			elseif(index == #path_array) then
				--Got final point
				tab[key] = dataToUpdate
				return fullData
			else
				warn("Invalid path")
				return
			end
		else
			warn("Key not found in table. Invalid path.")
			return nil
		end
	end
	
	return checkPath(fullData, path_array[index])
end

function CF:MatchTables(sorTab:table, doubTab:table, test) :boolean
	--if sorTab and doubTab and typeof(sorTab) == "table" and typeof(doubTab) == "table" then
	--	return CompareTables(sorTab, doubTab)
	--else
		return (HS:JSONEncode(sorTab) == HS:JSONEncode(doubTab))
	--end
end

function CF:CloneTable(Table)
	if not Table then
		return Table
	end
	local function Clone(original)
		local copy = {}

		for key, value in pairs(original) do
			if type(value) == "table" then
				copy[key] = Clone(value)
			else
				copy[key] = value
			end
		end
		return copy
	end

	local newTable = Clone(Table)
	return newTable
end
----------------------- Custom Classes ------------------------

local Val = {} do
	Val.__index = Val

	CF.Value = function(initialVal:any)
		if(not initialVal) then initialVal = "0" end

		local self = setmetatable({}, Val)
		self.__index = self
		self.__tostring = function()
			--print("[Value] :>" .. self._val)
			return self._val
		end

		self._typ = typeof(initialVal)

		--Init
		self._initVal = initialVal
		self._preVal = self:GetInitialVal()
		self._val = self:GetInitialVal()

		self.OnChange = Signal.new()

		return self
	end

	function Val:Set(newVal:any, force:boolean)
		if(typeof(newVal) ~= self._typ and not force) then
			return (self._typ == "table") and table.clone(self._val) or self._val
		end

		if(not force) then
			local same = false
			if(typeof(self._typ) == "table") then
				same = (CF:MatchTables(self._val, newVal))
			else
				same = (self._val == newVal)
			end

			if(same) then
				return
			end
		end

		self._preVal = self._val
		self._val = newVal
		self._typ = typeof(newVal)

		local preVal = self._preVal
		self.OnChange:Fire(newVal, preVal)

		return (self._typ == "table") and table.clone(self._val) or self._val
	end

	function Val:Get()
		return (self._typ == "table") and table.clone(self._val) or self._val
	end

	function Val:GetInitialVal()
		return (self._typ == "table") and table.clone(self._initVal) or self._initVal
	end

	function Val:GetPreVal()
		return (self._typ == "table") and table.clone(self._preVal) or self._preVal
	end

	function Val:Reset()
		return self:Set(self:GetInitialVal(), true)
	end

	function Val:Clear()
		self.OnChange:DisconnectAll()
		self._val = self:GetInitialVal()
		self._preVal = self:GetInitialVal()
	end
end



----------------------- Metatables Extensions ------------------------
CF.GetLength = {
	__len = function(t)
		if(#t <= 0) then
			local count = 0
			for i, v in pairs(t) do
				count += 1
			end
			
			return count
		else
			return #t
		end
	end,
	
	
	DisconnectAll = function()
		
	end,
}


return CF