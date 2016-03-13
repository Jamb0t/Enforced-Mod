
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

local orig_Extractor_GetTechButtons
orig_Extractor_GetTechButtons = Class_ReplaceMethod( "Extractor", "GetTechButtons", 
function(self, techId)
    local result = ResourceTower.GetTechButtons(self)

    if not self:GetIsElectrified() then
        result[2] = kTechId.Electrify
    end

    return result
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

    if self:GetIsElectrified() then
        description = "Electrified " .. description 
    end
    
    if HasMixin(self, "Construct") and not self:GetIsBuilt() then
        description = "Unbuilt " .. description
    end
    
    return description
end
)

Shared.LinkClassToMap("Extractor", Extractor.kMapName, networkVars)
