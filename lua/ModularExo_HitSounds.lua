Script.Load("lua/HitSounds.lua")

    local kHitSoundEnabledForWeapon =
        set {
            kTechId.Axe, kTechId.Welder, kTechId.Pistol, kTechId.Rifle, kTechId.Shotgun, kTechId.Flamethrower, kTechId.GrenadeLauncher, kTechId.HeavyMachineGun,
            kTechId.Claw, kTechId.Minigun, kTechId.Railgun,
            kTechId.Bite, kTechId.Parasite, kTechId.Xenocide, 
            kTechId.Spit, 
            kTechId.LerkBite, kTechId.Spikes, 
            kTechId.Swipe, kTechId.Stab, 
            kTechId.Gore,
        }
        
        
    function HitSound_IsEnabledForWeapon( techId )
        return techId and kHitSoundEnabledForWeapon[techId]
    end
