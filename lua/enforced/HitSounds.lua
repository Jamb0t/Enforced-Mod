kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

if Server then
    local soundTable = GetUpValue( HitSound_IsEnabledForWeapon, "kHitSoundEnabledForWeapon" )

    if soundTable then
        if type(soundTable) == "table" then
            table.insert(soundTable, kTechId.HeavyMachineGun)
        end
    end
end
