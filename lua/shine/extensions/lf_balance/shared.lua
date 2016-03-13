local Plugin = {}

Plugin.Version = "1.0"

Plugin.HasConfig = true
Plugin.ConfigName = "Balance.json"

Plugin.DefaultConfig = {
	MinPlayers = 5, --Minimum number of players on the server to enable voting.
	PercentNeeded = 0.3, --Percentage of the server population needing to vote for it to succeed.
	Duration = 0.8, --Time to force people onto teams for after a vote. Also time between successful votes.
	BlockAfterTime = 0.8, --Time after round start to block the vote. 0 to disable blocking.
	BalanceOnNextRound = false, --If false, then random teams are forced for a duration instead.
	InstantForce = true, --Forces a shuffle of everyone instantly when the vote succeeds (for time based).
	VoteTimeout = 45, --Time after the last vote before the vote resets.
	BalanceMode = Plugin.MODE_HIVE, --How should teams be balanced?
	FallbackMode = Plugin.MODE_KDR, --Which method should be used if Elo/Hive fails?
	BlockTeams = true, --Should team changing/joining be blocked after an instant force or in a round?
	IgnoreCommanders = true, --Should the plugin ignore commanders when switching?
	IgnoreSpectators = true, --Should the plugin ignore spectators when switching?
	AlwaysEnabled = false, --Should the plugin be always forcing each round?
	MaxStoredRounds = 3, --How many rounds of score data should we buffer?
	ReconnectLogTime = 0, --How long (in seconds) after a shuffle to log reconnecting players for?
	BalanceDelayInSeconds = 15,
	BalanceLockDurationInSeconds = 30
}
Plugin.CheckConfig = true
Plugin.CheckConfigTypes = true

Plugin.DefaultState = true

function Plugin:SetupDataTable()
    self:AddNetworkMessage( "EnableBalance", { }, "Client" )
end

Shine:RegisterExtension( "lf_balance", Plugin )
