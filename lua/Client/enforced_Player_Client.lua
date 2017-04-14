--
local kNewGrenades = {
    kTechId.ClusterGrenade,
    kTechId.GasGrenade,
    kTechId.NapalmGrenade,
    kTechId.PulseGrenade
}

ReplaceLocals(PlayerUI_GetHasItem, { kGrenades = kNewGrenades } )

-- Old healthbars
local orig_Player_GetShowHealthFor
orig_Player_GetShowHealthFor = Class_ReplaceMethod( "Player", "GetShowHealthFor",
function (self, player)
    return ( player:isa("Spectator") or ( not GetAreEnemies(self, player) and self:GetIsAlive() ) ) and self:GetTeamType() ~= kNeutralTeamType
end
)