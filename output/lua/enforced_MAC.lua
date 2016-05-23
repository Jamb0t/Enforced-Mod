kElixerVersion = 1.8
Script.Load("lua/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion )

local kThrusterMoveSpeed = 12

local networkVars =
{
    timeThrusterUsed = "time",
    thrusterActive = "boolean"
}

local original_MAC_OnInitialized
original_MAC_OnInitialized = Class_ReplaceMethod( "MAC", "OnInitialized",
function (self)
    original_MAC_OnInitialized(self)

    self.timeThrusterUsed = math.max(0, Shared.GetTime() - kMACThrusterDuration)
end
)

local original_MAC_GetMoveSpeed
original_MAC_GetMoveSpeed = Class_ReplaceMethod( "MAC", "GetMoveSpeed",
function (self)
    if not self.rolloutSourceFactory and self.thrusterActive then
        local maxSpeedTable = { maxSpeed = kThrusterMoveSpeed }
        self:ModifyMaxSpeed(maxSpeedTable)
        return maxSpeedTable.maxSpeed
    end

    return original_MAC_GetMoveSpeed(self)
end)

local function EndThrusters(self)
    self.thrusterActive = false
    return false
end

local original_MAC_PerformActivation
original_MAC_PerformActivation = Class_ReplaceMethod( "MAC", "PerformActivation",
function (self, techId, position, normal, commander)
    if techId == kTechId.MACEMP and self.timeThrusterUsed + kThrusterCooldown < Shared.GetTime() then

        self.timeThrusterUsed = Shared.GetTime()
        self.thrusterActive = true
        self:AddTimedCallback(EndThrusters, kMACThrusterDuration)
        return true, false

    end

    return ScriptActor.PerformActivation(self, techId, position, normal, commander)
end)

Class_AddMethod( "MAC", "OverrideGetStatusInfo",
function (self)
    local thrusterEnergy = 0

    if self.thrusterActive then
        thrusterEnergy = 1 - Clamp((Shared.GetTime() - self.timeThrusterUsed) / kMACThrusterDuration, 0, 1)
    else
        thrusterEnergy = Clamp((Shared.GetTime() - self.timeThrusterUsed - kMACThrusterDuration) / (kThrusterCooldown - kMACThrusterDuration), 0, 1)
    end

    return { Locale.ResolveString("THRUSTER_COOLDOWN"),
             thrusterEnergy,
             kTechId.MACEMP
    }
end)

local original_MAC_GetTechAllowed
original_MAC_GetTechAllowed = Class_ReplaceMethod( "MAC", "GetTechAllowed",
function (self, techId, techNode, player)
    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)

    if techId == kTechId.MACEMP then

        canAfford = true
        allowed = self.timeThrusterUsed + kThrusterCooldown < Shared.GetTime()

    end

    return allowed, canAfford
end)

local original_MAC_GetTechButtons
original_MAC_GetTechButtons = Class_ReplaceMethod( "MAC", "GetTechButtons",
function (self, techId)
    return { kTechId.MACEMP, kTechId.Stop, kTechId.Welding, kTechId.None,
             kTechId.None, kTechId.None, kTechId.None, kTechId.None }
end)

Shared.LinkClassToMap("MAC", MAC.kMapName, networkVars)
