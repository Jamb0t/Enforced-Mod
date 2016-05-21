
local function UpdateTechDescription( descTable )
    -- restore 295 build settings
    descTable[kTechId.Exosuit] = "WEAPON_DESC_EXO"
    descTable[kTechId.DualMinigunExosuit] = "WEAPON_DESC_DUALMINIGUN_EXO"
    descTable[kTechId.UpgradeToDualMinigun] = "WEAPON_DESC_DUALMINIGUN_EXO"
    descTable[kTechId.ClawRailgunExosuit] = "WEAPON_DESC_CLAWRAILGUN_EXO"
    descTable[kTechId.DualRailgunExosuit] = "WEAPON_DESC_DUALRAILGUN_EXO"
    descTable[kTechId.UpgradeToDualRailgun] = "WEAPON_DESC_DUALRAILGUN_EXO"
    -- Add napalm
    descTable[kTechId.NapalmGrenade] = "A nade of choice for the one who loves the smell of Napalm in the morning."   
end

local weaponDescription = nil

local oldMarineBuy_GetWeaponDescription = MarineBuy_GetWeaponDescription
function MarineBuy_GetWeaponDescription( techId )
    local result = oldMarineBuy_GetWeaponDescription(techId)

    if not weaponDescription then
        weaponDescription = GetUpValue( MarineBuy_GetWeaponDescription, "gWeaponDescription", { LocateRecurse = true } )
    end

    -- Add to table if it doesn't already exist
    if weaponDescription and not weaponDescription[kTechId.NapalmGrenade] then
        UpdateTechDescription( weaponDescription )

        -- Also update the string if needed
        result = oldMarineBuy_GetWeaponDescription(techId)
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


local displayTech = nil

local oldMarineBuy_GetEquipped = MarineBuy_GetEquipped
function MarineBuy_GetEquipped()

    local result = oldMarineBuy_GetEquipped()

    if not displayTech then
        displayTech = GetUpValue( oldMarineBuy_GetEquipped, "gDisplayTechs", { LocateRecurse = true } )
    end

    if displayTech and not displayTech[kTechId.HeavyMachineGun] then
        displayTech[kTechId.HeavyMachineGun] = true
        result = oldMarineBuy_GetEquipped()
    end
    
    return result
end