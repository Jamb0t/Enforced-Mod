if SERVER then
  local oldConstructMixinOnConstructUpdate = Shine.ReplaceClassMethod("ConstructMixin", "OnConstructUpdate",
    function(self, deltaTime)
        local effectTimeout = Shared.GetTime() - self.timeLastConstruct > 0.65
        self.underConstruction = not self:GetIsBuilt() and not effectTimeout

        -- Only Alien structures auto build.
        -- Update build fraction every tick to be smooth.
        if not self:GetIsBuilt() and GetIsAlienUnit(self) then

            if not self.GetCanAutoBuild or self:GetCanAutoBuild() then

                -- Make every additional driver half as effective
                local drifterRate = 0
                for i = 1, getDrifters(self) do
                  drifterRate = drifterRate + (1 / i)
                end

                local multiplier = self.hasDrifterEnzyme and 0 or kAutoBuildRate --kDrifterBuildRate
                multiplier = multiplier * ( (HasMixin(self, "Catalyst") and self:GetIsCatalysted()) and kNutrientMistAutobuildMultiplier or 1 )
                self:Construct(deltaTime * (multiplier + drifterRate))

            end

        end

        if self.timeDrifterConstructEnds then

            if self.timeDrifterConstructEnds <= Shared.GetTime() then

                self.hasDrifterEnzyme = false
                self.timeDrifterConstructEnds = nil

            end

        end

        -- respect the cheat here; sometimes the cheat breaks due to things relying on it NOT being built until after a frame
        if GetGamerules():GetAutobuild() then
            self:SetConstructionComplete()
        end

        if self.underConstruction or not self.constructionComplete then
            return kUpdateIntervalFull
        end

        -- stop running once we are fully constructed
        return false

    end
  )
end