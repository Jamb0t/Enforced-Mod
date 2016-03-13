
if Server then

    ModLoader.SetupFileHook( "lua/TechTree.lua", "lua/Server/enforced_TechTree_Server.lua", "post" )
    ModLoader.SetupFileHook( "lua/HitSounds.lua", "lua/Server/enforced_HitSounds_Server.lua", "post" )

elseif Client then

    ModLoader.SetupFileHook( "lua/Player.lua", "lua/Client/enforced_Player_Client.lua", "post" )
    ModLoader.SetupFileHook( "lua/NetworkMessages_Client.lua", "lua/Client/enforced_NetworkMessages_Client.lua", "post" )
    ModLoader.SetupFileHook( "lua/Scoreboard.lua", "lua/Client/enforced_Scoreboard_Client.lua", "post" )
    ModLoader.SetupFileHook( "lua/MarineBuy_Client.lua", "lua/Client/enforced_MarineBuy_Client.lua", "post" )
    ModLoader.SetupFileHook( "lua/AlienTechMap.lua", "lua/Client/enforced_AlienTechMap_Client.lua", "post" )

end

ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/enforced_TechTreeConstants.lua", "post" )
ModLoader.SetupFileHook( "lua/Globals.lua", "lua/enforced_Globals.lua", "post" )
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/enforced_TechData.lua", "post" )
ModLoader.SetupFileHook( "lua/EffectManager.lua", "lua/enforced_EffectManager.lua", "post" )

ModLoader.SetupFileHook( "lua/Balance.lua", "lua/enforced_Balance.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceHealth.lua", "lua/enforced_BalanceHealth.lua", "post" )
ModLoader.SetupFileHook( "lua/BalanceMisc.lua", "lua/enforced_BalanceMisc.lua", "post" )

ModLoader.SetupFileHook( "lua/EvolutionChamber.lua", "lua/enforced_EvolutionChamber.lua", "post" )
ModLoader.SetupFileHook( "lua/Armory.lua", "lua/enforced_Armory.lua", "post" )
ModLoader.SetupFileHook( "lua/Exo.lua", "lua/enforced_Exo.lua", "post" )
ModLoader.SetupFileHook( "lua/Extractor.lua", "lua/enforced_Extractor.lua", "post" )

ModLoader.SetupFileHook( "lua/JetpackMarine.lua", "lua/enforced_JetpackMarine.lua", "post" )
ModLoader.SetupFileHook( "lua/MAC.lua", "lua/enforced_MAC.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/enforced_Marine.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineCommander.lua", "lua/enforced_MarineCommander.lua", "post" )
ModLoader.SetupFileHook( "lua/Fade.lua", "lua/enforced_Fade.lua", "post" )
ModLoader.SetupFileHook( "lua/Lerk.lua", "lua/enforced_Lerk.lua", "post" )
ModLoader.SetupFileHook( "lua/Skulk.lua", "lua/enforced_Skulk.lua", "post" )
ModLoader.SetupFileHook( "lua/Onos.lua", "lua/enforced_Onos.lua", "post" )
ModLoader.SetupFileHook( "lua/Babbler.lua", "lua/enforced_Babbler.lua", "post" )
ModLoader.SetupFileHook( "lua/Drifter.lua", "lua/enforced_Drifter.lua", "post" )
ModLoader.SetupFileHook( "lua/PowerPoint.lua", "lua/enforced_PowerPoint.lua", "post" )

ModLoader.SetupFileHook( "lua/Weapons/Marine/Rifle.lua", "lua/Weapons/enforced_Marine_HeavyMachineGun.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/GasGrenadeThrower.lua", "lua/Weapons/enforced_Marine_NapalmGrenadeThrower.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/GasGrenade.lua", "lua/Weapons/enforced_Marine_NapalmGrenade.lua", "post" )
ModLoader.SetupFileHook( "lua/Onos.lua", "lua/Weapons/enforced_Alien_Doomsday.lua", "post" )
