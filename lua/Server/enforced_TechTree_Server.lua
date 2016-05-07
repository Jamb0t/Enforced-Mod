
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
        -- Add ElectrifyTech and Electrify
			orig_TechTree_AddResearchNode(self, kTechId.ElectrifyTech, prereq1,  prereq2, addOnTechId)
			self:AddActivation(kTechId.Electrify, kTechId.ElectrifyTech)
        -- Add Thruster
            self:AddActivation(kTechId.MACEMP)
            self:AddActivation(kTechId.Electrify, kTechId.RoboticsFactory, kTechId.None)
        elseif techId == kTechId.ExosuitTech then
        -- Napalm
            orig_TechTree_AddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
            self:AddTargetedBuyNode(kTechId.NapalmGrenade, kTechId.GrenadeTech)
        -- Original
        else
            orig_TechTree_AddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
        end
    end
)

local orig_TechTree_AddTargetedActivation
orig_TechTree_AddTargetedActivation = Class_ReplaceMethod( "TechTree", "AddTargetedActivation",
    function (self, techId, prereq1, prereq2)
        if techId == kTechId.NanoShield then
        -- Add ElectrifyTech
        --    orig_TechTree_AddTargetedActivation(self, kTechId.Electrify, kTechId.ElectrifyTech)
        -- Update NanoShield prereq
            prereq1 = kTechId.TwoCommandStations
        elseif techId == kTechId.DropShotgun then
        -- Add HMG
            orig_TechTree_AddTargetedActivation(self, kTechId.HeavyMachineGun, kTechId.AdvancedArmory, kTechId.None)
        end
        -- Original
        orig_TechTree_AddTargetedActivation(self, techId, prereq1, prereq2)
    end
)
