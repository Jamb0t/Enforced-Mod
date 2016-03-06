
local gWeaponDescription = nil
function MarineBuy_GetWeaponDescription(techId)

    if not gWeaponDescription then
    
        gWeaponDescription = { }
        gWeaponDescription[kTechId.Axe] = "WEAPON_DESC_AXE"
        gWeaponDescription[kTechId.Pistol] = "WEAPON_DESC_PISTOL"
        gWeaponDescription[kTechId.Rifle] = "WEAPON_DESC_RIFLE"
        gWeaponDescription[kTechId.Shotgun] = "WEAPON_DESC_SHOTGUN"
        gWeaponDescription[kTechId.Flamethrower] = "WEAPON_DESC_FLAMETHROWER"
        gWeaponDescription[kTechId.GrenadeLauncher] = "WEAPON_DESC_GRENADELAUNCHER"
        gWeaponDescription[kTechId.Welder] = "WEAPON_DESC_WELDER"
        gWeaponDescription[kTechId.LayMines] = "WEAPON_DESC_MINE"
        gWeaponDescription[kTechId.ClusterGrenade] = "WEAPON_DESC_CLUSTER_GRENADE"
        gWeaponDescription[kTechId.GasGrenade] = "WEAPON_DESC_GAS_GRENADE"
		gWeaponDescription[kTechId.NapalmGrenade] = "A nade of choice for the one who loves the smell of Napalm in the morning."
        gWeaponDescription[kTechId.PulseGrenade] = "WEAPON_DESC_PULSE_GRENADE"
        gWeaponDescription[kTechId.Jetpack] = "WEAPON_DESC_JETPACK"
        gWeaponDescription[kTechId.Exosuit] = "WEAPON_DESC_EXO"
        gWeaponDescription[kTechId.DualMinigunExosuit] = "WEAPON_DESC_DUALMINIGUN_EXO"
        gWeaponDescription[kTechId.UpgradeToDualMinigun] = "WEAPON_DESC_DUALMINIGUN_EXO"
        gWeaponDescription[kTechId.ClawRailgunExosuit] = "WEAPON_DESC_CLAWRAILGUN_EXO"
        gWeaponDescription[kTechId.DualRailgunExosuit] = "WEAPON_DESC_DUALRAILGUN_EXO"
        gWeaponDescription[kTechId.UpgradeToDualRailgun] = "WEAPON_DESC_DUALRAILGUN_EXO"
        
    end
    
    local description = gWeaponDescription[techId]
    if not description then
        description = ""
    end
    
    return Locale.ResolveString(description)
    
end