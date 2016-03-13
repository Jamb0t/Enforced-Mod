
if Server then
    local soundTable = GetUpValue( HitSound_IsEnabledForWeapon, "kHitSoundEnabledForWeapon" )
    if soundTable then
        soundTable[kTechId.HeavyMachineGun] = true
    end

    local origHitSound_ChooseSound = HitSound_ChooseSound
    function HitSound_ChooseSound(hit)
        if hit.weapon == kTechId.HeavyMachineGun then
            return 2
        end

        return origHitSound_ChooseSound(hit)
    end
end
