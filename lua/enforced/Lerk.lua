kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

Script.Load("lua/Enforced/PushableMixin.lua")

local networkVars = {}
AddMixinNetworkVars(PushableMixin, networkVars)
Class_Reload("Lerk", networkVars)

local orig_Lerk_OnInitialized
orig_Lerk_OnInitialized = Class_ReplaceMethod( "Lerk", "OnInitialized", 
	function (self)
		InitMixin(self, PushableMixin)
		orig_Lerk_OnInitialized(self)
	end
)

local function UpdateAirBrake(self, input, velocity, deltaTime)
    -- more control when moving forward
    local holdingShift = bit.band(input.commands, Move.MovementModifier) ~= 0
    if input.move.z ~= 0 and holdingShift then
        
        if velocity:GetLengthXZ() > kLerkFlySoundMinSpeed then
            local yVel = velocity.y
			local newScale = math.max(velocity:GetLengthXZ() - (kLerkAirBrakeSpeedDecrease * deltaTime), kLerkFlySoundMinSpeed)
            velocity.y = 0
            velocity:Normalize()
            velocity:Scale(newScale)
            velocity.y = yVel
        end

    end

end

local orig_Lerk_ModifyVelocity
orig_Lerk_ModifyVelocity = Class_ReplaceMethod( "Lerk", "ModifyVelocity",
	function(self, input, velocity, deltaTime)
		orig_Lerk_ModifyVelocity(self, input, velocity, deltaTime)
		UpdateAirBrake(self, input, velocity, deltaTime)
	end
)