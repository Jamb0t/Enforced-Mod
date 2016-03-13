
local techIdToMaterialOffset = GetUpValue( GetMaterialXYOffset, "kTechIdToMaterialOffset" )
if techIdToMaterialOffset then
	techIdToMaterialOffset[kTechId.HeavyMachineGun] = 73
	techIdToMaterialOffset[kTechId.Electrify] = 119
	techIdToMaterialOffset[kTechId.Doomsday] = 70
end
