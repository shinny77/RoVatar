-- @ScriptType: LocalScript
local slotName = script.Parent

local RS = game:GetService("ReplicatedStorage")
local Max_Length = RS.GameElements.Configs.MaxSlotNameLength.Value

slotName:GetPropertyChangedSignal("Text"):Connect(function()
	if slotName.Text:len() > Max_Length then
		slotName.Text = slotName.Text:sub(1, Max_Length)
	end
end)
