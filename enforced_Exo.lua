
ReplaceLocals( Exo.GetMaxSpeed, { kMaxSpeed = 5.85 } )

	local orig_Exo_ModifyVelocity  
	orig_Exo_ModifyVelocity = Class_ReplaceMethod( "Exo", "ModifyVelocity", 
    function (self, input, velocity, deltaTime)
	if self.thrustersActive then
	if self.thrusterMode == kExoThrusterMode.Vertical then   
	velocity:Add(kUpVector * kThrusterUpwardsAcceleration * deltaTime)
    velocity.y = math.min(1, velocity.y)
	elseif self.thrusterMode == kExoThrusterMode.Horizontal then
	        local maxSpeed = self:GetMaxSpeed() + kHorizontalThrusterAddSpeed
            local wishDir = self:GetViewCoords():TransformVector(input.move)
			wishDir.y = 0
            wishDir:Normalize()
			
            local currentSpeed = wishDir:DotProduct(velocity)
            local addSpeed = math.max(0, maxSpeed - currentSpeed)			
	        if addSpeed > 0 then
                    
            local accelSpeed = kThrusterHorizontalAcceleration * deltaTime               
            accelSpeed = math.min(addSpeed, accelSpeed)
            velocity:Add(wishDir * accelSpeed)
			end
	    end
	end	
end	
)	

if Server then
	local orig_Exo_PerformEject  
	orig_Exo_PerformEject = Class_ReplaceMethod( "Exo", "PerformEject", 
    function (self)
        result = orig_Exo_PerformEject(self)
        if self:isa("JetpackMarine") then
            self:SetFuel(.2)
        end
        return result
    end
	)
end	
