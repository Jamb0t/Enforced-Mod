local Shine = Shine
local Plugin = {}

function Plugin:Initialise()
	self:SetupAdminMenuCommands()
	self.Enabled = true
	return true
end

Shine:RegisterExtension( "changes", Plugin )
