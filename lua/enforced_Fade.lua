// Natural Selection 2 Competitive Mod
// Source located at - https://github.com/xToken/CompMod
// Detailed breakdown of changes at https://docs.google.com/document/d/1YOnjJz6_GhioysLaWiRfc17xnrmw6AEJIb6gq7TX3Qg/edit?pli=1
// lua\CompMod\Shared\FadeBlinkAdjustments.lua
// - Dragon

local kOffsetUpdate = 0 //Full Speed
local kFadeOffsetRange = 1
local kFadeOffsetScalar = 5

local networkVars = 
{ 
    modelOffset = "compensated interpolated float", 
    updateOffset = "compensated boolean", 
    lastOffsetTime = "compensated time"
}

local originalFadeOnCreate
originalFadeOnCreate = Class_ReplaceMethod("Fade", "OnCreate",
function(self)
    originalFadeOnCreate(self)
    self.updateOffset = false
    self.modelOffset = 0
    self.lastOffsetTime = 0
end
)

local originalFadeModifyVelocity
originalFadeModifyVelocity = Class_ReplaceMethod("Fade", "ModifyVelocity",
function(self, input, velocity, deltaTime)

    originalFadeModifyVelocity(self, input, velocity, deltaTime)
    
    //Model offset for crouching blinking fades
    if self.lastOffsetTime + kOffsetUpdate < Shared.GetTime() then
        local origin = self:GetOrigin()
        //Trace up to make sure we are against the ceiling.
        //Default to no updates
        self.updateOffset = false
        local upTrace = Shared.TraceRay(origin, origin + Vector(0, Fade.YExtents + kFadeCrouchModelOffset, 0), CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOneAndIsa(self, "Babbler"))
        if upTrace.fraction > 0 and upTrace.fraction < 1 then
            //The ceiling is here.
            //Trace down to make sure we are not against the floor.
            local downTrace = Shared.TraceRay(origin, origin - Vector(0, kFadeCrouchModelOffset, 0), CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOne(self))
            if downTrace.fraction <= 0 or downTrace.fraction >= 1 then
                self.updateOffset = true
            end
        end
        self.lastOffsetTime = Shared.GetTime()
    end
    
    local crouchoffset = self:GetCrouchAmount() 
    local modelcrouchoffset = self:ModifyCrouchAnimation(crouchoffset)
    local maxoffset = (crouchoffset - modelcrouchoffset) * kFadeCrouchModelOffset
    if crouchoffset > 0 and self.updateOffset then
        if self.modelOffset < maxoffset then
            self.modelOffset = math.min(maxoffset, self.modelOffset + (input.time * kFadeOffsetScalar))
        end
    else
        if self.modelOffset > 0 then
            self.modelOffset = math.max(0, self.modelOffset - (input.time * kFadeOffsetScalar))
        end
    end

end
)

Class_AddMethod( "Fade", "OnAdjustModelCoords",
function (self, modelCoords)
    modelCoords.origin = modelCoords.origin - Vector(0, self.modelOffset, 0)
    return modelCoords
end
)

Shared.LinkClassToMap("Fade", Fade.kMapName, networkVars, true)
