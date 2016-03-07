Script.Load("lua/EffectManager.lua")

local hmgMaterial = {decal = "cinematics/vfx_materials/decals/bullet_hole_01.material", scale = 0.15, doer = "HeavyMachineGun", done = true}
local hmgDrawSound = {player_sound = "sound/compmod.fev/compmod/marine/hmg/hmg_draw", classname = "HeavyMachineGun", done = true}
local hmgReloadSound = {player_sound = "sound/compmod.fev/compmod/marine/hmg/hmg_reload", classname = "HeavyMachineGun"}
local hmgReloadCancelSound = {stop_sound = "sound/compmod.fev/compmod/marine/hmg/hmg_reload", classname = "HeavyMachineGun"}
local napalmCinematic = {parented_cinematic = "cinematics/marine/grenades/napalm_explo.cinematic"}
local napalmSound = {sound = "sound/NS2.fev/marine/grenades/gas/explode"},

local original_EffectManager_AddEffectData
original_EffectManager_AddEffectData = Class_ReplaceMethod("EffectManager", "AddEffectData",
	function(self, identifier, data)
		if (identifier == "DamageEffects")
			if (data and data.damage_decal and data.damage_decal.damageDecals)
				local top = data.damage_decal.damageDecal
				table.insert(top, hmgMaterial)
			end
		elseif (identifier == "MarineWeaponEffects")
			if (data and data.draw and data.draw.marineWeaponDrawSounds)
				local top = data.draw.marineWeaponDrawSounds
				table.insert(top, 2, hmgDrawSound)
			end
			
			if (data and data.reload and data.reload.gunReloadEffects)
				local top = data.reload.gunReloadEffects
				table.insert(top, 2, hmgReloadSound)
			end
			
			if (data and data.reload_cancel and data.reload.gunReloadCancelEffects)
				local top = data.reload.gunReloadCancelEffects
				table.insert(top, 2, hmgReloadCancelSound)
			end
			
			if (data and not data.release_napalm)
				data["release_napalm"] = { releaseNapalmEffects = {} }
				local effects = data.release_napalm.releaseNapalmEffects
				table.insert(effects, napalmCinematic)
				table.insert(effects, napalmSound)				
			end
		end

		original_EffectManager_AddEffectData(self, identifier, data)
	end
)
