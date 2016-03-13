local Plugin = Plugin
local Shine = Shine
local VoteMenu = Shine.VoteMenu

function Plugin:ReceiveEnableBalance( Data )
	VoteMenu:EditPage( "Main", function( self )
		self:AddSideButton( "Shuffle", function()
			Shared.ConsoleCommand( "sh_votebalance" )
			VoteMenu:SetIsVisible( false )
		end )
	end )
end