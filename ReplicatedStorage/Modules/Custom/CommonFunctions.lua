-- @ScriptType: ModuleScript
local CommonFunctions = {}
local RS = game:GetService("ReplicatedStorage")
local HS = game:GetService("HttpService")
local CS = game:GetService("CollectionService")

local CT = require(script.Parent.CustomTypes)
local CD = require(script.Parent.Constants)
local VFXHandler = require(script.Parent.VFXHandler)

local DataModels = require(script.DataModels)

local Signal = require(RS.Packages.Signal) --The Signal component from Knit Framework


---------------->>>>>>>>>>>********* Values Conversion Functions **********>>>>>>>>>>>>>>>>>>-----------------

local monthShortTable = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
function CommonFunctions:ConvertUnixTimeStampToTimeFormat(timeStamp, timeWithDate:BoolValue)
	if(timeStamp == nil) then
		print("Unable to convert to timestring, utcSeconds is nil.")
		return
	end
	--print("[Unix timeStamp]:", timeStamp)
	local pTime = "AM"
	local dd = DateTime.fromUnixTimestamp(timeStamp)
	local Time = dd:ToLocalTime()
	local year = Time.Year
	local month = monthShortTable[Time.Month]
	local day = string.format("%02d",Time.Day)
	local hours = Time.Hour
	local min = string.format("%02d",Time.Minute)
	local sec = string.format("%02d",Time.Second)

	if(hours >= 12) then
		hours = hours > 12 and hours - 12 or hours
		pTime = "PM"
	end
	hours = string.format("%02d",hours)
	local timeString
	if(timeWithDate) then
		timeString = day.."-"..month.."-"..year.." "..hours..":"..min..":"..sec.." "..pTime
	else
		timeString = hours..":"..min..":"..sec
	end

	return timeString, day, month, year, hours, min, sec, pTime
end

function CommonFunctions:NumberToCurrencyFormat(number:number) :string
	local left,num,right = string.match(number,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function CommonFunctions:ConvertToTimeFormat(timeInSec:number , onlyMinSec:BoolValue)
	local hrs = math.floor(timeInSec / 3600)
	local minutes = (timeInSec / 60) % 60
	local seconds = timeInSec % 60
	if(onlyMinSec) then
		return string.format("%02d:%02d", minutes, seconds)
	else
		return string.format("%02d:%02d:%02d",hrs, minutes, seconds)
	end
end

function CommonFunctions:ConvertDicToArray(tbl)
	local newTbl = {}
	for key, Value in pairs(tbl) do
		table.insert(newTbl, Value)
	end
	return newTbl
end

function CommonFunctions:SortTable(tbl, property:string)
	if not tbl[1] then
		tbl = self:ConvertDicToArray(tbl)
	end

	local t = table.clone(tbl)
	table.sort(t, function(v1, v2)
		return v1[property] > v2[property]
	end)

	tbl = t
	return t
end

function CommonFunctions:MatchTables(sorTab:table, doubTab:table) :boolean
	return (HS:JSONEncode(sorTab) == HS:JSONEncode(doubTab))
end

function CommonFunctions:TableLength(Table) :number
	local counter = 0
	for i, v in pairs(Table) do
		counter += 1
	end
	return counter
end

function CommonFunctions:NextValue(Table, exceptId):table

	local TableC = table.clone(Table)
	if exceptId and TableC[exceptId] then
		TableC[exceptId] = nil
	end

	for _, data in pairs(TableC) do
		return data 
	end

	return nil
end

function CommonFunctions:CloneTable(Table)
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

local RNG = Random.new()
function CommonFunctions:RandomValue(Table)
	local array = {}
	for key, _ in pairs(Table) do
		table.insert(array, key)
	end

	local Index = math.floor(RNG:NextNumber(1, #array))
	local id = array[Index]

	return Table[id]
end
---------------->>>>>>>>>>>********* Values Conversion Functions **********>>>>>>>>>>>>>>>>>>-----------------

CommonFunctions.RoundNumber = function(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

CommonFunctions.WrapObject = function(obj:Instance)
	if(typeof(obj) == "CFrame") then
		return {Pos = {X = obj.Position.X,Y = obj.Position.Y,Z = obj.Position.Z,}, Rot = {X = obj.Rotation.X,Y = obj.Rotation.Y,Z = obj.Rotation.Z}}
	elseif(typeof(obj) == "Vector3") then
		return {X = obj.X,Y = obj.Y,Z = obj.Z,}
	elseif(typeof(obj) == "Vector2") then
		return {X = obj.X,Y = obj.Y}
	elseif(typeof(obj) == "UDim2") then
		return {Scale = {X = obj.X.Scale,Y = obj.Y.Scale}, Offset = {X = obj.X.Offset,Y = obj.Y.Offset}}
	else
		warn(obj, "Not supported type:", typeof(obj))
	end
end

CommonFunctions.CreateObject = function(obj:{}, typ)
	if(obj.Pos and obj.Rot) then
		--local s = {Pos = {X = obj.Position.X,Y = obj.Position.Y,Z = obj.Position.Z,}, Rot = {X = obj.Rotation.X,Y = obj.Rotation.Y,Z = obj.Rotation.Z}}

		return CFrame.lookAt(Vector3.new(obj.Pos.X, obj.Pos.Y, obj.Pos.Z), Vector3.new(obj.Rot.X, obj.Rot.Y, obj.Rot.Z))
	elseif(typeof(obj) == "Vector3") then
		return Vector3.new(obj.X, obj.Y, obj.Z)
	elseif(typeof(obj) == "Vector2") then
		return Vector2.new(obj.X, obj.Y)
	elseif(typeof(obj) == "UDim2") then
		return UDim2.new(obj.Scale.X, obj.Offset.X, obj.Scale.Y, obj.Offset.Y)
	else
		warn(obj, "Not supported type:", typeof(obj))
	end
end

CommonFunctions.Value = require(script.Value)

CommonFunctions.PivotTo = function(char :Model, part:Part, playEffect:boolean, caller)
	if(playEffect) then
		--VFXHandler:PlayEffect(char, CD.VFXs.SpawnEffect)
	end

	local cf :CFrame = part
	if(typeof(part) ~= "CFrame") then
		--print("Finding  dynamic position, ", char, part)
		cf = CommonFunctions:GetPivotLocation(char, part)
	end

	task.wait(.1)
	char:PivotTo(cf)
end

---------------->>>>>>>>>>>********* Models **********>>>>>>>>>>>>>>>>>>-----------------

function CommonFunctions:ApplyInventory(_character :Model, _itemData:CT.ItemDataType, _apply:boolean?)
	local function clear(__parent, __type)
		for _, child in pairs(__parent:GetChildren()) do
			local typee = child:GetAttribute("Type")
			if typee and typee == __type then
				child:Destroy()
			end
		end
	end

	local humanoid = _character:WaitForChild("Humanoid", 15)
	if not humanoid then
		return
	end
	
	local HumanoidDescription = humanoid:GetAppliedDescription()
	if not HumanoidDescription then
		return
	end
	
	if(_itemData.ItemType == CD.ItemType.Eye) 
		or(_itemData.ItemType == CD.ItemType.Mouth) 
		or(_itemData.ItemType == CD.ItemType.Eyebrows)
		or(_itemData.ItemType == CD.ItemType.Extra) then

		clear(_character.Head, _itemData.ItemType)

		if _apply then
			local decal = Instance.new("Decal", _character.Head)
			decal:SetAttribute("Type", _itemData.ItemType)
			decal.Texture = _itemData.Image
		end
	elseif(_itemData.ItemType == CD.ItemType.Skin) then

		local color = Color3.fromRGB(255, 224, 189)
		if _apply then
			if typeof(_itemData.Color) == "Color3" then
				color = _itemData.Color
			else
				local colorCont = string.split(_itemData.Color, ", ")
				color = Color3.fromRGB(table.unpack(colorCont))
			end
		end

		HumanoidDescription.HeadColor = color
		HumanoidDescription.LeftArmColor = color	
		--HumanoidDescription.LeftLegColor = color	
		HumanoidDescription.RightArmColor = color	
		--HumanoidDescription.RightLegColor = color	
		--HumanoidDescription.TorsoColor = color

		humanoid:ApplyDescription(HumanoidDescription)

	elseif(_itemData.ItemType == CD.ItemType.Hair) then
		-- Hair

		HumanoidDescription.HairAccessory = _itemData.ProductId
		local s, r = pcall(function()
			return humanoid:ApplyDescription(HumanoidDescription)
		end)
		--print("ApplyDescription :", s, r)

	elseif _itemData.ItemType == CD.ItemType.Jersey or _itemData.ItemType == CD.ItemType.Pant then
		local defaultIds = {
			[CD.ItemType.Jersey] = 1,--7123903816,
			[CD.ItemType.Pant] = 1,--12176104895
		}

		local id = _apply and _itemData.ProductId or defaultIds[_itemData.ItemType]

		clear(_character, _itemData.ItemType)
		local humanoid = _character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local desc = humanoid:GetAppliedDescription()
			--print("Jersey Add ", desc, _itemData, _itemData.ItemType)
			if _itemData.ItemType == CD.ItemType.Jersey then
				if desc.Shirt ~= id then
					desc.Shirt = id
				end
			elseif _itemData.ItemType == CD.ItemType.Pant then
				if desc.Pants ~= id then
					desc.Pants = id
				end
			end
			humanoid:ApplyDescription(desc)
		end
	end

end

function CommonFunctions:ApplyFullInventory(_character, _profileSlotData :CT.ProfileSlotDataType)

	local hairData = CD.GameInventory.Styling.Hair[_profileSlotData.Data.EquippedInventory.Styling.Hair.Id]

	local EyeData = CD.GameInventory.Styling.Eye[_profileSlotData.Data.EquippedInventory.Styling.Eye.Id]
	local PantData = CD.GameInventory.Styling.Pant[_profileSlotData.Data.EquippedInventory.Styling.Pant.Id]
	local SkinData = CD.GameInventory.Styling.Skin[_profileSlotData.Data.EquippedInventory.Styling.Skin.Id]
	local MouthData = CD.GameInventory.Styling.Mouth[_profileSlotData.Data.EquippedInventory.Styling.Mouth.Id]
	local ExtraData = CD.GameInventory.Styling.Extra[_profileSlotData.Data.EquippedInventory.Styling.Extra.Id]
	local JerseyData = CD.GameInventory.Styling.Jersey[_profileSlotData.Data.EquippedInventory.Styling.Jersey.Id]
	local EyebrowsData = CD.GameInventory.Styling.Eyebrows[_profileSlotData.Data.EquippedInventory.Styling.Eyebrows.Id]
	
	--print("Apply inventory:", hairData)
	task.delay(.1 ,function()
		CommonFunctions:ApplyInventory(_character, hairData, true)
		CommonFunctions:ApplyInventory(_character, PantData, true)
		CommonFunctions:ApplyInventory(_character, SkinData, true)
		CommonFunctions:ApplyInventory(_character, JerseyData, true)

		CommonFunctions:ApplyInventory(_character, EyeData, true)
		CommonFunctions:ApplyInventory(_character, MouthData, true)
		CommonFunctions:ApplyInventory(_character, ExtraData, true)
		CommonFunctions:ApplyInventory(_character, EyebrowsData, true)
	end)
	
end
---------------->>>>>>>>>>>********* Models **********>>>>>>>>>>>>>>>>>>-----------------

---------------->>>>>>>>>>>********* UI **********>>>>>>>>>>>>>>>>>>-----------------
CommonFunctions.UI = {
	Blink = function(player :Player, _time :number)
		------ 
		_time = _time or .75 

		local GUI = Instance.new("ScreenGui", player.PlayerGui)
		GUI.IgnoreGuiInset = true
		GUI.ResetOnSpawn = false
		GUI.DisplayOrder = 100
		local Frame = Instance.new("Frame", GUI)
		Frame.Size = UDim2.new(1, 0, 1, 0)
		Frame.AnchorPoint = Vector2.new(.5, .5)
		Frame.Position = UDim2.new(.5, 0, .5, 0)
		Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

		local TS = game:GetService("TweenService")

		local tween1 = TS:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
		tween1:Play()
		game.Debris:AddItem(tween1, 0.15)
		task.delay(_time, function()
			local tween2 = TS:Create(Frame, TweenInfo.new(.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
			tween2:Play()
			game.Debris:AddItem(tween2, .76)
			game.Debris:AddItem(GUI, .76)
		end)
	end,
	
	ToggleBlackScreen = function(player :Player, enable) 
		local TS = game:GetService("TweenService")
		
		local GUI = player.PlayerGui:FindFirstChild("BlackScreenGui") or Instance.new("ScreenGui", player.PlayerGui)
		GUI.IgnoreGuiInset = true
		GUI.ResetOnSpawn = false
		GUI.DisplayOrder = 100
		GUI.Name = "BlackScreenGui"
		
		local Frame = GUI:FindFirstChild('Frame') or Instance.new("Frame", GUI)
		Frame.Size = UDim2.new(1, 0, 1, 0)
		Frame.AnchorPoint = Vector2.new(.5, .5)
		Frame.Position = UDim2.new(.5, 0, .5, 0)
		Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		
		if enable then
			local tween1 = TS:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
			tween1:Play()
		else
			local tween2 = TS:Create(Frame, TweenInfo.new(.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
			tween2:Play()
			game.Debris:AddItem(tween2, .76)
			game.Debris:AddItem(GUI, .76)
		end
	end,
}
---------------->>>>>>>>>>>********* UI **********>>>>>>>>>>>>>>>>>>-----------------

---------------->>>>>>>>>>>********* Combats **********>>>>>>>>>>>>>>>>>>-----------------

function CommonFunctions:RefreshCombatControls(plr :Player, combatStats)

	local combatF = plr:FindFirstChild("CombatStats") or Instance.new("Folder", plr)
	combatF.Name = "CombatStats"

	for name, val in pairs(combatStats) do
		local kk = nil
		if(typeof(val) == "number") then
			kk = "NumberValue"
		elseif(typeof(val) == "string") then
			kk = "StringValue"
		end

		local element = combatF:FindFirstChild(name) or Instance.new(kk, combatF)
		element.Name = name
		element.Value = val
	end

	local StatesF = plr:FindFirstChild("States") or Instance.new("Folder", plr)
	StatesF.Name = "States"

	for Key, State in pairs(CD.StateTypes) do
		local StateS = StatesF:FindFirstChild(State) or Instance.new("StringValue", StatesF)
		StateS.Name = State
	end

	if not plr:FindFirstChild("isBlocking") then
		local value = Instance.new("BoolValue")
		value.Name = "isBlocking"
		value.Parent = plr
	end

	local CombatMechanics = plr:FindFirstChild("CombatMechanics") or Instance.new("Folder", plr) do
		CombatMechanics.Name = "CombatMechanics"

		-- Some Debounces and Combo Used in Fist and Meteorite Sword 
		local Debounce = CombatMechanics:FindFirstChild("Debounce") or Instance.new("BoolValue", CombatMechanics) do
			Debounce.Name = "Debounce"
		end

		local Combo = CombatMechanics:FindFirstChild("Combo") or Instance.new("NumberValue", CombatMechanics) do
			if Combo.Name ~= "Combo" then
				Combo.Name = "Combo"
				Combo.Value = 1
			end
		end

		local doingCombo = CombatMechanics:FindFirstChild("doingCombo") or Instance.new("NumberValue", CombatMechanics) do 
			doingCombo.Name = "doingCombo"
		end

		local canHit = CombatMechanics:FindFirstChild("canHit") or Instance.new("BoolValue", CombatMechanics) do
			if canHit.Name ~= "canHit" then
				canHit.Name = "canHit"
				canHit.Value = true
			end
		end
	end

	local Progression = plr:FindFirstChild("Progression") or Instance.new("Folder", plr) do
		Progression.Name = "Progression"

		-----[READ & WRITE]
		local EXP = Progression:FindFirstChild("EXP") or Instance.new("NumberValue", Progression) do
			EXP.Name = "EXP"
		end

		-----[READ ONLY]
		local LEVEL = Progression:FindFirstChild("LEVEL") or Instance.new("NumberValue", Progression) do
			LEVEL.Name = "LEVEL"
		end

	end

end

---------------->>>>>>>>>>>********* Combats **********>>>>>>>>>>>>>>>>>>-----------------

---------------->>>>>>>>>>>********* Calculations and Formulas **********>>>>>>>>>>>>>>>>>>-----------------

function CommonFunctions:CustomExplosion(data :CT.ExplosionData, onHit:()->())
	local explosion = Instance.new("Explosion", data.Parent or workspace)
	explosion.BlastPressure = data.BlastPressure or 0 -- this could be set higher to still apply velocity to parts
	explosion.DestroyJointRadiusPercent = data.BreakJoints and 100 or 0 -- joints are safe
	explosion.BlastRadius = data.Radius or explosion.BlastRadius
	explosion.Position = data.Position
	explosion.TimeScale = data.TimeScale or 1

	-- set up a table to track the models hit
	local modelsHit = {}

	-- listen for contact
	explosion.Hit:Connect(function(part, distance)
		local parentModel = part.Parent
		--print("Explostion hit:", part)
		if parentModel then
			-- check to see if this model has already been hit
			if modelsHit[parentModel] then
				return
			end
			-- log this model as hit
			modelsHit[parentModel] = true

			if(onHit) then
				onHit(parentModel)
			end
		end
	end)

	return explosion
end

function CommonFunctions:PosLiesInArea(area:Part, pos:Vector3) :boolean
	assert(area, "Area is nil")
	assert(pos, "ballPos is required to calculate the insidity if ball.")

	local function IsInsideShape(point: Vector2, shape)
		local angleSum = 0

		for i, a in ipairs(shape) do
			local b = shape[i + 1] or shape[1]
			local vector1 = a - point
			local vector2 = b - point

			local dot = vector1:Dot(vector2)
			dot /= vector1.Magnitude * vector2.Magnitude
			local subtendedAngle = math.deg(math.acos(dot))
			local signedAngle = subtendedAngle * math.sign(subtendedAngle)
			angleSum += subtendedAngle
		end

		return math.round(angleSum) == 360
	end

	local centre = Vector2.new(area.Position.X, area.Position.Z)
	local sizeX = (area.Size.X/2)
	local sizeZ = (area.Size.Z/2)

	local point = Vector2.new(pos.X, pos.Z)

	local length = math.sqrt((sizeX^2) + (sizeZ^2)) --Length of half diagnol of this square.

	--Don't change the order of these values.
	local shapePoints = {
		Vector2.new(centre.X - length, centre.Y),
		Vector2.new(centre.X, centre.Y - length),
		Vector2.new(centre.X + length, centre.Y),
		Vector2.new(centre.X, centre.Y + length),
	}

	local result :boolean = IsInsideShape(point, shapePoints)

	return result
end

function quadraticSolver(a, b, c)
	local x1 = (-b + math.sqrt((b*b) -4 * a * c)) / (2 * a)
	local x2 = (-b - math.sqrt((b*b) -4 * a * c)) / (2 * a)
	return if x2 > x1 then x2 else x1
end

function CommonFunctions:FindLandingPosition(Vo: Vector3, startingPosition: Vector3)
	local acc = -workspace.Gravity
	local seconds = quadraticSolver((0.5 * acc), Vo.Y, startingPosition.Y)

	local horizontalVel = Vector3.new(Vo.x, 0, Vo.Z)
	local endingOffset = horizontalVel * seconds
	return startingPosition + endingOffset + Vector3.new(0, -startingPosition.Y, 0)
end

function CommonFunctions:GetPivotLocation(obj, spawnner:Part)
	local groundClearence = 1
	local sizeMultiplier = 1
	local minItemsGap = 3 -- Sets distance between item boxes

	local function CalculatePos(spawner)
		local Position, Size = spawner.Position, spawner.Size

		--Get random position inside the spawner (respect to targetModel)
		local randomPos = Vector3.new(
			math.random(Position.X - Size.X/2, Position.X + Size.X/2),
			Position.Y - Size.Y/2 + obj.PrimaryPart.Size.Y/2 + groundClearence,
			math.random(Position.Z - Size.Z/2, Position.Z + Size.Z/2)
		)
		return randomPos
	end

	local function GetRandomPos(spawner :Instance, obj:Instance)
		--Get random position inside the spawner (respect to targetModel)
		local randomPos = CalculatePos(spawner)

		--Check the min distance between new pos and each previous items
		for i, itm:Instance in pairs(CS:GetTagged(CD.Tags.PlayerAvatar)) do

			local dist = (randomPos - itm.PrimaryPart.Position).Magnitude
			if(dist < minItemsGap) then
				randomPos = GetRandomPos(spawner, obj)
			end
		end

		local parms = OverlapParams.new()
		parms.FilterDescendantsInstances = {spawner.Parent.Parent}
		parms.FilterType = Enum.RaycastFilterType.Exclude
		--Check the collision with environment
		local p = workspace:GetPartBoundsInBox(CFrame.new(randomPos), (obj.PrimaryPart.Size * sizeMultiplier), parms)

		if(#p > 0) then
			randomPos = GetRandomPos(spawner, obj)
		end

		return randomPos
	end

	local location = GetRandomPos(spawnner, obj) do
		if not location then
			_G.Warn("[Need To Calculate Position Again -->>>>]")
			location = CalculatePos(spawnner)
		end

		location = CFrame.lookAlong(Vector3.new(location.X, spawnner.Position.Y, location.Z), spawnner.CFrame.LookVector)

	end

	return location
end
---------------->>>>>>>>>>>********* Calculations and Formulas **********>>>>>>>>>>>>>>>>>>-----------------

----------------*** Validations
function CommonFunctions:IsQuestValid(QuestData : CT.QuestDataType)
	local remTime = self:QuestRemainingSec(QuestData)
	if remTime == 0 then
		return false
	else
		return true
	end
end

function CommonFunctions:QuestRemainingSec(QuestData : CT.QuestDataType)

	local Start = QuestData.StartTime
	local Duration = QuestData.Duration

	local currentTime = workspace.Timers.Datetime.Value

	local diff = os.difftime(currentTime, Start)

	local remainingSeconds
	if Duration and (QuestData.Type == CD.QuestType.NPCQuest or QuestData.Type == CD.QuestType.LevelQuest) then
		local DurationInSec = (Duration * 60 * 60)

		if diff >= DurationInSec then
			remainingSeconds = 0
		else
			remainingSeconds = DurationInSec - diff
		end
	else
		remainingSeconds = workspace.Timers.Remaining.Value
	end

	if remainingSeconds <= 0 then
		return 0
	else
		return remainingSeconds
	end
end

local function _updateQuest(QuestData :CT.QuestDataType)

	if QuestData.IsCompleted then
		--print("Already Completed!", QuestData.Id)
		return 
	end

	if not CommonFunctions:IsQuestValid(QuestData) then
		--print('[Quest] Quest Not Valid ', QuestData)
		return
	end

	local Achieved =  QuestData.Achieved or 0
	local Target = #QuestData.Targets

	local IsAchieved = false
	local IsCompleted = false

	if Achieved < Target then
		Achieved += 1
		IsAchieved = true
		QuestData.Achieved = Achieved
	end

	if QuestData.Achieved == Target then
		if not QuestData.IsCompleted then
			IsCompleted = true
		end
		QuestData.IsCompleted = true
	end

	return IsAchieved, IsCompleted
end

function CommonFunctions:UpdateQuest(plrData :CT.PlayerDataModel, Objective, Achivement)
	local update = false
	local isAchieved, isCompleted = false, false

	local function _update(QuestData)
		if QuestData.Id and QuestData.Objective == Objective then
			local Achived = QuestData.Achieved or 0
			local target = QuestData.Targets[Achived + 1]
			if target and target.Id and target.Id == Achivement then
				local IsAchieved, IsCompleted = _updateQuest(QuestData)
				isAchieved = IsAchieved or isAchieved
				isCompleted = IsCompleted or isCompleted
				update = true
			end
		end
	end

	local activeProfile :CT.ProfileSlotDataType = self:GetPlayerActiveProfile(plrData)

	local NPCQuestData:CT.QuestDataType = activeProfile.Data.Quests.NPCQuestData
	local DailyQuestData:CT.QuestDataType = activeProfile.Data.Quests.DailyQuestData
	local LevelQuestData:CT.QuestDataType = activeProfile.Data.Quests.LevelQuestData
	local TutorialQuestData:CT.QuestDataType = activeProfile.Data.Quests.TutorialQuestData

	_update(NPCQuestData)
	_update(DailyQuestData)
	_update(LevelQuestData)
	_update(TutorialQuestData)

	if TutorialQuestData.IsCompleted then TutorialQuestData.IsClaimed = true end ---

	return update, isAchieved, isCompleted
end

----------------*** Validations
---------- Data Store Base Functions

--------**** Player Data
function CommonFunctions:GetDefaultStylings()
	local stylings = {
		Hair = {Id = CD.GameInventory.Styling.Hair.Hair_00.Id},
		Pant = {Id = CD.GameInventory.Styling.Pant.Pant_00.Id},
		Jersey = {Id = CD.GameInventory.Styling.Jersey.Jersey_00.Id},

		Eye = {Id = CD.GameInventory.Styling.Eye.Eye_01.Id},
		Skin = {Id = CD.GameInventory.Styling.Skin.Skin_01.Id},
		Extra = {Id = CD.GameInventory.Styling.Extra.Extra_00.Id},
		Mouth = {Id = CD.GameInventory.Styling.Mouth.Mouth_01.Id},
		Eyebrows = {Id = CD.GameInventory.Styling.Eyebrows.Eyebrow_01.Id},
	}
	return stylings
end

function CommonFunctions:GetSlotDataModel()
	local slotData : CT.ProfileSlotDataType = {}
	slotData.SlotId = nil
	slotData.SlotName = ''

	slotData.LastUpdatedOn = workspace.ServerTime.Value --workspace:GetServerTimeNow()
	slotData.CreatedOn = workspace.ServerTime.Value -- workspace:GetServerTimeNow()

	slotData.CharacterId = CD.CharacterTypes.Aang
	slotData.LastVisitedCF = CommonFunctions.WrapObject(CFrame.new())
	slotData.LastVisitedMap = CD.GameInventory.Maps.KioshiIsland.Id

	slotData.XP = 0
	slotData.TotalXP = 0
	slotData.PlayerLevel = 1

	slotData.Gold = 0
	slotData.Gems = 0

	slotData.Data = {}
	slotData.Data.Settings = {
		SFX = true,
		Music = true,
		UI = true,
		Shadow = true,
	}

	slotData.Data.EquippedInventory = {}
	slotData.Data.EquippedInventory.Maps = {[CD.GameInventory.Maps.KioshiIsland.Id] = true}
	slotData.Data.EquippedInventory.Abilities = {}
	slotData.Data.EquippedInventory.Transports = {}
	slotData.Data.EquippedInventory.Characters = {}
	slotData.Data.EquippedInventory.Styling = {}
	slotData.Data.EquippedInventory.Pets = {}
	slotData.Data.EquippedInventory.Weapons = {}


	local stylings = self:GetDefaultStylings()

	slotData.Data.EquippedInventory.Styling.Eye = stylings.Eye
	slotData.Data.EquippedInventory.Styling.Hair = stylings.Hair
	slotData.Data.EquippedInventory.Styling.Pant = stylings.Pant
	slotData.Data.EquippedInventory.Styling.Skin = stylings.Skin
	slotData.Data.EquippedInventory.Styling.Extra = stylings.Extra
	slotData.Data.EquippedInventory.Styling.Mouth = stylings.Mouth
	slotData.Data.EquippedInventory.Styling.Jersey = stylings.Jersey
	slotData.Data.EquippedInventory.Styling.Eyebrows = stylings.Eyebrows

	slotData.Data.Quests = {
		LevelQuestData = {},
		DailyQuestData = {},
		NPCQuestData = {},
		TutorialQuestData = {},
		JourneyQuestProgress = 1,
		KataraQuestProgress = 1,
	}

	slotData.Data.CombatStats = {
		StatPoints = 0,
		Energy = 100 ,
		Health = 100,
		Agility = 100 ,
		Defense = 100 ,
		Stamina = 100,
		Strength = 100,
		MaxStamina = 100,
	}

	slotData.Data.PlayerStats = {
		Kills = 0,
		Deaths = 0,
	}

	return slotData
end

function CommonFunctions:GetPlayerDataModel() 
	local playerData : CT.PlayerDataModel = {}

	playerData.LoginData = {}
	playerData.CoupansData = {}
	playerData.GamePurchases = {}
	playerData.OwnedInventory = {}

	playerData.PersonalProfile = {
		DisplayName = "",
		Description = "",
		AvatarURL = "",
		UserId = 0,
	}


	playerData.LoginData.MyDataStoreVersion = CommonFunctions.GetActiveDataStoreVersion()
	
	playerData.LoginData.LastLogin = workspace.ServerTime.Value --workspace:GetServerTimeNow()

	playerData.OwnedInventory.Maps = {}
	playerData.OwnedInventory.Transports = {}
	playerData.OwnedInventory.Abilities = {}
	playerData.OwnedInventory.Characters = {}
	playerData.OwnedInventory.Styling = {}

	playerData.OwnedInventory.Styling.Hair = {}
	playerData.OwnedInventory.Styling.Pant = {}
	playerData.OwnedInventory.Styling.Jersey = {}

	playerData.GamePurchases.Subscriptions =  {}
	playerData.GamePurchases.Passes =  {}

	playerData.ActiveProfile = CD.DefaultSlotId
	playerData.AllProfiles = {}

	local slot :CT.ProfileSlotDataType = self:GetSlotDataModel()
	slot.SlotId = CD.DefaultSlotId
	playerData.AllProfiles[playerData.ActiveProfile] = slot

	return playerData
end

function CommonFunctions:GetActiveDataStoreVersion()
	return CD.DataStoreVersions[#CD.DataStoreVersions]
end

function CommonFunctions:SetupProfile(plr: Player, plrData:CT.PlayerDataModel)
	warn("[SetupProfile] called for player:", plr)

	plrData.PersonalProfile.UserId = plr.UserId

	plrData.PersonalProfile.DisplayName = plr.Name
	
	plrData.PersonalProfile.AvatarURL = game.Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size100x100)
end

function CommonFunctions:CreateNewSlot(plrData : CT.PlayerDataModel, slotName:string?)
	warn("[CreateNewSlot] called for player:", plrData)

	local nProfile = CommonFunctions:TableLength(plrData.AllProfiles)

	--Creating new Slot
	local slotData :CT.ProfileSlotDataType = CommonFunctions:GetSlotDataModel()
	slotData.CreatedOn = workspace.ServerTime.Value --workspace:GetServerTimeNow()
	slotData.LastUpdatedOn = workspace.ServerTime.Value --workspace:GetServerTimeNow()
	slotData.SlotId = "Slot_"..os.time()
	slotData.SlotName = slotName or "GameSave"..(nProfile + 1)

	slotData.CharacterId = CD.CharacterTypes.Aang
	slotData.LastVisitedCF = CommonFunctions.WrapObject(CFrame.new())
	slotData.LastVisitedMap = CD.GameInventory.Maps.KioshiIsland.Id

	--Set back to player's profile
	plrData.ActiveProfile = slotData.SlotId
	plrData.AllProfiles[slotData.SlotId] = slotData
	warn("[CreateNewProfile] After profile added:", plrData)
end

function CommonFunctions:CheckAndUpdatePlayerData(playerData:CT.PlayerDataModel)

	warn("Checking playerData structure:",playerData)
	warn("Active Data Store Structure:",self:GetPlayerDataModel())
	local newDataModel = self:GetPlayerDataModel()
	
	local currentVersion = self:GetActiveDataStoreVersion().GameDataStoreVersion
	local plrStoreVersion = (typeof(playerData.LoginData.MyDataStoreVersion) == "number") and playerData.LoginData.MyDataStoreVersion or playerData.LoginData.MyDataStoreVersion.GameDataStoreVersion
	--print("Plyer stored verion:", plrStoreVersion, currentVersion)

	if(plrStoreVersion) then
		if (plrStoreVersion == 1 and currentVersion == 1.1) then
			warn("::Performing data version conversion 1 to 1.1 ::")
			return DataModels:UpdateData1To1Dot1(playerData, newDataModel, self:GetSlotDataModel())
			
		elseif (plrStoreVersion < 1) then
			playerData = newDataModel
			return playerData
		end
	end

	local function CopyTable(t)
		assert(type(t) == "table", "First argument must be a table")
		local tCopy = table.create(#t)
		for k,v in pairs(t) do
			if (type(v) == "table") then
				tCopy[k] = CopyTable(v)
			else
				tCopy[k] = v
			end
		end
		return tCopy
	end

	local function Sync(tbl, templateTbl)
		assert(type(tbl) == "table", "First argument must be a table")
		assert(type(templateTbl) == "table", "Second argument must be a table")
		
		--if existing key's type changed to `table` then assign same to tbl.
		for k,v in pairs(tbl) do
			local vTemplate = templateTbl[k]

			if (type(v) ~= type(vTemplate)) then
				if (type(vTemplate) == "table") then
					tbl[k] = CopyTable(vTemplate)
				end

				-- Synchronize sub-tables:
			elseif (type(v) == "table") then
				Sync(v, vTemplate)
			end
		end


		-- Add any missing keys:
		for k,vTemplate in pairs(templateTbl) do

			local v = tbl[k]

			if (v == nil) then
				if (type(vTemplate) == "table") then
					tbl[k] = CopyTable(vTemplate)
				else
					tbl[k] = vTemplate
					warn("Added new key in playerData:", k, vTemplate)
				end
			end

			if(typeof(vTemplate) ~= typeof(v)) then
				--print("Type not same. Key:",k)
				tbl[k] = vTemplate
			end
		end

	end

	local function remove(mainTbl, tmpTbl)
		for k, v in pairs(mainTbl) do
			local keyFound = false
			for kk, vv in pairs(tmpTbl) do
				if(kk == k) then
					keyFound = true
				end
			end

			--Remove the key if NOT found
			if(keyFound == false) then
				--print("Key not found in new tmp table.")
				--print("[Key]",k)
				mainTbl[k] = nil
			else
				if(typeof(v) == "table" and typeof(tmpTbl[k] == "table")) then
					remove(v, tmpTbl[k])
				end
			end
		end
	end

	Sync(playerData, newDataModel)
	--Special sync for slot profiles (because there are generate at runtime)
	for key, val in pairs(playerData.AllProfiles) do
		print("Syncing dynamic profile slot of profile", key, val)
		Sync(val, newDataModel.AllProfiles[newDataModel.ActiveProfile])
	end
	
	warn("After simple update:", playerData)
	return playerData
end

function CommonFunctions:ValidateSlotName(data:{[string] : CT.ProfileSlotDataType}, slotName:string, id)
	--print("[Debug New Slot] Validate Slot Name ", data, slotName)

	if(slotName == "") then
		return false, "Cannot be empty"
	end

	local minLength = 4
	local maxLength = RS.GameElements.Configs.MaxSlotNameLength.Value

	local length = slotName:len() 
	if(length < minLength) then
		return false, `Name too short (min {minLength} letters)`
	end

	if(length > maxLength) then
		return false, `Name too long (max {maxLength} letters)`
	end

	for key, slot in pairs(data) do
		--print("[Debug New Slot] Slots ", slot, slot.SlotName, slotName, slot.SlotName == slotName)
		if(slot.SlotName == slotName) and slot.SlotId ~= id then
			warn("SlotName already used")
			return false , "Slot Name already used"
		end

		local prohebitedNames = {"GameSlot", ""}
		if(table.find(prohebitedNames, slotName)) then
			warn("Prohibited name cannot be used")
			return false
		end

		local reservedNames = {"GameSlot", }
		if(table.find(reservedNames, slotName)) then
			warn("ReservedNames name cannot be used")
			return false
		end
	end

	return true
end

--------**** Player Quest Data
function CommonFunctions:GetJourneyQuestProgress(plrData :CT.PlayerDataModel)
	local plrQuestData :CT.AllQuestsType = self:GetPlrActiveQuests(plrData)

	return plrQuestData.JourneyQuestProgress or 1 --default value 1
end
function CommonFunctions:GetKataraQuestProgress(plrData :CT.PlayerDataModel)
	local plrQuestData :CT.AllQuestsType = self:GetPlrActiveQuests(plrData)
	
	return plrQuestData.KataraQuestProgress or 1 --default value 1
end

function CommonFunctions:GetPlayerQuestDataModel()
	local QuestDataModel : CT.AllQuestsType = {}

	QuestDataModel.NPCQuestData = {}
	QuestDataModel.DailyQuestData = {}
	QuestDataModel.LevelQuestData = {}
	QuestDataModel.TutorialQuestData = {}


	return QuestDataModel
end

function CommonFunctions:GetActiveQuestDataStoreVersion()
	return CD.QuestDataStoreVersions[#CD.QuestDataStoreVersions]
end

function CommonFunctions:CheckAndUpdatePlayerQuestData(playerQuestData)

	warn("Checking playerData structure:",playerQuestData)
	warn("Active Quest Data Store Structure:",self:GetPlayerQuestDataModel())
	local newDataModel = self:GetPlayerQuestDataModel()

	local function CopyTable(t)
		assert(type(t) == "table", "First argument must be a table")
		local tCopy = table.create(#t)
		for k,v in pairs(t) do
			if (type(v) == "table") then
				tCopy[k] = CopyTable(v)
			else
				tCopy[k] = v
			end
		end
		return tCopy
	end

	local function Sync(tbl, templateTbl)
		assert(type(tbl) == "table", "First argument must be a table")
		assert(type(templateTbl) == "table", "Second argument must be a table")

		for k,v in pairs(tbl) do
			local vTemplate = templateTbl[k]

			if (type(v) ~= type(vTemplate)) then
				if (type(vTemplate) == "table") then
					tbl[k] = CopyTable(vTemplate)
				end

				-- Synchronize sub-tables:
			elseif (type(v) == "table") then
				Sync(v, vTemplate)
			end
		end


		-- Add any missing keys:
		for k,vTemplate in pairs(templateTbl) do

			local v = tbl[k]

			if (v == nil) then
				if (type(vTemplate) == "table") then
					tbl[k] = CopyTable(vTemplate)
				else
					tbl[k] = vTemplate
				end
			end

			if(typeof(vTemplate) ~= typeof(v)) then
				--print("Type not same. Key:",k)
				tbl[k] = vTemplate
			end
		end

	end

	local function remove(mainTbl, tmpTbl)
		for k, v in pairs(mainTbl) do
			local keyFound = false
			for kk, vv in pairs(tmpTbl) do
				if(kk == k) then
					keyFound = true
				end
			end

			--Remove the key if NOT found
			if(keyFound == false) then
				--print("Key not found in new tmp table.")
				--print("[Key]",k)
				mainTbl[k] = nil
			else
				if(typeof(v) == "table" and typeof(tmpTbl[k] == "table")) then
					remove(v, tmpTbl[k])
				end
			end
		end
	end

	Sync(playerQuestData, newDataModel)
end

function CommonFunctions:ClaimQuestReward(QData, plrData:CT.PlayerDataModel)
	local plrQuestData :CT.AllQuestsType = self:GetPlrActiveQuests(plrData)

	---- Update Quest Data
	local QuestData :CT.QuestDataType = {}

	if QData.Type == CD.QuestType.DailyQuest then
		if plrQuestData.DailyQuestData.Id == QData.Id then
			plrQuestData.DailyQuestData.IsClaimed = true

			QuestData = plrQuestData.DailyQuestData

		else
			--Karna: Notification ("Something wrong!")
			warn("[Error] [Quest] Quest can't claim, Id Mismatched!")
			return false
		end
	elseif QData.Type == CD.QuestType.NPCQuest then
		plrQuestData.NPCQuestData.IsClaimed = true

		QuestData = plrQuestData.NPCQuestData

		plrQuestData.NPCQuestData = {}
	elseif QData.Type == CD.QuestType.LevelQuest then
		if plrQuestData.LevelQuestData.Objective == QData.Objective then
			plrQuestData.LevelQuestData.IsClaimed = true

			QuestData = plrQuestData.LevelQuestData

			--plrQuestData.LevelQuestData.CompletedQuests[QuestData] = QuestData
			plrQuestData.LevelQuestData = {}
		else
			--Karna: Notification ("Something wrong!")
			warn("[Error] [Quest] Quest can't claim, Id Mismatched!")
			return false
		end
	end
	
	--Update completion count for sequence-wise quests
	if QData.Objective == CD.QuestObjectives.Combined then
		if(not plrQuestData.JourneyQuestProgress) then --Give default value if not present
			plrQuestData.JourneyQuestProgress = 1 
		end
		plrQuestData.JourneyQuestProgress += 1	
	elseif(QData.Objective == CD.QuestObjectives.Train) then
		if(not plrQuestData.KataraQuestProgress) then --Give default value if not present
			plrQuestData.KataraQuestProgress = 1 
		end
		plrQuestData.KataraQuestProgress += 1
		
	--Special check for BreathTheSurface (Objective : Find, Train roola)	
	elseif(QData.Id == "BreathTheSurface") then
		if(not plrQuestData.KataraQuestProgress) then --Give default value if not present
			plrQuestData.KataraQuestProgress = 1 
		end
		plrQuestData.KataraQuestProgress += 1

	end

	---- Claiming Rewards 
	local Rewards = QuestData.Reward

	for _, rewardData :CT.QuestsRewardDataType in pairs(Rewards) do
		if rewardData.Type == CD.QuestRewardType.XP then
			-- Karna: Level Upgrade Check 
			self:UpdateXpInPlayerData(plrData, rewardData.Value)
		elseif rewardData.Type == CD.QuestRewardType.Gold then
			self:UpdateGoldInPlayerData(plrData, rewardData.Value)
		elseif rewardData.Type == CD.QuestRewardType.Gems then
			self:UpateGemsInPlayerData(plrData, rewardData.Value)
		else
			if rewardData.Type == CD.QuestRewardType.LevelUp then
				local activeProfile :CT.ProfileSlotDataType = self:GetPlayerActiveProfile(plrData)
				local plrLevel = activeProfile.PlayerLevel

				-- Increase player-Profile wise level
				do
					local lvlData :CT.GameLevelData = CD.GameLevelsData[plrLevel]

					--print("leveldata:", lvlData)
					if lvlData and lvlData ~= {} then
						local targetXp = lvlData.XpRequired

						self:UpdateXpInPlayerData(plrData, targetXp)
					end
				end
			end
		end
	end
	
	return true
end

function CommonFunctions:GetPlayerActiveProfile(plrData:CT.PlayerDataModel) :CT.ProfileSlotDataType
	return plrData.AllProfiles[plrData.ActiveProfile]
end

function CommonFunctions:GetPlrActiveQuests(plrData:CT.PlayerDataModel) :CT.AllQuestsType
	return plrData.AllProfiles[plrData.ActiveProfile].Data.Quests
end


---------- Get Calls 
function CommonFunctions:GetLevelData(level)
	for i, levelData in pairs(CD.GameLevelsData) do
		if(level >= levelData.MinLevel and level <= levelData.MaxLevel) then
			return levelData
		end
	end
	return nil
end

---------- Update Calls
function CommonFunctions:RandomizeNPCAppearance(_npc :Model)
	local function getRandomizeTexture(_type)
		local items = CD.GameInventory.Styling[_type]

		local item = self:RandomValue(items)
		return item.Image
	end

	local function remove(_parent, _type)
		for _, child in ipairs(_parent:GetChildren()) do
			if child:IsA("Decal") then
				local hasAttributes = next(child:GetAttributes()) ~= nil
				if (_type and child:GetAttribute("Type") == _type) or (not _type and not hasAttributes) then
					child:Destroy()
				end
			end
		end
	end

	local function applyTexture(_parent, _type)
		local Decal = Instance.new("Decal", _parent)
		Decal.Texture = getRandomizeTexture(_type)
		Decal:SetAttribute("Type", _type)
	end

	local head = _npc:WaitForChild("Head")
	local leftHand = _npc.LeftHand
	local rightHand = _npc.RightHand

	local function applyColor()
		local skinColors = {
			"255, 224, 189",  -- Fair skin (Peach)
			"255, 219, 172",  -- Light skin (Warm Ivory)
			"250, 210, 161",  -- Fair with warm undertone
			"245, 205, 156",  -- Beige
			"240, 194, 136",  -- Light tan
			"225, 184, 132",  -- Golden tan
			"216, 175, 127",  -- Medium tan
			"202, 157, 106",  -- Caramel
			"190, 140, 95",   -- Warm honey
			"179, 125, 81",   -- Deep tan
			"166, 111, 74",   -- Light brown
			"153, 97, 64",    -- Medium brown
			"140, 85, 56",    -- Deep brown
			"128, 72, 49",    -- Chocolate brown
			"116, 63, 42",    -- Dark caramel
			"105, 55, 36",    -- Deep cocoa
			"94, 48, 30",     -- Warm espresso
			"83, 42, 26",     -- Dark espresso
			"73, 37, 23",     -- Ebony
			"63, 32, 20"      -- Deep ebony
		}

		local index = math.floor(RNG:NextNumber(1, #skinColors))
		local randomSkinColor = skinColors[index]
		local colorCont = string.split(randomSkinColor, ", ")
		local color = Color3.fromRGB(table.unpack(colorCont))

		head.Color = color
		leftHand.Color = color
		rightHand.Color = color

		if not leftHand:FindFirstChildOfClass("SurfaceAppearance") then
			Instance.new('SurfaceAppearance', leftHand)
		end

		if not rightHand:FindFirstChildOfClass("SurfaceAppearance") then
			Instance.new('SurfaceAppearance', rightHand)
		end
	end

	remove(head)

	applyTexture(head, CD.ItemType.Eye)
	applyTexture(head, CD.ItemType.Eyebrows)
	applyTexture(head, CD.ItemType.Mouth)

	applyColor()
end

--.DataPaths should be table. --> The number of paths and value
function CommonFunctions:UpdateActiveProfile(playerData: CT.PlayerDataModel, DataPaths: table)
	--print("playerDataACTIVe", playerData.ActiveProfile)
	local IsUpdated = false

	for FullPath, Value in pairs(DataPaths) do
		--print("playerDataACTIVe Fulll Path", FullPath)
		local SPath = FullPath:split(".")

		local ReF = playerData.AllProfiles[playerData.ActiveProfile]
		--local ReF2 = playerData.ActiveProfile

		for i, Key in ipairs(SPath) do
			if i == #SPath then
				ReF[Key] = Value
				--ReF2[Key] = Value
			else
				if ReF[Key] == nil then
					ReF[Key] = {}
				end
				--if ReF2[Key] == nil then
				--	ReF2[Key] = {}
				--end

				ReF = ReF[Key]
				--ReF2 = ReF2[Key]
			end

		end

		IsUpdated = true
	end

	if IsUpdated then
		playerData.AllProfiles[playerData.ActiveProfile].LastUpdatedOn = workspace.ServerTime.Value --workspace:GetServerTimeNow()
	end
end

function CommonFunctions:DoesPlayerHaveAbility(playerData: CT.PlayerDataModel, abilityId)
	return CommonFunctions:GetPlayerActiveProfile(playerData).Data.EquippedInventory.Abilities[abilityId]
end

function CommonFunctions:EquipItem(_profileData :CT.ProfileSlotDataType, _itemData :CT.ItemDataType, _equip :boolean)
	if _profileData.Data.EquippedInventory[_itemData.InventoryType] then
		if _itemData.InventoryType == CD.InventoryType.Styling then
			if _equip then
				_profileData.Data.EquippedInventory[_itemData.InventoryType][_itemData.ItemType] = {Id = _itemData.Id}
			else
				if self:DoesPlayerEquipItem(_profileData, _itemData) then
					_profileData.Data.EquippedInventory[_itemData.InventoryType][_itemData.ItemType] = {Id = self:GetDefaultStylings()[_itemData.ItemType].Id}
				end
			end
		else
			if _equip then
				_profileData.Data.EquippedInventory[_itemData.InventoryType] = {Id = _itemData.Id}
			else
				if self:DoesPlayerEquipItem(_profileData, _itemData) then
					_profileData.Data.EquippedInventory[_itemData.InventoryType] = {}
				end
			end
		end
	end
end

function CommonFunctions:DoesPlayerEquipItem(_profileData: CT.ProfileSlotDataType, _itemData: CT.ItemDataType)
	local equippedInventory = _profileData.Data.EquippedInventory[_itemData.InventoryType]

	if not equippedInventory then
		return false
	end

	if _itemData.InventoryType == CD.InventoryType.Styling then
		local item = equippedInventory[_itemData.ItemType]
		return item and item.Id == _itemData.Id, item and item.Id or false
	end

	return equippedInventory.Id == _itemData.Id
end

function CommonFunctions:DoesPlayerHaveItem(_playerData: CT.PlayerDataModel, _itemData : CT.ItemDataType)
	if _playerData.OwnedInventory[_itemData.InventoryType] then
		if _playerData.OwnedInventory[_itemData.InventoryType][_itemData.ItemType] then
			return _playerData.OwnedInventory[_itemData.InventoryType][_itemData.ItemType][_itemData.Id]
		else
			return nil
		end
	end
end

function CommonFunctions:UpdateItem(storeObject, itemToAdd, add: any)

	if(storeObject[itemToAdd.Id]) then
		warn("Item already exists in the player's Data table:", itemToAdd)
		if(not add) then
			storeObject[itemToAdd.Id] = nil
		end
		return
	end
	if(add) then
		storeObject[itemToAdd.Id] = add
		--print("Item added to player's Data:", itemToAdd.Name)
	else
		storeObject[itemToAdd.Id] = nil
	end
end

function CommonFunctions:UpdateInventory(playerData: CT.PlayerDataModel, ItemData : CT.ItemDataType, Add)
	if(ItemData.ProductType) then
		if(ItemData.ProductType == Enum.InfoType.GamePass) then
			self:UpdatePassesData(playerData, ItemData.Id, Add)
		elseif(ItemData.ProductType == Enum.InfoType.Subscription) then
			self:UpdateSubscription(playerData, ItemData.Id, Add)
		end
	end

	--Update general/common inventory
	if playerData.OwnedInventory[ItemData.InventoryType] then
		if ItemData.InventoryType == CD.InventoryType.Styling then
			self:UpdateItem(playerData.OwnedInventory[ItemData.InventoryType][ItemData.ItemType], ItemData, Add)
		else
			self:UpdateItem(playerData.OwnedInventory[ItemData.InventoryType], ItemData, Add)
		end
	end

	--Update active profile inventory
	local activeProfile :CT.ProfileSlotDataType = self:GetPlayerActiveProfile(playerData)
	if(activeProfile.Data.EquippedInventory[ItemData.InventoryType]) then
		if ItemData.InventoryType == CD.InventoryType.Styling then
			self:UpdateItem(activeProfile.Data.EquippedInventory[ItemData.InventoryType][ItemData.ItemType], ItemData, Add)
		elseif(ItemData.ProductType ~= Enum.InfoType.GamePass) then
			self:UpdateItem(activeProfile.Data.EquippedInventory[ItemData.InventoryType], ItemData, Add)
		end

		--restore updated data into playerData
		playerData.AllProfiles[playerData.ActiveProfile] = activeProfile
	end
end

function CommonFunctions:UpdateProfileInventory(playerData: CT.PlayerDataModel, ItemData : CT.ItemDataType, Add)
	--Update active profile inventory
	local activeProfile :CT.ProfileSlotDataType = self:GetPlayerActiveProfile(playerData)
	if(activeProfile.Data.EquippedInventory[ItemData.InventoryType]) then
		if ItemData.InventoryType == CD.InventoryType.Styling then
			self:UpdateItem(activeProfile.Data.EquippedInventory[ItemData.InventoryType][ItemData.ItemType], ItemData, Add)
		else
			self:UpdateItem(activeProfile.Data.EquippedInventory[ItemData.InventoryType], ItemData, Add)
		end

		--restore updated data into playerData
		playerData.AllProfiles[playerData.ActiveProfile] = activeProfile
	end
end

function CommonFunctions:UpdateGoldInPlayerData(playerData:CT.PlayerDataModel, goldToUpdate:number)
	--print("[Updating Gold ] : ",playerData, goldToUpdate)
	local activeProfile :CT.ProfileSlotDataType = self:GetPlayerActiveProfile(playerData)

	activeProfile.Gold += goldToUpdate
	activeProfile.Gold = math.max(0, activeProfile.Gold)

	playerData.AllProfiles[playerData.ActiveProfile] = activeProfile
end

function CommonFunctions:UpateGemsInPlayerData(playerData:CT.PlayerDataModel, gemsToUpdate:number)
	--print("[Updating Gems ] : ",playerData, gemsToUpdate)
	local activeProfile :CT.ProfileSlotDataType = self:GetPlayerActiveProfile(playerData)

	activeProfile.Gems += gemsToUpdate
	activeProfile.Gems = math.max(0, activeProfile.Gems)

	playerData.AllProfiles[playerData.ActiveProfile] = activeProfile
end

function CommonFunctions:UpdatePlayerLevelData(playerData:CT.PlayerDataModel, levelToAdd:IntValue)

	playerData.AllProfiles[playerData.ActiveProfile].PlayerLevel += levelToAdd

	--self:UpdateXpInPlayerData(playerData, 0)
end

function CommonFunctions:UpdateXpInPlayerData(playerData:CT.PlayerDataModel, xpToAdd:IntValue)
	local activeProfile :CT.ProfileSlotDataType = self:GetPlayerActiveProfile(playerData)
	warn("Player XP to increase by:",xpToAdd," Now:", activeProfile.XP)
	local plrLevel = activeProfile.PlayerLevel

	-- Increase player-Profile wise level
	do
		local lvlData :CT.GameLevelData = CD.GameLevelsData[plrLevel]

		--print("leveldata:", lvlData)
		if lvlData and lvlData ~= {} then
			local targetXp = lvlData.XpRequired

			activeProfile.XP += xpToAdd
			activeProfile.TotalXP += xpToAdd

			if(activeProfile.XP >= targetXp) then
				local extraXp = activeProfile.XP - targetXp

				activeProfile.XP = extraXp

				--restore data in playerData
				activeProfile.LastUpdatedOn = workspace.ServerTime.Value
				playerData.AllProfiles[playerData.ActiveProfile] = activeProfile

				local nxtLvlData = CD.GameLevelsData[plrLevel + 1]
				if(nxtLvlData) then
					self:UpdatePlayerLevelData(playerData, 1)
					self:GiveLevelUpReward(playerData)
				end

				self:UpdateXpInPlayerData(playerData, 0) --Refreshing xp and lvl data to check and update.
			end
		end
	end


	return playerData
end

function CommonFunctions:UpdateSubscription(playerData: CT.PlayerDataModel, SubscriptionId, add)
	--if playerData.GamePurchases.Subscriptions[SubscriptionId] then
	playerData.GamePurchases.Subscriptions[SubscriptionId] = add
	--end
end

function CommonFunctions:UpdatePassesData(playerData: CT.PlayerDataModel, PassId, add)
	--if playerData.GamePurchases.Passes[PassId] then
	playerData.GamePurchases.Passes[PassId] = add
	--end
end

function CommonFunctions:GiveLevelUpReward(playerData:CT.PlayerDataModel, plrLevel)
	local activeProfile :CT.ProfileSlotDataType = self:GetPlayerActiveProfile(playerData)
	if not plrLevel then
		plrLevel = activeProfile.PlayerLevel
	end

	--VFXHandler:PlayEffect(nil, CD.VFXs.LevelUp, plrLevel)

	local RewardData :CT.GameLevelData = CD.GameLevelsData[plrLevel]

	if RewardData then
		if RewardData.Reward.Type == CD.LevelUpRewardType.Gold then
			CommonFunctions:UpdateGoldInPlayerData(playerData, RewardData.Reward.Amount)
		elseif RewardData.Reward.Type == CD.LevelUpRewardType.Gems then
			CommonFunctions:UpateGemsInPlayerData(playerData, RewardData.Reward.Amount)
		elseif RewardData.Reward.Type == CD.LevelUpRewardType.XP then
			CommonFunctions:UpdateXpInPlayerData(playerData, RewardData.Reward.Amount)
		end
	end
end

return CommonFunctions