local original_Alien_GetIsCamouflaged
original_Alien_GetIsCamouflaged = Class_ReplaceMethod( "Alien", "GetIsCamouflaged",
function (self)
    return GetHasCamouflageUpgrade(self) and not self:GetIsInCombat()
end)
