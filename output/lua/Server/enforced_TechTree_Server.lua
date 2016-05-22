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
	elseif techId == kTechId.NanoShieldTech then
	-- Skip NanoShieldTech
	-- Add Thruster
		self:AddActivation(kTechId.MACEMP)
	elseif techId == kTechId.ExosuitTech then
	-- Napalm
		orig_TechTree_AddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
		self:AddTargetedActivation(kTechId.DropExosuit, kTechId.ExosuitTech,     kTechId.None)
		self:AddBuyNode(kTechId.Exosuit,                kTechId.ExosuitTech,     kTechId.None)
		self:AddBuyNode(kTechId.ClawRailgunExosuit,     kTechId.ExosuitTech,     kTechId.None)
		self:AddBuyNode(kTechId.UpgradeToDualMinigun,   kTechId.DualMinigunTech, kTechId.None)
		self:AddBuyNode(kTechId.UpgradeToDualRailgun,   kTechId.DualMinigunTech, kTechId.None)
		self:AddTargetedBuyNode(kTechId.NapalmGrenade,  kTechId.GrenadeTech)
	-- Original
	else
		orig_TechTree_AddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
	end
end)

local orig_TechTree_AddTargetedActivation
orig_TechTree_AddTargetedActivation = Class_ReplaceMethod( "TechTree", "AddTargetedActivation",
function (self, techId, prereq1, prereq2)
	if techId == kTechId.NanoShield then
	-- Update NanoShield prereq
		prereq1 = kTechId.TwoCommandStations
	end
	-- Original
	orig_TechTree_AddTargetedActivation(self, techId, prereq1, prereq2)
end)

local orig_TechTree_AddBuyNode
orig_TechTree_AddBuyNode = Class_ReplaceMethod( "TechTree", "AddBuyNode",
function (self, techId, prereq1, prereq2, addOnTechId)

	if techId == kTechId.Crush then
    -- personal upgrades (all alien types)
		--self:AddBuyNode(kTechId.Crush, kTechId.Shell, kTechId.None, kTechId.AllAliens)    
		orig_TechTree_AddBuyNode(self, kTechId.Carapace, kTechId.Shell, kTechId.None, kTechId.AllAliens)    
		orig_TechTree_AddBuyNode(self, kTechId.Regeneration, kTechId.Shell, kTechId.None, kTechId.AllAliens)
		
		--self:AddBuyNode(kTechId.Focus, kTechId.Veil, kTechId.None, kTechId.AllAliens)
		orig_TechTree_AddBuyNode(self, kTechId.Aura, kTechId.Veil, kTechId.None, kTechId.AllAliens)
		orig_TechTree_AddBuyNode(self, kTechId.Phantom, kTechId.Veil, kTechId.None, kTechId.AllAliens)
		
		--self:AddBuyNode(kTechId.Silence, kTechId.Spur, kTechId.None, kTechId.AllAliens)  
		orig_TechTree_AddBuyNode(self, kTechId.Celerity, kTechId.Spur, kTechId.None, kTechId.AllAliens)  
		orig_TechTree_AddBuyNode(self, kTechId.Adrenaline, kTechId.Spur, kTechId.None, kTechId.AllAliens)
	elseif techId == kTechId.Carapace or techId == kTechId.Regeneration or 
	       techId == kTechId.Aura or techId == kTechId.Vampirism or --techId == kTechId.Focus or
	       techId == kTechId.Silence or techId == kTechId.Celerity or techId == kTechId.Adrenaline then
	       -- do nothing
	else
		orig_TechTree_AddBuyNode(self, techId, prereq1, prereq2, addOnTechId)
	end
end)