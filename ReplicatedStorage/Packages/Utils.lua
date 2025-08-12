-- @ScriptType: ModuleScript
local Utils = { };

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");

local Packages = ReplicatedStorage:WaitForChild("Packages");
local Knit = require(Packages:WaitForChild("Knit"));

local BUTTON_ICON_ROTATION_MAX = 8;
local GUI_OBJECT_SCALE_MODIFIER_DEFAULT = 0.1;
local GUI_OBJECT_ROTATION_MODIFIER_DEFAULT = 5;

local NUMBER_ABBREVIATIONS = {
	["K"] = 4,
	["M"] = 7,
	["B"] = 10,
	["Qa"] = 13
};

---- strings
function Utils.StringFirstToUpper(str: string): string
	return str:lower():gsub("^%l", string.upper);
end

---- tables
function Utils.TableAddForDuration(tbl, key, value, duration) --> coroutine
	local function Add()
		tbl[key] = value;
		wait(duration);
		tbl[key] = nil;
	end

	return coroutine.wrap(Add)();
end

---- numbers
function Utils.TimeframeGetSeconds(timeframe: number): number
	return (timeframe % 60);
end

function Utils.TimeframeGetMinutes(timeframe: number): number
	return ((timeframe % 3600) / 60);
end

function Utils.TimeframeGetHours(timeframe: number): number
	return (timeframe / 3600);
end

local function GetNumberZeroed(amount: number): string
	local str = tostring(amount);
	if (tostring(amount):len() == 1) then
		str = ("0" .. amount);
	end

	return str;
end

function Utils.TimeframeToString(timeFrame: number, includeSeconds, includeMinutes, includeHours): string
	local seconds = Utils.TimeframeGetSeconds(timeFrame);
	local minutes = math.floor(Utils.TimeframeGetMinutes(timeFrame));
	local hours = math.floor(Utils.TimeframeGetHours(timeFrame));

	local str = "";
	if (includeHours) then
		str = (str .. GetNumberZeroed(math.max(hours, 0)));

		if (includeMinutes) then
			str = (str .. ":");
		end
	end

	if (includeMinutes) then
		str = (str .. GetNumberZeroed(math.max(minutes, 0)));

		if (includeSeconds) then
			str = (str .. ":");
		end
	end

	if (includeSeconds) then
		str = (str .. GetNumberZeroed(math.max(seconds, 0)));
	end

	return str;
end

function Utils.NumberFormat(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

function Utils.AbbreviateWithText(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

	local text = tostring(math.floor(number))
	local chosenAbb = false
	for abbreviation, digits in pairs(NUMBER_ABBREVIATIONS) do
		if #text >= digits and #text < (digits + 3) then
			chosenAbb = abbreviation
		end
	end

	if chosenAbb then
		local digits = NUMBER_ABBREVIATIONS[chosenAbb]
		local rounded = math.floor(number / 10 ^ (digits - 2)) * 10 ^ (digits - 2)
		text = rounded / 10 ^ (digits - 1) .. chosenAbb
	else
		text = number
	end

	return text
end

---- ui
function Utils.UiAddScaleAnimations(guiObject: GuiBase, scaleModifier: number)
	scaleModifier = (scaleModifier or GUI_OBJECT_SCALE_MODIFIER_DEFAULT);
	local scaleLarge = (1 + scaleModifier);
	local scaleSmall = (1 - scaleModifier);

	local sizeDefault = guiObject.Size;
	local sizeLarge = UDim2.new((sizeDefault.X.Scale * scaleLarge), 0, (sizeDefault.Y.Scale * scaleLarge), 0);
	local sizeSmall = UDim2.new((sizeDefault.X.Scale * scaleSmall), 0, (sizeDefault.Y.Scale * scaleSmall), 0);

	local isButton = guiObject:IsA("GuiButton");

	local function ShouldAnimate()
		if (not isButton) then return true end;

		return guiObject.Active;
	end

	local function MouseEnter()
		if (not ShouldAnimate()) then return end;

		guiObject:TweenSize(sizeLarge, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.2, true);
	end

	local function MouseLeave()
		if (not ShouldAnimate()) then return end;

		guiObject:TweenSize(sizeDefault, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.15, true);
	end

	guiObject.MouseEnter:Connect(MouseEnter);
	guiObject.MouseLeave:Connect(MouseLeave);

	if (isButton) then
		local function MouseButton1Down()
			if (not ShouldAnimate()) then return end;

			guiObject:TweenSize(sizeSmall, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.1, true);
		end

		local function MouseButton1Up()
			if (not ShouldAnimate()) then return end;

			guiObject:TweenSize(sizeLarge, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.25, true);
		end

		guiObject.MouseButton1Down:Connect(MouseButton1Down);
		guiObject.MouseButton1Up:Connect(MouseButton1Up);
	end
end

function Utils.UiAddRotationAnimations(guiObject: GuiBase, rotationModifier: number)
	rotationModifier = (rotationModifier or GUI_OBJECT_ROTATION_MODIFIER_DEFAULT);

	local isButton = guiObject:IsA("GuiButton");

	local rotationDefault = guiObject.Rotation;
	local desiredRotation = rotationDefault;
	local possibleRotations = {(rotationDefault - rotationModifier), (rotationDefault + rotationModifier)};
	local function GetRotation()
		desiredRotation = possibleRotations[math.random(1, #possibleRotations)];
		return desiredRotation;
	end

	local function ShouldAnimate()
		if (not isButton) then return true end;

		return guiObject.Active;
	end

	local tween;
	local function TweenGuiObject(tweenInfo, rotation)
		if (tween) then tween:Cancel() end;

		tween = TweenService:Create(guiObject, tweenInfo, { Rotation = rotation });
		tween:Play();
	end

	local function MouseEnter()
		if (not ShouldAnimate()) then return end;

		local tweenInfo = TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0);
		TweenGuiObject(tweenInfo, GetRotation());
	end

	local function MouseLeave()
		if (not ShouldAnimate()) then return end;

		local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0);
		TweenGuiObject(tweenInfo, rotationDefault);
	end

	guiObject.MouseEnter:Connect(MouseEnter);
	guiObject.MouseLeave:Connect(MouseLeave);

	if (isButton) then
		local function MouseButton1Down()
			if (not ShouldAnimate()) then return end;

			local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0);
			TweenGuiObject(tweenInfo, -desiredRotation);
		end

		local function MouseButton1Up()
			if (not ShouldAnimate()) then return end;

			local tweenInfo = TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0);
			TweenGuiObject(tweenInfo, rotationDefault);
		end

		local function Activated()
			if (not ShouldAnimate()) then return end;

			local tweenInfo = TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0);
			TweenGuiObject(tweenInfo, rotationDefault);
		end

		guiObject.MouseButton1Down:Connect(MouseButton1Down);
		guiObject.MouseButton1Up:Connect(MouseButton1Up);
		guiObject.Activated:Connect(Activated);
	end
end

function Utils.UiAddSounds(guiObject: GuiBase)
	--local SFXController = Knit.GetController("SFXController");

	--local isButton = (guiObject:IsA("GuiButton") or guiObject:IsA("TextButton"));

	--local function ShouldAnimate()
	--	if (not isButton) then return true end;

	--	return guiObject.Active;
	--end

	--local function MouseEnter()
	--	if (not ShouldAnimate()) then return end;

	--	SFXController:Play("Gui Hover");
	--end

	--guiObject.MouseEnter:Connect(MouseEnter);

	--if (isButton) then
	--	local function MouseButton1Down()
	--		if (not ShouldAnimate()) then return end;

	--		SFXController:Play("Gui Press");
	--	end

	--	guiObject.MouseButton1Down:Connect(MouseButton1Down);
	--end
end

return Utils;