
Script.Load("lua/Exo.lua")
Script.Load("lua/Armory.lua")
Script.Load("lua/JetPackMarine.lua")
Script.Load("lua/HitSounds.lua")

Script.Load("lua/MarineBuy_Client.lua")
Script.Load("lua/Marine.lua")

Script.Load("lua/Lerk.lua")
Script.Load("lua/Skulk.lua")
Script.Load("lua/Onos.lua")
Script.Load("lua/Weapons/Marine/HeavyMachineGun.lua")
Script.Load("lua/Weapons/Alien/Doomsday.lua")

Script.Load("lua/Weapons/Marine/NapalmGrenade.lua")
Script.Load("lua/Weapons/Marine/NapalmGrenadeThrower.lua")

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

Marine.kGroundFrictionForce = 16

GetTexCoordsForTechId(kTechId.GasGrenade)
gTechIdPosition[kTechId.NapalmGrenade] = kDeathMessageIcon.GasGrenade

EvolutionChamber.kUpgradeButtons ={                            
    [kTechId.SkulkMenu] = { kTechId.Leap, kTechId.Xenocide, kTechId.None, kTechId.None,
                                kTechId.None, kTechId.None, kTechId.None, kTechId.None },
                             
    [kTechId.GorgeMenu] = { kTechId.BileBomb, kTechId.WebTech, kTechId.None, kTechId.None,
                                 kTechId.None, kTechId.None, kTechId.None, kTechId.None },
                                 
    [kTechId.LerkMenu] = { kTechId.Umbra, kTechId.Spores, kTechId.None, kTechId.None,
                                 kTechId.None, kTechId.None, kTechId.None, kTechId.None },
                                 
    [kTechId.FadeMenu] = { kTechId.MetabolizeEnergy, kTechId.MetabolizeHealth, kTechId.Stab, kTechId.None,
                                 kTechId.None, kTechId.None, kTechId.None, kTechId.None },
                                 
    [kTechId.OnosMenu] = { kTechId.None, kTechId.BoneShield, kTechId.Stomp, kTechId.None,
                                 kTechId.None, kTechId.None, kTechId.None, kTechId.None }
}

local function UpdateAirBrake(self, input, velocity, deltaTime)

    // more control when moving forward
    local holdingShift = bit.band(input.commands, Move.MovementModifier) ~= 0
    if input.move.z ~= 0 and holdingShift then
        
        if velocity:GetLengthXZ() > kLerkFlySoundMinSpeed then
            local yVel = velocity.y
			local newScale = math.max(velocity:GetLengthXZ() - (kLerkAirBrakeSpeedDecrease * deltaTime), kLerkFlySoundMinSpeed)
            velocity.y = 0
            velocity:Normalize()
            velocity:Scale(newScale)
            velocity.y = yVel
        end

    end

end

local originalLerkModifyVelocity
originalLerkModifyVelocity = Class_ReplaceMethod("Lerk", "ModifyVelocity",
	function(self, input, velocity, deltaTime)
		originalLerkModifyVelocity(self, input, velocity, deltaTime)
		UpdateAirBrake(self, input, velocity, deltaTime)
	end
)

local function ScanForNearbyEnemy(self)
local kDetectInterval = 0.5
local kDetectRange = 4.5
    // Check for nearby enemy units. Uncloak if we find any.
    self.lastDetectedTime = self.lastDetectedTime or 0
    if self.lastDetectedTime + kDetectInterval < Shared.GetTime() then
    
        if #GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kDetectRange) > 0 then
        
            self:TriggerUncloak()
            
        end
        self.lastDetectedTime = Shared.GetTime()
        
    end
    
end

ReplaceLocals(Drifter.OnUpdate, { ScanForNearbyEnemy = ScanForNearbyEnemy })

function Drifter:GetIsCamouflaged()
    return self.camouflaged
end

function PowerPoint:CanBeCompletedByScriptActor( player )

    PROFILE("PowerPoint:CanBeCompletedByScriptActor")

    if player:isa("MAC") then
            return true
    end
    
    if player:isa("Marine") then
            return true
    end

    if not self:RequirePrimedNodes() then
        -- If the server doesn't requires priming nodes in all circumstances, only require that a blueprint exists
        if self:HasUnbuiltConsumerRequiringPower() then
            return true
        end
    else
        -- Otherwise, power can only be completed when there is a fully built structure which requires power in the vicinity
        if self:HasConsumerRequiringPower() then
            return true
        end
    end
    
    return false
end

local originalMarineGetPlayerStatusDesc
originalMarineGetPlayerStatusDesc = Class_ReplaceMethod("Marine", "GetPlayerStatusDesc",
	function(self)
		local weapon = self:GetWeaponInHUDSlot(1)
		if (weapon) and self:GetIsAlive() then
			if (weapon:isa("HeavyMachineGun")) then
				return kPlayerStatus.HeavyMachineGun
			end
		end
		return originalMarineGetPlayerStatusDesc(self)
	end
)

// Call this once to generate the basics
GetTexCoordsForTechId(kTechId.Rifle)
// Add HMG
gTechIdPosition[kTechId.HeavyMachineGun] = kDeathMessageIcon.Rifle