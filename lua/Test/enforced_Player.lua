if CLIENT then
  oldMarineActionFinderMixinOnProcessMove = Shine.ReplaceClassMethod("MarineActionFinderMixin", "OnProcessMove",
    function(self, input)
          PROFILE("MarineActionFinderMixin:OnProcessMove")
          
          local gameStarted = self:GetGameStarted()
          local prediction = Shared.GetIsRunningPrediction()
          local now = Shared.GetTime()
          local enoughTimePassed = (now - self.lastMarineActionFindTime) >= kIconUpdateRate
          if not prediction and enoughTimePassed then
              self.lastMarineActionFindTime = now
              local success = false
              
              if self:GetIsAlive() and not GetIsVortexed(self) then
                  local foundNearbyWeapon = FindNearbyWeapon(self, self:GetOrigin())
                  if gameStarted and foundNearbyWeapon then
                  
                      self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Drop"), foundNearbyWeapon:GetClassName(), nil)
                      success = true
                  else
                      local ent = self:PerformUseTrace()
                      if ent and (gameStarted or (ent.GetUseAllowedBeforeGameStart and ent:GetUseAllowedBeforeGameStart())) then
                      
                          if GetPlayerCanUseEntity(self, ent) and not self:GetIsUsing() then
                              local hintText = nil
                              if self:isa("Exo") and ent:isa("MAC") then
                                  hintText = "Toggle Follow"
                              elseif ent:isa("CommandStation") and ent:GetIsBuilt() then
                                  hintText = gameStarted and "START_COMMANDING" or "START_GAME"
                              end
                              
                              self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Use"), nil, hintText, nil)
                              success = true
                          end
                      end
                  end
              end
              
              if not success then
                  self.actionIconGUI:Hide()
              end
          end
    end
  )
  
  oldAlienActionFinderMixinOnProcessMove = Shine.ReplaceClassMethod("AlienActionFinderMixin", "OnProcessMove",
    function(self, input)
          PROFILE("AlienActionFinderMixin:OnProcessMove")
          
          local ent = self:PerformUseTrace()
          if ent and (self:GetGameStarted() or (ent.GetUseAllowedBeforeGameStart and ent:GetUseAllowedBeforeGameStart())) then
          
              if GetPlayerCanUseEntity(self, ent) and not self:GetIsUsing() then
              
                  if ((ent:isa("Crag") or ent:isa("Shade")) and ent:GetIsBuilt()) or ent:isa("Drifter") then
                      self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Use"), nil, "Activate", nil)
                  elseif ent:isa("Hive") then
                      local text = self:GetGameStarted() and "START_COMMANDING" or "START_GAME"
                      self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Use"), nil, text, nil)
                  elseif ent:isa("Egg") then
                      self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Use"), nil, "EVOLVE", nil)
                  elseif HasMixin(ent, "Digest") and ent:GetIsAlive() then
                  
                      local digestFraction = DigestMixin.GetDigestFraction(ent)
                      // avoid the slight flicker at the end, caused by the digest effect for Clogs..
                      if digestFraction <= 1.0 then
                          self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Use"), nil, "DESTROY", digestFraction)
                       else
                          self.actionIconGUI:Hide()
                       end
                       
                  else
                      self.actionIconGUI:ShowIcon(BindingsUI_GetInputValue("Use"), nil, nil, nil)
                  end
                  
              else
                  self.actionIconGUI:Hide()
              end
              
          else
              self.actionIconGUI:Hide()
          end
    end
  )
else
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