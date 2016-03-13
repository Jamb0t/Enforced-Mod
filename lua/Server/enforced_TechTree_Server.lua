
-- Research/Upgrade
local orig_TechTree_AddResearchNode
orig_TechTree_AddResearchNode = Class_ReplaceMethod( "TechTree", "AddResearchNode",
    function (self, techId, prereq1, prereq2, addOnTechId)
        -- onos
        if techId == kTechId.Charge then
            self:AddActivation(kTechId.Charge, kTechId.None, kTechId.None, kTechId.AllAliens)
        elseif techId == kTechId.Stomp then
            self:AddActivation(kTechId.Doomsday, kTechId.BioMassEight, kTechId.Stomp, kTechId.AllAliens)
            orig_TechTree_AddResearchNode(self, kTechId.Stomp, kTechId.BioMassEight, kTechId.None, kTechId.AllAliens)
        -- marines
        elseif techId == kTechId.NanoShieldTech then
        -- Skip NanoShieldTech
            self:AddActivation(kTechId.MACEMP)
        elseif techId == kTechId.DualMinigunExosuit then
        -- order doesn't matter, add all the marine research here
            self:AddTargetedBuyNode(kTechId.NapalmGrenade, kTechId.GrenadeTech)
            self:AddUpgradeNode(kTechId.Electrify, kTechId.Extractor, kTechId.None)
            self:AddBuyNode(kTechId.DualMinigunExosuit, kTechId.DualMinigunTech, kTechId.TwoCommandStations)
        else
            orig_TechTree_AddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
        end
    end
)

local orig_TechTree_AddTargetedActivation
orig_TechTree_AddTargetedActivation = Class_ReplaceMethod( "TechTree", "AddTargetedActivation",
    function (self, techId, prereq1, prereq2)
        if techId == kTechId.NanoShield then
            prereq1 = kTechId.TwoCommandStations
        elseif techId == kTechId.DropShotgun then
            orig_TechTree_AddTargetedActivation(self, kTechId.HeavyMachineGun, kTechId.AdvancedArmory, kTechId.None)
        end
        orig_TechTree_AddTargetedActivation(self, techId, prereq1, prereq2)
    end
)
