-- @ScriptType: Script
local t = script.Parent


game:GetService("RunService").Heartbeat:Connect(function()
	t.Value = workspace:GetServerTimeNow()
end)