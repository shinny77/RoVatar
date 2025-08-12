-- @ScriptType: ModuleScript
local player = game.Players.LocalPlayer

type TooltipType = {
	text: string,
	parent: GuiObject,
	tooltipBg: TextLabel,
	show: (self: TooltipType) -> (),
	hide: (self: TooltipType) -> (),
	
	setPosition: (self: TooltipType, tooltipBg: TextLabel) -> (),
	setStyle: (self: TooltipType, tooltipBg: TextLabel) -> ()
}

local Tooltip: TooltipType = {}
Tooltip.__index = Tooltip

-- Konstruktor klasy
function Tooltip.new(text: string, parent: GuiObject)
	local self = setmetatable({}, Tooltip)
	self.__index = self
	
	self.text = text
	self.parent = parent
	
	self.parent.MouseEnter:Connect(function() self:show() end)
	self.parent.MouseLeave:Connect(function() self:hide() end)

	return self
end

-- Metoda klasy
function Tooltip:show()
	if self.tooltipBg then return end
	
	local tooltipBg = script.TooltipBg:Clone()
	
	local parent = player.PlayerGui:FindFirstChild("CustomTooltip") or Instance.new("ScreenGui", player.PlayerGui)
	parent.Name = "CustomTooltip"
	
	tooltipBg.Parent = parent
	tooltipBg.Label.Text = self.text
	
	self:setStyle(tooltipBg.Label)
	self:setSize(tooltipBg)
	self:setPosition(tooltipBg)
	self.tooltipBg = tooltipBg
end

function Tooltip:hide()
	if self.tooltipBg then
		self.tooltipBg:Destroy()
		self.tooltipBg = nil
	end
end

function Tooltip:setSize(tooltipBg:ImageLabel)
	tooltipBg.Size = UDim2.new(0, tooltipBg.Label.TextBounds.X + 10, 0, tooltipBg.Label.TextBounds.Y )
end

function Tooltip:setPosition(tooltipBg:TextLabel)
	tooltipBg.AnchorPoint = Vector2.new(0.0, 1)

	local parentPosition = self.parent.AbsolutePosition
	local parentSize = self.parent.AbsoluteSize
	local parentAnchor = self.parent.AnchorPoint
	
	local parentCenterX = parentPosition.X-- + (parentSize.X / 2) + (parentSize.X * parentAnchor.X)
	local tooltipPosY = parentPosition.Y - (tooltipBg.Size.Y.Offset / 2) - 10
	local tooltipPosX = parentCenterX
	
	tooltipBg.Position = UDim2.new(0, tooltipPosX, 0, tooltipPosY)
end

function Tooltip:setStyle(textLabel:TextLabel)
	textLabel.TextSize = 14
	
end

return Tooltip
