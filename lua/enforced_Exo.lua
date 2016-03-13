
ReplaceLocals( Exo.GetMaxSpeed, { kMaxSpeed = 5.85 } )
ReplaceLocals( Exo.ModifyVelocity, { kThrusterUpwardsAcceleration = 20, kHorizontalThrusterAddSpeed = 2.2, kThrusterHorizontalAcceleration = 50 } )

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
