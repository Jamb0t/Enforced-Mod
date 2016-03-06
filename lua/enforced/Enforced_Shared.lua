Script.Load("lua/ModularExo_Shared.lua")
Script.Load( "lua/Enforced/Elixer_Utility.lua" )
Elixer.UseVersion( 1.8 )

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

AppendToEnum( kPlayerStatus, 'HeavyMachineGun' )