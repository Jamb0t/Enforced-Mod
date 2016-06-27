local techIdToMaterialOffset = GetUpValue( GetMaterialXYOffset, "kTechIdToMaterialOffset" )
if techIdToMaterialOffset then
	techIdToMaterialOffset[kTechId.Doomsday] = 70
end
