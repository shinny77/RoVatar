-- @ScriptType: ModuleScript
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Knit = require(RS.Packages.Knit)

local Custom = RS.Modules.Custom
local CD = require(Custom.Constants)


local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")


local UIController = Knit.CreateController {
	Name = "UIController",
	uiScreens = {}, --Would contains instances of all screens "ScreenGui" modules (ModuleScripts).
}

local openedScreen :string = ""

-------------------------------->>>>>>>>> Public Methods <<<<<<<<<<-------------------------------
--# Subscribe the UI module with UIController. (A central place of all UI screens)
function UIController:SubsUI(screenTyp, module)
	if(not self.uiScreens[screenTyp]) then
		self.uiScreens[screenTyp] = module
	else
		warn(module, "Requested UI module is already subscribed.")
		return false
	end
	
	--print("[UIController] new screen subscribed:", screenTyp)
	return  true
end


function UIController:ToggleScreen(screenTyp :string, visible)
	if(self.uiScreens[screenTyp]) then
		self.uiScreens[screenTyp]:Toggle(visible)
	end
end

function UIController:ToggleProcessing(enable:boolean)
	self.uiScreens[CD.UiScreenTags.LoadingGui]:ToggleProcessing(enable)
end

function UIController:GetGui(screenTyp :string, waitTime:number)
	if(self.uiScreens[screenTyp]) then
		return self.uiScreens[screenTyp]
	else
		if(waitTime) then
			local timer = 0
			repeat task.wait()
				timer += task.wait()
			until self.uiScreens[screenTyp] or timer > waitTime
			--print("Wait tomcmejrklej for", screenTyp, self.uiScreens[screenTyp])
			return self.uiScreens[screenTyp] or nil
		end
	end
	
end

function UIController:GetOpenedUI(includeList :{})
	if includeList then
		for _, screenTyp in pairs(includeList) do
			if(self.uiScreens[screenTyp]) then
				if self.uiScreens[screenTyp].IsVisible and self.uiScreens[screenTyp]:IsVisible() then
					return screenTyp
				end
			end
		end
	else
		for screenTyp, class in pairs(self.uiScreens) do
			if class.Instance and self.uiScreens[screenTyp].IsVisible and self.uiScreens[screenTyp]:IsVisible() then
				return screenTyp
			end
		end
	end
end

function UIController:KnitInit()

end

function UIController:KnitStart()
	
end

return UIController