kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion )

Script.Load("Class.lua")

-- Add the techIds to the list
local newTechIds = { 
	'Electrify', 
	'HeavyMachineGun', 
	'NapalmGrenade',
	'NapalmGrenadeProjectile', 
	'Doomsday', 
}

local kTechId = GetUpValue( StringToTechId, "gTechIdToString" )

if kTechId then
	for _, v in ipairs(newTechIds) do
		AppendToEnum( kTechId, v )
	end
end

-- Research/Upgrade
local orig_TechTree_AddResearchNode
orig_TechTree_AddResearchNode = Class_ReplaceMethod( "TechTree", "AddResearchNode", 
	function (self, techId, prereq1, prereq2, addOnTechId)
		-- onos
		if techId == kTechId.Charge then
			self:AddActivation(kTechId.Charge, kTechId.None, kTechId.None, kTechId.AllAliens)
		elseif techId == kTechId.Stomp then
			self:AddActivation(kTechId.Doomsday, kTechId.BioMassEight, kTechId.Stomp, kTechId.AllAliens)
			orig_TechTree_AddResearchNode(kTechId.Stomp, kTechId.BioMassEight, kTechId.None, kTechId.AllAliens)
		-- marines
		elseif techId == kTechId.NanoShieldTech then
			self:AddTargetedActivation(kTechId.NanoShield, kTechId.NanoShieldTech)
		elseif techId == kTechId.DualMinigunExosuit then
		-- if order doesn't matter, then we just add all the marine stuff here
			self:AddActivation(kTechId.MACEMP)
			self:AddTargetedActivation(kTechId.HeavyMachineGun, kTechId.AdvancedArmory, kTechId.None)
			self:AddTargetedBuyNode(kTechId.NapalmGrenade, kTechId.GrenadeTech)
			self:AddUpgradeNode(kTechId.Electrify, kTechId.Extractor, kTechId.None)
			self:AddBuyNode(kTechId.DualMinigunExosuit, kTechId.DualMinigunTech, kTechId.TwoCommandStations)
		else
			orig_TechTree_AddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
		end
	end
)

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