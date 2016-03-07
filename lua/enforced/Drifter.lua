kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

local function ScanForNearbyEnemy(self)
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

ReplaceLocals(Drifter.OnUpdate, { ScanForNearbyEnemy = ScanForNearbyEnemy })

function Drifter:GetIsCamouflaged()
    return self.camouflaged
end