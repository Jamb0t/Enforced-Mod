local orig_BoneShield_IsOnCooldown
orig_BoneShield_IsOnCooldown = Class_ReplaceMethod( "BoneShield", "IsOnCooldown",
function (self)
    return self.timeLastBoneShield + kBoneShieldCooldown > Shared.GetTime()
end)

local orig_BoneShield_OnPrimaryAttackEnd
orig_BoneShield_OnPrimaryAttackEnd = Class_ReplaceMethod( "BoneShield", "OnPrimaryAttackEnd",
function (self, player)
    if self.primaryAttacking then
        self.primaryAttacking = false
    end   
end)

local orig_BoneShield_OnProcessMove
orig_BoneShield_OnProcessMove = Class_ReplaceMethod( "BoneShield", "OnProcessMove",
function (self, input)
    if self.primaryAttacking then

        local player = self:GetParent()
        if player then

            if self.firstboneshieldframe then
                player:DeductAbilityEnergy(self:GetEnergyCost())
                self.firstboneshieldframe = false
            end

            local energy = player:GetEnergy()
            player:DeductAbilityEnergy(input.time * kBoneShieldEnergyPerSecond)

            if player:GetEnergy() == 0 then
                self.primaryAttacking = false
                self.timeLastBoneShield = Shared.GetTime()
            end
        end
    else

        self.firstboneshieldframe = true

    end
end)
