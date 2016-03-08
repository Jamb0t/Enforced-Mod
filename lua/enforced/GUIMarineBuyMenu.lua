kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

local gBigIconIndex = GetUpValue( GUIMarineBuyMenu._InitializeContent, "gBigIconIndex", { LocateRecurse = true } )
local gSmallIconIndex = GetUpValue( GUIMarineBuyMenu._InitializeItemButtons, "gSmallIconIndex", { LocateRecurse = true } )

if gBigIconIndex then
	gBigIconIndex[kTechId.HeavyMachineGun] = 2
	gBigIconIndex[kTechId.NapalmGrenade] = 13
end

if gSmallIconIndex then
	gSmallIconIndex[kTechId.HeavyMachineGun] = 1
	gSmallIconIndex[kTechId.NapalmGrenade] = 43
end

if Client then
	local WeaponDescription = GetUpValue( MarineBuy_GetWeaponDescription, "gWeaponDescription" )
	
	if not gWeaponDescription[kTechId.NapalmGrenade] then
		gWeaponDescription[kTechId.NapalmGrenade] = "A nade of choice for the one who loves the smell of Napalm in the morning."
	end
end
