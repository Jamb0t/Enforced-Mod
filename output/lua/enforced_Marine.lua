kElixerVersion = 1.8
Script.Load("lua/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion )

kJumpHeightFactor = 0.74
local kStrafeJumpForce = 1

local orig_Marine_ModifyJump
orig_Marine_ModifyJump = Class_ReplaceMethod( "Marine", "ModifyJump",
function (self, input, velocity, jumpVelocity)
    jumpVelocity.y = jumpVelocity.y * kJumpHeightFactor

    local isStrafeJump = input.move.z == 0 and input.move.x ~= 0

    if self:GetIsSprinting() then
        local longjumpBonus = GetNormalizedVectorXZ(self:GetViewCoords().zAxis)
        longjumpBonus:Scale(self:GetSlowSpeedModifier() - 0.9)
        jumpVelocity:Add(longjumpBonus)
    end

    if isStrafeJump then
        jumpVelocity.y = jumpVelocity.y * 0.8
    else
        self.strafeJumped = false
    end
end)

local orig_Marine_GetPlayerStatusDesc
orig_Marine_GetPlayerStatusDesc = Class_ReplaceMethod("Marine", "GetPlayerStatusDesc",
function(self)
    local weapon = self:GetWeaponInHUDSlot(1)
    if self:GetIsAlive() and weapon and weapon:isa("HeavyMachineGun") then
        return kPlayerStatus.HeavyMachineGun
    end

    return orig_Marine_GetPlayerStatusDesc(self)
end)

local orig_Marine_ModifyGravityForce
orig_Marine_ModifyGravityForce = Class_ReplaceMethod("Marine", "ModifyGravityForce",
function (self, gravityTable)
    if self:GetIsOnGround() or self:GetRecentlyJumped() then
        gravityTable.gravity = 0
    end
end)

Class_AddMethod( "Marine", "OnPhaseGateEntry",
function (self, destinationOrigin)
    local velocity = self:GetVelocity()

    local aliums = GetEntitiesWithinRange("Skulk", destinationOrigin, 1.5)
    table.copy(GetEntitiesWithinRange("Lerk", destinationOrigin, 1.5), aliums, true)

    for _, entity in ipairs(aliums) do
        local isEnemy = GetEnemyTeamNumber(self:GetTeamNumber()) == entity:GetTeamNumber()
        if isEnemy and not entity:isa("Spectator") and HasMixin( entity, "Pushable" ) and entity:GetIsAlive() then

            local pushForce = GetNormalizedVectorXZ(entity:GetOrigin() - destinationOrigin)
            local speed = math.max( velocity:GetLengthXZ(), 1)

            pushForce:Scale(speed)
            if entity:GetIsOnGround() and self.jumping then
                pushForce:Add(Vector(0, 0, 0))
            end
            entity:Push( pushForce, 0.1, true )
        end
    end

    return true
end)
