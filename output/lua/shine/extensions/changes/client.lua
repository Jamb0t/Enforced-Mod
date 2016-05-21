local Shine = Shine
local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end

Shine.VoteMenu:EditPage( "Main", function( self ) 
self:AddSideButton( "MOD Changes", function()
Client.ShowWebpage( "http://www.luckyfkers.com/enforced-ingame/" )

    end)
end)


