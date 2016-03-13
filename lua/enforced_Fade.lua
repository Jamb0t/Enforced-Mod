// Natural Selection 2 Competitive Mod
// Source located at - https://github.com/xToken/CompMod
// Detailed breakdown of changes at https://docs.google.com/document/d/1YOnjJz6_GhioysLaWiRfc17xnrmw6AEJIb6gq7TX3Qg/edit?pli=1
// lua\CompMod\Shared\FadeBlinkAdjustments.lua
// - Dragon

local kOffsetUpdate = 0 //Full Speed
local kFadeOffsetRange = 1
local kFadeOffsetScalar = 5

local networkVars = 
{ 
    modelOffset = "compensated interpolated float", 
    updateOffset = "compensated boolean", 
    lastOffsetTime = "compensated time"
}

local originalFadeOnCreate
originalFadeOnCreate = Class_ReplaceMethod("Fade", "OnCreate",
function(self)
    originalFadeOnCreate(self)
    self.updateOffset = false
    self.modelOffset = 0
    self.lastOffsetTime = 0
end
)

local originalFadeModifyVelocity
originalFadeModifyVelocity = Class_ReplaceMethod("Fade", "ModifyVelocity",
function(self, input, velocity, deltaTime)

    originalFadeModifyVelocity(self, input, velocity, deltaTime)
    
    //Model offset for crouching blinking fades
    if self.lastOffsetTime + kOffsetUpdate < Shared.GetTime() then
        local origin = self:GetOrigin()
        //Trace up to make sure we are against the ceiling.
        //Default to no updates
        self.updateOffset = false
        local upTrace = Shared.TraceRay(origin, origin + Vector(0, Fade.YExtents + kFadeCrouchModelOffset, 0), CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOneAndIsa(self, "Babbler"))
        if upTrace.fraction > 0 and upTrace.fraction < 1 then
            //The ceiling is here.
            //Trace down to make sure we are not against the floor.
            local downTrace = Shared.TraceRay(origin, origin - Vector(0, kFadeCrouchModelOffset, 0), CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOne(self))
            if downTrace.fraction <= 0 or downTrace.fraction >= 1 then
                self.updateOffset = true
            end
        end
        self.lastOffsetTime = Shared.GetTime()
    end
    
    local crouchoffset = self:GetCrouchAmount() 
    local modelcrouchoffset = self:ModifyCrouchAnimation(crouchoffset)
    local maxoffset = (crouchoffset - modelcrouchoffset) * kFadeCrouchModelOffset
    if crouchoffset > 0 and self.updateOffset then
        if self.modelOffset < maxoffset then
            self.modelOffset = math.min(maxoffset, self.modelOffset + (input.time * kFadeOffsetScalar))
        end
    else
        if self.modelOffset > 0 then
            self.modelOffset = math.max(0, self.modelOffset - (input.time * kFadeOffsetScalar))
        end
    end

end
)

Class_AddMethod( "Fade", "OnAdjustModelCoords",
function (self, modelCoords)
    modelCoords.origin = modelCoords.origin - Vector(0, self.modelOffset, 0)
    return modelCoords
end
)

local TriggerBlinkOutEffects = GetUpValue( Blink.SetEthereal, "TriggerBlinkOutEffects", { LocateRecurse = true } )
local TriggerBlinkInEffects = GetUpValue( Blink.SetEthereal, "TriggerBlinkInEffects", { LocateRecurse = true } )
local kEtherealForce = GetUpValue( Blink.SetEthereal, "kEtherealForce", { LocateRecurse = true } )
local kEtherealVerticalForce = GetUpValue( Blink.SetEthereal, "kEtherealVerticalForce", { LocateRecurse = true } )

local originalBlinkSetEthereal
originalBlinkSetEthereal = Class_ReplaceMethod("Blink", "SetEthereal",
function(self, player, state)
    // Enter or leave ethereal mode.
    if player.ethereal ~= state then
    
        if state then
        
            player.etherealStartTime = Shared.GetTime()
            TriggerBlinkOutEffects(self, player)

            local celerityLevel = GetHasCelerityUpgrade(player) and GetSpurLevel(player:GetTeamNumber()) or 0
            local oldSpeed = player:GetVelocity():GetLengthXZ()
            local oldVelocity = player:GetVelocity()
            oldVelocity.y = 0
            local newSpeed = math.max(oldSpeed, kEtherealForce + celerityLevel * 0.5)

            // need to handle celerity different for the fade. blink is a big part of the basic movement, celerity wont be significant enough if not considered here
            local celerityMultiplier = 1 + celerityLevel * 0.10

            local newVelocity = player:GetViewCoords().zAxis * (kEtherealForce + celerityLevel * 0.5) + oldVelocity
            player:SetVelocity(newVelocity)
            if newVelocity:GetLength() > newSpeed then
                newVelocity:Scale(newSpeed / newVelocity:GetLength())
            end
            
            if player:GetIsOnGround() then
                newVelocity.y = math.max(newVelocity.y, kEtherealVerticalForce)
            end
            
            newVelocity:Add(player:GetViewCoords().zAxis * kFadeBlinkAddedAccel * celerityMultiplier)
            player:SetVelocity(newVelocity)
            player.onGround = false
            player.jumping = true
            
        else
        
            TriggerBlinkInEffects(self, player)
            player.etherealEndTime = Shared.GetTime()
            
        end
        
        player.ethereal = state        

        // Give player initial velocity in direction we're pressing, or forward if not pressing anything.
        if player.ethereal then
        
            // Deduct blink start energy amount.
            player:DeductAbilityEnergy(kStartBlinkEnergyCost)
            player:TriggerBlink()
            
        -- A case where OnBlinkEnd() does not exist is when a Fade becomes Commanders and
        -- then a new ability becomes available through research which calls AddWeapon()
        -- which calls OnHolster() which calls this function. The Commander doesn't have
        -- a OnBlinkEnd() function but the new ability is still added to the Commander for
        -- when they log out and become a Fade again.
        elseif player.OnBlinkEnd then

            player:OnBlinkEnd()

        end

    end

end
)

if Client then

	function Fade:UpdateClientEffects(deltaTime, isLocal)
		
		Alien.UpdateClientEffects(self, deltaTime, isLocal)

		if not self.trailCinematic then
			self:CreateTrailCinematic()
		end
		
		local showTrail = (self:GetIsBlinking() or self:GetIsShadowStepping()) and (not isLocal or self:GetIsThirdPerson())
		
		self.trailCinematic:SetIsVisible(showTrail)
		self.scanTrailCinematic:SetIsVisible(showTrail and self.isScanned)
		
		if self:GetIsAlive() then
		
			if self:GetIsShadowStepping() then
				self.blinkDissolve = 1    
			elseif self:GetIsBlinking() then
				self.blinkDissolve = 0.6
				self.wasBlinking = true
			else
			
				if self.wasBlinking then
					self.wasBlinking = false
					self.blinkDissolve = 1
				end    
			
				self.blinkDissolve = math.max(0, self.blinkDissolve - deltaTime)
			end
		
		else
			self.blinkDissolve = 0
		end  
		
		
		self:UpdateBlink2DSound(isLocal)
		
	end

	function Fade:UpdateBlink2DSound(isLocal)

		local playSound = self:GetIsBlinking() and not GetHasSilenceUpgrade(self) and isLocal

		if playSound and not self.blinkSoundPlaying then
		
			self:TriggerEffects("blink_loop_start")
			self.blinkSoundPlaying = true
			
		elseif not playSound and self.blinkSoundPlaying then
		
			self:TriggerEffects("blink_loop_end")
			self.blinkSoundPlaying = false
			
		end

	end
		
end

Shared.LinkClassToMap("Fade", Fade.kMapName, networkVars, true)
