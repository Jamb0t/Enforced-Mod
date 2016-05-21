// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\PushableMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

PushableMixin = CreateMixin( PushableMixin )
PushableMixin.type = "Pushable"

local kDefaultForce = 1
local kDefaultDuration = 0.1
local kMaxForce = 4 //so the force cannot go crazy strong. engine limit is 50.

PushableMixin.optionalCallbacks =
{
}

PushableMixin.networkVars =
{
    pushed = "private compensated boolean",
    //timePushEnds = "private compensated time",
	pushVelocity = "private compensated vector"
}

function PushableMixin:__initmixin()

	self.pushed = false	
	self.pushVelocity = Vector(0, 0, 0)
	if Server then
		self.timePushEnds = 0
	end

end

function PushableMixin:GetIsPushed()
    return self.pushed
end    

function PushableMixin:Push(newForce, duration, override)
	
	if newForce:GetLength() >= 0.01 then
		local pushDuration = duration or kDefaultDuration		
		local newVelocity = Vector(0, 0, 0)
		local canPush = false
				
		if override == true then
			canPush = true
			newVelocity = newForce
		elseif not self.pushed then
			canPush = true
			newVelocity = self.pushVelocity + newForce
		end
		
		if newVelocity:GetLength() > kMaxForce then
			newVelocity:Scale(kMaxForce/newVelocity:GetLength())
		end
		
		if canPush then
			if Server then
				self:DisableGroundMove(pushDuration)
				self.pushed = true
				self.pushVelocity = newVelocity
				self.timePushEnds = Shared.GetTime() + pushDuration
			end			
		end
		
	end
	
end

local function SharedUpdate(self)

    local wasPushed = self.pushed
	if Server then
		self.pushed = self.timePushEnds > Shared.GetTime()
	end
    
    if wasPushed and not self.pushed and self.OnPushedEnd then
        self:OnPushedEnd()
    end
    
	if self.pushed then
		self:SetVelocity(self.pushVelocity)
	end	
	
end

if Server then

    function PushableMixin:OnUpdate(deltaTime)
        PROFILE("PushableMixin:OnUpdate")
        SharedUpdate(self)
    end
	    
end

function PushableMixin:OnProcessMove(input)

    SharedUpdate(self)
        
end