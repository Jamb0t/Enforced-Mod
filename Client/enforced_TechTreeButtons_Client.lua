
local techIdToMaterialOffset = GetUpValue( GetMaterialXYOffset, "kTechIdToMaterialOffset" )
if techIdToMaterialOffset then
	techIdToMaterialOffset[kTechId.HeavyMachineGun] = 171
	techIdToMaterialOffset[kTechId.Electrify] = 119
	techIdToMaterialOffset[kTechId.Doomsday] = 70
end
