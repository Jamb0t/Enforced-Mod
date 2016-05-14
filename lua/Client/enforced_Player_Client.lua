
--
local kNewGrenades = {
    kTechId.ClusterGrenade,
    kTechId.GasGrenade,
    kTechId.NapalmGrenade,
    kTechId.PulseGrenade
}

ReplaceLocals(PlayerUI_GetHasItem, { kGrenades = kNewGrenades } )

--
local oldPlayerUI_GetCrosshairY = PlayerUI_GetCrosshairY
function PlayerUI_GetCrosshairY()
	local player = Client.GetLocalPlayer()
	if player and not player:GetIsThirdPerson() then
		local weapon = player:GetActiveWeapon()
		if weapon ~= nil and weapon:GetMapName() == HeavyMachineGun.kMapName then
			return 0 * 64
		end
	end
	return oldPlayerUI_GetCrosshairY()
end

-- Old healthbars
local orig_Player_GetShowHealthFor
orig_Player_GetShowHealthFor = Class_ReplaceMethod( "Player", "GetShowHealthFor",
function (self, player)
    return ( player:isa("Spectator") or ( not GetAreEnemies(self, player) and self:GetIsAlive() ) ) and self:GetTeamType() ~= kNeutralTeamType
end
)
