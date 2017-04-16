if CLIENT then
  function Shade:GetCanBeUsedConstructed(byPlayer)
    return true
  end
  
  oldShadeGetCanBeUsed = Shine.ReplaceClassMethod("Shade", "GetCanBeUsed",
    function(self, player, useSuccessTable)
      useSuccessTable.useSuccess = self:GetIsBuilt()
    end
  )
else
  oldShadeGetCanBeUsed = Shine.ReplaceClassMethod("Shade", "GetCanBeUsed",
    function(self, player, useSuccessTable)
      if (Shared.GetTime() - (self.lastUsed or 0) > 6 and player:GetTeamNumber() == 2 and self:GetIsBuilt()) then
        local resources = player:GetResources()
        if (resources >= 1) then
          player:SetResources(math.max(0, resources - 1))
          
          self:TriggerInk()
          self.lastUsed = Shared.GetTime()
        else
          Server.PlayPrivateSound(player, player:GetNotEnoughResourcesSound(), player, 1.0, Vector(0, 0, 0))   
        end
      end
    end
  )
end