-- why oh why have so many utility methods littered in places? and then marked local?
local function HasUpgrade(callingEntity, techId)

    if not callingEntity then
        return false
    end

    local techtree = GetTechTree(callingEntity:GetTeamNumber())

    if techtree then
        return callingEntity:GetHasUpgrade(techId)
    else
        return false
    end

end

function GetHasCamouflageUpgrade(callingEntity)
	return HasUpgrade(callingEntity, kTechId.Phantom)
end

function GetHasSilenceUpgrade(callingEntity)
	return HasUpgrade(callingEntity, kTechId.Phantom)
end
