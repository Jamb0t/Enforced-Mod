Script.Load("lua/GUIActionIcon.lua")

local iconOffsets = GetUpValue( GUIActionIcon.ShowIcon, "kIconOffsets", { LocateRecurse = true } )
if iconOffsets and iconOffsets["HeavyMachineGun"] == nil then
	iconOffsets["HeavyMachineGun"] = 0
end
