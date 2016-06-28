-- Defines
local Max = math.max
local Min = math.min

--The plugin table registered in shared.lua is passed in as the global "Plugin".
local Plugin = Plugin

function Plugin:Initialise()
	self:CreateCommands()

	self.Enabled = true

	return true
end

--Here we create two commands that set our datatable values.
function Plugin:Notify( Player, Title, Message, Format, ... )
	Shine:NotifyDualColour( Player, 100, 255, 100, Title, 255, 255, 255, Message, Format, ... )
end

function Plugin:CreateCommands()
  local Commands = Plugin.Commands
  
  //MCG.EnableMove = false

	/*local function ChangeBool( Client, Bool )
		self.dt.Bool = Bool
	end
	local ChangeBool = self:BindCommand( "sh_test_bool", "bool", ChangeBool, true )
	ChangeBool:AddParam{ Type = "boolean", Optional = true, Default = function() return not self.dt.Bool end }*/

	local function ComMoveServer( Client, host )
    MCG.SendMoveServer(host)
	end
	local ComMoveServer = self:BindCommand( "sh_moveserver", "string", ComMoveServer, true )
	ComMoveServer:AddParam{ Type = "string", Optional = false }
  
	/*local function ComSetEnableMove( Client, enable )
    MCG.EnableMove = enable
	end
	local ComSetEnableMove = self:BindCommand( "sh_move", "bool", ComSetEnableMove, true )
	ComSetEnableMove:AddParam{ Type = "boolean", Optional = false }*/

	local function ComForceEvenTeams( Client )
    ForceEvenTeams()
	end
	local ComMoveServer = self:BindCommand( "sh_forceeventeams", "string", ComForceEvenTeams, true )
  
	local function ComShuffleTeams( Client )
    local VoteRandom = Shine.Plugins.voterandom
    VoteRandom:ShuffleTeams()
	end
	local ComMoveServer = self:BindCommand( "sh_shuffle", "string", ComShuffleTeams, true )
  
	local function ComBalance( Client )
    local Players = Shine.GetAllPlayers()
    if (#Players <= 9) then
      return
    end
  
    local VoteRandom = Shine.Plugins.voterandom
    local scores = VoteRandom:GetTeamStats()
    local marineSkill, alienSkill = scores[1].Average, scores[2].Average
    
    Shine:Print( "Skills: #%i #%i", true, marineSkill, alienSkill )

    local variance = Max(marineSkill, alienSkill) - Min(marineSkill, alienSkill)
    if (variance > 300) then
      self:Notify( nil, "[Shuffle]", "Team skill was too varied by %i.", true, variance )
      
      local VoteRandom = Shine.Plugins.voterandom
      VoteRandom:ShuffleTeams()
      VoteRandom:ShuffleTeams()
    end
	end
	self:BindCommand( "sh_balance", "string", ComBalance, true )
  
  local PreGame = Shine.Plugins.pregame
  local oldStartCountdown = PreGame.StartCountdown
  PreGame.StartCountdown = function()
    oldStartCountdown(PreGame)
    
    ComBalance()
  end
  
  /*Shine:RegisterCommand( "sh_forceeventeams", "sh_forceeventeams", function( Client )
    ForceEvenTeams()
  end )
  
  Shine:RegisterCommand( "sh_shuffle", "sh_shuffle", function( Client )
    local VoteRandom = Shine.Plugins.voterandom
    VoteRandom:ShuffleTeams()
  end )*/
  
	local function ComTest( Client )
    self:Notify( nil, "[Test]", "7" )
	end
	self:BindCommand( "test", "string", ComTest, true )
end

--We call the base class cleanup to remove the console commands.
function Plugin:Cleanup()
	self.BaseClass.Cleanup( self )

	Print "Disabling feature pack plugin..."
end