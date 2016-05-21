Script.Load("lua/GUIPickups.lua")

local pickupTextureYOffsets = GetUpValue( GUIPickups.Update, "kPickupTextureYOffsets", { LocateRecurse = true } )
if pickupTextureYOffsets then
    pickupTextureYOffsets["HeavyMachineGun"] = 12
end