// Natural Selection 2 'Classic' Mod
// lua\Weapons\HeavyMachineGun.lua
// - Dragon

Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

class 'HeavyMachineGun' (ClipWeapon)

HeavyMachineGun.kMapName = "heavymachinegun"

HeavyMachineGun.kModelName = PrecacheAsset("models/marine/heavymachinegun/heavymachinegun.model")
local kViewModelName = PrecacheAsset("models/marine/heavymachinegun/heavymachinegun_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/heavymachinegun/heavymachinegun_view.animation_graph")

local kRange = 100
local kSingleShotSound = PrecacheAsset("sound/compmod.fev/compmod/marine/hmg/hmg_fire")
local kEndSound = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_down")
local kMuzzleEffect = PrecacheAsset("cinematics/marine/heavymachinegun/muzzle_flash.cinematic")
local kMuzzleAttachPoint = "fxnode_riflemuzzle"

local networkVars =
{
}

AddMixinNetworkVars(LiveMixin, networkVars)

function HeavyMachineGun:OnCreate()

    ClipWeapon.OnCreate(self)

	InitMixin(self, PickupableWeaponMixin)
	InitMixin(self, EntityChangeMixin)
	InitMixin(self, LiveMixin)

    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end

end

function HeavyMachineGun:OnInitialized()

    ClipWeapon.OnInitialized(self)
    self.lastfiredtime = 0
    self.reloadtime = 0
    if Client then

        self:SetUpdates(true)
        self:SetFirstPersonAttackingEffect(kMuzzleEffect)
        self:SetThirdPersonAttackingEffect(kMuzzleEffect)
        self:SetMuzzleAttachPoint(kMuzzleAttachPoint)

    end

end

local function CancelReload(self)
    self.reloading = false
    self:TriggerEffects("reload_cancel")
end

function HeavyMachineGun:OnPrimaryAttack(player)

    if self:GetIsPrimaryAttackAllowed(player) then
        if not self:GetIsReloading() and self.clip > 0 and self.deployed then
            if player and not self:GetHasAttackDelay() then
                if self:GetIsReloading() then
                    CancelReload(self)
                end
                self:FirePrimary(player)
                // Don't decrement ammo in Darwin mode
                if not player or not player:GetDarwinMode() then
                    self.clip = self.clip - 1
                end
                self.lastfiredtime = Shared.GetTime()
                self:CreatePrimaryAttackEffect(player)
                Weapon.OnPrimaryAttack(self, player)
                self.primaryAttacking = true
            end
        elseif self.ammo > 0 and self.deployed then
            self:OnPrimaryAttackEnd(player)
            // Automatically reload if we're out of ammo.
            player:Reload()
        else
            self:OnPrimaryAttackEnd(player)
            self.blockingPrimary = false
        end
    else
        self:OnPrimaryAttackEnd(player)
        self.blockingPrimary = false
    end

end

function HeavyMachineGun:OnDraw(player, previousWeaponMapName)
	ClipWeapon.OnDraw(self, player, previousWeaponMapName)
end

function HeavyMachineGun:OnHolsterClient()
    ClipWeapon.OnHolsterClient(self)
end

function HeavyMachineGun:GetMaxClips()
    return 3
end

function HeavyMachineGun:GetMaxAmmo()
    return 3 * self:GetClipSize()
end

function HeavyMachineGun:GetAnimationGraphName()
    return kAnimationGraph
end

function HeavyMachineGun:GetViewModelName()
    return kViewModelName
end

function HeavyMachineGun:GetFireDelay()
    return 0.03
end

function HeavyMachineGun:CanReload()
    return self.ammo > 0 and self.clip < self:GetClipSize() and not self.reloading and self.deployed
end

function HeavyMachineGun:OnReload(player)
    if self:CanReload() then
        self.reloadtime = Shared.GetTime()
    end
    ClipWeapon.OnReload(self, player)
end

function HeavyMachineGun:OnUpdateAnimationInput(modelMixin)

    PROFILE("HeavyMachineGun:OnUpdateAnimationInput")
    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)

    if Server and self.reloading and self.reloadtime + kHeavyMachineGunReloadTime < Shared.GetTime() then
        self.reloading = false
        self.ammo = self.ammo + self.clip
        self.reloadtime = 0
        // Transfer bullets from our ammo pool to the weapon's clip
        self.clip = math.min(self.ammo, self:GetClipSize())
        self.ammo = self.ammo - self.clip
    end

end

function HeavyMachineGun:GetHasAttackDelay()
    return self.lastfiredtime + self:GetFireDelay() > Shared.GetTime()
end

function HeavyMachineGun:OnTag(tagName)
    PROFILE("HeavyMachineGun:OnTag")
    if tagName == "deploy_end" then
        self.deployed = true
    end
end

function HeavyMachineGun:GetDeathIconIndex()
    return kDeathMessageIcon.HeavyMachineGun
end

function HeavyMachineGun:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function HeavyMachineGun:GetClipSize()
    return kHeavyMachineGunClipSize
end

function HeavyMachineGun:GetSpread()
    return Math.Radians(6)
end

local function HeavyMachineGunRandom()
    return math.max(0.1 + NetworkRandom())
end

function HeavyMachineGun:CalculateSpreadDirection(shootCoords, player)
    return CalculateSpread(shootCoords, self:GetSpread() * self:GetInaccuracyScalar(player), HeavyMachineGunRandom)
end

function HeavyMachineGun:GetBulletDamage(target, endPoint)
    return kHeavyMachineGunDamage
end

function HeavyMachineGun:GetRange()
    return kRange
end

function HeavyMachineGun:GetWeight()
    return kHeavyMachineGunWeight + ((math.ceil(self.ammo / self:GetClipSize()) + math.ceil(self.clip / self:GetClipSize())) * kHeavyMachineGunClipWeight)
end

function HeavyMachineGun:GetHasSecondary(player)
    return false
end

function HeavyMachineGun:GetSecondaryCanInterruptReload()
    return true
end

function HeavyMachineGun:OverrideWeaponName()
    return "rifle"
end

function HeavyMachineGun:GetCatalystSpeedBase()
    return 0.9 or 1
end

function HeavyMachineGun:GetBarrelSmokeEffect()
    return HeavyMachineGun.kBarrelSmokeEffect
end

function HeavyMachineGun:GetShellEffect()
    return chooseWeightedEntry ( HeavyMachineGun.kShellEffectTable )
end

function HeavyMachineGun:SetGunLoopParam(viewModel, paramName, rateOfChange)

    local current = viewModel:GetPoseParam(paramName)
    // 0.5 instead of 1 as full arm_loop is intense.
    local new = Clamp(current + rateOfChange, 0, 0.5)
    viewModel:SetPoseParam(paramName, new)

end

function HeavyMachineGun:GetDamageType()
    return kHeavyMachineGunDamageType
end

function HeavyMachineGun:OnSecondaryAttack(player)
end

function HeavyMachineGun:UpdateViewModelPoseParameters(viewModel)

    local attacking = self:GetPrimaryAttacking()
    local sign = (attacking and 1) or 0

    self:SetGunLoopParam(viewModel, "arm_loop", sign)

end

function HeavyMachineGun:GetAmmoPackMapName()
    return HeavyMachineGunAmmo.kMapName
end

if Client then

    function HeavyMachineGun:OnClientPrimaryAttacking()
	    Shared.StopSound(self, kSingleShotSound)
        Shared.PlaySound(self, kSingleShotSound)
    end

    function HeavyMachineGun:GetTriggerPrimaryEffects()
        return not self:GetIsReloading()
    end

    function HeavyMachineGun:OnClientPrimaryAttackEnd()
	    Shared.PlaySound(self, kEndSound)
    end

    function HeavyMachineGun:GetPrimaryEffectRate()
        return 0.08
    end

    function HeavyMachineGun:GetPreventCameraAnimation()
        return true
    end

    function HeavyMachineGun:GetBarrelPoint()

        local player = self:GetParent()
        if player then

            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()

            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.10 + viewCoords.yAxis * -0.22
        end

        return self:GetOrigin()

    end

end

function HeavyMachineGun:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    /*if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end*/

end

function HeavyMachineGun:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function HeavyMachineGun:OnKill()
        DestroyEntity(self)
    end

    function HeavyMachineGun:GetSendDeathMessageOverride()
        return false
    end

end

Shared.LinkClassToMap("HeavyMachineGun", HeavyMachineGun.kMapName, networkVars)

// -------------

class 'HeavyMachineGunAmmo' (WeaponAmmoPack)
HeavyMachineGunAmmo.kMapName = "heavymachinegunammo"
HeavyMachineGunAmmo.kModelName = PrecacheAsset("models/marine/ammopacks/hmg.model")

function HeavyMachineGunAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)
    self:SetModel(HeavyMachineGunAmmo.kModelName)

end

function HeavyMachineGunAmmo:GetWeaponClassName()
    return "HeavyMachineGun"
end

Shared.LinkClassToMap("HeavyMachineGunAmmo", HeavyMachineGunAmmo.kMapName)