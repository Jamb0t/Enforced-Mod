if SERVER then
  oldMACUpdateGreetings = Shine.ReplaceClassMethod("MAC", "UpdateGreetings",
    function(self)
    end
  )
else
  oldMACOnUse = Shine.ReplaceClassMethod("MAC", "OnUse",
    function(self, player, elapsedTime, useSuccessTable)
      if (not player:isa("Exo")) then
        oldMACOnUse(self, player, elapsedTime, useSuccessTable)
      elseif (Shared.GetTime() - (self.lastUsed or 0) > 4) then //Is exo and has been at least 4 seconds since used
        self.lastUsed = Shared.GetTime()
      
        local result = false
        
        local order = self:GetCurrentOrder()
        if (order) then
          local orderTarget = nil

          if (order:GetParam() ~= nil) then
            orderTarget = Shared.GetEntity(order:GetParam())
          end

          local isSelfOrder = orderTarget == self
          if (order:GetType() == kTechId.FollowAndWeld) then //If used mac is already following, stop it
            self:ClearCurrentOrder()
            Server.PlayPrivateSound(player, MAC.kPassbyDrifterSoundName, player, 1.0, Vector(0, 0, 0))
          elseif (not orderTarget or isSelfOrder) then //If the mac is not doing anything, or welding you
            result = true
          end
        else
          result = true
        end
        
        if (result) then
          -- Cancel out if player already has an assigned mac
          for _, mac in ipairs(GetEntitiesForTeam("MAC", player:GetTeamNumber())) do
            if mac then
              local order = mac:GetCurrentOrder()
              if order and order:GetType() == kTechId.FollowAndWeld then
                local target = Shared.GetEntity(order:GetParam())
                if target == player then
                  return
                end
              end
            end
          end
        
          //order:SetType(kTechId.FollowAndWeld)
          //order.orderParam = player:GetId()
          self:GiveOrder(kTechId.FollowAndWeld, player:GetId(), player:GetOrigin(), nil, false, false)
          Server.PlayPrivateSound(player, MAC.kHelpingSoundName, player, 1.0, Vector(0, 0, 0))
        end
      end
    end
  )
end