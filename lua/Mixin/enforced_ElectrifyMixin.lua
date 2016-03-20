// Natural Selection 2 'Classic' Mod
// Source located at - https://github.com/xToken/NS2c
// lua\ElectrifyMixin.lua
// - Dragon

ElectrifyMixin = CreateMixin( ElectrifyMixin )
ElectrifyMixin.type = "Electrify"

local kElectrifiedSound = PrecacheAsset("sound/NS2.fev/marine/commander/nano_damage")

ElectrifyMixin.expectedMixins =
{
}

ElectrifyMixin.networkVars =
{
    hasElectrifyUpgrade = "boolean", -- controls when the electrify upgrade is active
    timeElectrifyUpgrade = "time", -- last time the electrify upgrade was completed
	timeNextElectrifyDamaged = "time", -- next time the electrify upgrade can do damage
}

local function SetElectrify(self)
    self.hasElectrifyUpgrade = true
    self.timeElectrifyUpgrade = Shared.GetTime() + kElectrifyCooldownTime
    self.timeNextElectrifyDamaged = 0
end

local function ClearElectrify(self)
    self.hasElectrifyUpgrade = false
    self.timeElectrifyUpgrade = 0
    self.timeNextElectrifyDamaged = 0
end

function ElectrifyMixin:__initmixin()
    ClearElectrify(self)
    if Client then
        self.lasteffectupdate = 0
    end
end

function ElectrifyMixin:OnDestroy()
    if self:GetIsElectrified() then
        if not Client then
            ClearElectrify(self)
        elseif Client then
            self:_RemoveEffect()
        end
    end
end

function ElectrifyMixin:HasElectrifyUpgrade()
    return self.hasElectrifyUpgrade
end

function ElectrifyMixin:GetIsElectrified()
	return self.hasElectrifyUpgrade and self.timeElectrifyUpgrade > Shared.GetTime()
end

function ElectrifyMixin:GetCanElectrify()
	return self.hasElectrifyUpgrade and self.timeNextElectrifyDamaged < Shared.GetTime()
end

function ElectrifyMixin:OnResearchComplete(researchId)

    if researchId == kTechId.Electrify then

        SetElectrify(self)

		if Server then
		    self:AddTimedCallback(ElectrifyMixin.Update, kElectrifyPollRate)
		end
	end

end

function ElectrifyMixin:Update()

    -- Reset the upgrade if time has elapsed
    if self.hasElectrifyUpgrade and not self:GetIsElectrified() then
        ClearElectrify(self)
    end

    --
	if not self:GetIsAlive() or not self:GetIsPowered() or
	   not self:GetIsElectrified() or not self:GetCanElectrify() then
		return self:GetIsAlive()
	end

	local enemies = GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kElectricalRange + 2)
	local damageRadius = kElectricalRange
	local damagedentities = 0
	for index, entity in ipairs(enemies) do
		local attackPoint = entity:GetOrigin()
		if (attackPoint - self:GetOrigin()):GetLength() < damageRadius and damagedentities < kElectricalMaxTargets then
			if not entity:isa("Commander") and HasMixin(entity, "Live") and entity:GetIsAlive() then
				local trace = Shared.TraceRay(self:GetOrigin(), attackPoint, CollisionRep.Damage, PhysicsMask.Bullets, filterNonDoors)
				if entity.SetElectrified then
					entity:SetElectrified(.8)
				end
				self:SetEnergy(math.max(self:GetEnergy(), 0))
				self:DoDamage(kElectricalDamage, entity, trace.endPoint, (attackPoint - trace.endPoint):GetUnit(), "none" )
				damagedentities = damagedentities + 1
			end
		end
	end

	if damagedentities > 0 then
		self.timeNextElectrifyDamaged = Shared.GetTime() + kElectrifyDamageTime
		StartSoundEffectAtOrigin(kElectrifiedSound, self:GetOrigin())
	end

    return self:GetIsAlive()

end

if Client then

	local function UpdateClientElectrifyEffects(self)

		if self:GetIsElectrified() and self:GetIsAlive() then
			if self:GetIsPowered() then
				if not self.effecton then
					self:_RemoveEffect()
				end
				self:_CreateEffectOff()
				self.effectoff = false
			elseif not self:GetIsPowered() then
				self:_RemoveEffect()
			end
		end

	end

    function ElectrifyMixin:OnUpdateRender()

        PROFILE("ElectrifyMixin:OnUpdateRender")

        UpdateClientElectrifyEffects(self)
        if self.lasteffectupdate + 10 < Shared.GetTime() then
            self.lasteffectupdate = Shared.GetTime()
            self:_RemoveEffect()
        end

    end

    -- Adds the material effect to the entity and all child entities (hat have a Model mixin)
    local function AddEffect(entity, material, viewMaterial, entities)

        local numChildren = entity:GetNumChildren()

        if HasMixin(entity, "Model") then
            local model = entity._renderModel
            if model ~= nil then
                if model:GetZone() == RenderScene.Zone_ViewModel then
                    model:AddMaterial(viewMaterial)
                else
                    model:AddMaterial(material)
                end
                table.insert(entities, entity:GetId())
            end
        end

        for i = 1, entity:GetNumChildren() do
            local child = entity:GetChildAtIndex(i - 1)
            AddEffect(child, material, viewMaterial, entities)
        end

    end

    local function RemoveEffect(entities, material, viewMaterial)

        for i =1, #entities do
            local entity = Shared.GetEntity( entities[i] )
            if entity ~= nil and HasMixin(entity, "Model") then
                local model = entity._renderModel
                if model ~= nil then
                    if model:GetZone() == RenderScene.Zone_ViewModel then
                        model:RemoveMaterial(viewMaterial)
                    else
                        model:RemoveMaterial(material)
                    end
                end
            end
        end

    end

    function ElectrifyMixin:_CreateEffectOn()

        if not self.electrifiedMaterial then

            local material = Client.CreateRenderMaterial()
            material:SetMaterial("cinematics/vfx_materials/electrified.material")

            local viewMaterial = Client.CreateRenderMaterial()
            viewMaterial:SetMaterial("cinematics/vfx_materials/electrified_view.material")

            self.electrifiedEntities = {}
            self.electrifiedMaterial = material
            self.electrifiedViewMaterial = viewMaterial
            AddEffect(self, material, viewMaterial, self.electrifiedEntities)

        end

    end

    function ElectrifyMixin:_CreateEffectOff()

        if not self.electrifiedMaterial then

            local material = Client.CreateRenderMaterial()
            material:SetMaterial("cinematics/vfx_materials/electrified_1.material")

            local viewMaterial = Client.CreateRenderMaterial()
            viewMaterial:SetMaterial("cinematics/vfx_materials/electrified_view_1.material")

            self.electrifiedEntities = {}
            self.electrifiedMaterial = material
            self.electrifiedViewMaterial = viewMaterial
            AddEffect(self, material, viewMaterial, self.electrifiedEntities)

        end

    end

    function ElectrifyMixin:_RemoveEffect()

        if self.electrifiedMaterial then
            RemoveEffect(self.electrifiedEntities, self.electrifiedMaterial, self.electrifiedViewMaterial)
            Client.DestroyRenderMaterial(self.electrifiedMaterial)
            Client.DestroyRenderMaterial(self.electrifiedViewMaterial)
            self.electrifiedMaterial = nil
            self.electrifiedViewMaterial = nil
            self.electrifiedEntities = nil
        end

    end

end