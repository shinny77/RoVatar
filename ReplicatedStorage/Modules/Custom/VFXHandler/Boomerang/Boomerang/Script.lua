-- @ScriptType: Script
local Spining = script.Spinning
Spining:Play()

local Blood1 = script.Blood
local Blood2 = script.Blood

Blood1:Emit(40)
Blood2:Emit(40)


sphere = script.Parent
a = 0
repeat
	sphere.Rotation = Vector3.new( 0, a, 0) --The second value of vector3 is a,
	wait(.01) 
	a = a+50
until pigs == 1 

