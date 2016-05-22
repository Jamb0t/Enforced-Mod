local original_Alien_UpdateSilenceLevel
original_Alien_UpdateSilenceLevel = Class_ReplaceMethod( "Alien", "UpdateSilenceLevel",
function (self)
    if GetHasSilenceUpgrade(self) then
        self.silenceLevel = GetVeilLevel(self:GetTeamNumber())
    else
        self.silenceLevel = 0
    end
end)
