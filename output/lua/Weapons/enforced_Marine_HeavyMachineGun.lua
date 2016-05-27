
local original_HeavyMachineGun_GetBarrelPoint
original_HeavyMachineGun_GetBarrelPoint = Class_ReplaceMethod( "HeavyMachineGun", "GetBarrelPoint",
function(self)
        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
            
            return origin + viewCoords.zAxis * 0.65 + viewCoords.xAxis * -0.15 + viewCoords.yAxis * -0.2
            
        end
        
        return self:GetOrigin()
        
    end)
