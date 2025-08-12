-- @ScriptType: ModuleScript
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Knit = require(RS.Packages.Knit)

local player = game.Players.LocalPlayer

-- Effects --
local Effects = script.Parent.Parent.Parent.Helpers.Effects

-- EVENTS --
local Replicate = RS.Remotes.Replicate



local EffectsController = Knit.CreateController {
	Name = "EffectsController",
}


-------------------------------->>>>>>>>>  <<<<<<<<<<-------------------------------


local function Init()

	local Combat = require(Effects.Combat)

	-- REMOTE HANDLER --
	Replicate.OnClientEvent:Connect(function(Action, ...)

			print("[Effect] ", Action)
		if workspace:GetAttribute("GameStarted") then
			if Action == "CamShake" then
				require(Effects.CameraShake)(...)
			elseif Action == "Hit" then
				require(Effects.Hit)(...)
			elseif Action == "Combat" then
				--require(Effects.Combat)(...)
				Combat.Perform(...)
			end
		end
	end)

	--Replicate.OnClientEvent:Connect(function(Action,Hotkey, ...) -- Using ... Allows you to send as many variables as you want
	--	if Effects:FindFirstChild(Action) and script:FindFirstChild(Action):IsA("ModuleScript") then -- If the name of a ModuleScript inside this script fits the Action parameter,
	--		require(Effects[Action])(Hotkey,...) 						-- it'll require it
	--	elseif Effects:FindFirstChild(Action) and script:FindFirstChild(Action):IsA("Folder") then
	--		require(Effects[Action][Hotkey])(...) 
	--	end
	--end)

end


function EffectsController:KnitInit()

end

function EffectsController:KnitStart()
	Init()
end

return EffectsController