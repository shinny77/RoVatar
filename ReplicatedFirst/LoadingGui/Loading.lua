-- @ScriptType: LocalScript
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

_G.IsHub = workspace:WaitForChild("IsHub").Value

local divisorValue = _G.IsHub and 100 or 420

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

local DOF = game.Lighting:WaitForChild("DepthOfField")

--- Connection*
local ClickConn = nil

local random = Random.new()

local cam_Conn = nil
local function HoldCamera()
	--// Variables
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Scriptable
	local terrain = workspace:WaitForChild("Terrain")
	local camPart = _G.IsHub and terrain:WaitForChild("CameraPart_Hub") or terrain:WaitForChild("CameraPart_Tutorial") 

	cam.CFrame = camPart.CFrame

	local mouse = game:GetService("Players").LocalPlayer:GetMouse()

	if DOF then
		DOF.Enabled = true	
	end
	--// Move cam
	local maxTilt = 10
	cam_Conn = game:GetService("RunService").RenderStepped:Connect(function()
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = camPart.CFrame * CFrame.Angles(
			math.rad((((mouse.Y - mouse.ViewSizeY / 2) / mouse.ViewSizeY)) * -maxTilt),
			math.rad((((mouse.X - mouse.ViewSizeX / 2) / mouse.ViewSizeX)) * -maxTilt),
			0
		)
	end)
end


local function StartLoading()

	local assets = workspace:WaitForChild("Scripted_Items"):WaitForChild("MapsBuildings"):GetDescendants()

	local divisor = math.max(1, math.floor(#assets / divisorValue))
	local totalAssets = math.floor(#assets / divisor)

	for i = 1, totalAssets do
		local asset = assets[i]
		ContentProvider:PreloadAsync({ asset })

		local progress = i / totalAssets
		local percentage = math.clamp(progress * 100, 0, 100)

		ProcessText.Text = string.format("Loading %.1f%%", percentage)
		Filler.Size = UDim2.new(progress, 0, 1, 0)
		task.wait(random:NextNumber(0, .01))
	end

	ProcessText.Text = "Loaded successfully!"
	Filler.Size = UDim2.new(1, 0, 1, 0)
	task.wait(1)
end

function Finish()

	if ClickConn then ClickConn:Disconnect() end
	if cam_Conn then cam_Conn:Disconnect() end

	if DOF then
		DOF.Enabled = false	
	end

	SkipText.Visible = false
	Filler.Parent.Visible = false

	local tweenInfo = TweenInfo.new(1)
	local tween = TweenService:Create(SkipButton.Bar, tweenInfo, {GroupTransparency = 1})
	tween:Play()

	workspace:SetAttribute("GameLoaded", true)

	local tweenInfo = TweenInfo.new(.8)
	local tween2 = TweenService:Create(SkipButton, tweenInfo, {Position = UDim2.new(1.5, 0, .5, 0), })
	tween2:Play()

	local arr = game:GetService("CollectionService"):GetTagged("Miniature")
	for _, model in pairs(arr) do
		model:Destroy()
	end

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

task.wait(1)
task.spawn(HoldCamera)
task.wait(1)
StartLoading()
Finish()