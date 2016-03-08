kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

if Server then
    local kHitSoundEnabledForWeapon = GetUpValue( HitSound_IsEnabledForWeapon, "kHitSoundEnabledForWeapon" )

    if kHitSoundEnabledForWeapon then
        if type(kHitSoundEnabledForWeapon) == "table" then
            table.insert(kHitSoundEnabledForWeapon, kTechId.HeavyMachineGun)
        end
    end
end
