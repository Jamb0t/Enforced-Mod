
local orig_Rupture_OnAbilityOptionalEnd
orig_Rupture_OnAbilityOptionalEnd = Class_ReplaceMethod( "Rupture", "OnAbilityOptionalEnd",
function (self)
    if Server then
        --Ignore facing / blinding
        local entities = GetEntitiesForTeamWithinXZRange( "Entity", GetEnemyTeamNumber( self:GetTeamNumber() ), self:GetOrigin(), kRuptureEffectRadius )
        if entities then
            for i = 1, #entities do
                if HasMixin( entities[i], "ParasiteAble" ) then
                    entities[i]:SetParasited( self:GetOwner(), kRuptureParasiteTime ) --Will give Commander point(s)
                end
            end
        end
    end
end)
