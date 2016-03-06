local networkVars = {
}

local kMaxSpeed = 5.85

local orig_Exo_OnInitialized = Exo.OnInitialized
function Exo:OnInitialized()

    orig_Exo_OnInitialized(self)
end

local orig_Exo_GetSlowOnLand = Exo.GetSlowOnLand
function Exo:GetSlowOnLand()
    return true
end
local orig_Exo_GetWebSlowdownScalar = Exo.GetWebSlowdownScalar
function Exo:GetWebSlowdownScalar()
    return 0.6
end

local orig_Exo_GetArmorAmount = Exo.GetArmorAmount 
function Exo:GetArmorAmount(armorLevels)
	
	if not armorLevels then
    
        armorLevels = 0
    
        if GetHasTech(self, kTechId.Armor3, true) then
            armorLevels = 3
        elseif GetHasTech(self, kTechId.Armor2, true) then
            armorLevels = 2
        elseif GetHasTech(self, kTechId.Armor1, true) then
            armorLevels = 1
        end
    
    end

	return 320 + armorLevels * 55

end

ReplaceLocals(Exo.UpdateThrusters, { kThrustersCooldownTime = 2.5 })
ReplaceLocals(Exo.UpdateThrusters, { kThrusterDuration = 1.2 })

local kUpVector = Vector(0, 1, 0)
function Exo:ModifyVelocity(input, velocity, deltaTime)

    if self.thrustersActive then
    
        if self.thrusterMode == kExoThrusterMode.Vertical then   
        
            velocity:Add(kUpVector * 20 * deltaTime)
            velocity.y = math.min(1, velocity.y)
            
        elseif self.thrusterMode == kExoThrusterMode.Horizontal then
                
            local maxSpeed = self:GetMaxSpeed() + 2.2
            local wishDir = self:GetViewCoords():TransformVector(input.move)
            wishDir.y = 0
            wishDir:Normalize()
            
            local currentSpeed = wishDir:DotProduct(velocity)
            local addSpeed = math.max(0, maxSpeed - currentSpeed)
            
            if addSpeed > 0 then
                    
                local accelSpeed = 50 * deltaTime               
                accelSpeed = math.min(addSpeed, accelSpeed)
                velocity:Add(wishDir * accelSpeed)
            
            end
        
        end
        
    end
    
end

if Server then
    local orig_Exo_PerformEject = Exo.PerformEject
    function Exo:PerformEject()
        if self:GetIsAlive() then

            local exosuit = CreateEntity(Exosuit.kMapName, self:GetOrigin(), self:GetTeamNumber())
            exosuit:SetLayout(self.layout)		
            exosuit:SetCoords(self:GetCoords())
            exosuit:SetMaxArmor(self:GetMaxArmor())
            exosuit:SetArmor(self:GetArmor())
			exosuit:SetExoVariant(self:GetExoVariant())
		
		    local reuseWeapons = self.storedWeaponsIds ~= nil
            
            local marine = self:Replace(self.prevPlayerMapName or Marine.kMapName, self:GetTeamNumber(), false, self:GetOrigin() + Vector(0, 0.2, 0), { preventWeapons = reuseWeapons })
            marine:SetHealth(self.prevPlayerHealth or kMarineHealth)
            marine:SetMaxArmor(self.prevPlayerMaxArmor or kMarineArmor)
            marine:SetArmor(self.prevPlayerArmor or kMarineArmor)
            
            exosuit:SetOwner(marine)
            
            marine.onGround = false
            local initialVelocity = self:GetViewCoords().zAxis
            initialVelocity:Scale(4)
            initialVelocity.y = 9
            marine:SetVelocity(initialVelocity)
            
            if reuseWeapons then
                for _, weaponId in ipairs(self.storedWeaponsIds) do
                    local weapon = Shared.GetEntity(weaponId)
                    if weapon then
                        marine:AddWeapon(weapon)
                    end
                end
            end
            marine:SetHUDSlotActive(1)
            if marine:isa("JetpackMarine") then
                marine:SetFuel(.2)
            end
        end
        return false
    end
end	