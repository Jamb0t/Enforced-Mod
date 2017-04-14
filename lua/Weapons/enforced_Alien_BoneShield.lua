local orig_BoneShield_OnProcessMove
orig_BoneShield_OnProcessMove = Class_ReplaceMethod( "BoneShield", "OnProcessMove",
function (self, input)
    if self.primaryAttacking then
		if self:GetFuel() > 0 then
		else
            self:SetFuel( 0 )
            self.primaryAttacking = false
		end
    end
end)
