kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

local kPickupTextureYOffsets = GetUpValue( GUIPickups.Update, "kPickupTextureYOffsets", { LocateRecurse = true } )

if kPickupTextureYOffsets then
	kPickupTextureYOffsets["HeavyMachineGun"] = 2
end
