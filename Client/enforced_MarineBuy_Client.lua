
local napalmDesc = "A nade of choice for the one who loves the smell of Napalm in the morning."

local weaponDescription = GetUpValue( MarineBuy_GetWeaponDescription, "gWeaponDescription", { LocateRecurse = true } )

local oldMarineBuy_GetWeaponDescription = MarineBuy_GetWeaponDescription
function MarineBuy_GetWeaponDescription(techId)
    local string = oldMarineBuy_GetWeaponDescription(techId)

    if not weaponDescription then
        weaponDescription = GetUpValue( MarineBuy_GetWeaponDescription, "gWeaponDescription", { LocateRecurse = true } )
    end
    
    -- Add to table if it doesn't already exist
    if weaponDescription and not weaponDescription[kTechId.NapalmGrenade] then
        weaponDescription[kTechId.NapalmGrenade] = napalmDesc

        -- Also update the string if needed
        if techId == kTechId.NapalmGrenade then
            string = napalmDesc
        end
    end

    return string
end
