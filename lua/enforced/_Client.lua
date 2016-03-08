kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

Script.Load("lua/Enforced/_Shared.lua")

Script.Load("lua/Enforced/GUIActionIcon.lua")
Script.Load("lua/Enforced/GUIMarineBuyMenu.lua")
Script.Load("lua/Enforced/GUIMinimap.lua")
Script.Load("lua/Enforced/GUIPickups.lua")

--
local kNewGrenades = {
    kTechId.ClusterGrenade,
    kTechId.GasGrenade,
    kTechId.NapalmGrenade,
    kTechId.PulseGrenade
}

ReplaceLocals(PlayerUI_GetHasItem, { kGrenades = kNewGrenades } )

--
local oldPlayerUI_GetCrosshairY = PlayerUI_GetCrosshairY
function PlayerUI_GetCrosshairY()
	local player = Client.GetLocalPlayer()
	if (player and not player:GetIsThirdPerson()) then  
		local weapon = player:GetActiveWeapon()
		if weapon ~= nil and weapon:GetMapName() == HeavyMachineGun.kMapName then
			return 0 * 64
		end
	end
	return oldPlayerUI_GetCrosshairY()
end

local oldOnCommandScores = OnCommandScores
function OnCommandScores(scoreTable)
    local status = kPlayerStatus[scoreTable.status]
    if scoreTable.status == kPlayerStatus.HeavyMachineGun then

        status = "HMG"
		
		Scoreboard_SetPlayerData(scoreTable.clientId, scoreTable.entityId, scoreTable.playerName, scoreTable.teamNumber, scoreTable.score,
                             scoreTable.kills, scoreTable.deaths, math.floor(scoreTable.resources), scoreTable.isCommander, scoreTable.isRookie,
                             status, scoreTable.isSpectator, scoreTable.assists, scoreTable.clientIndex)
							 
    else

		oldOnCommandScores(scoreTable)

    end
end

local kStatusTranslationStringMap = GetUpValue(Scoreboard_ReloadPlayerData, "kStatusTranslationStringMap", { LocateRecurse = true })
if kStatusTranslationStringMap then
	kStatusTranslationStringMap[kPlayerStatus.HeavyMachineGun] = "HMG"
end

local kEquipmentOutlineColor = enum { [0]='TSFBlue', 'Green', 'Fuchsia', 'Yellow', 'Red' }
local kEquipmentOutlineModelLookup = GetUpValue( EquipmentOutline_UpdateModel, "lookup" )
if kEquipmentOutlineModelLookup then
	table.insert(kEquipmentOutlineModelLookup, "HeavyMachineGun")
	ReplaceLocals(EquipmentOutline_UpdateModel, { lookup = kEquipmentOutlineModelLookup })
end

local kTechIdToMaterialOffset = GetUpValue(GetMaterialXYOffset, "kTechIdToMaterialOffset")
if kTechIdToMaterialOffset then
	kTechIdToMaterialOffset[kTechId.HeavyMachineGun] = 73
	kTechIdToMaterialOffset[kTechId.Electrify] = 3
end
