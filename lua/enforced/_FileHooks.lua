
if Server then
	ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/Enforced/TechTree.lua", "post" )
	ModLoader.SetupFileHook( "lua/AlienTechMap.lua", "lua/Enforced/AlienTechMap.lua", "post" )

	ModLoader.SetupFileHook( "lua/MarineCommander_Server.lua", "lua/Enforced/MarineCommander_Server.lua", "post" )
		
elseif Client then

	ModLoader.SetupFileHook( "lua/GUIActionIcon.lua", "lua/Enforced/GUIActionIcon.lua", "post"  )
	ModLoader.SetupFileHook( "lua/GUIMarineBuyMenu.lua", "lua/Enforced/GUIMarineBuyMenu.lua", "post"  )
	ModLoader.SetupFileHook( "lua/GUIMinimap.lua", "lua/Enforced/GUIMinimap.lua", "post"  )
	ModLoader.SetupFileHook( "lua/GUIPickups.lua", "lua/Enforced/GUIPickups.lua", "post"  )
	
end

ModLoader.SetupFileHook( "lua/EffectManager.lua", "lua/Enforced/EffectManager.lua", "post" )
ModLoader.SetupFileHook( "lua/HitSounds.lua", "lua/Enforced/HitSounds.lua", "post" )
