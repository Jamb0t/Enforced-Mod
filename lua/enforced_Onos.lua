
Script.Load("lua/DamageMixin.lua")

local kHealth = 1000
local kMaxSpeed = 7.3
local kChargeStunDuration = 0.6
local kChargeStunCheckInterval = 0.08
local kChargeDamage = 8

-- OnCreate
local orig_Onos_OnCreate
orig_Onos_OnCreate = Class_ReplaceMethod( "Onos", "OnCreate",
	function (self)
		InitMixin(self, DamageMixin)
		orig_Onos_OnCreate(self)
	end
)

-- GetBaseHealth
local orig_Onos_GetBaseHealth
orig_Onos_GetBaseHealth = Class_ReplaceMethod( "Onos", "GetBaseHealth",
	function (self)
		return kHealth
	end
)

-- TriggerCharge
local orig_Onos_TriggerCharge
orig_Onos_TriggerCharge = Class_ReplaceMethod( "Onos", "TriggerCharge",
function (self, move)
	if Server then
		self:AddTimedCallback(KnockDownPlayers, kChargeStunCheckInterval)
	end
end
)

local function KnockDownPlayers(self)

	if not self.charging then
		return false
	end

	local velocity = self:GetVelocity()
	local chargeDirection = GetNormalizedVectorXZ(velocity)

    for _, entity in ipairs(GetEntitiesWithinRange("Player", self:GetOrigin() + chargeDirection * 1.4, 1.6)) do

		local isEnemy = GetEnemyTeamNumber(self:GetTeamNumber()) == entity:GetTeamNumber()
        if isEnemy and not entity:isa("Exo") and not entity:isa("Spectator") and entity:GetIsAlive()  then

			local pushForce = GetNormalizedVectorXZ(entity:GetOrigin() - self:GetOrigin())
			local dot = Clamp(chargeDirection:DotProduct(pushForce), 0, 1)
			local speed = math.max( velocity:GetLengthXZ() * dot, 9) + 2

			pushForce:Scale(speed)
			if entity:GetIsOnGround() and not entity:GetIsJumping() then
				pushForce:Add(Vector(0, 1.5, 0))
			end
			entity:DisableGroundMove(0.1)
            entity:SetVelocity(pushForce)

			self:DoDamage(kChargeDamage, entity, self:GetOrigin(), pushForce)

			--Print(ToString(entity) .. " pushforce: " .. ToString(pushForce))
        end

		--if HasMixin(entity, "Stun") then
		--	entity:SetStun(kChargeStunDuration)
		--end

    end

	return true

end

-- GetMaxSpeed
local orig_Onos_GetMaxSpeed
orig_Onos_GetMaxSpeed = Class_ReplaceMethod( "Onos", "GetMaxSpeed",
	function (self, possible)
		if possible then
			return kMaxSpeed
		end

		return (kMaxSpeed + self:GetChargeFraction() * (kChargeSpeed - kMaxSpeed)) * self:GetSlowSpeedModifier()
	end
)

Class_AddMethod( "Onos", "GetMovementSpecialCooldown",
	function (self)
		local cooldown = 0
		local timeLeft = (Shared.GetTime() - self.timeLastChargeEnd)

		local chargeDelay = self.kChargeDelay
		if timeLeft < chargeDelay then
			return Clamp(timeLeft / chargeDelay, 0, 1)
		end

		return cooldown
	end
)

if Server then
    local orig_Onos_GetTierThreeTechId
    orig_Onos_GetTierThreeTechId = Class_ReplaceMethod( "Onos", "GetTierThreeTechId",
        function (self)
            return kTechId.Doomsday
        end
    )
end
