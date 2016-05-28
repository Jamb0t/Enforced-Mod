local orig_BoneShield_IsOnCooldown
orig_BoneShield_IsOnCooldown = Class_ReplaceMethod( "BoneShield", "IsOnCooldown",
function (self)
    return self.timeLastBoneShield + kBoneShieldCooldown > Shared.GetTime()
end)

local orig_BoneShield_OnPrimaryAttack
orig_BoneShield_OnPrimaryAttack = Class_ReplaceMethod( "BoneShield", "OnPrimaryAttack",
function (self, player)
    if not self.primaryAttacking then
        if self:GetEnergyCost() < player:GetEnergy() and player:GetIsOnGround() and self:GetCanUseBoneShield(player) then
            player:DeductAbilityEnergy(self:GetEnergyCost())
            self.primaryAttacking = true
            self.timeLastBoneShield = Shared.GetTime()
        end
    end
end)


local orig_BoneShield_OnPrimaryAttackEnd
orig_BoneShield_OnPrimaryAttackEnd = Class_ReplaceMethod( "BoneShield", "OnPrimaryAttackEnd",
function (self, player)
    if self.primaryAttacking then 
        -- Start cooldown from this point
        self.timeLastBoneShield = Shared.GetTime() - kBoneShieldMaxDuration
        self.primaryAttacking = false
    end    
end)

local orig_BoneShield_OnProcessMove
orig_BoneShield_OnProcessMove = Class_ReplaceMethod( "BoneShield", "OnProcessMove",
function (self, input)
    if self.primaryAttacking then
        local player = self:GetParent()
        if player then
            player:DeductAbilityEnergy(input.time * kBoneShieldEnergyPerSecond)

            if player:GetEnergy() == 0 then
                self.primaryAttacking = false
                self.timeLastBoneShield = Shared.GetTime()
            end
        end
    end
end)
