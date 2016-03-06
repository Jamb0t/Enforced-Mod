Script.Load("lua/PushableMixin.lua")

local networkVars = {
}

AddMixinNetworkVars(PushableMixin, networkVars)

local orig_Skulk_OnInitialized = Skulk.OnInitialized
function Skulk:OnInitialized()
	InitMixin(self, PushableMixin)
	orig_Skulk_OnInitialized(self)
end