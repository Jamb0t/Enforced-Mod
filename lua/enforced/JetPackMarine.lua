kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

local kFlySpeed = 9
local kFlyAcceleration = 21 //28

local orig_JetpackMarine_ModifyVelocity 
orig_JetpackMarine_ModifyVelocity = Class_ReplaceMethod( "JetpackMarine", "ModifyVelocity",
	function (input, velocity, deltaTime)
		if self:GetIsJetpacking() then
			
			local verticalAccel = 22 //22
			local verticalSpeed = 4 //max speed
			
			if self:GetIsWebbed() then
				verticalAccel = 14
			elseif input.move:GetLength() == 0 then
				verticalAccel = 26
				verticalSpeed = 6
			end
		
			self.onGround = false
			local thrust = math.max(0, -velocity.y) / 6
			velocity.y = math.min(verticalSpeed, velocity.y + verticalAccel * deltaTime * (1 + thrust * 2.5))
	 
		end
		
		if not self.onGround then
		
			// do XZ acceleration
			local prevXZSpeed = velocity:GetLengthXZ()
			local maxSpeedTable = { maxSpeed = math.max(kFlySpeed, prevXZSpeed) }
			self:ModifyMaxSpeed(maxSpeedTable)
			local maxSpeed = maxSpeedTable.maxSpeed        
			
			if not self:GetIsJetpacking() then
				maxSpeed = prevXZSpeed
			end
			
			local wishDir = self:GetViewCoords():TransformVector(input.move)
			local acceleration = 0
			wishDir.y = 0
			wishDir:Normalize()
			
			acceleration = math.max(kFlySpeed, kFlyAcceleration * (1 - self:GetWeaponsWeight()))
			
			velocity:Add(wishDir * acceleration * self:GetInventorySpeedScalar() * deltaTime)

			if velocity:GetLengthXZ() > maxSpeed then
			
				local yVel = velocity.y
				velocity.y = 0
				velocity:Normalize()
				velocity:Scale(maxSpeed)
				velocity.y = yVel
				
			end 
			
			if self:GetIsJetpacking() then
				velocity:Add(wishDir * kJetpackingAccel * deltaTime)
			end
		
		end

	end
)