local newBuildTechAdded = false

local origBuildTechData = BuildTechData
function BuildTechData()
    local techData = origBuildTechData()

	if not newBuildTechAdded then
        -- Remove old webs
        local searchTech =
        {
            kTechId.NanoArmor,
        }

		for _, tech in pairs(searchTech) do
			for i, techTable in pairs(techData) do
				if techTable[kTechDataId] == tech then
					table.remove(techData, i)
				end
			end
		end

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
			
            -- Exo Nano Armor
            {
                [kTechDataId] = kTechId.NanoArmor,
                [kTechDataDisplayName] = "Exo Nano Armor Upgrade",
                [kTechDataTooltipInfo] = "Self repairing armor",
				[kTechDataCostKey] = kNanoArmorResearchCost,
				[kTechDataResearchTimeKey] = kNanoArmorResearchTime
            },			
        }

		for _, tech in pairs(newBuildTech) do
			table.insert(techData, tech)
		end

		newBuildTechAdded = true
	end

    return techData
end