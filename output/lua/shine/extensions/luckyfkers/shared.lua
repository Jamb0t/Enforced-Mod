local Shine = Shine
local Plugin = {}

Plugin.HasConfig = false

function Plugin:Initialise()
	self.Enabled = true
	return true
end

Shine:RegisterExtension( "luckyfkers", Plugin )
