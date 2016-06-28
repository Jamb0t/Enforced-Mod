if SERVER then
  local oldParasiteMixinOnTakeDamage = Shine.ReplaceClassMethod("ParasiteMixin", "OnTakeDamage", 
    function(self, damage, attacker, doer, point, damageType)
      if doer and (doer:isa("Parasite") or (doer:isa("Hydra") and math.random(0, 1) >= 0.75)) then --and GetAreEnemies(self, attacker) then
        self:SetParasited(attacker)
      end
    end
  )
end