-- @ScriptType: ModuleScript
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Knit = require(RS.Packages.Knit)

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Constant = require(RS.Modules.Custom.Constants)
local SFX = require(RS.Modules.Custom.SFXHandler)

local TweenController = Knit.CreateController {
	Name = "TweenController",
}

-- Helper table
local function GetUdim(OS, Dir)
	if Dir == Constant.TweenDir.Right then
		return UDim2.new(2, OS.X.Offset, OS.Y.Scale, OS.Y.Offset)
	elseif Dir == Constant.TweenDir.Left then
		return UDim2.new(-.5, OS.X.Offset, OS.Y.Scale, OS.Y.Offset)
	elseif Dir == Constant.TweenDir.Up then
		return UDim2.new(OS.X.Scale, OS.X.Offset, -1, OS.Y.Offset)
	elseif Dir == Constant.TweenDir.Bottom then
		return UDim2.new(OS.X.Scale, OS.X.Offset, 2, OS.Y.Offset)
	elseif Dir == Constant.TweenDir.Center then
		return UDim2.new(.5, OS.X.Offset, .5, OS.Y.Offset)
	end
end

-------------------------------->>>>>>>>> Public Methods <<<<<<<<<<-------------------------------
--# Subscribe the UI module with TweenController.
function TweenController:SubsTween(Object :Frame & TextButton & ImageButton, TweenDir, EasingStyle, Size, OnComplete :()->() )
	
	if not Object then return end
	
	local OS = Object.Size
	local TS = Size or UDim2.new(OS.X.Scale - .8, OS.X.Offset, OS.Y.Scale - .8, OS.Y.Offset)
	
	local OP = Object.Position
	local TP = GetUdim(Object.Position, TweenDir)
	
	EasingStyle = EasingStyle or Enum.EasingStyle.Bounce
	
	-- Debounce to track if a tween is already in progress
	local Deb = false
	local Connection = Object:GetPropertyChangedSignal("Visible"):Connect(function()
		
		if Object.Visible then
			-- Visiblity On
			if Deb == true then return end
			
			--print("[Tween] Open ", Object)
			
			Object.Size = TS
			Object.Position = TP
			Object:TweenSizeAndPosition(OS, OP, Enum.EasingDirection.InOut, 
				EasingStyle, .5, true, function()
				if OnComplete then
					OnComplete(true)
				end
			end)
		else
			-- Visiblity Off
			if Deb == true then return end
			
			--print("[Tween] Close ", Object)
			
			Deb = true
			Object.Visible = true
			Object:TweenSizeAndPosition(TS, TP, Enum.EasingDirection.InOut, 
				Enum.EasingStyle.Quart, .3, true, function()
				Object.Visible = false
				Deb = false
				if OnComplete then
					OnComplete(false)
				end
			end)
		end
		
	end)
	
	return Connection
end

function TweenController:SubsHover(Object :Frame & TextButton & ImageButton, ScaleX, ScaleY, callback:()->())
	
	if not Object then return end
	
	local OP :UDim = Object.Position
	local OS : UDim = Object.Size
	
	if not ScaleX then
		ScaleX = (Object:IsA("ImageButton") or Object:IsA("TextButton")) and .005 or .02
	end
	if not ScaleY then
		ScaleY = ScaleX
	end
	
	local HP = UDim2.new(OP.X.Scale, OP.X.Offset, OP.Y.Scale, OP.Y.Offset)
	local HS = UDim2.new(OS.X.Scale + ScaleX, OS.X.Offset, OS.Y.Scale + ScaleY, OS.Y.Offset)

	Object.MouseEnter:Connect(function()
		if(callback) then
			task.spawn(callback, true)
		end
		SFX:Play(Constant.SFXs.Hover, true)
		Object:TweenSizeAndPosition(HS, HP, Enum.EasingDirection.InOut, Enum.EasingStyle.Bounce, .15, true)
	end)

	Object.MouseLeave:Connect(function()
		if(callback) then
			task.spawn(callback, false)
		end
		Object:TweenSizeAndPosition(OS, OP, Enum.EasingDirection.Out, Enum.EasingStyle.Bounce, .25, true)
	end)
end

function TweenController:SubsClick(Button :ImageButton)
	if not Button then return end
	
	local OS = Button.Size
	local MS = UDim2.new(OS.X.Scale - .009, OS.X.Offset, OS.Y.Scale - .015, OS.Y.Offset)
	
	local Connection = Button.Activated:Connect(function()
		
		SFX:Play(Constant.SFXs.Activate, true)
		
		Button:TweenSize(MS, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, .05, true)
		task.wait(.07)
		if Button and Button.Parent then
			Button:TweenSize(OS, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, .05, true)
		end
	end)
	return Connection
end

function TweenController:KnitInit()

end

function TweenController:KnitStart()
	
end

return TweenController