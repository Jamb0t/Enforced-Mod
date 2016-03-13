
Script.Load("lua/Mixin/PushableMixin.lua")

local networkVars = {}
AddMixinNetworkVars(PushableMixin, networkVars)
--Class_Reload("Skulk", networkVars)

local orig_Skulk_OnInitialized  
orig_Skulk_OnInitialized = Class_ReplaceMethod( "Skulk", "OnInitialized", 
	function (self)
		InitMixin(self, PushableMixin)
		orig_Skulk_OnInitialized(self)
	end
)