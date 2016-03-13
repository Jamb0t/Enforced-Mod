// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\XenocideLeap.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
// 
//    First primary attack is xenocide, every next attack is bite. Secondary is leap.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")

local kRange = 1.6

class 'Doomsday' (Ability)

Doomsday.kMapName = "doomsday"

local kAnimationGraph = PrecacheAsset("models/alien/onos/onos_view.animation_graph")
local attackEffectMaterial = nil

// after kDetonateTime seconds the skulk goes 'boom!'
local kDetonateTime = 3.0
local kXenocideSoundName = PrecacheAsset("sound/NS2.fev/alien/onos/stomp")

local networkVars = { }
        
local function TriggerXenocide(self, player)

    if Server then
	
        StartSoundEffectOnEntity(kXenocideSoundName, player)
        self.xenocideTimeLeft = kDetonateTime
        
    elseif Client and Client.GetLocalPlayer() == player then

        if not self.xenocideGui then
            self.xenocideGui = GetGUIManager():CreateGUIScript("GUIXenocideFeedback")
        end
    
        self.xenocideGui:TriggerFlash(kDetonateTime)
        player:SetCameraShake(.01, 15, kDetonateTime)
        
    end
    
end

local function CleanUI(self)

    if self.xenocideGui ~= nil then
    
        GetGUIManager():DestroyGUIScript(self.xenocideGui)
        self.xenocideGui = nil
        
    end

end
    
function Doomsday:OnDestroy()

    Ability.OnDestroy(self)
	
    if Client then
        CleanUI(self)
    end

end

function Doomsday:GetDeathIconIndex()
    return kDeathMessageIcon.Consumed
end

function Doomsday:GetEnergyCost(player)

    if not self.xenociding then
        return kOnoscideEnergyCost
    else
        return Ability.GetEnergyCost(self, player)
    end
    
end

function Doomsday:GetAnimationGraphName()
    return kAnimationGraph
end

function Doomsday:GetHUDSlot()
    return 3
end

function Doomsday:GetRange()
    return kRange
end

function Doomsday:OnPrimaryAttack(player)
    
    if player:GetEnergy() >= self:GetEnergyCost() then
    
        if not self.xenociding then

            TriggerXenocide(self, player)
            self.xenociding = true
			
        else
        
            if self.xenocideTimeLeft and self.xenocideTimeLeft < kDetonateTime * 0.8 then
                Ability.OnPrimaryAttack(self, player)
            end
            
        end
        
    end
    
end

local function StopXenocide(self)

    CleanUI(self)
    
    self.xenociding = false

end

function Doomsday:OnHolster(player)

    if self.xenocideGui ~= nil then
    
        GetGUIManager():DestroyGUIScript(self.xenocideGui)
        self.xenocideGui = nil
    
    end
     
    self.xenociding = false

end

function Doomsday:OnProcessMove(input)

    Ability.OnProcessMove(self, input)
    
    local player = self:GetParent()
    if self.xenociding then
    player:DeductAbilityEnergy(kOnoscideEnergyCost)
        if player:isa("Commander") then
            StopXenocide(self)
        elseif Server then
        
            self.xenocideTimeLeft = math.max(self.xenocideTimeLeft - input.time, 0)
            
            if self.xenocideTimeLeft == 0 and player:GetIsAlive() then
            
                player:TriggerEffects("xenocide", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
                
                local hitEntities = GetEntitiesWithMixinWithinRange("Live", player:GetOrigin(), kOnoscideRange)
                RadiusDamage(hitEntities, player:GetOrigin(), kOnoscideRange, kOnoscideDamage + player:GetArmor(), self)
                
                player.spawnReductionTime = 4
                
                player:SetBypassRagdoll(true)

                player:Kill()

            end 

        elseif Client and not player:GetIsAlive() and self.xenocideGui then
            CleanUI(self)
        end
        
    end
    
end

if Server then

    function Doomsday:GetDamageType()
    
        if self.xenocideTimeLeft == 0 then
            return kOnoscideDamageType
        else
            return kBiteDamageType
        end
        
    end
    
end

Shared.LinkClassToMap("Doomsday", Doomsday.kMapName, networkVars)