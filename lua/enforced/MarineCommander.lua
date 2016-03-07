kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

local function AddHMGWeapon(menu)
	if (menu and menu[kTechId.WeaponsMenu])
		local weaponsMenu = menu[kTechId.WeaponsMenu]
		if weaponsMenu[7] ~= kTechId.HeavyMachineGun
			weaponsMenu[7] = kTechId.HeavyMachineGun
		end
	end
end

local orig_MarineCommander_GetButtonTable
orig_MarineCommander_GetButtonTable = Class_ReplaceMethod( "MarineCommander", "GetButtonTable", 
	function (self)
		local menu = orig_MarineCommander_GetButtonTable(self)
		ADDHMGWeapon(menu)
		return menu
	end
)

local MarineMenuButtons = GetUpValue( MarineCommander.GetQuickMenuTechButtons, "gMarineMenuButtons" )

if MarineMenuButtons
	AddHMGWeapon(MarineMenuButtons)
end
