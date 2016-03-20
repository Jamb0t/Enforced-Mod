
local origBuildTechData = BuildTechData
function BuildTechData()
    local techData = origBuildTechData()

	table.insert(techData, { 	[kTechDataId] = kTechId.Doomsday,
								[kTechDataCategory] = kTechId.Onos,
								[kTechDataMapName] = Doomsday.kMapName,
								[kTechDataDisplayName] = "DoomsDay",
								[kTechDataTooltipInfo] = "Self-destruct Devastation"})

	table.insert(techData, { 	[kTechDataId] = kTechId.HeavyMachineGun,
	                            [kTechDataMapName] = HeavyMachineGun.kMapName,
								[kTechDataModel] = HeavyMachineGun.kModelName,
								[kTechDataMaxHealth] = kMarineWeaponHealth,
								[kTechDataPointValue] = 7,
								[kTechDataDisplayName] = "HMG",
                                [kTechDataTooltipInfo] = "HeavyMachineGun",
								[kTechDataCostKey] = kHMGCost,
								[kStructureAttachId] = { kTechId.AdvancedArmory },
								[kStructureAttachRange] = kArmoryWeaponAttachRange })

	table.insert(techData, { 	[kTechDataId] = kTechId.Electrify,
	                            [kTechDataCostKey] = kElectricalUpgradeResearchCost,
								[kTechDataResearchTimeKey] = kElectricalUpgradeResearchTime,
								[kTechDataDisplayName] = "Electrify Extractor",
								[kTechDataTooltipInfo] = "Upgrades this extractor with an electric defense.",
								[kTechDataRequiresPower] = true,
								[kTechDataHotkey] = Move.U })

    table.insert(techData, {    [kTechDataId] = kTechId.NapalmGrenade,
	                            [kTechDataMapName] = NapalmGrenadeThrower.kMapName,
								[kTechDataDisplayName] = "Napalm grenade",
								[kTechDataCostKey] = kGasGrenadeCost })

    table.insert(techData, {    [kTechDataId] = kTechId.NapalmGrenadeProjectile,
	                            [kTechDataMapName] = NapalmGrenade.kMapName,
								[kTechDataDisplayName] = "Napalm Grenade",
								[kTechDataDamageType] = kDamageType.Flame })
								
	table.insert(techData, { 	[kTechDataId] = kTechId.MACEMP,
								[kTechDataDisplayName] = "Thruster",
								[kTechDataTooltipInfo] = "MAC_SPEED_TOOLTIP"})
    return techData
end
