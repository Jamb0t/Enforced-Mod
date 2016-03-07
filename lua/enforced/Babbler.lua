kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

local kNewFov = 160
local kNewAttackRange = 1
local kNewAttackRate = 0.5
local kNewLifeTime = 90
local kNewTargetSearchRange = 16
local kNewUpdateAttackInterval = 0.66

local kMinJumpDistance = 1
local kMaxJumpDistance = 8
local kNewBabblerRunSpeed = 9
local kNewVerticalJumpForce = 4
local kNewMaxJumpForce = 13
local kNewMinJumpForce = 3
local kNewTurnSpeed = math.pi * 2

-- OnInitialized
ReplaceLocals(Babbler.OnInitialized, { kTargetSearchRange = kNewTargetSearchRange, kUpdateAttackInterval = kNewUpdateAttackInterval, kLifeTime = kNewLifeTime } )
ReplaceLocals(Babbler.ProcessHit, { kAttackRate = kNewAttackRate } )

-- OnUpdatePoseParameters
ReplaceLocals(Babbler.OnUpdatePoseParameters, { kBabblerRunSpeed = kNewBabblerRunSpeed } )

-- GetTurnSpeedOverride
ReplaceLocals(Babbler.GetTurnSpeedOverride, { kTurnSpeed = kNewTurnSpeed } )

-- GetIsOnGround
local orig_Babbler_GetIsOnGround
orig_Babbler_GetIsOnGround = Class_ReplaceMethod( "Babbler", "GetIsOnGround", 
    function(self)
        local velocity = self:GetVelocity()
        return velocity:GetLength() < 1 and math.abs(velocity.y) < 0.5
    end
)

-- GetFov
Class_AddMethod( "Babbler", "GetFov",
	function(self)
		return kNewFov
	end
)

-- JumpRandom
local orig_Babbler_JumpRandom
orig_Babbler_JumpRandom = Class_ReplaceMethod( "Babbler", "JumpRandom", 
    function(self)
        self:Jump(Vector( (math.random() * 3) - 1.5, 2 + math.random() * 2, (math.random() * 3) - 1.5 ))
    end
)

-- UpdateAttack
local function NewGetMoveVelocity(self, targetPos)
	moveVelocity = (targetPos - self:GetOrigin()) * 1.25

	local YDiff = moveVelocity.y * 0.8

	local moveSpeedXZ = moveVelocity:GetLengthXZ()

	if moveSpeedXZ > kNewMaxJumpForce then
		moveVelocity:Scale(kNewMaxJumpForce / moveSpeedXZ)
	elseif moveSpeedXZ < kNewMinJumpForce then
		moveVelocity:Scale(kNewMinJumpForce / (moveSpeedXZ + 0.0001) )
	end

	if YDiff > 2 then
		moveVelocity.y = 8
	elseif YDiff > 1.2 then
		moveVelocity.y = 6
	else
		moveVelocity.y = kNewVerticalJumpForce
	end

	return moveVelocity
end
ReplaceUpValue( Babbler.UpdateAttack, "GetMoveVelocity", NewGetMoveVelocity, { LocateRecurse = true; CopyUpValues = true; } )

-- UpdateMove ...
local UpdateTargetPosition = GetUpValue( Babbler.UpdateMove, "UpdateTargetPosition" )
local UpdateClingAttached = GetUpValue( Babbler.UpdateMove, "UpdateClingAttached" )
local UpdateCling = GetUpValue( Babbler.UpdateMove, "UpdateCling" ) 
local NoObstacleInWay = GetUpValue( Babbler.UpdateMove, "NoObstacleInWay" )

local orig_Babbler_UpdateMove
orig_Babbler_UpdateMove = Class_ReplaceMethod( "Babbler", "UpdateMove", 
    function(self, deltaTime)

        PROFILE("Babbler:UpdateMove")

        UpdateTargetPosition(self)

        if self.clinged then

            UpdateClingAttached(self)

        elseif self.moveType == kBabblerMoveType.Move or self.moveType == kBabblerMoveType.Cling then

            if self.moveType == kBabblerMoveType.Cling and self.targetPosition and (self:GetOrigin() - self.targetPosition):GetLength() < 7 then

                UpdateCling(self, deltaTime)
                success = true

            elseif self:GetIsOnGround() then

                if self.timeLastJump + 0.5 < Shared.GetTime() then

                    local targetPosition = self.targetPosition or ( self:GetTarget() and self:GetTarget():GetOrigin())
                    if targetPosition then

                        local distance = math.max(0, ((self:GetOrigin() - targetPosition):GetLength() - kMinJumpDistance))
                        local Ydiff = (targetPosition - self:GetOrigin()).y
                        local shouldJump = 0.5
                        local jumpProbablity = 0

                        if Ydiff > 1 then
                            jumpProbablity = 1
                        elseif distance < kMaxJumpDistance then
                            jumpProbablity = 1 / (1 + distance)
                        end

                        local done = false
                        if self.jumpAttempts < 3 and jumpProbablity >= shouldJump and NoObstacleInWay(self, targetPosition) then
                            done = self:Jump(GetMoveVelocity(self, targetPosition))
                            self.jumpAttempts = self.jumpAttempts + 1
                        else
                            done = self:Move(targetPosition, deltaTime)
                        end

                        if done or (self:GetOrigin() - targetPosition):GetLengthXZ() <= 1.5 then
                            if self.physicsBody then
                                self.physicsBody:SetCoords(self:GetCoords())
                            end
                            self:SetMoveType(kBabblerMoveType.None)
                        end

                        success = true

                    end

                end

                if not success then
                    self:SetMoveType(kBabblerMoveType.None)
                end

            end

        end

        self.jumping = not self:GetIsOnGround()
    end
)

-- UpdateJumpPhysics
local orig_Babbler_UpdateJumpPhysics
orig_Babbler_UpdateJumpPhysics = Class_ReplaceMethod( "Babbler", "UpdateJumpPhysics", 
    function(self, deltaTime)

        local velocity = self:GetVelocity()
        local origin = self:GetOrigin()

        // simulation is updated only during jumping
        if self.physicsBody and not self.doesGroundMove then

            // If the Babbler has moved outside of the world, destroy it
            local coords = self.physicsBody:GetCoords()
            local origin = coords.origin

            local maxDistance = 1000

            if origin:GetLengthSquared() > maxDistance * maxDistance then
                Print( "%s moved outside of the playable area, destroying", self:GetClassName() )
                DestroyEntity(self)
            else
                // Update the position/orientation of the entity based on the current
                // position/orientation of the physics object.
                self:SetCoords( coords )
            end

            if self.lastVelocity ~= nil then

                local delta = velocity - self.lastVelocity
                if delta:GetLengthSquaredXZ() > 0.0001 then

                    local endPoint = self.lastOrigin + self.lastVelocity * (deltaTime + kNewAttackRange)

                    local trace = Shared.TraceCapsule(self.lastOrigin, endPoint, kNewAttackRange * 0.5, 0, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(self, "Babbler"))
                    self:ProcessHit(trace.entity, trace.surface)

                end

            end

            if self.targetSelector then
                self.targetSelector:AttackerMoved()
            end

        end

    end
)

-- Move
local orig_Babbler_Move
orig_Babbler_Move = Class_ReplaceMethod( "Babbler", "Move", 
   function(targetPos, deltaTime)

        self:SetGroundMoveType(true)

        local prevY = self:GetOrigin().y
        local done = self:MoveToTarget(PhysicsMask.AIMovement, targetPos, kNewBabblerRunSpeed, deltaTime)

        local newOrigin = self:GetOrigin()
        local desiredY = newOrigin.y + Babbler.kRadius
        newOrigin.y = Slerp(prevY, desiredY, deltaTime * 5)

        self:SetOrigin(newOrigin)
        self.targetSelector:AttackerMoved()

        return done

    end
)

-- MoveRandom
local GetBabblerBall = GetUpValue( Babbler.UpdateAttack, "GetBabblerBall" ) 

local function NewFindSomethingInteresting(self)

	PROFILE("Babbler:FindSomethingInteresting")

	local origin = self:GetOrigin()
	local searchRange = kTargetSearchRange
	local targetPos = nil
	local randomTarget = self:GetOrigin() + Vector(math.random() * 4 - 2, 0, math.random() * 4 - 2)

	if math.random() < 0 then
		targetPos = randomTarget
	else

		local babblerBall = GetBabblerBall(self)

		if babblerBall then
			targetPos = babblerBall:GetOrigin()
		else

			local interestingTargets = { }
			table.copy(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), origin, searchRange), interestingTargets, true)
			// cysts are very attractive, they remind us of the ball we like to catch!
			table.copy(GetEntitiesForTeamWithinRange("Cyst", self:GetTeamNumber(), origin, searchRange), interestingTargets, true)

			local numTargets = #interestingTargets
			if numTargets > 1 then
				targetPos = interestingTargets[math.random (1, numTargets)]:GetOrigin()
			elseif numTargets == 1 then
				targetPos = interestingTargets[1]:GetOrigin()
			else
				targetPos = randomTarget
			end

		end

	end

	return targetPos

end

ReplaceUpValue( Babbler.MoveRandom, "FindSomethingInteresting", NewFindSomethingInteresting, { LocateRecurse = true; CopyUpValues = true; } )