local kDamageInterval = 0.25

local orig_SporeCloud_OnUpdate
orig_SporeCloud_OnUpdate = Class_ReplaceMethod( "SporeCloud", "OnUpdate",
function (self, deltaTime)
    local time = Shared.GetTime()
    if Server then 
    
        if not self.targetY then
            local trace = Shared.TraceRay(self:GetOrigin(), self:GetOrigin() - Vector(0,10,0), CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAll())

            self.targetY = trace.endPoint.y + SporeCloud.kDropMinDistance
        end
    
        -- drop by a constant speed until we get close to the target, at which time we slow down the drop
        local origin = self:GetOrigin()
        local remDrop = origin.y - self.targetY
        local speed = SporeCloud.kDropSpeed 
       if remDrop < SporeCloud.kDropSlowDistance then
            speed = SporeCloud.kDropSpeed * remDrop / SporeCloud.kDropSlowDistance
        end
        -- cut bandwidth; when the speed is slow enough, we stop updating
        if speed > 0.05 then
            origin.y = origin.y - speed * deltaTime
            self:SetOrigin(origin)
        end  

        -- we do damage until the spores have died away.
        if time > self.nextDamageTime and time < self.endOfDamageTime then
 
            self:SporeDamage(time)
            self.nextDamageTime = time + kDamageInterval
        end
        
        if  time > self.destroyTime then
            DestroyEntity(self)
        end
        
    elseif Client then

        if self.sporeEffect then        
            self.sporeEffect:SetCoords(self:GetCoords())            
        else
        
            self.sporeEffect = Client.CreateCinematic(RenderScene.Zone_Default)
            local effectName = SporeCloud.kLoopingEffect
            if not GetAreEnemies(self, Client.GetLocalPlayer()) then
                effectName = SporeCloud.kLoopingEffectAlien
            end
            
            self.sporeEffect:SetCinematic(effectName)
            self.sporeEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.sporeEffect:SetCoords(self:GetCoords())
        
        end
    
    end
    
end)
