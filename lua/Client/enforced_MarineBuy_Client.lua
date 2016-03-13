
local napalmDesc = "A nade of choice for the one who loves the smell of Napalm in the morning."

local weaponDescription = GetUpValue( MarineBuy_GetWeaponDescription, "gWeaponDescription", { LocateRecurse = true } )

local oldMarineBuy_GetWeaponDescription = MarineBuy_GetWeaponDescription
function MarineBuy_GetWeaponDescription(techId)
--    Log("DEBUG -- MarineBuy_GetWeaponDescription")
    local string = oldMarineBuy_GetWeaponDescription(techId)

    -- Add to table if it doesn't already exist
    if weaponDescription and not weaponDescription[kTechId.NapalmGrenade] then
--        Log("DEBUG -- MarineBuy_GetWeaponDescription Added napalm text")
        table.insert( weaponDescription, kTechId.NapalmGrenade, napalmDesc )
        
        -- Also update the string if needed
        if techId == kTechId.NapalmGrenade then
            string = napalmDesc
        end
    end

    return string
end
