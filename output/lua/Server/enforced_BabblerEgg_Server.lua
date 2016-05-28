local orig_BabblerEgg_OnConstructionComplete
orig_BabblerEgg_OnConstructionComplete = Class_ReplaceMethod("BabblerEgg", "OnConstructionComplete",
function (self)
	-- Disables also collision.
	self:SetModel(nil)
	self:TriggerEffects("babbler_hatch")
	
	local owner = self:GetOwner()
	
	for i = 1, kNumBabblersPerEgg do
	
		local babbler = CreateEntity(Babbler.kMapName, self:GetOrigin() + kBabblerSpawnPoints[i], self:GetTeamNumber())
		babbler:SetOwner(owner)
		babbler:SetSilenced(self.silenced)
		
		if owner and owner:isa("Gorge") then
			babbler:SetVariant(owner:GetVariant())
		end
		
		table.insert(self.trackingBabblerId, babbler:GetId())
		
	end
end)
