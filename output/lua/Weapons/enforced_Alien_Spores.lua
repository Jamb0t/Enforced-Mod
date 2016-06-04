
local function OriginalCreateSporeCloud(self, origin, player)

    local spores = CreateEntity(SporeCloud.kMapName, origin, player:GetTeamNumber())
    spores:SetTravelDestination(player:GetEyePos())    
    spores:SetOwner(player)
    
    local coords = player:GetCoords()
    
    local velocity = player:GetVelocity()
    if velocity:Normalize() > 0.0 then
        -- adjusts the effect to the players move direction (strafe + sporing)
        zAxis = velocity
    end
    coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
    coords.yAxis = coords.xAxis:CrossProduct(coords.zAxis)
    
    spores:SetCoords(coords)

    return spores
    
end

ReplaceLocals(Spores.PerformPrimaryAttack, { CreateSporeCloud = OriginalCreateSporeCloud } )
