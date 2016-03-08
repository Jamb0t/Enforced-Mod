kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

--local function AddHMGWeapon(menu)
--	if (menu and menu[kTechId.WeaponsMenu]) then
--		local weaponsMenu = menu[kTechId.WeaponsMenu]
--		if weaponsMenu[7] ~= kTechId.HeavyMachineGun then
--			weaponsMenu[7] = kTechId.HeavyMachineGun
--		end
--	end
--end

local orig_MarineCommander_GetButtonTable
orig_MarineCommander_GetButtonTable = Class_ReplaceMethod( "MarineCommander", "GetButtonTable", 
	function (self)
		local menu = orig_MarineCommander_GetButtonTable(self)
        if (menu and menu[kTechId.WeaponsMenu]) then
            local weaponsMenu = menu[kTechId.WeaponsMenu]
            if weaponsMenu[7] ~= kTechId.HeavyMachineGun then
                weaponsMenu[7] = kTechId.HeavyMachineGun
            end
        end
		return menu
	end
)

local orig_MarineCommander_GetQuickMenuTechButtons
orig_MarineCommander_GetQuickMenuTechButtons = Class_ReplaceMethod( "MarineCommander", "GetQuickMenuTechButtons",
    function (self, techId)
        local menu = orig_MarineCommander_GetQuickMenuTechButtons(self, techId)
        if (menu and menu[kTechId.WeaponsMenu]) then
            local weaponsMenu = menu[kTechId.WeaponsMenu]
            if weaponsMenu[7] ~= kTechId.HeavyMachineGun then
                weaponsMenu[7] = kTechId.HeavyMachineGun
            end
        end
        return menu
    end
)