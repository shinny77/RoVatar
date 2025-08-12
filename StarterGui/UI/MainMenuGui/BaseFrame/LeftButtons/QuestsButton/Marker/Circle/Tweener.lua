-- @ScriptType: LocalScript
local TweenService = game:GetService("TweenService")

task.wait(2)
local circle = script.Parent

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

circle.Visible = true

local targetProperties = {
	ImageTransparency = 1,
	Size = UDim2.fromScale(7, 7)
}

function MakeTween()

	circle.Size = UDim2.fromScale(0, 0)
	circle.ImageTransparency = 0

	local tween = TweenService:Create(circle, tweenInfo, targetProperties)
	tween:Play()

	tween.Completed:Connect(function()
		task.wait(1.5)

		MakeTween()
	end)
end

MakeTween()