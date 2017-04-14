
Script.Load("lua/NS2Utility.lua")
Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/Weapons/enforced_Marine_NapalmGrenade.lua")

local networkVars =
{
}

class 'NapalmGrenadeThrower' (GrenadeThrower)

NapalmGrenadeThrower.kMapName = "napalmgrenade"

local kModelName = PrecacheAsset("models/marine/grenades/gr_nerve.model")
local kViewModels = GenerateMarineGrenadeViewModelPaths("gr_nerve")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/grenade_view.animation_graph")

function NapalmGrenadeThrower:OnCreate()
   GrenadeThrower.OnCreate(self)
   self.grenadesLeft = kMaxNapalmGrenades
end

function NapalmGrenadeThrower:GetThirdPersonModelName()
    return kModelName
end

function NapalmGrenadeThrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function NapalmGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function NapalmGrenadeThrower:GetGrenadeClassName()
    return "NapalmGrenade"
end

Shared.LinkClassToMap("NapalmGrenadeThrower", NapalmGrenadeThrower.kMapName, networkVars)