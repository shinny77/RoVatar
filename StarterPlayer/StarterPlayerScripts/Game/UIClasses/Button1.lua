-- @ScriptType: ModuleScript
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Fusion = require(Packages.Fusion)
local New, Children, OnEvent, Ref, Tween, Value = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.Ref, Fusion.Tween, Fusion.Value

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Button1 = {}
Button1.__index = Button1
Button1.Buttons = {}

function Button1.new(...)
    local self = setmetatable({}, Button1)
    return self:Constructor(...) or self
end

function Button1.get(Instance)
    return Button1.Buttons[Instance]
end

function Button1:Constructor(Props)
    local Element = New "ImageButton" {
        Name = Props.Name,
        AnchorPoint = Vector2.new(.5, .5),
        Position = Props.Position,
        Size = Props.Size,
        Image = Props.Image,
        BackgroundColor3 = Color3.fromRGB(),
        LayoutOrder = Props.LayoutOrder,
        Visible = Props.Visible,

        [Ref] = Props[Ref],

        [OnEvent "MouseEnter"] = function()
            self:OnMouseEnter()
        end,

        [OnEvent "MouseLeave"] = function()
            self:OnMouseLeave()
        end,
        
        [Children] = {
            New "UIAspectRatioConstraint" {
                AspectRatio = 1
            },
            table.unpack(Props[Children] or {})
        }
    }

    Button1.Buttons[Element] = self

    self.Instance = Element
    self.OriginalProps = {
        Size = Props.Size
    }

    return Element
end

function Button1:OnMouseEnter()
    TweenService:Create(
        self.Instance,
        TweenInfo.new(.1),
        {Size = self.Instance.Size + UDim2.fromOffset(7, 7)}
    ):Play()
end

function Button1:OnMouseLeave()
    TweenService:Create(
        self.Instance,
        TweenInfo.new(.1),
        self.OriginalProps
    ):Play()
end

function Button1:OnClick()
    if not self.Instance.Visible then
        return
    end

    local InstanceAbsPos = self.Instance.AbsolutePosition
    local InstanceAbsSize = self.Instance.AbsoluteSize

    local Transparency = Value(.6)
    local Size = Value(UDim2.fromOffset(InstanceAbsSize.X, InstanceAbsSize.Y))

    local _TweenInfo = TweenInfo.new(.2)

    local Element = New "Frame" {
        Parent = PlayerGui.Interface,
        Size = Tween(Size, _TweenInfo),
        Position = UDim2.fromOffset(InstanceAbsPos.X + InstanceAbsSize.X/2, InstanceAbsPos.Y + InstanceAbsSize.Y/2),
        BackgroundTransparency = Tween(Transparency, _TweenInfo),
        AnchorPoint = Vector2.new(.5, .5)
    }

    Transparency:set(1)
    Size:set(Size:get() + UDim2.fromOffset(15, 15))

    Debris:AddItem(Element, _TweenInfo.Time)
end

return {
    render = function(Props)
        return Button1.new(Props)
    end,
    class = Button1
}