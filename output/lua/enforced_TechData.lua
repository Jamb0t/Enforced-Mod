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

            -- Phantom
			{
				[kTechDataId] = kTechId.Phantom,
				[kTechDataCategory] = kTechId.ShadeHive,
				[kTechDataDisplayName] = "PHANTOM",
				[kTechDataSponitorCode] = "M",
				[kTechDataTooltipInfo] = "PHANTOM_TOOLTIP",
				[kTechDataCostKey] = kCamouflageCost
			},
			
			-- Webs
			{
				[kTechDataId] = kTechId.WebTech,
				[kTechDataDisplayName] = "WEB",
				[kTechDataCostKey] = kWebResearchCost,
				[kTechDataResearchTimeKey] = kWebResearchTime,
				[kTechDataTooltipInfo] = "WEB_TOOLTIP"
			},			
        }

		for _, tech in pairs(newBuildTech) do
			table.insert(techData, tech)
		end

		newBuildTechAdded = true
	end

    return techData
end