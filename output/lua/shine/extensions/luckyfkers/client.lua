local Shine = Shine
local Plugin = Plugin

Plugin.HasConfig = true
Plugin.ConfigName = "LuckyFkers.json"

Plugin.DefaultConfig =
{
	Feedback = true, -- Should we show feedback menu
}

Plugin.CheckConfig = true
Plugin.SilentConfigSave = true

function Plugin:Initialise()
	self.Enabled = true
	if self.Config.Feedback == nil then
		self.Config.Feedback = true
		Plugin:SaveConfig( true )
	end
	return true
end

--[[
function Plugin:Think(DeltaTime)
	if Client and not self.Config.Feedback then
		local gameFeedback = ClientUI.GetScript("GUIGameFeedback")
		if gameFeedback and gameFeedback:GetIsVisible() then
			gameFeedback:SetIsVisible(false)
		end

		if Client.showFeedback then
			Client.showFeedback = false
		end
	end
end
]]--

Shine.VoteMenu:EditPage( "Main",
function( self )
	self:AddSideButton( "LuckyFkers Mod",
	function()
		Client.ShowWebpage( "http://www.luckyfkers.com/enforced-ingame/" )
    end)

--[[
	-- dirty, but should work for now
	self:AddSideButton( "Toggle Feedback menu",
	function()
		local feedback = not Plugin.Config.Feedback
		Plugin.Config.Feedback = feedback

		local message = string.format("Feedback menu is now %s", feedback and "on" or "off")

		Shine.ScreenText.Add( 20,
		{
			X = 0.5, Y = 0.5,
			Text = message,
			Duration = 7,
			R = 0, G = 0, B = 128,
			Alignment = 2,
			Size = 2, FadeIn = 1
		})
    end)
]]--
end)
