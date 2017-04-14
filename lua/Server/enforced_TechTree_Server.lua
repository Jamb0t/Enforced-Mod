-- Research/Upgrade
local orig_TechTree_AddResearchNode
orig_TechTree_AddResearchNode = Class_ReplaceMethod( "TechTree", "AddResearchNode",
function (self, techId, prereq1, prereq2, addOnTechId)
	-- Aliens
	if techId == kTechId.Charge then
	-- Skip Charge
		self:AddActivation(kTechId.Charge, kTechId.None, kTechId.None, kTechId.AllAliens)
	elseif techId == kTechId.Stomp then
	-- Add Doomsday
		self:AddActivation(kTechId.Doomsday, kTechId.BioMassEight, kTechId.Stomp, kTechId.AllAliens)
	-- Change stomp
		orig_TechTree_AddResearchNode(self, kTechId.Stomp, kTechId.BioMassEight, kTechId.None, kTechId.AllAliens)

	-- Marines
	elseif techId == kTechId.PowerSurgeTech then
		-- do nothing
	elseif techId == kTechId.NanoShieldTech then
	-- Skip NanoShieldTech
	-- Add Thruster
           self:AddActivation(kTechId.MACEMP)
	elseif techId == kTechId.ExosuitTech then
	-- Napalm
		orig_TechTree_AddResearchNode(self, techId, prereq1, prereq2)
		self:AddTargetedBuyNode(kTechId.NapalmGrenade,  kTechId.GrenadeTech)
	-- Original
	else
		orig_TechTree_AddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
	end
end)

