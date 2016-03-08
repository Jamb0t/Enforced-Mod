kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion )

-- why can't I just add the enums I want? ...
Script.Load("lua/TechTreeConstants.lua")

-- Add the techIds to the list
local newTechIds = { 
	'Electrify', 
	'HeavyMachineGun', 
	'NapalmGrenade',
	'NapalmGrenadeProjectile', 
	'Doomsday', 
}

-- For some reason elixir tries to index two elements past kTechId.Max
-- No idea what they're trying to accomplish, but this method will move Max up to accomodate the list of techIds.AppendToEnum
-- This seems to work, so I'm going to do it this way instead
local function AppendTechIds( newTech )
    local max = tonumber(kTechId.Max)
    local count = #newTech
    local last = max + count
    
    rawset( kTechId, 'Max', last )
    rawset( kTechId, last, 'Max' )
    
    for i, v in ipairs(newTech) do
        local idx = max + i - 1
        rawset( kTechId, v, idx )
	    rawset( kTechId, idx, v )
    end
end

if kTechId then
    AppendTechIds(newTechIds)
end

if Server then
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
            -- if order doesn't matter, then we just add all the marine stuff here
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
end

local function AddTechChanges(techData)

	table.insert(techData, { 	[kTechDataId] = kTechId.Doomsday,           
								[kTechDataCategory] = kTechId.Onos,
								[kTechDataMapName] = Doomsday.kMapName,   
								[kTechDataDisplayName] = "DoomsDay",
								[kTechDataTooltipInfo] = "Self-destruct Devastation"})		

	table.insert(techData, { 	[kTechDataId] = kTechId.HeavyMachineGun,
	                            [kTechDataMapName] = HeavyMachineGun.kMapName,
								[kTechDataModel] = HeavyMachineGun.kModelName,
								[kTechDataMaxHealth] = kMarineWeaponHealth,
								[kTechDataPointValue] = 7,
								[kTechDataDisplayName] = "HMG",
                                [kTechDataTooltipInfo] = "HeavyMachineGun",
								[kTechDataCostKey] = kHMGCost,
								[kStructureAttachId] = { kTechId.AdvancedArmory }, 
								[kStructureAttachRange] = kArmoryWeaponAttachRange })	
								
	table.insert(techData, { 	[kTechDataId] = kTechId.Electrify,
	                            [kTechDataCostKey] = kElectricalUpgradeResearchCost,
								[kTechDataResearchTimeKey] = kElectricalUpgradeResearchTime,
								[kTechDataDisplayName] = "Electrify Extractor",
								[kTechDataTooltipInfo] = "Upgrades this extractor with an electric defense.",
								[kTechDataHotkey] = Move.U })							

    table.insert(techData, {    [kTechDataId] = kTechId.NapalmGrenade,
	                            [kTechDataMapName] = NapalmGrenadeThrower.kMapName,
								[kTechDataDisplayName] = "Napalm grenade",
								[kTechDataCostKey] = kGasGrenadeCost })

    table.insert(techData, {    [kTechDataId] = kTechId.NapalmGrenadeProjectile,
	                            [kTechDataMapName] = NapalmGrenade.kMapName,
								[kTechDataDisplayName] = "Napalm Grenade",
								[kTechDataDamageType] = kDamageType.Flame })								
																
	for index, record in ipairs(techData) do		
		if record[kTechDataId] == kTechId.MACEMP then
		    record[kTechDataDisplayName] = "Thruster"
			record[kTechDataTooltipInfo] = "MAC_SPEED_TOOLTIP"
		end
    end
end

local oldBuildTechData = BuildTechData
function BuildTechData()
	local techData = oldBuildTechData()
	AddTechChanges(techData)
	return techData
end