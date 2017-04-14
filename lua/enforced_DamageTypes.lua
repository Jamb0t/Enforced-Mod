do
	local index = #kDamageType+1
	rawset(kDamageType, index, 'MachineGun')
	rawset(kDamageType, 'MachineGun', index)

	kDamageTypeDesc[index] = "MachineGun: Deals 1.5x amount of base damage against players"
end

local kMachineGunPlayerDamageScalar = 1.5
local function MultiplyForPlayers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
	return ConditionalValue(target:isa("Player") or target:isa("Exosuit"), damage * kMachineGunPlayerDamageScalar, damage), armorFractionUsed, healthPerArmor
end

local oldGetDamageByType = GetDamageByType
function GetDamageByType(target, attacker, doer, damage, damageType, hitPoint, weapon)

	if not kDamageTypeRules then
		oldGetDamageByType(attacker, attacker, doer, 0, kDamageType.Normal, false, weapon ) --inits kDamageTypeRules

		kDamageTypeRules[kDamageType.MachineGun] = {
			MultiplyForPlayers
		}
	end

	return oldGetDamageByType(target, attacker, doer, damage, damageType, hitPoint, weapon)
end