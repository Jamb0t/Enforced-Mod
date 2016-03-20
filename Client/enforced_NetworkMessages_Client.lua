
-- ?? This is never called
local oldOnCommandScores = OnCommandScores
function OnCommandScores(scoreTable)
    local status = kPlayerStatus[scoreTable.status]
--    Log("DEBUG OnCommandScores -- %s", ToString(kPlayerStatus))
    if scoreTable.status == kPlayerStatus.HeavyMachineGun then
        status = "HMG"
		Scoreboard_SetPlayerData(scoreTable.clientId, scoreTable.entityId, scoreTable.playerName, scoreTable.teamNumber, scoreTable.score,
                             scoreTable.kills, scoreTable.deaths, math.floor(scoreTable.resources), scoreTable.isCommander, scoreTable.isRookie,
                             status, scoreTable.isSpectator, scoreTable.assists, scoreTable.clientIndex)

        return
    end
	oldOnCommandScores(scoreTable)
end
