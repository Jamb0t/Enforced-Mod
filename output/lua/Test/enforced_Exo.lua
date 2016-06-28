if CLIENT then
  oldScriptActorGetCanBeUsed = Shine.ReplaceClassMethod("ScriptActor", "GetCanBeUsed",
    function(self, player, useSuccessTable)
      if player:isa("Exo") and not self:isa("MAC") then
          useSuccessTable.useSuccess = false
      end

      if HasMixin(player, "Live") and not player:GetIsAlive() then
          useSuccessTable.useSuccess = false
      end
      
      if GetIsVortexed(self) or GetIsVortexed(player) then
          useSuccessTable.useSuccess = false
      end
    end
  )
end