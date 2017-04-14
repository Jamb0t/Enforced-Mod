
local function UpdateTechDescription( descTable )
    -- Add napalm
    descTable[kTechId.NapalmGrenade] = "A nade of choice for the one who loves the smell of Napalm in the morning."   
end

local weaponDescription = nil

local oldMarineBuy_GetWeaponDescription = MarineBuy_GetWeaponDescription
function MarineBuy_GetWeaponDescription( techId )
    local result = oldMarineBuy_GetWeaponDescription(techId)

    if not weaponDescription then
        weaponDescription = GetUpValue( MarineBuy_GetWeaponDescription, "gWeaponDescription", { LocateRecurse = true } )
        
		-- Add to table if it doesn't already exist
		if weaponDescription and not weaponDescription[kTechId.NapalmGrenade] then
			UpdateTechDescription( weaponDescription )

			-- Also update the string if needed
			result = oldMarineBuy_GetWeaponDescription(techId)
		end
    end

    return result
end

local oldMarineBuy_GetHasGrenades = MarineBuy_GetHasGrenades
function MarineBuy_GetHasGrenades( techId )
	return oldMarineBuy_GetHasGrenades( techId ) or techId == kTechId.NapalmGrenade
end

local oldMarineBuy_GetHas = MarineBuy_GetHas
function MarineBuy_GetHas( techId )
    if techId == kTechId.NapalmGrenade then
        return oldMarineBuy_GetHas( kTechId.ClusterGrenade )
    end

    return oldMarineBuy_GetHas( techId )
end
