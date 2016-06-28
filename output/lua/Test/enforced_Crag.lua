if CLIENT then
  function Crag:GetCanBeUsedConstructed(byPlayer)
    return true
  end

  oldCragGetCanBeUsed = Shine.ReplaceClassMethod("Crag", "GetCanBeUsed",
    function(self, player, useSuccessTable)
      useSuccessTable.useSuccess = self:GetIsBuilt() and not self.healWaveActive
    end
  )
else
  local kMistSound = PrecacheAsset("sound/NS2.fev/alien/commander/catalyze_3D")

  oldCragGetCanBeUsed = Shine.ReplaceClassMethod("Crag", "GetCanBeUsed",
    function(self, player, useSuccessTable)
      if (Shared.GetTime() - (self.lastUsed or 0) > 8 and player:GetTeamNumber() == 2 and self:GetIsBuilt()) then
        local resources = player:GetResources()
        if (resources >= 1) then
          player:SetResources(math.max(0, resources - 1))
          
          StartSoundEffectAtOrigin(kMistSound, self:GetOrigin())
          self:TriggerHealWave(player)
          self.lastUsed = Shared.GetTime()
        else
          Server.PlayPrivateSound(player, player:GetNotEnoughResourcesSound(), player, 1.0, Vector(0, 0, 0))
        end
      end
    end
  )
end