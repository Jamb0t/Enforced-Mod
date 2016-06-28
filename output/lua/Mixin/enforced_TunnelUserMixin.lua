
local origSharedUpdate = GetUpValue( TunnelUserMixin.OnUpdate, "SharedUpdate" )

local UpdateSinkIn = GetUpValue( origSharedUpdate, "UpdateSinkIn", { LocateRecurse = true } )
local UpdateExitTunnel = GetUpValue( origSharedUpdate, "UpdateExitTunnel", { LocateRecurse = true } )
local UpdateTunnelEffects = GetUpValue( origSharedUpdate, "UpdateTunnelEffects", { LocateRecurse = true } )


local function EnforcedSharedUpdate(self, deltaTime)

    if self.canUseTunnel then

        if self:GetIsEnteringTunnel() then
            UpdateSinkIn(self, deltaTime)
        elseif Server then
            
            self.timeSinkInStarted = nil
            local tunnel = GetIsPointInGorgeTunnel(self:GetOrigin())
            if tunnel then
                UpdateExitTunnel(self, deltaTime, tunnel)
            end
            
        end
    
    end
    
    if Server then
		local tunnelUseTimeout = self:isa("Gorge") and kGorgeTunnelCooldownGorge or kGorgeTunnelCooldown
        self.canUseTunnel = self.timeTunnelUsed + tunnelUseTimeout < Shared.GetTime()
    elseif Client and self.GetIsLocalPlayer and self:GetIsLocalPlayer() then    
        UpdateTunnelEffects(self)
    end

end

function TunnelUserMixin:OnProcessMove(input)
	local isCrouched = bit.band(input.commands, Move.Crouch) ~= 0 and self:isa("Alien")
	local isMoving = input.move:GetLength() == 0
	self:SetEnterTunnelDesired(isCrouched or isMoving)
	
	EnforcedSharedUpdate(self, input.time)
end

function TunnelUserMixin:OnUpdate(deltaTime)
    PROFILE("TunnelUserMixin:OnUpdate")
    EnforcedSharedUpdate(self, deltaTime)
end
