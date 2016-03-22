
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/Mixin/enforced_ElectrifyMixin.lua")

local networkVars = {}
AddMixinNetworkVars(ElectrifyMixin, networkVars)

local orig_Extractor_OnCreate
orig_Extractor_OnCreate = Class_ReplaceMethod( "Extractor", "OnCreate",
function(self)
    orig_Extractor_OnCreate(self)

    InitMixin(self, DamageMixin)
    InitMixin(self, ElectrifyMixin)
end
)

local original_Extractor_GetTechButtons
original_Extractor_GetTechButtons = Class_ReplaceMethod( "Extractor", "GetTechButtons",
function (self, techId)
    local techs = original_Extractor_GetTechButtons()
    techs[5] = kTechId.ElectrifyTech

    if self:IsElectrifyAllowed() then
        techs[2] = kTechId.Electrify
    else
        techs[2] = kTechId.None
    end

    return techs
end
)

function Extractor:PerformActivation(techId, position, normal, commander)

    if techId == kTechId.Electrify then
        self:SetElectrify()
    end

    return ScriptActor.PerformActivation(self, techId, position, normal, commander)
end

local original_Extractor_GetTechAllowed
original_Extractor_GetTechAllowed = Class_ReplaceMethod( "Extractor", "GetTechAllowed",
function (self, techId, techNode, player)

    local allowed, canAfford = original_Extractor_GetTechAllowed(self, techId, techNode, player)
    
    if allowed and self:IsElectrifyAllowed() then
        allowed = true
    end
    
    return allowed, canAfford
end
)

local original_Extractor_GetActivationTechAllowed
original_Extractor_GetActivationTechAllowed = Class_ReplaceMethod( "Extractor", "GetActivationTechAllowed",
function (self, techId)

    if techId == kTechId.Electrify then
        return self:IsElectrifyAllowed()
    end
    
    return true
end
)

Class_AddMethod( "Extractor", "GetUnitNameOverride",
function (self)

    local description = GetDisplayName(self)

    if not self:GetIsBuilt() then
        description = "Unbuilt " .. description
    elseif self:IsElectrifyActive() then
        description = "Electrified " .. description
    end

    return description
end
)

Class_AddMethod( "Extractor", "OverrideGetStatusInfo",
function (self)

    local status = self:GetElectrifyProgressBar()
    if #status > 0 then
        return status
    end
    
    local text = GetDisplayName(self)
    return { text }
end
)

Shared.LinkClassToMap("Extractor", Extractor.kMapName, networkVars)
