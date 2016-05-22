local techIdToMaterialOffset = GetUpValue( GetMaterialXYOffset, "kTechIdToMaterialOffset" )
if techIdToMaterialOffset then
	techIdToMaterialOffset[kTechId.Doomsday] = 70
	techIdToMaterialOffset[kTechId.UpgradePhantomVeil] = 66
	techIdToMaterialOffset[kTechId.PhantomVeil] = 66
	techIdToMaterialOffset[kTechId.Phantom] = 66
end
