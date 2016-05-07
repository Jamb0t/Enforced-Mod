
local napalmDesc = "A nade of choice for the one who loves the smell of Napalm in the morning."

local weaponDescription = nil

local oldMarineBuy_GetWeaponDescription = MarineBuy_GetWeaponDescription
function MarineBuy_GetWeaponDescription( techId )
    local result = oldMarineBuy_GetWeaponDescription(techId)

    if not weaponDescription then
        weaponDescription = GetUpValue( MarineBuy_GetWeaponDescription, "gWeaponDescription", { LocateRecurse = true } )
    end

    -- Add to table if it doesn't already exist
    if weaponDescription and not weaponDescription[kTechId.NapalmGrenade] then
        weaponDescription[kTechId.NapalmGrenade] = napalmDesc

        -- Also update the string if needed
        if techId == kTechId.NapalmGrenade then
            result = napalmDesc
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

