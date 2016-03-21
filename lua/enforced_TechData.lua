
local newBuildTechAdded = false

local origBuildTechData = BuildTechData
function BuildTechData()
    local techData = origBuildTechData()

	if not newBuildTechAdded then

        local newBuildTech =
        {
            -- Doomsday
            {
                [kTechDataId] = kTechId.Doomsday,
                [kTechDataCategory] = kTechId.Onos,
                [kTechDataMapName] = Doomsday.kMapName,
                [kTechDataDisplayName] = "DoomsDay",
                [kTechDataTooltipInfo] = "Self-destruct Devastation"
            },

            -- HMG
            {
                [kTechDataId] = kTechId.HeavyMachineGun,
                [kTechDataMapName] = HeavyMachineGun.kMapName,
                [kTechDataModel] = HeavyMachineGun.kModelName,
                [kTechDataMaxHealth] = kMarineWeaponHealth,
                [kTechDataPointValue] = 7,
                [kTechDataDisplayName] = "HMG",
                [kTechDataTooltipInfo] = "HeavyMachineGun",
                [kTechDataCostKey] = kHMGCost,
                [kStructureAttachId] = { kTechId.AdvancedArmory },
                [kStructureAttachRange] = kArmoryWeaponAttachRange
            },

            -- Electrify
            {
                [kTechDataId] = kTechId.Electrify,
                [kTechDataCostKey] = kElectrifyCost,
                [kTechDataCooldown] = kElectrifyCooldownTime,
                [kTechDataDisplayName] = "Electrify Extractor",
                [kTechDataTooltipInfo] = "Does damage to aliens near the extractor.",
                [kTechDataRequiresPower] = true,
                [kTechDataHotkey] = Move.U
            },

            {
                [kTechDataId] = kTechId.ElectrifyTech,
                [kTechDataDisplayName] = "Electrify Extractor Tech",
                [kTechDataTooltipInfo] = "Does damage to aliens near the extractor.",
                [kTechDataCostKey] = kElectrifyTechResearchCost,
                [kTechDataResearchTimeKey] = kElectrifyTechResearchTime
            },

            -- Napalm
            {
                [kTechDataId] = kTechId.NapalmGrenade,
                [kTechDataMapName] = NapalmGrenadeThrower.kMapName,
                [kTechDataDisplayName] = "Napalm grenade",
                [kTechDataCostKey] = kGasGrenadeCost
            },

            {
                [kTechDataId] = kTechId.NapalmGrenadeProjectile,
                [kTechDataMapName] = NapalmGrenade.kMapName,
                [kTechDataDisplayName] = "Napalm Grenade",
                [kTechDataDamageType] = kDamageType.Flame
            },

            -- Thruster
            {
                [kTechDataId] = kTechId.MACEMP,
                [kTechDataDisplayName] = "Thruster",
                [kTechDataTooltipInfo] = "MAC_SPEED_TOOLTIP"
            },

        }
	
		for _, tech in pairs(newBuildTech) do
			table.insert(techData, tech)
		end

		newBuildTechAdded = true
	end

    return techData
end
