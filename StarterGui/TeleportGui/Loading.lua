-- @ScriptType: LocalScript
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

-- Remove the default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local LoadingGui = script.Parent
LoadingGui.Parent = PlayerGui

local ProcessText = LoadingGui.BaseFrame.Bar.ProcessText
local Filler = LoadingGui.BaseFrame.Bar.Filler
local SkipButton = LoadingGui.BaseFrame

local SkipText = SkipButton.SkipText

local Config = LoadingGui.Configuration
local SkipTime = Config.SkipTime.Value

--- Connection*
local ClickConn = nil

local random = Random.new()

Filler.Size = UDim2.new(1, 0, 1, 0)
local function StartLoading()
	local assets = workspace:WaitForChild("Scripted_Items"):WaitForChild("MapsBuildings"):GetDescendants()

	local divisor = math.max(1, math.floor(#assets / 3000))
	local totalAssets = math.floor(#assets / divisor)

	while true do
		ProcessText.Text = "Teleporting."
		task.wait(.5)
		ProcessText.Text = "Teleporting.."
		task.wait(.5)
		ProcessText.Text = "Teleporting..."
		task.wait(.5)
	end
	
	task.wait(1)
end

function Finish()

	if ClickConn then ClickConn:Disconnect() end
	workspace:SetAttribute("GameLoaded", true)

	SkipText.Visible = false
	Filler.Parent.Visible = false

	local tweenInfo = TweenInfo.new(1)
	local tween = TweenService:Create(SkipButton.Bar, tweenInfo, {GroupTransparency = 1})
	tween:Play()

	task.wait(1)
	local tweenInfo = TweenInfo.new(.8)
	local tween2 = TweenService:Create(SkipButton, tweenInfo, {Position = UDim2.new(1.5, 0, .5, 0), })
	tween2:Play()
	tween2.Completed:Once(function()
		LoadingGui:Destroy()
		tween2:Destroy()
		tween:Destroy()
		script:Destroy()
	end)
end

-- Show the skip button after 5 seconds
task.delay(SkipTime, function()
	ClickConn = SkipButton.Activated:Connect(function()
		Finish()
	end)

	SkipText.Visible = true
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(SkipText, tweenInfo, {
		TextTransparency = 1,
	})
	tween:Play()
end)

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local customLoadingScreen = TeleportService:GetArrivingTeleportGui()
if customLoadingScreen then
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	customLoadingScreen.Parent = PlayerGui
	task.wait(4)
	ProcessText.Text = "Teleported Successfully!"
	task.wait(2)
	customLoadingScreen:Destroy()
	Finish()
else
	task.wait(2)
	StartLoading()
	Finish()
end