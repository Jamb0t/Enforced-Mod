
Script.Load("lua/EnergyMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/Mixin/enforced_ElectrifyMixin.lua")

local networkVars = {}
AddMixinNetworkVars(ElectrifyMixin, networkVars)

local orig_Extractor_OnCreate
orig_Extractor_OnCreate = Class_ReplaceMethod( "Extractor", "OnCreate", 
function(self)
    orig_Extractor_OnCreate(self)
    
    InitMixin(self, EnergyMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, ElectrifyMixin)	
end
)

local original_Extractor_GetTechButtons
original_Extractor_GetTechButtons = Class_ReplaceMethod( "Extractor", "GetTechButtons",
function (self, techId)
if self:GetIsElectrified() then
    return { kTechId.None, kTechId.None, kTechId.None, kTechId.None,
             kTechId.None, kTechId.None, kTechId.None, kTechId.None }
end
    return { kTechId.CollectResources, kTechId.Electrify, kTechId.None, kTechId.None,
             kTechId.None, kTechId.None, kTechId.None, kTechId.None }
end
)

Class_AddMethod( "Extractor", "OverrideGetEnergyUpdateRate",
function (self)
    return kElectrifyEnergyRegain
end
)

Class_AddMethod( "Extractor", "GetCanUpdateEnergy",
function (self)
    return self:GetIsElectrified()
end
)

Class_AddMethod( "Extractor", "GetUnitNameOverride",
function (self)
    local description = GetDisplayName(self)

    if self:HasElectrifyUpgrade() then
        description = "Electrified " .. description 
    end
    
    if HasMixin(self, "Construct") and not self:GetIsBuilt() then
        description = "Unbuilt " .. description
    end
    
    return description
end
)

Shared.LinkClassToMap("Extractor", Extractor.kMapName, networkVars)
