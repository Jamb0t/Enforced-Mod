
local function NewScanForNearbyEnemy(self)
	local kDetectInterval = 0.5
	local kDetectRange = 4.5
    -- Check for nearby enemy units. Uncloak if we find any.
    self.lastDetectedTime = self.lastDetectedTime or 0
    if self.lastDetectedTime + kDetectInterval < Shared.GetTime() then
        if #GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kDetectRange) > 0 then
            self:TriggerUncloak()
        end
        self.lastDetectedTime = Shared.GetTime()
    end
end

ReplaceLocals(Drifter.OnUpdate, { ScanForNearbyEnemy = NewScanForNearbyEnemy })

local original_Drifter_GetIsCamouflaged
original_Drifter_GetIsCamouflaged = Class_ReplaceMethod( "Drifter", "GetIsCamouflaged",
function (self)
    return self.camouflaged
end
)
