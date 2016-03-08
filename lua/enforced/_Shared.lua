kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion )

Script.Load("lua/Enforced/TechTree.lua")
Script.Load("lua/Enforced/HitSounds.lua")

Script.Load("lua/Enforced/Armory.lua")

Script.Load("lua/Enforced/Exo.lua")
Script.Load("lua/Enforced/Extractor.lua")
Script.Load("lua/Enforced/JetPackMarine.lua")

Script.Load("lua/Enforced/JetPackMarine.lua")
Script.Load("lua/Enforced/MAC.lua")
Script.Load("lua/Enforced/Marine.lua")
Script.Load("lua/Enforced/MarineCommander.lua")

Script.Load("lua/Enforced/Lerk.lua")
Script.Load("lua/Enforced/Skulk.lua")
Script.Load("lua/Enforced/Onos.lua")
Script.Load("lua/Enforced/Babbler.lua")
Script.Load("lua/Enforced/Drifter.lua")

Script.Load("lua/Weapons/Marine/HeavyMachineGun.lua")
Script.Load("lua/Weapons/Alien/Doomsday.lua")

Script.Load("lua/Weapons/Marine/NapalmGrenade.lua")
Script.Load("lua/Weapons/Marine/NapalmGrenadeThrower.lua")

//Balance.lua changes

kEMPCost = 2
kAxeDamage = 28
kOnoscideDamage = 550
kOnoscideDamageType = kDamageType.Heavy
kOnoscideRange = 12
kOnoscideEnergyCost = 95
kBileBombEnergyCost = 22
kStompResearchCost = 30
kMaxNapalmGrenades = 2
kNapalmDamagePerSecond = 11
kNapalmCloudLifetime = 6
kNapalmCloudRadius = 7
kBurnRadius = 3
kOnMarineDamageMultiplyer = 2
kDrifterCost = 6
kNanoShieldCooldown = 12
kHeavyMachineGunDamage = 5
kHeavyMachineGunDamageType = kDamageType.Puncture
kHeavyMachineGunClipSize = 100
kHeavyMachineGunWeight = 0.24
kHeavyMachineGunReloadTime = 6.4
kHeavyMachineGunClipWeight = 0.0035
kHMGCost = 25
kXenocideDamage = 160
kJetpackTechResearchTime = 80
kExosuitTechResearchTime = 80
kDrifterAbilityCooldown = 4
kElectricalDamage = 5
kElectricalMaxTargets = 3
kElectricalRange = 2.5
kElectricalUpgradeResearchCost = 15
kElectricalUpgradeResearchTime = 35
kElectrifyDamageTime = 3
kElectrifyCooldownTime = 10
kElectrifyEnergyRegain = 25
kElectrifyEnergyCost = 0

//BalanceHealth.lua changes			

kMACThrusterDuration = 5
kThrusterCooldown = 20
kLerkHealthPerBioMass = 3
kPhaseGateHealth = 2200
kInfantryPortalArmor = 400
kMatureTunnelEntranceHealth = 1450
kFadeHealthPerBioMass = 3
kScanDuration = 5
kScanRadius = 15

//BalanceMisc.lua changes

kTunnelEntranceMaturationTime = 120
kParasiteDuration = 24
kHallucinationCloudCooldown = 6
kLerkFlySoundMinSpeed = 6
kLerkAirBrakeSpeedDecrease = 8
kArmorySupply = 10
kARCSupply = 20
kRoboticsFactorySupply = 10
kCragSupply = 10
kShadeSupply = 15

-- Add napalm and hmg icons
local techIdPosition = GetUpValue(GetTexCoordsForTechId, "gTechIdPosition")
if techIdPosition then
	gTechIdPosition[kTechId.NapalmGrenade] = kDeathMessageIcon.GasGrenade
	gTechIdPosition[kTechId.HeavyMachineGun] = kDeathMessageIcon.Rifle
end

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

local original_PowerPoint_CanBeCompletedByScriptActor
original_PowerPoint_CanBeCompletedByScriptActor = Class_ReplaceMethod( "PowerPoint", "CanBeCompletedByScriptActor",
	function ( self, player )
		if player:isa("MAC") or player:isa("Marine") then
			return true
		end
		return original_PowerPoint_CanBeCompletedByScriptActor(self, player)
	end
)
