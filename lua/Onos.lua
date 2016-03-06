Script.Load("lua/DamageMixin.lua")

Onos.kHealth = 1000

local kRumbleSound = PrecacheAsset("sound/NS2.fev/alien/onos/rumble")

// used for animations and sound effects
Onos.kMaxSpeed = 7.3

Onos.kChargeUpDuration = 0.6

local kChargeStunDuration = 0.6
local kChargeStunCheckInterval = 0.08
Onos.kChargeDamage = 8

function Onos:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kOnosFov })
    
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, OnosVariantMixin)
    InitMixin(self, DamageMixin)
    
    if Client then
    
        InitMixin(self, RailgunTargetMixin)
        self.boneShieldCrouchAmount = 0
        
    end
    
    self.directionMomentum = 0
    
    self.altAttack = false
    self.stooping = false
    self.charging = false
    self.stoopIntensity = 0
    self.timeLastCharge = 0
    self.timeLastChargeEnd = 0
    self.chargeSpeed = 0
    
    if Client then
        self:SetUpdates(true)
    elseif Server then
    
        self.rumbleSound = Server.CreateEntity(SoundEffect.kMapName)
        self.rumbleSound:SetAsset(kRumbleSound)
        self.rumbleSound:SetParent(self)
        self.rumbleSound:Start()
        self.rumbleSoundId = self.rumbleSound:GetId()
        
    end
    
end

function Onos:GetMovementSpecialCooldown()
    local cooldown = 0
    local timeLeft = (Shared.GetTime() - self.timeLastChargeEnd)
    
    local chargeDelay = Onos.kChargeDelay
    if timeLeft < chargeDelay then
        return Clamp(timeLeft / chargeDelay, 0, 1)
    end
    
    return cooldown
end

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
			
			self:DoDamage(Onos.kChargeDamage, entity, self:GetOrigin(), pushForce)

			//Print(ToString(entity) .. " pushforce: " .. ToString(pushForce))

        end
		
		/*
		if HasMixin(entity, "Stun") then
			entity:SetStun(kChargeStunDuration)
		end*/
		
    end
	
	return true
	
end

function Onos:PreUpdateMove(input, runningPrediction)

    // determines how manuverable the onos is. When not charging, manuverability is 1.
    // when charging it goes towards zero as the speed increased. At zero, you can't strafe or change
    // direction.
    // The math.sqrt makes you drop manuverability quickly at the start and then drop it less and less
    // the 0.8 cuts manuverability to zero before the max speed is reached
    // Fiddle until it feels right.
    // 0.8 allows about a 90 degree turn in atrium, ie you can start charging
    // at the entrance, and take the first two stairs before you hit the lockdown.
    local manuverability = ConditionalValue(self.charging, math.max(0, 1 - math.sqrt(self:GetChargeFraction())), 1)
    local timeNow = Shared.GetTime()
	 
    if self.charging then
    
        // fiddle here to determine strafing
        input.move.x = input.move.x * math.max(0.3, manuverability)
        input.move.z = 1
        
        self:DeductAbilityEnergy(Onos.kChargeEnergyCost * input.time)
		
        // stop charging if out of energy, jumping or we have charged for a second and our speed drops below 4.5
        // - changed from 0.5 to 1s, as otherwise touchin small obstactles orat started stopped you from charging
        if self:GetEnergy() == 0 or
           self:GetIsJumping() or
          (self.timeLastCharge + 1 < timeNow and self:GetVelocity():GetLengthXZ() < 4.5) then
        
            self:EndCharge()
            
        end
        
    end
    
    if self.autoCrouching then
        self.crouching = self.autoCrouching
    end
    
    if Client and self == Client.GetLocalPlayer() then
    
        // Lower mouse sensitivity when charging, only affects the local player.
        Client.SetMouseSensitivityScalarX(manuverability)
        
    end
    
end

function Onos:TriggerCharge(move)

    if not self.charging and self:GetHasMovementSpecial() and self.timeLastChargeEnd + Onos.kChargeDelay < Shared.GetTime() and self:GetIsOnGround() and not self:GetCrouching() and not self:GetIsBoneShieldActive() then

        self.charging = true
        self.timeLastCharge = Shared.GetTime()
        
        if Server and (GetHasSilenceUpgrade(self) and GetVeilLevel(self:GetTeamNumber()) == 0) or not GetHasSilenceUpgrade(self) then
            self:TriggerEffects("onos_charge")
        end
        
		if Server then
			self:AddTimedCallback(KnockDownPlayers, kChargeStunCheckInterval)
		end
		
        self:TriggerUncloak()
    
    end
    
end

function Onos:GetMaxSpeed(possible)

    if possible then
        return Onos.kMaxSpeed
    end

    return ( Onos.kMaxSpeed + self:GetChargeFraction() * (Onos.kChargeSpeed - Onos.kMaxSpeed) ) * self:GetSlowSpeedModifier()

end

function Onos:GetTierThreeTechId()
    return kTechId.Doomsday
end