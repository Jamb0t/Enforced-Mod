local Plugin = Plugin
local Shine = Shine

local Abs = math.abs
local Ceil = math.ceil
local Clamp = math.Clamp
local Decode = json.decode
local Floor = math.floor
local assert = assert
local GetAllPlayers = Shine.GetAllPlayers
local GetNumPlayers = Shine.GetHumanPlayerCount
local IsType = Shine.IsType
local Max = math.max
local Min = math.min
local next = next
local Random = math.random
local SharedTime = Shared.GetTime
local StringFormat = string.format
local TableConcat = table.concat
local TableEmpty = table.Empty
local TableRemove = table.remove
local TableSort = table.sort
local tostring = tostring
local GetOwner = Server.GetOwner
local Notify = Shared.Message
local BalanceMinTime
local BlockTeamsUntilTime = Shared.GetTime()

Plugin.MODE_RANDOM = 1
Plugin.MODE_SCORE = 2
Plugin.MODE_ELO = 3
Plugin.MODE_KDR = 4
Plugin.MODE_HIVE = 5

local ModeStrings = {
	Mode = {
		"Random",
		"Score based",
		"Elo based",
		"KDR based",
		"Hive skill based"
	},
	ModeLower = {
		"random",
		"score based",
		"Elo based",
		"KDR based",
		"Hive skill based"
	},
	Action = {
		"randomly",
		"based on score",
		"based on Elo",
		"based on KDR",
		"based on Hive skill"
	}
}
Plugin.ModeStrings = ModeStrings

Plugin.Conflicts = {
    DisableThem = {
        "voterandom"
    },
    DisableUs = {
	}
}

Plugin.RandomEndTimer = "VoteRandomTimer"

function Plugin:Notify( Player, Message, Format, ... )
	Shine:NotifyDualColour( Player, 81, 194, 243, "[Balance]", 255, 255, 255, Message, Format, ... )
end

function Plugin:CreateCommands()
	local function VoteBalance( Client )
		local Gamerules = GetGamerules()
		local GameState = Gamerules:GetGameState()
		local State = Gamerules:GetGameState()
		local GameStarted = true

		if State == kGameState.PreGame or State == kGameState.NotStarted or State == kGameState.Countdown then
			GameStarted = false
		end

		if GameStarted then
			Plugin:Notify( Client, "Cannot vote balance since a game is underway", true )
			return
		end

		local Time = Shared.GetTime()

		if (Time <= BalanceMinTime) then
			Plugin:Notify( Client, "There is a %s second cooldown at the start of each round", true, self.Config.BalanceDelayInSeconds )
			return
		end

		local BlockTimeLeft = math.floor(BlockTeamsUntilTime - Shared.GetTime() + 0.5)

		if BlockTimeLeft > 0 then
			Plugin:Notify( Client, "Teams are balanced locked for %s more seconds", true, BlockTimeLeft )
			return false
		end

		local Player = Client and Client:GetControllingPlayer()
		local PlayerName = Player and Player:GetName() or "Console"

		local Team = Player:GetTeamNumber()

		local Success, Err = self:AddVote( Client )

		if Success then
			local VotesNeeded = self.Vote:GetVotesNeeded()

			if not self.BalanceApplied then
				self:Notify( nil, "%s voted to balance teams. %s more needed (M > Balance)", true, PlayerName, VotesNeeded )
			end

			if VotesNeeded == 0 and not self.BalanceApplied then
				self:ApplyBalanceSettings()
			end

			return
		end

		if Player then
			Shine:NotifyError( Player, Err )
		else
			Notify( Err )
		end
	end
	local VoteBalanceCommand = self:BindCommand( "sh_votebalance", { "balance", "votebalance" }, VoteBalance, true )
	VoteBalanceCommand:Help( "Votes to force balanced teams" )

	local function ForceBalance( Client, Enable )
		local Gamerules = GetGamerules()
		local GameState = Gamerules:GetGameState()
		local State = Gamerules:GetGameState()
		local GameStarted = true

		if State == kGameState.PreGame or State == kGameState.NotStarted or State == kGameState.Countdown then
			GameStarted = false
		end

		if GameStarted then
			Plugin:Notify( Client, "Cannot force balance since a game is underway", true )
			return
		end

		local Time = Shared.GetTime()

		if (Time <= BalanceMinTime) then
			Plugin:Notify( Client, "There is a %s second cooldown at the start of each round", true, self.Config.BalanceDelayInSeconds )
			return
		end

		self.Vote:Reset()
		self:ApplyBalanceSettings()

		Shine:CommandNotify( Client, "enabled %s teams", true, ModeStrings.ModeLower[ self.Config.BalanceMode ] )
	end
	local ForceBalanceCommand = self:BindCommand( "sh_forcebalance", { "forcebalance" }, ForceBalance )
	ForceBalanceCommand:Help( "<true/false> Enables (and applies) or disables forcing balancing of teams" )
end

function Plugin:ClientConfirmConnect( Client )
	self:SendNetworkMessage( Client, "EnableBalance", { }, true )
end

function Plugin:CheckGameStart( Gamerules )
	local State = Gamerules:GetGameState()

	if State ~= kGameState.NotStarted and State ~= kGameState.PreGame then return end

	--Do not allow starting too soon.
	if SharedTime() < BalanceMinTime then
		return false
	end
end

local ModeError = [[Error in voterandom config, FallbackMode is not set as a valid option.
Make sure BalanceMode and FallbackMode are not the same, and that FallbackMode is not 3 (Elo) or 5 (Hive).
Setting FallbackMode to KDR mode (4).]]

local ModeClamp = Shine.IsNS2Combat and 4 or 5

function Plugin:Initialise()
	BalanceMinTime = Shared.GetTime() + self.Config.BalanceDelayInSeconds

	--self.Config.BalanceMode = Clamp( Floor( self.Config.BalanceMode or 1 ), 1, ModeClamp )
	--self.Config.FallbackMode = Clamp( Floor( self.Config.FallbackMode or 1 ), 1, ModeClamp )

	self.Config.BalanceMode = Plugin.MODE_HIVE
	self.Config.FallbackMode = Plugin.MODE_KDR

	self.Config.MaxStoredRounds = Max( Floor( self.Config.MaxStoredRounds ), 1 )
	self.Config.ReconnectLogTime = Max( self.Config.ReconnectLogTime, 0 )

	local BalanceMode = self.Config.BalanceMode
	local FallbackMode = self.Config.FallbackMode

	if FallbackMode == self.MODE_ELO or FallbackMode == self.MODE_HIVE then
		self.Config.FallbackMode = self.MODE_KDR

		Notify( ModeError )

		self:SaveConfig()
	end

	self.NextVote = 0

	self.Vote = Shine:CreateVote( function() return self:GetVotesNeeded() end,
		function() self:ApplyBalanceSettings() end,
		function( Vote )
		if Vote.LastVoted and SharedTime() - Vote.LastVoted > self.Config.VoteTimeout then
			Vote:Reset()
		end
	end )

	self.ForceBalanceEnd = 0 --Time based.
	self.BalanceOnNextRound = false --Round based.

	self.ForceBalance = self.Config.AlwaysEnabled

	self.ScoreData = self:LoadScoreData()

	--We need this value to keep track of where we store the next round data.
	if not self.ScoreData.Round then
		self.ScoreData.Round = 1
	end

	if not self.ScoreData.Rounds then
		self.ScoreData.Rounds = {}
	end

	self.Enabled = true

	self:CreateCommands()

	return true
end

function Plugin:AddELOFail()
	if not self.ELOFailed then
		self.ELOFailed = true

		self.ELOFailCount = 1

		return
	end

	self.ELOFailCount = self.ELOFailCount + 1

	if self.ELOFailCount >= 2 then
		self.Config.BalanceMode = self.Config.FallbackMode

		Shine:Print( "[Elo Vote] Connection to NS2Stats failed 2 times in a row, reverting to %s sorting for the rest of the map",
			true, ModeStrings.ModeLower[ self.Config.FallbackMode ] )
	end
end

function Plugin:OnNS2StatsFail( Fail, Message, Format, ... )
	local FallbackMode = ModeStrings.ModeLower[ self.Config.FallbackMode ]

	Shine:Print( Message, Format, ... )

	--self:Notify( nil, "NS2Stats failed to respond, falling back to %s sorting", true, FallbackMode )

	self:ShuffleTeams( false, self.Config.FallbackMode )

	if not Fail then return end

	self:AddELOFail()
end

function Plugin:RequestNS2Stats( Gamerules, Callback )
	local Players, NumPlayers = GetAllPlayers()
	local Concat = {}

	local Count = 0

	for i = 1, NumPlayers do
		local Player = Players[ i ]
		local Client = GetOwner( Player )

		if Client and not Client:GetIsVirtual() then
			Count = Count + 1

			Concat[ Count ] = Client:GetUserId()
		end
	end

	local URL
	local _, NS2Stats = Shine:IsExtensionEnabled( "ns2stats" )

	URL = NS2Stats.Config.WebsiteUrl.."/api/players"

	local Params = {
		players = TableConcat( Concat, "," )
	}

	Shine.TimedHTTPRequest( URL, "POST", Params, function( Response, Status )
		if not Response then
			self:OnNS2StatsFail( true,
				"[Elo Vote] Could not connect to NS2Stats. Falling back to %s sorting",
				true, FallbackMode )

			return
		end

		local Data = Decode( Response )

		if not IsType( Data, "table" ) then
			self:OnNS2StatsFail( true,
				"[Elo Vote] NS2Stats returned corrupt or empty data. Falling back to %s sorting",
				true, FallbackMode )

			return
		end

		self.StatsData = self.StatsData or {}
		local StatsData = self.StatsData

		for i = 1, #Data do
			local Player = Data[ i ]

			if Player.id then
				local ID = tostring( Player.id )

				local Stored = StatsData[ ID ]

				if Stored then
					if Player.alien_ELO then
						Stored.AElo = Player.alien_ELO
					end
					if Player.marine_ELO then
						Stored.MElo = Player.marine_ELO
					end
				else
					StatsData[ ID ] = {
						AElo = Player.alien_ELO or 1500,
						MElo = Player.marine_ELO or 1500
					}
				end
			end
		end

		self.ELOFailed = nil

		Callback()
	end, function()
		Shine:Print( "[Elo Vote] Connection to NS2Stats timed out" )

		self:AddELOFail()

		Callback()
	end )
end

local function OnJoinError( Error )
	local Trace = Traceback()

	Shine:DebugLog( "Error: %s.\nEvenlySpreadTeams failed. %s", true, Error, Trace )
	Shine:AddErrorReport( StringFormat("A player failed to join a team in EvenlySpreadTeams: %s", Error ), Trace )
end

function Plugin:EvenlySpreadTeams( Gamerules, TeamMembers )
	local Marine = TeamMembers[ 1 ]
	local Alien = TeamMembers[ 2 ]

	local NumMarine = #TeamMembers[ 1 ]
	local NumAlien = #TeamMembers[ 2 ]

	local MarineGreater = NumMarine > NumAlien
	local Diff = Abs( NumMarine - NumAlien )

	if Diff > 1 then
		local NumToMove = Floor( Diff * 0.5 ) - 1

		if MarineGreater then
			for i = NumMarine, NumMarine - NumToMove, -1 do
				local Player = Marine[ i ]

				Marine[ i ] = nil

				Alien[ #Alien + 1 ] = Player
			end
		else
			for i = NumAlien, NumAlien - NumToMove, -1 do
				local Player = Alien[ i ]

				Alien[ i ] = nil

				Marine[ #Marine + 1 ] = Player
			end
		end
	end

	local Reported

	if Abs( #Marine - #Alien ) > 1 then
		local VoteRandom = Shine.Plugins.voterandom

		if VoteRandom then
			local BalanceMode = VoteRandom.Config.BalanceMode

			local Marines = TableToString( Marine )
			local Aliens = TableToString( Alien )

			Shine:AddErrorReport( "Team sorting resulted in imbalanced teams before applying",
				"Balance Mode: %s. Marine Size: %s. Alien Size: %s. Diff: %s. New Teams:\nMarines:\n%s\nAliens:\n%s",
				true, BalanceMode, NumMarine, NumAlien, Diff, Marines, Aliens )
		end

		Reported = true
	end

	local MarineTeam = Gamerules.team1
	local AlienTeam = Gamerules.team2

	local MaxPlayersPerTeam = 12

	for i, Player in pairs( Marine ) do
		if i <= MaxPlayersPerTeam then
			local Success, JoinSuccess, NewPlayer = xpcall( Gamerules.JoinTeam, OnJoinError, Gamerules, Player, 1, nil, true )
		else
			xpcall( Gamerules.JoinTeam, OnJoinError, Gamerules, Player, 3, nil, true )
		end

		if Success then
			Marine[ i ] = NewPlayer
		else
			Marine[ i ] = nil
		end
	end

	for i, Player in pairs( Alien ) do
		if i <= MaxPlayersPerTeam then
			local Success, JoinSuccess, NewPlayer = xpcall( Gamerules.JoinTeam, OnJoinError, Gamerules, Player, 2, nil, true )
		else
			xpcall( Gamerules.JoinTeam, OnJoinError, Gamerules, Player, 3, nil, true )
		end

		if Success then
			Alien[ i ] = NewPlayer
		else
			Alien[ i ] = nil
		end
	end

	local NewMarineCount = MarineTeam:GetNumPlayers()
	local NewAlienCount = AlienTeam:GetNumPlayers()
	local NewDiff = Abs( NewMarineCount - NewAlienCount )

	if NewDiff > 1 and not Reported then
		local VoteRandom = Shine.Plugins.voterandom

		if VoteRandom then
			local BalanceMode = VoteRandom.Config.BalanceMode

			local Marines = TableToString( Marine )
			local Aliens = TableToString( Alien )

			Shine:AddErrorReport( "Team sorting resulted in imbalanced teams after applying",
				"Balance Mode: %s. Table Marine Size: %s. Table Alien Size: %s. Table Diff: %s.\nActual Marine Size: %s. Actual Alien Size: %s. Actual Diff: %s.\nNew Teams:\nMarines:\n%s\nAliens:\n%s",
				true, BalanceMode, NumMarine, NumAlien, Diff, NewMarineCount,
				NewAlienCount, NewDiff, Marines, Aliens )
		end
	end
end

local function RandomiseSimilarSkill( Data, Count, Difference )
	local LastSkill = Data[ 1 ] and Data[ 1 ].Skill or 0

	--Swap those with a similar skill value randomly to make things different.
	for i = 2, Count do
		local Obj = Data[ i ]

		local CurSkill = Obj.Skill

		if LastSkill - CurSkill < Difference then
			if Random() >= 0.5 then
				local LastObj = Data[ i - 1 ]

				Data[ i ] = LastObj
				Data[ i - 1 ] = Obj

				LastSkill = LastObj.Skill
			else
				LastSkill = CurSkill
			end
		else
			LastSkill = CurSkill
		end
	end
end

local function GetAverageSkillFunc( Players, Func )
	local PlayerCount = #Players

	if PlayerCount == 0 then return 0, 0, 0 end

	local PlayerSkillSum = 0
	local Count = 0

	for i = 1, PlayerCount do
		local Ply = Players[ i ]

		if Ply then
			local Skill = Func( Ply )
			if Skill then
				Count = Count + 1
				PlayerSkillSum = PlayerSkillSum + Skill
			end
		end
	end

	if Count == 0 then
		return 0, 0, 0
	end

	return PlayerSkillSum / Count, PlayerSkillSum, Count
end

--Gets the average skill ranking of a table of players.
local function GetAverageSkill( Players )
	return GetAverageSkillFunc( Players, function( Ply )
		--[[local Client = GetOwner( Ply )
		if Client and Client:GetIsVirtual() then
			Client.Skill = Client.Skill or Random( 1000, 4000 )
			return Client.Skill
		end]]

		if Ply.GetPlayerSkill then
			return Ply:GetPlayerSkill()
		end

		return nil
	end )
end

function Plugin:SortPlayersByRank( TeamMembers, SortTable, Count, NumTargets, RankFunc, NoSecondPass )
	local Add = Random() >= 0.5 and 1 or 0

	local TeamSkills = {
		{ GetAverageSkillFunc( TeamMembers[ 1 ], RankFunc ) },
		{ GetAverageSkillFunc( TeamMembers[ 2 ], RankFunc ) }
	}

	local Team = 1 + Add
	local MaxForTeam = Ceil( ( NumTargets + #TeamMembers[ 1 ] + #TeamMembers[ 2 ] ) * 0.5 )
	local Sorted = {}

	--First pass, place unassigned players onto the team with the lesser average skill rating.
	for i = 1, Count do
		if SortTable[ i ] then
			local Player = SortTable[ i ].Player
			local Skill = SortTable[ i ].Skill
			local TeamToJoin = Team
			local OtherTeam = ( Team % 2 ) + 1

			if #TeamMembers[ Team ] < MaxForTeam then
				if #TeamMembers[ OtherTeam ] < MaxForTeam then
					local OtherAverage = TeamSkills[ OtherTeam ][ 1 ]
					local OtherTeamSkill = TeamSkills[ OtherTeam ][ 2 ]
					local OtherTeamCount = TeamSkills[ OtherTeam ][ 3 ]
					local OurAverage = TeamSkills[ Team ][ 1 ]
					local OurTeamSkill = TeamSkills[ Team ][ 2 ]
					local OurTeamCount = TeamSkills[ Team ][ 3 ]

					local NewAverage = ( OurTeamSkill + Skill ) / ( OurTeamCount + 1 )
					local TheirNewAverage = ( OtherTeamSkill + Skill ) / ( OtherTeamCount + 1 )

					if OurAverage > OtherAverage then
						if TheirNewAverage > NewAverage then
							TeamToJoin = OtherTeam
							Team = OtherTeam
						end
					end
				end
			else
				TeamToJoin = OtherTeam
			end

			local TeamTable = TeamMembers[ TeamToJoin ]

			TeamTable[ #TeamTable + 1 ] = Player
			Sorted[ Player ] = true

			local SkillSum = TeamSkills[ TeamToJoin ][ 2 ] + Skill
			local PlayerCount = TeamSkills[ TeamToJoin ][ 3 ] + 1
			local AverageSkill = SkillSum / PlayerCount

			TeamSkills[ TeamToJoin ][ 1 ] = AverageSkill
			TeamSkills[ TeamToJoin ][ 2 ] = SkillSum
			TeamSkills[ TeamToJoin ][ 3 ] = PlayerCount
		end
	end

	--Second pass, optimise the teams by swapping players that will reduce the average skill difference.
	if not NoSecondPass then
		local Stop
		local Team1 = TeamMembers[ 1 ]
		local Team2 = TeamMembers[ 2 ]
		local NumTeam1 = #Team1
		local NumTeam2 = #Team2

		local LargerTeam
		if NumTeam1 > NumTeam2 then
			LargerTeam = 1
		elseif NumTeam2 > NumTeam1 then
			LargetTeam = 2
		end
		local LesserTeam = LargerTeam and ( ( LargerTeam % 2 ) + 1 ) or 2

		--Just in case, though it ought to not infinitely loop even without this.
		local Iterations = 0

		local function CheckSwap( Ply, Skill, Target, TargetSkill, i, j, SwapData )
			local Team1Total = TeamSkills[ LargerTeam or 1 ][ 2 ]
			local Team1Count = TeamSkills[ LargerTeam or 1 ][ 3 ]

			local Team2Total = TeamSkills[ LesserTeam ][ 2 ]
			local Team2Count = TeamSkills[ LesserTeam ][ 3 ]

			local Team1Average = Team1Total / Team1Count
			local Team2Average = Team2Total / Team2Count
			local Diff = Abs( Team2Average - Team1Average )

			local NewTeam1Total = Team1Total - Skill + TargetSkill
			local NewTeam2Total = Team2Total - TargetSkill + Skill

			local NewTeam1Average = NewTeam1Total / Team1Count
			local NewTeam2Average = NewTeam2Total / Team2Count
			local NewDiff = Abs( NewTeam2Average - NewTeam1Average )

			if NewDiff < Diff and NewDiff < SwapData.BestDiff then
				SwapData.BestDiff = NewDiff
				SwapData.BestPlayers[ LargerTeam or 1 ] = Target
				SwapData.BestPlayers[ LesserTeam ] = Ply
				SwapData.Indices[ LargerTeam or 1 ] = i
				SwapData.Indices[ LesserTeam ] = j
				SwapData.Totals[ LargerTeam or 1 ] = NewTeam1Total
				SwapData.Totals[ LesserTeam ] = NewTeam2Total
			end
		end

		while Iterations < 30 do
			local Changed

			local SwapData = {
				BestDiff = math.huge,
				BestPlayers = {},
				Indices = {},
				Totals = {}
			}

			for i = 1, #TeamMembers[ LargerTeam or 1 ] do
				local Ply = TeamMembers[ LargerTeam or 1 ][ i ]
				if Ply then
					local Skill = RankFunc( Ply )
					local ShouldIgnorePly = self.Config.IgnoreCommanders and Ply:isa( "Commander" )

					if Skill and not ShouldIgnorePly then
						for j = 1, #TeamMembers[ LesserTeam ] do
							local Target = TeamMembers[ LesserTeam ][ j ]
							local TargetSkill = RankFunc( Target )
							local ShouldIgnoreTarget = self.Config.IgnoreCommanders
								and Target:isa( "Commander" )

							if TargetSkill and not ShouldIgnoreTarget then
								CheckSwap( Ply, Skill, Target, TargetSkill, i, j, SwapData )
							end
						end

						if LargerTeam then
							local Team2Count = TeamSkills[ LesserTeam ][ 3 ] + 1

							CheckSwap( Ply, Skill, nil, 0, i, Team2Count, SwapData )
						end
					end
				end
			end

			--We've found a match that lowers the difference in averages the most.
			if SwapData.BestDiff < math.huge then
				for i = 1, 2 do
					local SwapPly = SwapData.BestPlayers[ i ]
					--If we're moving a player from one side to the other, drop them properly.
					if not SwapPly then
						TableRemove( TeamMembers[ i ], SwapData.Indices[ i ] )
						--Update player counts for the teams.
						TeamSkills[ LargerTeam ][ 3 ] = TeamSkills[ LargerTeam ][ 3 ] - 1
						TeamSkills[ LesserTeam ][ 3 ] = TeamSkills[ LesserTeam ][ 3 ] + 1
						--Cycle the larger/lesser teams.
						LargerTeam = ( LargerTeam % 2 ) + 1
						LesserTeam = ( LesserTeam % 2 ) + 1
					else
						TeamMembers[ i ][ SwapData.Indices[ i ] ] = SwapPly
					end
					TeamSkills[ i ][ 2 ] = SwapData.Totals[ i ]
				end
				Changed = true
			end

			if not Changed then break end

			Iterations = Iterations + 1
		end
	end

	return Sorted
end

Plugin.ShufflingModes = {
	--Random only.
	function( self, Gamerules, Targets, TeamMembers, Silent )
		local NumPlayers = #Targets

		local TeamSequence = math.GenerateSequence( NumPlayers, { 1, 2 } )

		for i = 1, NumPlayers do
			local Player = Targets[ i ]
			if Player then
				local TeamTable = TeamMembers[ TeamSequence[ i ] ]

				TeamTable[ #TeamTable + 1 ] = Player
			end
		end

		Plugin:EvenlySpreadTeams( Gamerules, TeamMembers )

		if not Silent then
			Shine:LogString( "[Shuffle] Teams were sorted randomly" )
		end
	end,
	--Score based if available, random if not.
	function( self, Gamerules, Targets, TeamMembers, Silent, KDRSort )
		local ScoreData = self.ScoreData

		local ScoreTable = {}
		local RandomTable = {}

		for i = 1, #Targets do
			local Player = Targets[ i ]

			if Player then
				local Client = GetOwner( Player )

				if Client and Client.GetUserId then
					local ID = Client:GetUserId()

					local Data = self:GetAverageScoreData( ID )

					if Data then
						ScoreTable[ #ScoreTable + 1 ] = { Player = Player, Skill = Data }
					else
						RandomTable[ #RandomTable + 1 ] = Player
					end
				end
			end
		end

		local ScoreSortCount = #ScoreTable

		if ScoreSortCount > 0 then
			TableSort( ScoreTable, function( A, B ) return A.Skill > B.Skill end )
			local IgnoreSecondPass

			if not KDRSort and Silent then
				IgnoreSecondPass = true
			end

			--Make sure we ignore the second pass if we're a fallback for skill/Elo sorting.
			self:SortPlayersByRank( TeamMembers, ScoreTable, ScoreSortCount, #Targets, function( Player )
				local Client = GetOwner( Player )

				if Client and Client.GetUserId then
					local ID = Client:GetUserId()
					return self:GetAverageScoreData( ID )
				end

				return nil
			end, IgnoreSecondPass )
		end

		local RandomTableCount = #RandomTable

		if RandomTableCount > 0 then
			local TeamSequence = math.GenerateSequence( RandomTableCount, { 1, 2 } )

			for i = 1, RandomTableCount do
				local TeamTable = TeamMembers[ TeamSequence[ i ] ]

				TeamTable[ #TeamTable + 1 ] = RandomTable[ i ]
			end
		end

		Plugin:EvenlySpreadTeams( Gamerules, TeamMembers )

		if not Silent then
			Shine:LogString( "[Shuffle] Teams were sorted based on score" )
		end
	end,

	function( self, Gamerules, Targets, TeamMembers ) --NS2Stats Elo based.
		local NS2StatsEnabled, NS2Stats = Shine:IsExtensionEnabled( "ns2stats" )

		if not NS2StatsEnabled then
			local FallbackMode = ModeStrings.ModeLower[ self.Config.FallbackMode ]

			--self:Notify( nil, "Balancing based on Elo failed, falling back to %s sorting", true, FallbackMode )

			self.ShufflingModes[ self.Config.FallbackMode ]( self, Gamerules, Targets, TeamMembers )

			self.LastShuffleMode = self.Config.FallbackMode

			Shine:Print( "[Elo Vote] NS2Stats is not installed correctly, defaulting to %s sorting",
				true, FallbackMode )

			self:AddELOFail()

			return
		end

		self:RequestNS2Stats( Gamerules, function()
			local StatsData = self.StatsData

			if not StatsData or not next( StatsData ) then
				self:OnNS2StatsFail( false,
					"[Elo Vote] NS2Stats does not have any web data for players. Using %s sorting instead",
					true, FallbackMode )

				return
			end

			local Targets, TeamMembers = self:GetTargetsForSorting()

			local EloSort = {}
			local Count = 0

			for i = 1, #Targets do
				local Player = Targets[ i ]
				local Client = Player and GetOwner( Player )

				if Client and Client.GetUserId then
					local ID = tostring( Client:GetUserId() )
					local Data = StatsData[ ID ]

					if Data then
						Count = Count + 1
						EloSort[ Count ] = { Player = Player, Skill = ( Data.AElo + Data.MElo ) * 0.5 }
					end
				end
			end

			TableSort( EloSort, function( A, B ) return A.Skill > B.Skill end )

			RandomiseSimilarSkill( EloSort, Count, 20 )

			local Sorted = self:SortPlayersByRank( TeamMembers, EloSort, Count, #Targets, function( Player )
				local Client = GetOwner( Player )

				if Client and Client.GetUserId then
					local ID = tostring( Client:GetUserId() )
					local Data = StatsData[ ID ]

					if Data then
						return ( Data.AElo + Data.MElo ) * 0.5
					end
				end

				return nil
			end )

			--Sort the remaining players with the fallback method.
			local FallbackTargets = {}

			for i = 1, #Targets do
				local Player = Targets[ i ]

				if Player and not Sorted[ Player ] then
					FallbackTargets[ #FallbackTargets + 1 ] = Player
					Sorted[ Player ] = true
				end
			end

			if #FallbackTargets > 0 then
				self.ShufflingModes[ self.Config.FallbackMode ]( self, Gamerules,
					FallbackTargets, TeamMembers, true )

				Shine:LogString( "[Elo Vote] Teams were sorted based on NS2Stats Elo ranking" )

				--We return as the fallback has already evenly spread the teams.
				return
			end

			Plugin:EvenlySpreadTeams( Gamerules, TeamMembers )

			Shine:LogString( "[Elo Vote] Teams were sorted based on NS2Stats Elo ranking" )
		end )
	end,

	--KDR based works identically to score, the score data is what is different.
	function( self, Gamerules, Targets, TeamMembers, Silent )
		if not Silent then
			Shine:LogString( "[Shuffle] Teams were sorted based on KDR" )
		end

		return self.ShufflingModes[ self.MODE_SCORE ]( self, Gamerules, Targets,
			TeamMembers, true, not Silent )
	end,

	--Hive data based. Relies on UWE's ranking data to be correct for it to work.
	function( self, Gamerules, Targets, TeamMembers )
		local SortTable = {}
		local Count = 0
		local Sorted = {}

		local TargetCount = #Targets

		for i = 1, TargetCount do
			local Ply = Targets[ i ]

			if Ply and Ply.GetPlayerSkill then
				local SkillData = Ply:GetPlayerSkill()

				if SkillData and SkillData > 0 then
					Count = Count + 1
					SortTable[ Count ] = { Player = Ply, Skill = SkillData }
				end
			end
		end

		TableSort( SortTable, function( A, B )
			return A.Skill > B.Skill
		end )

		RandomiseSimilarSkill( SortTable, Count, 10 )

		local Sorted = self:SortPlayersByRank( TeamMembers, SortTable, Count, TargetCount, function( Ply )
			--[[local Client = GetOwner( Ply )
			if Client and Client:GetIsVirtual() then
				Client.Skill = Client.Skill or Random( 1000, 4000 )
				return Client.Skill
			end]]

			if Ply.GetPlayerSkill then
				return Ply:GetPlayerSkill()
			end

			return nil
		end )

		--If some players have rank 0 or no rank data, sort them with the fallback instead.
		local FallbackTargets = {}

		for i = 1, TargetCount do
			local Player = Targets[ i ]

			if Player and not Sorted[ Player ] then
				FallbackTargets[ #FallbackTargets + 1 ] = Player
				Sorted[ Player ] = true
			end
		end

		if #FallbackTargets > 0 then
			self.ShufflingModes[ self.Config.FallbackMode ]( self, Gamerules, FallbackTargets, TeamMembers, true )

			Shine:LogString( "[Skill Vote] Teams were sorted based on Hive skill ranking" )

			local Marines = GetEntitiesForTeam( "Player", 1 )
			local Aliens = GetEntitiesForTeam( "Player", 2 )

			local MarineSkill = GetAverageSkill( Marines )
			local AlienSkill = GetAverageSkill( Aliens )

			--self:Notify( nil, "Average skill rankings - Marines: %.0f. Aliens: %.0f.", true, MarineSkill, AlienSkill )

			return
		end

		Plugin:EvenlySpreadTeams( Gamerules, TeamMembers )

		Shine:LogString( "[Skill Vote] Teams were sorted based on Hive skill ranking" )

		local Marines = GetEntitiesForTeam( "Player", 1 )
		local Aliens = GetEntitiesForTeam( "Player", 2 )

		local MarineSkill = GetAverageSkill( Marines )
		local AlienSkill = GetAverageSkill( Aliens )

		--self:Notify( nil, "Average skill rankings - Marines: %.0f. Aliens: %.0f.", true, MarineSkill, AlienSkill )
	end
}

--[[
	Gets all valid targets for sorting.
]]
function Plugin:GetTargetsForSorting( ResetScores )
	local Players, Count = GetAllPlayers()

	local Gamerules = GetGamerules()

	if not Gamerules then return end

	local Targets = {}
	local TeamMembers = {
		{},
		{}
	}

	local AFKEnabled, AFKKick = Shine:IsExtensionEnabled( "afkkick" )

	local Time = SharedTime()

	local function SortPlayer( Player, Client, Commander, Pass )
		local Team = Player:GetTeamNumber()

		if Team == 3 and self.Config.IgnoreSpectators then
			return
		end

		local IsImmune = Shine:HasAccess( Client, "sh_balanceimmune" ) or Commander

		--Pass 1, put all immune players into team slots.
		--This ensures they're picked last if there's a team imbalance at the end of sorting.
		--It does not stop them from being swapped if it helps overall balance though.
		if Pass == 1 then
			if IsImmune then
				local TeamTable = TeamMembers[ Team ]

				if TeamTable then
					TeamTable[ #TeamTable + 1 ] = Player
				end
			end

			return
		end

		--Pass 2, put all non-immune players into team slots/target list.
		if IsImmune then return end

		local BalanceMode = self.Config.BalanceMode
		local BiasTeams = BalanceMode == self.MODE_ELO or BalanceMode == self.MODE_HIVE
		--If they're on a playing team, bias towards letting them keep it.
		if ( Team == 1 or Team == 2 ) and BiasTeams then
			local TeamTable = TeamMembers[ Team ]

			TeamTable[ #TeamTable + 1 ] = Player
		else
			Targets[ #Targets + 1 ] = Player
		end
	end

	for j = 1, 2 do
		for i = 1, Count do
			local Player = Players[ i ]

			if Player then
				if Player.ResetScores and ResetScores then
					Player:ResetScores()
				end

				local Commander = Player:isa( "Commander" ) and self.Config.IgnoreCommanders

				local Client = Player:GetClient()

				local Team1Players = Gamerules:GetTeam( kTeam1Index ):GetNumPlayers()
				local Team2Players = Gamerules:GetTeam( kTeam2Index ):GetNumPlayers()
				local PlayingPlayers = Team1Players + Team2Players

				if Client then
					SortPlayer( Player, Client, Commander, j )
				end
			end
		end
	end

	return Targets, TeamMembers
end

--[[
	Shuffles everyone on the server into random teams.
]]
function Plugin:ShuffleTeams( ResetScores, ForceMode )
	local Gamerules = GetGamerules()

	if not Gamerules then return end

	local Targets, TeamMembers = self:GetTargetsForSorting( ResetScores )

	self.LastShuffleMode = ForceMode or self.Config.BalanceMode
	self.ReconnectLogTimeout = SharedTime() + self.Config.ReconnectLogTime
	self.ReconnectingClients = {}

	local ModeFunc = self.ShufflingModes[ ForceMode or self.Config.BalanceMode ]

	return ModeFunc( self, Gamerules, Targets, TeamMembers )
end

--[[
	Stores a player's score.
]]
function Plugin:StoreScoreData( Player )
	local Client = GetOwner( Player )

	if not Client then return end

	if Client.GetIsVirtual and Client:GetIsVirtual() then return end
	if not Client.GetUserId then return end

	local Round = self.Round

	assert( Round, "Attempted to store score data before round data was created!" )

	local ID = tostring( Client:GetUserId() )

	local Mode = self.Config.BalanceMode

	if Mode == self.MODE_ELO or Mode == self.MODE_HIVE then
		Mode = self.Config.FallbackMode
	end

	local DataTable = self.ScoreData.Rounds[ Round ]

	if Mode == self.MODE_SCORE then
		--Don't want to store data about 0 score players, we'll just randomise them.
		if Player.score and Player.score > 0 then
			DataTable[ ID ] = Player.score
		end
	elseif Mode == self.MODE_KDR then
		local Kills = Player.GetKills and Player:GetKills() or 0
		local Assists = Player.GetAssistKills and Player:GetAssistKills() or 0
		local Deaths = Player.GetDeaths and Player:GetDeaths() or 0

		--Each assist counts for 0.5.
		Kills = Kills + Assists * 0.5

		--0 KDR is useless, let's just randomise them.
		if Kills == 0 then return end
		--Don't want a NaN ratio!
		if Deaths == 0 then Deaths = 1 end

		DataTable[ ID ] = Kills / Deaths
	end
end

--[[
	Gets the average of all stored round scores for the given Steam ID.
]]
function Plugin:GetAverageScoreData( ID )
	ID = tostring( ID )

	local ScoreData = self.ScoreData
	local RoundData = ScoreData.Rounds
	local StoredRounds = #RoundData

	local Score = 0
	local StoredForPlayer = 0

	for i = 1, StoredRounds do
		local CurScore = RoundData[ i ][ ID ]

		if CurScore then
			Score = Score + CurScore
			StoredForPlayer = StoredForPlayer + 1
		end
	end

	if StoredForPlayer == 0 then return 0 end

	return Score / StoredForPlayer
end

--[[
	Saves the score data for previous rounds.
]]
function Plugin:SaveScoreData()
	local Success, Err = Shine.SaveJSONFile( self.ScoreData,
		"config://shine/temp/balance_scores.json" )

	if not Success then
		Notify( "Error writing balance scoredata file: "..Err )

		return
	end
end

--[[
	Loads the stored data from the file, will load on plugin load only.
]]
function Plugin:LoadScoreData()
	local Data = Shine.LoadJSONFile( "config://shine/temp/balance_scores.json" )

	return Data or { Round = 1, Rounds = {} }
end

--[[
	Moves a single player onto a random team.
]]
function Plugin:JoinRandomTeam( Player )
	local Gamerules = GetGamerules()
	if not Gamerules then return end

	local Team1 = Gamerules:GetTeam( kTeam1Index ):GetNumPlayers()
	local Team2 = Gamerules:GetTeam( kTeam2Index ):GetNumPlayers()

	if Team1 < Team2 then
		Gamerules:JoinTeam( Player, 1, nil, true )
	elseif Team2 < Team1 then
		Gamerules:JoinTeam( Player, 2, nil, true )
	else
		if self.LastShuffleMode == self.MODE_HIVE then
			local Team1Players = Gamerules.team1:GetPlayers()
			local Team2Players = Gamerules.team2:GetPlayers()

			local Team1Average, Team1Skill, Team1Count = GetAverageSkill( Team1Players )
			local Team2Average, Team2Skill, Team2Count = GetAverageSkill( Team2Players )

			--If team skill is identical, then we should just pick a random team.
			if Team1Average ~= Team2Average then
				local BetterTeam = Team1Average > Team2Average and 1 or 2

				local PlayerSkill = Player.GetPlayerSkill and Player:GetPlayerSkill() or 1000
				local TeamToJoin = BetterTeam == 1 and 2 or 1

				--If they have a skill of 0, there will be no real effect on the average.
				--So we just hope for the best and put them on the worse team.
				if PlayerSkill > 0 then
					local NewTeam1Average = ( Team1Skill + PlayerSkill ) / ( Team1Count + 1 )
					local NewTeam2Average = ( Team2Skill + PlayerSkill ) / ( Team2Count + 1 )

					--If we're going to make the lower team even worse, then put them on the "better" team.
					if BetterTeam == 1 and NewTeam2Average < Team2Average then
						TeamToJoin = 1
					elseif BetterTeam == 2 and NewTeam1Average < Team1Average then
						TeamToJoin = 2
					end
				end

				Gamerules:JoinTeam( Player, TeamToJoin, nil, true )

				return
			end
		end

		if Random() < 0.5 then
			Gamerules:JoinTeam( Player, 1, nil, true )
		else
			Gamerules:JoinTeam( Player, 2, nil, true )
		end
	end
end

function Plugin:SetGameState( Gamerules, NewState, OldState )
	if NewState ~= kGameState.Countdown then return end

	--Block the vote after the set time.
	if self.Config.BlockAfterTime > 0 then
		self.VoteBlockTime = SharedTime() + self.Config.BlockAfterTime * 60
	end

	if not self.Config.AlwaysEnabled then return end
	if GetNumPlayers() < self.Config.MinPlayers then
		return
	end

	if self.DoneStartShuffle then return end

	self.DoneStartShuffle = true

	local OldValue = self.Config.IgnoreCommanders

	--Force ignoring commanders.
	self.Config.IgnoreCommanders = true

	self:Notify( nil, "Balancing teams %s due to server settings", true, ModeStrings.Action[ self.Config.BalanceMode ] )

	self:ShuffleTeams()

	self.Config.IgnoreCommanders = OldValue
end

function Plugin:EndGame( Gamerules, WinningTeam )
	BalanceMinTime = Shared.GetTime() + self.Config.BalanceDelayInSeconds

	self.DoneStartShuffle = false
	self.VoteBlockTime = nil

	local Players, Count = GetAllPlayers()
	local BalanceMode = self.Config.BalanceMode
	local IsScoreBased = BalanceMode == self.MODE_SCORE or BalanceMode == self.MODE_KDR

	if BalanceMode == self.MODE_ELO or BalanceMode == self.MODE_HIVE then
		local Fallback = self.Config.FallbackMode
		IsScoreBased = Fallback == self.MODE_SCORE or Fallback == self.MODE_KDR
	end

	if IsScoreBased then
		local ScoreData = self.ScoreData
		local Round = ScoreData.Round
		local RoundData = ScoreData.Rounds

		RoundData[ Round ] = RoundData[ Round ] or {}

		TableEmpty( RoundData[ Round ] )

		self.Round = Round

		ScoreData.Round = ( Round % self.Config.MaxStoredRounds ) + 1
	end

	--Reset the randomised state of all players and store score data.
	for i = 1, Count do
		local Player = Players[ i ]

		if Player then
			Player.ShineBalanced = nil

			if IsScoreBased then
				self:StoreScoreData( Player )
			end
		end
	end

	self:SaveScoreData()

	--If we're always enabled, we'll shuffle on round start.
	if self.Config.AlwaysEnabled then
		return
	end

	if self.BalanceOnNextRound then
		self.BalanceOnNextRound = false

		self:SimpleTimer( 15, function()
			local Enabled, MapVote = Shine:IsExtensionEnabled( "mapvote" )

			if Enabled and MapVote:IsEndVote() then
				self.ForceBalance = true

				return
			end

			self:Notify( nil, "Balancing teams %s due to previous vote", true, ModeStrings.Action[ self.Config.BalanceMode ] )

			self:ShuffleTeams()

			self.ForceBalance = true
		end )

		return
	end

	self.ForceBalance = false
	if not self:TimerExists( self.RandomEndTimer ) then return end

	self:SimpleTimer( 15, function()
		local Enabled, MapVote = Shine:IsExtensionEnabled( "mapvote" )

		if not ( Enabled and MapVote:IsEndVote() ) then
			self:Notify( nil, "Balancing teams %s due to previous vote", true, ModeStrings.Action[ self.Config.BalanceMode ] )

			self:ShuffleTeams()
		end

		if self:TimerExists( self.RandomEndTimer ) then
			self.ForceBalance = true
		end
	end )
end

function Plugin:ClientDisconnect( Client )
	self.Vote:ClientDisconnect( Client )

	if not self.ReconnectLogTimeout then return end
	if SharedTime() > self.ReconnectLogTimeout then return end

	self.ReconnectingClients[ Client:GetUserId() ] = true
end

function Plugin:ClientConnect( Client )
	if not self.ReconnectingClients or not self.ReconnectLogTimeout then return end

	if SharedTime() > self.ReconnectLogTimeout then
		self.ReconnectingClients = nil

		return
	end

	if not self.ReconnectingClients[ Client:GetUserId() ] then return end

	Shine:Print( "[Shuffle] Client %s reconnected after a shuffle vote", true,
		Shine.GetClientInfo( Client ) )
end

function Plugin:GetVotesNeeded()
	local Gamerules = GetGamerules()

	local PlayerCount = GetNumPlayers()
	local Spectators = Gamerules:GetTeam( kSpectatorIndex ):GetNumPlayers()

	local ActivePlayerCount = PlayerCount - Spectators

	return Ceil( ActivePlayerCount * self.Config.PercentNeeded )
end

function Plugin:CanStartVote()
	local PlayerCount = GetNumPlayers()

	if PlayerCount < self.Config.MinPlayers then
		return false, "There are not enough players to start a vote"
	end

	if self.NextVote >= SharedTime() then
		local String = ModeStrings.ModeLower[ self.Config.BalanceMode ]

		String = String:sub( 1, 1 ) == "E" and "an "..String or "a "..String

		return false, StringFormat( "You cannot start %s teams vote at this time", String )
	end

	if self.BalanceOnNextRound then
		local String = ModeStrings.Mode[ self.Config.BalanceMode ]

		return false, StringFormat( "%s teams have already been voted for the next round", String )
	end

	return true
end

--[[
	Adds a player's vote to the counter.
]]
function Plugin:AddVote( Client )
	if self.Config.AlwaysEnabled then
		return false, StringFormat( "%s teams are forced to enabled by the server",
			ModeStrings.Mode[ self.Config.BalanceMode ] )
	end

	if self.VoteBlockTime and self.VoteBlockTime < SharedTime() then
		return false, "It is too far into the current round to start a vote"
	end

	if not Client then Client = "Console" end

	local Allow, Error = Shine.Hook.Call( "OnVoteStart", "random" )
	if Allow == false then
		return false, Error
	end

	local Success, Err = self:CanStartVote()
	if not Success then
		return false, Err
	end

	Success = self.Vote:AddVote( Client )
	if not Success then
		return false, StringFormat( "You have already voted for %s teams",
			ModeStrings.ModeLower[ self.Config.BalanceMode ] )
	end

	return true
end

--[[
	Timeout the vote.
]]
function Plugin:Think()
	self.Vote:Think()
end

--[[
	Applies the configured randomise settings.
	If set to random teams on next round, it queues a force of random teams for the next round.
	If set to a time duration, it enables random teams and queues the disabling of them.
]]
function Plugin:ApplyBalanceSettings()
	self.BalanceApplied = true
	self:SimpleTimer( 0, function()
		self.BalanceApplied = false
	end )

	--Set up teams for the next round.
	if self.Config.BalanceOnNextRound then
		local Gamerules = GetGamerules()

		--Game hasn't started, apply the settings now, as the next round is the one that's going to start...
		if not Gamerules:GetGameStarted() then
			self:Notify( nil, "Balancing teams %s for the next round", true, ModeStrings.Action[ self.Config.BalanceMode ] )
			self:Notify( nil, "Teams are balanced locked for %s seconds", true, self.Config.BalanceLockDurationInSeconds )

			self:ShuffleTeams()

			BlockTeamsUntilTime = Shared.GetTime() + self.Config.BalanceLockDurationInSeconds

			self.ForceBalance = true

			return
		end

		self:Notify( nil, "Teams will be forced to %s in the next round", true, ModeStrings.ModeLower[ self.Config.BalanceMode ] )

		self.BalanceOnNextRound = true

		return
	end

	--Set up teams now and make them last for the given time in the config.
	local Duration = self.Config.Duration * 60

	if Duration > 0 then
		self.ForceBalance = true
		self.NextVote = SharedTime() + Duration

		--self:Notify( nil, "%s teams have been enabled", true, ModeStrings.Mode[ self.Config.BalanceMode ], string.TimeToString( Duration ) )

		self:CreateTimer( self.RandomEndTimer, Duration, 1, function()
			--self:Notify( nil, "%s team enforcing disabled, time limit reached", true, ModeStrings.Mode[ self.LastShuffleMode or self.Config.BalanceMode ] )
			self.ForceBalance = false
		end )
	end

	if self.Config.InstantForce then
		local Gamerules = GetGamerules()

		local Started = Gamerules:GetGameStarted()

		if Started then
			--self:Notify( nil, "Balancing teams %s and restarting round", true, ModeStrings.Action[ self.Config.BalanceMode ] )

			self:ShuffleTeams( true )
		else
			self:Notify( nil, "Balancing teams %s", true, ModeStrings.Action[ self.Config.BalanceMode ] )

			self:ShuffleTeams()
		end

		if Started then
			Gamerules:ResetGame()
		end
	end
end

function Plugin:JoinTeam( Gamerules, Player, NewTeam, Force, ShineForce )
	if ShineForce then return end

	if not self.Config.BlockTeams then return end

	local CurrentTeam = Player:GetTeamNumber()

	if NewTeam == CurrentTeam then return end

	if CurrentTeam == 0 or CurrentTeam == 3 then return end

	local BlockTimeLeft = math.floor(BlockTeamsUntilTime - Shared.GetTime() + 0.5)

	if BlockTimeLeft > 0 then
		self:Notify( Player, "Teams are balanced locked for %s more seconds", true, BlockTimeLeft )
		return false
	end

end
