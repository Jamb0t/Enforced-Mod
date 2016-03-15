// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\GasGrenade.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/OwnerMixin.lua")

class 'NapalmGrenade' (PredictedProjectile)

NapalmGrenade.kMapName = "napalmgrenadeprojectile"
NapalmGrenade.kModelName = PrecacheAsset("models/marine/grenades/gr_nerve_world.model")
NapalmGrenade.kUseServerPosition = true

NapalmGrenade.kRadius = 0.085
NapalmGrenade.kClearOnImpact = false
NapalmGrenade.kClearOnEnemyImpact = false

local networkVars =
{
    releaseGas = "boolean"
}

local kLifeTime = 10
local kGasReleaseDelay = 0.50

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

local function TimeUp(self)
    DestroyEntity(self)
end

function NapalmGrenade:OnCreate()

    PredictedProjectile.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)

    if Server then

        self:AddTimedCallback(TimeUp, kLifeTime)
        self:AddTimedCallback(NapalmGrenade.ReleaseGas, kGasReleaseDelay)
        self:AddTimedCallback(NapalmGrenade.UpdateNerveGas, 1)

    end

    self.releaseGas = false
    self.clientGasReleased = false

end

function NapalmGrenade:ProcessHit(targetHit, surface)

    if self:GetVelocity():GetLength() > 2 then
        self:TriggerEffects("grenade_bounce")
    end

end

if Client then

    function NapalmGrenade:OnUpdateRender()

        PredictedProjectile.OnUpdateRender(self)

        if self.releaseGas and not self.clientGasReleased then

            self:TriggerEffects("release_napalm", { effethostcoords = Coords.GetTranslation(self:GetOrigin())} )
            self.clientGasReleased = true

        end

    end

elseif Server then

    function NapalmGrenade:ReleaseGas()
        self.releaseGas = true
    end

    function NapalmGrenade:UpdateNerveGas()

        if self.releaseGas then

            local direction = Vector(math.random() - 0.5, 0.5, math.random() - 0.5)
            direction:Normalize()

            local trace = Shared.TraceRay(self:GetOrigin() + Vector(0, 0.2, 0), self:GetOrigin() + direction * 7, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAll())
            local nervegascloud = CreateEntity(NapalmCloud.kMapName, self:GetOrigin(), self:GetTeamNumber())
            nervegascloud:SetEndPos(trace.endPoint)

            local owner = self:GetOwner()
            if owner then
                nervegascloud:SetOwner(owner)
            end

        end

        return true

    end

end

Shared.LinkClassToMap("NapalmGrenade", NapalmGrenade.kMapName, networkVars)

class 'NapalmCloud' (Entity)

NapalmCloud.kMapName = "napalmcloud"
NapalmCloud.kEffectName = PrecacheAsset("cinematics/marine/napalmcloud.cinematic")

local gNerveGasDamageTakers = {}

local kCloudUpdateRate = 0.3
local kSpreadDelay = 0.6

local kCloudMoveSpeed = 2

local networkVars =
{
}

AddMixinNetworkVars(TeamMixin, networkVars)

function NapalmCloud:OnCreate()

    Entity.OnCreate(self)

    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)

    if Server then

        self.creationTime = Shared.GetTime()

        self:AddTimedCallback(TimeUp, kNapalmCloudLifetime)
        self:AddTimedCallback(NapalmCloud.DoNerveGasDamage, kCloudUpdateRate)

        InitMixin(self, OwnerMixin)

    end

    self:SetUpdates(true)
    self:SetRelevancyDistance(kMaxRelevancyDistance)

end

function NapalmCloud:SetEndPos(endPos)
    self.endPos = Vector(endPos)
end

if Client then

    function NapalmCloud:OnInitialized()

        local cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        cinematic:SetCinematic(NapalmCloud.kEffectName)
        cinematic:SetParent(self)
        cinematic:SetCoords(Coords.GetIdentity())

    end

end

local function GetRecentlyDamaged(entityId, time)

    for index, pair in ipairs(gNerveGasDamageTakers) do
        if pair[1] == entityId and pair[2] > time then
            return true
        end
    end

    return false

end

local function SetRecentlyDamaged(entityId)

    for index, pair in ipairs(gNerveGasDamageTakers) do
        if pair[1] == entityId then
            table.remove(gNerveGasDamageTakers, index)
        end
    end

    table.insert(gNerveGasDamageTakers, {entityId, Shared.GetTime()})

end

local function GetIsInCloud(self, entity, radius)

    local targetPos = entity.GetEyePos and entity:GetEyePos() or entity:GetOrigin()
    return (self:GetOrigin() - targetPos):GetLength() <= radius

end

function NapalmCloud:DoNerveGasDamage()

   local radius = math.min(1, (Shared.GetTime() - self.creationTime) / kSpreadDelay) * kNapalmCloudRadius

   -- hurt marines
   for _, entity in ipairs(GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), 2*kNapalmCloudRadius)) do

      if not GetRecentlyDamaged(entity:GetId(), (Shared.GetTime() - kCloudUpdateRate)) and GetIsInCloud(self, entity, radius) then

	 local damages = kNapalmDamagePerSecond * kCloudUpdateRate
	 if (self:GetTeamNumber() == entity:GetTeamNumber()) then
	    damages = damages * kOnMarineDamageMultiplyer
	 end
	 self:DoDamage(damages, entity, entity:GetOrigin(), GetNormalizedVector(self:GetOrigin() - entity:GetOrigin()), "none")
	 SetRecentlyDamaged(entity:GetId())

      end

   end
   -- Put in fire enemy to close from the center
   for _, entity in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kBurnRadius)) do
      if (HasMixin(entity, "Fire")) then
	 entity:SetOnFire(self:GetOwner(), self)
      end
   end

   return true

end

function NapalmCloud:GetDeathIconIndex()
    return kDeathMessageIcon.GasGrenade
end

if Server then

    function NapalmCloud:OnUpdate(deltaTime)

        if self.endPos then
            local newPos = SlerpVector(self:GetOrigin(), self.endPos, deltaTime * kCloudMoveSpeed)
            self:SetOrigin(newPos)
        end

    end

end

function NapalmCloud:GetDamageType()
    return kDamageType.Flame
end

Shared.LinkClassToMap("NapalmCloud", NapalmCloud.kMapName, networkVars)

