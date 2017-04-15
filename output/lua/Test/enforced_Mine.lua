if SERVER then
  oldMineOnCreate = Shine.ReplaceClassMethod("Mine", "OnInitialized", 
  function(self)
    oldMineOnCreate(self)
    
    InitMixin(self, StaticTargetMixin)
  end)
end