Script.Load("lua/PushableMixin.lua")

local networkVars = {
}

AddMixinNetworkVars(PushableMixin, networkVars)

local orig_Lerk_OnInitialized = Lerk.OnInitialized
function Lerk:OnInitialized()
	InitMixin(self, PushableMixin)
	orig_Lerk_OnInitialized(self)
end