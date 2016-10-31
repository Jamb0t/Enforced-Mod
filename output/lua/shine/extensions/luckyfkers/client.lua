local Shine = Shine
local Plugin = Plugin

Plugin.HasConfig = true
Plugin.ConfigName = "LuckyFkers.json"

Plugin.DefaultConfig =
{
}

Plugin.CheckConfig = true
Plugin.SilentConfigSave = true

function Plugin:Initialise()
	self.Enabled = true
	return true
end


Shine.VoteMenu:EditPage( "Main",
function( self )
	self:AddSideButton( "LuckyFkers Mod",
	function()
		Client.ShowWebpage( "http://www.luckyfkers.com/enforced-ingame/" )
    end)
end)
